# Interception Mechanics Clarification

> **Status**: Design Specification - HIGH-07
> **Last Updated**: October 31, 2025
> **Related Systems**: INTERCEPTION.md, GEOSCAPE.md, MISSION_ASSIGNMENT_INTEGRATION.md
> **Purpose**: Clarify interception mission assignment, prioritization, and integration with geoscape systems

## Overview

This specification clarifies the interception mechanics that were previously undefined or ambiguous. It focuses on how interception missions are assigned, prioritized, and integrated with the broader geoscape mission system.

**Key Clarifications:**
1. Interception mission assignment and prioritization
2. Interception impact on UFO behavior and campaign progression
3. Integration with geoscape mission system
4. Resource allocation conflicts between interception and ground missions

---

## 1. Interception Mission Assignment System

### Mission Generation Triggers

Interception missions are automatically generated when UFOs meet specific detection criteria:

```lua
function shouldGenerateInterceptionMission(ufo, radar_coverage)
    local detection_threshold = calculateDetectionThreshold(ufo, radar_coverage)
    local random_roll = math.random()

    return random_roll < detection_threshold
end

function calculateDetectionThreshold(ufo, radar_coverage)
    -- Base detection chance
    local base_chance = 0.3  -- 30% base chance

    -- Radar coverage modifier (0-100% coverage)
    local coverage_modifier = radar_coverage / 100

    -- UFO size modifier (larger = easier to detect)
    local size_modifier = ufo.detection_difficulty or 1.0

    -- Distance modifier (closer = easier to detect)
    local distance_to_base = calculateDistanceToNearestBase(ufo)
    local distance_modifier = math.max(0.1, 1.0 - (distance_to_base / 50))

    -- Final calculation
    local threshold = base_chance * coverage_modifier * size_modifier * distance_modifier

    return math.min(threshold, 0.95)  -- Cap at 95%
end
```

### Mission Priority Classification

Interception missions are classified by priority level affecting assignment urgency:

| Priority | Threat Level | Assignment Time | Resource Allocation |
|----------|-------------|----------------|-------------------|
| **Critical** | Battleship/Transport | Immediate (same turn) | All available craft |
| **High** | Fighter/Harvester | 1-2 turns | Primary interceptors |
| **Medium** | Scout | 2-4 turns | Available craft |
| **Low** | Damaged/Retreating | 4-8 turns | Surplus capacity |

```lua
function classifyInterceptionPriority(ufo)
    if ufo.type == "battleship" or ufo.type == "transport" then
        return "critical"
    elseif ufo.type == "fighter" or ufo.type == "harvester" then
        return "high"
    elseif ufo.type == "scout" then
        return "medium"
    else
        return "low"
    end
end
```

### Craft Assignment Algorithm

Interception missions use a specialized assignment algorithm prioritizing speed and interception capability:

```lua
function assignCraftsToInterception(mission, available_crafts)
    local assigned = {}
    local priority = mission.priority

    -- Sort craft by interception suitability
    table.sort(available_crafts, function(a, b)
        return calculateInterceptionScore(a, mission) > calculateInterceptionScore(b, mission)
    end)

    -- Assign based on priority
    if priority == "critical" then
        -- Assign all available intercept-capable craft
        for _, craft in ipairs(available_crafts) do
            if craft:canIntercept() then
                table.insert(assigned, craft)
            end
        end
    elseif priority == "high" then
        -- Assign 2-3 best craft
        local count = math.min(3, #available_crafts)
        for i = 1, count do
            if available_crafts[i]:canIntercept() then
                table.insert(assigned, available_crafts[i])
            end
        end
    else
        -- Assign 1-2 craft based on availability
        local count = math.min(2, #available_crafts)
        for i = 1, count do
            table.insert(assigned, available_crafts[i])
        end
    end

    return assigned
end

function calculateInterceptionScore(craft, mission)
    local score = 0

    -- Speed bonus (faster craft get priority)
    score = score + (craft.speed * 10)

    -- Weapon effectiveness vs UFO type
    score = score + calculateWeaponMatchScore(craft, mission.ufo)

    -- Fuel efficiency (craft with more fuel get priority)
    score = score + (craft.fuel / craft.max_fuel * 20)

    -- Distance penalty (closer craft get priority)
    local distance = calculateDistance(craft.location, mission.location)
    score = score - (distance * 2)

    -- Pilot experience bonus
    if craft.pilot then
        score = score + (craft.pilot.interception_experience * 5)
    end

    return score
end
```

---

## 2. Interception Impact on UFO Behavior

### UFO Response to Interception Attempts

UFOs modify their behavior based on interception threat level:

```lua
function updateUFOBehavior(ufo, interception_threat)
    if interception_threat == "none" then
        -- Normal behavior
        ufo.aggression = "normal"
        ufo.speed_modifier = 1.0
        ufo.evade_chance = 0.1

    elseif interception_threat == "low" then
        -- Slight caution
        ufo.aggression = "cautious"
        ufo.speed_modifier = 1.1  -- 10% faster
        ufo.evade_chance = 0.2

    elseif interception_threat == "medium" then
        -- Defensive posture
        ufo.aggression = "defensive"
        ufo.speed_modifier = 1.2  -- 20% faster
        ufo.evade_chance = 0.3
        ufo.may_retreat = true

    elseif interception_threat == "high" then
        -- Evasive maneuvers
        ufo.aggression = "evasive"
        ufo.speed_modifier = 1.4  -- 40% faster
        ufo.evade_chance = 0.5
        ufo.may_retreat = true
        ufo.may_call_reinforcements = true
    end
end
```

### Post-Interception UFO Behavior Modification

Failed interceptions cause UFOs to become more aggressive and evasive:

```lua
function processInterceptionResult(ufo, result)
    if result == "escaped" then
        -- UFO becomes more cautious and aggressive
        ufo.threat_level = ufo.threat_level + 1
        ufo.aggression = "aggressive"
        ufo.evade_chance = math.min(0.8, ufo.evade_chance + 0.2)

        -- May change mission type
        if ufo.mission_type == "scout" then
            ufo.mission_type = "raid"  -- Escalate to more aggressive mission
        end

    elseif result == "damaged" then
        -- UFO becomes more defensive
        ufo.health = ufo.health * 0.7  -- Take damage
        ufo.speed_modifier = ufo.speed_modifier * 0.8  -- Slower
        ufo.weapon_accuracy = ufo.weapon_accuracy * 0.9  -- Less accurate

        -- May retreat or call for help
        if math.random() < 0.6 then
            ufo.status = "retreating"
        end
    end
end
```

### Campaign Progression Impact

Interception success/failure affects global campaign state:

```lua
function updateCampaignFromInterception(result, ufo_type)
    local campaign = getCurrentCampaign()

    if result == "destroyed" then
        -- Positive impact
        campaign.alien_morale = math.max(0, campaign.alien_morale - 5)
        campaign.player_reputation = campaign.player_reputation + 2
        campaign.interception_success_rate = campaign.interception_success_rate + 0.05

        -- Technology gains
        if ufo_type == "battleship" then
            unlockResearch("advanced_plasma")
        elseif ufo_type == "scout" then
            unlockResearch("ufo_analysis")
        end

    elseif result == "escaped" then
        -- Negative impact
        campaign.alien_morale = campaign.alien_morale + 2
        campaign.player_reputation = math.max(0, campaign.player_reputation - 1)
        campaign.interception_success_rate = math.max(0, campaign.interception_success_rate - 0.03)

        -- Increased UFO activity
        increaseUFOSpawnRate(0.1)  -- 10% more UFOs
    end

    -- Update difficulty scaling
    campaign.interception_difficulty = calculateNewDifficulty(campaign)
end
```

---

## 3. Interception-Geoscape Integration

### Mission Queue Integration

Interception missions integrate with the geoscape mission queue:

```lua
function integrateInterceptionIntoMissionQueue(mission_queue, interception_mission)
    -- Find insertion point based on priority
    local insert_index = 1

    for i, existing_mission in ipairs(mission_queue) do
        if shouldInsertBefore(interception_mission, existing_mission) then
            insert_index = i
            break
        end
        insert_index = i + 1
    end

    -- Insert interception mission
    table.insert(mission_queue, insert_index, interception_mission)

    -- Update mission priorities
    updateMissionPriorities(mission_queue)
end

function shouldInsertBefore(interception, existing)
    local priority_weights = {
        critical = 4,
        high = 3,
        medium = 2,
        low = 1
    }

    local interception_weight = priority_weights[interception.priority] or 1
    local existing_weight = priority_weights[existing.priority] or 1

    return interception_weight > existing_weight
end
```

### Resource Allocation Conflicts

Interception missions compete with ground missions for craft resources:

