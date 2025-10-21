# Basescape API Reference

**Status**: Complete  
**Last Updated**: October 21, 2025  
**Audience**: Developers, Modders

---

## Overview

This document provides API reference for the Basescape (base management) system, covering three core systems:
- **Expansion System**: Base size progression and facility preservation
- **Adjacency Bonus System**: Strategic facility clustering for efficiency bonuses
- **Power Management System**: Facility power distribution and shortage handling

For comprehensive mechanics overview, see [Basescape.md](../systems/Basescape.md).

## Contents

- [Overview](#overview)
- [Expansion System API](#expansion-system-api)
- [Adjacency Bonus System API](#adjacency-bonus-system-api)
- [Power Management System API](#power-management-system-api)
- [Data Structures](#data-structures)
- [Examples](#examples)
- [Related Documentation](#related-documentation)

---

## Expansion System API

**Module**: `engine/basescape/systems/expansion_system.lua`

### Functions

#### `new()`
Initialize expansion system. Must be called once on engine startup.

```lua
local expansionSystem = require("engine.basescape.systems.expansion_system")
local system = expansionSystem.new()
```

**Returns**: Expansion system instance

---

## Data Structures

### Base Size Specification
```lua
{
  name = "medium",
  grid = {width = 5, height = 5},
  maxTiles = 25,
  cost = 250000,
  buildTime = 45,
  relationBonus = 1
}
```

### Power Status Table
```lua
{
  available = 150,        -- Total power generated
  consumed = 145,         -- Total power consumed
  shortage = 0,           -- Deficit amount
  ratio = 0.967,          -- Utilization percentage
  isPowered = true,       -- Sufficient power
  surplus = 5             -- Excess available
}
```

---

## Examples

### Example 1: Power Management & Shortage Resolution
```lua
local powerSystem = require("engine.basescape.systems.power_management_system")
local power = powerSystem.new()

-- Check status
local status = power:getPowerStatus(base)
print("Power: " .. status.available .. "/" .. status.consumed)

if not status.isPowered then
    print("Power shortage detected!")
    power:updatePowerStates(base)
else
    print("Power stable: " .. status.surplus .. " surplus")
end
```

---

## Related Documentation

- [Basescape System](../systems/Basescape.md) - Game mechanics and overview
- [Core API](CORE.md) - Core engine APIs
- [GEOSCAPE API](GEOSCAPE.md) - Strategic layer APIs
- [API Index](README.md) - All API documentation

---

**To contribute**: See [DOCUMENTATION_STANDARD.md](../../docs/DOCUMENTATION_STANDARD.md)

**Last Updated**: October 21, 2025 | **Status**: Complete - All systems documented

```
