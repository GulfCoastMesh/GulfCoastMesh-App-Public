# Repository Guidelines

## Project Structure & Module Organization
- Core Flutter code is in `lib/`, with protocol definitions in `lib/connector/meshcore_protocol.dart` and transport/session state in `lib/connector/meshcore_connector.dart`.
- UI lives in `lib/screens/` and `lib/widgets/`, models in `lib/models/`, tests in `test/`, and platform runners in `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`.
- Chat list filters (`All | Unread | DMs | Channels | Rooms`) and node category chips (`Favorites | Contacts | Repeaters | Rooms`) use shared `FilterChipRow` (`lib/widgets/filter_chips.dart`) and filter enums in `lib/helpers/list_filters.dart`. Selected filters persist via `AppSettings.chatFilter` / `nodeCategoryFilter`.
- Contact favorites: `Contact.isFavorite` + `MeshCoreConnector.toggleContactFavorite`. "New" badge: `Contact.firstSeenAt` + `Contact.isNew` (7-day window); missing `firstSeenAt` on legacy contacts means not new.
- Adaptive layout: `HomeScreen` uses bottom `NavigationBar` below 600px width; at ≥600px it switches to `NavigationRail` + master-detail split for Chats/Nodes (`ContactDetailPanel` for node detail; embedded `ChatScreen`/`ChannelChatScreen` for conversations).

## Transports
- Three transports implement `MeshCoreTransport` (`lib/connector/meshcore_transport.dart`): BLE (`ble_meshcore_transport.dart`), USB serial (`usb_serial_meshcore_transport.dart`), and TCP (`tcp_meshcore_transport.dart`). `MeshCoreConnector` holds one per `MeshCoreTransportKind` and selects by `MeshCoreDevice.transportKind`.
- USB and TCP share `ByteStreamMeshCoreTransport` and `SerialFrameCodec`: byte streams have no frame boundaries, so frames are wrapped as `0x3C`/`0x3E` + 2-byte LE length. BLE needs none of this — one GATT notification is one frame.
- Everything above the transport (frame dispatch, handlers, reconnect backoff, self-info handshake) is transport-agnostic. See `docs/BLE_PROTOCOL.md` for the full frame reference.
- Saved endpoints live in `ConnectionProfile` / `ConnectionProfileStore`; auto-connect is opt-in per profile (`lib/services/connection_profile_service.dart`).

