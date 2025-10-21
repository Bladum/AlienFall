# Phase 2C: AI Systems Enhancement - Comprehensive Fixes

**Created:** October 21, 2025  
**Status:** TODO  
**Duration:** 10-15 hours  
**Priority:** HIGH  

---

## Executive Summary

AI systems are 70% aligned with wiki design. This phase implements missing features:
1. **Strategic Planning** - Better mission selection and resource allocation
2. **Unit Coordination** - Squad tactics, positioning, support roles
3. **Resource Awareness** - AI considers supply levels and research state
4. **Threat Assessment** - Already partially done in Phase 2A, but enhanced here
5. **Diplomatic AI** - Country relationship decisions

---

## Gap Analysis

### Gap #1: Strategic Planning

**Current Status:** Likely simplified
- ⚠️ AI may select missions randomly or by priority
- ⚠️ No resource impact analysis
- ❌ No multi-turn strategy planning
- ❌ No tech tree influence on decisions

**Wiki Requirement:**
```
Strategic AI:
- Evaluate missions by: reward, risk, relation impact
- Consider: current tech level, facility status, research
- Plan 3-6 months ahead for major decisions
- Prioritize: tech unlocks first, then difficult missions
- Adjust difficulty based on player performance
```

**Fix Required:**
1. ⚠️ Implement mission scoring system
2. ⚠️ Add resource impact analysis
3. ❌ Implement multi-turn planning (3-6 months)
4. ❌ Add tech-driven decision making
5. ❌ Implement difficulty scaling

---

### Gap #2: Unit Coordination & Squad Tactics

**Current Status:** Likely individual unit AI
- ⚠️ Each unit acts independently
- ❌ No squad coordination
- ❌ No role assignment (leader, medic, heavy, scout)
- ❌ No positioning tactics

**Wiki Requirement:**
```
Squad Tactics:
- Squad leader: Makes strategic decisions
- Heavy weapons: Cover team advance
- Medic: Supports and heals
- Scout: Flanks and explores
- Team formations: Wedge, line, diamond
- Covering fire coordination
```

**Fix Required:**
1. ⚠️ Implement squad leader role
2. ❌ Create role-based unit behaviors
3. ❌ Implement squad formations
4. ❌ Add covering fire mechanics
5. ❌ Coordinate movement between units

---

### Gap #3: Resource Awareness

**Current Status:** Likely not considered
- ❌ AI doesn't care about ammo/supplies
- ❌ No energy management
- ❌ No research awareness
- ❌ No budget consideration in decisions

**Wiki Requirement:**
```
Resource Awareness:
- Check ammo before aggressive action
- Conserve expensive ammunition
- Retreat if heavily damaged
- Consider research benefits before tech rush
- Avoid expensive operations if low budget
```

**Fix Required:**
1. ❌ Implement ammo checking
2. ❌ Add energy conservation
3. ❌ Add research state evaluation
4. ❌ Add budget consideration

---

### Gap #4: Threat Assessment Enhancements

**Current Status:** Basic threat calculation (Phase 2A)
- ⚠️ Basic threat score exists
- ⚠️ Missing: Positioning weight
- ⚠️ Missing: Range consideration
- ⚠️ Missing: Weapon type awareness

**Wiki Requirement:**
```
Enhanced Threat Assessment:
- Base damage potential (50% weight)
- Position advantage: flanking/high ground (30% weight)
- Range to target (10% weight)
- Weapon type vs armor (10% weight)
- Cumulative threat from multiple enemies
```

**Fix Required:**
1. ⚠️ Add positioning weight to threat
2. ⚠️ Add range consideration
3. ⚠️ Add weapon vs armor analysis
4. ⚠️ Implement cumulative threat

---

### Gap #5: Diplomatic AI

**Current Status:** Likely non-existent
- ❌ No country relationship decisions
- ❌ No faction strategy
- ❌ No demand handling
- ❌ No relationship change decisions

**Wiki Requirement:**
```
Diplomatic AI:
- Respond to player diplomacy
- Make trade/alliance offers
- Increase demands if relationship good
- Decrease funding if relationship bad
- React to player actions (base attacks, funding)
```

**Fix Required:**
1. ❌ Implement country decision logic
2. ❌ Add demand/offer system
3. ❌ Implement relationship response
4. ❌ Add faction strategy

---

## Implementation Plan

### Phase 2C.1: Strategic Planning (3-4 hours)

