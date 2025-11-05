# Battlescape API Snapshot

## Scope & Responsibilities

- Governs tactical encounters: hex-grid generation, unit orchestration, action economy, LOS/cover, environmental effects, and victory resolution.
- Integrates with Geoscape for mission deployment, Units/Items for actor data, and feeds results back to campaign state.

## Architecture Highlights

- Core modules: Battle (session container), BattleMap (tiles/blocks), BattleRound (turn manager), BattleUnit, BattleAction, BattleVision, BattleEnvironment.
- Spatial hierarchy: tile -> 15-hex map block -> map grid (4x4-7x7 blocks) -> battlefield; supports rotations/mirroring for procedural variety.
- Unified vertical axial coordinate system (axial `{q,r}`, cube `{x,y,z}`, pixel for rendering) shared across game layers.

## Key Systems

- Turn economy: AP-based actions, initiative ordering, overwatch/reaction system, wounds and critical hits, morale/sanity checks.
- Environment: biome-driven procedural maps, weather imports, destructible terrain, hazards (fire, smoke, gas), aura effects.
- AI integration: tactical decision hooks, status effect processing, squad coordination.
- Data interfaces: mission seeds, squad templates, inventory payloads, battle results (casualties, loot, XP).

## Extensibility Points

- Future roadmap includes directional vision cones, vertical multi-level maps, dynamic weather shifts, advanced stealth layers, squad formations, physics-driven destructibles, adaptive AI, multiplayer, and mod-defined terrain/abilities.
- Mod API expected to expose terrain registration, action definitions, and AI behavior overrides once roadmap items land.

## Implementation Notes & QA

- Ensure LOS and fog-of-war calculations update per action and respect obstruction weights (0.0-1.0).
- Validate hex coordinate conversions (axial<->cube<->pixel) to avoid desync between rendering and simulation.
- Regression focus on procedural generation determinism, initiative ordering, reaction triggers, and data handoff to Geoscape save pipeline.
- Monitor roadmap gap: directional sight, multi-level maps, and dynamic weather currently absent; document when first prototypes land to update API reference.
