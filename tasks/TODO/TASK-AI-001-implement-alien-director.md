# Task: Implement Alien Director (Strategic AI)

**Status:** TODO  
**Priority:** HIGH  
**Created:** January XX, 2026  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement the Alien Director system - a strategic AI that manages campaign pressure, alien activity, and adaptive difficulty. Creates dynamic, responsive alien opposition that adjusts to player success/failure, making each campaign unique and challenging.

---

## Purpose

The Alien Director is the "AI Dungeon Master" that orchestrates alien activity across the Geoscape. It monitors player performance, adjusts threat levels, coordinates faction activities, and creates dramatic pacing. This system is critical for replayability and challenge.

**Current State**: No strategic AI director exists  
**After This Task**: Complete adaptive AI system managing alien activity

---

## Requirements

### Functional Requirements
- [ ] Campaign pressure system (threat level increases over time)
- [ ] Adaptive difficulty (harder if player succeeding, easier if struggling)
- [ ] Faction coordination (multiple alien factions work together)
- [ ] UFO activity generation (patrols, terror missions, infiltration)
- [ ] Resource investment (aliens build bases, research tech)
- [ ] Dynamic event generation (missions, terror attacks, infiltration)
- [ ] Performance tracking (player win/loss rate affects AI)

### Technical Requirements
- [ ] Create engine/ai/strategic/alien_director.lua
- [ ] Create engine/ai/strategic/threat_manager.lua
- [ ] Create engine/ai/strategic/faction_coordinator.lua
- [ ] Create mods/core/ai/alien_director_config.toml
- [ ] Integration with Geoscape
- [ ] Integration with mission generation
- [ ] Integration with faction system

### Acceptance Criteria
- [ ] Threat level increases over campaign
- [ ] AI adjusts to player performance
- [ ] Multiple factions coordinate attacks
- [ ] UFO activity feels organic
- [ ] Missions scale appropriately
- [ ] Documentation complete
- [ ] Tests verify AI behavior

---

## Plan

### Step 1: Create Threat Manager
**Description:** System for tracking and adjusting campaign threat level  
**Files to create:**
- `engine/ai/strategic/threat_manager.lua`

**Key functions**:
```lua
-- Update threat level based on time and player performance
function ThreatManager:updateThreatLevel(delta_time)
    -- Base threat increases over time
    self.threat_level = self.threat_level + (delta_time * self.threat_increase_rate)
    
    -- Adjust based on player performance
    if self.player_win_rate > 0.8 then
        self.threat_increase_rate = self.threat_increase_rate * 1.2  -- Increase pressure
    elseif self.player_win_rate < 0.4 then
        self.threat_increase_rate = self.threat_increase_rate * 0.8  -- Decrease pressure
    end
    
    -- Cap threat level per phase
    local phase_cap = self:getPhaseThrea tCap()
    self.threat_level = math.min(self.threat_level, phase_cap)
end

-- Get current threat level (0.0 to 1.0)
function ThreatManager:getThreatLevel()
    return self.threat_level
end

-- Track player performance
function ThreatManager:recordMissionOutcome(mission_type, success)
    -- Update win/loss statistics
    -- Adjust threat accordingly
end
```

**Estimated time:** 6 hours

### Step 2: Create Faction Coordinator
**Description:** System for coordinating multiple faction activities  
**Files to create:**
- `engine/ai/strategic/faction_coordinator.lua`

**Key functions**:
```lua
-- Coordinate faction activities based on threat level
function FactionCoordinator:coordinateFactions(threat_level)
    -- Determine which factions are active
    local active_factions = self:getActiveFactions()
    
    -- Allocate resources to factions
    for _, faction in ipairs(active_factions) do
        local resource_allocation = threat_level * faction.resource_weight
        self:allocateResources(faction, resource_allocation)
    end
    
    -- Plan joint operations (e.g., Sectoids + Mutons attack same region)
    self:planJointOperations(active_factions, threat_level)
end

-- Plan joint faction operations
function FactionCoordinator:planJointOperations(factions, threat_level)
    -- Higher threat = more coordination
    if threat_level > 0.6 then
        -- Schedule multi-faction terror missions
        -- Coordinate simultaneous UFO waves
        -- Plan combined base assaults
    end
end
```

