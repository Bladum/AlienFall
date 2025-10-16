# 📑 Docs Reorganization: Specific Examples & File Changes

**Purpose:** Show exactly what files need to change, where they go, and what happens

---

## 🔧 EXAMPLE 1: docs/balancing/ → docs/balance/testing/

### Current Structure
```
docs/balance/
└── GAME_NUMBERS.md (276 lines - balance numeric data)

docs/balancing/
└── framework.md (148 lines - balance testing framework)
```

### Problem
- Two folders with similar names
- Unclear relationship
- User confusion about which to use

### Solution
```
docs/balance/                          ← Keep (balance-focused folder)
├── README.md                          ← CREATE: Explain structure
├── GAME_NUMBERS.md                    ← MOVE FROM current location
└── testing/                           ← CREATE: New subfolder
    └── framework.md                   ← MOVE FROM docs/balancing/

docs/balancing/                        ← DELETE: No longer needed
```

### Changes to Update
1. `docs/balance/README.md` - Explain folder structure
2. Cross-references in other docs pointing to `docs/balancing/framework.md`
   - Change to: `docs/balance/testing/framework.md`
3. Any internal links within files

### Time: 30 minutes

---

## 🔧 EXAMPLE 2: Create docs/technical/ and Organize Large Technical Files

### Current Structure (Problematic)
```
docs/
├── systems/
│   ├── TILESET_SYSTEM.md (825 lines, 12 TOML + 7 Lua)
│   ├── RESOLUTION_SYSTEM_ANALYSIS.md (656 lines, 7 Lua)
│   └── FIRE_SMOKE_MECHANICS.md (334 lines, 6 Lua)
├── rendering/
│   └── HEX_RENDERING_GUIDE.md (611 lines)
└── battlescape/
    ├── COMBAT_SYSTEMS_COMPLETE.md
    ├── 3D_BATTLESCAPE_ARCHITECTURE.md
    └── 3D_BATTLESCAPE_SUMMARY.md
```

### Problem
- Code blocks in design docs (violates standard)
- Large technical files scattered across folders
- Unclear which files are "design" vs "technical analysis"

### Solution

#### Step 1: Create Technical Folder
```
docs/technical/                        ← CREATE: New folder for analysis files
├── README.md                          ← CREATE: Explain this folder
├── TILESET_SYSTEM.md                 ← MOVE FROM docs/systems/
├── RESOLUTION_SYSTEM_ANALYSIS.md     ← MOVE FROM docs/systems/
├── FIRE_SMOKE_MECHANICS.md           ← MOVE FROM docs/systems/
├── HEX_RENDERING_GUIDE.md            ← MOVE FROM docs/rendering/
├── COMBAT_SYSTEMS_COMPLETE.md        ← MOVE FROM docs/battlescape/
├── 3D_BATTLESCAPE_ARCHITECTURE.md    ← MOVE FROM docs/battlescape/
└── GEOSCAPE_STRATEGIC_LAYER_*.md     ← MOVE FROM docs/geoscape/ (3 files)
```

#### Step 2: Clean Up Original Folders
```
docs/systems/                          ← KEEP (but now only contains appropriate design docs)
docs/rendering/                        ← KEEP (or remove if empty)
docs/battlescape/                      ← CLEANER (only design docs remain)
docs/geoscape/                         ← CLEANER (only design docs remain)
```

#### Step 3: Extract and Process Files
For each file (e.g., TILESET_SYSTEM.md):

**Original file (825 lines):**
```markdown
# Tileset System

> **Implementation**: ...

## 🏗️ Tileset Architecture

### Tileset Organization
- Tileset content organized by...

## 📋 File Format

```toml
[tileset]
name = "grassland"
tiles = 50
variants = 3
```

## 🔧 Technical Implementation

```lua
-- Lua code implementation...
local Tileset = {}
function Tileset.load(filename)
    -- Implementation...
end
```
```

**Split into TWO files:**

