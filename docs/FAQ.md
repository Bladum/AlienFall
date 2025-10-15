# FAQ

## General Questions

### What is AlienFall?
AlienFall is an open-source turn-based strategy game inspired by the X-COM series, built with Love2D and Lua. It features geoscape strategic gameplay, base management, and turn-based tactical combat against alien invaders. Unlike traditional games with fixed endings, AlienFall offers sandbox-style gameplay with player-driven goals and extensive modding support.

### How is it different from X-COM?
While inspired by X-COM, AlienFall includes:
- **Open-ended gameplay** with no fixed win/loss conditions
- **Extensive modding** through TOML configuration and Lua scripting
- **Modern development practices** with comprehensive documentation
- **Community-driven development** with open-source collaboration

### Is it free and open source?
Yes! AlienFall is completely free and open source under an appropriate open-source license. The source code is available on GitHub, and the game can be downloaded and played without any cost or restrictions.

### What platforms does it run on?
AlienFall runs on any platform supported by Love2D:
- **Windows** (7+)
- **macOS** (10.7+)
- **Linux** (most distributions)
- **Potentially others** where Love2D is available

## Getting Started

### How do I install AlienFall?
1. **Install Love2D**: Download from [love2d.org](https://love2d.org/) (version 11.5+ recommended)
2. **Download AlienFall**: Get the latest release from GitHub
3. **Run the game**: Double-click the .love file or run `love path/to/alienfall.love`
4. **For development**: Clone the repository and run `love .` from the project directory

### What are the system requirements?
**Minimum Requirements:**
- OS: Windows 7+, macOS 10.7+, or Linux
- RAM: 2GB
- Storage: 500MB free space
- Display: 1280x720 resolution

**Recommended Requirements:**
- OS: Windows 10+, macOS 12+, or Linux
- RAM: 4GB
- Storage: 1GB free space
- Display: 1920x1080 resolution

### How do I start playing?
1. **Launch the game** using Love2D
2. **Choose difficulty** (Rookie, Veteran, Commander, Legend)
3. **Select base location** on the world map
4. **Begin with initial funding** and basic facilities
5. **Complete tutorial missions** to learn the basics
6. **Expand your base** and start researching new technologies

## Gameplay Questions

### What are the main game layers?
AlienFall has three interconnected layers:

**Geoscape (Strategic Layer)**: World map management where you:
- View an 80×40 hex grid world map representing Earth
- Track craft movement between provinces (strategic locations)
- Monitor day/night cycle moving across the world
- Manage calendar system (1 turn = 1 day, 360 days/year)
- Deploy crafts to provinces for missions and interceptions
- Monitor country relations and funding
- Plan operational ranges based on craft fuel and speed
- Build bases in strategic provinces

**Basescape (Base Management)**: Base operations where you:
- Construct facilities in a 5×5 grid (labs, workshops, hangars)
- Research new technologies with scientists
- Manufacture weapons and equipment with engineers
- Manage personnel and resources
- Store items and vehicles
- Provide services (power, fuel, maintenance)

**Battlescape (Tactical Combat)**: Turn-based combat where you:
- Control individual soldiers on procedurally generated maps
- Use cover, positioning, and tactics
- Complete mission objectives (kill, capture, rescue, defend)
- Recover alien technology and salvage
- Progress unit skills and experience

### How does the Geoscape work?
The Geoscape strategic layer features:

**Hex Grid World**: 80×40 hex tiles, each representing ~500km
- Axial coordinate system (q, r) for precise positioning
- Provinces are strategic nodes on the hex grid
- Connections between provinces form a travel network

**Calendar System**: Turn-based time progression
- 1 turn = 1 day
- 6 days per week
- 30 days per month (5 weeks)
- 360 days per year (12 months, 4 quarters)
- Events scheduled by turn number

**Day/Night Cycle**: Visual overlay moving across world
- Moves 4 tiles per day (20-day full cycle)
- 50% day coverage, 50% night coverage
- Affects mission visibility and difficulty
- Smooth transition zones between day and night

**Province System**: Strategic locations with properties
- Each province has a biome, country, region
- Max 4 crafts per province
- Can contain player bases
- Missions spawn in provinces
- Connected to neighbors for travel

**Craft Travel**: Fuel-based movement between provinces
- Crafts move along province connections
- Travel cost = fuel consumption × distance
- Operational range shown as reachable provinces
- A* pathfinding finds optimal routes
- Crafts auto-return to base after missions

### How does the combat system work?
Battlescape combat uses:
- **Action Points (AP)**: Limited resource for movement, shooting, and actions. Each unit gets AP based on Time Units stat.
- **Turn-based**: Alternate between player and alien turns. All player units act, then all alien units act.
- **Line of Sight**: Visibility affects targeting and overwatch. Smoke, darkness, and terrain block LOS.
- **Cover System**: Hard and soft cover provide defensive bonuses. Hard cover (walls) is better than soft cover (bushes).
- **Unit Progression**: Soldiers gain experience and improve over time. Stats increase based on actions performed.

### What determines hit chance?
Hit chance is calculated from:
- **Base Accuracy**: Shooter's accuracy stat
- **Range Modifiers**: Longer distance reduces hit chance
- **Cover Modifiers**: Target in cover is harder to hit
- **Stance Modifiers**: Crouching or prone targets are harder to hit
- **Environmental Factors**: Darkness and smoke reduce accuracy
- **Target Size**: Larger targets are easier to hit
- **Weapon Type**: Different weapons have different accuracy profiles

Formula: Base Accuracy - Range Penalty + Cover Penalty + Stance Penalty + Environmental Modifiers = Final Hit %

### How does damage calculation work?
Damage follows this process:
1. **Weapon Damage Roll**: Random value within weapon's damage range
2. **Armor Reduction**: Target's armor value reduces damage
3. **Armor Penetration**: Weapon's AP stat bypasses some armor
4. **Damage Type**: Some armor is more effective against certain damage types
5. **Final Damage**: Applied to target's health pool
6. **Critical Hits**: Random chance for bonus damage and effects

### What are critical hits?
Critical hits provide:
- **Bonus Damage**: Usually 1.5x to 2x normal damage
- **Special Effects**: May cause bleeding, disorientation, or equipment damage
- **Ignore Armor**: Some critical hits bypass armor partially
- **Morale Impact**: Critical hits affect enemy morale more severely

Critical chance is based on attacker skill, weapon type, and sometimes flanking position.

### How does morale and panic work?
**Morale System:**
- Each unit has morale value (0-100)
- High morale improves performance
- Low morale (<50) reduces accuracy and may trigger panic
- Very low morale (<25) high panic risk

**Panic Triggers:**
- Nearby casualties (especially allies)
- Taking heavy damage
- Suppression fire
- Overwhelming enemy presence
- Psionic attacks

**Panic Effects:**
- **Cowering**: Unit does nothing, loses turn
- **Fleeing**: Unit runs away from combat
- **Berserk**: Unit attacks nearest target (friend or foe)
- **Dropping Weapon**: Unit becomes unarmed

**Recovery**: Morale recovers slowly over turns, faster when near high-morale allies or after successful actions.

### How do I research new technologies?
1. **Build a Laboratory** in your base
2. **Hire Scientists** to work in the lab
3. **Select research projects** from the available tech tree
4. **Wait for completion** (time varies by project complexity)
5. **Unlock new capabilities** like better weapons, armor, or aircraft

**Research Progress:**
- Each scientist in a lab generates research points daily
- Projects require specific amounts of research points
- Multiple labs work independently (more labs = faster research)
- Some projects require alien artifacts or live specimens
- Random "breakthroughs" can instantly complete projects (rare)

**Research Prerequisites:**
- Many projects require previous research completion
- Some need specific facilities (e.g., Psi Lab for psionics)
- Live alien interrogations unlock crucial technologies
- Alien artifacts must be recovered from missions

### How does mission detection work?
**Mission Detection System:**
AlienFall features a dynamic mission detection system where alien missions spawn weekly but remain hidden until discovered by player radar systems. This creates strategic tension between expanding radar coverage and responding to threats.

**Mission Types:**
- **Alien Sites** (50%): Land-based installations, 14 days duration, orange icons
- **UFO Missions** (35%): Air or landed craft, 7 days duration, red icons  
- **Alien Bases** (15%): Underground/underwater facilities, 30 days duration, purple icons

**Cover Mechanics:**
- Missions spawn with **cover value** (0-100) that hides them from detection
- Cover **regenerates daily** at mission-specific rates:
  - Sites: +5 per day
  - Flying UFOs: +3 per day (easier to detect)
  - Alien bases: +10 per day (well-hidden)
- Cover must be reduced to **0** for mission detection

**Radar Detection:**
- **Base Facilities**: Provide radar coverage
  - Small Radar: 20 power, 5 province range
  - Large Radar: 50 power, 10 province range  
  - Hyperwave Radar: 100 power, 20 province range
- **Craft Equipment**: Mobile radar scanning
  - Basic Radar: 10 power, 3 province range
  - Advanced Radar: 25 power, 7 province range
- **Detection Formula**: `cover_reduction = radar_power × (1 - distance/max_range)`
- **Multiple Scanners**: Combine coverage for better detection

**Gameplay Flow:**
1. **Weekly Spawning**: 2-4 missions spawn every Monday with full cover
2. **Daily Scanning**: All bases/crafts scan for missions each turn
3. **Cover Reduction**: Radar power reduces mission cover over time
4. **Detection**: Mission appears on Geoscape when cover reaches 0
5. **Expiration**: Missions disappear after duration if not intercepted
6. **Strategic Choice**: Balance radar investment vs interception capability

### How does fire spreading work?

**Fire Mechanics:**
- **Binary State**: Tiles are either on fire or not (no fire levels)
- **Spread Chance**: 30% base chance per adjacent flammable tile
- **Terrain Factor**: Multiplied by terrain flammability (0.0-1.0)
- **Unit Damage**: 5 HP per turn for units standing in fire
- **Smoke Production**: Each fire tile produces smoke each turn
- **Movement Block**: Fire tiles are impassable (0 movement cost)
- **LOS Penalty**: Fire adds +3 sight cost to line-of-sight calculations

**Flammability Values:**
- **Non-flammable**: Water (0.0), rock (0.0), road (0.0), wall (0.2)
- **Low flammability**: Floor (0.1), mud (0.1), concrete (0.1)
- **Medium flammability**: Grass (0.6), fence (0.6)
- **High flammability**: Bushes (0.9), trees (0.9), wood wall (0.8), door (0.7)

**Tactical Uses:**
- **Area Denial**: Block enemy movement paths
- **Damage Over Time**: Force enemies out of cover
- **Smoke Generation**: Create concealment for flanking
- **Environmental Control**: Shape battlefield with fire lines

### What are smoke levels and how do they affect gameplay?

**Smoke Levels:**
- **Light Smoke (Level 1)**: +2 sight cost, 30% opacity
- **Medium Smoke (Level 2)**: +4 sight cost, 50% opacity
- **Heavy Smoke (Level 3)**: +6 sight cost, 70% opacity

**Smoke Mechanics:**
- **Dissipation**: 33% chance per turn to reduce level (3→2→1→0)
- **Spreading**: Heavy smoke spreads to adjacent tiles (20% chance)
- **Accumulation**: Multiple sources stack up to level 3
- **LOS Integration**: Adds to accumulated sight cost in shadow casting
- **Visual Effect**: Translucent gray overlay with level-based opacity

**Tactical Implications:**
- **Concealment**: Smoke blocks enemy vision and LOS
- **Flanking**: Use smoke to mask movement and repositioning
- **Defense**: Create smoke screens for retreat
- **Offense**: Smoke grenades for area denial
- **Risk**: Smoke affects both sides equally

**Fire Integration:**
- Fire produces smoke automatically each turn
- Smoke persists longer than fire (gradual dissipation)
- Heavy smoke spreads independently of fire
- Combined effects create complex environmental hazards

## Technical Questions

### What is the hex battle system?

AlienFall features a complete hexagonal grid battle system implemented with modern ECS (Entity Component System) architecture. This system provides strategic depth and tactical gameplay similar to advanced turn-based strategy games.

**Key Features:**
- **Hexagonal Grid**: 60×60 hex grid with even-Q vertical offset layout
- **AP-Based Movement**: Units have action points (2 AP per hex, 1 AP per 60° rotation)
- **Directional Vision**: 120° vision cones with line-of-sight calculations
- **Pathfinding**: A* algorithm for intelligent unit movement
- **ECS Architecture**: Clean separation of data (components) and logic (systems)

**Debug Controls:**
- **F8**: Toggle fog of war display
- **F9**: Toggle hex grid overlay (green hexagons)
- **F10**: Toggle debug mode

### How does the vision work?

**Vision System:**
- **Range**: Default 8 hexes (configurable per unit)
- **Arc**: 120° directional cone (3 forward hexes)
- **Line-of-Sight**: Bresenham algorithm for hex lines
- **Blocking**: Terrain and units can block vision

**Vision States:**
- **Visible**: Unit can see and be seen
- **Explored**: Previously seen, now hidden
- **Hidden**: Never seen, fog of war active

### What are the movement rules?

**Action Points (AP):**
- Each unit starts with 10 AP per turn
- **Moving**: 2 AP per hex moved
- **Rotating**: 1 AP per 60° turn
- AP resets at the start of each turn

**Movement Examples:**
- Move 3 hexes: 6 AP
- Move 2 hexes + rotate once: 4 AP + 1 AP = 5 AP
- Rotate twice: 2 AP (no movement)

### Why does the game crash on startup?
Common causes:
- **Wrong Love2D version**: Ensure you're using Love2D 11.5+
- **Missing dependencies**: Some systems may need additional libraries
- **Corrupted files**: Redownload the game files
- **Permission issues**: Ensure write access to save directory
- **Conflicting mods**: Disable all mods and test
- **Graphics driver issues**: Update to latest drivers
- **Insufficient memory**: Close other applications

**Troubleshooting Steps:**
1. Verify Love2D version: `love --version`
2. Run with console: `lovec.exe` to see error messages
3. Check save directory permissions
4. Disable all mods
5. Reinstall Love2D
6. Redownload game files
7. Check system requirements

### Where are save files stored?
Save files are stored in Love2D's save directory:
- **Windows**: `%APPDATA%\LOVE\alienfall\` or `C:\Users\username\AppData\Roaming\LOVE\alienfall\`
- **macOS**: `~/Library/Application Support/LOVE/alienfall/`
- **Linux**: `~/.local/share/love/alienfall/`

**Save File Structure:**
```
saves/
├── autosave.sav
├── campaign_01.sav
├── campaign_02.sav
└── quicksave.sav
```

**Save File Management:**
- **Backup**: Copy save files before major updates
- **Transfer**: Copy saves between computers
- **Corruption**: Delete corrupted save, use backup
- **Mod Changes**: Saves may break with mod changes

### How do I enable debug mode?
For development builds:
- Run with `--debug` flag: `love . --debug`
- Check console output for detailed error messages
- Use built-in debug tools for performance monitoring

**Debug Features:**
- **Console Logging**: Detailed output with `lovec.exe`
- **FPS Counter**: Frame rate monitoring
- **Memory Usage**: Track RAM consumption
- **Entity Counts**: See active game objects
- **Collision Boxes**: Visualize hitboxes
- **Path Display**: Show unit movement paths
- **AI Decisions**: Log AI reasoning

**Enabling in Config:**
```lua
-- conf.lua
function love.conf(t)
  t.console = true  -- Opens console window
  t.debug = true    -- Enables debug features
end
```

## Status Effects Questions

### What status effects are there?
**Negative Effects:**
- **Poisoned**: Damage over time from toxins
- **Bleeding**: Health loss from wounds
- **Stunned**: Cannot act for turns
- **Suppressed**: Accuracy and morale penalties
- **Panicked**: Loss of control (see panic mechanics)
- **Disoriented**: Reduced accuracy and reactions
- **On Fire**: Damage per turn, spreads to adjacent units
- **Blinded**: Severely reduced vision and accuracy
- **Mind Controlled**: Enemy controls unit
- **Zombified**: Chryssalid infection (becomes zombie)
- **Corroded**: Armor degradation from acid

**Positive Effects:**
- **Stimmed**: Temporary stat boosts
- **In Cover**: Defense bonus
- **Overwatch**: Reaction fire ready
- **Aimed**: Accuracy bonus
- **Inspired**: Morale and effectiveness boost
- **Shielded**: Temporary HP/damage absorption
- **Camouflaged**: Reduced detection
- **Focused**: Enhanced accuracy
- **Energized**: Bonus AP

### How do I cure status effects?
**Treatment Methods:**

**Medical:**
- **Medikit**: Stops bleeding, heals wounds
- **Antidote**: Cures poison
- **Stim Pack**: Removes fatigue, boosts stats temporarily
- **Psi Healing**: Restores health and sanity

**Time:**
- Most effects wear off after 2-5 turns
- Some permanent until treated
- Unconscious units may recover naturally

**Prevention:**
- Gas masks prevent poison
- Fire-resistant armor reduces burn chance
- Mind shield resists mental effects
- High morale resists suppression

**Combat Solutions:**
- Kill source of effect (e.g., kill controller to break mind control)
- Break line of sight to stop suppression
- Use smoke to block fire
- Extinguish fires by stopping/dropping/rolling

## Modding Questions

### How do I create a mod?
1. **Create mod directory**: `mods/your_mod_name/`
2. **Add mod.toml**: Configuration file with mod metadata
3. **Create content**: TOML files for data, Lua scripts for logic
4. **Test mod**: Enable in main menu and verify functionality
5. **Package and share**: Distribute your mod files

**Mod Structure:**
```
mods/your_mod_name/
├── mod.toml (metadata: name, version, author, dependencies)
├── content/ (TOML configuration files)
│   ├── units/ (soldier and alien definitions)
│   ├── items/ (weapons, armor, equipment)
│   ├── facilities/ (base building definitions)
│   └── missions/ (mission type configurations)
├── scripts/ (Lua logic files)
│   ├── init.lua (mod initialization)
│   └── custom_systems.lua (new functionality)
└── assets/ (graphics, sounds, optional)
    ├── sprites/
    └── audio/
```

### What can I mod?
**Easily Moddable (TOML):**
- Unit stats (health, accuracy, reactions, etc.)
- Weapon stats (damage, accuracy, AP cost)
- Armor values and equipment
- Facility costs and requirements
- Research tree and prerequisites
- Manufacturing recipes
- Mission parameters
- AI behavior weights
- Economy values (costs, salaries, funding)

**Advanced Modding (Lua):**
- New game systems and mechanics
- Custom UI elements
- AI behavior logic
- Mission generation algorithms
- Campaign events and scripting
- Special abilities and effects
- Save game modifications

**Not Easily Moddable:**
- Core engine features
- Love2D framework limitations
- Fundamental rendering system
- Network/multiplayer (not implemented)

### How do I test my mod?
**Testing Process:**
1. **Enable Mod**: In-game mod menu, check your mod
2. **Start New Game**: Many changes need fresh game
3. **Console Output**: Run with `lovec.exe` for debug logs
4. **Verify Changes**: Check your modifications work
5. **Test Edge Cases**: Try unusual situations
6. **Performance**: Monitor frame rate and memory

**Debugging Tips:**
- Use `print()` statements liberally
- Check Love2D console for errors
- Test with minimal other mods
- Verify TOML syntax with validator
- Keep backup saves for testing
- Test on different difficulty settings

**Common Issues:**
- TOML syntax errors (missing quotes, brackets)
- Undefined references (wrong IDs)
- Load order conflicts
- Missing dependencies
- Incompatible game version

### How do I create custom map blocks?

**MapBlock Creation Process:**
1. **Copy Template**: Start from `mods/core/mapblocks/open_field_01.toml`
2. **Edit Metadata**: Set unique ID, name, biome, difficulty, author, tags
3. **Design Layout**: Plan 15×15 tile layout (0-indexed coordinates)
4. **Add Tiles**: Specify terrain for non-grass tiles using `"x_y" = "terrain"` format
5. **Test**: Load in game and verify appearance
6. **Iterate**: Refine based on gameplay testing

**TOML Structure:**
```toml
[metadata]
id = "my_urban_block_01"
name = "My Urban Block"
description = "Custom city block with buildings"
width = 15
height = 15
biome = "urban"
difficulty = 2
author = "YourName"
tags = "urban, buildings, custom"

[tiles]
# Roads (horizontal)
"7_0" = "road"
"7_1" = "road"
# ... more road tiles

# Building
"2_2" = "wall"
"2_3" = "wall"
"3_2" = "wall"
"3_3" = "floor"
# ... more building tiles
```

**Available Terrains:**
- **Structures**: `floor`, `wall`, `wood_wall`, `door`, `window`
- **Nature**: `grass`, `tree`, `bushes`, `rock`, `water`, `mud`
- **Urban**: `road`, `fence`, `sidewalk`

**Design Guidelines:**
- **Balance**: Mix open areas with cover (30-40% cover terrain)
- **Paths**: Include movement corridors and defensible positions
- **Biome Consistency**: Match terrain to biome type
- **Testing**: Load blocks and playtest for balance

## Development Questions

### How can I contribute code?
1. **Fork the repository** on GitHub
2. **Create a feature branch** for your changes
3. **Make your modifications** following code standards
4. **Test thoroughly** and add tests if needed
5. **Submit a pull request** with clear description
6. **Address feedback** from code review

### Where is the source code?
The complete source code is available at:
- **GitHub Repository**: `https://github.com/your-repo/alienfall`
- **Development Branch**: `main` for latest changes
- **Releases**: Tagged versions for stable downloads

### How do I report bugs?
1. **Check existing issues** to avoid duplicates
2. **Create new issue** on GitHub with:
   - Clear title describing the problem
   - Detailed steps to reproduce
   - Expected vs. actual behavior
   - System information and game version
   - Screenshots or error logs if applicable

**Good Bug Report:**
```
Title: Crash when researching Alien Alloys

Description:
Game crashes to desktop when completing Alien Alloys research.

Steps to Reproduce:
1. Start new game on Veteran difficulty
2. Research Alien Alloys
3. Wait for research completion
4. Crash occurs on completion screen

Expected: Research completes, new options unlock
Actual: Game crashes, error log shows "nil value"

System:
- OS: Windows 10
- Love2D: 11.5
- Game Version: 0.9.2
- Mods: None
- Save file: attached
```

### Can I contribute to development?
**Yes! Multiple ways:**

**Code Contributions:**
1. Fork repository on GitHub
2. Create feature branch
3. Make changes following code standards
4. Write tests for new features
5. Submit pull request
6. Respond to review feedback

**Code Standards:**
- Lua 5.1+ compatibility
- Local variables (avoid globals)
- Comment complex logic
- Follow existing patterns
- Test thoroughly

**Non-Code Contributions:**
- Documentation improvements
- Wiki content
- Tutorial creation
- Bug testing and reporting
- Mod creation
- Community support
- Translations (if system exists)
- Art/audio assets

**Getting Started:**
- Read contributing.md
- Check "good first issue" labels
- Ask in Discord for guidance
- Start small, learn systems
- Review existing PRs

If you can't find an answer here, please ask in our Discord server or create a GitHub Discussion!