#### Step 1.1: Create Mission Scoring System
```lua
-- Strategic mission evaluation
local StrategicPlanner = {}

-- Scoring: 0-100 (higher = better)
function StrategicPlanner:scoreMission(mission, game_state, base)
  local score = 0
  local details = {}
  
  -- Reward value (0-40 points)
  local reward_score = math.min(mission.reward / 100, 40)
  score = score + reward_score
  details.reward = {score = reward_score, weight = 0.40}
  
  -- Risk assessment (0-30 points, inverted)
  local risk_modifier = 1.0
  if mission.difficulty > game_state.current_tech_level then
    risk_modifier = 0.5  -- High risk
  elseif mission.difficulty < game_state.current_tech_level - 1 then
    risk_modifier = 1.2  -- Easy (small bonus for morale)
  end
  local risk_score = (30 - (mission.difficulty * 3)) * risk_modifier
  score = score + math.max(0, risk_score)
  details.risk = {score = risk_score, weight = 0.30}
  
  -- Relation impact (0-20 points)
  local relation_mult = base:getRelationMultiplier(mission.requester_faction)
  local relation_score = relation_mult * 20
  score = score + relation_score
  details.relations = {score = relation_score, weight = 0.20}
  
  -- Strategic value (0-10 points)
  -- Missions that unlock new tech or open new areas worth more
  local strategic_bonus = 0
  if mission.unlocks_tech then
    strategic_bonus = 10
  elseif mission.opens_region then
    strategic_bonus = 7
  elseif mission.increases_influence then
    strategic_bonus = 5
  end
  score = score + strategic_bonus
  details.strategic = {score = strategic_bonus, weight = 0.10}
  
  -- Time pressure (multiplier)
  if mission.turns_until_deadline < 3 then
    score = score * 1.3  -- Urgent missions boosted
  end
  
  details.final_score = score
  details.recommendation = score > 70 and "CRITICAL" or 
                         score > 50 and "IMPORTANT" or
                         score > 30 and "MINOR" or
                         "TRIVIAL"
  
  return score, details
end

-- Rank available missions
function StrategicPlanner:rankMissions(missions, game_state, base)
  local ranked = {}
  
  for _, mission in ipairs(missions) do
    local score, details = self:scoreMission(mission, game_state, base)
    table.insert(ranked, {
      mission = mission,
      score = score,
      details = details
    })
  end
  
  -- Sort by score descending
  table.sort(ranked, function(a, b) return a.score > b.score end)
  
  return ranked
end

-- Get AI recommendation
function StrategicPlanner:getMissionRecommendation(ranked_missions)
  if #ranked_missions == 0 then
    return nil, "No available missions"
  end
  
  local top = ranked_missions[1]
  
  if top.score < 30 then
    return nil, "All missions too trivial - wait for better options"
  elseif top.score < 50 then
    return top.mission, "Limited options, consider this mission"
  else
    return top.mission, "Recommended mission: " .. top.mission.name
  end
end

return StrategicPlanner
```

**Tasks:**
- [ ] Create `strategic_planner.lua`
- [ ] Implement mission scoring (reward/risk/relations/strategic)
- [ ] Implement mission ranking
- [ ] Add recommendation system

#### Step 1.2: Add Resource Impact Analysis
```lua
-- Mission resource impact analysis
function StrategicPlanner:analyzeResourceImpact(mission, base)
  local impact = {
    ammo_cost = 0,
    personnel_loss_risk = 0,
    energy_drain = 0,
    recovery_time = 0,
    payoff_turns = 0  -- How many months to recoup cost
  }
  
  -- Estimate ammo consumption
  impact.ammo_cost = mission.difficulty * 500  -- Rough estimate
  
  -- Personnel loss risk
  impact.personnel_loss_risk = mission.difficulty * 0.1
  if impact.personnel_loss_risk > 0.5 then
    impact.personnel_loss_risk = 0.5
  end
  
  -- Energy drain for equipment
  impact.energy_drain = mission.duration_turns * 50
  
  -- Recovery time (days) after mission
  impact.recovery_time = mission.difficulty * 2
  
  -- Payoff calculation: How many months to recover cost
  impact.payoff_turns = math.ceil(impact.ammo_cost / (mission.reward / 4))
  
  -- Verdict: Should we do this mission?
  local current_budget = base:getCurrentBudget()
  if impact.ammo_cost > current_budget * 0.3 then
    impact.verdict = "EXPENSIVE - Risk budget deficit"
  elseif impact.personnel_loss_risk > 0.3 then
    impact.verdict = "RISKY - High casualty chance"
  elseif impact.payoff_turns > 4 then
    impact.verdict = "SLOW PAYOFF - Wait for better rewards"
  else
    impact.verdict = "ACCEPTABLE - Proceed with caution"
  end
  
  return impact
end
```

**Tasks:**
- [ ] Create resource impact analysis
- [ ] Calculate payoff period
- [ ] Generate verdict based on risk/reward

