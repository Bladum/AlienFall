# AlienFall Documentation Rewrite Priority Checklist

**Purpose:** Actionable checklist for systematically improving "alien fall" folder content using "alien fall wiki" as source material.

---

## Phase 1: Critical Infrastructure (Week 1-2) 🔴

### Must-Have Foundation - Cannot develop coherently without these

- [ ] **Create `integration/` folder**
  - [ ] `README.md` - System matrix, event catalogue, lifecycle diagrams (~200 lines)
    - Source: `alien fall wiki/integration/README.md`
    - Key content: Service interactions, event payloads, cross-system flows
  - [ ] `Mission_Lifecycle.md` - Complete mission flow from detection to debriefing (~400 lines)
    - Source: `alien fall wiki/integration/Mission_Lifecycle.md`
    - Key content: 5-phase lifecycle, state transitions, integration points
  - [ ] `Anti_Patterns.md` - Common integration mistakes
    - Source: `alien fall wiki/integration/Anti_Patterns.md`
  - [ ] `Debugging_Guide.md` - Troubleshooting cross-system issues
    - Source: `alien fall wiki/integration/Debugging_Guide.md`

- [ ] **Create `docs/` folder**
  - [ ] `architecture.md` - System overview and design principles (~200 lines)
    - Source: `alien fall wiki/docs/architecture.md`
    - Key content: State stack, service registry, domain models
  - [ ] `Love2D_Implementation_Plan.md` - Complete implementation blueprint (~800 lines)
    - Source: `alien fall wiki/docs/Love2D_Implementation_Plan.md`
    - Key content: File structure, module blueprints, roadmap
  - [ ] `style-guide.md` - Code and documentation standards
    - Source: `alien fall wiki/docs/style-guide.md`

- [ ] **Create `technical/` folder**
  - [ ] `README.md` - Service architecture, data pipeline, RNG patterns (~150 lines)
    - Source: `alien fall wiki/technical/README.md`
    - Key content: Service locator, deterministic RNG, data flow, Mermaid diagrams

- [ ] **Rewrite `Core Systems/README.md`** (~100 lines)
  - Source: `alien fall wiki/core/README.md`
  - Key content:
    - Action Economy Framework (4 AP standard)
    - Capacity Management System (binary constraints)
    - Energy Resource System (0-100 pools)
    - Time Progression Framework (5-min ticks, 30-sec rounds, 6-sec turns)
    - Cross-system integration patterns

**Phase 1 Success Criteria:**
- ✅ Developers can understand how systems connect
- ✅ Implementation architecture is clear
- ✅ Core mechanics are consistently defined
- ✅ Integration patterns are documented

---

## Phase 2: Core Game Systems (Week 3-4) 🔴

### Essential Gameplay Mechanics

- [ ] **Rewrite `Basescape/Facilities.md`** (~120 lines)
  - Source: `alien fall wiki/basescape/Facilities.md`
  - Transform from: 30 lines, generic bullets
  - Transform to: Comprehensive specs with:
    - Size and footprint system (1×1, 2×2 tiles)
    - Construction lifecycle (Planning → Building → Operational)
    - Connectivity requirements (HQ network)
    - Health and damage system (HP + armor)
    - Capacity contribution framework
    - Service tag system
    - Tactical integration (map blocks)
    - Operations and maintenance costs
    - Failure mode handling

- [ ] **Rewrite `Basescape/README.md`** (~100 lines)
  - Source: `alien fall wiki/basescape/README.md`
  - Key content: Grid system, capacity framework, service network, construction queue

- [ ] **Rewrite `Basescape/Capacities.md`**
  - Source: `alien fall wiki/basescape/Capacities.md`
  - Key content: Capacity types, aggregation rules, overflow policies

- [ ] **Rewrite `Basescape/Services.md`**
  - Source: `alien fall wiki/basescape/Services.md`
  - Key content: Service tag system, dependency chains

- [ ] **Rewrite `Economy/Research tree.md`** (~250 lines)
  - Source: `alien fall wiki/economy/Research tree.md`
  - Transform from: 40 lines, trivial examples
  - Transform to: Comprehensive DAG system with:
    - Graph structure (prerequisites, DAG relationships)
    - Choice and branching systems (mutually exclusive paths)
    - Discovery mechanics (hidden technologies)
    - Event hooks (unlock triggers)
    - Planning tools (research queues)
    - Contest mechanics (research races)
    - Mermaid diagrams (technology trees)

- [ ] **Rewrite `Economy/Research entry.md`**
  - Source: `alien fall wiki/economy/Research entry.md`
  - Key content: Project attributes, progress formulas, lab allocation

- [ ] **Rewrite `Economy/Manufacturing.md`** (~100 lines)
  - Source: `alien fall wiki/economy/Manufacturing.md`
  - Key content: Production capacity, man-hours, queue management

