# AlienFall Love2D - AI Agent System Prompt

## 🤖 AUTONOMOUS AGENT MODE

**Execute autonomously:** Take initiative → Validate each step → Fix errors before reporting → Follow Design → API → Architecture → Engine → Mods → Tests

**Workflow:**
```
Request → Check docs (design/, api/, architecture/) → Plan → Implement engine/ + mods/ → Write tests/ → Verify → Update docs
```

**Critical Actions:**
- **Before:** Check `design/mechanics/`, `api/`, `architecture/` | Run `lovec "engine"`
- **After:** Run `lovec "tests2/runners" run_subsystem [name]` | Fix errors immediately
- **Always:** Update docs, commit atomically, use `temp/` for temporary files

---

## Project: AlienFall (XCOM-inspired Love2D Strategy Game)

**Core:** Turn-based | Moddable | Data-driven TOML | Geoscape + Battlescape + Basescape
**Docs:** [README](../README.md) | [Design](../design/README.md) | [API](../api/README.md) | [Architecture](../architecture/README.md) | [Tests](../tests2/README.md)

---

## Commands

**Run:** `lovec "engine"` or `run_xcom.bat`
**Test:** `lovec "tests2/runners" run_all` | `run_subsystem [name]` | `run_single_test [path]`
**Debug:** `print("[Module] " .. tostring(value))`
**Safe:** `local ok, err = pcall(func, args); if not ok then print("[ERROR] " .. err) end`
**Temp:** Always use `temp/` directory

**Validation:** `lovec "engine"` → `lovec "tests2/runners" run_subsystem [subsystem]` → Use `get_errors` tool → Verify docs

---

## Directory Structure

```
api/ -- 36 API files + GAME_API.toml (SOURCE OF TRUTH)
architecture/ -- Mermaid diagrams (core/, layers/, systems/)
design/ -- Game mechanics specs (mechanics/, gaps/)
engine/ -- Lua implementation (main.lua, core/, geoscape/, battlescape/, basescape/, ai/, gui/)
tests2/ -- 2493+ tests <1s (framework/, [subsystems]/, runners/, generators/)
logs/ -- Runtime data (game/, tests/, mods/, system/, analytics/) - READ FIRST for debugging
docs/ -- Central hub (chatmodes/, instructions/, prompts/, system/, handbook/, processes/)
mods/ -- Content (core/rules/*.toml, core/assets/, minimal_mod/, examples/)
tools/ -- 9 utilities (validators, generators, editors)
temp/ -- Temporary work (USE THIS)
run/ -- Automation scripts (.bat files)
```

**Links:** [API](../api/README.md) | [Architecture](../architecture/README.md) | [Design](../design/README.md) | [Tests](../tests2/README.md) | [Logs](../logs/README.md) | [Docs Hub](../docs/README.md) | [Mods](../mods/README.md) | [Tools](../tools/README.md)

---

## Documentation Index

**Hub:** [docs/README.md](../docs/README.md)

### AI Personas & Development Guides
- **23 ChatModes:** [docs/chatmodes/](../docs/chatmodes/) | [Quick Ref](../docs/chatmodes/QUICK-REFERENCE.md) - Strategic, Design, Implementation, Testing, Analysis, Support layers
- **24 Practices:** [docs/instructions/](../docs/instructions/) | [Index](../docs/instructions/INDEX_ALL_24_PRACTICES.md) | [Start Here](../docs/instructions/START_HERE.md) - Programming, Art, Design, DevOps, Management, Security, Global, Community
- **27 Prompts:** [docs/prompts/](../docs/prompts/) - add_unit, add_item, add_craft, add_mission, add_facility, add_research, add_event, etc.

**Key Guides:**
- [🛠️ Love2D & Lua](../docs/instructions/🛠️%20Love2D%20&%20Lua.instructions.md) | [🧪 Testing](../docs/instructions/🧪%20Testing.instructions.md) | [🔄 Git](../docs/instructions/🔄%20Git%20Workflow%20&%20Collaboration.instructions.md) | [🎮 Mechanics](../docs/instructions/🎮%20Game%20Mechanics.instructions.md) | [⚔️ Combat](../docs/instructions/⚔️%20Battlescape%20&%20AI.instructions.md)

### System Patterns & Creation
- **9 Universal Patterns:** [docs/system/](../docs/system/) - Separation of Concerns, Pipeline Architecture, Data-Driven Content, Hierarchical Testing, Task Management, Automation, AI Guidance, Infrastructure, Logging
- **Creation Prompts:** [ChatMode](../docs/system/create_chatmode.prompt.md) | [Instruction](../docs/system/create_instruction.prompt.md) | [Prompt](../docs/system/create_prompt.prompt.md) | [Pattern](../docs/system/create_system_pattern.prompt.md)

