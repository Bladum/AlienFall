# API: Economy & Items

**Version**: 1.0  
**Last Updated**: October 21, 2025  
**Purpose**: Complete reference for economy systems, items, marketplace, and resource management  
**Audience**: Lua developers, TOML modders, game designers  

---

## Quick Start: Lua Developer

### Get All Items

```lua
local DataLoader = require("engine.core.data_loader")
local items = DataLoader.item.getAllIds()

for _, itemId in ipairs(items) do
    local item = DataLoader.item.get(itemId)
    print(item.name .. ": " .. item.category .. " ($" .. item.market_price .. ")")
end
```

### Get Items by Category

```lua
local function getItemsByCategory(category)
    local allItems = DataLoader.item.getAllIds()
    local results = {}
    
    for _, itemId in ipairs(allItems) do
        local item = DataLoader.item.get(itemId)
        if item.category == category then
            table.insert(results, item)
        end
    end
    
    return results
end

local consumables = getItemsByCategory("consumables")
for _, item in ipairs(consumables) do
    print(item.name .. " (Cost: $" .. item.market_price .. ")")
end
```

### Calculate Budget Status

```lua
local function calculateBudgetStatus(base)
    local income = calculateMonthlyIncome(base)
    local expenses = calculateMonthlyExpenses(base)
    local balance = income - expenses
    
    return {
        income = income,
        expenses = expenses,
        balance = balance,
        deficit = balance < 0,
        months_to_bankruptcy = balance < 0 and math.ceil(base.credits / math.abs(balance)) or nil
    }
end
```

---

## Quick Start: TOML Modder

### Create a New Item

```toml
[[item]]
id = "item_medical_pack_advanced"
name = "Advanced Medical Pack"
category = "consumables"
description = "Advanced medical supplies for emergency healing"
weight = 0.5
market_price = 450
stock_availability = "common"
rarity = "uncommon"
tech_level = 3

[item.effects]
health_restore = 40
panic_reduction = 20
```

### Create a Resource

```toml
[[resource]]
id = "resource_elerium"
name = "Elerium-115"
category = "alien_material"
description = "Highly unstable alien element with immense energy potential"
unit = "kg"
market_price = 5000
rarity = "rare"
rarity_level = "alien_artifact"
source = "alien_craft"
uses = ["weapons", "armor", "power_generation"]
```

---

## Economy System

### Economy Schema

**File Location**: `mods/[modname]/content/rules/economy/economy.toml`

```toml
[[resource_type]]
id = "string - unique identifier (e.g., 'resource_credits')"
name = "string - human-readable name"
category = "enum - currency|material|component|alien_material|knowledge"
description = "string - what is this resource"
unit = "string - unit of measurement (credits, kg, units, etc.)"
base_value = "integer - base credit value per unit"
market_price = "integer - current marketplace price"
rarity = "enum - common|uncommon|rare|very_rare|unique"
storage_requirement = "integer - storage space required per unit"
decay_rate = "float - percentage lost per month (0-1.0)"
max_stock = "integer - maximum storable amount"
source = "array - where to obtain (missions, research, manufacturing, trade)"
uses = "array - what can this resource be used for"
```

### Resource Types

| Resource | Unit | Base Value | Rarity | Source |
|----------|------|-----------|--------|--------|
| **Credits** | - | 1 | Common | Missions, trade, suppliers |
| **Elerium-115** | kg | 5000 | Rare | UFO salvage, alien crafts |
| **Alien Alloys** | kg | 2000 | Rare | UFO salvage, alien bases |
| **UFO Components** | unit | 1500 | Uncommon | UFO salvage |
| **Weapon Fragments** | unit | 800 | Uncommon | UFO salvage |
| **Knowledge** | points | 1 | Common | Research, missions |

---

## Item System

### Item Schema

**File Location**: `mods/[modname]/content/rules/items/items.toml`

