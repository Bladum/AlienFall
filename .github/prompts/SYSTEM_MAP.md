# Mod Content Prompts - System Map

Visual reference showing all 26 prompts organized by game system and interconnections.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ALIENFALL MOD CONTENT PROMPTS                           │
│                        26 Prompts | 11 Systems                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ CORE GAME SYSTEMS (6 Prompts)                                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  item_*         unit_*         craft_*        mission_*      faction_*       │
│  Equipment      Soldiers       Vehicles       Objectives     Species         │
│  Resources      Aliens         Aircraft       Operations     Organizations   │
│                                                                              │
│                                                                              │
│                  campaign_*                                                  │
│                  Story Arcs                                                  │
│                  Phases & Progression                                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│ BASESCAPE INFRASTRUCTURE (3 Prompts)                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  facility_*          service_*            base_*                             │
│  Buildings           Operations           Defense Systems                   │
│  Manufacturing       Services             Integration                       │
│  Research            Training                                               │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│ GEOSCAPE & WORLD (3 Prompts)                                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  world_*                      country_*              region_*                │
│  Strategic Map                Nations                Territories             │
│  Continents                   Governments            Provinces               │
│  Global Scale                 Funding                UFO Activity            │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│ BATTLESCAPE - TERRAIN & VISUALS (5 Prompts)                                  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  terrain_*          biome_*           mapblock_*        mapscript_*          │
│  Tile Types         Zones             Individual        Procedural           │
│  Properties         Themes            Tactical Maps     Generation           │
│  Cover Values       Climate           Layouts           Algorithms           │
│                                                                              │
│                          tileset_*                                           │
│                          Visual Tiles                                        │
│                          Sprites                                            │
│                          Appearance                                         │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│ COMBAT & AI (1 Prompt)                                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ufo_*                                                                       │
│  UFO Behavior                                                                │
│  Combat Tactics                                                              │
│  Interception Systems                                                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│ ECONOMY & PROGRESSION (4 Prompts)                                            │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  research_*         manufacturing_*    purchase_*        supplier_*          │
│  Technology         Production         Marketplace       Vendors             │
│  Tech Trees         Recipes            Items             Pricing             │
│  Unlocks            Costs              Availability      Inventory           │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│ NARRATIVE & NPC (3 Prompts)                                                  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  event_*                      quest_*                   advisor_*             │
│  Game Events                  Objectives                NPC Characters       │
│  Consequences                 Story Arcs                Personalities        │
│  Triggers                     Rewards                   Expertise             │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│ ORGANIZATION & META (1 Prompt)                                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  org_*                                                                       │
│  Player Organization                                                         │
│  Rank Systems                                                                │
│  Divisions & Structure                                                       │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────────────┐
│ CONTENT DEPENDENCY GRAPH                                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Campaign                    Mission                                         │
│     ├─ faction_*  ←─ unit_*  ←─ item_*  ← research_*                       │
│     ├─ world_*    ←─ region_* ←─ terrain_*  ← tileset_*                   │
│     ├─ country_*  ←─ biome_*  ←─ mapblock_*  ← mapscript_*                │
│     └─ quest_*    ←─ event_*  ← advisor_*                                  │
│                                ← supplier_* ← manufacturing_*              │
│                                                                              │
│  Base Management                                                             │
│     ├─ facility_*  ← research_*                                            │
│     ├─ service_*   ← manufacturing_*                                       │
│     └─ base_*      ← unit_* (garrison)                                     │
│                                                                              │
│  Interception & Combat                                                      │
│     ├─ craft_*     ← item_* (weapons)                                      │
│     ├─ ufo_*       ← faction_* (crew)                                      │
│     └─ mapblock_*  ← terrain_* ← biome_*                                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────────────┐
│ CONTENT FLOW EXAMPLE: Creating a Complete Mission                            │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Step 1: Create Faction                                                      │
│     └─ faction_sectoids.toml  (add_faction)                                 │
│        ├─ Units needed? → add_unit                                          │
│        └─ Technology? → add_research                                        │
│                                                                              │
│  Step 2: Create Battlescape                                                  │
│     └─ Environment: biome_urban.toml  (add_biome)                          │
│        ├─ Terrain: terrain_concrete.toml  (add_terrain)                    │
│        ├─ Tiles: tileset_urban.toml  (add_tileset)                        │
│        └─ Map: mapblock_urban_01.toml  (add_map_block)                    │
│                                                                              │
│  Step 3: Create Mission                                                      │
│     └─ mission_urban_defense.toml  (add_mission)                           │
│        ├─ Uses: mapblock_urban_01                                           │
│        ├─ Enemy: faction_sectoids                                           │
│        ├─ Units: sectoid_soldier, sectoid_leader  (add_unit)              │
│        └─ Rewards: research unlocks, items  (add_research, add_item)      │
│                                                                              │
│  Step 4: Add to Campaign                                                     │
│     └─ campaign_phase1.toml  (add_campaign)                                │
│        └─ Include: mission_urban_defense                                    │
│                                                                              │
│  Step 5: Configure Economy                                                   │
│     ├─ Loot: items  (add_item)                                             │
│     ├─ Research: tech_urban_defense  (add_research)                        │
│     └─ Manufacturing: armor_urban  (add_manufacturing)                     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────────────┐
│ FILE ORGANIZATION IN MODS/CORE/                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  economy/              ← add_item, add_research, add_manufacturing          │
│  ├─ items.toml           add_purchase, add_supplier                         │
│  ├─ manufacturing.toml                                                      │
│  ├─ purchase_entries.toml                                                   │
│  └─ suppliers.toml                                                          │
│                                                                              │
│  factions/             ← add_faction, add_unit                              │
│  ├─ faction_*.toml                                                          │
│  └─ (units defined within)                                                  │
│                                                                              │
│  campaign/             ← add_campaign, add_mission, add_quest               │
│  ├─ campaign_*.toml                                                         │
│  ├─ missions.toml                                                           │
│  └─ quests.toml                                                             │
│                                                                              │
│  basescape/            ← add_facility, add_service, add_base_script        │
│  ├─ facilities/                                                             │
│  ├─ services/                                                               │
│  └─ base_*.toml                                                             │
│                                                                              │
│  geoscape/             ← add_world, add_country, add_region               │
│  ├─ world.toml                                                              │
│  ├─ provinces.toml  (countries & regions)                                   │
│  └─ crafts.toml                                                             │
│                                                                              │
│  mapblocks/            ← add_map_block                                      │
│  └─ *.toml  (individual maps)                                               │
│                                                                              │
│  mapscripts/           ← add_map_script                                     │
│  └─ *.toml  (generation scripts)                                            │
│                                                                              │
│  tilesets/             ← add_tileset                                        │
│  └─ *.toml  (visual tiles)                                                  │
│                                                                              │
│  battlescape/ai/       ← add_ufo_script                                     │
│  └─ *.toml  (UFO behaviors)                                                 │
│                                                                              │
│  technology/           ← add_research                                       │
│  ├─ phase1_*.toml                                                           │
│  └─ phase2_*.toml                                                           │
│                                                                              │
│  narrative/            ← add_event, add_quest, add_advisor                 │
│  ├─ events.toml                                                             │
│  ├─ quests.toml                                                             │
│  └─ advisors.toml                                                           │
│                                                                              │
│  lore/                 ← add_advisor (character backgrounds)                │
│  └─ characters/                                                             │
│                                                                              │
│  organizations.toml    ← add_organization                                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────────────┐
│ PROMPT COMPLEXITY LEVELS                                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ⭐ BEGINNER (Start Here)                                                    │
│     add_item.prompt.md        - Simple item creation                         │
│     add_terrain.prompt.md     - Basic tile types                            │
│     add_research.prompt.md    - Simple tech tree entries                    │
│                                                                              │
│  ⭐⭐ INTERMEDIATE                                                            │
│     add_unit.prompt.md        - Complex unit definitions                    │
│     add_craft.prompt.md       - Vehicle creation                            │
│     add_facility.prompt.md    - Base infrastructure                         │
│     add_biome.prompt.md       - Environmental zones                         │
│     add_supplier.prompt.md    - Marketplace integration                     │
│                                                                              │
│  ⭐⭐⭐ ADVANCED                                                              │
│     add_mission.prompt.md     - Complete mission design                     │
│     add_faction.prompt.md     - Faction system integration                  │
│     add_campaign.prompt.md    - Campaign design & pacing                    │
│     add_map_block.prompt.md   - Tactical map layout                         │
│     add_organization.prompt.md- Organization structure                      │
│                                                                              │
│  ⭐⭐⭐⭐ EXPERT (Systems Integration)                                         │
│     add_map_script.prompt.md  - Procedural generation                       │
│     add_base_script.prompt.md - Base system integration                     │
│     add_ufo_script.prompt.md  - AI behavior systems                         │
│     add_event.prompt.md       - Complex event chains                        │
│     add_quest.prompt.md       - Multi-stage quest design                    │
│                                                                              │
│  ⭐⭐⭐⭐⭐ MASTER (Polish & Content)                                           │
│     add_advisor.prompt.md     - Character development                       │
│     add_world.prompt.md       - World design & balance                      │
│     add_country.prompt.md     - Geopolitical simulation                     │
│     add_region.prompt.md      - Regional management                         │
│     add_tileset.prompt.md     - Visual polish                               │
│     add_service.prompt.md     - Service integration                         │
│     add_manufacturing.prompt.md- Economy balance                            │
│     add_purchase.prompt.md    - Marketplace curation                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


