# Hex Coordinate Summary

## Unified Vertical Axial Grid

- All layers (Geoscape, Battlescape, Basescape) share vertical axial coordinates `{q, r}` with flat-top hexes; odd columns shift down 0.5 hex for staggered layout.
- Cube conversion `{x=q, z=r, y=-x-z}` enables distance calculation: `( |Δx| + |Δy| + |Δz| ) / 2`.
- Neighbor offsets fixed: (E) {+1,0}, (SE) {0,+1}, (SW) {−1,+1}, (W) {−1,0}, (NW) {0,−1}, (NE) {+1,−1}.

## Map Construction

- Map blocks contain 15 hexes in 3-4-5-4-3 rings; battlefields assemble 4×4 to 7×7 blocks (≈240–735 tiles) with rotations/mirroring for variety.
- Geoscape grid spans 90×45 hexes with horizontal wrap; provinces, countries, and regions align to this lattice.
- Bases align facilities on the same coordinate system, simplifying pathfinding and modding.

## Rendering & Movement

- Pixel conversion: `pixelX = size * √3 * q`, `pixelY = size * 1.5 * r`, plus 0.75 size offset for odd q columns; default hex radius 24 px.
- Movement costs typically 1 TU per hex; terrain modifies costs but never allows diagonal shortcuts—movement stays on hex adjacency.

## Benefits & Guidelines

- Eliminates inter-layer conversion bugs, standardizes pathfinding, and ensures consistent API (`moveTo(q, r)`).
- Visual skew is intentional; documentation and UI underscore hex orientation to limit player confusion.
- Testing priorities: neighbor enumeration, cube conversions, pixel mapping, and map-block assembly integrity across rotations.
