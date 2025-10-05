# Modding Hub

> **Purpose:** Comprehensive guide to creating, distributing, and maintaining mods for Alien Fall using the Love2D engine and Lua scripting.

---

## Welcome to Alien Fall Modding!

Alien Fall is designed from the ground up to be **extensively moddable**. Every game system—from tactical combat to strategic research—can be extended, modified, or completely overhauled through mods. This documentation will guide you through the entire modding process, from your first simple data override to complex total conversion projects.

---

## Why Mod Alien Fall?

### Built for Modding
- **Data-Driven Design:** All game content defined in TOML files
- **Deterministic Systems:** Reproducible outcomes for testing and balance
- **Sandboxed Lua Scripting:** Safe, powerful scripting environment
- **Dependency Resolution:** Automatic mod load order and conflict detection
- **Hot Reload Support:** Test changes without restarting the game (dev mode)

### Powerful Capabilities
- Add new missions, enemies, weapons, and equipment
- Create custom factions and campaign arcs
- Design unique tactical maps and mission types
- Implement new game mechanics and systems
- Override or extend existing content
- Create custom UI widgets and themes
- Script complex AI behaviors

### Community Ecosystem
- Mod sharing and distribution platform
- Comprehensive API documentation
- Example mods and templates
- Active modding community
- Developer support and feedback

---

## Quick Navigation

### Getting Started
- **[Getting Started Guide](Getting_Started.md)** - Your first mod in 15 minutes
- **[Mod Structure](Mod_Structure.md)** - File organization and manifest format
- **[Development Workflow](Development_Workflow.md)** - Best practices for mod development

### Core Concepts
- **[API Reference](API_Reference.md)** - Complete sandboxed Lua API documentation
- **[Content Override System](Content_Override_System.md)** - Modify existing game content
- **[Data Formats](Data_Formats.md)** - TOML schema and data structure reference
- **[Event System](Event_System.md)** - Hook into game events and triggers

### Advanced Topics
- **[Dependency Management](Dependency_Management.md)** - Multi-mod compatibility
- **[Lua Scripting](Lua_Scripting.md)** - Advanced scripting techniques
- **[Custom Widgets](Custom_Widgets.md)** - Create new UI components
- **[Localization](Localization.md)** - Multi-language support for mods
- **[Performance Optimization](Performance_Optimization.md)** - Keep your mod running smoothly

### Content Creation
- **[Mission Design](content/Mission_Design.md)** - Create custom missions and objectives
- **[Unit Design](content/Unit_Design.md)** - Design soldiers, aliens, and civilians
- **[Item Design](content/Item_Design.md)** - Weapons, armor, and equipment
- **[Map Creation](content/Map_Creation.md)** - Build tactical battlefields
- **[Research Trees](content/Research_Trees.md)** - Tech progression and unlocks
- **[AI Behaviors](content/AI_Behaviors.md)** - Custom enemy tactics

### Publishing & Distribution
- **[Testing Your Mod](Testing_Your_Mod.md)** - Quality assurance and debugging
- **[Publishing Guidelines](Publishing_Guidelines.md)** - Prepare your mod for release
- **[Distribution Platforms](Distribution_Platforms.md)** - Share your creation
- **[Version Management](Version_Management.md)** - Updates and compatibility

---

## Modding Philosophy

### Design Principles

#### 1. **Determinism First**
All mods must respect Alien Fall's deterministic simulation. Random events use seeded RNG, ensuring reproducible outcomes for testing and multiplayer compatibility.

```lua
-- CORRECT: Use seeded RNG
local rng = modAPI:getRNG("mymod:event_name")
local roll = rng:random(1, 100)

-- INCORRECT: Global random breaks determinism
local roll = math.random(1, 100)  -- DON'T DO THIS
```

#### 2. **Data-Driven Content**
Prefer TOML data files over hardcoded Lua logic. This makes your mod easier to balance, localize, and maintain.

```toml
# data/weapons/custom_rifle.toml
[[weapon]]
id = "mymod_plasma_rifle"
name = "Plasma Rifle Mk2"
damage = 45
accuracy = 85
ap_cost = 3
```

#### 3. **Compatibility by Default**
Design mods to coexist with others. Use unique IDs, respect dependency chains, and provide clear conflict warnings.

