# Mission Design Template

**Tags:** #content-creation #mission-design #game-design #scripting  
**Last Updated:** September 30, 2025  
**Related:** [[README]], [[Map_Block_Authoring]], [[Enemy_Design_Process]]

---

## Mission Design Document Template

Use this template when creating new mission types for Alien Fall. Complete all sections before beginning implementation.

---

## MISSION OVERVIEW

### Mission ID
`mission_unique_id_here`

### Mission Name
"Display Name Here"

### Mission Type
- [ ] Terror Mission
- [ ] UFO Crash Site
- [ ] UFO Landing Site
- [ ] Base Defense
- [ ] Base Assault (Alien)
- [ ] Base Assault (Human)
- [ ] Supply Ship
- [ ] Council Mission
- [ ] Story Mission
- [ ] Training Mission

### Mission Summary
Brief 2-3 sentence description of mission premise and objectives.

### Design Pillars (Pick 2-3)
- [ ] **Tension** - Time pressure, difficult choices
- [ ] **Exploration** - Discovery, unknown threats
- [ ] **Combat** - Intense tactical firefights
- [ ] **Stealth** - Avoid detection, silent elimination
- [ ] **Survival** - Limited resources, attrition
- [ ] **Puzzle** - Environmental challenges, objectives
- [ ] **Story** - Narrative moments, character development

---

## MISSION PARAMETERS

### Difficulty Range
- Minimum Level: X
- Maximum Level: Y
- Difficulty Scaling: Linear / Exponential / Step

### Duration
- Expected Playtime: 15-45 minutes
- Turn Limit: 20-50 turns (if applicable)
- Timer: None / Soft / Hard

### Map Configuration
- Map Size: Small (20×20) / Medium (30×30) / Large (40×40)
- Block Types: Urban / Industrial / Rural / Alien / Mixed
- Block Count: 4-9 blocks
- Elevation: Single level / Multi-level
- Environment: Day / Night / Interior / Mixed

### Squad Parameters
- Squad Size: 4-8 soldiers
- Minimum Required: 4 soldiers
- Starting Position: Deploy zone / Fixed spawns / Vehicle
- Equipment Access: Full inventory / Limited loadout / Mission-specific

---

## VICTORY CONDITIONS

### Primary Objectives (Required)
1. **Objective Name**: Brief description
   - Success Criteria: What defines completion?
   - Failure Condition: What causes failure?
   - Time Limit: N turns or None
   - Rewards: Money, items, research unlocks

2. **Objective Name**: (if multiple primary objectives)

### Secondary Objectives (Optional)
1. **Objective Name**: Brief description
   - Bonus Reward: Extra money, items, reputation
   - Failure Impact: None (optional is truly optional)

### Failure Conditions
- [ ] All soldiers KIA
- [ ] Timer expires
- [ ] Civilians killed (threshold)
- [ ] Objective object destroyed
- [ ] VIP dies
- [ ] Other: _____________

---

## ENEMY COMPOSITION

### Enemy Budget
- Easy: 800-1200 points
- Normal: 1200-1800 points
- Hard: 1800-2500 points
- Impossible: 2500+ points

### Enemy Groups
**Group 1: Entry Forces** (Turns 1-5)
- Unit Type A: 3-5 units @ 100pts each = 300-500pts
- Unit Type B: 2-3 units @ 150pts each = 300-450pts
- Total: 600-950 points

**Group 2: Patrol** (Present from start)
- Unit Type C: 4-6 units @ 80pts each = 320-480pts
- Unit Type D: 1-2 units @ 200pts each = 200-400pts
- Total: 520-880 points

**Group 3: Reinforcements** (Trigger: Turn 10 or 50% enemies dead)
- Unit Type E: 2-4 units @ 150pts each = 300-600pts

**Boss Unit** (Optional)
- Boss Type: 1 unit @ 500pts

### Enemy Behaviors
- **Entry Forces**: Aggressive, push toward objectives
- **Patrol**: Defensive, guard key areas
- **Reinforcements**: Flanking, arrive at edges
- **Boss**: Unique AI behavior, special abilities

### Spawn Locations
- Fixed spawn points: Mark on map
- Dynamic spawns: Edge of map, specific connectors
- Boss spawn: Central location, dramatic reveal

---

## MAP & ENVIRONMENT

### Required Map Blocks
1. **Block Type**: Purpose (e.g., "Urban Street" - Player deployment)
2. **Block Type**: Purpose
3. **Block Type**: Purpose
(Add 4-9 total)

