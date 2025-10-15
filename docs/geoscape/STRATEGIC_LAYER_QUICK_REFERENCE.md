# Strategic Layer Quick Reference Card

**Quick lookup for Relations, Mission Detection, and Interception systems**

---

## Relations System (TASK-026)

### Relation Values & Labels
| Range | Label | Impact |
|-------|-------|--------|
| 75-100 | Allied | Best funding/prices, ceasefire |
| 50-74 | Friendly | Good funding/prices, fewer missions |
| 25-49 | Positive | Slight bonus, weaker missions |
| -24 to 24 | Neutral | Baseline, normal missions |
| -49 to -25 | Negative | Slight penalty, stronger missions |
| -74 to -50 | Hostile | Bad funding/prices, many missions |
| -100 to -75 | War | Worst funding/prices, strong missions |

### Country Relations → Funding
- **Allied (75+):** +50% to +100% funding
- **Friendly (50-74):** +25% to +50% funding
- **Neutral:** 0% modifier
- **Hostile (-74 to -50):** -25% to -50% funding
- **War (-100 to -75):** -50% to -75% funding

### Supplier Relations → Prices
- **Allied (75+):** -30% to -50% discount + special offers
- **Friendly (50-74):** -15% to -30% discount
- **Neutral:** 0% modifier
- **Hostile (-74 to -50):** +25% to +50% markup
- **War (-100 to -75):** +50% to +100% markup + restricted items

### Faction Relations → Missions
| Relation | Missions/Week | Power Modifier |
|----------|---------------|----------------|
| Allied (75+) | 0 | N/A (cease-fire) |
| Friendly (50-74) | 1 | 0.5x (weaker) |
| Positive (25-49) | 1-2 | 0.75x |
| Neutral (-24 to 24) | 2-3 | 1.0x (normal) |
| Negative (-49 to -25) | 3-4 | 1.25x |
| Hostile (-74 to -50) | 4-5 | 1.5x |
| War (-100 to -75) | 5-7 | 2.0x (double) |

### Relation Changes
- **Mission Success:** +5 to +15 (country), -5 to -15 (faction)
- **Mission Failure:** -3 to -10 (country)
- **Purchase (per $10k):** +1 (supplier, max +5 per transaction)
- **Gift (per $5k spent):** +1 (any entity type)
- **Time Decay:** -0.05 to -0.15 per day toward neutral

---

## Mission Detection (TASK-027)

### Mission Types
| Type | Duration | Cover Regen | Altitude |
|------|----------|-------------|----------|
| Site | 14 days | 5/day | Land |
| UFO | 7 days | 3/day (air), 5/day (landed) | Air or Land |
| Base | 30 days | 10/day | Underground/Underwater |

### Cover Mechanics
- **Spawn:** 100 cover (hidden)
- **Regen:** 3-10 points per day (mission type dependent)
- **Detection:** Cover ≤ 0 → mission visible
- **Scan:** Reduces cover by (Radar Power × Effectiveness)

### Radar Systems
#### Base Radar
| Facility | Range (Provinces) | Power |
|----------|-------------------|-------|
| Small Radar | 5 | 20 |
| Large Radar | 10 | 50 |
| Hyperwave | 20 | 100 |

#### Craft Radar
| Equipment | Range (Provinces) | Power |
|-----------|-------------------|-------|
| Basic Radar | 3 | 10 |
| Advanced Radar | 7 | 25 |

### Scan Formula
```
Effectiveness = 1.0 - (Distance / MaxRange)
Cover Reduction = Radar Power × Effectiveness
```

### Campaign Schedule
- **Mission Generation:** Every Monday (Day 1 of week)
- **Turn Length:** 1 turn = 1 day
- **Scan Frequency:** Once per turn (daily)

---

## Interception Screen (TASK-028)

### Turn System
- **Turn Length:** 1 turn = 5 minutes game time
- **AP per Unit:** 4 AP per turn (all units)
- **Energy:** Regenerates 10-20 per turn

### Altitude Layers (Top to Bottom)
1. **AIR (240px high):** Flying UFOs, interceptor crafts
2. **LAND/WATER (240px high):** Landed UFOs, sites, player bases
3. **UNDERGROUND/UNDERWATER (240px high):** Alien bases

### Weapon Altitude Restrictions
| Weapon Type | From Layer | To Layer | Example |
|-------------|------------|----------|---------|
| AIR-to-AIR | Air | Air | Cannon, Missiles |
| AIR-to-LAND | Air | Land/Water | Bombs, Rockets |
| LAND-to-AIR | Land/Water | Air | AA Missiles, Lasers |
| LAND-to-LAND | Land/Water | Land/Water | Artillery |
| UNDERGROUND | Any | Underground | Special weapons |

### Example Weapons
| Weapon | Damage | AP Cost | Energy Cost | Cooldown | Type |
|--------|--------|---------|-------------|----------|------|
| Cannon | 30 | 2 | 10 | 0 | AIR-to-AIR |
| AA Missile | 80 | 3 | 25 | 2 turns | AIR-to-AIR |
| Bomb | 100 | 3 | 20 | 1 turn | AIR-to-LAND |
| Base Laser | 50 | 2 | 20 | 0 | LAND-to-AIR |
| UFO Plasma | 60 | 2 | 15 | 0 | AIR-to-AIR |

### Unit Stats (Typical)
| Unit Type | Health | Armor | Shields | AP | Energy |
|-----------|--------|-------|---------|----|----|
| Interceptor | 150 | 10 | 50 | 4 | 100 |
| Bomber | 200 | 20 | 0 | 4 | 120 |
| Player Base | 1000 | 50 | 0 | 4 | 200 |
| Scout UFO | 100 | 5 | 0 | 4 | 80 |
| Heavy UFO | 300 | 30 | 100 | 4 | 150 |
| Alien Base | 2000 | 100 | 200 | 4 | 500 |

