# Item Design Checklist

**Tags:** #content-creation #item-design #balance #equipment  
**Last Updated:** September 30, 2025  
**Related:** [[README]], [[Enemy_Design_Process]], [[Mission_Design_Template]]

---

## Overview

This checklist ensures all items and equipment in Alien Fall meet quality, balance, and integration standards. Use this document when creating weapons, armor, grenades, and utility items.

---

## Item Design Checklist

### PHASE 1: CONCEPT (30 minutes)

- [ ] **Item name** defined and unique
- [ ] **Item category** selected (weapon/armor/grenade/utility/consumable)
- [ ] **Tactical role** clearly defined
- [ ] **Visual concept** sketched or described
- [ ] **Unique mechanic** identified (what makes it special?)
- [ ] **Tech tier** assigned (early/mid/late game)
- [ ] **Concept approved** by lead designer

**Deliverables:** 1-page concept document

---

### PHASE 2: STAT DESIGN (1-2 hours)

#### Weapon Stats
- [ ] **Base damage** balanced against tier
- [ ] **Accuracy** appropriate for weapon type
- [ ] **Range** (short/medium/long) defined
- [ ] **Ammo capacity** balanced
- [ ] **AP cost** per shot reasonable
- [ ] **Critical chance** and damage set
- [ ] **Special effects** (stun, burn, etc.) defined
- [ ] **Comparison chart** vs similar weapons created

#### Armor Stats
- [ ] **Armor value** appropriate for tier
- [ ] **Movement penalty** (if any) balanced
- [ ] **Special resistances** (fire, psi, etc.) defined
- [ ] **Inventory slots** (if adds slots) specified
- [ ] **Comparison chart** vs other armor created

#### Grenade/Utility Stats
- [ ] **Effect radius** defined
- [ ] **Damage/effect strength** balanced
- [ ] **AP cost** to use reasonable
- [ ] **Limited uses** (1-3 typical) set
- [ ] **Special mechanics** fully specified

**Deliverables:** Complete stat block in TOML format

---

### PHASE 3: ECONOMIC BALANCE (1 hour)

- [ ] **Research prerequisites** identified
- [ ] **Manufacturing cost** calculated
  - [ ] Money cost ($X,XXX)
  - [ ] Material requirements (elerium, alloys, etc.)
  - [ ] Manufacturing time (hours/days)
  - [ ] Engineer requirements
- [ ] **Purchase cost** (if buyable) set at 150-200% of manufacturing
- [ ] **Sell value** set at 40-60% of purchase/manufacturing cost
- [ ] **Maintenance cost** (if applicable) defined
- [ ] **Tech tree placement** validated
- [ ] **Progression curve** verified (available at appropriate time)

**Deliverables:** Economy data table

---

### PHASE 4: VISUAL DESIGN (2-4 hours)

- [ ] **Sprite created** (10×10 pixels for items, 20×20 for equipped)
- [ ] **Inventory icon** created (20×20 or 40×40 pixels)
- [ ] **Color palette** uses approved colors
- [ ] **Silhouette** readable and distinct
- [ ] **Animation frames** (if weapon):
  - [ ] Idle/holstered
  - [ ] Aim
  - [ ] Fire/use
  - [ ] Reload (if applicable)
- [ ] **VFX defined** (muzzle flash, projectile, impact)
- [ ] **SFX defined** (shoot, reload, equip sounds)
- [ ] **Sprite sheet compiled** and optimized

**Deliverables:** Item sprite sheet PNG, VFX specs, audio specs

---

### PHASE 5: DESCRIPTION & LORE (30 minutes)

- [ ] **Short description** (1-2 sentences for UI tooltip)
- [ ] **Long description** (2-3 paragraphs for Pedia)
- [ ] **Lore text** establishes world flavor
- [ ] **Tactical tips** included (how to best use item)
- [ ] **Stat text** explains mechanical effects clearly
- [ ] **All text** reviewed for grammar/spelling
- [ ] **Localization keys** added

**Deliverables:** Item description text document

---

### PHASE 6: IMPLEMENTATION (2-3 hours)

