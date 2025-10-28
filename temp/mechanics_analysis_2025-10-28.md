# Design Mechanics Analysis - Gap Identification & File Organization

> **Analysis Date**: 2025-10-28  
> **Analyzed Files**: 27 mechanics documents  
> **Purpose**: Identify gaps, inconsistencies, and propose file organization strategy

---

## Executive Summary

### Key Findings

1. **File Size Imbalance**: Wide variation from 200 lines (BlackMarket.md, Assets.md) to 1200+ lines (Battlescape.md, AI.md, Basescape.md)
2. **Cross-Reference Issues**: 23+ broken or missing cross-references between files
3. **Duplicate Content**: Several systems described in multiple files with minor variations
4. **Missing Documentation**: 8 major gaps in critical systems
5. **Inconsistent Depth**: Some files are comprehensive specifications, others are outlines

### Critical Gaps Identified

- **Hex coordinate system** referenced everywhere but not in mechanics/ folder (found in design/mechanics/ but missing from index)
- **Pilot system** mechanics spread across Units.md, Crafts.md, and Pilots.md with contradictions
- **Research tree** described conceptually but no actual tree structure documented
- **Mission generation** described in AI.md but not in Missions.md (which doesn't exist)
- **Salvage system** mentioned 40+ times but never fully specified
- **Transfer system** referenced in multiple files but incomplete specification

---

## Part 1: Content Gaps & Inconsistencies

### CRITICAL GAPS (Block Implementation)

#### 1. Missing HexSystem.md in Mechanics Folder

**Status**: ❌ **CRITICAL - Referenced 15+ times but not in main index**

**Issue**: 
- README.md lists "hex_vertical_axial_system.md" as core reading
- Battlescape.md references it extensively
- File appears to exist but not in standard location or not indexed properly

**Impact**: Cannot implement any spatial systems without coordinate system specification

**Action Required**:
1. Verify if `hex_vertical_axial_system.md` exists
2. Move to `design/mechanics/HexSystem.md` or update all references
3. Add to README.md core documents section

---

#### 2. Pilot System Contradictions

**Status**: ⚠️ **INCONSISTENT - Three different specifications**

**Contradictions Found**:

| Aspect | Pilots.md | Units.md | Crafts.md |
|--------|-----------|----------|-----------|
| Pilot count per craft | "1+ pilots based on craft type" | "Any unit can pilot" | "Requires 1 pilot (any)" |
| Pilot specialization | Dedicated pilot class | Piloting stat on all units | Fighter Pilot class exists |
| XP system | Separate Pilot XP track | Standard unit XP | "Pilots gain experience" (unspecified) |
| Reassignment | "Can switch to ground combat" | Not mentioned | "Pilots assigned to crafts" |

**Example from Crafts.md**:
> "Each craft requires 1+ pilot units based on craft type"

**But later in same file**:
> "Note: All crafts require 1 pilot. Any unit can pilot any craft."

**Action Required**:
1. Create unified Pilot System specification
2. Decide: Dedicated pilot class OR universal piloting stat
3. Update all three files consistently
4. Document in SYNCHRONIZATION_GUIDE.md

---

#### 3. Research Tree Not Documented

**Status**: ❌ **MISSING - Referenced but not specified**

**References Found**:
- Economy.md: "Research projects form interconnected branches"
- Economy.md: "Strong dependencies create logical progression paths"
- Basescape.md: "Research unlocks technology categories"
- Units.md: "Research enables unit upgrades"

**But No Actual Tree Structure**:
- No prerequisite mapping
- No technology categories defined
- No research costs per project
- No progression tiers

**Action Required**:
1. Create `ResearchTree.md` with:
   - All research projects listed
   - Prerequisite dependencies (graph/tree format)
   - Cost ranges per project
   - Manufacturing unlocks per research
   - Estimated campaign progression timeline

---

#### 4. Mission System Not Documented

**Status**: ❌ **MISSING - Critical gameplay system**

**What's Missing**:
- No `Missions.md` file exists
- Mission types scattered across AI.md, Geoscape.md, Countries.md
- Mission generation described in AI.md (procedural system)
- Mission objectives not fully specified
- Victory/failure conditions incomplete

**Mentioned Mission Types** (from various files):
- UFO Crash, UFO Interception, Alien Base Attack, Colony Defense
- Research Facility, Supply Raid, Terror Mission, Base Defense
- Rescue Mission, Assassination, Sabotage, Heist (Black Market)
- Diplomatic Mission, Escort Mission (mentioned but not specified)

**Action Required**:
1. Create `Missions.md` with:
   - All mission types with full specifications
   - Objective definitions
   - Victory/failure conditions
   - Reward structures
   - Difficulty scaling formulas
   - Generation triggers and frequencies

---

#### 5. Salvage System Incomplete

**Status**: ⚠️ **INCOMPLETE - 40+ references but no specification**

**References**:
- Economy.md: "Mission salvage funds research"
- Basescape.md: "Salvage processed into resources"
- Items.md: "Salvage from destroyed equipment"
- Crafts.md: "Scrap materials from damaged items"

**Missing Specification**:
- How salvage is generated (random? fixed?)
- Salvage value calculation
- Processing mechanics (instant or time-based?)
- Storage requirements
- Conversion to credits/materials

**Action Required**:
1. Add comprehensive Salvage System section to Economy.md OR
2. Create dedicated `Salvage.md` file
3. Specify:
   - Salvage generation tables per enemy type
   - Processing requirements (time, facility)
   - Value formulas
   - Storage mechanics
   - Integration with research/manufacturing

---

#### 6. Transfer System Incomplete

**Status**: ⚠️ **INCOMPLETE - Referenced 12+ times**

**References**:
- Economy.md: "Transfer between bases via transfer system (1-14 day delivery)"
- Basescape.md: "Inter-base logistics enabling resource redistribution"
- Items.md: "Transfers: Transfer between bases"
- Marketplace.md: "Purchased goods arrive via transfer system"

**Missing Specification**:
- Transfer cost calculation
- Route mechanics (direct vs. multi-hop)
- Interception risks (mentioned at 5-15% but not detailed)
- Transfer capacity limits
- Priority/expedited transfer mechanics

**Action Required**:
1. Create dedicated Transfer System section in Economy.md
2. Specify:
   - Cost formula (distance, weight, urgency)
   - Time calculation
   - Interception mechanics (roll, consequences)
   - Capacity per route
   - UI/queue management

---

#### 7. Terrain & Environment Systems Missing

**Status**: ❌ **MISSING - Critical for Battlescape**

**What's Missing**:
- Terrain types and properties (mentioned but not specified)
- Environmental effects (smoke, fire, gas mentioned but incomplete)
- Weather system (referenced but not documented)
- Destructible terrain mechanics (mentioned but not detailed)

**References Found**:
- Battlescape.md: "Environmental Effects" section exists but incomplete
- Battlescape.md: "Terrain Destruction" mentioned but not specified
- 3D.md: "Environmental Effects" section
- Assets.md: "Environmental art (terrain, objects, weather effects)"

**Action Required**:
1. Create `Environment.md` with:
   - Terrain type definitions (properties, movement costs, cover values)
   - Environmental effect specifications (smoke, fire, gas mechanics)
   - Weather system (types, effects on visibility/movement)
   - Destructible terrain rules
   - Map generation integration

---

#### 8. Integration Mechanics Underspecified

**Status**: ⚠️ **VAGUE - Described conceptually but not mechanically**

**Integration Points Referenced**:
- Overview.md: "Integration: How Systems Connect" (conceptual only)
- Basescape.md: "Base Integration & Feedback Loops" (incomplete)
- Economy.md: No integration section
- Geoscape.md: No integration section

**Missing Details**:
- Exact data flow between systems
- State synchronization rules
- Event propagation mechanics
- Feedback loop formulas

**Action Required**:
1. Create `Integration.md` or expand each system's integration section
2. Document:
   - Data dependencies (what reads/writes what)
   - Event triggers and handlers
   - State synchronization requirements
   - API contracts between systems

---

### MODERATE GAPS (Should Address Soon)

#### 9. Event System Not Documented

**References**: Countries.md, Politics.md, BlackMarket.md mention "events" but no unified event system

**Action**: Create `Events.md` documenting:
- Event types (political, economic, military, alien)
- Trigger conditions
- Effect specifications
- Duration mechanics

---

#### 10. Perks System Mentioned But Not Found

**References**: 
- README.md lists `Perks.md` in file structure
- Units.md mentions "perks" and "traits" interchangeably
- No actual Perks.md file found in analysis

**Action**: 
1. Verify if Perks.md exists
2. If exists, integrate with Units.md
3. If missing, document perk system in Units.md or create file

---

#### 11. Weapons & Combat Formulas Incomplete

**Issues**:
- Battlescape.md has accuracy formula but damage formula incomplete
- Weapon modes specified but AP costs inconsistent
- Range mechanics mentioned but not fully defined

**Action**: Expand Battlescape.md combat sections with:
- Complete damage formula
- All weapon mode specifications
- Range penalty tables
- Ammunition mechanics

---

#### 12. Facility Adjacency Bonus Inconsistency

**Issue**:
- Basescape.md lists adjacency bonuses
- Some bonuses reference "1-hex touching"
- Some reference "2-hex distance"
- Grid system is square but bonuses assume hex?

**Contradiction**:
> "Facility Grid System: Square grid (x-axis horizontal, y-axis vertical)"

But then:
> "Adjacency Bonuses: Must be orthogonally adjacent (4-directional only)"

And later:
> "Power Plant + Lab/Workshop: +10% efficiency | Within 2-hex distance"

**Action**: Clarify if "hex" is terminology carryover or actual distance metric on square grid

---

#### 13. Karma & Fame Systems Overlap

**Issue**:
- Karma described in Politics.md and BlackMarket.md
- Fame described in Finance.md and BlackMarket.md
- Unclear if these are same system or different
- Different thresholds listed in different files

**Action**: Create unified `Reputation.md` or consolidate in Politics.md

---

#### 14. Manufacturing vs. Research Priorities Unclear

**Issue**:
- Both systems compete for same personnel (units allocated as scientists/engineers)
- No clear priority system documented
- Resource allocation mechanics vague

**Action**: Add priority/allocation system to Economy.md

---

#### 15. Base Defense Mission vs. Basescape Integration

**Issue**:
- Base Defense is a mission type (Battlescape)
- Base Defense facilities exist (Basescape: Turrets)
- Integration between these not documented
- Do turrets participate in Base Defense missions?

**Action**: Document integration in Basescape.md Base Defense section

---

### MINOR GAPS (Nice to Have)

#### 16. Victory Conditions Not Specified

**References**: Overview.md mentions "No fixed victory conditions; sandbox"

**But**: Multiple "campaign end" references suggest victory exists

**Action**: Clarify in Overview.md or create `Victory.md`

---

#### 17. Modding System Referenced But Not Specified

**Issue**: Multiple references to "moddable" and "TOML content" but no mechanics documented

**Action**: Already covered in `api/MODDING_GUIDE.md` - add cross-reference to mechanics README

---

#### 18. Tutorial System Not Mentioned

**Issue**: Complex game with no tutorial system documented

**Action**: Consider adding Tutorial.md if tutorials are planned

---

#### 19. Save/Load System Not Mentioned

**Issue**: "save/load progression" mentioned in Overview.md but no mechanics

**Action**: Low priority, likely engine concern not design

---

#### 20. Difficulty Scaling Inconsistent

**Issue**: 
- Battlescape.md has difficulty table
- AI.md has different scaling formulas
- Geoscape.md mentions difficulty but no specifics

**Action**: Create unified difficulty scaling specification

---

## Part 2: Cross-Reference Issues

### Broken or Missing References

#### 1. README.md References

**Issue**: README.md lists files that don't match actual filenames:

Listed in README.md:
- `hex_vertical_axial_system.md` → Not found in analysis
- `PilotSystem_Technical.md` → Found as `Pilots.md`
- `DiplomaticRelations_Technical.md` → Found as `Relations.md`
- `ai_systems.md` → Found as `AI.md`
- `FutureOpportunities.md` → Found as `Future.md`

**Action**: Update README.md filenames or rename files for consistency

---

#### 2. Cross-Reference Validation Needed

Many files reference others using inconsistent naming:
- Some use "See X.md"
- Some use "See **X.md**"
- Some use "Related Systems: X"
- Some use full relative paths

**Action**: Standardize cross-reference format

---

## Part 3: File Organization Strategy

### Current Problems

1. **Inconsistent File Sizes**: 200-line files next to 1200-line files
2. **Topic Overlap**: Pilot system in 3 files, economy topics in 4 files
3. **Depth Variation**: Some files are detailed specs, others are outlines
4. **Navigation Difficulty**: 27 files without clear hierarchy

---

## Recommended File Organization: Three-Tier System

### **Tier 1: Core Systems (6-8 files, 400-800 lines each)**

These are the main gameplay layers that most users need:

**Recommended Core Files**:
1. **Geoscape.md** (Strategic Layer) - 600 lines
   - World map, provinces, territories
   - Base placement strategy
   - Craft movement and deployment
   - Mission detection and response
   - Time management

2. **Basescape.md** (Operational Layer) - 700 lines
   - Base construction and expansion
   - Facility system
   - Personnel management
   - Equipment storage
   - Research & Manufacturing (overview, link to Economy.md)

3. **Battlescape.md** (Tactical Layer) - 800 lines
   - Hex combat system
   - Map generation
   - Turn-based combat
   - Unit actions
   - Environmental effects

4. **Units.md** (Character System) - 600 lines
   - Unit stats and classes
   - Progression and specialization
   - Inventory and equipment
   - Status effects (morale, sanity, health)
   - Pilot integration (keep unified here)

5. **Economy.md** (Resource Management) - 700 lines
   - Research system + Research Tree
   - Manufacturing system
   - Marketplace
   - Supplier relations
   - Transfer system
   - Salvage system

6. **Politics.md** (Diplomatic Layer) - 500 lines
   - Country system (merge from Countries.md)
   - Relationship mechanics (merge from Relations.md)
   - Funding system (merge from Finance.md)
   - Karma & Fame (unified reputation)
   - Faction system

---

### **Tier 2: Specialized Systems (8-12 files, 200-400 lines each)**

These cover specific gameplay features:

**Recommended Specialized Files**:
1. **Crafts.md** - 400 lines (already good size)
2. **Items.md** - 400 lines
3. **AI.md** - Split into:
   - **AI_Strategic.md** - 300 lines (Geoscape AI)
   - **AI_Tactical.md** - 300 lines (Battlescape AI)
4. **Interception.md** - 300 lines (craft combat)
5. **Missions.md** - **NEW** - 400 lines
   - Mission types
   - Generation system
   - Objectives
   - Rewards
6. **BlackMarket.md** - 300 lines (expand current)
7. **Environment.md** - **NEW** - 300 lines
   - Terrain types
   - Environmental effects
   - Weather system
   - Destructible terrain

---

### **Tier 3: Reference & Technical (5-8 files, 100-300 lines each)**

Supporting documentation:

**Recommended Reference Files**:
1. **Overview.md** - 300 lines (project introduction)
2. **README.md** - 150 lines (navigation index)
3. **Glossary.md** - 200 lines (terminology)
4. **HexSystem.md** - 200 lines (coordinate system specification)
5. **3D.md** - 200 lines (alternative view documentation)
6. **Analytics.md** - 300 lines (data collection)
7. **Assets.md** - 200 lines (resource pipeline)
8. **Lore.md** - Variable (story content)
9. **Future.md** - Variable (ideas and roadmap)

---

## Reorganization Action Plan

### Phase 1: Consolidation (Reduce 27 → 18 files)

**Merge These Files**:

1. **Countries.md + Relations.md + Finance.md → Politics.md**
   - Reason: All three cover diplomatic/economic aspects
   - Result: One comprehensive political-economic system
   - New size: ~800 lines

2. **Pilots.md → Units.md (Pilot System section)**
   - Reason: Pilots are specialized units
   - Result: Unified character system
   - Add: 200 lines to Units.md

3. **AI.md → AI_Strategic.md + AI_Tactical.md**
   - Reason: 1200-line file is too large
   - Result: Two focused AI documents
   - Split: 600 lines each

4. **MoraleBraverySanity.md → Units.md (Status Effects section)**
   - Reason: Unit properties, already covered in Units.md
   - Result: Single source of truth for unit mechanics
   - Note: May need to expand Units.md Status Effects section

---

### Phase 2: Expansion (Add 4 critical files)

**Create These Files**:

1. **Missions.md** - 400 lines
   - Extract from AI.md, Geoscape.md, Countries.md
   - Consolidate all mission type specifications
   - Document generation system

2. **Environment.md** - 300 lines
   - Extract from Battlescape.md, Assets.md
   - Consolidate terrain and environmental effects
   - Document weather system

3. **Integration.md** - 300 lines
   - Document system interactions
   - Data flow specifications
   - Event propagation
   - State synchronization

4. **HexSystem.md** - 200 lines
   - Find and integrate existing hex documentation
   - Make it central reference
   - Add to core reading list

---

### Phase 3: Standardization

**Apply Consistent Structure**:

Every file should have:

```markdown
# [System Name]

> **Status**: Design Document / Technical Specification / Reference Document  
> **Last Updated**: YYYY-MM-DD  
> **Related Systems**: [Links to related files]
> **Dependencies**: [Required reading before this file]

## Table of Contents
[Auto-generated or manual]

## Overview
[1-2 paragraphs: What is this system? Why does it exist?]

## Core Mechanics
[Main gameplay mechanics]

## Integration with Other Systems
[How this connects to other parts of the game]

## Balance & Tuning
[Design goals, balance considerations]

## Implementation Notes
[Technical considerations, API references]

## Future Enhancements
[Planned features, potential expansions]
```

---

### Phase 4: Cross-Reference Audit

1. **Run automated check** for all internal references
2. **Validate** all "See X.md" references
3. **Update** README.md with accurate file list
4. **Add** "Dependencies" section to each file header
5. **Create** dependency graph visualization

---

## Proposed Final File Structure

### Core Layer (8 files)
```
Overview.md           (300 lines) - Project introduction
Geoscape.md          (600 lines) - Strategic layer
Basescape.md         (700 lines) - Operational layer
Battlescape.md       (800 lines) - Tactical layer
Units.md             (700 lines) - Character system + Pilots + Status
Economy.md           (700 lines) - Research, Manufacturing, Trade, Salvage
Politics.md          (800 lines) - Countries, Relations, Finance, Reputation
HexSystem.md         (200 lines) - Coordinate system
```

### Specialized Layer (11 files)
```
Crafts.md            (400 lines) - Vehicle system
Items.md             (400 lines) - Equipment system
Weapons.md           (300 lines) - Weapons & combat (extract from Battlescape)
Missions.md          (400 lines) - **NEW** - Mission types
AI_Strategic.md      (600 lines) - Geoscape AI
AI_Tactical.md       (600 lines) - Battlescape AI
Interception.md      (300 lines) - Craft combat
BlackMarket.md       (300 lines) - Underground economy
Environment.md       (300 lines) - **NEW** - Terrain & effects
Integration.md       (300 lines) - **NEW** - System connections
Gui.md               (existing)   - UI system
```

### Reference Layer (6 files)
```
README.md            (150 lines) - Navigation index
Glossary.md          (200 lines) - Terminology
3D.md                (200 lines) - Alternative view
Analytics.md         (300 lines) - Data system
Assets.md            (200 lines) - Resource pipeline
Lore.md              (variable)  - Story content
Future.md            (variable)  - Roadmap
```

**Total: 25 files (down from 27, up from missing 4)**

---

## Implementation Priority

### Phase 1: Critical (Week 1)
1. ✅ Create Missions.md
2. ✅ Create Environment.md  
3. ✅ Locate/create HexSystem.md
4. ✅ Resolve Pilot system contradictions (unify in Units.md)

### Phase 2: Consolidation (Week 2)
5. ✅ Merge Countries.md + Relations.md + Finance.md → Politics.md
6. ✅ Merge Pilots.md → Units.md
7. ✅ Split AI.md → AI_Strategic.md + AI_Tactical.md
8. ✅ Merge MoraleBraverySanity.md → Units.md

### Phase 3: Expansion (Week 3)
9. ✅ Create Integration.md
10. ✅ Expand Salvage System in Economy.md
11. ✅ Expand Transfer System in Economy.md
12. ✅ Document Research Tree in Economy.md

### Phase 4: Polish (Week 4)
13. ✅ Standardize all file headers
14. ✅ Audit all cross-references
15. ✅ Update README.md with new structure
16. ✅ Create dependency graph
17. ✅ Spell-check and formatting pass

---

## Metrics & Success Criteria

### Current State
- **Files**: 27
- **Average size**: 450 lines (wide variance: 200-1200)
- **Cross-references**: 150+ (23+ broken)
- **Critical gaps**: 8
- **Moderate gaps**: 7
- **Minor gaps**: 6

### Target State
- **Files**: 25 (more focused)
- **Average size**: 400 lines (less variance: 300-800)
- **Cross-references**: 200+ (0 broken)
- **Critical gaps**: 0
- **Moderate gaps**: 0
- **Minor gaps**: 2-3 (acceptable)

### Quality Measures
- ✅ Every file has consistent header
- ✅ Every file has Integration section
- ✅ All cross-references validated
- ✅ README.md matches actual files
- ✅ No contradictions between files
- ✅ Dependency graph created
- ✅ All core systems fully specified

---

## Conclusion

The design documentation is comprehensive but suffers from organizational issues and critical gaps. The three-tier reorganization strategy will:

1. **Reduce confusion** through consolidation
2. **Fill gaps** by creating missing specifications
3. **Improve navigation** through consistent structure
4. **Maintain completeness** while reducing redundancy
5. **Enable implementation** by resolving contradictions

**Estimated Effort**: 4 weeks of focused documentation work

**Priority**: High - Current gaps block implementation of core systems

**Next Steps**: Begin Phase 1 with Missions.md, Environment.md, and HexSystem.md creation

