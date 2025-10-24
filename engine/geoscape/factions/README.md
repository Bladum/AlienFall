# Geoscape Factions Subsystem

**Purpose:** Manages alien faction data, characteristics, relationships, and behavior patterns during the strategic campaign layer.

**Layer:** Strategic (Geoscape)

**Parent:** Geoscape

## Contents

This folder contains faction system implementations:
- Faction definitions and characteristics
- Alien unit compositions per faction
- Faction relationship/diplomacy systems
- Faction territory and influence tracking
- Faction-specific research trees and technology

## Key Components

- **Faction Manager:** Central faction management and queries
- **Alien Composition:** Alien unit types per faction
- **Relationships:** Diplomatic state between factions
- **Technology:** Faction-specific tech progression

## Dependencies

- Depends on: `geoscape` (campaign orchestration), `content` (data)
- Used by: Campaign logic, missions, events

## Architecture Notes

- Each faction has distinct behavior patterns
- Faction relationships affect campaign events
- Tech trees vary by faction
- Aliens spawned per faction type

## See Also

- `api/GEOSCAPE.md` - Geoscape API documentation
- `design/factions/` - Faction design documentation
