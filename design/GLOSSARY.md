# AlienFall Glossary: Comprehensive Terminology Reference

**Version**: 1.0 | **Last Updated**: October 20, 2025 | **Scope**: All modules and systems

---

## Overview

This glossary consolidates all domain-specific terminology, abbreviations, and key concepts across AlienFall systems. Terms are grouped by module with one-sentence definitions for quick reference and AI/developer onboarding.

---

## GEOSCAPE (Strategic Global Layer)

### Core Geoscape Concepts

- **Geoscape**: The strategic map layer representing global military operations where players manage bases, deploy crafts, and respond to alien missions on a hex-grid world.
- **World**: A complete strategic map (Earth, alien homeworlds, etc.) represented as a 2D hexagonal grid with provinces, countries, and factions.
- **Universe**: The meta-system managing all worlds simultaneously with inter-world connectivity through portals and dimensional mechanics.
- **Hex/Hexagon**: The fundamental map unit on the Geoscape (each representing ~500km on Earth), arranged in a hexagonal grid topology with 6 adjacent neighbors.
- **Province**: The fundamental territorial unit on a world, capable of containing one player base, multiple enemy missions, and unlimited player craft.
- **Region**: A grouping of 4-12 provinces sharing geopolitical and administrative boundaries; scoring aggregates at regional level before country-level calculation.
- **Country**: A political entity representing allied or hostile nations that provide funding, claim territories, and respond to player diplomatic actions.
- **Biome**: Environmental classification of a province (Ocean, Grassland, Forest, Mountain, Desert, Urban, Arctic, Volcanic) affecting terrain, missions, and unit availability.
- **Portal**: A special transit location enabling instantaneous, cost-free travel between distant provinces on the same or different worlds.

### Geoscape Mechanics

- **Detection/Radar Coverage**: The system by which player bases and craft scan nearby provinces daily to reveal enemy missions based on radar power and mission cover values.
- **Cover (Mission Stealth)**: An enemy mission stat (0-100) representing how well-hidden it is; reduces naturally over time or when scanned by player radar.
- **Radar Power/Range**: The detection capability of a player facility, with power indicating strength and range indicating effective detection radius in provinces.
- **UFO**: Unidentified Flying Object; an alien craft mission type that travels autonomously across the map following scripted behavior patterns.
- **Alien Base**: A permanent enemy facility that grows, generates missions, and can be attacked; represents strategic alien presence in a region.
- **Site**: A temporary, static alien mission that expires over time if not intercepted.
- **Landing Zone**: A designated map block on the Battlescape where player units deploy; selected before combat and safe from enemy units.
- **Craft**: A player vehicle capable of traveling across the Geoscape to destinations, intercepting UFOs, or deploying to Battlescape missions.
- **Craft Speed**: A stat determining movement distance per turn on the Geoscape; directly impacts operational range and response time.
- **Movement Points (MP)**: The Geoscape currency determining how far a craft can travel per turn, calculated as Speed × Available AP.
- **Travel System**: The mechanics governing craft movement between provinces using pre-calculated world paths considering terrain movement costs.
- **World Path**: A pre-optimized route between two provinces for a specific craft type (air, water, ground), calculated using Dijkstra/A* pathfinding.

### Mission & Escalation System

- **Campaign Escalation Meter**: A numeric tracker accumulating faction pressure, resetting periodically; thresholds trigger UFO armada events and increased mission frequency.
- **Mission Generation**: The procedural system creating enemy missions based on faction state, escalation meter, player threat level, and regional biome preferences.
- **Mission Type**: The category of hostile encounter (UFO Crash, Interception, Alien Base, Defense, Research Facility, Supply Raid), each with distinct composition and rewards.
- **Interception**: The act of deploying player craft to engage a UFO before it completes its objective, potentially preventing a Battlescape ground mission.
- **Reinforcements (Geoscape)**: Additional enemy squads arriving at designated turns during a Battlescape mission, expanding the combat challenge.

### Faction & Diplomacy

- **Faction**: An independent alien or human organization (Sectoids, Ethereals, Hybrids, Nations) with strategic goals, resource management, and diplomatic relations to the player.
- **Faction Escalation**: The threat level of a faction, increasing with their attack frequency and resource accumulation; affects mission difficulty and special events.
- **Relations/Relationship**: The diplomatic standing (-100 hostile to +100 allied) between the player organization and a country, faction, or supplier.
- **Funding Tier**: The monthly financial support level (0-10) from allied countries, determined by the player's performance in regions they control.
- **Fame**: A player reputation score (0-100) reflecting notoriety; affects mission difficulty, supplier access, and recruitment options.
- **Karma**: A player morality meter (-100 evil to +100 saint) tracking ethical decisions; gates black market access and faction relationships.
- **Supplier**: A marketplace entity providing equipment, resources, and services with unique specializations; relationships determine pricing and availability.
- **Black Market**: Restricted marketplace access providing rare, experimental, or prohibited items; requires low karma and criminal faction alignment.

