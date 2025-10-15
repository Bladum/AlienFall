# Geoscape Layer

Strategic world map view where commanders manage global XCOM operations.

## Overview

The Geoscape layer provides the strategic bird's-eye view of Earth where players:
- Track UFO activity and alien missions worldwide
- Deploy interceptor crafts to engage alien threats
- Manage bases, research facilities, and funding
- Monitor diplomatic relations with funding nations
- Respond to terror sites and crash sites
- Build and maintain the worldwide sensor network

This is the primary "campaign map" layer inspired by X-COM: UFO Defense.

## Features

### World Management
- **Globe Rendering**: 3D rotating Earth or flat map view
- **Territory Control**: Track control of provinces, regions, and countries
- **Day/Night Cycle**: Real-time day progression with visual feedback
- **Zoom Levels**: Strategic (whole planet) to tactical (region detail)

### Mission Detection
- **Radar Network**: Base and craft-mounted sensors scan for threats
- **Cover System**: Missions start hidden, revealed by radar over time
- **Mission Types**: UFO landings, terror sites, alien bases, supply ships
- **Priority Alerts**: Notifications for critical threats

### Craft Operations
- **Deployment**: Send crafts from bases to mission locations
- **Interception**: Air combat with UFOs
- **Travel Time**: Realistic fuel consumption and travel duration
- **Auto-Return**: Crafts return to base when mission complete

### Relations & Diplomacy
- **Funding Nations**: Monthly funding from member countries
- **Panic Levels**: Country panic increases from alien activity
- **Defection Risk**: Countries may leave XCOM if panic too high
- **Bonuses**: Successfully defended countries provide bonuses

## Architecture

```
geoscape/
├── screens/
│   └── geoscape_screen.lua     # Main geoscape UI and state management
├── systems/
│   ├── world_map.lua            # World rendering and interaction
│   ├── detection_manager.lua   # Radar and mission detection
│   ├── relations_manager.lua   # Country relations and panic
│   └── calendar.lua             # Time progression system
├── rendering/
│   ├── globe_renderer.lua      # 3D Earth rendering
│   └── flat_map_renderer.lua   # 2D map alternative
├── logic/
│   ├── craft_movement.lua      # Craft travel calculations
│   └── territory_control.lua   # Province ownership tracking
├── ui/
│   ├── geoscape_hud.lua        # HUD elements (time, funding, etc.)
│   ├── mission_panel.lua       # Mission list and details
│   └── base_selector.lua       # Base selection UI
├── world/
│   └── geography.lua            # Province/region/country definitions
└── data/
    └── world_data.lua           # Geographic and political data
```

## Key Systems

### Detection Manager (`systems/detection_manager.lua`)

Handles radar scanning and mission discovery:

```lua
local DetectionManager = require("geoscape.systems.detection_manager")

-- Perform daily radar scans
DetectionManager:performDailyScans()

-- Get detected missions
local missions = DetectionManager:getDetectedMissions()

-- Check radar coverage at position
local power, range = DetectionManager:getRadarCoverageAt(province)
```

### Relations Manager (`systems/relations_manager.lua`)

Tracks diplomatic relationships:

```lua
local RelationsManager = require("geoscape.systems.relations_manager")

-- Get country relations (-100 to +100)
local relations = RelationsManager:getRelation("country", "USA")

-- Modify relations
RelationsManager:modifyRelation("country", "USA", -10, "Failed to stop terror mission")

-- Check if country is at risk
if RelationsManager:isAtRisk("USA") then
    -- Show warning
end
```

### World Map (`systems/world_map.lua`)

Manages world rendering and interaction:

```lua
local WorldMap = require("geoscape.systems.world_map")

WorldMap:init()
WorldMap:update(dt)
WorldMap:draw()

-- Get province at screen coordinates
local province = WorldMap:getProvinceAt(mouseX, mouseY)

-- Zoom to location
WorldMap:zoomToProvince(province)
```

## Data Flow

