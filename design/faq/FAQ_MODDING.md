# FAQ: Modding System

> **Audience**: Modders and content creators familiar with data-driven games  
> **Last Updated**: 2025-10-28  
> **Related Docs**: [MODDING_GUIDE.md](../../api/MODDING_GUIDE.md), [GAME_API.toml](../../api/GAME_API.toml), [mods/README.md](../../mods/README.md)

---

## Quick Navigation

- [Getting Started](#getting-started)
- [Mod Structure](#mod-structure)
- [TOML Data Format](#toml-data-format)
- [Asset Requirements](#asset-requirements)
- [Mod Compatibility](#mod-compatibility)
- [Common Issues](#common-issues)

---

## Getting Started

### Q: How hard is it to create a mod?

**A**: **Easy** - Data-driven TOML format (no programming required).

**Skill Requirements**:
- ✅ **Basic**: Edit text files (TOML format)
- ⚠️ **Optional**: Create pixel art (24x24 PNG)
- ❌ **Not required**: Programming, Lua knowledge

**Time to First Mod**:
- Simple unit: **15 minutes**
- New weapon: **30 minutes**
- Full mod pack: **2-10 hours**

---

### Q: What can I mod?

**A**: **Everything data-driven** (no engine modifications).

**Moddable Content**:

| Category | Examples | Difficulty |
|----------|----------|------------|
| **Units** | New soldier classes, aliens | Easy |
| **Items** | Weapons, armor, equipment | Easy |
| **Facilities** | Base buildings | Easy |
| **Crafts** | New aircraft | Medium |
| **Research** | Tech tree additions | Medium |
| **Missions** | Custom objectives | Medium |
| **Events** | Story triggers | Medium |
| **Factions** | New alien groups | Hard |

**Cannot Mod** (engine-level):
- Core combat mechanics
- UI layout
- Game engine behavior
- Lua code (without advanced modding)

---

### Q: Do I need programming knowledge?

**A**: **No** - TOML is human-readable data format.

**Example TOML** (New Unit):
```toml
[unit.my_sniper]
name = "Elite Sniper"
class = "sniper"
health = 20
accuracy = 85
strength = 8
# ... more stats
```

**What you need**:
- Text editor (Notepad++, VS Code)
- Understanding of game mechanics
- Patience to read documentation

**What you don't need**:
- Programming skills
- Compiler/IDE
- Complex tools

---

## Mod Structure

### Q: How do I create a mod?

**A**: **Copy template, edit files** (5-step process).

**Quick Start**:

1. **Copy `minimal_mod/` folder** to `mods/my_mod/`
2. **Edit `mod.toml`** (mod metadata)
3. **Add TOML files** to `rules/[type]/` (units, items, etc.)
4. **Add assets** to `assets/[type]/` (PNG, OGG files)
5. **Test** with `lovec "engine"`

**Example Structure**:
```
mods/my_mod/
├── mod.toml              # Mod metadata
├── rules/
│   ├── units/
│   │   └── sniper.toml   # Unit definition
│   ├── items/
│   │   └── rifle.toml    # Weapon definition
│   └── facilities/
│       └── lab.toml      # Facility definition
└── assets/
    ├── units/
    │   └── sniper.png    # 24x24 sprite
    └── items/
        └── rifle.png     # 12x12 or 24x24 sprite
```

---

### Q: What goes in `mod.toml`?

**A**: **Mod metadata** (name, version, dependencies).

**Example `mod.toml`**:
```toml
[mod]
id = "my_awesome_mod"            # Unique ID (no spaces)
name = "My Awesome Mod"          # Display name
version = "1.0.0"                # Semantic versioning
author = "YourName"              # Your name
description = "Adds cool stuff"  # Short description

[dependencies]
core = ">=1.0.0"                 # Requires core mod version 1.0.0+
other_mod = ">=2.5.0"            # Optional: Depends on another mod
```

**Key Fields**:
- **id**: Must be unique, alphanumeric + underscores
- **version**: Use semantic versioning (major.minor.patch)
- **dependencies**: List required mods and minimum versions

---

## TOML Data Format

### Q: How do I define a new unit?

**A**: Create TOML file in `rules/units/[unit_id].toml`.

**Example** (`rules/units/elite_sniper.toml`):
```toml
[unit]
id = "elite_sniper"              # Unique ID
name = "Elite Sniper"            # Display name
class = "sniper"                 # Unit class
rank = 3                         # Starting rank

[stats]
health = 20
accuracy = 85
strength = 8
reaction = 10
bravery = 12
piloting = 30

[equipment]
primary_weapon = "sniper_rifle"  # Item ID
armor = "combat_armor"           # Item ID
inventory = ["medikit", "grenade"]  # Starting items

[traits]
positive = ["smart", "fast"]     # Trait IDs
negative = []                    # No negative traits

[cost]
credits = 50000                  # Recruitment cost
training_time = 30               # Days to train
```

**Validation**:
- Game auto-validates against `api/GAME_API.toml` schema
- Errors shown in console on load
- Missing fields use default values

---

### Q: How do I add a new weapon?

**A**: Create TOML file in `rules/items/[item_id].toml`.

**Example** (`rules/items/plasma_rifle.toml`):
```toml
[item]
id = "plasma_rifle"
name = "Plasma Rifle"
type = "weapon"
category = "rifle"

[weapon]
damage = 30
accuracy = 75
range = 15
ap_cost = 2
energy_cost = 2
ammo_capacity = 20
damage_type = "energy"

[modes]
snap = { ap = 1, accuracy_mod = -5 }
aimed = { ap = 2, accuracy_mod = 15 }
auto = { ap = 2, accuracy_mod = -10, shots = 3 }

[requirements]
research = "plasma_technology"   # Must research first
rank = 2                         # Rank 2+ can use

[cost]
credits = 25000
manufacturing_time = 5           # Days to build
materials = { alien_alloys = 2, elerium = 1 }

[asset]
sprite = "assets/items/plasma_rifle.png"  # 12x12 or 24x24
```

---

### Q: What's the complete TOML schema?

**A**: See **`api/GAME_API.toml`** - SOURCE OF TRUTH for all data structures.

**Key Sections**:
- `[units]` - Unit definitions
- `[items]` - Weapons, armor, equipment
- `[facilities]` - Base buildings
- `[research]` - Tech tree projects
- `[crafts]` - Aircraft
- `[missions]` - Mission types
- `[events]` - Story events
- `[factions]` - Alien groups

**Documentation**:
- **[GAME_API_GUIDE.md](../../api/GAME_API_GUIDE.md)** - How to use the API
- **[MODDING_GUIDE.md](../../api/MODDING_GUIDE.md)** - Complete modding reference

---

## Asset Requirements

### Q: What art format do I need?

**A**: **PNG files** with specific sizes (pixel art style).

**Asset Specifications**:

| Asset Type | Size | Format | Transparency |
|------------|------|--------|--------------|
| **Units** | 24×24 px | PNG | Yes (alpha) |
| **Items** | 12×12 or 24×24 | PNG | Yes |
| **Facilities** | 48×48 or 96×96 | PNG | Yes |
| **Crafts** | 32×32 or 48×48 | PNG | Yes |
| **UI Icons** | 16×16 | PNG | Yes |

**Audio**:
- **Format**: OGG Vorbis
- **Sample Rate**: 44.1kHz
- **Channels**: Mono or Stereo

---

### Q: Can I use placeholder art?

**A**: **Yes** - Game uses fallback graphics if assets missing.

**Fallback System**:
- Missing unit sprite → Uses default soldier sprite
- Missing item sprite → Uses default item icon
- Missing audio → Silent (no error)

**Testing Without Art**:
1. Create TOML definitions first
2. Test mechanics with placeholder art
3. Add final art later

**Recommended Workflow**:
- Focus on mechanics first (TOML)
- Polish art later
- Release "mechanics complete" beta

---

### Q: Where can I get art assets?

**A**: Multiple sources (free and paid).

**Free Resources**:
- **OpenGameArt.org** - CC0 pixel art
- **itch.io** - Game assets
- **Kenney.nl** - Public domain assets

**Custom Art**:
- **Aseprite** - Pixel art editor ($20)
- **GIMP** - Free image editor
- **Piskel** - Free web-based pixel art

**Commission Artists**:
- **Fiverr** - $5-50 per asset
- **itch.io commissions** - Varies
- **r/gameDevClassifieds** - Community artists

---

## Mod Compatibility

### Q: Can I use multiple mods together?

**A**: **Yes** - Mod load order determines priority.

**Load Order Rules**:
1. **Core mod** loads first (always)
2. **Dependencies** load next (if specified)
3. **User mods** load in alphabetical order
4. **Later mods override earlier** (if conflicts)

**Example**:
```
Load order:
1. core/              (base game)
2. balance_mod/       (modifies core values)
3. units_expansion/   (adds new units)
4. my_custom_mod/     (overrides balance_mod values)
```

**Conflict Resolution**:
- If two mods define same unit ID → Last loaded wins
- Partial overrides supported (can modify only specific fields)

---

### Q: How do I make mods compatible?

**A**: **Use unique IDs** and **avoid overriding core content**.

**Best Practices**:
1. **Prefix IDs**: Use `mymod_sniper` instead of `sniper`
2. **Extend, don't replace**: Add new content instead of modifying core
3. **Document dependencies**: List required mods in `mod.toml`
4. **Test combinations**: Verify with popular mods

**Example**:
```toml
# ❌ Bad (conflicts with core)
[unit]
id = "sniper"

# ✅ Good (unique ID)
[unit]
id = "mymod_elite_sniper"
```

---

### Q: Can I make mods that require other mods?

**A**: **Yes** - Use `[dependencies]` in `mod.toml`.

**Example**:
```toml
[mod]
id = "advanced_weapons"
name = "Advanced Weapons Pack"
version = "2.0.0"

[dependencies]
core = ">=1.0.0"                 # Requires base game 1.0.0+
balance_mod = ">=3.5.0"          # Requires balance_mod 3.5.0+
```

**Dependency Behavior**:
- Game checks dependencies on load
- Errors if required mod missing or wrong version
- Load order automatically adjusted

---

## Common Issues

### Q: My mod doesn't load. What's wrong?

**A**: **Check console for errors** (most common issues below).

**Common Errors**:

1. **Invalid TOML Syntax**
   - **Error**: `Parse error at line X`
   - **Fix**: Check TOML syntax (quotes, brackets, commas)

2. **Missing Required Field**
   - **Error**: `Missing required field 'name' in unit definition`
   - **Fix**: Add missing field to TOML

3. **Invalid ID Reference**
   - **Error**: `Item 'laser_rifle' not found`
   - **Fix**: Verify item ID exists in another TOML file

4. **Asset Not Found**
   - **Warning**: `Asset 'units/sniper.png' not found, using fallback`
   - **Fix**: Add PNG file to correct assets folder

5. **Circular Dependency**
   - **Error**: `Circular dependency detected: mod_a → mod_b → mod_a`
   - **Fix**: Remove circular dependency chain

---

### Q: How do I debug my mod?

**A**: **Use console output** and **test incrementally**.

**Debugging Steps**:
1. **Run game**: `lovec "engine"`
2. **Check console**: Look for error messages
3. **Test one file**: Add one TOML at a time
4. **Verify assets**: Check asset paths in TOML match files
5. **Validate TOML**: Use online TOML validator

**Debug Tools**:
- **Console output**: Shows load errors
- **Mod validator**: `lovec "tools/mod_validator" my_mod` (if available)
- **GAME_API.toml**: Reference for valid fields

---

### Q: Can I test mods without restarting the game?

**A**: **No** - Must restart to reload mods (engine limitation).

**Workflow**:
1. Edit TOML file
2. Save file
3. Restart game (`lovec "engine"`)
4. Check console for errors
5. Test in-game

**Tip**: Keep game and text editor side-by-side for fast iteration.

---

## Related Content

**For detailed information, see**:
- **[MODDING_GUIDE.md](../../api/MODDING_GUIDE.md)** - Complete modding reference
- **[GAME_API.toml](../../api/GAME_API.toml)** - SOURCE OF TRUTH for data structures
- **[GAME_API_GUIDE.md](../../api/GAME_API_GUIDE.md)** - How to use the API
- **[mods/README.md](../../mods/README.md)** - Mod folder organization
- **[minimal_mod/](../../mods/minimal_mod/)** - Template to start from

---

## Quick Reference

**Mod Folder**: `mods/my_mod/`  
**Metadata**: `mod.toml` (id, name, version, dependencies)  
**Data Files**: `rules/[type]/[id].toml` (units, items, etc.)  
**Assets**: `assets/[type]/[id].png` (24x24 for units, 12x12 for items)  
**Testing**: `lovec "engine"` (restart required to reload)  
**Validation**: Errors shown in console on load  
**Schema**: `api/GAME_API.toml` (SOURCE OF TRUTH)  
**Load Order**: core → dependencies → user mods (alphabetical)  
**Conflicts**: Last loaded wins (later mods override earlier)

