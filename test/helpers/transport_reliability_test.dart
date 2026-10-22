import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/transport_reliability.dart';

void main() {
  group('shouldHandleUnexpectedDisconnect', () {
    test('handles disconnecting while connected', () {
      expect(
        shouldHandleUnexpectedDisconnect(
          manualDisconnect: false,
          alreadyHandling: false,
          connectorStateName: 'connected',
          transportStateName: 'disconnecting',
        ),
        isTrue,
      );
    });

    test('handles disconnected while connected', () {
      expect(
        shouldHandleUnexpectedDisconnect(
          manualDisconnect: false,
          alreadyHandling: false,
          connectorStateName: 'connected',
          transportStateName: 'disconnected',
        ),
        isTrue,
      );
    });

    test('ignores second event while already handling', () {
      expect(
        shouldHandleUnexpectedDisconnect(
          manualDisconnect: false,
          alreadyHandling: true,
          connectorStateName: 'disconnecting',
          transportStateName: 'disconnected',
        ),
        isFalse,
      );
    });

    test('ignores manual disconnect', () {
      expect(
        shouldHandleUnexpectedDisconnect(
          manualDisconnect: true,
          alreadyHandling: false,
          connectorStateName: 'connected',
          transportStateName: 'disconnecting',
        ),
        isFalse,
      );
    });

    test('ignores transport connected events', () {
      expect(
        shouldHandleUnexpectedDisconnect(
          manualDisconnect: false,
          alreadyHandling: false,
          connectorStateName: 'connecting',
          transportStateName: 'connected',
        ),
        isFalse,
      );
    });

    test('ignores when already fully disconnected', () {
      expect(
        shouldHandleUnexpectedDisconnect(
          manualDisconnect: false,
          alreadyHandling: false,
          connectorStateName: 'disconnected',
          transportStateName: 'disconnected',
        ),
        isFalse,
      );
    });
  });

  group('canApplyDisconnectTeardown', () {
    test('allows teardown only for the current session generation', () {
      expect(
        canApplyDisconnectTeardown(
          disconnectGeneration: 3,
          currentGeneration: 3,
        ),
        isTrue,
      );
      expect(
        canApplyDisconnectTeardown(
          disconnectGeneration: 3,
          currentGeneration: 4,
        ),
        isFalse,
      );
    });
  });

  group('shouldLeaveHub', () {
    test('keeps hub while connected or connecting', () {
      expect(
        shouldLeaveHub(
          isConnected: true,
          isConnecting: false,
          manualDisconnect: false,
          hadHealthySession: true,
          hasLastDevice: true,
        ),
        isFalse,
      );
      expect(
        shouldLeaveHub(
          isConnected: false,
          isConnecting: true,
          manualDisconnect: false,
          hadHealthySession: true,
          hasLastDevice: true,
        ),
        isFalse,
      );
    });

    test('keeps hub during unexpected drop reconnect', () {
      expect(
        shouldLeaveHub(
          isConnected: false,
          isConnecting: false,
          manualDisconnect: false,
          hadHealthySession: true,
          hasLastDevice: true,
        ),
        isFalse,
      );
    });

    test('leaves hub on manual disconnect', () {
      expect(
        shouldLeaveHub(
          isConnected: false,
          isConnecting: false,
          manualDisconnect: true,
          hadHealthySession: false,
          hasLastDevice: false,
        ),
        isTrue,
      );
    });

    test('leaves hub on manual disconnect even with a healthy session', () {
      expect(
        shouldLeaveHub(
          isConnected: false,
          isConnecting: false,
          manualDisconnect: true,
          hadHealthySession: true,
          hasLastDevice: true,
        ),
        isTrue,
      );
    });

    test('keeps hub through reconnect give-up when session was healthy', () {
      // Background retries continue indefinitely after give-up, so the
      // hub must stay mounted rather than unwinding to the scanner.
      expect(
        shouldLeaveHub(
          isConnected: false,
          isConnecting: false,
          manualDisconnect: false,
          hadHealthySession: true,
          hasLastDevice: true,
        ),
        isFalse,
      );
    });

    test('leaves hub when a first connect never became healthy', () {
      expect(
        shouldLeaveHub(
          isConnected: false,
          isConnecting: false,
          manualDisconnect: false,
          hadHealthySession: false,
          hasLastDevice: true,
        ),
        isTrue,
      );
    });
  });

  group('shouldReconnectOnResume', () {
    test('retries after background drop', () {
      expect(
        shouldReconnectOnResume(
          manualDisconnect: false,
          hadHealthySession: true,
          hasLastDevice: true,
          connectorStateName: 'disconnected',
        ),
        isTrue,
      );
    });

    test('does not retry while already connecting or connected', () {
      expect(
        shouldReconnectOnResume(
          manualDisconnect: false,
          hadHealthySession: true,
          hasLastDevice: true,
          connectorStateName: 'connecting',
        ),
        isFalse,
      );
      expect(
        shouldReconnectOnResume(
          manualDisconnect: false,
          hadHealthySession: true,
          hasLastDevice: true,
          connectorStateName: 'connected',
        ),
        isFalse,
      );
    });

    test('does not retry after manual disconnect', () {
      expect(
        shouldReconnectOnResume(
          manualDisconnect: true,
          hadHealthySession: false,
          hasLastDevice: false,
          connectorStateName: 'disconnected',
        ),
        isFalse,
      );
    });
  });

  group('isSelfInfoFresh', () {
    test('rejects leftover pubkey from a previous connect generation', () {
      expect(
        isSelfInfoFresh(connectGeneration: 2, lastSelfInfoGeneration: 1),
        isFalse,
      );
      expect(
        isSelfInfoFresh(connectGeneration: 0, lastSelfInfoGeneration: 0),
        isFalse,
      );
    });

    test('accepts self-info from this connect generation', () {
      expect(
        isSelfInfoFresh(connectGeneration: 4, lastSelfInfoGeneration: 4),
        isTrue,
      );
    });
  });
}
