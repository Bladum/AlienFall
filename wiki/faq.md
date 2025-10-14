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

**Controls**:
- Mouse drag: Pan camera
- Mouse wheel: Zoom in/out
- Click: Select province
- Space: Advance one day
- G: Toggle hex grid
- N: Toggle day/night overlay
- L: Toggle province labels

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

### What should I research first?
**Early Game Priority:**
1. **Alien Weapons**: Laser or plasma weapons for better firepower
2. **Better Armor**: Personal armor or carapace armor for survivability
3. **Alien Biology**: Understanding enemies helps in combat
4. **Improved Aircraft**: Better interceptors for UFO hunting

**Mid Game:**
5. **Alien Base Location**: Finding alien bases for assault missions
6. **Advanced Armor**: Power armor or flying suits
7. **Heavy Weapons**: Rockets and heavy plasma

**Late Game:**
8. **Psionic Research**: Mind control and psi defense
9. **Ultimate Weapons**: Blaster launchers and fusion weapons
10. **Hyperwave Decoder**: UFO mission intelligence

### How does manufacturing work?
**Manufacturing Process:**
1. **Build Workshops** in your base
2. **Hire Engineers** to staff workshops
3. **Select production project** from available items
4. **Pay upfront costs** (money and materials)
5. **Wait for completion** (time based on complexity and engineers)
6. **Receive finished items** in storage

**Manufacturing Points:**
- Engineers generate manufacturing points daily
- Projects require specific point totals
- More engineers = faster production
- Workshop quality affects efficiency

**What to Manufacture:**
- **Weapons and Armor**: Equip your troops
- **Ammunition**: Keep soldiers supplied
- **Craft Equipment**: Arm your interceptors
- **Facility Components**: Base expansion materials
- **Items for Sale**: Generate income through black market

**Resource Requirements:**
- Basic items need money and common materials
- Advanced items require alien alloys, elerium, or special components
- Some items need research prerequisites
- Alien artifacts can be reverse-engineered

### How does manufacturing differ from research?
**Research:**
- Unlocks new technologies and knowledge
- Requires scientists and laboratories
- One-time completion per project
- Cannot be sold directly
- Opens new manufacturing options

**Manufacturing:**
- Creates physical items for use
- Requires engineers and workshops
- Can repeat projects for multiple items
- Items can be sold for profit
- Requires completed research as prerequisite

### How does funding work?
- **Monthly Payments**: Governments pay based on your performance
- **Performance Factors**: Mission success, containment of alien activity
- **Penalties**: Failures reduce funding from affected regions
- **Base Costs**: Ongoing expenses for facility maintenance
- **Research Costs**: Upfront payments for technology investigation

**Funding Details:**
- Each nation contributes monthly based on satisfaction
- Score system tracks performance (positive/negative points)
- High alien activity in region reduces that nation's funding
- Terror attacks significantly hurt regional funding
- Successful mission completions increase funding
- Nations can permanently withdraw if too dissatisfied

**Budget Management:**
- Track monthly income vs expenses
- Staff salaries are major ongoing cost
- Facility maintenance adds to monthly bills
- Manufacturing costs are upfront (materials + labor)
- Research costs are upfront (equipment + materials)
- Emergency funding available but unreliable

### How can I make extra money?
**Income Sources:**
1. **Black Market Sales**: Sell alien artifacts and corpses
2. **Manufactured Goods**: Produce items specifically for sale
3. **Mission Rewards**: Some missions provide direct payment
4. **Regional Bonuses**: High performance grants bonus funding
5. **Recovered UFO Components**: Sell undamaged alien technology

**Best Items to Sell:**
- Alien Alloys (high value, common from UFOs)
- Elerium-115 (extremely valuable, but needed for manufacturing)
- Alien Corpses (low value individually, but plentiful)
- Manufactured Laser/Plasma Weapons (if you have surplus)
- Captured Alien Weapons (before you can manufacture)

**Warning:** Don't sell items you'll need for research or manufacturing!

### What happens if I run out of money?
**Debt Consequences:**
- Cannot hire new personnel
- Cannot start new construction
- Cannot begin new research or manufacturing
- Existing projects continue
- Staff may leave if unpaid too long
- Game doesn't end, but severely limits operations

**Recovery Strategies:**
1. Sell unnecessary inventory
2. Dismiss redundant staff
3. Focus on high-value mission rewards
4. Manufacture items for sale
5. Wait for monthly funding
6. Complete high-priority missions for council bonuses

### What affects monthly funding changes?
**Positive Factors:**
- Successful mission completions
- UFO shootdowns and recoveries
- Terror mission successes
- Alien base destructions
- Low alien activity in regions
- High overall performance score

**Negative Factors:**
- Mission failures or ignored missions
- Successful terror attacks
- Lost aircraft
- High alien activity
- Undetected UFO missions
- Poor overall score

**Nation Withdrawal:**
- Happens when nation satisfaction drops too low
- Permanent loss of monthly funding
- May trigger if alien base in their territory
- Recovery impossible once withdrawn
- Losing too many nations can spiral into game over

## Base Management Questions

### How many bases should I build?
**Recommendations:**
- **Early Game**: 1 base, focus on development
- **Mid Game**: 2-3 bases for radar coverage
- **Late Game**: 4-6 bases for global coverage

**Base Purposes:**
- **Main Base**: Full facilities, research, manufacturing, troops
- **Radar Stations**: Minimal facilities, just radar and interceptors
- **Regional Bases**: Medium facilities, local response teams
- **Specialized Bases**: Focus on manufacturing or research

**Considerations:**
- Each base has construction and maintenance costs
- Multiple bases provide better UFO detection coverage
- Local bases respond faster to regional missions
- Too many bases spreads resources thin

### What facilities should I build first?
**Priority Order:**
1. **Living Quarters**: Enables hiring more personnel
2. **Laboratory**: Start researching better technology
3. **Workshop**: Begin manufacturing equipment
4. **Storage**: Prevent item loss from full inventory
5. **Hangar**: For additional aircraft (interceptors/transports)
6. **Radar System**: Detect more UFOs

**Optional Early:**
- **Defense Systems**: If base assault is possible
- **Power Plant**: If base power insufficient

**Late Game:**
- **Psi Lab**: Psionic training
- **Hyperwave Decoder**: Advanced UFO detection
- **Advanced Workshops/Labs**: Efficiency upgrades

### How should I layout my base?
**Layout Considerations:**
- **Facility Adjacency**: Some facilities benefit from being adjacent
- **Defense Planning**: Consider routes for base defense missions
- **Expansion Room**: Leave space for future facilities
- **Elevator Access**: Central location for easy navigation
- **Efficiency**: Minimize distance between related facilities

**Common Layouts:**
- **Grid Pattern**: Organized, easy to plan
- **Hub & Spoke**: Central facilities with surrounding support
- **Defensive**: Choke points for base defense
- **Efficiency**: Group labs together, workshops together

**Base Defense Notes:**
- Soldiers spawn at base entrance
- Aliens enter from edges
- Narrow corridors create defensive positions
- Defense facilities provide auto-turrets

### Can I relocate facilities?
**Facility Management:**
- **No relocation**: Facilities cannot be moved once built
- **Demolition**: Can destroy facilities for rebuild (no refund)
- **Planning ahead**: Plan layout carefully before building
- **Multiple bases**: Build new base if layout unsatisfactory

**Renovation Process:**
1. Sell or transfer equipment/personnel
2. Demolish unwanted facilities
3. Wait for demolition completion
4. Rebuild in desired locations
5. Costs time and money, disrupts operations

## Tactical Combat Questions

### How do I improve my soldiers' aim?
**Accuracy Factors:**
- **Experience**: Soldiers improve accuracy through combat
- **Weapon Choice**: Some weapons are more accurate
- **Range**: Get closer for better hit chance
- **Stance**: Kneel or go prone for accuracy bonus
- **Suppression**: Avoid being suppressed yourself
- **Equipment**: Targeting systems and scopes help
- **Training**: Between missions, soldiers naturally improve

