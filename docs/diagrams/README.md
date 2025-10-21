# Visual Diagrams Index

**Created:** October 21, 2025  
**Status:** Complete (4 comprehensive diagram documents)

---

## Quick Navigation

This folder contains comprehensive visual diagrams for all AlienFall game systems. Each document uses ASCII art, Mermaid diagrams, and detailed text explanations.

### Diagram Documents

| # | Document | Focus | Pages | Complexity |
|---|----------|-------|-------|------------|
| 1 | [Game Structure](01-game-structure.md) | Layer architecture, time scales, progression | 6 | ⭐⭐⭐ |
| 2 | [Procedural Generation](02-procedural-generation.md) | Map gen, mission spawn, entity creation | 7 | ⭐⭐⭐⭐ |
| 3 | [Combat & Tactics](03-combat-tactics.md) | Combat flow, damage calc, LOS, positioning | 8 | ⭐⭐⭐⭐⭐ |
| 4 | [Base & Economy](04-base-economy.md) | Facility grid, economic cycle, manufacturing | 7 | ⭐⭐⭐⭐ |

**Total:** 28 pages of comprehensive visual documentation

---

## Document 1: Game Structure

**File:** `01-game-structure.md`

### Contents

1. **Game Layer Architecture**
   - Main game loop (60 FPS)
   - Three interconnected game modes (Geoscape, Basescape, Battlescape)
   - Layer connections and responsibilities

2. **Time Scale Hierarchy**
   - Real-world time vs game time
   - Geoscape (1 day per turn)
   - Interception (1 minute per turn)
   - Battlescape (10 seconds per turn)
   - Time progression matrix

3. **Campaign Progression Timeline**
   - Month 1 (Early Game)
   - Months 2-3 (Expansion)
   - Months 4-6 (Mid Game)
   - Months 7-12 (Late Game)
   - Year 2+ (Endgame)

4. **Organization Progression Tree**
   - 5 organizational levels (Recruit → Supreme)
   - Progression requirements (missions, funds, kills)
   - Level benefits (base count, research tiers, facility types)

5. **Game Mode Transitions**
   - Scene navigation flow (Menu → Geoscape → Basescape → Battlescape)
   - Battle resolution paths (Victory/Defeat/Draw)
   - State management

6. **Core Gameplay Loop (Detailed)**
   - Geoscape day cycle (0600-2400 hours)
   - Mission detection → deployment → battle
   - Research & manufacturing progress
   - Economic processing
   - Campaign events

### When to Use
- Understanding overall game structure
- Explaining time management
- Campaign progression planning
- New developer onboarding

---

## Document 2: Procedural Generation

**File:** `02-procedural-generation.md`

### Contents

1. **Map Generation Pipeline** (7 stages)
   - Stage 1: Biome Selection (from province hex)
   - Stage 2: Terrain Generation (biome → terrain type)
   - Stage 3: MapScript Selection (terrain rules)
   - Stage 4: MapBlock Assembly (grid generation)
   - Stage 5: MapBlock Transformations (rotations, mirrors)
   - Stage 6: Entity Placement (units, items, objectives)
   - Stage 7: Validation & Finalization

2. **Mission Generation Flow** (6 stages)
   - Stage 1: Mission Type Selection (8 possible types)
   - Stage 2: Location Selection (province hex + weights)
   - Stage 3: Difficulty Scaling (1-10 rating)
   - Stage 4: Enemy Force Composition (units, equipment)
   - Stage 5: Reward Calculation (credits, intel, artifacts)
   - Stage 6: Mission Parameters (final definition)

3. **Entity Generation System**
   - Player unit generation (squad loading)
   - Enemy unit generation (by type and rank)
   - Item generation for missions
   - Technology research trees (5 tiers)
   - Manufacturing generation (queue system)

4. **Progression Curves**
   - Unit stats by rank (Grunt → Commander)
   - Research duration by tier
   - Scaling examples

### When to Use
- Understanding procedural content generation
- Mission system behavior
- Map generation mechanics
- Enemy force composition
- Progression scaling

---

## Document 3: Combat & Tactics

**File:** `03-combat-tactics.md`

### Contents