### Economics & Finance (Geoscape Context)

- **Funding**: Monthly financial support from allied countries based on performance in their provinces; scales with country relations and regional scoring.
- **Economic Power/GDP**: The total wealth production of a country calculated as the sum of all its provinces' economies; grants monthly income to the player.
- **Province Economy**: The economic output of a single province; scales with population and development level.
- **Country Satisfaction**: The morale indicator for a nation; declines with undefended provinces and enemy operations, affecting relations and funding.
- **Economic Cascade**: The feedback loop where mission success generates salvage, enabling research and manufacturing, which improves future mission success and income.

---

## BASESCAPE (Operational Base Management Layer)

### Base Structure & Construction

- **Base**: A player's operational hub in a province, providing housing, research, manufacturing, defense, and resource storage on a hexagonal grid facility layout.
- **Base Size**: The grid dimensions of a base (4×4 Small to 7×7 Huge), determining facility capacity, construction cost/time, and defensive rating.
- **Base Grid**: The hexagonal layout system where facilities are positioned; grid-based placement enables adjacency bonuses and strategic planning.
- **Facility**: A modular structure providing a specific service (Power, Research, Manufacturing, Housing, Storage, Defense); each facility has production, consumption, and maintenance costs.
- **Facility Slot**: A grid position capable of holding one facility; base size determines total available slots (16-49 depending on size).
- **Footprint**: The grid area occupied by a facility on the base grid (1×1, 2×2, or 3×3 hexagons); larger facilities require more space but typically provide greater capacity.
- **Adjacency**: The connection relationship between two facilities on the base grid; adjacent facilities unlock synergy bonuses (e.g., Lab + Workshop = +10% research & manufacturing).
- **Connectivity**: The requirement that all facilities must be physically connected (adjacent or linked via corridors) to function; isolated facilities are offline.
- **Corridor**: A 1×1 facility providing only connection function; enables bridging disconnected sections and serves as defensive positions in Battlescape.
- **Service**: A binary capability provided by facilities (Power, Research Capacity, Manufacturing Capacity, Psi Education, Radar Coverage, Defense); either produced or consumed.

### Facility Types (Reference)

- **Power Plant**: Provides essential power (+50) consumed by all other facilities; without power, dependent facilities go offline.
- **Barracks**: Provides unit housing and recruitment capacity; larger versions (1×1 vs. 2×2) provide 8 vs. 20+ housing slots.
- **Storage**: Provides item and resource storage capacity; inventory space prevents excess purchasing and forces capacity planning.
- **Lab**: Provides research capacity measured in man-days; larger labs enable parallel research projects and accelerate science through bonuses.
- **Workshop**: Provides manufacturing capacity measured in man-days; enables production of equipment and ammunition for sustained operations.
- **Hospital**: Provides healing (+2 HP/week) and sanity recovery (+1/week) for units; critical for unit recovery between missions.
- **Academy**: Provides unit training (+1 XP/unit/week), enabling faster experience gain and rank progression.
- **Garage**: Provides craft repair (+50 HP/week), enabling rapid turnaround of damaged craft.
- **Hangar**: Provides craft storage and boarding capacity; necessary for maintaining craft fleet at base.
- **Radar (S/L)**: Provides Geoscape mission detection (+3 to +5 detection bonus) enabling early warning and interception.
- **Turret (M/L)**: Provides base defense points (+50 to +150) against UFO attacks; primary passive defense mechanism.
- **Prison**: Provides prisoner storage and interrogation capability; enables research extraction from captured aliens.
- **Temple**: Provides sanity recovery (+1/week, all units) and morale boost; enables mental health infrastructure for long-term unit retention.

### Personnel & Units (Basescape Context)

- **Unit**: A soldier or alien operative under player control; persists across missions, gains experience, and develops specializations.
- **Unit Class**: The specialization path of a unit (Soldier, Medic, Sniper, Assault, Engineer, etc.), determining stat progression and equipment synergy.
- **Unit Rank/Promotion**: The experience level of a unit (Rank 0-6); higher ranks unlock specializations and stat bonuses but require more combat to achieve.
- **Recruitment**: Acquiring new units through marketplace, factions, or specialist suppliers; limited by barracks capacity and monthly budget.
- **Barracks Capacity**: The total unit housing available across barracks facilities; exceeding capacity imposes morale penalties and blocks new recruitment.
- **Salary/Maintenance Cost**: The monthly cost per unit (5K base) kept in the organization; scales with rank and specialization.
- **Experience (XP)**: A unit's accumulated combat points earned through missions; triggers rank promotion and specialization unlocks at thresholds (100, 300, 600, 1000 XP).
- **Bravery**: Core unit stat (6-12 range) determining morale capacity in battle; higher bravery = larger morale pool and better panic resistance. Increases with experience (+1 per 3 ranks) and traits (Brave +2, Fearless +3).
- **Morale**: In-battle psychological state starting at Bravery value and degrading from stress (ally deaths, damage, flanking); drops to 0 trigger PANIC (all AP lost). Recoverable via Rest action (2 AP → +1) or Leader rally (4 AP → +2). Resets to Bravery after mission.
- **Sanity**: Long-term mental stability (6-12 range) that persists between missions; drops after missions based on horror level (Standard 0, Moderate -1, Hard -2, Horror -3). Recovers slowly (+1/week base, +2/week with Temple). At 0 sanity, unit cannot deploy (Broken state).
- **Health Recovery**: The passive healing system (+1 HP/week) accelerated by hospital facilities and medic specialization.
- **Prisoner**: A captured alien unit held in prison facility; provides research opportunity and can be traded, experimented on, or executed.

