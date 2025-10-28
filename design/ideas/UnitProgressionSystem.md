# Unit Progression & Alternative Advancement System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: HIGH  
> **Related Systems**: Units.md, Battlescape.md, Items.md, Pilots.md

## Table of Contents

- [Overview](#overview)
- [XP Curve Rebalance](#xp-curve-rebalance)
- [Weapon Mastery System](#weapon-mastery-system)
- [Combat Role Specialization](#combat-role-specialization)
- [Cross-Training System](#cross-training-system)
- [Veteran Mentorship](#veteran-mentorship)
- [Training Facilities](#training-facilities)
- [Achievement-Based Traits](#achievement-based-traits)
- [Legacy System](#legacy-system)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

Addresses **unit progression imbalance** by reducing XP requirements, adding alternative progression paths, and creating meaningful specialization without tedious grinding.

**Core Goals**:
- Make Rank 4-6 achievable within campaign (30-35 missions)
- Add weapon mastery for emergent specialization
- Create combat role identity (aggressive/defensive/support)
- Enable cross-training (pilots learn ground combat, vice versa)
- Reward veteran players with catchup mechanics

---

## XP Curve Rebalance

### Current vs. Proposed

```yaml
Current (Too Steep):
Rank 1: 100 XP (5 missions)
Rank 2: 300 XP (12 missions, +200)
Rank 3: 600 XP (25 missions, +300)
Rank 4: 1,000 XP (40 missions, +400) ← Wall starts
Rank 5: 1,500 XP (60 missions, +500)
Rank 6: 2,100 XP (85 missions, +600) ← Effectively impossible

Proposed (Balanced):
Rank 1: 100 XP (5 missions, unchanged)
Rank 2: 250 XP (10 missions, -17%)
Rank 3: 500 XP (20 missions, -17%)
Rank 4: 800 XP (32 missions, -20%)
Rank 5: 1,200 XP (48 missions, -20%)
Rank 6: 1,700 XP (68 missions, -19%)

Reasoning:
- Rank 4 achievable in ~30 missions (realistic for focused player)
- Rank 5 achievable in ~45 missions (dedicated veteran)
- Rank 6 achievable in ~65 missions (elite player, still challenging)
```

### Mission XP Breakdown

**XP Sources Per Mission**:
```yaml
Combat Kills:
  - Enemy kill: 10-20 XP (based on enemy rank)
  - Assist kill: 5-10 XP (supporting fire)
  - Melee kill: +5 XP bonus (risk bonus)

Mission Completion:
  - Success: 25-50 XP (difficulty-based)
  - Perfect (no casualties): +25 XP bonus
  - Failure: 10 XP (learn from mistakes)

Special Actions:
  - Civilian saved: +10 XP per civilian
  - Objective secured: +15 XP
  - Elite enemy killed: +30 XP
  - Boss enemy killed: +50 XP

Typical Mission Total: 60-120 XP per unit
```

### Smart Trait Modifier

Units with **Smart** trait gain +20% XP:
```
Standard Unit: 100 XP mission = 100 XP
Smart Unit: 100 XP mission = 120 XP

Impact on Rank 6:
- Standard: 68 missions required
- Smart: 57 missions required (11 fewer missions)
```

---

## Weapon Mastery System

### Overview

Track kills per weapon type, gain mastery bonuses without micromanagement.

### Mastery Progression

```yaml
Mastery Levels:
  Novice (0-9 kills):
    - No bonuses (learning weapon)
  
  Competent (10-19 kills):
    - +2% accuracy
    - +5% crit chance
    - Visual: ★ (1 star)
  
  Proficient (20-29 kills):
    - +4% accuracy
    - +10% crit chance
    - Visual: ★★ (2 stars)
  
  Expert (30-39 kills):
    - +6% accuracy
    - +15% crit chance
    - Visual: ★★★ (3 stars)
  
  Master (40-49 kills):
    - +8% accuracy
    - +20% crit chance
    - Special: Unlock weapon-specific ability
    - Visual: ★★★★ (4 stars)
  
  Legendary (50+ kills):
    - +10% accuracy (cap)
    - +25% crit chance (cap)
    - Special: Enhanced weapon ability
    - Visual: ★★★★★ (5 stars, glowing)
```

### Weapon Categories

Mastery tracked separately per category:

```yaml
Rifles:
  - Assault Rifle, Battle Rifle, Gauss Rifle
  - Master Ability: "Controlled Burst" (3-round burst, +accuracy)
  - Legendary: "Perfect Control" (no recoil, always accurate)

Sniper Rifles:
  - Sniper Rifle, Anti-Material Rifle, Plasma Sniper
  - Master Ability: "Headshot" (guaranteed crit if aimed)
  - Legendary: "Executioner" (kill any non-boss in one shot)

Shotguns:
  - Combat Shotgun, Auto-Shotgun, Plasma Scatter
  - Master Ability: "Breacher" (ignore cover at close range)
  - Legendary: "Room Clearer" (hit all adjacent enemies)

Heavy Weapons:
  - Rocket Launcher, Plasma Cannon, Railgun
  - Master Ability: "Danger Close" (no friendly fire)
  - Legendary: "Devastation" (2× explosion radius)

Pistols:
  - Sidearm, Magnum, Plasma Pistol
  - Master Ability: "Quick Draw" (-1 AP cost to fire)
  - Legendary: "Gunslinger" (fire twice per turn)

Melee:
  - Combat Knife, Powered Blade, Psi Blade
  - Master Ability: "Assassinate" (instakill unaware enemies)
  - Legendary: "Bladestorm" (counterattack all adjacent enemies)
```

### Visual Feedback

```
Unit Inventory Screen:
╔══════════════════════════════════════════╗
║  SGT. Sarah "Viper" Chen                 ║
╠══════════════════════════════════════════╣
║  PRIMARY WEAPON:                         ║
║    Gauss Rifle ★★★★ (Master)             ║
║    Kills: 42 | Accuracy: +8%            ║
║    Special: Controlled Burst (unlocked)  ║
║                                          ║
║  SECONDARY WEAPON:                       ║
║    Combat Knife ★★ (Proficient)          ║
║    Kills: 23 | Crit Chance: +10%        ║
║                                          ║
║  [Switch Weapons] [View Mastery Tree]    ║
╚══════════════════════════════════════════╝
```

---

## Combat Role Specialization

### Overview

Units naturally evolve based on combat behavior, gaining role-specific bonuses.

### Role Detection Algorithm

```lua
function detectCombatRole(unit)
  local kills = unit.stats.total_kills
  local overwatch_uses = unit.stats.overwatch_activations
  local support_actions = unit.stats.healing + unit.stats.buffs_applied
  
  if kills > overwatch_uses * 2 and kills > support_actions * 3 then
    return "AGGRESSIVE"
  elseif overwatch_uses > kills and overwatch_uses > support_actions then
    return "DEFENSIVE"
  elseif support_actions > kills and support_actions > overwatch_uses * 2 then
    return "SUPPORT"
  else
    return "BALANCED"
  end
end
```

### Role Bonuses

```yaml
Aggressive Role (20+ kills):
  - +15% damage to all weapons
  - +10% movement speed
  - -10% defense (glass cannon)
  - Personality: Bold, risk-taker
  - Icon: Red sword symbol

Defensive Role (20+ overwatch activations):
  - +15% armor value
  - +20% overwatch accuracy
  - -10% movement speed (methodical)
  - Personality: Cautious, reliable
  - Icon: Blue shield symbol

Support Role (20+ support actions):
  - +50% healing effectiveness
  - +2 AP when adjacent to allies
  - +10% accuracy when buffing allies
  - Personality: Team player, selfless
  - Icon: Green cross symbol

Balanced Role:
  - +5% to all stats
  - No specialization bonuses
  - Personality: Adaptable, versatile
  - Icon: Yellow star symbol
```

### Role Evolution

Roles can change over time:
- Track last 10 missions (not lifetime)
- Role shifts if behavior changes
- Bonuses adjust dynamically
- No penalties for role switching

**Example Evolution**:
```
Missions 1-10: Aggressive (lots of kills)
Missions 11-20: Balanced (varied tactics)
Missions 21-30: Defensive (adopted overwatch style)
```

---

## Cross-Training System

### Overview

Units gain skills from activities outside primary role.

### Cross-Training Mechanics

```yaml
Pilots Gaining Ground Combat Skills:
  - +0.5 Aim per 10 ground missions (battlescape)
  - +0.5 Reflex per 10 ground missions
  - +1 Strength per 20 ground missions
  - Caps at +5 per stat (prevents full conversion)

Ground Units Gaining Piloting Skills:
  - +0.5 Piloting per 10 interception missions
  - +0.5 Reflexes per 10 interception missions
  - Caps at +5 Piloting (can become backup pilots)

Scientists Gaining Combat Experience:
  - If deployed to combat (rare): +0.2 Aim per mission
  - +0.5 Intelligence per 5 missions
  - Unlock "Combat Scientist" hybrid class

Engineers Gaining Research Skills:
  - If assigned to research: +0.3 Intelligence per month
  - Unlock "Technician" hybrid class
  - Can assist both research and manufacturing
```

### Hybrid Classes

Units with cross-training unlock hybrid roles:

```yaml
Combat Pilot (Pilot + Ground Combat):
  - Piloting 50+, Aim 50+, 15+ combined missions
  - Abilities: Can pilot OR fight equally well
  - Special: "Ace Multitasker" (switch roles mid-campaign)

Pilot Sniper (Pilot + Sniper):
  - Piloting 60+, Aim 70+, 10 ground sniper kills
  - Synergy: Piloting improves sniping (+precision)
  - Special: "Eagle Eye" (spotting from air + ground)

Combat Scientist:
  - Intelligence 60+, Aim 40+, 10 combat missions
  - Abilities: Analyze enemies mid-combat (reveals weaknesses)
  - Special: "Field Research" (gain research points from kills)
```

---

## Veteran Mentorship

### Overview

Veteran units accelerate training of rookies through proximity.

### Mentorship Mechanics

```yaml
Requirements:
  - Squad has 2+ Rank 3+ units (veterans)
  - Rookie units in same squad
  - Applies during missions and base training

Effect:
  - Rookies gain +50% XP from all sources
  - Applies to mission XP and passive training
  - Stacks with Smart trait (+20% XP)
  - Max: +70% XP (mentorship + smart)

Example:
  Standard Rookie: 100 XP mission = 100 XP
  Mentored Rookie: 100 XP mission = 150 XP
  Mentored Smart Rookie: 100 XP mission = 170 XP

Benefit:
  - New recruits reach Rank 3 in ~13 missions (vs. 20)
  - Prevents "roster lock" (fear of recruiting)
  - Encourages mixed veteran/rookie squads
```

### Mentorship UI

```
Squad Composition (Deployment Screen):
╔══════════════════════════════════════════╗
║  SQUAD ALPHA - Deployment Status         ║
╠══════════════════════════════════════════╣
║  [✓] SGT Chen (Rank 5) - VETERAN         ║
║  [✓] CPL Torres (Rank 4) - VETERAN       ║
║  [✓] PFC Kim (Rank 2) - STANDARD         ║
║  [✓] RCT Anderson (Rank 1) - ROOKIE      ║
║  [✓] RCT Williams (Rank 1) - ROOKIE      ║
║                                          ║
║  ⚠ MENTORSHIP ACTIVE:                    ║
║    2 veterans provide +50% XP to:        ║
║    - RCT Anderson                        ║
║    - RCT Williams                        ║
║                                          ║
║  [Deploy Squad] [Reassign Units]         ║
╚══════════════════════════════════════════╝
```

---

## Training Facilities

### Accelerated Training Facility

```yaml
Training Grounds (2×2):
  Cost: 75K credits
  Build Time: 20 days
  Maintenance: 5K per month
  
  Effect:
    - Units assigned gain +10 XP per day (passive)
    - Maximum 10 units can train simultaneously
    - No combat risk (safe advancement)
    - Can specify training focus (weapon type)
  
  Strategic Use:
    - Fast-track critical roles (medics, snipers)
    - Recover wounded units (gain XP while healing)
    - Prepare reserves (bench units stay sharp)
    - Emergency recruitment prep (rapid onboarding)

Advanced Academy (3×3):
  Cost: 200K credits
  Build Time: 40 days
  Maintenance: 15K per month
  Prerequisites: Research "Elite Training"
  
  Effect:
    - Units assigned gain +20 XP per day
    - Can train up to 20 units
    - Unlock "Elite Training" missions (gain bonus XP)
    - Can fast-track to Rank 3 (bypass Rank 1-2)
  
  Strategic Use:
    - Rapid replacement for casualties
    - Create specialist units quickly
    - Late-game recruitment acceleration
```

### Training Costs

```yaml
Passive Training (Free):
  - Units at base gain +2 XP per day
  - Represents maintenance training
  - Slow but free

Training Grounds (5K monthly):
  - +10 XP per day per unit
  - Cost: 500 credits per unit per month
  - Break-even: ~15 days = 150 XP gained

Advanced Academy (15K monthly):
  - +20 XP per day per unit
  - Cost: 750 credits per unit per month
  - Break-even: ~10 days = 200 XP gained

Combat Missions (Free XP, Risk):
  - 60-120 XP per mission
  - Risk: Unit casualties, injuries
  - Best XP per time, but dangerous
```

---

## Achievement-Based Traits

### Overview

Units earn traits through gameplay achievements, not random chance.

### Earnable Traits

```yaml
"Deadeye" (Sniper Specialist):
  Unlock: 25 headshot kills with sniper rifle
  Effect: +15% headshot damage, +10% sniper accuracy
  Visual: Crosshair icon next to name

"Tank" (Survivalist):
  Unlock: Take 500+ damage without dying (cumulative)
  Effect: +20% health, +10% armor
  Visual: Shield icon

"Medic" (Support Specialist):
  Unlock: Heal 1,000+ HP (cumulative)
  Effect: +100% healing effectiveness, +2 medikit charges
  Visual: Red cross icon

"Demolitions Expert":
  Unlock: 30 kills with explosives
  Effect: +30% explosive damage, +1 grenade capacity
  Visual: Bomb icon

"Ghost" (Stealth Specialist):
  Unlock: Complete 10 missions without being detected
  Effect: +50% concealment, enemies detect 2 turns later
  Visual: Shadow icon

"Berserker" (Aggressive):
  Unlock: 50 melee kills
  Effect: +30% melee damage, melee attacks cost -1 AP
  Visual: Red fist icon

"Overwatch Specialist":
  Unlock: 100 overwatch kills
  Effect: +30% overwatch accuracy, free overwatch per turn
  Visual: Eye icon

"Leader" (Commander):
  Unlock: Lead 20 successful missions
  Effect: All nearby allies +10% accuracy, +1 morale
  Visual: Star icon
```

### Trait Stacking

Units can have multiple traits:
- Maximum 3 active traits simultaneously
- Player chooses which to equip (if more than 3 earned)
- Creates build diversity (sniper/tank vs. sniper/ghost)

---

## Legacy System

### Overview

When units die, they leave legacy bonuses for their replacements.

### Legacy Mechanics

```yaml
Fallen Hero Memorial (Base Facility 2×2):
  Cost: 50K credits
  Effect: Memorialize fallen units, grant legacy bonuses
  
  Legacy Bonuses:
    - Units gain +10% XP if same class as fallen hero
    - Fallen hero's best weapon grants +5% accuracy to all users
    - Morale boost when avenging fallen comrade
  
  Example:
    SGT Chen (Sniper, Rank 5) dies in mission
    Memorial Effect:
      - All future snipers gain +10% XP
      - Chen's rifle grants +5% accuracy to any user
      - Units on revenge mission gain +20% damage vs. killers
```

### Memorial UI

```
╔══════════════════════════════════════════╗
║       MEMORIAL WALL                      ║
╠══════════════════════════════════════════╣
║  SGT Sarah "Viper" Chen                  ║
║    Sniper Specialist, Rank 5             ║
║    KIA: Month 9, Mission "Last Stand"    ║
║    Kills: 127 | Missions: 45             ║
║    Legacy: All snipers +10% XP           ║
║                                          ║
║  CPL Marcus "Ironside" Torres            ║
║    Heavy Weapons, Rank 4                 ║
║    KIA: Month 11, Mission "Alien Base"   ║
║    Kills: 89 | Missions: 38              ║
║    Legacy: All heavies +10% XP           ║
║                                          ║
║  [View Full Memorial] [Pay Respects]     ║
╚══════════════════════════════════════════╝
```

---

## Technical Implementation

### Progression Tracking

```lua
-- engine/units/progression_manager.lua

ProgressionManager = {
  units = {}, -- All unit progression data
  weapon_mastery = {}, -- Mastery per unit per weapon
  combat_roles = {} -- Role tracking per unit
}

function ProgressionManager:awardXP(unit, xp_amount, source)
  -- Base XP
  local total_xp = xp_amount
  
  -- Smart trait bonus
  if unit:hasTrait("Smart") then
    total_xp = total_xp * 1.20
  end
  
  -- Mentorship bonus
  if self:hasVeteranMentors(unit.squad) then
    total_xp = total_xp * 1.50
  end
  
  -- Apply XP
  unit.experience = unit.experience + total_xp
  
  -- Check for rank up
  if self:checkRankUp(unit) then
    self:promoteUnit(unit)
  end
  
  -- Log for analytics
  Analytics:recordXPGain(unit, total_xp, source)
end

function ProgressionManager:trackWeaponMastery(unit, weapon_type, kill_count)
  if not self.weapon_mastery[unit.id] then
    self.weapon_mastery[unit.id] = {}
  end
  
  if not self.weapon_mastery[unit.id][weapon_type] then
    self.weapon_mastery[unit.id][weapon_type] = 0
  end
  
  self.weapon_mastery[unit.id][weapon_type] = 
    self.weapon_mastery[unit.id][weapon_type] + kill_count
  
  -- Check for mastery level up
  local mastery_level = self:getMasteryLevel(
    self.weapon_mastery[unit.id][weapon_type]
  )
  
  if mastery_level > unit.weapon_mastery_levels[weapon_type] then
    self:unlockMasteryBonus(unit, weapon_type, mastery_level)
  end
end

function ProgressionManager:getMasteryLevel(kill_count)
  if kill_count >= 50 then return 5 -- Legendary
  elseif kill_count >= 40 then return 4 -- Master
  elseif kill_count >= 30 then return 3 -- Expert
  elseif kill_count >= 20 then return 2 -- Proficient
  elseif kill_count >= 10 then return 1 -- Competent
  else return 0 -- Novice
  end
end

function ProgressionManager:detectCombatRole(unit)
  -- Analyze last 10 missions
  local recent_missions = self:getRecentMissions(unit, 10)
  
  local total_kills = 0
  local total_overwatch = 0
  local total_support = 0
  
  for _, mission in ipairs(recent_missions) do
    total_kills = total_kills + mission.kills
    total_overwatch = total_overwatch + mission.overwatch_uses
    total_support = total_support + mission.support_actions
  end
  
  -- Determine role
  if total_kills > total_overwatch * 2 and total_kills > total_support * 3 then
    return "AGGRESSIVE"
  elseif total_overwatch > total_kills and total_overwatch > total_support then
    return "DEFENSIVE"
  elseif total_support > total_kills and total_support > total_overwatch * 2 then
    return "SUPPORT"
  else
    return "BALANCED"
  end
end

function ProgressionManager:checkRankUp(unit)
  local xp_required = self:getXPForNextRank(unit.rank)
  return unit.experience >= xp_required
end

function ProgressionManager:getXPForNextRank(current_rank)
  local xp_thresholds = {
    [0] = 100,   -- Rank 1
    [1] = 250,   -- Rank 2
    [2] = 500,   -- Rank 3
    [3] = 800,   -- Rank 4
    [4] = 1200,  -- Rank 5
    [5] = 1700   -- Rank 6
  }
  
  return xp_thresholds[current_rank] or 9999
end
```

---

## Conclusion

The Unit Progression & Alternative Advancement System makes unit development accessible and rewarding throughout the campaign. By reducing XP requirements, adding weapon mastery, and creating emergent role specialization, units feel like they constantly progress without tedious grinding.

**Key Success Metrics**:
- 70%+ players achieve Rank 4 (vs. 30% current)
- 40%+ players achieve Rank 5 (vs. 10% current)
- 15%+ players achieve Rank 6 (vs. 2% current)
- Weapon mastery engagement: 80%+ players actively manage
- Role specialization: 90%+ units develop clear identity

**Implementation Priority**: HIGH (Tier 2)  
**Estimated Development Time**: 1-2 weeks  
**Dependencies**: Units.md, Battlescape.md  
**Risk Level**: Low (tuning existing systems)

---

**Document Status**: Design Proposal - Ready for Review  
**Next Steps**: Implement XP rebalance, prototype mastery system, playtest  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28

