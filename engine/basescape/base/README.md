# Basescape Base System

## Goal / Purpose
The Base System manages the physical and operational structure of player bases. It handles base construction, facility placement, layout management, and base state persistence.

## Content
- **Base layout and grid** - 2D grid-based base structure
- **Facility placement** - Logic for placing facilities in base grid
- **Base construction** - Building and upgrading facilities
- **Base state** - Current base configuration and status
- **Base persistence** - Save/load base state

## Features
- Grid-based base construction
- Facility placement validation
- Real-time layout updates
- Base expansion capabilities
- Visual base representation
- Base state snapshots

## Integrations with Other Folders / Systems
- **engine/basescape/facilities** - Facility definitions and behavior
- **engine/basescape/systems** - Base management systems
- **engine/basescape/logic** - Base operation logic
- **engine/basescape/data** - Base configuration data
- **engine/basescape/ui** - Base interface and visualization
- **engine/core/save_system.lua** - Base persistence
- **engine/content/crafts** - Craft storage in bases
- **mods/core/rules/facilities** - Modded facility definitions