### Manufacturing & Research (Basescape Context)

- **Manufacturing**: The production of equipment, ammunition, and consumables using engineer man-days and raw materials; significantly cheaper than marketplace.
- **Research**: The scientific advancement unlocking new technologies, equipment categories, facilities, and manufacturing options; measured in scientist man-days.
- **Manufacturing Queue**: An ordered list of production projects; automatically proceeds when one completes without manual intervention or penalty.
- **Batch Bonus**: A production efficiency bonus (5-10%) applied when manufacturing 5+ units of the same item; encourages bulk production.
- **Engineer**: The abstracted workforce performing manufacturing; no individual engineers exist, just pool of available man-days.
- **Scientist**: The abstracted workforce performing research; allocated to projects and paid only for active work days.
- **Man-Days**: The abstract unit of work (scientist or engineer labor per day) required to complete research or manufacturing projects.
- **Progress (Research/Manufacturing)**: The percentage completion of a project; advances daily based on assigned man-days.

### Economics & Facility Management

- **Facility Maintenance Cost**: The monthly operational cost of a facility (5-50K per facility); scales with facility size and complexity.
- **Base Layout Maintenance**: The monthly cost to maintain base infrastructure; scales non-linearly with base size (5K × size²).
- **Craft Maintenance**: The monthly maintenance per craft (2K per craft).
- **Facility State**: The operational status of a facility (Operational, Offline, Construction, Damaged, Destroyed); state determines production and maintenance costs.
- **Power Shortage**: A state where power production is insufficient for all facilities; facilities switch offline in priority order (Research/Manufacturing/Support).
- **Offline (Player Decision)**: Intentionally disabling a facility to save on maintenance (50% cost) without destroying it; reverses instantly.
- **Damaged Facility**: A facility at reduced HP producing 50-90% capacity; results from UFO attacks; requires repair or replacement.
- **Destroyed Facility**: A facility reduced to 0 HP; becomes inert and must be rebuilt at full cost.
- **Repair Time/Cost**: The time and credits required to restore a damaged facility; scales with damage taken.

### Storage & Inventory

- **Storage Capacity**: The total item/resource storage available across storage facilities; limits purchasing and inventory management.
- **Item Overflow**: A state where storage is full; blocks new purchases until space is freed through selling or manufacturing.
- **Inventory Stack**: Multiple units of the same item stored as single stack entry; reduces space overhead.
- **Craft Storage**: The capacity of hangars for storing player craft; each craft occupies 1-4 hangar slots depending on size.
- **Weapon/Armor Assignment**: The process of equipping units with specific gear; transfers instantly between units at base.

### Defense & Interception (Basescape Context)

- **Base Defense Rating**: The total defense points from turrets and defensive facilities; determines UFO attack resistance.
- **Facility Damage (UFO Attack)**: The outcome of failed base defense; random facilities take 10-50 damage points in attack resolution.
- **UFO Attack**: An alien assault on a player base; occurs if UFO bypasses interception; resolves through passive defense first, then player Battlescape engagement option.
- **Interception Option**: The player's choice to engage a UFO in Battlescape after defense resolution; can prevent facility damage or salvage UFO wreckage.

---

## BATTLESCAPE (Tactical Combat Layer)

### Map Structure & Hierarchy

- **Battlescape**: The turn-based tactical combat system where squads fight in hex-grid tactical maps; all combat is non-real-time.
- **Battle Tile/Hex**: The fundamental tactical unit of Battlescape (2-3 meters each); each hex contains one unit maximum plus up to 5 ground objects.
- **Map Block**: A 15-hex cluster representing a cohesive environmental region (forest zone, building interior, etc.); can be rotated and mirrored for variety.
- **Map Grid**: A 2D array of map blocks forming the overall battle layout; generated procedurally using map scripts.
- **Battlefield**: The final unified tactical map; dimensions = Map Grid × 15 hexes.
- **Biome**: Environmental classification affecting available map block types and terrain properties.
- **Terrain Type**: The specific terrain theme for a map (Sand Dunes, Urban Ruins, Forest, etc.); determines visual appearance and map block selections.
- **Map Script**: A procedural generation rule set that builds the map grid through a series of conditional steps, placing blocks, features, and terrain.
- **Battle Size Categories**: Standard map dimensions (Small 4×4=16 blocks, Medium 5×5=25, Large 6×6=36, Huge 7×7=49).

