# TASK: Pilot & Perks System Implementation

**Status:** TODO | **Priority:** HIGH | **Duration:** 40-60 hours estimated  
**Created:** October 23, 2025 | **Target Completion:** TBD

---

## 🎯 Overview

Comprehensive implementation of the PILOT class and PERKS systems as requested. This task covers:

1. **PILOT Class System** - New unit class for craft operation
2. **Craft Pilot Requirements** - Craft requirements for 1-6 pilots
3. **Capacity Distribution** - PILOT/CREW/CARGO capacity types
4. **PERKS System** - Boolean flag-based unit trait system with 40+ perks
5. **Dual-Wield Mechanic** - Special perk enabling two-weapon combat
6. **Pilot Bonuses** - Stat transfer from pilot to craft
7. **Pilot Progression** - XP gain during interception combat
8. **Complete Documentation** - All files updated

---

## 📋 Requirements Analysis

### From User Request

✅ **"crafty nie maja promocji ani doswiadczenia, za to maja je UNITS"**
- Crafts DO NOT get promotion/experience
- UNITS (pilots) get experience and bonuses instead
- Pilot rank increases pilot stats, which boost craft stats

✅ **"dodaje zwykla prosta klase PILOT"**
- Create PILOT class (simple, like RIFLEMAN)
- Stats: SPEED, AIM, REACTION (driver-focused)
- Range: 6-10 like other units

✅ **"craft wymaga PILOT"**
- Small craft: 1-2 pilots required
- Medium craft: 2-3 pilots required
- Large craft: 4-6 pilots required

✅ **"pilot zdobywa expa jak UNIT ale prosciej"**
- Pilots gain XP during interception (not ground battle)
- Simple progression: 3 levels instead of 7
- XP from UFO/enemy HP defeated

✅ **"crafty moga wymagac 1-6 pilotow"**
- craft.pilotsRequired: 1-6 (per craft type)
- craft.pilotClasses: array of required specialist classes
- Example: bombers require "bomber_pilot" class

✅ **"crafty maja wtedy capacity na PILOT -> units jako piloci, a potem zaloga do bitwy"**
- PILOT capacity: units serving as pilots (1-6 slots)
- CREW capacity: units as combat troops (0-N slots)
- CARGO capacity: items/weapons only

✅ **"piloci ktorzy kieruja craftem dostaja experience z walki podczas interception"**
- Pilots gain XP from interception victories
- Award XP based on enemy HP/difficulty
- Pilots rank-up with +speed, +aim, +reaction

✅ **"crafty nie sa promowane, ale piloci daja bonusy do crafta ktorym steruja"**
- Craft stats remain fixed
- Pilot stats grant bonuses to craft (speed +%, aim +%, etc.)
- All bonuses calculated per pilot stat

✅ **"moga byc specjalne unit class potrzebne jako piloci"**
- Standard PILOT class
- Specialist classes: BOMBER_PILOT, SUBMARINE_PILOT, HELICOPTER_PILOT, etc.
- Craft can require specific pilot classes

✅ **"craft moze miec wymaganych pilotow specjalnych do walki"**
- craft.pilotClasses: ["bomber_pilot"]
- craft.specialPilotSlots: required specialist slots
- General pilots + specialists allowed

✅ **"wieksze crafty moga wymagac pilota oficera"**
- craft.requiresOfficer: boolean
- Officer must be ELITE rank or special leadership trait
- Grants +morale and command bonuses

✅ **"staty unita beda przenosily sie na bonus to statow craftu"**
- Pilot SPEED → Craft speed bonus
- Pilot AIM → Craft accuracy bonus
- Pilot STRENGTH → Craft damage bonus
- Pilot ENERGY → Craft energy bonus
- Pilot REACTION → Craft dodge/evasion bonus
- Pilot SIGHT → Craft radar range
- Calculation: (pilot_stat - 5) / 100 = % bonus

✅ **"taki pilot moze miec ekwipunek ktory normalnie"**
- Pilots have standard equipment like units
- Can equip weapons, armor, items
- Equipment affects pilot perks and effectiveness

✅ **"pilot moze brac udzial w walce jesli statek wyladuje normalnie"**
- Pilot + crew both deploy to ground battle
- After landing: pilots become combat units
- Pilot combat stats: based on pilot class + rank

---