#### Step 1.3: Implement Multi-Turn Planning
```lua
-- Multi-turn strategic planning
function StrategicPlanner:planTurns(game_state, base, turns_ahead)
  local plan = {
    current_turn = game_state.current_turn,
    plan_horizon = turns_ahead,
    objectives = {},
    tech_targets = {},
    facility_goals = {},
    contingencies = {}
  }
  
  -- Analyze tech tree - what should we unlock?
  plan.tech_targets = self:identifyKeyTechs(game_state, base)
  
  -- Identify facility needs
  plan.facility_goals = self:identifyFacilityNeeds(base)
  
  -- Set primary objectives for next N turns
  for turn = 1, turns_ahead do
    local turn_obj = {
      turn = game_state.current_turn + turn,
      primary = nil,
      secondary = {},
      resources_available = self:estimateResources(base, turn)
    }
    
    -- Assign objectives based on plan
    if turn <= 2 and plan.tech_targets[1] then
      turn_obj.primary = "Research: " .. plan.tech_targets[1].name
    elseif plan.facility_goals[1] then
      turn_obj.primary = "Build: " .. plan.facility_goals[1].name
    else
      turn_obj.primary = "Explore and prepare"
    end
    
    table.insert(plan.objectives, turn_obj)
  end
  
  -- Plan contingencies
  plan.contingencies = {
    {condition = "Budget drops below 5000", action = "Reduce research spending"},
    {condition = "Personnel loss > 3", action = "Pause offensive ops"},
    {condition = "Key facility damaged", action = "Prioritize repair"}
  }
  
  return plan
end

-- Identify key techs to unlock
function StrategicPlanner:identifyKeyTechs(game_state, base)
  local tech_tree = game_state.tech_tree
  local targets = {}
  
  -- Find high-priority unlocked techs
  for _, tech in ipairs(tech_tree.available) do
    local score = tech.priority or 0
    
    -- Bonus for techs that unlock other techs
    if tech.unlocks_count > 2 then
      score = score + 50
    end
    
    -- Bonus for combat-related techs if facing tough enemies
    if game_state.enemy_power_level > 50 and tech.category == "combat" then
      score = score + 30
    end
    
    table.insert(targets, {name = tech.name, score = score, tech = tech})
  end
  
  table.sort(targets, function(a, b) return a.score > b.score end)
  
  -- Return top 3
  return {targets[1], targets[2], targets[3]}
end

-- Identify facility needs
function StrategicPlanner:identifyFacilityNeeds(base)
  local needs = {}
  
  -- Check for bottlenecks
  if base:countFacility("laboratory") < 2 then
    table.insert(needs, {name = "Laboratory", reason = "Research bottleneck"})
  end
  
  if base:countFacility("hangar") < base:countFacility("soldier") / 10 then
    table.insert(needs, {name = "Hangar", reason = "Not enough craft"})
  end
  
  if base:getTotalFacilityMaintenance() > base:getCurrentIncome() * 0.3 then
    table.insert(needs, {name = "Power Generator", reason = "Power cost too high"})
  end
  
  return needs
end
```

**Tasks:**
- [ ] Create multi-turn planning system
- [ ] Identify key techs to research
- [ ] Identify facility needs
- [ ] Generate 3-6 month plan

---

### Phase 2C.2: Unit Coordination (3-4 hours)

#### Step 2.1: Create Squad Leader Role
```lua
-- Squad leader coordination system
local SquadLeader = {}

-- Designate unit as squad leader
function SquadLeader:designateLeader(squad, unit)
  squad.leader = unit
  unit.is_leader = true
  unit.squad = squad
  
  print("[SquadLeader] " .. unit.name .. " designated leader")
end

-- Get squad formation center
function SquadLeader:getFormationCenter(squad)
  local avg_x, avg_y = 0, 0
  
  for _, unit in ipairs(squad.units) do
    avg_x = avg_x + unit.x
    avg_y = avg_y + unit.y
  end
  
  return avg_x / #squad.units, avg_y / #squad.units
end

-- Lead squad to objective
function SquadLeader:leadToObjective(squad, objective_x, objective_y)
  if not squad.leader then
    print("[ERROR] Squad has no leader!")
    return false
  end
  
  local leader = squad.leader
  
  -- Leader picks path
  leader:pathfindTo(objective_x, objective_y)
  
  -- Get leader's waypoints
  local path = leader:getPath()
  
  -- Subordinates follow with offset
  for i, unit in ipairs(squad.units) do
    if unit ~= leader then
      -- Calculate formation offset (diamond formation)
      local offset = self:getFormationOffset(i, #squad.units)
      
      -- Apply offset to leader's path
      local adjusted_path = self:offsetPath(path, offset.x, offset.y)
      
      unit:setPath(adjusted_path)
    end
  end
  
  squad.current_objective = {x = objective_x, y = objective_y}
  
  return true
end

-- Get formation offset for squad member
function SquadLeader:getFormationOffset(member_index, squad_size)
  -- Diamond formation:
  --     1
  --   2   3
  --     4
  
  local offsets = {
    {x = 0, y = -2},    -- Member 1: front
    {x = -2, y = 0},    -- Member 2: left
    {x = 2, y = 0},     -- Member 3: right
    {x = 0, y = 2}      -- Member 4: back
  }
  
  return offsets[member_index] or {x = 0, y = 0}
end

-- Offset a path by (dx, dy)
function SquadLeader:offsetPath(path, dx, dy)
  local adjusted = {}
  for _, waypoint in ipairs(path) do
    table.insert(adjusted, {
      x = waypoint.x + dx,
      y = waypoint.y + dy
    })
  end
  return adjusted
end

return SquadLeader
```

