# Items & Equipment API Reference

**System:** Strategic Layer (Inventory & Equipment)  
**Module:** `engine/content/items/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The Items system manages all equipment, weapons, consumables, armor, and resources in the game. Items are the physical manifestation of equipment that units use in combat, bases store, and players trade. The system tracks item properties, stacking behavior, durability, equipment slots for units, and crafting requirements. Items form the backbone of unit effectiveness and resource management.

**Layer Classification:** Strategic / Equipment & Inventory  
**Primary Responsibility:** Item definitions, item stacks, equipment slots, durability, crafting recipes  
**Integration Points:** Inventory (storage), Equipment (unit loadouts), Trading (market items), Crafting (production)

---

## Implementation Status

### ✅ Implemented (in engine/content/items/)
- ItemDefinition entity with properties and stats
- ItemStack entity with durability and condition tracking
- Equipment slot system with compatibility
- Item access and unlocking via research
- Basic item functionality and stat bonuses
- TOML configuration support

### 🚧 Partially Implemented
- Crafting recipe system
- Marketplace trading
- Stacking operations

### 📋 Planned
- Advanced item properties
- Item degradation mechanics
- Complex crafting chains

---

## Core Entities

### Entity: ItemDefinition

Base definition for an item type with all properties.

**Properties:**
```lua
ItemDefinition = {
  id = string,                    -- "rifle_standard"
  name = string,                  -- "Rifle"
  description = string,           -- "Standard rifle, reliable"
  type = string,                  -- "weapon", "armor", "consumable", "resource", "ammo"
  
  -- Classification
  category = string,              -- "primary_weapon", "armor_torso", "medical", "grenade"
  subcategory = string | nil,     -- More specific type
  rarity = string,                -- "common", "uncommon", "rare", "epic", "legendary"
  tier = number,                  -- Tech tier requirement (1-5)
  
  -- Physical Properties
  weight = number,                -- kg (affects encumbrance)
  bulk = number,                  -- Grid size (1-8 for inventory)
  durability = number,            -- 0-100 (degrades with use)
  value = number,                 -- Sale price in credits
  
  -- Functionality (for weapons/armor)
  primary_stat = number,          -- Damage, AC, healing, etc.
  secondary_stats = table,        -- {stat_name: value}
  stat_bonuses = table,           -- {bonus_type: percent}
  
  -- Availability
  is_craftable = boolean,
  craft_components = table,       -- {component_id: quantity}
  craft_time = number,            -- Turns to craft
  availability = string,          -- "default", "research:tech_name"
  required_tech = string | nil,   -- Must have researched tech
  
  -- Stack behavior
  max_stack_size = number,        -- 1 for weapons, 100+ for consumables
  is_stackable = boolean,
  
  -- Ammunition/Consumable
  uses_per_unit = number,         -- Bullets per magazine, etc.
  is_consumable = boolean,
  
  -- Visual
  icon_id = string,
  color = string,
}
```

**Functions:**
```lua
-- Access
ItemDefinition.getItem(item_id: string) → ItemDefinition | nil
ItemDefinition.getItems() → ItemDefinition[]
ItemDefinition.getItemsByType(type: string) → ItemDefinition[]
ItemDefinition.getItemsByCategory(category: string) → ItemDefinition[]
ItemDefinition.getItemsByRarity(rarity: string) → ItemDefinition[]

-- Queries
item:getName() → string
item:getType() → string
item:getWeight() → number
item:getValue() → number
item:getStackSize() → number
item:canStack() → boolean
item:isAvailable() → boolean
item:getPrimaryStat() → number
item:getSecondaryStats() → table
```

---

### Entity: ItemStack

Instance of an item in inventory or equipped on unit.

**Properties:**
```lua
ItemStack = {
  id = string,                    -- "stack_001"
  definition_id = string,         -- Reference to ItemDefinition
  quantity = number,              -- How many (1 if not stackable)
  
  -- Condition
  durability = number,            -- Current durability (0-max)
  max_durability = number,        -- Full durability
  condition = string,             -- "pristine", "worn", "damaged", "broken"
  uses_remaining = number,        -- For ammo/consumables
  
  -- Equipment state
  equipped_to = string | nil,     -- Unit ID if equipped
  equipped_slot = string | nil,   -- Equipment slot type
  is_equipped = boolean,
  
  -- Modifications
  modifications = string[],       -- Applied mods (id list)
  is_modified = boolean,
  mod_stats = table,              -- Stat bonuses from mods
  
  -- History
  created_turn = number,
  last_used_turn = number,
  usage_count = number,           -- Times used
  damage_taken = number,          -- Accumulated damage
}
```

**Functions:**
```lua
-- Creation
ItemStack.new(definition_id: string, quantity: number) → ItemStack
ItemStack.getDefinition() → ItemDefinition
ItemStack.getName() → string