### PERKS System Requirements

✅ **"nowy mechanizm w units to sa perki"**
- Create boolean flag system for unit traits
- Per-unit tracking of enabled/disabled perks
- Perks affect unit capabilities and behavior

✅ **"system perkow to system flag TRUE FALSE ktory aktywyje dla jednostki jakas akcje"**
- Perks: simple boolean on/off
- 40+ standard perks defined
- Can be enabled/disabled per unit

✅ **"od takich prostych jak can_move, can_run, can_fly, can_breathe do bardziej complex np can_fire_both_weapons"**
- Basic perks: can_move, can_run, can_fly, can_breathe, can_swim
- Combat perks: can_shoot, can_melee, can_throw, can_use_psionics
- Complex perks: two_weapon_proficiency, regeneration, leader

✅ **"wymysl jakie rzeczy moga byc oflagowane i jakie sa standardowe wartosci"**
- Create comprehensive perk list (40+ items)
- Per-class default perks
- Modders can add custom perks

---

### Dual-Wielding Requirement

✅ **"jeden z perkow to dwurczenosc"**
- Create "two_weapon_proficiency" or "dual_wield" perk
- When enabled: can fire 2 identical weapons

✅ **"jesli jednostka unit posiada 2 weapons of the same type"**
- Check: unit has 2 weapons equipped
- Check: both weapons are same type (both rifles, both pistols, etc.)
- Check: unit has dual_wield perk enabled

✅ **"when fire them, unit will pay for both energy consumption but only single action point cost"**
- Single AP cost (like normal shot)
- Both weapons' energy cost consumed (doubled)

✅ **"potential -10% to hit"**
- Accuracy penalty: -10% on dual-wield shots
- Display in targeting UI

---

## 📐 Architecture & Files

### Phase 1: PILOT Class System

**Files to Create/Modify:**

1. **mods/core/rules/unit/classes.toml**
   - Add PILOT class definition
   - Stats: SPEED 8, AIM 7, REACTION 8, others 5-6
   - Perks: [can_move, can_run, can_shoot, no_morale_penalty]
   - Health: 50 HP
   - Description: "Professional aircraft/spacecraft pilot"

2. **engine/basescape/logic/unit_system.lua** (if needed)
   - Add support for PILOT class in unit creation
   - Ensure pilot units load correctly

3. **docs/content/units/pilots.md** (NEW)
   - Comprehensive pilot documentation
   - Pilot class stats and progression
   - Requirements per craft
   - Examples

### Phase 2: Craft Pilot Requirements

**Files to Create/Modify:**

1. **mods/core/rules/content/crafts.toml**
   - Add to each craft:
     ```toml
     pilotsRequired = 2
     pilotClasses = ["pilot"]  # or ["bomber_pilot", "pilot"]
     minPilotLevel = 0
     requiresOfficer = false  # Large craft only
     ```

2. **engine/geoscape/logic/craft_system.lua**
   - Add craft.pilotsRequired field
   - Add craft.pilotClasses array
   - Add craft.minPilotLevel
   - Add craft.requiresOfficer boolean
   - Add validation: canOperate(pilots_assigned)
   - Add functions:
     - getPilotsRequired(): number
     - getPilotClassesRequired(): string[]
     - getAssignedPilots(): Unit[]
     - isFullyCrew(): boolean

3. **engine/geoscape/logic/craft_pilot_system.lua** (NEW)
   - Craft pilot validation
   - Pilot requirement checking
   - Craft operation prerequisites

### Phase 3: Capacity Distribution

**Files to Create/Modify:**

1. **mods/core/rules/content/crafts.toml**
   - Add capacity object:
     ```toml
     [craft_name.capacity]
     pilots = 2
     crew = 8
     cargo = 50  # in kg
     ```

2. **engine/geoscape/logic/craft_system.lua**
   - Extend craft entity:
     ```lua
     craft.capacity = {
       pilots = 2,
       crew = 8,
       cargo = 50
     }
     craft.assigned = {
       pilots = {},  -- Unit[]
       crew = {},    -- Unit[]
       cargo = {}    -- ItemStack[]
     }
     ```
   - Add functions:
     - getAvailablePilotSlots(): number
     - getAvailableCrewSlots(): number
     - getAvailableCargoSpace(): number
     - assignPilot(unit): bool
     - assignCrewMember(unit): bool
     - addCargo(item, quantity): bool