- [ ] **TOML data file** created in correct location
- [ ] **Item ID** unique and follows naming convention (snake_case)
- [ ] **Stats** match design document exactly
- [ ] **Prerequisites** correctly referenced
- [ ] **Costs** correctly specified
- [ ] **Loot tables** updated (if enemy drops item)
- [ ] **Tech tree** updated with unlock conditions
- [ ] **Manufacturing menu** updated
- [ ] **Shop/market** updated (if purchasable)
- [ ] **Sprite references** point to correct files
- [ ] **No syntax errors** in TOML

**Deliverables:** Integrated item data file

---

### PHASE 7: TESTING (2-3 hours)

#### Functional Testing
- [ ] Item loads without errors
- [ ] Item appears in correct menus
- [ ] Stats display correctly in UI
- [ ] Item can be equipped/used
- [ ] Special effects trigger correctly
- [ ] VFX and SFX play correctly
- [ ] No crashes or bugs

#### Balance Testing
- [ ] Item performs as intended in combat
- [ ] Damage output appropriate for tier
- [ ] Not overpowered compared to alternatives
- [ ] Not useless or underpowered
- [ ] Cost-to-benefit ratio reasonable
- [ ] Viable tactical applications exist

#### Integration Testing
- [ ] Research unlock works correctly
- [ ] Manufacturing functions properly
- [ ] Item appears in loot drops (if applicable)
- [ ] Savegame compatibility maintained
- [ ] Mod compatibility verified

**Deliverables:** Test report with pass/fail results

---

### PHASE 8: BALANCE TUNING (1-2 hours)

- [ ] **Playtester feedback** collected (minimum 5 players)
- [ ] **Usage statistics** reviewed (if in alpha/beta)
- [ ] **Balance adjustments** made based on data:
  - [ ] Damage tweaked
  - [ ] Cost adjusted
  - [ ] Availability changed
  - [ ] Special effects refined
- [ ] **Comparison tests** run against similar items
- [ ] **Edge cases** addressed (exploits, cheese tactics)
- [ ] **Final balance** approved by balance designer

**Deliverables:** Balance report, adjusted stats

---

### PHASE 9: DOCUMENTATION (30 minutes)

- [ ] **Wiki page** created or updated
- [ ] **Item catalog** updated with new entry
- [ ] **Tech tree diagram** reflects new item
- [ ] **Strategy guide** mentions item (if notable)
- [ ] **Changelog** entry written
- [ ] **Mod API docs** updated (if item uses new systems)

**Deliverables:** Complete documentation

---

### PHASE 10: RELEASE (30 minutes)

- [ ] **Final code review** completed
- [ ] **Final art review** completed
- [ ] **All tests passing**
- [ ] **Documentation complete**
- [ ] **Merged to main branch**
- [ ] **Patch notes** written
- [ ] **Community announcement** (if major item)
- [ ] **Release approved** by project lead

**Deliverables:** Released item in stable build

---

## Item Balance Guidelines

### Weapon Progression

**Tier 1: Conventional (Early Game)**
- Damage: 3-6
- Accuracy: 60-70%
- Cost: $500-2,000
- Examples: Assault Rifle, Pistol, Shotgun

**Tier 2: Laser (Mid Game)**
- Damage: 5-8
- Accuracy: 70-80%
- Cost: $3,000-6,000
- Examples: Laser Rifle, Laser Pistol, Heavy Laser

**Tier 3: Plasma (Late Game)**
- Damage: 7-12
- Accuracy: 75-85%
- Cost: $8,000-15,000
- Examples: Plasma Rifle, Plasma Pistol, Heavy Plasma

**Tier 4: Exotic (End Game)**
- Damage: 10-16
- Accuracy: 80-90%
- Cost: $15,000-30,000
- Examples: Fusion Lance, Particle Beam, Blaster Launcher

### Armor Progression

**Tier 1: Kevlar Vest**
- Armor: 2
- Movement: -0
- Cost: $1,000

**Tier 2: Carapace Armor**
- Armor: 4
- Movement: -1
- Cost: $4,000

**Tier 3: Titan Armor**
- Armor: 8
- Movement: -2
- Cost: $8,000

**Tier 4: Ghost Armor**
- Armor: 6
- Movement: -0
- Special: Stealth
- Cost: $12,000

### Grenade Balance

**Damage Radius Formula:**
```
Center tile: Full damage
Adjacent tiles (radius 1): 75% damage
Radius 2: 50% damage
Radius 3: 25% damage
```

