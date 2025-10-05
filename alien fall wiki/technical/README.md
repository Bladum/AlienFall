# Technic## Architectural Principles
- **Love2D Core:** `LOVE/main.lua` bootstraps the application, instantiates services, and manages the state stack.
- **Service Locator:** Lightweight registry exposes shared services (e.g., `EventBus`, `TimeService`, `EconomyService`). Each service is a Lua table with lifecycle functions (`init`, `update`, `shutdown`).
- **State Stack:** Screens (menu, geoscape, basescape, interception, battlescape, pedia) push/pop states. Input, update, and draw route to the top-most state.
- **Deterministic RNG:** `RngService:get(scope)` returns generators seeded by campaign + subsystem identifiers. Never use Lua's global `math.random` directly.

---

## Architecture Diagrams

### Service Architecture

```mermaid
graph TB
    subgraph "Application Core"
        MAIN[main.lua<br/>Bootstrap]
        SERVICE[ServiceLocator<br/>Registry]
        STATE[StateStack<br/>Screen Manager]
    end
    
    subgraph "Core Services"
        EVENT[EventBus<br/>Pub/Sub System]
        TIME[TimeService<br/>Scheduling]
        RNG[RngService<br/>Deterministic Random]
        SAVE[SaveService<br/>Persistence]
        ASSET[AssetService<br/>Resource Loading]
    end
    
    subgraph "Game Services"
        ECON[EconomyService<br/>Resources/Funding]
        UNIT[UnitService<br/>Soldier Management]
        RESEARCH[ResearchService<br/>Tech Tree]
        MISSION[MissionService<br/>Spawning/Tracking]
    end
    
    subgraph "Screen States"
        MENU[MenuState]
        GEO[GeoscapeState]
        BASE[BasescapeState]
        BATTLE[BattlescapeState]
        INTER[InterceptionState]
    end
    
    MAIN --> SERVICE
    MAIN --> STATE
    
    SERVICE --> EVENT
    SERVICE --> TIME
    SERVICE --> RNG
    SERVICE --> SAVE
    SERVICE --> ASSET
    SERVICE --> ECON
    SERVICE --> UNIT
    SERVICE --> RESEARCH
    SERVICE --> MISSION
    
    STATE --> MENU
    STATE --> GEO
    STATE --> BASE
    STATE --> BATTLE
    STATE --> INTER
    
    GEO -.uses.-> TIME
    GEO -.uses.-> MISSION
    BASE -.uses.-> ECON
    BASE -.uses.-> RESEARCH
    BATTLE -.uses.-> UNIT
    BATTLE -.uses.-> RNG
    
    style MAIN fill:#4a90e2
    style SERVICE fill:#50c878
    style STATE fill:#ffa500
```

### Data Flow Pipeline

```mermaid
graph LR
    subgraph "Source Data"
        TOML[TOML Files<br/>data/*.toml]
        ASSETS[Assets<br/>sprites/audio/tiles]
        MODS[Mod Content<br/>mods/*/]
    end
    
    subgraph "Loading Pipeline"
        PARSER[TOML Parser<br/>toml.lua]
        VALIDATOR[Schema Validator<br/>data/schema/*.lua]
        MERGER[Mod Merger<br/>Priority + Deps]
        LOADER[Asset Loader<br/>Love2D APIs]
    end
    
    subgraph "Runtime Data"
        TABLES[Lua Tables<br/>In-Memory Data]
        TEXTURES[Textures<br/>Sprite Batches]
        AUDIO_BUF[Audio Buffers<br/>OGG/WAV]
    end
    
    subgraph "Services"
        GAME[Game Services<br/>Use Data]
    end
    
    TOML --> PARSER
    PARSER --> VALIDATOR
    VALIDATOR -->|Valid| TABLES
    VALIDATOR -->|Invalid| ERROR[Diagnostic Overlay]
    
    MODS --> MERGER
    MERGER --> PARSER
    
    ASSETS --> LOADER
    LOADER --> TEXTURES
    LOADER --> AUDIO_BUF
    
    TABLES --> GAME
    TEXTURES --> GAME
    AUDIO_BUF --> GAME
    
    style VALIDATOR fill:#50c878
    style ERROR fill:#ff6b6b
    style GAME fill:#4a90e2
```