### Entity & Object Types

- **Entity**: Any occupant of a battle tile (Unit, Object, Environmental Effect, Terrain).
- **Unit**: A combat entity (soldier or alien) occupying one hex; can move, attack, perform actions, and be targeted.
- **Object/Ground Item**: Non-entity items on the battlefield (weapons, armor, grenades, corpses); up to 5 per tile.
- **Corpse**: A deceased unit converted to a ground item; recoverable for extraction but not usable in combat.
- **Wall/Floor**: Terrain entities (passable terrain or impassable walls); affect movement, line-of-sight, and projectile paths.
- **Smoke**: An environmental hazard occupying tiles; reduces visibility (2-4 sight cost), interferes with accuracy (1 fire cost), and slowly disperses.
- **Fire**: An environmental hazard dealing damage (1-2 HP/turn) to units entering; spreads to adjacent flammable tiles and self-extinguishes after several turns.
- **Environmental Effect**: Ambient hazards (smoke, fire, gas) affecting combat conditions.

### Line of Sight & Vision

- **Line-of-Sight (LOS)**: The visibility calculation determining what a unit can see; uses raycasting on hex grid with cumulative sight cost.
- **Sight Range**: A unit stat (typically 8-12 hexes day sight, 3-6 hexes night sight) representing maximum visibility distance.
- **Sight Cost**: The cumulative obstruction penalty as you trace a ray from unit to target; each tile/obstacle adds cost; exceeding sight range hides the target.
- **Sight Cost Examples**: Clear terrain = 1, Smoke = 2-4, Wall = infinite, Unit = 1-3 depending on size.
- **Day/Night Sight**: Separate sight range stats for daytime vs. night missions; night missions impose sanity penalties and reduced visibility.
- **Line of Sense**: A special unit ability bypassing normal sight cost calculation; enables seeing units outside normal sight range.
- **Fog-of-War (FOW)**: The system hiding unexplored tiles and marking line-of-sight visibility; initialized at battle start from player unit positions.
- **Reveal/Shroud**: Tiles transition from shrouded (unexplored) to revealed (seen at any point) to visible (currently in sight); shrouded tiles appear empty.

### Line of Fire & Accuracy

- **Line-of-Fire (LOF)**: The geometric line from shooter to target on hex grid; determines if a shot is geometrically possible.
- **Fire Cost**: The obstruction penalty to accuracy along the line of fire; solid obstacles count (walls 1-6, bushes 3, etc.); each point = 5% accuracy reduction.
- **Ranged Accuracy**: The calculated chance-to-hit for ranged attacks; derived from unit accuracy, weapon bonus, range modifier, cover, and visibility.
- **Accuracy Calculation**: Base accuracy + weapon modifier + weapon mode + range modifier - cover modifier - visibility modifier, clamped 5-95%.
- **Range Modifier**: A multiplier based on distance to target; close range bonus, medium range baseline, long range penalty, beyond max range = 0%.
- **Cover Modifier**: The defense bonus from obstacles between shooter and target (-5% per cover point).
- **Minimum Range**: Some weapons (sniper rifles) have minimum effective range penalties; close targets harder to aim at.
- **Weapon Mode Accuracy**: Different firing modes modify accuracy (Snap -5%, Burst ±0%, Aim +15%).
- **Visibility Modifier**: Targets not in line-of-sight suffer -50% accuracy penalty.

### Combat Mechanics

- **Accuracy Test**: The roll determining if a ranged attack succeeds; succeeds if random(0-100) <= final accuracy.
- **Projectile Deviation**: The random offset of a missed shot; determines where the projectile goes instead of target.
- **Deviation Distance**: The distance a projectile deviates; = target distance × (final accuracy / 100).
- **Collision Detection**: The system checking if projectiles hit solid obstacles along their path; hits stop projectile and apply area damage if explosion.
- **Cover**: Defensive obstacles that increase sight cost and reduce attacker accuracy; provides incremental defense (-5% per obstacle).
- **Cover Level**: The magnitude of defense provided by an obstacle (Half-Cover +10%, Full-Cover +20%, Elevated +25%).
- **Terrain Destruction**: Destructible terrain (walls, structures) with armor values; damaged when incoming damage exceeds armor.
- **Damage Classification**: Damage categories (Point, Area, Beam) determining how damage spreads (single tile, radial, or line).
- **Explosion System**: Area damage spreading radially from epicenter with dropoff; damage decreases per hex distance.
- **Dropoff Rate**: The damage reduction per hex distance in an explosion (typically 3 points/hex).

### Damage & Health

