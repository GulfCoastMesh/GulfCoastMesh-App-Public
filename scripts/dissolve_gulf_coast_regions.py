#!/usr/bin/env python3
"""Dissolve parish/county MultiPolygons into outer-boundary rings only.

Reads assets/geo/gulf_coast_regions.geojson, unions each feature's parts,
keeps exterior rings (drops holes), and overwrites the same file.

Requires: pip install shapely
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from shapely import make_valid
from shapely.geometry import mapping, shape
from shapely.geometry.base import BaseGeometry
from shapely.ops import unary_union

ROOT = Path(__file__).resolve().parents[1]
GEOJSON_PATH = ROOT / "assets" / "geo" / "gulf_coast_regions.geojson"


def _exterior_polygons(geom: BaseGeometry) -> list:
    """Return Polygon geometries using only exterior rings (no holes)."""
    from shapely.geometry import MultiPolygon, Polygon

    if geom.is_empty:
        return []

    geom = make_valid(geom)

    polys: list[Polygon] = []
    if geom.geom_type == "Polygon":
        polys = [geom]
    elif geom.geom_type == "MultiPolygon":
        polys = list(geom.geoms)
    elif geom.geom_type == "GeometryCollection":
        for g in geom.geoms:
            polys.extend(_exterior_polygons(g))
        return polys
    else:
        return []

    out: list[Polygon] = []
    for p in polys:
        if p.is_empty:
            continue
        # Drop holes so the map stroke is only the region silhouette.
        clean = Polygon(p.exterior)
        if not clean.is_empty and clean.area > 0:
            out.append(clean)
    return out


def dissolve_feature(feature: dict) -> dict:
    geom = shape(feature["geometry"])
    unioned = unary_union(geom)
    exteriors = _exterior_polygons(unioned)
    if not exteriors:
        raise ValueError(
            f"Dissolve produced empty geometry for {feature.get('properties')}"
        )

    if len(exteriors) == 1:
        out_geom = exteriors[0]
    else:
        from shapely.geometry import MultiPolygon

        out_geom = MultiPolygon(exteriors)

    return {
        "type": "Feature",
        "properties": dict(feature.get("properties") or {}),
        "geometry": mapping(out_geom),
    }


def main() -> int:
    path = GEOJSON_PATH
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])

    data = json.loads(path.read_text())
    features = data.get("features") or []
    dissolved = []
    for feat in features:
        code = (feat.get("properties") or {}).get("code", "?")
        before = (
            len(feat["geometry"]["coordinates"])
            if feat["geometry"]["type"] == "MultiPolygon"
            else 1
        )
        out = dissolve_feature(feat)
        after = (
            len(out["geometry"]["coordinates"])
            if out["geometry"]["type"] == "MultiPolygon"
            else 1
        )
        print(f"{code}: {before} parts -> {after} outer ring(s)")
        dissolved.append(out)

    data["features"] = dissolved
    path.write_text(json.dumps(data, separators=(",", ":")))
    print(f"Wrote {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
