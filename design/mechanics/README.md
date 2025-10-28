# Game Mechanics Documentation

> **Status**: Index Document  
> **Last Updated**: 2025-10-28  
> **Purpose**: Central index for all game mechanics design documents
> **Last Updated**: 2025-10-28  
## Overview

This folder contains detailed design specifications for all game systems and mechanics. These documents define how each system works, what parameters control behavior, balance values, and the relationships between systems.

## Overview

---

## Core System Documents

### Technical Specifications
- **hex_vertical_axial_system.md** ⭐ - Universal coordinate system (READ FIRST)
- **PilotSystem_Technical.md** - Pilot mechanics specification
- **DiplomaticRelations_Technical.md** - Universal relationship system

### Game Layer Systems
- **Geoscape.md** - Strategic layer, world map (90×45 hex grid), campaign progression
- **Basescape.md** - Base construction (hex layout), facility management, upgrades
- **Battlescape.md** - Tactical combat mechanics (hex-based), turn resolution

### Core Gameplay Systems

- **Crafts.md** - Spacecraft types, capabilities, specifications
- **Items.md** - Equipment, weapons, armor, consumables
- **Economy.md** - Financial systems, resources, production
- **ai_systems.md** - AI decision-making (hex pathfinding), behavior systems

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
- **Units.md** - Unit classes, abilities, stats (including Piloting), progression systems
- **FutureOpportunities.md** - Potential features, design ideas

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
2. **HexSystem.md** - Learn the coordinate system
3. **Geoscape.md** - Strategic layer concepts
4. **Basescape.md** - Operational management
5. **Battlescape.md** - Tactical combat
6. **Units.md** & **Items.md** - Core gameplay elements
7. **Pilots.md** - How units pilot crafts (simple system)
8. Other systems as needed

---

## Status Legend

- **Design Document** - Core game system specification
- **Technical Specification** - Detailed technical reference
- **Reference Document** - Supporting information
- **Index Document** - Navigation/organization
- **Brainstorming Document** - Future ideas

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