**Tasks:**
- [ ] Create `squad_leader.lua`
- [ ] Implement leader designation
- [ ] Implement formation control
- [ ] Implement formation offsets

#### Step 2.2: Create Role-Based Unit Behaviors
```lua
-- Role-based combat behaviors
local UnitRoles = {}

UnitRoles.ROLES = {
  LEADER = "leader",
  HEAVY = "heavy",
  MEDIC = "medic",
  SCOUT = "scout",
  SUPPORT = "support"
}

-- Assign role to unit based on equipment and stats
function UnitRoles:assignRole(unit)
  -- Analyze equipment
  local has_heavy_weapon = unit:hasWeapon("heavy")
  local has_medical_kit = unit:hasEquipment("medical_kit")
  local is_experienced = unit.experience_level >= 3
  local is_mobile = unit.speed > 10
  
  -- Decision logic
  if is_experienced then
    unit.role = self.ROLES.LEADER
  elseif has_heavy_weapon then
    unit.role = self.ROLES.HEAVY
  elseif has_medical_kit then
    unit.role = self.ROLES.MEDIC
  elseif is_mobile then
    unit.role = self.ROLES.SCOUT
  else
    unit.role = self.ROLES.SUPPORT
  end
  
  unit:setupRoleBehavior(unit.role)
end

-- Get behavior for role
function UnitRoles:getBehavior(role)
  return {
    leader = {
      priority = "Hold ground and coordinate",
      shoot_priority = "highest_threat",
      retreat_threshold = 0.4,  -- 40% HP
      special_action = "Rally allies"
    },
    heavy = {
      priority = "Support advance",
      shoot_priority = "crowd_control",
      retreat_threshold = 0.2,
      special_action = "Suppressive fire"
    },
    medic = {
      priority = "Keep squad alive",
      shoot_priority = "finish_wounded_enemies",
      retreat_threshold = 0.6,
      special_action = "Heal squad member"
    },
    scout = {
      priority = "Flank enemies",
      shoot_priority = "unaware_targets",
      retreat_threshold = 0.5,
      special_action = "Scout ahead"
    },
    support = {
      priority = "General combat",
      shoot_priority = "nearest_threat",
      retreat_threshold = 0.5,
      special_action = "Supply ammo"
    }
  }
end

-- Execute role-based action
function UnitRoles:executeRoleAction(unit, squad, situation)
  local behavior = self:getBehavior(unit.role)
  local action = nil
  
  if unit.role == self.ROLES.LEADER then
    action = self:leaderAction(unit, squad, situation)
  elseif unit.role == self.ROLES.HEAVY then
    action = self:heavyAction(unit, squad, situation)
  elseif unit.role == self.ROLES.MEDIC then
    action = self:medicAction(unit, squad, situation)
  elseif unit.role == self.ROLES.SCOUT then
    action = self:scoutAction(unit, squad, situation)
  else
    action = self:supportAction(unit, squad, situation)
  end
  
  return action
end

-- Leader action
function UnitRoles:leaderAction(unit, squad, situation)
  -- Prioritize healing if squad member injured
  for _, member in ipairs(squad.units) do
    if member.hp < member.max_hp * 0.3 then
      -- Order medic to help
      if squad.medic then
        return {type = "order", target = squad.medic, command = "heal", patient = member}
      end
    end
  end
  
  -- Otherwise, move to best position
  return {type = "move", x = situation.best_cover.x, y = situation.best_cover.y}
end

-- Heavy action (suppression)
function UnitRoles:heavyAction(unit, squad, situation)
  if situation.enemy_group then
    -- Use suppressive fire on enemy group
    return {
      type = "shoot",
      target = situation.enemy_group[1],
      weapon = unit:getWeapon("heavy"),
      suppress = true
    }
  end
end

-- Medic action (healing)
function UnitRoles:medicAction(unit, squad, situation)
  -- Find most injured unit
  local injured = nil
  local lowest_hp = 100
  
  for _, member in ipairs(squad.units) do
    if member.hp < member.max_hp and member.hp < lowest_hp then
      injured = member
      lowest_hp = member.hp
    end
  end
  
  if injured then
    return {type = "heal", target = injured}
  else
    return {type = "move", x = situation.squad_center.x, y = situation.squad_center.y}
  end
end

-- Scout action (flanking)
function UnitRoles:scoutAction(unit, squad, situation)
  -- Move to flank position
  if situation.flank_position then
    return {type = "move", x = situation.flank_position.x, y = situation.flank_position.y}
  end
end

-- Support action (general)
function UnitRoles:supportAction(unit, squad, situation)
  return {type = "shoot", target = situation.nearest_threat}
end

return UnitRoles
```

**Tasks:**
- [ ] Create `unit_roles.lua`
- [ ] Implement 5 role types
- [ ] Implement role assignment logic
- [ ] Implement role-based behaviors

