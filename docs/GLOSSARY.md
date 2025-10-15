# Glossary - AlienFall Terminology

> **Purpose**: Unified terminology reference for game design
> **Audience**: Designers, developers, testers, modders

This glossary defines key terms used throughout AlienFall documentation. Terms are organized by category for quick reference.

## Core Concepts

### Turn
Single game step. Duration varies by layer:
- **Geoscape**: 1 turn = 1 day
- **Interception**: 1 turn = single card exchange
- **Battlescape**: 1 turn = one unit's complete activation

### Day/Night Cycle
Visual overlay on geoscape showing time of day per world tile. Affects mission lighting. Moves 4 tiles per turn on Earth (20-turn full cycle).

### Calendar System
- **Day**: Base time unit (1 turn)
- **Week**: 6 days
- **Month**: 30 days (5 weeks)
- **Quarter**: 3 months
- **Year**: 360 days (12 months, 4 quarters)

## Geoscape (Strategic Layer)

### World
Single planet or dimensional plane. Contains provinces connected by paths. Earth is primary world (80×40 hex grid).

### Hex Grid
Axial coordinate system (q, r) dividing world into tiles. Each tile ~500km. Used for positioning and path calculation.

### Region
Large geographic area grouping multiple countries. Used for analytics and mission generation.

### Country
Political entity with government, economy, and relations. Provides funding. Can become hostile if relations deteriorate.

### Province
Smallest strategic unit. Single location on map. Has:
- Economy level (contributes to country GDP)
- Biome (affects terrain generation)
- Can contain player base
- Can contain missions

### Province Path
Connection between provinces. Defines travel time, fuel cost. Terrain type affects efficiency and craft speed.

### Portal
Special province link across worlds. Allows inter-dimensional craft/UFO travel.

### UFO
Unidentified Flying Object. Alien craft that appears on geoscape, can be tracked and intercepted.

### Mission
Tactical engagement triggered by UFO, base assault, or story event. Leads to battlescape.

## Basescape (Base Management)

### Base
Player facility constructed in a province. Contains 5×5 facility grid.

### Facility
Building occupying one or more grid tiles. Types:
- Production (labs, workshops)
- Support (quarters, storage)
- Defense (turrets, shields)

### Radar Coverage
Detection radius from base. Allows UFO tracking in range.

### Capacity
Maximum storage/operations:
- **Workshop/Lab**: Concurrent projects
- **Prison**: Alien captives
- **Quarters**: Personnel
- **Hangar**: Crafts
- **Storage**: Items
- **Medical**: Healing rate
- **Psych**: Morale recovery rate

### Transfer
Moving personnel, equipment, or resources between bases. Takes time based on distance.

### Maintenance Cost
Ongoing expense to operate base facilities. Deducted per turn.

## Interception (Air Combat)

### Craft
Player aircraft. Used for:
- Deploying to missions
- Intercepting UFOs
- Base-to-base transfers

### Interception
Turn-based air combat between craft and target (UFO or hostile base).

### Craft Weapon
Air-to-air weapon mounted on craft. Different ranges, damage, ammo.

### Fuel
Craft resource limiting operational range. Consumed during travel.

## Battlescape (Tactical Combat)

### Battlefield
Procedurally generated tactical map for missions. Composed of tiles, objects, and units.

### Mapblock
10×10 tile building block used to generate maps. Contains terrain, walls, objects.

### Mapscript
Generation rules defining how mapblocks are assembled for specific mission types.

### Tile
Single battlefield cell (24×24 pixels). Has terrain type, elevation, occupancy.

### Terrain Type
Tile classification: grass, concrete, metal, dirt, etc. Affects movement cost and destruction.

### Biome
Environmental setting (urban, rural, desert, arctic). Determines available mapblocks and aesthetics.

### Cover
Obstacle providing protection. Reduces hit chance:
- **No cover**: 0% reduction
- **Partial cover**: ~30% reduction
- **Full cover**: ~60% reduction

### Line of Sight (LOS)
Vision between two tiles. Blocked by walls, objects. Required for shooting.

### Squad
Group of units deployed to mission. Typically 4-8 soldiers.

