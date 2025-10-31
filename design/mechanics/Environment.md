# Environment & Terrain System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Battlescape.md, Assets.md, Geoscape.md
> **Source Note**: This file consolidates environment information from Battlescape.md (Environmental Systems, Weather, Terrain), Assets.md (Environmental art), and map generation mechanics

## Table of Contents

- [Overview](#overview)
- [Terrain System](#terrain-system)
- [Environmental Hazards](#environmental-hazards)
- [Weather System](#weather-system)
- [Day vs Night Conditions](#day-vs-night-conditions)
- [Destructible Terrain](#destructible-terrain)
- [Special Environments](#special-environments)
- [Biome System](#biome-system)
- [Integration with Other Systems](#integration-with-other-systems)

---

## Overview

### System Architecture

The Environment System manages all non-unit, non-object elements of tactical maps: terrain properties, environmental hazards (smoke, fire, gas), weather conditions, lighting, and destructible elements. These systems create dynamic tactical challenges and strategic depth by modifying visibility, movement, and combat effectiveness.

**Design Philosophy**

Environmental systems create meaningful tactical decisions through interaction with core mechanics. Weather reduces visibility and movement, fire creates area denial, destructible terrain enables tactical improvisation. The environment is not passive scenery but an active tactical element.

**Core Principle**: Environment as tactical element, not cosmetic detail.

---

## Terrain System

### Terrain Types

**Source Reference**: Battlescape.md §Entity Types

All map tiles have terrain properties affecting gameplay mechanics:

#### Core Terrain Categories

| Category | Movement Cost | Cover Value | Block LOS | Block Fire | Examples |
|----------|--------------|-------------|-----------|-----------|----------|
| **Floor** | 1 (base) | 0% | No | No | Grass, concrete, dirt |
| **Wall** | Impassable | 100% | Yes | Yes | Buildings, rock walls |
| **Water** | 3 or impassable | 0% | No | No | Rivers, lakes, ocean |
| **Difficult** | 2-3 | 0-20% | No | No | Rubble, forest, swamp |
| **Cover** | 1-2 | 40-80% | Partial | Partial | Low walls, sandbags |

---

### Detailed Terrain Properties

#### Floor Terrain (Walkable)

**Movement Properties**:
- **Base Cost**: 1 AP per tile
- **Modifiers**: Weather, unit encumbrance, status effects
- **Special**: Some floor types have material properties (wood, metal, ice)

**Sight Properties**:
- **Cost of Sight**: 1 (standard)
- **Visibility**: Does not block line of sight

**Examples**:
- **Grass**: Standard floor, no special properties
- **Concrete**: Standard floor, fire-resistant
- **Dirt**: Standard floor, becomes mud in rain (+1 move cost)
- **Ice**: Slippery (+1 move cost, chance of falling)
- **Metal Grating**: Conductive (electrical hazards)

---

#### Wall Terrain (Blocked)

**Movement Properties**:
- **Base Cost**: Impassable (cannot enter)
- **Exceptions**: Flying units, ethereal units (special cases)

**Sight Properties**:
- **Cost of Sight**: Infinite (complete obstruction)
- **Visibility**: Blocks all line of sight

**Fire Properties**:
- **Line of Fire**: Completely blocked
- **Exceptions**: Explosive weapons (splash damage)

**Examples**:
- **Stone Wall**: Indestructible, permanent obstruction
- **Wooden Wall**: Destructible (20 HP, burns)
- **Metal Wall**: Destructible (50 HP, fire-resistant)
- **Glass Wall**: Fragile (5 HP, transparent before destroyed)

---

#### Water Terrain

**Movement Properties**:
- **Shallow Water**: 2 AP per tile
- **Deep Water**: 3 AP per tile or impassable (unit-dependent)
- **Flying Units**: Can cross without penalty
- **Aquatic Units**: Reduced cost (1 AP)

**Combat Properties**:
- **Cover**: Partial (20-40% based on depth)
- **Accuracy Penalty**: -10% when targeting units in water
- **Fire Resistance**: Extinguishes fire immediately

**Examples**:
- **Puddle**: Shallow (1 tile), mud properties
- **Stream**: Shallow (2-3 tiles wide), flowing
- **River**: Deep (4+ tiles), requires swimming
- **Lake/Ocean**: Very deep, impassable for most units

---

#### Difficult Terrain

**Movement Properties**:
- **Increased Cost**: 2-3 AP per tile
- **Reason**: Dense vegetation, rubble, debris

**Sight Properties**:
- **Partial Obstruction**: +1-2 sight cost
- **Cover Bonus**: 20-40% depending on density

**Examples**:
- **Forest**: 2 AP movement, +1 sight cost, 20% cover
- **Dense Forest**: 3 AP movement, +2 sight cost, 40% cover
- **Rubble**: 2 AP movement, +1 sight cost, 30% cover
- **Debris Field**: 2 AP movement, +1 sight cost, 20% cover
- **Swamp**: 3 AP movement, sanity damage (-1 per 5 turns)
- **Sand**: 2 AP movement, reduces accuracy (-5%)

---

#### Cover Terrain

**Movement Properties**:
- **Standard or Increased**: 1-2 AP depending on type
- **Interaction**: Unit can "take cover" behind object

**Combat Properties**:
- **Cover Bonus**: 40-80% damage reduction
- **Height**: Low cover (40%), Medium cover (60%), High cover (80%)
- **Destructible**: Most cover can be destroyed

**Examples**:
- **Low Wall**: 1 AP, 40% cover, 20 HP
- **Sandbags**: 1 AP, 60% cover, 30 HP
- **Barricade**: 2 AP, 60% cover, 25 HP
- **Vehicle Wreck**: 2 AP, 80% cover, 50 HP
- **Tree**: 1 AP, 40% cover, 15 HP

---

### Terrain Material Properties

Materials determine destruction behavior and environmental interaction:

| Material | HP | Fire Behavior | Explosive Resistance | Bullet Resistance |
|----------|-----|---------------|---------------------|-------------------|
| **Wood** | 10-20 | Burns (spreads fire) | Low (25%) | Low (20%) |
| **Stone** | 50-100 | Fire-resistant | High (75%) | High (80%) |
| **Metal** | 30-60 | Fire-resistant | Medium (50%) | High (70%) |
| **Glass** | 3-8 | Shatters | Very Low (10%) | Very Low (5%) |
| **Concrete** | 60-120 | Fire-resistant | Very High (90%) | Very High (90%) |
| **Vegetation** | 5-15 | Burns easily | Very Low (10%) | Very Low (10%) |

---

## Environmental Hazards

**Source Reference**: Battlescape.md §Environmental Systems

### Smoke

**Properties**:
- **Duration**: 3-8 turns (disperses gradually)
- **Spread**: Expands to adjacent tiles each turn (20% chance per adjacent tile)
- **Stacking**: Multiple smoke sources accumulate intensity

**Gameplay Effects**:

| Intensity | Sight Cost | Accuracy Penalty | Stun Damage | Movement Cost |
|-----------|-----------|------------------|-------------|---------------|
| **Light** | +2 per tile | -10% | 0 | +0 |
| **Medium** | +3 per tile | -20% | 1 per turn | +1 |
| **Heavy** | +4 per tile | -30% | 1 per turn | +1 |

**Generation Sources**:
- **Smoke Grenades**: Intentional deployment, 5-turn duration
- **Fire**: Burning objects produce smoke
- **Explosions**: Large explosions create temporary smoke (2-3 turns)
- **Destroyed Vehicles**: Permanent smoke source (until vehicle removed)

**Tactical Use**:
- **Concealment**: Break line of sight for safe movement
- **Denial**: Force enemies out of positions
- **Screening**: Protect flanking maneuvers

---

### Fire

**Properties**:
- **Duration**: 4-10 turns (self-extinguishes gradually)
- **Spread**: Expands to adjacent flammable tiles (30% chance per turn)
- **Intensity**: Small fire (1 damage) or Large fire (2 damage)
- **Fuel Dependency**: Requires flammable material (wood, vegetation)

**Gameplay Effects**:

| Effect Type | Small Fire | Large Fire |
|-------------|-----------|-----------|
| **HP Damage** | 1 per turn | 2 per turn |
| **Morale Damage** | -1 per turn | -2 per turn |
| **Movement Cost** | +2 AP | +3 AP |
| **Sight Cost** | +2 (smoke) | +3 (smoke) |
| **Cover Destruction** | Burns wooden cover | Burns wooden cover faster |

**Generation Sources**:
- **Incendiary Weapons**: Molotov cocktails, flamethrowers
- **Explosions**: 20% chance per explosive near flammable material
- **Environmental**: Pre-existing fires on map (burning buildings)

**Fire Spread Mechanics**:
```
Each Turn:
For each adjacent tile to fire:
  If tile is flammable (wood, vegetation):
    Roll 30% chance → ignite tile
  If tile has unit:
    Apply damage to unit
  If tile has water:
    Extinguish fire immediately
```

**Tactical Use**:
- **Area Denial**: Block enemy advance routes
- **Flush Out**: Force enemies from cover
- **Destruction**: Burn wooden structures
- **Panic**: Morale damage to enemies

---

### Gas (Toxic Clouds)

**Properties**:
- **Duration**: 5-12 turns (disperses slowly)
- **Spread**: Minimal (stays in place, slight drift)
- **Visibility**: Partially visible (tinted cloud effect)

**Gameplay Effects**:

| Gas Type | HP Damage | Morale Effect | Sanity Effect | Special |
|----------|-----------|---------------|---------------|---------|
| **Poison Gas** | 2 per turn | -1 per turn | 0 | Ignores armor |
| **Nerve Gas** | 1 per turn | -2 per turn | -1 per turn | Reduces accuracy -20% |
| **Acid Gas** | 3 per turn | -1 per turn | 0 | Damages equipment |
| **Stun Gas** | 0 | -3 per turn | 0 | Stun effect after 3 turns |

**Generation Sources**:
- **Gas Grenades**: Intentional deployment
- **Alien Weapons**: Certain alien units deploy gas
- **Environmental**: Ruptured chemical storage

**Tactical Use**:
- **Bypass Armor**: Poison gas ignores armor values
- **Demoralize**: Nerve gas reduces enemy effectiveness
- **Clear Buildings**: Force units to evacuate interior spaces

---

### Electrical Hazards

**Properties**:
- **Duration**: Permanent (until power source destroyed) or temporary (3-5 turns)
- **Conductive**: Spreads through metal surfaces and water

**Gameplay Effects**:
- **Damage**: 2-4 HP per turn in contact
- **Stun**: High chance of stun effect (50%)
- **Equipment Damage**: May damage electronic equipment

**Generation Sources**:
- **Destroyed Electronics**: Damaged power systems
- **Environmental**: Exposed wiring, power stations
- **Weapons**: Electrical weapons, EMP devices

---

### Radiation

**Properties**:
- **Duration**: Very long (20-50 turns) or permanent
- **Invisible**: No visual indicator (requires detection equipment)

**Gameplay Effects**:
- **Gradual Damage**: 1 HP per turn
- **Sanity Damage**: -1 per 3 turns
- **Long-term**: Continued damage after mission (requires medical treatment)

**Generation Sources**:
- **Alien Technology**: Elerium cores, power sources
- **Environmental**: Nuclear facilities, weapon detonations

---

## Weather System

**Source Reference**: Battlescape.md §Weather Systems

Weather conditions affect entire battlefield uniformly. Weather is optional and scales difficulty dynamically.

### Weather Types

| Weather | Sight Modifier | Accuracy Modifier | Movement Modifier | Special Effects |
|---------|----------------|-------------------|-------------------|-----------------|
| **Clear** | +0 | +0% | +0 AP | Baseline conditions |
| **Rain** | +1 per tile | -5% | +1 AP | Extinguishes fire, creates mud |
| **Heavy Rain** | +2 per tile | -10% | +1 AP | Strong fire suppression |
| **Snow** | +2 per tile | -10% | +2 AP | Slippery terrain, cold damage |
| **Blizzard** | +3 per tile | -15% | +3 AP | Severe visibility loss, morale -1 |
| **Sandstorm** | +2 per tile | -5% | +2 AP | Equipment damage, accuracy loss |
| **Heavy Fog** | +3 per tile | -5% | +1 AP | Near-total visibility loss |
| **Thunderstorm** | +1 per tile | -10% | +1 AP | Lightning strikes (random damage) |

---

### Weather Details

#### Rain

**Effects**:
- **Visibility**: +1 sight cost per tile
- **Accuracy**: -5% (wet conditions)
- **Movement**: +1 AP (slippery ground)
- **Fire Suppression**: 50% chance per turn to extinguish fires
- **Terrain**: Dirt becomes mud (+1 additional movement cost)

**Duration**: Variable (5-20 turns typical)

**Tactical Impact**:
- Reduces effectiveness of incendiary weapons
- Makes stealth easier (noise masking)
- Reduces sight range significantly at night

---

#### Snow

**Effects**:
- **Visibility**: +2 sight cost per tile
- **Accuracy**: -10% (cold, wind)
- **Movement**: +2 AP (deep snow)
- **Cold Damage**: -1 HP per 5 turns exposure (unprotected units)
- **Terrain**: Leaves snow trails (footprints visible for 3 turns)

**Duration**: Persistent (entire mission)

**Tactical Impact**:
- Tracks reveal unit movement
- Cold damage penalizes extended missions
- White camouflage effective

---

#### Blizzard (Extreme Snow)

**Effects**:
- **Visibility**: +3 sight cost per tile
- **Accuracy**: -15% (severe conditions)
- **Movement**: +3 AP (snow drifts)
- **Cold Damage**: -2 HP per 5 turns
- **Morale**: -1 per 10 turns
- **Sanity**: -1 per 10 turns (psychological stress)

**Duration**: Variable (10-30 turns)

**Tactical Impact**:
- Nearly impossible to see beyond 4-5 hexes
- Forces close-range combat
- High attrition environment

---

#### Sandstorm

**Effects**:
- **Visibility**: +2 sight cost per tile
- **Accuracy**: -5% (sand in eyes)
- **Movement**: +2 AP (wind resistance)
- **Equipment Damage**: 5% chance per turn to jam weapon
- **Directional**: Wind direction affects movement (favorable/unfavorable)

**Duration**: Variable (8-25 turns)

**Tactical Impact**:
- Weapon reliability concerns
- Directional advantage (move with wind easier)
- Sand accumulation (reduces visibility over time)

---

#### Heavy Fog

**Effects**:
- **Visibility**: +3 sight cost per tile
- **Accuracy**: -5% (obscured targets)
- **Movement**: +1 AP (disorientation)
- **Audio**: Sound travels further (hearing range +2 tiles)

**Duration**: Persistent or gradual dissipation (20-40 turns)

**Tactical Impact**:
- Extreme visibility reduction
- Stealth operations highly effective
- Long-range weapons nearly useless
- Close-range combat favored

---

#### Thunderstorm

**Effects**:
- **Visibility**: +1 sight cost per tile (dark clouds)
- **Accuracy**: -10% (wind, rain)
- **Movement**: +1 AP (wet ground)
- **Lightning Strikes**: 2% chance per turn per unit in open terrain → 10 HP damage
- **Electrical Hazards**: Metal objects more dangerous

**Duration**: Variable (10-20 turns)

**Tactical Impact**:
- Random damage risk
- Indoor positions safer
- Metal armor disadvantage

---

## Day vs Night Conditions

**Source Reference**: Battlescape.md §Day vs. Night Missions

### Day Missions

**Characteristics**:
- **Sight Range**: Standard (8-12 hexes per unit)
- **Visibility**: Full color, clear visuals
- **Morale**: Baseline
- **Sanity**: No penalty

**Common Mission Types**:
- UFO crashes (daytime interceptions)
- Colony defense
- Facility raids
- Base defense (if attacked during day)

---

### Night Missions

**Characteristics**:
- **Sight Range**: Severely reduced (3-6 hexes per unit)
- **Visibility**: Blue screen tint, dark environment
- **Morale**: Baseline
- **Sanity**: -1 penalty (fear of darkness)

**Equipment Modifiers**:
- **Flashlight**: +2 hex sight range (narrow cone)
- **Night Vision Goggles**: +5 hex sight range (normal vision)
- **Flare**: Illuminates 5-hex radius for 10 turns
- **Glow Stick**: Illuminates 2-hex radius for 20 turns

**Enemy Advantages**:
- Some aliens have natural night vision
- Stealth units more effective
- Ambush probability increased

**Common Mission Types**:
- Terror missions (night raids)
- Infiltration operations
- Alien abductions
- Black market contracts

---

### Lighting System

**Light Sources**:

| Source | Radius | Duration | Portable | Special |
|--------|--------|----------|----------|---------|
| **Flashlight** | 5 hexes (cone) | Permanent | Yes | Directional |
| **Flare** | 5 hexes (radius) | 10 turns | Throwable | Reveals position |
| **Glow Stick** | 2 hexes (radius) | 20 turns | Droppable | Tactical marker |
| **Fire** | 3 hexes (radius) | Variable | No | Hazardous |
| **Explosion** | 10 hexes (flash) | 1 turn | No | Temporary blind |

**Lighting Tactics**:
- **Flare Illumination**: Reveal enemies in darkness
- **Flashlight Coordination**: Team members cover different angles
- **Light Denial**: Destroy enemy light sources
- **Tactical Darkness**: Turn off lights to hide

---

### Time Determination

**Mission Time Selection**:
- **Province-Based**: Most missions inherit day/night from Geoscape province time
- **Forced Night**: Underground locations, interior facilities
- **Mission Type**: Terror missions always at night, base defense matches base time

**Time Progression**:
- Missions do not transition between day/night (static)
- Turn duration: 30 seconds per turn
- Average mission length: 15-30 turns = 7.5-15 minutes game time

---

## Destructible Terrain

### Destruction Mechanics

**Source Reference**: Battlescape.md §Terrain Destruction (mentioned but not fully specified)

**Destructible Elements**:
- Wooden walls, doors, windows
- Furniture and objects
- Light cover (sandbags, barricades)
- Vehicles and machinery

**Indestructible Elements**:
- Stone walls (permanent structures)
- Map boundaries
- Mission-critical objects (unless objective is destruction)

---

### Damage Types vs. Materials

| Weapon Type | Wood | Stone | Metal | Glass | Concrete |
|-------------|------|-------|-------|-------|----------|
| **Bullets** | 20% | 5% | 15% | 80% | 10% |
| **Explosives** | 80% | 40% | 60% | 100% | 50% |
| **Fire** | 100% | 0% | 0% | 0% | 0% |
| **Melee** | 30% | 10% | 20% | 100% | 5% |
| **Energy** | 40% | 30% | 50% | 100% | 40% |

---

### Destruction Effects

**When Terrain Destroyed**:
1. **Structure Removal**: Terrain tile becomes rubble or empty floor
2. **Line of Sight**: Blocked LOS becomes clear
3. **Cover Loss**: Units lose cover bonuses
4. **Debris Creation**: May create difficult terrain (rubble)
5. **Splash Damage**: Adjacent units may take collateral damage

**Rubble Properties**:
- **Movement Cost**: 2 AP
- **Cover**: 20-30%
- **Sight Cost**: +1
- **Permanent**: Remains for mission duration

---

### Tactical Destruction

**Use Cases**:
- **Create Sightlines**: Destroy walls to gain line of fire
- **Deny Cover**: Destroy enemy cover with explosives
- **Create Paths**: Blast through walls instead of using doors
- **Collapse Buildings**: Destroy support structures (advanced)
- **Clear Fields of Fire**: Remove obstacles

**Limitations**:
- **Ammunition**: Destruction requires significant firepower
- **Collateral Damage**: May damage friendly units or objectives
- **Noise**: Explosions alert enemies
- **Time**: Takes multiple turns to destroy sturdy objects

---

## Special Environments

### Underground Environments

**Characteristics**:
- **Lighting**: Forced night conditions
- **Weather**: No weather effects (sheltered)
- **Map Design**: Linear, claustrophobic corridors
- **Audio**: Echo effects amplify sound
- **Visibility**: Limited by tunnel geometry

**Common Locations**:
- Alien bases
- Sewer systems
- Underground bunkers
- Cave networks

**Tactical Considerations**:
- Chokepoints critical
- Flanking difficult
- Explosives highly effective (confined space)
- Retreat limited

---

### Facility Interiors

**Characteristics**:
- **Mixed Lighting**: Some areas lit, others dark
- **Neutral Units**: Civilians, scientists, workers
- **Destructible**: Furniture, equipment, walls (except structural)
- **Hazards**: Electrical, chemical, fire hazards common

**Common Locations**:
- Research facilities
- Manufacturing plants
- Military installations
- Civilian buildings

**Tactical Considerations**:
- Civilian protection required
- Environmental hazards abundant
- Multi-level structures possible
- Close-quarters combat

---

### Outdoor Wilderness

**Characteristics**:
- **Full Weather**: All weather types possible
- **Natural Cover**: Trees, rocks, hills
- **Wildlife**: Neutral animals may be present
- **Visibility**: Variable by biome

**Common Locations**:
- UFO crash sites
- Forest missions
- Desert operations
- Mountain terrain

**Tactical Considerations**:
- Long sightlines possible
- Natural concealment
- Weather significant factor
- Flank opportunities

---

### Urban Environments

**Characteristics**:
- **Dense Buildings**: Many structures, limited sightlines
- **Civilians**: High civilian presence
- **Verticality**: Multi-story buildings (future)
- **Destructible**: Many destructible objects

**Common Locations**:
- Terror missions
- Colony defense
- City battles

**Tactical Considerations**:
- Building-to-building combat
- Civilian casualties risk
- Cover abundant
- Flanking opportunities through alleys

---

## Biome System

### Biome Types

**Source Reference**: Battlescape.md §Map Generation (Step 1: Biome & Terrain Selection)

Biomes determine terrain type distribution and environmental conditions:

| Biome | Terrain Mix | Weather Types | Common Hazards | Visibility |
|-------|-------------|---------------|----------------|------------|
| **Forest** | 60% trees, 30% grass, 10% paths | Rain, fog | Dense vegetation | Medium |
| **Desert** | 80% sand, 15% rock, 5% oasis | Sandstorm, heat | Heat, sand | High |
| **Urban** | 70% concrete, 20% buildings, 10% parks | Rain, fog | Civilians, vehicles | Low |
| **Arctic** | 90% snow, 10% ice | Snow, blizzard | Cold, ice | Medium |
| **Swamp** | 50% water, 40% mud, 10% vegetation | Rain, fog | Poison gas (natural) | Low |
| **Mountain** | 60% rock, 30% grass, 10% snow | Snow, wind | Falls, cold | High |
| **Ocean** | 90% water, 10% islands | Storms, fog | Water, waves | Very Low |

---

### Biome-Specific Mechanics

#### Forest Biome

**Terrain Features**:
- Dense tree coverage (40-60% of tiles)
- Underbrush (difficult terrain)
- Clearings (open areas)

**Tactical Characteristics**:
- High concealment
- Limited sightlines (3-6 hexes typical)
- Flammable (fire spreads easily)
- Ambush-favorable

---

#### Desert Biome

**Terrain Features**:
- Open sand dunes
- Rock formations
- Minimal cover

**Tactical Characteristics**:
- Long sightlines (10+ hexes)
- Minimal cover
- Sandstorms common
- Heat effects (extended missions)

---

#### Urban Biome

**Terrain Features**:
- Buildings (mixed sizes)
- Streets and alleys
- Vehicles (cover/hazards)
- Infrastructure (power lines, pipes)

**Tactical Characteristics**:
- Complex geometry
- Verticality (future)
- Civilians present
- Close-quarters favored

---

#### Arctic Biome

**Terrain Features**:
- Snow-covered ground
- Ice patches (slippery)
- Rock outcroppings

**Tactical Characteristics**:
- Extreme cold
- Visibility variable (blizzards)
- Tracks visible
- Morale/sanity challenges

---

#### Swamp Biome

**Terrain Features**:
- Shallow water (50% of tiles)
- Mud (difficult terrain)
- Vegetation (partial cover)

**Tactical Characteristics**:
- Slow movement
- Natural hazards (gas pockets)
- Poor visibility (fog common)
- Sanity penalties

---

## Integration with Other Systems

### Battlescape Integration

**Map Generation**:
- Biome selection determines available terrain types
- Weather system modifies tactical options
- Day/night affects mission difficulty

**Combat Mechanics**:
- Environmental hazards deal damage
- Terrain modifies accuracy and movement
- Destructible terrain changes battlefield dynamically

---

### Geoscape Integration

**Province Terrain**:
- Province biome determines mission environment
- Time of day inherited from Geoscape
- Weather patterns follow Geoscape climate

**Strategic Planning**:
- Players can predict mission environment
- Equipment loadout adjusts for expected conditions
- Night missions require special preparation

---

### Assets Integration

**Art Assets**:
- Terrain sprites by biome
- Environmental effect animations (fire, smoke, rain)
- Weather overlay effects

**Tileset System**:
- Autotiles for seamless terrain transitions
- Random variants prevent repetition
- Animated tiles for water, fire, grass

---

### Economy Integration

**Salvage**:
- Destroyed terrain may yield scrap materials
- Environmental damage affects salvage quality
- Fire destroys valuable equipment

---

## Related Content

**For detailed information, see**:
- **Battlescape.md** - Combat mechanics, map generation, environmental effects in combat
- **Assets.md** - Terrain sprites, environmental art, tileset system
- **Geoscape.md** - Province biomes, time of day, weather patterns
- **Missions.md** - Mission types and environmental contexts
- **Items.md** - Environmental equipment (flashlights, night vision, gas masks)

---

## Implementation Notes

**Priority Systems**:
1. Core terrain types (floor, wall, cover)
2. Environmental hazards (smoke, fire)
3. Weather system (rain, snow, fog)
4. Day/night lighting
5. Destructible terrain
6. Advanced hazards (gas, radiation)

**Balance Considerations**:
- Environment should create tactical options, not frustration
- Weather should be optional for accessibility
- Destructible terrain should not break missions
- Hazards should be telegraphed clearly

**Testing Focus**:
- Environment impact on difficulty
- Hazard spread mechanics
- Destructible terrain edge cases
- Weather balance vs. player frustration

**Performance Optimization**:
- Environmental effects should not lag game
- Fire/smoke spread optimized
- Destruction calculations efficient
- Weather overlay lightweight

---

## Examples

- Scenario: Heavy fog mission where players must rely on flares; validate visibility modifiers and UI indicators.
- Scenario: Forest biome fire spreads; test fire spread rate and cover destruction to ensure tactical fairness.

---

## Balance Parameters

| Parameter | Default | Range | Notes |
|---|---:|---|---|
| Fire spread chance | 30% | 10-50% | Per-adjacent-turn ignition chance |
| Smoke duration | 5 turns | 2-12 turns | Controls concealment windows |
| Blizzard visibility penalty | +3 sight cost | +1 to +4 | Scales difficulty in arctic missions |

---

## Difficulty Scaling

- Easy: Reduced hazard damage, slower spread, and milder weather effects.
- Normal: Standard values as specified above.
- Hard: Increased hazard damage and spread; weather durations extended.

---

## Testing Scenarios

- [ ] Weather Effects: Verify weather modifiers (movement, accuracy, visibility) apply correctly.
- [ ] Hazard Spread: Test deterministic fire/smoke/gas spread in scripted maps.
- [ ] Destruction Edge Cases: Validate destructible walls and rubble interactions.

---

## Related Features

- Battlescape.md — combat interactions and map generation
- Assets.md — environmental art assets and tilesets
- Geoscape.md — biome prevalence and strategic effects

---

## Implementation Notes

- Use cellular automata with capped iteration per-turn for fire/smoke to avoid performance spikes. Telemetry hooks for per-turn hazard counts to identify hotspots.
- Ensure hazard visuals are decoupled from simulation frequency (visual smoothing) to preserve performance.

---

## Review Checklist

- [ ] Terrain types and movement costs defined
- [ ] Hazard mechanics specified and telegraphed
- [ ] Weather modifiers validated against combat balance
- [ ] Destructible terrain behaviour tested
- [ ] Performance budget respected for environmental systems