### Phase 4: PERKS System Framework

**Files to Create/Modify:**

1. **engine/battlescape/systems/perks_system.lua** (NEW, 300+ lines)
   ```lua
   -- PerkSystem
   -- Module for managing unit perks
   
   local PerkSystem = {}
   
   -- Perk registry
   PerkSystem.perks = {}  -- {perk_id -> {name, description, effects}}
   
   -- Per-unit perk tracking
   PerkSystem.unitPerks = {}  -- {unit_id -> {perk_id -> active}}
   
   -- Register perk
   function PerkSystem.registerPerk(id, name, description, effects)
   
   -- Get unit perks
   function PerkSystem.getUnitPerks(unitId)
   
   -- Check if perk active
   function PerkSystem.hasPerk(unitId, perkId)
   
   -- Enable perk
   function PerkSystem.enablePerk(unitId, perkId)
   
   -- Disable perk
   function PerkSystem.disablePerk(unitId, perkId)
   
   -- Apply perk effects
   function PerkSystem.applyPerkEffect(unitId, perkId)
   
   -- Get all perks
   function PerkSystem.getAvailablePerks()
   
   return PerkSystem
   ```

2. **mods/core/rules/unit/perks.toml** (NEW, 150+ lines)
   ```toml
   # Basic Movement Perks
   [[perks]]
   id = "can_move"
   name = "Can Move"
   description = "Unit can move normally"
   category = "basic"
   default_enabled = true
   
   [[perks]]
   id = "can_run"
   name = "Can Run"
   description = "Unit can run (double movement, double cost)"
   category = "basic"
   default_enabled = true
   
   [[perks]]
   id = "can_fly"
   name = "Can Fly"
   description = "Unit can fly over terrain"
   category = "movement"
   default_enabled = false
   
   [[perks]]
   id = "can_swim"
   name = "Can Swim"
   description = "Unit can move through water"
   category = "movement"
   default_enabled = false
   
   [[perks]]
   id = "can_breathe"
   name = "Can Breathe"
   description = "Unit survives without air (underwater)"
   category = "survival"
   default_enabled = true
   
   # Combat Perks
   [[perks]]
   id = "can_shoot"
   name = "Can Shoot"
   description = "Unit can use firearms"
   category = "combat"
   default_enabled = true
   
   [[perks]]
   id = "can_melee"
   name = "Can Melee"
   description = "Unit can perform melee attacks"
   category = "combat"
   default_enabled = true
   
   [[perks]]
   id = "can_throw"
   name = "Can Throw"
   description = "Unit can throw grenades and items"
   category = "combat"
   default_enabled = true
   
   [[perks]]
   id = "can_use_psionics"
   name = "Can Use Psionics"
   description = "Unit has psionic abilities available"
   category = "combat"
   default_enabled = false
   
   # Dual Wielding
   [[perks]]
   id = "two_weapon_proficiency"
   name = "Two-Weapon Proficiency"
   description = "Can fire 2 identical weapons for 1 AP (double energy cost, -10% accuracy)"
   category = "combat"
   default_enabled = false
   
   # Senses
   [[perks]]
   id = "darkvision"
   name = "Darkvision"
   description = "Can see in complete darkness"
   category = "senses"
   default_enabled = false
   
   [[perks]]
   id = "thermal_vision"
   name = "Thermal Vision"
   description = "Can see heat signatures through walls/smoke"
   category = "senses"
   default_enabled = false
   
   # Survival/Defensive
   [[perks]]
   id = "regeneration"
   name = "Regeneration"
   description = "Recover 1 HP per turn"
   category = "survival"
   default_enabled = false
   
   [[perks]]
   id = "poison_immunity"
   name = "Poison Immunity"
   description = "Immune to poison damage/effects"
   category = "survival"
   default_enabled = false
   
   [[perks]]
   id = "fear_immunity"
   name = "Fear Immunity"
   description = "Cannot be panicked or lose morale from fear"
   category = "survival"
   default_enabled = false
   ```

3. **docs/content/unit_systems/perks.md** (NEW, 500+ lines)
   - Comprehensive perk documentation
   - All 40+ perks with descriptions
   - Per-class default perks
   - Modding guide

### Phase 5: Dual-Wield Mechanic