-- Stacking
stack:canCombine(other_stack: ItemStack) → boolean
stack:combine(other_stack: ItemStack) → ItemStack (remaining items)
stack:split(quantity: number) → ItemStack (new stack)

-- Condition
stack:getDurability() → number
stack:getDurabilityPercent() → number (0-100)
stack:takeDamage(damage: number) → void
stack:repair(amount: number) → void
stack:getCondition() → string
stack:isBroken() → boolean

-- Equipment
stack:equip(unit: Unit) → boolean
stack:unequip() → void
stack:isEquipped() → boolean
stack:getEquippedUnit() → Unit | nil

-- Modifications
stack:addModification(mod_id: string) → boolean
stack:removeModification(mod_id: string) → boolean
stack:getModifications() → string[]
```

---

### Entity: EquipmentSlot

Slot on a unit for equipping items.

**Properties:**
```lua
EquipmentSlot = {
  id = string,                    -- "left_hand", "chest", "head"
  name = string,                  -- Display name
  type = string,                  -- "hand", "torso", "head", "legs", "feet", "utility"
  
  -- Equipped item
  equipped_item = ItemStack | nil,-- Currently equipped
  allowed_item_types = string[],  -- "weapon", "armor", "grenade", "consumable"
  
  -- Stats
  base_stat_bonus = number,       -- Inherent slot bonus
  equipped_stat_bonus = number,   -- From item
  required_strength = number,     -- Strength needed to equip
  
  -- Limits
  is_mandatory = boolean,         -- Must always have something
  max_items = number,             -- Max items in slot
}
```

**Functions:**
```lua
-- Queries
slot:isOccupied() → boolean
slot:canEquip(item: ItemStack) → boolean
slot:getEquippedItem() → ItemStack | nil
slot:getAvailableSpace() → number

-- Operations
slot:equip(item: ItemStack) → (success: boolean, error: string | nil)
slot:unequip() → ItemStack | nil
slot:swap(item: ItemStack) → ItemStack | nil (unequipped item)
```

---

## Services & Functions

### Item Manager Service

```lua
-- Item access
ItemManager.getItem(item_id: string) → ItemDefinition | nil
ItemManager.getItems() → ItemDefinition[]
ItemManager.getItemsByType(type: string) → ItemDefinition[]
ItemManager.getItemsByCategory(category: string) → ItemDefinition[]
ItemManager.getItemsByRarity(rarity: string) → ItemDefinition[]
ItemManager.getItemsByTier(tier: number) → ItemDefinition[]

-- Availability
ItemManager.isItemAvailable(item_id: string) → boolean
ItemManager.getAvailableItems() → ItemDefinition[]
ItemManager.getUnavailableItems() → ItemDefinition[]
ItemManager.unlockItem(item_id: string) → void (via research)
ItemManager.lockItem(item_id: string) → void

-- Creation
ItemManager.createItemStack(item_id: string, quantity: number) → ItemStack
ItemManager.createRandomItem(rarity: string) → ItemStack
ItemManager.createModifiedStack(item_id: string, modifications: string[]) → ItemStack
```

### ItemStack Service

```lua
-- Stack management
ItemStackManager.getStack(stack_id: string) → ItemStack | nil
ItemStackManager.getAllStacks() → ItemStack[]
ItemStackManager.getStacksByType(type: string) → ItemStack[]

