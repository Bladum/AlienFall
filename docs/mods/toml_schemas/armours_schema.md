# Armours TOML Schema

Complete schema documentation for armor/equipment definitions.

## File Location

```
mods/core/rules/items/armours.toml
```

## Overview

Armor provides protective gear that reduces damage taken.

## Schema Definition

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Unique armor ID | `"combat_armor_light"` |
| `name` | string | Display name | `"Light Combat Armor"` |
| `type` | string | Armor type | `"light"`, `"heavy"`, `"power"` |
| `armor_value` | number | Damage reduction (0-30) | `10` |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Armor description |
| `weight` | number | Carrying weight |
| `cost` | number | Purchase cost |
| `tech_level` | string | Technology tier |

## Complete Example

```toml
[[armour]]
id = "combat_armor_heavy"
name = "Heavy Combat Armor"
description = "Heavy reinforced armor suit"
type = "heavy"
armor_value = 15
weight = 8
cost = 1500
tech_level = "conventional"
```

---

**Schema Version:** 1.0
