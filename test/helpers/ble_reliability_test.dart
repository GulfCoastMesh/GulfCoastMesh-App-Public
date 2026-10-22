import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/ble_reliability.dart';

void main() {
  group('isAttMtuSufficientForMeshCore', () {
    test('requires 175', () {
      expect(isAttMtuSufficientForMeshCore(174), isFalse);
      expect(isAttMtuSufficientForMeshCore(175), isTrue);
      expect(isAttMtuSufficientForMeshCore(185), isTrue);
      expect(isAttMtuSufficientForMeshCore(23), isFalse);
    });
  });

  group('MeshCore ATT MTU compatibility', () {
    test('rejects MTUs below 172', () {
      expect(isAttMtuCompatibleWithMeshCore(171), isFalse);
    });

    test('accepts MTU 172 in compatibility mode', () {
      expect(isAttMtuCompatibleWithMeshCore(172), isTrue);
      expect(isAttMtuCompatibilityMode(172), isTrue);
    });

    test('treats MTU 175 as fully supported', () {
      expect(isAttMtuCompatibleWithMeshCore(175), isTrue);
      expect(isAttMtuCompatibilityMode(175), isFalse);
      expect(isAttMtuSufficientForMeshCore(175), isTrue);
    });
  });

  group('attPayloadBudget', () {
    test('reserves the three-byte ATT write header', () {
      expect(attPayloadBudget(172), 169);
      expect(attPayloadBudget(175), 172);
    });
  });

  group('shouldWriteWithoutResponse', () {
    test('prefers with-response when available', () {
      expect(
        shouldWriteWithoutResponse(
          payloadLength: 172,
          attMtu: 185,
          canWriteWithResponse: true,
          canWriteWithoutResponse: true,
        ),
        isFalse,
      );
    });

    test('rejects oversized payloads even with-response', () {
      expect(
        () => shouldWriteWithoutResponse(
          payloadLength: 170,
          attMtu: 172,
          canWriteWithResponse: true,
          canWriteWithoutResponse: true,
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Payload 170 exceeds ATT payload limit 169 (ATT MTU 172)',
          ),
        ),
      );
    });

    test('uses WoR only when with-response missing and payload fits', () {
      expect(
        shouldWriteWithoutResponse(
          payloadLength: 20,
          attMtu: 23,
          canWriteWithResponse: false,
          canWriteWithoutResponse: true,
        ),
        isTrue,
      );
    });

    test('rejects oversized payloads with only WoR', () {
      expect(
        () => shouldWriteWithoutResponse(
          payloadLength: 170,
          attMtu: 172,
          canWriteWithResponse: false,
          canWriteWithoutResponse: true,
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Payload 170 exceeds ATT payload limit 169 (ATT MTU 172)',
          ),
        ),
      );
    });

    test('throws when neither write mode is available', () {
      expect(
        () => shouldWriteWithoutResponse(
          payloadLength: 10,
          attMtu: 185,
          canWriteWithResponse: false,
          canWriteWithoutResponse: false,
        ),
        throwsArgumentError,
      );
    });
  });

  group('awaitBleWrite', () {
    test('returns a completing write unchanged', () async {
      final result = await awaitBleWrite<String>(
        frameDescription: 'MeshCore command 0x02 (8 bytes)',
        write: () async => 'written',
      );

      expect(result, 'written');
    });

    test('reports a recognizable timeout for a stalled write', () async {
      final stalledWrite = Completer<void>();

      await expectLater(
        awaitBleWrite<void>(
          frameDescription: 'MeshCore command 0x03 (172 bytes)',
          timeout: const Duration(milliseconds: 1),
          write: () => stalledWrite.future,
        ),
        throwsA(
          isA<TimeoutException>()
              .having(
                (error) => error.message,
                'message',
                contains('BLE write timed out'),
              )
              .having(
                (error) => error.message,
                'frame',
                contains('command 0x03 (172 bytes)'),
              ),
        ),
      );
    });

    test('uses the eight-second production timeout by default', () {
      expect(bleWriteTimeout, const Duration(seconds: 8));
    });
  });

  group('isFatalBluetoothAdapterStateName', () {
    test('only tears down on off or unauthorized', () {
      expect(isFatalBluetoothAdapterStateName('off'), isTrue);
      expect(isFatalBluetoothAdapterStateName('unauthorized'), isTrue);
      expect(isFatalBluetoothAdapterStateName('on'), isFalse);
      expect(isFatalBluetoothAdapterStateName('unknown'), isFalse);
      expect(isFatalBluetoothAdapterStateName('turningOn'), isFalse);
    });
  });

  group('resolveAttMtu', () {
    test('uses a successful requested MTU when compatible', () async {
      expect(
        await resolveAttMtu(
          requestedMtu: 185,
          mtuNow: 23,
          waitForNegotiated: (_) async => 23,
        ),
        185,
      );
    });

    test('uses mtuNow when already compatible', () async {
      expect(
        await resolveAttMtu(
          requestedMtu: null,
          mtuNow: 172,
          waitForNegotiated: (_) async => 23,
        ),
        172,
      );
    });

    test('waits for negotiation when mtuNow is still 23', () async {
      expect(
        await resolveAttMtu(
          requestedMtu: null,
          mtuNow: 23,
          waitForNegotiated: (_) async => 185,
        ),
        185,
      );
    });

    test('falls back to mtuNow when negotiation times out', () async {
      expect(
        await resolveAttMtu(
          requestedMtu: null,
          mtuNow: 23,
          timeout: const Duration(milliseconds: 1),
          waitForNegotiated: (timeout) async {
            throw TimeoutException('mtu wait', timeout);
          },
        ),
        23,
      );
    });
  });
}