STATISTICS
═══════════════════════════════════════════════════════════════════════════════

  Total Prompts:                26
  Game Systems Covered:         11
  Unique Prefixes:              26
  Documentation Files:          3 (README, SUMMARY, COMPLETION_CHECKLIST)
  Total Files:                  29

  Average Prompt Length:        ~2,500 words
  Total Prompt Content:         ~65,000 words
  Documentation Content:        ~8,000 words
  Total Project Content:        ~73,000 words

  Code Templates:               26 (one per prompt)
  Validation Checklists:        26
  Testing Procedures:           26
  API References:               26+

═══════════════════════════════════════════════════════════════════════════════
```

## How to Use This Map

1. **Find Your Content Type** - Locate the prompt in the appropriate system section
2. **Check Dependencies** - See what content it depends on (in Content Dependency Graph)
3. **Follow Examples** - Use the example flow (Creating a Mission) as a template
4. **Work Step-by-Step** - Process section shows order of operations
5. **Verify Complexity** - Check complexity level to gauge learning curve

## Quick Start Examples

### Creating a Simple Item
1. Read: `add_item.prompt.md`
2. File: `mods/core/economy/items.toml`
3. Use: TOML template provided
4. Validate: Using checklist

### Creating a Complete Mission
1. Read: `add_mission.prompt.md`
2. Prepare: `add_biome` → `add_terrain` → `add_map_block`
3. Configure: Enemy faction (add_faction)
4. Rewards: Items (add_item), Tech (add_research)
5. Add to: Campaign (add_campaign)

### Building a Campaign
1. Phases: Use `add_campaign` template
2. Missions: Create missions (add_mission)
3. Content: Items, tech, factions (add_item, add_research, add_faction)
4. World: Setup map (add_world, add_country, add_region)
5. Polish: Add advisors (add_advisor), events (add_event)

---

**All prompts ready to use! Start with beginner-level prompts and progress upward.**