### State Management Flow

```mermaid
graph TD
    START[Application Start] --> BOOT[Bootstrap main.lua]
    BOOT --> INIT_SERV[Initialize Services]
    INIT_SERV --> LOAD_DATA[Load Data/Assets]
    LOAD_DATA --> VALIDATE[Validate Schemas]
    
    VALIDATE -->|Success| MENU_STATE[Push MenuState]
    VALIDATE -->|Failure| ERROR_STATE[Show Error Overlay]
    
    MENU_STATE --> MENU_LOOP{Menu Loop}
    MENU_LOOP -->|New Game| NEW_GAME[Initialize Campaign]
    MENU_LOOP -->|Load Game| LOAD_SAVE[Load Save File]
    MENU_LOOP -->|Exit| SHUTDOWN[Cleanup & Exit]
    
    NEW_GAME --> GEO_STATE[Push GeoscapeState]
    LOAD_SAVE --> GEO_STATE
    
    GEO_STATE --> GEO_LOOP{Geoscape Loop}
    GEO_LOOP -->|Mission| PUSH_BATTLE[Push BattlescapeState]
    GEO_LOOP -->|Base| PUSH_BASE[Push BasescapeState]
    GEO_LOOP -->|Interception| PUSH_INTER[Push InterceptionState]
    GEO_LOOP -->|Menu| POP_GEO[Pop to Menu]
    
    PUSH_BATTLE --> BATTLE_STATE[BattlescapeState]
    BATTLE_STATE -->|Complete| POP_BATTLE[Pop to Geoscape]
    POP_BATTLE --> GEO_LOOP
    
    PUSH_BASE --> BASE_STATE[BasescapeState]
    BASE_STATE -->|Exit| POP_BASE[Pop to Geoscape]
    POP_BASE --> GEO_LOOP
    
    PUSH_INTER --> INTER_STATE[InterceptionState]
    INTER_STATE -->|Victory| PUSH_BATTLE
    INTER_STATE -->|Escape| POP_INTER[Pop to Geoscape]
    POP_INTER --> GEO_LOOP
    
    POP_GEO --> MENU_LOOP
    
    ERROR_STATE --> SHUTDOWN
    SHUTDOWN --> END[Application Exit]
    
    style GEO_STATE fill:#50c878
    style BATTLE_STATE fill:#e24a4a
    style BASE_STATE fill:#4a90e2
    style ERROR_STATE fill:#ff6b6b
```

---erview

This README defines the engineering backbone for AlienFall’s Love2D implementation: architecture conventions, data pipelines, save/load, and tooling. It supersedes Python/PySide6 references and standardises our approach.

## Role in AlienFall
- Provide services, state management, and deterministic scheduling for all gameplay systems.
- Ensure assets, data, and mods load consistently across platforms.
- Offer profiling, telemetry, and testing hooks for continuous validation.

## Architectural Principles
- **Love2D Core:** `LOVE/main.lua` bootstraps the application, instantiates services, and manages the state stack.
- **Service Locator:** Lightweight registry exposes shared services (e.g., `EventBus`, `TimeService`, `EconomyService`). Each service is a Lua table with lifecycle functions (`init`, `update`, `shutdown`).
- **State Stack:** Screens (menu, geoscape, basescape, interception, battlescape, pedia) push/pop states. Input, update, and draw route to the top-most state.
- **Deterministic RNG:** `RngService:get(scope)` returns generators seeded by campaign + subsystem identifiers. Never use Lua’s global `math.random` directly.

## Data Pipeline
- **Source Formats:** Author data in TOML, convert to Lua tables at load time using `toml.lua` (bundled under `LOVE/widgets/lib`).
- **Schema Validation:** Each dataset has a schema definition in `data/schema/*.lua`. Validation runs on startup; failures display diagnostics overlay.
- **Hot Reload (Dev Only):** Optional file watcher reloads data tables when running in dev mode (enabled via `LOVE/run_dev.lua`).

## Asset Management
- **Sprites:** 10×10 pixel source art stored under `assets/sprites/`, scaled ×2 by rendering helpers.
- **Audio:** OGG/WAV under `assets/audio/`, loaded lazily.
- **Tilesets:** Battlescape and GUI tilesets live under `assets/tilesets/`. The loader packs them into sprite batches for performance.

