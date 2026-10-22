# Desktop installers

The `Build desktop installers` workflow produces end-user installables for the
three supported desktop platforms. It runs for pull requests and for pushes to
`main` and `bugs-features`; artifacts are retained for 14 days.

| Platform | Artifact | Install/use |
| --- | --- | --- |
| Linux x64 | `.deb` | `sudo apt install ./gulfcoast-mesh_<version>_amd64.deb` |
| Linux x64 | `.AppImage` | Mark executable (`chmod +x`) and run it. This is the portable option for non-Debian systems. |
| Windows x64 | `.msix` | Double-click after the release build has been signed with the project certificate. |
| macOS arm64 | `.dmg` | Open the disk image and drag **Gulf Coast Mesh** to Applications. |

## Release signing

CI always creates installable packages, but trusted production installation
requires platform signing credentials. The workflow signs packages when the
corresponding GitHub secrets are configured, and otherwise labels the package
as unsigned in its job output.

- **Windows:** set `WINDOWS_SIGNING_PFX_BASE64` to a base64-encoded code-signing
  PFX, `WINDOWS_SIGNING_PFX_PASSWORD` to its password, and
  `WINDOWS_SIGNING_PUBLISHER` to the certificate subject (for example,
  `CN=Gulf Coast Mesh`). The workflow writes that publisher into the MSIX
  manifest, imports the certificate only for signing, and removes it afterward.
- **macOS:** set `MACOS_SIGNING_CERT_P12_BASE64`,
  `MACOS_SIGNING_CERT_PASSWORD`, and `MACOS_SIGNING_IDENTITY` (for example,
  `Developer ID Application: Example, Inc. (TEAMID)`). Optionally set
  `MACOS_NOTARY_PROFILE` to an existing `notarytool` keychain profile to submit
  and staple the DMG. Without notarization, Gatekeeper will warn users.

Signing secrets must be configured before distributing a production package.
Do not ask end users to bypass operating-system security prompts for a release.

## Local packaging

The CI workflow is the supported cross-platform packager. On its native host,
first build the release bundle with the appropriate `flutter build` command and
then run the matching packaging step from `.github/workflows/build.yml`.

Linux packaging expects `dpkg-deb`, `convert` (ImageMagick), and
`appimagetool`; CI installs these dependencies. The Linux bundle is placed in
`/opt/gulfcoast-mesh` by the Debian package and is self-contained in the
AppImage.
