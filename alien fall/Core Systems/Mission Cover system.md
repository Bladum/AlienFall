# Mission Cover System

## Overview
The Mission Cover System manages the visibility of missions on the geoscape, using a cover stat to determine if events are hidden or detectable by the player. Missions start covered and can be revealed through radar scans or natural decay, creating dynamic discovery mechanics. This system integrates with the Geo Turn System and base radar capabilities for strategic scouting.

## Mechanics
- **Cover Stat**: Positive values keep missions hidden; zero or negative makes them visible.
- **Decay**: Cover changes daily, potentially increasing (stealth) or decreasing (exposure).
- **Detection**: Bases and crafts with radar scan provinces, reducing cover by radar power.
- **Mission Types**: Stealth missions have high cover or rapid decay; obvious missions start at zero cover.
- **Interaction**: Revealed missions allow player engagement, such as interception or investigation.

## Examples

Cover Progression Table:

| Mission Type | Initial Cover | Daily Change | Detection Threshold |
|--------------|---------------|--------------|---------------------|
| UFO Landing | 10 | -1 | 0 |
| Stealth Infiltration | 20 | +2 | 0 |
| Public Sighting | 0 | 0 | N/A |

Scenario: A base with radar power 5 scans a province, reducing a UFO mission's cover from 8 to 3. Next day, it drops to 2, still hidden.

## References
- **XCOM Series**: Mission detection via radar and satellite coverage.
- **Civilization VI**: Hidden units and exploration mechanics.
- **Silent Service**: Submarine detection and stealth systems.