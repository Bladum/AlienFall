# Phase 2: Engine Alignment Implementation Plan

**Project**: AlienFall (XCOM Simple)  
**Phase**: Phase 2 (Implementation & Fixes)  
**Date Started**: October 21, 2025  
**Status**: IN_PROGRESS

---

## Overview

Based on Phase 1 comprehensive audit results (86.6% average alignment), Phase 2 focuses on fixing identified gaps and improving documentation to reach 95%+ alignment across all systems.

### Phase 1 Results Summary
- **Geoscape**: 86% alignment ✅
- **Basescape**: 72% alignment ⚠️ (grid decision made)
- **Battlescape**: 95% alignment ✅
- **Economy**: 88% alignment ✅
- **Integration**: 92% alignment ✅
- **Average**: 86.6% (EXCELLENT)

---

## Phase 2 Goals

**Target Alignment**: 95%+  
**Target Completion**: 2-3 weeks  
**Total Effort**: 25-30 hours of focused work

### Primary Objectives
1. ✅ Verify all data-driven game values are correct
2. 📝 Update documentation to match implementation
3. 📐 Create technical reference guides for modders
4. 🧪 Comprehensive integration testing
5. 🎮 Gameplay balance verification

---

## Priority Tasks

### CRITICAL PRIORITY (Complete First)

#### Task 1: Verify Data File Values
**Status**: IN_PROGRESS  
**Time Estimate**: 3-4 hours  
**Importance**: 🔴 CRITICAL - Game balance depends on this

**What to Verify**:
- [ ] Supplier definitions and pricing multipliers
- [ ] Facility costs and maintenance
- [ ] Research cost multipliers
- [ ] Manufacturing costs and batch bonuses
- [ ] Marketplace pricing formulas
- [ ] Weapon stats and damage values
- [ ] Unit armor and health values
- [ ] Economy thresholds and multipliers

**Files to Check**:
```
mods/core/rules/items/        - Weapon/armor stats
mods/core/rules/units/        - Unit definitions
mods/core/rules/facilities/   - Facility costs
mods/core/economy/            - Economy data
mods/core/factions/           - Faction definitions
```

**Success Criteria**:
- All data values verified against wiki documentation
- No balance issues identified
- Documentation updated for any discrepancies

**Outcome**: Confirm game is balanced and ready for gameplay testing

---

#### Task 2: Update Basescape Grid Documentation
**Status**: NOT_STARTED  
**Time Estimate**: 2-3 hours  
**Importance**: 🔴 CRITICAL - Prevents developer confusion

**What to Update**:
- [ ] wiki/systems/Basescape.md - clarify square grid (40×60)
- [ ] Add square grid diagram showing facility positions
- [ ] Document coordinate system (0,0 = top-left)
- [ ] Clarify facility size and placement rules
- [ ] Update examples with square grid screenshots

**Decision Made in Phase 1**:
> Wiki documented hex grid, engine implements square grid (40×60).  
> DECISION: Keep square grid (pragmatic, simpler).  
> ACTION: Update wiki to match actual implementation.

**Files to Modify**:
- wiki/systems/Basescape.md (primary update)
- docs/basescape/README.md (if exists)
- Wiki diagrams/images

**Success Criteria**:
- No more hex vs square confusion
- Developers can understand grid layout
- Coordinates clearly documented

**Outcome**: Clear documentation matching actual implementation

---

#### Task 3: Create TOML Format Specification
**Status**: NOT_STARTED  
**Time Estimate**: 4-5 hours  
**Importance**: 🟠 HIGH - Enables community modding

**What to Create**:
- [ ] docs/mods/TOML_SCHEMAS.md (master index)
- [ ] Schema for each content type (13 total):
  - [ ] units_schema.md
  - [ ] weapons_schema.md
  - [ ] armor_schema.md
  - [ ] items_schema.md
  - [ ] facilities_schema.md
  - [ ] missions_schema.md
  - [ ] campaigns_schema.md
  - [ ] factions_schema.md
  - [ ] technology_schema.md
  - [ ] narrative_schema.md
  - [ ] geoscape_schema.md
  - [ ] economy_schema.md
  - [ ] biomes_schema.md

**Each Schema Includes**:
- Required fields (must have)
- Optional fields (nice to have)
- Data types and valid ranges
- Examples (working TOML snippet)
- Common mistakes
- Best practices

**Files to Create**:
- docs/mods/ (new folder structure)
- docs/mods/toml_schemas/ (13 schema files)
- docs/mods/README.md (modding guide index)

**Success Criteria**:
- All 14 content types documented
- Real-world examples for each
- Modders can create content without code reading
- Validation rules clear

**Outcome**: Comprehensive modding documentation enabling content creation

---

### HIGH PRIORITY (Implement Second)

