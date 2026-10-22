# Gulf Coast Mesh App - Flutter Client

Open-source Flutter client for MeshCore LoRa mesh networking devices.

## Build Commands

```bash
# Install dependencies
~/flutter/bin/flutter pub get

# Run in debug mode (optional MeshMapper / Giphy keys)
./scripts/flutter_with_defines.sh run
# or: ~/flutter/bin/flutter run --dart-define-from-file=dart_defines.json

# Build Android APK
~/flutter/bin/flutter build apk --dart-define-from-file=dart_defines.json

# Run static analysis
~/flutter/bin/flutter analyze --fatal-infos --fatal-warnings

# Run tests
~/flutter/bin/flutter test
```

Copy `dart_defines.json.example` → `dart_defines.json` for local secrets (`API_KEY`, `GIPHY_API_KEY`). Never commit `dart_defines.json`.

## Project Structure

```
lib/
├── main.dart                         # MaterialApp + Provider wiring
├── connector/
│   ├── meshcore_connector.dart       # BLE transport, session state
│   └── meshcore_protocol.dart        # Frame builders / parsers
├── screens/
│   ├── scanner_screen.dart           # BLE scan (home); connects → Contacts
│   ├── contacts_screen.dart          # Post-connect hub + QuickSwitch
│   ├── chat_screen.dart / channel_chat_screen.dart
│   ├── map_screen.dart / settings_screen.dart
│   └── repeater_*.dart               # Repeater/room admin flows
├── helpers/                          # Protocol helpers (ATAK, crypto, redaction…)
├── services/                         # BLE debug log, storage wrappers, etc.
├── storage/                          # Prefs + secure password stores
├── models/ / widgets/ / utils/
└── l10n/                             # Generated localizations
```

## Architecture

### State Management
- **Provider** with `ChangeNotifier`
- `MeshCoreConnector` is the central BLE/session state holder
- Screens use `Consumer<MeshCoreConnector>` for reactive UI

### Theming
- Material 3 (`useMaterial3: true`)
- System dark/light (`ThemeMode.system`)

### Navigation
- Scanner → on connect → `ContactsScreen` (hub)
- QuickSwitch moves between Contacts / Channels / Map
- Disconnect auto-returns to Scanner

## BLE Protocol

### Nordic UART Service (NUS)
- **Service UUID**: `6e400001-b5a3-f393-e0a9-e50e24dcca9e`
- **RX Characteristic**: `6e400002-b5a3-f393-e0a9-e50e24dcca9e` (write)
- **TX Characteristic**: `6e400003-b5a3-f393-e0a9-e50e24dcca9e` (notify)

### Device Discovery
- Name prefix `MeshCore-` via `platformName` / `advertisementData.advName`

### Connection States
```dart
enum MeshCoreConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  disconnecting,
}
```

### Frame I/O
- Send: `MeshCoreConnector.sendFrame(Uint8List data)`
- Receive: `MeshCoreConnector.receivedFrames`
- Frames capped at `maxFrameSize = 172`; see `AGENTS.md` for command codes

## Coding Conventions

- Minimal / readable code; one responsibility per file
- Prefer `StatelessWidget` + `Consumer`; `const` where possible
- Material widgets only (no Cupertino UI)
- Private members prefixed with `_`
- No premature abstractions; avoid unnecessary comments
- Do not commit secrets; redact passwords/PSKs in BLE debug logs

## Key Files

| File | Purpose |
|------|---------|
| `lib/connector/meshcore_connector.dart` | BLE scan/connect/I/O + high-level commands |
| `lib/connector/meshcore_protocol.dart` | Frame build/parse |
| `lib/screens/scanner_screen.dart` | Entry / device list |
| `lib/screens/contacts_screen.dart` | Connected hub |
| `lib/helpers/frame_redaction.dart` | Frame debug-log secret scrubbing |
| `pubspec.yaml` | Dependencies |
| `AGENTS.md` | Protocol detail for agents |