### Win/Loss Conditions
- **Player Victory:** All enemy units destroyed → Option to proceed to Battlescape
- **Player Defeat:** All player units destroyed → Return to Geoscape (units damaged/destroyed)
- **Player Retreat:** Voluntary exit → Return to Geoscape (current damage applied)

---

## System Integration Flow

### Geoscape → Interception → Battlescape

```
1. GEOSCAPE (TASK-027)
   └─> Weekly mission generation
   └─> Radar detection reveals mission
   └─> Player clicks mission
       └─> Has crafts in province?
           ├─> YES: Offer interception
           └─> NO: Show mission details

2. INTERCEPTION (TASK-028)
   └─> Player selects crafts to deploy
   └─> Turn-based combat begins
   └─> Player vs Mission units
       ├─> Player Victory
       │   └─> Choice: Battlescape or Return
       ├─> Player Defeat
       │   └─> Return to Geoscape (loss)
       └─> Player Retreat
           └─> Return to Geoscape (partial damage)

3. BATTLESCAPE
   └─> Ground assault
   └─> Mission completion/failure
   └─> Update relations (TASK-026)
   └─> Return to Geoscape
```

### Relations Impact Chain

```
MISSION RESULT
    │
    ├─> Country Relations (TASK-026)
    │   └─> Funding Changes
    │       └─> More/Less Resources
    │
    ├─> Supplier Relations (TASK-026)
    │   └─> Price Changes
    │       └─> Equipment Affordability
    │
    └─> Faction Relations (TASK-026)
        └─> Mission Generation (TASK-027)
            └─> More/Fewer Missions
            └─> Stronger/Weaker Missions
                └─> Interception Difficulty (TASK-028)
```

---

## Performance Targets

| System | Target | Critical |
|--------|--------|----------|
| Relations update (per turn) | <1ms | <5ms |
| Radar scan (all bases/crafts) | <5ms | <10ms |
| Interception turn processing | <2ms | <5ms |
| Mission generation (weekly) | <10ms | <20ms |

---

## Testing Checklist

### Relations System
- [ ] Relations stay within -100 to +100 bounds
- [ ] Funding changes with country relations
- [ ] Prices change with supplier relations
- [ ] Missions change with faction relations
- [ ] Relations decay over time
- [ ] Save/load preserves relations

### Mission Detection
- [ ] Missions spawn weekly
- [ ] Cover regenerates daily
- [ ] Radar reduces cover correctly
- [ ] Missions appear when cover reaches 0
- [ ] Missions expire after duration
- [ ] Multiple scanners combine coverage

### Interception Screen
- [ ] Units appear in correct layers
- [ ] AP/Energy systems work
- [ ] Weapons respect altitude restrictions
- [ ] Cooldowns function
- [ ] Damage calculations correct
- [ ] Win/loss conditions trigger
- [ ] Transitions smooth

---

## Common Issues & Solutions

### Relations Not Changing
- Check if RelationsManager initialized
- Verify modifyRelation() being called
- Check decay rate not canceling changes
- Enable debug logging: `RelationsManager.debugMode = true`

### Missions Not Detected
- Verify base has radar facility
- Check craft has radar equipment
- Verify range calculation correct
- Check cover value: may need multiple scans
- Enable debug: `DetectionManager.debugMode = true`

### Interception Targeting Issues
- Check altitude compatibility
- Verify weapon targetAltitude property
- Check AP/energy sufficient
- Verify cooldown not active
- Use `unit:canUseWeapon(weapon)` to debug

---

## File Locations

### Relations System (TASK-026)
```
engine/geoscape/systems/relations_manager.lua
engine/geoscape/systems/funding_manager.lua (modified)
engine/geoscape/systems/marketplace_manager.lua (modified)
engine/geoscape/systems/diplomacy_manager.lua
engine/geoscape/ui/relations_panel.lua
engine/widgets/relation_bar.lua
engine/data/relations_config.lua
```

### Mission Detection (TASK-027)
```
engine/geoscape/systems/campaign_manager.lua
engine/geoscape/systems/detection_manager.lua
engine/geoscape/systems/time_manager.lua
engine/geoscape/logic/mission.lua
engine/geoscape/ui/geoscape_view.lua (modified)
engine/data/mission_templates.lua
```

### Interception Screen (TASK-028)
```
engine/interception/systems/interception_manager.lua
engine/interception/logic/interception_unit.lua
engine/interception/ui/interception_view.lua
engine/interception/logic/weapon.lua
engine/data/interception_weapons.lua
```

---

## Balancing Guidelines

### Relations
- **Change Rate:** Major events ±10-20, minor events ±1-5
- **Decay Rate:** 0.05-0.15 per day (slower = more stable)
- **Thresholds:** Allies at 75+ should feel significant

### Mission Detection
- **Cover Values:** 80-120 range gives good variety
- **Regen Rates:** 3-10 per day (lower = easier to find)
- **Radar Power:** Base 20-100, Craft 10-25 (bases >> crafts)
- **Radar Range:** Base 5-20, Craft 3-7 provinces

### Interception
- **Weapon Damage:** 20-100 per shot
- **AP Costs:** 1-4 (most weapons 2-3)
- **Energy Costs:** 10-30 per shot
- **Cooldowns:** 0-3 turns (0 = spam, 3 = tactical)
- **Unit Health:** Crafts 100-300, Bases 500-2000, UFOs 50-500

---

**Last Updated:** October 13, 2025  
**Related Tasks:** TASK-026, TASK-027, TASK-028  
**Total Estimated Time:** 118 hours (14-17 days)