## Frames & Protocol Notes
- **`docs/BLE_PROTOCOL.md` is the authoritative frame reference.** The codes below are a quick index only; `lib/connector/meshcore_protocol.dart` is the source of truth.
- Nordic UART Service (NUS) UUIDs: Service `6e400001-b5a3-f393-e0a9-e50e24dcca9e`, RX `6e400002-b5a3-f393-e0a9-e50e24dcca9e`, TX `6e400003-b5a3-f393-e0a9-e50e24dcca9e`.
- Discovery: scans for device name prefix `MeshCore-` and filters by `platformName`/`advertisementData.advName`.
- Frames are capped at `maxFrameSize = 172` bytes; byte 0 is the command/response/push code. I/O is `MeshCoreConnector.sendFrame` and `MeshCoreConnector.receivedFrames`.
- Command codes (to device): `cmdAppStart`=1, `cmdSendTxtMsg`=2, `cmdSendChannelTxtMsg`=3, `cmdGetContacts`=4, `cmdGetDeviceTime`=5, `cmdSetDeviceTime`=6, `cmdSendSelfAdvert`=7, `cmdSetAdvertName`=8, `cmdAddUpdateContact`=9, `cmdSyncNextMessage`=10, `cmdSetRadioParams`=11, `cmdSetRadioTxPower`=12, `cmdResetPath`=13, `cmdSetAdvertLatLon`=14, `cmdRemoveContact`=15, `cmdShareContact`=16, `cmdExportContact`=17, `cmdImportContact`=18, `cmdReboot`=19, `cmdGetBattAndStorage`=20 (0x14), `cmdDeviceQuery`=22 (0x16), `cmdSendLogin`=26, `cmdSendStatusReq`=27 (0x1B), `cmdSendRawData`=25 (0x19), `cmdGetContactByKey`=30, `cmdGetChannel`=31, `cmdSetChannel`=32, `cmdSendTracePath`=36, `cmdSetOtherParams`=38 (0x26), `cmdGetTelemetryReq`=39 (0x27, deprecated — use binary requests), `cmdGetCustomVar`=40, `cmdSetCustomVar`=41, `cmdSendBinaryReq`=50 (0x32), `cmdSetFloodScopeKey`=54 (0x36), `cmdSendControlData`=55, `cmdGetStats`=56 (0x38), `cmdGetRadioSettings`=57, `cmdSetPathHashMode`=61 (0x3D), `cmdSendChannelData`=62 (0x3E), `cmdSetDefaultFloodScope`=63 (0x3F), `cmdGetDefaultFloodScope`=64 (0x40).
- Binary request sub-types (payload byte for `cmdSendBinaryReq`): `reqTypeGetStatus`=0x01, `reqTypeKeepAlive`=0x02, `reqTypeGetTelemetry`=0x03, `reqTypeGetAccessList`=0x05, `reqTypeGetNeighbors`=0x06.
- Response codes (from device): `respCodeOk`=0, `respCodeErr`=1, `respCodeContactsStart`=2, `respCodeContact`=3, `respCodeEndOfContacts`=4, `respCodeSelfInfo`=5, `respCodeSent`=6, `respCodeContactMsgRecv`=7, `respCodeChannelMsgRecv`=8, `respCodeCurrTime`=9, `respCodeNoMoreMessages`=10, `respCodeExportContact`=11, `respCodeBattAndStorage`=12, `respCodeDeviceInfo`=13, `respCodeContactMsgRecvV3`=16, `respCodeChannelMsgRecvV3`=17, `respCodeChannelInfo`=18, `respCodeCustomVars`=21, `respCodeStats`=24 (0x18), `respCodeRadioSettings`=25, `respCodeChannelDataReceived`=27 (0x1B), `respCodeDefaultFloodScope`=28 (0x1C).
- Push codes (async): `pushCodeAdvert`=0x80, `pushCodePathUpdated`=0x81, `pushCodeSendConfirmed`=0x82, `pushCodeMsgWaiting`=0x83, `pushCodeRawData`=0x84, `pushCodeLoginSuccess`=0x85, `pushCodeLoginFail`=0x86, `pushCodeStatusResponse`=0x87, `pushCodeLogRxData`=0x88, `pushCodeTraceData`=0x89, `pushCodeNewAdvert`=0x8A, `pushCodeTelemetryResponse`=0x8B (legacy; payload layout undocumented and not parsed), `pushCodeBinaryResponse`=0x8C, `pushCodePathDiscoveryResponse`=0x8D, `pushCodeControlData`=0x8E.
- Device info: `cmdAppStart` triggers `respCodeSelfInfo` with tx power, pubkey, lat/lon, telemetry flags, radio params, and node name (see offsets in `lib/connector/meshcore_connector.dart`).
- Radio/time helpers: `cmdGetRadioSettings` → `respCodeRadioSettings`; `cmdGetDeviceTime` → `respCodeCurrTime`; `cmdSetDeviceTime` updates device time.
- Telemetry: `cmdGetStats` → `respCodeStats` yields `RadioStats` (noise floor, last RSSI/SNR, TX/RX airtime); `cmdGetBattAndStorage` → `respCodeBattAndStorage` yields battery mV plus storage used/total. Remote nodes answer `cmdSendBinaryReq` + `reqTypeGetTelemetry` on `pushCodeBinaryResponse` with a Cayenne LPP payload (`lib/helpers/cayenne_lpp.dart`). `TelemetryMonitorService` samples on a schedule and keeps bounded per-node history; remote polling is opt-in per node because it costs airtime both ways.
- Reboot: prefer `MeshCoreConnector.rebootDevice()` / `buildRebootFrame()` (`cmdReboot`); CLI `sendCliCommand('reboot')` remains available for repeater remote reboot paths.
- Companion radio format: `cmdSendTxtMsg` expects `[cmd][txt_type][attempt][timestamp x4][pub_key_prefix x6][text...]` (no flags/full pubkey). CLI commands use `txtTypeCliData` in the same format, and the app maps `forceFlood` to attempt `3` when sending.
- Group text packets (`PAYLOAD_TYPE_GRP_TXT`): payload is `[channel_hash (1)][MAC (2)][encrypted data...]`. Decrypted data layout is `[timestamp x4][txt_type][text...]` where text is `"sender: message"` (see MeshCore `BaseChatMesh::sendGroupMessage`). Sender identity is not in the payload; use `PUSH_CODE_LOG_RX_DATA` raw packet path bytes for origin hash when available.
- Tactical map payloads over channel/DM text: `a:v1|pos|lat|lon|timestamp|name` (position) and `a:v1|poi|lat|lon|timestamp|label|type` (POI). Legacy shared pins use `m:lat,lon|label|flags`. Parsers in `lib/helpers/tactical_map_payload.dart` and `lib/helpers/legacy_map_marker.dart` (read-only: `m:` is parsed for older clients and pre-migration history, never sent); `a:` is excluded from SMAZ like `g:` and `m:`.
- ATAK location broadcast: `AtakLocationBroadcastService` reads phone GPS via `geolocator` (`lib/helpers/atak_location_access.dart`) while the app is foreground, connected, and the user has joined/selected an ATAK channel with broadcast enabled. ATAK uses `#atak` by default or a user-defined hashtag channel (`lib/helpers/atak_channel_helper.dart`); the global Public channel is excluded. The first position sends immediately when broadcast is enabled; the map self marker uses phone GPS while broadcasting. Sends `a:v1|pos|…` through `sendChannelMessage` (silent history) when movement and minimum interval thresholds pass (`lib/helpers/atak_broadcast_policy.dart`). Optional `atakSyncNodeAdvertLocation` setting also calls `setNodeLocation` on each gated broadcast send.
- ATAK map overlay: markers are derived from persisted channel history via `MeshCoreConnector.loadTacticalChannelMessages()` (full tactical scan, not the 200-message in-memory window). `collectAtakParticipants` / `collectAtakPois` in `lib/helpers/atak_map_markers.dart` dedupe by sender (latest position) and `messageId` (POIs). User hide/remove state persists in `AtakMapStateStore` (`atak_hidden_marker_ids`, `atak_removed_marker_ids`). Participant markers use tiered stale opacity at 15/60 minutes.
- Identity hash: `PATH_HASH_SIZE` is 1 byte; it is the prefix of the public key (see `Identity::copyHashTo`). Flooded packets append this hash to the path as they traverse hops. Self-identification via log data should compare sender name and presence of self pubkey prefix within the path bytes.

