# Task: Audit and Fix DOCS-ENGINE Cross-References

**Status:** TODO  
**Priority:** HIGH  
**Created:** October 16, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent / Development Team

---

## Overview

Audit all implementation links in design documentation (`docs/`), verify they point to correct files, update broken/outdated links, and add bidirectional references from engine code back to design docs. Establish automated validation to prevent future drift.

---

## Purpose

**Current Problem:**
- Design docs use `> **Implementation**: path` but links often vague or outdated
- Engine code rarely links back to design docs
- No systematic validation of references
- Design and implementation drift apart over time

**Solution:**
Complete audit of all cross-references, fix broken links, standardize format, create bidirectional linkage, implement automated validation.

---

## Requirements

### Functional Requirements
- [ ] Audit all implementation links in docs/
- [ ] Verify each link points to existing file/directory
- [ ] Update broken or vague links
- [ ] Add bidirectional links (engine → docs)
- [ ] Standardize reference format
- [ ] Create automated validation script

### Technical Requirements
- [ ] Links use relative paths from docs/ folder
- [ ] Engine docstrings reference design docs
- [ ] Format: `> **Implementation**: path` in docs
- [ ] Format: `---@see docs/path/file.md` in engine Lua files
- [ ] Validation script checks all links

### Acceptance Criteria
- [ ] All implementation links valid and accurate
- [ ] 95%+ of engine modules link to design docs
- [ ] Standard format used consistently
- [ ] Validation script passes with 0 errors
- [ ] Documentation updated
- [ ] Process documented for future use

---

## Plan

### Step 1: Create Audit Script (3 hours)
**Description:** Script to extract and validate all implementation links  
**Files to create:**
- `tools/validate_docs_links.lua` or `tools/validate_docs_links.ps1`

**Script functionality:**
```powershell
# Extract all implementation links
$links = Select-String -Path "docs/**/*.md" -Pattern "> \*\*Implementation\*\*: \`(.+?)\`"

# Check each link
foreach ($link in $links) {
    $path = $link.Matches.Groups[1].Value
    $fullPath = Join-Path $projectRoot $path
    
    if (-not (Test-Path $fullPath)) {
        Write-Warning "Broken link in $($link.Filename): $path"
    }
}
```

**Estimated time:** 3 hours

### Step 2: Run Audit and Generate Report (2 hours)
**Description:** Execute audit script, generate report of issues  
**Output:**
- `docs_links_audit_report.txt` - List of all broken/vague links

**Tasks:**
- Run validation script
- Categorize issues (broken, vague, missing)
- Prioritize fixes

**Estimated time:** 2 hours

### Step 3: Fix Broken Links in Core Systems (3 hours)
**Description:** Update broken links in core documentation  
**Files to update:**
- `docs/core/concepts.md`
- `docs/core/implementation.md`
- `docs/core/physics.md`
- (Other core docs as needed)

**Before:**
```markdown
> **Implementation**: `../../engine/core/`, `../../engine/main.lua`
```

**After:**
```markdown
> **Implementation**: `engine/core/state_manager.lua`, `engine/core/game_loop.lua`, `engine/main.lua`
> **Tests**: `tests/core/test_state_manager.lua`
> **Related**: `docs/core/implementation.md`
```

**Estimated time:** 3 hours

### Step 4: Fix Links in Game Layer Docs (4 hours)
**Description:** Update links in geoscape, basescape, battlescape, interception  
**Files to update:**
- `docs/geoscape/*.md` (10+ files)
- `docs/basescape/*.md` (10+ files)
- `docs/battlescape/*.md` (15+ files)
- `docs/interception/*.md`

**Estimated time:** 4 hours

### Step 5: Fix Links in Supporting Systems (3 hours)
**Description:** Update links in economy, politics, AI, etc.  
**Files to update:**
- `docs/economy/*.md`
- `docs/politics/*.md`
- `docs/ai/*.md`
- `docs/mods/*.md`

**Estimated time:** 3 hours

### Step 6: Add Bidirectional Links to Engine (5 hours)
**Description:** Add design doc references to engine Lua files  
**Implementation:**
```lua
---@module battlescape.combat.battle_tile
---@see docs/battlescape/maps.md For map tile design
---@see docs/battlescape/combat-mechanics/README.md For combat mechanics

local BattleTile = {}
```

**Files to update:**
- `engine/**/*.lua` (50+ critical files)

**Priority files:**
1. Core systems (`engine/core/`)
2. Battlescape (`engine/battlescape/`)
3. Geoscape (`engine/geoscape/`)
4. Economy (`engine/economy/`)
5. Others as time allows

**Estimated time:** 5 hours

### Step 7: Standardize Reference Format (2 hours)
**Description:** Ensure all references use consistent format  
**Standard format:**
```markdown
> **Implementation**: `engine/path/to/file.lua`, `engine/path/to/other.lua`
> **Tests**: `tests/path/to/test.lua`
> **Related**: `docs/path/to/related.md`
```

**Tasks:**
- Document standard in `docs/README.md`
- Update all docs to follow standard
- Add examples

**Estimated time:** 2 hours

### Step 8: Create Automated Validation (4 hours)
**Description:** Create CI-compatible validation script  
**Files to create:**
- `tools/validate_docs_alignment.lua`
- `tools/README.md` - Document validation tool

**Script checks:**
- All implementation links point to existing files
- All engine modules have @see references
- Links use correct format
- No circular references