```toml
[[item]]
id = "string - unique identifier (e.g., 'item_grenade_frag')"
name = "string - human-readable item name"
category = "enum - weapons|armor|ammunition|consumables|components|crafting_materials|special"
subcategory = "string - specific type (e.g., 'grenade' for weapons)"
description = "string - item description"
weight = "float - item weight in kg (0.1-10.0)"
market_price = "integer - price to buy/sell"
stock_availability = "enum - common|uncommon|rare|very_rare|only_alien|unique"
rarity = "enum - common|uncommon|rare|very_rare|unique"
tech_level = "integer - technology tier required (1-5)"
required_technology = "string - specific tech needed to use (optional)"

[item.effects]
# Consumable effects
health_restore = "integer - HP restored"
panic_reduction = "integer - panic points reduced"
accuracy_bonus = "integer - temporary accuracy bonus"
ammo_restore = "integer - ammo rounds restored"

[item.usage]
reusable = "boolean - can item be reused"
charges = "integer - number of uses (for consumables)"
cooldown_turns = "integer - turns before reuse (for special items)"
```

### Item Categories

| Category | Purpose | Subcategories | Examples |
|----------|---------|--|----------|
| **Weapons** | Combat equipment | Firearms, melee, grenades | Rifles, pistols, grenades |
| **Armor** | Protection | Suits, helmets | Combat armor, power suits |
| **Ammunition** | Weapon fuel | Rounds, energy cells | 5.56mm, laser cells |
| **Consumables** | Single-use items | Medical, utility | Medikits, stim packs, grenades |
| **Components** | Crafting materials | Weapon parts, armor plates | Alloys, circuits |
| **Special** | Unique items | Mission items, artifacts | Data disks, alien artifacts |

---

## Item Examples

### Consumable Items

```toml
[[item]]
id = "item_medikit"
name = "Medikit"
category = "consumables"
subcategory = "medical"
description = "Emergency medical supplies restoring moderate health"
weight = 0.3
market_price = 300
stock_availability = "common"
rarity = "common"
tech_level = 1

[item.effects]
health_restore = 30
panic_reduction = 10

[item.usage]
reusable = false
charges = 1

[[item]]
id = "item_medikit_advanced"
name = "Advanced Medikit"
category = "consumables"
subcategory = "medical"
description = "Advanced medical kit restoring most wounds"
weight = 0.5
market_price = 600
stock_availability = "uncommon"
rarity = "uncommon"
tech_level = 2
required_technology = "tech_advanced_medicine"

[item.effects]
health_restore = 60
panic_reduction = 20

[item.usage]
reusable = false
charges = 1

[[item]]
id = "item_stimulant"
name = "Combat Stimulant"
category = "consumables"
subcategory = "utility"
description = "Temporary boost to accuracy and reaction time"
weight = 0.1
market_price = 400
stock_availability = "uncommon"
rarity = "uncommon"
tech_level = 2

[item.effects]
accuracy_bonus = 20
cooldown_turns = 1

[item.usage]
reusable = false
charges = 1

[[item]]
id = "item_grenade_frag"
name = "Fragmentation Grenade"
category = "consumables"
subcategory = "grenade"
description = "Explosive grenade causing area damage"
weight = 0.4
market_price = 350
stock_availability = "common"
rarity = "common"
tech_level = 1

[item.effects]
damage_area = 5  # Tiles radius

[item.usage]
reusable = false
charges = 1
```

### Ammunition Items

```toml
[[item]]
id = "item_ammunition_rifle"
name = "5.56mm Rifle Ammunition"
category = "ammunition"
description = "Standard rifle ammunition cartridge"
weight = 0.2
market_price = 50
stock_availability = "common"
rarity = "common"

[item.usage]
reusable = false
charges = 100  # Rounds per box

[[item]]
id = "item_ammunition_laser"
name = "Laser Power Cell"
category = "ammunition"
description = "Energy cell for laser weapons"
weight = 0.3
market_price = 250
stock_availability = "uncommon"
rarity = "uncommon"
tech_level = 2
required_technology = "tech_laser_weapons"

[item.usage]
reusable = true
charges = 150  # Shots

[[item]]
id = "item_ammunition_plasma"
name = "Plasma Cartridge"
category = "ammunition"
description = "Plasma energy cartridge for plasma weapons"
weight = 0.4
market_price = 600
stock_availability = "rare"
rarity = "rare"
tech_level = 3
required_technology = "tech_plasma_weapons"

[item.usage]
reusable = false
charges = 100  # Shots
```

