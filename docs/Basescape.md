## Basescape

### Overview

**System Architecture**
Basescape is the tactical base management layer where players construct and maintain operational hubs. Each base is a grid-based facility complex that provides housing, research capability, manufacturing capacity, resource storage, and defensive capabilities. Bases serve as the economic and operational backbone of the player organization, converting battlefield salvage into research, equipped units, and long-term strategic advantage.

**Design Philosophy**
Basescape emphasizes spatial planning, resource optimization, and interconnected systems. Facilities provide diverse functions but require careful positioning to maximize efficiency bonuses. The system creates meaningful strategic decisions: size affects cost and defensive capacity; facility placement determines adjacency bonuses; maintenance costs scale with complexity. Multiple playstyles are supported: research-focused bases, manufacturing-focused factories, defense-oriented strongholds, or balanced facilities.

**Core Principle**: One base per province (exclusive territorial occupation).

---

### Base Construction & Sizing

**Overview**
Base construction is a capital-intensive decision that gates player expansion. Base size directly affects initial cost, construction time, facility capacity, and defensive potential. Larger bases provide more slots but require greater resources and longer construction periods.

**Base Size Progression**

| Size | Grid | Tiles | Cost | Build Time | Relation Bonus | Capacity Slots | Strategic Use |
|------|------|-------|------|------------|---|---|---|
| Small | 4×4 | 16 | 150K | 30 days | +1 | 8-10 | Scout bases, forward positions |
| Medium | 5×5 | 25 | 250K | 45 days | +1 | 15-18 | Standard operational bases |
| Large | 6×6 | 36 | 400K | 60 days | +2 | 24-28 | Regional hubs, manufacturing centers |
| Huge | 7×7 | 49 | 600K | 90 days | +3 (if allied) | 35-40 | Strategic strongholds, capitols |

**Base Expansion**
- Bases can expand by adding rows/columns (not just size upgrades)
- Expansion cost: 50K per new row/column + terrain penalties
- Expansion time: 15-30 days per row/column added
- Expanded bases maintain original facilities + gain new slots
- Maximum expansion: Typically limited by province terrain (expansion restricted in some biomes)

**Construction Gate Mechanics**
Base construction and size are gated by multiple factors, preventing early continental dominance:

| Factor | Impact | Requirement |
|--------|--------|------------|
| **Technology** | Determines facility types available | Base Tech, Grid Foundation |
| **Country Relations** | Allows base in territory | +0 minimum relations |
| **Biome** | Affects build cost, build time, terrain | Biome-appropriate structures |
| **Organization Level** | Gates base count | Level 1: 1 base, Level 5: 5 bases, Level 10: 10 bases |
| **Province Ownership** | Cannot build in enemy-controlled territory | Must have established control |
| **Relation Bonus** | Large/Huge bases require allied status | Relation >50 for Large, >75 for Huge |

**Construction Penalties by Biome**
- **Ocean**: +250% cost and time (engineering difficulty)
- **Mountain**: +40% cost and time (terrain challenges)
- **Arctic**: +35% cost and time (extreme conditions)
- **Urban**: +25% cost (infrastructure integration)
- **Desert**: +20% cost and time (supply logistics)
- **Forest/Grassland**: Baseline (no penalty)

**Build Time Factors**
```
Actual Build Time = Base Time × (1 + Biome Penalty) × (1 - Engineer Bonus) × (1 - Tech Bonus)
Engineer Bonus: Chief Engineer advisor provides -15% time reduction
Tech Bonus: Advanced construction research provides -10% to -20% time reduction
```

**Relocation Mechanics**
- Bases cannot be moved (destroy and rebuild only)
- Destroying base: Instant destruction, 0% refund on construction costs
- Rebuilding: Full cost and time required; region left vulnerable during rebuild
- Strategic implication: Base placement is permanent decision

---

### Facility Grid System

**Overview**
Base facilities exist on a hexagonal grid, creating a two-dimensional strategic layout. The hex grid creates a balanced topology where each facility touches six neighbors (not four as in square grids), encouraging diverse placement strategies and requiring careful planning.

**Grid Architecture**
- **Grid Type**: Hexagonal (H-axis linear, V-axis diagonal)
- **Neighbor Topology**: Each facility connects to 6 adjacent hexes (N, NE, SE, S, SW, NW)
- **Layout Pattern**: Creates diamond/rhombus-shaped base perimeter
- **Rotation**: Facilities are rotatable within their footprint for optimization
- **Visual Clarity**: Grid prevents ambiguous positioning; all placement clear and unambiguous