#### Step 2.3: Implement Squad Formations
```lua
-- Squad formation system
local Formations = {}

Formations.TYPES = {
  DIAMOND = "diamond",
  LINE = "line",
  WEDGE = "wedge",
  COLUMN = "column"
}

-- Get formation positions
function Formations:getFormationPositions(squad_size, formation_type, center_x, center_y)
  local positions = {}
  
  if formation_type == self.TYPES.DIAMOND then
    positions = {
      {x = center_x, y = center_y - 2},           -- Front
      {x = center_x - 2, y = center_y},           -- Left
      {x = center_x + 2, y = center_y},           -- Right
      {x = center_x, y = center_y + 2},           -- Back
      {x = center_x - 1, y = center_y + 1},       -- Back-left
      {x = center_x + 1, y = center_y + 1}        -- Back-right
    }
  elseif formation_type == self.TYPES.LINE then
    for i = 1, squad_size do
      table.insert(positions, {
        x = center_x - (squad_size / 2) + i,
        y = center_y
      })
    end
  elseif formation_type == self.TYPES.WEDGE then
    positions = {
      {x = center_x, y = center_y - 2},           -- Point
      {x = center_x - 1, y = center_y - 1},       -- Upper-left
      {x = center_x + 1, y = center_y - 1},       -- Upper-right
      {x = center_x - 2, y = center_y},           -- Left
      {x = center_x + 2, y = center_y},           -- Right
      {x = center_x - 2, y = center_y + 1}        -- Lower-left
    }
  elseif formation_type == self.TYPES.COLUMN then
    for i = 1, squad_size do
      table.insert(positions, {
        x = center_x,
        y = center_y - (squad_size / 2) + i
      })
    end
  end
  
  return positions
end

-- Arrange squad in formation
function Formations:arrangeSquad(squad, formation_type, center_x, center_y)
  local positions = self:getFormationPositions(
    #squad.units, formation_type, center_x, center_y
  )
  
  -- Move each unit to formation position
  for i, unit in ipairs(squad.units) do
    if positions[i] then
      unit:moveToPosition(positions[i].x, positions[i].y)
    end
  end
  
  squad.formation = formation_type
end

-- Best formation for situation
function Formations:bestFormation(situation)
  if situation.fighting_enemies then
    if situation.enemy_count > 5 then
      return self.TYPES.LINE  -- Wide line for many enemies
    else
      return self.TYPES.WEDGE  -- Wedge for focused attack
    end
  elseif situation.in_corridor then
    return self.TYPES.COLUMN  -- Column in narrow space
  else
    return self.TYPES.DIAMOND  -- Flexible diamond
  end
end

return Formations
```

**Tasks:**
- [ ] Create `formations.lua`
- [ ] Implement 4 formation types
- [ ] Implement formation positioning
- [ ] Add formation selection logic

---

### Phase 2C.3: Resource Awareness (2-3 hours)

#### Step 3.1: Ammo & Energy Management
```lua
-- Resource awareness in combat
local ResourceAwareness = {}

-- Check ammo before action
function ResourceAwareness:checkAmmoBeforeShoot(unit, weapon)
  local ammo = unit:getAmmo(weapon.type)
  
  if ammo < weapon.cost_per_shot then
    return false, "Not enough ammo"
  end
  
  -- Check if we should conserve ammo
  local low_ammo_threshold = unit:getMaxAmmo(weapon.type) * 0.2
  if ammo < low_ammo_threshold then
    return true, "Low ammo - consider less fire"
  end
  
  return true, "Ammo OK"
end

-- Get ammo conservation score (0-100)
function ResourceAwareness:getAmmoConservationScore(unit, battle_state)
  local score = 0
  
  -- Check remaining turns estimate
  local estimated_turns = battle_state.turns_remaining or 5
  
  -- Check ammo sufficiency
  local avg_shots_per_turn = 3
  local ammo_needed = avg_shots_per_turn * estimated_turns * 50  -- 50 cost per shot
  local current_ammo = unit:getTotalAmmo()
  
  if current_ammo < ammo_needed then
    score = 50 + ((1 - (current_ammo / ammo_needed)) * 50)  -- 50-100
  else
    score = 10 + ((ammo_needed / current_ammo) * 40)  -- 10-50
  end
  
  return score
end

-- Should unit switch to melee?
function ResourceAwareness:shouldUseMelee(unit, target)
  local conservation_score = self:getAmmoConservationScore(unit, {})
  
  -- Use melee if:
  -- 1. Close to target AND
  -- 2. Ammo is running low
  
  local distance = unit:distanceTo(target)
  
  if distance < 2 and conservation_score > 60 then
    return true
  end
  
  return false
end

-- Check energy status
function ResourceAwareness:checkEnergy(unit, max_actions)
  local current_energy = unit.action_points or 100
  local energy_per_action = 20
  
  local actions_possible = math.floor(current_energy / energy_per_action)
  
  if actions_possible < 2 then
    return "CRITICAL", "Almost out of action points"
  elseif actions_possible < max_actions / 2 then
    return "LOW", "Energy running low"
  else
    return "OK", "Energy sufficient"
  end
end

-- Recommend rest/consolidation
function ResourceAwareness:recommendRest(unit, squad)
  local reasons = {}
  
  local ammo_score = self:getAmmoConservationScore(unit, {})
  if ammo_score > 70 then
    table.insert(reasons, "Low ammo - rest to recover")
  end
  
  local energy_status, _ = self:checkEnergy(unit, 5)
  if energy_status == "CRITICAL" then
    table.insert(reasons, "Energy critical - rest")
  end
  
  if unit.hp < unit.max_hp * 0.5 then
    table.insert(reasons, "Heavily wounded - rest")
  end
  
  if #reasons > 0 then
    return true, table.concat(reasons, ", ")
  end
  
  return false, "Resources sufficient"
end

return ResourceAwareness
```