- [ ] **Rewrite `Economy/README.md`**
  - Source: `alien fall wiki/economy/README.md`
  - Key content: Economy overview, resource flow

- [ ] **CREATE `Battle Tactical Combat/Damage calculations.md`** (~100 lines)
  - Source: `alien fall wiki/items/Damage calculations.md`
  - File doesn't exist in new folder!
  - Key content:
    - Damage pipeline (7 stages)
    - Type multiplication (resistances)
    - Armor mitigation (penetration)
    - Channel distribution (health/stun/energy/morale)
    - Derived effects (wounds, death, panic)
    - Provenance logging

- [ ] **Rewrite `Battle Tactical Combat/Unit Actions.md`** (~80 lines)
  - Source: Synthesize from `alien fall wiki/battlescape/mechanics/*`
  - Transform from: 40 lines, inconsistent AP costs
  - Transform to: Comprehensive action system with:
    - Action point costs (consistent with 4 AP system)
    - Movement formulas
    - Combat actions (accuracy, damage)
    - Special abilities (energy costs)
    - Reaction fire mechanics
    - Action resolution order
    - Environment interactions

- [ ] **Rewrite `Battle Tactical Combat/Line of Sight.md`** (~60 lines)
  - Source: `alien fall wiki/battlescape/mechanics/` (distributed)
  - Key content: LOS algorithms, tile blocking, height mechanics

**Phase 2 Success Criteria:**
- ✅ Basescape facilities fully specified with formulas
- ✅ Research system has branching DAG mechanics
- ✅ Combat damage pipeline completely defined
- ✅ Unit actions consistent with core AP system

---

## Phase 3: Secondary Systems (Week 5-6) 🟡

### Important for Complete Game

- [ ] **Create unified `AI/` folder**
  - [ ] `README.md` - AI framework overview (~80 lines)
    - Source: `alien fall wiki/ai/README.md`
    - Key content: AI director, utility systems, personality traits
  - [ ] `Director.md` - Campaign-level AI
    - Source: `alien fall wiki/ai/Alien Strategy.md`
  - [ ] `Battlescape_AI.md` - Tactical AI
    - Source: `alien fall wiki/ai/Battlescape AI.md`
  - [ ] `Geoscape_AI.md` - Strategic AI
    - Source: `alien fall wiki/ai/Geoscape AI.md`
  - [ ] `Faction_Behavior.md` - Personality systems
    - Source: `alien fall wiki/ai/Faction_Behavior.md`

- [ ] **Enhance `GUI Widgets/`**
  - [ ] `README.md` - Widget library architecture
    - Source: Synthesize from `alien fall wiki/widgets/*`
    - Key content: Widget patterns, theme system, event handling

- [ ] **Create `examples/` folder**
  - Source: `alien fall wiki/examples/`
  - [ ] `data/` - TOML examples
  - [ ] `lua/` - Lua script examples
  - [ ] `mods/` - Mod structure examples

**Phase 3 Success Criteria:**
- ✅ AI systems unified and comprehensive
- ✅ Widget library documented
- ✅ Examples available for modders

---

## Phase 4: Supporting Systems (Week 7-8) 🟢

### Quality of Life and Extensibility

- [ ] **Create `templates/` folder**
  - Source: `alien fall wiki/templates/`
  - [ ] Mod templates
  - [ ] Content authoring guides

- [ ] **Enhance `Geoscape/` files**
  - [ ] `Mission_Types.md` from wiki (~100 lines)
  - [ ] `Detection.md` from wiki
  - [ ] `Craft Operations.md` from wiki

- [ ] **Enhance `Interception/` files**
  - [ ] `Overview.md` from wiki (~120 lines)
  - [ ] `Air_Weapons.md` from wiki
  - [ ] `Interception Core Mechanics.md` from wiki

- [ ] **Enhance `Items/` files**
  - [ ] Multiple weapon and armor files from wiki
  - [ ] Detailed stat specifications

- [ ] **Enhance `Units/` files**
  - [ ] `Stats.md` from wiki (~80 lines)
  - [ ] Other unit system files

**Phase 4 Success Criteria:**
- ✅ Templates support mod creation
- ✅ All major systems have comprehensive docs
- ✅ Modding extensibility fully documented

---

## File-by-File Quick Reference

### Top 20 Files by Priority

