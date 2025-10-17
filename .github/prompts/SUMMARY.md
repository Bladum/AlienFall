# Mod Content Prompts - Summary

**Created:** October 16, 2025
**Location:** `.github/prompts/`
**Total Files:** 27 (26 prompts + 1 README)

## Quick Stats

| Category | Count | Prefixes |
|----------|-------|----------|
| **Core Systems** | 6 | item_, unit_, craft_, mission_, faction_, campaign_ |
| **Base Management** | 3 | facility_, service_, base_ |
| **World & Strategy** | 3 | world_, country_, region_ |
| **Battlescape** | 5 | terrain_, biome_, mapblock_, mapscript_, tileset_ |
| **AI & Combat** | 1 | ufo_ |
| **Economy** | 4 | research_, manufacturing_, purchase_, supplier_ |
| **Narrative** | 3 | event_, quest_, advisor_ |
| **Meta** | 1 | org_ |
| **Documentation** | 1 | README.md |
| **TOTAL** | **27** | |

## Prompt Files

### ✅ All 24 Content Creation Prompts

**Game Mechanics (6)**
- ✅ `add_item.prompt.md` - Equipment, resources, special items
- ✅ `add_unit.prompt.md` - Soldiers, aliens, NPCs  
- ✅ `add_craft.prompt.md` - Aircraft and vehicles
- ✅ `add_mission.prompt.md` - Tactical missions
- ✅ `add_faction.prompt.md` - Alien species and organizations
- ✅ `add_campaign.prompt.md` - Campaign structure and phases

**Infrastructure (3)**
- ✅ `add_facility.prompt.md` - Base buildings
- ✅ `add_service.prompt.md` - Base services and operations
- ✅ `add_base_script.prompt.md` - Base defense systems

**World Building (3)**
- ✅ `add_world.prompt.md` - Strategic map definition
- ✅ `add_country.prompt.md` - Nations and governments
- ✅ `add_region.prompt.md` - Geoscape territories

**Battlescape (5)**
- ✅ `add_terrain.prompt.md` - Tile types and properties
- ✅ `add_biome.prompt.md` - Environmental zones
- ✅ `add_map_block.prompt.md` - Individual tactical maps
- ✅ `add_map_script.prompt.md` - Procedural generation
- ✅ `add_tileset.prompt.md` - Visual tile collections

**AI & Systems (1)**
- ✅ `add_ufo_script.prompt.md` - UFO behavior

**Economy (4)**
- ✅ `add_research.prompt.md` - Technology trees
- ✅ `add_manufacturing.prompt.md` - Production recipes
- ✅ `add_purchase.prompt.md` - Marketplace items
- ✅ `add_supplier.prompt.md` - Vendors

**Narrative (3)**
- ✅ `add_event.prompt.md` - Game events
- ✅ `add_quest.prompt.md` - Quests and objectives
- ✅ `add_advisor.prompt.md` - NPC characters

**Organization (1)**
- ✅ `add_organization.prompt.md` - Player organization

**Documentation (1)**
- ✅ `README.md` - Comprehensive guide and index

## Key Features

### Each Prompt Includes

✓ **Clear Naming Convention**: Prefixed IDs (item_, unit_, craft_, etc.)
✓ **Structured Format**: Consistent section organization
✓ **TOML Templates**: Code examples for each content type
✓ **Input Specification**: Required and optional parameters
✓ **Validation Criteria**: Quality checks and validation rules
✓ **Testing Checklist**: Step-by-step verification procedures
✓ **Cross-References**: Links to API and documentation
✓ **Scope Definition**: Affected files and systems

### Consistency Features

✓ **Standardized TOML Structure**
```toml
[entity]
id = "unique_id"
name = "Display Name"
description = "What this is"
type = "category"
tags = ["tag1", "tag2"]
```

✓ **Universal Validation Checks**
- TOML syntax verification
- ID uniqueness confirmation
- Cross-reference validity
- Balance appropriateness
- No circular dependencies

✓ **Reusable Process**
1. Define concept/requirements
2. Create/update TOML entry
3. Validate syntax and references
4. Test in-game
5. Document changes

## System Coverage

