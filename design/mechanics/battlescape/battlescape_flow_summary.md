# Battlescape Flow Summary

## Map Generation Pipeline

- Biome selection drives terrain palette, block lists, and script rules (forest vs desert vs interior). Scripts assemble 15-hex blocks into 4×4 to 7×7 grids, rotating/mirroring as needed before committing to the unified battlefield.
- Step order: select biome/terrain → assign blocks via script directives → apply transforms → stitch into final grid → record block boundaries for deployments.
- Post-assembly passes layer ambient props, pre-battle hazards (fires, smoke), and fog-of-war initialization, ensuring LoS-ready state at mission start.

## Landing Zones & Scale

- Landing zones correspond to map size: Small=1, Medium=2, Large=3, Huge=4. Each zone occupies a dedicated block free of enemies/obstacles and is the only legal deployment area for players.
- No vehicles present on-map; units deploy as infantry stacks, forcing initial tactical spread within the chosen zone.

## Enemy Deployment Pipeline

1. **Squad Build**: Mission script defines unit counts, split into squads based on type (UFO crash: 50% guarding craft, remainder patrolling; base defense: interior garrisons + reinforcements, etc.). Difficulty scales personnel and reinforcement counts.
2. **Auto Promotion**: Each squad receives XP budgets; promotion tree upgrades rank, abilities, and gear until budget spent, then inventory finalised.
3. **Block Priorities**: Mission goals and terrain chokepoints score each map block. Squads claim highest-priority blocks, one per block.
4. **Tile Placement**: Units seeded randomly on free tiles within their block, respecting terrain passability and avoiding landing zones.

## Neutral & Environmental Setup

- Neutral NPCs (civilians, facility staff) populate assigned tiles regardless of proximity to player/enemy units; base defense missions also spawn stationary turrets.
- Environmental hazards (fires, gas, smoke) and fog-of-war computed last; LoS from player units reveals initial tiles while hidden areas remain shrouded.

## Entity Layering

- Tile components: floor (movement cost), walls (block movement/fire), objects (up to five ground items/corpses), units (block movement, partial LoF), smoke/fire hazards, and roof visuals for future verticality.
- Environmental intensities drive sight and fire costs (smoke adds 2–4 sight cost, fire adds movement penalties and DoT, etc.).

## Weather & Special Conditions

- Weather applies global modifiers: Rain (+1 sight cost, +1 move, −1 fire), Snow (+2 sight, +2 move, −2 fire), Blizzard (+3 sight, +3 move, −3 fire), etc.
- Special mission templates (night, underground, facility) override weather, enforce sight caps, spawn neutral defenders, and restrict map geometry.

## QA Focus

- Validate block scripts produce legal landing zones and respect mission constraints across all map sizes.
- Ensure promotion budgets, prioritized block assignments, and tile placements avoid overlaps and illegal spawns.
- Confirm weather/special-condition modifiers propagate to sight, fire, and movement costs, and that fog-of-war initialization matches LoS calculations.
