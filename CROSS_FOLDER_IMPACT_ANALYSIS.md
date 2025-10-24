# 📋 COMPREHENSIVE CROSS-FOLDER IMPACT ANALYSIS

**Analysis Date:** October 25, 2025  
**Purpose:** Evaluate impact of engine restructuring on ALL project folders  
**Status:** CRITICAL REVIEW BEFORE ANY ENGINE CHANGES

---

## Executive Summary

**CRITICAL FINDING:** Engine restructuring will impact **6 major folders** beyond engine/:
- ✅ **api/** - Moderate impact (file references)
- ✅ **architecture/** - Moderate impact (system organization)
- ✅ **design/** - Low impact (conceptual, not file paths)
- ⚠️ **tests/** - HIGH impact (import paths, mock structure)
- ⚠️ **tools/** - HIGH impact (scanners, validators reference engine)
- ✅ **docs/** - Moderate impact (documentation updates)

**Total Affected Files:** 150+ files across all folders  
**Estimated Update Effort:** +8-12 hours (on top of engine restructuring)

---

## Folder-by-Folder Analysis

---

## 1. 📚 API FOLDER (`api/`)

### Current State
- **Files:** 25+ markdown documentation files
- **Purpose:** System contracts and interface documentation
- **Dependencies on Engine:** FILE PATH REFERENCES ONLY
- **Structure:**
  ```
  api/
  ├── README.md (overview)
  ├── GAME_API.toml (schema definition)
  ├── GAME_API_GUIDE.md
  ├── SYNCHRONIZATION_GUIDE.md
  ├── AI_SYSTEMS.md
  ├── BATTLESCAPE.md
  ├── GEOSCAPE.md
  ├── ... (20+ other system docs)
  ```

### Impact Assessment

**MODERATE IMPACT** - File path references need updates

#### What Will Change
1. **File References in Documentation**
   - Current: References like "See `engine/ai/tactical.lua`"
   - After: References like "See `engine/layers/battlescape/ai/tactical.lua`"
   - Affected: Most API documentation files

2. **System Architecture Descriptions**
   - Current: "AI system lives in `engine/ai/`"
   - After: "AI system lives in `engine/systems/ai/` (cross-layer)"
   - Affected: AI_SYSTEMS.md, INTEGRATION.md, SYNCHRONIZATION_GUIDE.md

3. **Configuration Path Examples**
   - Current: May reference old paths in examples
   - After: Update example code snippets
   - Affected: API guide files

#### What Won't Change
- ✅ **TOML Configuration Format** - Stays same, no engine path encoding
- ✅ **System Contracts** - Lua interfaces don't change with folder moves
- ✅ **Data Structures** - Entity definitions remain unchanged
- ✅ **Integration Patterns** - System-to-system communication unchanged
- ✅ **Design Principles** - Architectural patterns stable
- ✅ **Design Rationale** - Why decisions exist, not where they live

### Required Updates

**Files to Update (15-20 files):**
```
✏️ AI_SYSTEMS.md - AI system folder moved to systems/ai
✏️ ANALYTICS.md - Analytics folder moved to systems/analytics
✏️ ECONOMY.md - Economy folder moved to systems/economy
✏️ INTEGRATION.md - System paths updated
✏️ SYNCHRONIZATION_GUIDE.md - References current structure
✏️ GEOSCAPE.md - If references engine paths
✏️ BATTLESCAPE.md - If references engine paths
✏️ GUI.md - If references engine/gui paths
✏️ RENDERING.md - If references engine paths
... (others as needed)

✅ GAME_API.toml - NO CHANGES (engine paths not encoded)
✅ All other system files - Mostly no changes
```

### Update Strategy

**Phase:** After engine migration complete
**Effort:** 1-2 hours
**Process:**
1. Search all .md files for "engine/" paths
2. Update old paths to new structure
3. Review examples and code snippets
4. Verify SYNCHRONIZATION_GUIDE updated

---

## 2. 🏗️ ARCHITECTURE FOLDER (`architecture/`)

### Current State
- **Files:** 6 key files + diagrams
- **Purpose:** High-level system design and integration patterns
- **Dependencies on Engine:** Conceptual references + some code examples
- **Structure:**
  ```
  architecture/
  ├── README.md
  ├── 01-game-structure.md
  ├── 02-procedural-generation.md
  ├── 03-combat-tactics.md
  ├── 04-base-economy.md
  ├── INTEGRATION_FLOW_DIAGRAMS.md
  └── ROADMAP.md
  ```

### Impact Assessment

**MODERATE IMPACT** - Architecture stays same, folder references change

#### What Will Change
1. **System Organization Description**
   - Current: "Systems organized by type (ai, economy, geoscape, etc.)"
   - After: "Systems organized hierarchically (core, systems, layers)"
   - Affected: 01-game-structure.md

2. **Layer Documentation**
   - Current: "Game layers in root engine/ folder"
   - After: "Game layers in engine/layers/ subfolder"
   - Affected: 01-game-structure.md, INTEGRATION_FLOW_DIAGRAMS.md

3. **Integration Flow Examples**
   - Current: May show old paths in diagrams/examples
   - After: Update to new structure
   - Affected: INTEGRATION_FLOW_DIAGRAMS.md

4. **Code Examples**
   - Current: `require("ai.tactical")` or `require("engine/ai/tactical")`
   - After: `require("systems.ai.tactical")` 
   - Affected: All docs with code examples

#### What Won't Change
- ✅ **Architectural Patterns** - Layered, ECS, event-driven patterns stable
- ✅ **System Interactions** - How systems communicate unchanged
- ✅ **Data Flow** - Information flow between layers unchanged
- ✅ **State Management** - State machine logic unchanged
- ✅ **Design Principles** - Architectural philosophy unchanged
- ✅ **Roadmap Goals** - What we're building stays same

### Required Updates

**Files to Update (4-6 files):**
```
✏️ 01-game-structure.md - Describe new folder hierarchy
✏️ INTEGRATION_FLOW_DIAGRAMS.md - Update code examples in diagrams
✏️ README.md - Link to new engine structure
✏️ 02-procedural-generation.md - If has code examples
✏️ 03-combat-tactics.md - If has code examples
✏️ 04-base-economy.md - If has code examples

✅ ROADMAP.md - Usually no changes (is strategic, not structural)
```

### Update Strategy

**Phase:** After engine migration complete
**Effort:** 1-2 hours
**Process:**
1. Review each file for engine path references
2. Update to new hierarchical structure
3. Update code examples with new require paths
4. Update integration flow diagrams
5. Verify diagrams still make sense

---

## 3. 🎨 DESIGN FOLDER (`design/`)

### Current State
- **Files:** 40+ design specification files
- **Purpose:** Game mechanics, balance, design decisions
- **Dependencies on Engine:** Minimal (conceptual reference only)
- **Structure:**
  ```
  design/
  ├── README.md
  ├── GLOSSARY.md
  ├── DESIGN_TEMPLATE.md
  ├── gaps/
  │   ├── GAPS_SUMMARY.md
  │   └── (10+ gap files)
  └── mechanics/
      ├── (30+ system design files)
  ```

### Impact Assessment

**LOW IMPACT** - Design is conceptual, not structural

#### What Will NOT Change (90% of content)
- ✅ **Game Mechanics** - How units work, combat rules, etc.
- ✅ **Balance Parameters** - Damage values, costs, etc.
- ✅ **System Design** - What features exist and interact
- ✅ **Design Rationale** - Why decisions were made
- ✅ **Gap Analysis** - What's missing vs. done
- ✅ **Glossary** - Game terminology
- ✅ **Design Templates** - Format for new designs

#### What Might Change (10% of content)
1. **Implementation References** (if any)
   - Current: "See `engine/ai/tactical.lua` for implementation"
   - After: "See `engine/systems/ai/tactical.lua` for implementation"
   - Frequency: Rare (most design is abstract)

2. **Structure Notes** (if detailed)
   - Current: "AI stored in `engine/ai/` folder"
   - After: "AI stored in `engine/systems/ai/` folder"
   - Frequency: Very rare

### Required Updates

**Files to Update (0-3 files):**
```
? Possibly search all .md files for "engine/" paths
? Likely to find very few if any in design docs (they're abstract)

✅ GLOSSARY.md - NO CHANGES
✅ DESIGN_TEMPLATE.md - NO CHANGES
✅ Most mechanics/ files - NO CHANGES
✅ Most gaps/ files - NO CHANGES
```

### Update Strategy

**Phase:** Last (low priority)
**Effort:** 0.5 hours (just search for references)
**Process:**
1. Search all design files for "engine/" paths
2. Update if any found (unlikely)
3. Verify engine implementation notes still valid

---

## 4. 🧪 TESTS FOLDER (`tests/`)

### Current State
- **Files:** 50+ test files + runners
- **Purpose:** Unit, integration, system, performance tests
- **Dependencies on Engine:** HIGH - Import paths, mock structure
- **Structure:**
  ```
  tests/
  ├── runners/
  ├── unit/
  ├── integration/
  ├── battle/
  ├── battlescape/
  ├── geoscape/
  ├── systems/
  ├── performance/
  ├── mock/
  └── framework/
  ```

### Impact Assessment

**HIGH IMPACT** - Tests import from engine, mock follows engine structure

#### What Will Change (Critical!)
1. **All Import Statements in Tests**
   - Current: `local AI = require("ai.tactical")`
   - After: `local AI = require("systems.ai.tactical")`
   - Affected: 50+ test files
   - Impact: Tests won't run if imports wrong

2. **Mock Data Structure**
   - Current: `tests/mock/engine/ai/` mirrors engine structure
   - After: `tests/mock/engine/systems/ai/` mirrors new structure
   - Affected: Mock data organization
   - Impact: Mock references need updating

3. **Test Runners**
   - Current: May hardcode engine paths
   - After: Update to new structure
   - Affected: `runners/` folder scripts
   - Impact: Test discovery might break

4. **Import Scanner References**
   - Current: Scans `engine/` structure
   - After: Scans new `engine/` structure
   - Affected: `tools/import_scanner/` (separate folder)
   - Impact: Scanner needs reconfiguration

#### What Won't Change
- ✅ **Test Logic** - What we're testing stays same
- ✅ **Test Framework** - How tests are written unchanged
- ✅ **Assertions** - Test expectations unchanged
- ✅ **Performance Benchmarks** - Metrics comparison unchanged

### Required Updates

**CRITICAL - Files to Update (40-50 test files):**
```
✏️ tests/unit/ - All test files (search/replace imports)
✏️ tests/integration/ - All test files (search/replace imports)
✏️ tests/battle/ - All test files (search/replace imports)
✏️ tests/battlescape/ - All test files (search/replace imports)
✏️ tests/geoscape/ - All test files (search/replace imports)
✏️ tests/systems/ - All test files (search/replace imports)
✏️ tests/performance/ - All test files (search/replace imports)
✏️ tests/framework/ - Framework utilities (search/replace imports)
✏️ tests/mock/ - Mock data structure needs reorganizing
✏️ tests/runners/ - Test runners (if they reference paths)
✏️ tests/TEST_API_FOR_AI.lua - Update import references
✏️ tests/TEST_DEVELOPMENT_GUIDE.md - Update examples
✏️ tests/QUICK_TEST_COMMANDS.md - Update example commands
```

### Update Strategy

**Phase:** PARALLEL with engine migration
**Effort:** 4-6 hours
**Process:**
1. Create mapping of old imports → new imports
2. Use find/replace across all test files
3. Reorganize mock/ folder structure
4. Update test runners if needed
5. Run full test suite to verify

**Automation Possible:**
```lua
-- Pseudo-code for automated update
local oldPaths = {
  "ai.tactical" = "systems.ai.tactical",
  "economy.calculator" = "systems.economy.calculator",
  -- etc.
}

for oldPath, newPath in pairs(oldPaths) do
  replaceInAllFiles(oldPath, newPath, "tests/")
end
```

---

## 5. 🛠️ TOOLS FOLDER (`tools/`)

### Current State
- **Files:** Multiple subdirectories with tools
- **Purpose:** Development utilities, validators, scanners
- **Dependencies on Engine:** Import scanner specifically
- **Key Subdirectories:**
  ```
  tools/
  ├── import_scanner/ - Scans engine imports
  ├── validators/ - Validates mods (references engine)
  ├── structure/ - Engine structure tools
  └── [other tools]
  ```

### Impact Assessment

**HIGH IMPACT** - Tools that scan/reference engine structure

#### What Will Change
1. **Import Scanner Configuration**
   - Current: Scans `engine/` and knows its structure
   - After: Scan configuration should be updated
   - Affected: `tools/import_scanner/scan_imports.ps1`, `.lua`, `.sh`
   - Impact: Path patterns need updating

2. **Structure Audit Tool**
   - Current: `tools/structure/audit_engine_structure.lua`
   - After: Still works but produces different output
   - Affected: Audit tool (our own creation)
   - Impact: Becomes outdated documentation

3. **Migration Tools**
   - Current: Don't exist yet
   - After: Must be created for Phase 4
   - New files: Migrator scripts, path updaters
   - Impact: Core to migration success

4. **Validator Tools**
   - Current: `tools/validators/validate_content.lua` etc.
   - After: Doesn't reference engine structure, so OK
   - Affected: None directly
   - Impact: None (only validates mod content, not engine)

#### What Won't Change
- ✅ **Mod Validator Logic** - Validation rules unchanged
- ✅ **TOML Parsing** - Schema format unchanged
- ✅ **Report Generation** - Report format unchanged

### Required Updates

**Files to Update (5-10 files):**
```
✏️ tools/import_scanner/scan_imports.ps1 - Update engine path patterns
✏️ tools/import_scanner/scan_imports.lua - Update engine path patterns
✏️ tools/import_scanner/scan_imports.sh - Update engine path patterns
✏️ tools/import_scanner/README.md - Update examples
✏️ tools/structure/audit_engine_structure.lua - Update/retire after use

✅ tools/validators/ - NO CHANGES (validates mods, not engine)
```

### Update Strategy

**Phase:** BEFORE executing migration
**Effort:** 1-2 hours
**Process:**
1. Review import_scanner for hardcoded paths
2. Update path patterns to match new structure
3. Test scanner on new structure
4. Audit tool can be retired after use or updated for reference

---

## 6. 📖 DOCS FOLDER (`docs/`)

### Current State
- **Files:** 10+ documentation files
- **Purpose:** Code standards, development guides
- **Dependencies on Engine:** Some code examples
- **Key Files:**
  ```
  docs/
  ├── CODE_STANDARDS.md
  ├── COMMENT_STANDARDS.md
  ├── ENGINE_ORGANIZATION_PRINCIPLES.md (NEW - this session)
  ├── IDE_SETUP.md (NEW - this session)
  └── [other documentation]
  ```

### Impact Assessment

**MODERATE IMPACT** - Documentation examples may need updating

#### What Will Change
1. **Code Examples**
   - Current: `require("ai.tactical")`
   - After: `require("systems.ai.tactical")`
   - Affected: CODE_STANDARDS.md, other examples
   - Impact: Examples become outdated

2. **Engine Structure References**
   - Current: References old structure
   - After: References new structure
   - Affected: ENGINE_ORGANIZATION_PRINCIPLES.md
   - Impact: Must be updated to be valid

3. **IDE Setup**
   - Current: May have examples with old paths
   - After: Update examples
   - Affected: IDE_SETUP.md
   - Impact: Examples misleading

#### What Won't Change
- ✅ **Code Standards** - How to write code unchanged
- ✅ **Comment Conventions** - How to comment unchanged
- ✅ **Best Practices** - General practices unchanged

### Required Updates

**Files to Update (3-5 files):**
```
✏️ ENGINE_ORGANIZATION_PRINCIPLES.md - Update to reflect actual changes
✏️ CODE_STANDARDS.md - Update import path examples
✏️ IDE_SETUP.md - Update example imports
✏️ Any other docs with code examples

✅ COMMENT_STANDARDS.md - NO CHANGES
✅ DOCUMENTATION_STANDARD.md - NO CHANGES
```

### Update Strategy

**Phase:** After engine migration complete
**Effort:** 1 hour
**Process:**
1. Search all .md files for code examples with imports
2. Update old paths to new structure
3. Verify examples are correct and buildable

---

## 7. ⚙️ COPILOT INSTRUCTIONS (`copilot-instructions.md`)

### Current State
- **Files:** 1 file + 25+ instruction files in .github/
- **Purpose:** AI instructions for development
- **Dependencies on Engine:** Path documentation
- **File:** `.github/copilot-instructions.md`

### Impact Assessment

**MODERATE IMPACT** - Documentation needs updating

#### What Will Change
1. **Project Structure Section**
   - Current: Shows current structure
   - After: Shows new structure
   - Affected: Structure diagram in instructions
   - Impact: Instructions become inaccurate

2. **Engine Path References**
   - Current: References old structure
   - After: References new structure
   - Affected: All path examples
   - Impact: AI gives wrong path suggestions

### Required Updates

**Files to Update (1 file):**
```
✏️ .github/copilot-instructions.md - Update project structure section
✏️ Potentially: .github/instructions/*.md - If they reference engine
```

### Update Strategy

**Phase:** After engine migration complete
**Effort:** 0.5 hours
**Process:**
1. Update project structure diagram
2. Update path examples
3. Test that instructions are accurate

---

## 📊 Impact Summary Matrix

| Folder | Impact | Effort | Critical | Phase |
|--------|--------|--------|----------|-------|
| **api/** | Moderate | 1-2h | No | After |
| **architecture/** | Moderate | 1-2h | No | After |
| **design/** | Low | 0.5h | No | Last |
| **tests/** | HIGH | 4-6h | YES | Parallel |
| **tools/** | HIGH | 1-2h | YES | Before |
| **docs/** | Moderate | 1h | No | After |
| **.github/** | Moderate | 0.5h | No | After |
| **engine/** | Very High | 8-12h | YES | Core |
| **TOTAL** | - | **18-27h** | - | - |

---

## 🔴 CRITICAL DEPENDENCIES

### Must Do BEFORE Engine Migration
1. ✏️ Update `tools/import_scanner/` path patterns
2. ✏️ Create import path mappings for tests
3. ✏️ Prepare migration automation tools

### Must Do PARALLEL with Engine Migration
1. ✏️ Update 40-50 test files with new imports
2. ✏️ Reorganize mock/ data structure
3. ✏️ Run tests continuously to catch issues

### Must Do AFTER Engine Migration
1. ✏️ Update api/ file path references (15-20 files)
2. ✏️ Update architecture/ documentation (4-6 files)
3. ✏️ Update design/ if any references found (0-3 files)
4. ✏️ Update docs/ examples (3-5 files)
5. ✏️ Update copilot-instructions.md (1 file)

---

## ✅ What Stays Exactly the Same

These DO NOT need changes after engine restructuring:

- ✅ **Game Logic** - Code behavior unchanged
- ✅ **TOML Configuration Format** - Schema stays same
- ✅ **System Contracts** - Interfaces unchanged
- ✅ **Design Principles** - Why things exist
- ✅ **Test Logic** - What we're testing
- ✅ **Architectural Patterns** - How systems interact
- ✅ **Game Mechanics** - How game works
- ✅ **Documentation Standards** - How to write docs

---

## 🚀 Recommended Approach

### Phase 0: Preparation (Before Migration)
1. Create comprehensive import mapping spreadsheet
2. Update import_scanner configuration
3. Prepare find/replace patterns for tests
4. Create rollback scripts

### Phase 1: Engine Migration (Core Work)
1. Restructure engine/ folders
2. Update engine/ imports
3. Test game runs
4. Commit changes

### Phase 2: Test Updates (Parallel)
1. Update all test imports (bulk find/replace)
2. Reorganize mock/ structure
3. Run full test suite
4. Fix any failures

### Phase 3: Documentation (Sequential)
1. Update api/ path references
2. Update architecture/ examples
3. Update docs/ examples
4. Check design/ (likely minimal)

### Phase 4: Final Verification
1. Run all tests again
2. Run import scanner
3. Check all cross-references
4. Update copilot-instructions

---

## 📋 Cross-Folder Checklist

Before considering engine migration COMPLETE, verify:

### API Folder
- [ ] All file path references updated
- [ ] Code examples use new import paths
- [ ] SYNCHRONIZATION_GUIDE reflects new structure
- [ ] No broken links to engine documentation

### Architecture Folder
- [ ] System organization description updated
- [ ] Integration flow diagrams show new structure
- [ ] Code examples use new import paths
- [ ] Roadmap still makes sense

### Design Folder
- [ ] Searched for engine path references (probably none)
- [ ] Implementation notes still valid
- [ ] Gap analysis still accurate

### Tests Folder ⚠️ CRITICAL
- [ ] All 40-50 test files updated with new imports
- [ ] Mock data structure mirrors new engine structure
- [ ] Mock file references point to correct locations
- [ ] All tests run successfully
- [ ] No import errors in console

### Tools Folder ⚠️ CRITICAL
- [ ] Import scanner updated with new path patterns
- [ ] Scanner tested on new structure
- [ ] Validator tools still work (shouldn't need changes)

### Docs Folder
- [ ] Code examples use new import paths
- [ ] ENGINE_ORGANIZATION_PRINCIPLES reflects reality
- [ ] IDE_SETUP examples are correct
- [ ] Copilot instructions updated

---

## 🎯 Key Insight

**The engine folder restructuring is NOT just an engine change - it's a whole-project change.**

Every documentation system, testing system, and development tool must be updated to reflect the new structure. The 8-12 hours of engine work grows to 18-27 hours when considering all downstream impacts.

**Success requires:**
1. Comprehensive planning (this document)
2. Automated tools where possible
3. Parallel work on tests and engine
4. Systematic verification across all folders

---

**Status:** Ready for team review before proceeding with restructuring

**Next Step:** Review this analysis, confirm approach, then proceed with Phase 0 preparation