## Build, Test, and Development Commands
- `~/flutter/bin/flutter pub get` installs dependencies (or `flutter pub get` if Flutter is on PATH).
- `~/flutter/bin/flutter run` launches the app; `~/flutter/bin/flutter build apk|ios` produces release builds.
- Wardriving uploads to MeshMapper.net require a build-time API key (no in-app setting). Copy `dart_defines.json.example` to `dart_defines.json`, set `API_KEY`, then use `./scripts/flutter_with_defines.sh run` or pass `--dart-define-from-file=dart_defines.json` on `flutter run` / `flutter build`. CI uses the `MESHMAPPER_API_KEY` GitHub Actions secret the same way (see `.github/workflows/build-apk.yml`).
- `~/flutter/bin/flutter analyze --fatal-infos --fatal-warnings`, `~/flutter/bin/flutter test`, and `~/flutter/bin/dart format --set-exit-if-changed lib/ test/` are the three CI gates.

## Android Auto
- Notification-based messaging only (no Car App Library). `MeshCoreConnector.notifiableMessages` fires alongside the in-app notifications, so Auto inherits the user's mute settings. Replies route back through `sendMessage`/`sendChannelMessage`. See `docs/ANDROID_AUTO.md` for the DHU test script.
- The notification builder is native Kotlin because Android Auto requires `SEMANTIC_ACTION_REPLY`/`SEMANTIC_ACTION_MARK_AS_READ`, which `flutter_local_notifications` does not expose.

## Coding Style & Naming Conventions
- Follow `flutter_lints`, use `lowerCamelCase`/`UpperCamelCase`/`snake_case`, prefer `StatelessWidget` + `Consumer`, and use `const` constructors.
- Material widgets only; keep screens simple, handle disconnects by returning to the scanner, and avoid premature abstractions.

## Testing Guidelines
- Tests use `flutter_test`; add `*_test.dart` under `test/` and run `flutter test` before UI/protocol changes.

## Commit & Pull Request Guidelines
- Keep commit subjects short and action-focused; PRs should describe behavior changes, link issues, include screenshots for UI changes, and call out BLE protocol changes explicitly.

## Cursor Cloud specific instructions

### Flutter SDK
- Flutter stable is expected at `~/flutter/bin/flutter` (clone `https://github.com/flutter/flutter.git -b stable` if missing). `~/.bashrc` should include `export PATH="$HOME/flutter/bin:$PATH"`.
- Run `flutter config --enable-linux-desktop` once per VM if you need the Linux runner.

### Linux desktop system packages (one-time per VM)
- Required for `flutter build linux` / `flutter run -d linux`: `ninja-build`, `libgtk-3-dev`, `pkg-config`, `libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`, `g++-14`, `libstdc++-14-dev` (clang 18 links against GCC 14’s libstdc++ on Ubuntu 24.04).
- Optional: `mesa-utils` for `flutter doctor` EGL checks; `scrot` / `xdotool` for GUI screenshots in headless setups with `DISPLAY` set.

### Running the app on Linux (cloud VM)
- After a successful build, the relocatable bundle is `build/linux/x64/debug/bundle/gulf_coast_mesh_app` (run from that directory so `data/` and `lib/` resolve).
- If `cmake --install` fails with “Permission denied” under `/usr/local`, delete `build/linux` and rebuild so `CMAKE_INSTALL_PREFIX` points at `build/linux/x64/debug/bundle`.
- BLE scanning needs a working Bluetooth adapter and BlueZ; VMs often log `flutter_blue_plus_linux` / D-Bus errors but the UI still reaches **Scanner** (splash → scanner in ~3s).
- Full mesh E2E (connect to `MeshCore-*`, send messages) requires physical MeshCore hardware; use `flutter test` when no radio is available.

### Lint / CI parity
- CI (`.github/workflows/flutter_dart.yml`) runs `flutter analyze --fatal-infos --fatal-warnings` and `dart format --output=none --set-exit-if-changed lib/ test/`. Reference code in `temp/` is outside the app's check scope.