**Facility Dimensions**

| Size | Footprint | Grid Space | Typical Facilities |
|------|-----------|-----------|---|
| 1×1 | Single hex | 1 tile | Power Plant, Barracks (small), Storage (small) |
| 2×2 | 4-hex cluster | 4 tiles | Lab, Workshop, Academy, Hospital, Garage, Radar, Turret |
| 3×3 | 9-hex cluster | 9 tiles | Hangar (large), Prison, Temple |

**Placement Restrictions**
- Facilities must be placed within base grid bounds
- Overlapping facility footprints are prohibited
- Some facilities require specific neighboring facilities (power-dependent facilities need Power Plant adjacent or connected)
- Edges of base grid cannot house certain facilities (need internal positioning)

**Connection Requirements**
- **Mandatory Adjacency**: Facilities must be connected (touching) to be active
- **Isolated Facilities**: Any facility without adjacent facility neighbors is offline
- **Power Chain**: Power plant must be within 2-hex distance of consuming facilities
- **Corridor Bridges**: Corridors can bridge disconnected sections (1×1 connecting facilities)

**Strategic Grid Implications**
- Dense clustering: Creates efficiency bonuses but reduces flexibility
- Spread layout: Maximizes adjacency options but loses bonuses
- Barrier placement: Corridors create defensive positions in Battlescape
- Expansion planning: Layout must allow room for future expansion

---

### Facilities & Services System