- **Health Points (HP)**: The combat resource representing unit damage capacity (typically 6-12 HP for humans); unit dies at 0 HP.
- **Stun Points**: Temporary damage accumulating from hazards (smoke, stun weapons, fatigue); decays naturally (-1/turn) or via rest action.
- **Unconscious State**: A condition when Stun ≥ Max HP; unit becomes inactive until stun drops below max HP.
- **Wound**: A persistent injury from critical hits; inflicts 1 HP damage per turn until healed (requires medikit).
- **Damage Types**: Kinetic (bullets), Explosion (grenades), Energy (lasers), Chemical (gas), Biological (toxins), Psionic (psychic), Fire (incendiary), Stun (taser).
- **Armor Resistance**: Percentage reduction of specific damage types (e.g., Heavy Armor +50% kinetic, -30% energy).
- **Armor Vulnerability**: Percentage increase in specific damage types (e.g., Light Armor -20% explosive).
- **Armor Value (Terrain)**: Structural integrity of destructible terrain; damage exceeding armor value damages the tile.
- **Damaged Terrain State**: Terrain at reduced HP; can be damaged further until destroyed.
- **Rubble State**: Terrain converted to passable floor after destruction; no longer blocks movement but occupies visual space.

### Unit Actions & Resources

- **Action Point (AP)**: The turn resource (4 per turn) limiting unit actions; each action costs 1-4 AP.
- **Energy Point (EP)**: The stamina/ammunition resource representing weapon fire capability; regenerates 30% per turn.
- **Movement Point (MP)**: The distance a unit can travel per action; calculated as AP × Speed stat.
- **Move Action**: The standard movement action (1 AP per 2 hexes); affected by terrain movement costs.
- **Run Action**: A faster movement (1 AP per hex) at 50% speed; imposes -3 sight penalty.
- **Sneak Action**: A careful movement (1 AP per hex) at 200% terrain cost; grants +3 cover and sight bonuses.
- **Fire Action**: A ranged attack (1-2 AP) consuming ammunition/energy; accuracy subject to all modifiers.
- **Overwatch**: A defensive stance (2 AP) enabling reaction fire when enemies enter LOS during their turn.
- **Cover Action**: Assuming defensive position (2 AP per level) granting cumulative -5% attacker accuracy per level.
- **Suppress Enemy**: A shot targeting enemy to reduce their AP next turn (-1 AP if successful).
- **Rest Action**: Recovery action (2-4 AP) restoring morale, reducing stun, or regenerating energy.
- **Throw Action**: Picking up and throwing an object (2 AP); accuracy based on aim stat.

### Status Effects & Psychology

- **Morale**: A unit's psychological state in battle (6-12 range); drops to 0 triggers panic, reducing AP by 1-2 per threshold level.
- **Morale Loss Events**: Witnessing ally death nearby (-1), taking critical damage (-1), seeing enemy superiority (-1).
- **Morale Recovery**: Rest action (+1), Leader aura (+1), Rally ability (+2).
- **Sanity**: A separate psychological buffer affected by mission horror, night missions, casualties; low sanity triggers breakdowns.
- **Panic State**: Condition when morale = 0 or sanity = 0; unit becomes inactive (0 AP) until both recover above 0.
- **Bravery**: The core stat determining morale capacity in battle; higher bravery units resist panic more effectively.
- **Suppression**: A status effect (-1 AP next turn) applied by suppressive fire actions.
- **Smoke Damage**: Stun damage (1 per large cloud per turn) from smoke inhalation.
- **Fire Damage**: HP damage (1-2 per turn) plus morale damage from entering fire tiles.
- **Chemical Exposure**: Variable effects (poison, confusion, paralysis) from gas clouds.
- **Bleed**: Persistent HP damage from wounds; 1 HP/turn per wound until healed.

### Weapon & Equipment Systems

- **Weapon Mode**: A firing configuration (Snap, Burst, Aim, etc.) modifying accuracy, AP cost, range, and damage.
- **AP Cost**: The action point expense of firing (1-2 typically).
- **EP Cost**: The energy/ammunition expense (1-3 typically).
- **Weapon Range**: The maximum targeting distance (multiples of 4 typically, e.g., 12 hexes).
- **Weapon Damage**: The HP reduction inflicted by successful hits.
- **Accuracy Bonus**: The weapon modifier to base accuracy.
- **Armor Slot**: Single equipment slot for body armor per unit.
- **Primary Weapon Slot**: One weapon slot per unit.
- **Secondary Weapon Slots**: Up to 3 additional weapon slots per unit.
- **Inventory Limit**: Carry capacity determined by Strength stat (ST × 2 = slots).
- **Equipment Transfer**: Instant gear exchange between units at base; no cost or delay.
- **Ammunition Type Selection**: Pre-battle choice of ammunition type per weapon; determines damage type and properties.

### Tactical Systems

