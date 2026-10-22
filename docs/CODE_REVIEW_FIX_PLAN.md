**GulfCoastMeshAPP code review and fix plan — 2026-09-12**

Reviewed commit `b41604a` with Flutter 3.44.1 / Dart 3.12.1 on Linux. The working tree was clean before the review. This document records the five confirmed defects, the original repair plan, and the implementation results. All five repairs were authorized and implemented on 2026-09-13.

The review covered the repository's CI checks and a focused inspection of message persistence, routing, transport response handling, retry behavior, and browser startup. It is not an exhaustive audit of every feature or platform.

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub --fatal-infos --fatal-warnings` | Passed; no issues |
| `dart format --output=none --set-exit-if-changed .` | Passed; 374 files, zero changes |
| `flutter test --no-pub --reporter expanded` | 754 passed, one skipped because PDFium was unavailable |
| `flutter build web --release --no-pub` | Passed; emitted Wasm compatibility and font warnings |
| Five additional host regression reproductions | All failed their expected-correct-behavior assertions, confirming four defects; history loss was reproduced independently for channels and DMs |
| Additional Chromium regression reproduction | Failed with `Unsupported operation: Platform._operatingSystem`, confirming the fifth defect |

At review time, the existing suite did not cover these failing cases. Reproductions used mock preferences, fake transport responses, and a simulated timer; they did not access real message history or radio hardware. Tests required localhost access outside the sandbox. The web build also required downloading its missing Flutter SDK component. Neither restriction was counted as an application defect.

1. **P1 — Preserve saved history when loading a 200-message display window.**

   Sources: [DM loading](../lib/connector/meshcore_connector.dart#L465), [channel loading](../lib/connector/meshcore_connector.dart#L813), and [persistence helpers](../lib/connector/meshcore_connector.dart#L1096).

   Both loaders merge the saved history with live messages, reduce that result to the newest 200 entries, and persist the reduced list as the entire conversation. Channel loading runs during application startup; DM loading runs when a contact frame is processed. A reproduction seeded 250 distinct messages, loaded the conversation, and observed `saved=200, older page=0` for both channels and DMs. Older messages are deleted, pagination cannot retrieve them, and tactical markers derived from older channel history can disappear.

   Repair: keep persisted history independent of the UI window. Loading must not overwrite storage with a partial window. Serialize history writes and retain the saved prefix preceding each loaded window; replace only the loaded tail for new messages, edits, reactions, delivery-status updates, and explicit deletions. Audit every `_saveConversationMessages` and `_saveChannelMessages` caller so the next new message or edit cannot truncate history again. Explicit deletion must remove the selected message without resurrecting it during a later save, including legacy DMs without message IDs. Preserve current storage keys and formats where practical.

   Acceptance: seed at least 250 DMs and 250 channel messages, restart/load, and verify all remain stored while 200 are initially visible and the older 50 can be paged in. Then receive/send, edit, react, update delivery status, and delete one message; reload and verify only the intended records changed. Cover a message arriving during load and a tactical marker older than the visible window. Previously overwritten records cannot be reconstructed by this code fix alone.

2. **P1 — Prevent browser startup from executing unsupported platform getters.**

   Sources: [background service initialization](../lib/services/background_service.dart#L23) and its [startup call](../lib/main.dart#L191). Related platform checks occur in [the scanner](../lib/screens/scanner_screen.dart#L38) and [settings](../lib/screens/settings_screen.dart#L45).

   `main()` awaits `BackgroundService.initialize()` before `runApp()`. That method evaluates `dart:io`'s `Platform.isAndroid` without a web guard. Calling the real initializer in headless Chromium produced `Unsupported operation: Platform._operatingSystem`. A successful JavaScript build therefore does not establish that this startup path can run in a browser.

   Repair: make the background service a supported no-op on web using conditional implementations or consistent `kIsWeb` guards before any native platform access. Apply the same treatment to scanner/settings paths, and hide unavailable transports according to actual platform support. Check the remaining startup service/plugin calls in a full browser launch.

   Acceptance: the initializer succeeds in Chromium; a browser smoke test reaches Scanner, can enter demo mode and open Settings, and records no uncaught platform errors. Keep the web build check and add browser execution to CI. Preserve Android foreground-service behavior and native desktop behavior.

3. **P1 — Decode three-byte contact routes as unsigned metadata.**

   Source: [Contact.fromFrame](../lib/models/contact.dart#L218); related helpers are in [meshcore_protocol.dart](../lib/connector/meshcore_protocol.dart#L614).

   The parser converts the path metadata byte with `toSigned(8)` and treats every negative value as flood mode. Valid three-byte route metadata has its high bit set. A two-hop, three-byte route encoded as `0x82` was parsed as `pathLength=-126` with zero path bytes. This loses a valid route and makes callers treat it as flood routing. Existing contact tests cover encoded two-byte routes but omit this three-byte case.

   Repair: read the field unsigned, recognize the protocol's `0xFF` flood sentinel explicitly, and decode valid hash-size/hop-count metadata through the shared helpers. Validate reserved encodings and byte-length bounds. Retain compatibility with legacy fields that rely on the negotiated hash size.

   Acceptance: table-driven contact-frame tests for one-, two-, and three-byte hashes; `0x82` must produce two hops and six path bytes. Include direct neighbors, `0xFF` flood, legacy fallback fields, malformed/truncated frames, and route persistence/display round trips. Verify a three-byte route on a companion radio during hardware validation.

4. **P2 — Register pending command acknowledgements before responses can arrive.**

   Source: [MeshCoreConnector.sendFrame](../lib/connector/meshcore_connector.dart#L1787).

   Native sends await the transport write before registering the command in the pending generic-ACK queue. Incoming frames are processed independently. A fake connected transport emitted a valid `RESP_CODE_OK` during a contact-import write, before that write's future completed. The result was `callbacks=[], outstanding=1`: the acknowledgement was dropped, then a stale pending entry was added. Imports can time out; channel-send confirmation uses this mechanism too. A later response can also consume the stale entry.

   Repair: reserve a command-specific pending entry in transmission order before starting the write. On a definite send failure, remove only that entry if it is still pending; do not disturb entries already completed by an early response. Preserve the existing cancellation/tombstone behavior for commands already sent, and explicitly handle ambiguous transport failures. Ensure concurrent writes cannot register pending entries in a different order from the wire.

   Acceptance: fake-transport tests for OK and ERR both before and after write completion; two consecutive commands; write failure with another command queued; early completion followed by a write error; and disconnect cleanup. Keep existing generic-ACK FIFO tests passing. Each response must resolve only its corresponding command, with no stale entry left behind.

5. **P2 — Preserve delivery timers when SENT arrives before write completion.**

   Source: [MessageRetryService._attemptSend](../lib/services/message_retry_service.dart#L250).

   `updateMessageFromSent()` installs the radio's delivery timeout, but `_attemptSend()` unconditionally installs its eight-second send-phase timer after awaiting the send callback. If SENT arrives during that await, the shorter timer overwrites the delivery timer. The reproduction supplied a 30-second radio timeout and observed `retryCount=1` by nine seconds. This causes premature retries and unnecessary airtime.

   Repair: distinguish the send and delivery phases for each attempt. Install the send-phase timeout before a response can arrive, or install it after the write only if that same attempt is still awaiting SENT. A completed/delivered, cancelled, disposed, or superseded attempt must never re-arm its timer. Coordinate failure handling with step 4 without changing the radio ACK-hash format.

   Acceptance: simulated-clock tests for SENT before/after write completion, no SENT, delivery before write completion, delayed responses from an older attempt, and send failure. A 30-second delivery timeout must not trigger a retry at eight seconds; missing SENT must still reach retry/failure instead of leaving a message pending indefinitely.

**Implementation and validation — 2026-09-13**

All five fixes are implemented using the existing classes and storage format, with no added dependencies. History saves retain the older disk prefix and serialize writes; legacy DMs still work without assigning new IDs or migrating storage. Browser guards cover the background/notification services, foreground-task communication port, Scanner, and Settings. Contact parsing treats only `0xFF` as flood routing. Pending command acknowledgements are registered before transport writes. Retry timers check that the same attempt is still awaiting SENT before installing a send timeout.

Browser validation also exposed a timestamp overflowing the narrow desktop conversation list. Its existing row now constrains the timestamp with `Flexible`; no new widget or layout abstraction was introduced.

Permanent regression coverage lives in `test/connector/message_history_test.dart`, `test/connector/generic_ack_fifo_test.dart`, `test/path_hash_mode_test.dart`, `test/services/message_retry_service_test.dart`, and `test/browser_startup_test.dart`. A small shared fake transport supplies early responses without hardware. Tests cover archived history, legacy edits, reactions, deletions, pagination, restart, tactical markers, concurrent arrival during load, response timing, write errors, disconnect/disposal, and a previous write completing during a newer retry attempt.

| Post-fix check | Result |
| --- | --- |
| Strict Flutter analysis | Passed; no issues |
| Complete host test suite | 776 passed; one PDFium extraction test skipped |
| Android debug build | Passed |
| Linux release build | Passed |
| JavaScript web release build | Passed; existing Wasm compatibility and font warnings remain |
| Chromium startup and navigation tests | 2 passed; Scanner, demo mode, and Settings reached without errors |
| Repository formatting gate | Passed; zero changes |

CI now runs the Chromium regression in addition to the existing gates; the self-hosted Linux runner must have Chromium or Google Chrome installed. Its browser test server needs the generated asset bundle exposed under `test/assets` so PDFium can load its real worker. The workflow creates and removes that temporary symlink. To reproduce locally on Linux with Chromium installed:

```sh
ln -s ../build/unit_test_assets test/assets
trap 'rm test/assets' EXIT
CHROME_EXECUTABLE=chromium flutter test --platform chrome test/browser_startup_test.dart
```

The browser test uses mock preferences and location-service responses while executing the real startup, PDF initialization, existing Web Bluetooth plugin, app font, and screen navigation. Its teardown also cancels timers belonging to process-lifetime services created by `main()`. Android and Linux builds produced dependency/compiler warnings but completed successfully. macOS/iOS builds and real BLE/USB/TCP exchange/reconnect checks still require the relevant hosts and hardware. Previously overwritten message history cannot be reconstructed by these fixes. The optional native PDFium extraction test remains skipped on this test runner.