**Tasks:**
- [ ] Create `resource_awareness.lua`
- [ ] Implement ammo checking
- [ ] Implement energy management
- [ ] Implement conservation decisions

#### Step 3.2: Research & Budget Awareness
```lua
-- Research and budget awareness
function ResourceAwareness:considerResearchImpact(base, decision)
  -- If considering expensive action, check budget
  if decision.cost then
    local current_budget = base:getCurrentBudget()
    local safety_margin = 5000  -- Keep 5000 reserve
    
    if decision.cost > current_budget - safety_margin then
      return false, "Would exceed budget safety margin"
    end
  end
  
  return true, "Budget OK"
end

-- Check if research state affects combat
function ResourceAwareness:getResearchBonus(unit, base, tech)
  -- If we've researched armor, units take less damage
  if base:hasResearched("advanced_armor") then
    unit.armor_bonus = unit.armor_bonus or 0 + 1
  end
  
  -- If we've researched better weapons
  if base:hasResearched("advanced_weapons") then
    unit.damage_bonus = unit.damage_bonus or 0 + 5
  end
  
  return unit.armor_bonus or 0, unit.damage_bonus or 0
end

-- Estimate tech impact on missions
function ResourceAwareness:techImpactOnMission(mission, base)
  local impact = {
    bonus_to_hit = 0,
    bonus_to_defense = 0,
    equipment_available = true
  }
  
  -- Advanced weapons tech
  if base:hasResearched("plasma_weapons") then
    impact.bonus_to_hit = impact.bonus_to_hit + 10
  end
  
  -- Advanced armor
  if base:hasResearched("combat_armor") then
    impact.bonus_to_defense = impact.bonus_to_defense + 10
  end
  
  -- Check if equipment is researched
  if mission.requires_tech then
    impact.equipment_available = base:hasResearched(mission.requires_tech)
  end
  
  return impact
end
```

**Tasks:**
- [ ] Add research awareness system
- [ ] Add budget awareness to decisions
- [ ] Calculate tech bonuses

---

### Phase 2C.4: Enhanced Threat Assessment (2-3 hours)