**Grenade Types:**
- **Frag**: 6 damage, radius 2, $50
- **High Explosive**: 10 damage, radius 3, $150
- **Incendiary**: 4 damage + 3 burn/turn, radius 2, $75
- **Smoke**: No damage, blocks LOS, radius 3, $25
- **Flashbang**: No damage, stuns radius 2, $60
- **Alien Grenade**: 12 damage, radius 3, $300

### Utility Item Guidelines

**Medkit**: Heals 6 HP, 3 uses, $50  
**Scanner**: Reveals enemies 15 tiles, 1 use per mission, $200  
**Mind Shield**: +40 Will vs psi, passive, $500  
**Arc Thrower**: Stun for capture, 4 AP, 60% success, $800  
**Grappling Hook**: Reach elevation, 4 AP, unlimited, $150  

---

## Item Categories

### Weapons

**Primary Weapons** (2-handed, main damage)
- Assault Rifles (balanced)
- Sniper Rifles (long range, high damage)
- Shotguns (close range, high spread)
- Heavy Weapons (LMG, rockets)
- Alien Weapons (plasma, etc.)

**Secondary Weapons** (1-handed, backup)
- Pistols (accurate, low damage)
- Machine Pistols (spray, low accuracy)
- Melee Weapons (swords, stun batons)

**Special Weapons** (unique mechanics)
- Rocket Launchers (explosive, limited ammo)
- Grenade Launchers (arc trajectory)
- Flamethrowers (cone AoE, burning)
- Psi Amps (psionic abilities)

### Armor

**Body Armor** (main protection)
- Light (low armor, full mobility)
- Medium (balanced)
- Heavy (high armor, movement penalty)
- Powered (exoskeleton, enhanced stats)

**Tactical Vests** (utility slots)
- Increases grenade/item capacity
- Minimal armor bonus
- No movement penalty

### Grenades & Explosives

**Lethal**
- Frag Grenade
- High Explosive
- Alien Grenade

**Tactical**
- Smoke Grenade
- Flashbang
- Gas Grenade

**Special**
- Incendiary
- EMP (vs robots)
- Acid (vs armor)

### Utility Items

**Medical**
- Medkit
- Stim Pack
- Revival Protocol

**Tactical**
- Scanner
- Motion Tracker
- Combat Stims

**Psi Protection**
- Mind Shield
- Psi Screen
- Ethereal Cage

**Capture**
- Arc Thrower
- Stasis Field
- Restraints

---

## Item Naming Conventions

### File Naming
```
items/weapons/rifle_laser_01.toml
items/armor/vest_carapace.toml
items/grenades/grenade_frag.toml
items/utility/medkit_advanced.toml
```

### Item IDs
```lua
-- Format: category_type_variant
weapon_rifle_assault_conventional
armor_body_carapace
grenade_frag
utility_medkit_basic
```

### Display Names
```
Assault Rifle (clear, descriptive)
Laser Rifle (tech tier obvious)
Plasma Rifle (progression clear)
Heavy Plasma (variant specified)
```

---

## Common Item Design Pitfalls

### ❌ Power Creep
**Problem:** Each new item invalidates previous  
**Solution:** Situational advantages, not pure upgrades

### ❌ Overly Complex
**Problem:** Too many mechanics, hard to understand  
**Solution:** Keep it simple, clear mechanics

### ❌ No Counter-Play
**Problem:** Item with no downside or counter  
**Solution:** Every strength has a weakness

### ❌ Useless Items
**Problem:** No viable tactical application  
**Solution:** Ensure every item has use cases

### ❌ Unclear Description
**Problem:** Players don't understand what item does  
**Solution:** Write clear, concise descriptions with examples

### ❌ Visual Confusion
**Problem:** Item looks like another item  
**Solution:** Distinct silhouettes and colors

### ❌ Economy Breaking
**Problem:** Item too cheap/expensive for power level  
**Solution:** Follow cost formulas, test thoroughly

---

## Item Cost Formula