**Overview**
Facilities are modular buildings that provide services, generate capacity, and consume resources. Each facility serves one primary function but may provide secondary benefits. Services are simple binary flags (service exists or doesn't); there are no service levels.

**Services Mechanic**
- **Service Types**: Power, Research Capability, Manufacturing Capacity, Psi Education, Radar Coverage, Defense
- **Binary Model**: Service either provided or not (no partial services)
- **Consumption**: Facilities and technologies consume services
- **Production Priority**: Power > Manufacturing > Research > Support (determines priority when supply constrained)

**Core Facilities Reference**

| Facility | Size | Production | Consumption | Maintenance | Capacity | Functions |
|----------|------|-----------|-------------|------------|----------|-----------|
| **Power Plant** | 1×1 | +50 power | 10 power (self) | 10K | N/A | Supplies all facilities |
| **Barracks (S)** | 1×1 | Housing | 5 power | 5K | 8 units | Soldier recruitment, housing |
| **Barracks (L)** | 2×2 | Housing | 10 power | 15K | 20 units | Large unit capacity |
| **Storage (S)** | 1×1 | Item storage | 2 power | 3K | 100 items | Basic storage |
| **Storage (M)** | 2×2 | Item storage | 5 power | 10K | 400 items | Expanded storage |
| **Storage (L)** | 3×3 | Item storage | 8 power | 20K | 800 items | Massive storage |
| **Lab (S)** | 2×2 | 10 man-days | 15 power | 15K | Research queue (1) | Basic research |
| **Lab (L)** | 3×3 | 30 man-days | 30 power | 40K | Research queue (2) | Advanced research, +20% scientists |
| **Workshop (S)** | 2×2 | 10 man-days | 15 power | 20K | Manufacturing queue (1) | Basic manufacturing |
| **Workshop (L)** | 3×3 | 30 man-days | 30 power | 50K | Manufacturing queue (2) | Advanced manufacturing, +20% engineers |
| **Hospital** | 2×2 | +2 HP/week, +1 Sanity/week | 10 power | 12K | 20 beds | Healing, mental recovery |
| **Academy** | 2×2 | +1 XP/unit/week | 8 power | 15K | 15 trainees | Unit training, experience gain |
| **Garage** | 2×2 | +50 HP/week repair | 12 power | 10K | 1 craft | Craft repair and maintenance |
| **Hangar (M)** | 2×2 | Storage | 15 power | 15K | 4 craft | Craft storage, small hangars |
| **Hangar (L)** | 3×3 | Storage | 30 power | 35K | 8 craft | Large craft storage |
| **Radar (S)** | 2×2 | +3 detection | 8 power | 8K | 500km range | Mission detection, Geoscape scan |
| **Radar (L)** | 2×2 | +5 detection | 12 power | 15K | 800km range | Enhanced detection, early warning |
| **Turret (M)** | 2×2 | 50 defense points | 15 power | 12K | Single weapon | Base defense, interception |
| **Turret (L)** | 3×3 | 150 defense points | 35 power | 30K | Multiple weapons | Advanced defense, area coverage |
| **Prison** | 3×3 | Prisoner storage | 12 power | 25K | 10 prisoners | Interrogation, research subjects |
| **Temple** | 2×2 | +1 Sanity/week (all units) | 8 power | 12K | Psi Education service | Mental health, morale boost |
| **Corridor** | 1×1 | Connection only | 2 power | 2K | N/A | Facility connector, defense position |

**Facility Lifecycle States**

| State | Production | Maintenance | Notes | Transition |
|-------|-----------|-------------|-------|-----------|
| **Operational** | 100% | Full | Normal operation | Active by default |
| **Construction** | 0% | 0% | Under construction | During build phase |
| **Offline (Player)** | 0% | 50% | Intentionally disabled | Player choice |
| **Offline (Power)** | 0% | 100% | Insufficient power | Automatic when power low |
| **Damaged** | 50-90% | 100% | Partial capability | After combat damage |
| **Destroyed** | 0% | 0% | Non-functional, requires rebuild | After reaching 0 HP |

**Adjacency Bonuses**
Horizontal/vertical connections provide efficiency bonuses:

| Pairing | Bonus | Requirements |
|--------|-------|---|
| Lab + Workshop | +10% research & manufacturing speed | Adjacent (1-hex touching) |
| Workshop + Storage | -10% material cost | Adjacent |
| Hospital + Barracks | +1 HP/week & +1 Sanity/week (all units) | Adjacent |
| Garage + Hangar | +15% craft repair speed | Adjacent |
| Power Plant + Lab/Workshop | +10% efficiency | Within 2-hex distance |
| Radar + Turret | +10% targeting accuracy | Adjacent |
| Academy + Barracks | +1 XP/week (training speed) | Adjacent |

**Stacking Limits**: Maximum 3-4 bonuses per facility (prevents overpowered clustering).

---

### Unit Recruitment & Personnel

**Overview**
Units are the only living personnel in bases. There are no separate scientists or engineers; all work is performed by units allocated to facilities. Units provide housing, training capacity, and combat effectiveness.

**Unit Recruitment Sources**

| Source | Cost | Quality Range | Time | Requirements |
|--------|------|---|---|---|
| **Country Recruitment** | 20-50K | 6-12 stats | Immediate | +0 relations minimum |
| **Faction Recruitment** | 30-75K | 8-14 stats (specialized) | 1 week | +2 relations with faction |
| **Advisor Recruitment** | -15% cost | +1 quality tier | Immediate | Chief Recruitment Officer advisor |
| **Retraining** | 0K | Randomized stats | 1 week | Existing unit pool |
| **Marketplace Purchase** | 40-100K | Variable | Immediate | Credits available |

**Barracks Capacity & Housing**
- **1×1 Barracks**: 8 unit capacity
- **2×2 Barracks**: 20 unit capacity
- **Plus Org Level Bonus**: +1-5 additional slots per level (total range 16-128)
- **Mandatory Salary**: 5K credits per unit per month (base cost)
- **Morale Impact**: Overcrowding (-50% morale if above capacity)

**Unit Stat Progression**

| Stat | Base Range | Growth per Promotion | Max Value | Purpose |
|------|---|---|---|---|
| HP | 15-25 | +1 per promotion | 50+ | Health points |
| Accuracy | 50-100% | +10% per promotion | 150%+ | Weapon effectiveness |
| Reaction | 6-12 | +1 per 2 promotions | 20+ | Initiative, action priority |
| Strength | 6-12 | +1 per promotion | 18+ | Carry capacity, inventory slots |
| Morale | 10+ | -1 per casualty, +1/week rest | 20+ | Psychological resilience |
| Sanity | 6-12 | -5 per failed psi save, +1/week hospital | 12 | Mental health, psi vulnerability |
| XP | 0-1000 | +5-10 per combat mission | 1000 (promotion) | Experience accumulation |

**Unit Specialization System**
- **Promotion Requirements**: 100 XP to unlock specialization
- **Specialization Types**:
  - **Gunner**: +2 damage, -5% accuracy (aggressive)
  - **Medic**: Can heal allies, -10% damage (support)
  - **Sniper**: +20% accuracy, -1 reaction (tactical)
  - **Assault**: +1 HP, +1 reaction (balanced)
- **Respec Option**: Retrain to change specialization (costs 5K, 1 week time)

**Health Recovery System**
- **Base Recovery**: +1 HP per week (passive)
- **Hospital Bonus**: +2 HP per week (capacity limited)
- **Medic Specialty**: +0.5 HP per medic per unit per week (stacks with hospital)
- **Over-Healing**: Cannot exceed max HP value

**Sanity System**
- **Base Recovery**: +1 Sanity per week (passive)
- **Hospital Bonus**: +1 Sanity per week (stacks)
- **Temple Bonus**: +1 Sanity per week (religious morale)
- **Psi Exposure**: -5 Sanity per failed psi-defense save
- **Breakdown**: At 0 Sanity, unit becomes unreliable (-50% accuracy, -10% morale)
- **Treatment Time**: Hospital recovery 2-4 weeks to restore full sanity

**Equipment System**
- **Weapon Slots**: 2 per unit (primary + secondary)
- **Armor Slot**: 1 per unit (body armor)
- **Inventory Limit**: Strength stat determines carry capacity
- **Equipment Transfer**: Instant transfer between units in base
- **Equipment Selling**: Can sell equipment at 50% purchase price

**Prisoner System**
- **Prison Facility**: Provides capacity for captured alien units
- **Prisoner Lifetime**: 30-60 days (varies by race)
- **Interrogation**: Prisoners provide research opportunity (+30 man-days to Alien Interrogation research)
- **Disposal Options**:
  - Execute: -5 karma, -2000 credits (body disposal)
  - Experiment: -3 karma, +50 man-days research (unethical)
  - Release: +5 karma, risk of enemy intelligence leak
  - Exchange: Trade for diplomatic favor (+5 relations with recipient)

---

### Equipment & Crafts Management

**Overview**
Items and crafts represent player equipment inventory and transport capabilities. All items have weight and space; crafts occupy dedicated slots in hangars and garages. Strategic management of equipment directly impacts field effectiveness.

**Item System**
- **Weight Property**: All items have weight stat (ranges 0.5-10 units)
- **Storage Space**: Each item occupies 1-5 grid spaces based on SIZE stat
- **Storage Limits**: Storage facilities have maximum capacity (100-800 items by size)
- **Overflow Handling**: Cannot exceed storage (purchase blocked if inventory full)
- **Selling**: Marketplace resale at 50% of purchase price
- **Transfers**: Transfer between bases via transfer system (1-14 day delivery)
- **Inventory Management**: Stack items by type to save space

**Craft System**
- **Hangar Slots**: Each hangar space holds 1 craft
- **Vehicle Sizes**:
  - Small craft: 1 slot (fighter, scout)
  - Medium craft: 2 slots (bomber, transport)
  - Large craft: 4 slots (capital ship)
- **Marketplace Purchase**: Buy additional craft at 40-150K credits each
- **Craft Weapons**: Each craft has armed hardpoints (varies by craft type)
- **Craft Armor**: Craft have armor class and HP (separate from health)
- **Crew Requirements**: 3-20 personnel depending on craft size
- **Fuel System**: Requires fuel item (costs 5% of tank capacity per travel)
- **Repair System**: Craft repair facility provides +50 HP/week repair

**Craft Maintenance**
- **Rearm**: Automatic at base (no separate rearm phase)
- **Energy Recovery**: Craft energy regenerates after every travel (100% recovery)
- **Repair Queue**: Damaged craft enter repair queue (automatic)
- **Repair Time**: 10% HP per week repair time + facility bonuses

---

### Base Maintenance & Economics

**Overview**
Bases are capital-intensive and require continuous resource investment. Maintenance costs scale with base complexity and scale non-linearly with size, creating economic pressure to optimize efficiency.

**Base Maintenance Costs**

| Cost Category | Calculation | Monthly Cost |
|---|---|---|
| **Layout Maintenance** | (Base Size)² × 5K | 80-2000K (4×4 to 7×7) |
| **Facility Maintenance** | Per facility × individual cost | 5-50K per facility |
| **Inactive Facility Tax** | 50% of active maintenance | 2-25K per disabled facility |
| **Unit Salaries** | 5K per unit per month | Variable (100-1000K+) |
| **Craft Maintenance** | 2K per craft per month | Variable (4K-100K) |
| **Labor Costs** | Man-days × 1K per day | Variable (research/manufacturing) |
| **Facility Damage Repairs** | HP needed × 1K per point | Variable (0-500K) |

**Total Base Cost Formula**
```
Monthly Cost = Layout + (Operational Facilities × Facility Cost) + (Disabled Facilities × 0.5 Facility Cost) + (Units × 5K) + (Crafts × 2K) + Labor + Repairs
Monthly Income = (Country Funding × Base Multiplier) + (Manufacturing Profit) + (Research Milestone Bonus) + (Equipment Sales)
Net Monthly Budget = Monthly Income - Monthly Cost
```

**Economic Management Strategies**
- **Efficient Layout**: Clusters reduce average adjacency distance but increases positioning complexity
- **Selective Operations**: Disable facilities to reduce costs during resource shortage
- **Specialization**: Focus on 2-3 facility types to maximize bonuses
- **Scaling**: Large bases require substantial monthly income; plan growth carefully
- **Overflow Handling**: Excess income per month accumulates as credits

---

### Base Defense & Interception

**Overview**
Bases are vulnerable to alien interception attacks. Defense is primarily passive (turrets, defensive facilities, HP values) supplemented by player active defense through Battlescape engagement.

**Defense Mechanics**
- **Passive Defense**: Turrets, radars, defensive facilities provide defense points
- **Active Defense**: Player can engage UFO in Battlescape (additional interception attempt)
- **Defense Rating**: Sum of all defense facility points (typical 50-300 points for established bases)

**Defense Resolution**
```
If Defense Points > UFO Attack Power: UFO defeated, base saved
If 50 < Defense Points < UFO Attack Power: UFO damages random facility (50% damage)
If Defense Points < 50: UFO succeeds, multiple facility damage (80% damage each)
```

**Facility Damage System**
- **HP Tracking**: Each facility has separate HP value (not armor, pure HP)
- **Random Targeting**: UFO attack targets 1-3 random facilities
- **Damage Application**: Each facility takes independent damage roll (10-50 points typical)
- **Facility States**:
  - 100% HP: Operational
  - 50-99% HP: Damaged (50-90% production)
  - 10-49% HP: Severely Damaged (25-50% production)
  - 0% HP: Destroyed (non-operational, rebuild required)

**Repair Mechanics**
```
Repair Time = (Damage Taken / Max HP) × (Facility Build Time) + (Facility Type Modifier)
Repair Cost = (Damage Taken / Max HP) × (50% of Build Cost)
```
- Example: Workshop with 50 max HP takes 30 damage, 2×2 size
  - Build time: 30 days
  - Repair time: (30/50) × 30 = 18 days
  - Repair cost: (30/50) × (50% of 250K) = 75K

**Battlescape Defense Integration**
- If player engages UFO in Battlescape, outcome determines facility damage
- Player victory: UFO destroyed, no facility damage
- Player defeat: UFO deals damage based on Battlescape outcome
- Draw: Partial damage (UFO escapes, inflicts 50% damage)

**Defense Building Strategy**
- **Early Game**: Vulnerable (1-2 turrets)
- **Mid Game**: Established defense (4-6 turrets, radar coverage)
- **Late Game**: Heavy defense (8+ turrets, multiple radars, defensive layout)
- **Specialization**: Can prioritize offense or defense based on playstyle

---

### Base Integration & Feedback Loops

**Overview**
Basescape integrates with Geoscape, Battlescape, and economy systems through vertical and horizontal feedback loops creating emergent gameplay and strategic depth.

**Vertical Integration** (Cascading Effects)
- **Geoscape Salvage** → Storage → Manufacturing → Equipped Units
- **Research Breakthrough** → Unlocks new manufacturing options → Equipment availability → Combat effectiveness
- **Battlescape XP** → Academy training → Promotions → Unit specializations → Improved field performance
- **Craft Damage** → Garage repair → Restored interception capability → Mission prevention

**Horizontal Integration** (Playstyle Support)

**Research-Focused Strategy**:
- Prioritize Lab, Academy, Prison facilities
- Invest in scientist recruitment and research capacity
- Early tech advantage enables late-game equipment
- Playstyle: Technology drives military superiority

**Manufacturing-Focused Strategy**:
- Prioritize Workshop, Storage, Garage facilities
- Maximize production queues and efficiency
- Convert salvage to profit margin efficiently
- Playstyle: Economic dominance through production

**Defense-Focused Strategy**:
- Prioritize Turret, Radar, Hangar facilities
- Invest in craft procurement and interception capability
- Prevent UFO missions through superior defense
- Playstyle: Military hardening and interception

**Support-Focused Strategy**:
- Prioritize Hospital, Academy, Barracks, Temple facilities
- Maximize unit recruitment and training
- Develop elite units through extended training
- Playstyle: Personnel quality over quantity

**Feedback Loops**
- **Victory Loop**: Mission Victory → Salvage → Manufacturing → Equipped Units → Better Mission Success (positive reinforcement)
- **Research Loop**: Research Completion → Manufacturing Unlock → Production → Income → More Research (exponential growth)
- **Recovery Loop**: Combat Damage → Hospital/Repair → Ready Units/Craft → Deployment (damage mitigation)
- **Specialization Multiplier**: Facility Synergy Bonus → Production Efficiency → Surplus Equipment → Transfer to Other Bases → Multiplicative strategic advantage

**Monthly Reconciliation Report**
- Research/manufacturing progress summary
- Personnel status (total/recovering/ready)
- Facility status (operational/damaged/offline)
- Inventory summary (items, crafts, capacity usage)
- Financial summary (income, costs, net profit/loss)
- Alerts (power shortage, storage overflow, unrest, structural damage)
- Strategic recommendations (capacity expansion, facility repair priorities, economic adjustments)

---

### Base Radar Coverage

**Overview**
Radar facilities provide Geoscape mission detection and early warning. Higher radar coverage increases mission visibility range, directly impacting player ability to intercept threats before they complete objectives.

**Radar Mechanics**
- **Detection Range**: 500-1000km per radar facility (based on facility size)
- **Stacking**: Multiple radars increase total detection area (coverage circles overlap)
- **Detection Bonus**: +3-5 per radar facility
- **Detection Formula**: Range × (1 + Bonuses × 0.1) = Total effective detection radius
- **Passive Scanning**: Automatic Geoscape scan every day cycle
- **Mission Visibility**: Missions within detection radius appear on map

**Detection Success Factors**
- Radar range and quantity
- Enemy unit stealth properties
- Electronic warfare countermeasures (from upgrades)
- UFO type (larger craft more visible)
- Atmospheric conditions (weather events affect radar)

**Hiding Mechanics**
- **Stealth Facilities**: Specialized facilities reduce base radar signature (-50% detection range)
- **Cloaking Technology**: Research unlock reduces visibility (-75% detection)
- **Underground Construction**: Biome bonus (volcanic/mountain bases naturally stealthier)

---

### Base Reports & Analytics

**Overview**
Monthly base reports provide comprehensive overview of base status, enabling informed strategic decisions and identifying optimization opportunities.

**Report Contents**
- **Production Summary**: Research progress, manufacturing queue, completion dates
- **Personnel Status**: Total units, recovering/ready count, morale average, sanity levels
- **Facility Status**: Operational count, damaged facilities, offline facilities, efficiency rating
- **Inventory Status**: Item count, storage capacity percentage, valuable items, low-stock alerts
- **Craft Status**: Total craft, ready/damaged/repairing count, fuel reserves, crew status
- **Financial Summary**: Monthly income, monthly costs, net profit/loss, bank balance, trend analysis
- **Defense Status**: Total defense points, turret status, radar coverage, vulnerability zones
- **Alerts & Warnings**:
  - Power shortage (suggest Power Plant expansion)
  - Storage overflow (suggest Storage expansion)
  - Personnel unrest (suggest morale improvement)
  - Structural damage (suggest repair priority)
  - Economic deficit (suggest cost reduction or income increase)
  - Capacity inefficiency (suggest facility reorganization)

**Strategic Insights**
- Suggested facility additions based on current bottlenecks
- Efficiency rating (utilization percentage across all facilities)
- Comparative analysis (base vs. other bases)
- Trend indicators (improving/declining efficiency over months)
- Optimization recommendations (adjacency bonus opportunities, power efficiency, etc.)
	

