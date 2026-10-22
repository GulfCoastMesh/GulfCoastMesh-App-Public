# macOS desktop (Apple Silicon)

The macOS target supports Apple Silicon (`arm64`) only. Runner and CocoaPods
build settings exclude Intel. Prebuilt third-party frameworks may still contain
additional architecture slices; the app executable and Flutter AOT framework
are checked for arm64-only output in CI.

## GitHub Actions

The **Build** workflow includes an enabled **macOS (Apple Silicon)** job on the
GitHub-hosted `macos-15` runner. It runs for pushes to `main`, pull requests, and
manual **Run workflow** requests. Manual requests also run the other enabled
jobs in that workflow.

The job selects Xcode 26.2 (the image default is too old for current plugin
APIs), installs Flutter stable dependencies, builds release mode, checks the
app/AOT architecture and bundle signature, and uploads
`gulfcoast-mesh-macos-arm64-<commit>` for 14 days. Download and extract the
artifact, then extract the contained ZIP to obtain `gulf_coast_mesh_app.app`. The
inner ZIP preserves executable permissions and framework symlinks.

`MESHMAPPER_API_KEY` is passed through a temporary JSON defines file. Without
that secret (including fork PRs), the app builds without MeshMapper upload
credentials. The defines file is removed after the job.

These are **ad-hoc-signed test builds**, not Developer ID-signed or notarized
distribution builds. A successful CI build does not establish Gatekeeper
acceptance or hardware compatibility.

## Local build

Use an Apple Silicon Mac with full Xcode selected, its command-line tools,
CocoaPods, and Flutter stable compatible with `pubspec.lock`.

```sh
flutter pub get
flutter build macos --release
```

For MeshMapper uploads, configure the ignored `dart_defines.json` using
`dart_defines.json.example`, then build with
`--dart-define-from-file=dart_defines.json`.

Output: `build/macos/Build/Products/Release/gulf_coast_mesh_app.app`.

## Capabilities and feature status

Both entitlement configurations include Bluetooth, serial/USB, outgoing
networking, camera, location, user-selected read/write files, and the
secure-storage package's default Keychain configuration. Camera, Bluetooth,
and location usage descriptions are in `Runner/Info.plist`.
Permission grants and Keychain persistence must be tested in a signed release.

- BLE, USB serial, and TCP implementations exist; validate against real radios.
- Location accuracy depends on the Mac and environment. Phone-quality GPS
  should not be assumed for wardriving.
- Reverse geocoding and automatic joining of an ESP32 Wi-Fi network use
  mobile-specific dependencies. Use manual ZIP entry/network joining on Mac.
- Closing the last window currently terminates the app.

## Before public distribution

1. Confirm the effective minimum macOS version supported by all native plugins
   with a clean build and real-Mac testing; the declared target is macOS 12.
2. Finalize GulfCoast Mesh branding, owned bundle ID, and signing team. Verify
   saved passwords survive relaunch and upgrades with the final identity.
3. Configure Developer ID signing and hardened runtime, sign embedded code,
   notarize and staple, then package a DMG or ZIP. Test Gatekeeper on a clean Mac.
4. Test BLE/USB/TCP messaging, unplug/replug, sleep/wake reconnect, permission
   denial/recovery, file import/export, notification taps, and password storage.
5. Complete the desktop UX follow-ups: draft preservation, minimum split-view
   widths, first-unread positioning, right-click/selectable messages, and the
   native Settings menu action.
