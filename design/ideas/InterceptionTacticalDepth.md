# Interception Tactical Depth System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: LOW-MEDIUM  
> **Related Systems**: Interception.md, Crafts.md, Pilots.md, AI.md

## Table of Contents

- [Overview](#overview)
- [Design Decision: Mini-Game vs. Tactical Layer](#design-decision-mini-game-vs-tactical-layer)
- [Option A: Enhanced Mini-Game](#option-a-enhanced-mini-game)
- [Option B: Full Tactical Layer](#option-b-full-tactical-layer)
- [Hybrid Approach](#hybrid-approach-recommended)
- [Environmental Systems](#environmental-systems)
- [Craft Loadouts & Customization](#craft-loadouts--customization)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

Addresses **interception layer lacks tactical depth** by either streamlining as fast-paced mini-game OR expanding into full tactical layer with positioning and special abilities.

**Core Goals**:
- Decide: Mini-game (fast) OR tactical layer (deep)?
- If mini-game: Add auto-resolve, faster pacing, cinematic flair
- If tactical: Add 3D positioning, special abilities, environment
- Create engaging interception experience (not skip-able tedium)

### Current State Analysis

**Problems**:
- Formulaic card-game combat (fire → wait → repeat)
- No positioning mechanics (just altitude sectors)
- Limited tactical options (fire, evade, retreat)
- No skill expression (optimal strategy obvious)
- Players want to skip to battlescape

---

## Design Decision: Mini-Game vs. Tactical Layer

### Decision Framework

```yaml
Choose MINI-GAME if:
  - Interception is gate to battlescape (qualification phase)
  - Players primarily interested in ground combat
  - Development resources limited
  - Fast pacing more important than depth
  
Choose TACTICAL LAYER if:
  - Interception is core gameplay pillar
  - Target audience enjoys aerial combat depth
  - Development resources available for polish
  - Want replayability in interception itself

HYBRID APPROACH (Recommended):
  - Default: Enhanced mini-game with auto-resolve
  - Optional: Tactical mode for players who want depth
  - Both modes share same underlying systems
  - Player chooses preference (accessibility + depth)
```

---

## Option A: Enhanced Mini-Game

### Philosophy

**"Get to the good stuff fast, but make it satisfying."**

### Core Improvements

```yaml
1. Auto-Resolve System:
   - Calculate outcome based on stats + random variance
   - Show cinematic replay (3D visualization, 10 seconds)
   - Player can watch or skip
   - Provides instant gratification
   
2. Quick-Time Events (Optional):
   - Critical moments pause for player input
   - Example: "Enemy missile incoming! [Dodge] or [Counter]?"
   - 3-5 seconds to decide
   - Adds skill expression without complexity
   
3. Turn Duration Reduction:
   - Current: 10-15 turns per interception
   - Proposed: 5 turns max (faster resolution)
   - Scale damage accordingly (2× damage per hit)
   
4. Cinematic Flair:
   - Dynamic camera angles during combat
   - Missile trails and explosions (visual feedback)
   - Pilot voice lines ("I've got tone!" "Fox 2!")
   - Epic music during critical moments
```

### Auto-Resolve Mechanics

```yaml
Auto-Resolve Algorithm:

Step 1: Calculate Power Differential
  Player_Power = (Craft_Stats × Pilot_Bonuses) + Equipment_Value
  Enemy_Power = (UFO_Stats × AI_Bonuses) + Alien_Tech_Level
  
  Power_Ratio = Player_Power / Enemy_Power

Step 2: Determine Outcome Probability
  if Power_Ratio >= 2.0:
    Win_Chance = 95% (overwhelming advantage)
  elseif Power_Ratio >= 1.5:
    Win_Chance = 80% (strong advantage)
  elseif Power_Ratio >= 1.0:
    Win_Chance = 60% (slight advantage)
  elseif Power_Ratio >= 0.75:
    Win_Chance = 40% (even odds)
  else:
    Win_Chance = 20% (disadvantage)

Step 3: Roll Outcome
  Roll = random(0, 100)
  
  if Roll <= Win_Chance:
    Outcome = "VICTORY"
    Damage_Taken = random(0, 30)% of max hull
  else:
    Outcome = "DEFEAT" or "RETREAT"
    Damage_Taken = random(40, 70)% of max hull

Step 4: Apply Results
  - Update craft hull
  - Award XP to pilot
  - Generate salvage (if victory)
  - Show cinematic replay (10 seconds)
```

### Quick-Time Events

```yaml
QTE Scenarios:

Missile Lock Warning (15% chance per turn):
  Player has 3 seconds to react:
    [A] Dodge (+30% dodge this turn)
    [B] Chaff (+50% dodge, costs chaff item)
    [C] Counter-Fire (attempt to shoot down missile)
  
  No Input: Standard dodge chance applies

Critical Damage Alert (when hull <30%):
  Player has 3 seconds to react:
    [A] Emergency Repairs (restore 20% hull, once per battle)
    [B] Aggressive Rush (all-in attack, +50% damage, -50% defense)
    [C] Retreat (attempt to flee, success based on pilot skill)

Enemy Vulnerable Window (when enemy hull <40%):
  Player has 3 seconds to react:
    [A] Finish Him! (guaranteed hit, 2× damage)
    [B] Capture Attempt (try to disable for salvage bonus)
    [C] Standard Attack (normal hit chance)
```

### Implementation Cost

- Development Time: 1 week
- Complexity: Low (streamlines existing system)
- Risk: Low (improves pacing, no major changes)

---

## Option B: Full Tactical Layer

### Philosophy

**"Make interception as deep as battlescape, different flavor."**

### 3D Positioning System

```yaml
Combat Arena:
  - 5×5×3 hex grid (width × depth × altitude)
  - Total: 75 hexes (3 altitude layers)
  - Movement: 2-4 hexes per turn (craft speed)
  - Range: Weapons have optimal range (5-15 hexes)

Altitude Mechanics:
  - Low (0-1000m): Ground clutter, radar interference
  - Medium (1000-5000m): Optimal combat altitude
  - High (5000-10000m): Thin air, energy weapons advantaged
  
  Altitude Effects:
    - Diving (high → low): +2 movement, +20% accuracy (gravity assist)
    - Climbing (low → high): -1 movement, -10% accuracy (energy cost)
    - Same altitude: Standard combat (no modifiers)

Positioning Tactics:
  - Flanking: Attack from side/rear (+20% accuracy, ignore evasion)
  - Head-On: Mutual fire exchange (standard accuracy)
  - Tailing: Follow behind enemy (+30% accuracy, -20% enemy accuracy)
  - Boom & Zoom: Dive attack then climb away (hit-and-run)
```

### Special Abilities System

```yaml
Pilot-Activated Abilities:

"Barrel Roll" (2 AP, 5 turn cooldown):
  - +40% dodge for 1 turn
  - Cannot attack same turn
  - Use when low on hull or overwhelmed

"Immelman Turn" (3 AP, 3 turn cooldown):
  - Reverse direction instantly (180° turn)
  - Gain altitude (+1 level)
  - Next attack +15% accuracy (momentum bonus)

"Cobra Maneuver" (4 AP, once per battle):
  - Advanced maneuver, requires Piloting 60+
  - Effect: Enemy overshoots, automatic flank position
  - Enemy cannot attack next turn (disoriented)
  - High risk: 20% chance of stall (lose 1 turn)

"Afterburner" (2 AP, 3 turn cooldown):
  - +3 movement this turn
  - +20% dodge (speed bonus)
  - Cost: 20 fuel consumed instantly

"Weapons Free" (4 AP, 2 turn cooldown):
  - Fire all weapons simultaneously
  - 3× damage potential
  - -20% accuracy (overwhelming fire)

"Electronic Warfare" (3 AP, 5 turn cooldown):
  - Jam enemy sensors
  - Enemy -30% accuracy for 2 turns
  - Requires EW pod equipped
```

### Environmental Interactions

```yaml
Weather Effects:

Clear Skies:
  - No modifiers (baseline)
  
Clouds:
  - Provide concealment (-20% enemy accuracy when inside)
  - Limit visibility (detection range -3 hexes)
  - Ambush opportunities (hidden until enemy close)

Storm:
  - All craft -30% accuracy (turbulence)
  - +20% evasion (unpredictable movements)
  - Lightning strikes deal 10 damage randomly (5% chance per turn)

Fog:
  - Detection range -5 hexes (limited visibility)
  - Radar effectiveness -50%
  - Ambush ideal (surprise attacks +30% damage)

Night:
  - Visual detection range -6 hexes
  - Radar becomes primary sensor
  - Stealth craft advantage (+30% concealment)

Terrain Masking:

Mountains:
  - Provide cover if craft flies low
  - Enemy line of sight blocked (must fly around or over)
  - Risk: Collision if flying too low (10% chance, 20 damage)

Urban Areas:
  - Buildings provide cover (similar to mountains)
  - Civilian casualties risk (-karma if stray shots hit buildings)

Open Ocean:
  - No cover, no terrain
  - Long-range engagement favored (sniping)

Canyons:
  - Tight maneuvering space (-1 movement)
  - Dogfighting advantage (close combat +20% accuracy)
```

### Range & Weapon Systems

```yaml
Weapon Range Mechanics:

Guns (Optimal: 3-5 hexes):
  - Close range: High accuracy, high damage
  - Long range: Rapid accuracy falloff
  - Ammo: Limited (30-50 rounds)

Missiles (Optimal: 8-12 hexes):
  - Medium range: Tracking missiles
  - Turn delay: 1-2 turns to impact (can be evaded)
  - Ammo: Very limited (4-8 missiles)

Lasers (Optimal: 10-15 hexes):
  - Long range: Instant hit (no travel time)
  - Energy cost: Drains power cells
  - Ammo: Infinite (but recharge delay 2 turns)

Plasma (Optimal: 6-10 hexes):
  - Medium range: Devastating damage
  - Heat buildup: -10% accuracy per shot (cumulative)
  - Ammo: Limited (10-15 shots)

Range Calculation:
  Distance = hex_distance(shooter, target)
  
  if Distance <= Optimal_Min:
    Accuracy_Modifier = -20% (too close)
  elseif Distance >= Optimal_Min and Distance <= Optimal_Max:
    Accuracy_Modifier = 0% (optimal)
  else:
    Accuracy_Modifier = -(Distance - Optimal_Max) × 5% per hex
```

### Implementation Cost

- Development Time: 4-6 weeks
- Complexity: High (new systems, 3D positioning, AI)
- Risk: High (requires extensive balance testing)

---

## Hybrid Approach (Recommended)

### Best of Both Worlds

```yaml
Default Mode: Enhanced Mini-Game
  - Fast auto-resolve available
  - Cinematic replays
  - QTEs for engagement
  - 90% of players use this (casual experience)

Optional Mode: Full Tactical
  - Toggle in settings: "Tactical Interception Mode"
  - 3D positioning grid
  - Special abilities unlocked
  - 10% of players use this (hardcore fans)

Shared Systems:
  - Same underlying combat calculator
  - Same pilot progression
  - Same craft stats
  - Both modes award same XP/rewards

Benefits:
  - Accessibility (casual players not forced into complexity)
  - Depth (hardcore players get engaging content)
  - Development efficiency (share code between modes)
  - Player choice (respect different playstyles)
```

### Mode Selection UI

```
╔══════════════════════════════════════════╗
║     INTERCEPTION MODE SELECTION          ║
╠══════════════════════════════════════════╣
║                                          ║
║  [○] Quick Mode (Auto-Resolve)           ║
║      Fast-paced, cinematic replays       ║
║      Recommended for most players        ║
║                                          ║
║  [ ] Tactical Mode (Manual Control)      ║
║      Full 3D positioning and abilities   ║
║      For experienced pilots only         ║
║                                          ║
║  You can change this anytime in settings ║
║                                          ║
║  [Confirm Selection]                     ║
╚══════════════════════════════════════════╝
```

---

## Environmental Systems

### Dynamic Weather

```yaml
Weather Generation:
  - Roll weather at mission start
  - 60% clear, 20% clouds, 10% storm, 10% fog
  - Weather affects all craft equally (balanced)

Weather Forecast (Intelligence 50+):
  - View weather forecast before deployment
  - Strategic planning (bring appropriate equipment)
  - Example: Storm forecast → bring EW pod for jamming

Seasonal Weather:
  - Winter: More storms, icing risk (
-10% accuracy)
  - Summer: More clear days, heat haze (-5% long-range accuracy)
  - Spring/Fall: Balanced weather patterns
```

### Tactical Environment Features

```yaml
Sun Position:
  - Attacking from sun direction: +15% accuracy (enemy blinded)
  - Defending with sun behind: -15% accuracy (glare)
  - Rotate dynamically during battle (sun moves)

Cloud Banks:
  - Large cloud formations on 5×5×3 grid
  - Provide concealment (-30% detection)
  - Can hide inside for ambush setup
  - Limit visibility (3 hex radius inside cloud)

Terrain Elevation:
  - Mountains create line-of-sight blockers
  - Must fly over (costs movement) or around
  - Low-altitude flight through valleys (risky but stealthy)
```

---

## Craft Loadouts & Customization

### Pre-Mission Loadout System

```yaml
Craft Equipment Slots:

Primary Weapon (1 slot):
  - Autocannon (fast fire, low damage)
  - Heavy Cannon (slow fire, high damage)
  - Laser Cannon (infinite ammo, medium damage)
  - Plasma Cannon (limited ammo, devastating)

Secondary Weapon (1 slot):
  - Air-to-Air Missiles (tracking, medium range)
  - Heavy Missiles (dumbfire, long range, huge damage)
  - Rockets (unguided, short range, area damage)

Utility Slot (1 slot):
  - Chaff Dispenser (dodge bonus vs. missiles)
  - Flares (distract heat-seeking missiles)
  - Electronic Warfare Pod (jam enemy sensors)
  - Fuel Tank (extended range, +50% fuel)
  - Armor Plating (passive +20% hull)

Loadout Examples:

Dogfighter Build:
  - Primary: Autocannon (high rate of fire)
  - Secondary: Air-to-Air Missiles (tracking)
  - Utility: Chaff Dispenser (defense)
  - Role: Close-range aerial superiority

Sniper Build:
  - Primary: Laser Cannon (long range, instant)
  - Secondary: Heavy Missiles (long range, high damage)
  - Utility: Electronic Warfare Pod (accuracy debuff)
  - Role: Long-range precision strikes

Tank Build:
  - Primary: Heavy Cannon (high damage per shot)
  - Secondary: Rockets (area damage)
  - Utility: Armor Plating (survivability)
  - Role: Frontline brawler

Scout Build:
  - Primary: Autocannon (light weapon)
  - Secondary: None (save weight)
  - Utility: Fuel Tank (extended range)
  - Role: Reconnaissance and fast deployment
```

---

## Technical Implementation

### Hybrid System Architecture

```lua
-- engine/interception/interception_controller.lua

InterceptionController = {
  mode = "QUICK", -- or "TACTICAL"
  combat_grid = nil,
  quick_combat_calculator = nil
}

function InterceptionController:init(player_craft, enemy_craft, mode)
  self.mode = mode or GameState.settings.interception_mode
  
  if self.mode == "QUICK" then
    self:initQuickMode(player_craft, enemy_craft)
  else
    self:initTacticalMode(player_craft, enemy_craft)
  end
end

function InterceptionController:initQuickMode(player_craft, enemy_craft)
  -- Auto-resolve system
  local outcome = self.quick_combat_calculator:resolve(player_craft, enemy_craft)
  
  -- Show cinematic
  Cinematics:playInterceptionReplay(outcome, 10) -- 10 seconds
  
  -- Apply results
  self:applyOutcome(player_craft, enemy_craft, outcome)
  
  -- Check for QTE moments
  if outcome.qte_moments then
    for _, qte in ipairs(outcome.qte_moments) do
      GUI:showQTE(qte, 3) -- 3 second timer
    end
  end
end

function InterceptionController:initTacticalMode(player_craft, enemy_craft)
  -- Create 3D combat grid
  self.combat_grid = HexGrid3D:new(5, 5, 3) -- 5×5×3 grid
  
  -- Place craft on grid
  self.combat_grid:placeCraft(player_craft, {x = 1, y = 1, z = 1})
  self.combat_grid:placeCraft(enemy_craft, {x = 4, y = 4, z = 2})
  
  -- Load environment
  local weather = self:generateWeather()
  self.combat_grid:applyWeather(weather)
  
  -- Start tactical turn system
  TacticalCombat:beginCombat(self.combat_grid, player_craft, enemy_craft)
end

function InterceptionController:generateWeather()
  local roll = math.random(1, 100)
  
  if roll <= 60 then
    return {type = "CLEAR", modifiers = {}}
  elseif roll <= 80 then
    return {type = "CLOUDS", modifiers = {accuracy = -10, concealment = 20}}
  elseif roll <= 90 then
    return {type = "STORM", modifiers = {accuracy = -30, evasion = 20}}
  else
    return {type = "FOG", modifiers = {detection_range = -5}}
  end
end
```

---

## Conclusion

The Interception Tactical Depth System offers flexibility: streamlined mini-game for accessibility OR full tactical layer for depth. The recommended hybrid approach respects player preferences while maximizing development efficiency.

**Key Success Metrics**:
- Mode usage: 70-90% quick, 10-30% tactical (both viable)
- Player satisfaction: 80%+ enjoy interceptions (not skip-able tedium)
- Engagement time: Quick mode <1 minute, Tactical mode 3-5 minutes
- Replayability: Tactical mode adds variety to air combat

**Implementation Priority**: LOW-MEDIUM (Tier 3)  
**Estimated Development Time**: 1 week (quick) OR 4-6 weeks (tactical) OR 3 weeks (hybrid)  
**Dependencies**: Interception.md, Crafts.md, Pilots.md  
**Risk Level**: Low (quick) OR High (tactical) OR Medium (hybrid)

**Recommendation**: Implement **hybrid approach** - quick mode first (1 week), tactical mode later as DLC/expansion (4 weeks additional).

---

**Document Status**: Design Proposal - Awaiting Decision  
**Next Steps**: Choose mode (mini-game/tactical/hybrid), prototype selected approach  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28
# Combat Formula Documentation & Balance System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: HIGH  
> **Related Systems**: Battlescape.md, Units.md, Items.md, AI.md

## Table of Contents

- [Overview](#overview)
- [Damage Calculation System](#damage-calculation-system)
- [Accuracy Formula](#accuracy-formula)
- [Status Effect System](#status-effect-system)
- [Critical Hit System](#critical-hit-system)
- [Cover & Positioning](#cover--positioning)
- [Action Point Economics](#action-point-economics)
- [Balance Verification Tools](#balance-verification-tools)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

Addresses **combat formula documentation gaps** by explicitly defining all damage, accuracy, status effect, and combat calculations with complete formulas and examples.

**Core Goals**:
- Document every combat formula (no ambiguity)
- Define damage reduction mechanics (armor vs. damage types)
- Specify accuracy calculations (distance, cover, modifiers)
- Detail status effect durations (turns, conditions, removal)
- Provide balance verification tools (prevent broken combinations)

---

## Damage Calculation System

### Base Damage Formula

```yaml
Final Damage = Base_Weapon_Damage - Effective_Armor + Random_Variance

Where:
  Base_Weapon_Damage = Weapon stat from Items.md
  Effective_Armor = Armor_Value × Damage_Type_Modifier
  Random_Variance = ±10% of Base_Weapon_Damage

Minimum Damage = 1 (always deal at least 1 damage if hit)
Maximum Damage = Base_Weapon_Damage × 1.10 (with variance)
```

### Damage Type Modifiers

```yaml
Armor Effectiveness vs. Damage Types:

Kinetic Damage (Rifles, Pistols, Melee):
  - Armor Effectiveness: 100%
  - Formula: Effective_Armor = Armor_Value × 1.00
  - Example: 10 armor reduces kinetic damage by 10

Energy Damage (Lasers, Plasma):
  - Armor Effectiveness: 50%
  - Formula: Effective_Armor = Armor_Value × 0.50
  - Example: 10 armor reduces energy damage by 5

Explosive Damage (Grenades, Rockets):
  - Armor Effectiveness: 25%
  - Formula: Effective_Armor = Armor_Value × 0.25
  - Example: 10 armor reduces explosive damage by 2.5 (rounds to 3)

Psionic Damage (Mind Attacks):
  - Armor Effectiveness: 0%
  - Formula: Effective_Armor = 0 (armor ignored completely)
  - Example: 10 armor reduces psionic damage by 0

Hazard Damage (Fire, Acid, Poison):
  - Armor Effectiveness: 75%
  - Formula: Effective_Armor = Armor_Value × 0.75
  - Example: 10 armor reduces hazard damage by 7.5 (rounds to 8)
```

### Damage Calculation Examples

**Example 1: Rifle vs. Light Armor**
```
Weapon: Assault Rifle (25 base damage, kinetic)
Target: Soldier with 5 armor
Damage Type Modifier: 100% (kinetic vs. armor)

Calculation:
  Effective_Armor = 5 × 1.00 = 5
  Base_Damage = 25
  Random_Variance = ±2.5 (10% of 25)
  
  Roll = 0 (neutral variance)
  Final_Damage = 25 - 5 + 0 = 20 damage

Result: Target takes 20 damage
```

**Example 2: Plasma Rifle vs. Heavy Armor**
```
Weapon: Plasma Rifle (35 base damage, energy)
Target: Heavy Trooper with 15 armor
Damage Type Modifier: 50% (energy vs. armor)

Calculation:
  Effective_Armor = 15 × 0.50 = 7.5 (rounds to 8)
  Base_Damage = 35
  Random_Variance = ±3.5 (10% of 35)
  
  Roll = +2 (positive variance)
  Final_Damage = 35 - 8 + 2 = 29 damage

Result: Target takes 29 damage
```

**Example 3: Grenade vs. Heavy Armor**
```
Weapon: Frag Grenade (40 base damage, explosive)
Target: Heavy Trooper with 15 armor
Damage Type Modifier: 25% (explosive vs. armor)

Calculation:
  Effective_Armor = 15 × 0.25 = 3.75 (rounds to 4)
  Base_Damage = 40
  Random_Variance = ±4 (10% of 40)
  
  Roll = -3 (negative variance)
  Final_Damage = 40 - 4 - 3 = 33 damage

Result: Target takes 33 damage
```

**Example 4: Minimum Damage Edge Case**
```
Weapon: Pistol (12 base damage, kinetic)
Target: Tank with 20 armor
Damage Type Modifier: 100% (kinetic vs. armor)

Calculation:
  Effective_Armor = 20 × 1.00 = 20
  Base_Damage = 12
  Random_Variance = ±1.2 (10% of 12)
  
  Roll = -1 (negative variance)
  Calculated_Damage = 12 - 20 - 1 = -9
  
  Minimum_Damage_Rule = max(1, Calculated_Damage)
  Final_Damage = 1 damage (floor)

Result: Target takes 1 damage (armor too strong, but always min 1)
```

---

## Accuracy Formula

### Base Hit Chance Calculation

```yaml
Final_Hit_Chance = Base_Accuracy + Aim_Bonus + Equipment_Bonus - 
                   Distance_Penalty - Cover_Penalty - Movement_Penalty +
                   Height_Advantage + Flanking_Bonus + Status_Modifiers

Clamped to: min(5%, max(Final_Hit_Chance, 95%))

Where:
  Base_Accuracy = Weapon accuracy stat (50-85% typical)
  Aim_Bonus = (Unit_Aim_Stat - 6) × 5% (6-12 stat range = 0-30%)
  Equipment_Bonus = Scope/attachments (+0-15%)
  Distance_Penalty = (Current_Range - Optimal_Range) × 2% per hex
  Cover_Penalty = Half cover -20%, Full cover -40%
  Movement_Penalty = Moved this turn -30%, Dashed -50%
  Height_Advantage = +10% if attacking from higher elevation
  Flanking_Bonus = +20% if target has no cover from your angle
  Status_Modifiers = Sum of all status effects (±5-30%)
```

### Detailed Accuracy Components

**Aim Bonus Calculation**:
```yaml
Unit Aim Stat Range: 6-12 (base stats)

Aim Stat → Bonus:
  6: +0%  (baseline, no training)
  7: +5%
  8: +10%
  9: +15%
  10: +20%
  11: +25%
  12: +30% (elite marksman)

Formula: (Aim_Stat - 6) × 5%
```

**Distance Penalty Calculation**:
```yaml
Optimal Range (weapon-dependent):
  - Shotgun: 4 hexes
  - Pistol: 8 hexes
  - Rifle: 15 hexes
  - Sniper Rifle: 25 hexes

Penalty Formula:
  If Current_Range <= Optimal_Range:
    Distance_Penalty = 0% (no penalty)
  
  If Current_Range > Optimal_Range:
    Distance_Penalty = (Current_Range - Optimal_Range) × 2% per hex
    
Example:
  Sniper Rifle (optimal 25 hexes) at 30 hexes
  Penalty = (30 - 25) × 2% = 10% penalty
  
  Shotgun (optimal 4 hexes) at 10 hexes
  Penalty = (10 - 4) × 2% = 12% penalty
```

**Cover Penalties**:
```yaml
No Cover:
  - Penalty: 0%
  - Unit fully exposed

Half Cover (low wall, sandbags):
  - Penalty: -20% hit chance
  - Target partially obscured

Full Cover (building, vehicle):
  - Penalty: -40% hit chance
  - Target mostly hidden

Flank Shot (no cover from attack angle):
  - Bonus: +20% hit chance
  - Cover ignored from this angle
```

### Accuracy Examples

**Example 1: Easy Shot**
```
Weapon: Rifle (70% base accuracy, 15 hex optimal)
Shooter: Unit with Aim 10 (+20%)
Target: 10 hexes away, no cover, standing still
Conditions: Normal (no modifiers)

Calculation:
  Base_Accuracy = 70%
  Aim_Bonus = +20%
  Equipment = 0%
  Distance = 0% (within optimal)
  Cover = 0% (none)
  Movement = 0% (standing)
  Height = 0% (level ground)
  Flanking = 0% (no cover to flank)
  Status = 0%
  
  Final = 70 + 20 = 90%
  Clamped = 90% (within 5-95% range)

Result: 90% chance to hit
```

**Example 2: Difficult Shot**
```
Weapon: Sniper Rifle (85% base, 25 hex optimal)
Shooter: Unit with Aim 8 (+10%), moved this turn
Target: 30 hexes away, full cover, higher elevation
Conditions: Shooter at disadvantage

Calculation:
  Base_Accuracy = 85%
  Aim_Bonus = +10%
  Equipment = +10% (scope)
  Distance = -10% (30-25 = 5 hexes over optimal × 2%)
  Cover = -40% (full cover)
  Movement = -30% (moved)
  Height = -10% (target higher, shooter disadvantaged)
  Flanking = 0%
  Status = 0%
  
  Final = 85 + 10 + 10 - 10 - 40 - 30 - 10 = 15%
  Clamped = 15% (within 5-95% range)

Result: 15% chance to hit (very difficult)
```

**Example 3: Flanking Shot**
```
Weapon: Rifle (70% base, 15 hex optimal)
Shooter: Unit with Aim 12 (+30%), flanking position
Target: 12 hexes away, full cover (but flanked), stationary
Conditions: Flanking negates cover

Calculation:
  Base_Accuracy = 70%
  Aim_Bonus = +30%
  Equipment = 0%
  Distance = 0% (within optimal)
  Cover = 0% (ignored due to flanking)
  Movement = 0%
  Height = +10% (shooter on high ground)
  Flanking = +20%
  Status = 0%
  
  Final = 70 + 30 + 10 + 20 = 130%
  Clamped = 95% (capped at maximum)

Result: 95% chance to hit (nearly guaranteed)
```

---

## Status Effect System

### Status Effect Definitions

```yaml
Status Effects (Complete List):

Stunned:
  Duration: 1-3 turns (damage-based)
  Effect: -2 AP (lose entire turn)
  Removal: Time expires OR Medikit stimulant
  Stacking: Refreshes duration (doesn't stack)
  
  Duration Calculation:
    Stun_Turns = floor(Stun_Damage / Unit_Max_HP × 3)
    Min = 1 turn, Max = 3 turns
  
  Example:
    Unit with 50 HP takes 25 stun damage
    Duration = floor(25/50 × 3) = floor(1.5) = 1 turn

Panicked:
  Duration: Until morale restored
  Effect: -1 AP, unit may flee or shoot randomly
  Removal: Leadership ability OR mission success
  Stacking: No (binary state)
  
  Panic Trigger:
    - Morale drops to 0
    - Ally killed nearby (15% chance)
    - Surrounded by enemies (30% chance)

Burning:
  Duration: 3 turns
  Effect: 5 damage per turn (DoT)
  Removal: Water hex OR Medikit foam OR 3 turns expire
  Stacking: Yes (multiple fire sources add duration)
  
  Example:
    Turn 1: Take 5 damage (burning)
    Turn 2: Hit by second incendiary (duration refreshes to 3)
    Turn 3: Take 5 damage (burning)
    Turn 4: Take 5 damage (burning)
    Turn 5: Take 5 damage (burning, last turn)
    Turn 6: Effect ends

Poisoned:
  Duration: 5 turns
  Effect: 3 damage per turn (DoT), -10% accuracy
  Removal: Antidote OR 5 turns expire
  Stacking: No (refreshes duration)

Bleeding:
  Duration: Permanent until healed
  Effect: 2 damage per turn (DoT)
  Removal: Medikit heal OR end of mission
  Stacking: No (binary state)
  
  Critical: If unit reaches 0 HP while bleeding, dies instantly

Suppressed:
  Duration: 1 turn (until shooter's next turn)
  Effect: -30% accuracy, -1 AP
  Removal: Time expires OR move to new position
  Stacking: Multiple sources = -30% per source (stacks)

Disoriented:
  Duration: 2 turns
  Effect: -20% accuracy, -10% dodge
  Removal: Time expires OR Leadership ability
  Stacking: Refreshes duration

Hunkered:
  Duration: Until unit moves
  Effect: +40% defense, cannot attack
  Removal: Unit takes any action
  Stacking: No (intentional defensive stance)
```

### Status Effect Interactions

```yaml
Status Effect Combinations:

Burning + Bleeding:
  - Both damage types apply (5 + 2 = 7 per turn)
  - Heal bleeding first (more dangerous long-term)

Stunned + Any:
  - Stun overrides other AP costs
  - Unit cannot act regardless of other effects

Panicked + Suppressed:
  - Cumulative accuracy penalties (-30% suppressed + random panic fire)
  - May flee even under suppression

Poisoned + Bleeding + Burning (Triple DoT):
  - Total: 10 damage per turn (lethal combo)
  - Priority: Stop burning (remove immediately)
  - Then: Heal bleeding (permanent threat)
  - Finally: Antidote for poison (temporary)
```

### Status Effect Examples

**Example 1: Stun Duration**
```
Unit: 60 HP max
Hit by: Stun Grenade dealing 40 stun damage

Calculation:
  Stun_Turns = floor(40 / 60 × 3)
  Stun_Turns = floor(2.0) = 2 turns

Result: Unit stunned for 2 turns (loses 2 full actions)
```

**Example 2: Fire Spread**
```
Turn 1: Unit walks through fire hex (catch fire, 3 turn duration)
Turn 2: Unit takes 5 damage (burning), duration = 2 turns left
Turn 3: Unit hit by incendiary grenade (duration refreshes to 3 turns)
Turn 4: Unit takes 5 damage (burning), duration = 2 turns left
Turn 5: Unit uses medikit foam (fire extinguished immediately)

Total Damage: 10 (5 + 5, stopped early with foam)
```

---

## Critical Hit System

### Critical Hit Mechanics

```yaml
Critical Hit Chance:
  Base: 0% (no crits by default)
  Sources:
    - Weapon Mastery: +5-25% (based on mastery level)
    - Flanking: +10%
    - Height Advantage: +5%
    - Target Stunned: +20%
    - Sniper Aimed Shot: +15%
  
  Maximum: 95% crit chance (same cap as hit chance)

Critical Hit Effect:
  Damage Multiplier: 1.5× (50% more damage)
  Armor Penetration: +50% (ignores half of armor)
  
  Formula:
    Crit_Damage = Base_Weapon_Damage × 1.5
    Effective_Armor_vs_Crit = Effective_Armor × 0.50
    
    Final_Crit_Damage = Crit_Damage - Effective_Armor_vs_Crit

Example:
  Weapon: Sniper Rifle (50 damage)
  Target: 10 armor
  Normal Hit: 50 - 10 = 40 damage
  Critical Hit: (50 × 1.5) - (10 × 0.5) = 75 - 5 = 70 damage
```

### Headshot System (Snipers Only)

```yaml
Headshot (Special Critical):
  Requirement: Sniper rifle + Aimed shot + Crit roll success
  Chance: Standard crit chance (as above)
  Effect: Instant kill on non-boss enemies
  
  Boss Enemies (cannot instant-kill):
    - Deal 3× damage instead of instant kill
    - Armor ignored completely
  
  Example:
    Sniper with Master sniper mastery (+20% crit)
    Aimed shot on stunned target (+15% aim + 20% crit)
    Total crit chance: 55%
    
    Success: Instant kill (if not boss)
    Boss: 50 × 3 = 150 damage (massive damage)
```

---

## Cover & Positioning

### Cover Types & Mechanics

```yaml
Cover Destruction:
  - Explosive damage can destroy cover
  - Explosive Damage > Cover_HP: Cover destroyed
  - Cover_HP typical: 20-50 depending on material
  
  Examples:
    Wood Crate: 20 HP (easily destroyed)
    Sandbags: 30 HP (moderate)
    Concrete Wall: 50 HP (durable)
    Vehicle: 80 HP (very durable)

Flanking Detection:
  - Check angle between attacker and target
  - If angle > 90° from cover direction: Flanking
  - Cover bonus negated, flanking bonus applied
  
  Example:
    Target behind north wall (facing north)
    Attacker from east (90° angle)
    Result: Flanking (+20% hit chance, cover ignored)

Height Advantage:
  - Elevation difference > 2 meters: Height advantage
  - Attacker higher: +10% hit, +5% crit
  - Attacker lower: -10% hit
  - Calculated per hex: 1 hex = 2 meters elevation
```

---

## Action Point Economics

### AP Cost Breakdown

```yaml
Action Point Costs (Per Action):

Movement:
  - 1 hex normal terrain: 1 AP
  - 1 hex difficult terrain: 2 AP
  - Dash (double movement, -50% accuracy): 2 AP
  - Climb (up elevation): 2 AP per hex

Combat:
  - Snap Shot: 1 AP (-20% accuracy)
  - Standard Shot: 2 AP (base accuracy)
  - Aimed Shot: 3 AP (+20% accuracy, stationary only)
  - Burst Fire: 3 AP (3-5 shots, -10% accuracy)
  - Auto Fire: 4 AP (10+ shots, -20% accuracy)

Items:
  - Use Medikit: 1 AP
  - Throw Grenade: 1 AP
  - Reload Weapon: 1 AP
  - Switch Weapon: 0 AP (free action)
  - Use Item: 1 AP (general)

Abilities:
  - Overwatch: 1 AP (reserve fire)
  - Hunker Down: 1 AP (defensive stance)
  - Psionic Ability: 2-3 AP (based on power)
  - Special Ability: Varies (1-4 AP)

AP Regeneration:
  - Start of turn: Full AP restore
  - Base AP: 4 per turn (all units)
  - Modified by: Health, morale, status effects
  - Minimum AP: 1 (even if heavily wounded)
```

### AP Optimization Strategies

```yaml
Optimal Turn Structure:

Aggressive Build (4 AP):
  - Move 1 hex (1 AP)
  - Aimed Shot (3 AP)
  - Total: 4 AP (maximize damage)

Balanced Build (4 AP):
  - Move 2 hexes (2 AP)
  - Standard Shot (2 AP)
  - Total: 4 AP (mobility + damage)

Mobile Build (4 AP):
  - Dash 4 hexes (2 AP)
  - Snap Shot (1 AP)
  - Throw Grenade (1 AP)
  - Total: 4 AP (maximum positioning)

Defensive Build (4 AP):
  - Move to cover (1-2 AP)
  - Hunker Down (1 AP)
  - Overwatch (1 AP)
  - Total: 3-4 AP (survival focus)
```

---

## Balance Verification Tools

### Damage Balance Calculator

```lua
-- Verify weapon balance across all scenarios
function verifyWeaponBalance(weapon, armor_range)
  local results = {}
  
  for armor = 0, armor_range, 5 do
    local avg_damage = calculateAverageDamage(weapon, armor)
    local ttk = calculateTimeToKill(weapon, armor, 50) -- 50 HP target
    
    table.insert(results, {
      armor = armor,
      avg_damage = avg_damage,
      time_to_kill = ttk
    })
  end
  
  return results
end

-- Example output:
-- Rifle (25 damage, kinetic):
--   Armor 0: 25 avg, 2 turns to kill
--   Armor 5: 20 avg, 3 turns to kill
--   Armor 10: 15 avg, 4 turns to kill
--   Armor 15: 10 avg, 5 turns to kill
--   Armor 20: 5 avg, 10 turns to kill
```

### Accuracy Balance Verifier

```lua
-- Verify hit chances across all scenarios
function verifyAccuracyBalance(weapon, unit_aim)
  local scenarios = {
    {name = "Point Blank", distance = 0, cover = 0},
    {name = "Optimal Range", distance = weapon.optimal_range, cover = 0},
    {name = "Long Range", distance = weapon.optimal_range * 1.5, cover = 0},
    {name = "Cover (Half)", distance = weapon.optimal_range, cover = -20},
    {name = "Cover (Full)", distance = weapon.optimal_range, cover = -40}
  }
  
  for _, scenario in ipairs(scenarios) do
    local hit_chance = calculateHitChance(weapon, unit_aim, scenario)
    print(string.format("%s: %d%%", scenario.name, hit_chance))
  end
end
```

---

## Technical Implementation

```lua
-- engine/battlescape/combat_calculator.lua

CombatCalculator = {}

function CombatCalculator:calculateDamage(weapon, target, hit_type)
  local base_damage = weapon.base_damage
  local damage_type = weapon.damage_type
  
  -- Armor effectiveness based on damage type
  local armor_multiplier = self:getDamageTypeMultiplier(damage_type)
  local effective_armor = target.armor * armor_multiplier
  
  -- Random variance
  local variance = math.random(-10, 10) / 100 * base_damage
  
  -- Critical hit
  local crit_multiplier = 1.0
  if hit_type == "CRITICAL" then
    crit_multiplier = 1.5
    effective_armor = effective_armor * 0.5 -- Crits ignore 50% armor
  end
  
  -- Calculate final damage
  local damage = (base_damage * crit_multiplier) - effective_armor + variance
  
  -- Enforce minimum damage
  damage = math.max(1, damage)
  
  return math.floor(damage)
end

function CombatCalculator:calculateHitChance(weapon, shooter, target, conditions)
  local base_accuracy = weapon.base_accuracy
  
  -- Aim bonus
  local aim_bonus = (shooter.aim_stat - 6) * 5
  
  -- Equipment
  local equipment_bonus = shooter.scope_bonus or 0
  
  -- Distance penalty
  local distance = conditions.distance
  local optimal_range = weapon.optimal_range
  local distance_penalty = 0
  
  if distance > optimal_range then
    distance_penalty = (distance - optimal_range) * 2
  end
  
  -- Cover
  local cover_penalty = conditions.cover_value or 0
  
  -- Movement
  local movement_penalty = 0
  if conditions.shooter_moved then
    movement_penalty = 30
  elseif conditions.shooter_dashed then
    movement_penalty = 50
  end
  
  -- Height
  local height_bonus = 0
  if conditions.height_advantage > 0 then
    height_bonus = 10
  elseif conditions.height_advantage < 0 then
    height_bonus = -10
  end
  
  -- Flanking
  local flanking_bonus = 0
  if conditions.flanking then
    flanking_bonus = 20
    cover_penalty = 0 -- Flanking negates cover
  end
  
  -- Calculate total
  local hit_chance = base_accuracy + aim_bonus + equipment_bonus -
                     distance_penalty - cover_penalty - movement_penalty +
                     height_bonus + flanking_bonus
  
  -- Clamp to 5-95%
  hit_chance = math.max(5, math.min(95, hit_chance))
  
  return hit_chance
end

function CombatCalculator:applyStatusEffect(unit, effect_type, duration, source)
  -- Check if effect already exists
  local existing = unit.status_effects[effect_type]
  
  if existing then
    -- Refresh duration if stacking allowed
    if self:canStack(effect_type) then
      existing.duration = existing.duration + duration
    else
      existing.duration = math.max(existing.duration, duration)
    end
  else
    -- Add new effect
    unit.status_effects[effect_type] = {
      type = effect_type,
      duration = duration,
      source = source,
      start_turn = GameState.current_turn
    }
  end
  
  -- Apply immediate effects
  self:applyStatusEffectModifiers(unit, effect_type)
end
```

---

## Conclusion

The Combat Formula Documentation & Balance System provides complete transparency into all combat calculations. By explicitly defining every formula, damage type interaction, and status effect, implementation becomes straightforward and balance verification becomes systematic.

**Key Success Metrics**:
- 100% formula coverage (no ambiguous mechanics)
- Balance verification tools implemented (automated testing)
- Damage curves verified across armor ranges (TTK consistency)
- Status effects documented with examples (clear player understanding)

**Implementation Priority**: HIGH (Tier 1)  
**Estimated Development Time**: 3-5 days (documentation + verification)  
**Dependencies**: Battlescape.md, Units.md, Items.md  
**Risk Level**: Low (documentation task, no gameplay changes)

---

**Document Status**: Design Proposal - Ready for Implementation  
**Next Steps**: Review formulas, implement verification tools, validate balance  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28

