# Getting Started with Modding

> **Purpose:** A step-by-step tutorial to create your first Alien Fall mod in 15 minutes.

---

## What You'll Learn

By the end of this tutorial, you will:
- ✅ Understand the basic mod structure
- ✅ Create a simple weapon mod
- ✅ Test your mod in the game
- ✅ Learn how to debug common issues
- ✅ Be ready to explore advanced modding features

**Estimated Time:** 15-20 minutes  
**Difficulty:** ⭐ Beginner  
**Prerequisites:** Basic text editing skills

---

## Prerequisites

### Required Software
1. **Alien Fall Game** - Installed and working
2. **Text Editor** - Any text editor works, but we recommend:
   - VS Code (with TOML and Lua extensions)
   - Notepad++
   - Sublime Text

### Optional Tools
- **Git** - For version control (recommended)
- **Image Editor** - For custom sprites (GIMP, Aseprite, Photoshop)

---

## Tutorial: Your First Weapon Mod

Let's create a simple mod that adds a new weapon to the game!

### Step 1: Create Mod Directory Structure

Navigate to your Alien Fall installation and find the `mods/` directory:

```
C:\Users\YourName\Documents\AlienFall\LoveNew\mods\
```

Create a new folder called `my_first_mod`:

```
mods/
└── my_first_mod/        ← Create this folder
```

### Step 2: Create the Mod Manifest

Inside `my_first_mod/`, create a file called `mod.toml`:

**File:** `mods/my_first_mod/mod.toml`

```toml
[mod]
id = "my_first_mod"
name = "My First Weapon Mod"
version = "1.0.0"
author = "Your Name"
description = "Adds a powerful new plasma rifle to the game"

[mod.compatibility]
game_version = ">=0.5.0"
dependencies = []
optional_dependencies = []
conflicts = []

[mod.metadata]
tags = ["weapons", "beginner", "tutorial"]
```

**What This Does:**
- `id`: Unique identifier for your mod (no spaces, lowercase)
- `name`: Display name shown in mod manager
- `version`: Semantic versioning (MAJOR.MINOR.PATCH)
- `game_version`: Minimum game version required
- `tags`: Help players find your mod

---

### Step 3: Create Data Directory

Create the data folder structure:

```
mods/my_first_mod/
├── mod.toml
└── data/              ← Create this folder
    └── weapons/       ← Create this folder
```

---

### Step 4: Define Your Weapon

Create a new weapon data file:

**File:** `mods/my_first_mod/data/weapons/plasma_rifle.toml`

```toml
# My Custom Plasma Rifle
[[weapon]]
id = "my_first_mod_plasma_rifle"
name = "Prototype Plasma Rifle"
type = "rifle"
description = "An experimental energy weapon with devastating firepower."

[weapon.stats]
damage = 50                    # High damage!
accuracy = 85                  # Good accuracy
range = 22                     # Longer range than basic rifle
ap_cost = 3                    # Standard rifle AP cost
crit_chance = 15               # 15% critical hit chance
crit_multiplier = 2.0          # Double damage on crits

[weapon.ammo]
capacity = 24                  # Magazine size
reload_ap = 2                  # AP to reload
ammo_type = "energy_cell"      # Uses energy ammunition

[weapon.fire_modes]
single_shot = true             # Can fire single shots
burst = false                  # No burst fire mode
auto = false                   # No full auto

[weapon.requirements]
research = ["plasma_weapons"]  # Requires plasma tech research

[weapon.costs]
credits = 8000                 # Purchase price
manufacture_time = 120         # Hours to manufacture
manufacture_resources = {      # Resources needed
    elerium = 5,
    alloys = 10,
    electronics = 8
}

[weapon.metadata]
tier = 2                       # Mid-tier weapon
tags = ["energy", "rifle", "prototype", "advanced"]
weight = 4.5                   # Encumbrance weight
size = 2                       # Inventory slots (2x1)
```

**Understanding the Stats:**