#### Step 4.1: Multi-Factor Threat Calculation
```lua
-- Enhanced threat assessment with multiple factors
local ThreatAssessment = {}

-- Calculate threat from enemy to target
function ThreatAssessment:calculateThreat(attacker, target, battlefield)
  local threat = 0
  
  -- Factor 1: Damage potential (50% weight)
  local damage_potential = self:estimateDamage(attacker, target)
  threat = threat + (damage_potential / 100) * 50
  
  -- Factor 2: Position advantage (30% weight)
  local position_advantage = self:calculatePositionAdvantage(attacker, target, battlefield)
  threat = threat + position_advantage * 30
  
  -- Factor 3: Range consideration (10% weight)
  local range_advantage = self:calculateRangeAdvantage(attacker, target)
  threat = threat + range_advantage * 10
  
  -- Factor 4: Weapon vs armor (10% weight)
  local weapon_advantage = self:calculateWeaponAdvantage(attacker, target)
  threat = threat + weapon_advantage * 10
  
  -- Apply urgency multiplier if target is in cover
  if target:isInCover() then
    threat = threat * 1.2  -- 20% more urgent to shoot
  end
  
  return math.min(threat, 100)  -- Cap at 100
end

-- Estimate damage from attack
function ThreatAssessment:estimateDamage(attacker, target)
  local weapon = attacker:getEquippedWeapon()
  if not weapon then return 0 end
  
  local base_damage = weapon.damage or 30
  
  -- Hit chance from attacker's accuracy
  local hit_chance = attacker.accuracy / 100
  
  -- Armor reduction
  local armor_reduction = (target.armor or 0) / 100
  
  -- Expected damage
  local expected_damage = base_damage * hit_chance * (1 - armor_reduction)
  
  -- Scale to 0-100
  return math.min((expected_damage / 50) * 100, 100)
end

-- Calculate position advantage (flanking, high ground)
function ThreatAssessment:calculatePositionAdvantage(attacker, target, battlefield)
  local advantage = 0
  
  -- Check if attacker is flanking target
  if self:isFlanking(attacker, target, battlefield) then
    advantage = advantage + 0.8
  end
  
  -- Check if attacker is on high ground
  if attacker.height > target.height then
    advantage = advantage + 0.5
  end
  
  -- Check if target is surrounded
  local nearby_enemies = self:countNearbyEnemies(target, 3, battlefield)
  if nearby_enemies > 1 then
    advantage = advantage + (nearby_enemies * 0.2)
  end
  
  return math.min(advantage, 1.0)
end

-- Check if attacker is flanking
function ThreatAssessment:isFlanking(attacker, target, battlefield)
  -- Simplified: flanking if not directly in front
  local angle = self:getRelativeAngle(target, attacker)
  
  -- Flanking if angle > 45 degrees but not > 180 degrees (behind)
  if angle > 45 and angle < 135 then
    return true
  end
  
  return false
end

-- Calculate range advantage
function ThreatAssessment:calculateRangeAdvantage(attacker, target)
  local distance = attacker:distanceTo(target)
  local weapon = attacker:getEquippedWeapon()
  
  if not weapon then return 0 end
  
  local optimal_range = weapon.optimal_range or 5
  local max_range = weapon.max_range or 15
  
  if distance > max_range then
    return 0  -- Out of range
  elseif distance <= optimal_range then
    return 1.0  -- Optimal range
  else
    -- Penalize for too long range
    local range_penalty = (distance - optimal_range) / (max_range - optimal_range)
    return 1.0 - (range_penalty * 0.5)
  end
end

-- Calculate weapon vs armor advantage
function ThreatAssessment:calculateWeaponAdvantage(attacker, target)
  local weapon = attacker:getEquippedWeapon()
  if not weapon then return 0 end
  
  local target_armor_type = target:getArmorType() or "light"
  
  -- Weapon effectiveness matrix
  local effectiveness = {
    plasma = {light = 1.0, medium = 0.8, heavy = 0.6},
    ballistic = {light = 0.8, medium = 1.0, heavy = 0.9},
    laser = {light = 0.9, medium = 0.9, heavy = 0.7},
    melee = {light = 1.0, medium = 0.7, heavy = 0.4}
  }
  
  local weapon_type = weapon.type or "ballistic"
  local eff = effectiveness[weapon_type] or {}
  
  return eff[target_armor_type] or 0.8
end

-- Count nearby enemies
function ThreatAssessment:countNearbyEnemies(unit, distance, battlefield)
  local count = 0
  for _, enemy in ipairs(battlefield.enemies) do
    if enemy ~= unit and unit:distanceTo(enemy) <= distance then
      count = count + 1
    end
  end
  return count
end

-- Get relative angle (for flanking detection)
function ThreatAssessment:getRelativeAngle(target, attacker)
  local dx = attacker.x - target.x
  local dy = attacker.y - target.y
  
  local angle = math.atan2(dy, dx) * (180 / math.pi)
  
  -- Normalize to 0-360
  if angle < 0 then angle = angle + 360 end
  
  -- Get angle relative to target's facing
  local relative = angle - (target.facing or 0)
  if relative < 0 then relative = relative + 360 end
  
  return relative
end

return ThreatAssessment
```

**Tasks:**
- [ ] Create enhanced threat calculation
- [ ] Implement 4 threat factors
- [ ] Add position advantage calculation
- [ ] Add flanking detection

---

### Phase 2C.5: Diplomatic AI (2-3 hours)

#### Step 5.1: Country Decision Logic
```lua
-- Diplomatic AI for country factions
local DiplomaticAI = {}

-- Make country decision
function DiplomaticAI:makeDecision(country, game_state)
  local decision = {
    type = nil,
    reason = nil,
    impact = nil
  }
  
  -- Evaluate player relations
  local relations_score = country.relations_with_player or 0
  
  -- Evaluate player performance
  local player_power = self:evaluatePlayerPower(game_state)
  
  -- Evaluate own status
  local country_status = self:evaluateCountryStatus(country, game_state)
  
  -- Decide: Offer, Demand, or Threaten
  if relations_score > 50 and country_status == "strong" then
    decision.type = "offer_alliance"
    decision.reason = "Relations good and we are strong"
    decision.impact = {relations = 10, funding = 200}
  elseif relations_score < -50 or player_power > country_status then
    decision.type = "increase_demands"
    decision.reason = "Relations poor or player too strong"
    decision.impact = {relations = -10, funding = -300}
  elseif country_status == "weak" then
    decision.type = "request_help"
    decision.reason = "We need player assistance"
    decision.impact = {relations = 5, mission_priority = "high"}
  else
    decision.type = "trade_offer"
    decision.reason = "Standard relations"
    decision.impact = {relations = 0}
  end
  
  return decision
end

-- Evaluate player power level
function DiplomaticAI:evaluatePlayerPower(game_state)
  local score = 0
  
  -- Base power from technology level
  score = score + (game_state.tech_level or 0) * 10
  
  -- Base power from resources
  score = score + math.floor((game_state.total_budget or 10000) / 100)
  
  -- Base power from military strength
  local total_units = 0
  for _, base in ipairs(game_state.bases) do
    total_units = total_units + #base.units
  end
  score = score + total_units * 5
  
  -- Base power from missions completed
  score = score + (game_state.missions_completed or 0) * 2
  
  return score
end

-- Evaluate country's own status
function DiplomaticAI:evaluateCountryStatus(country, game_state)
  local military_strength = country.military or 0
  local economy = country.economy or 0
  local cities = country.cities or 0
  
  local score = military_strength + (economy / 10) + (cities * 5)
  
  if score > 100 then
    return "strong"
  elseif score < 30 then
    return "weak"
  else
    return "stable"
  end
end

-- Handle player action (base attack, funding refusal, etc)
function DiplomaticAI:handlePlayerAction(country, action)
  local reaction = {
    type = nil,
    severity = 0,
    message = nil
  }
  
  if action.type == "base_attacked" then
    country.relations_with_player = country.relations_with_player - 50
    reaction.type = "increase_hostility"
    reaction.severity = 2
    reaction.message = country.name .. " is outraged!"
  elseif action.type == "refused_funding" then
    country.relations_with_player = country.relations_with_player - 20
    reaction.type = "increase_tension"
    reaction.severity = 1
    reaction.message = country.name .. " is disappointed."
  elseif action.type == "mission_completed" then
    country.relations_with_player = country.relations_with_player + 15
    reaction.type = "improve_relations"
    reaction.severity = -1
    reaction.message = country.name .. " is pleased."
  end
  
  return reaction
end

return DiplomaticAI
```

