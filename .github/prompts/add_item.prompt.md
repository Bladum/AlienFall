# add_item

Create or update item definitions in TOML format. Items include weapons, armor, equipment, resources, and special objects.

## Prefix
`item_`

## Task Type
Content Creation / Modification

## Description
Create or update item entries in `mods/core/economy/` folder. Items are game assets that can be equipped, traded, manufactured, or consumed. Each item has properties for economy, gameplay balance, and functionality.

## Inputs

### Required
- **Item ID**: Unique identifier (e.g., `rifle_basic`, `armor_combat`, `alloy_alien`)
- **Item Name**: Display name for UI and tooltips
- **Item Type**: Category - `weapon`, `armor`, `resource`, `tactical_item`, `craft_equipment`, `lore_item`, `prisoner_item`
- **Description**: Short description of the item's purpose and characteristics

### Optional
- **Item Properties**: Weight, volume, durability, special effects
- **Economy Data**: Manufacturing cost, market price, available quantity
- **Gameplay Stats**: Damage, protection, accuracy bonuses, special abilities
- **Requirements**: Tech prerequisites, facility requirements, faction restrictions
- **Equipment Slots**: Where item can be equipped (head, chest, hands, feet, utility)

## Scope

### Affected Files
- `mods/core/economy/items.toml` (or category-specific file)
- Related: `mods/core/technology/` (if research required)
- Related: `mods/core/economy/manufacturing.toml` (if craft-able)

### Validation
- ✓ Item ID is unique and follows naming convention
- ✓ All required TOML fields present
- ✓ Item type matches valid category
- ✓ No syntax errors in TOML
- ✓ Cross-references exist (tech trees, manufacturing recipes, factions)
- ✓ Game balance values are reasonable
- ✓ Weight and volume are non-negative numbers
- ✓ No duplicate item entries

## TOML Structure Template

```toml
[[items]]
id = "item_id"
name = "Item Display Name"
description = "What this item does and its purpose"
type = "weapon|armor|resource|tactical_item|craft_equipment|lore_item|prisoner_item"
category = "subcategory"
tags = ["tag1", "tag2"]

[item_properties]
weight = 1.5
volume = 2.0
rarity = "common|uncommon|rare|unique"
stackable = true
max_stack = 99

[economy]
cost_to_manufacture = 1000
selling_price = 500
market_availability = "common|rare|limited"
trader_availability = "all|specific_factions"

[gameplay]
damage = 25
armor_value = 5
accuracy_bonus = 10
special_abilities = ["ability_name"]
cooldown_turns = 2
action_points_cost = 2

[requirements]
technology_required = "tech_id"
facility_required = "facility_id"
faction_restricted = ["faction_id"]
minimum_level = 1
```

## Outputs

### Created/Modified
- Item entry in TOML file with all properties defined
- Properly formatted TOML with correct syntax
- Unique item ID following naming convention
- Cross-references verified

### Validation Report
- ✓ TOML syntax verified
- ✓ Item ID uniqueness confirmed
- ✓ All required fields populated
- ✓ Economy values balanced
- ✓ References resolved
- ✓ No conflicts with existing items

## Process

1. **Query API**: Check existing items to avoid duplicates
2. **Define Properties**: Gather all item specifications
3. **Create TOML Entry**: Add to appropriate items file
4. **Cross-Reference**: Verify related entries exist (tech, manufacturing)
5. **Validate**: Check TOML syntax and game balance
6. **Test**: Load item in-game and verify display/functionality
7. **Document**: Update mods/core/economy/README.md with new item

## Testing Checklist

- [ ] Item loads without errors in game console
- [ ] Item displays correctly in UI menus
- [ ] Item appears in correct inventory category
- [ ] Economy values are consistent with similar items
- [ ] Cross-references resolve correctly
- [ ] Gameplay properties balance with progression
- [ ] No console errors or warnings
- [ ] TOML file validates successfully

## References

- API: `mods/core/economy/README.md`
- Examples: `mods/core/economy/items.toml`
- Balance Guide: `docs/content/items.md`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
