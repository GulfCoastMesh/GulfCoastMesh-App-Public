# Play Console technical-quality items

Decisions and root causes for the items Google Play reports against release builds,
so they are not re-diagnosed every release. Evidence below was gathered by reading
ELF program headers out of the built `.aab`, not from source inspection.

## 16 KB native library alignment

Verify each release bundle uses 16 KB-aligned native libraries. The former Codec2,
audio, and PDF media plugins have been removed and are no longer part of release builds.

**Regression check** — run against the built bundle, not the source:

```bash
unzip -o -j <bundle>.aab "base/lib/arm64-v8a/*.so" -d /tmp/libs
for f in /tmp/libs/*.so; do
  echo "$(basename "$f"): $(readelf -lW "$f" | awk '$1=="LOAD"{print $NF}' | sort -u | tr '\n' ' ')"
done
```

Every library must report `0x4000` or larger.

## `libdatastore_shared_counter.so` built with an old NDK — FIXED by exclusion

Play's suggested remedy ("upgrade to NDK r28") does not apply: this is a **prebuilt we do
not compile**.

- The library is *already* 16 KB aligned (`0x4000`). Its `.note.android.ident` says **r20**
  (Kotlin/Native's clang fork), and that stale tag is what trips Play's scanner.
- It ships inside `androidx.datastore:datastore-core-android:1.2.0`, pulled transitively by
  `shared_preferences_android`. **1.2.0 is the current release** — a version bump does not
  help.
- Disassembling the AAR shows `System.loadLibrary("datastore_shared_counter")` lives in
  `androidx.datastore.core.SharedCounter` / `NativeSharedCounter`, reachable only from
  `MultiProcessCoordinator` / `MultiProcessDataStoreFactory`.
- `shared_preferences_android` uses the **single-process** delegate
  (`preferencesDataStore(...)` in `SharedPreferencesPlugin.kt`), which never touches that
  path.

The library is therefore unreachable dead weight, and `android/app/build.gradle.kts`
excludes it from packaging.

**Revisit if** any dependency ever adopts multi-process DataStore. After changing
`shared_preferences` or adding a DataStore-backed plugin, smoke-test settings persistence:
launch, change a setting, force-stop, relaunch, confirm it stuck.

## Edge-to-edge — FIXED

`targetSdk = 36`, so Android 15+ draws the app edge-to-edge regardless of opt-in, and the
app had never opted in nor opted out. `main()` now calls
`SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`, `AppBarTheme` carries a
brightness-aware `systemOverlayStyle`, and `MaterialApp.builder` wraps the tree in an
`AnnotatedRegion` for screens that have no `AppBar`.

Auditing the ~38 `SafeArea` call sites found no systematic double-insetting, because
`Scaffold` already removes body top padding when an `AppBar` is present, removes body
bottom padding when a `bottomNavigationBar` is present, and positions FABs using
`minViewPadding`. The floating navigation pill in `home_screen.dart` was already correctly
wrapped in `SafeArea(top: false)` — and the `bottomNavigationBar` slot keeps its bottom
padding (`removeBottomPadding: false`), so that wrapper does real work.

One genuine defect was found and fixed: `_DemoModeBanner` sits outside any `Scaffold` in
`MaterialApp.builder` and consumes the status-bar inset itself, while the content below it
still saw the full `MediaQuery` padding and inset a second time. The content is now wrapped
in `MediaQuery.removePadding(removeTop: true)`.

## Picture-in-picture — DECLINED

This is a generic Play Console suggestion shown to every app, not a defect.

Gulf Coast Mesh App has no video playback. Its only continuous surfaces are the map and wardriving
sessions, and session continuity is already handled by the shared `flutter_foreground_task`
foreground service. Adding PiP would mean a new activity-lifecycle surface,
`supportsPictureInPicture` in the manifest, and a second render path for the map — for no
user-facing gain.

**Revisit if** a live-map-while-navigating or active-wardrive PiP window becomes a real
user request; that is the only defensible use here.
