#!/usr/bin/env python3
"""Bundle the app's complete Gulf Coast region catalog as one local asset.

The source embeds all geometry collections, so the app never fetches boundary
files at runtime. Refresh explicitly from the repository root with:

    python3 scripts/sync_region_index.py
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
import shutil
import urllib.request

SOURCE_URL = "https://docs.gulfcoastmesh.org/regions.json"
REPO_ROOT = Path(__file__).resolve().parents[1]
ASSET_FILE = REPO_ROOT / "assets" / "geo" / "regions.json"
PICKER_ASSET_FILE = REPO_ROOT / "assets" / "geo" / "gulf_coast_regions.geojson"
PICKER_REGION_CODES = (
    "us-la-msy", "us-la-lft", "us-la-lc", "us-ms-gpt",
    "us-ms", "us-pns", "us-la", "us-gc",
)
LEGACY_ASSET_DIR = REPO_ROOT / "assets" / "geo" / "regions"
MAX_FILE_BYTES = 20 * 1024 * 1024


def fetch() -> tuple[bytes, str | None]:
    request = urllib.request.Request(
        SOURCE_URL,
        headers={
            "Accept": "application/json,*/*",
            "Referer": "https://docs.gulfcoastmesh.org/",
            "User-Agent": "Gulf Coast Mesh region asset sync/1.0",
        },
    )
    with urllib.request.urlopen(request, timeout=45) as response:
        payload = response.read(MAX_FILE_BYTES + 1)
        if len(payload) > MAX_FILE_BYTES:
            raise ValueError(f"Refusing oversized response from {SOURCE_URL}")
        return payload, response.headers.get("Last-Modified")


def _validate_position(position: object, label: str) -> None:
    if (
        not isinstance(position, list)
        or len(position) < 2
        or not isinstance(position[0], (int, float))
        or not isinstance(position[1], (int, float))
        or not math.isfinite(position[0])
        or not math.isfinite(position[1])
    ):
        raise ValueError(f"{label} contains an invalid GeoJSON coordinate")


def _validate_polygon(coordinates: object, label: str) -> None:
    if not isinstance(coordinates, list) or not coordinates:
        raise ValueError(f"{label} has no polygon coordinate rings")
    for ring in coordinates:
        if not isinstance(ring, list) or len(ring) < 4:
            raise ValueError(f"{label} has an invalid polygon ring")
        for position in ring:
            _validate_position(position, label)


def validate_catalog(payload: bytes) -> tuple[dict, int, int]:
    document = json.loads(payload)
    if not isinstance(document, dict):
        raise ValueError("The region catalog root must be a JSON object")
    regions = document.get("regions")
    geometries = document.get("geometries")
    policy = document.get("policy")
    if not isinstance(regions, list) or not regions:
        raise ValueError("The region catalog must contain a non-empty regions array")
    if not isinstance(geometries, dict) or not geometries:
        raise ValueError("The region catalog must embed its geometry collections")
    if not isinstance(policy, dict):
        raise ValueError("The region catalog is missing its policy object")

    ids: set[str] = set()
    geometry_urls: set[str] = set()
    for position, region in enumerate(regions):
        if not isinstance(region, dict):
            raise ValueError(f"Region entry {position} must be an object")
        region_id = region.get("id")
        name = region.get("name")
        geometry_url = region.get("geometry")
        if not isinstance(region_id, str) or not region_id.strip() or region_id in ids:
            raise ValueError(f"Invalid or duplicate region id: {region_id!r}")
        if not isinstance(name, str) or not name.strip():
            raise ValueError(f"Region {region_id} is missing its name")
        if not isinstance(geometry_url, str) or geometry_url not in geometries:
            raise ValueError(f"Region {region_id} has no embedded geometry")
        ids.add(region_id)
        geometry_urls.add(geometry_url)

    shape_count = 0
    for geometry_url, collection in geometries.items():
        if not isinstance(collection, dict) or collection.get("type") != "GeometryCollection":
            raise ValueError(f"{geometry_url} is not a GeometryCollection")
        shapes = collection.get("geometries")
        if not isinstance(shapes, list) or not shapes:
            raise ValueError(f"{geometry_url} has no geometry shapes")
        for shape in shapes:
            if not isinstance(shape, dict):
                raise ValueError(f"{geometry_url} contains a malformed geometry")
            shape_type = shape.get("type")
            coordinates = shape.get("coordinates")
            if shape_type == "Polygon":
                _validate_polygon(coordinates, geometry_url)
            elif shape_type == "MultiPolygon":
                if not isinstance(coordinates, list) or not coordinates:
                    raise ValueError(f"{geometry_url} has invalid MultiPolygon coordinates")
                for polygon in coordinates:
                    _validate_polygon(polygon, geometry_url)
            else:
                raise ValueError(f"{geometry_url} has unsupported shape type {shape_type!r}")
            shape_count += 1

    if not geometry_urls.issubset(geometries):
        raise ValueError("One or more region geometries are not embedded")
    return document, len(regions), shape_count


def build_picker_geometry(document: dict) -> bytes:
    """Use the same snapshot for the map picker, without internal borders."""
    from dissolve_gulf_coast_regions import dissolve_feature

    regions = {region["id"]: region for region in document["regions"]}
    features = []
    for code in PICKER_REGION_CODES:
        region = regions[code]
        features.append(dissolve_feature({
            "type": "Feature",
            "properties": {"code": code},
            "geometry": document["geometries"][region["geometry"]],
        }))
    return json.dumps({
        "type": "FeatureCollection",
        "features": features,
    }, separators=(",", ":")).encode("utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--from-bundle", action="store_true",
        help="Regenerate picker geometry from the existing catalog without downloading.",
    )
    args = parser.parse_args()
    if args.from_bundle:
        payload, modified = ASSET_FILE.read_bytes(), None
    else:
        payload, modified = fetch()
    document, region_count, shape_count = validate_catalog(payload)
    # Generate before replacing either asset so missing scopes or invalid
    # geometry cannot leave the picker using a different source snapshot.
    picker_payload = build_picker_geometry(document)

    # Replace the single asset only after the complete catalog validates.
    ASSET_FILE.parent.mkdir(parents=True, exist_ok=True)
    temporary_file = ASSET_FILE.with_suffix(".json.tmp")
    temporary_file.write_bytes(payload)
    temporary_file.replace(ASSET_FILE)
    picker_temporary_file = PICKER_ASSET_FILE.with_suffix(".geojson.tmp")
    picker_temporary_file.write_bytes(picker_payload)
    picker_temporary_file.replace(PICKER_ASSET_FILE)

    # Remove the boundary files from the previous source snapshot, now replaced
    # by the all-in-one docs endpoint. This path was dedicated to those assets.
    if LEGACY_ASSET_DIR.exists():
        shutil.rmtree(LEGACY_ASSET_DIR)

    unique_geometry_count = len(document["geometries"])
    print(
        f"Synced {region_count} region entries and {unique_geometry_count} embedded "
        f"geometry groups ({shape_count} shapes, {len(payload):,} bytes). "
        f"Source Last-Modified: {modified or 'not supplied'}."
    )
    print(f"Regenerated {len(PICKER_REGION_CODES)} dissolved picker boundaries.")


if __name__ == "__main__":
    main()