### Component Items

```toml
[[item]]
id = "item_rifle_components"
name = "Rifle Component Pack"
category = "components"
description = "Pre-manufactured rifle components for assembly"
weight = 1.0
market_price = 400
stock_availability = "common"
rarity = "common"

[[item]]
id = "item_plasma_components"
name = "Plasma Weapon Components"
category = "components"
description = "Advanced components for plasma weapon manufacturing"
weight = 1.2
market_price = 1200
stock_availability = "uncommon"
rarity = "uncommon"
tech_level = 3

[[item]]
id = "item_armor_alloy"
name = "Combat Armor Alloy Sheet"
category = "components"
description = "Pre-formed alloy sheet for armor manufacturing"
weight = 2.0
market_price = 800
stock_availability = "uncommon"
rarity = "uncommon"
```

### Special Items

```toml
[[item]]
id = "item_alien_artifact"
name = "Alien Artifact"
category = "special"
description = "Unknown alien device of technological significance"
weight = 0.5
market_price = 0  # Cannot be sold
stock_availability = "very_rare"
rarity = "very_rare"

[[item]]
id = "item_ufo_power_source"
name = "UFO Power Source"
category = "special"
description = "Mysterious power source recovered from downed UFO"
weight = 1.5
market_price = 0  # Cannot be sold
stock_availability = "very_rare"
rarity = "very_rare"
tech_level = 5
```

---

## Marketplace System

### Marketplace Schema

```lua
-- Marketplace instance (in-game data)
{
    available_items = {
        {
            item_id = "item_rifle_conventional",
            quantity = 10,
            price = 500,  -- Individual price
            supplier = "supplier_arms"
        },
        {
            item_id = "item_medikit",
            quantity = 25,
            price = 300,
            supplier = "supplier_medical"
        }
    },
    last_updated = "2025-01-20",
    rotation_day = 5,  -- Updates every 5 days
}
```

### Lua: Buy Item

```lua
local function buyItem(base, itemId, quantity)
    local item = DataLoader.item.get(itemId)
    local totalCost = item.market_price * quantity
    
    -- Check budget
    if base.credits < totalCost then
        return false, "Insufficient credits (" .. base.credits .. "/" .. totalCost .. ")"
    end
    
    -- Check storage
    local totalWeight = item.weight * quantity
    if not hasStorageSpace(base, totalWeight) then
        return false, "Insufficient storage space"
    end
    
    -- Purchase
    base.credits = base.credits - totalCost
    addItemToBase(base, itemId, quantity)
    
    return true, "Purchased " .. quantity .. " x " .. item.name
end
```

### Lua: Sell Item

```lua
local function sellItem(base, itemId, quantity)
    local item = DataLoader.item.get(itemId)
    local totalValue = item.market_price * quantity * 0.8  -- 80% value when selling
    
    -- Check inventory
    local currentAmount = base.inventory[itemId] or 0
    if currentAmount < quantity then
        return false, "Not enough items to sell"
    end
    
    -- Sell
    base.inventory[itemId] = currentAmount - quantity
    base.credits = base.credits + totalValue
    
    return true, "Sold " .. quantity .. " x " .. item.name .. " for $" .. math.floor(totalValue)
end
```

---

## Budget & Finance System

### Income Sources

| Source | Amount | Frequency | Condition |
|--------|--------|-----------|-----------|
| **Mission Rewards** | 500-5000 | Variable | Complete missions |
| **Alien Artifact Sales** | 2000-5000 | Variable | Salvage UFOs |
| **Technology Licensing** | 1000-2000 | Monthly | Countries pay for research |
| **Supplier Contracts** | 500-1000 | Monthly | Trade agreements |
| **Research Grants** | 1000-3000 | Monthly | Government funding |

### Expense Categories

| Category | Cost | Frequency |
|----------|------|-----------|
| **Salaries** | 500-1500 | Monthly |
| **Facility Maintenance** | 200-1000 | Monthly |
| **Equipment Purchases** | 500-5000 | Variable |
| **Research Costs** | 1000-10000 | During research |
| **Manufacturing** | 500-2000 | During production |
| **Ammunition & Supplies** | 200-1000 | Monthly |

