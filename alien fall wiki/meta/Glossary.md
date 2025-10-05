# Alien Fall - Comprehensive Glossary

**Tags:** `#reference` `#glossary` `#terminology` `#meta`  
**Related:** [[QuickStart_Guide]], [[tutorials/README]], [[docs/README]]  
**Audience:** All Users  
**Last Updated:** September 30, 2025

---

## Overview

This glossary defines all terminology used throughout Alien Fall documentation, code, and gameplay. Terms are organized by category for easy reference.

**Categories:**
- [Core Game Concepts](#core-game-concepts)
- [Combat Terms](#combat-terms)
- [Strategic Layer](#strategic-layer)
- [Base Management](#base-management)
- [Research & Technology](#research--technology)
- [Units & Classes](#units--classes)
- [Items & Equipment](#items--equipment)
- [Technical Terms](#technical-terms)
- [UI & Interface](#ui--interface)
- [Modding Terms](#modding-terms)
- [System-Specific Terms](#system-specific-terms)

---

## Core Game Concepts

### Action Economy
The total number of actions available per turn across all units. Managing action economy involves maximizing your actions while minimizing enemy actions.

### Action Points (AP)
The resource spent to perform actions during combat. Each soldier starts with 12 AP per turn. Also referred to as Time Units (TU) in some contexts.

### Battlescape
The tactical combat layer where missions are resolved. Isometric grid-based combat environment where soldiers fight aliens.

### Campaign
A complete playthrough of Alien Fall from start to finish, typically lasting 12+ months of in-game time.

### Determinism
System property where identical inputs always produce identical outputs. Alien Fall uses deterministic RNG (seeded randomness) for reproducible gameplay.

### Fog of War
Unexplored or unseen areas of the battlefield. Enemies in fog are invisible until a soldier's vision reveals them.

### Geoscape
The strategic world map layer where you monitor UFO activity, select missions, manage bases, and advance time.

### Ironman Mode
Gameplay mode with permanent consequences. No manual saves, soldier deaths are permanent, mission failures have lasting impact.

### Mission
A tactical engagement where soldiers deploy to combat aliens. Missions have objectives, rewards, and consequences.

### Permadeath
Permanent death system where soldiers who die in missions are lost forever and cannot be recovered.

### RNG (Random Number Generator)
System that generates random outcomes for combat, mission generation, etc. Alien Fall uses seeded RNG for determinism.

### Turn
One complete cycle of actions in tactical combat. Player turn → Enemy turn → Next turn cycle.

---

## Combat Terms

### Aim
Soldier stat representing shooting accuracy. Higher aim = higher hit chance. Rookie soldiers start at 65 aim.

### Alpha Strike
Tactical doctrine of eliminating all enemies before they can act, typically on first contact.

### Cover
Battlefield obstacles that protect soldiers from enemy fire. Provides defensive bonuses (+20% half cover, +40% full cover).

### Critical Hit (Crit)
Attack that deals bonus damage (typically +50-100%). Base crit chance is 5%, modified by various factors.

### Flanking
Attacking an enemy from the side or rear, ignoring their cover bonuses and gaining +30% hit chance.

### Focus Fire
Tactical concept of concentrating multiple soldiers' attacks on a single target to guarantee kills.

### Hit Chance
Probability that an attack will successfully hit the target, displayed as a percentage (0-95% cap).

### Line of Sight (LOS)
Direct, unobstructed vision path between two points. Required for shooting, detection, and most abilities.

### Overwatch
Reaction fire mode where soldiers automatically shoot at the first enemy that moves within their vision cone.

### Reaction Fire
Automatic shooting that occurs during the enemy turn when specific conditions are met (movement, etc.).

### Suppression
Tactical action (typically from LMGs) that penalizes enemy aim, mobility, and abilities through sustained fire.

### Time Units (TU)
Alternative term for Action Points. Used interchangeably in some documentation.

---

## Strategic Layer

### Alien Base
Permanent alien installation on Earth. Increases UFO activity in region. Can be assaulted for major strategic advantage.

### Council Nations
Funding countries that support XCOM. Provide monthly income. Can panic and withdraw if conditions deteriorate.

### Funding
Monthly income from Council Nations. Baseline ~$1,000,000, varies by satellites and panic levels.

### Geoscape Time
Accelerated time flow on the strategic map. 5 seconds in-game ≈ 1 hour real-time.

### Interception
Air combat between your craft (interceptors) and UFOs. Determines if missions become available.

### Panic
Measure of regional fear of aliens (0-100). High panic leads to country withdrawal. Reduced by successful missions.

### Satellite Coverage
Orbital surveillance providing income, panic reduction, and UFO detection in covered regions.

### UFO (Unidentified Flying Object)
Alien spacecraft. Types include Scout, Fighter, Harvester, Terror Ship, Battleship. Each has different capabilities.

---

## Base Management

### Access Lift
Mandatory facility serving as base entry point. Cannot be destroyed or moved. Starting point for all base construction.

### Adjacency Bonus
Efficiency boost (+10%) when facilities of the same type are built adjacent to each other (labs, workshops).

### Base Grid
6×6 tile layout (36 total spaces) for facility placement. Facilities must connect to Access Lift.

### Engineer
Personnel who work in workshops. Enable manufacturing and reduce production time. Cost $45,000 to hire.

### Facility
Buildings constructed in your base. Examples: Laboratory, Workshop, Hangar, Power Generator, etc.

### Hangar
Facility that stores and maintains one interceptor craft. Required for air operations.

### Laboratory
Research facility. Houses scientists and enables research projects. Costs $400,000 and 15 days to build.

### Living Quarters
Personnel housing. Increases capacity for soldiers, scientists, and engineers by 10/5/5 respectively.

### Maintenance Cost
Monthly upkeep expense for facilities, personnel, and craft. Must be paid or facilities shut down.

### Power Generator
Facility producing 10 power units. Required to operate other facilities. Costs $250,000 and 18 days.

### Scientist
Research personnel who work in laboratories. Reduce research time. Cost $50,000 to hire.

### Stores
Storage facility increasing item capacity by +50 slots. Costs $100,000 and 10 days to build.

### Upkeep
Alternative term for maintenance cost. Monthly recurring expense.

### Workshop
Manufacturing facility. Houses engineers and enables item production. Costs $500,000 and 20 days.

---

## Research & Technology

### Autopsy
Research project analyzing alien corpses. Provides combat bonuses (+10% damage vs that species) and unlocks.

### Interrogation
Research project from captured aliens. Reveals strategic intelligence (base locations, tactics, etc.).

### Prerequisites
Required research projects that must be completed before unlocking dependent projects.

### Research Project
Scientific investigation requiring time, scientists, and sometimes materials. Unlocks tech, facilities, or items.

### Research Queue
Ordered list of pending research projects. Projects activate automatically when previous project completes.

### Research Speed
Rate at which research progresses. Base 1 day per research unit, modified by scientist count and adjacency.

### Tech Tree
Hierarchical structure of research dependencies showing which projects unlock which technologies.

---

## Units & Classes

### Assault
Soldier class specializing in close-quarters combat. High mobility, shotgun proficiency, aggressive abilities.

### Class
Soldier specialization chosen at Squaddie rank. Four classes: Assault, Heavy, Sniper, Support.

### Experience (XP)
Points earned from missions. Accumulate to trigger promotions. Typical mission awards 100-200 XP.

### Heavy
Soldier class specializing in explosives and suppression. LMG proficiency, rocket launchers, area denial.

### Morale
Unit stat representing mental resilience. Low morale can cause panic. Base 40-60, increases with rank.

### Promotion
Rank advancement earned through experience. Each promotion increases stats and may unlock abilities.

### Rank
Soldier's military grade. Progression: Rookie → Squaddie → Corporal → Sergeant → Lieutenant → Captain → Colonel.

### Rookie
Starting soldier rank with basic stats (65 aim, 40 will, 100 HP). No special abilities or class.

### Sniper
Soldier class specializing in long-range precision. Sniper rifle proficiency, high-damage single shots.

### Soldier
Playable human unit in tactical missions. Can be recruited, promoted, equipped, and customized.

### Support
Soldier class specializing in utility and healing. Medkit proficiency, smoke grenades, team buffs.

### Will
Soldier stat representing mental fortitude. Affects panic resistance and psionic defense. Higher is better.

---

## Items & Equipment

### Alien Alloys
Advanced material recovered from UFOs. Used in armor and facility construction. High value.

### Ammo
Consumable resource for weapons. Automatically restocked between missions. Can be depleted mid-mission.

### Arc Thrower
Special weapon for capturing aliens alive. Short range, requires target at low HP. Enables interrogations.

### Armor
Defensive equipment providing HP bonus and damage reduction. Types: Basic, Carapace, Skeleton, Titan, Archangel.

### Carapace Armor
First major armor upgrade. +30 HP, moderate defense. Unlocked through "Alien Materials" research.

### Elerium
Rare alien element used as fuel and in advanced manufacturing. Critical late-game resource.

### Frag Grenade
Explosive weapon dealing 3-6 damage in 3×3 area. Destroys cover. Guaranteed hit. Costs 4 AP to throw.

### Medkit
Healing item restoring 15-25 HP. 3 uses per medkit. Requires adjacency to heal target. Costs 4 AP.

### Plasma Pistol
Alien sidearm. 4-6 damage, short range. First plasma weapon usually researched.

### Plasma Rifle
Standard alien weapon. 5-8 damage, medium range. Major combat upgrade when researched.

### Primary Weapon
Main armament slot. Holds rifles, shotguns, snipers, LMGs, etc. Costs 4 AP to fire.

### Scope
Weapon attachment providing +10% aim. Can be applied to most weapons. Cheap upgrade.

### Secondary Weapon
Backup armament slot. Usually pistols. Costs 3 AP to fire. Used when primary empty or tactical.

### Smoke Grenade
Utility grenade creating concealment. -20% enemy aim in smoke cloud. Lasts 2 turns.

### Utility Slot
Equipment slot for grenades, medkits, special items. Soldiers have 1-2 utility slots depending on class.

---

## Technical Terms

### Canvas
Rendering surface where graphics are drawn. Love2D uses canvas for offscreen rendering and effects.

### Component
Data container in ECS architecture. Pure data, no behavior. Examples: PositionComponent, HealthComponent.

### Deterministic Simulation
System property where same inputs always produce same outputs. Critical for save/load and multiplayer.

### ECS (Entity Component System)
Architectural pattern separating data (Components) from behavior (Systems) for entities.

### Entity
Game object in ECS architecture. Identifier with attached components. Examples: soldier entity, alien entity.

### Event Bus
Communication system where systems publish events and other systems subscribe to listen.

### Grid System
20×20 pixel alignment system for UI elements. All widgets must snap to grid multiples.

### Love2D
Lua game framework powering Alien Fall. Provides graphics, audio, input handling, etc.

### Lua
Programming language used to script Alien Fall. Lightweight, embedded, dynamically typed.

### Mod Loader
System responsible for loading and initializing mod content from the `/mods/` directory.

### Sandboxing
Security technique restricting mod code access to dangerous functions. Protects game from malicious mods.

### Seed
Initial value for RNG that determines all subsequent random outcomes. Same seed = same randomness.

### System
Logic processor in ECS architecture. Operates on entities with specific component combinations.

### TOML
Configuration file format (.toml). Human-readable, strongly typed. Used for all game data definitions.

### Widget
UI component (button, label, panel, etc.). All widgets align to 20×20 pixel grid.

---

## UI & Interface

### Action Bar
Bottom UI panel showing selected soldier's available actions (Move, Shoot, Overwatch, Items, etc.).

### Canvas Resolution
Internal render resolution (800×600 pixels). UI designed at this fixed resolution, then scaled for display.

### Cursor
Mouse pointer. Contextual appearance based on action (move, shoot, invalid, etc.).

### Grid Unit
20×20 pixel square. Base unit for all UI measurements. Canvas is 40×30 grid units (800×600 pixels).

### HUD (Heads-Up Display)
In-mission UI showing soldier stats, turn info, action bar, and battlefield overlays.

### Nearest-Neighbor Filtering
Rendering technique for pixel-perfect scaling. Prevents blur when upscaling pixel art.

### Pixel Art
Visual style using discrete pixels. Alien Fall uses 10×10 pixel tiles and characters.

### Scene
Top-level UI state (MainMenu, Geoscape, Battlescape, Base Management, etc.). Only one active at a time.

### Screen Space
Actual window/monitor coordinates. May differ from internal 800×600 resolution due to scaling.

### Tooltip
Contextual popup explaining UI element. Appears on hover. Shows detailed info about items, abilities, stats.

### UI Scale
Multiplier applied to internal 800×600 resolution for display. Auto-calculated based on window size.

### Viewport
Visible portion of a larger scene. In Battlescape, camera can pan to view different parts of map.

### Widget Tree
Hierarchical structure of UI widgets. Parent widgets contain child widgets. Root → Panel → Button, etc.

---

## Modding Terms

### API Surface
Set of functions and interfaces exposed to mods. Sandboxed subset of full game engine.

### Content Override
Mod technique replacing base game content with custom versions. Examples: replace alien stats, mission types.

### Dependency
Mod requirement stating it needs another mod loaded first. Specified in `mod.toml` file.

### Manifest File
`mod.toml` file declaring mod metadata, dependencies, version, authors, etc. Required for all mods.

### Mod
User-created content package extending or modifying game. Loaded from `/mods/` directory.

### Mod ID
Unique identifier for a mod. Format: `author_modname`. Used for dependency resolution.

### Mod Load Order
Sequence in which mods are initialized. Determined by dependency resolution. Affects override priority.

### Mod Priority
Numerical value (0-100) determining which mod's overrides take precedence. Higher = higher priority.

### Mod Validation
Automated checks ensuring mod follows structure rules, has required files, and valid data.

### Override System
Mechanism allowing mods to replace base game definitions (weapons, aliens, missions, etc.).

### Sandbox
Restricted Lua environment for mod scripts. Blocks dangerous functions (file I/O, networking, etc.).

---

## System-Specific Terms

### Geoscape

#### Detection Range
Radius around base/satellite where UFOs can be detected. Varies by radar system type.

#### Mission Window
Time limit to respond to a mission before it expires. Typical windows: 12-24 hours.

#### Scan Cycle
Periodic check for UFO activity. Occurs every 30 in-game minutes on Geoscape.

#### UFO Activity Level
Measure of alien presence in a region. Increases over time, reduced by successful missions.

### Battlescape

#### Battlefield Grid
Tactical map divided into tiles. Typically 40×30 tiles for standard missions, larger for special missions.

#### Deployment Zone
Starting area where soldiers spawn at mission start. Usually edge of map, safe from immediate threats.

#### Sight Radius
Distance a unit can see (15-20 tiles). Determines fog of war revelation.

#### Tile
Single grid square on tactical map. 20×20 pixels on-screen. Basic unit of movement and positioning.

### Economy

#### Black Market
Special vendor offering rare items for high prices. Occasional random inventory refreshes.

#### Monthly Report
End-of-month financial summary showing income, expenses, panic changes, and strategic assessment.

#### Production Queue
Ordered list of manufacturing projects. Engineers work on first item until complete.

#### Sell Value
Price received when selling items. Usually 50% of purchase cost. Used to raise emergency funds.

### Units

#### Armor Value
Damage reduction from armor. Subtracts from incoming damage before HP loss.

#### Health Points (HP)
Unit's survivability. When reaches 0, unit dies. Rookies start with 100 HP.

#### Mobility
Movement speed stat. Determines how far unit can move per AP spent. Varies by class and armor.

#### Sight Range
Distance unit can detect enemies. Typically 15 tiles, modified by environment and abilities.

### Items

#### Ammo Capacity
Magazine size for weapon. Assault Rifle = 30 rounds, Sniper Rifle = 5 rounds, etc.

#### Clip
Alternative term for ammo capacity. "Empty clip" = out of ammo.

#### Damage Range
Min-max damage values for weapon. Example: Assault Rifle = 3-5 damage per shot.

#### Weapon Range
Effective distance for weapon. Beyond optimal range, accuracy penalties apply.

---

## Abbreviations & Acronyms

| Abbrev | Full Term                    | Meaning                                  |
|--------|------------------------------|------------------------------------------|
| AP     | Action Points                | Resource for combat actions              |
| TU     | Time Units                   | Alternative term for AP                  |
| HP     | Health Points                | Unit survivability                       |
| XP     | Experience Points            | Gained from missions, triggers promotions|
| LOS    | Line of Sight                | Vision/shooting path                     |
| AOE    | Area of Effect               | Attacks hitting multiple targets         |
| RNG    | Random Number Generator      | Randomness system                        |
| UFO    | Unidentified Flying Object   | Alien spacecraft                         |
| ECS    | Entity Component System      | Architecture pattern                     |
| UI     | User Interface               | Visual controls and displays             |
| HUD    | Heads-Up Display             | In-game overlay UI                       |
| AI     | Artificial Intelligence      | Computer-controlled units                |
| LMG    | Light Machine Gun            | Heavy weapon type                        |
| CQC    | Close Quarters Combat        | Short-range fighting                     |
| ROI    | Return on Investment         | Economic efficiency measure              |

---

## Context-Specific Meanings

Some terms have different meanings depending on context:

### "Turn"
- **Combat Context:** One cycle of player + enemy actions
- **Geoscape Context:** Abstract time unit (not used much)

### "Range"
- **Weapon Context:** Effective distance for shooting
- **Sight Context:** Detection distance for units
- **Radar Context:** UFO detection radius

### "System"
- **Technical Context:** ECS logic processor (MovementSystem, CombatSystem)
- **Game Context:** Game subsystem (Research System, Economy System)

### "Class"
- **Soldier Context:** Specialization (Assault, Heavy, Sniper, Support)
- **Programming Context:** Lua object-oriented structure

### "Grid"
- **Base Context:** 6×6 facility placement grid
- **Battlescape Context:** 40×30 tactical map grid
- **UI Context:** 20×20 pixel alignment grid

---

## Related Documentation

### For New Players:
- [[tutorials/QuickStart_Guide]] - Introduction to game concepts
- [[tutorials/README]] - Learning paths and tutorials

### For Developers:
- [[technical/README]] - Technical architecture
- [[docs/architecture]] - System design documents

### For Modders:
- [[mods/README]] - Modding overview
- [[mods/API_Reference]] - Complete API documentation

---

## Contributing to Glossary

To add new terms:
1. Identify appropriate category
2. Provide clear, concise definition
3. Include context or examples where helpful
4. Add cross-references to related terms
5. Update alphabetical index if term is commonly referenced

**Format:**
```markdown
### Term Name
Definition text. May include examples, context, or usage notes. Cross-reference [[related_doc]].
```

---

## Version History

**v1.0 (September 30, 2025)**
- Initial comprehensive glossary
- 150+ terms defined across 10 categories
- Cross-references added
- Abbreviation table included

---

*This glossary is a living document. New terms are added as the game evolves.*

**Last Updated:** September 30, 2025  
**Maintainer:** Documentation Team  
**Review Cycle:** Monthly
