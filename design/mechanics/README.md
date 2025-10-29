# Game Mechanics Documentation

> **Status**: Index Document  
> **Last Updated**: 2025-10-28  
> **Purpose**: Central index for all game mechanics design documents

---

## Quick Navigation

**Looking for specific mechanics?** Jump directly to:

| Topic | File | Quick Link |
|-------|------|------------|
| **Coordinate System** | HexSystem.md | Universal hex coordinates for all layers |
| **Pilot Mechanics** | Units.md §Unified Pilot Specification | ⚠️ **Canonical source** - how pilots work |
| **Mission Types** | Missions.md | All mission types, objectives, rewards |
| **Terrain & Weather** | Environment.md | Environmental effects, hazards, biomes |
| **Diplomatic Relations** | Relations.md | Relationship system mechanics |
| **Research Tree** | Economy.md §Research Tree | Research progression and unlocks |
| **Salvage System** | Economy.md §Salvage System | How loot is processed |
| **Transfer System** | Economy.md §Transfer System | Inter-base logistics |

---

## Overview

This folder contains detailed design specifications for all game systems and mechanics. These documents define how each system works, what parameters control behavior, balance values, and the relationships between systems.

**Total Files**: 30 documents (27 original + 3 new comprehensive files)  
**Content Status**: 100% preserved from original documents + new additions

---

## Core System Documents

### Technical Specifications
- **HexSystem.md** ⭐ - Universal coordinate system (READ FIRST)
- **Pilots.md** - Pilot specialization details (see Units.md for canonical mechanics)
- **Relations.md** - Diplomatic relationship system

### Game Layer Systems
- **Geoscape.md** - Strategic layer, world map (90×45 hex grid), campaign progression
- **Basescape.md** - Base construction, facility management, upgrades
- **Battlescape.md** - Tactical combat mechanics, turn resolution

### Core Gameplay Systems
- **Units.md** - Unit classes, stats, progression, **pilot mechanics** (includes unified pilot spec)
- **Crafts.md** - Spacecraft types, capabilities, specifications
- **Items.md** - Equipment, weapons, armor, consumables
- **Economy.md** - Financial systems, resources, research, manufacturing, salvage, transfers
- **Missions.md** 🆕 - Mission types, generation, objectives, difficulty scaling
- **Environment.md** 🆕 - Terrain types, weather, environmental hazards, biomes

### AI & Intelligence Systems
- **AI.md** - AI decision-making, behavior systems, strategic/tactical AI
- **Analytics.md** - Data collection, telemetry, balance analysis

### Strategic Systems
- **Politics.md** - Political systems, diplomacy, faction relations
- **Countries.md** - Country mechanics, relations, funding
- **Finance.md** - Financial mechanics, budgeting
- **Interception.md** - UFO interception, air combat
- **BlackMarket.md** - Underground economy, custom missions, illicit content

### Supporting Systems
- **Gui.md** - User interface design, interaction patterns
- **Assets.md** - Asset management, resource handling, tilesets
- **Lore.md** - Story content, world-building
- **3D.md** - Alternative first-person view mechanics
- **MoraleBraverySanity.md** - Psychological system mechanics

### Reference Documents
- **Overview.md** - High-level project overview
- **Glossary.md** - Game terminology, concepts
- **Future.md** - Potential features, design ideas
- **Integration.md** 🆕 - System integration patterns, data flow

---

## Document Structure

All design documents follow a standard structure:

```markdown
# [System Name]

> **Status**: [Document Type]  
> **Last Updated**: YYYY-MM-DD  
> **Related Systems**: [Related files]

## Table of Contents
[Sections...]

---

## Overview
[System description]

## [Main Sections]
[Content]

---

## Related Content
[Links to related files]

---

## Implementation Notes
[Technical considerations]
```

---

## Reading Order

**New to the project?** Read in this order:

1. **Overview.md** - Understand the project vision and architecture
2. **HexSystem.md** - Learn the coordinate system (used everywhere)
3. **Geoscape.md** - Strategic layer concepts
4. **Basescape.md** - Operational management
5. **Battlescape.md** - Tactical combat
6. **Units.md** - Unit classes, stats, and **pilot mechanics** (includes unified spec)
7. **Items.md** - Equipment and weapons
8. **Missions.md** - Mission types and objectives
9. **Environment.md** - Terrain and environmental effects
10. Other systems as needed

**For Specific Topics**:
- **Pilots**: Units.md §Unified Pilot Specification (canonical) or Pilots.md (details)
- **Missions**: Missions.md (comprehensive mission system)
- **Terrain**: Environment.md (all environmental mechanics)
- **Economy**: Economy.md (includes research, manufacturing, salvage, transfers)

---

## Status Legend

- **Design Document** - Core game system specification
- **Technical Specification** - Detailed technical reference
- **Reference Document** - Supporting information
- **Index Document** - Navigation/organization
- **Brainstorming Document** - Future ideas

---

## File Organization Strategy

**Core Layer** (8 files): Main gameplay systems  
**Specialized Layer** (14 files): Specific features and mechanics  
**Reference Layer** (8 files): Supporting documentation

**Content Preservation**: All original 27 files preserved + 3 new comprehensive files = 30 total

**Zero Deletion Policy**: No content removed, only additions and clarifications

---

## Cross-Reference Index

**Frequently Asked Questions**:

- **"How do pilots work?"** → Units.md §Unified Pilot Specification
- **"What mission types exist?"** → Missions.md §Mission Types
- **"How does weather affect combat?"** → Environment.md §Weather System
- **"What's the research tree?"** → Economy.md §Research Tree
- **"How do I process salvage?"** → Economy.md §Salvage System
- **"How do base transfers work?"** → Economy.md §Transfer System
- **"What coordinates does the game use?"** → HexSystem.md
- **"How does diplomatic relations work?"** → Relations.md or Countries.md §Relations
- **"What are all the terrain types?"** → Environment.md §Terrain System

