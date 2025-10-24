# Task: Content Expansion - New Aliens, Missions & Events

**Status:** TODO
**Priority:** Medium
**Created:** October 24, 2025
**Completed:** N/A
**Assigned To:** AI Agent

---

## Overview

Expand campaign content with:
1. 6 new alien faction types (expand from 4 current)
2. 20 new mission template types
3. 30 new campaign event types
4. Dynamic mission generation system
5. Procedural event chains

Transforms campaign from limited scenarios to diverse, replayable experiences.

---

## Purpose

The campaign system works but content is limited. Players face same missions/events repeatedly. Content expansion creates:
- **Variety:** Each playthrough feels different
- **Replayability:** 50+ mission types, 30+ events
- **Strategy depth:** Different alien tactics requiring different responses
- **Challenge:** Dynamic difficulty via event chains

---

## Requirements

### Functional Requirements
- [ ] 6 new alien faction types with distinct traits
- [ ] 20 new mission templates (diverse objectives)
- [ ] 30 new campaign events (strategy, diplomacy, economy)
- [ ] Event chains (events trigger other events)
- [ ] Dynamic mission generation (procedural variation)
- [ ] Faction-specific tech trees (8 new trees)
- [ ] New diplomatic relations (expanded from 4 → 8 types)
- [ ] Economy variations (resource scarcity events)
- [ ] Mission difficulty modifiers
- [ ] Random encounter tables

### Content Requirements
- [ ] Alien faction data files
- [ ] Mission template data files
- [ ] Event data files
- [ ] Tech tree definitions
- [ ] Lore/flavor text for all new content
- [ ] UI art/portraits for new factions

### Technical Requirements
- [ ] Create mission generator system
- [ ] Implement event chain resolver
- [ ] Create content database structure
- [ ] Mission randomization system
- [ ] Event probability engine
- [ ] Content balance framework

### Acceptance Criteria
- [ ] All new content loads without errors
- [ ] Mission generation produces valid missions
- [ ] Event chains work correctly
- [ ] Campaign plays with new content
- [ ] No balance issues (exit code 0)
- [ ] Lore/flavor text integrated
- [ ] UI shows new content

---

## Plan

### Step 1: Content Database Structure (5 hours)
**Description:** Design content organization system
**Files to modify/create:**
- `engine/content/content_database.lua` (NEW - 300 lines)
- `engine/content/mission_templates.lua` (NEW - 250 lines)
- `engine/content/campaign_events_db.lua` (NEW - 250 lines)
- `engine/content/faction_definitions.lua` (modify - add new factions)

**Content structure:**
```lua
-- Factions
{
  id = "insectoids",
  name = "Insectoid Collective",
  description = "Hive mind creatures from deep space",
  units = {"insectoid_worker", "insectoid_soldier", "insectoid_queen"},
  tech_tree = "insectoid_tech",
  relations = {human = -50, sectoid = 20}, -- diplomacy graph
  traits = {"hive_mind", "fast_reproduction"},
  color = {r=0.2, g=0.8, b=0.2}
}

-- Mission Templates
{
  id = "alien_harvesting",
  name = "Alien Harvesting Operation",
  description = "Aliens conducting mass abductions",
  objectives = {"protect_civilians", "eliminate_aliens"},
  difficulty = 3,
  enemy_count_range = {8, 12},
  rewards = {science = 300, money = 500, artifacts = 2},
  probability = 0.15
}

-- Campaign Events
{
  id = "research_breakthrough",
  name = "Research Breakthrough",
  description = "Scientists unlock new technology",
  type = "positive",
  effects = {
    {type = "tech_unlock", tech_id = "plasma_weapons"},
    {type = "morale_boost", amount = 10}
  },
  trigger_conditions = {research_points_min = 1000},
  probability = 0.08
}
```

**Database organization:**
- Core content (built-in)
- Modded content (loaded from mods)
- Generated content (procedural)

**Estimated time:** 5 hours

### Step 2: 6 New Alien Factions (8 hours)
**Description:** Design and implement new factions
**Files to create:**
- `engine/content/factions/insectoids.lua` (NEW - 200 lines)
- `engine/content/factions/reptilians.lua` (NEW - 200 lines)
- `engine/content/factions/arachnids.lua` (NEW - 200 lines)
- `engine/content/factions/cyborgs.lua` (NEW - 200 lines)
- `engine/content/factions/ethereals.lua` (NEW - 200 lines)
- `engine/content/factions/mutants.lua` (NEW - 200 lines)