### Environmental Hazards
- [ ] Fire (spreading, damaging)
- [ ] Explosives (barrels, vehicles)
- [ ] Toxic gas
- [ ] Electrical hazards
- [ ] Collapsing structures
- [ ] Other: _____________

### Interactive Elements
- [ ] Doors (locked/unlocked)
- [ ] Terminals (hackable)
- [ ] Vehicles (drivable/destructible)
- [ ] Elevators/Lifts
- [ ] Environmental triggers (alarms, lights)

### Atmosphere
- Lighting: Bright / Dim / Dark / Mixed
- Weather: Clear / Rain / Fog / Storm
- Time of Day: Day / Dusk / Night / Dawn
- Audio: Ambient sounds, music cues

---

## NARRATIVE & CONTEXT

### Mission Briefing
```
Full mission briefing text here. 2-4 paragraphs.

Explain situation, stakes, and objectives in narrative form.
This is what the player reads before deploying.

Set the tone and build tension.
```

### In-Mission Events
**Turn 3:** Event description and scripting notes
**Turn 8:** Event description and scripting notes
**On Objective Complete:** Event description
**On Enemy Boss Dies:** Event description

### Mission Debrief (Success)
```
Success debrief text. 1-2 paragraphs.

Celebrate victory, explain consequences, tease future missions.
```

### Mission Debrief (Failure)
```
Failure debrief text. 1-2 paragraphs.

Explain consequences, maintain narrative continuity.
```

---

## REWARDS & CONSEQUENCES

### Success Rewards
- **Money**: $X,XXX
- **Items**: List specific items and quantities
- **Research Unlocks**: Technology IDs unlocked
- **Story Progress**: Which story flags are set
- **Reputation**: +X with faction/council
- **Special**: Unique rewards (e.g., new soldier, base location)

### Failure Consequences
- **Panic Increase**: +X% in region
- **Funding Loss**: -$X,XXX monthly
- **Story Impact**: Which story flags are set
- **Reputation**: -X with faction/council
- **Lost Opportunity**: What becomes unavailable

### Partial Success
If some objectives complete but others fail:
- **Reduced Rewards**: 50% money, some items
- **Mixed Consequences**: Some panic increase, partial funding loss

---

## MISSION SCRIPTING

### Initialization Script
```lua
-- Mission: mission_unique_id_here
-- Phase: Initialization

function Mission:init(params)
    -- Set up mission parameters
    self.turn_limit = 30
    self.objective_status = {
        primary_1 = false,
        primary_2 = false,
        secondary_1 = false
    }
    
    -- Spawn enemies
    self:spawnEnemyGroup("entry_forces", {
        {type = "sectoid", count = 5},
        {type = "floater", count = 3}
    })
    
    -- Set up objectives
    self:createObjective({
        id = "rescue_civilians",
        type = "rescue",
        targets = self:getCiviliansInZone("extraction_zone"),
        required = 6
    })
    
    -- Register event listeners
    self:onTurn(10, self.spawnReinforcements)
    self:onUnitDeath("boss", self.onBossDeath)
end
```

### Event Scripts
```lua
-- Reinforcement spawn (Turn 10)
function Mission:spawnReinforcements()
    if self.turn_count >= 10 then
        self:spawnEnemyGroup("reinforcements", {
            {type = "muton", count = 2},
            {type = "chryssalid", count = 4}
        }, "north_edge")
        
        self:showMessage("Enemy reinforcements detected!")
    end
end

-- Boss death event
function Mission:onBossDeath()
    self:showMessage("The alien commander has fallen!")
    self:completeObjective("kill_boss")
    self:unlockResearch("alien_commander_corpse")
end
```

### Victory/Defeat Checks
```lua
-- Check victory conditions
function Mission:checkVictory()
    local all_primary_complete = true
    for obj_id, status in pairs(self.objective_status) do
        if obj_id:starts_with("primary_") and not status then
            all_primary_complete = false
        end
    end
    
    if all_primary_complete then
        self:missionSuccess()
    end
end

-- Check defeat conditions
function Mission:checkDefeat()
    if self:getAllySoldiersAlive() == 0 then
        self:missionFailure("All soldiers KIA")
    elseif self.turn_count > self.turn_limit then
        self:missionFailure("Time expired")
    elseif self:getCiviliansAlive() < 3 then
        self:missionFailure("Too many civilian casualties")
    end
end
```

---

## BALANCE CONSIDERATIONS

### Difficulty Curve
- **Early Game (Levels 1-3)**: Tutorial mission, forgiving
- **Mid Game (Levels 4-6)**: Standard challenge
- **Late Game (Levels 7-9)**: High difficulty, veteran players
- **End Game (Level 10+)**: Maximum challenge

