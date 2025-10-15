# AlienFall Numbers Reference

**Quick lookup for all key game values and parameters**

---

## Action Economy

### Action Points (AP)
| Context | AP per Turn/Round | Notes |
|---------|-------------------|-------|
| Tactical Units | 4 | Soldiers and aliens in battlescape |
| Operational Craft | 4 | Aircraft during interception |
| No Banking | - | Unused AP doesn't carry over |

### Action Costs (Tactical)
| Action | AP Cost | Notes |
|--------|---------|-------|
| Move (1 tile) | 1 | Base cost, terrain modifies |
| Snap Shot | 1 | Quick attack, lower accuracy |
| Aimed Shot | 2 | Standard attack |
| Burst Fire | 3 | Multiple rounds, high ammo use |
| Reload | 1-2 | Weapon-dependent |
| Grenade | 2 | Throw + detonate |
| Overwatch | 1 | Reaction fire setup |
| Item Use | 1 | Most utility items |
| Special Ability | 2-4 | Unit/ability-dependent |

### Movement Modifiers
| Terrain Type | Multiplier | AP per Tile |
|--------------|------------|-------------|
| Road/Clear | 0.5× | 0.5 (rounds to 1) |
| Grass/Normal | 1.0× | 1 |
| Rubble/Rough | 2.0× | 2 |
| Water/Swamp | 3.0× | 3 |
| Climb/Vertical | 4.0× | 4 |

---

## Time Systems

### Strategic Time (Geoscape)
| Unit | Value | Notes |
|------|-------|-------|
| Tick Duration | 5 minutes | Base time increment |
| Ticks per Hour | 12 | 60 min ÷ 5 min |
| Ticks per Day | 288 | 24 hours × 12 |
| Days per Month | 30 | Simplified calendar |
| Months per Year | 12 | Standard year |
| Days per Year | 360 | 30 × 12 |
| Ticks per Year | 103,680 | 360 × 288 |
| Speed Multipliers | 1×, 5×, 30× | Player-controlled |

### Combat Time Scales
| Layer | Time per Turn/Round | Abstraction |
|-------|---------------------|-------------|
| Tactical | ~6 seconds | Battlescape turn |
| Operational | ~30 seconds | Interception round |
| Strategic | 5 minutes | Geoscape tick |

---

## Combat Mechanics

### Hit Chance
| Factor | Base Range | Modifiers |
|--------|------------|-----------|
| Base Accuracy | 50-95% | Weapon + Unit Stats |
| Point Blank (0-5 tiles) | +20% | Very close |
| Close (6-10 tiles) | +10% | Within effective range |
| Medium (11-20 tiles) | 0% | Standard range |
| Long (21-30 tiles) | -20% | Difficult shot |
| Extreme (31+ tiles) | -40% | Very difficult |
| Cover (Half) | -20% | Target behind cover |
| Cover (Full) | -40% | Target well-protected |
| Aimed Shot | +20% | Extra AP spent |
| Snap Shot | -10% | Quick shot penalty |

### Damage & Armor
| Mechanic | Value | Notes |
|----------|-------|-------|
| Damage Calculation | Base × Multipliers | Weapon-dependent |
| Armor Reduction | 1:1 | Each armor point reduces damage by 1 |
| Minimum Damage | 0 | Cannot go negative |
| Critical Chance | 10% | Base probability |
| Critical Multiplier | 1.5× | Damage bonus on crit |
| Overkill | Excess ignored | Max = unit HP |

### Morale
| State | Range | Effects |
|-------|-------|---------|
| High Morale | 80-100 | No penalties |
| Normal | 50-79 | Standard performance |
| Shaken | 30-49 | -10% accuracy, panic checks |
| Panicked | 0-29 | -30% accuracy, random actions |
| Morale Loss (Ally Death) | -10 | Nearby units affected |
| Morale Loss (Take Damage) | -5 | Per significant hit |
| Morale Gain (Enemy Kill) | +5 | Confidence boost |

---

## Economy & Resources

### Starting Conditions
| Resource | Amount | Notes |
|----------|--------|-------|
| Starting Credits | 1,000,000 | Initial capital |
| Starting Base | 1 | Predefined location |
| Starting Units | 8-10 | Basic soldiers |
| Starting Equipment | Basic weapons/armor | Standard issue |

### Monthly Funding
| Source | Amount | Conditions |
|--------|--------|------------|
| Country Funding | 500K-2M | Performance-based |
| Mission Rewards | 10K-100K | Mission type/difficulty |
| Item Sales | Variable | Manufactured goods |
| Monthly Expenses | -200K-1M | Salaries + maintenance |

### Salaries (per month)
| Personnel Type | Salary | Notes |
|----------------|--------|-------|
| Scientist | 5,000 | Research capacity |
| Engineer | 4,000 | Manufacturing capacity |
| Soldier (Rookie) | 2,000 | Basic combat unit |
| Soldier (Veteran) | 3,000 | Experienced unit |
| Soldier (Elite) | 5,000 | Top-tier unit |
| Pilot | 3,000 | Craft operations |

### Research Costs
| Tier | RP Cost | Duration (10 Scientists) | Notes |
|------|---------|--------------------------|-------|
| Early Tech | 100-300 | 2-3 weeks | Basic equipment upgrades |
| Mid Tech | 500-1,000 | 4-6 weeks | Advanced weapons, armor |
| Late Tech | 2,000-5,000 | 8-12 weeks | Alien tech, psionics |
| Breakthrough | 10,000+ | 20+ weeks | Game-changing tech |