-- Stacking operations
ItemStackManager.canStack(stack1: ItemStack, stack2: ItemStack) → boolean
ItemStackManager.combineStacks(stack1: ItemStack, stack2: ItemStack) → ItemStack[]
ItemStackManager.splitStack(stack: ItemStack, quantity: number) → (stack1: ItemStack, stack2: ItemStack)
ItemStackManager.mergeStacks(stacks: ItemStack[]) → ItemStack[] (optimized stacks)

-- Condition management
ItemStackManager.damageStack(stack: ItemStack, damage: number) → void
ItemStackManager.repairStack(stack: ItemStack, amount: number) → void
ItemStackManager.hasBreakChance(stack: ItemStack) → boolean
ItemStackManager.checkBreakage(stack: ItemStack) → void (may break)
```

### Equipment Service

```lua
-- Equipment slots
EquipmentService.getEquipmentSlots(unit: Unit) → EquipmentSlot[]
EquipmentService.getSlot(unit: Unit, slot_id: string) → EquipmentSlot | nil
EquipmentService.getEmptySlots(unit: Unit) → EquipmentSlot[]

-- Equipping
EquipmentService.equipItem(unit: Unit, slot_id: string, item: ItemStack) → (success: boolean, error: string | nil)
EquipmentService.unequipItem(unit: Unit, slot_id: string) → ItemStack | nil
EquipmentService.swapItems(unit: Unit, slot1: string, slot2: string) → boolean
EquipmentService.getEquippedItems(unit: Unit) → ItemStack[]

-- Stat calculation
EquipmentService.calculateEquipmentStats(unit: Unit) → table (all stat bonuses)
EquipmentService.getEquippedWeapon(unit: Unit) → ItemStack | nil (primary weapon)
EquipmentService.getSecondaryWeapon(unit: Unit) → ItemStack | nil
EquipmentService.getArmor(unit: Unit) → ItemStack | nil (body armor)
EquipmentService.getTotalCarryWeight(unit: Unit) → number
```

### Item Crafting Service

```lua
-- Crafting queries
CraftingService.canCraft(item_id: string) → boolean
CraftingService.getCraftRecipe(item_id: string) → table (components, cost, time)
CraftingService.checkIngredients(item_id: string, inventory: ItemStack[]) → boolean
CraftingService.getAvailableRecipes(inventory: ItemStack[]) → string[] (item IDs)

-- Crafting execution
CraftingService.craftItem(item_id: string, facility: Facility, quantity: number) → ProductionJob
CraftingService.canCraftMultiple(item_id: string, quantity: number, inventory: ItemStack[]) → boolean
CraftingService.getRequiredIngredients(item_id: string, quantity: number) → table
```

### Item Marketplace Service

```lua
-- Market operations
MarketplaceService.listItem(item: ItemStack, price: number) → listing_id
MarketplaceService.delistItem(listing_id: string) → void
MarketplaceService.buyItem(listing_id: string, quantity: number, buyer_budget: number) → (success: boolean, cost: number)
MarketplaceService.sellItem(item: ItemStack, quantity: number) → number (credit amount)

-- Market queries
MarketplaceService.getItemPrice(item_id: string) → number (market rate)
MarketplaceService.getAvailableItemsForSale() → ItemStack[]
MarketplaceService.getMarketHistory(item_id: string) → table (price history)
```

---

## Configuration (TOML)

### Weapons

```toml
# content/items/weapons.toml

[[weapons]]
id = "rifle_standard"
name = "Rifle"
type = "weapon"
category = "primary_weapon"
rarity = "common"
description = "Reliable combat rifle"
weight = 3.5
bulk = 2
durability = 100
value = 500
primary_stat = 25
max_stack_size = 1
availability = "default"

[[weapons]]
id = "plasma_rifle"
name = "Plasma Rifle"
type = "weapon"
category = "primary_weapon"
rarity = "rare"
description = "Alien plasma weapon, devastating"
weight = 4.0
bulk = 2
durability = 120
value = 2500
primary_stat = 45
max_stack_size = 1
availability = "research:plasma_technology"
required_tech = "plasma_technology"

[[weapons]]
id = "pistol_service"
name = "Service Pistol"
type = "weapon"
category = "secondary_weapon"
rarity = "common"
description = "Sidearm for emergency situations"
weight = 1.5
bulk = 1
durability = 80
value = 250
primary_stat = 15
max_stack_size = 1
availability = "default"

