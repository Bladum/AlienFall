# Mod Content Creation Prompts

Comprehensive set of structured prompts for creating and updating game content in TOML format. Each prompt provides clear instructions, input specifications, validation criteria, and testing procedures.

## Usage

Each prompt file follows a consistent structure:
- **Prefix**: Short prefix for grouping related prompts
- **Task Type**: Classification of work needed
- **Description**: What the prompt handles
- **Inputs**: Required and optional parameters
- **Scope**: Affected files and systems
- **Validation**: Quality checks
- **TOML Template**: Code structure reference
- **Outputs**: Expected deliverables
- **Process**: Step-by-step workflow
- **Testing Checklist**: Verification steps
- **References**: API and documentation links

## Game Content Prompts

### Core Game Systems

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_item** | item_ | Weapons, armor, equipment, resources | `mods/core/economy/` |
| **add_unit** | unit_ | Soldiers, aliens, NPCs | `mods/core/factions/` |
| **add_craft** | craft_ | Aircraft and vehicles | `mods/core/geoscape/` |
| **add_mission** | mission_ | Tactical missions and operations | `mods/core/campaign/` |
| **add_faction** | faction_ | Alien species and organizations | `mods/core/factions/` |
| **add_campaign** | campaign_ | Campaign phases and progression | `mods/core/campaign/` |

### Base Management & Infrastructure

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_facility** | facility_ | Base buildings and structures | `mods/core/basescape/facilities/` |
| **add_service** | service_ | Base services and operations | `mods/core/basescape/services/` |
| **add_base_script** | base_ | Base defense and integration | `mods/core/basescape/` |

### Geoscape & World

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_world** | world_ | Global strategic map | `mods/core/geoscape/world.toml` |
| **add_country** | country_ | Nations and governments | `mods/core/geoscape/provinces.toml` |
| **add_region** | region_ | Geoscape regions and territories | `mods/core/geoscape/provinces.toml` |

### Battlescape & Tactical

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_terrain** | terrain_ | Tile types and terrain properties | `mods/core/geoscape/biomes.toml` |
| **add_biome** | biome_ | Environmental zones and themes | `mods/core/geoscape/biomes.toml` |
| **add_map_block** | mapblock_ | Individual tactical maps | `mods/core/mapblocks/` |
| **add_map_script** | mapscript_ | Procedural map generation | `mods/core/mapscripts/` |
| **add_tileset** | tileset_ | Visual tile collections | `mods/core/tilesets/` |

### Combat & AI

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_ufo_script** | ufo_ | UFO behavior and appearance | `mods/core/battlescape/ai/` |

### Economy & Progression

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_research** | research_ | Technology trees | `mods/core/technology/` |
| **add_manufacturing** | manufacturing_ | Production recipes | `mods/core/economy/manufacturing.toml` |
| **add_purchase** | purchase_ | Marketplace items | `mods/core/economy/purchase_entries.toml` |
| **add_supplier** | supplier_ | Vendors and suppliers | `mods/core/economy/suppliers.toml` |

### Narrative & NPCs

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_event** | event_ | Game events and consequences | `mods/core/narrative/events.toml` |
| **add_quest** | quest_ | Objectives and story arcs | `mods/core/narrative/quests.toml` |
| **add_advisor** | advisor_ | NPC advisors and characters | `mods/core/narrative/advisors.toml` |

### Organization & Meta

| Prompt | ID | Purpose | Affected Files |
|--------|----|---------|----|
| **add_organization** | org_ | Player organization structure | `mods/core/organizations.toml` |

---

## Quick Reference by System

### Combat & Characters
- `add_unit.prompt.md` - Create soldier/alien units
- `add_faction.prompt.md` - Define alien species
- `add_advisor.prompt.md` - Create NPC advisors

### Economy & Resources
- `add_item.prompt.md` - Create equipment and resources
- `add_manufacturing.prompt.md` - Create production recipes
- `add_purchase.prompt.md` - Add marketplace items
- `add_supplier.prompt.md` - Create vendors
- `add_research.prompt.md` - Define technology

### Maps & Visuals
- `add_map_block.prompt.md` - Create tactical maps
- `add_map_script.prompt.md` - Create procedural generation
- `add_tileset.prompt.md` - Define tile visuals
- `add_terrain.prompt.md` - Create tile types
- `add_biome.prompt.md` - Create environmental zones

### Strategy & Progression
- `add_mission.prompt.md` - Create tactical missions
- `add_campaign.prompt.md` - Design campaign structure
- `add_quest.prompt.md` - Create quests and objectives
- `add_event.prompt.md` - Define game events

### World & Politics
- `add_world.prompt.md` - Define strategic map
- `add_country.prompt.md` - Create nations
- `add_region.prompt.md` - Create territories
- `add_organization.prompt.md` - Define player organization

### Infrastructure & Operations
- `add_facility.prompt.md` - Create base buildings
- `add_service.prompt.md` - Create base services
- `add_base_script.prompt.md` - Define base systems
- `add_craft.prompt.md` - Create vehicles/aircraft

### AI & Behavior
- `add_ufo_script.prompt.md` - Create UFO behavior

---

## Common Patterns

