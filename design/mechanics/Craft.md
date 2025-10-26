# Craft System

> **Implementation**: `engine/geoscape/crafts/`, `engine/interception/`
> **Tests**: `tests/geoscape/`
> **Related**: `docs/geoscape/missions.md`, `docs/battlescape/README.md`

Vehicle and aircraft systems for strategic movement, interception, and transportation.

## ✈️ Craft Architecture

### Craft Statistics
Core attributes defining vehicle performance and capabilities.

**Performance Stats:**
- **Speed**: Movement rate and interception capability
- **Health**: Durability and damage resistance
- **Weapon Slots**: Available weapon attachment points
- **Addon Slots**: Equipment and modification capacity
- **Personnel Limit**: Maximum crew/passenger capacity
- **Cargo Limit**: Item transportation capacity

**Operational Stats:**
- **Maintenance Cost**: Ongoing repair and upkeep expenses
- **Fuel Type/Consumption**: Energy requirements for operation
- **Range**: Maximum travel distance per fuel unit
- **Craft Type**: Air, water, or land-based classification
- **Action Points**: Tactical maneuver resource (base 4 AP)

**Combat Stats:**
- **Dodge Bonus**: Evasion capability in interception
- **Aim Bonus**: Accuracy modifiers for weapons
- **Armor**: Damage resistance value
- **Radar Power/Range/Stealth**: Detection capabilities
- **Size**: Base storage space requirement (1-4+ units)

## 🔧 Craft Equipment

### Equipment Slots
Modular attachment system for weapons and special systems.

**Slot Configuration:**
- **Interception Craft**: 1-2 weapon slots, 0-1 addon slots, no personnel
- **Transport Craft**: 0-1 weapon slots, 1-2 addon slots, personnel capacity
- **Maximum Slots**: 3 total slots per craft (weapons/addons mixable)

### Encumbrance System
Capacity limits for personnel and cargo transportation.

**Capacity Rules:**
- **Personnel**: Unit size determines space requirements (1, 2, or 4 units)
- **Cargo**: Items fit or don't fit based on craft capacity
- **No Weight Impact**: Only size matters for fitting
- **Equipment Scaling**: Weapons sized for different craft types

## 🛰️ Craft Operations

### Radar Coverage
Detection and surveillance capabilities for aerial reconnaissance.

**Radar Mechanics:**
- **Power/Range**: Detection strength and distance
- **Stealth Interaction**: Counter-stealth capabilities
- **Province Scanning**: Automatic detection checks when entering areas
- **Strategic Intelligence**: Mission planning and threat assessment

### Personnel Management
Crew and passenger capacity for different craft roles.

**Capacity Types:**
- **Zero Capacity**: Unmanned or specialized craft
- **Built-in Capacity**: Standard crew accommodations
- **Addon Upgrades**: Additional space through modifications
- **Unit Size System**: Consistent with base barracks capacity

### Geoscape Movement
Strategic navigation and deployment on the world map.

**Movement Process:**
- **Province Selection**: Choose destination from current location
- **Base Assignment**: Select originating facility
- **Travel Execution**: Automatic movement with radar scanning
- **Interception Decisions**: Combat engagement options upon arrival

## 📈 Craft Progression

### Experience System
Upgrade mechanics through successful operations and accumulated experience.

**Experience Mechanics:**
- **Slower Progression**: Craft leveling takes longer than units
- **Standard Levels**: 100, 300, 600, 1000, 1500, 2100 experience thresholds
- **Class Upgrades**: Interceptor → Interceptor II transitions
- **Small Improvements**: Incremental stat gains between classes

### Strategic Decision
- **Upgrade vs Replace**: Compare experience investment vs new craft construction
- **Specialization**: Focus on interception, transport, or mixed roles
- **Resource Allocation**: Balance craft development with other systems

## 🔧 Craft Maintenance

### Repair System
Restoration mechanics for damaged vehicles.

**Repair Mechanics:**
- **Natural Recovery**: 10% health restoration per week
- **Facility Acceleration**: Dedicated repair facilities for faster recovery
- **Resource Costs**: Materials and personnel for repairs
- **Downtime Impact**: Reduced operational capacity during repairs

### Fuel System
Energy management for craft operations and travel.

**Fuel Mechanics:**
- **Consumption Rate**: Fuel units required per travel segment
- **Range Calculation**: Path cost based on terrain and craft type
- **Turn Limits**: Speed attribute determines travels per turn
- **No Refueling**: Pay fuel cost at travel initiation

## ⚡ Craft Resources

### Action Points
Tactical resource system for maneuvers and combat.

**AP System:**
- **Turn-Based**: Replenish at the start of each turn
- **Maneuver Costs**: Different actions consume varying AP
- **Strategic Planning**: Balance movement and combat actions

### Energy Pool
Internal power reserve for special abilities and enhanced performance.

**Energy Mechanics:**
- **Short-term Reserve**: Battery/ammo equivalent for craft
- **Regeneration**: Slow recovery during interception combat
- **Ability Costs**: Special systems consume energy
- **Capacity Limits**: Maximum energy based on craft design

## 🎮 Player Experience

### Craft Strategy
- **Fleet Composition**: Balance interception and transport capabilities
- **Mission Assignment**: Match craft to appropriate operation types
- **Maintenance Planning**: Schedule repairs and avoid operational downtime
- **Resource Management**: Monitor fuel and personnel requirements

### Operational Challenges
- **Fuel Constraints**: Limited range affects strategic flexibility
- **Repair Downtime**: Damaged craft reduce operational capacity
- **Capacity Limits**: Personnel and cargo restrictions
- **Experience Investment**: Long-term commitment to craft development

### Craft Roles
- **Interception**: Combat-focused craft for air defense
- **Transport**: Personnel and cargo movement between bases
- **Reconnaissance**: Radar-equipped craft for intelligence gathering
- **Specialized**: Unique craft for specific mission requirements

## 📊 Craft Balance

### Difficulty Scaling
- **Rookie**: Fast repairs, low fuel costs, generous capacity
- **Veteran**: Standard craft performance and requirements
- **Commander**: Slower repairs, higher fuel costs, limited capacity
- **Legend**: Very slow repairs, maximum fuel costs, minimal capacity

### Integration Points
- **Geoscape Synergy**: Craft enable global operations and interception
- **Manufacturing**: Craft production requires facilities and resources
- **Research**: Technology unlocks advanced craft capabilities
- **Base Management**: Hangar space limits craft deployment

### Balance Considerations
- **Cost Scaling**: Advanced craft require significant investment
- **Operational Risk**: Interception combat carries loss potential
- **Strategic Value**: Craft enable global presence and response
- **Resource Trade-offs**: Fuel and maintenance compete with other systems