[[weapons]]
id = "grenade_frag"
name = "Frag Grenade"
type = "consumable"
category = "grenade"
rarity = "common"
description = "Explosive area weapon"
weight = 0.4
bulk = 1
value = 100
primary_stat = 20
max_stack_size = 10
is_consumable = true
uses_per_unit = 1
```

### Armor

```toml
# content/items/armor.toml

[[armor]]
id = "armor_combat_vest"
name = "Combat Vest"
type = "armor"
category = "armor_torso"
rarity = "common"
description = "Standard military body armor"
weight = 8.0
bulk = 3
durability = 100
value = 750
primary_stat = 15
max_stack_size = 1
availability = "default"

[[armor]]
id = "armor_plasma"
name = "Plasma Armor"
type = "armor"
category = "armor_torso"
rarity = "rare"
description = "Alien plasma-resistant armor"
weight = 6.0
bulk = 2
durability = 150
value = 3000
primary_stat = 25
max_stack_size = 1
availability = "research:plasma_armor"
required_tech = "plasma_armor"

[[armor]]
id = "helmet_tactical"
name = "Tactical Helmet"
type = "armor"
category = "armor_head"
rarity = "common"
description = "Combat helmet with HUD"
weight = 1.2
bulk = 1
durability = 60
value = 400
primary_stat = 8
max_stack_size = 1
availability = "default"
```

### Resources

```toml
# content/items/resources.toml

[[resources]]
id = "metal_parts"
name = "Metal Parts"
type = "resource"
category = "crafting_material"
rarity = "common"
description = "Raw metal components"
weight = 0.5
value = 50
max_stack_size = 100
availability = "default"

[[resources]]
id = "polymer_stock"
name = "Polymer Stock"
type = "resource"
category = "crafting_material"
rarity = "common"
description = "Polymer material for construction"
weight = 0.3
value = 40
max_stack_size = 100
availability = "default"

[[resources]]
id = "alien_alloy"
name = "Alien Alloy"
type = "resource"
category = "crafting_material"
rarity = "rare"
description = "Advanced alien material"
weight = 0.2
value = 500
max_stack_size = 50
availability = "research:alien_materials"
required_tech = "alien_materials"
```

### Consumables

```toml
# content/items/consumables.toml

[[consumables]]
id = "medkit_standard"
name = "Medical Kit"
type = "consumable"
category = "medical"
rarity = "common"
description = "Heals 25 HP"
weight = 0.8
bulk = 1
value = 200
primary_stat = 25
max_stack_size = 10
is_consumable = true
uses_per_unit = 1

[[consumables]]
id = "stimulant_combat"
name = "Combat Stimulant"
type = "consumable"
category = "stimulant"
rarity = "uncommon"
description = "Boosts accuracy and reaction time"
weight = 0.1
bulk = 1
value = 300
primary_stat = 15
max_stack_size = 10
is_consumable = true
uses_per_unit = 1
```

---

## Usage Examples

### Example 1: Create and Equip Item

```lua
-- Create a rifle
local rifle = ItemManager.createItemStack("rifle_standard", 1)
print("Created: " .. rifle:getName())

-- Get unit
local unit = Squad.getSquad("squad_1"):getUnit(1)

-- Equip to primary hand slot
local success, error = EquipmentService.equipItem(unit, "left_hand", rifle)
if success then
  print("Equipped " .. rifle:getName() .. " to " .. unit:getName())
else
  print("Failed to equip: " .. error)
end
```

### Example 2: Stack Items

```lua
-- Create stacks of ammo
local ammo1 = ItemManager.createItemStack("rifle_ammo", 30)
local ammo2 = ItemManager.createItemStack("rifle_ammo", 50)

-- Check if can combine
if ItemStackManager.canStack(ammo1, ammo2) then
  local remaining = ammo1:combine(ammo2)
  print("Combined to: " .. ammo1.quantity .. " rounds")
  if remaining then
    print("Overflow: " .. remaining.quantity .. " rounds")
  end
else
  print("Cannot stack these items")
end
```

### Example 3: Check Equipment Stats

```lua
-- Get unit equipment
local unit = Squad.getSquad("squad_1"):getUnit(1)
local slots = EquipmentService.getEquipmentSlots(unit)