## Input Abstraction Layer
- **Purpose**: Normalizes keyboard, mouse, and controller input into high-level UI actions
- **Implementation**: Input mapping layer translates device inputs to semantic actions (`ui_accept`, `ui_cancel`, `ui_next_tab`)
- **Configuration**: Settings stored in `config/input.toml`; remapping updates at runtime without restart
- **Accessibility**: Supports custom key bindings and input device preferences
- **Testing**: Input sequences can be scripted for automated UI testing

## Modding
- Mods reside in `mods/<id>/` with `mod.toml` manifest, `data/`, `assets/`, and optional `scripts/` for sandboxed Lua logic.
- Load order resolved by priority + dependency graph. Conflicts resolved deterministically: higher priority overwrites specific keys; merges handle lists/maps.
- Sandbox restricts available globals; use whitelisted API (documented in `mods/README.md`) to interact with the game.
- **Widget Registration**: Mods may register new widgets via `mods/<id>/gui/widgets.lua`; must declare theme tokens.
- **Theme Overrides**: Theme modifications loaded in priority order; conflicts resolved by load priority with warnings.
- **Localization**: Mod strings stored in `assets/locale/*.toml`; fallback to EN-US if missing.

## Save & Replay
- **Save Format:** Serialized Lua tables compressed with zlib, stored in Love2D save directory under `saves/<campaignId>.sav`.
- **Autosave:** After each player turn (battlescape) and at key geoscape milestones.
- **Replay Metadata:** Stores RNG scopes, mission seeds, and significant choices for deterministic playback.
- **Versioning:** `save_version` increments with breaking changes. Load pipeline applies migrations defined in `data/migrations/*.lua`.

## Telemetry & Profiling
- **Telemetry:** Optional; collects event log entries (`event`, `timestamp`, `seed`, `payload`). Can export to JSON for analysis.
- **Profiling:** Integrate with `ProFi` (lightweight Lua profiler). Start/stop via debug console or dev hotkeys.
- **Logging:** `LogService` handles structured logs with severity levels.

## Testing Infrastructure
- **Unit Tests:** Located under `LOVE/tests/`, run with `busted`. Cover data validation, RNG determinism, and core services.
- **Smoke Tests:** `_GODOT_PROJECT_ALIEN_FALL/` harness retained for comparison snapshots but not authoritative.
- **CI Hooks:** Scripts in `tools/love-test-runner/` allow headless runs.
- **UI Tests:** Automated UI tests defined in `tests/gui/` using scripted input sequences.
- **Screenshot Testing:** Deterministic screenshot harness captures key screens for regression review.
- **Logging Guidelines:** Include screen name, widget id, and seed in debug logs.

## Performance Guidance
- **Rendering Optimization:** Batch draw calls per widget layer using Love2D sprite batches.
- **Memory Management:** Reuse canvases for static elements (e.g., panel chrome) updated only when theme changes.
- **Layout Performance:** Defer heavy layout recalculation until `love.update` loops to avoid input jitter.
- **Asset Loading:** Load assets lazily and cache aggressively for performance.
- **Profiling:** Use `ProFi` lightweight Lua profiler for performance analysis.

## Event Bus Reference
- `EventBus:publish(eventName, payload)`
- `EventBus:subscribe(eventName, handler, opts?)`
- `EventBus:unsubscribe(token)`
- Events are namespaced (e.g., `geoscape:mission_spawned`). Payloads must be table literals to support serialization.

## Development Workflow
1. Update TOML data ➜ run validation (`make validate` or VS Code task).
2. Implement Lua services/states adhering to Love2D style (locals only, no globals).
3. Run Love2D with dev flags for hot reload and debugging overlays.
4. Execute tests (`love . -- test`) before committing.

## Grid & Visual Standards
- Reinforce 20×20 logical grid for screens; helper module `ui/grid.lua` computes snap positions.
- Scaling handled centrally: 10×10 art scaled ×2 when drawn.

## Related Reading
- [Modding README](../technical/Modding.md)
- [GUI Specification](../GUI.md)
- [Economy README](../economy/README.md)
- [Battlescape README](../battlescape/README.md)
- [Geoscape README](../geoscape/README.md)

## Tags
`#technical` `#love2d` `#architecture` `#modding` `#determinism`
