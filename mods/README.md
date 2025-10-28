# Mods - Game Content & Customization

**Purpose:** Mod system for game content (units, items, missions, etc.) in TOML format  
**Audience:** Modders, content creators, AI agents, designers  
**Status:** Active development  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Quick Start](#quick-start)
- [Content Types](#content-types)
- [Relations to Other Modules](#relations-to-other-modules)
- [How to Use](#how-to-use)
- [AI Agent Instructions](#ai-agent-instructions)
- [Good Practices](#good-practices)
- [Quick Reference](#quick-reference)

---

## Overview

The `mods/` folder contains **all game content** as data-driven TOML files and assets. Mods are the primary way to add/modify units, items, missions, and other content without changing engine code.

**Core Purpose:**
- Store all game content in TOML format
- Provide modding system for customization
- Separate content from code (data-driven)
- Enable easy content creation
- Support mod conflicts and overrides

---

## Folder Structure

```
mods/
├── README.md                          ← This file
│
├── core/                              ← Base Game Content (ALWAYS LOADED)
│   ├── mod.toml                      ← Core mod metadata
│   ├── rules/                        ← TOML configurations
│   │   ├── units/                    ← soldiers.toml, aliens.toml
│   │   ├── items/                    ← weapons.toml, armor.toml
│   │   ├── crafts/                   ← xcom_crafts.toml, ufos.toml
│   │   ├── facilities/               ← base_facilities.toml
│   │   ├── missions/                 ← terror.toml, ufo_landing.toml
│   │   ├── research/                 ← weapons.toml, aliens.toml
│   │   └── [other types]
│   └── assets/                       ← Core assets
│       ├── units/                    ← 24x24 PNG sprites
│       ├── items/                    ← 12x12 or 24x24 PNG icons
│       ├── sounds/                   ← OGG audio
│       └── music/                    ← OGG music
│
├── minimal_mod/                       ← Mod Template (COPY THIS)
│   ├── mod.toml                      ← Edit: id, name, author
│   ├── rules/example.toml            ← Example TOML
│   └── assets/example.png            ← Example asset
│
├── examples/                          ← Example Mods
│   ├── custom_faction/
│   ├── weapon_pack/
│   └── [other examples]
│
└── new/                              ← New Mod Development
    └── mapblocks/
```

---

## Key Features

- **Data-Driven:** All content in TOML, no code changes
- **Core Mod:** Base game content in `core/`
- **Template:** Copy `minimal_mod/` to start
- **Validation:** Automatic TOML schema checking
- **Assets:** Organized sprites, sounds, music
- **Conflicts:** Later mods override earlier ones

---

## Quick Start

```bash
# 1. Copy template
cd mods/
cp -r minimal_mod/ my_mod/

# 2. Edit mod.toml
[mod]
id = "my_mod"              # Change this
name = "My Mod"            # Change this
author = "Your Name"       # Change this

# 3. Create TOML in rules/
touch rules/units/my_units.toml

# 4. Add assets
cp my_unit.png assets/units/

# 5. Test
cd ../..
lovec "engine"
```

---

## Content Types

| Type | Location | Schema | Assets |
|------|----------|--------|--------|
| **Units** | `rules/units/*.toml` | [api/UNITS.md](../api/UNITS.md) | 24x24 PNG |
| **Items** | `rules/items/*.toml` | [api/ITEMS.md](../api/ITEMS.md) | 12x12/24x24 PNG |
| **Weapons** | `rules/items/weapons.toml` | [api/WEAPONS_AND_ARMOR.md](../api/WEAPONS_AND_ARMOR.md) | 12x12/24x24 PNG |
| **Crafts** | `rules/crafts/*.toml` | [api/CRAFTS.md](../api/CRAFTS.md) | 24x24 PNG |
| **Facilities** | `rules/facilities/*.toml` | [api/FACILITIES.md](../api/FACILITIES.md) | 24x24 PNG |
| **Missions** | `rules/missions/*.toml` | [api/MISSIONS.md](../api/MISSIONS.md) | - |
| **Research** | `rules/research/*.toml` | [api/RESEARCH_AND_MANUFACTURING.md](../api/RESEARCH_AND_MANUFACTURING.md) | - |

**TOML Example:**
```toml
[unit.elite_soldier]
id = "elite_soldier"
name = "Elite Soldier"
type = "soldier"

[unit.elite_soldier.stats]
health = 120
time_units = 60
strength = 50

[unit.elite_soldier.sprite]
path = "units/elite_soldier.png"
width = 24
height = 24
```

---

## Relations to Other Modules

```
api/GAME_API.toml → mods/*/rules/**/*.toml → engine/mods/mod_loader.lua
    ↓                      ↓                          ↓
  Schema              Content                    Loaded
```

| Module | Relationship |
|--------|--------------|
| **api/GAME_API.toml** | Schema validates TOML |
| **design/** | Design defines content |
| **engine/** | Engine loads content |
| **logs/** | Errors logged |
| **docs/prompts/** | Templates guide creation |

---

## How to Use

### For Modders

1. **Copy template:** `cp -r minimal_mod/ my_mod/`
2. **Edit mod.toml:** Set id, name, author, dependencies
3. **Create TOML:** Follow `api/GAME_API.toml` schema
4. **Add assets:** 24x24 PNG for units, 12x12/24x24 for items
5. **Test:** `lovec "engine"` and check console

**Using Prompts:**
```bash
# Use structured templates
cat docs/prompts/add_unit.prompt.md
cat docs/prompts/add_item.prompt.md
cat docs/prompts/add_mission.prompt.md
```

### For AI Agents

See [AI Agent Instructions](#ai-agent-instructions) below.

---

## AI Agent Instructions

### Content Creation Workflow

```
User asks to add unit/item/mission
    ↓
1. Select prompt: docs/prompts/add_[type].prompt.md
    ↓
2. Read design: design/mechanics/[System].md
    ↓
3. Check schema: api/GAME_API.toml
    ↓
4. Create TOML: mods/core/rules/[type]/[name].toml
    ↓
5. Create assets: mods/core/assets/[type]/[name].png
    ↓
6. Test: lovec "engine"
    ↓
7. Check logs: logs/mods/mod_errors_*.log
```

### Reading Mod Errors

```
Log: logs/mods/mod_errors_*.log

[ERROR] Mod: my_mod
File: rules/units/soldier.toml
Error: Missing required field 'health'

AI Action:
1. Open file
2. Add missing field: health = 100
3. Test again
```

---

## Good Practices

### ✅ TOML
- Follow `api/GAME_API.toml` schema exactly
- Use descriptive IDs (prefix with mod name)
- Document with comments
- Use snake_case naming

### ✅ Assets
- Use correct sizes (24x24 units, 12x12/24x24 items)
- Transparent backgrounds
- Normalize audio volume
- Optimize file sizes

---

## Quick Reference

### Essential Files

| File | Purpose |
|------|---------|
| `core/mod.toml` | Core mod metadata |
| `minimal_mod/` | Mod template |
| `api/GAME_API.toml` | TOML schema |
| `docs/prompts/` | Content templates |

### Content Prompts

| Prompt | Output Location |
|--------|-----------------|
| add_unit.prompt.md | mods/*/rules/units/ |
| add_item.prompt.md | mods/*/rules/items/ |
| add_facility.prompt.md | mods/*/rules/facilities/ |
| add_mission.prompt.md | mods/*/rules/missions/ |

### Quick Commands

```bash
# Create mod
cp -r mods/minimal_mod/ mods/my_mod/

# Test
lovec "engine"

# Check errors
cat logs/mods/mod_errors_*.log
```

### Related Documentation

- **API:** [api/README.md](../api/README.md) - TOML schemas
- **Design:** [design/README.md](../design/README.md) - Content requirements
- **Engine:** [engine/README.md](../engine/README.md) - Mod loading
- **Docs:** [docs/prompts/](../docs/prompts/) - Content templates
- **Guide:** [api/MODDING_GUIDE.md](../api/MODDING_GUIDE.md) - Complete guide

---

**Last Updated:** 2025-10-28  
**Questions:** See [api/MODDING_GUIDE.md](../api/MODDING_GUIDE.md) or Discord