- **Turn Order**: A fixed sequence (Player Team → Allied Teams → Enemy Teams); all units on team act during team turn.
- **Initiative**: Within a team, player selects unit action order (no random initiative).
- **Reaction Fire**: Enabled through Overwatch status; automatic shot when enemy enters LOS during their turn.
- **Flank/Flanking**: Attacking a unit from outside their facing arc; grants +20% accuracy, -50% target defense (future feature).
- **High Ground**: Elevation advantage; attacker gains +15% accuracy and +1 range.
- **Melee Combat**: Close-range combat using Strength stat instead of Accuracy; 1 AP cost, defense roll available.
- **Concealment/Stealth**: Optional mission mechanic with limited stealth budget; consuming budget reveals player position.
- **Squad Tactics**: Coordinated fire support (+10% accuracy per supporting ally, max +30%) and suppressive fire (-1 AP per attacker, max -2).
- **Reinforcements**: Additional enemy squads arriving at designated turns, expanding combat scope.

### Victory & Defeat

- **Objective (Mission)**: The goal for each side (Eliminate Enemies, Capture Unit, Defend Objective, Reach Objective, Rescue Unit, etc.).
- **Objective Completion**: Achievement of objective goal; triggers mission success/failure for respective side.
- **Victory Condition**: Completion of player objective before defeat condition triggers.
- **Defeat Condition**: Elimination of all player units or failure to achieve objective before reinforcements overwhelm.
- **Retreat**: Player option to extract units from battlefield; units survive but mission fails, no salvage collected.
- **Salvage**: Equipment and resources collected from defeated enemies and looted tiles.
- **Prisoner**: Enemy units captured alive instead of killed; can be interrogated for research.
- **XP Gain**: Experience awarded to surviving units based on mission performance.
- **Medal**: Achievement reward for exceptional performance (killing sprees, perfect stealth, etc.).
- **Post-Mission Healing**: Unit recovery time in hospital facility based on damage taken.

---

## INTERCEPTION (Aerial Combat Layer)

### Craft System

- **Craft**: A player vehicle capable of Geoscape travel and aerial interception combat.
- **Craft Type**: Classification by size and role (Fighter, Bomber, Transport, Scout, etc.).
- **Craft Speed**: The movement rate on Geoscape; determines operational range and travel time.
- **Craft Armor/HP**: Health points of a craft; reduced by UFO weapons or environmental damage.
- **Craft Weapons**: Armed hardpoints on craft allowing aerial combat against UFOs.
- **Crew**: Personnel assigned to craft; required for operation and determines available AP per turn.
- **Fuel**: The resource consumed per Geoscape movement; insufficient fuel prevents launch.
- **Hangar Slot**: Storage location for craft at base; each hangar provides 1-8 slots depending on facility size.
- **Repair Queue**: Damaged craft automatically queued for repair upon return; repair rate +50 HP/week in Garage.

### Interception Mechanics

- **Interception**: The act of deploying craft to intercept UFO before it completes objective.
- **UFO Behavior**: The AI state machine determining UFO movement and combat decisions (Aggressive, Tactical Withdrawal, Escape, Defensive).
- **Survival Odds**: The UFO calculation determining combat viability; high odds = attack, low odds = escape.
- **Engagement**: The combat interaction between player craft and UFO.
- **Success**: UFO destroyed; prevents ground mission.
- **Failure**: UFO reaches objective; triggers Battlescape ground mission instead.
- **Draw**: UFO escapes with damage; triggers weakened Battlescape mission.

---

## ECONOMY & RESOURCES

### Financial Systems

- **Credits**: The primary currency enabling purchases, hiring, and construction.
- **Income**: Monthly financial generation from country funding and manufacturing sales.
- **Expense**: Monthly cost from facility maintenance, unit salaries, and craft upkeep.
- **Net Monthly Budget**: Income minus expenses; positive = surplus accumulation, negative = deficit spending.
- **Funding (Country)**: Monthly support from allied countries based on performance; scales with relations.
- **Funding Tier**: The level (0-10) of country support; higher tiers grant more monthly income.
- **Manufacturing Profit**: Revenue generated by selling manufactured items to marketplace or other bases.
- **Research Milestone Bonus**: One-time credits awarded upon completing research trees.
- **Equipment Sales Revenue**: Credits from selling surplus equipment at 50% purchase price.
- **Economic Pressure**: The challenge of maintaining positive cash flow while managing growth and operations.

### Resources (Raw Materials)

- **Resource**: A consumable material used in manufacturing, research, and craft fuel; examples include Fuel, Metal, Titanium, Elerium, etc.
- **Fuel**: The primary energy resource consumed by craft travel; insufficient fuel prevents launch.
- **Raw Materials**: Generic construction materials (Metal, Plastic, etc.) used in early manufacturing.
- **Advanced Materials**: Mid-tier materials (Titanium, Fusion Core) unlocked through research.
- **Alien Materials**: Late-tier materials (Elerium, Alien Alloy) requiring alien technology research.
- **Resource Synthesis**: The crafting system converting materials into other materials (e.g., Metal + Fuel → Titanium).
- **Scrap/Salvage**: Resources recovered from destroyed equipment or enemy items (50-75% material recovery).
- **Resource Acquisition**: Sources include battlefield salvage, marketplace purchase, supplier contracts, and synthesis.

