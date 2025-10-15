# Politics Systems

Diplomacy, relations, reputation, and faction management.

## Overview

Politics systems handle diplomatic relations between organizations, countries, and factions. Manage reputation, karma, fame, and political standing across the game world.

## Architecture

```
engine/politics/
├── relations/
│   ├── relations_manager.lua   -- Main diplomacy system
│   └── reputation_system.lua   -- Organization reputation
├── karma/
│   └── karma_system.lua        -- Action-based karma tracking
├── fame/
│   └── fame_system.lua         -- Public recognition system
└── README.md                   -- This file
```

## Core Systems

### Relations Manager
Tracks relationships between entities (countries, factions, organizations).

**Key Features:**
- Bilateral relations (-100 to +100 scale)
- Relation modifiers from events
- Alliance and hostility tracking
- Diplomatic incidents and treaties

**Usage:**
```lua
local RelationsManager = require("politics.relations.relations_manager")

-- Improve relations
RelationsManager.modifyRelation("USA", "XCOM", 10)

-- Check relation
local relation = RelationsManager.getRelation("USA", "XCOM")
if relation > 50 then
    print("USA is friendly to XCOM")
end
```

### Reputation System
Tracks organization reputation with various groups.

**Key Features:**
- Per-country reputation scores
- Global reputation average
- Reputation decay over time
- Major event bonuses/penalties

**Usage:**
```lua
local ReputationSystem = require("politics.relations.reputation_system")

-- Successful mission in Europe
ReputationSystem.addReputation("France", 15)
ReputationSystem.addReputation("Germany", 15)

-- Failed to respond to UFO
ReputationSystem.addReputation("Japan", -25)
```

### Karma System
Tracks moral/ethical choices and their consequences.

**Key Features:**
- Good/evil karma spectrum
- Action-based karma changes
- Karma affects mission rewards
- Unlocks story branches

**Usage:**
```lua
local KarmaSystem = require("politics.karma.karma_system")

-- Player executes surrendered alien
KarmaSystem.addKarma(-15, "Executed prisoner")

-- Player rescues civilians
KarmaSystem.addKarma(20, "Rescued 5 civilians")
```

### Fame System
Public recognition and notoriety.

**Key Features:**
- Fame level (0-100)
- Fame affects funding and recruitment
- Famous actions spread news
- Fame decay without activity

**Usage:**
```lua
local FameSystem = require("politics.fame.fame_system")

-- Major victory publicized
FameSystem.addFame(30, "Defeated alien battleship")

-- Check fame level
if FameSystem.getFame() > 75 then
    print("XCOM is world-renowned!")
end
```

## Integration Points

### From Geoscape
```lua
-- After mission completion
function Geoscape:onMissionComplete(mission, result)
    if result == "victory" then
        ReputationSystem.addReputation(mission.country, 10)
        FameSystem.addFame(15, "Mission success")
    else
        ReputationSystem.addReputation(mission.country, -20)
    end
end
```

### To Economy
```lua
-- Funding based on reputation
function Economy:calculateMonthlyFunding()
    local funding = 0
    for country, rep in pairs(ReputationSystem.getAllReputation()) do
        funding = funding + (rep * country.baseContribution)
    end
    return funding
end
```

### To Story Events
```lua
-- Karma affects story branches
function StorySystem:checkBranch()
    local karma = KarmaSystem.getKarma()
    
    if karma < -50 then
        return "dark_path"
    elseif karma > 50 then
        return "heroic_path"
    else
        return "neutral_path"
    end
end
```

## Diplomatic States

| Relation | Range | Effects |
|----------|-------|---------|
| **Allied** | 75-100 | Shared intel, increased funding, joint operations |
| **Friendly** | 25-74 | Normal cooperation, standard funding |
| **Neutral** | -24-24 | Minimal interaction |
| **Unfriendly** | -74--25 | Reduced funding, denied airspace |
| **Hostile** | -100--75 | Funding cut, may attack XCOM |

## See Also

- [Geoscape README](../geoscape/README.md) - Strategic layer
- [Economy Systems](../economy/README.md) - Funding and resources
- [Story System](../lore/README.md) - Narrative integration
