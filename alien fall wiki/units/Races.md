# Races

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Race Assignment and Inheritance](#race-assignment-and-inheritance)
  - [Separation of Concerns](#separation-of-concerns)
  - [Content Organization and Filtering](#content-organization-and-filtering)
  - [Compatibility Systems](#compatibility-systems)
  - [Recruitment Integration](#recruitment-integration)
  - [Faction Composition](#faction-composition)
  - [Data-Driven Design](#data-driven-design)
  - [UI and User Experience](#ui-and-user-experience)
- [Examples](#examples)
  - [Basic Race Assignment](#basic-race-assignment)
  - [Equipment Compatibility](#equipment-compatibility)
  - [Faction Composition](#faction-composition)
  - [Research-Gated Recruitment](#research-gated-recruitment)
  - [Multi-Race Compatibility](#multi-race-compatibility)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Races system provides categorical identifiers for units, enabling content organization, compatibility filtering, and narrative flavor without containing mechanical stats. Races serve as metadata tags that designers use to create rules and groupings, with all concrete gameplay values coming from classes, traits, or transformations. Units inherit race tags from their assigned classes, with support for multiple tags on hybrid or complex units.

Races are distinct from unit types (biological, mechanical, hybrid) and physical sizes, focusing instead on species or faction categorization. They control access to specialized equipment, transformations, and abilities while supporting deterministic compatibility checks and data-driven rule authoring. The system enables diverse faction compositions, research-gated recruitment, and comprehensive modding support.

## Mechanics
### Race Assignment and Inheritance
Units receive race tags from their assigned classes, with each class declaring one primary race and potentially multiple secondary tags for hybrids. Race assignment occurs automatically during unit creation and can change through class changes or transformations. All assignments are tracked for provenance and validation.

### Separation of Concerns
Races operate independently from unit types, classes, and sizes. Unit types drive core mechanics like healing and repair, classes provide stat profiles and abilities, and sizes affect positioning. Races provide categorical metadata for compatibility and organization without encoding performance characteristics.

### Content Organization and Filtering
Races categorize units for UI displays, spawn tables, and encounter composition. Roster interfaces include race filters, vendor inventories vary by available races, and mission generation uses race tags for balanced opposition. Research discoveries can unlock new race access.

### Compatibility Systems
Races control access to items, transformations, and abilities through tag-based requirements. Equipment may require specific races or ban others, transformations can be race-specific, and abilities may have racial prerequisites. Compatibility checks are deterministic and provide clear feedback.

### Recruitment Integration
Race availability depends on research completion, facility construction, and campaign progress. Recruitment weights control encounter frequency, with dynamic adjustment based on player advancement. Prerequisites prevent premature access to advanced races.

### Faction Composition
Factions can include multiple races with different tactical roles and technology tiers. Race distribution creates strategic variety, with some races filling specialized niches while others provide general capabilities. This supports diverse faction identities and counterplay opportunities.

### Data-Driven Design
All race definitions, compatibility rules, and recruitment parameters are stored in configuration files. New races can be added without code changes, with comprehensive modding support for rule modification and extension.

### UI and User Experience
Race information appears throughout interfaces with visual indicators, filter options, and tooltip details. Compatibility status is clearly communicated, and race-based organization improves navigation and decision-making.

## Examples
### Basic Race Assignment
Human recruits receive Human race tags, enabling standard equipment access. Sectoid units get Sectoid tags, unlocking psionic content while restricting heavy weapons. Cyborg units carry both Human and Cyborg tags for hybrid compatibility.

### Equipment Compatibility
Psi Amp requires Human or Sectoid race tags, allowing psionic-capable species access. Repair Kit requires Mechanical unit type regardless of race. Heavy armor may ban small races while allowing large ones.

### Faction Composition
Alien faction primarily fields Sectoids with Floater support units. Human faction includes only Human units across various classes. Hybrid faction mixes biological and mechanical races for combined capabilities.

### Research-Gated Recruitment
Sectoid race requires alien capture research and containment facility. Floater race needs additional aerial research. Even with recruitment opportunities, advanced races remain unavailable until prerequisites complete.

### Multi-Race Compatibility
Cybernetic units with Human and Cyborg tags access both organic medical items and mechanical repair equipment. Transformation system validates against all applicable race tags.

## Related Wiki Pages

- [Classes.md](../units/Classes.md) - Class compatibility and restrictions
- [Units.md](../units/Units.md) - Unit creation and race assignment
- [Inventory.md](../units/Inventory.md) - Equipment and item compatibility
- [Faces.md](../units/Faces.md) - Visual representation and portraits
- [Geoscape.md](../geoscape/Geoscape.md) - Faction composition and deployment
- [Research tree.md](../economy/Research%20tree.md) - Race unlock requirements
- [AI.md](../ai/AI.md) - Mission generation and enemy behavior
- [Lore.md](../lore/Lore.md) - Faction lore and background
- [Modding.md](../technical/Modding.md) - Custom race creation
- [Basescape.md](../basescape/Basescape.md) - Recruitment and training facilities

## References to Existing Games and Mechanics

- **X-COM Series**: Alien race system and faction differences
- **Fire Emblem Series**: Character race and background system
- **Final Fantasy Tactics**: Race and job combination system
- **Advance Wars**: Faction-specific unit differences
- **Tactics Ogre**: Race system with stat modifiers
- **Disgaea Series**: Race and class combination mechanics
- **Persona Series**: Character background and social systems
- **Mass Effect Series**: Species system and racial abilities
- **Dragon Age Series**: Race system with background traits
- **Fallout Series**: Race system with stat modifiers

