# OpenXCOM Ruleset Reference Guide

*Extracted and adapted for AlienFall development - October 13, 2025*

This document provides a comprehensive reference for OpenXCOM ruleset mechanics and API structures. Since the original ufopaedia.org site is currently inaccessible due to Cloudflare protection, this guide has been compiled from OpenXCOM source code analysis and community documentation.

## Overview

OpenXCOM uses YAML-based rulesets to define all game mechanics, allowing extensive modding capabilities. Rulesets are loaded from `Ruleset/` folders in mods and define everything from unit stats to research trees.

## Core Ruleset Structure

### Main Ruleset Files

```
Ruleset/
├── ruleset.yml          # Main ruleset configuration
├── items.yml            # Item definitions
├── units.yml            # Unit/alien definitions
├── crafts.yml           # Craft/vehicle definitions
├── facilities.yml       # Base facility definitions
├── researches.yml       # Research tree definitions
├── manufactories.yml    # Manufacturing definitions
├── alienDeployments.yml # Alien mission deployments
├── alienMissions.yml    # Alien mission types
├── terrains.yml         # Terrain definitions
├── maps.yml            # Map definitions
├── ufopaedia.yml       # In-game encyclopedia
└── extraSprites.yml    # Additional sprite definitions
```

## Key API Concepts

### 1. Items System

Items define weapons, equipment, and consumables:

```yaml
items:
  - type: STR_PISTOL
    name: STR_PISTOL
    categories: [STR_WEAPON]
    size: 0.0
    costBuy: 300
    costSell: 150
    weight: 2
    bigSprite: 0
    floorSprite: 0
    handSprite: 0
    bulletSprite: 0
    fireSound: 0
    hitSound: 0
    hitAnimation: 0
    power: 32
    damageType: 0
    accuracyAuto: 40
    accuracySnap: 60
    accuracyAimed: 80
    tuAuto: 20
    tuSnap: 15
    tuAimed: 25
    clipSize: 12
    battleType: 0
    twoHanded: false
    waypoints: 0
    compatibleAmmo:
      - STR_PISTOL_CLIP
    damageAlter:
      ItemDamageBonus: 0
      ItemDamageMultiplier: 100
```

### 2. Unit/Alien Definitions

Units define soldier and alien stats:

```yaml
units:
  - type: STR_SOLDIER
    race: STR_HUMAN
    rank: STR_LIVE_SOLDIER
    stats:
      tu: 50
      stamina: 40
      health: 30
      bravery: 50
      reactions: 50
      firing: 50
      throwing: 50
      strength: 30
      psiStrength: 0
      psiSkill: 0
      melee: 50
    armor: STR_NONE_UC
    standHeight: 16
    kneelHeight: 12
    value: 20000
    specab: 0
    livingWeapon: false
    psiWeapon: false
    capture: true
    builtInWeaponSets:
      - STR_PISTOL
      - STR_PISTOL_CLIP
```

### 3. Research System

Research defines the technology tree:

```yaml
research:
  - name: STR_THE_ULTIMATE_WEAPON
    cost: 1000
    points: 1000
    dependencies:
      - STR_ALIEN_ORIGINS
      - STR_THE_MARTIAN_SOLUTION
    unlocks:
      - STR_PLASMA_CANNON
      - STR_FUSION_BALL_LAUNCHER
    getOneFree:
      - STR_PLASMA_CANNON
    requires:
      - STR_ALIEN_COMMANDER
```

### 4. Manufacturing System

Manufacturing defines production capabilities:

```yaml
manufacture:
  - name: STR_STINGRAY
    category: STR_AIRCRAFT
    requiresBaseFunc: [STR_HANGAR]
    space: 0
    time: 1800
    cost: 1400000
    requiredItems:
      STR_AVALANCHE_LAUNCHER: 1
      STR_STINGRAY_MISSILES: 2
    producedItems:
      STR_STINGRAY: 1
```

### 5. Craft/Vehicle System

Crafts define flying vehicles:

```yaml
crafts:
  - type: STR_SKYRANGER
    sprite: 0
    weaponStrings:
      - STR_NONE
      - STR_NONE
    maxItems: 14
    maxSoldiers: 14
    maxVehicles: 0
    soldiers: 8
    vehicles: 0
    items: 6
    speedMax: 760
    speedMaxRadian: 0.017453
    acceleration: 2
    accelerationRadian: 0.000349
    fuelMax: 50
    damageMax: 22
    weaponCapacity:
      - 0
      - 0
    weaponTypes:
      - 0
      - 0
    radarRange: 672
    radarChance: 10
    sightRange: 1696
    maxAltitude: 4
    refuelItem: STR_ELERIUM_115
    repairRate: 1
    repairPercent: 0.1
    costBuy: 500000
    costRent: 0
    costSell: 250000
```

### 6. Facility System

Facilities define base buildings:

```yaml
facilities:
  - type: STR_HANGAR
    size: 2
    buildCost: 150000
    buildTime: 24
    monthlyCost: 20000
    storage: 0
    personnel: 0
    capacity: 0
    mapName: HANGAR
    lift: false
    hyper: false
    mind: false
    grav: false
    damage: 0
    provides:
      - STR_HANGAR
```

### 7. Alien Deployment System

Alien deployments define mission encounters:

```yaml
alienDeployments:
  - type: STR_SMALL_SCOUT
    data:
      - alienRank: 0
        lowQty: 1
        highQty: 2
        dQty: 1
        percentageOutsideUfo: 100
        itemSets:
          - - STR_SECTOID
            - STR_PLASMA_PISTOL
          - - STR_SECTOID
            - STR_PLASMA_PISTOL
            - STR_PLASMA_PISTOL
    width: 20
    length: 20
    height: 4
    terrains:
      - STR_FOREST
      - STR_JUNGLE
      - STR_DESERT
      - STR_MOUNTAIN
      - STR_POLAR
```

### 8. Terrain System

Terrains define battle maps:

```yaml
terrains:
  - name: STR_FOREST
    script: F0.PCK
    mapDataSets:
      - BLANKS
      - FOREST01
      - FOREST02
    mapBlocks:
      - name: STR_FOREST
        width: 10
        length: 10
        height: 4
        data:
          - STR_DIRT
          - STR_GRASS
          - STR_TREES
          - STR_ROCKS
```

### 9. Mission System

Alien missions define UFO activities:

```yaml
alienMissions:
  - type: STR_ALIEN_ABDUCTION
    points: 50
    waves:
      - ufo: STR_SMALL_SCOUT
        count: 1
        trajectory: STR_TRAJECTORY_0
        timer: 1800
      - ufo: STR_MEDIUM_SCOUT
        count: 1
        trajectory: STR_TRAJECTORY_1
        timer: 3600
    raceWeights:
      STR_SECTOID: 40
      STR_FLOATER: 30
      STR_SNAKEMAN: 20
      STR_MUTON: 10
```

## Key Mechanics

### Damage Types
- 0: None
- 1: Armor Piercing
- 2: Incendiary
- 3: High Explosive
- 4: Laser
- 5: Plasma
- 6: Stun
- 7: Melee
- 8: Acid
- 9: Smoke

### Unit Ranks
- 0: Rookie
- 1: Squaddie
- 2: Sergeant
- 3: Captain
- 4: Colonel
- 5: Commander

### Battle Types
- 0: Firearm
- 1: Ammo
- 2: Melee
- 3: Grenade
- 4: Proximity Grenade
- 5: Medikit
- 6: Scanner
- 7: Mind Probe
- 8: Psi Amp
- 9: Corpse

### Special Abilities
- 0: None
- 1: Flying
- 2: PSI
- 3: MC Reader immunity
- 4: MC Controller immunity
- 5: MC Controller
- 6: MC Reader
- 7: Fire immunity
- 8: Acid immunity
- 9: Smoke immunity

## Advanced Combat Mechanics

### Accuracy and Hit Chance
```yaml
# Accuracy calculation factors
accuracyBase: 50          # Base accuracy percentage
accuracyModifier: 10      # Per-tile range penalty
kneelModifier: 115        # Kneeling accuracy bonus (%)
woundModifier: 50         # Wounded accuracy penalty (%)
moraleModifier: 100       # Morale-based accuracy modifier
```