**Estimated time:** 5 hours

### Step 3: Create Alien Director Core
**Description:** Main AI director orchestrating all strategic alien activity  
**Files to create:**
- `engine/ai/strategic/alien_director.lua`

**Key functions**:
```lua
-- Main update loop for Alien Director
function AlienDirector:update(delta_time)
    -- Update threat level
    self.threat_manager:updateThreatLevel(delta_time)
    
    -- Coordinate factions
    local threat_level = self.threat_manager:getThreatLevel()
    self.faction_coordinator:coordinateFactions(threat_level)
    
    -- Generate alien activity
    self:generateUFOActivity(threat_level)
    self:generateTerrorMissions(threat_level)
    self:planAlienBases(threat_level)
    self:manageInfiltration(threat_level)
end

-- Generate UFO activity based on threat
function AlienDirector:generateUFOActivity(threat_level)
    -- More UFOs at higher threat
    local ufo_count = math.floor(threat_level * 10)
    
    -- Vary UFO types by threat level
    if threat_level < 0.3 then
        -- Scout UFOs
    elseif threat_level < 0.6 then
        -- Medium UFOs (Harvester, Abductor)
    else
        -- Large UFOs (Terror Ship, Battleship)
    end
end

-- Generate terror missions
function AlienDirector:generateTerrorMissions(threat_level)
    -- Higher threat = more terror missions
    -- Target countries with low panic
    -- Use phase-appropriate factions
end

-- Plan alien base construction
function AlienDirector:planAlienBases(threat_level)
    -- Aliens build bases at higher threat levels
    -- Bases generate ongoing missions
    -- Bases must be discovered and destroyed by player
end

-- Manage country infiltration
function AlienDirector:manageInfiltration(threat_level)
    -- Aliens infiltrate countries to gain funding
    -- Higher infiltration = country withdrawal risk
    -- Player must detect and counter infiltration
end
```

**Estimated time:** 8 hours

### Step 4: Create Configuration File
**Description:** TOML config for tuning Alien Director behavior  
**Files to create:**
- `mods/core/ai/alien_director_config.toml`

**Content**:
```toml
[threat_system]
base_threat_increase_rate = 0.01  # Threat increase per day
threat_cap_phase0 = 0.3            # Max threat in Phase 0
threat_cap_phase1 = 0.6            # Max threat in Phase 1
threat_cap_phase2 = 0.8            # Max threat in Phase 2
threat_cap_phase3 = 1.0            # Max threat in Phase 3

[adaptive_difficulty]
performance_window = 10            # Number of missions to track
high_performance_threshold = 0.8   # Win rate considered "high"
low_performance_threshold = 0.4    # Win rate considered "low"
pressure_increase_multiplier = 1.2 # Increase rate if player winning
pressure_decrease_multiplier = 0.8 # Decrease rate if player struggling

[ufo_generation]
base_ufo_rate = 2                  # UFOs per month at 0.5 threat
ufo_rate_multiplier = 2.0          # Multiply by threat level
scout_weight_phase0 = 1.0
scout_weight_phase1 = 0.6
medium_weight_phase1 = 0.3
large_weight_phase1 = 0.1
# ... (more UFO weights per phase)

[terror_missions]
base_terror_rate = 1               # Terror missions per month at 0.5 threat
terror_rate_multiplier = 3.0       # Multiply by threat level
target_low_panic_countries = true  # Prioritize countries with low panic

[alien_bases]
threat_threshold_first_base = 0.4  # Threat level to build first base
base_construction_time_days = 30   # Days to build a base
max_bases_phase1 = 2
max_bases_phase2 = 4
max_bases_phase3 = 6

[infiltration]
infiltration_rate = 0.05           # Infiltration increase per month
infiltration_detection_difficulty = 0.6  # Chance to detect infiltration
infiltration_withdrawal_threshold = 0.8  # Country withdraws at this level
```