**Combat Tips:**
- Flank enemies to bypass cover
- Use high-ground advantage
- Avoid shooting through smoke
- Take time to aim (don't rush shots)
- Use reaction fire when enemies move

### What's the best squad composition?
**Balanced Squad (8 soldiers):**
- 2 Assault (close combat, shotguns)
- 2 Gunners (suppression, machine guns)
- 2 Snipers (long range, precision)
- 1 Heavy (rockets, demolition)
- 1 Support (medic, utilities)

**Early Game (fewer soldiers):**
- Mix of rifles and shotguns
- At least one heavy weapon
- Prioritize reliable weapons

**Specialized Squads:**
- **Urban Combat**: More assault, fewer snipers
- **Open Terrain**: More snipers, less close combat
- **Terror Missions**: Heavy focus, lots of firepower
- **Base Assault**: Balanced with explosives

### How do I deal with Chryssalids?
**Chryssalid Tactics:**
- **Keep Distance**: They're melee only, stay away
- **High Ground**: They can't climb easily
- **Overwatch**: Reaction fire as they approach
- **Area Weapons**: Grenades/rockets hit multiple
- **Don't Let Them Kill**: Corpses become zombies
- **Fire Support**: Set them ablaze for DOT
- **Panic Prevention**: High morale soldiers essential

**Emergency Measures:**
- Retreat if overwhelmed
- Use environmental barriers
- Sacrifice panicking soldiers to save squad
- Focus fire to kill quickly

### When should I use grenades?
**Grenade Situations:**
- **Destroy Cover**: Remove enemy protection
- **Multiple Enemies**: Clustered targets
- **Guaranteed Damage**: When hit chance is low
- **Flush Out**: Force enemies from positions
- **Panic Inducement**: Soften enemy morale
- **Environmental**: Create new paths

**Grenade Types:**
- **Frag**: Standard explosive, reliable damage
- **High Explosive**: Demolition, terrain destruction
- **Smoke**: Block LOS, provide soft cover
- **Incendiary**: Damage over time, area denial
- **Flashbang**: Disorient without lethal damage
- **Proximity**: Area denial trap

**Conservation:**
- Grenades are limited per mission
- Manufacture more between missions
- Use when tactical advantage significant
- Don't waste on single weak enemies

### How does overwatch work?
**Overwatch Mechanics:**
- Costs AP to activate (usually 50-75%)
- Unit watches specific arc or direction
- Automatically fires at enemy movement
- Based on Reactions stat for trigger speed
- Can interrupt enemy mid-move
- Limited to certain weapons (no rockets)

**Overwatch Tactics:**
- **Overwatch Trap**: Multiple units covering area
- **Door Watching**: Cover entrances and choke points
- **Bait**: One soldier advances, others on overwatch
- **Suppression + Overwatch**: Pin and punish
- **Last Man**: Put remaining soldier on overwatch

**Limitations:**
- Only one shot per enemy (can miss)
- Reduced accuracy compared to aimed shot
- Cannot target all enemy actions
- Some aliens can trigger multiple overwatches

## UFO and Geoscape Questions

### How do I detect UFOs?
**Detection Methods:**
- **Radar Facilities**: Basic detection, limited range
- **Advanced Radar**: Better range and reliability
- **Hyperwave Decoder**: Ultimate detection, reveals missions
- **Multiple Bases**: Overlapping coverage
- **Patrol Routes**: UFOs more likely in certain areas

**Detection Factors:**
- **UFO Size**: Larger UFOs easier to detect
- **UFO Speed**: Slower UFOs easier to track
- **Distance**: Closer to radar = better detection
- **Altitude**: Some altitudes harder to detect
- **Technology**: Better tech = better detection

### Should I always intercept UFOs?
**Consider:**
- **Aircraft Readiness**: Do you have healthy interceptors?
- **UFO Size**: Small scouts are easy, battleships dangerous
- **Weapons**: Do you have adequate weaponry?
- **Strategic Value**: Is the UFO mission important?
- **Risk vs Reward**: Losing aircraft is expensive

**When to Intercept:**
- Small/Medium UFOs with good chance of success
- UFOs heading to important targets
- When you have superior weapons
- Multiple interceptors available

**When to Avoid:**
- Large battleships without proper weapons
- Low fuel/damaged interceptors
- Over water (harder recovery)
- Too far from base (fuel limits)

### What happens if I ignore UFOs?
**Consequences:**
- UFOs complete their missions
- Alien activity increases in region
- Regional funding decreases
- Score penalty
- May lead to terror attacks
- Alien bases may be established
- Strategic situation worsens

**Sometimes Acceptable:**
- Can't safely intercept (too dangerous)
- No interceptors available
- Focusing resources elsewhere
- UFO over ocean (nothing to recover anyway)

### How do I find alien bases?
**Discovery Methods:**
1. **Research "Alien Base Location"**: Reveals one base
2. **Hyperwave Decoder**: Tracks UFOs to supply ships
3. **Supply Ship Tracking**: Follow them to bases
4. **Regional Activity**: High activity suggests nearby base
5. **Interrogation**: Live aliens may reveal locations

**Base Assault:**
- Highly dangerous missions
- Multiple alien levels to clear
- Elite alien forces
- Significant strategic victory if successful
- Reduces regional alien activity dramatically

### What's the difference between crash sites and landing sites?
**Crash Sites:**
- UFO destroyed in air combat
- Damaged UFO, less intact technology
- Fewer surviving aliens
- Time pressure (site disappears after hours)
- Easier than landing sites
- Less valuable loot but safer

**Landing Sites:**
- UFO landed voluntarily
- Intact UFO, pristine technology
- Full alien crew alive
- Time pressure (UFO may take off)
- More dangerous
- Better loot but higher risk

**Tactical Differences:**
- Crash sites have damaged terrain
- Landing sites have intact UFO systems
- Crash survivors may be wounded (easier)
- Landing crews are fresh (harder)

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

**Debug Controls:**
- **F6**: Start test fire (5×5 cluster at camera center)
- **F7**: Clear all fire and smoke effects

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

**Strategic Implications:**
- **Early Game**: Limited radar means missions stay hidden longer
- **Mid Game**: Build radar networks to detect threats proactively
- **Late Game**: Hyperwave coverage reveals most missions quickly
- **Mobile Assets**: Use craft radar for gap coverage
- **Risk/Reward**: Hidden missions may expire, but detected ones demand response

**Visual Indicators:**
- **Hidden Missions**: Not visible (cover > 0)
- **Detected Missions**: Colored icons on Geoscape map
- **Newly Detected**: Blinking icons for 2 days
- **Mission Tooltips**: Hover for details (type, difficulty, days active)
- **UI Stats**: Campaign info shows active/detected mission counts

**Difficulty Scaling:**
- Mission difficulty increases every 4 weeks (+1 level)
- Higher difficulty = stronger missions with more cover regeneration
- Strategic depth: early detection vs late-game power scaling

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

### How do I see the hex grid?

1. **Start the game** and navigate to the Battlescape
2. **Press F9** to toggle the hex grid overlay
3. **Green hexagons** will appear over the battlefield
4. **Press F9 again** to hide the overlay

The hex grid is currently an overlay system that works alongside the existing rectangular grid. This allows for gradual migration and testing.

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

### How does vision work?

**Vision System:**
- **Range**: Default 8 hexes (configurable per unit)
- **Arc**: 120° directional cone (3 forward hexes)
- **Line-of-Sight**: Bresenham algorithm for hex lines
- **Blocking**: Terrain and units can block vision

**Vision States:**
- **Visible**: Unit can see and be seen
- **Explored**: Previously seen, now hidden
- **Hidden**: Never seen, fog of war active

### What is ECS architecture?

ECS (Entity Component System) is a software architecture pattern that provides:
- **Components**: Pure data structures (no logic)
- **Systems**: Pure logic functions (no data)
- **Entities**: Composition of components

**Benefits:**
- **Modularity**: Easy to add/remove features
- **Performance**: Cache-friendly data layout
- **Testability**: Pure functions are easy to test
- **Flexibility**: Dynamic component composition

### How do I create units with the new system?

```lua
local UnitEntity = require("systems.battle.entities.unit_entity")

local soldier = UnitEntity.new({
    q = 10, r = 10,        -- Hex position
    facing = 0,            -- Direction (0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE)
    teamId = 1,            -- Team affiliation
    maxHP = 100,           -- Health
    armor = 10,            -- Damage reduction
    maxAP = 10,            -- Action points
    visionRange = 8,       -- Vision distance
    name = "Soldier Alpha" -- Unit name
})
```

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

### What are the system requirements?
**Minimum:**
- OS: Windows 7+, macOS 10.7+, Linux
- CPU: 1.5 GHz dual-core
- RAM: 2GB
- GPU: OpenGL 2.1 support
- Storage: 500MB free
- Display: 1280x720

**Recommended:**
- OS: Windows 10+, macOS 12+, Linux
- CPU: 2.5 GHz quad-core
- RAM: 4GB
- GPU: Dedicated graphics with OpenGL 3.3+
- Storage: 1GB free
- Display: 1920x1080

**Performance Factors:**
- Large battles (many units) require more CPU
- Mods may increase requirements
- Multiple bases increase overhead
- High-resolution textures need more VRAM

### How do I improve performance?
**In-Game Settings:**
- Lower graphics quality
- Reduce particle effects
- Disable shadows
- Lower resolution
- Disable vsync if stuttering
- Reduce audio channels

**System Optimization:**
- Update graphics drivers
- Close background applications
- Disable Windows visual effects
- Ensure adequate cooling (prevents throttling)
- Use SSD for faster loading

**Mod Considerations:**
- Disable resource-intensive mods
- Reduce custom scripts
- Avoid HD texture packs
- Test mods individually

**For Developers:**
- Profile with Love2D tools
- Optimize hot loops
- Use object pooling
- Batch draw calls
- Reduce garbage collection

### How does the save system work?
**Save Components:**
- **Geoscape State**: Base layouts, research, manufacturing
- **Personnel**: Soldiers, scientists, engineers
- **Inventory**: Items, equipment, resources
- **Campaign Progress**: Missions, score, funding
- **Battlescape State**: Mid-mission saves (if enabled)
- **Mod List**: Active mods and versions

**Save Types:**
- **Autosave**: Automatic at month end or mission start
- **Quicksave**: Manual quick save (F5 typically)
- **Named Saves**: Player-named save files
- **Ironman**: Single save file, no loading

**Save Compatibility:**
- Game updates may break saves (check patch notes)
- Mod changes usually break saves
- Save version tracked for compatibility checks
- Backup saves before updates

### What file formats does the game use?
**Configuration:**
- **TOML**: Game data, mod configuration
- **Lua**: Scripts, game logic
- **JSON**: Alternative data format (less common)

**Assets:**
- **PNG**: Graphics, sprites, textures
- **OGG/WAV**: Audio, music, sound effects
- **TTF**: Fonts for UI text
- **TMX**: Tile maps (if used)

**Save Files:**
- **Binary or Lua tables**: Serialized game state
- **Compressed**: May be gzipped

**Modding Notes:**
- TOML preferred for readability
- Lua for complex logic
- PNG with transparency for sprites
- OGG for compressed audio

### How do I report bugs?
1. **Check existing issues** to avoid duplicates
2. **Create new issue** on GitHub with:
   - Clear title describing the problem
   - Detailed steps to reproduce
   - Expected vs. actual behavior
   - System information and game version
   - Screenshots or error logs if applicable
   - Active mods list
   - Save file (if relevant)

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

### What's the development roadmap?
**Current Focus:**
- MVP features completion
- Core systems stability
- Performance optimization
- Bug fixing

**Future Plans:**
- Additional alien species
- More mission types
- Campaign events
- Improved AI
- Enhanced modding tools
- Multiplayer (maybe?)
- Mobile support (maybe?)

**Check GitHub:**
- Milestones for version goals
- Issues for tracked features
- Projects for organized development
- Discussions for community input

## Psionic Systems Questions

### What are psionics?
**Psionics** are mental powers that allow units to manipulate reality through thought alone. These rare and dangerous abilities include:
- **Offensive Powers**: Mind blast, panic broadcast, mind control
- **Defensive Powers**: Mind shield, telekinetic barrier, psi drain
- **Support Powers**: Mind link, psi healing, telekinetic lift

**Key Facts:**
- Only 5-10% of humans have measurable psionic potential
- Requires minimum PSI stat of 20 to begin training
- High risk, high reward gameplay mechanic
- Can turn tide of battle but risks user's sanity

### How do I train psionic soldiers?
**Training Requirements:**
1. **Build Psi Lab**: Special facility for psionic training
2. **Test Soldiers**: Screen recruits for PSI ≥20 potential
3. **Select Training Level**:
   - Basic (30 days, $50k, PSI ≥20): Fundamental abilities
   - Advanced (60 days, $200k, PSI ≥40): Powerful abilities
   - Master (120 days, $500k, PSI ≥60): Ultimate abilities
4. **Research Prerequisites**: May need specific tech unlocked
5. **Equip Psi Amp**: Required device for using psionic powers

**Training Results:**
- Unlock new psionic abilities
- Improve PSI stat through use
- Increase psionic stability (control)
- Specialize in ability trees

### What are the risks of using psionics?
**Dangers:**
- **Sanity Loss**: Overuse degrades mental health permanently
- **Psionic Backlash**: Failed attempts cause self-damage
- **Control Loss**: Total failure may harm self or allies
- **Energy Depletion**: Running out of psionic energy causes severe penalties
- **Enemy Counter-Psionics**: Alien psionics can dominate human minds
- **Instability**: Low stability increases all risk factors

**Risk Management:**
- Don't overuse abilities in single mission
- Train stability through successful use
- Keep psionic energy above 30%
- Use defensive psionics for protection
- Have backup plans if psionic soldier fails

### How does mind control work?
**Mind Control Mechanics:**
- **Energy Cost**: 50 points (very expensive)
- **Range**: 8 tiles
- **Duration**: 2-4 turns
- **Requirement**: Your PSI must exceed target's PSI
- **Success Rate**: Based on PSI difference

**Effects:**
- Take complete control of enemy unit
- Use their AP, weapons, and abilities
- Enemy acts on your turn
- Breaks on: controller death, range exceeded, duration ends

**Tactical Uses:**
- Control dangerous enemies (Sectopods, Mutons)
- Use enemy weapons against them
- Scout with controlled unit
- Block enemy advance with their own forces
- Force enemies to waste turns attacking controlled unit

**Counter-Measures:**
- Keep soldiers spread out
- High bravery reduces control duration
- Mind shield ability provides resistance
- Kill psionic enemies first
- High PSI soldiers harder to control

### How do I defend against alien psionics?
**Defensive Strategies:**

**Unit Attributes:**
- High Bravery stat resists panic attacks
- High PSI-STR provides natural resistance
- Mind Shield ability (+30% resistance)
- Mental Fortress for sustained protection

**Tactical Measures:**
- Kill psionic aliens (Sectoids, Ethereals) first priority
- Spread units to limit area effect impact
- Keep controlled units isolated
- Maintain high morale (reduces vulnerability)
- Use cover even against mental attacks (psychological)

**Equipment:**
- Psi Amp with defensive focus
- Mind Shield devices (if available)
- Stim packs to maintain morale

**Strategic Solutions:**
- Train your own psionics (offense is defense)
- Research psionic resistance technologies
- Screen for high-PSI recruits
- Build Psi Lab early in campaign

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

### What happens with Chryssalid infection?
**Infection Process:**
1. Chryssalid melee attack that kills soldier
2. Corpse becomes zombie (immediate)
3. Zombie is slow but durable
4. Zombie death spawns new Chryssalid

**Prevention:**
- Don't let soldiers die to Chryssalid attacks
- Keep distance (they're melee only)
- Use overwatch to kill approaching Chryssalids
- Explosives damage multiple Chryssalids

**Dealing with Zombies:**
- Kill quickly before they reach your troops
- Destroy corpses with fire/explosives
- Prevent Chryssalid spawn
- Consider sacrificing infected soldier
- Heavy weapons to ensure kills

**No Cure:**
- Once zombified, no recovery possible
- Must kill infected soldier/zombie
- Memorial wall honors their sacrifice

## Personnel and Training Questions

### How do I improve soldier stats?
**Experience System:**
- **Combat Actions**: Shooting, moving, killing gain XP
- **Successful Missions**: Completion bonus XP
- **Stat Increase**: Random rolls based on actions performed
  - Shooting improves Accuracy
  - Moving improves Mobility
  - Taking damage improves Health
  - Killing improves general stats

**Training Facilities:**
- Build Training Facility for accelerated skill gain
- Assign soldiers between missions
- Costs money but faster improvement
- Can focus on specific skills

**Equipment Effects:**
- Some armor increases stats (power armor STR boost)
- Weapons don't increase stats but grant experience
- Psi Amp required for psionic abilities

**Specialization:**
- Choose soldier class (Assault, Sniper, Heavy, Support)
- Class determines ability tree
- Unlocks unique abilities at rank thresholds
- Builds on soldier's natural strengths

### What's the difference between scientists and engineers?
**Scientists:**
- **Function**: Generate research points in laboratories
- **Purpose**: Unlock new technologies
- **Salary**: $2,000-3,000/month typically
- **Output**: Research progress per day
- **Specialization**: May have research focus bonuses
- **Result**: Knowledge (enables new options)

**Engineers:**
- **Function**: Generate manufacturing points in workshops
- **Purpose**: Produce equipment and items
- **Salary**: $1,500-2,500/month typically
- **Output**: Manufacturing progress per day
- **Specialization**: May have production focus bonuses
- **Result**: Physical items (weapons, armor, etc.)

**Hiring Strategy:**
- **Early Game**: More scientists (research advantage crucial)
- **Mid Game**: Balance both (need tech and production)
- **Late Game**: More engineers (produce advanced equipment)
- **Always**: Consider budget constraints

### Should I dismiss underperforming soldiers?
**Considerations:**

**Reasons to Dismiss:**
- Low stat growth after many missions
- Permanent injuries reducing effectiveness
- Severe psychological trauma
- Budget constraints (reduce salary costs)
- Making room for better recruits

**Reasons to Keep:**
- Experience and rank (veterans valuable)
- Specialized training (psionics, etc.)
- Squad bonds with other soldiers
- Memorial/story value
- Training new recruits (mentorship)

**Best Practices:**
- Keep veterans for training missions
- Rotate injured soldiers rather than dismiss
- Give second chances unless truly hopeless
- Consider stat boost items/upgrades
- Maintain squad morale (dismissals hurt)

**Economic Reality:**
- Every soldier costs monthly salary
- Can't afford unlimited roster
- Quality over quantity late game
- Balance nostalgia with effectiveness

## Craft and Interception Questions

### How do I win air combat?
**Interception Tactics:**

**Before Engagement:**
- Research better craft weapons (lasers, plasma)
- Upgrade craft armor
- Use multiple interceptors (2-3 vs large UFOs)
- Position bases for quick response

**During Combat:**
- **Aggressive**: Close distance, maximum damage, high risk
- **Standard**: Balanced approach, most common
- **Cautious**: Maintain distance, minimize damage, slow
- **Disengage**: Retreat if taking too much damage

**Weapon Choice:**
- **Cannons**: Short range, high damage, cheap
- **Missiles**: Long range, limited ammo, expensive
- **Lasers**: Unlimited ammo, medium damage
- **Plasma**: Best damage, expensive, research required

**Strategy:**
- Intercept small UFOs early for easy kills
- Gang up on large UFOs (Battleships, Terror Ships)
- Disengage if outmatched (repair and try again)
- Let some UFOs land (safer ground mission)

### When should I build more bases?
**Timing:**
- **Month 2-3**: Plan second base location
- **Month 4-5**: Build second base
- **Month 7-9**: Consider third base
- **Late Game**: 4-6 bases for global coverage

**Reasons for New Bases:**
- **Radar Coverage**: Detect UFOs in new regions
- **Response Time**: Faster interception and missions
- **Redundancy**: Backup if main base attacked
- **Specialization**: Research base, manufacturing base
- **Regional Presence**: Maintain funding in threatened areas

**Base Types:**
- **Main Base**: Full facilities, primary operations
- **Radar Station**: Minimal facilities, just detection and interceptors
- **Regional Hub**: Medium facilities, local response
- **Manufacturing Base**: Workshops and storage
- **Research Base**: Labs and containment

**Cost Considerations:**
- Each base costs $200k-500k+ to establish
- Monthly maintenance adds up
- Staff salaries for multiple bases
- Don't spread too thin

### What craft should I build first?
**Early Game Priority:**
1. **Second Interceptor**: Critical for UFO coverage
2. **Better Weapons**: Upgrade existing craft armament
3. **Transport Backup**: Redundancy for mission deployment

**Mid Game:**
4. **Advanced Interceptor**: Research-unlocked superior fighter
5. **Heavy Transport**: More soldiers per mission
6. **Scout Craft**: Extended radar and intelligence

**Late Game:**
7. **Elite Interceptors**: Alien-tech integrated fighters
8. **Specialized Craft**: Stealth, psionic dampening, etc.

**Don't Overbuild:**
- Each craft needs hangar space (limited)
- Maintenance and fuel costs add up
- Quality over quantity
- 2-3 interceptors per base usually sufficient
- 1-2 transports per base adequate

### How do I repair damaged aircraft?
**Repair System:**
- **Automatic**: Craft automatically repair at base
- **Time-Based**: Days required based on damage severity
- **Cost**: Materials and labor for repairs
- **Priority**: Critical damage repaired first

**Repair Time:**
- Light Damage (10-30%): 1-2 days
- Moderate Damage (31-60%): 3-5 days
- Heavy Damage (61-90%): 6-10 days
- Critical Damage (91-99%): 10-15 days

**Speed Factors:**
- Engineer count (more engineers = faster)
- Repair facilities (workshops help)
- Spare parts availability
- Craft complexity (alien tech slower)

**Strategy:**
- Rotate damaged craft out of service
- Have backup craft ready
- Don't send damaged craft into combat
- Preventive maintenance cheaper than major repairs

**Q: How do I manage craft fuel and range?**  
A: Fuel limits operational distance:
- **Fuel Capacity**: Each craft has maximum fuel
- **Consumption**: Depletes during flight, combat, and loitering
- **Range**: Can't reach distant UFOs without refueling
- **Refueling**: Automatic at base, instant
- **Strategy**: Build multiple bases for global coverage, or research long-range craft
- **Hyperwave Decoder**: Reveals UFO mission, allowing you to wait at base instead of chasing

## Difficulty & Campaign

**Q: What difficulty should I choose?**  
A: Depends on experience:
- **Easy/Rookie**: New to X-COM games, want forgiving experience. Higher accuracy, more funding, weaker enemies.
- **Normal/Veteran**: Default balanced challenge. Fair for experienced strategy gamers.
- **Hard/Commander**: Familiar with X-COM mechanics, want tough challenge. Less funding, smarter AI, stronger aliens.
- **Impossible/Legend**: Masochistic challenge for veterans. Extreme enemy stats, minimal resources, punishing.
- **Recommendation**: Start Normal, adjust next campaign based on experience. Can't change mid-campaign.

**Q: What is Ironman mode?**  
A: Hardcore permadeath challenge:
- **Single Save**: Only one save file, overwrites automatically
- **No Save Scumming**: Can't reload to undo bad decisions or luck
- **Permanent Consequences**: Dead soldiers, failed missions, bankruptcy all permanent
- **Strategic Depth**: Forces careful play, risk management, and contingency planning
- **Achievement**: Ultimate challenge for skilled players
Not recommended for first playthrough—learn game mechanics first on regular mode.

**Q: What are the victory conditions?**  
A: Depends on campaign mode:
- **Mission Victory**: Complete tactical objectives (eliminate enemies, rescue VIP, destroy UFO, etc.)
- **Strategic Victory** (if implemented): Defeat alien invasion through research milestones and final mission (alien base, mothership, etc.)
- **Sandbox Mode**: No fixed victory—play indefinitely managing earth defense
- **Defeat Conditions**: All bases lost, bankruptcy (negative funds for extended period), all council nations withdrawn
- **Open-Ended**: Many campaigns designed as endless management simulation rather than story with ending

**Q: Can I keep playing after "winning"?**  
A: Depends on campaign type:
- **Sandbox Mode**: No victory condition, play indefinitely by design
- **Story Mode** (if implemented): Beating final mission may end campaign or allow continuation
- **New Game+**: Some implementations allow post-victory play with increased difficulty and retained tech
- **Configuration**: Check campaign settings to understand victory/defeat conditions
AlienFall leans toward open-ended sandbox design inspired by early X-COM games.

**Q: What is campaign progression and pacing?**  
A: Campaign evolves through phases:
- **Early Game (Months 1-3)**: Establish base, research basics, handle light UFO activity, build economy
- **Mid Game (Months 4-8)**: Face tougher aliens, research advanced tech, expand bases, manage multiple regions
- **Late Game (Months 9+)**: Heavy UFO waves, dangerous alien types, power armor, plasma weapons, ultimate threats
- **Difficulty Scaling**: Aliens get stronger equipment and stats over time
- **Milestones**: Key research (alien containment, plasma weapons, psi-lab) gates progression
- **Pacing**: Balance aggressive research vs economic stability, expand vs consolidate

**Q: How does adaptive difficulty work?**  
A: AI adjusts to your performance (if enabled):
- **Success Tracking**: Monitors mission outcomes, funding, research speed
- **Dynamic Scaling**: Increases difficulty if you're dominating, reduces if struggling
- **Adjustments**: Modifies enemy stats, UFO frequency, mission complexity, funding changes
- **Goal**: Maintain challenging but not impossible experience
- **Trade-Off**: Prevents runaway victories but may feel artificial
- **Option**: Typically optional feature, can disable for static difficulty

## Terrain & Map Systems

**Q: How does terrain affect tactical combat?**  
A: Major impact on tactics:
- **Cover**: High cover (walls, vehicles) provides -40 accuracy penalty to enemies, low cover (fences, barrels) -20
- **Elevation**: High ground provides +10-20 accuracy bonus and extended vision
- **Movement Cost**: Roads cost 1 AP per tile, rubble/water cost 2-3 AP, impassable terrain blocks completely
- **Visibility**: Fog, darkness, dense vegetation reduce sight range
- **Destructible**: Explosives destroy walls and cover, opening new paths
- **Environmental Hazards**: Fire, smoke, toxic areas cause damage or status effects
Adapt tactics to terrain type.

**Q: What are the different terrain types?**  
A: Many environment categories:
- **Urban**: Cities with multi-story buildings, dense cover, close-quarters combat
- **Rural**: Farms, forests, villages—open spaces with scattered cover
- **Desert**: Sandy/rocky areas, minimal cover, extreme temperature
- **Arctic**: Snow and ice, visibility and movement challenges
- **Jungle**: Dense vegetation, limited line of sight, difficult movement
- **Industrial**: Factories and warehouses, large structures and machinery hazards
- **Alien**: UFO crash sites and bases, exotic materials and technology
- **Underground**: Caves, tunnels, sewers—enclosed spaces with limited exits
Each type requires different tactical approaches.

**Q: Are maps procedurally generated or fixed?**  
A: Hybrid approach:
- **Procedural Generation**: Most maps use modular blocks combined algorithmically
- **Map Blocks**: Pre-designed 10x10 or 20x20 tile segments
- **Assembly**: Blocks connected via connection points to create full battlefield
- **Variation**: Same mission type generates different layouts each time
- **Prefabs**: Some story missions or special locations use fixed pre-designed maps
- **Seeded**: Can use specific seed for reproducible maps (testing or challenge runs)
Provides variety while maintaining quality and balance.

**Q: Can I destroy terrain?**  
A: Yes, explosive destruction:
- **Destructible Terrain**: Walls, doors, cover, vehicles can be destroyed
- **Explosives**: Grenades, rockets, HE rounds, demo charges all cause terrain damage
- **Tactical Use**: Create new paths, remove enemy cover, breach buildings
- **Line of Sight**: Destroying walls opens sight lines
- **Trade-Off**: Also destroys your own cover and potential loot
- **Indestructible**: Some terrain (reinforced walls, natural rock) may be unbreakable
Strategic use of explosives is key to advanced tactics.

**Q: How do multi-level maps work?**  
A: Vertical battlefield layers:
- **Floors**: Multiple levels connected by stairs, ramps, or elevators
- **Navigation**: Must use connection points to move between levels
- **Line of Sight**: Can shoot through floors at vertical angles if no obstruction
- **Falling Damage**: Destroying floor under unit causes fall and injury
- **Tactical Depth**: Vertical flanking, high ground advantage, multi-level ambushes
- **Complexity**: Harder to track enemy positions across levels
Common in urban, alien base, and ship interior missions.

## Soldier Management & Survivability

**Q: How does the injury system work?**  
A: Injuries affect availability and stats:
- **Injury Severity**: Minor (1-3 days recovery), Serious (5-10 days), Critical (15-30 days), Fatal (instant death)
- **Caused By**: Taking damage in combat, especially from powerful hits
- **Recovery**: Wounded soldiers unavailable for missions during healing
- **Stat Penalties**: Temporary attribute reduction while recovering
- **Medical Bay**: Base facility speeds recovery and prevents permanent injuries
- **Permanent Damage**: Critical injuries risk permanent stat loss
- **Risk Management**: Don't let soldiers take excessive damage, prioritize medical research

**Q: What is fatigue and how does it work?**  
A: Exhaustion from combat stress:
- **Accumulation**: Builds during long missions, consecutive deployments, intense combat
- **Fatigue Levels**: Fresh (no penalties) → Tired (-5-10% stats) → Exhausted (-15-30% stats, high panic/injury risk)
- **Recovery**: Rest days between missions, faster with recreation facilities
- **Penalties**: Reduced accuracy, reactions, mobility, and morale
- **Management**: Rotate soldiers, avoid deploying exhausted troops
- **Squad Pool**: Maintain multiple teams so some can rest while others deploy
Critical for long campaigns with frequent missions.

**Q: Should I rotate my soldiers or use my best team every mission?**  
A: Rotation recommended:
- **Fatigue Management**: Prevents exhaustion and performance degradation
- **Injury Backup**: If A-team gets wounded, have trained B-team ready
- **Experience Spread**: Develops multiple skilled soldiers instead of few experts
- **Death Insurance**: Losing your only veteran squad is campaign-ending
- **Specialization**: Can field specialized squads for different mission types
- **Trade-Off**: Lower performance from less experienced soldiers, more salaries
Balance depends on mission frequency and soldier availability.

**Q: How do armor types compare?**  
A: Progression from weak to strong:
1. **No Armor**: 0 protection, starting soldiers
2. **Tactical Vest**: 10-20 armor, cheap but weak, early game
3. **Carapace Armor**: 30-40 armor, mid-game using alien materials
4. **Titan Armor**: 50-60 armor, heavy conventional armor, reduced mobility
5. **Power Suit**: 60-70 armor + strength boost, advanced exoskeleton
6. **Ghost Armor**: 40-50 armor + stealth capability, light and mobile
7. **Flying Armor**: 70-80 armor + flight, ultimate mobility and protection

**Trade-offs**: Heavy armor = better protection but slower movement. Light armor = mobility but less protection. Choose based on soldier role (scout = ghost, tank = titan).

**Q: What happens if my best soldier dies?**  
A: Permanent loss, prepare for it:
- **Permadeath**: Dead soldiers gone forever (unless Save Scumming in non-Ironman)
- **Impact**: Lose all experience, stats, and bonuses
- **Psychological**: Can be demoralizing, especially veteran soldiers
- **Recovery**: Recruit replacement, will start inexperienced
- **Prevention**: Better armor, careful tactics, medical kits, avoid unnecessary risks
- **Ironman**: No reload option, must live with consequences
This is why soldier rotation and backup teams are critical.

## Aliens & Combat Enemies

**Q: What alien species will I fight?**  
A: Many species with different roles:
- **Sectoids**: Weak grey aliens with psionic powers. Scouts and leaders, easy early targets.
- **Mutons**: Heavy assault troops. High health, armor, and aggression. Tough mid-game enemies.
- **Floaters**: Flying aliens with jetpacks. Ranged attackers, use terrain advantage.
- **Snakemen**: Reptilian aliens with poison. Ambush tactics, dangerous melee.
- **Chryssalids**: Fast melee terrors that zombify victims. Priority threat, kill on sight.
- **Ethereals**: Advanced psionic masters. Fragile but devastating psionics. Late-game leaders.
- **Cyberdiscs**: Robotic flying discs. Heavy armor and weapons, explode when destroyed.
Each species requires different tactical approaches.

**Q: How does alien AI work?**  
A: Intelligent tactical behavior:
- **Cover Usage**: Aliens seek high cover and defensible positions
- **Flanking**: Enemies attempt to get around your cover
- **Suppression**: Aliens use suppressing fire to pin you down
- **Grenade Use**: AI throws grenades at clustered soldiers
- **Pod System**: Aliens activate in groups (2-4 units) when spotted
- **Aggression Levels**: Varies by species (Chryssalids charge, Sectoids hang back)
- **Priority Targeting**: AI focuses on exposed or wounded soldiers
AI gets smarter on higher difficulties.

**Q: What are alien pods and how do they activate?**  
A: Dormant alien groups:
- **Pod**: 2-4 aliens grouped together, initially dormant
- **Activation**: Pod "wakes up" when you spot them or they take their turn
- **Patrol**: Dormant pods may patrol area on predictable routes
- **Simultaneous Activation**: All aliens in pod activate at once, potentially multiple turns
- **Multiple Pods**: Maps contain several pods, activating one doesn't alert others
- **Strategic Challenge**: Control engagement timing, avoid activating multiple pods
Fight one pod at a time when possible.

**Q: What's the difference between laser and plasma weapons?**  
A: Two advanced weapon tiers:
- **Laser Weapons** (Mid-game):
  - Unlimited ammo (no reloading)
  - Good accuracy and moderate damage
  - Faster research and cheaper manufacturing
  - Intermediate upgrade from ballistics
- **Plasma Weapons** (Late-game):
  - High damage, best in game
  - Good accuracy, armor penetration
  - Requires alien corpses/alloys
  - Expensive and slow to research/build
- **Progression**: Ballistics → Lasers → Plasma
- **Strategy**: Laser for economy, plasma for maximum power

**Q: Should I use explosives in combat?**  
A: Yes, but carefully:
- **Advantages**: Area damage, destroys cover, kills multiple enemies, creates breach points
- **Disadvantages**: Destroys loot, damages your cover, friendly fire risk, limited ammo
- **Grenade Types**: Frag (damage), smoke (concealment), incendiary (fire/DoT), flashbang (stun)
- **Rockets**: Heavy area damage, destroys terrain, limited shots
- **Demo Charges**: Maximum demolition, must be placed manually
- **Tactical Use**: Remove enemy cover, flush out enemies, destroy Cyberdiscs before explosion
Balance destruction with loot preservation.

## Weapons & Equipment

**Q: What firing modes should I use?**  
A: Depends on situation:
- **Snap Shot**: Low AP cost, reduced accuracy. Use for reaction fire, flanking, finishing wounded enemies.
- **Single Shot**: Balanced AP and accuracy. Standard fire mode for most engagements.
- **Aimed Shot**: High AP cost, accuracy bonus. Use on distant targets, critical shots, high-value enemies.
- **Burst Fire**: 3-5 rounds, moderate AP. Good damage against unarmored enemies, wastes ammo.
- **Auto Fire**: Full magazine, terrible accuracy. Suppression or panic fire, rarely effective.
Aimed shots for precision, snap shots for action economy.

**Q: What equipment should I bring on missions?**  
A: Loadout priorities:
1. **Primary Weapon**: Rifle, shotgun, or sniper based on role
2. **Armor**: Best available that fits role (heavy for tanks, light for scouts)
3. **Grenades**: At least one per soldier (frag or smoke)
4. **Medical Kit**: 1-2 per squad for healing
5. **Specialist Gear**: Motion scanner (scout), extra ammo (heavy), mind shield (psionic defense)
6. **Utility**: Electro-flares for night missions, proximity mines for defense

**Avoid**: Overpacking (reduces TU/mobility), redundant items, untested experimental gear on critical missions.

**Q: How does weapon accuracy work with aimed/snap shots?**  
A: Accuracy modifiers stack:
- **Base Accuracy**: Soldier's accuracy stat (50-90+)
- **Weapon Accuracy**: Inherent weapon modifier (-10 to +20)
- **Firing Mode**: Snap shot (-10 to -20), aimed shot (+10 to +30)
- **Range**: Accuracy drops beyond effective range
- **Cover**: Target in high cover (-40 to hit)
- **Stance**: Kneeling provides accuracy bonus
- **Formula**: Base + Weapon + Mode + Range + Cover + Stance = Final %
Aimed shots compensate for range/cover penalties.

## Time & Strategic Systems

**Q: What's the difference between Time Units and Action Points?**  
A: Two action cost systems:
- **Time Units (TU)**: Granular classic X-COM system. Each action costs specific TU (move 1 tile = 1 TU, shoot rifle = 30 TU). Total pool 50-100 TU.
- **Action Points (AP)**: Abstract modern system. Actions cost 1-3 AP (move = 1 AP, shoot = 2 AP). Total pool 8-12 AP.
- **Design Trade-off**: TU more flexible and realistic, AP simpler and more accessible.
- **AlienFall**: May use TU for authenticity, or AP for accessibility, or hybrid system.
Check game configuration for which system is active.

**Q: How does time acceleration work on the Geoscape?**  
A: Control strategic time pace:
- **1x Speed**: Real-time, normal pace
- **5x Speed**: Moderate fast-forward
- **30x Speed**: Rapid time compression
- **Maximum**: Instant skip to next event
- **Auto-Pause**: Stops automatically on UFO detection, research complete, mission available, base attacked
- **Manual Pause**: Press pause anytime for planning
- **Strategy**: Use high speed between events, pause for decisions
Prevents tedious waiting but maintains strategic tension.

**Q: Should I save frequently or rely on autosaves?**  
A: Depends on mode and preference:
- **Normal Mode**: Manual save frequently (before missions, after major decisions, monthly). Autosave is backup.
- **Ironman Mode**: Autosave only, single file. No manual saves, can't reload bad outcomes.
- **Quicksave**: Use for quick checkpoints, but creates save scumming temptation.
- **Save Slots**: Use multiple slots for different strategies or fallback points.
- **Save Corruption**: Rare but possible, keep backups of important saves.
- **Best Practice**: Manual save before risky missions, after major achievements, at month start.
Ironman eliminates save scumming but increases stakes.

**Q: How does the world map/territory control work?**  
A: Strategic globe interface:
- **3D Globe**: Rotating earth showing continents, countries, bases, UFOs
- **Territory Control**: Regions marked as player-controlled, alien-controlled, or contested
- **Funding Impact**: Controlled regions provide monthly funding
- **Radar Coverage**: Circles showing detection range from bases and craft
- **Coverage Gaps**: Areas outside radar where UFOs operate undetected
- **UFO Markers**: Real-time icons showing UFO positions and flight paths
- **Activity Heatmap**: Visual overlay showing alien activity intensity
- **Base Icons**: Show your base locations and operational status
- **Strategic Goal**: Maintain radar coverage, control key territories, intercept UFOs
Territory loss reduces funding and increases alien strength.

**Q: What is the core game loop?**  
A: Cyclical gameplay across three layers:
1. **Geoscape**: Monitor world map, detect UFOs, launch interception
2. **Interception**: Air combat, shoot down or scare off UFO
3. **Battlescape**: Tactical ground mission at crash site, alien base, or terror site
4. **Loot & XP**: Recover alien materials, weapons, corpses. Soldiers gain experience.
5. **Basescape**: Research alien tech, manufacture equipment, build facilities, manage personnel
6. **Repeat**: Stronger aliens appear, escalating challenge, requiring better tech

**Feedback Loops:**
- Positive: Better gear → easier missions → more resources → even better gear
- Negative: High performance → aliens send tougher forces → harder missions
This creates engaging risk-reward gameplay cycle.

**Q: What happens if aliens attack my base?**  
A: Base defense mission triggers:
- **Warning**: Security facility may detect impending attack
- **Defender Deployment**: Your soldiers at base defend (limited by barracks capacity)
- **Tactical Mission**: Battlescape using your actual base layout as map
- **Objectives**: Eliminate all aliens, protect facilities
- **Consequences**: 
  - **Victory**: Repel attack, salvage alien loot
  - **Defeat**: Facility destruction, personnel casualties, equipment loss, possible game over if only base
- **Defense Rating**: Automatic defense towers engage before tactical mission. High rating may repel attack without battle.
Build defense facilities and keep trained guards at bases.

**Q: How does base storage work?**  
A: Limited capacity management:
- **Storage Capacity**: Each base has maximum item slots (based on storage facilities)
- **Categories**: Weapons, armor, materials, consumables, alien artifacts, corpses
- **Overflow**: If full, can't manufacture more, mission loot may be lost
- **Expansion**: Build more storage facilities (General Stores, Cold Storage)
- **Alien Containment**: Special storage for live aliens (research subjects)
- **Inter-Base Transfer**: Move equipment between bases (costs time and money)
- **Management**: Sell excess items, prioritize valuable equipment, distribute across multiple bases
Running out of storage blocks progression—monitor carefully.

**Q: What are council reports and how do they affect funding?**  
A: Monthly performance reviews:
- **Timing**: End of each month, council evaluates your performance
- **Metrics**: Missions completed, UFOs shot down, civilians saved, aliens killed, research progress
- **Ratings**: Excellent → Good → Fair → Poor → Terrible
- **Consequences**:
  - **Good**: Increased monthly funding, access to more soldiers/equipment
  - **Poor**: Reduced funding, nation may withdraw from council
  - **Terrible**: Multiple nations withdraw, funding crisis, possible game over
- **Nation Panic**: Individual countries have panic levels. High panic = withdrawal risk.
- **Strategy**: Balance mission types, protect all regions, maintain consistent performance
Losing too many council nations ends the campaign in some modes.

**Q: What's the difference between a crash site and an alien base mission?**  
A: Mission difficulty and rewards:
- **Crash Site**:
  - UFO shot down by interception
  - Time-limited (UFO self-destructs or aliens evacuate after ~24 hours)
  - Moderate difficulty, damaged aliens, salvage rewards
  - Random small/medium maps
- **Alien Base**:
  - Permanent alien installation underground
  - Can assault anytime once detected
  - Very high difficulty, full-strength aliens, command units, Cyberdiscs
  - Large multi-level maps with defensive positions
  - High rewards: alien tech, artifacts, disrupts alien operations, reduces panic
- **Strategy**: Crash sites for routine farming, alien bases for major strategic impact
Alien bases significantly harder—come prepared with best equipment.

**Q: How do I unlock advanced weapons and armor?**  
A: Research and manufacturing progression:
1. **Capture Aliens/UFOs**: Shoot down UFOs, capture aliens alive
2. **Research Prerequisites**: Alien Containment (to interrogate), Alien Weapons, Alien Alloys
3. **Specific Research**: Laser Weapons → Laser Rifle, Carapace Armor → Carapace Suit, etc.
4. **Manufacturing**: Build items using resources and engineer time
5. **Tech Tree**: Some items require multiple research chains (Plasma needs Elerium, which needs UFO Power Source, which needs captured UFO)

**Key Milestones:**
- Alien Containment (enables interrogation)
- Laser Weapons (mid-game weapon tier)
- Carapace/Titan Armor (mid-game protection)
- Plasma Weapons (late-game weapons)
- Power Armor (late-game protection)
- Psi-Lab (psionics access)

Focus research on next tier of weapons/armor for combat advantage.

## Advanced Tactical Combat

**Q: How does line of sight work?**  
A: Vision and visibility system:
- **LOS Calculation**: Raycasts from unit to target checking for obstructions
- **Blocking Terrain**: Walls block fully, smoke partially blocks, windows allow through
- **Sight Range**: Based on unit vision stat (10-20 tiles typical), reduced at night
- **Fog of War**: Black = unexplored, grey = previously seen, clear = currently visible
- **Height Advantage**: Elevation extends vision range and provides accuracy bonus
- **Asymmetric LOS**: Stealth/camouflage lets you see enemies without them seeing you
- **Required for Combat**: Must have LOS to shoot (except blind fire with severe penalty)
Use LOS preview before moving to avoid exposing soldiers unnecessarily.

**Q: What's the difference between cover and concealment?**  
A: Critical distinction:
- **Cover**: Physical protection reducing damage. High cover (-40 accuracy to enemies), low cover (-20 accuracy).
- **Concealment**: Visual obstruction blocking line of sight. Smoke, darkness, fog—enemies can't see you.
- **Cover Provides Both**: Walls give cover (damage reduction) and concealment (blocks LOS if opaque).
- **Smoke = Concealment Only**: Blocks vision but doesn't stop bullets. Shooting through smoke hits if lucky.
- **Tactical Use**: Smoke for movement, cover for firefights. Combine for maximum safety.
Breaking enemy LOS with smoke is often better than partial cover.

**Q: How does reaction fire/overwatch work?**  
A: Enemy turn interruption system:
- **Reaction Fire**: Shooting during enemy turn when they move into view
- **Reserved AP**: Must save AP/TU from your turn for reactions (trade-off)
- **Overwatch Mode**: Actively aim at area, auto-shoot first enemy entering
- **Reaction Stat**: High reactions = faster and more frequent reaction shots
- **Accuracy Penalty**: Reaction shots less accurate than aimed shots (snap fire)
- **Suppression Counter**: Suppressed units can't reaction fire effectively
- **Strategy**: Position soldiers in overwatch to cover chokepoints and approaches
Reserve 25-50% of AP for reactions on defensive missions.

**Q: What triggers panic and how do I prevent it?**  
A: Morale breakdown system:
- **Panic Triggers**: Seeing allies die, taking heavy damage, being suppressed, witnessing terror units (Chryssalids), psionic attacks
- **Panic Check**: Roll when morale drops below threshold (based on bravery stat)
- **Panic Effects**: Flee uncontrollably, cower, drop weapon, shoot randomly, or go berserk
- **Prevention**:
  - High bravery soldiers (veterans, officers)
  - Commander/leader presence (morale aura)
  - Avoid seeing allies die (spread out, don't cluster)
  - Kill threats quickly (especially terror units)
  - Use psionics defense (mind shields)
- **Recovery**: Morale recovers slowly over turns, faster with successful actions
Rookies panic easily—don't send them against terror missions.

**Q: How do smoke grenades work and when should I use them?**  
A: Concealment tool:
- **Effect**: Creates smoke cloud blocking line of sight for 3-5 turns
- **Concealment Only**: Doesn't stop bullets, just prevents enemies from seeing/targeting
- **Duration**: Dissipates gradually over turns, wind affects spread
- **Tactical Uses**:
  - Cover retreats (break LOS while falling back)
  - Safe advances (move through smoke without being shot at)
  - Disrupt overwatch (enemies can't see through smoke)
  - Rescue wounded (obscure medic and patient)
  - Mark locations (colored smoke variants)
- **Limitations**: Enemies inside smoke can still see/shoot at close range
- **Combo**: Smoke + flanking = move safely then attack from unexpected angle
Every soldier should carry at least one smoke grenade.

**Q: How does fire spread and how do I use it tactically?**  
A: Area denial and damage-over-time:
- **Fire Sources**: Incendiary grenades, flamethrowers, explosive secondary effects
- **Spreading**: Fire moves to adjacent flammable tiles (wood, grass, fuel)
- **Damage**: Units standing in fire take 5-10 damage per turn
- **Duration**: Burns for 5-10 turns, creates smoke automatically
- **Tactical Uses**:
  - **Area Denial**: Block enemy paths, force them into kill zones
  - **Flush Enemies**: Burn them out of entrenched positions
  - **DoT Damage**: Injure clustered enemies over time
  - **Destroy Cover**: Burn wooden structures, remove enemy protection
- **Risks**: Can trap your own soldiers, destroys loot, friendly fire hazard
- **Counters**: Avoid flammable terrain, move before fire reaches you, use fire-resistant armor
Effective against stationary enemies or chokepoint defense.

**Q: What is auditory detection and how does sound work?**  
A: Hearing-based awareness:
- **Sound Sources**: Gunfire (loud), footsteps (quiet), alien sounds, explosions (very loud)
- **Sound Radius**: Distance sound travels (gunshots 10-15 tiles, footsteps 3-5 tiles)
- **Through Walls**: Sound muffled but still detectable through obstacles
- **Detection**: Enemies hear sounds and investigate (? marker on map)
- **Tactical Implications**:
  - **Suppressed Weapons**: Reduced sound radius, stealthier kills
  - **Silent Takedowns**: Melee or stun rod avoids alerting nearby aliens
  - **Noise Distraction**: Deliberately make sound to lure enemies away
  - **Stealth Movement**: Move slowly to reduce footstep noise
- **AI Behavior**: Aliens investigate sounds, may call reinforcements
Silence is golden when facing multiple alien pods.

**Q: How does lighting affect combat at night?**  
A: Darkness and illumination:
- **Night Missions**: Drastically reduced sight range, accuracy penalties in darkness
- **Light Sources**: Flashlights (personal), flares (area, temporary), building lights, explosions
- **Visibility**: Well-lit areas = normal sight, darkness = reduced sight and accuracy
- **Stealth**: Staying in shadows provides concealment bonus, harder for enemies to spot
- **Equipment**:
  - **Flashlight**: Personal light, reveals area but exposes your position
  - **Flare**: Thrown, large radius, lasts 3-5 turns
  - **Night Vision**: See in darkness without light source (expensive equipment)
- **Tactics**: Destroy enemy lights for advantage, use flares before breaching, keep some soldiers with night vision
Night missions are much harder—bring illumination or night vision gear.

**Q: What's the best way to set up an overwatch trap?**  
A: Ambush positioning:
1. **Chokepoint Identification**: Find narrow passage enemies must cross (door, corridor, gap)
2. **Multiple Angles**: Position 2-4 soldiers with overlapping overwatch cones
3. **Reserve AP**: Each soldier needs 30-50% AP saved for reaction fire
4. **High Ground**: Elevate for accuracy bonus and extended vision
5. **Smoke Screening**: Hide your positions with smoke, enemy walks into trap blind
6. **Bait Setup**: One visible soldier lures enemies into kill zone
7. **Crossfire**: Ensure multiple soldiers can hit same target simultaneously
8. **Patience**: Wait for enemies to enter zone before triggering

**Result**: First enemy stepping into zone gets 3-4 simultaneous reaction shots. Devastating.

**Q: What should I prioritize for loot after missions?**  
A: Recovery priorities:
1. **Alien Artifacts**: Elerium, UFO Power Sources, Alien Alloys—essential for research
2. **Alien Corpses**: Research requirements (need Sectoid body for autopsy)
3. **Intact Weapons**: Plasma rifles, heavy plasmas—valuable for use or research
4. **Live Captures**: Captured aliens (highest research value, requires containment)
5. **Damaged Equipment**: Still has value, just reduced
6. **Common Items**: Low priority, sell excess for credits

**Capacity Management:**
- Large transports carry more loot (Skyranger < Avenger)
- Leave behind common items if limited space
- Prioritize mission-specific artifacts (power sources from UFOs)
- Dead soldiers' equipment auto-recovered

Always recover corpses and artifacts—these enable tech progression.

## Technical & Modding

**Q: What is TOML and why is it used for configuration?**  
A: Human-readable config format:
- **TOML**: Tom's Obvious Minimal Language—config file format similar to INI
- **Advantages**:
  - **Human-Readable**: Easy to edit in text editor
  - **Structured**: Tables, arrays, nested data support
  - **Safe**: Can't execute code (unlike Lua), prevents malicious mods
  - **Comments**: Document settings with # comments
  - **Version Control Friendly**: Clean diffs, easy merges
- **Usage in AlienFall**: Unit stats, weapons, facilities, research, difficulty settings all defined in TOML
- **Example**:
```toml
[weapons.rifle]
name = "Assault Rifle"
damage = 30
accuracy = 70
ap_cost = 40
```
- **Modding**: Mods override TOML values without coding
Easy for non-programmers to create content mods.

**Q: How do I debug issues or errors in the game?**  
A: Debugging techniques:
1. **Run with lovec.exe**: Console version showing print output and error messages
2. **Check Error Messages**: Stack trace shows exactly where error occurred
3. **Print Debugging**: Add `print()` statements to track variable values
4. **Logger Module**: Use logging system for structured debug output
5. **Common Errors**:
   - **Nil Value**: Accessing undefined variable—check initialization
   - **Type Mismatch**: Number vs string error—check data types
   - **Missing File**: Check file paths, case sensitivity
6. **Performance Issues**: Profile frame rate, check for infinite loops
7. **Save/Load Bugs**: Test with fresh save, check serialization

**Console Command**: `lovec.exe .` runs game with debug console visible.

**Q: What's the difference between content mods and script mods?**  
A: Two modding approaches:
- **Content Mods** (TOML-based):
  - Edit game data without programming
  - Change stats, add weapons/units, adjust balance
  - Safe—can't crash game or execute malicious code
  - Easy to create—just edit text files
  - Example: Increase rifle damage from 30 to 35
- **Script Mods** (Lua-based):
  - Program new mechanics and systems
  - Create custom abilities, AI behaviors, mission types
  - Full game access via mod API
  - Requires programming knowledge
  - Riskier—errors can crash game
  - Example: New psionic ability with custom effects

**Recommendation**: Start with content mods, progress to scripts for advanced features.

**Q: How do tooltips work and what information do they show?**  
A: Contextual help system:
- **Trigger**: Hover mouse over UI element for 0.5-1 seconds
- **Content**: Title, description, stats, keyboard shortcuts, formulas
- **Smart Positioning**: Auto-adjusts to stay on screen, avoids edges
- **Context-Sensitive**: Different info based on what you're hovering
  - **Units**: Stats, status effects, morale, equipment
  - **Weapons**: Damage, accuracy, AP cost, range
  - **Abilities**: Effect description, AP/TU cost, cooldown
  - **Facilities**: Build cost, time, upkeep, effects
  - **Research**: Prerequisites, time, unlock benefits
- **Comparison Tooltips**: Hold Shift to compare items side-by-side
- **Dismiss**: Move mouse away or click elsewhere

Tooltips are primary information source—use them liberally.

**Q: What are notifications and how do I manage them?**  
A: Event alert system:
- **Types**:
  - **Pop-ups**: Full-screen, requires acknowledgment (base attacked)
  - **Banners**: Top-screen, auto-dismiss after 5-10 seconds (research complete)
  - **Toasts**: Small corner messages, brief display (soldier promoted)
- **Priority Levels**:
  - **Critical** (red): Urgent threats (UFO attacking base)
  - **Warning** (yellow): Important events (funding drop)
  - **Info** (blue): General updates (facility built)
  - **Success** (green): Achievements (mission victory)
- **Notification Queue**: Multiple notifications shown in sequence
- **Message Log**: View history of all past notifications
- **Settings**: Filter notification types, adjust frequency
- **Audio Cues**: Sound effects for different priority levels

Critical notifications pause game on Geoscape.

**Q: How does the widget system work for UI?**  
A: Reusable UI component architecture:
- **Widgets**: Modular UI elements (buttons, panels, lists, text boxes)
- **Hierarchy**: Parent-child structure (window contains panels, panels contain buttons)
- **Types**:
  - **Interactive**: Accept input (buttons, sliders, checkboxes)
  - **Display**: Show information (labels, icons, progress bars)
  - **Container**: Hold other widgets (panels, windows, tabs)
- **Events**: User interactions trigger callbacks (click, hover, focus)
- **Layouts**: Positioning systems (absolute, relative, flex, grid)
- **Styling**: Consistent visual theme (16x16 pixel art upscaled to 32x32)
- **Reusability**: Same widget code used across game screens
- **Modding**: Mods can create custom widgets for new UI elements

Located in `widgets/` directory—study for custom UI development.

**Q: What Love2D callbacks are most important for game development?**  
A: Core Love2D functions:
- **love.load()**: Initialization—runs once at startup. Load assets, set up game state.
- **love.update(dt)**: Game logic—runs every frame. dt = delta time (seconds since last frame). Update positions, AI, timers.
- **love.draw()**: Rendering—runs every frame after update. Draw everything to screen.
- **love.keypressed(key)**: Keyboard input—runs when key pressed. Handle player commands.
- **love.mousepressed(x, y, button)**: Mouse input—runs on click. Handle UI interactions.
- **love.quit()**: Cleanup—runs when game closes. Save data, release resources.

**Flow**: load → (update → draw) loop → quit

**Delta Time (dt)**: Multiply movement/changes by dt for frame-independent speed. Example: `position = position + velocity * dt`

**Q: How do I test my changes or mod?**  
A: Testing workflow:
1. **Enable Mod**: Mod menu in game, check your mod
2. **Start Fresh**: New game for most changes (saves may have old data)
3. **Console Output**: Run with `lovec.exe` to see debug prints and errors
4. **Verify Changes**: Test all modified features
5. **Edge Cases**: Try unusual inputs, boundary conditions
6. **Performance**: Monitor frame rate (should stay 60 FPS)
7. **Save/Load**: Test saving and loading with your changes
8. **Mod Conflicts**: Test with/without other mods

**Iterative Testing**: Make small changes, test frequently. Don't accumulate untested code.

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

### How do TOML mods work?
**TOML Configuration:**
- Human-readable format for data
- Defines game content declaratively
- No programming required for simple mods
- Overrides or extends base game data

**Example: Modify Rifle Stats**
```toml
[weapons.rifle]
name = "Assault Rifle"
damage = 35  # Increased from 30
accuracy = 75  # Increased from 70
ap_cost = 40
range = 20
ammo_capacity = 30
```

**Benefits:**
- Easy to create and understand
- Safe (can't crash game with syntax errors)
- Version control friendly
- Quick iteration and testing

### How do Lua script mods work?
**Lua Scripting:**
- Programming language for advanced mods
- Full access to game systems via API
- Event-driven architecture
- Can create entirely new features

**Example: Custom Ability**
```lua
-- Register new ability
function mod.init()
  game.abilities.register({
    id = "my_mod:super_shot",
    name = "Super Shot",
    ap_cost = 50,
    cooldown = 3,
    effect = function(user, target)
      -- Custom logic here
      local damage = user.accuracy * 2
      target:takeDamage(damage)
    end
  })
end
```

**Use Cases:**
- Complex game mechanics
- Dynamic content generation
- AI modifications
- Custom mission types
- Special events

### What are mod dependencies?
**Dependencies:**
- Mods that must be loaded before your mod
- Ensures required content/systems exist
- Prevents conflicts and crashes

**In mod.toml:**
```toml
[mod]
name = "My Expansion"
version = "1.0.0"
dependencies = [
  "core_game >= 1.0.0",
  "base_expansion >= 2.1.0"
]
```

**Dependency Types:**
- **Required**: Mod won't load without it
- **Optional**: Mod adapts if present
- **Conflicts**: Mod incompatible with another
- **Load Order**: Sequence matters for overrides

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

### Can I combine multiple mods?
**Yes, with considerations:**

**Compatibility Factors:**
- **Content Conflicts**: Two mods changing same item
- **ID Collisions**: Unique identifiers must not overlap
- **Script Conflicts**: Lua hooks competing
- **Load Order**: Later mods override earlier ones
- **Dependencies**: All required mods must be present

**Best Practices:**
- Read mod descriptions for compatibility notes
- Test combinations before committing to playthrough
- Disable mods one at a time if issues arise
- Check load order in mod menu
- Use mod manager tools if available

**Load Order Example:**
1. Core fixes (bug fixes first)
2. Major overhauls (total conversions)
3. Content expansions (new units/weapons)
4. Balance mods (stat adjustments)
5. Cosmetic mods (visuals/audio)

### How do I share my mod?
**Distribution Methods:**
1. **GitHub Release**: Create repository with mod files
2. **Mod Repository**: Upload to community database
3. **Discord/Forum**: Share download link
4. **Mod Pack**: Bundle with other compatible mods

**Best Practices:**
- Clear README with installation instructions
- List dependencies and requirements
- Include version number
- Provide change log
- Add screenshots/videos
- State compatibility (game version)
- License information (open source recommended)

**Mod Page Should Include:**
- Description of what mod does
- Installation steps
- Known issues/limitations
- Compatibility information
- Credits and attribution
- Contact for support/bug reports

### Where do I put mod files?
Mod files go in the `mods/` directory:
```
mods/
├── your_mod/
│   ├── mod.toml
│   ├── content/
│   │   ├── gameplay/units/
│   │   └── items/
│   └── scripts/
│       └── custom_logic.lua
```

### How do I load mods in-game?
1. **Launch the game**
2. **Go to Main Menu** → **Mods**
3. **Enable desired mods** (be aware of load order)
4. **Start new game** or load existing save
5. **Mods apply automatically** to new content

### Can mods conflict with each other?
Yes, mods can conflict if they:
- **Modify same content**: Two mods changing the same unit stats
- **Use same names**: Identical identifiers for different content
- **Have load order dependencies**: One mod requires another to load first
- **Script conflicts**: Lua scripts interfering with each other

Always check mod descriptions for compatibility information.

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

### How are battlefields generated from map blocks?

**Procedural Generation Process:**
1. **Grid Size**: Randomly select 4×4 to 7×7 grid (60-105 tiles)
2. **Biome Preferences**: Weighted selection (urban 30%, forest 25%, etc.)
3. **Block Placement**: 80% primary biome, 20% variety for interest
4. **Coordinate Assembly**: Convert 15×15 blocks to world coordinates
5. **Battlefield Creation**: Generate playable Battlefield instance

**Generation Modes:**
- **Random**: Any block from pool, no biome filtering
- **Themed**: Biome-weighted selection with fallback to any block

**GridMap System:**
- **Coordinate Systems**: World (1-based) ↔ Grid (0-based) ↔ Local (1-based)
- **Assembly**: Blocks arranged in grid, converted to continuous battlefield
- **Variety**: Each battle has unique layout based on random selection

**Technical Details:**
- **File Location**: `mods/core/mapblocks/*.toml`
- **Loading**: `MapBlock.loadAll("mods/core/mapblocks")`
- **Integration**: `battlescape:enter()` creates GridMap and generates battlefield
- **Performance**: <130ms initialization, minimal runtime impact

**Customization:**
- Add new TOML files to `mods/core/mapblocks/`
- Modify biome preferences in `battlescape.lua`
- Create themed block sets for specific mission types

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

## Community Questions

### Where can I get help?
- **GitHub Discussions**: General questions and community support
- **Discord Server**: Real-time chat and help
- **Wiki**: Comprehensive documentation and tutorials
- **Forum**: Long-form discussions and troubleshooting

### Where can I share my mods?
- **GitHub Repository**: Create releases for your mods
- **Mod Database**: Community-maintained mod repository
- **Discord**: Share and discuss mods with the community
- **Forum**: Post mod releases and get feedback

### How do I join the community?
- **Discord**: Join our server for real-time discussion
- **GitHub**: Follow the repository and participate in discussions
- **Forum**: Join long-form community conversations
- **Newsletter**: Subscribe for development updates

## Troubleshooting

### Game runs slowly
- **Lower graphics settings** in options menu
- **Close other applications** to free up system resources
- **Update graphics drivers** to latest version
- **Check system requirements** - you may need better hardware

### Mod not working
- **Check load order** in mod menu
- **Verify file structure** matches documentation
- **Check for errors** in Love2D console
- **Test with minimal mod** to isolate issues

### Can't save game
- **Check write permissions** on save directory
- **Free up disk space** if running low
- **Try different save slot** in case of corruption
- **Backup existing saves** before troubleshooting

### Audio issues
- **Check Love2D audio settings**
- **Verify sound drivers** are working
- **Test with different audio formats**
- **Disable problematic mods** that might affect audio

If you can't find an answer here, please ask in our Discord server or create a GitHub Discussion!