### Lua: Calculate Base Economy

```lua
local function calculateBaseEconomy(base)
    -- Income calculation
    local monthlyIncome = 0
    
    -- Mission rewards (average)
    monthlyIncome = monthlyIncome + (base.average_mission_reward or 2000)
    
    -- Supplier contracts
    for _, contract in ipairs(base.supplier_contracts) do
        monthlyIncome = monthlyIncome + (contract.monthly_payment or 500)
    end
    
    -- Technology licensing
    if base.researched_technologies then
        for _, tech in ipairs(base.researched_technologies) do
            monthlyIncome = monthlyIncome + (tech.licensing_value or 0)
        end
    end
    
    -- Expense calculation
    local monthlyExpense = 0
    
    -- Personnel salaries
    monthlyExpense = monthlyExpense + (base.total_personnel * 50)
    
    -- Facility maintenance
    for _, facility in ipairs(base.facilities) do
        monthlyExpense = monthlyExpense + (facility.maintenance_cost or 100)
    end
    
    -- Research cost (if active)
    if base.current_research then
        monthlyExpense = monthlyExpense + 1000  -- Research overhead
    end
    
    -- Ammunition and supplies
    monthlyExpense = monthlyExpense + (base.total_personnel * 25)
    
    return {
        income = monthlyIncome,
        expense = monthlyExpense,
        balance = monthlyIncome - monthlyExpense,
        months_until_bankruptcy = monthlyIncome - monthlyExpense < 0 
            and math.ceil(base.credits / math.abs(monthlyIncome - monthlyExpense)) 
            or nil
    }
end
```

---

## Supplier System

### Supplier Schema

```toml
[[supplier]]
id = "string - unique identifier (e.g., 'supplier_arms')"
name = "string - supplier company name"
type = "enum - arms|medical|components|alien_materials|general"
description = "string - supplier profile"
reliability = "enum - trustworthy|neutral|unreliable"
price_modifier = "float - price markup (0.8-1.5)"
stock_variety = "enum - limited|moderate|extensive"
delivery_time = "integer - days to deliver (1-15)"
relationship_bonus = "float - discount for good relationship"
reputation_requirement = "integer - minimum reputation to trade"
available_items = ["array - item ids they sell"]
availability_chance = "float - probability item is in stock (0.5-1.0)"
```

### Supplier Examples

```toml
[[supplier]]
id = "supplier_arms_dealer"
name = "Arms & Ammunition Depot"
type = "arms"
description = "Reliable supplier of small arms and ammunition"
reliability = "trustworthy"
price_modifier = 1.0
stock_variety = "extensive"
delivery_time = 3
available_items = [
    "item_rifle_conventional",
    "item_pistol",
    "item_ammunition_rifle",
    "item_grenade_frag"
]
availability_chance = 0.95

[[supplier]]
id = "supplier_black_market"
name = "Black Market Dealer"
type = "general"
description = "Shady dealer with access to rare items"
reliability = "unreliable"
price_modifier = 1.5
stock_variety = "moderate"
delivery_time = 10
available_items = [
    "item_plasma_components",
    "item_alien_artifact",
    "item_rare_materials"
]
availability_chance = 0.6

[[supplier]]
id = "supplier_medical"
name = "Medical Supplies Inc"
type = "medical"
description = "Specialized in medical equipment and consumables"
reliability = "trustworthy"
price_modifier = 0.9
stock_variety = "extensive"
delivery_time = 2
available_items = [
    "item_medikit",
    "item_medikit_advanced",
    "item_stimulant"
]
availability_chance = 0.98
```

---

## Resource Storage

### Storage Capacity

| Structure | Capacity | Cost |
|-----------|----------|------|
| **General Storage** | 100 units | $1500 |
| **Ammunition Storage** | 500 units | $800 |
| **Alien Material Storage** | 50 units | $2000 |
| **Research Archives** | 100 projects | $1200 |

### Lua: Calculate Storage Usage

