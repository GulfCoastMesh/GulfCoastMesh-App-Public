# Gulf Coast Mesh App
## This is the internal codebase of the Gulf Coast Mesh App, A fork of Gulf Coast Mesh App; Designed by ScarlettOSA and MrSharky.

### Run on desktop

Use the desktop launcher from the project root:

```bash
./scripts/run_desktop.sh
```

Linux is the default target. Select another desktop runner with `linux`,
`macos`, or `windows`; use `--list` to see available Flutter devices. Extra
arguments are passed through to `flutter run`.

Build a release desktop bundle with the matching build script:

```bash
./scripts/build_desktop.sh
```

Linux is also the default build target. Pass `macos` or `windows` as the first
argument when building on those platforms. If `dart_defines.json` exists, the
script includes it automatically; additional arguments are passed to
`flutter build`.
