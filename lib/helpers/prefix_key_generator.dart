import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;

import 'prefix_search_worker_count_stub.dart'
    if (dart.library.io) 'prefix_search_worker_count_io.dart'
    as worker_count;

/// Ed25519 keypair whose public key hex starts with [publicKeyHex] prefix.
class PrefixKeyPair {
  /// 128-char lowercase hex (64 bytes) for MeshCore `set prv.key`.
  ///
  /// Format matches MeshBuddy / orlp/ed25519:
  /// `SHA512(seed)` with the first 32 bytes clamped — **not** Dart `seed∥pubkey`.
  final String privateKeyHex;

  /// 64-char lowercase hex public key.
  final String publicKeyHex;

  /// How many candidate keys were tried before this match (inclusive).
  final int attempts;

  const PrefixKeyPair({
    required this.privateKeyHex,
    required this.publicKeyHex,
    required this.attempts,
  });
}

/// MeshCore keypair bytes (private 64 + public 32).
class MeshCoreKeypairBytes {
  final Uint8List privateKey;
  final Uint8List publicKey;

  const MeshCoreKeypairBytes({
    required this.privateKey,
    required this.publicKey,
  });
}

/// Converts an RFC 8032 32-byte seed into MeshCore's 64-byte private key.
///
/// MeshCore (orlp/ed25519) stores `SHA512(seed)` with clamping on the first
/// 32 bytes. Dart `ed25519_edwards` stores `seed∥pubkey` instead; sending that
/// format makes firmware `validatePrivateKey` reject the key as "Error, bad key".
Uint8List expandSeedToMeshCorePrivateKey(List<int> seed) {
  if (seed.length != 32) {
    throw ArgumentError.value(seed.length, 'seed.length', 'expected 32 bytes');
  }
  final expanded = Uint8List.fromList(sha512.convert(seed).bytes);
  expanded[0] &= 248;
  expanded[31] &= 63;
  expanded[31] |= 64;
  return expanded;
}

/// MeshBuddy / mc-keygen algorithm for a fixed seed:
/// 1. SHA-512(seed) → 64 bytes
/// 2. Clamp first 32 bytes
/// 3. Public key = Ed25519 base-point × clamped scalar (via ed25519_edwards)
/// 4. Private key = clamped_scalar ∥ sha512[32..64]
MeshCoreKeypairBytes generateMeshCoreKeypairFromSeed(List<int> seed) {
  if (seed.length != 32) {
    throw ArgumentError.value(seed.length, 'seed.length', 'expected 32 bytes');
  }
  final seedBytes = seed is Uint8List ? seed : Uint8List.fromList(seed);
  final dartPrivate = ed25519.newKeyFromSeed(seedBytes);
  return MeshCoreKeypairBytes(
    privateKey: expandSeedToMeshCorePrivateKey(seedBytes),
    publicKey: Uint8List.fromList(dartPrivate.bytes.sublist(32)),
  );
}

final _hex = RegExp(r'^[0-9a-fA-F]+$');
const _hexChars = '0123456789abcdef';

/// Returns true when [prefix] is valid hex suitable for vanity search.
bool isValidKeyPrefix(String prefix, {int? expectedLength}) {
  final trimmed = prefix.trim();
  if (trimmed.isEmpty) return false;
  if (expectedLength != null && trimmed.length != expectedLength) return false;
  if (!_hex.hasMatch(trimmed)) return false;
  // MeshCore LocalIdentity::validatePrivateKey rejects pub[0] of 0x00 / 0xFF.
  if (trimmed.length >= 2) {
    final firstByte = trimmed.substring(0, 2).toLowerCase();
    if (firstByte == '00' || firstByte == 'ff') return false;
  }
  return true;
}

/// Expected attempts for a uniform hex prefix of the given length.
int expectedAttemptsForPrefix(String prefix) {
  final len = prefix.trim().length;
  if (len <= 0) return 1;
  return pow(16, len).toInt();
}

/// Parallel workers used by [findPrefixKey] on this platform.
int get parallelPrefixSearchWorkerCount =>
    worker_count.parallelPrefixSearchWorkers;

/// Whether [findPrefixKey] offloads search to background isolates.
bool get parallelPrefixSearchUsesIsolates =>
    worker_count.supportsParallelPrefixIsolates;

class _PrefixNibbles {
  final List<int> values;

  _PrefixNibbles(String hexPrefix)
    : values = List<int>.generate(
        hexPrefix.length,
        (i) => _hexCharToNibble(hexPrefix.codeUnitAt(i)),
      );

