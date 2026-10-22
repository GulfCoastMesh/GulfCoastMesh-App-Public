# Play Console "Data Safety" form — reference answers

Fill this out in Play Console under App content → Data safety. These
answers are based on reading the actual app code (see the research behind
this doc for file references) — double-check anything that matters legally.

## Does your app collect or share any of the required user data types?

**Yes.**

## Data types

### Location
- **Approximate location** — Collected, **not required** (opt-in). Shared
  with MeshMapper only if wardriving is enabled; shared with other mesh
  users only if ATAK location broadcast is enabled. Purpose: App
  functionality.
- **Precise location** — same as above (Geolocator returns precise GPS;
  approximate/precise are usually declared together).

### Personal info
- **Name** — Collected, not required. Only if you use MeshBuddy node
  reservation (display name) or set a mesh display name. Purpose: App
  functionality.
- **Email address** — Collected, not required. Only if you use MeshBuddy
  node-name reservation. Shared with MeshBuddy (Gulf Coast Mesh's own
  service). Purpose: App functionality (identity reservation), Account
  management.

### Messages
- **In-app messages** — Collected (stored locally on-device), not shared
  with us. Messages are transmitted peer-to-peer over LoRa radio to other
  mesh devices, which is the app's core function — this is not "sharing
  with a third-party company" in Play's sense, but you should still declare
  it as collected/processed since Play's form asks about message content
  handling in general. Purpose: App functionality.

### App activity
- Generally **not applicable** — no analytics/usage-tracking SDK is
  present.

### App info and performance
- **Crash logs / diagnostics** — **Not collected.** No crash reporting SDK
  (no Crashlytics/Sentry/etc.) is present in the app.

### Device or other IDs
- **Device ID** — Not collected in the Play-defined sense (no advertising
  ID, no analytics ID). The app does read Bluetooth device identifiers
  locally to connect to your MeshCore hardware, but these stay on-device
  and are not transmitted to any server.

### Financial info, Health & fitness, Web browsing history, Contacts (address book)
- **Not collected.**

## Is all of the user data collected by your app encrypted in transit?

- Data sent to MeshMapper, MeshBuddy, GIPHY, GitHub, and Open-Meteo is sent
  over HTTPS. **Verify each base URL in the code actually uses `https://`
  before answering yes** — the research found these are called via the
  `http` package; confirm scheme per call site if Play asks for a blanket
  yes/no.
- Mesh radio traffic (LoRa) uses the MeshCore protocol's own encryption —
  document your channel/PSK encryption details if asked.

## Can users request that data be deleted?

**Yes** — data collected by MeshMapper/MeshBuddy would need a deletion
process on those services' side (document what that is, if any, e.g. an
email request). On-device data (contacts, messages, secure-stored
passwords/PSKs) can be deleted by the user directly within the app or by
uninstalling it.

## Is data collection required or optional?

All of the above (location, email/name for MeshBuddy, wardriving telemetry)
is **optional** — the app is fully usable without opting into any of it.

---

**Things only you can answer** (not derivable from code):
- Whether MeshMapper/MeshBuddy are operated by you or a separate
  organization (affects "shared with third party" framing).
- Your data-deletion process for anything stored server-side on
  MeshMapper/MeshBuddy.
- Whether you want to commit to a specific data-retention period.