### Manufacturing Costs
| Item Type | Man-Hours | Duration (10 Engineers) | Material Cost |
|-----------|-----------|------------------------|---------------|
| Ammo | 10-20 | 1-2 days | 50-100 credits |
| Basic Weapon | 80-150 | 1-2 weeks | 500-2,000 credits |
| Advanced Weapon | 200-500 | 3-6 weeks | 5,000-20,000 credits |
| Armor | 150-300 | 2-4 weeks | 2,000-10,000 credits |
| Equipment | 50-200 | 1-3 weeks | 1,000-5,000 credits |
| Craft | 1,000-5,000 | 10-50 weeks | 50,000-500,000 credits |

---

## Base Management

### Facility Costs
| Facility Type | Construction Time | Cost | Maintenance |
|---------------|-------------------|------|-------------|
| Living Quarters | 15 days | 200,000 | 10,000/month |
| Laboratory | 20 days | 500,000 | 30,000/month |
| Workshop | 20 days | 400,000 | 25,000/month |
| Hangar | 25 days | 600,000 | 40,000/month |
| Radar Array | 15 days | 300,000 | 15,000/month |
| Power Plant | 18 days | 350,000 | 20,000/month |
| Storage | 12 days | 150,000 | 5,000/month |

### Facility Capacities
| Facility | Provides | Amount |
|----------|----------|--------|
| Living Quarters | Personnel Capacity | 50 people |
| Laboratory | Research Capacity | 10 scientists |
| Workshop | Manufacturing Capacity | 10 engineers |
| Hangar | Craft Slots | 1-2 craft |
| Storage | Item Storage | 50-100 units |
| Radar | Detection Range | 500-1,000 km |
| Power Plant | Power Generation | 100-200 units |

### Facility Sizes
| Size | Tiles | Examples |
|------|-------|----------|
| Small | 1×1 | Storage, Small Radar |
| Medium | 2×1 | Living Quarters, Lab |
| Large | 2×2 | Hangar, Large Workshop |
| Special | 3×2, etc. | Command Center, Large Hangar |

---

## Battlescape

### Map Parameters
| Parameter | Min | Max | Typical |
|-----------|-----|-----|---------|
| Map Width | 20 | 50 | 30-40 |
| Map Height | 20 | 50 | 30-40 |
| Unit Count (Player) | 4 | 12 | 6-8 |
| Unit Count (Enemy) | 4 | 20 | 8-12 |
| Mission Duration | 10 turns | 50 turns | 20-30 turns |

### Vision & Detection
| Condition | Range (Tiles) | Notes |
|-----------|---------------|-------|
| Day Vision | 15-20 | Clear weather |
| Night Vision | 5-10 | Darkness penalty |
| Smoke/Fog | 3-5 | Environmental obscurement |
| Infrared | 10-15 | Special equipment |
| Motion Tracker | 20-30 | Detection only, no LOS |

### Unit Stats (Typical Soldier)
| Stat | Rookie | Veteran | Elite |
|------|--------|---------|-------|
| Health | 40-60 | 60-80 | 80-100 |
| Accuracy | 50-60 | 70-80 | 85-95 |
| Reactions | 40-50 | 60-70 | 75-85 |
| Strength | 30-40 | 40-50 | 50-60 |
| Bravery | 40-50 | 60-70 | 80-90 |
| Speed | 40-50 | 50-60 | 60-70 |

---

## Interception

### Craft Stats
| Craft Type | Speed | Armor | Weapons | Range |
|------------|-------|-------|---------|-------|
| Interceptor | 100 | 20 | 2 slots | 1,000 km |
| Fighter | 120 | 15 | 2 slots | 800 km |
| Heavy Fighter | 80 | 40 | 3 slots | 1,200 km |
| Transport | 60 | 30 | 1 slot | 2,000 km |

### Weapons
| Weapon | Damage | Range | Ammo | Reload |
|--------|--------|-------|------|--------|
| Cannon | 10-20 | Short | 200 | 1 AP |
| Missile | 50-100 | Medium | 6 | 2 AP |
| Laser | 30-40 | Long | Unlimited | 0 AP |
| Plasma | 40-60 | Long | 50 | 1 AP |

---

## Performance Targets

### Technical Requirements
| Metric | Target | Acceptable | Notes |
|--------|--------|------------|-------|
| Frame Rate | 60 FPS | 45 FPS | Minimum performance |
| Memory Usage | <500 MB | <650 MB | RAM budget |
| Load Time (Mission) | <30 sec | <45 sec | Battlescape startup |
| Save File Size | <10 MB | <25 MB | Per save slot |
| Max Map Size | 50×50 | 60×60 | Performance tested |

---

## Balancing Philosophy

### Early Game (Months 1-3)
- Enemies: Sectoids, basic weapons
- Player: Conventional weapons, limited research
- Focus: Learning mechanics, surviving missions
- Difficulty: Low-moderate

### Mid Game (Months 4-8)
- Enemies: Tougher aliens, better weapons
- Player: Laser weapons, basic alien tech
- Focus: Base expansion, tech race
- Difficulty: Moderate-high

### Late Game (Months 9+)
- Enemies: Elite aliens, advanced weapons, psionics
- Player: Plasma weapons, powered armor, psionic defense
- Focus: Endgame technologies, final missions
- Difficulty: High-extreme

---

**Last Updated**: October 7, 2025  
**For**: Quick reference and balancing  
**Status**: Living document (values subject to tuning)

**Navigation**: [← Quick Start](QUICK_START_GUIDE.md) | [Main README](README.md) | [Systems Architecture →](01_Foundation/Systems_Architecture.md)