### Unit
Individual character (soldier, alien, civilian). Has stats, equipment, position.

### Action Points (AP)
Resource spent on actions. Regenerates each turn. Used for movement, shooting, items.

### Time Units (TU)
Legacy term for Action Points. Still used in some contexts.

### Reaction Fire
Automatic attack triggered by enemy movement. "Overwatch" system.

### Morale
Unit mental state (0-100). Affects behavior. Low morale causes panic.

### Panic
Loss of player control due to low morale. Unit acts randomly or flees.

### Suppression
Temporary morale damage from near-miss shots. Recovers over time.

### Wound
Injury reducing max health. Requires medical recovery time.

### Status Effect
Temporary condition (burning, stunned, bleeding). Affects unit capabilities.

### Experience (XP)
Points earned through combat. Increases unit stats and unlocks abilities.

## Economy

### Funding
Monthly income from countries. Based on relations and organization level.

### Research
Scientific study of technology. Unlocks manufacturing and game content. Requires scientists and time.

### Manufacturing
Production of items and equipment. Requires engineers, materials, and time.

### Marketplace
Buy/sell interface for equipment and materials. Prices fluctuate.

### Resource
Generic term for money, materials, and manufactured goods.

## Politics

### Diplomacy
System managing relations between player organization and countries/factions.

### Reputation
Numeric value (0-100) representing relationship strength. Affects funding and hostility.

### Organization Level
Player organization's global standing. Increases with successful missions and research milestones.

### Faction
Group with shared interests (countries, alien groups, independent organizations).

### Fame
Public recognition. Increases funding and recruitment quality.

### Karma
Hidden morality score. Affects story events and faction relations.

## Content

### Soldier
Player-controlled unit. Can be trained, equipped, and promoted.

### Alien
Enemy unit. Various types with different abilities and equipment.

### Civilian
Non-combatant unit. May need rescue or evacuation.

### Weapon
Equipment for combat. Categories: rifles, pistols, heavy weapons, melee.

### Armor
Protective equipment. Reduces damage and provides resistances.

### Item
Equipment: medkits, grenades, tools, alien artifacts.

### Class
Unit specialization: Assault, Sniper, Heavy, Medic, etc. Defines abilities and stat growth.

## Progression

### Difficulty
Game challenge level: Rookie, Veteran, Commander, Legend. Affects enemy strength and resource availability.

### Achievement
Optional challenge or milestone. Provides recognition.

### Tech Tree
Hierarchical research structure. Prerequisites unlock advanced technologies.

### Promotion
Unit advancement to higher rank. Improves stats and grants abilities.

## UI/UX

### HUD
Heads-up display showing game information during play.

### Widget
UI component: button, panel, label, etc. Built on 24×24 pixel grid.

### Screen
Full-screen UI state: main menu, geoscape view, base management, etc.

### Grid System
UI layout based on 24×24 pixel tiles. Screen is 40×30 grid (960×720).

## Systems

### Mod
User-created content modification. Can add/change units, weapons, mechanics.

### Localization (I18n)
Translation and internationalization system. Supports multiple languages.

### Save Game
Serialized game state. Can be loaded to resume play.

### Analytics
Telemetry tracking player behavior and game balance.

## Technical

### ECS (Entity-Component-System)
Architecture pattern used in battle system. Separates data from logic.

### TOML
Configuration file format for game data. Human-readable, easy to mod.

### Procedural Generation
Algorithmic content creation. Used for maps, missions, events.

## X-COM Legacy Terms

These terms from original X-COM are preserved for familiarity:

### Geoscape
Strategic world view. Adopted directly from X-COM.

### Basescape
Base management view. Adopted directly from X-COM.

### Battlescape
Tactical combat view. Adopted directly from X-COM.

### TU (Time Units)
Original X-COM term for action points. We use AP but TU appears in legacy code.

### Psi (Psionics)
Psychic abilities. Planned feature inspired by X-COM.

---

## Usage Notes

- **Consistent terminology**: Use these exact terms in all documentation
- **Context matters**: Some terms have different meanings in different layers
- **Link to glossary**: Reference this document when introducing terms
- **Update regularly**: Add new terms as systems are designed

**Last Updated**: October 15, 2025
