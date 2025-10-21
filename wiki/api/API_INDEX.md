# AlienFall API Documentation Index

**Version**: 1.0.0  
**Date**: October 21, 2025  
**Status**: Phase 5 Step 3 In Progress  
**Coverage**: 118 entity types, 14 content categories, 50+ TOML examples

---

## Navigation Quick Links

### Getting Started
- **New to modding?** → Start with [Mod Developer Guide](#mod-developer-guide)
- **Want to edit weapons?** → See [Weapons & Armor API](#weapons--armor-api)
- **Need to create units?** → See [Units & Classes API](#units--classes-api)
- **Building facilities?** → See [Facilities API](#facilities-api)

### API Reference Files
1. [Schema Reference](#schema-reference) - ✅ Complete entity type documentation
2. [Weapons & Armor](#weapons--armor-api) - ✅ Weapons, armor, and equipment
3. [Units & Classes](#units--classes-api) - ✅ Unit classes and unit types
4. [Facilities](#facilities-api) - ✅ Base facilities and structures
5. [Research & Manufacturing](#research--manufacturing-api) - ✅ Technology and crafting
6. [Missions](#missions-api) - ✅ Mission definitions and objectives
7. [Economy & Items](#economy--items-api) - ✅ Marketplace, resources, items
8. [Mod Developer Guide](#mod-developer-guide) - ⏳ Complete modding tutorial

---

## Schema Reference

**File**: `wiki/api/API_SCHEMA_REFERENCE.md`

Complete schema documentation for all entity types across 14 content categories.

### Coverage

- **Weapons & Armour**: Weapon, Armour, Ammo
- **Units & Classes**: UnitClass, Unit, Trait
- **Facilities**: Facility, Adjacency Bonus
- **Research & Manufacturing**: ResearchProject, Recipe
- **Items & Resources**: Resource, Equipment
- **Missions**: Mission, Objective
- **Economy**: Marketplace Item, Supplier
- **Factions**: Faction, Unit Roster
- **Campaigns**: Campaign, Phase
- **Narrative**: Event, Quest
- **Geoscape**: Country, Region, Biome
- **Crafts**: Craft, Weapon
- **Interception**: Combat state
- **General**: Settings, Difficulty

### Key Sections

- Field type conventions (string, integer, boolean, array, table)
- TOML array vs section syntax
- Required vs optional fields with defaults
- Constraints and validation rules
- Real working examples from mods/core

### When to Use

- Look up specific entity schema
- Understand field types and constraints
- Get validation rules for your TOML
- See defaults for optional fields

---

## Weapons & Armor API

**File**: `wiki/api/API_WEAPONS_AND_ARMOR.md`

Comprehensive weapon, armor, and equipment documentation with 50+ working examples.

### Content

**Weapons**:
- Conventional (Rifle, Machine Gun, Sniper Rifle, Rocket Launcher)
- Plasma (Alien technology weapons)
- Laser (Research-unlocked weapons)
- Secondary weapons (Pistols)
- Melee weapons (Swords, Knives)

**Armor**:
- Conventional (Light, Standard, Heavy)
- Advanced (Power Suit, Flying Suit, Stealth Suit)
- Alien (Muton, Floater, Chryssalid armor)
- Special (Hazmat, Medical)

**Equipment**:
- Support items (Medkits, repair kits)
- Utility (Sensors, communication gear)
- Consumables (Smoke grenades, explosives)

### Stat System

- Damage (10-150)
- Accuracy (0-100%)
- Range (5-100 tiles)
- AP Cost (1-5 action points)
- EP Cost (0-25 energy points)
- Fire Rate (1-5 shots/turn)
- Weight (encumbrance)
- Cost (manufacture price)

### Balance Guidelines

- High damage = Low accuracy (balanced formula)
- Heavy armor = High maintenance cost
- Advanced weapons = Late-game unlock

### When to Use

- Creating custom weapons
- Balancing weapon stats
- Understanding damage calculation
- Learning armor system

---

## Units & Classes API

**File**: `wiki/api/API_UNITS_AND_CLASSES.md`

Unit class and unit type system with progression, traits, and promotion paths.

### Content

**Unit Classes** (Templates):
- Human classes (Soldier, Heavy, Sniper, Scout, Support)
- Alien classes (Sectoid, Sectoid Leader, Muton, Floater, Chryssalid)
- Civilian class

**Unit Types** (Specific instances):
- Recruit, Veteran, Expert units
- Faction-specific units
- Special units with traits

**Traits System**:
- Personality traits (Brave, Coward, Aggressive)
- Physical traits (Strong, Fast, Tough)
- Learned traits (Veteran, Marksman)

**Progression System**:
- 7 ranks (0-6)
- XP requirements (100-2500 per rank)
- Promotion trees
- Experience tracking

### Stats

- Aim (accuracy)
- Melee (close combat)
- React (reaction fire)
- Speed (movement)
- Sight (vision range)
- Armor (damage reduction)

### When to Use

- Creating custom unit classes
- Defining new unit types
- Adding traits to units
- Understanding rank progression
- Balancing unit stats

---

## Facilities API

**File**: `wiki/api/API_FACILITIES.md`

Base facility system including construction, maintenance, adjacency bonuses, and specialization.

### Facility Types

- **Command**: Command Center (base control)
- **Residential**: Living Quarters (soldier barracks)
- **Manufacturing**: Workshop, Armor Workshop, Munitions Workshop
- **Research**: Lab, Alien Containment
- **Storage**: General Storage
- **Power**: Power Generator
- **Detection**: Radar Station
- **Medical**: Medical Lab
- **Defense**: Defensive Turrets

### Facility Stats

- Size (1×1 to 5×5 hex grid)
- Cost (500-99999 credits)
- Build time (1-100 days)
- Maintenance (0-500 credits/month)
- Capacity (storage, personnel)
- Production rate (manufacturing bonus)
- Power generation/consumption
- Detection radius (radar range)

### Special Features

- Adjacency bonuses (research, manufacturing)
- Specialization (armor, ammunition, research)
- Power grid connectivity
- Facility expansion

### When to Use

- Creating custom facilities
- Designing base layouts
- Understanding adjacency system
- Balancing facility costs
- Planning base progression

---

## Research & Manufacturing API

**File**: `wiki/api/API_RESEARCH_AND_MANUFACTURING.md` (Planned)

Technology trees, research projects, manufacturing recipes, and research progression.

### Content

**Research System**:
- Technology tree structure
- Research project definitions
- Prerequisites and dependencies
- Research costs (man-days)
- Unlocks (new items, facilities, units)

**Manufacturing System**:
- Manufacturing recipes
- Input resources required
- Output items
- Manufacturing times
- Batch efficiency bonuses

**Salvage System**:
- Salvage processing
- Resource extraction
- Research opportunities

### When to Use

- Creating custom technologies
- Defining research progression
- Creating manufacturing recipes
- Setting research costs
- Planning tech tree layout

---

## Missions API

**File**: `wiki/api/API_MISSIONS.md` (Planned)

Mission definitions, objectives, difficulty scaling, and mission generation.

### Content

**Mission Types**:
- Tactical missions (Clear, Defend, Retrieve, Reach)
- Strategic missions (UFO crash, Alien base, Abduction)
- Difficulty levels (Easy, Normal, Hard, Impossible)

**Mission Components**:
- Objectives (victory/defeat conditions)
- Enemy squads (configuration)
- Map type (environment)
- Rewards (XP, loot, research)

**Scaling**:
- Difficulty multipliers
- Enemy unit levels
- Squad sizes
- Time limits

### When to Use

- Creating mission types
- Designing mission objectives
- Setting difficulty scaling
- Configuring enemy squads
- Defining mission rewards

---

## Economy & Items API

**File**: `wiki/api/API_ECONOMY_AND_ITEMS.md` (Planned)

Resource types, marketplace items, suppliers, and economic systems.

### Content

**Resources**:
- Credits (currency)
- Fuel (craft propulsion)
- Supplies (general materials)
- Components (tech parts)
- Exotics (alien materials)

**Items**:
- Weapons (purchasable)
- Armor (purchasable)
- Equipment (support items)
- Ammo (ammunition)
- Craft parts

**Economy**:
- Marketplace system
- Supplier relationships
- Pricing modifiers
- Supply limits
- Trade mechanics

### When to Use

- Adding new resources
- Defining marketplace items
- Setting supplier pricing
- Creating trade routes
- Balancing economy

---

## Mod Developer Guide

**File**: `wiki/api/MOD_DEVELOPER_GUIDE.md` (Planned)

Complete tutorial for mod developers from setup to deployment.

### Content

**Getting Started**:
- Mod structure and organization
- mod.toml metadata format
- File naming conventions

**Creating Content**:
- TOML syntax and formatting
- Adding weapons, armor, units
- Creating facilities
- Defining missions

**Advanced Topics**:
- Mod dependencies
- Content overrides
- Custom mod content
- Testing and validation

**Deployment**:
- Mod packaging
- Sharing mods
- Compatibility checking

### When to Use

- Starting a new mod
- Understanding mod structure
- Learning TOML syntax
- Creating complex mods
- Packaging for distribution

---

## File Organization

```
wiki/api/
├── API_SCHEMA_REFERENCE.md          ← Start here for schema info
├── API_WEAPONS_AND_ARMOR.md         ← Weapons and armor documentation
├── API_UNITS_AND_CLASSES.md         ← Units and classes documentation
├── API_FACILITIES.md                ← Facilities documentation (planned)
├── API_RESEARCH_AND_MANUFACTURING.md ← Research and manufacturing (planned)
├── API_MISSIONS.md                  ← Missions documentation (planned)
├── API_ECONOMY_AND_ITEMS.md         ← Economy and items (planned)
├── MOD_DEVELOPER_GUIDE.md           ← Complete modding guide (planned)
├── TOML_FORMATTING_GUIDE.md         ← TOML syntax and best practices (planned)
└── API_INDEX.md                     ← This file
```

---

## Entity Type Quick Reference

### All 118 Entity Types by Category

#### Strategic Layer (28 entities)
- Geoscape: World, Province, Region, Country, Biome, Craft Position, UFO, Base Location (8)
- Missions: Campaign, Mission (Strategic), Mission (Tactical), Escalation Meter, Mission Site, UFO Armada Event, Reinforcement Wave (7)
- Politics: Faction, Country Relationship, Supplier Relationship, Fame Tier, Karma Tracker, Supplier Profile, Faction Unit Roster (7)
- Craft/Interception: Craft, Craft Weapon, Craft Addon, Interception Engagement (4)
- Economy: Resource Type, Marketplace Item (2)

#### Operational Layer (32 entities)
- Base & Facilities: Base, Base Size Progression, Facility Template, Facility Instance, Grid Layout, Adjacency Bonus, Base Defense Rating, Base Expansion State, Power Grid (9)
- Personnel: Unit Class, Unit Instance, Unit Stats, Unit Trait, Unit Ability, Squad Loadout, Squad Composition, Personnel Management (8)
- Research: Research Project, Research Instance, Technology Tree, Manufacturing Recipe, Manufacturing Job, Manufacturing Queue, Salvage Processing, Research Analysis Result (8)
- Economics: Base Economy, Monthly Budget, Personnel Cost, Facility Maintenance, Production Output, Storage Capacity, Fuel & Supply (7)

#### Tactical Layer (24 entities)
- Combat: Combat Instance, Accuracy Formula, Damage Calculation, Cover System, Line of Sight, Action Resolution (6)
- Missions: Battlescape Mission Type, Mission Instance, Objective, Enemy Squad Config, Mission Outcome, Casualty Report (6)
- Maps: Map Block, Tileset, Map Script, Map Grid, Battlefield, Landing Zone (6)
- Units: Unit Action, Weapon Instance, Armor Instance, Unit Status, Loot Table, Salvage Collection (6)

#### Meta Systems (34 entities)
- Analytics: Event Log Entry, Event Type Definition, Simulation Session, Analytics Metric, Balance Report, Player Behavior Pattern (6)
- Mods: Mod, Mod Data File, Entity Override, Mod Dependency, Mod Validation Report, API Function Reference (6)
- Interception: Interception Combat, Interception Action, Interception Outcome, UFO Behavior Script (4)
- UI: Scene, Widget, Widget Callback, Theme, Responsive Layout, Tooltip (6)
- Lore: Narrative Event, Faction Narrative Arc, Quest, Dialogue Line, Campaign Timeline (5)
- Settings: Game Settings (1)

---

## Common Modding Tasks

### Task: Add a new weapon

**Steps**:
1. Open `mods/mymod/content/rules/items/weapons.toml`
2. Add `[[weapon]]` entry with weapon schema
3. Run Love2D: `lovec "engine"`
4. Check console for load confirmation

**See**: API_WEAPONS_AND_ARMOR.md → Weapons Complete Examples

### Task: Create custom unit

**Steps**:
1. Create unit class in `rules/units/classes.toml`
2. Create unit type in `rules/units/soldiers.toml`
3. Test with Love2D
4. Adjust stats if needed

**See**: API_UNITS_AND_CLASSES.md → Custom Units section

### Task: Design facility layout

**Steps**:
1. Research facility types (base_facilities.toml)
2. Plan adjacency bonuses
3. Calculate power needs
4. Design expansion phases

**See**: API_FACILITIES.md (Planned)

### Task: Balance weapon stats

**Steps**:
1. Reference balance formula
2. Adjust damage/accuracy ratio
3. Test in combat
4. Compare to similar weapons

**See**: API_WEAPONS_AND_ARMOR.md → Balance Guidelines

---

## Error Reference

### Common TOML Parsing Errors

```
[DataLoader] ERROR: Could not get [contentType] path from mod
  → mod.toml missing [paths].[contentType] entry

[DataLoader] ERROR: Failed to load TOML
  → TOML syntax error, check formatting

[DataLoader] ERROR: Missing expected key 'X' in TOML data
  → Required field missing from entity

Warning: Missing field 'Y' for entity X
  → Optional field omitted, using default
```

### Debugging Tips

1. **Enable console**: Built-in via conf.lua
2. **Run with debug**: `lovec "engine"` shows all loading messages
3. **Check files**: Verify TOML files exist in correct paths
4. **Validate syntax**: Use online TOML validator
5. **Check field types**: integers vs strings vs arrays

---

## Related Documentation

### Game Systems
- `wiki/systems/Overview.md` - Game architecture
- `wiki/systems/Geoscape.md` - Strategic layer
- `wiki/systems/Basescape.md` - Operational layer
- `wiki/systems/Battlescape.md` - Tactical layer

### Development
- `wiki/DEVELOPMENT.md` - Development workflow
- `tasks/TASK_TEMPLATE.md` - Task documentation template
- `tests/README.md` - Testing guide

### Tools
- `tools/README.md` - Development tools
- `tools/map_editor/` - Map editing tool

---

## Phase 5 Progress

**Step 1**: ✅ Entity Analysis & Extraction (118 entities identified)  
**Step 2**: ✅ Engine Code Analysis (TOML parsing documented)  
**Step 3**: 🔄 API Documentation (In Progress - 3 files complete)

**Remaining Step 3 Files** (Planned):
- API_FACILITIES.md - Facility API (pending)
- API_RESEARCH_AND_MANUFACTURING.md - Research API (pending)
- API_MISSIONS.md - Mission API (pending)
- API_ECONOMY_AND_ITEMS.md - Economy API (pending)
- MOD_DEVELOPER_GUIDE.md - Complete modding guide (pending)
- TOML_FORMATTING_GUIDE.md - TOML best practices (pending)

**Following Steps**:
- Step 4: Mock Data Generation (1000+ entries)
- Step 5: Example Mods (Complete + Minimal)
- Step 6: Integration & Cross-References
- Step 7: Validation & Testing
- Step 8: Polish & Finalize

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Oct 21, 2025 | Initial API documentation release |

---

## Contact & Support

- **Issues**: Report in GitHub issues
- **Questions**: Check FAQ.md or API_SCHEMA_REFERENCE.md
- **Suggestions**: Open a discussion

---

## License

AlienFall API Documentation - Open Source  
Licensed under project license

