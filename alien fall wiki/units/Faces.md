# Faces

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Portrait Assets](#portrait-assets)
  - [Catalogue System](#catalogue-system)
  - [Assignment Rules](#assignment-rules)
  - [Presentation](#presentation)
  - [Asset Referencing](#asset-referencing)
  - [Localization and Variants](#localization-and-variants)
  - [Design Constraints](#design-constraints)
- [Examples](#examples)
  - [Asset ID Structure](#asset-id-structure)
  - [Catalogue Configuration](#catalogue-configuration)
  - [Deterministic Selection](#deterministic-selection)
  - [Tooling Integration](#tooling-integration)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Faces provide cosmetic portrait assignments for units in Alien Fall, giving visual identity without affecting gameplay mechanics. The system uses seeded, data-driven selection to ensure reproducible assignments for testing, storytelling, and save consistency.

Portraits are pre-authored images organized in catalogues that support different races, cultures, and visual themes. The system maintains provenance tracking to allow exact reconstruction of roster appearances from saves and telemetry data.

## Mechanics

### Portrait Assets

Portraits use simple, efficient image assets.

Asset Format:
- Single Images: Pre-authored complete portrait images
- No Compositing: No runtime layering of facial elements
- Standard Resolution: Consistent dimensions for UI display
- Optimized Format: Compressed images for memory efficiency

Asset Organization:
- File Structure: Organized by race, gender, and skin tone
- Naming Convention: Systematic naming for easy identification
- Batch Processing: Efficient loading and caching
- Fallback System: Default portraits for missing assets

### Catalogue System

Portraits are organized in configurable catalogues.

Human Catalogue:
- Gender Options: 2 categories (male, female) - configurable
- Skin Tones: 4 palette variations - configurable
- Faces Per Combination: 8 distinct images per gender/skin combination
- Total Human Portraits: 2 × 4 × 8 = 64 (fully configurable)

Race-Specific Catalogues:
- Alien Races: Smaller sets tailored to species characteristics
- Robots/Cyborgs: Mechanical or hybrid appearance options
- Special Variants: Unique portraits for special characters
- Configurable Counts: Different sizes per race as needed

### Assignment Rules

Portrait selection follows deterministic rules.

Assignment Timing:
- Unit Creation: Portrait assigned during recruitment or generation
- One Per Unit: Each unit receives exactly one portrait
- Cosmetic Only: No gameplay effects unless explicitly configured
- Permanent Assignment: Portrait remains with unit throughout career

Selection Method:
- Seeded Hashing: Hash(seed, unitId) determines portrait index
- Deterministic Results: Same inputs always produce same portrait
- Reproducible: Save files can recreate exact roster appearance
- Testing Support: Predictable assignments for QA and design

### Presentation

Portraits appear throughout the game's UI systems.

Display Locations:
- Roster Screens: Unit selection and management interfaces
- Barracks View: Personnel management and assignment
- Dossier System: Individual unit information displays
- Mission HUD: Tactical display during combat operations

UI Integration:
- Consistent Scaling: Portraits adapt to different UI contexts
- Quality Preservation: Maintain image quality across sizes
- Loading Optimization: Efficient display in scrolling lists
- Accessibility: Alternative representations when needed

### Asset Referencing

Portraits use structured identification and referencing.

ID System:
- Structured Naming: face.race.gender.skin.index format
- Example: face.human.male.skin3.05
- Parseable: Components easily extracted for filtering
- Modding Friendly: Clear structure for custom content

Data Integration:
- YAML Catalogues: Portrait definitions in configuration files
- Metadata Storage: Additional properties per portrait
- Version Tracking: Catalogue versions for compatibility
- Tool Integration: Editor support for portrait management

### Localization and Variants

Support for different visual themes and cultural representations.

Cultural Variants:
- Regional Sets: Different appearances for different world regions
- Campaign Specific: Unique portraits for special story content
- Pack Overrides: Mod-provided portrait collections
- Priority System: Base → campaign → mod override hierarchy

Implementation:
- File Organization: Separate directories for different variants
- Bulk Replacement: Easy swapping of entire portrait sets
- Translation Support: Cultural adaptation of visual content
- Version Compatibility: Tracking of portrait set versions

### Design Constraints

Portraits remain purely cosmetic by design.

Gameplay Neutrality:
- No Stat Links: Portraits don't affect unit capabilities
- Explicit Only: Gameplay effects only if explicitly declared in data
- Balance Preservation: No hidden advantages or disadvantages
- Fairness: All portraits equally viable for competitive play

Technical Requirements:
- Asset Pipeline: Consistent production and integration process
- Provenance Logging: Complete tracking of portrait assignments
- Replay Fidelity: Exact reconstruction from save data
- Performance: Efficient loading and display systems

## Examples

### Asset ID Structure

Systematic naming convention for portrait identification:

- Basic Format: face.[race].[gender].[skin].[index]
- Human Male: face.human.male.skin1.01 through face.human.male.skin4.08
- Human Female: face.human.female.skin1.01 through face.human.female.skin4.08
- Alien Example: face.sectoid.neutral.skin1.01 through face.sectoid.neutral.skin2.04
- Robot Example: face.robot.neutral.metal.01 through face.robot.neutral.metal.06

### Catalogue Configuration

YAML-based portrait catalogue definition:

```yaml
catalogue:
  version: "1.0"
  human:
    genders: [male, female]
    skin_tones: [skin1, skin2, skin3, skin4]
    faces_per_combination: 8
    total_portraits: 64
  sectoid:
    genders: [neutral]
    skin_tones: [skin1, skin2]
    faces_per_combination: 4
    total_portraits: 8
  robot:
    genders: [neutral]
    skin_tones: [metal, plastic]
    faces_per_combination: 3
    total_portraits: 6
```

### Deterministic Selection

Seeded portrait assignment for reproducible results:

- Hash Function: portraitIndex = Hash(missionSeed, unitId, "portrait")
- Modulo Operation: portraitIndex = hashResult % catalogueSize
- Consistent Results: Same seed + unitId always yields same portrait
- Testing Benefit: QA can verify exact portrait assignments
- Save Compatibility: Portraits preserved across save/load cycles

### Tooling Integration

Hooks and APIs for development and modding support:

- Catalogue Query: portrait_catalog_query() returns available portraits
- Assignment Hook: on_portrait_assign triggered during unit creation
- Preview Tool: Designers can visualize seeded assignments
- Mod Support: Custom portrait packs with metadata integration
- Debug Display: UI shows portrait IDs and provenance for troubleshooting

## Related Wiki Pages

- [Units.md](../units/Units.md) - Unit portrait assignment and display
- [Races.md](../units/Races.md) - Race-specific portrait catalogues
- [Classes.md](../units/Classes.md) - Class-based portrait selection
- [Ranks.md](../units/Ranks.md) - Rank insignia and portrait overlays
- [SaveSystem.md](../technical/SaveSystem.md) - Portrait persistence and save data
- [Modding.md](../technical/Modding.md) - Custom portrait pack creation
- [BattleTileset.md](../battlescape/BattleTileset.md) - Asset management integration
- [TilesetLoader.md](../technical/TilesetLoader.md) - Portrait asset loading systems
- [Geoscape.md](../geoscape/Geoscape.md) - Roster and personnel display
- [Basescape.md](../basescape/Basescape.md) - Personnel management and portraits

## References to Existing Games and Mechanics

- **X-COM Series**: Unit portrait system for squad identification
- **Fire Emblem Series**: Character portrait art and expressions
- **Advance Wars**: CO portrait system with personality display
- **Final Fantasy Tactics**: Unit portrait display in tactical battles
- **Tactics Ogre**: Character portrait system for story integration
- **Disgaea Series**: Chibi-style character portraits and customization
- **Persona Series**: Character portrait art and social features
- **Mass Effect Series**: Character customization and portrait options
- **Dragon Age Series**: Character portrait selection and display
- **Fallout Series**: Character portrait system for companions and NPCs

