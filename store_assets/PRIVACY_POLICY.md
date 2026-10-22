# Privacy Policy — Gulf Coast Mesh App

_Last updated: August 23, 2026_

Gulf Coast Mesh App ("the app") is a client for MeshCore LoRa mesh radio networks. This
policy explains what data the app accesses, stores, and transmits.

## Data the app stores on your device

- **Contacts, messages, and channels** you send or receive over the mesh
  radio are stored locally on your device so you can view your conversation
  history.
- **Repeater login passwords** and **channel/community secret keys (PSKs)**
  are stored using your device's secure hardware-backed storage (Android
  Keystore), not in plain text.
- None of the above ever leaves your device unless you take one of the
  actions below.

## Data the app sends over the mesh radio (not the internet)

Messages, location shares, and node advertisements you choose to send are
transmitted over LoRa radio to other mesh devices — this is the app's core
function. This is peer-to-peer radio communication, not a connection to any
company's servers.

If you turn on **ATAK location broadcasting** (off by default), your GPS
location is periodically sent to other users on your selected mesh channel,
and optionally attached to your node's own beacon. This is entirely within
the mesh network you're part of — it is not sent to us or any internet
service.

## Data sent to internet services (only when you opt in)

- **MeshMapper wardriving** (off by default, requires you to accept a
  disclosure and manually start a session): if enabled, your device's public
  key/identity, display name, app version, radio settings, and GPS location
  are sent to meshmapper.net to build community coverage maps. You can use
  an offline mode instead, which keeps this data on your device.
- **MeshBuddy node-name reservation** (only if you use this optional
  feature): the email address, display name, and location you type into the
  reservation form are sent to our MeshBuddy service to reserve a unique
  mesh node identity for you.
- **GIF search** (only if enabled and only when you open the GIF picker):
  your search text is sent to GIPHY to return matching GIFs.
- **Link previews**: if a chat message contains a link, the app fetches that
  link directly to build a preview card. You can turn this off in Settings.
- **Firmware updates**: the app checks GitHub for the latest MeshCore
  firmware releases when you use the firmware/OTA update screens.
- **Line-of-sight terrain tool**: coordinates you select on the map are sent
  to a public elevation-data API (Open-Meteo) to compute terrain profiles.

## What we don't do

The app contains no advertising SDKs, no analytics SDKs, and no crash-
reporting SDKs. We do not sell your data, and we do not build advertising
profiles.

## Your choices

Wardriving, ATAK location broadcasting, and link previews are all optional
and can be turned off in Settings. You can delete your local message
history, contacts, and stored passwords/keys from within the app.

## Contact

Questions about this policy can be sent to: **support@gulfcoastmesh.org**