1. **Combat Flow Diagram** (3 phases per turn)
   - Phase 1: Player Action Phase (move, attack, items, abilities, cover, end)
   - Phase 2: AI Action Phase (behavior tree, decision making)
   - Phase 3: Resolution & Special Events (environment, recovery, objectives)
   - Battle initialization and conclusion

2. **Damage Calculation System** (5 stages)
   - Stage 1: Accuracy Check (to-hit roll)
   - Stage 2: Damage Roll (weapon damage)
   - Stage 3: Armor Penetration (damage vs armor)
   - Stage 4: Special Effects (by damage type)
   - Stage 5: Critical Hit Check (multiplier)
   - Damage type effectiveness matrix

3. **Line of Sight & Cover System**
   - Basic visibility rules (range, obstruction)
   - Cover types (full, half, flanked)
   - Cover bonuses (accuracy, damage reduction)
   - Flanking penalties (rear attacks)
   - Fog of War (dynamic visibility)

4. **Action Point Economy**
   - Movement costs (4 TU per hex)
   - Attack costs (by weapon mode: 15-60 TU)
   - Special action costs (item use, cover, etc.)
   - TU economy examples (different tactics)
   - Resource management (health, ammo, energy)

### When to Use
- Understanding combat mechanics
- Balancing damage calculations
- Explaining tactical positioning
- AI behavior design
- Action economy planning

---

## Document 4: Base & Economy

**File:** `04-base-economy.md`

### Contents

1. **Base Facility Grid System**
   - 5×5 hexagonal grid layout
   - Example base layouts
   - Hexagonal neighbor topology (6 neighbors per hex)
   - Adjacency bonus rules (research, engineering, hangar)
   - 12 facility types (mandatory, early, mid, late game)
   - Facility construction gating

2. **Economic Cycle Diagram**
   - Monthly income sources (country funding: $16-18k)
   - Relations multipliers (0.5x to 1.5x)
   - Expense breakdown (maintenance, personnel, supplies)
   - Balance calculation (income - expenses)
   - Deficit consequences (game over risk)
   - Campaign progression by phase
   - Financial reporting template
   - Budget alert thresholds

3. **Research & Manufacturing Pipeline**
   - Research queue system (4 active projects)
   - 5-tier tech tree progression
   - Research time formulas
   - Manufacturing queue system
   - Manufacturing time calculation
   - Deployment workflow (auto/manual assignment)
   - Resource management (materials, credits, engineers)
   - Strategic balance by game phase

### When to Use
- Understanding base building strategy
- Economic balance planning
- Facility adjacency bonuses
- Research/manufacturing timing
- Campaign resource management

---

## Diagram Legend

### Symbols and Conventions

**Box/Container Symbols:**
```
┌─────┐    Bordered section (major component)
│     │
└─────┘

[LABEL]   Square brackets (clickable/actionable)

{NAME}    Curly braces (configuration/settings)
```

**Flow Symbols:**
```
     │
     ▼     Downward flow/progression

  ┌──▼──┐
  │ YES │  Decision point (diamond)
  └──┬──┘
  NO │
     ├─→   Branching path

     →     Arrow (direction/connection)
     ←     Reverse flow
     ↔     Bidirectional
```

**Status Symbols:**
```
✅ Complete    ❌ Missing/Not Done    ⚠️ Partial/In Progress
☆ Important    ◯ Optional            ✓ Verified
```

**Game Elements:**
```
HQ      Headquarters facility
⚗      Research laboratory
⚙      Engineering/Manufacturing
🚀     Hangar/Aircraft
▓      Forest/Vegetation
~      Water/Terrain
X      Enemy unit
◯      Friendly unit
```

---

## Cross-References

### By Game System

**Geoscape (Strategic Layer)**
- Structure: Document 1, Section 3
- Time scales: Document 1, Section 2
- Mission generation: Document 2, Section 2
- Campaign progression: Document 1, Section 3

**Basescape (Management Layer)**
- Facility grid: Document 4, Section 1
- Economic cycle: Document 4, Section 2
- Research/manufacturing: Document 4, Section 3
- Time scales: Document 1, Section 2

**Battlescape (Tactical Layer)**
- Combat flow: Document 3, Section 1
- Damage system: Document 3, Section 2
- Positioning: Document 3, Section 3
- Action economy: Document 3, Section 4
- Map generation: Document 2, Section 1
- Entity placement: Document 2, Section 3

