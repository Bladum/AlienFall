# Welcome to AlienFall

**A turn-based strategy game inspired by X-COM, built with Love2D and designed for total conversion modding**

AlienFall is a strategic and tactical game where you manage a covert organization from startup to multiplanetary power. Lead your team through global operations, squad-based tactical combat, base management, and technology research in an open-ended sandbox experience.

[Join our Discord](https://discord.gg/)

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/0663bafd-a56d-40b3-a937-f748159204a3" />

---

## 📋 Table of Contents

- [What is AlienFall?](#what-is-alienfall)
- [Core Design Principles](#core-design-principles)
- [Game Layers Explained](#game-layers-explained)
- [What AlienFall IS](#what-alienfall-is)
- [What AlienFall IS NOT](#what-alienfall-is-not)
- [For Players](#for-players)
- [For Modders](#for-modders)
- [For Developers](#for-developers)
- [Project Navigation](#project-navigation)
- [Getting Started](#getting-started)

---

## What is AlienFall?

AlienFall is an **open-source, moddable turn-based strategy game** combining three layers of gameplay:

🌍 **Geoscape** - Manage global operations, detect threats, deploy your forces  
🏗️ **Basescape** - Build facilities, research technology, train soldiers, manufacture equipment  
⚔️ **Battlescape** - Command squad-level tactical combat on procedurally generated hex-based maps

**The Name:** "Alien" represents any outsider or opponent (not just extraterrestrials), "Fall" represents defeating them. Like a persistent tick, you start small but ultimately bring down larger adversaries.

**The Goal:** There is no fixed ending. Build your organization, survive threats, expand across planets, and shape your own story through procedurally generated campaigns and emergent gameplay.

---

## Core Design Principles

### 🎮 Game Design Philosophy

**Inspired by, Not a Clone of X-COM**
- Takes the best ideas from X-COM: UFO Defense and OpenXcom
- Adds modern mechanics and streamlined systems
- Not constrained by recreating the original exactly
- Compatible with X-Com Files mod concepts in spirit

**Open-Ended Sandbox**
- No fixed victory or defeat conditions
- Procedurally generated campaigns provide endless variety
- Your decisions shape the narrative
- Multiple paths to success
- Play as long as you want

**Moddability First**
- **Total conversion support** - Create entirely new games
- **Data-driven design** - All content in TOML files (no code changes needed)
- **Simple modding** - Text files, not scripting languages
- **Template system** - Copy `minimal_mod` and start creating
- **Validation tools** - Automatic TOML schema checking

### 🔧 Technical Philosophy

**Built with Love2D & Lua**
- Lightweight 2D game framework
- Fast iteration and development
- Cross-platform (Windows, Linux, macOS)
- Easy to understand and modify
- ~22,500 lines of clean Lua code

**AI-Assisted Development**
- Developed using AI agentic coding as a practical experiment
- Documentation-first approach
- AI-readable and human-readable formats
- Continuous testing (2,493+ automated tests)

**Visual Style**
- **12×12 pixel art** upscaled to **24×24** for crisp, symbolic graphics
- Functional UI over flashy effects
- Clear information hierarchy
- Minimal screen nesting
- Notification system instead of popup overload

---

## Game Layers Explained

AlienFall consists of three interconnected game layers, each with distinct gameplay:

### 🌍 Geoscape - Strategic World Layer

**What You Do:**
- Monitor a **hex-based world map** (Earth, Moon, Mars, and more)
- Detect enemy operations using **radar networks**
- Deploy interceptor craft to engage UFOs
- Send squads to mission sites
- Manage **multiple bases** across planets
- Monitor **country funding** and regional panic levels

**Key Mechanics:**
- **Turn-Based Time:** 1 turn = 1 day
- **Detection System:** Bases and craft have detection range/power; enemy operations have cover that degrades over time
- **Mission Types:** Alien bases (permanent), Sites (temporary), UFOs (mobile)
- **Planetary Scale:** Earth with detailed regions, plus Moon and Mars environments
- **Dynamic Campaigns:** Monthly mission generation based on alien activity

**Inspired By:** X-COM's Geoscape, but with tile-based mechanics and multiple planets

---

### 🏗️ Basescape - Base Management Layer

**What You Do:**
- Build and expand bases (starting 4×4, up to 6×6 hex grid)
- Construct **facilities** (labs, workshops, hangars, living quarters)
- Research **technology** to unlock new capabilities
- Manufacture **items, weapons, and craft**
- Hire and train **soldiers, scientists, and engineers**
- Manage **finances** (monthly invoicing, variable costs)

**Key Mechanics:**
- **Capacity-Based Systems:** Labs and workshops use capacity points, not individual scientists
- **Pay-for-Results:** Pay for completed research and manufacturing, not monthly salaries
- **Flexible Layout:** Generic facilities, no fixed hangar locations
- **Resource Management:** Balance maintenance costs vs operational expenses
- **Tech Tree:** Unlock items, craft, and facilities through research

**Inspired By:** X-COM base management, but streamlined and less micromanagement

---

### ⚔️ Battlescape - Tactical Combat Layer

**What You Do:**
- Command **squad-based tactical combat** (4-8 soldiers)
- Fight on **procedurally generated hex maps** (15×15 tiles per block)
- Use **4 Action Points per unit** for movement and attacks
- Employ **line-of-sight mechanics** and cover system
- Complete varied **mission objectives** (rescue, elimination, defense, retrieval)
- **Loot equipment** and capture enemies

**Key Mechanics:**
- **Hex-Based Movement:** Flat-top hexagons with 6 directions (E, SE, SW, W, NW, NE)
- **Turn-Based Combat:** Player turn → Enemy turn
- **Action System:** 4 AP per unit, 1-2 AP for actions
- **Morale & Sanity:** Battle-limited morale affects AP; persistent sanity affects long-term performance
- **Simplified Inventory:** Armor + Primary weapon + 3 secondary slots
- **Promotion System:** Gain experience, level up (max 5 levels), select traits/perks
- **Permadeath:** Soldiers can die permanently or suffer lasting injuries

**Key Differences from X-COM:**
- Hex grid instead of square tiles
- 4 Action Points instead of Time Units
- Speed stat determines movement distance
- Simplified day/night (binary states)
- Battle-limited ammunition (no micromanagement)
- Height-based cover and visibility

**Inspired By:** X-COM tactical combat, but with modern hex-based mechanics

---

## What AlienFall IS

✅ **A Strategic Game**
- Global operational management
- Resource allocation and prioritization
- Long-term planning and tech progression
- Multiple bases across planets
- Dynamic threat response

✅ **A Tactical Game**
- Squad-level turn-based combat
- Terrain-based tactics and cover
- Line-of-sight and fog of war
- Varied mission objectives
- Permadeath and consequences

✅ **A Sandbox Game**
- No fixed win/loss conditions
- Open-ended gameplay
- Emergent storytelling
- Multiple paths to success
- Play your way

✅ **A Simulation Game**
- Detailed economic systems
- Realistic logistics (ammo, fuel, repairs)
- Soldier development and psychology
- Research and manufacturing pipelines
- Country relations and funding

✅ **Heavily Moddable**
- Total conversion support
- All content in TOML files
- No programming required
- Template system for quick starts
- Validation tools included

✅ **Open Source & Free**
- MIT License (likely)
- Non-commercial project
- Community-driven development
- Full access to source code
- AI-assisted development experiment

---

## What AlienFall IS NOT

❌ **Not an X-COM Clone**
- Takes inspiration but makes own decisions
- Different mechanics in many areas
- Not trying to recreate OpenXcom
- Not limited by original game design

❌ **Not Bound to Original X-COM Lore**
- Uses "alien" generically (any opponent)
- Flexible narrative framework
- Support for multiple settings
- Total conversion friendly

❌ **Not Focused on Small Mods**
- Designed for **total conversions**
- Not optimized for tiny tweaks
- Encourages complete overhauls
- Think new games, not balance patches

❌ **Not Using Scripting Languages**
- No Lua/Python modding scripts (initially)
- Pure data-driven (TOML files)
- Simpler for non-programmers
- May add scripting later if needed

❌ **Not Real-Time**
- Fully turn-based on all layers
- No real-time pressure
- Think and plan your moves
- Geoscape: 1 turn = 1 day

❌ **Not Multiplayer** (currently)
- Single-player focused
- May add later if there's demand
- AI opponent, not human

❌ **Not 3D**
- 2D top-down perspective
- Pixel art aesthetic
- Consistent across all layers
- Optional 3D planned for far future

---

## For Players

### 🎮 How to Play

**System Requirements:**
- Windows, Linux, or macOS
- Love2D 11.x installed
- ~500MB disk space
- Any computer from the last 10 years

**Quick Start:**
```bash
# Windows
lovec "engine"
# or
run_xcom.bat

# Linux/Mac
love engine/
```

**What to Expect:**
- **Geoscape:** Manage global operations, detect threats, deploy forces
- **Basescape:** Build bases, research tech, manufacture gear, train soldiers
- **Battlescape:** Command tactical squad combat on hex maps

**Game Progression:**
1. Start with small base and basic equipment
2. Detect and respond to enemy operations
3. Complete missions to gain resources and intel
4. Research technology to unlock better gear
5. Expand to multiple bases and planets
6. Face escalating threats and specialized enemies
7. Shape your own story through decisions

**Tips:**
- **Permadeath is real** - Don't get too attached to soldiers
- **Research is key** - Unlocks better equipment and facilities
- **Economy matters** - Balance costs vs income
- **Scout carefully** - Use line-of-sight to avoid ambushes
- **Use cover** - Height and terrain affect accuracy
- **Plan long-term** - Some research chains are lengthy

### 📚 Player Documentation

- **Game Mechanics:** [design/README.md](design/README.md) - Complete game systems
- **Tutorial:** (Coming soon)
- **Strategy Guide:** (Community-driven)

---

## For Modders

### 🔧 Creating Mods

AlienFall is designed for **total conversion modding** - create entirely new games using the engine!

**Quick Start:**
```bash
# 1. Copy the template
cd mods/
cp -r minimal_mod/ my_awesome_mod/

# 2. Edit mod.toml
# Set id, name, version, author, description

# 3. Create content in rules/
# Add TOML files for units, items, missions, etc.

# 4. Add assets to assets/
# Create 24x24 PNG sprites, OGG audio

# 5. Test your mod
lovec "engine"
```

**What You Can Mod:**

| Content Type | File Location | Schema Reference |
|--------------|---------------|------------------|
| **Units** | `rules/units/*.toml` | [api/UNITS.md](api/UNITS.md) |
| **Items** | `rules/items/*.toml` | [api/ITEMS.md](api/ITEMS.md) |
| **Weapons** | `rules/items/weapons.toml` | [api/WEAPONS_AND_ARMOR.md](api/WEAPONS_AND_ARMOR.md) |
| **Crafts** | `rules/crafts/*.toml` | [api/CRAFTS.md](api/CRAFTS.md) |
| **Facilities** | `rules/facilities/*.toml` | [api/FACILITIES.md](api/FACILITIES.md) |
| **Missions** | `rules/missions/*.toml` | [api/MISSIONS.md](api/MISSIONS.md) |
| **Research** | `rules/research/*.toml` | [api/RESEARCH_AND_MANUFACTURING.md](api/RESEARCH_AND_MANUFACTURING.md) |
| **Countries** | `rules/countries/*.toml` | [api/COUNTRIES.md](api/COUNTRIES.md) |
| **Factions** | `rules/factions/*.toml` | [api/POLITICS.md](api/POLITICS.md) |

**TOML Format Example:**
```toml
# my_mod/rules/units/my_unit.toml

[unit.elite_soldier]
id = "elite_soldier"
name = "Elite Soldier"
type = "soldier"
faction = "xcom"

[unit.elite_soldier.stats]
health = 120
time_units = 60
strength = 50
firing_accuracy = 75
throwing_accuracy = 65

[unit.elite_soldier.sprite]
path = "units/elite_soldier.png"
width = 24
height = 24
```

**Asset Standards:**
- **Unit sprites:** 24×24 PNG, transparent background
- **Item icons:** 12×12 or 24×24 PNG, transparent background
- **Audio:** OGG format, normalized volume
- **Naming:** lowercase_with_underscores.png

**Validation:**
Your TOML is automatically validated against the master schema ([api/GAME_API.toml](api/GAME_API.toml)). Check console output or `logs/mods/` for errors.

**Content Creation Helpers:**
Use structured prompts to create content:
- [docs/prompts/add_unit.prompt.md](docs/prompts/add_unit.prompt.md)
- [docs/prompts/add_item.prompt.md](docs/prompts/add_item.prompt.md)
- [docs/prompts/add_mission.prompt.md](docs/prompts/add_mission.prompt.md)
- ...and 24 more prompts!

### 📚 Modder Documentation

| Resource | Purpose |
|----------|---------|
| [mods/README.md](mods/README.md) | Complete modding guide |
| [api/MODDING_GUIDE.md](api/MODDING_GUIDE.md) | Detailed modding tutorial |
| [api/GAME_API.toml](api/GAME_API.toml) | Master TOML schema (source of truth) |
| [mods/minimal_mod/](mods/minimal_mod/) | Template to copy |
| [mods/examples/](mods/examples/) | Example mods to learn from |
| [docs/prompts/](docs/prompts/) | 27 content creation templates |

**Community:**
- Share mods on Discord
- Get help from other modders
- Contribute examples
- Request features

---

## For Developers

### 💻 Contributing to AlienFall

AlienFall is open source and welcomes contributions!

**Tech Stack:**
- **Engine:** Love2D 11.x (Lua game framework)
- **Language:** Lua 5.1
- **Content Format:** TOML (data files)
- **Graphics:** 12×12 pixel art (upscaled to 24×24)
- **Testing:** 2,493+ automated tests using custom framework
- **Documentation:** Markdown (AI-readable and human-readable)

**Development Workflow:**
```
Design → API → Architecture → Engine → Mods → Tests
   ↓       ↓         ↓          ↓       ↓       ↓
 What    Interface  Structure  Code   Content  Verify
```

**Quick Start:**
```bash
# 1. Clone repository
git clone https://github.com/yourusername/alienfall.git
cd alienfall

# 2. Install Love2D
# Download from https://love2d.org

# 3. Run the game
lovec "engine"

# 4. Run tests
lovec "tests2/runners" run_all

# 5. Create feature branch
git checkout -b feature/my-feature

# 6. Make changes and test
# Follow workflow: design → api → architecture → engine → mods → tests

# 7. Commit and push
git add .
git commit -m "feat(system): description"
git push origin feature/my-feature

# 8. Create Pull Request on GitHub
```

**Code Standards:**
- **Naming:** snake_case (files), PascalCase (modules), camelCase (functions)
- **Error Handling:** Use `pcall` for safety
- **Testing:** Write tests alongside code (tests2/)
- **Documentation:** Update docs/ when changing systems
- **Style:** Follow [docs/instructions/🛠️ Love2D & Lua.instructions.md](docs/instructions/🛠️%20Love2D%20&%20Lua.instructions.md)

### 📚 Developer Documentation

| Resource | Purpose |
|----------|---------|
| [engine/README.md](engine/README.md) | Complete engine structure |
| [tests2/README.md](tests2/README.md) | Testing framework guide |
| [docs/instructions/](docs/instructions/) | 24 development best practices |
| [architecture/README.md](architecture/README.md) | System architecture diagrams |
| [api/README.md](api/README.md) | API contracts and schemas |
| [design/README.md](design/README.md) | Game design specifications |

**AI-Assisted Development:**
This project uses AI agents for development. See [docs/chatmodes/](docs/chatmodes/) for 23 specialized AI personas and [docs/system/](docs/system/) for 9 universal patterns.

---

## Project Navigation

### 📁 Folder Overview

```
alienfall/
│
├── 🎮 Game Content & Design
│   ├── design/          → Game mechanics, balance, design specs (25+ docs)
│   ├── mods/            → Game content in TOML + assets (core mod + templates)
│   └── lore/            → Story, narrative events, world-building
│
├── 🔧 Technical Implementation
│   ├── engine/          → Love2D/Lua game engine (~22,500 lines, 117 files)
│   ├── api/             → System contracts & TOML schemas (36 APIs)
│   ├── architecture/    → Mermaid diagrams, state machines (17 docs)
│   └── tests2/          → Test suite (2,493+ tests, <1s runtime)
│
├── 📚 Documentation & Guides
│   ├── docs/            → Development guides (87 files)
│   │   ├── chatmodes/   → 23 AI personas
│   │   ├── instructions/→ 24 best practices
│   │   ├── prompts/     → 27 content templates
│   │   └── system/      → 9 universal patterns
│   └── README.md        → This file (project overview)
│
├── 🛠️ Development Tools
│   ├── tools/           → Validators, generators, editors (9 tools)
│   ├── logs/            → Runtime logs & analytics (5 categories)
│   ├── tasks/           → Task management (TODO/DONE)
│   └── system/          → Project-wide patterns
│
└── 🚀 Quick Start
    ├── run_xcom.bat     → Windows launcher
    └── run/             → Automation scripts
```

### 🎯 Quick Links by Role

**Players:**
- [How to Play](#for-players) - Getting started
- [design/mechanics/](design/mechanics/) - Game systems explained
- Run game: `lovec "engine"` or `run_xcom.bat`

**Modders:**
- [Modding Guide](#for-modders) - Create content
- [mods/README.md](mods/README.md) - Complete modding guide
- [api/MODDING_GUIDE.md](api/MODDING_GUIDE.md) - Detailed tutorial
- [mods/minimal_mod/](mods/minimal_mod/) - Template to copy
- [docs/prompts/](docs/prompts/) - 27 content creation templates

**Developers:**
- [Contributing Guide](#for-developers) - Join development
- [engine/README.md](engine/README.md) - Engine structure
- [tests2/README.md](tests2/README.md) - Testing framework
- [docs/instructions/](docs/instructions/) - 24 best practices
- [architecture/README.md](architecture/README.md) - System diagrams

**Designers:**
- [design/README.md](design/README.md) - Design workflow
- [design/DESIGN_TEMPLATE.md](design/DESIGN_TEMPLATE.md) - Template for new designs
- [design/GLOSSARY.md](design/GLOSSARY.md) - Game terminology

### 📖 Essential Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| **README.md** (this file) | Project overview, getting started | Everyone |
| [design/README.md](design/README.md) | Game design specifications | Players, Designers, Modders |
| [mods/README.md](mods/README.md) | Modding system guide | Modders |
| [engine/README.md](engine/README.md) | Engine implementation | Developers |
| [api/README.md](api/README.md) | System APIs & schemas | Developers, Modders |
| [docs/README.md](docs/README.md) | Development guides hub | Developers |
| [architecture/README.md](architecture/README.md) | System architecture | Developers, Architects |
| [tests2/README.md](tests2/README.md) | Testing framework | Developers, QA |

---

## Getting Started

### 🎮 Players: Run the Game

**Windows:**
```bash
lovec "engine"
# or double-click run_xcom.bat
```

**Linux/Mac:**
```bash
love engine/
```

**System Requirements:**
- Love2D 11.x (download from https://love2d.org)
- ~500MB disk space
- Any modern computer

### 🔧 Modders: Create Content

```bash
# 1. Copy template
cd mods/
cp -r minimal_mod/ my_mod/

# 2. Edit mod.toml (set name, id, author)

# 3. Create TOML content in rules/
# Follow examples in mods/core/rules/

# 4. Add sprites to assets/
# 24x24 PNG for units, 12x12/24x24 for items

# 5. Test
lovec "engine"
```

**Learn More:** [mods/README.md](mods/README.md) | [api/MODDING_GUIDE.md](api/MODDING_GUIDE.md)

### 💻 Developers: Contribute Code

```bash
# 1. Clone repo
git clone https://github.com/yourusername/alienfall.git

# 2. Install Love2D from https://love2d.org

# 3. Run game
lovec "engine"

# 4. Run tests
lovec "tests2/runners" run_all

# 5. Read developer guides
cat docs/instructions/START_HERE.md
```

**Learn More:** [engine/README.md](engine/README.md) | [docs/instructions/](docs/instructions/)

---

## Project Status

**Current Status:** Active Development  
**Version:** 0.1.0 (Alpha)  
**License:** MIT (likely)  
**Platform:** Windows, Linux, macOS (via Love2D)

**What Works:**
- ✅ Core engine architecture
- ✅ Mod loading system
- ✅ TOML content validation
- ✅ Basic geoscape (world map)
- ✅ Basic basescape (base management)
- ✅ Basic battlescape (tactical combat)
- ✅ Hex-based movement and combat
- ✅ 2,493+ automated tests

**In Progress:**
- 🚧 Complete game systems implementation
- 🚧 Content creation (units, items, missions)
- 🚧 UI/UX polish
- 🚧 Balance tuning
- 🚧 Documentation expansion

**Planned:**
- 📝 Campaign generation system
- 📝 Advanced AI behaviors
- 📝 More mission types
- 📝 Multiple planets (Moon, Mars)
- 📝 Tutorial system
- 📝 Save/Load functionality

---

## Community & Support

**Discord:** [Join our Discord](https://discord.gg/) (TBD)  
**GitHub:** [Project Repository](https://github.com/yourusername/alienfall)  
**Issues:** [Report bugs or request features](https://github.com/yourusername/alienfall/issues)  

**How to Help:**
- 🎮 **Play and test** - Report bugs and suggestions
- 🔧 **Create mods** - Share your content
- 💻 **Contribute code** - Submit pull requests
- 📚 **Write docs** - Improve documentation
- 🎨 **Create art** - Contribute sprites and assets
- 🗣️ **Spread the word** - Tell others about the project

---

## Credits & Inspiration

**Inspired By:**
- **X-COM: UFO Defense** (1994) - The original masterpiece
- **OpenXcom** - Open source X-COM engine
- **X-Com Files** - Comprehensive OpenXcom mod
- **XCOM: Enemy Unknown** (2012) - Modern reimagining

**Built With:**
- **Love2D** - 2D game framework
- **Lua** - Programming language
- **TOML** - Configuration format
- **AI-Assisted Development** - Practical experiment in agentic coding

**Special Thanks:**
- X-COM community for decades of inspiration
- Love2D community for excellent framework and support
- OpenXcom team for keeping X-COM alive
- Contributors and testers

---

## License

**License:** MIT (likely) - Free and open source  
**Non-Commercial:** This is a hobby project, not for profit  
**Community-Driven:** Contributions welcome from everyone

**Note:** This is an independent fan project, not affiliated with or endorsed by Firaxis Games, 2K Games, or MicroProse.

---

**Start Playing:** `lovec "engine"` or `run_xcom.bat`  
**Start Modding:** [mods/README.md](mods/README.md)  
**Start Developing:** [docs/instructions/START_HERE.md](docs/instructions/START_HERE.md)

**Welcome to AlienFall - Your covert organization awaits!** 🛸