  bool matchesPublicKeyBytes(List<int> pubBytes) {
    // Reject MeshCore-invalid first bytes (MeshBuddy should_skip).
    if (pubBytes.isNotEmpty && (pubBytes[0] == 0x00 || pubBytes[0] == 0xFF)) {
      return false;
    }
    for (var i = 0; i < values.length; i++) {
      final byte = pubBytes[i >> 1];
      final nibble = (i & 1) == 0 ? (byte >> 4) : (byte & 0x0f);
      if (nibble != values[i]) return false;
    }
    return true;
  }
}

int _hexCharToNibble(int codeUnit) {
  if (codeUnit >= 48 && codeUnit <= 57) return codeUnit - 48; // 0-9
  if (codeUnit >= 97 && codeUnit <= 102) return codeUnit - 87; // a-f
  return codeUnit - 55; // A-F
}

/// Synchronous vanity search — useful for unit tests with short prefixes.
PrefixKeyPair? findPrefixKeySync(
  String prefix, {
  int maxAttempts = 1 << 20,
  void Function(int attempts)? onProgress,
  bool Function()? isCancelled,
  int progressEvery = 256,
}) {
  final target = prefix.trim().toLowerCase();
  if (!isValidKeyPrefix(target)) {
    throw ArgumentError.value(prefix, 'prefix', 'invalid key prefix');
  }
  final matcher = _PrefixNibbles(target);

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    if (isCancelled?.call() ?? false) return null;
    final pair = ed25519.generateKey();
    if (matcher.matchesPublicKeyBytes(pair.publicKey.bytes)) {
      return PrefixKeyPair(
        privateKeyHex: _toHex(
          expandSeedToMeshCorePrivateKey(ed25519.seed(pair.privateKey)),
        ),
        publicKeyHex: _toHex(pair.publicKey.bytes),
        attempts: attempt,
      );
    }
    if (onProgress != null &&
        (attempt % progressEvery == 0 || attempt == maxAttempts)) {
      onProgress(attempt);
    }
  }
  return null;
}

