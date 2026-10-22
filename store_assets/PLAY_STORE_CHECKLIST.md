# Google Play submission checklist — Gulf Coast Mesh App

## Done

- [x] Upload keystore generated: `android/app/upload-keystore.jks`
- [x] Signing config wired up: `android/key.properties` (gitignored, matches
      the existing `signingConfigs.release` block in
      `android/app/build.gradle.kts`)
- [x] Signed release app bundle built:
      `build/app/outputs/bundle/release/app-release.aab` (verified signed
      with the new key via `jarsigner -verify`, not the debug key)
- [x] `targetSdk`/`compileSdk` = 36 (Android 16) — comfortably meets Play's
      current minimum target API requirement
- [x] 512×512 hi-res store icon: `store_assets/play_store_icon_512.png`
- [x] Draft privacy policy: `store_assets/PRIVACY_POLICY.md`
- [x] Draft Data Safety form answers: `store_assets/PLAY_DATA_SAFETY.md`

## You need to do (account-level / can't be automated)

1. **Back up `android/app/upload-keystore.jks` and `android/key.properties`
   somewhere safe** (password manager, encrypted backup) — outside this
   repo, and ideally outside this machine too. **If you lose this keystore,
   you can never publish an update to this app under the same listing
   again.** Neither file is committed to git (both are gitignored).
2. **Google Play Console developer account** — one-time $25 registration if
   you don't already have one.
3. **Fill in `[SUPPORT EMAIL]`** in `PRIVACY_POLICY.md`, then **host that
   page at a public URL** (GitHub Pages off this repo works well) — Play
   Console requires a live privacy policy URL, not just text.
4. **Data Safety form** — walk through Play Console's form using
   `PLAY_DATA_SAFETY.md` as your answer key. A few questions there need
   your input specifically (marked at the bottom of that file).
5. **Store listing graphics** — these need actual design/screenshot work,
   which I haven't done:
   - Feature graphic: 1024×500 PNG/JPG
   - At least 2 phone screenshots (recommend 4–8, showing Scanner,
     Contacts, Chat, Map)
   - Short description (≤80 chars) and full description (≤4000 chars) —
     drafted in `store_assets/STORE_LISTING.md`
6. **Content rating questionnaire** and **target audience/age** — answered
   in Play Console directly.
7. **App category** and **contact details** (support email, optional
   website) — Play Console store listing fields.
8. **Upload** `build/app/outputs/bundle/release/app-release.aab` to a new
   release (start with an Internal Testing or Closed Testing track before
   Production — Play requires at least one closed test with 12+ testers
   for 14 days before a new personal developer account can publish to
   Production).

## Rebuilding after future code changes

```bash
~/flutter/bin/flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

This automatically picks up `android/key.properties` and signs with the
same upload key, as long as that file and the `.jks` are still in place.
Bump `version:` in `pubspec.yaml` (format `versionName+versionCode`) before
each new upload — Play requires a strictly increasing versionCode per
release.