**Estimated time:** 3 hours

### Step 5: Integration with Geoscape
**Description:** Hook Alien Director into Geoscape time system  
**Files to modify:**
- `engine/geoscape/geoscape.lua`

**Integration**:
- Call AlienDirector:update() during time advance
- Display alien activity on Geoscape
- Handle UFO spawning and movement
- Trigger terror missions
- Show alien base markers (if detected)

**Estimated time:** 4 hours

### Step 6: Integration with Mission Generation
**Description:** Connect Alien Director to mission system  
**Files to modify:**
- Mission generation system

**Integration**:
- Director requests mission generation
- Mission difficulty scales with threat level
- Faction selection based on phase
- Resource allocation affects enemy count/quality

**Estimated time:** 3 hours

### Step 7: Documentation
**Description:** Document Alien Director system and tuning  
**Files to create:**
- `docs/ai/alien_director.md`
- `docs/ai/threat_system.md`
- `docs/modding/alien_director_tuning.md`

**Estimated time:** 3 hours

### Step 8: Testing
**Description:** Unit tests and integration tests  
**Test cases:**
- Threat level increases over time
- Adaptive difficulty adjusts to player performance
- Factions coordinate attacks
- UFO generation scales with threat
- Terror missions trigger appropriately

**Files to create:**
- `tests/ai/test_alien_director.lua`
- `tests/ai/test_threat_manager.lua`
- `tests/integration/test_strategic_ai.lua`

**Estimated time:** 3 hours

---

## Implementation Details

### Alien Director Architecture
```
Alien Director
├── Threat Manager - Tracks campaign pressure
├── Faction Coordinator - Manages faction activities
├── Activity Generator - Creates UFOs, missions, events
└── Adaptive Difficulty - Adjusts to player performance
```

### Threat Level Progression
- **Phase 0 (0.0-0.3)**: Low threat, investigation missions
- **Phase 1 (0.3-0.6)**: Medium threat, UFO combat, terror missions
- **Phase 2 (0.6-0.8)**: High threat, two-front war, alien bases
- **Phase 3 (0.8-1.0)**: Maximum threat, coordinated assaults, endgame

### Adaptive Difficulty
- **Player Winning (>80%)**: Increase pressure faster, spawn harder enemies
- **Player Balanced (40-80%)**: Normal progression
- **Player Struggling (<40%)**: Decrease pressure, give recovery time

### Dependencies
- engine/geoscape/geoscape.lua
- engine/lore/campaign/phase_manager.lua (from TASK-LORE-001)
- engine/lore/factions/faction_system.lua (from TASK-LORE-002)
- Mission generation system

---

## Testing Strategy

### Unit Tests
- Test 1: Threat level calculation
- Test 2: Adaptive difficulty adjustment
- Test 3: Faction resource allocation
- Test 4: UFO generation rates

### Integration Tests
- Test 1: Complete campaign with AI director active
- Test 2: Verify threat increases over time
- Test 3: Verify AI adjusts to player success/failure
- Test 4: Verify faction coordination
- Test 5: Verify mission difficulty scaling

### Manual Testing
1. Run campaign from Phase 0
2. Win missions consistently
3. Verify AI increases pressure
4. Lose missions consistently
5. Verify AI decreases pressure
6. Check UFO activity scales with threat
7. Verify terror missions trigger
8. Check faction coordination in Phase 2-3

---

## Documentation Updates

- [x] `docs/ai/alien_director.md`
- [x] `docs/ai/threat_system.md`
- [x] `docs/modding/alien_director_tuning.md`
- [ ] `wiki/API.md` - Add AlienDirector API
- [ ] `wiki/FAQ.md` - Add AI director explanation

---

## Review Checklist

- [ ] Threat system works correctly
- [ ] Adaptive difficulty functional
- [ ] Faction coordination implemented
- [ ] UFO generation scales properly
- [ ] Terror missions trigger appropriately
- [ ] Documentation complete
- [ ] Tests passing
