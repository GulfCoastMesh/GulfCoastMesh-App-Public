# Locally bundled region catalog

The Gulf Coast Mesh Flutter app packages the complete catalog from
<https://docs.gulfcoastmesh.org/regions.json>. It includes the 82 region entries,
all 76 embedded geometry collections, and the source policy metadata (including
aliases and area definitions) in one local asset at `assets/geo/regions.json`.
The region-boundary map reads this bundled file and does not fetch the docs site
or the geometry URLs at runtime. Base map tiles are separate and use the app's
existing cache-first OpenStreetMap tile layer.

Repeater remote settings use **Choose regions on map** to select an installation
point (or enter coordinates). The lookup checks every catalog boundary,
regardless of which layers are visible, and follows the region-codes website's
policy: exclude optional and unapproved statuses, include matching geographic
scopes, and add each local area's MeshMapper / Louisiana codes. The resulting
allow list and unscoped traffic (`*`) are staged in the editor; **Save Regions**
writes them through the existing remote CLI flow. Existing home selection and
other region flags are preserved, apart from the recommended scopes becoming
allowed.

To refresh the snapshot from the repository root, run:

```sh
python3 scripts/sync_region_index.py
```

The sync script validates the full index, policy, and every embedded Polygon or
MultiPolygon before replacing the bundled asset. It also regenerates the eight
Gulf Coast scope-picker silhouettes in `assets/geo/gulf_coast_regions.geojson`
from that same catalog, dissolving internal county/parish borders with Shapely
(`python3 -m pip install shapely`). To regenerate those silhouettes from the
existing local snapshot without downloading, use `--from-bundle`.
It removes the previous
`assets/geo/regions/` snapshot after the new file has been validated and saved.

The last verified source snapshot was retrieved at
`2026-10-06T16:50:32.918643+00:00` from the URL above. This snapshot adds
Demopolis AL Mesh (`us-al-dya`), refreshes the Jacksonville geometry, and
replaces the MSY MeshMapper entry with aliases to `us-la-msy`.

The app's operational scopes use `us-gc`, `us-la`, `us-ms`, `us-pns`,
`us-ms-gpt`, `us-la-msy`, `us-la-lft`, and `us-la-lc`. Compatibility aliases
in `RegionScopeCodes` migrate earlier app codes in saved channel scopes,
known-region lists, and channel invites. Custom scopes retain their spelling.
Repeater presets follow the source policy: PNS uses `gc-fl-pns-mm`, LFT uses
`gc-la-lft-mm`, GPT uses `us-ms-gpt-mm`, and MSY uses `us-la-msy`.
The catalog tests verify these choices against the policy on every refresh.

Existing repeater configurations are read using their actual device names;
the editor stages a migrated draft and writes it when the user saves Regions.
An existing companion default scope is migrated when the user applies it in
settings. The protocol frame layout and public-scope key derivation are unchanged.
