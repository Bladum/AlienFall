# Geoscape Data

**Status:** [PLACEHOLDER - Data structure ready, content in progress]

## Goal / Purpose
Stores configuration data for geoscape systems including world settings, region definitions, location data, and geoscape-specific game rules.

## Content
- **World configuration** - Global world settings
- **Region definitions** - Geographic region configurations
- **Location data** - City, base, and point-of-interest definitions
- **Climate data** - Biome and weather configurations
- **Faction territories** - Faction region ownership
- **Mission generation rules** - Default mission parameters

## Features
- TOML-based configuration
- World size configuration
- Region and location definitions
- Easy customization
- Mod-friendly format

## Integrations with Other Folders / Systems
- **engine/core/data_loader.lua** - Data loading
- **engine/geoscape/world** - World generation
- **engine/geoscape/geography** - Geographic systems
- **engine/geoscape/systems** - All geoscape systems
- **mods/core/geoscape** - Modded geoscape data
