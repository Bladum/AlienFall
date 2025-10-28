# Pilot Specialization & Identity System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: MEDIUM  
> **Related Systems**: Pilots.md, Units.md, Crafts.md, Interception.md

## Table of Contents

- [Overview](#overview)
- [Pilot Specialization Tracks](#pilot-specialization-tracks)
- [Ace Progression System](#ace-progression-system)
- [Squadron Dynamics](#squadron-dynamics)
- [Pilot Personality System](#pilot-personality-system)
- [Interception Tactics](#interception-tactics)
- [Pilot-Craft Bonding](#pilot-craft-bonding)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

Addresses **pilot system integration issues** by adding clear specialization paths, emergent identity, and meaningful tactical depth to interception combat.

**Core Goals**:
- Create distinct pilot specializations (fighter/bomber/transport/ace)
- Add pilot personality traits (affect combat behavior)
- Enable pilot-craft bonding (preferred vehicles)
- Introduce squadron-level tactics (formation combat)
- Make interception layer engaging (not just stat checks)

---

## Pilot Specialization Tracks

### Specialization Unlock

At **30+ Piloting stat** and **10+ missions**, pilots can specialize.

### Fighter Pilot Track

```yaml
Identity: Air superiority specialist, aggressive combat

Requirements:
  - Piloting 30+
  - 10 successful interceptions
  - 5+ UFO kills

Progression:

Tier 1: Fighter Pilot (Piloting 30-49)
  Bonuses:
    - +20% craft accuracy
    - +15% craft dodge
    - +10% missile damage
  Abilities:
    - "Dogfighter" (passive): Auto-evade first missile per battle
  Personality: Aggressive, confident

Tier 2: Veteran Fighter (Piloting 50-69)
  Bonuses:
    - +30% craft accuracy
    - +25% craft dodge
    - +20% missile damage
  Abilities:
    - "Ace Maneuver" (active, 5 turn cooldown): Perfect dodge for 1 turn
    - "Pursuit" (passive): +2 movement when chasing fleeing enemy
  Personality: Calculated aggression

Tier 3: Ace Fighter (Piloting 70+)
  Bonuses:
    - +40% craft accuracy
    - +35% craft dodge
    - +30% missile damage
  Abilities:
    - "Death From Above" (active, once per battle): Guaranteed crit + double damage
    - "Fleet Command" (passive): All friendly craft in formation gain +10% accuracy
  Personality: Legendary status, inspires others
```

### Bomber Pilot Track

```yaml
Identity: Ground strike specialist, precision bombardment

Requirements:
  - Piloting 30+
  - 5 ground support missions
  - 3 base assault missions

Progression:

Tier 1: Bomber Pilot (Piloting 30-49)
  Bonuses:
    - +30% bomb damage
    - +15% bombing accuracy
    - -20% craft dodge (heavy payload)
  Abilities:
    - "Precision Strike" (active): Guarantee hit on stationary targets
  Personality: Methodical, patient

Tier 2: Strategic Bomber (Piloting 50-69)
  Bonuses:
    - +50% bomb damage
    - +25% bombing accuracy
    - -15% craft dodge (improved handling)
  Abilities:
    - "Carpet Bombing" (active): Hit 5×5 hex area (2 turn cooldown)
    - "Evasive Maneuvers" (passive): +20% dodge when not attacking
  Personality: Professional, focused

Tier 3: Doomsday Pilot (Piloting 70+)
  Bonuses:
    - +75% bomb damage
    - +35% bombing accuracy
    - 0% craft dodge penalty (mastered heavy craft)
  Abilities:
    - "Apocalypse Protocol" (once per battle): Nuclear-scale explosion (7×7 area)
    - "Danger Close" (passive): No friendly fire from own bombs
  Personality: Ice-cold professional
```

### Transport Pilot Track

```yaml
Identity: Logistics master, safe deployment specialist

Requirements:
  - Piloting 30+
  - 15 troop deployments
  - 0 passenger casualties

Progression:

Tier 1: Transport Pilot (Piloting 30-49)
  Bonuses:
    - +50% fuel efficiency
    - +2 cargo capacity
    - +20% craft armor
  Abilities:
    - "Safe Landing" (passive): Can land on any terrain
  Personality: Cautious, responsible

Tier 2: Veteran Transport (Piloting 50-69)
  Bonuses:
    - +75% fuel efficiency
    - +4 cargo capacity
    - +30% craft armor
  Abilities:
    - "Emergency Extraction" (active): Instant pickup from any location
    - "Hardened Hull" (passive): Ignore first hit per mission
  Personality: Reliable, trusted

Tier 3: Master Pilot (Piloting 70+)
  Bonuses:
    - +100% fuel efficiency (half cost)
    - +6 cargo capacity
    - +50% craft armor
  Abilities:
    - "Combat Drop" (active): Deploy troops mid-flight (no landing needed)
    - "Untouchable" (passive): +50% dodge when carrying passengers
  Personality: Legendary reliability
```

### Ace Pilot Track (Elite)

```yaml
Identity: Master of all roles, legendary hero

Requirements:
  - Piloting 70+
  - 25+ successful missions
  - 15+ UFO kills
  - 5+ ground support missions

Bonuses (Combines all tracks at 50%):
  - +20% accuracy (fighter)
  - +20% dodge (fighter)
  - +25% bomb damage (bomber)
  - +30% fuel efficiency (transport)

Abilities:
  - "Jack of All Trades" (passive): Can fly any craft with full bonuses
  - "Ace Maneuver" (active): Perfect dodge + guaranteed crit (once per battle)
  - "Squadron Leader" (passive): All nearby allies gain +15% to all stats

Personality: Living legend, inspires awe
```

---

## Ace Progression System

### Kill Count Tracking

```yaml
Ace Status (Based on UFO Kills):

Rookie (0-4 kills):
  - No ace status
  - Standard pilot bonuses

Ace (5-9 kills):
  - +10% to all combat stats
  - Callsign earned (e.g., "Maverick")
  - Painted nose art on craft (visual customization)

Veteran Ace (10-14 kills):
  - +20% to all combat stats
  - Squadron command ability unlocked
  - Other pilots gain +5% when flying with ace

Elite Ace (15-24 kills):
  - +30% to all combat stats
  - "Ace Maneuver" ability unlocked
  - Fame +10 (media attention)

Legendary Ace (25+ kills):
  - +40% to all combat stats
  - Unique abilities unlocked
  - Become hero unit (irreplaceable)
  - Permanent base morale +10 (inspiration)
```

### Ace Personality Events

```yaml
"Interview Request" Event:
  Trigger: Pilot becomes Ace (5 kills)
  Choice:
    - Accept interview: +10 fame, -1 day (media duty)
    - Decline: No fame, focus on missions
  
"Propaganda Poster" Event:
  Trigger: Pilot becomes Veteran Ace (10 kills)
  Choice:
    - Become poster pilot: +20 fame, +15% recruitment
    - Refuse: Pilot morale +10 (respects privacy)

"Retirement Offer" Event:
  Trigger: Pilot becomes Legendary Ace (25 kills)
  Choice:
    - Retire as hero: +50 fame, lose pilot permanently
    - Continue service: Pilot gains "Veteran" trait (+10% all stats)
    - Become instructor: Lose as active pilot, all new pilots gain +20% XP
```

---

## Squadron Dynamics

### Formation Flying

```yaml
Squadron Formation System:

V-Formation (3 craft):
  Leader Position (front):
    - +10% accuracy (clear sight)
    - -10% dodge (exposed)
  
  Wing Positions (flanks):
    - +20% dodge (protected by leader)
    - -10% accuracy (supporting position)
  
  Squadron Bonus:
    - All craft gain +15% damage (coordinated fire)

Line Formation (3-5 craft):
  All Positions:
    - +10% accuracy (organized approach)
    - Standard dodge
  
  Squadron Bonus:
    - +25% suppression (intimidation effect)
    - Enemies more likely to flee

Swarm Formation (5+ craft):
  All Positions:
    - -20% accuracy (chaotic)
    - +30% dodge (unpredictable movements)
  
  Squadron Bonus:
    - Overwhelming numbers
    - Enemies take morale damage
```

### Squadron Leader Abilities

```yaml
Squadron Leader Requirements:
  - Piloting 60+
  - 15+ missions
  - 10+ UFO kills

Leader Abilities:

"Coordinate Strike" (active, 3 turn cooldown):
  - All squadron members attack same target
  - +50% damage for coordinated volley
  - Requires line of sight from all craft

"Rally Squadron" (active, once per battle):
  - All squadron members heal 20% hull
  - Remove all negative status effects
  - +15 morale for remainder of battle

"Emergency Scatter" (active, once per battle):
  - All squadron members gain perfect dodge for 1 turn
  - Break formation (must reform next turn)
  - Use when ambushed or outnumbered
```

---

## Pilot Personality System

### Personality Traits

Randomly assigned or earned through actions:

```yaml
Bold (10% spawn chance):
  - +20% damage
  - -10% dodge (takes risks)
  - Will pursue fleeing enemies aggressively
  - Voice lines: "I've got him!" "No escape!"

Cautious (10% spawn chance):
  - +20% dodge
  - -10% damage (conservative)
  - Will retreat at 30% hull (self-preservation)
  - Voice lines: "Breaking off!" "Too dangerous!"

Vengeful (Earned: lose wingman):
  - +30% damage vs. killer of wingman
  - Will prioritize revenge target
  - May disobey orders to pursue revenge
  - Voice lines: "This is for [wingman]!" "Payback time!"

Protective (Earned: save 3 wingmen):
  - +25% dodge when near injured ally
  - Will cover retreating allies
  - -20% accuracy when protecting
  - Voice lines: "I've got your back!" "Cover me, covering you!"

Ice Cold (Earned: 10 missions, 0 panic):
  - Immune to morale penalties
  - +10% accuracy under pressure
  - Never retreats (can be dangerous)
  - Voice lines: "Steady..." "Focus fire."

Showboat (Earned: 3 solo kills):
  - +15% all stats when alone
  - -10% all stats in formation (prefers solo)
  - Will break formation to pursue kills
  - Voice lines: "Watch this!" "Going solo!"
```

### Personality Conflicts

```yaml
Incompatible Personalities:

Bold + Cautious:
  - -10% squadron cohesion
  - May argue over tactics
  - Risk of insubordination

Showboat + Anyone:
  - -15% formation bonuses
  - Showboat breaks formation frequently
  - Other pilots frustrated

Compatible Personalities:

Bold + Vengeful:
  - +15% aggressive bonuses stack
  - Dangerous but effective pair

Cautious + Protective:
  - +20% defensive bonuses stack
  - Excellent defensive formation

Ice Cold + Any:
  - Calm presence steadies others
  - +5% morale to squadron
```

---

## Interception Tactics

### Advanced Combat Maneuvers

```yaml
Tactical Maneuvers (Unlock at Piloting 40+):

"Barrel Roll" (2 AP):
  - +30% dodge for 1 turn
  - Cannot attack same turn
  - Use when low on hull

"Immelman Turn" (3 AP):
  - Reverse direction instantly
  - Gain altitude advantage (+15% accuracy next turn)
  - Costs extra fuel (10 units)

"Dive Bombing" (3 AP):
  - +40% bomb accuracy
  - +20% bomb damage
  - Must be above target (altitude system)

"Yo-Yo Maneuver" (4 AP):
  - Complex maneuver, difficult to execute
  - Success: Perfect dodge + guaranteed hit
  - Failure (30% chance): Take damage, lose turn

"Energy Fighting" (passive):
  - Trade speed for position
  - +10% dodge, -1 movement
  - Tactical positioning over raw speed
```

---

## Pilot-Craft Bonding

### Preferred Craft System

```yaml
Bonding Mechanic:

Pilots gain bonuses when flying same craft repeatedly:

5 Missions: "Familiar"
  - +5% to all stats with this craft
  - Recognize craft handling quirks

10 Missions: "Bonded"
  - +10% to all stats with this craft
  - Can name craft (player customization)
  - Craft gains pilot's callsign (visual)

20 Missions: "One With The Machine"
  - +15% to all stats with this craft
  - Unlock "Perfect Sync" ability:
    - Once per mission: +50% all stats for 1 turn
  - If craft destroyed: Pilot takes morale hit (-20)

Example:
  "Maverick" Chen flies Interceptor-07 for 20 missions
  Renames it "Chen's Fury"
  Gains +15% bonuses when flying it
  If transferred to different interceptor: Loses bonuses, must rebond
```

### Ace Craft (Hero Vehicles)

```yaml
Legendary Ace + Bonded Craft = Hero Vehicle

Effects:
  - Craft painted with ace's colors/insignia
  - +20% all stats (ace + bond stack)
  - Enemies recognize and fear (morale damage)
  - If destroyed: Major morale hit globally (-30)
  - Can be rebuilt with same bonuses (legacy craft)

Example:
  Legendary Ace "Viper" bonds with Fighter-12
  Renames to "Viper's Fang"
  Painted red with viper emblem
  Enemies flee when detected (fame precedes)
  If destroyed: Memorial event, rebuild as "Viper's Fang II"
```

---

## Technical Implementation

```lua
-- engine/pilots/pilot_specialization_manager.lua

PilotSpecializationManager = {
  pilot_specializations = {},
  squadron_formations = {},
  ace_roster = {}
}

function PilotSpecializationManager:checkSpecializationUnlock(pilot)
  if pilot.piloting_stat < 30 then
    return false, "Insufficient piloting skill"
  end
  
  if pilot.total_missions < 10 then
    return false, "Insufficient experience"
  end
  
  -- Check specialization criteria
  local eligible_specs = {}
  
  -- Fighter track
  if pilot.successful_interceptions >= 10 and pilot.ufo_kills >= 5 then
    table.insert(eligible_specs, "FIGHTER")
  end
  
  -- Bomber track
  if pilot.ground_support_missions >= 5 and pilot.base_assaults >= 3 then
    table.insert(eligible_specs, "BOMBER")
  end
  
  -- Transport track
  if pilot.troop_deployments >= 15 and pilot.passenger_casualties == 0 then
    table.insert(eligible_specs, "TRANSPORT")
  end
  
  if #eligible_specs > 0 then
    return true, eligible_specs
  end
  
  return false, "No specialization criteria met"
end

function PilotSpecializationManager:specialize(pilot, specialization_type)
  pilot.specialization = specialization_type
  pilot.specialization_tier = 1
  
  -- Apply tier 1 bonuses
  self:applySpecializationBonuses(pilot, specialization_type, 1)
  
  -- Notify player
  GUI:showSpecializationUnlock(pilot, specialization_type)
  
  -- Track for analytics
  Analytics:recordSpecialization(pilot.id, specialization_type)
end

function PilotSpecializationManager:updateAceStatus(pilot)
  local kill_count = pilot.ufo_kills
  
  local ace_tiers = {
    {threshold = 25, status = "LEGENDARY_ACE"},
    {threshold = 15, status = "ELITE_ACE"},
    {threshold = 10, status = "VETERAN_ACE"},
    {threshold = 5, status = "ACE"}
  }
  
  for _, tier in ipairs(ace_tiers) do
    if kill_count >= tier.threshold then
      if pilot.ace_status ~= tier.status then
        pilot.ace_status = tier.status
        self:triggerAceEvent(pilot, tier.status)
      end
      break
    end
  end
end

function PilotSpecializationManager:calculateBondBonus(pilot, craft)
  if not pilot.craft_bonds then
    pilot.craft_bonds = {}
  end
  
  if not pilot.craft_bonds[craft.id] then
    pilot.craft_bonds[craft.id] = {missions = 0, level = "NONE"}
  end
  
  local bond = pilot.craft_bonds[craft.id]
  local bonus_multiplier = 0
  
  if bond.missions >= 20 then
    bond.level = "ONE_WITH_MACHINE"
    bonus_multiplier = 0.15
  elseif bond.missions >= 10 then
    bond.level = "BONDED"
    bonus_multiplier = 0.10
  elseif bond.missions >= 5 then
    bond.level = "FAMILIAR"
    bonus_multiplier = 0.05
  end
  
  return bonus_multiplier, bond.level
end

function PilotSpecializationManager:formSquadron(craft_list, formation_type)
  local squadron = {
    id = self:generateSquadronID(),
    craft = craft_list,
    formation = formation_type,
    leader = self:selectSquadronLeader(craft_list)
  }
  
  -- Apply formation bonuses
  for _, craft in ipairs(craft_list) do
    local position_bonus = self:getFormationBonus(formation_type, craft.position)
    craft.formation_bonuses = position_bonus
  end
  
  table.insert(self.squadron_formations, squadron)
  
  return squadron
end
```

---

## Conclusion

The Pilot Specialization & Identity System transforms pilots from generic stat-providers into unique characters with distinct roles, personalities, and emergent stories. Specialization tracks, ace progression, and squadron dynamics create engaging interception gameplay.

**Key Success Metrics**:
- 80%+ pilots specialize (clear role identity)
- 40%+ pilots achieve ace status (progression rewarding)
- 60%+ players actively manage squadron formations (tactical depth)
- Pilot-craft bonding: 70%+ players maintain preferred craft (attachment)

**Implementation Priority**: MEDIUM (Tier 2)  
**Estimated Development Time**: 1-2 weeks  
**Dependencies**: Pilots.md, Units.md, Interception.md  
**Risk Level**: Low (extends existing systems)

---

**Document Status**: Design Proposal - Ready for Review  
**Next Steps**: Implement specialization tracks, prototype squadron system, playtest  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28
# Research Strategic Depth System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: MEDIUM  
> **Related Systems**: Economy.md, Research.md, AI.md, Politics.md

## Table of Contents

- [Overview](#overview)
- [Branching Research Trees](#branching-research-trees)
- [Research Competition System](#research-competition-system)
- [Parallel Research Limits](#parallel-research-limits)
- [Technology Obsolescence](#technology-obsolescence)
- [Research Breakthrough Events](#research-breakthrough-events)
- [Collaborative Research](#collaborative-research)
- [Espionage & Counter-Intelligence](#espionage--counter-intelligence)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

Addresses **research tree lacks strategic depth** by adding branching paths, alien counter-research, and meaningful technology choices.

**Core Goals**:
- Create mutually exclusive research paths (strategic commitment)
- Add alien adaptive research (arms race dynamics)
- Limit parallel research (capacity constraints force prioritization)
- Introduce technology obsolescence (prevent single-strategy dominance)
- Enable research espionage (steal/sabotage enemy research)

---

## Branching Research Trees

### Philosophy

Replace linear "research everything eventually" with "choose your path, live with consequences."

### Major Research Branches

#### Weapons Technology (Month 5 unlock)

**Branch Point: "Advanced Weapons Doctrine"**

```yaml
Option A: Energy Weapons Path
  Tier 1: Laser Rifles
    - Fast research (50 man-days)
    - Low damage (18 base)
    - Infinite ammo (no reload)
    - Weak vs. armor (50% effectiveness)
  
  Tier 2: Plasma Weapons
    - Expensive research (150 man-days)
    - High damage (35 base)
    - Requires alien tech
    - Manufacturing cost 3× normal
  
  Tier 3: Dimensional Weapons
    - Endgame (300 man-days)
    - Reality-warping effects (ignore armor)
    - Risk: 5% dimensional rift per use
    - Ultimate power, ultimate risk

Option B: Kinetic Weapons Path
  Tier 1: Gauss Rifles
    - Mid research (75 man-days)
    - Balanced damage (22 base)
    - Standard ammo cost
    - Reliable, no downsides
  
  Tier 2: Railguns
    - Expensive (200 man-days)
    - Armor-piercing (ignore 50% armor)
    - Requires power cells
    - High AP cost (3 AP per shot)
  
  Tier 3: Coilguns
    - Endgame (250 man-days)
    - Perfect accuracy (95% base)
    - Silent operations (stealth)
    - Tactical precision weapon

Option C: Chemical/Biological Path
  Tier 1: Poison Gas
    - Fast (40 man-days)
    - Area denial (3 turns DoT)
    - -30 karma per use (war crime)
    - Cheap manufacturing
  
  Tier 2: Acid Launchers
    - Mid (100 man-days)
    - Armor destruction (permanent)
    - Hazard zones (environmental damage)
    - Strategic terrain control
  
  Tier 3: Nanoweapons
    - Endgame (280 man-days)
    - Persistent DoT (spreads to nearby enemies)
    - Stealth delivery (invisible clouds)
    - Ethical nightmare (-50 karma)
```

**Cross-Research Penalty**: Switching paths mid-game costs 2× research time

**Example Player Journey**:
```
Month 5: Choose Energy Weapons (fast, infinite ammo)
Month 7: Unlock Plasma Weapons (powerful but expensive)
Month 9: Realize aliens developed plasma-reflective armor
Month 10: Want to switch to Kinetic (railguns pierce armor)
Cost: 200 man-days × 2 = 400 man-days (major setback)
```

---

## Research Competition System

### Alien Adaptive Research

Aliens analyze player tactics and develop countermeasures.

### Counter-Research Mechanics

```yaml
Analysis Phase (Every 3 Missions):
  - Aliens track player weapon usage
  - Track player armor types
  - Track player tactical patterns
  - Generate counter-research project

Counter-Research Delay:
  - 2 months from analysis to deployment
  - Intelligence missions can reveal alien projects
  - Player can pre-emptively counter-counter

Counter-Tech Examples:
  Laser Weapons Detected (>60% usage):
    - Alien Research: "Reflective Plating"
    - Effect: -30% laser damage vs. aliens
    - Duration: Permanent unless player adapts
  
  Heavy Armor Detected (>80% squad):
    - Alien Research: "Armor-Piercing Rounds"
    - Effect: +50% penetration vs. player armor
    - Duration: Permanent
  
  Psionic Abilities Detected:
    - Alien Research: "Psi-Shields"
    - Effect: 50% resistance to mind control
    - Duration: Permanent
  
  Stealth Tactics Detected:
    - Alien Research: "Motion Sensors"
    - Effect: Detection range +3 hexes
    - Duration: 6 months (technology cycle)
```

### Player Response Options

**Option 1: Adapt Tactics**
- Switch weapon types (use kinetic instead of energy)
- Change combat approach (aggression vs. defense)
- Cost: None (flexibility rewarded)
- Risk: Learning curve = potential failures

**Option 2: Counter-Counter Research**
- Research "Anti-Reflective Coating" (negate laser counter)
- Cost: 100 man-days emergency research
- Risk: Diverts scientists from other projects
- Benefit: Maintain current strategy

**Option 3: Brute Force**
- Accept -30% effectiveness
- Compensate with more firepower (+30% damage output)
- Cost: Higher casualties, expensive
- Risk: Unsustainable in long run

### Intelligence Missions

**"Intercept Alien Research"** (Special Mission):
- Trigger: Month 6+, Intelligence 60+
- Effect: Reveal current alien research projects (2 months advance warning)
- Reward: Can prepare counter-counter tech before deployed
- Frequency: 1 per 2 months

---

## Parallel Research Limits

### Capacity-Based Constraints

Replace unlimited parallel research with facility-based caps.

```yaml
Research Facility Limits:

Basic Lab (2×2):
  Cost: 50K credits
  Capacity: 3 active projects max
  Scientist Slots: 10 scientists
  Bonus: None

Advanced Lab (3×3):
  Cost: 150K credits
  Capacity: 5 active projects max
  Scientist Slots: 20 scientists
  Bonus: +20% research speed

Research Complex (4×4):
  Cost: 400K credits
  Capacity: 8 active projects max
  Scientist Slots: 40 scientists
  Bonus: +40% research speed

Overflow Penalty:
  - Exceeding capacity: +50% research time per overflow project
  - Scientists stretched thin (inefficiency)
  - Morale penalty (overworked)
```

### Strategic Implications

**Early Game (1 Lab, 3 capacity)**:
```
Active Projects:
1. Laser Rifles (critical weapon upgrade)
2. Improved Armor (survival need)
3. Alien Biology (understand enemy)

Queue (Delayed):
4. Advanced Explosives (would be +50% time)
5. Stealth Technology (would be +50% time)

Decision: Focus on critical 3, delay others
```

**Mid Game (2 Labs, 8 capacity)**:
```
Can research more broadly, but still constrained
Must prioritize offensive vs. defensive vs. utility
```

---

## Technology Obsolescence

### Adaptive Enemy Upgrades

Technologies become less effective as campaign progresses.

```yaml
Technology Lifecycle:

Introduction Phase (Months 1-3):
  - New tech highly effective (+30% effectiveness)
  - Enemies unprepared (baseline counters)
  - "Surprise" bonus

Maturity Phase (Months 4-8):
  - Tech at baseline effectiveness (100%)
  - Enemies adapt tactics
  - Standard combat

Decline Phase (Months 9-12):
  - Tech effectiveness reduced (-20%)
  - Enemies developed counters
  - Must upgrade or switch

Obsolescence (Month 13+):
  - Tech significantly weakened (-40%)
  - Enemies fully adapted
  - Upgrade mandatory for viability

Example: Laser Rifles
  Month 5 (introduced): 30 damage effective
  Month 8 (mature): 25 damage effective
  Month 11 (declining): 20 damage effective
  Month 14 (obsolete): 15 damage effective
  
  Solution: Research "Plasma Rifles" (next tier)
```

### Technology Upgrade Paths

**Incremental Upgrades** (maintain current path):
```yaml
Laser Rifle → Advanced Laser Rifle → Plasma Rifle
- Each upgrade: 75 man-days
- +5 damage per tier
- Maintains tech familiarity (no retraining)
```

**Revolutionary Upgrades** (switch paths):
```yaml
Laser Rifle → Gauss Rifle (different tech tree)
- Switching cost: 150 man-days (2× normal)
- +10 damage jump (bigger improvement)
- Requires unit retraining (3 missions adaptation)
```

---

## Research Breakthrough Events

### Serendipitous Discoveries

Random research breakthroughs inject unpredictability.

```yaml
Breakthrough Types:

Critical Success (5% chance per project):
  - Research completes 50% faster
  - Unlock bonus project (related tech free)
  - +20 fame (scientific achievement)
  - Example: "Laser Rifles" unlocks "Laser Pistols" free

Partial Success (15% chance):
  - Research completes 25% faster
  - Small bonus (+5% effectiveness)
  - No additional unlocks

Standard Success (75% chance):
  - Research completes as expected
  - No bonuses or penalties

Complication (4% chance):
  - Research takes +25% time (unexpected issues)
  - May require additional resources
  - Risk of minor setback

Critical Failure (1% chance):
  - Research fails completely (50% time wasted)
  - Must restart from scratch
  - -10 scientist morale
  - Rare but painful
```

### Eureka Moments

**Scientist Personality Events**:
```yaml
Genius Scientist:
  - 10% chance of breakthrough per project
  - +30% research speed
  - Risk: May defect if mistreated

Mad Scientist:
  - 20% chance of breakthrough
  - 20% chance of critical failure
  - High risk, high reward

Methodical Scientist:
  - 0% chance of breakthrough
  - 0% chance of failure
  - Reliable, predictable
```

---

## Collaborative Research

### International Research Programs

```yaml
Joint Research (Diplomatic Option):
  Requirements:
    - Allied with 3+ countries (relation +50)
    - Month 7+
    - Diplomatic reputation +60
  
  Mechanics:
    - Countries contribute scientists (2-5 per country)
    - Research speed +40% (collaboration bonus)
    - Cost shared (player pays 50%, countries 50%)
    - Results shared (all countries gain tech)
  
  Benefits:
    - Faster research
    - Cheaper costs
    - Improved relations (+10 per completed project)
  
  Drawbacks:
    - Can't research unethical tech (karma <0 blocked)
    - Technology leaked (enemies may steal)
    - Loss of exclusivity (countries have same tech)

Example:
  Solo Research: "Plasma Rifles" = 150 man-days, 100K credits
  Joint Research: "Plasma Rifles" = 90 man-days, 50K credits
  Trade-off: Allies also get plasma rifles (less advantage)
```

### Corporate Partnerships

```yaml
Private Sector Research:
  Requirements:
    - Fame >50
    - Credits >100K
    - Not in debt
  
  Mechanics:
    - Corporations offer research contracts
    - Pay upfront (50K-200K)
    - Research completes 30% faster (corporate resources)
    - Must share results (corporations sell to others)
  
  Benefits:
    - Cash injection (funding boost)
    - Faster research
    - Access to corporate facilities
  
  Drawbacks:
    - Technology commercialized (enemies can buy)
    - -10 karma (profit motive)
    - Loss of military exclusivity

Example:
  "Gauss Weapons" research via corporate contract:
    - Receive 100K upfront payment
    - Complete in 105 man-days (vs. 150 solo)
    - 3 months later: Black market sells gauss weapons
    - Aliens buy from black market (your tech used against you)
```

---

## Espionage & Counter-Intelligence

### Research Espionage

**Steal Enemy Research**:
```yaml
"Industrial Espionage" Mission:
  Requirements:
    - Intelligence 70+
    - Stealth specialist unit
    - Target: Enemy organization or alien base
  
  Success (60% base chance):
    - Steal research project (50% completion bonus)
    - Example: Aliens researching "Advanced Armor" at 60% completion
    - Player gains 30% completion toward "Advanced Armor" (50% of 60%)
  
  Failure (40% chance):
    - Mission failed, no intel gained
    - Risk: Unit captured (10% chance)
    - Risk: Enemy alerted (increase security +20%)
  
  Diplomatic Consequences:
    - If stealing from countries: -30 relation
    - If caught: -50 relation, possible war
    - If stealing from aliens: No diplomatic penalty
```

### Research Sabotage

**Delay Enemy Research**:
```yaml
"Sabotage Research Facility" Mission:
  Requirements:
    - Explosives expert unit
    - Intelligence on enemy research (recon first)
  
  Success (70% base chance):
    - Delay enemy research by 2 months
    - Destroy research materials
    - -20% enemy research speed (3 months)
  
  Failure (30% chance):
    - Mission failed, enemy research continues
    - Risk: Unit casualties (15% chance)
    - Enemy counter-sabotage (they target you)
  
  Example:
    Aliens researching "Psi-Shields" (counter to player psionics)
    Sabotage delays by 2 months (buy time to adapt)
```

### Counter-Intelligence

**Protect Your Research**:
```yaml
Security Measures:

Basic Security (Free):
  - Standard protocols
  - 30% chance to detect espionage
  - No bonuses

Enhanced Security (5K per month):
  - Security checkpoints
  - 60% chance to detect espionage
  - Captured spies reveal enemy plans

Maximum Security (15K per month):
  - AI surveillance, biometric locks
  - 90% chance to detect espionage
  - Counter-espionage missions unlocked
  - Can turn enemy spies (double agents)

Trade-off:
  - High security costs money
  - Slows research speed (-10% per security tier)
  - Paranoid environment (scientist morale -5%)
```

---

## Technical Implementation

### Research Tree Manager

```lua
-- engine/research/research_tree_manager.lua

ResearchTreeManager = {
  active_projects = {},
  completed_projects = {},
  available_branches = {},
  locked_branches = {},
  capacity_limits = {}
}

function ResearchTreeManager:selectBranch(branch_id, player_choice)
  -- Lock alternative branches
  local branch_data = ResearchDatabase.branches[branch_id]
  
  for _, alt_branch in ipairs(branch_data.alternatives) do
    self.locked_branches[alt_branch] = true
  end
  
  -- Unlock chosen path
  self.available_branches[player_choice] = true
  
  -- Track player decision
  GameState.research_choices[branch_id] = player_choice
  
  -- Notify UI
  GUI:showBranchSelection(branch_id, player_choice)
  
  -- Analytics
  Analytics:recordResearchChoice(branch_id, player_choice)
end

function ResearchTreeManager:checkCapacity(new_project)
  local total_capacity = 0
  
  -- Sum facility capacities
  for _, base in ipairs(GameState.bases) do
    for _, facility in ipairs(base.facilities) do
      if facility.type == "research_lab" then
        total_capacity = total_capacity + facility.capacity
      end
    end
  end
  
  local active_count = #self.active_projects
  
  if active_count >= total_capacity then
    return false, "Research capacity exceeded"
  end
  
  return true, "Capacity available"
end

function ResearchTreeManager:triggerAlienCounterResearch(player_tactics)
  -- Analyze player weapon usage
  local weapon_usage = Analytics:getWeaponUsageStats(3) -- Last 3 missions
  
  local dominant_weapon = self:findDominantWeapon(weapon_usage)
  
  if dominant_weapon and weapon_usage[dominant_weapon] > 0.60 then
    -- Aliens develop counter
    local counter_tech = self:getCounterTechnology(dominant_weapon)
    
    -- Queue alien research
    AlienAI:queueResearchProject(counter_tech, 2) -- 2 months delay
    
    -- Notify player (if intelligence high enough)
    if GameState.intelligence_level >= 60 then
      GUI:showAlienResearchWarning(counter_tech, dominant_weapon)
    end
  end
end

function ResearchTreeManager:getCounterTechnology(weapon_type)
  local counters = {
    ["laser"] = {
      name = "Reflective Plating",
      effect = {damage_reduction = 0.30},
      duration = "permanent"
    },
    ["kinetic"] = {
      name = "Reactive Armor",
      effect = {armor_bonus = 5},
      duration = "permanent"
    },
    ["explosive"] = {
      name = "Blast Shielding",
      effect = {explosion_resistance = 0.50},
      duration = "permanent"
    },
    ["psionic"] = {
      name = "Psi-Shields",
      effect = {psi_resistance = 0.50},
      duration = "permanent"
    }
  }
  
  return counters[weapon_type] or counters["kinetic"]
end

function ResearchTreeManager:applyTechnologyObsolescence(tech_id, months_active)
  local obsolescence_curve = {
    [0] = 1.30,  -- Introduction (+30%)
    [3] = 1.00,  -- Maturity (baseline)
    [6] = 0.80,  -- Decline (-20%)
    [9] = 0.60   -- Obsolescence (-40%)
  }
  
  -- Find appropriate multiplier
  local multiplier = 1.00
  for threshold, mult in pairs(obsolescence_curve) do
    if months_active >= threshold then
      multiplier = mult
    end
  end
  
  -- Apply to all weapons of this tech type
  for _, weapon in ipairs(ItemDatabase.weapons) do
    if weapon.technology_base == tech_id then
      weapon.effectiveness_modifier = multiplier
    end
  end
  
  -- Notify if significant drop
  if multiplier <= 0.80 then
    GUI:showTechObsolescenceWarning(tech_id, multiplier)
  end
end
```

---

## Conclusion

The Research Strategic Depth System transforms research from passive "wait for everything" into active strategic decision-making. Branching paths, alien counter-research, and capacity limits create meaningful choices and ongoing tension.

**Key Success Metrics**:
- 80%+ players commit to research branch (demonstrate specialization)
- 60%+ players experience alien counter-research (dynamic gameplay)
- 50%+ players switch strategies mid-campaign (adapt to counters)
- Research capacity becomes limiting factor (forces prioritization)

**Implementation Priority**: MEDIUM (Tier 2)  
**Estimated Development Time**: 2-3 weeks  
**Dependencies**: Economy.md, AI.md  
**Risk Level**: Medium (requires AI adaptation logic)

---

**Document Status**: Design Proposal - Ready for Review  
**Next Steps**: Design branching trees, prototype counter-research AI, playtest  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28