### Risk vs Reward
- Higher difficulty = Better rewards
- Optional objectives = Bonus rewards
- Time pressure = Efficiency bonus
- Stealth bonus = Reduced combat

### Player Skill Requirements
- [ ] Basic movement and shooting
- [ ] Cover usage and positioning
- [ ] Flanking tactics
- [ ] Overwatch and reaction fire
- [ ] Grenade usage
- [ ] Special abilities (psi, tech)
- [ ] Team coordination
- [ ] Resource management
- [ ] Time management

### Expected Player Loadout
- Armor Tier: Basic / Advanced / Elite
- Weapon Tier: Conventional / Laser / Plasma
- Special Equipment: Grenades, medkits, scanners
- Abilities: Rank 1-3 / Rank 4-6 / Rank 7+

---

## TESTING CHECKLIST

### Pre-Implementation
- [ ] Design document reviewed by lead designer
- [ ] Narrative approved by writer
- [ ] Technical feasibility confirmed
- [ ] Assets identified (existing or need creation)
- [ ] Enemy composition balanced
- [ ] Rewards appropriate for difficulty

### Implementation
- [ ] Mission data file created (TOML)
- [ ] Scripts implemented (Lua)
- [ ] Map blocks selected/created
- [ ] Spawn points placed
- [ ] Objectives configured
- [ ] Events triggered correctly

### Testing
- [ ] Mission loads without errors
- [ ] All objectives completable
- [ ] Victory conditions work
- [ ] Defeat conditions work
- [ ] Enemy AI behaves correctly
- [ ] Rewards granted properly
- [ ] Performance acceptable (60 FPS)
- [ ] No game-breaking bugs

### Balance Testing
- [ ] Tested on Easy difficulty (pass rate ~80%)
- [ ] Tested on Normal difficulty (pass rate ~60%)
- [ ] Tested on Hard difficulty (pass rate ~40%)
- [ ] Tested on Impossible difficulty (pass rate ~20%)
- [ ] Average completion time appropriate
- [ ] Player feedback gathered

### Final Review
- [ ] Mission is fun and engaging
- [ ] Difficulty appropriate for level range
- [ ] Narrative flows well
- [ ] Rewards feel satisfying
- [ ] No exploits or cheese strategies
- [ ] Documentation updated
- [ ] Approved for release

---

## EXAMPLE MISSION: "Urban Terror"

### Mission Overview
**ID**: `terror_urban_01`  
**Name**: "City Under Siege"  
**Type**: Terror Mission  
**Summary**: Aliens are terrorizing civilians in downtown. Eliminate all hostiles and save as many civilians as possible.

### Parameters
- **Difficulty**: 2-5
- **Duration**: 25-35 minutes, 30 turn soft limit
- **Map**: Urban, 30×30, multiple blocks (street, office, parking lot, rooftop)
- **Squad**: 6-8 soldiers, full loadout

### Victory Conditions
**Primary:**
1. Eliminate all alien units
2. Save at least 6 of 10 civilians

**Secondary:**
1. No soldier casualties (bonus: +$5,000)

### Enemy Composition (Normal)
- **Sectoids**: 6 units (600pts) - Patrol, psi abilities
- **Floaters**: 4 units (600pts) - Aggressive, vertical mobility
- **Chryssalids**: 3 units (600pts) - Ambush predators
- **Boss - Sectoid Commander**: 1 unit (400pts) - Psi powers, support
- **Total**: 2,200 points

### Rewards
- **Success**: $15,000 + alien corpses + Sectoid Commander research unlock
- **Failure**: +10% panic in region, -$5,000 monthly funding

---

## MISSION CATALOG

Track all mission types in the game:

| Mission ID | Name | Type | Level | Status |
|-----------|------|------|-------|--------|
| tutorial_01 | First Contact | Training | 1 | Complete |
| terror_urban_01 | City Under Siege | Terror | 2-5 | Complete |
| ufo_crash_small_01 | Scout Crash | UFO Crash | 1-3 | Complete |
| base_defense_01 | Base Under Siege | Base Defense | 3-6 | In Progress |
| ... | ... | ... | ... | ... |

---

## Related Documentation

- [[README]] - Content pipeline overview
- [[Map_Block_Authoring]] - Creating maps for missions
- [[Enemy_Design_Process]] - Designing enemy units
- [[../../battlescape/README]] - Battlescape system
- [[../../geoscape/Missions]] - Mission generation system
- [[../../../examples/lua/mission_script]] - Complete mission script example

---

**Document Status:** Complete  
**Review Date:** October 7, 2025  
**Owner:** Lead Game Designer
