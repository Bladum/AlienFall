# Lore & Story Content

## Goal / Purpose

The Lore folder contains all story content, world-building, narrative elements, and campaign progression for AlienFall. It includes faction descriptions, world settings, detailed campaign phases, and visual media for the game's universe.

## Content

- **story/** - Campaign narrative and story content
- **images/** - Lore-related images, artwork, and visual references

## Features

- **Campaign Phases**: Five-phase story progression from Shadow War to Final Retribution
- **Faction Details**: Comprehensive faction descriptions and histories
- **World Details**: Descriptions of planets, locations, and environments
- **Timeline**: Chronology of game events
- **Character Narratives**: NPC stories and character development
- **Visual Content**: Artwork and images for lore content
- **Lore Events**: Narrative events triggered during gameplay
- **Mission Context**: Story context for individual missions

## Integrations with Other Systems

### Campaign & Progression
- Campaign phases guide game progression
- Story events trigger at appropriate times
- Narrative affects faction relationships

### Narrative System (Engine)
- Lore content is loaded and managed by `engine/lore/`
- Story events triggered by game conditions
- Dialog and narrative managed by narrative system

### Geoscape
- Faction locations shown on geoscape
- Campaign phases affect geoscape gameplay
- Story events trigger geoscape events

### Basescape & Research
- Story context for research and upgrades
- Narrative impacts research availability
- Lore explains technology progression

### Design & Balance
- Story informs game balance and difficulty
- Narrative shapes player progression
- Lore justifies design decisions

## Folder Structure

### Story Folder
- **phase_0.md** - Phase 0: Shadow War initiation
- **phase_1.md** - Phase 1: Regional Conflict
- **phase_2.md** - Phase 2: Shadow War escalation
- **phase_3.md** - Phase 3: Abyss Moon discovery
- **phase_4.md** - Phase 4: Final Enemy appearance
- **phase_5.md** - Phase 5: Final Retribution
- **factions.md** - Detailed faction descriptions
- **worlds.md** - World and location descriptions
- **timeline.md** - Complete timeline of events
- **gap_analysis.md** - Story gaps and needed content

### Images Folder
- **00_IMAGES_INDEX.md** - Index of all lore images
- **01_FACTIONS.md** - Faction artwork and images
- **02_WORLDS_LOCATIONS.md** - Location and environment images
- **03_PHASE_0_INITIATION.md** - Phase 0 related images
- **04_PHASE_1_REGIONAL_CONFLICT.md** - Phase 1 related images
- **05_PHASE_2_SHADOW_WAR.md** - Phase 2 related images
- **06_PHASE_3_ABYSS_MOON.md** - Phase 3 related images
- **07_PHASE_4_FINAL_ENEMY.md** - Phase 4 related images
- **08_PHASE_5_FINAL_RETRIBUTION.md** - Phase 5 related images

## Campaign Phases

### Phase 0: Shadow War
Initiation and discovery of alien presence

### Phase 1: Regional Conflict
First contact and escalating regional conflicts

### Phase 2: Shadow War (Escalation)
Expanded alien operations and player response

### Phase 3: Abyss Moon
Discovery and exploration of dimensional rifts

### Phase 4: Final Enemy
True nature of alien threat revealed

### Phase 5: Final Retribution
Final confrontation and game conclusion

## See Also

- [Story Content](./story/README.md) - Narrative documentation
- [Lore Images](./images/README.md) - Visual media
- [Engine Lore System](../engine/lore/README.md) - Lore system implementation
- [Design Lore](../design/mechanics/Lore.md) - Lore design specifications
- [API Lore](../api/LORE.md) - Lore system API
