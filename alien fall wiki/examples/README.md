# Alien Fall Examples Repository

> **Purpose:** Provide working code examples, complete mods, and TOML templates that demonstrate best practices for Alien Fall development and modding.

---

## Overview

This examples repository contains **production-ready code** that you can:
- **Copy & Modify** - Use as templates for your own content
- **Learn From** - Understand best practices and patterns
- **Test With** - Run directly in your development environment
- **Reference** - Quick lookup for syntax and structure

All examples follow the **20×20 grid system**, use **deterministic patterns**, and comply with the **Love2D 11.5+ API**.

---

## Directory Structure

```
examples/
├── README.md              # This file
├── data/                  # TOML data file examples
│   ├── mission_template.toml
│   ├── research_entry.toml
│   ├── unit_class.toml
│   ├── weapon_definition.toml
│   ├── facility_definition.toml
│   └── enemy_unit.toml
├── lua/                   # Lua code examples
│   ├── custom_widget.lua
│   ├── mission_script.lua
│   ├── ai_behavior.lua
│   ├── event_handler.lua
│   ├── service_example.lua
│   └── rng_usage.lua
└── mods/                  # Complete example mods
    ├── example_weapon_mod/
    ├── example_faction_mod/
    └── example_mission_pack/
```

---

## Quick Start Guide

### Using Data Examples
1. Navigate to `/examples/data/`
2. Copy the relevant `.toml` file
3. Modify the values for your content
4. Place in your mod's `/data/` directory
5. Update the `mod.toml` manifest

### Using Lua Examples
1. Navigate to `/examples/lua/`
2. Review the code and comments
3. Adapt the patterns to your needs
4. Test in Love2D environment
5. Follow the determinism guidelines

### Using Complete Mods
1. Navigate to `/examples/mods/`
2. Copy the entire mod directory to `/mods/`
3. Modify `mod.toml` with your details
4. Customize the content
5. Test in-game

---

## Example Categories

### 📊 Data Examples (`/data/`)
Complete TOML templates for all major game content types:
- **[mission_template.toml](data/mission_template.toml)** - Full mission definition with objectives
- **[research_entry.toml](data/research_entry.toml)** - Research tech with prerequisites
- **[unit_class.toml](data/unit_class.toml)** - Soldier class with stats and abilities
- **[weapon_definition.toml](data/weapon_definition.toml)** - Complete weapon with all properties
- **[facility_definition.toml](data/facility_definition.toml)** - Base facility with costs and services
- **[enemy_unit.toml](data/enemy_unit.toml)** - Enemy unit with AI behavior tags

### 💻 Lua Code Examples (`/lua/`)
Working Lua code demonstrating core patterns:
- **[custom_widget.lua](lua/custom_widget.lua)** - UI widget with 20×20 grid alignment
- **[mission_script.lua](lua/mission_script.lua)** - Mission event scripting
- **[ai_behavior.lua](lua/ai_behavior.lua)** - AI decision-making pattern
- **[event_handler.lua](lua/event_handler.lua)** - Event bus usage
- **[service_example.lua](lua/service_example.lua)** - Service architecture pattern
- **[rng_usage.lua](lua/rng_usage.lua)** - Deterministic randomness

### 🎮 Complete Mods (`/mods/`)
Full working mods ready to use:
- **[example_weapon_mod/](mods/example_weapon_mod/)** - Adds a new weapon with custom stats
- **[example_faction_mod/](mods/example_faction_mod/)** - New enemy faction (coming soon)
- **[example_mission_pack/](mods/example_mission_pack/)** - Custom mission set (coming soon)

---

## Best Practices Demonstrated

### ✅ Grid System Compliance
All UI examples use the **20×20 pixel grid**:
```lua
-- Positions are multiples of 20
local x = 5 * GRID_SIZE  -- 100 pixels
local y = 3 * GRID_SIZE  -- 60 pixels

-- Widgets snap to grid
widget:setPosition(x, y)
widget:setSize(10 * GRID_SIZE, 2 * GRID_SIZE)  -- 200×40
```

### ✅ Deterministic Design
All gameplay code uses **seeded RNG**:
```lua
-- Correct: Seeded, reproducible
local rng = services:get("rng")
local damage = rng:random("combat:damage", 20, 40)

-- Incorrect: Non-deterministic (DON'T DO THIS)
local damage = math.random(20, 40)
```