### Manufacturing & Research Economics

- **Manufacturing Cost**: Credits + resources consumed to produce items through workshops.
- **Production Time**: Days to complete manufacturing; accelerated by engineer assignment and facility bonuses.
- **Research Cost**: Credits + scientist man-days to unlock technologies.
- **Research Time**: Days to complete research; accelerated by scientist assignment and facility bonuses.
- **Technology Prerequisite**: Research completion required before manufacturing specific items.
- **Facility Efficiency**: Adjacency bonuses and upgrades improving production speed (5-30% bonuses typical).
- **Batch Bonus**: Efficiency bonus (5-10%) when manufacturing 5+ units of same item.
- **Diminishing Returns**: Additional workers (scientists/engineers) provide decreasing efficiency (5th = 80%, 10th = 60%).

### Marketplace & Trade

- **Marketplace**: The primary commerce system providing items, equipment, and resources through competing suppliers.
- **Supplier**: A merchant providing specific categories of items; pricing and availability affected by relationship.
- **Supplier Relationship**: The diplomatic standing (-100 to +100) affecting supplier pricing and item availability.
- **Base Price**: The standard price of an item from a given supplier.
- **Pricing Modifier**: The multiplier (0.5x to 3.0x) applied based on supplier and relationship.
- **Availability**: The quantity of items available monthly from a supplier; limited stock for rare items.
- **Purchase Order**: The transaction placing an order with a supplier; items delivered after delay (1-14 days).
- **Delivery Time**: The delay before purchased items arrive (varies by supplier and shipping method).
- **Failed Delivery**: 10% chance of delivery loss; player receives partial refund (20-50%).
- **Bulk Discount**: Price reduction (5-25%) for purchasing large quantities (50+ units).
- **Subscription/Recurring Order**: Automatic monthly purchases at agreed pricing and delivery schedule.
- **Black Market**: Underground economy system providing restricted items (experimental weapons, banned tech), special units (mercenaries, defectors), special craft (stolen military), mission generation (assassination, sabotage, heist), event purchasing (political manipulation), and corpse trading. Requires karma below +40 and fame above 25. All transactions carry karma penalties (-5 to -40) and discovery risk (5-15%). Discovery results in fame loss (-20 to -50) and relations damage (-30 to -70). Access tiers: Restricted (items only) → Standard (items + units) → Enhanced (most services) → Complete (all services including extreme operations).
- **Corpse Trading**: Black Market service allowing sale of dead units for credits. Values: Human soldier (5K, -10 karma), Alien common (15K, -15 karma), Alien rare (50K, -25 karma), VIP (100K, -30 karma). Fresh corpses +50% value, preserved +100%, damaged -50%. 5% discovery risk per sale. Alternative ethical uses: Research (0 karma), Burial (0 karma, +5 morale), Ransom (0 karma, +relations).
- **Mission Generation**: Black Market service to purchase custom missions that spawn on Geoscape. Types: Assassination (50K, -30 karma), Sabotage (40K, -20 karma), Heist (30K, -15 karma), Kidnapping (35K, -25 karma), False Flag (60K, -40 karma), Data Theft (25K, -10 karma), Smuggling (20K, -5 karma). Missions spawn in 3-7 days with 150-300% profit potential if completed successfully.
- **Event Purchasing**: Black Market service to trigger political/economic events. Types: Improve Relations (30K, -10 karma, +20 relations), Sabotage Economy (50K, -25 karma, drops economy tier), Incite Rebellion (80K, -35 karma, contests province), Spread Propaganda (20K, -5 karma, +10 fame), Frame Rival (60K, -30 karma, -30 rival relations), Bribe Officials (40K, -15 karma, ignore black market activity 6 months), Crash Market (70K, -20 karma, 30% cheaper items 3 months).
- **Embargo**: Complete trade block with supplier when relationship ≤ -100; requires diplomatic reset to restore.

### Transfer & Logistics

- **Transfer System**: The inter-base logistics system moving items, craft, and personnel between bases.
- **Transfer Cost**: Credits charged for logistical transport; scales with distance and transport method.
- **Transfer Time**: Days required for delivery; varies by transport type and distance.
- **Transport Type**: The method used (Air = 2 hexes/day, Ground = 1.5, Maritime = 1); determines cost and speed.
- **Supply Line**: Recurring transfers for consumables (ammunition, resources) establishing permanent supply routes.
- **Supply Line Cost**: Monthly fee for automatic resupply contracts.
- **Auto-Replenish**: Automatic supply trigger when destination inventory below minimum threshold.
- **Interception Risk**: Chance (5-15%) of enemy interception during transfer; supplies lost permanently.
- **Stealth Routing**: +50% cost option reducing interception risk by 20%.
- **Emergency Transfer**: +200% cost option enabling rapid delivery (bypasses normal queue).

---

## CORE GAME SYSTEMS

### Unit Advancement & Progression