print("Equipment:")
for _, slot in ipairs(slots) do
  local item = slot:getEquippedItem()
  if item then
    print("  " .. slot.name .. ": " .. item:getName())
  else
    print("  " .. slot.name .. ": [Empty]")
  end
end

-- Calculate total stats
local stats = EquipmentService.calculateEquipmentStats(unit)
print("Bonuses:")
for stat, value in pairs(stats) do
  print("  " .. stat .. ": +" .. value)
end
```

### Example 4: Craft Item

```lua
-- Check if item can be crafted
if CraftingService.canCraft("plasma_rifle") then
  local recipe = CraftingService.getCraftRecipe("plasma_rifle")
  print("Plasma Rifle Recipe:")
  for component, qty in pairs(recipe.components) do
    print("  - " .. qty .. "x " .. component)
  end
  print("Time: " .. recipe.time .. " turns")
  print("Cost: $" .. recipe.cost)
  
  -- Start crafting
  local facility = Base.getCurrentBase():getFacility("workshop")
  local job = CraftingService.craftItem("plasma_rifle", facility, 1)
  print("Crafting started: " .. job.id)
else
  print("Cannot craft plasma rifle (missing tech)")
end
```

### Example 5: Item Repair and Durability

```lua
-- Get equipped weapon
local unit = Squad.getSquad("squad_1"):getUnit(1)
local weapon = EquipmentService.getEquippedWeapon(unit)

if weapon then
  print("Weapon: " .. weapon:getName())
  print("Durability: " .. weapon:getDurabilityPercent() .. "%")
  print("Condition: " .. weapon:getCondition())
  
  -- Take damage in combat
  weapon:takeDamage(15)
  print("After combat: " .. weapon:getDurabilityPercent() .. "%")
  
  -- Repair
  if weapon:getCondition() == "worn" then
    weapon:repair(20)
    print("Repaired to: " .. weapon:getCondition())
  end
end
```

---

## Balance Framework

### Weapon Balance System

#### Damage Progression by Tier

| Tier | Rarity | Damage Range | Crit Chance | Accuracy | Tier Unlock |
|---|---|---|---|---|---|
| **Tier 1** | Common | 4-8 | 2% | 75% | Rank 1 |
| **Tier 2** | Uncommon | 8-14 | 4% | 75% | Rank 3 |
| **Tier 3** | Rare | 14-24 | 6% | 78% | Rank 5 |
| **Tier 4** | Epic | 24-38 | 8% | 80% | Rank 8 |
| **Tier 5** | Legendary | 38-55 | 10% | 82% | Rank 10 |

**Damage Scaling Formula:**
```lua
function calculateWeaponDamage(tier, rarity_bonus)
  local base_damages = {
    [1] = {min = 4, max = 8},
    [2] = {min = 8, max = 14},
    [3] = {min = 14, max = 24},
    [4] = {min = 24, max = 38},
    [5] = {min = 38, max = 55}
  }
  
  local base = base_damages[tier]
  local rarity_multiplier = 1.0 + rarity_bonus  -- Common: 0, Uncommon: 0.15, etc.
  
  return {
    min = math.floor(base.min * rarity_multiplier),
    max = math.floor(base.max * rarity_multiplier)
  }
end