**Files to Create/Modify:**

1. **engine/battlescape/systems/weapon_system.lua**
   - Add support for dual-wield checks:
     ```lua
     function WeaponSystem.canDualWield(unit)
       return unit:hasPerk("two_weapon_proficiency") and 
              unit:hasSecondaryWeapon() and
              unit:getWeaponType(primary) == unit:getWeaponType(secondary)
     end
     
     function WeaponSystem.fireDualWield(unit, target)
       -- Single AP cost
       apCost = 2  -- normal shot cost
       
       -- Double energy cost
       energyCost = 
         unit:getPrimaryWeapon().energyCost +
         unit:getSecondaryWeapon().energyCost
       
       -- Accuracy penalty -10%
       accuracy = accuracy * 0.9
       
       -- Fire both weapons with combined damage
     end
     ```

2. **engine/battlescape/ui/action_menu_system.lua**
   - Add "Dual Fire" action when available
   - Show: "2 Weapons" in weapon name
   - Show accuracy penalty: "-10%"
   - Show energy cost doubled

### Phase 6: Pilot Bonus System

**Files to Create/Modify:**

1. **engine/geoscape/logic/craft_pilot_system.lua** (EXTEND)
   ```lua
   function CraftPilotSystem.calculateCraftBonuses(craft)
     local bonuses = {
       speed = 0,
       accuracy = 0,
       damage = 0,
       energy = 0,
       evasion = 0,
       radar = 0
     }
     
     for _, pilot in ipairs(craft:getAssignedPilots()) do
       -- Each stat contributes to different bonus
       bonuses.speed += (pilot:getSpeed() - 5) / 100
       bonuses.accuracy += (pilot:getAim() - 5) / 100
       bonuses.damage += (pilot:getStrength() - 5) / 100
       bonuses.energy += (pilot:getEnergy() - 5) / 100
       bonuses.evasion += (pilot:getReaction() - 5) / 100
       bonuses.radar += (pilot:getSight() - 5) / 100 * 5
     end
     
     return bonuses
   end
   ```

2. **docs/content/crafts/pilot_bonuses.md** (NEW)
   - Pilot stat -> craft bonus mapping
   - Examples with numbers
   - Bonus calculation formula

### Phase 7: Pilot Progression

**Files to Create/Modify:**

1. **engine/basescape/logic/pilot_progression.lua** (NEW, 250+ lines)
   ```lua
   -- Pilot experience and rank system
   
   local PilotProgression = {}
   
   PilotProgression.RANKS = {
     {name = "Rookie", xp = 0},
     {name = "Veteran", xp = 100},
     {name = "Ace", xp = 300}
   }
   
   function PilotProgression.gainXP(pilot, amount)
     pilot.xp += amount
     while pilot.xp >= PilotProgression.RANKS[pilot.rank + 2].xp do
       PilotProgression.rankUp(pilot)
     end
   end
   
   function PilotProgression.rankUp(pilot)
     pilot.rank += 1
     pilot.speed += 1
     pilot.aim += 2
     pilot.reaction += 1
     pilot.experience = 0
   end
   
   return PilotProgression
   ```

2. **engine/interception/logic/interception_system.lua** (EXTEND)
   - Track pilot involvement in battle
   - Award XP on victory:
     ```lua
     local enemyHP = calculateTotalEnemyHP()
     local xpReward = enemyHP / 10  -- 10 XP per enemy HP
     
     for _, pilot in ipairs(interception.playerPilots) do
       PilotProgression.gainXP(pilot, xpReward)
     end
     ```

3. **mods/core/rules/unit/pilot_ranks.toml** (NEW)
   ```toml
   [[ranks]]
   rank = 0
   name = "Rookie"
   xp_required = 0
   speed_bonus = 0
   aim_bonus = 0
   reaction_bonus = 0
   
   [[ranks]]
   rank = 1
   name = "Veteran"
   xp_required = 100
   speed_bonus = 1
   aim_bonus = 2
   reaction_bonus = 1
   
   [[ranks]]
   rank = 2
   name = "Ace"
   xp_required = 300
   speed_bonus = 2
   aim_bonus = 4
   reaction_bonus = 2
   ```

### Phase 8: UI Systems

**Files to Create/Modify:**

