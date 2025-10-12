# Geoscape

This document covers the strategic world map layer in AlienFall for global operations and resource management. It defines the universe structure, regions, countries, and time systems that govern strategic gameplay.

## Table of Contents

- [Basic Definitions](#basic-definitions)

## Basic Definitions

### Universe
The entire game world containing multiple planets and dimensional realms.
Manage travels of crafts between worlds via portals. 

### World
A single planet or dimensional plane that serves as the primary setting for operations.
World contains provinces contected to each other via paths. 

### World tile
World tile is virtual element 2D map of tiles below world image displayed in game
it is used only to calcualte paths between provinces
tile is either water or land or rought land
cost to travel is 1, 1, 3 and depends on type of craft (air, land, water) it may create different path 

### Region
Large geographical areas grouping multiple countries with shared characteristics.
Used to generate missions and calculate analytics per region
All provinces must have region

### Country
Political entities with their own governments, resources, and strategic importance.
Relation with country may improve funding 
Bad relation with country may cause it hostile to player
All score is also accumulated per country
Has economy power based on sum of its provinces

### Province
Smallest administrative divisions within countries, serving as mission locations.
Province has economy level, used to calculate economy of country 
Has biome that define terrains for battle and background for interception
May have many missions but single player base
Can be water or land

### World Time
Global time system that advances consistently across all regions and activities.
1 day = 1 turn 
6 days = 1 week
5 weeks = 1 months
3 months = 1 quater
4 quters = 1 year

### Calendar
Unified dating system tracking campaign progression through phases and years.
Manage logic triggered per day, week, month, quater
Create new campaigns per faction at start of month, and new mission for campaigns at start of week

### Time & Day
Day/night cycle affecting mission generation, UFO activity, and strategic timing.
Each world has its own rotation speed for day / night calculation
Each world tile is either day or night and this changes every turn
on earth it 80x40 world map, 1 tile = 500km and assume 20 days is full cycle = shift speed is 4 tiles per turn

### Province Paths
Transportation routes and connections between provinces for movement and logistics. Paths determine travel time, fuel consumption, and interception opportunities. Different terrain types affect path efficiency and craft speed. Strategic path management is crucial for timely UFO interception.

### Province Biome
Environmental characteristics of provinces affecting terrain, resources, and mission types.

### Portal
Location in provice that link to another province including provinces on different world. 
Allows to travel via portals for crafts and / or missions ufo. 