-- Example outputs:
-- Tier 1 Common: 4-8
-- Tier 1 Epic: 4-8 × 1.25 = 5-10 (5% tier scaling)
-- Tier 3 Uncommon: 14-24 × 1.15 = 16-28
```

#### Weapon Type Balance

**Weapon Archetypes:**

| Type | Damage | Accuracy | Crit | Range | Special |
|---|---|---|---|---|---|
| **Pistol** | Low | High | Low | Short | Quick |
| **Rifle** | Medium | High | Medium | Medium | Reliable |
| **Shotgun** | High | Low | High | Very Short | Burst damage |
| **Sniper** | Very High | Medium | High | Very Long | Setup time |
| **Submachine Gun** | Low | Medium | Low | Short | Rapid fire |
| **Grenade Launcher** | High | Medium | High | Medium | Area effect |

**Damage Variance by Type:**
```lua
weapon_archetypes = {
  pistol = {base_damage = 0.7, accuracy = 0.9, crit_chance = 0.02, range_optimal = 8},
  rifle = {base_damage = 1.0, accuracy = 0.85, crit_chance = 0.05, range_optimal = 15},
  shotgun = {base_damage = 1.4, accuracy = 0.65, crit_chance = 0.08, range_optimal = 4},
  sniper = {base_damage = 1.6, accuracy = 0.80, crit_chance = 0.10, range_optimal = 25},
  smg = {base_damage = 0.6, accuracy = 0.75, crit_chance = 0.03, range_optimal = 10},
  grenade_launcher = {base_damage = 1.2, accuracy = 0.70, crit_chance = 0.06, range_optimal = 12}
}
```

---

#### Weapon Cost Scaling

**Balance: Damage vs. Availability**

```lua
weapon_cost_formula = {
  -- Tier 1
  ["pistol_standard"] = 400,       -- 6 avg damage
  ["rifle_standard"] = 800,        -- 12 avg damage
  
  -- Tier 2
  ["rifle_semi_auto"] = 1200,      -- 16 avg damage
  ["shotgun_combat"] = 1500,       -- 20 avg damage
  
  -- Tier 3
  ["sniper_standard"] = 2500,      -- 24 avg damage
  ["rifle_plasma"] = 2800,         -- 24 avg damage, special
  
  -- Tier 4
  ["sniper_plasma"] = 4500,        -- 38 avg damage
  ["rifle_exotic"] = 4200,         -- 36 avg damage
  
  -- Tier 5
  ["rifle_final"] = 6500,          -- 50 avg damage
  ["sniper_legendary"] = 7500      -- 52 avg damage
}

-- Cost-to-Damage ratio: ~150 credits per average damage point
```

---

### Armor Balance System

#### Armor Rating Progression

| Tier | Armor Class | AC Reduction | Weight | Cost | Special |
|---|---|---|---|---|---|
| **Tier 1** | Light | 2-3 AC | 2 kg | 300 | High mobility |
| **Tier 2** | Medium | 4-5 AC | 4 kg | 800 | Balanced |
| **Tier 3** | Heavy | 6-8 AC | 8 kg | 1800 | Slow |
| **Tier 4** | Combat | 8-10 AC | 10 kg | 3000 | Limited |
| **Tier 5** | Exosuit** | 12-15 AC | 15 kg | 5500 | Max protection |

**Armor Damage Reduction:**
```lua
function calculateArmorReduction(armor_class, damage_type)
  -- Base reduction by armor tier
  local ac_reductions = {
    [2] = 0.08,   -- Tier 1: 8% damage reduction
    [4] = 0.16,   -- Tier 2: 16%
    [7] = 0.28,   -- Tier 3: 28%
    [9] = 0.36,   -- Tier 4: 36%
    [13] = 0.52   -- Tier 5: 52%
  }
  
  -- Find appropriate tier
  local base_reduction = ac_reductions[armor_class] or 0.0
  
  -- Adjust by damage type effectiveness
  local type_effectiveness = {
    kinetic = 1.0,    -- Full effectiveness
    energy = 0.75,    -- 75% effectiveness
    explosive = 0.5,  -- 50% effectiveness
    special = 0.3     -- Specialized less effective
  }
  
  local effective_reduction = base_reduction * type_effectiveness[damage_type]
  return math.min(effective_reduction, 0.90)  -- Cap at 90%
end
```

#### Armor Encumbrance Penalty

```lua
-- Movement speed penalty from armor weight
function calculateEncumbrancePenalty(armor_weight)
  local penalty = armor_weight * 0.03  -- 3% penalty per kg
  return math.min(penalty, 0.40)       -- Max 40% speed reduction
end

