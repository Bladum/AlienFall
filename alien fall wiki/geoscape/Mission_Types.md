# Mission Types

## Table of Contents
- [Overview](#overview)
- [Mission Catalog](#mission-catalog)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Mission Types catalog defines all tactical engagement scenarios in Alien Fall including UFO crash sites, terror attacks, base defense, infiltration operations, and VIP extraction missions, each with unique objectives, map generation rules, enemy compositions, and reward structures that create diverse tactical challenges requiring different strategic approaches and equipment loadouts.  
**Purpose:** Complete reference for all mission types including objectives, enemy composition, rewards, and consequences.

---

## Overview

Missions are the core gameplay loop of Alien Fall, generated dynamically based on alien activity and strategic priorities. Each mission type has distinct objectives, enemy compositions, time pressures, and rewards/consequences.

### Mission Categories

1. **UFO Missions** - Crash sites and landing sites
2. **Terror Missions** - Alien attacks on civilian centers
3. **Infiltration Missions** - Covert alien operations
4. **Base Missions** - Alien and XCOM base assaults
5. **Special Missions** - Story-critical and unique encounters

---

## Mission Type Summary

| Mission Type | Duration | Difficulty | Frequency | Expiration | Failure Penalty |
|--------------|----------|------------|-----------|------------|-----------------|
| UFO Crash Site | 3-5 hours | Low-Medium | Very High | 24 hours | Minor |
| UFO Landing Site | 2-4 hours | Medium | High | 8 hours | Moderate |
| Terror Mission | 1-3 hours | High | Medium | 2 hours | Severe |
| Abduction | 2-4 hours | Medium | High | 12 hours | Moderate |
| Alien Base | 4-6 hours | Very High | Rare | None | Critical |
| XCOM Base Defense | 2-4 hours | High | Rare | None | Catastrophic |
| Council Mission | 2-3 hours | Varies | Low | 6 hours | Severe |
| Supply Ship | 3-5 hours | High | Low | 12 hours | Minor |
| Battleship | 5-7 hours | Very High | Very Rare | 24 hours | Major |
| Final Mission | 6-10 hours | Extreme | Once | None | Game Over |

---

## UFO Missions

### UFO Crash Site

**Trigger:** UFO shot down by interception  
**Objective:** Secure crash site, eliminate survivors, recover technology  
**Map Size:** 40x40 to 60x60 tiles (varies by UFO size)  
**Time Limit:** None (tactical)  
**Expiration:** 24 hours (site deteriorates)

#### Enemy Composition

```lua
MissionType_UFOCrash = {
    type = "ufo_crash",
    enemyCount = function(ufoSize, difficulty)
        local baseCount = {
            small = {min = 4, max = 8},
            medium = {min = 8, max = 14},
            large = {min = 12, max = 20},
            very_large = {min = 16, max = 28}
        }
        
        local count = baseCount[ufoSize]
        local multiplier = 1 + (difficulty * 0.2) -- +20% per difficulty level
        
        return {
            min = math.floor(count.min * multiplier),
            max = math.floor(count.max * multiplier)
        }
    end,
    
    -- Survivors based on damage taken during interception
    survivalRate = function(damagePercent)
        return math.max(0.3, 1 - (damagePercent / 100)) -- 30-100% survive
    end,
    
    -- Wounded aliens more common at crash sites
    woundedRate = 0.4, -- 40% of survivors wounded
}

function MissionType_UFOCrash:generateEnemies(ufo, difficulty)
    local totalCount = self.enemyCount(ufo.size, difficulty)
    local survivors = math.floor(totalCount.max * self.survivalRate(ufo.damage))
    local wounded = math.floor(survivors * self.woundedRate)
    
    local enemies = {}
    
    -- Generate enemy composition based on UFO mission type
    for i = 1, survivors do
        local enemy = self:selectEnemyType(ufo.mission, difficulty)
        
        -- Some are wounded
        if i <= wounded then
            enemy.hp = math.random(enemy.maxHP * 0.3, enemy.maxHP * 0.7)
        end
        
        table.insert(enemies, enemy)
    end
    
    return enemies
end
```

#### Map Generation

- **Terrain:** Based on province biome where UFO crashed
- **UFO Placement:** Center of map, varies by UFO type
- **Enemy Spawn:** Inside and around UFO
- **Cover:** Natural terrain + UFO wreckage
- **Special Features:** Fires, damaged systems, exposed power cores

#### Rewards

```lua
Rewards_UFOCrash = {
    -- Guaranteed
    ufoRecovery = function(ufoSize)
        local rewards = {
            small = {elerium = 10, alloys = 15, money = 5000},
            medium = {elerium = 20, alloys = 30, money = 10000},
            large = {elerium = 40, alloys = 60, money = 20000},
            very_large = {elerium = 80, alloys = 120, money = 40000}
        }
        return rewards[ufoSize]
    end,
    
    -- Variable based on enemy kills
    alienCorpses = "all_killed_aliens",
    alienEquipment = "all_recovered_items",
    
    -- Bonus for no losses
    perfectBonus = {money = 5000, score = 100},
    
    -- Research unlocks
    researchOpportunity = function(ufoType)
        return {
            "ufo_construction",
            "ufo_power_source",
            "ufo_navigation_" .. ufoType
        }
    end
}
```

#### Failure Consequences

- **Ignored:** Site despawns after 24 hours, materials lost
- **Mission Failed:** Lost soldiers, partial material recovery
- **Squad Wiped:** Major score penalty, no recovery

#### Tactical Considerations

**Pros:**
- Wounded enemies easier to fight
- Static enemy positions
- Rich material rewards
- Good for new players

**Cons:**
- Enemies dug in with good cover
- UFO provides defensive positions
- Time pressure (24h expiration)
- Damaged UFO may have hazards (fires, explosions)

---

### UFO Landing Site

**Trigger:** UFO lands to conduct mission  
**Objective:** Assault landed UFO, prevent mission completion  
**Map Size:** 40x40 to 60x60 tiles  
**Time Limit:** None (tactical)  
**Expiration:** 8 hours (UFO takes off)

#### Enemy Composition

```lua
MissionType_UFOLanding = {
    type = "ufo_landing",
    enemyCount = function(ufoSize, difficulty)
        local baseCount = {
            small = {min = 6, max = 12},
            medium = {min = 10, max = 18},
            large = {min = 15, max = 25},
            very_large = {min = 20, max = 35}
        }
        
        local count = baseCount[ufoSize]
        local multiplier = 1 + (difficulty * 0.25)
        
        return {
            min = math.floor(count.min * multiplier),
            max = math.floor(count.max * multiplier)
        }
    end,
    
    -- All aliens at full health
    woundedRate = 0.0,
    
    -- Aliens deployed around UFO conducting mission
    deploymentPattern = "perimeter",
}

function MissionType_UFOLanding:generateEnemies(ufo, difficulty)
    local totalCount = self.enemyCount(ufo.size, difficulty)
    local enemyCount = math.random(totalCount.min, totalCount.max)
    
    local enemies = {}
    
    -- More organized composition
    local ranks = self:determineRankDistribution(enemyCount, difficulty)
    
    for rank, count in pairs(ranks) do
        for i = 1, count do
            local enemy = self:selectEnemyByRank(ufo.mission, rank, difficulty)
            table.insert(enemies, enemy)
        end
    end
    
    return enemies
end

function MissionType_UFOLanding:determineRankDistribution(total, difficulty)
    return {
        soldier = math.floor(total * 0.50), -- 50% soldiers
        leader = math.floor(total * 0.30),  -- 30% leaders
        commander = math.floor(total * 0.15), -- 15% commanders
        special = math.floor(total * 0.05)   -- 5% special
    }
end
```

#### Map Generation

- **Terrain:** Province biome
- **UFO State:** Intact, all systems functional
- **Enemy Deployment:** 
  - 30% inside UFO
  - 50% perimeter guard
  - 20% conducting mission objectives
- **Special Features:** Active UFO defenses, patrol patterns

#### Rewards

```lua
Rewards_UFOLanding = {
    -- Better recovery (intact UFO)
    ufoRecovery = function(ufoSize)
        local crashRewards = Rewards_UFOCrash.ufoRecovery(ufoSize)
        return {
            elerium = crashRewards.elerium * 1.5,
            alloys = crashRewards.alloys * 1.5,
            money = crashRewards.money * 1.3
        }
    end,
    
    -- Prevents alien mission success
    missionPrevention = {
        score = 200,
        funding = "no_penalty",
        panic = -10 -- Reduces panic
    },
    
    -- Chance for live captures (UFO intact)
    liveCaptureBonus = true,
    
    -- Better condition equipment
    equipmentBonus = 1.3 -- 30% more equipment recovered
}
```

#### Failure Consequences

- **Ignored:** UFO completes mission, flies away (major penalty)
- **Mission Failed:** Alien mission succeeds partially
- **Time Expired:** UFO escapes, mission success for aliens

#### Tactical Considerations

**Pros:**
- Better material recovery
- Prevents alien mission
- Live capture opportunities
- Reduces regional panic

**Cons:**
- Healthy enemies at full strength
- Better organized defenses
- Active UFO systems
- Time pressure (8h expiration)
- Patrol patterns detect soldiers

---

## Terror Missions

### Terror Site

**Trigger:** Alien terror attack on civilian population  
**Objective:** Save civilians, eliminate terror units  
**Map Size:** 50x50 tiles (urban area)  
**Time Limit:** 20 turns (civilians dying)  
**Expiration:** 2 hours (attack concludes)

#### Enemy Composition

```lua
MissionType_Terror = {
    type = "terror",
    enemyCount = function(month, difficulty)
        local base = 12 + month * 2
        local multiplier = 1 + (difficulty * 0.3)
        return math.floor(base * multiplier)
    end,
    
    -- Terror units: Floaters, Chryssalids, Sectopods
    terrorUnits = {"floater", "chryssalid", "sectopod"},
    terrorUnitRatio = 0.4, -- 40% terror units, 60% support
    
    -- Civilians on map
    civilianCount = function()
        return math.random(14, 20)
    end,
    
    -- Civilians killed per turn
    civilianLossRate = function(remainingEnemies)
        return math.min(3, math.floor(remainingEnemies / 5))
    end
}

function MissionType_Terror:generateEnemies(month, difficulty)
    local total = self.enemyCount(month, difficulty)
    local terrorCount = math.floor(total * self.terrorUnitRatio)
    local supportCount = total - terrorCount
    
    local enemies = {}
    
    -- Terror units (aggressive, anti-civilian)
    for i = 1, terrorCount do
        local species = self.terrorUnits[math.random(#self.terrorUnits)]
        local enemy = self:createEnemy(species, "soldier", difficulty)
        enemy.behavior = "hunt_civilians"
        table.insert(enemies, enemy)
    end
    
    -- Support units (standard aliens)
    for i = 1, supportCount do
        local enemy = self:selectEnemyType("terror_support", difficulty)
        enemy.behavior = "hunt_xcom"
        table.insert(enemies, enemy)
    end
    
    return enemies
end

function MissionType_Terror:updateCivilians(turn)
    local aliveEnemies = self:countAliveEnemies()
    local lossRate = self.civilianLossRate(aliveEnemies)
    
    for i = 1, lossRate do
        local civilian = self:getRandomAliveCivilian()
        if civilian then
            civilian:kill()
            self.civiliansCasualties = self.civiliansCasualties + 1
        end
    end
end
```

#### Map Generation

- **Terrain:** Urban (city streets, buildings)
- **Layout:** 
  - Multiple buildings (shops, apartments, offices)
  - Streets with vehicles
  - Parks or open areas
- **Civilians:** Scattered, panicked, fleeing
- **Enemy Spawn:** Central area, spreading outward
- **Special Features:** Fires, damaged vehicles, destructible environment

#### Civilian Behavior

```lua
Civilian = Class('Civilian')

function Civilian:initialize(position)
    self.position = position
    self.hp = 20
    self.panic = 100
    self.movementType = "random_flee"
end

function Civilian:update()
    if not self:canSeeXCOM() and self:canSeeAlien() then
        -- Flee from aliens
        local fleeDir = self:getFleeDirection()
        self:moveToward(fleeDir)
    elseif self:canSeeXCOM() then
        -- Move toward XCOM for safety
        local nearestSoldier = self:getNearestXCOM()
        self:moveToward(nearestSoldier.position)
    else
        -- Random panicked movement
        self:moveRandom()
    end
end

function Civilian:onDeath()
    -- Penalty for civilian deaths
    Game.panic:increase(self.country, 5)
    Game.score:decrease(30)
end
```

#### Rewards

```lua
Rewards_Terror = {
    -- Based on civilians saved
    civilianBonus = function(saved, total)
        local ratio = saved / total
        return {
            score = math.floor(saved * 50),
            money = math.floor(saved * 1000),
            panic = -math.floor(ratio * 20), -- Up to -20 panic
            funding = ratio * 5000 -- Bonus funding
        }
    end,
    
    -- Standard combat rewards
    alienKills = "standard",
    equipment = "standard",
    
    -- Bonus for saving majority
    heroBonus = function(saved, total)
        if saved >= total * 0.8 then -- 80%+ saved
            return {
                score = 500,
                money = 20000,
                panic = -30
            }
        end
        return {}
    end,
    
    -- Regional appreciation
    regionalEffect = function(saved, total)
        if saved >= total * 0.5 then
            return {
                funding = "+10% next month",
                soldiers = "bonus recruit"
            }
        end
        return {}
    end
}
```

#### Failure Consequences

- **Ignored:** All civilians die, massive panic increase (+50), funding cuts
- **Mission Failed:** Partial civilian casualties, significant panic
- **High Casualties:** Country may withdraw from council
- **Time Expired:** Remaining civilians die

#### Tactical Considerations

**Pros:**
- High score potential
- Reduces panic significantly
- Bonus funding
- Regional appreciation

**Cons:**
- Time pressure (civilians dying)
- Aggressive enemies
- Collateral damage risk
- High stress mission
- Civilians block movement

**Strategy Tips:**
1. Split squad: half to engage enemies, half to protect civilians
2. Prioritize terror units killing civilians
3. Create safe zones with overwatch
4. Use non-lethal methods near civilians
5. Smoke grenades to protect civilian clusters

---

## Infiltration Missions

### Abduction Mission

**Trigger:** Alien abduction in progress  
**Objective:** Rescue abductees, eliminate abduction team  
**Map Size:** 40x50 tiles (rural or suburban)  
**Time Limit:** 15 turns (abductees being taken)  
**Expiration:** 12 hours

#### Enemy Composition

```lua
MissionType_Abduction = {
    type = "abduction",
    enemyCount = function(month, difficulty)
        local base = 10 + month * 1.5
        return math.floor(base * (1 + difficulty * 0.25))
    end,
    
    -- Sectoids and Floaters (abduction specialists)
    primarySpecies = {"sectoid", "floater"},
    speciesRatio = 0.7, -- 70% primary, 30% support
    
    -- Abductees on map
    abducteeCount = function()
        return math.random(6, 10)
    end,
    
    -- Abduction progress
    abductionRate = 1, -- 1 abductee per 2 turns
}

function MissionType_Abduction:generateEnemies(month, difficulty)
    local total = self.enemyCount(month, difficulty)
    local primaryCount = math.floor(total * self.speciesRatio)
    
    local enemies = {}
    
    -- Primary abduction species
    for i = 1, primaryCount do
        local species = self.primarySpecies[math.random(#self.primarySpecies)]
        local enemy = self:createEnemy(species, nil, difficulty)
        enemy.behavior = "abduct"
        table.insert(enemies, enemy)
    end
    
    -- Support units
    for i = primaryCount + 1, total do
        local enemy = self:selectEnemyType("abduction_support", difficulty)
        enemy.behavior = "defend_abductors"
        table.insert(enemies, enemy)
    end
    
    return enemies
end

function MissionType_Abduction:updateAbduction(turn)
    if turn % 2 == 0 then -- Every 2 turns
        local abductee = self:getRandomAbductee()
        if abductee and abductee:isNearAlien() then
            abductee:beAbducted()
            self.abducteesLost = self.abducteesLost + 1
        end
    end
end
```

#### Map Generation

- **Terrain:** Farm, suburban neighborhood, or remote facility
- **Layout:**
  - Scattered buildings
  - UFO landing zone (small craft)
  - Abduction beam effect
- **Abductees:** Unconscious civilians, being moved to UFO
- **Enemy Deployment:**
  - 40% escorting abductees
  - 30% perimeter defense
  - 30% inside UFO
- **Special Features:** Stasis chambers, abduction equipment

#### Abductee Status

```lua
Abductee = Class('Abductee')

function Abductee:initialize(position)
    self.position = position
    self.hp = 15
    self.conscious = false
    self.beingCarried = false
    self.abductionProgress = 0 -- 0-100
end

function Abductee:update(turn)
    if self:isNearAlien() then
        self.abductionProgress = self.abductionProgress + 10
        
        if self.abductionProgress >= 100 then
            self:completeAbduction()
        end
    end
end

function Abductee:rescue()
    self.rescued = true
    Game.score:increase(50)
    return true
end

function Abductee:completeAbduction()
    self.abducted = true
    Game.score:decrease(50)
    Game.panic:increase(self.country, 3)
end
```

#### Rewards

```lua
Rewards_Abduction = {
    -- Based on abductees rescued
    rescueBonus = function(rescued, total)
        return {
            score = rescued * 50,
            money = rescued * 2000,
            panic = -math.floor((rescued / total) * 15)
        }
    end,
    
    -- UFO recovery (small craft)
    ufoRecovery = {
        elerium = 8,
        alloys = 12,
        money = 3000
    },
    
    -- Abduction research
    researchOpportunity = {
        "alien_abduction_protocols",
        "psionic_sedation",
        "memory_manipulation"
    },
    
    -- All rescued bonus
    perfectRescue = function(rescued, total)
        if rescued == total then
            return {
                score = 300,
                money = 10000,
                panic = -20,
                soldier = "bonus_psionic_potential"
            }
        end
        return {}
    end
}
```

#### Failure Consequences

- **Ignored:** All abductees taken, panic increase (+25)
- **Mission Failed:** Partial abductions, moderate panic
- **Time Expired:** Remaining abductees lost

#### Tactical Considerations

**Pros:**
- Moderate difficulty
- Good rewards
- Research opportunities
- Reduces panic

**Cons:**
- Time pressure
- Abductees fragile
- Enemies prioritize escape over combat
- Must reach UFO quickly

**Strategy Tips:**
1. Rush the UFO to prevent takeoff
2. Kill aliens carrying abductees first
3. Use stun weapons to capture specimens
4. Protect unconscious abductees from collateral
5. Secure UFO early to prevent escape

---

## Base Missions

### Alien Base Assault

**Trigger:** Alien base discovered (research or detection)  
**Objective:** Destroy alien base, eliminate all forces  
**Map Size:** 60x60 tiles (underground facility)  
**Time Limit:** None  
**Expiration:** None (base remains until assaulted)

#### Enemy Composition

```lua
MissionType_AlienBase = {
    type = "alien_base",
    enemyCount = function(baseLevel, difficulty)
        local base = 25 + (baseLevel * 5)
        return math.floor(base * (1 + difficulty * 0.4))
    end,
    
    -- Hierarchical command structure
    commandStructure = {
        commander = 1,     -- Base commander
        leaders = 4,        -- Section leaders
        elites = 8,         -- Elite guards
        soldiers = "remaining"
    },
    
    -- Multiple alien species
    speciesDiversity = true,
    
    -- Base defenses
    defenseSystems = {
        turrets = {count = 4, hp = 100, damage = 40},
        sensors = {count = 6, detection = 20},
        shields = {sections = 3, hp = 200}
    }
}

function MissionType_AlienBase:generateEnemies(baseLevel, difficulty)
    local total = self.enemyCount(baseLevel, difficulty)
    local enemies = {}
    
    -- Commander (1)
    local commander = self:createEnemy("ethereal", "commander", difficulty)
    commander.position = "command_center"
    table.insert(enemies, commander)
    
    -- Leaders (4)
    for i = 1, 4 do
        local species = self:selectEliteSpecies(difficulty)
        local leader = self:createEnemy(species, "leader", difficulty)
        leader.position = "section_" .. i
        table.insert(enemies, leader)
    end
    
    -- Elite guards (8)
    for i = 1, 8 do
        local species = self:selectEliteSpecies(difficulty)
        local elite = self:createEnemy(species, "elite", difficulty)
        elite.position = "guard_post_" .. i
        table.insert(enemies, elite)
    end
    
    -- Remaining soldiers
    local soldierCount = total - 13
    for i = 1, soldierCount do
        local species = self:selectStandardSpecies(difficulty)
        local soldier = self:createEnemy(species, "soldier", difficulty)
        table.insert(enemies, soldier)
    end
    
    return enemies
end
```

#### Map Generation

- **Structure:** Multi-level underground facility
- **Sections:**
  1. **Entry Corridor** - Defensive chokepoint
  2. **Barracks** - Living quarters, many enemies
  3. **Power Core** - Elerium reactor (destructible)
  4. **Research Labs** - Experimental tech, hazards
  5. **Command Center** - Base commander location
  6. **Hangar** - UFO storage, vehicles
- **Environmental Hazards:**
  - Radiation zones
  - Energy barriers
  - Automated defenses
  - Explosive containers
- **Enemy Deployment:** Layered defense, reinforcements

#### Base Defense Systems

```lua
AlienBaseDefense = Class('AlienBaseDefense')

function AlienBaseDefense:initialize()
    self.turrets = self:createTurrets(4)
    self.sensors = self:createSensors(6)
    self.shields = self:createShields(3)
    self.reinforcements = {
        trigger = "section_breach",
        waves = 3,
        unitsPerWave = 6
    }
end

function AlienBaseDefense:onSectionBreach(section)
    -- Call reinforcements
    self:spawnReinforcements(section)
    
    -- Activate nearby defenses
    for _, turret in ipairs(self:getNearbyTurrets(section)) do
        turret:activate()
    end
    
    -- Alert base commander
    if section == "command_approach" then
        self:alertCommander()
    end
end

function AlienBaseDefense:createTurret(position)
    return {
        position = position,
        hp = 100,
        armor = 30,
        damage = 40,
        accuracy = 0.7,
        range = 20,
        fireRate = 1, -- Every turn
        active = false
    }
end
```

#### Objectives

```lua
Objectives_AlienBase = {
    primary = {
        {
            id = "destroy_power_core",
            description = "Destroy the base power core",
            required = true,
            reward = {score = 500}
        },
        {
            id = "eliminate_commander",
            description = "Eliminate the base commander",
            required = true,
            reward = {score = 1000}
        }
    },
    
    secondary = {
        {
            id = "capture_commander",
            description = "Capture the base commander alive",
            required = false,
            reward = {score = 2000, research = "alien_command_structure"}
        },
        {
            id = "recover_research",
            description = "Recover alien research data",
            required = false,
            reward = {research = "multiple_breakthroughs"}
        },
        {
            id = "disable_defenses",
            description = "Disable all turret systems",
            required = false,
            reward = {money = 10000}
        },
        {
            id = "no_casualties",
            description = "Complete mission without losses",
            required = false,
            reward = {score = 1000, money = 20000}
        }
    }
}
```

#### Rewards

```lua
Rewards_AlienBase = {
    -- Massive material recovery
    baseRecovery = {
        elerium = 200,
        alloys = 400,
        money = 100000,
        equipment = "full_inventory"
    },
    
    -- Research breakthroughs
    researchData = {
        "alien_command_protocols",
        "base_construction_tech",
        "hyperwave_relay",
        "advanced_power_systems"
    },
    
    -- Strategic benefits
    strategicImpact = {
        ufoActivity = -30, -- Reduces UFO spawns
        panic = -40, -- Massive panic reduction worldwide
        funding = "+20% next month",
        score = 5000
    },
    
    -- Commander capture bonus
    commanderCapture = {
        research = "alien_hierarchy",
        intelligence = "final_mission_location",
        score = 2000
    }
}
```

#### Failure Consequences

- **Mission Failed:** Squad lost, base remains operational
- **Partial Success:** Base damaged but functional, reduced activity
- **High Casualties:** Pyrrhic victory, strategic gains offset by losses

#### Tactical Considerations

**Pros:**
- Massive rewards
- Reduces UFO activity
- Critical research
- Major score boost
- Strategic game-changer

**Cons:**
- Extremely difficult
- Long mission duration
- High casualty risk
- Reinforcement waves
- Complex multi-level layout
- Best equipment required

**Strategy Tips:**
1. Bring A-team with best gear
2. Clear section by section, no rushing
3. Destroy turrets with explosives
4. Use psionics against commander
5. Prioritize power core to disable shields
6. Save stun weapons for commander capture
7. Expect 2-3 hour mission

---

### XCOM Base Defense

**Trigger:** Alien discovers and attacks XCOM base  
**Objective:** Defend base facilities, repel invasion  
**Map Size:** Your base layout (variable)  
**Time Limit:** None  
**Expiration:** None (must defend)

#### Trigger Conditions

```lua
BaseDefenseTrigger = {
    -- Alien detection of base
    detectionChance = function(baseAge, exposureLevel)
        local baseChance = 0.01 -- 1% per month
        local ageMultiplier = baseAge / 12 -- Increases with age
        local exposureMultiplier = exposureLevel / 100
        
        return baseChance * (1 + ageMultiplier + exposureMultiplier)
    end,
    
    -- Exposure increases from:
    exposureFactors = {
        ufoInterceptions = 2, -- Per interception
        missionsInRegion = 1, -- Per mission near base
        hyperwave = -20, -- Hyperwave decoder reduces exposure
        mindShields = -15, -- Mind shields reduce psionic detection
        baseSize = 5 -- Per 5 facilities
    }
}
```

#### Enemy Composition

```lua
MissionType_BaseDefense = {
    type = "base_defense",
    enemyCount = function(baseValue, difficulty)
        -- More valuable bases attract larger forces
        local base = 20 + math.floor(baseValue / 10000)
        return math.floor(base * (1 + difficulty * 0.5))
    end,
    
    -- Elite assault force
    rankDistribution = {
        commander = 0.10,
        elite = 0.25,
        soldier = 0.65
    },
    
    -- Waves of attackers
    waveSystem = {
        waves = 4,
        delay = 3, -- 3 turns between waves
        escalation = 1.2 -- Each wave 20% stronger
    },
    
    -- Target priority
    targetPriority = {
        "power_generator",
        "research_lab",
        "workshop",
        "hangar",
        "barracks"
    }
}

function MissionType_BaseDefense:spawnWave(waveNumber, difficulty)
    local baseCount = math.floor(5 * math.pow(self.waveSystem.escalation, waveNumber - 1))
    local enemies = {}
    
    for i = 1, baseCount do
        local rank = self:selectRank()
        local species = self:selectEliteSpecies(difficulty)
        local enemy = self:createEnemy(species, rank, difficulty)
        
        -- Set spawn location (entry point)
        enemy.spawnPoint = self:getEntryPoint(waveNumber)
        
        -- Set target facility
        enemy.target = self:selectTargetFacility()
        
        table.insert(enemies, enemy)
    end
    
    return enemies
end
```

#### Map Generation

- **Layout:** Your actual base layout
- **Facilities:** Functional facilities as tactical map
- **Conversion:**
  - Each facility = 8x8 tile tactical section
  - Corridors = 4-tile wide passages
  - Lifts = vertical access points
- **Entry Points:** Lifts and access shafts
- **Special Features:** Facility equipment provides cover

#### Defense Forces

```lua
BaseDefenseForces = {
    -- All soldiers at base participate
    availableSoldiers = "all_not_wounded",
    
    -- Start in barracks or assigned facility
    deployment = function(soldier)
        if soldier.facility then
            return soldier.facility.location
        else
            return "barracks"
        end
    end,
    
    -- Soldiers have whatever equipment they carry
    equipment = "current_loadout",
    
    -- Base personnel (engineers, scientists) can fight
    civilians = {
        scientists = {count = "all", combat = 20, equipment = "pistol"},
        engineers = {count = "all", combat = 30, equipment = "rifle"}
    },
    
    -- Base defenses
    defenses = {
        turrets = "all_defense_turrets",
        shields = "all_shield_generators",
        sensors = "motion_scanners"
    }
}

function BaseDefenseForces:deployForces()
    local forces = {}
    
    -- Soldiers
    for _, soldier in ipairs(self:getAvailableSoldiers()) do
        soldier.position = self.deployment(soldier)
        table.insert(forces, soldier)
    end
    
    -- Base staff (if desperate)
    if Game.settings.baseStaffCombat then
        for _, scientist in ipairs(self:getScientists()) do
            local combatant = self:createStaffCombatant(scientist, "scientist")
            table.insert(forces, combatant)
        end
        
        for _, engineer in ipairs(self:getEngineers()) do
            local combatant = self:createStaffCombatant(engineer, "engineer")
            table.insert(forces, combatant)
        end
    end
    
    return forces
end
```

#### Facility Destruction

```lua
function FacilityDestruction:onFacilityDestroyed(facility)
    local effects = {
        power_generator = function()
            -- Lose power, disable shields and advanced systems
            Base.power = Base.power - facility.powerOutput
            if Base.power < 0 then
                Base:disableSystems()
            end
        end,
        
        research_lab = function()
            -- Lose research progress
            local project = facility.currentProject
            if project then
                project.progress = project.progress * 0.5 -- 50% loss
            end
            Base.labs = Base.labs - 1
        end,
        
        workshop = function()
            -- Lose production
            local production = facility.currentProduction
            if production then
                production.progress = production.progress * 0.5
            end
            Base.workshops = Base.workshops - 1
        end,
        
        hangar = function()
            -- Craft destroyed
            local craft = facility.craft
            if craft then
                craft:destroy()
            end
        end,
        
        barracks = function()
            -- Soldiers in barracks killed
            for _, soldier in ipairs(facility.soldiers) do
                if soldier.wounded then
                    soldier:kill()
                end
            end
        end,
        
        storage = function()
            -- Lose stored items
            local lossPercent = math.random(30, 70) / 100
            Base:loseStoredItems(lossPercent)
        end
    }
    
    if effects[facility.type] then
        effects[facility.type]()
    end
    
    Game.score:decrease(500)
    facility:destroy()
end
```

#### Rewards

```lua
Rewards_BaseDefense = {
    -- Survival is the reward
    basePreserved = function(facilitiesRemaining)
        local ratio = facilitiesRemaining / Base.totalFacilities
        return {
            score = math.floor(ratio * 2000),
            funding = "maintain_support",
            panic = -math.floor(ratio * 30)
        }
    end,
    
    -- Perfect defense
    noFacilityLoss = {
        score = 3000,
        money = 50000,
        panic = -50,
        morale = "+30 all soldiers"
    },
    
    -- Combat rewards
    alienEquipment = "all_recovered",
    corpses = "all_killed",
    
    -- Research from attackers
    researchOpportunity = {
        "base_assault_tactics",
        "alien_detection_methods"
    }
}
```

#### Failure Consequences

- **Base Lost:** Game Over if only base
- **Partial Loss:** Facilities destroyed, must rebuild
- **Heavy Casualties:** Soldiers killed, staff lost
- **Equipment Loss:** Stored items destroyed

#### Tactical Considerations

**Pros:**
- Fight on home ground
- Know the layout
- Base defenses active
- All soldiers available

**Cons:**
- No warning, no prep
- Soldiers may have poor loadouts
- Facility destruction permanent
- Waves of enemies
- High stakes (base loss = catastrophic)

**Strategy Tips:**
1. Build defensible base layouts
2. Keep squad equipped at all times
3. Construct defensive facilities
4. Protect power generators first
5. Use chokepoints in corridors
6. Deploy turrets at entry points
7. Evacuate critical staff to safe facilities

---

## Special Missions

### Council Mission

**Trigger:** Council requests special operation  
**Objective:** Varies by mission type  
**Expiration:** 6 hours  
**Failure:** Council displeasure, funding cuts

#### Mission Types

```lua
CouncilMissions = {
    {
        type = "VIP_rescue",
        objective = "Extract VIP from hostile area",
        vipHP = 30,
        extraction = "must_reach_evac",
        enemies = "heavy_guard"
    },
    {
        type = "bomb_disposal",
        objective = "Disarm alien bomb in city",
        timeLimit = 12, -- turns
        disarmSkill = "engineer_required",
        failure = "city_destroyed"
    },
    {
        type = "asset_recovery",
        objective = "Recover stolen technology",
        item = "classified_device",
        intel = "enemy_location_revealed",
        enemies = "mixed_force"
    },
    {
        type = "assassination",
        objective = "Eliminate high-value target",
        target = "alien_commander",
        detection = "stealth_preferred",
        escape = "after_kill_difficult"
    }
}
```

#### Rewards

```lua
Rewards_CouncilMission = {
    baseReward = {
        score = 1000,
        money = 30000,
        funding = "+10% next month"
    },
    
    perfectExecution = {
        score = 500,
        money = 10000,
        item = "unique_weapon_or_armor"
    },
    
    councilFavor = {
        unlocks = "special_technology",
        support = "emergency_funding_available"
    }
}
```

---

## Final Mission

### Alien Fortress Assault

**Trigger:** Temple Ship location discovered  
**Objective:** Board temple ship, defeat Uber Ethereal, end invasion  
**Map Size:** 80x80 tiles (massive ship interior)  
**Time Limit:** None  
**Expiration:** None

#### Enemy Composition

```lua
FinalMission = {
    type = "final",
    phases = 4,
    
    phase1_entryHall = {
        enemies = 20,
        species = {"muton", "sectopod"},
        difficulty = "extreme"
    },
    
    phase2_innerSanctum = {
        enemies = 15,
        species = {"ethereal", "muton_elite"},
        difficulty = "extreme"
    },
    
    phase3_ascensionChamber = {
        enemies = 10,
        species = {"ethereal"},
        difficulty = "extreme",
        boss = "ethereal_warlock"
    },
    
    phase4_uberEthereal = {
        boss = "uber_ethereal",
        minions = 6,
        difficulty = "impossible"
    }
}
```

#### Boss: Uber Ethereal

```lua
UberEthereal = {
    hp = 300,
    armor = 50,
    psiStrength = 150,
    psiSkill = 150,
    
    abilities = {
        "rift",
        "mass_mind_control",
        "psionic_storm",
        "telekinesis",
        "psionic_barrier",
        "summon_reinforcements"
    },
    
    phases = {
        {hp = 300, behavior = "defensive"},
        {hp = 200, behavior = "aggressive"},
        {hp = 100, behavior = "desperate"}
    }
}
```

#### Victory

- **Success:** Game won, ending cinematic, score calculation
- **Failure:** Game Over

---

## Cross-References

**Related Documents:**
- [Mission Generation](../geoscape/Mission_Generation.md) - Dynamic mission creation
- [Alien Species](../lore/Alien_Species.md) - Enemy stats and behavior
- [Detection System](../geoscape/Detection.md) - Mission triggers
- [Map Generation Pipeline](../integration/Map_Generation_Pipeline.md) - Tactical maps

**See Also:**
- [Combat System](../battlescape/Combat.md) - Tactical gameplay
- [Time Systems](../core/Time_Systems.md) - Mission timing
- [Panic System](../geoscape/Panic.md) - Failure consequences

---

**Document Status:** Complete  
**Implementation Status:** Not started  
**Last Review:** September 30, 2025  
**Version:** 1.0