### TOML Organization
All prompts follow consistent TOML structure:
```toml
[section]
id = "unique_identifier"
name = "Display Name"
description = "What this does"
type = "category"
tags = ["tag1", "tag2"]

[subsection]
property1 = "value"
property2 = 123
```

### ID Naming Convention
All content uses prefixed IDs:
- `item_plasma_rifle`
- `unit_soldier_basic`
- `craft_interceptor_alpha`
- `mission_first_contact`
- `facility_laboratory_001`

### File Structure
- Each entity type gets unique prefix (item_, unit_, craft_, etc.)
- Related content grouped in same folder
- Separate files for major categories
- Linked references between systems

### Validation Requirements
Every prompt includes validation checks for:
- TOML syntax correctness
- ID uniqueness
- Cross-reference validity
- Balance appropriateness
- No circular dependencies
- Logical consistency

---

## Workflow

### Creating New Content

1. **Select Appropriate Prompt**: Match content type to prompt
2. **Gather Requirements**: Define inputs using prompt specification
3. **Use TOML Template**: Start with provided template
4. **Validate**: Check against validation criteria
5. **Test**: Run through testing checklist
6. **Document**: Update relevant README.md files

### Modifying Existing Content

1. **Select Prompt**: Identify what's being changed
2. **Review Current Content**: Understand existing structure
3. **Make Updates**: Use TOML template as reference
4. **Re-validate**: Ensure consistency
5. **Test Changes**: Verify behavior in-game
6. **Update Documentation**: Reflect changes

### Common Modifications

- **Balance Changes**: Use TOML template to adjust values
- **Add Content**: Create new entry using template
- **Remove Content**: Delete entry and verify no broken references
- **Rename**: Change ID and update all references
- **Reorganize**: Move between files/folders

---

## API References

### Documentation Structure
- `wiki/API.md` - Complete API reference
- `docs/content/` - Content guides
- `docs/balance/GAME_NUMBERS.md` - Balance parameters
- `docs/[SYSTEM]/` - System-specific documentation

### Key Systems
- Economy: `docs/economy/`
- Battlescape: `docs/battlescape/`
- Basescape: `docs/basescape/`
- Geoscape: `docs/geoscape/`
- Narrative: `docs/narrative/`

### Example Files
- Items: `mods/core/economy/items.toml`
- Factions: `mods/core/factions/faction_sectoids.toml`
- Mapblocks: `mods/core/mapblocks/farm_field_01.toml`
- Facilities: `mods/core/basescape/facilities/`

---

## Best Practices

### Content Creation
1. Use provided TOML templates
2. Follow naming conventions
3. Balance with similar content
4. Cross-reference documentation
5. Test thoroughly before committing

### Validation
1. Verify TOML syntax
2. Check ID uniqueness
3. Validate all references
4. Test in-game
5. Check console for errors

### Documentation
1. Update README.md files
2. Add examples if creating new category
3. Link to related content
4. Include balance notes
5. Document any special rules

### Organization
1. Keep related content together
2. Use consistent naming
3. Maintain file structure
4. Comment complex sections
5. Version track changes

---

## Troubleshooting

### Validation Failures
- **ID Conflict**: Search all files for duplicate ID
- **Reference Missing**: Verify referenced item exists
- **TOML Syntax Error**: Check quotes, brackets, indentation
- **Type Mismatch**: Ensure property value matches expected type
- **Circular Reference**: Trace dependency chain

### Common Issues
- Missing TOML sections (check template)
- Incorrect file paths (verify folder structure)
- Broken cross-references (search project)
- Balance problems (compare similar content)
- Rendering issues (check tileset/sprite definitions)

### Testing Problems
- Content doesn't load: Check console for errors
- Values not applying: Verify property names
- References not resolving: Confirm ID correctness
- Visual issues: Check tileset and sprite paths
- Behavior incorrect: Review AI/behavior configuration

---

## Files Included

**Game Content Prompts (24 total):**
- add_item.prompt.md
- add_unit.prompt.md
- add_craft.prompt.md
- add_mission.prompt.md
- add_faction.prompt.md
- add_campaign.prompt.md
- add_facility.prompt.md
- add_service.prompt.md
- add_world.prompt.md
- add_country.prompt.md
- add_region.prompt.md
- add_terrain.prompt.md
- add_biome.prompt.md
- add_event.prompt.md
- add_research.prompt.md
- add_manufacturing.prompt.md
- add_purchase.prompt.md
- add_supplier.prompt.md
- add_quest.prompt.md
- add_map_block.prompt.md
- add_map_script.prompt.md
- add_ufo_script.prompt.md
- add_base_script.prompt.md
- add_tileset.prompt.md
- add_advisor.prompt.md
- add_organization.prompt.md

**This Index:**
- README.md (you are here)

---

## Version

Created: October 16, 2025

Total Prompts: 24
Covered Systems: 11 major game systems
Game Engine: Love2D 12.0+
Language: TOML for data, Lua for game code

---

## Support

For questions about specific prompts:
1. Check the prompt's "References" section
2. Review examples in `mods/core/`
3. Read system-specific documentation in `docs/`
4. Check `wiki/API.md` for complete reference