#### 4. **Performance Conscious**
The game runs at 60 FPS on a 20×20 grid. Profile your code, batch draw calls, and cache expensive calculations.

#### 5. **Player Experience Focus**
Balance fun over realism. Provide clear feedback, avoid frustrating mechanics, and respect player agency.

---

## Mod Capabilities Matrix

| Capability | Difficulty | Documentation |
|------------|-----------|---------------|
| **Override existing items** | ⭐ Easy | [Content Override System](Content_Override_System.md) |
| **Add new weapons/armor** | ⭐ Easy | [Item Design](content/Item_Design.md) |
| **Create custom missions** | ⭐⭐ Moderate | [Mission Design](content/Mission_Design.md) |
| **Design new unit classes** | ⭐⭐ Moderate | [Unit Design](content/Unit_Design.md) |
| **Modify research trees** | ⭐⭐ Moderate | [Research Trees](content/Research_Trees.md) |
| **Build tactical maps** | ⭐⭐ Moderate | [Map Creation](content/Map_Creation.md) |
| **Script AI behaviors** | ⭐⭐⭐ Advanced | [AI Behaviors](content/AI_Behaviors.md) |
| **Create custom widgets** | ⭐⭐⭐ Advanced | [Custom Widgets](Custom_Widgets.md) |
| **Implement new systems** | ⭐⭐⭐⭐ Expert | [Lua Scripting](Lua_Scripting.md) |

---

## Example Mods

### Starter Projects
Learn by example with these complete, working mods:

1. **[Simple Weapon Mod](../examples/mods/simple_weapon_mod/)** - Add a new rifle to the game
2. **[Faction Expansion](../examples/mods/faction_expansion/)** - New enemy faction with custom units
3. **[Mission Pack](../examples/mods/mission_pack/)** - Collection of custom missions
4. **[UI Theme](../examples/mods/ui_theme/)** - Custom colors and visual style

### Community Showcases
Inspiring mods from the community:

- **Long War Conversion** - Extended campaign with 200+ hours of content
- **Underwater Warfare** - Aquatic combat expansion
- **Psionic Overhaul** - Reimagined psionic system
- **Historical Earth** - Real-world nations and conflicts
- **Alien Perspectives** - Play as the alien invaders

---

## Development Tools

### Essential Tools
- **Love2D 11.5+** - Game engine (included in project)
- **Text Editor** - VS Code recommended with Lua extensions
- **TOML Editor** - Built-in validation for data files
- **Git** - Version control for your mod

### Helpful Utilities
- **Mod Template Generator** - Scaffold new mod structure
- **Data Validator** - Check TOML files for errors
- **Hot Reload Watcher** - Auto-reload on file changes (dev mode)
- **Profiler** - Performance analysis tools
- **Debug Console** - Runtime inspection and testing

### Debugging Features
```lua
-- Enable debug mode in your mod
modAPI:setDebugMode(true)

-- Log messages to console
modAPI:log("Debug message: " .. tostring(value))

-- Inspect game state
modAPI:inspectGameState()

-- Dump mod data
modAPI:dumpModData("mymod")
```

---

## Modding API Overview

### Core Services Available to Mods

#### Registry Service
```lua
-- Access game systems
local economy = modAPI:getService("economy")
local units = modAPI:getService("units")
```

#### Event Bus
```lua
-- Subscribe to game events
modAPI:subscribe("battlescape:mission_start", function(payload)
    modAPI:log("Mission started: " .. payload.mission_id)
end)

-- Publish custom events
modAPI:publish("mymod:custom_event", {data = "example"})
```

#### Data Access
```lua
-- Read game data
local weapons = modAPI:getData("items/weapons")

-- Register mod data
modAPI:registerData("mymod/custom_units", unitData)
```

#### Asset Loading
```lua
-- Load mod assets
local sprite = modAPI:loadSprite("mymod/assets/sprites/custom_rifle.png")
local sound = modAPI:loadSound("mymod/assets/audio/plasma_fire.ogg")
```

---

## Sandboxed Environment

For security and stability, mod Lua scripts run in a **sandboxed environment** with restricted access to system functions.

### ✅ Allowed
- All Lua standard library (except `io`, `os`, `package`, `debug`)
- Whitelisted Love2D functions (graphics, audio, input)
- Game API functions via `modAPI` table
- Math, string, table operations
- Coroutines for async logic