-- Example:
-- Light (2kg) = 6% speed penalty
-- Medium (4kg) = 12% speed penalty
-- Heavy (8kg) = 24% speed penalty
```

---

### Equipment Slot Balance

#### Loadout Configuration

```lua
-- Unit equipment capacity by class
equipment_slots = {
  soldier = {
    head = 1,        -- Helmet
    chest = 1,       -- Chest armor
    legs = 1,        -- Leg armor
    hands = 1,       -- Gloves
    feet = 1,        -- Boots
    main_hand = 2,   -- Primary weapon + ammo
    off_hand = 1,    -- Secondary weapon / grenade
    back = 2,        -- Backpack / equipment
    total_weight = 20  -- kg capacity
  },
  
  heavy = {
    head = 1,
    chest = 1,
    legs = 1,
    hands = 1,
    feet = 1,
    main_hand = 2,
    off_hand = 1,
    back = 3,        -- Extra capacity
    total_weight = 35  -- Higher capacity
  },
  
  scout = {
    head = 1,
    chest = 1,
    legs = 1,
    hands = 1,
    feet = 1,
    main_hand = 1,   -- Lighter
    off_hand = 1,
    back = 2,
    total_weight = 15  -- Less capacity
  }
}
```

---

### Rarity-Based Stat Bonuses

#### Stat Bonuses by Rarity

| Rarity | Bonus % | Drop Rate | Gold Cost Multiplier |
|---|---|---|---|
| Common | +0% | 60% | 1.0x |
| Uncommon | +5% | 25% | 1.3x |
| Rare | +10% | 10% | 1.6x |
| Epic | +15% | 4% | 2.2x |
| Legendary | +25% | 1% | 3.5x |

**Stat Bonus Application:**
```lua
function applyRarityBonus(base_value, rarity)
  local bonus_percentages = {
    common = 0.00,
    uncommon = 0.05,
    rare = 0.10,
    epic = 0.15,
    legendary = 0.25
  }
  
  local bonus = bonus_percentages[rarity] or 0.0
  return base_value * (1.0 + bonus)
end

-- Example:
-- Rifle damage 8-14, Common: 8-14 (+0%)
-- Rifle damage 8-14, Uncommon: 8.4-14.7 (+5%)
-- Rifle damage 8-14, Epic: 9.2-16.1 (+15%)
```

---

### Weapon Specialization Balance

#### Bonus Damage by Specialization

```lua
-- Bonus damage to equipped units with matching specialization
specialization_bonuses = {
  marksmanship = {
    sniper_rifle = 1.15,          -- +15% sniper damage
    heavy_pistol = 1.10,          -- +10% pistol damage
    description = "Increased accuracy and critical damage"
  },
  
  assault = {
    rifle = 1.10,                 -- +10% rifle damage
    smg = 1.15,                   -- +15% SMG damage
    grenades = 1.10,              -- +10% grenade damage
    description = "Increased assault weapon effectiveness"
  },
  
  heavy_weapons = {
    shotgun = 1.15,               -- +15% shotgun
    grenade_launcher = 1.10,      -- +10% launcher
    heavy_cannon = 1.15,          -- +15% cannon
    description = "Massive firepower"
  },
  
  support = {
    pistol = 1.10,                -- +10% pistol
    grenades = 1.10,              -- +10% grenades
    medical_kit = 1.15,           -- +15% healing
    description = "Support and utility focus"
  }
}
```

---

### Consumable Balance

-- Equipment operations
EquipmentService.equipItem(unit, "left_hand", item)
if not success then
  if error == "SLOT_FULL" then
    print("Equipment slot is full")
  elseif error == "ITEM_INCOMPATIBLE" then
    print("Item cannot be equipped to this slot")
  else
    print("Equipment failed: " .. error)
  end
  return false
end

-- Safe crafting
if not CraftingService.canCraft(item_id) then
  print("[ERROR] Item cannot be crafted: " .. item_id)
  return nil
end

if not CraftingService.checkIngredients(item_id, inventory) then
  print("[ERROR] Insufficient ingredients to craft: " .. item_id)
  return nil
end
```

---

### Consumable Balance

#### Consumable Effectiveness

| Type | Cost | Effect | Uses | Best For |
|---|---|---|---|---|
| **Medical Kit** | 200 | +25 HP | 1 | Emergency healing |
| **Stimulant** | 300 | +20% accuracy | 1 | Critical shots |
| **Ammo Pouch** | 150 | +30 ammo | 1 | Extended ops |
| **Grenade** | 100 | Area damage | 1 | Crowd control |

---

**Last Updated:** October 22, 2025  
**Status:** ✅ Complete
