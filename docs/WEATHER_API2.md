# Experimental Weather: API2 client

Enable **Experimental Weather** in app settings, connect to a MeshCore companion,
and open **Weather**. The app discovers an API2 bot on `#wx-bot-hidden`, creating that
hashtag channel if a channel slot is available. Capabilities are cached for the
current connection; **Bot & Reports → Discover** repeats discovery.

## Pages

### Forecast

- Enter a five-digit U.S. ZIP (ZIP+4 is normalized) or use phone location.
- **Get weather** requests current conditions, apparent temperature, up to five
  hourly forecasts with precipitation/wind, and coded alerts.
- **Load descriptive current conditions** separately requests location and weather
  descriptions, humidity, apparent temperature, wind, and optional alert details.
- Existing results remain visible while refreshing or after an error. Their ZIP
  and update time identify the displayed report.
- The current bot's Open-Meteo combined provider supplies an empty alert list;
  that does not establish that no NOAA alerts are active. Automatic notifications
  use the bot's separate reporting path.

### Radar

1. Tap a map point, enter signed decimal latitude/longitude, or use phone GPS.
2. Choose **−5h … Now … +5h**.
3. Tap **Load radar**. Changing a control alone does not send mesh traffic.

Each request returns one north-up, 50-statute-mile-radius snapshot. Observed
MRMS products cover Now/past hours; future hours are **HRRR model guidance**.
The caption shows the actual product valid time in UTC and the forecast issue
time, rather than estimating time from when the reply arrived. The grid supports
both documented widths (28 and 32). A legend distinguishes reflectivity levels,
dry cells, and gray missing-coverage cells. Outside the circular grid has no data.

The reflectivity payload comes over mesh; the map background uses the existing
OSM cache-first tile provider. GPS-to-ZIP resolution uses the existing platform
geocoding flow. Radar coordinates can be entered without geocoding. Initial
provider coverage is CONUS. An unavailable snapshot or unsupported location is
reported with a readable error, retaining the last complete snapshot.

### Bot & Reports

- Refresh discovery/help capabilities and inspect the bot version.
- Select the matching bot contact from Contacts for direct-message tools.
- Ping displays receipt time, route, and optional approximate endpoint distance.
- Subscribe to a ZIP or **Stop all reports** (all ZIPs for the sending identity).
  Acknowledgments use API2; subsequent automatic reports remain ordinary text DMs.
- Unsupported capabilities disable the corresponding actions.

## Commands used

| Action | Command | Transport |
| --- | --- | --- |
| Discovery | `bot api2` | `#wx-bot-hidden` |
| Help/capabilities | `wx help api2` | `#wx-bot-hidden` |
| Forecast | `wx ZIP all api2` | `#wx-bot-hidden` |
| Descriptive current | `wx ZIP api2` | `#wx-bot-hidden` |
| Radar | `wx radar LAT LON TIME api2` | `#wx-bot-hidden` |
| Version | `wx version api2` | `#wx-bot-hidden` |
| Ping | `ping api2` | Selected contact DM |
| Subscribe | `wx report ZIP api2` | Selected contact DM |
| Stop reports | `wx report stop api2` | Selected contact DM |

API2 replaces API1 in the experimental page. It does not add `json` to commands.
No weather-provider API key is needed in the app; providers run on the bot.

## Implementation and limits

- `lib/helpers/weather_api2_codec.dart`: `~W2` framing, binary weather, positional
  response types, circular radar header and 3-bit cells.
- `lib/helpers/weather_inflate.dart`: portable bounded raw RFC1951 inflation,
  requiring stream completion, rejecting trailing bytes, limiting output to 8192
  bytes while decoding. It works without `dart:io` on web as well as native.
- `lib/services/weather_api_service.dart`: one outstanding request, sender/context
  grouping, eight bounded groups, duplicate/conflict handling, 60-second expiry,
  expected response kind/ZIP/radar-coordinate checks, disconnect/dispose cleanup.
- Channel discovery pins the answering sender key when available, otherwise its
  channel sender name. Channel names are not authenticated public-key identities.
- IDs are bot-generated; API2 has no echoed client request ID. A delayed response
  from the same sender for identical request parameters cannot always be
  distinguished from a fresh response. Incomplete replies are never rendered.
- Radar is limited to four fragments; other API2 responses to sixteen.
- The bot's contact-warning flag is displayed without claiming it proves the final
  radio delivery route.
- `lib/helpers/demo_weather_api2.dart`: explicitly synthetic demo-mode replies,
  including radar, so the same client pipeline can be exercised without a radio.

## Verification

Protocol tests include the bot's published error/weather vectors and independent
Python reference-generated radar fixtures, including four uncompressed fragments.
Inflater tests compare against zlib for stored, fixed, and dynamic blocks, test
truncation/trailing streams, and enforce the output cap. Service tests exercise
sender separation, DM routing, subscription acknowledgments, timeout/retry, and
disconnect behavior. Widget tests exercise forecast errors and manual radar loads.

```sh
flutter test test/helpers/weather_api2_codec_test.dart \
  test/services/weather_api_service_test.dart test/widgets/weather_screen_test.dart
flutter analyze --fatal-infos --fatal-warnings
```

For live validation: discover your running bot on `#wx-bot-hidden`, request your ZIP,
load Now radar at your coordinates, then load a future hour and check the forecast
label. Select its contact to test ping and a subscribe/stop round trip. Physical
radio testing is needed to verify real mesh latency, fragmentation delivery, and
the running bot's provider availability.