| Field | Purpose | Example Values |
|-------|---------|----------------|
| `damage` | Base damage per hit | 20-100 |
| `accuracy` | Base accuracy % | 50-95 |
| `range` | Maximum effective range | 10-30 tiles |
| `ap_cost` | Action points per shot | 2-5 |
| `crit_chance` | Critical hit % | 0-25 |

---

### Step 5: Test Your Mod

#### Enable the Mod

1. Launch Alien Fall with console enabled:
   ```
   love-11.5-win64\lovec.exe .
   ```

2. The console should show mod loading:
   ```
   [MOD] Loading mod: my_first_mod v1.0.0
   [MOD] Registered 1 weapon(s) from my_first_mod
   [MOD] my_first_mod loaded successfully
   ```

#### Verify in Game

1. Start a new campaign or load a save
2. Go to Research screen
3. Research "Plasma Weapons" (if not already done)
4. Go to Manufacturing or Marketplace
5. Look for "Prototype Plasma Rifle"
6. Equip it on a soldier
7. Start a mission and test it in combat!

---

### Step 6: Debugging Common Issues

#### ❌ Mod Doesn't Appear

**Problem:** Mod not showing in mod list

**Solutions:**
1. Check `mod.toml` is in the correct location:
   ```
   mods/my_first_mod/mod.toml  ← Must be here
   ```
2. Verify TOML syntax is valid (use online validator)
3. Check console for error messages
4. Ensure `id` field has no spaces or special characters

---

#### ❌ Weapon Not Available

**Problem:** Weapon doesn't appear in manufacturing/marketplace

**Solutions:**
1. Check weapon ID is unique (no duplicates)
2. Verify research requirement is met
3. Check data file path:
   ```
   mods/my_first_mod/data/weapons/plasma_rifle.toml
   ```
4. Look for validation errors in console

---

#### ❌ Game Crashes on Load

**Problem:** Game crashes when loading mod

**Solutions:**
1. Check TOML syntax for errors:
   - Missing quotes around strings
   - Missing commas in tables
   - Invalid field types (string vs number)
2. Verify all required fields are present
3. Check console for specific error message
4. Temporarily disable mod to confirm it's the cause

---

#### ❌ Stats Don't Work as Expected

**Problem:** Weapon damage/accuracy seems wrong

**Solutions:**
1. Remember: damage is modified by:
   - Target armor
   - Distance penalties
   - Cover bonuses
   - Random spread
2. Test in controlled conditions (console commands)
3. Check combat log for actual calculations
4. Verify stats are reasonable (damage 1-100, accuracy 0-100)

---

### Step 7: Console Commands for Testing

Enable developer console with `~` (tilde key), then try:

```lua
-- Spawn your weapon directly
/give my_first_mod_plasma_rifle

-- Check weapon stats
/inspect weapon my_first_mod_plasma_rifle

-- Start test mission
/mission test_combat

-- Set soldier stats to max (for testing)
/buff_unit soldier_1 all 100

-- Enable debug overlay
/debug_mode true
```

---

## Next Steps: Expanding Your Mod

### Add Visual Assets

Create custom sprites for your weapon:

```
mods/my_first_mod/
├── mod.toml
├── data/
│   └── weapons/
└── assets/          ← Create this
    └── sprites/     ← Create this
        └── weapons/
            ├── plasma_rifle_icon.png      (10x10 pixels)
            └── plasma_rifle_tactical.png  (10x10 pixels)
```

**Update weapon data:**
```toml
[weapon.visual]
icon = "my_first_mod/assets/sprites/weapons/plasma_rifle_icon.png"
sprite = "my_first_mod/assets/sprites/weapons/plasma_rifle_tactical.png"
```

**Sprite Requirements:**
- Size: 10×10 pixels (scaled 2× in-game)
- Format: PNG with transparency
- Style: Pixel art matching game aesthetic
- Filtering: Nearest-neighbor (no anti-aliasing)

---

### Add Sound Effects

Add custom weapon sounds:

```
mods/my_first_mod/
└── assets/
    └── audio/
        └── weapons/
            ├── plasma_fire.ogg
            ├── plasma_reload.ogg
            └── plasma_impact.ogg
```