| System | Prompts | Coverage |
|--------|---------|----------|
| Economy | 4 | Research, Manufacturing, Marketplace |
| Combat | 2 | Units, UFOs |
| Battlescape | 5 | Terrain, Biomes, Maps, Tilesets |
| Basescape | 3 | Facilities, Services, Infrastructure |
| Geoscape | 5 | World, Regions, Countries, Missions, Crafts |
| Narrative | 3 | Events, Quests, NPCs |
| Organization | 2 | Factions, Player Org |
| **Total** | **24** | Complete game content |

## Naming Prefixes

All content follows prefix pattern for organization:

- **item_** - Equipment, resources
- **unit_** - Soldiers, aliens
- **craft_** - Vehicles, aircraft
- **mission_** - Tactical operations
- **faction_** - Species, organizations
- **campaign_** - Story arcs, phases
- **facility_** - Base buildings
- **service_** - Base operations
- **base_** - Base systems
- **world_** - Strategic maps
- **country_** - Nations
- **region_** - Territories
- **terrain_** - Tile types
- **biome_** - Environmental zones
- **mapblock_** - Tactical maps
- **mapscript_** - Generation scripts
- **tileset_** - Visual tiles
- **ufo_** - Alien craft behavior
- **research_** - Technology
- **manufacturing_** - Production
- **purchase_** - Marketplace
- **supplier_** - Vendors
- **event_** - Game events
- **quest_** - Objectives
- **advisor_** - NPCs
- **org_** - Organizations

## Usage

### To Create New Content
1. Select appropriate prompt file
2. Review "Inputs" section for requirements
3. Use TOML template as starting point
4. Follow "Process" step-by-step
5. Run through "Testing Checklist"
6. Update relevant documentation

### To Modify Content
1. Find content in appropriate system folder
2. Select relevant prompt file
3. Update TOML using template as reference
4. Re-validate all references
5. Test changes in-game
6. Document what changed

### To Find Content
- Use README.md index to find relevant prompt
- Group by system (Economy, Combat, etc.)
- Search by prefix (item_, unit_, etc.)
- Check file organization table

## File Organization

```
.github/prompts/
├── README.md                    ← Start here for overview
├── add_item.prompt.md
├── add_unit.prompt.md
├── add_craft.prompt.md
├── add_mission.prompt.md
├── add_faction.prompt.md
├── add_campaign.prompt.md
├── add_facility.prompt.md
├── add_service.prompt.md
├── add_base_script.prompt.md
├── add_world.prompt.md
├── add_country.prompt.md
├── add_region.prompt.md
├── add_terrain.prompt.md
├── add_biome.prompt.md
├── add_map_block.prompt.md
├── add_map_script.prompt.md
├── add_tileset.prompt.md
├── add_ufo_script.prompt.md
├── add_research.prompt.md
├── add_manufacturing.prompt.md
├── add_purchase.prompt.md
├── add_supplier.prompt.md
├── add_event.prompt.md
├── add_quest.prompt.md
├── add_advisor.prompt.md
└── add_organization.prompt.md
```

## Integration Points

### Mod Content Structure
```
mods/core/
├── economy/          ← items, manufacturing, suppliers, purchases
├── factions/         ← faction definitions with units
├── campaign/         ← missions, campaigns
├── basescape/        ← facilities, services
├── geoscape/         ← world, regions, countries
├── mapblocks/        ← individual maps
├── mapscripts/       ← procedural generation
├── tilesets/         ← visual tiles
├── battlescape/ai/   ← UFO behaviors
├── technology/       ← research trees
├── narrative/        ← events, quests, advisors
└── organizations.toml← player organization
```

### Documentation Reference
- `wiki/API.md` - Complete API reference
- `docs/balance/GAME_NUMBERS.md` - Balance numbers
- `docs/content/` - Content guides
- `docs/[SYSTEM]/` - System documentation

## Next Steps

1. **Review README.md** for comprehensive overview
2. **Select a prompt** matching content to create
3. **Follow TOML template** in the prompt
4. **Validate using checklist** in the prompt
5. **Test in-game** with Love2D console enabled
6. **Document changes** in relevant README.md

## Support

Each prompt includes:
- ✅ Full TOML template
- ✅ Validation criteria
- ✅ Testing procedures
- ✅ API references
- ✅ Example files locations
- ✅ Troubleshooting help

---

**All prompts ready for use!** 🎮