### ✅ Event-Driven Architecture
All systems communicate via **event bus**:
```lua
-- Emit events
eventBus:emit("geoscape:mission_spawned", {
    mission_id = mission.id,
    province_id = province.id
})

-- Listen for events
eventBus:on("battlescape:mission_end", function(data)
    -- Handle mission completion
end)
```

### ✅ TOML Data Format
All content uses **structured TOML**:
```toml
[[weapon]]
id = "mymod_plasma_rifle"
name = "Plasma Rifle"
tier = 2

[weapon.stats]
damage = 45
accuracy = 80
ap_cost = 3
```

---

## Testing Your Code

### Running Lua Examples
```bash
# From project root
./love-11.5-win64/lovec.exe .

# With console for debugging
./love-11.5-win64/lovec.exe . --console
```

### Validating TOML Files
```bash
# Use the TOML validator tool
lua tools/validate_toml.lua examples/data/weapon_definition.toml
```

### Testing Complete Mods
1. Copy mod to `/mods/` directory
2. Enable in mod loader UI
3. Start game and verify content appears
4. Check console for errors

---

## Common Patterns Reference

### Pattern: Creating a Widget
```lua
local Widget = require("src.widgets.base_widget")

local MyWidget = Widget:extend()

function MyWidget:new(x, y)
    MyWidget.super.new(self, x * GRID_SIZE, y * GRID_SIZE, 10 * GRID_SIZE, 5 * GRID_SIZE)
end

function MyWidget:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return MyWidget
```

### Pattern: Using Services
```lua
local services = require("src.core.services.registry")

-- Get service instance
local economy = services:get("economy")
local credits = economy:getCredits()

-- Deduct credits
economy:spendCredits(5000)
```

### Pattern: Emitting Events
```lua
local eventBus = require("src.core.services.event_bus")

-- Emit with data payload
eventBus:emit("research:completed", {
    research_id = "laser_weapons",
    unlock_items = {"laser_rifle", "laser_pistol"}
})
```

---

## Troubleshooting

### Issue: Code doesn't work in Love2D
**Solution:** Check that you're using Love2D 11.5+ and have all required modules loaded.

### Issue: TOML file won't load
**Solution:** Validate TOML syntax. Common errors:
- Missing quotes around strings
- Incorrect array syntax `[]`
- Wrong table structure `[[]]`

### Issue: Widget position is wrong
**Solution:** Ensure you're using grid coordinates:
```lua
-- Correct: Grid units
setPosition(5, 3)  -- 5 grid units × 20px = 100px

-- Also correct: Explicit pixels (must be multiples of 20)
setPosition(100, 60)
```

### Issue: Random values change on reload
**Solution:** Use seeded RNG instead of `math.random()`:
```lua
-- Use scoped RNG
local rng = services:get("rng")
local value = rng:random("my_scope:value", 1, 100)
```

---

## Contributing Examples

Want to add your own examples? Follow these guidelines:

### Requirements
1. **Working Code** - Must run without errors
2. **Well Commented** - Explain what the code does
3. **Best Practices** - Follow grid system, determinism, event bus
4. **Complete** - Include all dependencies and data files
5. **Documented** - Add README explaining the example

### Submission Process
1. Create your example following existing structure
2. Test thoroughly in Love2D
3. Add entry to this README
4. Submit via pull request or mod portal

---

## Related Documentation

### Core References
- **[Modding Hub](../mods/README.md)** - Complete modding guide
- **[Getting Started](../mods/Getting_Started.md)** - First mod tutorial
- **[API Reference](../mods/API_Reference.md)** - Lua API documentation
- **[Mod Structure](../mods/Mod_Structure.md)** - Directory layout spec

### Technical Guides
- **[Architecture](../technical/README.md)** - System architecture
- **[Grid System](../technical/Grid_System.md)** - 20×20 grid details
- **[Determinism](../technical/Determinism.md)** - RNG and reproducibility
- **[Event Bus](../technical/Event_Bus.md)** - Event-driven architecture

### Game Systems
- **[Geoscape](../geoscape/README.md)** - Strategic layer
- **[Battlescape](../battlescape/README.md)** - Tactical combat
- **[Economy](../economy/README.md)** - Research & manufacturing
- **[Units](../units/README.md)** - Soldier management

---

## License

All examples are provided under the same license as Alien Fall. You are free to use, modify, and distribute these examples in your own mods and projects.

---

## Tags
`#examples` `#code` `#toml` `#lua` `#mods` `#templates` `#reference`
