# Items & Equipment TOML Schema

Complete schema documentation for miscellaneous items and equipment.

## File Location

```
mods/core/rules/items/equipment.toml
mods/core/rules/items/ammo.toml
```

## Overview

Equipment includes grenades, medkits, utilities, and ammunition.

## Equipment Schema

```toml
[[equipment]]
id = "hand_grenade"
name = "Hand Grenade"
description = "Standard explosive grenade"
type = "grenade"
damage = 60
radius = 10
cost = 100
tech_level = "conventional"
```

## Ammunition Schema

```toml
[[ammo]]
id = "rifle_ammo"
name = "Rifle Ammunition"
description = "Standard rifle cartridges"
type = "ballistic"
quantity = 50
cost = 50
tech_level = "conventional"
```

---

**Schema Version:** 1.0