**Update weapon data:**
```toml
[weapon.audio]
fire = "my_first_mod/assets/audio/weapons/plasma_fire.ogg"
reload = "my_first_mod/assets/audio/weapons/plasma_reload.ogg"
impact = "my_first_mod/assets/audio/weapons/plasma_impact.ogg"
```

---

### Add Localization

Support multiple languages:

```
mods/my_first_mod/
└── locale/
    ├── en_US.toml
    ├── es_ES.toml
    └── fr_FR.toml
```

**File:** `locale/en_US.toml`
```toml
[weapons]
my_first_mod_plasma_rifle_name = "Prototype Plasma Rifle"
my_first_mod_plasma_rifle_desc = "An experimental energy weapon with devastating firepower."
my_first_mod_plasma_rifle_flavor = "\"The future of warfare, today.\" - R&D Report #447"
```

**Update weapon data:**
```toml
[[weapon]]
id = "my_first_mod_plasma_rifle"
name = "@weapons.my_first_mod_plasma_rifle_name"      # Reference translation
description = "@weapons.my_first_mod_plasma_rifle_desc"
```

---

### Add Custom Fire Effects

Create visual effects for weapon firing:

**File:** `mods/my_first_mod/scripts/weapon_effects.lua`

```lua
-- Custom plasma rifle fire effect
local function plasmaFireEffect(weapon, shooter, target)
    -- Spawn plasma particle effect
    local fx = modAPI:spawnEffect("plasma_beam", shooter.pos, target.pos)
    fx:setColor(0, 255, 100)  -- Green plasma
    fx:setDuration(0.3)
    
    -- Screen shake
    modAPI:cameraShake(2, 0.2)
    
    -- Play sound
    modAPI:playSound("my_first_mod/assets/audio/weapons/plasma_fire.ogg")
end

-- Register effect handler
modAPI:registerWeaponEffect("my_first_mod_plasma_rifle", plasmaFireEffect)
```

---

## Advanced Topics Preview

Once you're comfortable with basic weapon modding, explore:

### 🎯 Mission Design
Create custom missions with unique objectives and map layouts.  
**Guide:** [Mission Design](content/Mission_Design.md)

### 👽 Unit Design
Design new soldiers, aliens, and enemy factions.  
**Guide:** [Unit Design](content/Unit_Design.md)

### 🔬 Research Trees
Add new research projects and tech progression.  
**Guide:** [Research Trees](content/Research_Trees.md)

### 🗺️ Map Creation
Build tactical battlefields with custom terrain.  
**Guide:** [Map Creation](content/Map_Creation.md)

### 🤖 AI Behaviors
Script custom enemy tactics and behaviors.  
**Guide:** [AI Behaviors](content/AI_Behaviors.md)

### 🎨 Custom Widgets
Create new UI elements and interfaces.  
**Guide:** [Custom Widgets](Custom_Widgets.md)

---

## Example Mod Structure (Complete)

Here's what a complete, polished mod looks like:

```
mods/my_first_mod/
├── mod.toml                    # Mod manifest
├── README.md                   # Documentation
├── CHANGELOG.md                # Version history
├── LICENSE.txt                 # License (MIT, GPL, etc.)
│
├── data/                       # Game data
│   ├── weapons/
│   │   └── plasma_rifle.toml
│   ├── research/
│   │   └── plasma_tech.toml
│   └── manufacturing/
│       └── plasma_recipes.toml
│
├── assets/                     # Visual/audio assets
│   ├── sprites/
│   │   └── weapons/
│   │       ├── plasma_rifle_icon.png
│   │       └── plasma_rifle_tactical.png
│   └── audio/
│       └── weapons/
│           ├── plasma_fire.ogg
│           └── plasma_reload.ogg
│
├── scripts/                    # Lua scripts
│   ├── init.lua               # Mod initialization
│   ├── weapon_effects.lua     # Custom effects
│   └── balance.lua            # Balance tweaks
│
├── locale/                     # Translations
│   ├── en_US.toml
│   ├── es_ES.toml
│   └── fr_FR.toml
│
└── tests/                      # Automated tests
    └── test_plasma_rifle.lua
```

---