### Time Units (TU) System
```yaml
# TU costs for actions
tuWalk: 4                 # Cost per tile walked
tuRun: 8                  # Cost per tile run
tuStrafe: 3               # Cost per tile strafed
tuTurn: 1                 # Cost per 45-degree turn
tuReserve: 50             # TU reserved for reaction fire
```

### Morale System
```yaml
# Morale ranges and effects
moraleMin: 0              # Minimum morale
moraleMax: 100            # Maximum morale
moraleBreakThreshold: 25  # Point where unit breaks
braveryModifier: 10       # Bravery stat influence
```

## Alien AI Behavior

### AI States
- **0**: Patrol - Random movement within range
- **1**: Ambush - Wait for targets, high aggression
- **2**: Hunt - Actively pursue visible targets
- **3**: Combat - Aggressive close-range fighting

### AI Priorities
```yaml
aiPriorities:
  - targetPriority: 10     # Priority for targeting enemies
  - patrolPriority: 5      # Priority for patrolling
  - reservePriority: 3     # Priority for holding position
```

## Research and Progression

### Research Categories
- **Biology**: Alien life forms and physiology
- **Physics**: Energy weapons and propulsion
- **Engineering**: Craft and facility construction
- **Psionics**: Mind control and psychic abilities

### Technology Tree Structure
```yaml
researchTree:
  - name: STR_LASER_WEAPONS
    unlocks:
      - STR_LASER_PISTOL
      - STR_LASER_RIFLE
      - STR_HEAVY_LASER
    requires:
      - STR_ALIEN_ALLOYS
    points: 500
    cost: 25000
```

## Economy and Resources

### Resource Types
- **Money**: Funding from countries
- **Scientists**: Research point generation
- **Engineers**: Manufacturing capacity
- **Elerium-115**: Advanced technology fuel
- **Alien Alloys**: Construction material

### Market Fluctuations
```yaml
marketData:
  basePrice: 100           # Base item price
  volatility: 20           # Price variation percentage
  supplyModifier: 10       # Supply/demand influence
  countryModifier: 5       # Country-specific pricing
```

## Geoscape Mechanics

### UFO Trajectories
- **0**: Landing site approach
- **1**: Patrol pattern
- **2**: Attack run
- **3**: Retreat trajectory
- **4**: Terror mission path

### Detection Ranges
```yaml
detectionRanges:
  visualRange: 100         # Visual detection distance (km)
  radarRange: 150          # Radar detection distance (km)
  hyperwaveRange: 300      # Hyperwave detection distance (km)
```

## Implementation Considerations

### Performance Optimization
- **Lazy Loading**: Load rulesets on demand
- **Caching**: Cache parsed YAML data
- **Validation**: Validate rulesets at load time
- **Memory Management**: Pool common objects

### Mod Compatibility
- **Override System**: Allow mods to override base rules
- **Merge Logic**: Deep merge of nested structures
- **Version Checking**: Ensure mod compatibility
- **Dependency Resolution**: Handle research/manufacturing dependencies

### Error Handling
- **Missing Files**: Graceful fallback to defaults
- **Invalid Data**: Comprehensive validation with error messages
- **Circular Dependencies**: Detection and prevention
- **Balance Checks**: Automatic balance validation

## Migration Path for AlienFall

### Phase 1: Core Systems
1. Implement YAML loading system
2. Create basic item/unit definitions
3. Add research tree structure
4. Implement manufacturing system

### Phase 2: Combat Systems
1. Port accuracy and TU mechanics
2. Add morale and AI systems
3. Implement damage types
4. Create battle state management

### Phase 3: Advanced Features
1. Add mod loading support
2. Implement geoscape mechanics
3. Create alien deployment system
4. Add terrain and map generation

### Phase 4: Polish and Balance
1. Balance all systems
2. Add comprehensive validation
3. Create modding tools
4. Performance optimization

This OpenXCOM API reference provides a solid foundation for implementing X-COM style mechanics in AlienFall, with extensive modding capabilities and balanced gameplay systems.