1. **engine/geoscape/ui/craft_pilot_display.lua** (NEW, 200 lines)
   - Show pilot info in craft screen
   - Pilot name, rank, XP bar
   - Pilot portrait
   - Current bonuses applied to craft

2. **engine/basescape/ui/recruit_pilot_ui.lua** (NEW, 250 lines)
   - Recruitment screen
   - Convert soldier → pilot option
   - Cost: 5000 credits
   - Training time: 30 days

3. **engine/geoscape/ui/craft_crew_assignment.lua** (NEW, 300 lines)
   - Assign pilots to craft
   - Show required slots
   - Validate requirements
   - Show warnings

### Phase 9: Documentation Updates

**Files to Update:**

1. **api/UNITS.md**
   - Add PILOT section
   - Add Perk entity definition
   - Add pilot progression info

2. **api/CRAFTS.md**
   - Add pilot requirements section
   - Capacity system documentation
   - Pilot bonus calculations

3. **docs/content/units/pilots.md** (NEW)
   - 1000+ lines comprehensive guide
   - Pilot class, stats, progression
   - Interception XP gain system
   - Requirements per craft
   - Examples

4. **docs/content/unit_systems/perks.md** (NEW)
   - 1000+ lines comprehensive guide
   - 40+ perk definitions
   - Per-class default perks
   - Modding guide

---

## 🧪 Testing Strategy

### Unit Tests

1. **Test Perk System**
   - Create unit with perks
   - Enable/disable perks
   - Check hasPerks returns correct values

2. **Test Pilot Class**
   - Create PILOT unit
   - Verify stats (SPEED 8, AIM 7, REACTION 8)
   - Verify perks assigned

3. **Test Dual-Wield**
   - Unit with 2 identical weapons + perk
   - Fire dual: verify 1 AP cost, doubled energy
   - Verify -10% accuracy

### Integration Tests

1. **Pilot Interception XP**
   - Create 2-pilot craft
   - Engage UFO in interception
   - Win battle
   - Verify pilots gained XP
   - Verify rank-up if XP threshold crossed

2. **Craft Bonuses**
   - Create craft with high-rank pilots
   - Calculate bonuses
   - Verify in interception combat (+accuracy shown)

3. **Pilot Assignment**
   - Try deploy without pilots → blocked
   - Assign pilots → allowed
   - Try mission without required classes → blocked
   - Assign all required classes → allowed

### Manual Testing

1. Run game normally
2. Go to craft screen
3. Assign pilots to craft
4. Engage in interception
5. Check pilot XP gain
6. Verify craft bonuses applied

---

## 📊 Success Criteria

- [ ] PILOT class exists and can be recruited
- [ ] Crafts require 1-6 pilots per type
- [ ] Pilots gain XP from interception victories
- [ ] Pilot ranks increase with +speed, +aim, +reaction
- [ ] Pilot stats grant bonuses to craft
- [ ] PERKS system functional with 40+ perks
- [ ] Two-weapon proficiency perk enables dual-wield
- [ ] Dual-wield fires both weapons for 1 AP, -10% accuracy
- [ ] All documentation updated
- [ ] Game runs without errors
- [ ] All tests pass

---

## ⏱️ Time Breakdown

- Phase 1 (PILOT Class): 4-5 hours
- Phase 2 (Craft Requirements): 6-8 hours
- Phase 3 (Capacity System): 4-5 hours
- Phase 4 (PERKS Framework): 6-8 hours
- Phase 5 (Dual-Wield): 3-4 hours
- Phase 6 (Pilot Bonuses): 4-5 hours
- Phase 7 (Pilot Progression): 5-7 hours
- Phase 8 (UI Systems): 8-10 hours
- Phase 9 (Documentation): 5-7 hours
- Testing & Polish: 5-7 hours

**Total: 50-66 hours**

---

## 📚 Related Documentation

- [Pilot Class Design](../docs/content/units/pilots.md) (TBD)
- [Perks System Design](../docs/content/unit_systems/perks.md) (TBD)
- [Craft Pilot Bonuses](../docs/content/crafts/pilot_bonuses.md) (TBD)
- [UNITS.md API](../api/UNITS.md) - updated sections
- [CRAFTS.md API](../api/CRAFTS.md) - updated sections

---

**Task Created:** October 23, 2025  
**Task Status:** TODO → READY FOR EXECUTION