**Tasks:**
- [ ] Create `diplomatic_ai.lua`
- [ ] Implement country decision logic
- [ ] Implement player power evaluation
- [ ] Implement action response

---

## Testing Strategy

### Manual Testing Checklist

```
Strategic Planning:
[ ] Missions ranked by score correctly
[ ] High-reward missions scored higher
[ ] Easy missions get small bonus
[ ] Tech unlock missions prioritized
[ ] Multi-month plan generated (3-6 months)
[ ] Facility needs identified
[ ] Tech targets selected

Unit Coordination:
[ ] Squad leader designated
[ ] Squad follows leader in formation
[ ] Diamond formation working
[ ] Line formation working
[ ] Wedge formation working
[ ] Unit roles assigned correctly
[ ] Role behaviors executed

Resource Awareness:
[ ] Ammo checked before shot
[ ] Low ammo triggers conservation
[ ] Melee used when ammo low
[ ] Energy management working
[ ] Unit rests when damaged
[ ] Budget impacts decisions

Threat Assessment:
[ ] Threat calculation includes 4 factors
[ ] Flanking multiplier applied
[ ] High ground advantage shown
[ ] Weapon effectiveness correct
[ ] Range penalty calculated

Diplomatic AI:
[ ] Country makes decisions
[ ] Relations affect decisions
[ ] Player actions trigger reactions
[ ] Demands increase when relations bad
```

### Console Verification
```bash
Run command:
lovec "engine"

Watch console for:
- Strategic decisions logged
- Mission rankings printed
- Squad formation messages
- Resource checks logged
- Threat assessments calculated
- Diplomatic decisions made
- No error messages
```

---

## Success Criteria

Phase 2C is complete when:

✅ **Strategic Planning:**
- [ ] Mission scoring works (0-100 scale)
- [ ] Ranking prioritizes high-value missions
- [ ] 3-6 month plans generated
- [ ] Tech targets identified
- [ ] Facility needs identified

✅ **Unit Coordination:**
- [ ] Squad leader system working
- [ ] All 4 formations working
- [ ] Unit roles assigned
- [ ] Role behaviors executed
- [ ] Formations responsive

✅ **Resource Awareness:**
- [ ] Ammo management working
- [ ] Energy conservation implemented
- [ ] Budget impacts decisions
- [ ] Research bonuses applied

✅ **Threat Assessment:**
- [ ] 4-factor threat calc working
- [ ] All multipliers applied
- [ ] Accuracy vs armor considered
- [ ] Position advantage calculated

✅ **Diplomatic AI:**
- [ ] Country decisions made
- [ ] Relations impact decisions
- [ ] Player actions trigger responses
- [ ] Messages appropriate to situation

✅ **No Errors:**
- [ ] Love2D console error-free
- [ ] All calculations verified
- [ ] Units respond appropriately

---

## Time Estimate

- Step 1.1 (Mission scoring): 45 min
- Step 1.2 (Resource analysis): 30 min
- Step 1.3 (Multi-turn planning): 45 min
- Step 2.1 (Squad leaders): 45 min
- Step 2.2 (Role behaviors): 1 hour
- Step 2.3 (Formations): 1 hour
- Step 3.1 (Ammo/energy): 45 min
- Step 3.2 (Research/budget): 45 min
- Step 4.1 (Threat assessment): 1.5 hours
- Step 5.1 (Diplomatic AI): 1 hour
- Final (Testing & docs): 1.5 hours

**Total: 11-13 hours**

---

**Next:** Phase 3 will handle testing and validation across all Phase 2 implementations.