**File 1: docs/battlescape/maps.md (Design-focused, NO CODE)**
```markdown
# Battle Map System

> **Implementation**: `engine/battlescape/map_system/`
> **Technical Details**: See `docs/technical/TILESET_SYSTEM.md`
> **Tests**: `tests/battlescape/test_map_system.lua`

Tileset system for building tactical combat maps using predefined tile sets.

## 🏗️ Tileset Architecture

The tileset system organizes map elements into reusable components:
- **Base Tiles**: Grassland, urban, alien terrain types
- **Variants**: Multiple visual representations of the same tile type
- **Multi-Tile Modes**: Support for animations, damage states, and variants

## 📋 Tileset Types

### Grassland Tileset
- 50 unique tiles
- 3 visual variants per tile
- Suitable for outdoor missions
- Includes water and forest elements

### Urban Tileset
- 45 unique tiles
- 2 visual variants per tile  
- Suitable for city missions
- Includes building elements

### File Format

Tilesets are defined in configuration format specifying:
- Tileset name and ID
- Number of tiles and variants
- Variant definitions
- Multi-tile mode support

For technical implementation details, see `docs/technical/TILESET_SYSTEM.md`
```

**File 2: docs/technical/TILESET_SYSTEM.md (Technical-focused, WITH CODE)**
```markdown
# Tileset System - Technical Implementation

> **Design**: See `docs/battlescape/maps.md` for design overview
> **Implementation**: `engine/battlescape/tileset/`
> **Tests**: `tests/battlescape/test_tileset.lua`

Technical implementation guide for the tileset system.

## 📋 File Format

```toml
[tileset]
name = "grassland"
tiles = 50
variants = 3

[tile.0]
name = "grass"
category = "terrain"
walkable = true

[variant.grass_1]
frame = 0
animation = false

[variant.grass_2]
frame = 1
animation = false
```

## 🔧 Loading Implementation

```lua
local Tileset = {}