#### Task 4: Create Integration Flow Diagrams
**Status**: NOT_STARTED  
**Time Estimate**: 2-3 hours  
**Importance**: 🟡 HIGH - Helps future developers

**What to Create**:
- [ ] State transition diagram (Geoscape ↔ Battlescape ↔ Basescape)
- [ ] Data flow diagram (save/load process)
- [ ] System initialization sequence
- [ ] Turn processing flowchart
- [ ] Mission generation flow

**Format Options**:
- Mermaid.js diagrams (markdown-embedded)
- ASCII art flowcharts
- PNG diagrams (if visual design needed)

**Files to Create**:
- docs/architecture/STATE_TRANSITIONS.md
- docs/architecture/DATA_FLOW.md
- docs/architecture/SYSTEM_INITIALIZATION.md
- docs/architecture/TURN_PROCESSING.md

**Success Criteria**:
- Visual documentation clear and accurate
- Developers can trace code flow from diagrams
- New team members onboard faster

**Outcome**: Visual documentation reducing code learning curve

---

#### Task 5: Complete Integration Testing
**Status**: NOT_STARTED  
**Time Estimate**: 3-4 hours  
**Importance**: 🟡 HIGH - Ensures production readiness

**Test Plan**:

1. **Menu → Geoscape Flow**
   - [ ] Start new game successfully
   - [ ] Load saved game successfully
   - [ ] Menu buttons work
   - [ ] Settings persist

2. **Geoscape → Battlescape Flow**
   - [ ] Select mission from geoscape
   - [ ] Mission briefing screen appears
   - [ ] Squad selection works
   - [ ] Loadout management works
   - [ ] Deployment screen shows correctly
   - [ ] Battlescape initializes correctly

3. **Battlescape Gameplay**
   - [ ] Units move correctly
   - [ ] Combat actions work
   - [ ] Accuracy calculations correct
   - [ ] Damage applied properly
   - [ ] Status effects work
   - [ ] Turn progression works

4. **Battlescape → Geoscape Flow**
   - [ ] Mission completion detected
   - [ ] Victory/defeat handled correctly
   - [ ] Salvage collected properly
   - [ ] Units return to geoscape
   - [ ] Resources added to base

5. **Geoscape → Basescape Flow**
   - [ ] Base screen opens
   - [ ] Facilities display
   - [ ] Research queue visible
   - [ ] Manufacturing queue visible
   - [ ] Marketplace accessible

6. **Save/Load System**
   - [ ] Save creates file
   - [ ] Load restores state
   - [ ] Multiple save slots work
   - [ ] Auto-save functions
   - [ ] Corrupted save detection

7. **Mod System**
   - [ ] Mods load at startup
   - [ ] Content accessible from mod
   - [ ] TOML parsing works
   - [ ] Path resolution correct

**Testing Tools**:
- Love2D console output
- Manual gameplay verification
- Automated test suite

**Success Criteria**:
- All flows work without errors
- No console warnings
- Game playable end-to-end
- Save/load working reliably

**Outcome**: Verified production-ready integration

---

#### Task 6: Document Error Recovery
**Status**: NOT_STARTED  
**Time Estimate**: 2 hours  
**Importance**: 🟡 MEDIUM - Improves reliability

**What to Document**:
- [ ] Missing mod files → Fallback behavior
- [ ] Corrupted TOML → Error message + skip
- [ ] Corrupt saves → Load previous slot
- [ ] Missing scene → Error screen
- [ ] Missing data → Use defaults
- [ ] State transition errors → Error dialog

**Files to Create**:
- docs/ERROR_HANDLING.md
- docs/TROUBLESHOOTING.md
- docs/FALLBACK_MECHANISMS.md

**Each Section**:
- Error scenario
- Current handling (from code)
- User experience
- Recovery steps
- Logging/debugging info

**Success Criteria**:
- All error paths documented
- Developers know what to expect
- Users get helpful error messages
- No silent failures

**Outcome**: Robust error handling documentation

---

### MEDIUM PRIORITY (Nice to Have)

#### Task 7: Gameplay Balance Testing
**Status**: NOT_STARTED  
**Time Estimate**: 4-5 hours  
**Importance**: 🟢 MEDIUM - Improves player experience

**What to Test**:
- [ ] Enemy difficulty scaling (phases 1-4)
- [ ] Economy balance (funding vs expenses)
- [ ] Research progression (meaningful milestone unlocks)
- [ ] Manufacturing queue (costs reasonable)
- [ ] Marketplace pricing (suppliers offer value)
- [ ] Combat difficulty (not too easy/hard)
- [ ] Morale system (impacts gameplay)
- [ ] Injuries/recovery (reasonable timeline)

**Success Criteria**:
- Game playable without balance issues
- Difficulty curve smooth
- Economy sustainable
- No game-breaking exploits