### Mission Generation and Detection

1. **Campaign System** spawns hidden missions weekly/monthly
2. **Mission** starts with high cover value (hidden)
3. **Detection Manager** scans daily with all radars
4. Cover decreases based on radar power in area
5. When cover reaches 0, mission becomes **detected**
6. Player sees mission on map, can deploy crafts

### Craft Deployment

1. Player selects detected mission
2. Selects available craft from base
3. Craft travels to mission location (takes time)
4. Upon arrival, triggers **Interception** or **Battlescape**

### Relations Updates

1. **Daily**: Passive panic decay
2. **Mission Success**: Relations improve, panic decreases
3. **Mission Failure**: Relations worsen, panic increases
4. **Monthly**: Countries check if panic > threshold, may defect

## Usage Examples

### Starting Geoscape

```lua
local GeoscapeScreen = require("geoscape.screens.geoscape_screen")
local StateManager = require("core.state_manager")

-- Switch to geoscape
StateManager.switch("geoscape")
```

### Deploying Craft to Mission

```lua
local mission = getMissionById("mission_001")
local craft = getAvailableCraft("SKYRANGER-1")

-- Deploy craft
craft:setDestination(mission.province)
craft:setMission(mission)
craft:launch()

print("ETA: " .. craft:getETA() .. " hours")
```

### Checking Relations

```lua
local relations = RelationsManager:getRelation("country", "GERMANY")

if relations < -50 then
    print("⚠️ GERMANY is unhappy!")
elseif relations > 50 then
    print("✓ GERMANY is pleased")
end
```

### Time Progression

```lua
local Calendar = require("geoscape.systems.calendar")

-- Advance one day
Calendar:advanceDay()

-- Check current date
print("Date: " .. Calendar:getDateString()) -- "January 15, 1999"

-- Check if Monday (mission spawn day)
if Calendar:isMonday() then
    spawnWeeklyMissions()
end
```

## Integration Points

### → Basescape
- Click on base icon to enter base management
- Base provides radar coverage for detection
- Crafts launch from bases

### → Battlescape
- Craft arrives at mission location
- Player clicks "Enter Battlescape"
- Loads tactical combat map

### → Interception
- Craft encounters UFO in flight
- Enters turn-based air combat
- Can shoot down or retreat

### → Campaign/Lore
- Campaign system spawns missions
- Faction system provides enemy types
- Mission system tracks objectives

## Testing

Tests located in `tests/geoscape/`:
- `test_detection.lua` - Radar and mission detection
- `test_relations.lua` - Country relations calculations
- `test_craft_movement.lua` - Travel time and fuel

Run with:
```bash
lovec tests/runners/run_geoscape_test.lua
```

## Debug Commands

Press `~` to open console:
```lua
-- Advance time
advanceTime(7) -- 7 days

-- Spawn mission
spawnMission("terror", "ROME")

-- Max radar
enableMaxRadar()

-- Set relations
setRelation("USA", 100)

-- List all missions
listMissions()
```

## Performance Notes

- World rendering is the most expensive operation
- Use LOD (level of detail) for distant provinces
- Limit mission scan frequency (once per day, not per frame)
- Cache radar coverage calculations

## Common Issues

**Issue**: Missions never detected  
**Solution**: Ensure bases have radar facilities built, check radar power

**Issue**: Crafts take forever to arrive  
**Solution**: Travel time realistic based on distance, use closer bases

**Issue**: Countries defecting too fast  
**Solution**: Balance panic increase/decrease rates in config

## See Also

- [Basescape Layer](../basescape/README.md) - Base management
- [Battlescape Layer](../battlescape/README.md) - Tactical combat
- [Interception Layer](../interception/README.md) - Air combat
- [Campaign System](../lore/campaign/README.md) - Mission generation
- [Relations System Guide](../../wiki/STRATEGIC_LAYER_QUICK_REFERENCE.md#relations-system)
- [API Documentation](../../wiki/API.md#geoscape)