```lua
function resolveResourceConflicts(missions, available_crafts)
    local assigned_crafts = {}
    local conflicts = {}

    -- Sort missions by priority
    table.sort(missions, function(a, b)
        return getMissionPriority(a) > getMissionPriority(b)
    end)

    -- Assign craft to highest priority missions first
    for _, mission in ipairs(missions) do
        local needed_crafts = calculateCraftRequirements(mission)
        local assigned = assignAvailableCrafts(mission, needed_crafts, available_crafts)

        if #assigned < needed_crafts then
            -- Conflict detected
            table.insert(conflicts, {
                mission = mission,
                needed = needed_crafts,
                assigned = #assigned,
                shortfall = needed_crafts - #assigned
            })
        end
    end

    return assigned_crafts, conflicts
end

function resolveConflicts(conflicts)
    for _, conflict in ipairs(conflicts) do
        if conflict.mission.type == "interception" then
            -- Try to delay ground mission
            delayGroundMission(conflict.mission)
        elseif conflict.mission.type == "ground" then
            -- Try to reassign craft from lower priority interception
            reassignFromLowerPriority(conflict.mission)
        end
    end
end
```

### Interception Mission Lifecycle

Interception missions follow a specific lifecycle integrated with geoscape:

```lua
interception_mission_states = {
    "detected",        -- UFO detected, mission created
    "assigned",        -- Craft assigned, en route
    "engaged",         -- Combat initiated
    "completed",       -- Combat resolved
    "processed"        -- Rewards distributed, cleanup done
}

function processInterceptionLifecycle(mission)
    while mission.state ~= "processed" do
        if mission.state == "detected" then
            assignCraftsToMission(mission)
            mission.state = "assigned"

        elseif mission.state == "assigned" then
            if craftsHaveReachedInterceptPoint(mission) then
                initiateCombat(mission)
                mission.state = "engaged"
            end

        elseif mission.state == "engaged" then
            if combatIsResolved(mission) then
                processCombatResults(mission)
                mission.state = "completed"
            end

        elseif mission.state == "completed" then
            distributeRewards(mission)
            updateCampaignState(mission)
            mission.state = "processed"
        end
    end
end
```

---

## 4. Interception Priority System

### Priority Calculation Factors

Interception priority is calculated using multiple factors:

```lua
function calculateInterceptionPriority(ufo, campaign_state)
    local priority_score = 0

    -- UFO type base priority
    local type_priorities = {
        battleship = 100,
        transport = 90,
        harvester = 80,
        fighter = 70,
        scout = 50
    }
    priority_score = priority_score + (type_priorities[ufo.type] or 50)

    -- Threat level modifier
    priority_score = priority_score + (ufo.threat_level * 10)

    -- Distance to base modifier (closer = higher priority)
    local distance = calculateDistanceToNearestBase(ufo)
    local distance_modifier = math.max(0, 50 - distance)
    priority_score = priority_score + distance_modifier

    -- Campaign escalation modifier
    local escalation_modifier = campaign_state.escalation_level * 5
    priority_score = priority_score + escalation_modifier

    -- Previous interception history
    if ufo.has_escaped_before then
        priority_score = priority_score + 20  -- Higher priority for repeat offenders
    end

    -- Time since last interception
    local time_since_last = getTimeSinceLastInterception()
    local time_modifier = math.min(30, time_since_last / 10)
    priority_score = priority_score + time_modifier

    return priority_score
end

function classifyPriorityFromScore(score)
    if score >= 150 then return "critical"
    elseif score >= 100 then return "high"
    elseif score >= 70 then return "medium"
    else return "low"
    end
end
```

### Priority-Based Resource Allocation

Higher priority interceptions get preferential resource allocation:

```lua
function allocateResourcesByPriority(missions, available_resources)
    -- Sort by priority
    table.sort(missions, function(a, b)
        return a.priority_score > b.priority_score
    end)

    local allocations = {}

    for _, mission in ipairs(missions) do
        local allocation = calculateResourceAllocation(mission, available_resources)
        allocations[mission.id] = allocation

        -- Reduce available resources
        available_resources = subtractAllocation(available_resources, allocation)
    end

    return allocations
end

function calculateResourceAllocation(mission, available_resources)
    local allocation = {}

    if mission.priority == "critical" then
        -- Allocate maximum available
        allocation.crafts = math.min(available_resources.crafts, 4)
        allocation.fuel = math.min(available_resources.fuel, 1000)
        allocation.pilots = math.min(available_resources.pilots, 8)

    elseif mission.priority == "high" then
        -- Allocate substantial resources
        allocation.crafts = math.min(available_resources.crafts, 3)
        allocation.fuel = math.min(available_resources.fuel, 750)
        allocation.pilots = math.min(available_resources.pilots, 6)

    elseif mission.priority == "medium" then
        -- Allocate moderate resources
        allocation.crafts = math.min(available_resources.crafts, 2)
        allocation.fuel = math.min(available_resources.fuel, 500)
        allocation.pilots = math.min(available_resources.pilots, 4)

    else -- low
        -- Allocate minimal resources
        allocation.crafts = math.min(available_resources.crafts, 1)
        allocation.fuel = math.min(available_resources.fuel, 250)
        allocation.pilots = math.min(available_resources.pilots, 2)
    end

    return allocation
end
```

