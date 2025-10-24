# Core Mod: Campaign Content

## Goal / Purpose

The Campaign folder contains campaign-related content and configuration, including campaign phases, progression, and campaign-specific settings.

## Content

- Campaign phase definitions
- Campaign progression data
- Campaign-specific events and triggers
- Campaign balance and difficulty settings

## Features

- **Phase Management**: Campaign organized into distinct phases
- **Progression Tracking**: How player advances through campaign
- **Event Triggers**: When campaign events occur
- **Balance Per Phase**: Different balance settings per phase
- **Pacing Control**: How quickly campaign unfolds

## Integrations with Other Systems

### Campaign Manager
- Loaded by `engine/geoscape/campaign_manager.lua`
- Drives campaign progression
- Triggers phase transitions

### Narrative System
- Campaign phases tied to story phases
- Events trigger narrative content
- Progression gates story availability

### Design Specifications
- Campaign design in `design/mechanics/`
- Phase definitions in `design/mechanics/Geoscape.md`

### API Documentation
- Campaign configuration format in `api/GEOSCAPE.md`

## See Also

- [Core Mod README](../README.md) - Core content overview
- [Campaign Timeline](../../lore/story/timeline.md) - Story timeline
- [Geoscape API](../../api/GEOSCAPE.md) - Campaign configuration