| # | File | Source | Lines | Status |
|---|------|--------|-------|--------|
| 1 | `integration/README.md` | integration/README.md | ~200 | ⬜ Not Started |
| 2 | `integration/Mission_Lifecycle.md` | integration/Mission_Lifecycle.md | ~400 | ⬜ Not Started |
| 3 | `docs/architecture.md` | docs/architecture.md | ~200 | ⬜ Not Started |
| 4 | `docs/Love2D_Implementation_Plan.md` | docs/Love2D_Implementation_Plan.md | ~800 | ⬜ Not Started |
| 5 | `technical/README.md` | technical/README.md | ~150 | ⬜ Not Started |
| 6 | `Core Systems/README.md` | core/README.md | ~100 | ⬜ Not Started |
| 7 | `Basescape/Facilities.md` | basescape/Facilities.md | ~120 | ⬜ Not Started |
| 8 | `Basescape/README.md` | basescape/README.md | ~100 | ⬜ Not Started |
| 9 | `Economy/Research tree.md` | economy/Research tree.md | ~250 | ⬜ Not Started |
| 10 | `Battle Tactical Combat/Damage calculations.md` | items/Damage calculations.md | ~100 | ⬜ Not Started |
| 11 | `Battle Tactical Combat/Unit Actions.md` | battlescape/mechanics/* | ~80 | ⬜ Not Started |
| 12 | `Battle Tactical Combat/Line of Sight.md` | battlescape/mechanics/ | ~60 | ⬜ Not Started |
| 13 | `AI/README.md` | ai/README.md | ~80 | ⬜ Not Started |
| 14 | `integration/Base_Defense.md` | integration/Base_Defense.md | ~150 | ⬜ Not Started |
| 15 | `Geoscape/Mission_Types.md` | geoscape/Mission_Types.md | ~100 | ⬜ Not Started |
| 16 | `Interception/Overview.md` | interception/README.md | ~120 | ⬜ Not Started |
| 17 | `Units/Stats.md` | units/Stats.md | ~80 | ⬜ Not Started |
| 18 | `Economy/Manufacturing.md` | economy/Manufacturing.md | ~100 | ⬜ Not Started |
| 19 | `Finance/Funding.md` | finance/Funding.md | ~80 | ⬜ Not Started |
| 20 | `GUI Widgets/README.md` | widgets/* | ~100 | ⬜ Not Started |

---

## Rewriting Methodology

### For Each File Rewrite:

1. **Read wiki source completely** - Understand full scope
2. **Extract core principles** - Game design essentials
3. **Identify formulas** - Mathematical specifications
4. **Note integration points** - Cross-system dependencies
5. **Collect examples** - Numeric scenarios
6. **Structure with ToC** - Match wiki organization depth
7. **Add Love2D notes** - Implementation specifics
8. **Include TOML examples** - Data structure samples
9. **Add Mermaid diagrams** - Visual workflows (where appropriate)
10. **Cross-reference** - Link to related files

### Quality Checklist Per File:

- [ ] Table of Contents present (if >80 lines)
- [ ] Overview section with context
- [ ] Mechanics section with 5+ subsections
- [ ] Formulas included where applicable
- [ ] Examples with specific numbers
- [ ] Integration notes showing cross-system connections
- [ ] TOML data structure examples
- [ ] Related pages section
- [ ] References to existing games
- [ ] File is 80+ lines (not 30-50)

---

## Progress Tracking

### Overall Progress
- Phase 1: ⬜⬜⬜⬜ (0/4 major sections)
- Phase 2: ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ (0/10 files)
- Phase 3: ⬜⬜⬜ (0/3 sections)
- Phase 4: ⬜⬜⬜⬜ (0/4 sections)

**Total: 0/21 major tasks completed**

### Completion Legend
- ⬜ Not Started
- 🟨 In Progress
- ✅ Completed

---

## Next Actions

### Immediate (This Week)
1. Create `integration/` folder
2. Write `integration/README.md` (~200 lines)
3. Write `integration/Mission_Lifecycle.md` (~400 lines)
4. Create `docs/` folder
5. Write `docs/architecture.md` (~200 lines)

### This Month
6. Complete all Phase 1 tasks
7. Complete Basescape rewrites (Phase 2)
8. Complete Economy rewrites (Phase 2)
9. Begin Battle Tactical Combat rewrites (Phase 2)

### Next 2 Months
10. Complete all Phase 2 and Phase 3 tasks
11. Begin Phase 4 tasks
12. Add cross-references between all files

---

## Success Metrics

### Target Completion Metrics
- **Average file length:** 80+ lines (currently 30-50)
- **Documentation depth score:** 8/10+ (currently 2/10)
- **Integration coverage:** 100% of systems (currently ~10%)
- **Formula inclusion:** 80%+ of mechanical systems (currently ~20%)
- **Example quality:** Numeric calculations (currently generic)
- **TOML coverage:** All configurable systems (currently 0%)

### Final Assessment Criteria
- ✅ Can a developer implement any system from docs alone?
- ✅ Are all cross-system interactions documented?
- ✅ Are formulas complete and unambiguous?
- ✅ Are examples realistic and calculated?
- ✅ Can modders extend systems using templates?
- ✅ Is the architecture clear and Love2D-specific?

---

**Start with Phase 1 - Integration and Architecture are the foundation for everything else.**
