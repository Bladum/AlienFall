# Geoscape Terror Subsystem

**Purpose:** Manages alien terror missions, civilian casualties, panic levels, and strategic threat mechanics during the campaign.

**Layer:** Strategic (Geoscape)

**Parent:** Geoscape

## Contents

This folder contains terror system implementations:
- Terror mission definitions
- Civilian evacuation mechanics
- Panic level tracking and effects
- Terror site management
- Casualty and recovery systems

## Key Components

- **Terror Manager:** Central terror event management
- **Panic System:** Panic level tracking
- **Casualties:** Civilian impact calculation
- **Recovery:** Panic reduction over time

## Dependencies

- Depends on: `geoscape` (campaign), `missions` (terror missions)
- Used by: Campaign events, difficulty scaling

## Architecture Notes

- Terror missions increase panic levels
- High panic can trigger events and failures
- Panic decreases over time with management
- Casualties affect country relationships

## See Also

- `api/GEOSCAPE.md` - Geoscape API documentation
- `design/campaign/` - Campaign design documentation