### Technical Documentation
- **API:** [api/README.md](../api/README.md) - GAME_API.toml (master schema), 36 system APIs, [Guide](../api/GAME_API_GUIDE.md), [Sync](../api/SYNCHRONIZATION_GUIDE.md), [Modding](../api/MODDING_GUIDE.md), [Naming](../api/NAMING_CONVENTIONS.md)
- **Architecture:** [architecture/README.md](../architecture/README.md) - Mermaid diagrams, state machines, [Guide](../architecture/ARCHITECTURE_GUIDE.md), [Roadmap](../architecture/ROADMAP.md)
- **Design:** [design/README.md](../design/README.md) - [Template](../design/DESIGN_TEMPLATE.md), [Glossary](../design/GLOSSARY.md), mechanics/, gaps/
- **Testing:** [tests2/README.md](../tests2/README.md) - [Quick Ref](../tests2/QUICK_REFERENCE.md), 2493+ tests, <1s runtime, 3-level hierarchy, 75%+ coverage target
- **Tools:** [tools/README.md](../tools/README.md) - Map Editor, World Editor, Asset Verification, Spritesheet Generator, Import Scanner, Docs Validator, QA System
- **Mods:** [mods/README.md](../mods/README.md) - [Modding Guide](../api/MODDING_GUIDE.md), core/, minimal_mod/, examples/
- **Logs:** [logs/README.md](../logs/README.md) - Runtime data (game/, tests/, mods/, system/, analytics/) - READ FIRST for debugging

**Workflow:** Design → API → Architecture → Engine → Mods → Tests


---

## Mod System

**Docs:** [mods/README.md](../mods/README.md) | [MODDING_GUIDE.md](../api/MODDING_GUIDE.md) | [GAME_API.toml](../api/GAME_API.toml)

**Structure:** `mods/core/` (base content) | `mods/minimal_mod/` (template) | `mods/examples/` (samples)

**Quick Start:**
1. Copy `minimal_mod/` → Edit `mod.toml` (id, name, version, dependencies)
2. Add TOML to `rules/[type]/` (units, items, facilities, etc.) - Follow `api/GAME_API.toml` schema
3. Add assets to `assets/[type]/` (24x24 PNG for units, 12x12 or 24x24 for items, OGG for audio)
4. Test: `lovec "engine"` - Check console for loading messages

**Content Prompts:** Use `docs/prompts/add_*.prompt.md` for structured content creation (27 prompts available)

**Best Practices:** Unique IDs with mod prefix | Follow core/ structure | Test with core only first | Document in README.md

---

## Code Standards

**Lua:** Clean code, meaningful names, avoid globals, use `pcall` for error handling
**Naming:** snake_case (files), PascalCase (modules), camelCase (functions/vars)
**Love2D:** Structure around callbacks, separate logic/render/input
**Testing:** Keep current, write unit + integration tests
**Docs:** [🛠️ Love2D & Lua](../docs/instructions/🛠️%20Love2D%20&%20Lua.instructions.md) | [🧪 Testing](../docs/instructions/🧪%20Testing.instructions.md)

---

## Testing

**Framework:**
```lua
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("MyModule", "tests2/subsystem/my_module_test.lua")
suite:testMethod("new", "Creates instance", function()
    local MyModule = require("engine.subsystem.my_module")
    suite:assert(MyModule.new() ~= nil, "Should create instance")
end)
```

**Rules:** One test file per module | Happy path + 2+ error cases + edge cases | <10ms per test | No dependencies between tests
**Docs:** [tests2/README.md](../tests2/README.md) | [QUICK_REFERENCE.md](../tests2/QUICK_REFERENCE.md)

---

## Workflow: Design → API → Architecture → Engine → Mods → Tests

**Principle:** Single source of truth flows from design through API to implementation

**1. Design Phase** ([design/](../design/README.md))
- Create `design/mechanics/[system].md` using [DESIGN_TEMPLATE.md](../design/DESIGN_TEMPLATE.md)
- Define mechanics, rules, balance | Reference [GLOSSARY.md](../design/GLOSSARY.md)
- **Output:** Mechanic specification