**Integration:**
- Can be run manually
- Can be added to CI/CD pipeline
- Outputs clear error messages

**Estimated time:** 4 hours

### Step 9: Document Process (2 hours)
**Description:** Create guide for maintaining alignment  
**Files to create:**
- `docs/internal/DOCS_ENGINE_ALIGNMENT_GUIDE.md`

**Content:**
- How to add new design docs
- How to link implementation
- How to run validation
- Best practices

**Files to update:**
- `docs/README.md` - Reference alignment guide
- `wiki/DEVELOPMENT.md` - Add alignment section

**Estimated time:** 2 hours

### Step 10: Final Validation and Testing (2 hours)
**Description:** Run complete validation, fix any remaining issues  
**Tasks:**
- Run validation script
- Fix any errors
- Verify all links work
- Test bidirectional navigation

**Estimated time:** 2 hours

---

## Implementation Details

### Reference Format Standard
```markdown
## Design Document Header

> **Implementation**: `engine/exact/path/file.lua`, `engine/other/file.lua`
> **Tests**: `tests/exact/path/test_file.lua`
> **Related**: `docs/related/doc.md`, `docs/other/doc.md`
```

### Engine Code Reference Standard
```lua
---Module description
---
---Design documentation: See docs/path/to/design.md
---Related systems: See docs/path/to/related.md
---
---@module module.name
---@see docs/path/to/design.md For design concepts
---@see engine/other/module.lua For related implementation
```

### Validation Script Output
```
Validating DOCS-ENGINE alignment...

[✅] docs/core/concepts.md → engine/core/state_manager.lua
[✅] docs/battlescape/maps.md → engine/battlescape/maps/
[❌] docs/economy/research.md → engine/economy/research.lua NOT FOUND
[⚠️] docs/politics/diplomacy/ → No implementation reference

Summary:
- 45 valid links
- 8 broken links
- 12 missing implementation references
- 23 engine files without design doc references

Alignment score: 68%
```

### Key Components
- **Audit Script:** Extracts and validates all links
- **Fix Process:** Systematic update of all docs
- **Bidirectional Links:** Engine ↔ Docs
- **Validation Tool:** Automated checking
- **Process Guide:** Maintaining alignment

---

## Testing Strategy

### Validation Tests
```powershell
# Run validation script
.\tools\validate_docs_alignment.lua

# Should output:
# [✅] All implementation links valid
# [✅] 95%+ engine modules have design references
# [✅] Consistent format used
# Alignment score: 95%+
```

### Manual Spot Checks
1. Pick random design doc
2. Follow implementation link
3. Verify file exists and is correct
4. Check engine file has @see reference back
5. Repeat 20 times

### Integration Test
```lua
-- Test automated validation
local validator = require("tools.validate_docs_alignment")
local results = validator.validate()

assert(results.brokenLinks == 0, "Should have no broken links")
assert(results.alignmentScore >= 95, "Alignment score should be 95%+")
```

---

## How to Run/Debug

1. **Run audit script:**
   ```powershell
   cd c:\Users\tombl\Documents\Projects
   .\tools\validate_docs_alignment.ps1
   ```

2. **Review report:**
   - Check `docs_links_audit_report.txt`
   - Prioritize broken links first
   - Then fix vague/missing links

3. **Fix links systematically:**
   - Start with core systems
   - Move to game layers
   - Finish with supporting systems

4. **Validate fixes:**
   ```powershell
   .\tools\validate_docs_alignment.ps1
   # Should show improvement
   ```

5. **Add bidirectional links:**
   - Open engine file
   - Add @see reference to design doc
   - Verify link works

---

## Documentation Updates

### Files to Create
- `tools/validate_docs_alignment.lua` or `.ps1`
- `tools/README.md`
- `docs/internal/DOCS_ENGINE_ALIGNMENT_GUIDE.md`
- `docs_links_audit_report.txt` (generated)

### Files to Update
- `docs/README.md` - Add alignment standards
- `docs/**/*.md` - Fix all broken links
- `engine/**/*.lua` - Add @see references
- `wiki/DEVELOPMENT.md` - Add alignment section
- `tasks/tasks.md` - Mark complete

---

## Review Checklist

- [ ] Audit script created and tested
- [ ] Audit report generated
- [ ] All broken links fixed
- [ ] Vague links made specific
- [ ] Missing links added
- [ ] Bidirectional links added to engine
- [ ] Format standardized across all docs
- [ ] Validation script runs successfully
- [ ] Alignment score 95%+
- [ ] Process documented
- [ ] Examples provided
- [ ] No console errors

---

## Notes

**Current Alignment Issues Found:**
- ~40% of implementation links are vague (e.g., `engine/core/`)
- ~20% of implementation links are broken
- ~5% of engine files reference design docs
- No automated validation

**Target After Completion:**
- 0% broken links
- 0% vague links
- 95%+ engine files reference design docs
- Automated validation in place

**Maintenance:**
- Run validation script monthly
- Add to CI/CD pipeline if possible
- Update DOCS_ENGINE_ALIGNMENT_GUIDE.md as needed

---

## What Worked Well
(To be filled in after completion)

---

## Lessons Learned
(To be filled in after completion)

---

## Follow-up Tasks
- Add validation to CI/CD pipeline
- Create similar validation for DOCS-MODS alignment
- Periodic audits (quarterly)
