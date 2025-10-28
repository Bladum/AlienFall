# Game Mechanics Specifications - Hex-Based Systems

## Goal / Purpose

The Mechanics folder contains detailed design specifications for all game systems and mechanics. These documents define how each system works, what parameters control behavior, balance values, and the relationships between systems.

**🎯 CRITICAL:** All spatial systems use **vertical axial hex coordinate system**. See `hex_vertical_axial_system.md` for complete specification.

## Content

System design files for each major game mechanic:

- **hex_vertical_axial_system.md** ⭐ - **Universal coordinate system (READ FIRST)**
- **Units.md** - Unit classes, abilities, progression systems
- **Battlescape.md** - Tactical combat mechanics (hex-based) and turn resolution
- **Geoscape.md** - Strategic layer, world map (90×45 hex grid), and campaign progression
- **Basescape.md** - Base construction (hex layout), facility management, and upgrades
- **Economy.md** - Financial systems, resources, and production
- **Crafts.md** - Spacecraft types, capabilities, and specifications
- **Items.md** - Equipment, weapons, armor, and consumables
- **AI_Systems.md** - AI decision-making (hex pathfinding) and behavior systems
- **Politics.md** - Political systems, diplomacy, and faction relations
- **Gui.md** - User interface design and interaction patterns
- **Finance.md** - Financial mechanics and budgeting
- **Analytics.md** - Data collection and telemetry systems
- **Assets.md** - Asset management and resource handling
- **Lore.md** - Story content and world-building
- **Integration.md** - System integration patterns
- **Interception.md** - UFO interception and air combat
- **3D.md** - 3D rendering and graphics systems
- **Glossary.md** - Game terminology and concepts
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