**New Factions:**

1. **Insectoid Collective** (hive mind)
   - Traits: Hive coordination, fast reproduction, weak individually
   - Units: Worker, Soldier, Queen
   - Tech: Chemical weapons, pheromone signals
   - Relations: Ally with Sectoids

2. **Reptilian Empire** (cold-blooded, military)
   - Traits: Disciplined, slow but powerful, adaptable
   - Units: Warrior, Specialist, Commander
   - Tech: Thermal weapons, heat vision
   - Relations: Rival with everyone

3. **Arachnid Swarm** (spider-like, numerous)
   - Traits: Web coordination, weak solo, deadly group
   - Units: Drone, Warrior, Overseer
   - Tech: Biotech, toxins, neural link
   - Relations: Neutral

4. **Cybernetic Union** (half-organic, half-machine)
   - Traits: Technological, upgrading constantly, slow to adapt
   - Units: Cyborg, Assassin, Nexus
   - Tech: Hacking, EMP, cyber enhancements
   - Relations: Conflict with organic life

5. **Ethereal Collective** (psychic, ancient)
   - Traits: Psychic powers, ancient knowledge, rare
   - Units: Priest, Warrior, Avatar
   - Tech: Psionic powers, interdimensional tech
   - Relations: Mysterious, unpredictable

6. **Mutant Horde** (bio-engineered, diverse)
   - Traits: Varied abilities, unpredictable, evolving
   - Units: Mutant Warrior (random), Beast, Overseer
   - Tech: Genetic engineering, biology weapons
   - Relations: Desperate, unpredictable

**Estimated time:** 8 hours

### Step 3: 20 New Mission Types (10 hours)
**Description:** Create diverse mission templates
**Files to create:**
- `engine/content/missions/` directory with 20 mission files (NEW)

**Mission Categories:**

**Combat-focused (8 types):**
- Alien Invasion (straight attack)
- Base Defense (protect facilities)
- Rescue Operation (save civilians/soldiers)
- Artifact Recovery (retrieve alien tech)
- Alien Harvesting (stop abductions)
- UFO Crash Recovery (salvage crashed craft)
- Assassination Target (eliminate specific alien)
- Territory Dispute (control map areas)

**Exploration-focused (6 types):**
- Archaeological Dig (discover alien tech)
- Research Facility Breach (study alien science)
- Alien Colony Discovery (find hidden base)
- Portal Investigation (study alien gateway)
- Derelict Exploration (investigate abandoned ship)
- Genetic Vault Infiltration (capture alien samples)

**Objective-varied (6 types):**
- Bomb Defusal (find and disable device)
- Hostage Rescue (extract civilians)
- VIP Extraction (protect important NPC)
- Data Theft (recover alien databases)
- Assassination (eliminate high-value target)
- Sabotage (destroy alien installations)

**Example mission template:**
```lua
{
  id = "alien_colony_discovery",
  name = "Alien Colony Discovery",
  description = "Scouts discovered an underground alien colony. We must investigate.",
  difficulty = 4,
  enemy_types = {"insectoid_soldier", "insectoid_worker"},
  enemy_count_range = {12, 18},
  map_type = "underground_hive",
  objectives = {
    {id = "eliminate_enemies", description = "Eliminate alien forces"},
    {id = "collect_samples", description = "Collect 3 genetic samples", optional = true}
  },
  rewards = {
    science = 500,
    money = 800,
    artifacts = 3,
    tech_unlock = "hive_biology"
  },
  probability = 0.12,
  prerequisites = {faction_relations_min = 0}
}
```

**Estimated time:** 10 hours

### Step 4: 30 New Campaign Events (9 hours)
**Description:** Create strategic events and event chains
**Files to create:**
- `engine/content/events/` directory with 30 event files (NEW)

**Event Categories:**

**Research Events (6):**
- Research breakthrough (unlock tech)
- Equipment malfunction (lose tech)
- Espionage discovered (enemy steals tech)
- Scientist defection (lose research capacity)
- Technology donation (gain from allies)
- Lab explosion (lose progress)

**Diplomacy Events (6):**
- Alliance offer (improve relations)
- Trade negotiation (economy boost)
- Territory dispute (conflict)
- Cultural exchange (morale boost)
- Betrayal discovered (relations drop)
- Peace treaty (war ends)