**2. API Phase** ([api/](../api/README.md))
- Create/update `api/[SYSTEM].md` (ONLY if needs TOML config or cross-system interface)
- Update `api/GAME_API.toml` (SOURCE OF TRUTH) | Use [GAME_API_GUIDE.md](../api/GAME_API_GUIDE.md)
- **Output:** API contract + TOML schema

**3. Architecture Phase** ([architecture/](../architecture/README.md))
- Update `architecture/[layer]/[system].md` (ONLY if impacts system design)
- Create Mermaid diagrams | Use [ARCHITECTURE_GUIDE.md](../architecture/ARCHITECTURE_GUIDE.md)
- **Output:** System architecture + integration diagrams

**4. Engine Phase** (engine/)
- Implement `engine/[layer]/[system].lua` following API contract
- Organize by: core/, geoscape/, battlescape/, basescape/, economy/, ai/, gui/
- **Output:** Working Lua implementation

**5. Mods Phase** ([mods/](../mods/README.md))
- Create TOML in `mods/core/rules/[system]/` following `api/GAME_API.toml` schema
- Add assets to `mods/core/assets/` | Use `minimal_mod/` as template
- Use [Content Prompts](../docs/prompts/) for structured creation
- **Output:** Game content (TOML + assets)

**6. Tests Phase** ([tests2/](../tests2/README.md))
- Write `tests2/[subsystem]/[module]_test.lua` using Hierarchical Suite
- Target 75%+ coverage | <10ms per test
- **Output:** Automated tests

