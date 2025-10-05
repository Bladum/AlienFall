# Alien Species

## Table of Contents
- [Overview](#overview)
- [Species Catalog](#species-catalog)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Alien Species codex documents all extraterrestrial factions, organisms, and entities encountered in Alien Fall including their biology, capabilities, behavior patterns, technology, and strategic roles within the invasion force, providing narrative context and tactical intelligence that informs strategic planning and combat preparation across the campaign.  
**Purpose:** Comprehensive reference for all alien species including stats, abilities, behavior patterns, and lore.

---

## Overview

The alien invasion consists of five primary species, each with unique characteristics, strengths, and tactical roles. Understanding each species is critical for tactical planning and strategic research prioritization.

### Species Classification

1. **Sectoid** - Psionic manipulators and research specialists
2. **Floater** - Aerial assault units and shock troops
3. **Muton** - Heavy infantry and frontline warriors
4. **Snakeman** - Infiltration specialists and biological warfare
5. **Ethereal** - Psionic masters and invasion commanders

---

## Sectoid

### Overview
Small, grey-skinned humanoids with oversized craniums. The Sectoid are the most commonly encountered alien species, serving as the primary workforce for the invasion. Despite their frail physical form, they possess formidable psionic abilities.

### Physical Characteristics
- **Height:** 1.2-1.4 meters
- **Build:** Thin, fragile frame
- **Distinctive Features:** Large black eyes, grey skin, disproportionately large head
- **Lifespan:** 80-120 years

### Base Stats

| Stat | Soldier | Medic | Engineer | Leader | Commander |
|------|---------|-------|----------|--------|-----------|
| **HP** | 30 | 35 | 40 | 50 | 60 |
| **Armor** | 0 | 0 | 5 | 10 | 15 |
| **Speed** | 12 | 12 | 10 | 14 | 14 |
| **Accuracy** | 60 | 55 | 50 | 70 | 75 |
| **Strength** | 20 | 20 | 25 | 30 | 35 |
| **Psi Strength** | 40 | 50 | 30 | 70 | 85 |
| **Psi Skill** | 30 | 40 | 20 | 60 | 80 |

### Abilities

#### Psionic Powers (All Ranks)
```lua
-- Mind Probe: Reveals target stats and inventory
function Sectoid:mindProbe(target)
    if self:psiCheck(target, 0.7) then -- 70% base chance
        target:reveal()
        return {
            stats = target:getStats(),
            inventory = target:getInventory(),
            mentalState = target:getMentalState()
        }
    end
    return nil
end
```

#### Panic Attack (Soldier+)
```lua
-- Induces panic in target unit
function Sectoid:panicAttack(target)
    local psiDiff = self.psiStrength - target.mentalStrength
    local chance = 0.5 + (psiDiff / 200) -- Base 50% + psi differential
    
    if math.random() < chance then
        target:applyStatus("panicked", 3) -- 3 turns
        return true
    end
    return false
end
```

#### Mind Control (Leader+)
```lua
-- Takes control of target unit
function Sectoid:mindControl(target)
    local psiDiff = self.psiStrength - target.mentalStrength
    local chance = 0.3 + (psiDiff / 150) -- Base 30% + psi differential
    
    if math.random() < chance then
        target:setController(self.faction)
        target:applyStatus("mindControlled", 5) -- 5 turns
        return true
    end
    return false
end
```

#### Psionic Shield (Commander)
```lua
-- Creates protective barrier
function Sectoid:psionicShield()
    self:applyBuff({
        name = "PsionicShield",
        duration = 3,
        damageReduction = 0.5, -- 50% damage reduction
        psionicImmunity = true
    })
end
```

### Equipment

#### Weapons
- **Plasma Pistol** (Soldier, Medic)
- **Plasma Rifle** (Engineer, Leader)
- **Heavy Plasma** (Commander)

#### Items
- **Mind Probe Device** (All ranks)
- **Alien Grenade** (Soldier, Engineer)
- **Medikit** (Medic)

### Tactical Behavior

#### Aggression: Low (30%)
Sectoids prefer to maintain distance and use psionic abilities rather than direct combat.

```lua
function Sectoid:selectAction()
    local nearestEnemy = self:getNearestEnemy()
    local distance = self:getDistance(nearestEnemy)
    
    -- Prioritize psionic attacks at any range
    if self.rank >= RANK_LEADER and self:canUsePsionic() then
        if math.random() < 0.7 then -- 70% chance
            return self:selectPsionicTarget()
        end
    end
    
    -- Maintain distance
    if distance < 10 then
        return self:findRetreatPosition()
    end
    
    -- Seek cover and shoot
    if distance > 15 then
        return self:findCoverPosition()
    end
    
    -- Standard attack
    return self:selectAttackAction()
end
```

#### Preferred Tactics
1. **Psionic Harassment** - Use panic and mind control on isolated targets
2. **Cover Camping** - Find defensive positions and suppress
3. **Support Role** - Heal allies with medikits, provide covering fire
4. **Retreat When Wounded** - Fall back at <50% HP

### Threat Assessment

| Rank | Threat Level | Priority | Notes |
|------|--------------|----------|-------|
| Soldier | Low | 4 | Easy kills, minimal threat |
| Medic | Low | 4 | Non-combatant, low priority |
| Engineer | Medium | 3 | Slightly tougher, grenade threat |
| Leader | High | 2 | Dangerous psionics, prioritize |
| Commander | Critical | 1 | Extreme psionic threat, kill first |

### Counter-Tactics

1. **Mental Screening** - Equip mind shields on all soldiers
2. **Aggressive Advance** - Don't give them time to use psionics
3. **High Accuracy Weapons** - They die quickly with accurate fire
4. **Explosives** - Low HP makes them vulnerable to grenades
5. **Flanking** - Poor armor means flanking shots are lethal

### Lore

The Sectoid represent the scientific caste of the alien hierarchy. They serve as researchers, engineers, and low-level administrators in the invasion force. Their psionic abilities stem from centuries of genetic manipulation and technological augmentation.

Sectoid society is rigidly hierarchical, with individual identity subsumed into collective consciousness. Lower ranks function as extensions of their commanders' will, making them predictable but coordinated.

**Research Notes:**
- Autopsy reveals cranial implants enhancing psionic capability
- Genetic analysis shows extensive artificial modification
- Brain tissue suggests hive-mind connection when in proximity
- No evidence of independent culture or art

---

## Floater

### Overview
Cybernetically enhanced organisms suspended in powered flight suits. The Floater serves as shock troops and rapid response units, capable of bypassing terrain obstacles that would hinder ground forces.

### Physical Characteristics
- **Height:** 1.8-2.0 meters (including cybernetics)
- **Build:** Heavily modified organic core with extensive cybernetic systems
- **Distinctive Features:** Integrated flight system, multiple cybernetic limbs, exposed mechanical components
- **Lifespan:** 40-60 years (heavily reduced by cybernetics)

### Base Stats

| Stat | Soldier | Heavy | Navigator | Leader | Commander |
|------|---------|-------|-----------|--------|-----------|
| **HP** | 50 | 65 | 55 | 70 | 80 |
| **Armor** | 15 | 25 | 20 | 30 | 35 |
| **Speed** | 16 | 14 | 18 | 18 | 20 |
| **Accuracy** | 65 | 60 | 70 | 75 | 80 |
| **Strength** | 35 | 45 | 30 | 40 | 45 |
| **Flight** | Yes | Yes | Yes | Yes | Yes |

### Abilities

#### Flight (All Ranks)
```lua
-- Floaters can move vertically without penalty
function Floater:canFly()
    return true
end

function Floater:getMovementCost(tile)
    -- Ignore terrain modifiers, only height costs energy
    local baseCost = 1
    local heightCost = math.abs(tile.height - self.currentHeight) * 0.5
    return baseCost + heightCost
end

-- Flight provides height bonus to accuracy and defense
function Floater:getFlightBonus()
    if self.height > 0 then
        return {
            accuracy = 10, -- +10% accuracy when elevated
            defense = 15   -- +15% dodge chance
        }
    end
    return {accuracy = 0, defense = 0}
end
```

#### Rocket Launcher (Heavy only)
```lua
-- Area damage attack
function FloaterHeavy:rocketLauncher(target)
    local damage = 60 + math.random(-10, 10)
    local radius = 3 -- 3 tile radius
    
    for _, unit in ipairs(self:getUnitsInRadius(target, radius)) do
        local dist = self:getDistance(unit, target)
        local damageMultiplier = 1 - (dist / radius) * 0.5 -- 50-100% damage
        unit:takeDamage(damage * damageMultiplier, "explosive")
    end
end
```

#### Aerial Superiority (Navigator+)
```lua
-- Bonus when attacking from above
function Floater:getAttackBonus(target)
    if self.height > target.height + 1 then
        return {
            accuracy = 20,  -- +20% accuracy
            damage = 1.25,  -- +25% damage
            critChance = 0.15 -- +15% crit chance
        }
    end
    return {accuracy = 0, damage = 1.0, critChance = 0}
end
```

#### Suppressive Fire (Leader+)
```lua
-- Pins down enemies in area
function Floater:suppressiveFire(target)
    local affectedTiles = self:getAdjacentTiles(target, 2)
    
    for _, tile in ipairs(affectedTiles) do
        tile:applySuppression({
            source = self,
            duration = 2,
            accuracyPenalty = -30,
            movementPenalty = -50
        })
    end
end
```

### Equipment

#### Weapons
- **Plasma Rifle** (Soldier, Navigator)
- **Heavy Plasma** (Heavy, Leader)
- **Blaster Launcher** (Commander)

#### Items
- **Alien Grenade** (All ranks)
- **Rocket Pack** (Heavy only)
- **Medikit** (Navigator)

### Tactical Behavior

#### Aggression: High (70%)
Floaters are aggressive shock troops that leverage mobility to flank and overwhelm.

```lua
function Floater:selectAction()
    local enemies = self:getVisibleEnemies()
    local bestTarget = self:selectHighValueTarget(enemies)
    
    -- Prioritize flanking from above
    if self:canFlank(bestTarget) then
        local flankPos = self:findAerialFlankPosition(bestTarget)
        if flankPos then
            return {
                action = "move_and_shoot",
                position = flankPos,
                target = bestTarget
            }
        end
    end
    
    -- Use explosives on clusters
    if self.rank == RANK_HEAVY and self:hasRocket() then
        local cluster = self:findEnemyCluster(3, 2) -- 3+ enemies in 2 tiles
        if cluster then
            return {
                action = "rocket",
                target = cluster.center
            }
        end
    end
    
    -- Aggressive advance
    local advancePos = self:findAggressivePosition()
    return {
        action = "move_and_shoot",
        position = advancePos,
        target = bestTarget
    }
end
```

#### Preferred Tactics
1. **Aerial Flanking** - Fly over cover to attack from above
2. **Height Advantage** - Maintain elevation for bonuses
3. **Coordinated Assault** - Multiple floaters attack simultaneously
4. **Explosive Entry** - Lead with grenades/rockets on fortified positions

### Threat Assessment

| Rank | Threat Level | Priority | Notes |
|------|--------------|----------|-------|
| Soldier | Medium | 3 | Mobile threat, moderate danger |
| Heavy | High | 2 | Rocket launcher can devastate squad |
| Navigator | Medium | 3 | High mobility, flanking threat |
| Leader | High | 2 | Dangerous combatant, good stats |
| Commander | Critical | 1 | Extreme threat with blaster launcher |

### Counter-Tactics

1. **Overwatch Traps** - Set up reaction fire for flying units
2. **Explosives** - Clip their wings with well-placed grenades
3. **High Ground** - Deny height advantage by taking elevated positions
4. **Smoke Grenades** - Reduce their accuracy bonus
5. **Focus Fire** - They're tough but not invincible

### Lore

Floaters are tragic remnants of a conquered species, forcibly converted into cyborg shock troops. The cybernetic conversion process is irreversible and painful, leaving them dependent on alien technology for survival.

Their society was completely destroyed during assimilation. No records exist of their original culture, language, or homeworld. They exist only as weapons now, their biological components sustained by mechanical life support.

**Research Notes:**
- Organic tissue shows signs of severe trauma and rejection
- Cybernetics are fused directly to nervous system
- Pain suppressors prevent awareness of constant agony
- No higher brain functions - pure combat conditioning
- Power source is alien elerium fuel cells

---

## Muton

### Overview
Massive, heavily armored brutes bred for frontline combat. Mutons are genetically engineered warriors designed to absorb punishment and dish out devastating firepower. They serve as the backbone of alien ground forces.

### Physical Characteristics
- **Height:** 2.2-2.5 meters
- **Build:** Massively muscled, thick-skinned
- **Distinctive Features:** Pronounced jaw, thick hide, combat scars
- **Lifespan:** 60-80 years

### Base Stats

| Stat | Soldier | Berserker | Elite | Leader | Commander |
|------|---------|-----------|-------|--------|-----------|
| **HP** | 90 | 110 | 100 | 120 | 140 |
| **Armor** | 20 | 25 | 30 | 35 | 40 |
| **Speed** | 10 | 12 | 11 | 12 | 13 |
| **Accuracy** | 70 | 60 | 80 | 85 | 90 |
| **Strength** | 60 | 75 | 65 | 70 | 75 |
| **Will** | 70 | 50 | 75 | 85 | 90 |

### Abilities

#### Intimidation (All Ranks)
```lua
-- Nearby enemies suffer accuracy penalty
function Muton:intimidationAura()
    local radius = 5
    for _, enemy in ipairs(self:getEnemiesInRadius(radius)) do
        if not enemy:hasHighMorale() then
            enemy:applyDebuff({
                name = "Intimidated",
                duration = 2,
                accuracyPenalty = -15,
                willPenalty = -20
            })
        end
    end
end
```

#### Blood Call (Berserker)
```lua
-- Enrage when wounded, gaining damage and speed
function MutonBerserker:bloodCall()
    local hpPercent = self.hp / self.maxHp
    
    if hpPercent < 0.5 then
        self:applyBuff({
            name = "Enraged",
            duration = 999, -- Until combat ends
            damageBonus = 0.5, -- +50% damage
            speedBonus = 4,    -- +4 speed
            accuracyPenalty = -20, -- -20% accuracy
            defense = -10      -- -10% defense
        })
    end
end

-- On taking damage
function MutonBerserker:onDamage(damage, source)
    self:bloodCall()
    
    -- Chance to charge attacker
    if math.random() < 0.3 then
        self:setTarget(source)
        self:forceAction("charge")
    end
end
```

#### Heavy Weapon Specialist (Elite+)
```lua
-- No accuracy penalty for heavy weapons
function Muton:getHeavyWeaponPenalty()
    if self.rank >= RANK_ELITE then
        return 0
    end
    return -15 -- Standard penalty
end

-- Can fire heavy weapons without setup
function Muton:canFireHeavyWeaponImmediately()
    return self.rank >= RANK_ELITE
end
```

#### Suppression Resistance (Leader+)
```lua
-- Immune to suppression effects
function Muton:applySuppression(effect)
    if self.rank >= RANK_LEADER then
        return false -- No effect
    end
    -- Standard suppression applied
    return true
end
```

#### War Cry (Commander)
```lua
-- Buff all nearby allies
function MutonCommander:warCry()
    local radius = 8
    
    for _, ally in ipairs(self:getAlliesInRadius(radius)) do
        ally:applyBuff({
            name = "WarCry",
            duration = 3,
            damageBonus = 0.25, -- +25% damage
            accuracyBonus = 15, -- +15% accuracy
            willBonus = 30      -- +30 will
        })
    end
    
    self:useEnergy(20)
end
```

### Equipment

#### Weapons
- **Plasma Rifle** (Soldier, Berserker)
- **Heavy Plasma** (Elite, Leader, Commander)
- **Blaster Launcher** (Commander only)

#### Items
- **Alien Grenade** (All ranks)
- **Medikit** (Elite, Leader, Commander)

### Tactical Behavior

#### Aggression: Very High (85%)
Mutons are fearless warriors who press the attack relentlessly.

```lua
function Muton:selectAction()
    local enemies = self:getVisibleEnemies()
    local nearestEnemy = self:getNearestEnemy()
    local distance = self:getDistance(nearestEnemy)
    
    -- Berserker charging behavior
    if self.rank == RANK_BERSERKER and self:hasStatus("Enraged") then
        return {
            action = "charge",
            target = nearestEnemy
        }
    end
    
    -- Use war cry if available (Commander)
    if self.rank == RANK_COMMANDER and self:canUseWarCry() then
        if self:countNearbyAllies(8) >= 2 then
            return {action = "war_cry"}
        end
    end
    
    -- Aggressive advance
    if distance > 12 then
        local advancePos = self:findAggressivePosition()
        return {
            action = "move_and_shoot",
            position = advancePos,
            target = nearestEnemy
        }
    end
    
    -- Hold position and shoot
    return {
        action = "shoot",
        target = self:selectBestTarget()
    }
end
```

#### Preferred Tactics
1. **Frontal Assault** - Direct advance under fire
2. **Suppression** - Pin down enemies with heavy fire
3. **Grenade Opening** - Start engagements with explosives
4. **Hold the Line** - Never retreat, fight to the death

### Threat Assessment

| Rank | Threat Level | Priority | Notes |
|------|--------------|----------|-------|
| Soldier | High | 2 | Tough and accurate, dangerous |
| Berserker | Critical | 1 | Enrage mechanic makes them deadly |
| Elite | High | 2 | Excellent stats, heavy weapons |
| Leader | Critical | 1 | Very dangerous combatant |
| Commander | Critical | 1 | Extreme threat, buffs allies |

### Counter-Tactics

1. **Armor Piercing** - Use AP ammo or plasma weapons
2. **Flanking** - Bypass their heavy armor with positioning
3. **Psionics** - High will but not immune to panic
4. **Kiting** - They're slow, maintain distance
5. **Kill Berserkers First** - Don't let them enrage and close

### Lore

Mutons are genetically engineered warriors, created specifically for the invasion. Unlike Floaters, they were purpose-built rather than converted from a conquered species. Their genetic code shows markers from multiple species, suggesting they are synthetic constructs.

Muton culture revolves entirely around warfare. They possess a rigid military hierarchy with absolute obedience to superiors. Combat is their purpose and identity - they have no concept of peace or civilian life.

**Research Notes:**
- DNA analysis reveals artificial gene sequences
- Multiple species markers suggest designer organism
- Enhanced pain tolerance and aggression
- Limited higher cognition outside combat scenarios
- Bred in batches in alien facilities

---

## Snakeman

### Overview
Reptilian infiltrators and biological warfare specialists. Snakemen combine agility with deadly poison attacks, making them dangerous in close quarters. They excel at ambush tactics and hit-and-run engagements.

### Physical Characteristics
- **Height:** 1.8-2.0 meters
- **Build:** Lean and muscular with serpentine flexibility
- **Distinctive Features:** Scaled skin, elongated skull, forked tongue
- **Lifespan:** 70-90 years

### Base Stats

| Stat | Scout | Infiltrator | Assassin | Leader | Commander |
|------|-------|-------------|----------|--------|-----------|
| **HP** | 55 | 60 | 65 | 75 | 85 |
| **Armor** | 10 | 15 | 20 | 25 | 30 |
| **Speed** | 14 | 16 | 18 | 16 | 17 |
| **Accuracy** | 75 | 80 | 85 | 85 | 90 |
| **Strength** | 30 | 35 | 40 | 45 | 50 |
| **Reactions** | 65 | 75 | 85 | 80 | 85 |

### Abilities

#### Poison Spit (All Ranks)
```lua
-- Ranged poison attack
function Snakeman:poisonSpit(target)
    local hitChance = self:calculateHitChance(target, "poison")
    
    if math.random() < hitChance then
        local damage = 15 + math.random(0, 5)
        target:takeDamage(damage, "poison")
        
        -- Apply poison status
        target:applyStatus("poisoned", {
            duration = 5,
            damagePerTurn = 5,
            healingReduction = 0.5 -- 50% healing effectiveness
        })
        
        return true
    end
    return false
end
```

#### Stealth (Scout+)
```lua
-- Reduced detection range
function Snakeman:getDetectionModifier()
    if self.rank >= RANK_SCOUT then
        if self:isInCover() then
            return -0.5 -- 50% harder to detect
        end
        return -0.3 -- 30% harder to detect
    end
    return 0
end

-- Can move after shooting if in stealth
function Snakeman:canMoveAfterShooting()
    return self.rank >= RANK_INFILTRATOR and self:hasStatus("Stealthed")
end
```

#### Ambush Strike (Infiltrator+)
```lua
-- Bonus damage on first attack from stealth
function Snakeman:ambushStrike(target)
    if not self:hasBeenDetected() then
        local baseDamage = self:calculateDamage(target)
        local ambushBonus = 2.0 -- 100% damage bonus
        
        target:takeDamage(baseDamage * ambushBonus, "ambush")
        self:reveal() -- Breaks stealth
        
        return true
    end
    return false
end
```

#### Evasion (Assassin+)
```lua
-- High chance to dodge incoming fire
function Snakeman:calculateDodgeChance(attacker)
    local baseDodge = 0.15 -- 15% base
    
    if self.rank >= RANK_ASSASSIN then
        baseDodge = baseDodge + 0.15 -- +15% for assassins
    end
    
    if self:isMoving() then
        baseDodge = baseDodge + 0.10 -- +10% while moving
    end
    
    return baseDodge
end
```

#### Venom Strike (Leader+)
```lua
-- Melee attack with massive poison damage
function Snakeman:venomStrike(target)
    if self:isAdjacent(target) then
        local damage = 25 + math.random(0, 10)
        target:takeDamage(damage, "melee")
        
        -- Stronger poison
        target:applyStatus("poisoned", {
            duration = 8,
            damagePerTurn = 10,
            healingReduction = 0.75, -- 75% healing reduction
            speedPenalty = -4
        })
        
        return true
    end
    return false
end
```

### Equipment

#### Weapons
- **Plasma Pistol** (Scout, Infiltrator)
- **Plasma Rifle** (Assassin, Leader)
- **Heavy Plasma** (Commander)

#### Items
- **Alien Grenade** (All ranks)
- **Smoke Grenade** (Scout, Infiltrator, Assassin)
- **Medikit** (Leader, Commander)

### Tactical Behavior

#### Aggression: Medium (50%)
Snakemen are opportunistic, striking when they have advantage and retreating otherwise.

```lua
function Snakeman:selectAction()
    local enemies = self:getVisibleEnemies()
    local nearestEnemy = self:getNearestEnemy()
    local distance = self:getDistance(nearestEnemy)
    
    -- Ambush from stealth
    if not self:hasBeenDetected() then
        if self:hasCleanShot(nearestEnemy) then
            return {
                action = "ambush_strike",
                target = nearestEnemy
            }
        end
        
        -- Reposition for better ambush
        local stealthPos = self:findStealthPosition(nearestEnemy)
        return {
            action = "move",
            position = stealthPos,
            stealth = true
        }
    end
    
    -- Melee range: use venom strike
    if distance <= 1 and self.rank >= RANK_LEADER then
        return {
            action = "venom_strike",
            target = nearestEnemy
        }
    end
    
    -- Use poison spit if available
    if self:canUsePoisonSpit() and distance <= 10 then
        if math.random() < 0.6 then -- 60% chance
            return {
                action = "poison_spit",
                target = nearestEnemy
            }
        end
    end
    
    -- Hit and run
    if self:isExposed() then
        local retreatPos = self:findRetreatPosition()
        return {
            action = "shoot_and_move",
            target = nearestEnemy,
            position = retreatPos
        }
    end
    
    -- Standard attack
    return {
        action = "shoot",
        target = self:selectBestTarget()
    }
end
```

#### Preferred Tactics
1. **Ambush** - Wait in stealth for optimal first strike
2. **Poison Application** - Use poison to weaken over time
3. **Hit and Run** - Strike and relocate
4. **Flanking** - High mobility enables flanking maneuvers
5. **Smoke Screen** - Use smoke to disengage

### Threat Assessment

| Rank | Threat Level | Priority | Notes |
|------|--------------|----------|-------|
| Scout | Medium | 3 | Stealth makes them annoying |
| Infiltrator | High | 2 | Ambush damage is dangerous |
| Assassin | High | 2 | High evasion, hard to hit |
| Leader | Critical | 1 | Venom strike can one-shot |
| Commander | Critical | 1 | All abilities, extreme threat |

### Counter-Tactics

1. **Motion Scanners** - Detect stealthed units
2. **Area Denial** - Use explosives to flush them out
3. **Antidotes** - Carry medikits to cure poison
4. **Steady Aim** - High accuracy weapons counter evasion
5. **Overwatch** - Catch them during movement

### Lore

Snakemen are the intelligence and espionage arm of the invasion. Their cold-blooded metabolism and patience make them excellent scouts and assassins. They operate in small, independent cells with minimal oversight.

Snakeman culture values cunning over brute force. They maintain a complex social hierarchy based on successful missions and kills. Unlike other species, they retain significant autonomy and independent thought.

**Research Notes:**
- Reptilian physiology with mammalian brain structure
- Venom glands are bioengineered, not natural evolution
- Superior sensory organs (heat vision, enhanced smell)
- Evidence of advanced tactical training
- Retain cultural identity despite alien control

---

## Ethereal

### Overview
The masters of the invasion. Ethereals are ancient psionic beings of immense power who command all other alien species. They rarely appear on the battlefield, preferring to direct operations from behind the scenes.

### Physical Characteristics
- **Height:** 1.6-1.8 meters
- **Build:** Extremely frail, atrophied muscles
- **Distinctive Features:** Robed appearance, glowing eyes, floating locomotion
- **Lifespan:** 500+ years (possibly immortal)

### Base Stats

| Stat | Adept | Psion | Warlock | Commander | Uber Commander |
|------|-------|-------|---------|-----------|----------------|
| **HP** | 50 | 60 | 70 | 90 | 120 |
| **Armor** | 5 | 10 | 15 | 25 | 35 |
| **Speed** | 10 | 12 | 14 | 14 | 16 |
| **Accuracy** | 80 | 85 | 90 | 95 | 100 |
| **Strength** | 15 | 15 | 20 | 25 | 30 |
| **Psi Strength** | 90 | 100 | 110 | 120 | 130 |
| **Psi Skill** | 85 | 95 | 105 | 115 | 125 |
| **Will** | 100 | 110 | 120 | 130 | 140 |

### Abilities

#### Psionic Mastery (All Ranks)
```lua
-- All psionic abilities cost 50% less energy
function Ethereal:getPsionicCost(ability)
    local baseCost = ability.baseCost
    return baseCost * 0.5
end

-- Immune to psionic attacks
function Ethereal:isPsionicImmune()
    return true
end

-- Can use multiple psionic abilities per turn
function Ethereal:getPsionicActionsPerTurn()
    return 2 + math.floor(self.rank / 2)
end
```

#### Mind Control (Adept+)
```lua
-- Permanent mind control until broken
function Ethereal:mindControl(target)
    local psiDiff = self.psiStrength - target.mentalStrength
    local chance = 0.6 + (psiDiff / 100) -- Base 60% + psi differential
    
    if math.random() < chance then
        target:setController(self.faction)
        target:applyStatus("mindControlled", 999) -- Permanent
        self:addThrall(target)
        return true
    end
    return false
end

-- Can control multiple units simultaneously
function Ethereal:getMaxThralls()
    return self.rank + 1 -- 2-6 units depending on rank
end
```

#### Psionic Storm (Psion+)
```lua
-- Area psionic attack
function Ethereal:psionicStorm(center)
    local radius = 4
    local baseDamage = 30
    
    for _, unit in ipairs(self:getUnitsInRadius(center, radius)) do
        if not unit:isPsionicImmune() then
            local dist = self:getDistance(unit, center)
            local damageMultiplier = 1 - (dist / radius) * 0.5
            local damage = baseDamage * damageMultiplier
            
            -- Psionic damage bypasses armor
            unit:takeDamage(damage, "psionic")
            
            -- Chance to panic
            if math.random() < 0.4 then
                unit:applyStatus("panicked", 3)
            end
        end
    end
    
    self:useEnergy(30)
end
```

#### Telekinesis (Warlock+)
```lua
-- Move units or objects remotely
function Ethereal:telekinesis(target, destination)
    local psiCheck = self:psiCheck(target, 0.8)
    
    if psiCheck or target:isObject() then
        target:setPosition(destination)
        
        -- Damage if moved into hazard
        if destination:isHazardous() then
            target:takeDamage(20, "environmental")
        end
        
        return true
    end
    return false
end

-- Can throw units into each other
function Ethereal:telekinesisCrash(unit1, unit2)
    local midpoint = self:calculateMidpoint(unit1, unit2)
    self:telekinesis(unit1, midpoint)
    self:telekinesis(unit2, midpoint)
    
    unit1:takeDamage(30, "kinetic")
    unit2:takeDamage(30, "kinetic")
    unit1:applyStatus("stunned", 1)
    unit2:applyStatus("stunned", 1)
end
```

#### Psionic Barrier (Commander+)
```lua
-- Shields all nearby allies
function Ethereal:psionicBarrier()
    local radius = 8
    
    for _, ally in ipairs(self:getAlliesInRadius(radius)) do
        ally:applyBuff({
            name = "PsionicBarrier",
            duration = 5,
            damageReduction = 0.4, -- 40% damage reduction
            psionicImmunity = true,
            shieldHP = 50 -- Absorbs 50 damage
        })
    end
    
    self:useEnergy(40)
end
```

#### Rift (Uber Commander)
```lua
-- Creates spatial rift that damages and displaces
function EtherealUber:rift(location)
    local radius = 5
    
    -- Create persistent hazard
    self:createHazard({
        position = location,
        radius = radius,
        duration = 5,
        damagePerTurn = 15,
        type = "psionic",
        displaceChance = 0.3 -- 30% chance to teleport randomly
    })
    
    -- Initial burst damage
    for _, unit in ipairs(self:getUnitsInRadius(location, radius)) do
        if not unit:isPsionicImmune() then
            unit:takeDamage(40, "psionic")
            
            if math.random() < 0.3 then
                local randomPos = self:getRandomPosition(10)
                unit:setPosition(randomPos)
            end
        end
    end
    
    self:useEnergy(50)
end
```

### Equipment

#### Weapons
- **Plasma Pistol** (Adept, Psion) - Rarely used
- **Plasma Rifle** (Warlock, Commander) - Backup weapon
- **Psi Amp** (All ranks) - Enhances psionic powers

#### Items
- **Mind Shield** (Commander+ only)
- **Medikit** (Warlock+)

### Tactical Behavior

#### Aggression: Low (20%)
Ethereals command from the rear, using psionics to control the battlefield.

```lua
function Ethereal:selectAction()
    local enemies = self:getVisibleEnemies()
    local allies = self:getVisibleAllies()
    local distance = self:getDistance(self:getNearestEnemy())
    
    -- Maintain maximum distance
    if distance < 15 then
        local retreatPos = self:findSafePosition()
        return {
            action = "retreat",
            position = retreatPos
        }
    end
    
    -- Cast psionic barrier if allies nearby
    if self.rank >= RANK_COMMANDER and self:canUsePsionicBarrier() then
        if #allies >= 2 then
            return {action = "psionic_barrier"}
        end
    end
    
    -- Mind control high-value targets
    local controlTarget = self:findBestControlTarget(enemies)
    if controlTarget and self:canAddThrall() then
        return {
            action = "mind_control",
            target = controlTarget
        }
    end
    
    -- Use area attacks on clusters
    if self.rank >= RANK_PSION then
        local cluster = self:findEnemyCluster(3, 3) -- 3+ enemies in 3 tiles
        if cluster then
            return {
                action = "psionic_storm",
                target = cluster.center
            }
        end
    end
    
    -- Telekinesis for positioning
    if self.rank >= RANK_WARLOCK then
        local throwTarget = self:findThrowTarget()
        if throwTarget then
            return {
                action = "telekinesis",
                target = throwTarget.unit,
                destination = throwTarget.hazard
            }
        end
    end
    
    -- Default: take cover and mind control
    return {
        action = "mind_control",
        target = self:selectMindControlTarget()
    }
end
```

#### Preferred Tactics
1. **Mind Control** - Turn enemies against each other
2. **Area Denial** - Psionic storms and rifts control space
3. **Force Multiplication** - Buff and shield allies
4. **Battlefield Control** - Telekinesis for positioning
5. **Strategic Retreat** - Never engage in direct combat

### Threat Assessment

| Rank | Threat Level | Priority | Notes |
|------|--------------|----------|-------|
| Adept | High | 2 | Mind control is dangerous |
| Psion | Critical | 1 | Area attacks and control |
| Warlock | Critical | 1 | Full toolkit, very dangerous |
| Commander | Critical | 1 | Extreme threat, kill immediately |
| Uber Commander | Extreme | 1 | Mission-ending threat level |

### Counter-Tactics

1. **Mind Shields** - Mandatory equipment, blocks most psionics
2. **Focus Fire** - Physically fragile, dies to concentrated fire
3. **Snipers** - Long range counters their retreat tactics
4. **Suppression** - Pin them down before they act
5. **Rush** - Don't give them time to use abilities

### Lore

Ethereals are the ancient architects of the invasion. They have conquered countless worlds, assimilating useful species and destroying the rest. Their physical forms have atrophied over millennia as they relied entirely on psionic power.

The Ethereal collective seeks Earth not for resources, but for humanity's psionic potential. They view humans as raw material for their next generation of warrior-slaves. Their ultimate goal remains unknown.

**Research Notes:**
- Virtually no physical organs remain functional
- Brain case is 3x normal size
- Sustained entirely by psionic energy
- Technology is fused with their biology
- Possible hive-mind connection
- May be clones or fragments of original beings
- Show signs of extreme age and decay

---

## Species Comparison Tables

### Combat Statistics

| Species | HP (Avg) | Armor (Avg) | Speed (Avg) | Accuracy (Avg) | Threat |
|---------|----------|-------------|-------------|----------------|--------|
| Sectoid | 43 | 6 | 12 | 62 | Low-High |
| Floater | 64 | 25 | 17 | 70 | Medium-Critical |
| Muton | 112 | 30 | 11 | 79 | High-Critical |
| Snakeman | 68 | 20 | 16 | 83 | Medium-Critical |
| Ethereal | 78 | 18 | 13 | 90 | High-Extreme |

### Tactical Roles

| Species | Role | Strengths | Weaknesses |
|---------|------|-----------|------------|
| Sectoid | Support/Psionic | Psionics, numerous | Fragile, weak combat |
| Floater | Shock Trooper | Mobility, flanking | Vulnerable to overwatch |
| Muton | Heavy Infantry | Durability, firepower | Slow, predictable |
| Snakeman | Skirmisher | Stealth, poison | Medium durability |
| Ethereal | Commander | Psionics, control | Physically weak |

### Encounter Frequency

| Species | Early Game | Mid Game | Late Game | Final Mission |
|---------|------------|----------|-----------|---------------|
| Sectoid | Very High | Medium | Low | Rare |
| Floater | Medium | High | Medium | Medium |
| Muton | None | Medium | High | Very High |
| Snakeman | Low | Medium | High | Medium |
| Ethereal | None | Rare | Medium | Guaranteed |

---

## Research Priorities

### Autopsy Research

1. **Sectoid Autopsy** - Unlocks: Mind Shield research
2. **Floater Autopsy** - Unlocks: Flying Suit research
3. **Muton Autopsy** - Unlocks: Medikit improvement
4. **Snakeman Autopsy** - Unlocks: Antidote production
5. **Ethereal Autopsy** - Unlocks: Psi Lab, Psi Amp

### Interrogation Research

1. **Sectoid Medic** - Intelligence on alien research facilities
2. **Floater Navigator** - UFO navigation systems
3. **Muton Commander** - Alien battle tactics
4. **Snakeman Leader** - Infiltration mission locations
5. **Ethereal Commander** - Alien base location

---

## Implementation Notes

### Love2D Entity Structure
```lua
AlienSpecies = Class('AlienSpecies', Entity)

function AlienSpecies:initialize(species, rank)
    Entity.initialize(self)
    
    self.species = species
    self.rank = rank
    self.stats = self:loadStats(species, rank)
    self.abilities = self:loadAbilities(species, rank)
    self.equipment = self:loadEquipment(species, rank)
    self.behavior = self:loadBehavior(species)
end

function AlienSpecies:loadStats(species, rank)
    local statTables = {
        sectoid = require('data.species.sectoid'),
        floater = require('data.species.floater'),
        muton = require('data.species.muton'),
        snakeman = require('data.species.snakeman'),
        ethereal = require('data.species.ethereal')
    }
    
    return statTables[species][rank]
end
```

### Data File Structure
```toml
# data/species/sectoid.toml
[soldier]
hp = 30
armor = 0
speed = 12
accuracy = 60
strength = 20
psi_strength = 40
psi_skill = 30

[soldier.abilities]
mind_probe = true
panic_attack = false
mind_control = false

[soldier.equipment]
weapon = "plasma_pistol"
items = ["mind_probe", "alien_grenade"]
```

---

## Cross-References

**Related Systems:**
- [AI Behavior](../ai/Faction_Behavior.md) - Faction-level behavior patterns
- [Combat System](../battlescape/Combat.md) - Damage calculation
- [Status Effects](../battlescape/Status_Effects.md) - Psionic effects
- [Research Tree](../economy/Research.md) - Autopsy/interrogation unlocks
- [Mission Generation](../geoscape/Mission_Generation.md) - Species composition

**See Also:**
- [Unit Stats](../units/Stats.md) - Base stat system
- [Armor System](../units/Armor.md) - Damage reduction mechanics
- [Weapons](../items/Weapons.md) - Alien weapon statistics
- [Detection System](../geoscape/Detection.md) - UFO detection

---

**Document Status:** Complete  
**Implementation Status:** Not started  
**Last Review:** September 30, 2025  
**Version:** 1.0