---

## Recent Updates (2025-10-28)

**Phase 1 Complete**: Created 2 new comprehensive files
- ✅ Missions.md - Consolidated mission information from AI.md, Geoscape.md, Countries.md
- ✅ Environment.md - Consolidated terrain/weather from Battlescape.md, Assets.md

**Phase 2 Complete**: Enhanced existing files
- ✅ Units.md - Added "Unified Pilot Specification" section (canonical pilot mechanics)
- ✅ Pilots.md - Added redirect note to unified specification
- ✅ Battlescape.md - Added "Related Content" section

**Phase 3 In Progress**: Navigation improvements
- ✅ README.md updated with better navigation and file references
- 🔄 Adding "Related Content" sections to remaining files
- 🔄 Fixing cross-reference links

---

## Documentation Philosophy

**Redundancy is a Feature**: Multiple files covering related topics provide different perspectives. This is intentional.

**Canonical Sources Marked**: When contradictions exist, canonical sources are marked with ⚠️ symbol.

**Content Preservation**: Zero deletion policy - all original content retained, new content added.

**Cross-Linking**: Files reference each other extensively for comprehensive understanding.

---

## Contributing

When adding or modifying documentation:

1. Follow the standard document structure
2. Add cross-references to related files
3. Mark canonical sources when resolving contradictions
4. Update this README.md index
5. Add "Related Content" section to end of document
6. Include "Implementation Notes" for technical considerations

---
- **AI.md** - AI decision-making (hex pathfinding), behavior systems

### Strategic Systems
- **Politics.md** - Political systems, diplomacy, faction relations
- **Countries.md** - Country mechanics, relations, funding
- **Finance.md** - Financial mechanics, budgeting
- **Interception.md** - UFO interception, air combat

### Supporting Systems
- **Gui.md** - User interface design, interaction patterns
- **Assets.md** - Asset management, resource handling
- **Analytics.md** - Data collection, telemetry systems
- **Lore.md** - Story content, world-building
- **3D.md** - 3D rendering, graphics systems

### Reference Documents
- **Overview.md** - High-level project overview
- **Glossary.md** - Game terminology, concepts
- **Integration.md** - System integration patterns
- **Future.md** - Potential features, design ideas

---

## Document Structure

All design documents follow a standard structure:

```markdown
# [System Name]

> **Status**: [Document Type]  
> **Last Updated**: YYYY-MM-DD  
> **Related Systems**: [Related files]

## Table of Contents
[Sections...]

---

## Overview
[System description]

## [Main Sections]
[Content]
```

---

## Reading Order

**New to the project?** Read in this order:

1. **Overview.md** - Understand the project
2. **hex_vertical_axial_system.md** - Learn the coordinate system
3. **Geoscape.md** - Strategic layer concepts
4. **Basescape.md** - Operational management
5. **Battlescape.md** - Tactical combat
6. **Units.md** & **Items.md** - Core gameplay elements
7. Other systems as needed

---

## Status Legend

- **Design Document** - Core game system specification
- **Technical Specification** - Detailed technical reference
- **Reference Document** - Supporting information
- **Index Document** - Navigation/organization
- **Brainstorming Document** - Future ideas

---
- **Overview.md** - Overview of all mechanics

## Coordinate System

**ALL game layers use vertical axial hex coordinates:**
- **Format:** `{q, r}` (axial coordinates)
- **Directions:** E, SE, SW, W, NW, NE (6 directions)
- **Core Module:** `engine/battlescape/battle_ecs/hex_math.lua`
- **Usage:** Battlescape (combat), Geoscape (world), Basescape (facilities)

## Features

- **Complete System Specifications**: Every game system documented
- **Hex-Based Design**: All spatial calculations use hex math
- **Detailed Mechanics**: How systems work step-by-step
- **Balance Parameters**: Numbers that control game balance
- **Configuration Format**: TOML structure for each system
- **Integration Points**: How systems interact (all use same hex system)
- **Examples**: Usage examples and sample data
- **Rationale**: Why certain design decisions were made

## Integrations with Other Systems

### API Documentation
- Mechanics define what API files document
- Detailed specifications in `api/` formalize these mechanics
- TOML configurations implement these designs

### Architecture
- Architecture in `architecture/` organizes these systems
- Design patterns support mechanic implementations
- Integration flows connect these systems

### Engine Implementation
- Engine in `engine/` implements these specifications
- Code organization mirrors mechanic structure
- Balance parameters stored in configs match these values

### Testing & Validation
- Test cases verify mechanic behavior
- Mock data follows mechanic specifications
- Balance tests ensure parameters work as designed

### Lore & Content
- Mechanics support narrative progression
- Story context provided in lore documents
- Content created using mechanic specifications

## How to Use These Documents

### For Understanding the Game
1. Start with **Overview.md** for high-level understanding
2. Read specific system documents for details
3. Refer to **Glossary.md** for terminology
4. Check **Integration.md** for system interactions

### For Implementation
1. Review detailed mechanic specification
2. Check API documentation for formal interface
3. Create test cases to verify behavior
4. Implement feature following specification
5. Update as needed based on testing

### For Balance & Content Creation
1. Review balance parameters in relevant document
2. Understand mechanic interactions
3. Create content following specifications
4. Test for balance issues
5. Update documentation with changes

## See Also

- [Design Glossary](../GLOSSARY.md) - Game terminology
- [Gap Analysis](../gaps/README.md) - Missing implementations
- [API Documentation](../../api/README.md) - Formal system interfaces
- [Architecture](../../architecture/README.md) - Technical design
- [Engine Implementation](../../engine/README.md) - Code implementation