- **Experience (XP)**: The unit progression currency earned through combat kills and objectives; accumulates toward rank promotion.
- **Rank/Promotion**: The experience level (0-6) representing unit specialization; higher ranks unlock better stat growth and abilities.
- **Stat Progression**: The incremental improvement of unit stats (HP, Accuracy, Strength, etc.) per promotion; diminishes at higher ranks.
- **Specialization**: The role-specific path (Soldier, Medic, Sniper, etc.) chosen upon reaching Rank 1; determines stat bonuses and equipment synergy.
- **Class Synergy**: Equipment bonuses (+50%) when used by matching class (e.g., Medic using Medikit).
- **Class Penalty**: Equipment penalties (-30% accuracy) when used by non-matching class above minimum requirement.
- **Trait**: A persistent modifier affecting unit stats, abilities, and behavior (Smart +20% XP, Brave +2 morale, etc.).
- **Mutation**: A transformative trait applying permanent changes (increased XP, new abilities) but potentially debilitating side effects.
- **Medal**: Achievement reward earning prestige and minor stat bonuses.
- **Equipment Specialization**: Unlocked abilities when using high-tier equipment matching unit rank/class.

### Progression Gates & Tuning

- **Tech Prerequisite**: Research requirement before accessing specific equipment, facilities, or capabilities.
- **Level Gate**: Minimum unit rank required to use equipment without penalty.
- **Facility Prerequisite**: Organization-level requirements before building certain facility types.
- **Organization Level**: The player's advancement tier (1-10); determines max base count, unit recruitment tiers, and facility access.
- **Difficulty Scaling**: Mission composition scales with player force strength to maintain challenge.
- **Economy Scaling**: Late-game costs increase; balanced by higher income sources.
- **Endgame Content**: Special missions, ultimate technologies, and ascension mechanics triggering after campaign milestones.

### Localization & Accessibility

- **Localization**: Translation support for multiple languages and regional adaptations.
- **Accessibility Features**: UI scaling, color-blind modes, reduced animation, text-to-speech, customizable controls.
- **Difficulty Options**: Selectable difficulty presets (Easy, Normal, Hard, Impossible) or custom-tuned difficulty parameters.

### Analytics & Telemetry

- **Session Analytics**: Tracking playtime, mission success rates, unit survivorship, and progression speed.
- **Balance Telemetry**: Monitoring weapon usage, unit specialization popularity, and economy health.
- **User Engagement**: Metrics for retention, mission completion rates, and feature adoption.

---

## UNIVERSAL ABBREVIATIONS & SHORTHAND

### Common Abbreviations

| Abbreviation | Term | Context |
|---|---|---|
| **AP** | Action Points | Battlescape: 4 per turn; limits actions |
| **EP** | Energy Points | Battlescape: stamina/ammo; regenerates 30% per turn |
| **HP** | Health Points | Damage capacity; death at 0 HP |
| **MP** | Movement Points | Distance a unit can travel per action |
| **XP** | Experience Points | Unit progression currency toward rank promotion |
| **LOS** | Line-of-Sight | Visibility calculation determining unit awareness |
| **LOF** | Line-of-Fire | Geometric path from shooter to target |
| **FOW** | Fog-of-War | Hidden/unexplored tile mechanic |
| **UFO** | Unidentified Flying Object | Enemy craft mission type |
| **AI** | Artificial Intelligence | NPC behavior systems (Strategic/Operational/Tactical) |
| **NPC** | Non-Player Character | AI-controlled unit or entity |
| **UI** | User Interface | On-screen menus, buttons, dialogs |
| **LoF** | Line of Fire | Synonym for LOF (used interchangeably) |
| **RNG** | Random Number Generator | Probability system for hit chances, loot drops |
| **ECS** | Entity-Component System | Engine architecture pattern |

### Damage Type Shortcuts

- **KIN**: Kinetic (bullets)
- **EXP**: Explosive (grenades)
- **ENE**: Energy (lasers)
- **CHE**: Chemical (gas)
- **BIO**: Biological (toxins)
- **PSI**: Psionic (psychic)
- **FIR**: Fire (incendiary)
- **STU**: Stun (taser)

### Facility Type Shortcuts

- **PWR**: Power Plant
- **BAR**: Barracks
- **STG**: Storage
- **LAB**: Laboratory
- **WRK**: Workshop
- **HOS**: Hospital
- **ACD**: Academy
- **GAR**: Garage
- **HNG**: Hangar
- **RAD**: Radar
- **TUR**: Turret
- **PRI**: Prison
- **TMP**: Temple
- **COR**: Corridor

---

## Related Documentation

- **Complete Mechanics**: See individual system documents (systems/Geoscape.md, systems/Battlescape.md, systems/Basescape.md, etc.)
- **API Reference**: See wiki/API.md for system interfaces
- **Quick Reference**: See tests/QUICK_TEST_COMMANDS.md for testing shortcuts

---

**End of Glossary**