```lua
local function calculateStorageUsage(base)
    local totalWeight = 0
    
    for itemId, quantity in pairs(base.inventory) do
        local item = DataLoader.item.get(itemId)
        totalWeight = totalWeight + (item.weight * quantity)
    end
    
    local totalCapacity = 0
    for _, storage in ipairs(base.storage_facilities) do
        totalCapacity = totalCapacity + storage.capacity
    end
    
    return {
        used = totalWeight,
        capacity = totalCapacity,
        available = totalCapacity - totalWeight,
        percent_used = (totalWeight / totalCapacity) * 100
    }
end
```

---

## Price Fluctuation

### Market Dynamics

```lua
local function calculateMarketPrice(item, dayOfMonth, supplyLevel)
    local basePrice = item.market_price
    
    -- Time-based fluctuation (+/- 20%)
    local timeMultiplier = 1.0 + ((math.sin(dayOfMonth / 30 * math.pi * 2) * 0.2))
    
    -- Supply-based fluctuation (inverse relationship)
    local supplyMultiplier = 1.0 + ((1 - supplyLevel) * 0.3)
    
    -- Rarity multiplier
    local rarityMultiplier = {
        common = 1.0,
        uncommon = 1.2,
        rare = 1.5,
        very_rare = 2.0,
        unique = 3.0,
    }
    
    local rarity = item.rarity or "common"
    local finalPrice = basePrice * timeMultiplier * supplyMultiplier * (rarityMultiplier[rarity] or 1.0)
    
    return math.floor(finalPrice)
end
```

---

## Complete Example: Marketplace Transaction

```lua
local function processMarketplaceTransaction(base, transaction)
    -- Transaction types: "buy" or "sell"
    
    if transaction.type == "buy" then
        local item = DataLoader.item.get(transaction.item_id)
        local totalCost = item.market_price * transaction.quantity
        
        if base.credits < totalCost then
            return false, "Cannot afford (" .. base.credits .. "/" .. totalCost .. ")"
        end
        
        if not hasStorageSpace(base, item.weight * transaction.quantity) then
            return false, "No storage space"
        end
        
        base.credits = base.credits - totalCost
        base.inventory[transaction.item_id] = (base.inventory[transaction.item_id] or 0) + transaction.quantity
        
        return true, "Purchased " .. transaction.quantity .. " x " .. item.name
        
    elseif transaction.type == "sell" then
        local item = DataLoader.item.get(transaction.item_id)
        local hasAmount = base.inventory[transaction.item_id] or 0
        
        if hasAmount < transaction.quantity then
            return false, "Not enough items"
        end
        
        local sellValue = item.market_price * transaction.quantity * 0.8  -- 80% of value
        base.credits = base.credits + sellValue
        base.inventory[transaction.item_id] = hasAmount - transaction.quantity
        
        return true, "Sold " .. transaction.quantity .. " x " .. item.name .. " for $" .. math.floor(sellValue)
    end
    
    return false, "Invalid transaction type"
end
```

---

## Best Practices for Economy Design

### Item Pricing

- **Common items**: 50-500 credits
- **Uncommon items**: 500-2000 credits
- **Rare items**: 2000-5000 credits
- **Very rare**: 5000+ credits

### Income/Expense Balance

- Monthly income should be 1.5-3x monthly expenses
- Early game: Tight budget (forces strategy)
- Mid game: Moderate budget (allows expansion)
- Late game: Abundant budget (endgame comfort)

### Supplier Strategy

- 2-3 trustworthy suppliers (reliable, fair prices)
- 1-2 neutral suppliers (moderate pricing)
- 1 black market supplier (rare items, high prices)
- Relationship matters (discounts for loyalty)

### Resource Management

- Force player choices (can't afford everything)
- Balance immediate needs vs. long-term investment
- Create supply chain challenges
- Reward efficient management

---

## Related Documentation

- `API_SCHEMA_REFERENCE.md` - Core entity schemas
- `API_WEAPONS_AND_ARMOR.md` - Item details
- `API_RESEARCH_AND_MANUFACTURING.md` - Production costs
- `wiki/systems/Economy.md` - Economic theory
- `MOD_DEVELOPER_GUIDE.md` - Complete modding workflow

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 21, 2025 | Initial documentation |

