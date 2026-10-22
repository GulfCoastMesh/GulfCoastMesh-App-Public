import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nordic_dfu/nordic_dfu.dart';

/// Thrown when more than one OTA/DFU peripheral is advertising nearby.
class AmbiguousDfuTargetException implements Exception {
  AmbiguousDfuTargetException(this.candidates);

  final List<DfuCandidate> candidates;

  @override
  String toString() =>
      'Multiple DFU devices found nearby: '
      '${candidates.map((c) => '"${c.name}"').join(', ')}';
}

class DfuCandidate {
  final String address;
  final String name;

  const DfuCandidate({required this.address, required this.name});
}

/// Runs a Nordic Secure DFU against an nRF52 repeater that has entered OTA
/// mode via the `start ota` CLI command.
class NrfDfuService {
  static const int dfuPacketCount = 8;

  /// Resolves the DFU target address.
  ///
  /// On Android we can address peripherals by MAC, but the MAC the repeater
  /// returns in its `start ota` reply rides the LoRa mesh and is not
  /// authenticated end-to-end. To avoid blindly pointing Nordic DFU at any
  /// address an attacker can inject, we still kick off a local BLE scan and
  /// confirm that the device at that MAC is currently advertising a known
  /// DFU-mode name (`*_OTA` / `*_DFU` / `AdaDFU`) before using it. If the
  /// verification fails we fall back to scan-based discovery (the same path
  /// iOS uses) so we never target an unverified address.
  ///
  /// iOS identifies peripherals by UUID, so we always go straight to the
  /// scan-based path.
  Future<String?> resolveTarget({
    String? macFromReply,
    Duration timeout = const Duration(seconds: 20),
    void Function(String)? onLog,
  }) async {
    if (Platform.isAndroid && macFromReply != null) {
      onLog?.call('Verifying DFU MAC from repeater reply: $macFromReply');
      final verifiedAddress = await _verifyDfuMacByScan(
        mac: macFromReply,
        timeout: timeout,
        onLog: onLog,
      );
      if (verifiedAddress != null) {
        onLog?.call(
          'Verified DFU advertisement at $verifiedAddress; proceeding.',
        );
        // Return the address exactly as flutter_blue_plus reported it so we
        // match the format Nordic DFU expects, instead of whatever casing /
        // separator the mesh reply happened to use.
        return verifiedAddress;
      }
      onLog?.call(
        'No DFU advertisement seen for $macFromReply within '
        '${timeout.inSeconds}s; falling back to nearby DFU scan.',
      );
      // Fall through so we never silently target an unverified MAC.
    }
    return _scanForDfuDevice(timeout: timeout, onLog: onLog);
  }

  /// Returns the canonical address of a BLE peripheral at [mac] that is
  /// currently advertising in DFU mode, or null if none is seen within the
  /// scan window. Used to confirm a mesh-supplied MAC actually belongs to
  /// the repeater that just entered OTA mode (and isn't a spoofed redirect).
  Future<String?> _verifyDfuMacByScan({
    required String mac,
    required Duration timeout,
    void Function(String)? onLog,
  }) async {
    final normalized = mac.trim().toUpperCase();
    final completer = Completer<String?>();

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final address = result.device.remoteId.str;
        if (address.toUpperCase() != normalized) continue;

        final name = result.advertisementData.advName.isNotEmpty
            ? result.advertisementData.advName
            : result.device.platformName;
        if (_isDfuName(name)) {
          if (!completer.isCompleted) completer.complete(address);
          return;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: timeout);
      return await completer.future.timeout(
        timeout + const Duration(seconds: 2),
        onTimeout: () => null,
      );
    } finally {
      await subscription.cancel();
      try {
        await FlutterBluePlus.stopScan();
      } on Exception {
        // Scan may have already stopped.
      }
    }
  }

  Future<String?> _scanForDfuDevice({
    required Duration timeout,
    void Function(String)? onLog,
  }) async {
    onLog?.call('Scanning for OTA/DFU advertisement...');
    final candidates = <String, DfuCandidate>{};
    final completer = Completer<String?>();

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final name = result.advertisementData.advName.isNotEmpty
            ? result.advertisementData.advName
            : result.device.platformName;
        if (name.isEmpty) continue;
        if (!_isDfuName(name)) continue;

        final address = result.device.remoteId.str;
        candidates[address] = DfuCandidate(address: address, name: name);
      }

      if (candidates.length > 1 && !completer.isCompleted) {
        completer.completeError(
          AmbiguousDfuTargetException(candidates.values.toList()),
        );
        return;
      }
      if (candidates.length == 1 && !completer.isCompleted) {
        final candidate = candidates.values.first;
        onLog?.call(
          'Found DFU target "${candidate.name}" (${candidate.address})',
        );
        completer.complete(candidate.address);
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: timeout);
      final result = await completer.future.timeout(
        timeout + const Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (result == null && candidates.length > 1) {
        throw AmbiguousDfuTargetException(candidates.values.toList());
      }
      return result;
    } finally {
      await subscription.cancel();
      try {
        await FlutterBluePlus.stopScan();
      } on Exception {
        // Scan may have already stopped.
      }
    }
  }

  static bool _isDfuName(String name) {
    final upper = name.toUpperCase();
    return upper.endsWith('_OTA') ||
        upper.endsWith(' OTA') ||
        upper == 'ADADFU' ||
        upper.endsWith('_DFU');
  }

  /// Runs the DFU with MeshCore's recommended settings (PRN on, 8 packets,
  /// no resume) and reports progress 0-100.
  Future<void> startDfu({
    required String address,
    required String zipPath,
    required void Function(int percent) onProgress,
    void Function(String)? onLog,
  }) async {
    final completer = Completer<void>();

    await NordicDfu().startDfu(
      address,
      zipPath,
      numberOfPackets: dfuPacketCount,
      androidParameters: const AndroidParameters(
        packetReceiptNotificationsEnabled: true,
        startAsForegroundService: true,
        rebootTime: 0,
      ),
      darwinParameters: DarwinParameters(
        packetReceiptNotificationParameter: dfuPacketCount,
        disableResume: true,
        forceScanningForNewAddressInLegacyDfu: true,
        alternativeAdvertisingNameEnabled: false,
      ),
      dfuEventHandler: DfuEventHandler(
        onDeviceConnecting: (address) => onLog?.call('Connecting to $address'),
        onDfuProcessStarted: (address) => onLog?.call('DFU transfer started'),
        onEnablingDfuMode: (address) => onLog?.call('Enabling DFU mode'),
        onFirmwareValidating: (address) => onLog?.call('Validating firmware'),
        onProgressChanged:
            (address, percent, speed, avgSpeed, currentPart, totalParts) {
              onProgress(percent);
            },
        onDfuCompleted: (address) {
          onLog?.call('DFU completed');
          if (!completer.isCompleted) completer.complete();
        },
        onDfuAborted: (address) {
          onLog?.call('DFU aborted');
          if (!completer.isCompleted) {
            completer.completeError(Exception('DFU aborted'));
          }
        },
        onError: (address, error, errorType, message) {
          onLog?.call('DFU error $error ($errorType): $message');
          if (!completer.isCompleted) {
            completer.completeError(Exception('DFU error: $message'));
          }
        },
      ),
    );

    return completer.future;
  }

  Future<void> abort() async {
    try {
      await NordicDfu().abortDfu();
    } on Exception {
      // No DFU in flight.
    }
  }
}