### Priority Escalation Over Time

Interception priority increases if not addressed promptly:

```lua
function updateInterceptionPriorityOverTime(mission, elapsed_turns)
    if elapsed_turns > mission.initial_response_time then
        -- Priority escalation
        local escalation_factor = math.floor(elapsed_turns / 2)
        mission.priority_score = mission.priority_score + (escalation_factor * 10)

        -- Reclassify if needed
        local new_priority = classifyPriorityFromScore(mission.priority_score)
        if new_priority ~= mission.priority then
            mission.priority = new_priority
            notifyPriorityEscalation(mission)
        end
    end
end
```

---

## 5. Testing Scenarios

### Scenario 1: Priority Assignment
**Setup**: Multiple UFOs detected simultaneously
- Battleship at distance 10
- Fighter at distance 5
- Scout at distance 20

**Expected**: Battleship gets critical priority, fighter gets high, scout gets medium

**Verification**:
```lua
local battleship_priority = calculateInterceptionPriority(battleship_ufo, campaign)
local fighter_priority = calculateInterceptionPriority(fighter_ufo, campaign)
local scout_priority = calculateInterceptionPriority(scout_ufo, campaign)

assert(battleship_priority > fighter_priority)
assert(fighter_priority > scout_priority)
assert(classifyPriorityFromScore(battleship_priority) == "critical")
```

### Scenario 2: Resource Conflict Resolution
**Setup**: Critical interception and high-priority ground mission both require craft

**Expected**: Interception gets priority allocation, ground mission delayed

**Verification**:
```lua
local conflicts = resolveResourceConflicts({interception, ground_mission}, available_crafts)
assert(#conflicts == 1)  -- Ground mission has conflict
assert(conflicts[1].mission.type == "ground")
```

### Scenario 3: UFO Behavior Modification
**Setup**: UFO escapes interception attempt

**Expected**: UFO becomes more aggressive and evasive

**Verification**:
```lua
local original_aggression = ufo.aggression
local original_evade = ufo.evade_chance

processInterceptionResult(ufo, "escaped")

assert(ufo.aggression == "aggressive")
assert(ufo.evade_chance > original_evade)
assert(ufo.threat_level > original_threat)
```

### Scenario 4: Campaign Impact
**Setup**: Successful interception of high-value UFO

**Expected**: Positive campaign effects, technology unlocks

**Verification**:
```lua
local original_morale = campaign.alien_morale
local original_reputation = campaign.player_reputation

updateCampaignFromInterception("destroyed", "battleship")

assert(campaign.alien_morale < original_morale)
assert(campaign.player_reputation > original_reputation)
assert(isResearchUnlocked("advanced_plasma"))
```

---

## 6. Implementation Checklist

- [ ] Implement interception mission generation triggers
- [ ] Add priority classification system
- [ ] Create craft assignment algorithm for interception
- [ ] Implement UFO behavior modification system
- [ ] Add campaign progression impact calculations
- [ ] Integrate with geoscape mission queue
- [ ] Implement resource conflict resolution
- [ ] Add interception lifecycle management
- [ ] Create priority escalation over time
- [ ] Add comprehensive testing scenarios

---

## 7. Balance Parameters

| Parameter | Value | Range | Reasoning |
|-----------|-------|-------|-----------|
| Base Detection Chance | 0.3 | 0.1-0.5 | Balance between too many/few interceptions |
| Critical Priority Threshold | 150 | 100-200 | When to allocate maximum resources |
| UFO Speed Boost (Threat) | 1.4x | 1.1-1.6x | Make threatened UFOs appropriately faster |
| Campaign Morale Impact | ±5 | 1-10 | Meaningful but not overwhelming impact |
| Priority Escalation Rate | +10/2 turns | +5-20 | Gradual increase for unattended missions |
| Resource Allocation (Critical) | Max available | 50-100% | Critical missions get priority access |

---

## 8. Related Systems

- **INTERCEPTION.md**: Core combat mechanics and weapon systems
- **GEOSCAPE.md**: World map, provinces, and strategic movement
- **MISSIONS.md**: Mission generation and objective types
- **CRAFTS.md**: Craft capabilities and weapon systems
- **CAMPAIGN.md**: Campaign progression and difficulty scaling</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\HIGH_CLARIFY_INTERCEPTION_MECHANICS.md
