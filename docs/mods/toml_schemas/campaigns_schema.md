# Campaigns TOML Schema

Complete schema documentation for campaign and phase definitions.

## File Locations

```
mods/core/campaigns/campaign_timeline.toml
mods/core/campaigns/phase0_shadow_war.toml
mods/core/campaigns/phase1_sky_war.toml
mods/core/campaigns/phase2_deep_war.toml
mods/core/campaigns/phase3_dimensional_war.toml
```

## Overview

Campaigns define the structure, phases, and timeline of AlienFall's 8-year narrative arc.

## Campaign Timeline File Format

The master timeline (`campaign_timeline.toml`) defines milestones:

```toml
[campaign_metadata]
total_campaign_length = 8
total_milestones = 18
start_year = 1996
end_year = 2004

[[milestone]]
id = "start_private_firm"
phase = 0
name = "Private Organization Started"
year = 1996
month = 1
description = "Private paranormal investigation firm founded..."
```

## Phase File Format

Each phase has its own file (`phase0_shadow_war.toml`):

```toml
[phase]
id = "phase0_shadow_war"
# ... fields ...
```

## Phase Schema Definition

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Unique phase identifier | `"phase0_shadow_war"` |
| `name` | string | Phase display name | `"Shadow War"` |
| `description` | string | Phase description | `"Covert operations..."` |
| `start_year` | number | Starting year | `1996` |
| `end_year` | number | Ending year | `1999` |
| `phase_number` | number | Phase order (0-3) | `0` |

### Timeline Section

```toml
[timeline]
milestones = [
    "start_private_firm",
    "first_anomalies",
    "supernatural_outbreaks",
    # ... more milestones
]
```

### Factions Section

```toml
[factions]
active = [
    "faction_cult",
    "faction_blackops",
    "faction_supernatural"
]
```

### Missions Section

```toml
[missions]
types = [
    "investigation",
    "containment",
    "suppression"
]
```

### Enemy Types Section

```toml
[enemy_types]
common = ["cult_member", "supernatural_entity"]
rare = ["early_scout"]
boss = []
```

### Technology Section

```toml
[technology]
available = [
    "investigation_techniques",
    "occult_knowledge",
    "basic_surveillance"
]
```

### Gameplay Section

```toml
[gameplay]
tech_level = "conventional"
difficulty_scaling = 0.5
alien_visibility = "minimal"
```

## Complete Examples

### Phase 0: Shadow War
```toml
[phase]
id = "phase0_shadow_war"
name = "Shadow War"
description = "Human factions, covert operations, and supernatural outbreaks"
start_year = 1996
end_year = 1999
phase_number = 0
status = "investigation"

[timeline]
milestones = [
    "start_private_firm",
    "first_anomalies",
    "supernatural_outbreaks",
    "blackops_evidence",
    "alien_signatures",
    "build_network",
    "intelligence_spike",
    "formalize_xcom"
]

[factions]
active = [
    "faction_cult",
    "faction_blackops",
    "faction_mib"
]

[missions]
types = ["investigation", "containment", "suppression"]

[enemy_types]
common = ["cult_member"]
rare = ["supernatural_entity"]

[technology]
available = ["investigation_techniques", "occult_knowledge"]

[gameplay]
tech_level = "conventional"
difficulty_scaling = 0.5
alien_visibility = "minimal"
```

### Phase 1: Sky War
```toml
[phase]
id = "phase1_sky_war"
name = "Sky War"
description = "Direct alien invasion through UFO assaults"
start_year = 1999
end_year = 2001
phase_number = 1
status = "invasion"

[factions]
active = ["faction_sectoids", "faction_mutons", "faction_ethereals"]

[missions]
types = ["terror_attack", "crash_recovery", "facility_raid"]

[enemy_types]
common = ["sectoid_soldier", "floater"]
rare = ["ethereal"]
boss = ["ethereal"]

[gameplay]
tech_level = "plasma"
difficulty_scaling = 1.0
alien_visibility = "high"
```

## Milestone Format

Each milestone in the timeline:

```toml
[[milestone]]
id = "start_private_firm"
phase = 0
name = "Private Organization Started"
year = 1996
month = 1
description = "Private paranormal investigation firm founded..."
```

### Milestone Fields

| Field | Type | Description | Valid Range |
|-------|------|-------------|------------|
| `id` | string | Unique identifier | Any string |
| `phase` | number | Which campaign phase | 0, 1, 2, 3 |
| `name` | string | Display name | Short text |
| `year` | number | Year | 1996-2004 |
| `month` | number | Month | 1-12 |
| `description` | string | Event description | Longer text |

## Field Validation Rules

### Phase Number
- `0` - Shadow War (1996-1999)
- `1` - Sky War (1999-2001)
- `2` - Deep War (2001-2002)
- `3` - Dimensional War (2003-2004)

### Status Field
- `"investigation"` - Investigation phase
- `"invasion"` - Active invasion
- `"expansion"` - Expanding threat
- `"endgame"` - Final battle

### Tech Levels
- `"conventional"` - Ballistic weapons
- `"plasma"` - Alien plasma tech
- `"advanced_plasma"` - Advanced plasma
- `"laser"` - Laser technology
- `"dimensional"` - Dimensional tech

### Difficulty Scaling
- `0.5` - Easy (Phase 0)
- `1.0` - Normal (Phase 1)
- `1.2` - Hard (Phase 2)
- `1.5` - Nightmare (Phase 3)

### Alien Visibility
- `"minimal"` - Rare encounters
- `"high"` - Frequent encounters
- `"overwhelming"` - Constant threat

## Usage in Code

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get campaign phase
local phase = DataLoader.campaigns.get("phase1_sky_war")
print(phase.name)                   -- "Sky War"
print(phase.start_year)             -- 1999

-- Get timeline
local timeline = DataLoader.campaigns.getTimeline()
for _, milestone in ipairs(timeline) do
    print(milestone.name)
end
```

---

**Schema Version:** 1.0  
**Last Updated:** October 16, 2025
