# Assets & Resource Pipeline Summary

## Scope & Responsibilities

- Centralizes graphics, audio, and data resources; orchestrates loading, caching, and mod overrides to keep Love2D memory budgets predictable across scenes.
- Maintains inventory/loadout linkage: base warehouses, storage facilities, and procurement orders rely on the same asset registry metadata.
- Ensures tilesets, atlases, and audio banks meet performance budgets (≤512 MB total, ≤500 ms scene loads) via aggressive atlasing and streaming.

## Asset Types & Standards

- **Graphics**: 12×12 native pixel art upscaled to 24×24, packed into power-of-two atlases (UI 512², units 1024², terrain 2048²) with 1px padding to avoid bleed.
- **Audio**: OGG (ambient 128 kbps, combat 128+, SFX 64 kbps), WAV reserved for ultra-short UI cues; streamed when >10 MB.
- **Data**: TOML definitions (units, missions, localization) compiled to cached Lua tables; mod folders can override with fallback hierarchies.

## Pipeline Workflow

1. **Design** specifications + references → sprite/track briefs.
2. **Development** in external tools (Aseprite, Piskel) at 12×12, color variants validated at 24×24.
3. **Integration**: atlas packing, TOML metadata, registry updates, version control.
4. **Testing** in-engine (alignment, animation timing, audio loops) with profiling.
5. **Optimization**: lossless compression, cache priming, documentation of load metrics.

## Performance & Memory Strategy

- Preload assets during scene fade-in (250 ms); stream anything above 10 MB on background threads while showing loading screens when >50 MB pending.
- Cache tiers: in-memory LRU for recent textures, disk cache for prebuilt atlases/parsed TOML, GPU cache per-scene; invalidated on file hash change.
- Scene budgets: Geoscape ~50 MB, Basescape ~30 MB, Battlescape ~80 MB, Menu ~10 MB; desktop target cache 256 MB (128 MB on laptops).

## Tileset & Atlas Management

- Autotiles (47-piece sets), random variants, animations (4–8 frames @100 ms), and 8-way directional sprites provide map variety.
- Tiles describe walkability, cover (0–100), and LOS blocking within TOML; loaded per map with cached sprite references and unloaded when switching maps.

## Inventory, Storage, & Loadouts

- Base inventory capped by `(base level × 500 kg)` plus storage facilities (Small +500 kg, Medium +2,000 kg, Large +5,000 kg); overflow imposes −10% equipment effectiveness per +20% capacity, >150% risks item loss.
- Loadout templates (5 per base) auto-validate weight (<100 kg per unit), class compatibility, and availability; recommended via mission type heuristics.
- Transfers between bases handled via logistics aircraft; maintenance facilities restore +20 durability/month on stored gear.

## Durability & Maintenance

- Global 0–100 durability: weapons −5 per mission, armor −3 per hit, gear −2 per mission; environment modifiers (volcanic +2, underwater +1) and class usage adjustments apply.
- Condition tiers: Pristine (≥75), Worn (50–74), Damaged (25–49, −10% effectiveness), Critical (1–24, −30%), Destroyed (0, lost).
- Repairs cost 1% of purchase price per point and 1 day/10 durability; preventive maintenance facility extends lifespan, but broken items (0) cannot be recovered.

## Modification Framework

- Weapons: 2 slots (scopes, laser sights, extended mags, AP rounds, stocks, rapid-fire modules) with conflict rules (scope ↔ laser sight, silencer ↔ rapid-fire).
- Armor: 1 slot (ceramic plating, lightweight alloy, reactive plating, camouflage overlays, thermal lining).
- Equipment: 1 slot (extended batteries, sensor boosts) where applicable.
- Installations require research unlock, workshop time, +10% mod cost, and −5 durability; mods reusable if removed before item destruction.

## Procurement & Supplier Network

- Supplier relations (−100 enemy → +100 trusted) drive price multipliers (1.5× to 0.5×) and stock (0% to 200%); relationship shifts monthly via purchases, mission performance, and atrocities.
- Orders: max five active per supplier, upfront payment, delivery 1–7 days (regional), 5–14 days (black market), expedited at +50% cost; bulk discounts at 5+/20+/50+ units.
- Tech tiers (Human → Advanced → Alien → Strategic → Endgame) gate catalog entries; black market provides restricted gear with high risk/cost.

## QA Watchlist

- Asset hash invalidation and cache rebuild timing, atlas UV accuracy, streaming-induced frame spikes (<2 ms target) across platforms.
- Inventory overflow penalties, storage destruction loss rolls, loadout validation edge cases (class mismatch, out-of-stock templates).
- Durability decrement formulas per item/environment, repair cost/time alignment, maintenance facility bonuses.
- Modification conflicts enforced, removal reusability, durability reduction on install, and destruction cleanup.
- Supplier pricing multipliers, delivery delays, bulk discount stacking, and tech-tier gating across marketplace and black market flows.
