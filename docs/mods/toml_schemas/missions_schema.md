# Missions TOML Schema

Complete schema documentation for mission definitions.

## File Locations

```
mods/core/rules/missions/tactical_missions.toml
mods/core/rules/missions/strategic_missions.toml
```

## Overview

Missions define objectives available in tactical (battlescape) and strategic (geoscape) gameplay.

## Schema Definition

### Tactical Missions

```toml
[[mission]]
id = "terror_attack"
name = "Terror Attack"
description = "Defend a city from alien invasion"
type = "tactical"
difficulty = 3
squad_size = 6
time_limit = 20
map_size = "large"
enemy_types = ["sectoid_soldier", "floater"]
enemy_count = 8
reward_experience = 200
reward_credits = 500
```

### Strategic Missions

```toml
[[mission]]
id = "council_battle"
name = "Council Battle"
description = "Defend council nation from invasion"
type = "strategic"
reward_experience = 100
reward_credits = 500
council_approval = 25
```

## Complete Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique mission ID |
| `name` | string | Mission name |
| `description` | string | Mission description |
| `type` | string | `"tactical"` or `"strategic"` |
| `difficulty` | number | 1-5 difficulty scale |
| `squad_size` | number | Players units (tactical) |
| `time_limit` | number | Turns available (tactical) |
| `map_size` | string | Map size: small/medium/large/extra_large |
| `enemy_types` | array | Enemy unit types |
| `enemy_count` | number | Number of enemies |
| `civilian_count` | number | Civilians to protect (optional) |
| `reward_experience` | number | XP awarded on success |
| `reward_credits` | number | Credits awarded |
| `council_approval` | number | Council approval change |

---

**Schema Version:** 1.0