**Interception**
- Time scales: Document 1, Section 2
- (Full system: See Document 3 for combat mechanics)

**Economy**
- Economic cycle: Document 4, Section 2
- Research progression: Document 2, Section 2 & Document 4, Section 3
- Manufacturing: Document 4, Section 3
- Relations: Document 4, Section 2

### By Implementation Task

**Map Generation:**
- See Document 2, Section 1 (Map Generation Pipeline)
- See Document 3, Section 3 (LOS/Cover affects map design)

**Mission System:**
- See Document 2, Section 2 (Mission Generation Flow)
- See Document 1, Section 6 (Daily cycle)

**Combat System:**
- See Document 3, Sections 1-4 (Complete combat reference)
- See Document 4, Section 1 (Base equipment sources)

**AI Behavior:**
- See Document 3, Section 1 (AI Action Phase)
- See Document 2, Section 2 (Enemy force composition)

**Base Management:**
- See Document 4, Section 1 (Facility grid)
- See Document 4, Section 2 (Economic cycle)
- See Document 4, Section 3 (Research/manufacturing)

**Economy:**
- See Document 4, Section 2 (Monthly cycle)
- See Document 4, Section 3 (Research timing)
- See Document 1, Section 3 (Campaign progression affects economy)

**Progression:**
- See Document 1, Section 4 (Organization levels)
- See Document 1, Section 3 (Campaign timeline)
- See Document 2, Section 4 (Progression curves)

---

## Documentation Relationships

```
                      ┌─────────────────────────┐
                      │   Game Structure (1)    │
                      │  (Overall architecture) │
                      └────────────┬────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
            ┌─────────────┐  ┌─────────────┐ ┌──────────────┐
            │  Procedural │  │  Combat &   │ │ Base &       │
            │  Generation │  │  Tactics    │ │ Economy      │
            │    (2)      │  │    (3)      │ │   (4)        │
            └─────────────┘  └─────────────┘ └──────────────┘
                    │              │              │
            Maps/Missions      Battles/AI      Facilities/
            Enemy Forces       Positioning      Research/
            Loot/Tech          Damage           Manufacturing
```

---

## Usage Guide

### For Documentation Updates
1. Find relevant diagram in this index
2. Open corresponding .md file
3. Locate relevant section
4. Update text/ASCII art as needed
5. Verify cross-references still accurate

### For New Feature Design
1. Determine which system is affected (Geoscape/Basescape/Battlescape/etc.)
2. Check corresponding diagram
3. Use diagram to understand current mechanics
4. Design feature within framework shown
5. Create pull request with diagram updates

### For Developer Onboarding
1. Start with Document 1 (Game Structure)
2. Read Document 2-4 based on focus area
3. Review relevant wiki/systems/.md files
4. Study engine code matching diagram
5. Ask questions about unclear sections

### For Balance Design
1. Review relevant economy section (Document 4, Section 2)
2. Check progression curves (Document 2, Section 4)
3. Examine damage tables (Document 3, Section 2)
4. Verify against wiki game design specs
5. Update diagrams if changes needed

---

## Future Enhancements

Diagrams that could be added:
- AI decision trees (detailed behavior flow)
- Faction/relation systems
- Interception combat specifics
- User interface flow
- Technical architecture (data structures)
- Performance optimization strategies
- Modding system architecture

---

## Maintenance

**Last Updated:** October 21, 2025  
**Total Documentation:** 28 pages  
**Coverage:** All major game systems  
**Maintenance Cadence:** Update with each major feature implementation

---

**Related Files:**
- `wiki/systems/` - Detailed game design specifications
- `engine/` - Implementation code
- `docs/` - Related documentation
- `tasks/` - Development tasks and progress

---

**How to View These Diagrams**

- **VS Code:** Open .md file, Markdown preview (Ctrl+Shift+V)
- **GitHub:** Browse directly (auto-renders Markdown)
- **Text Editor:** View raw ASCII art
- **Mermaid Live Editor:** https://mermaid.live/ (for diagram syntax)

All diagrams use pure Markdown, no special dependencies needed!