/// Vanity search using MeshBuddy-style parallel workers.
///
/// Workers are long-lived (no per-batch isolate spawn) and capped below full
/// CPU so the Flutter UI isolate can keep animating the spinner.
Future<PrefixKeyPair?> findPrefixKey(
  String prefix, {
  void Function(int attempts)? onProgress,
  bool Function()? isCancelled,
  int batchSize = 1024,
  int? workerCount,
  Duration progressMinInterval = const Duration(milliseconds: 150),
}) async {
  final target = prefix.trim().toLowerCase();
  if (!isValidKeyPrefix(target)) {
    throw ArgumentError.value(prefix, 'prefix', 'invalid key prefix');
  }

  if (!worker_count.supportsParallelPrefixIsolates) {
    return _findPrefixKeySequential(
      target,
      onProgress: onProgress,
      isCancelled: isCancelled,
      batchSize: batchSize,
    );
  }

  final workers = workerCount ?? worker_count.parallelPrefixSearchWorkers;
  final resultPort = ReceivePort();
  final controlPorts = <SendPort>[];
  final isolates = <Isolate>[];

  try {
    for (var i = 0; i < workers; i++) {
      final readyPort = ReceivePort();
      isolates.add(
        await Isolate.spawn(
          _prefixWorkerMain,
          _PrefixWorkerArgs(
            readyPort.sendPort,
            resultPort.sendPort,
            target,
            batchSize,
          ),
        ),
      );
      controlPorts.add(await readyPort.first as SendPort);
      readyPort.close();
    }

    var totalAttempts = 0;
    var lastProgressAttempts = 0;
    DateTime? lastProgressTime;
    final completer = Completer<PrefixKeyPair?>();

    void reportProgress(int attempts) {
      if (onProgress == null) return;
      final now = DateTime.now();
      if (lastProgressTime != null &&
          now.difference(lastProgressTime!) < progressMinInterval &&
          attempts - lastProgressAttempts < batchSize) {
        return;
      }
      lastProgressTime = now;
      lastProgressAttempts = attempts;
      onProgress(attempts);
    }

    late final StreamSubscription<dynamic> subscription;
    subscription = resultPort.listen((message) {
      if (completer.isCompleted) return;
      if (message is! _BatchResult) return;

      totalAttempts += message.attempts;
      reportProgress(totalAttempts);

      if (message.privateKeyHex != null && message.publicKeyHex != null) {
        subscription.cancel();
        completer.complete(
          PrefixKeyPair(
            privateKeyHex: message.privateKeyHex!,
            publicKeyHex: message.publicKeyHex!,
            attempts:
                totalAttempts - message.attempts + message.matchedAttempt!,
          ),
        );
        return;
      }

      if (isCancelled?.call() ?? false) {
        subscription.cancel();
        completer.complete(null);
      }
    });

    while (!completer.isCompleted) {
      if (isCancelled?.call() ?? false) {
        await subscription.cancel();
        return null;
      }
      // Poll cancel without busy-spinning; workers keep crunching.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    return await completer.future;
  } finally {
    for (final port in controlPorts) {
      port.send(_prefixWorkerCancel);
    }
    for (final isolate in isolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    resultPort.close();
  }
}

Future<PrefixKeyPair?> _findPrefixKeySequential(
  String target, {
  void Function(int attempts)? onProgress,
  bool Function()? isCancelled,
  required int batchSize,
}) async {
  var totalAttempts = 0;
  while (true) {
    if (isCancelled?.call() ?? false) return null;
    final batch = await Isolate.run(() => _searchBatch(target, batchSize));
    totalAttempts += batch.attempts;
    onProgress?.call(totalAttempts);
    if (batch.privateKeyHex != null && batch.publicKeyHex != null) {
      return PrefixKeyPair(
        privateKeyHex: batch.privateKeyHex!,
        publicKeyHex: batch.publicKeyHex!,
        attempts: totalAttempts - batch.attempts + batch.matchedAttempt!,
      );
    }
    await Future<void>.delayed(Duration.zero);
  }
}

class _PrefixWorkerArgs {
  final SendPort readyPort;
  final SendPort resultPort;
  final String target;
  final int batchSize;

  const _PrefixWorkerArgs(
    this.readyPort,
    this.resultPort,
    this.target,
    this.batchSize,
  );
}

const _prefixWorkerCancel = Object();

void _prefixWorkerMain(_PrefixWorkerArgs args) {
  final controlPort = ReceivePort();
  args.readyPort.send(controlPort.sendPort);

  var cancelled = false;
  controlPort.listen((message) {
    if (identical(message, _prefixWorkerCancel)) {
      cancelled = true;
      controlPort.close();
    }
  });

  final matcher = _PrefixNibbles(args.target);
  while (!cancelled) {
    final batch = _searchBatchWithMatcher(matcher, args.batchSize);
    args.resultPort.send(batch);
    if (batch.privateKeyHex != null) return;
  }
}

class _BatchResult {
  final int attempts;
  final String? privateKeyHex;
  final String? publicKeyHex;
  final int? matchedAttempt;

  const _BatchResult({
    required this.attempts,
    this.privateKeyHex,
    this.publicKeyHex,
    this.matchedAttempt,
  });
}

_BatchResult _searchBatch(String target, int batchSize) {
  return _searchBatchWithMatcher(_PrefixNibbles(target), batchSize);
}

/// Hot loop — only expands to MeshCore private-key format on a match.
_BatchResult _searchBatchWithMatcher(_PrefixNibbles matcher, int batchSize) {
  for (var i = 1; i <= batchSize; i++) {
    final pair = ed25519.generateKey();
    if (matcher.matchesPublicKeyBytes(pair.publicKey.bytes)) {
      final meshPrivate = expandSeedToMeshCorePrivateKey(
        ed25519.seed(pair.privateKey),
      );
      return _BatchResult(
        attempts: i,
        privateKeyHex: _toHex(meshPrivate),
        publicKeyHex: _toHex(pair.publicKey.bytes),
        matchedAttempt: i,
      );
    }
  }
  return _BatchResult(attempts: batchSize);
}

String _toHex(List<int> bytes) {
  final buffer = StringBuffer();
  for (final b in bytes) {
    buffer.write(_hexChars[b >> 4]);
    buffer.write(_hexChars[b & 0x0f]);
  }
  return buffer.toString();
}

/// Parses the pubkey from a MeshCore `set prv.key` reply.
String? parseNewPubkeyFromSetPrvKeyReply(String reply) {
  final match = RegExp(
    r'New pubkey:\s*([0-9a-fA-F]{64})',
    caseSensitive: false,
  ).firstMatch(reply);
  return match?.group(1)?.toLowerCase();
}

/// Returns the new pubkey only for a successful `set prv.key` device reply.
///
/// Firmware success looks like:
/// `OK, reboot to apply! New pubkey: <64 hex>`
/// Failures such as `Error, bad key` or bare `OK` return null.
String? parseSuccessfulSetPrvKeyReply(String reply) {
  final trimmed = reply.trim();
  if (trimmed.isEmpty) return null;
  final lower = trimmed.toLowerCase();
  if (lower.contains('error') || lower.contains('bad key')) return null;
  return parseNewPubkeyFromSetPrvKeyReply(trimmed);
}

/// Builds the CLI command. [privateKeyHex] must be 128 hex chars (64 bytes).
String buildSetPrivateKeyCommand(String privateKeyHex) {
  final hex = privateKeyHex.trim().toLowerCase();
  if (hex.length != 128 || !_hex.hasMatch(hex)) {
    throw ArgumentError.value(
      privateKeyHex,
      'privateKeyHex',
      'expected 128 hex characters',
    );
  }
  return 'set prv.key $hex';
}