### Weapon Cost Calculation
```
Base Cost = $500

+ Damage × $150 per point above 4
+ Accuracy × $40 per 1% above 65%
+ Range modifier:
  * Short: -$200
  * Medium: +$0
  * Long: +$300
+ Special effects: +$500-2,000 each
+ Tech tier multiplier:
  * Conventional: ×1.0
  * Laser: ×1.5
  * Plasma: ×2.5
  * Exotic: ×4.0

Example: Laser Rifle
$500 + (6 damage × $150) + (75% acc × $40 × 10) + $0 + $0
= $500 + $900 + $400
= $1,800 × 1.5 (laser tier)
= $2,700
```

### Armor Cost Calculation
```
Base Cost = $300

+ Armor value × $400 per point
- Movement penalty × $200 per point
+ Special effects: +$1,000-5,000 each
+ Tech tier multiplier

Example: Carapace Armor
$300 + (4 armor × $400) - (1 movement × $200)
= $300 + $1,600 - $200
= $1,700 × 1.5 (alien tech tier)
= $2,550 (round to $2,500)
```

---

## Item Templates

### Weapon Template
```toml
[item]
id = "weapon_rifle_laser"
name = "Laser Rifle"
category = "weapon"
subcategory = "rifle"
tech_tier = 2
description_short = "Energy weapon firing concentrated light beams."
description_long = "The Laser Rifle represents our first successful adaptation of alien energy technology. Highly accurate with no ballistic drop, perfect for medium to long range engagements."

[stats]
damage = 6
armor_penetration = 2
accuracy = 75
critical_chance = 10
critical_multiplier = 1.5
range_short = 12
range_medium = 24
range_long = 36
ammo_capacity = 20
reload_ap = 4
fire_ap = 6
fire_modes = ["single", "burst"]

[economy]
research_required = "laser_weapons"
manufacture_cost = 2700
manufacture_time = 240  # hours
materials = [
    {item = "elerium", quantity = 5},
    {item = "alien_alloys", quantity = 10}
]
engineers_required = 10
sell_value = 1350

[visual]
sprite = "items/weapons/laser_rifle.png"
icon = "items/icons/laser_rifle.png"
equipped_sprite = "items/equipped/laser_rifle.png"
muzzle_flash = "vfx/muzzle_laser.png"
projectile = "vfx/projectile_laser_blue.png"
impact = "vfx/impact_laser.png"

[audio]
fire = "audio/weapons/laser_fire.ogg"
reload = "audio/weapons/energy_reload.ogg"
equip = "audio/weapons/weapon_equip.ogg"
```

### Armor Template
```toml
[item]
id = "armor_carapace"
name = "Carapace Armor"
category = "armor"
tech_tier = 2
description_short = "Alien alloy composite armor plating."
description_long = "Carapace Armor incorporates reverse-engineered alien materials to provide superior protection while maintaining soldier mobility."

[stats]
armor_value = 4
movement_penalty = 1
inventory_slots = 2  # Extra utility slots
special_resistances = {fire = 25, acid = 25}

[economy]
research_required = "alien_materials"
manufacture_cost = 2500
manufacture_time = 300
materials = [
    {item = "alien_alloys", quantity = 30},
    {item = "elerium", quantity = 3}
]
engineers_required = 15
sell_value = 1250

[visual]
sprite = "items/armor/carapace.png"
icon = "items/icons/armor_carapace.png"
equipped_sprite_male = "items/equipped/carapace_male.png"
equipped_sprite_female = "items/equipped/carapace_female.png"
```

---

## Item Catalog

Track all items in game:

| ID | Name | Category | Tier | Cost | Status |
|----|------|----------|------|------|--------|
| weapon_rifle_assault | Assault Rifle | Weapon | 1 | $800 | Complete |
| weapon_rifle_laser | Laser Rifle | Weapon | 2 | $2,700 | Complete |
| armor_vest_kevlar | Kevlar Vest | Armor | 1 | $1,000 | Complete |
| grenade_frag | Frag Grenade | Grenade | 1 | $50 | Complete |
| utility_medkit | Medkit | Utility | 1 | $50 | Complete |
| ... | ... | ... | ... | ... | ... |

**Total Items:** 80+ (target: 120+)

---

## Related Documentation

- [[README]] - Content pipeline overview
- [[Enemy_Design_Process]] - Enemy unit creation
- [[Mission_Design_Template]] - Mission design
- [[../../items/README]] - Item system documentation
- [[../../economy/README]] - Economy and manufacturing

---

**Document Status:** Complete  
**Review Date:** October 7, 2025  
**Owner:** Systems Designer