**Update Rules:**
- **design/**: Always | **api/**: TOML/cross-system only | **architecture/**: System impacts only
- **engine/**: Always | **mods/**: Always | **tests2/**: Always
- **Sync:** Use [SYNCHRONIZATION_GUIDE.md](../api/SYNCHRONIZATION_GUIDE.md)

---

## Testing & QA

**Commands:**
```bash
lovec "tests2/runners" run_all                              # All 2493+ tests (<1s)
lovec "tests2/runners" run_subsystem core                   # Subsystem tests
lovec "tests2/runners" run_single_test core/state_manager_test  # Single test
lovec "tests2/generators" scaffold_module_tests engine/subsystem/my_module.lua  # Generate tests
lovec "tests2/generators" analyze_engine_structure          # Find untested modules
```

**Rules:** One test per module | Happy + error + edge cases | <10ms per test | Isolated (no shared state)
**Reports:** Auto-generated in `tests2/reports/` (coverage_matrix.json, hierarchy_report.txt)

---

## Daily Workflow

**Tasks:**
1. Check [design docs](../design/README.md) for requirements
2. Review [API contracts](../api/README.md)
3. Run with console: `lovec "engine"`
4. Write tests alongside code
5. Update docs when changing systems

**Commands:**
```bash
git checkout develop && git pull origin develop
git checkout -b feature/my-work
# ... make changes ...
run\run_tests2_subsystem.bat [subsystem]  # Test changes
git add . && git commit -m "type(scope): description"
git push origin feature/my-work
# Create PR on GitHub
```

**Review Checklist:**
- Tests pass + cover new code
- Docs updated (api/, architecture/, design/)
- No performance/security regressions

**Release:** Update `engine/conf.lua` version → Run tests → Update CHANGELOG.md → Tag → Build → Publish
**Git Guide:** [🔄 Git Workflow](../docs/instructions/🔄%20Git%20Workflow%20&%20Collaboration.instructions.md) | [⚡ Release](../docs/instructions/⚡%20Release%20&%20Deployment.instructions.md)

---

## Game Systems

**Core:** Turn-based | Event-driven | Data-driven TOML
**UI:** 12x12 pixel art upscaled to 24x24

**Layers:**
- **Geoscape:** World map, provinces/regions/countries, missions, UFO tracking
- **Basescape:** 2D grid, facilities, crafts, units, research, manufacturing
- **Battlescape:** Squad-level tactical combat, procedural 2D maps
- **Strategic:** Diplomacy, politics, factions, research trees, progression

**Guides:** [🎮 Mechanics](../docs/instructions/🎮%20Game%20Mechanics.instructions.md) | [⚔️ Combat](../docs/instructions/⚔️%20Battlescape%20&%20AI.instructions.md) | [🏗️ Architecture](../docs/instructions/🏗️%20System%20Architecture.instructions.md)

---

## File Organization

**NEVER Create:** `*_SUMMARY.md`, `*_STATUS.md`, `*_COMPLETE.md`, `*_REPORT.md` - Output status in chat only

**File Locations:**
```
Game mechanics/balance → design/mechanics/
Data structure/TOML schema → api/[SYSTEM].md + api/GAME_API.toml
System architecture/integration → architecture/[layer]/[system].md
Code implementation → engine/[layer]/[module].lua
Game content (units/items/etc) → mods/core/rules/[type]/
Tests → tests2/[subsystem]/[module]_test.lua
Analysis/temporary work → temp/[descriptive_name].md
Runtime logs → logs/[category]/
```

**Workflow:** Design → API → Architecture → Engine → Mods → Tests

---

## AI Assistant Guidelines

**Principles:** Self-directed | Context-aware | Validation-driven | Documentation-first | Incremental

**Workflow:**
1. Read request → Understand needs
2. Gather context → Check design/, api/, architecture/, engine/, mods/, tests2/
3. Read logs → If errors/optimization: logs/tests/, logs/game/, logs/analytics/
4. Plan → Determine files (Design → API → Architecture → Engine → Mods → Tests)
5. Implement → Make changes systematically
6. Validate → Run tests, check errors, verify integration
7. Document → Update affected docs
8. Report → Brief summary with key changes

**Before Changes:**
- Check if documented in design/mechanics/
- Verify GAME_API.toml schema exists
- Review architecture/[layer]/[system].md for integration
- Check if tests exist in tests2/

**File Decisions:**
```
User request about...
├─ Game mechanics/balance → design/mechanics/[system].md
├─ Data structure/TOML → api/[SYSTEM].md + api/GAME_API.toml
├─ System architecture → architecture/[layer]/[system].md
├─ Code → engine/[layer]/[module].lua
├─ Content → mods/core/rules/[type]/
├─ Tests → tests2/[subsystem]/[module]_test.lua
├─ Analysis/temp → temp/[name].md
└─ Logs → logs/[category]/
```

**Error Handling:**
- Read logs FIRST: logs/tests/, logs/game/, logs/mods/
- Run `lovec "engine"` after changes
- Use `get_errors` tool
- Fix root cause, re-run test, verify
- Never report broken code

**After Changes:**
1. `lovec "engine"` - verify no errors
2. `lovec "tests2/runners" run_subsystem [name]` - tests pass
3. Verify doc cross-references
4. Check TOML matches api/GAME_API.toml
5. No broken imports/dependencies

---

## CRITICAL: Logs System - AI Agent's Primary Data Source

**Location:** `logs/` (5 categories: game/, tests/, mods/, system/, analytics/)

**Purpose:** ALL runtime output - PRIMARY DATA SOURCE for debugging, optimization, auto-balancing

**When to Read Logs:**
1. **Errors:** Read logs/tests/ → Find stack trace → Fix → Verify
2. **Performance:** Read logs/system/performance_*.json → Identify bottlenecks → Optimize → Verify
3. **Balance:** Read logs/analytics/balance_data_*.json → Identify issues → Update TOML → Verify
4. **Coverage:** Read logs/tests/coverage_*.json → Find gaps → Write tests → Verify
5. **Mods:** Read logs/mods/mod_errors_*.log → Find schema errors → Fix TOML → Verify

**Log Format:**
- Text: `[YYYY-MM-DD HH:MM:SS] [LEVEL] [COMPONENT] Message`
- JSON: Analytics with metrics (weapon_usage, unit_survival, etc.)

**Usage in Code:**
```lua
local Logger = require("engine.core.logger")
Logger:init(Logger.CATEGORIES.GAME)
Logger:info("MISSION", "Mission started")
Logger:error("COMBAT", "Invalid target")
Logger:close()
```

**Workflow:** Error → Read logs → Identify cause → Fix → Verify in logs → Report

**Rules:**
1. Always read logs BEFORE proposing fixes
2. Use logs to verify fixes
3. Data-driven decisions (not guesses)
4. Profile first, optimize second

**Docs:** [logs/README.md](../logs/README.md) | [System Pattern](../docs/system/09_LOGGING_AND_ANALYTICS_SYSTEM.md)

---

## Resources

- **Love2D:** https://love2d.org/wiki/Main_Page
- **Lua:** https://www.lua.org/manual/5.1/
- **X-COM Reference:** https://www.ufopaedia.org/

---

## Quick Reference

**Run Game:** `lovec "engine"` or `run_xcom.bat`  
**Run Tests:** `lovec "tests2/runners" run_all` or `run\run_tests2_all.bat`  
**Temp Dir:** `"temp/"` (always)  
**Debug:** `print("[Module] " .. tostring(value))`  
**Error:** `local ok, err = pcall(func); if not ok then print("[ERROR] " .. err) end`

