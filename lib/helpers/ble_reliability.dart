import 'dart:async';

// Pure helpers for BLE write selection and ATT/MTU negotiation.
// Kept free of flutter_blue_plus so they can be unit-tested. Transport-neutral
// session policy lives in transport_reliability.dart instead.

/// Maximum time to wait for a companion BLE characteristic write.
const Duration bleWriteTimeout = Duration(seconds: 8);

/// Minimum ATT MTU needed for MeshCore frames (`maxFrameSize` 172 + 3 ATT overhead).
const int minMeshCoreAttMtu = 175;

/// Smallest ATT MTU supported by current MeshCore firmware.
///
/// At this size, writes are limited to 169 bytes. This supports normal
/// commands but not every possible 172-byte MeshCore frame.
const int minCompatibleMeshCoreAttMtu = 172;

/// Default ATT MTU when negotiation has not reported a value yet.
const int defaultAttMtu = 23;

/// How long to wait for the platform to publish a negotiated ATT MTU.
const Duration negotiatedMtuWaitTimeout = Duration(seconds: 3);

/// Whether [attMtu] is large enough for a full MeshCore companion frame.
bool isAttMtuSufficientForMeshCore(int attMtu) => attMtu >= minMeshCoreAttMtu;

/// Whether [attMtu] can connect to MeshCore, including its 172-byte fallback.
bool isAttMtuCompatibleWithMeshCore(int attMtu) =>
    attMtu >= minCompatibleMeshCoreAttMtu;

/// Whether [attMtu] supports normal MeshCore operation but not all frames.
bool isAttMtuCompatibilityMode(int attMtu) =>
    isAttMtuCompatibleWithMeshCore(attMtu) &&
    !isAttMtuSufficientForMeshCore(attMtu);

/// Maximum payload bytes permitted in one ATT write for [attMtu].
///
/// ATT reserves three bytes for its write header. MeshCore frames are never
/// fragmented or truncated by the transport, so every write must fit here.
int attPayloadBudget(int attMtu) => attMtu > 3 ? attMtu - 3 : 0;

/// Throws when [payloadLength] cannot fit in a single ATT write.
void validateAttPayloadLength({
  required int payloadLength,
  required int attMtu,
}) {
  final payloadBudget = attPayloadBudget(attMtu);
  if (payloadLength > payloadBudget) {
    throw StateError(
      'Payload $payloadLength exceeds ATT payload limit $payloadBudget '
      '(ATT MTU $attMtu)',
    );
  }
}

/// Decide whether to use BLE write-without-response for [payloadLength].
///
/// Prefer with-response when available. Only use WoR when with-response is
/// unavailable and the payload fits in a single ATT write (`attMtu - 3`).
bool shouldWriteWithoutResponse({
  required int payloadLength,
  required int attMtu,
  required bool canWriteWithResponse,
  required bool canWriteWithoutResponse,
}) {
  if (!canWriteWithoutResponse && !canWriteWithResponse) {
    throw ArgumentError('Characteristic supports neither write mode');
  }
  validateAttPayloadLength(payloadLength: payloadLength, attMtu: attMtu);
  if (canWriteWithResponse) return false;
  return true;
}

/// Completes [write], failing when a companion BLE write stops making progress.
///
/// [frameDescription] is retained in timeout errors so callers can tell which
/// outbound frame stalled without inspecting a platform-specific BLE error.
Future<T> awaitBleWrite<T>({
  required Future<T> Function() write,
  required String frameDescription,
  Duration timeout = bleWriteTimeout,
}) {
  return write().timeout(
    timeout,
    onTimeout: () => throw TimeoutException(
      'BLE write timed out after ${timeout.inSeconds} seconds for '
      '$frameDescription',
      timeout,
    ),
  );
}

/// Adapter states that should tear down an active BLE session.
/// Ignore unknown/turningOn — those fire at connect start on some platforms.
bool isFatalBluetoothAdapterStateName(String name) =>
    name == 'off' || name == 'unauthorized';

/// Resolve ATT MTU after connect. A failed Android-only [requestMtu] plus
/// [mtuNow] of 23 is not final on iOS/Linux — wait for negotiation.
Future<int> resolveAttMtu({
  required int? requestedMtu,
  required int mtuNow,
  required Future<int> Function(Duration timeout) waitForNegotiated,
  Duration timeout = negotiatedMtuWaitTimeout,
}) async {
  if (requestedMtu != null && isAttMtuCompatibleWithMeshCore(requestedMtu)) {
    return requestedMtu;
  }
  if (isAttMtuCompatibleWithMeshCore(mtuNow)) {
    return mtuNow;
  }
  try {
    return await waitForNegotiated(timeout);
  } on TimeoutException {
    return mtuNow;
  } catch (_) {
    return mtuNow;
  }
}
