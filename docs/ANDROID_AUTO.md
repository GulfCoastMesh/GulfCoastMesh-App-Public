# Android Auto

Gulf Coast Mesh App integrates with Android Auto as a **notification-based messaging app**.
Android Auto supplies the text-to-speech read-aloud and the voice dictation
itself; the app only publishes each mesh message as a `MessagingStyle`
notification and routes the dictated reply back through the same
`MeshCoreConnector` the phone UI uses.

This deliberately avoids the Car App Library (`androidx.car.app`): its messaging
templates are heavily restricted, it needs a Play Console Android Auto
declaration and category review, and none of that buys anything for a read-and-
reply flow. It also means driver-distraction handling is the platform's, not
ours — there is no Gulf Coast Mesh App UI on the car screen at all.

## How it fits together

| Piece | File | Role |
|---|---|---|
| Descriptor | `android/app/src/main/res/xml/automotive_app_desc.xml` | Declares `<uses name="notification"/>` |
| Manifest | `AndroidManifest.xml` | `com.google.android.gms.car.application` meta-data + the (non-exported) `CarReplyReceiver` |
| Notification builder | `CarMessagingBridge.kt` | `MessagingStyle` + `Person`, reply action with `RemoteInput`, mark-as-read action |
| Reply receiver | `CarReplyReceiver.kt` | Pulls the dictated text out of `RemoteInput` |
| Channels | `MainActivity.kt` | `MethodChannel` (Dart→native) and `EventChannel` (native→Dart) |
| Dart bridge | `lib/services/car_messaging_service.dart` | Publishes messages, routes replies to the connector |
| Message source | `MeshCoreConnector.notifiableMessages` | Fires alongside the in-app notification |

**Why native rather than `flutter_local_notifications`:** Android Auto only
recognises a reply action that carries `SEMANTIC_ACTION_REPLY` (and mark-as-read
carrying `SEMANTIC_ACTION_MARK_AS_READ`). That plugin does not expose
`setSemanticAction`, so the notification would be built but Auto would ignore its
actions.

## Behaviour worth knowing

- **Mute settings are inherited, not duplicated.** `notifiableMessages` fires at
  exactly the points the in-app notifications fire, after
  `notificationsEnabled`, `notifyOnNewMessage` / `notifyOnNewChannelMessage`, the
  per-conversation `NotificationPref`, and the mentions filter have all passed.
  Silencing a conversation on the phone silences it in the car.
- **A conversation open on the phone is not announced in the car**, via
  `activeContactKey` / `activeChannelIndex`.
- **Replies go through the same connection.** `connector.sendMessage` /
  `sendChannelMessage`, so they get the same retry, path selection and delivery
  tracking as a message typed on the phone.
- **Dictation is truncated, not rejected.** Mesh text caps at 160 bytes and voice
  input overruns that easily, so the reply is trimmed on a UTF-8 boundary and the
  driver is told it was shortened.
- **Failures are spoken, not swallowed.** No connection, unknown contact/channel,
  or a send error posts a message back into the same car thread — the driver
  cannot see the phone, so silence would read as "sent".
- **Replies need a live session.** Android Auto fires the reply intent without
  opening the app. Within a running process a short queue bridges the gap until
  the Flutter engine attaches. If the app was fully killed there is no mesh
  connection either, so the reply could not have been sent regardless.

## Testing with the Desktop Head Unit

**This cannot be verified from CI or a headless environment — it needs a phone
and the DHU, or real car hardware.**

1. Install Android Auto on the phone, open it, and tap the version 10 times to
   unlock developer mode. In the overflow menu enable **Developer settings**, then
   **Unknown sources**.
2. Install the DHU: Android Studio → SDK Manager → SDK Tools → **Android Auto
   Desktop Head Unit Emulator**. It lands in
   `~/Android/Sdk/extras/google/auto/desktop-head-unit`.
3. Build and install:
   ```bash
   ~/flutter/bin/flutter build apk --release --dart-define-from-file=dart_defines.json
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
4. Start head-unit server mode on the phone (Android Auto → Developer settings →
   **Start head unit server**), then:
   ```bash
   adb forward tcp:5277 tcp:5277
   ~/Android/Sdk/extras/google/auto/desktop-head-unit/desktop-head-unit
   ```

### Test script

Needs a second MeshCore node to send from.

| # | Step | Expected |
|---|---|---|
| 1 | Connect Gulf Coast Mesh App to a companion radio, leave the app backgrounded | Foreground service notification shows the active transport |
| 2 | Send a DM from the second node | DHU announces sender and message aloud |
| 3 | Tap Reply in the DHU, dictate a short message | Message arrives at the second node; no phone interaction needed |
| 4 | Check the phone's chat screen | The dictated reply appears in history like any sent message |
| 5 | Send a channel message from the second node | Announced with the channel name as the conversation title |
| 6 | Reply to the channel from the DHU | Lands on the correct channel, not the DM |
| 7 | Open the DM on the phone, send another from node two | **Not** announced in the car — already being read |
| 8 | Mute the conversation on the phone, send again | **Not** announced in the car |
| 9 | Disconnect the radio, then reply from the DHU | Thread reports "Not connected to a MeshCore device" |
| 10 | Dictate something very long (>160 bytes) | Sent truncated; thread reports it was shortened |
| 11 | Tap Mark as read in the DHU | Notification clears; unread count clears on the phone |
| 12 | Revoke notification permission, send a message | No crash; app surfaces the permission state |

Steps 9–12 are the ones most likely to regress, since they are the paths that
only run when something has gone wrong.