### ❌ Restricted
- File system access (use `modAPI:loadFile()` instead)
- Network operations
- System calls
- Loading external libraries
- Direct access to game internals

### API Documentation
Complete API reference with examples: **[API Reference](API_Reference.md)**

---

## Grid System & Visual Standards

Alien Fall uses a **20×20 pixel logical grid** for all UI and tactical maps.

### Grid Requirements
- All UI elements must snap to 20×20 grid
- Sprite source art is 10×10 pixels, scaled ×2 during render
- Use grid constants: `GRID_SIZE = 20`
- Calculate positions: `x = grid_unit * GRID_SIZE`

### Example: Grid-Aligned Widget
```lua
-- Custom widget positioned on grid
local widget = {
    x = 5 * 20,  -- Grid unit 5 = 100 pixels
    y = 3 * 20,  -- Grid unit 3 = 60 pixels
    width = 10 * 20,  -- 10 grid units wide
    height = 4 * 20   -- 4 grid units tall
}
```

### Visual Assets
- Use nearest-neighbor filtering for pixel-perfect rendering
- Disable antialiasing (MSAA = 0)
- Fixed 800×600 internal resolution (40×30 grid units)
- Window scaling handled automatically

See: **[Love2D UI Design System](../love2d_ui_design_system.md)**

---

## Data-Driven Design

### TOML Data Files
Game content is defined in `.toml` files under your mod's `data/` directory.

```
mymod/
├── mod.toml          # Mod manifest
├── data/
│   ├── weapons/
│   │   └── plasma_weapons.toml
│   ├── units/
│   │   └── elite_soldiers.toml
│   └── missions/
│       └── custom_scenarios.toml
```

### Schema Validation
All data files are validated against schemas on load:

```toml
# data/weapons/plasma_rifle.toml
[[weapon]]
id = "mymod_plasma_rifle"        # Required: unique identifier
name = "Plasma Rifle"            # Required: display name
type = "rifle"                   # Required: weapon type

[weapon.stats]
damage = 45                      # Required: base damage
accuracy = 85                    # Required: base accuracy
range = 20                       # Required: maximum range
ap_cost = 3                      # Required: action points

[weapon.ammo]
capacity = 30                    # Optional: magazine size
reload_ap = 2                    # Optional: reload cost

[weapon.requirements]
research = ["plasma_tech"]       # Optional: unlock requirements
```

See complete schemas: **[Data Formats](Data_Formats.md)**

---

## Load Order & Dependencies

### Mod Manifest
Every mod requires a `mod.toml` manifest in its root directory:

```toml
[mod]
id = "mymod"
name = "My Awesome Mod"
version = "1.0.0"
author = "YourName"
description = "Adds amazing new content to Alien Fall"

[mod.compatibility]
game_version = ">=0.5.0"         # Minimum game version
dependencies = []                 # Required mods
optional_dependencies = []        # Optional compatibility
conflicts = []                    # Incompatible mods

[mod.metadata]
tags = ["weapons", "units", "missions"]
homepage = "https://github.com/yourname/mymod"
license = "MIT"
```

### Dependency Resolution
The mod loader automatically:
1. Resolves dependency graphs
2. Determines load order based on priority and dependencies
3. Detects circular dependencies
4. Reports conflicts and missing dependencies

### Load Priority
```toml
[mod]
priority = 100  # Higher numbers load later (default: 50)
```

**Priority Ranges:**
- `0-25`: Framework mods (libraries, APIs)
- `26-50`: Content mods (default)
- `51-75`: Balance/overhaul mods
- `76-100`: Compatibility patches

See: **[Dependency Management](Dependency_Management.md)**

---

## Content Override System

Mods can override existing game content using the same ID:

### Example: Modify Existing Weapon
```toml
# Override vanilla rifle stats
[[weapon]]
id = "rifle_assault"  # Same ID as base game
damage = 50           # Increased from base 35
accuracy = 90         # Increased from base 80
# Other fields inherit base game values
```

### Merge Strategies
1. **Replace**: Completely override base content
2. **Merge**: Combine with base content (arrays concatenate)
3. **Patch**: Modify specific fields only

```toml
[mod.content_strategy]
weapons = "patch"     # Modify specific fields
missions = "merge"    # Add to existing missions
units = "replace"     # Completely override
```

