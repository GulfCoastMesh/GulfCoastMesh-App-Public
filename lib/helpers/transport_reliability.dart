// Pure session-policy helpers shared by every transport (BLE, USB serial, TCP).
// Kept free of transport packages so they can be unit-tested, and so the
// connector never has to import BLE code to make a session decision.

/// Whether a transport state transition should trigger unexpected-drop teardown.
///
/// Transport emits `disconnecting` then `disconnected` on link loss. The
/// connector must react on the first of those while still session-active,
/// otherwise reconnect never schedules.
bool shouldHandleUnexpectedDisconnect({
  required bool manualDisconnect,
  required bool alreadyHandling,
  required String connectorStateName,
  required String transportStateName,
}) {
  if (manualDisconnect || alreadyHandling) return false;
  final sessionActive =
      connectorStateName == 'connected' ||
      connectorStateName == 'connecting' ||
      connectorStateName == 'disconnecting';
  if (!sessionActive) return false;
  return transportStateName == 'disconnecting' ||
      transportStateName == 'disconnected';
}

/// Whether a completed disconnect may clear transport fields for [currentGeneration].
bool canApplyDisconnectTeardown({
  required int disconnectGeneration,
  required int currentGeneration,
}) => disconnectGeneration == currentGeneration;

/// Whether hub screens should pop back to the scanner.
///
/// A reconnect give-up is NOT treated as leaving the session: background
/// retries continue indefinitely after give-up (see meshcore_connector.dart),
/// so a hub screen must stay mounted and let the app bar's reconnecting
/// indicator communicate status instead of unwinding the whole nav stack.
bool shouldLeaveHub({
  required bool isConnected,
  required bool isConnecting,
  required bool manualDisconnect,
  required bool hadHealthySession,
  required bool hasLastDevice,
}) {
  if (isConnected || isConnecting) return false;
  if (manualDisconnect) return true;
  if (hadHealthySession && hasLastDevice) return false;
  return true;
}

/// Whether returning to the foreground should kick another reconnect attempt.
bool shouldReconnectOnResume({
  required bool manualDisconnect,
  required bool hadHealthySession,
  required bool hasLastDevice,
  required String connectorStateName,
}) {
  if (manualDisconnect || !hadHealthySession || !hasLastDevice) {
    return false;
  }
  return connectorStateName != 'connected' &&
      connectorStateName != 'connecting';
}

/// Whether [_waitForSelfInfo] may accept the current pubkey as this connect.
bool isSelfInfoFresh({
  required int connectGeneration,
  required int lastSelfInfoGeneration,
}) => connectGeneration > 0 && connectGeneration == lastSelfInfoGeneration;
