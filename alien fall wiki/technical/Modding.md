# Modding System

AlienFall’s modding toolkit is centred on TOML data files and Love2D-friendly Lua scripts. This document updates the legacy guidance to reflect the current pipeline and security model.

## Table of Contents
- [Overview](#overview)
- [Mod Structure](#mod-structure)
- [Loading Pipeline](#loading-pipeline)
- [Dependency Resolution](#dependency-resolution)
- [Asset Overrides](#asset-overrides)
- [Data Merging](#data-merging)
- [Sandboxed Lua Scripts](#sandboxed-lua-scripts)
- [Validation & Diagnostics](#validation--diagnostics)
- [Performance Notes](#performance-notes)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [Tags](#tags)

## Overview
- **Data-first:** Mods author content in TOML. The engine loads and validates TOML into Lua tables at runtime.
- **Lua engine:** Core game logic is Love2D + Lua 5.1. Mods may include optional Lua scripts executed in a sandbox with a whitelisted API.
- **Deterministic merges:** All overrides preserve determinism (seed logging, conflict resolution order).
- **Grid alignment:** Any UI content added by mods must respect the 20×20 logical grid and 10×10 sprite scaling rule.

## Mod Structure
```
mods/
  my_mod/
    mod.toml            # required metadata
    assets/             # optional art/audio (10×10 sprites scaled ×2)
    data/               # TOML files defining content
    scripts/            # optional Lua scripts (sandboxed)
    localization/       # optional TOML translation tables
```

### mod.toml Requirements
- `id` – unique string identifier
- `version` – semantic version (e.g., `1.2.0`)
- `author`, `description`
- `dependencies` – table of required/optional mod ids with version ranges
- `load_priority` – integer; higher values load later
- `compatibility` – supported game version range
- `tags` – keywords for filtering (e.g., `weapons`, `ui`, `campaign`)

### Data Folder
- Place TOML files mirroring base game structures (`items.toml`, `units.toml`, etc.).
- Each file must match schemas documented in subsystem READMEs.
- Use tables, arrays, and inline tables—YAML/JSON are **not** supported.

### Scripts Folder (Optional)
- Lua files for advanced behaviour (event handlers, generated content).
- Entry point is optional `scripts/init.lua`; other files loaded via `require` within sandbox.

## Loading Pipeline
1. **Discovery:** Scan `mods/` for folders with `mod.toml`. Validate metadata.
2. **Dependency Graph:** Build directed graph; perform cycle detection; compute load order.
3. **Data Load:** For each mod (in order):
   - Parse TOML into Lua tables.
   - Validate against schema (type checks, required fields).
   - Merge into runtime catalogs.
4. **Asset Registration:** Register images, audio, fonts using priority-based lookup.
5. **Script Execution:** If scripts exist, run `init.lua` in sandbox after data merges.
6. **Final Validation:** Run post-merge checks (e.g., unresolved references) and log diagnostics.

## Dependency Resolution
- Required vs optional dependencies specified in `mod.toml`.
- Version constraints use semver expressions (`>= 1.0.0`, `^2.1.0`).
- If required mods missing or incompatible, loader aborts before data merge.
- Optional dependencies allow conditional hooks (checked at runtime via API).

## Asset Overrides
- Supported types: sprites (PNG), audio (OGG/WAV), fonts (TTF), shaders.
- Override order: later mods replace earlier ones when paths match exactly.
- Mods must respect art guidelines (10×10 source, scaled ×2) and align UI assets to the 20×20 grid.
- Assets outside `assets/` are ignored.

## Data Merging
- Deep-merge TOML tables by primary key (typically `id`).
- Scalars: last-wins by load order.
- Arrays: append by default; mods may specify `mode = "replace"` per dataset where supported.
- Type mismatches raise validation errors to prevent silent corruption.

## Sandboxed Lua Scripts
- Sandboxes expose limited globals: math, table, string, pairs/ipairs, and whitelisted game APIs.
- Forbidden operations: `require` outside sandbox path, file IO, OS calls, networking.
- Script API highlights:
  - `ModApi.registerEventHandler(eventName, handler)`
  - `ModApi.getData(namespace, id)`
  - `ModApi.log(level, message)`
  - `ModApi.scheduleTask(delayHours, callback)`
- Execution time monitored; long-running scripts are terminated with warnings.

## Validation & Diagnostics
- Metadata check: missing fields, duplicate ids, invalid versions.
- Schema validation: type/enum checking against subsystem definitions.
- Asset validation: ensure referenced asset files exist.
- Script lint: syntax parse using Lua interpreter before sandbox execution.
- Diagnostics log to `logs/mod_loader.log` with severity levels.

## Performance Notes
- Lazy load assets when first requested.
- Memoize parsed TOML to speed up subsequent launches (cache invalidated by mod timestamp).
- Avoid large Lua tables or tight loops in sandbox; keep script work incremental.
- For heavy data transforms, pre-process offline and ship TOML with final values.

## Examples
### Minimal Metadata
```toml
id = "advanced_weapons"
version = "1.0.0"
author = "WeaponMaster"
description = "Adds plasma weapons to mid-game." 
compatibility = "1.0.0 - 1.0.99"
load_priority = 100

[dependencies]
required = ["core >= 1.0.0"]
optional = ["enhanced_ui >= 1.1.0"]

tags = ["weapons", "combat"]
```

### Weapon Definition (TOML)
```toml
[[weapons]]
id = "plasma_rifle"
name = "Plasma Rifle"
class = "rifle"
base_damage = 45
accuracy = 0.75
ap_cost = 2
energy_cost = 8
range_bands = [
  { range = "close", multiplier = 1.0 },
  { range = "medium", multiplier = 0.9 },
  { range = "long", multiplier = 0.7 }
]
``` 

### Optional Script Hook
```lua
-- scripts/init.lua
local ModApi = ...

ModApi.registerEventHandler("battlescape:mission_start", function(payload)
  if payload.missionId == "alien_fortress" then
    ModApi.log("info", "Boosting plasma rifle drop chance")
    ModApi.modifyLootTable({ weapon = "plasma_rifle", weight = 5 })
  end
end)
```

## Related Wiki Pages
- [Technical Overview](README.md)
- [Items README](../items/README.md)
- [Units README](../units/README.md)
- [Economy README](../economy/README.md)
- [Geoscape README](../geoscape/README.md)
- [Battlescape README](../battlescape/README.md)

## Tags
`#modding` `#toml` `#lua` `#love2d` `#grid20x20`