**Economy Events (6):**
- Resource discovery (money/resources up)
- Economic collapse (money down)
- Trade opportunity (sell artifacts)
- Inflation crisis (prices up)
- Revolution (economy chaos)
- New markets open (new trade routes)

**Military Events (6):**
- UFO sighting (potential mission)
- Alien attack (immediate threat)
- Desertion (lose soldiers)
- Victory celebration (morale up)
- Soldier infection (crisis)
- New recruit arrives (gain soldier)

**Random Events (6):**
- Mysterious signal (investigation mission)
- Ancient artifact found (science points)
- Meteor impact (economic loss)
- Dimensional rift (supernatural event)
- Time anomaly (reschedule missions)
- First contact (new faction appears)

**Example event:**
```lua
{
  id = "research_breakthrough",
  name = "Research Breakthrough!",
  description = "Our scientists achieved a major breakthrough in plasma technology!",
  type = "positive",
  source = "research",
  effects = {
    {type = "tech_unlock", tech_id = "plasma_rifles", cost_reduction = 0.2},
    {type = "morale_boost", countries = "all", amount = 5},
    {type = "science_points", amount = 100}
  },
  trigger_conditions = {
    research_points = 2000,
    tech_level_min = 3,
    probability = 0.15
  },
  triggers_chains = {"plasma_weapon_adoption", "military_expansion"},
  duration_turns = 5
}
```

**Event Chains:**
- Research breakthrough → Military expansion → Alien retaliation
- Trade opportunity → Economic boom → Inflation crisis
- UFO sighting → First contact → Diplomacy event

**Estimated time:** 9 hours

### Step 5: Event Chain System (6 hours)
**Description:** Implement event trigger and chain system
**Files to modify/create:**
- `engine/core/event_chain_manager.lua` (NEW - 400 lines)
- `engine/geoscape/campaign_orchestrator.lua` (modify - integrate chains)

**Event chain logic:**
```lua
EventChainManager = {
  -- Register event and its triggers
  register_chain = function(chain_definition)
    -- Event A happens
    -- Check probability/conditions
    -- Trigger Event B after 3 turns
    -- Update world state
    -- Queue Event C if B succeeded
  end,

  -- Resolve event and queue chains
  execute_event = function(event)
    -- Apply effects
    -- Check for triggered chains
    -- Queue next events
    -- Update world state
  end
}
```

**Event probabilities:**
- Positive events: 10-20% per turn
- Negative events: 5-15% per turn
- Chain events: dependent on parent event

**Estimated time:** 6 hours

### Step 6: Mission Generator System (7 hours)
**Description:** Create procedural mission variation
**Files to modify/create:**
- `engine/geoscape/mission_generator.lua` (NEW - 500 lines)
- `engine/geoscape/difficulty_scaler.lua` (modify - integrate with generator)

**Generation process:**
```
1. Select mission template
2. Roll for difficulty modifier (-2 to +2)
3. Generate enemy composition (balanced for difficulty)
4. Randomize objectives (add/remove optional objectives)
5. Assign map layout
6. Set reward scaling
7. Create mission instance
```

**Mission variation:**
- Same template, different difficulties
- Same difficulty, different enemies
- Same enemies, different objectives
- Procedural map layout

**Example generation:**
```lua
-- Template: Alien Base Raid (difficulty 3)
-- Generated: Difficulty 4 variant
--   - 3 more aliens (15 vs 12)
--   - 1 commander unit (increased AI)
--   - 2 extra objectives
--   - 20% more rewards
--   - Underground map with more cover
```

**Estimated time:** 7 hours

### Step 7: Tech Trees & Progression (6 hours)
**Description:** Add new faction tech trees
**Files to create:**
- `engine/content/tech_trees/` directory with 6 new trees (NEW)
- Each tree: 15-20 techs, 3-4 tiers

**Tech tree structure:**
```lua
{
  id = "insectoid_tech",
  faction = "insectoids",
  name = "Insectoid Technology",
  description = "Hive-mind biological technology",
  techs = {
    tier_1 = {
      {id = "hive_communication", name = "Hive Communication", cost = 100},
      {id = "toxin_production", name = "Toxin Production", cost = 120}
    },
    tier_2 = {
      {id = "pheromone_control", name = "Pheromone Control", cost = 300, prereq = "hive_communication"}
    }
  }
}
```

**Estimated time:** 6 hours

### Step 8: Content Balance & Polish (6 hours)
**Description:** Balance and refine all content
**Files to modify:**
- All content files (review, adjust)
- Balance testing