**Outcome**: Balanced gameplay experience

---

#### Task 8: Developer Onboarding Guide
**Status**: NOT_STARTED  
**Time Estimate**: 3-4 hours  
**Importance**: 🟢 MEDIUM - Helps new developers

**What to Create**:
- [ ] docs/DEVELOPER_GUIDE.md (master guide)
- [ ] Architecture overview
- [ ] Key file locations
- [ ] Development workflow
- [ ] Debugging tips
- [ ] Common tasks (add weapon, add mission, etc.)
- [ ] Testing procedures
- [ ] Code standards reference

**Target Audience**: New developers or modders

**Success Criteria**:
- New developer can build and run game in <30 minutes
- Can make first code change in <1 hour
- Knows where to find anything in codebase

**Outcome**: Faster developer onboarding

---

## Implementation Schedule

### Week 1 (This Week)
- **Day 1-2**: Task 1 - Verify data values
- **Day 2**: Task 2 - Update Basescape wiki
- **Day 3-4**: Task 3 - TOML specifications
- **Day 4-5**: Task 4 - Flow diagrams

### Week 2
- **Day 1-2**: Task 5 - Integration testing
- **Day 2-3**: Task 6 - Error recovery docs
- **Day 3-4**: Task 7 - Balance testing
- **Day 5**: Task 8 - Onboarding guide

### Week 3
- **Review & Polish**: Final documentation pass
- **QA**: Comprehensive testing
- **Release**: Phase 2 completion

---

## Success Metrics

### Completion Criteria
- [ ] All 8 tasks completed
- [ ] 95%+ alignment achieved across all systems
- [ ] Zero critical documentation gaps
- [ ] Full game loop tested and working
- [ ] Modding documentation complete
- [ ] Developer onboarding guide finalized

### Quality Gates
- [ ] No console errors during normal gameplay
- [ ] No console warnings
- [ ] All data values verified
- [ ] All state transitions working
- [ ] Save/load system reliable

### Documentation Quality
- [ ] All systems documented
- [ ] Real-world examples provided
- [ ] Diagrams clear and accurate
- [ ] TOML schemas complete
- [ ] Developer guide comprehensive

---

## Risk Mitigation

### Identified Risks

**Risk 1: Data value verification finds imbalances**
- **Impact**: Medium (game balance affected)
- **Mitigation**: Document findings, create tuning guide
- **Action**: Adjust constants as needed

**Risk 2: Grid documentation change causes confusion**
- **Impact**: Low (documentation only)
- **Mitigation**: Clear before/after examples
- **Action**: Update all references systematically

**Risk 3: Integration tests find critical bugs**
- **Impact**: High (game not production-ready)
- **Mitigation**: Fix immediately, add regression tests
- **Action**: Document fixes for future reference

**Risk 4: TOML schema documentation incomplete**
- **Impact**: Medium (modders confused)
- **Mitigation**: Use existing data files as examples
- **Action**: Cross-reference with implementation

---

## Resources Needed

### Documentation Files
- [ ] 13 TOML schema files
- [ ] 4 flow diagram files
- [ ] 3 error handling files
- [ ] 1 developer guide
- [ ] 1 Basescape wiki update

### Tools
- Love2D with console output
- Text editor (VS Code)
- Mermaid.js or similar for diagrams
- Git for version control

### Testing Equipment
- One Windows PC (current setup)
- Love2D runtime
- ~30GB disk space

---

## Phase 2 Success Definition

**COMPLETE** when:
1. ✅ All 8 implementation tasks finished
2. ✅ Alignment scores: All systems ≥90% (Basescape ≥85%)
3. ✅ Full game loop playable without errors
4. ✅ Documentation matches implementation
5. ✅ Modders can create content from docs
6. ✅ New developers can contribute quickly
7. ✅ Game is balanced and fun to play

---

## Next Steps After Phase 2

### Phase 3: Content Expansion
- Expand facility types and research options
- Add more mission types and scenarios
- Implement advanced AI behaviors
- Add UI polish and animations

### Phase 4: Community Release
- Public alpha testing
- Community feedback integration
- Bug fixes and polish
- Official documentation release

### Phase 5: Advanced Features
- Multiplayer support
- Advanced mods system
- DLC content pipeline
- Long-term balance updates

---

## Tracking & Updates

**Last Updated**: October 21, 2025  
**Current Status**: Phase 2 Started  
**Task Progress**: 1/8 started

**Status Legend**:
- ✅ Complete
- 🔄 In Progress
- ⏳ Blocked
- ❌ Failed
- ⭕ Not Started

---

**Report**: Generated during Phase 1 completion  
**Approval Status**: Ready to implement  
**Next Review**: Weekly progress check
