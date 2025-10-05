# Capacity Systems

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Binary Validation Framework](#binary-validation-framework)
  - [Unit Encumbrance System](#unit-encumbrance-system)
  - [Craft Cargo Capacity](#craft-cargo-capacity)
  - [Validation Points and Timing](#validation-points-and-timing)
  - [Capacity Upgrade Paths](#capacity-upgrade-paths)
  - [Equipment Weight Categories](#equipment-weight-categories)
  - [Emergency Situations](#emergency-situations)
  - [Deterministic Calculations](#deterministic-calculations)
- [Examples](#examples)
  - [Soldier Loadout Validation](#soldier-loadout-validation)
  - [Craft Dispatch Scenarios](#craft-dispatch-scenarios)
  - [Capacity Progression Examples](#capacity-progression-examples)
  - [Mixed Unit Loading](#mixed-unit-loading)
  - [Overflow Handling](#overflow-handling)
  - [Upgrade Trade-offs](#upgrade-trade-offs)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Capacity Systems establish binary constraint frameworks governing equipment carrying limits and transport capacity throughout AlienFall operations. This deterministic validation system operates on a clear can/cannot principle without graduated penalties or hidden slowdown effects, forcing meaningful strategic decisions about loadout composition and craft selection. Unit Encumbrance constrains individual soldier equipment based on Strength statistics, while Craft Cargo Capacity governs both personnel transport (unit slots) and item recovery (weight capacity) creating dual-constraint optimization challenges.

The binary validation philosophy prioritizes player clarity and strategic planning over complex penalty calculations. When total weight exceeds capacity limits, configurations receive complete rejection with clear visual feedback rather than partial acceptance with performance degradation. This approach eliminates min-maxing through partial overloading while creating natural equipment progression where advanced technology typically provides enhanced capabilities at reduced weight costs. Pre-mission validation prevents invalid deployments, while runtime checks govern battlefield pickups and post-mission loot recovery.

## Mechanics

### Unit Encumbrance
- **Context:** Individual soldiers and their equipment
- **Metric:** Weight units based on Strength stat
- **Validation:** Pre-mission loadout and battlefield pickup
- **Reference:** [Units/Encumbrance.md](../units/Encumbrance.md)

### Craft Cargo Capacity
- **Context:** Craft transport and storage
- **Metrics:** Weight capacity (items/loot) + Unit capacity (personnel)
- **Validation:** Pre-dispatch and post-mission recovery
- **Reference:** [Crafts/Encumbrance.md](../crafts/Encumbrance.md)

---

## Common Validation Logic

Both systems share identical validation principles:

### Binary Validation
```
if Total_Weight > Capacity_Limit then
    REJECT configuration
else
    ACCEPT configuration
end
```

**No Graduated Penalties:**
- No speed reduction
- No accuracy penalties
- No progressive slowdown
- Simply: Over limit = Not allowed

### Design Philosophy

**Why Binary?**
1. **Clarity:** Players understand "can/cannot" better than "20% penalty"
2. **Balance:** Prevents min-maxing through partial overloading
3. **Simplicity:** Easier to implement and test
4. **Gameplay:** Forces meaningful loadout decisions

**Player Experience:**
- Clear feedback during equipment selection
- No hidden penalties to discover
- Strategic planning required
- Natural equipment progression (better gear = lighter/more capacity)

---

## Unit Encumbrance

### Core Mechanics

**Carrying Capacity Formula:**
```
Max_Weight = Strength × Weight_Multiplier
```

**Typical Values:**
- Weight Multiplier: 2.0 (configurable per difficulty)
- Strength 10 soldier: 20 weight units
- Strength 20 soldier: 40 weight units

### Equipment Weight

**Weight Categories:**
```toml
# Example item weights
[item.assault_rifle]
weight = 4

[item.heavy_plasma]
weight = 8

[item.medkit]
weight = 2

[item.grenade]
weight = 1
```

**Loadout Calculation:**
```
Total_Weight = Weapon_Weight + Armor_Weight + Sum(Item_Weights)
```

### Validation Points

**Pre-Mission:**
- Equipment screen validates loadout before mission start
- Red indicator if over capacity
- Cannot launch mission with invalid loadouts

**During Mission:**
- Pickup validation when attempting to grab items
- Swap validation when exchanging equipment
- Drop is always allowed (reduces weight)

### Edge Cases

**Temporary Strength Changes:**
- Wounded soldier: Strength reduced → capacity reduced
- Buffed soldier: Strength increased → capacity increased
- Recalculation happens immediately

**Equipment Changes:**
- Dropping weapon: Frees capacity
- Picking up weapon: Requires capacity
- Swapping weapons: Net weight change checked

**Unconscious Units:**
- Cannot pick up items
- Equipment remains on body
- Other units can loot unconscious allies

---

## Craft Cargo Capacity

### Core Mechanics

**Dual Capacity System:**

**1. Weight Capacity (Items/Loot):**
```
Max_Cargo_Weight = Craft_Base_Capacity + Cargo_Module_Bonus
```

**2. Unit Capacity (Personnel):**
```
Max_Units = Craft_Base_Slots + Troop_Module_Bonus
```

### Weight Capacity

**Cargo Calculation:**
```
Total_Cargo = Sum(Mission_Loot_Weight) + Sum(Extra_Items_Weight)
```

**Typical Craft Values:**
```toml
[craft.skyranger]
base_cargo_weight = 100

[craft.heavy_transport]
base_cargo_weight = 250
```

**Cargo Types:**
- Alien corpses (1-10 weight each)
- Alien weapons (2-15 weight each)
- Artifact fragments (5-50 weight each)
- Mission-specific loot (variable)

### Unit Capacity

**Personnel Calculation:**
```
Total_Personnel_Size = Sum(Unit_Size_Values)
```

**Size Classification:**
- **Size 1:** Normal humanoids (soldiers, small aliens)
- **Size 2:** Large creatures (mutons, cyberdiscs)
- **Size 4:** Huge creatures (sectopods, tanks)

**Typical Craft Values:**
```toml
[craft.skyranger]
base_unit_capacity = 8  # Can transport 8 size-1 units

[craft.heavy_transport]
base_unit_capacity = 16  # Can transport 16 size-1 units
```

**Mixed Loading Examples:**
- 6 soldiers (size 1 each) + 1 tank (size 4) = 10 total (OK for Skyranger capacity 8? NO)
- 8 soldiers (size 1 each) = 8 total (OK for Skyranger)
- 4 soldiers + 2 mutons captured = 4 + 2×2 = 8 total (OK for Skyranger)

### Validation Points

**Pre-Dispatch:**
- Craft assignment screen shows capacity usage
- Cannot launch craft with over-capacity personnel
- Warning if cargo space insufficient for expected loot

**Post-Mission:**
- Loot validation when returning to base
- Excess loot must be left behind (player choice)
- Captured aliens count against unit capacity

**Emergency Situations:**
- Craft destroyed: All cargo lost
- Craft damaged: Cargo capacity may be reduced
- Emergency evac: May sacrifice loot to save personnel

---

## Capacity Upgrades

### Unit Strength Progression

**Stat Increases:**
- Combat experience: +1-3 Strength over campaign
- Gene mods: +5-10 Strength (research unlocks)
- Power armor: Effective +5 Strength (capacity bonus)

**Effective Capacity Growth:**
```
Early Game: 10 Strength × 2 = 20 weight (basic loadout)
Mid Game:   15 Strength × 2 = 30 weight (expanded loadout)
Late Game:  25 Strength × 2 = 50 weight (full equipment)
```

### Craft Capacity Upgrades

**Module Installation:**
```toml
[module.cargo_expansion]
weight_bonus = 50
unit_bonus = 0

[module.troop_bay]
weight_bonus = 0
unit_bonus = 4

[module.heavy_cargo_bay]
weight_bonus = 100
unit_bonus = 2
```

**Strategic Trade-offs:**
- Cargo modules vs. weapon modules
- Unit capacity vs. fuel capacity
- Armor vs. transport capability

---

## Cross-System Comparison

| Aspect | Unit Encumbrance | Craft Cargo Capacity |
|--------|------------------|----------------------|
| **Metric** | Weight units | Weight + Unit size |
| **Base Limit** | Strength × 2 | Craft-defined |
| **Validation** | Pre-mission + pickups | Pre-dispatch + return |
| **Upgrades** | Stat progression | Module installation |
| **Flexibility** | Dynamic (stat changes) | Static (craft type) |
| **Penalty** | Cannot equip/pickup | Cannot dispatch/recover |
| **Player Control** | Loadout management | Craft/module selection |

---

## Design Considerations

### Balance Philosophy

**Early Game:**
- Limited capacity forces prioritization
- Basic equipment = reasonable loadouts
- Soldiers can carry rifle + armor + 2-3 items

**Mid Game:**
- Improved stats allow more equipment
- Specialized loadouts become viable
- Choice between versatility vs. specialization

**Late Game:**
- High capacity enables full equipment suites
- Power armor + heavy weapons + utility items
- Capacity rarely limiting factor

### Player Experience

**Feedback Systems:**
- Visual capacity bars (current/maximum)
- Color-coded warnings (green/yellow/red)
- Hover tooltips showing weight breakdown
- Pre-validation prevents invalid states

**Strategic Decisions:**
- Heavy weapons vs. utility items
- Armor protection vs. equipment slots
- Craft type selection for mission needs
- Module priorities for fleet composition

---

## Implementation Notes

### Love2D Integration

**Data Tables:**
```toml
# data/units/[unit_type].toml
[stats]
strength = 12
weight_multiplier = 2.0

# data/items/[item].toml
weight = 4

# data/crafts/[craft_type].toml
cargo_weight = 100
unit_capacity = 8

# data/modules/[module].toml
cargo_weight_bonus = 50
unit_capacity_bonus = 4
```

**Event Bus:**
- `capacity:validation_failed` - Fired when over-limit attempt
- `capacity:equipment_changed` - Fired when loadout updated
- `capacity:craft_loaded` - Fired when craft dispatch validated
- `capacity:loot_overflow` - Fired when must abandon items

**State Management:**
```lua
-- Unit encumbrance
local current_weight = calculate_equipment_weight(unit)
local max_weight = unit.stats.strength * unit.weight_multiplier
local can_equip = (current_weight + item.weight) <= max_weight

-- Craft capacity
local current_cargo = calculate_cargo_weight(craft)
local current_units = calculate_unit_size(craft)
local can_dispatch = current_cargo <= craft.cargo_weight and 
                     current_units <= craft.unit_capacity
```

### Deterministic Simulation

**Seed Usage:**
```
seed:capacity:[context]:[id]:[event]
```

**Deterministic Events:**
- Strength stat rolls (on level up)
- Loot drop weights (procedural missions)
- Capacity module availability (research)

**Non-Deterministic:**
- Player loadout choices (intentional player agency)
- Loot pickup decisions (player choice)
- Module installation order (player strategy)

---

## UI/UX Specifications

### Capacity Display

**Equipment Screen:**
```
┌─────────────────────────────┐
│ SOLDIER: CPL. MARTINEZ      │
│ Strength: 15   Capacity: 30 │
├─────────────────────────────┤
│ [████████████░░░░░░] 24/30  │
│                              │
│ ☑ Assault Rifle (4)         │
│ ☑ Tactical Armor (8)        │
│ ☑ Medkit (2)                │
│ ☑ Grenades x5 (5)           │
│ ☑ Ammo Clips x2 (2)         │
│ ☑ Motion Tracker (3)        │
└─────────────────────────────┘
```

**Craft Dispatch Screen:**
```
┌─────────────────────────────┐
│ CRAFT: SKYRANGER-1          │
│ Personnel: 8   Cargo: 100   │
├─────────────────────────────┤
│ Units: [████████] 8/8       │
│ Cargo: [███░░░░░] 45/100    │
│                              │
│ ☑ 8 Soldiers (8)            │
│ ☑ Equipment (45)            │
│ ☐ Expected Loot (~30)       │
│   Warning: May exceed limit │
└─────────────────────────────┘
```

### Grid Alignment
- Capacity bars: 2 grid units tall (40px)
- Item icons: 1 grid unit (20px)
- Capacity text: 1 grid unit (20px font)

---

## Cross-References

**Related Systems:**
- [Energy Systems](Energy_Systems.md) - Weight vs. energy tradeoffs
- [Action Economy](Action_Economy.md) - Movement unaffected by weight
- [Units/Encumbrance](../units/Encumbrance.md) - Detailed unit mechanics
- [Crafts/Encumbrance](../crafts/Encumbrance.md) - Detailed craft mechanics

**Integration Points:**
- [Items System](../items/README.md) - Item weights and categories
- [Equipment Screen](../GUI/Equipment_Screen.md) - Loadout management UI
- [Craft Operations](../geoscape/Craft Operations.md) - Dispatch validation
- [Mission System](../integration/Mission_Lifecycle.md) - Loot recovery

---

## Version History

- **v1.0 (2025-09-30):** Initial master document consolidating unit and craft capacity systems