**Balance review:**
- Mission difficulties vs player progression
- Event probabilities
- Reward scaling
- Resource allocation
- Difficulty curves

**Polish:**
- Flavor text proofreading
- Icon/color consistency
- Lore coherence
- Name consistency

**Estimated time:** 6 hours

### Step 9: Integration & Testing (8 hours)
**Description:** Integrate all new content into campaign
**Files to create:**
- `tests/integration/test_new_content.lua` (NEW - 500 lines)
- `tests/integration/test_missions_generated.lua` (NEW - 400 lines)
- `tests/integration/test_event_chains.lua` (NEW - 400 lines)

**Integration:**
- Load all new factions
- Initialize all mission templates
- Register all events
- Start event chains
- Run campaign with new content

**Test scenarios:**
1. All factions load without errors
2. 20 mission types generate correctly
3. Event chains trigger appropriately
4. Mission generator creates varied missions
5. Campaign balance is reasonable
6. No crashes with new content
7. Lore text displays correctly
8. Tech trees complete with unlocks

**Estimated time:** 8 hours

---

## Implementation Details

### Architecture

**Content flow:**
```
ContentDatabase (all definitions)
    ↓
    ├→ FactionFactory (creates faction instances)
    ├→ MissionGenerator (creates missions)
    └→ EventManager (triggers events)
    ↓
Campaign uses generated content
```

**Mission generation:**
```
Select template → Scale difficulty → Generate enemies →
Randomize objectives → Assign map → Set rewards → Create instance
```

**Event chains:**
```
Event triggered → Check conditions → Apply effects →
Queue chain events → Update world state
```

### Key Components

- **ContentDatabase:** Central data store
- **MissionGenerator:** Procedural missions
- **EventChainManager:** Event triggers
- **BalanceFramework:** Difficulty scaling
- **RandomEncounters:** Procedural variation

### Dependencies

- Campaign system (TASK-025) - COMPLETE ✅
- Mission system (existing) - verified functional
- Event system (existing) - verified functional

---

## Testing Strategy

### Unit Tests
- Content loading
- Mission generation
- Event triggering
- Balance calculations

### Integration Tests
- Full campaign with new content
- Event chains working
- Mission generation valid
- No balance breaks

### Manual Testing

1. **Load new factions:**
   - Start campaign
   - Check all 10 factions available
   - Play with each faction

2. **Generate missions:**
   - Trigger 20 different mission types
   - Verify they load correctly
   - Check reward scaling

3. **Test event chains:**
   - Play 10 campaigns
   - Track events and chains
   - Verify chains trigger

4. **Balance check:**
   - Run 3 full campaigns
   - Check difficulty progression
   - Review win/loss ratio

---

## Documentation Updates

### Files to Update/Create
- [ ] `lore/factions/` - New faction lore
- [ ] `api/MISSIONS.md` - Mission template reference
- [ ] `api/EVENTS.md` - Event system reference
- [ ] `design/mechanics/Content_Expansion.md` - Design docs
- [ ] `README.md` - Update content list

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging Content

1. **Check content loading:**
```lua
print("[ContentDB] Loading factions...")
print("[ContentDB] Loaded " .. faction_count .. " factions")
print("[ContentDB] Loading missions...")
print("[ContentDB] Loaded " .. mission_count .. " missions")
```

2. **Debug mission generation:**
```lua
print("[MissionGen] Selected template: " .. template_id)
print("[MissionGen] Difficulty: " .. difficulty)
print("[MissionGen] Enemy count: " .. enemy_count)
```

3. **Trace event chains:**
```lua
print("[EventChain] Event triggered: " .. event_id)
print("[EventChain] Checking triggers for: " .. next_event_id)
print("[EventChain] Queuing chain: " .. chain_name)
```

---

## Notes

- Content balance is critical for replayability
- Event chains create strategic depth
- Mission variation prevents monotony
- New factions add unique gameplay
- Tech trees reward faction choice

---

## Blockers

None identified - all dependencies exist.

---

## Review Checklist

- [ ] All factions load without errors
- [ ] All missions generate correctly
- [ ] All events trigger properly
- [ ] Event chains work
- [ ] Campaign playable with new content
- [ ] Balance reasonable
- [ ] Lore integrated
- [ ] UI shows new content
- [ ] Tests passing
- [ ] Documentation complete

---

## Estimated Total Time

**5 + 8 + 10 + 9 + 6 + 7 + 6 + 6 + 8 = 65 hours (8-9 days)**