## Troubleshooting Guide

### Getting Help

If you run into issues:

1. **Check Console Output** - Most errors are logged with helpful messages
2. **Read Error Messages** - They usually tell you exactly what's wrong
3. **Validate TOML Files** - Use online validator or IDE plugin
4. **Search Documentation** - Use Ctrl+F in the wiki
5. **Ask Community** - Discord, forums, GitHub issues

### Common Error Messages

#### "Mod manifest not found"
```
[ERROR] Could not load mod: mod.toml not found
```
**Solution:** Ensure `mod.toml` is in mod root directory

#### "Invalid TOML syntax"
```
[ERROR] TOML parse error at line 15: expected '=' after key
```
**Solution:** Check TOML syntax, common issues:
- Missing quotes around strings
- Missing commas in arrays
- Invalid characters in keys

#### "Duplicate ID"
```
[ERROR] Weapon ID 'my_first_mod_plasma_rifle' already registered
```
**Solution:** Change weapon ID to be unique, or use content override system

#### "Missing required field"
```
[ERROR] Weapon validation failed: missing required field 'damage'
```
**Solution:** Add all required fields to weapon definition

#### "Invalid game version"
```
[ERROR] Mod requires game version >=0.6.0, but current version is 0.5.0
```
**Solution:** Update game or change `game_version` requirement in mod.toml

---

## Best Practices Checklist

Before publishing your mod, ensure:

- [ ] Unique mod ID (no conflicts with other mods)
- [ ] Semantic versioning (1.0.0 format)
- [ ] All required fields in manifest
- [ ] Data files validate without errors
- [ ] Assets are correct size (10×10 for sprites)
- [ ] No console errors or warnings
- [ ] Tested in a clean game install
- [ ] README.md with installation instructions
- [ ] CHANGELOG.md documenting versions
- [ ] LICENSE.txt with appropriate license
- [ ] Localization for at least English
- [ ] Screenshots showing the mod in action

---

## Publishing Your Mod

Ready to share your creation?

1. **Document Everything** - Write clear README and changelog
2. **Create Screenshots** - Show your mod in action
3. **Package Correctly** - Zip the entire mod folder
4. **Choose Platform** - GitHub, Steam Workshop, Nexus Mods
5. **Get Feedback** - Share with community for testing

**Full Publishing Guide:** [Publishing Guidelines](Publishing_Guidelines.md)

---

## Quick Reference Card

### Essential Mod Structure
```
mods/your_mod_name/
├── mod.toml          # Required: mod manifest
├── data/             # Game data (TOML files)
├── assets/           # Sprites, audio, etc.
├── scripts/          # Lua code
└── locale/           # Translations
```

### Minimum mod.toml
```toml
[mod]
id = "your_mod_id"
name = "Your Mod Name"
version = "1.0.0"
author = "Your Name"
description = "What your mod does"

[mod.compatibility]
game_version = ">=0.5.0"
```

### Testing Commands
```bash
# Run with console
lovec.exe .

# Run with dev mode
lovec.exe . --dev

# Run with mod debugging
lovec.exe . --dev --mod-debug=your_mod_id
```

---

## Congratulations! 🎉

You've created your first Alien Fall mod! You now know how to:
- ✅ Create mod directory structure
- ✅ Write mod manifests
- ✅ Define game data in TOML
- ✅ Test mods in-game
- ✅ Debug common issues

### Continue Your Journey
- Explore the [Mod Structure](Mod_Structure.md) guide for advanced organization
- Read the [API Reference](API_Reference.md) for scripting capabilities
- Check out [Example Mods](../examples/mods/) for inspiration
- Join the community and share your creations!

---

## Additional Resources

- **[Modding Hub](README.md)** - Main modding documentation
- **[API Reference](API_Reference.md)** - Complete Lua API
- **[Data Formats](Data_Formats.md)** - TOML schema reference
- **[Testing Guide](Testing_Your_Mod.md)** - Quality assurance
- **[Content Creation Guides](content/)** - Design documentation

---

## Tags
`#tutorial` `#beginner` `#modding` `#weapons` `#getting-started`
