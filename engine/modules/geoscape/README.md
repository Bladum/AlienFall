# Geoscape

Geoscape screen implementation for strategic gameplay.

## Overview

The geoscape submodule implements the strategic world map view of XCOM Simple. It handles province management, UFO tracking, mission deployment, and global strategy gameplay. The geoscape provides the high-level view of the XCOM campaign.

## Files

### data.lua
Geoscape data management and persistence. Handles saving/loading campaign state, province data, and strategic information.

### init.lua
Geoscape module initialization. Sets up the world map, provinces, and initial campaign state.

### input.lua
Input handling for geoscape interactions. Processes mouse clicks on provinces, mission selection, and strategic commands.

### logic.lua
Strategic game logic and AI. Manages UFO movement, mission generation, time progression, and campaign events.

### render.lua
World map rendering and visualization. Draws provinces, UFOs, missions, and strategic overlays.

## Usage

The geoscape module coordinates strategic gameplay:

```lua
local Geoscape = require("modules.geoscape")

function Geoscape:enter()
    self:init()  -- Load world data
end

function Geoscape:update(dt)
    self:logic(dt)  -- Update UFO positions, time
end

function Geoscape:draw()
    self:render()  -- Draw world map
end
```

## Architecture

- **Data-Driven**: Province and mission data loaded from configuration files
- **Event-Based**: Campaign events and UFO activity follow scripted patterns
- **Real-Time**: Continuous time progression with pause capability
- **Interactive**: Click-to-deploy missions and strategic decision making

## Game Features

- **Province Network**: Connected territories with strategic value
- **UFO Tracking**: Real-time alien activity monitoring
- **Mission Deployment**: Send interceptors and ground teams
- **Resource Management**: Funding, research, and manufacturing
- **Time Progression**: Days advance with events and opportunities

## Dependencies

- **World Data**: Province and country configuration files
- **UI Framework**: Strategic interface elements
- **Time System**: Campaign calendar and event scheduling
- **Asset System**: Map textures and strategic icons