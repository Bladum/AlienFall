# 🎯 RECOMMENDED CHANGES BY FOLDER

**Purpose:** Clear recommendations on what to change/keep when restructuring engine  
**Status:** Ready for execution

---

## QUICK SUMMARY TABLE

| Folder | Status | Action | Scope | Files | Effort | Priority |
|--------|--------|--------|-------|-------|--------|----------|
| **engine/** | RESTRUCTURE | Full reorganization | 8-12h core work | 100+ | High | CRITICAL |
| **tests/** | UPDATE IMPORTS | Search/replace imports | 40-50 test files | 50 | 4-6h | CRITICAL |
| **tools/import_scanner/** | RECONFIGURE | Update path patterns | Pattern files | 3 | 1-2h | CRITICAL |
| **api/** | UPDATE PATHS | File references only | 15-20 docs | 20 | 1-2h | Important |
| **architecture/** | UPDATE EXAMPLES | Code examples + paths | 4-6 docs | 6 | 1-2h | Important |
| **docs/** | UPDATE EXAMPLES | Code examples + paths | 3-5 docs | 5 | 1h | Important |
| **design/** | REVIEW ONLY | Check for refs | 40+ docs | 0-3 | 0.5h | Low |
| **.github/** | UPDATE PATHS | Update instructions | 1 file | 1 | 0.5h | Low |

---

## 📚 API FOLDER - RECOMMENDATIONS

### ✅ What Should Definitely CHANGE

**Update file path references in documentation:**
- `ai.tactical` → `systems.ai.tactical`
- `engine/ai/` → `engine/systems/ai/`
- `engine/economy/` → `engine/systems/economy/`
- `engine/politics/` → `engine/systems/politics/`
- `engine/analytics/` → `engine/systems/analytics/`
- `engine/content/` → `engine/systems/content/`
- `engine/lore/` → `engine/systems/lore/`
- `engine/tutorial/` → `engine/systems/tutorial/`

**Update layer references:**
- `engine/geoscape/` → `engine/layers/geoscape/`
- `engine/basescape/` → `engine/layers/basescape/`
- `engine/battlescape/` → `engine/layers/battlescape/`
- `engine/interception/` → `engine/layers/interception/`

**Files to update (15-20):**
```
AI_SYSTEMS.md - System paths
ANALYTICS.md - System paths
ECONOMY.md - System paths
POLITICS.md - System paths
INTEGRATION.md - All system paths
SYNCHRONIZATION_GUIDE.md - Structure references
GEOSCAPE.md - If any references
BATTLESCAPE.md - If any references
GUI.md - UI system paths
... and others with path references
```

### ✅ What Should STAY the Same

**Do NOT change:**
- TOML configuration schema (GAME_API.toml stays identical)
- System interfaces and contracts
- Data structures and entities
- Configuration format
- Examples of game mechanics
- Design rationale

---

## 🏗️ ARCHITECTURE FOLDER - RECOMMENDATIONS

### ✅ What Should Definitely CHANGE

**Update system organization description:**
- Current: "Systems in root engine/ folder organized by type"
- Change to: "Systems organized hierarchically: core → systems → layers"

**Update diagram examples:**
- Show new folder relationships
- Update code examples in diagrams
- Keep data flow arrows same (logic unchanged)

**Update code examples:**
- Old: `require("ai.tactical")`
- New: `require("systems.ai.tactical")`

**Files to update (4-6):**
```
01-game-structure.md - NEW hierarchy description
INTEGRATION_FLOW_DIAGRAMS.md - Update example code
README.md - Link to new structure
02-procedural-generation.md - Code examples
03-combat-tactics.md - Code examples
04-base-economy.md - Code examples
```

### ✅ What Should STAY the Same

**Do NOT change:**
- Architectural patterns (ECS, event-driven, layered)
- System interaction logic (how systems talk)
- Data flow (what information moves where)
- State management (state machine logic)
- Design philosophy and principles

---

## 🎨 DESIGN FOLDER - RECOMMENDATIONS

### ✅ What Should CHANGE

**Probably nothing! Design is abstract.**

However, search for references to "engine/" paths just in case:
```bash
grep -r "engine/" design/
```

If you find any (unlikely):
- Update old paths to new structure
- Example: "See `engine/ai/tactical.lua`" → "See `engine/systems/ai/tactical.lua`"

**Expected findings:** 0-3 files max (design docs are conceptual)

### ✅ What Should STAY the Same

**Do NOT change (100% of content):**
- Game mechanics and rules
- Balance parameters
- Unit descriptions
- Combat system design
- Economic system design
- Design rationale
- Design templates
- Glossary

---

## 🧪 TESTS FOLDER - RECOMMENDATIONS

### ⚠️ CRITICAL - What MUST CHANGE

**ALL test import statements must be updated:**

**Find/Replace Mapping:**
```
Old Path → New Path
"ai" → "systems.ai"
"economy" → "systems.economy"
"politics" → "systems.politics"
"analytics" → "systems.analytics"
"content" → "systems.content"
"lore" → "systems.lore"
"tutorial" → "systems.tutorial"
"geoscape" → "layers.geoscape"
"basescape" → "layers.basescape"
"battlescape" → "layers.battlescape"
"interception" → "layers.interception"
"core" → "core" (stays same)
"utils" → "utils" (stays same)
"gui" → "ui" (if restructuring GUI)
```

**Files to update (ALL test files):**
```
tests/unit/*.lua - Update all requires
tests/integration/*.lua - Update all requires
tests/battle/*.lua - Update all requires
tests/battlescape/*.lua - Update all requires
tests/geoscape/*.lua - Update all requires
tests/systems/*.lua - Update all requires
tests/performance/*.lua - Update all requires
tests/framework/*.lua - Update all requires
tests/TEST_API_FOR_AI.lua - Update requires
```

**Mock data structure must be reorganized:**
```
Current: tests/mock/engine/ai/
New: tests/mock/engine/systems/ai/

Current: tests/mock/engine/geoscape/
New: tests/mock/engine/layers/geoscape/
```

**Test runner documentation needs updates:**
```
tests/TEST_DEVELOPMENT_GUIDE.md - Update examples
tests/QUICK_TEST_COMMANDS.md - Update example commands
```

### ✅ What Should STAY the Same

- Test logic (what assertions test)
- Test framework (how tests are written)
- Performance benchmarks (what metrics matter)
- Mock data values (test numbers stay same)

---

## 🛠️ TOOLS FOLDER - RECOMMENDATIONS

### ⚠️ CRITICAL - Import Scanner Must Update

**Update path patterns in scanner:**

**File:** `tools/import_scanner/scan_imports.ps1`
- Update engine path patterns
- Update recognition of valid paths
- Test on new structure

**File:** `tools/import_scanner/scan_imports.lua`
- Update engine path patterns
- Update file search patterns

**File:** `tools/import_scanner/scan_imports.sh`
- Update engine path patterns

**File:** `tools/import_scanner/README.md`
- Update example output
- Update expected patterns

### ✅ Validators Need NO CHANGES

**These don't need updates:**
- `tools/validators/validate_content.lua`
- `tools/validators/validate_mod.lua`
- `tools/validators/CONTENT_VALIDATOR_GUIDE.md`
- `tools/validators/VALIDATORS_OVERVIEW.md`

Reason: They validate MOD content, not engine structure

### ✅ Structure Tools

**Audit tool can be retired/archived after use:**
- `tools/structure/audit_engine_structure.lua` - Was temporary for analysis

---

## 📖 DOCS FOLDER - RECOMMENDATIONS

### ✅ What Should CHANGE

**Update code examples:**

**File:** `docs/CODE_STANDARDS.md`
- Old example: `require("ai.tactical")`
- New example: `require("systems.ai.tactical")`

**File:** `docs/ENGINE_ORGANIZATION_PRINCIPLES.md` (NEW!)
- This becomes accurate description of actual structure
- Verify examples match reality

**File:** `docs/IDE_SETUP.md`
- Update any hardcoded import path examples

**Files to update (3-5):**
```
CODE_STANDARDS.md - Update import examples
ENGINE_ORGANIZATION_PRINCIPLES.md - Verify accuracy
IDE_SETUP.md - Update import examples
README.md - If has examples
Any other docs with code examples
```

### ✅ What Should STAY the Same

**Do NOT change:**
- Code standards themselves
- Comment standards
- Best practices
- Documentation format standards

---

## 🤖 COPILOT INSTRUCTIONS - RECOMMENDATIONS

### ✅ What Should CHANGE

**File:** `.github/copilot-instructions.md`

**Update this section:**
```
OLD:
engine/
├── core/
├── utils/
├── ai/
├── geoscape/
├── battlescape/
...

NEW:
engine/
├── core/
├── utils/
├── ui/
├── systems/
│   ├── ai/
│   ├── economy/
│   └── ...
├── layers/
│   ├── geoscape/
│   ├── battlescape/
│   └── ...
```

**Update path examples:**
```
Old: See engine/ai/ folder
New: See engine/systems/ai/ folder
```

### ✅ What Should STAY the Same

- Build instructions
- Testing procedures
- Development workflow
- Debugging tips
- General guidance

---

## ❌ What Folders Need ZERO CHANGES

These folders are completely unaffected:

- ✅ **lore/** - Game story, no code references
- ✅ **mods/** - Mod organization unaffected
- ✅ **mods/core/rules/** - TOML configs unaffected (schema stays same)
- ✅ **tasks/** - Task documentation unaffected
- ✅ **content/** - If exists, probably OK
- ✅ All other non-engine-dependent folders

---

## 🎯 EXECUTION ORDER RECOMMENDATIONS

### Before Migration
1. ✅ Create import path mapping file
2. ✅ Prepare find/replace patterns
3. ✅ Update tools/import_scanner configuration
4. ✅ Create backup of tests/ folder
5. ✅ Get team review of this analysis

### During Migration
1. 🔴 Restructure engine/ folder
2. 🟡 Update tests/ imports (parallel)
3. 🟡 Reorganize tests/mock/ structure
4. ⚫ Run tests constantly to catch issues

### After Migration
1. ✅ Update api/ path references
2. ✅ Update architecture/ examples
3. ✅ Update docs/ examples
4. ✅ Check design/ for references
5. ✅ Update copilot-instructions.md
6. ✅ Run full test suite
7. ✅ Final verification

---

## 📋 CONCRETE CHANGE EXAMPLES

### Example 1: Test File Update

**Before:**
```lua
local AI = require("ai.tactical")
local Movement = require("battlescape.movement")
local Units = require("core.units")
```

**After:**
```lua
local AI = require("systems.ai.tactical")
local Movement = require("layers.battlescape.movement")
local Units = require("core.units")
```

### Example 2: API Documentation Update

**Before:**
```markdown
The AI system is located in `engine/ai/` and contains:
- `engine/ai/tactical.lua` - Tactical AI
- `engine/ai/strategic.lua` - Strategic AI
```

**After:**
```markdown
The AI system is located in `engine/systems/ai/` and contains:
- `engine/systems/ai/tactical.lua` - Tactical AI
- `engine/systems/ai/strategic.lua` - Strategic AI
```

### Example 3: Architecture Diagram Update

**Before (in code example in diagram):**
```lua
require("ai.tactical")
require("geoscape.manager")
```

**After (in code example in diagram):**
```lua
require("systems.ai.tactical")
require("layers.geoscape.manager")
```

---

## ⏱️ TIME ESTIMATES BREAKDOWN

| Task | Hours | Priority | Critical? |
|------|-------|----------|-----------|
| Engine restructuring core | 8-12 | P0 | YES |
| Test imports update | 4-6 | P0 | YES |
| Import scanner update | 1-2 | P0 | YES |
| API path references | 1-2 | P1 | No |
| Architecture examples | 1-2 | P1 | No |
| Docs examples | 1 | P1 | No |
| Design review | 0.5 | P2 | No |
| Copilot instructions | 0.5 | P2 | No |
| **TOTAL** | **18-27h** | - | - |

---

## ✅ FINAL APPROVAL CHECKLIST

Before starting migration, confirm:

- [ ] This impact analysis reviewed by team
- [ ] Approach approved by tech lead
- [ ] Test backup created
- [ ] Import mapping prepared
- [ ] Find/replace patterns tested
- [ ] Git branch created for work
- [ ] All team members notified
- [ ] Time blocked on calendar for focused work

---

## 🎓 Key Principles for Implementation

1. **Structural changes (engine/)** are mechanical (move files)
2. **Import changes (tests/)** are mechanical (find/replace)
3. **Documentation changes** are manual (review and verify)
4. **No logic changes** - only file locations and import paths

This means:
- Automation can handle ~60% of work
- Manual verification needed for ~40% of work
- No code behavior changes needed

---

**Ready to proceed with Phase 3 (Detailed Migration Plan)?**

See: `CROSS_FOLDER_IMPACT_ANALYSIS.md` for full details