See: **[Content Override System](Content_Override_System.md)**

---

## Localization Support

Make your mod accessible to international players:

```
mymod/
├── locale/
│   ├── en_US.toml    # English (default)
│   ├── es_ES.toml    # Spanish
│   ├── fr_FR.toml    # French
│   └── de_DE.toml    # German
```

### Localization File
```toml
# locale/en_US.toml
[items.weapons]
mymod_plasma_rifle_name = "Plasma Rifle Mk2"
mymod_plasma_rifle_desc = "Advanced energy weapon with sustained fire capability."

[ui]
mymod_settings_title = "Mod Settings"
```

### Using Translations
```lua
-- In your mod script
local name = modAPI:translate("items.weapons.mymod_plasma_rifle_name")
```

See: **[Localization](Localization.md)**

---

## Testing & Quality Assurance

### Development Mode
Enable hot reload and debug features:

```bash
# Run with dev mode enabled
lovec.exe . --dev

# Enable mod debugging
lovec.exe . --dev --mod-debug=mymod
```

### Testing Checklist
- [ ] All data files validate against schemas
- [ ] No Lua errors in console
- [ ] Deterministic behavior (same seed = same result)
- [ ] Performance: maintains 60 FPS
- [ ] Grid alignment: all UI elements snap to 20×20
- [ ] Localization: all strings translatable
- [ ] Compatibility: test with popular mods
- [ ] Save/load: game state persists correctly

### Automated Testing
```lua
-- tests/test_mymod.lua
local test = require('test_framework')

test.describe("My Mod Tests", function()
    test.it("should load custom weapon", function()
        local weapon = modAPI:getData("weapons/mymod_plasma_rifle")
        test.expect(weapon).to.exist()
        test.expect(weapon.damage).to.equal(45)
    end)
end)
```

See: **[Testing Your Mod](Testing_Your_Mod.md)**

---

## Publishing Your Mod

### Preparation
1. **Documentation** - Write a comprehensive README
2. **Screenshots** - Show your mod in action
3. **Changelog** - Document all changes
4. **License** - Choose an appropriate license (MIT, GPL, CC)
5. **Version** - Follow semantic versioning (1.0.0)

### Distribution Platforms
- **GitHub** - Source code and releases
- **Steam Workshop** - Steam version integration (planned)
- **Nexus Mods** - Popular modding community
- **Official Mod Portal** - In-game mod browser (planned)

### Package Structure
```
mymod-1.0.0.zip
├── mod.toml
├── README.md
├── LICENSE.txt
├── CHANGELOG.md
├── data/
├── assets/
├── scripts/
└── locale/
```

See: **[Publishing Guidelines](Publishing_Guidelines.md)**

---

## Community & Support

### Get Help
- **Discord** - Real-time chat with modders and developers
- **Forums** - In-depth discussions and tutorials
- **GitHub Issues** - Bug reports and feature requests
- **Wiki** - Community-maintained knowledge base

### Contribute
- Share your mods with the community
- Write tutorials and guides
- Report bugs and suggest improvements
- Help other modders troubleshoot issues

### Best Practices
- Use semantic versioning
- Document your code
- Provide example configurations
- Test with multiple mod combinations
- Keep mods focused and modular
- Respect other creators' work

---

## Additional Resources

### Official Documentation
- [Technical README](../technical/README.md) - Engine architecture
- [Love2D Implementation Plan](../docs/Love2D_Implementation_Plan.md) - Development roadmap
- [Style Guide](../docs/style-guide.md) - Documentation standards

### Game Systems
- [Geoscape](../geoscape/README.md) - Strategic layer
- [Battlescape](../battlescape/README.md) - Tactical combat
- [Economy](../economy/README.md) - Research and manufacturing
- [Units](../units/README.md) - Soldier management
- [Items](../items/README.md) - Equipment and weapons

### Example Code
- [Examples Directory](../examples/) - Working code samples
- [Mod Templates](../examples/mods/) - Starter projects

---

## Changelog

### Version 1.0.0 (September 30, 2025)
- Initial modding documentation release
- Complete API reference
- Example mods and templates
- Development tools and utilities

---

## Tags
`#modding` `#lua` `#toml` `#love2d` `#api` `#documentation` `#tutorial`