function Tileset.load(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil, "File not found: " .. filename
    end
    -- Implementation...
end
```
```

### Cross-Reference Updates
Find all files mentioning these files and update:
```
OLD: `docs/systems/TILESET_SYSTEM.md`
NEW: `docs/technical/TILESET_SYSTEM.md`

OLD: `docs/battlescape/maps.md` (may have been shorter)
NEW: See both design file AND technical file
```

### Time: 2-3 hours (for all 4 files)

---

## 🔧 EXAMPLE 3: Clarify docs/economy/ Confusing Structure

### Current Problem
```
docs/economy/
├── research.md (216 lines) - Design docs
├── research/ (folder)      - Purpose unclear?
├── manufacturing.md (264 lines) - Design docs
├── production/ (folder)    - Purpose unclear?
├── marketplace.md (140 lines) - Design docs
├── marketplace/ (folder)   - Purpose unclear?
├── funding.md
├── finance/ (folder)       - Duplicate of funding?
└── README.md              - Doesn't exist!
```

### Solution A: Consolidate (If subfolders are empty)
```
docs/economy/
├── README.md                       ← CREATE: Explain structure
├── research.md (design)
├── manufacturing.md (design)
├── marketplace.md (design)
├── funding.md
└── [DELETE: research/, production/, marketplace/, finance/ if empty]
```

### Solution B: Clarify Structure (If subfolders have content)
```
docs/economy/
├── README.md                       ← CREATE: Explain structure
├── overview.md                     ← Optional: System overview
├── research/
│   ├── README.md                  ← Explain: Research techs doc location
│   ├── [other research docs]
│   └── research.md                ← MOVE FROM: docs/economy/research.md
├── manufacturing/
│   ├── README.md
│   ├── [other manufacturing docs]
│   └── manufacturing.md           ← MOVE FROM: docs/economy/manufacturing.md
├── marketplace/
│   ├── README.md
│   ├── [other marketplace docs]
│   └── marketplace.md             ← MOVE FROM: docs/economy/marketplace.md
└── funding.md (or funding/)       ← RENAME/MOVE finance/ → funding/
```

### Create README
```markdown
# Economy System

> **Implementation**: `engine/economy/`
> **Tests**: `tests/economy/`

Economic systems managing technology, production, and trading.

## 📁 Structure

- **research/** - Technology research and advancement
- **manufacturing/** - Equipment and supply production
- **marketplace/** - Trading, buying, selling
- **funding.md** - Government funding and income

See individual folders for detailed design documentation.
```

### Time: 1-2 hours

---

## 🔧 EXAMPLE 4: Add README Files to Empty Folder Pairs

### docs/ai/ (Currently has 4 subfolders with no README)

#### Create: docs/ai/README.md
```markdown
# AI Systems

> **Implementation**: `engine/ai/`
> **Tests**: `tests/ai/`

Artificial intelligence systems for unit behavior, strategic decisions, and game difficulty.

## 📁 Structure

### Diplomacy
Political and faction AI for NPCs and relationships.
- Implementation: `engine/ai/diplomacy/`

### Pathfinding
Movement and navigation AI for units.
- Implementation: `engine/ai/pathfinding/`

### Strategic
High-level strategic AI for global decisions and long-term planning.
- Implementation: `engine/ai/strategic/`

### Tactical
Combat AI for unit behavior during missions.
- Implementation: `engine/ai/tactical/`

See individual folders for detailed documentation.
```

#### Create: docs/ai/diplomacy/README.md
```markdown
# Diplomacy AI

AI systems for diplomatic relations and faction behavior.

...content...
```

(Repeat for pathfinding/, strategic/, tactical/)

### Time: 1 hour

---

## 🔧 EXAMPLE 5: Standardize File Naming Conventions

### Current Inconsistencies
```
✅ Good (lowercase):
   docs/economy/research.md
   docs/geoscape/missions.md
   docs/ui/system.md

❌ Bad (UPPERCASE):
   docs/OVERVIEW.md
   docs/QUICK_NAVIGATION.md
   docs/geoscape/STRATEGIC_LAYER_DIAGRAMS.md
   docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md
   docs/systems/TILESET_SYSTEM.md
```

### Convention to Adopt
```
Root-level INDEX/NAVIGATION files (keep UPPERCASE):
  README.md, OVERVIEW.md, QUICK_NAVIGATION.md, API.md, GLOSSARY.md

Design documentation files (use lowercase):
  research.md, missions.md, combat.md, crafts.md, units.md

Technical analysis files (use UPPERCASE, goes in docs/technical/):
  TILESET_SYSTEM.md, RESOLUTION_SYSTEM_ANALYSIS.md, FIRE_SMOKE_MECHANICS.md
```

### Specific Renames

```
OLD: docs/battlescape/QUICK_REFERENCE.md
NEW: docs/battlescape/quick-reference.md (or keep as QUICK_REFERENCE.md for reference)

OLD: docs/geoscape/STRATEGIC_LAYER_DIAGRAMS.md
NEW: docs/technical/GEOSCAPE_STRATEGIC_LAYER_DIAGRAMS.md

OLD: docs/geoscape/STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md
NEW: docs/technical/GEOSCAPE_STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md

OLD: docs/geoscape/STRATEGIC_LAYER_QUICK_REFERENCE.md
NEW: docs/battlescape/QUICK_REFERENCE.md (consolidate?)

OLD: docs/battlescape/ECS_BATTLE_SYSTEM_API.md
NEW: docs/technical/ECS_BATTLE_SYSTEM_API.md

OLD: docs/rendering/HEX_RENDERING_GUIDE.md
NEW: docs/technical/HEX_RENDERING_GUIDE.md
```

### Time: 1 hour (renames) + 1 hour (update cross-references)

---

## 📝 EXAMPLE 6: Consolidate Navigation Files

### Current Situation
```
docs/README.md (80 lines)
├── Purpose: "What is this folder?"
├── Structure: Lists all folders
└── Standards: Document conventions

docs/OVERVIEW.md (186 lines)
├── Purpose: "What is this game?"
├── Game flow: Diagrams and concepts
└── Layers: Overview of systems

docs/QUICK_NAVIGATION.md (355 lines)
├── Purpose: "How do I find [X]?"
├── Index: All files with descriptions
└── Statistics: Documentation metrics

docs/API.md (1,811 lines)
├── Purpose: "Technical API reference"
├── Classes: All class documentation
└── Functions: All function signatures
```

### Problem
- New users don't know which to read first
- Overlap between README and OVERVIEW
- QUICK_NAVIGATION too long but useful as index

### Solution: Streamline

**Keep as-is (clear purpose):**
```
✅ docs/README.md - Folder intro and structure
✅ docs/OVERVIEW.md - Game design overview
✅ docs/API.md - Technical reference
```

**Consolidate:**
```
QUICK_NAVIGATION.md (355 lines) → Too long as separate file
- Move essential parts to README.md
- Keep as extended reference (or archive in docs/references/)
```

**Result:**
```
docs/
├── README.md (updated, 150-200 lines)
│   ├── What is docs/? (copied from current README)
│   ├── Structure: All folders (copied from current README)
│   ├── How to Use: Quick navigation guide
│   ├── Document Standards
│   └── Quick Links: [OVERVIEW](OVERVIEW.md) | [API](API.md)
│
├── OVERVIEW.md (unchanged, 186 lines)
│   └── Game design concepts and flow
│
├── API.md (unchanged, 1,811 lines)
│   └── Technical API reference
│
└── docs/references/QUICK_NAVIGATION_EXTENDED.md (optional archive)
    └── Detailed index for advanced users
```

### Time: 1-2 hours

---

## 🎯 SUMMARY: Files Affected by Each Change

### Change 1: Consolidate balance/balancing/
```
Files to rename:
  docs/balancing/ → DELETE
  docs/balance/testing/ → CREATE
  docs/balancing/framework.md → docs/balance/testing/framework.md

Files to update (cross-references):
  docs/balance/README.md (create)
  docs/QUICK_NAVIGATION.md
  docs/README.md
  Any other docs linking to balance/balancing
```

### Change 2: Create docs/technical/ and Move Files
```
Files to create:
  docs/technical/README.md

Files to move:
  docs/systems/TILESET_SYSTEM.md
  docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md
  docs/systems/FIRE_SMOKE_MECHANICS.md
  docs/rendering/HEX_RENDERING_GUIDE.md
  docs/battlescape/COMBAT_SYSTEMS_COMPLETE.md
  docs/battlescape/3D_BATTLESCAPE_ARCHITECTURE.md
  docs/battlescape/3D_BATTLESCAPE_SUMMARY.md
  docs/geoscape/STRATEGIC_LAYER_DIAGRAMS.md
  docs/geoscape/STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md (and others)

Files to update (cross-references):
  docs/QUICK_NAVIGATION.md
  docs/README.md
  All design docs linking to moved files

Files to extract code from (create split docs):
  docs/systems/TILESET_SYSTEM.md → Split into design + technical
  docs/systems/FIRE_SMOKE_MECHANICS.md → Extract code
  docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md → Extract code
  docs/testing/TESTING.md → Extract code examples
```

### Change 3: Add README to All Folders
```
Files to create:
  docs/ai/README.md
  docs/geoscape/README.md (update if exists)
  docs/battlescape/README.md (update if exists)
  docs/economy/README.md
  docs/content/README.md
  docs/politics/README.md
  docs/technical/README.md (for new folder)
  docs/core/README.md (update if exists)
  docs/systems/README.md
  [All empty folder pairs]
```

### Change 4: Standardize Naming
```
Files to rename:
  [Multiple files with UPPERCASE to follow convention]

Files to update (cross-references):
  docs/QUICK_NAVIGATION.md
  docs/API.md
  docs/README.md
  All cross-reference links throughout docs/
```

---

## ✅ Validation Checklist

After each change, verify:

- [ ] All cross-references still work (check relative paths)
- [ ] New README files created and formatted correctly
- [ ] No code remains in design docs (only text descriptions)
- [ ] Folder structures match documentation
- [ ] Navigation files updated with new locations
- [ ] No broken links in markdown
- [ ] File names follow convention
- [ ] All moved files have updated "Implementation" and "Tests" links

---

**Ready to start?** See `tasks/TASK_TEMPLATE.md` to create implementation tasks for each phase.
