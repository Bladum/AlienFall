# Quick Reference Card

## 🎮 Mod Content Prompts - Quick Access Guide

**Location:** `.github/prompts/`  
**Total:** 26 prompts + 4 documentation files  
**Status:** ✅ Ready to use

---

## 📋 All 26 Prompts

### By Purpose

| Purpose | Prompt File | Prefix | Use For |
|---------|-------------|--------|---------|
| **Equipment** | add_item.prompt.md | item_ | Weapons, armor, resources |
| **Units** | add_unit.prompt.md | unit_ | Soldiers, aliens, NPCs |
| **Vehicles** | add_craft.prompt.md | craft_ | Aircraft, ground vehicles |
| **Missions** | add_mission.prompt.md | mission_ | Tactical operations |
| **Species** | add_faction.prompt.md | faction_ | Alien factions, organizations |
| **Campaigns** | add_campaign.prompt.md | campaign_ | Story progression, phases |
| **Buildings** | add_facility.prompt.md | facility_ | Base structures |
| **Services** | add_service.prompt.md | service_ | Base operations |
| **Defense** | add_base_script.prompt.md | base_ | Base systems, defense |
| **Map** | add_world.prompt.md | world_ | Strategic world |
| **Nations** | add_country.prompt.md | country_ | Governments, funding |
| **Regions** | add_region.prompt.md | region_ | Territories, provinces |
| **Tiles** | add_terrain.prompt.md | terrain_ | Ground types, properties |
| **Zones** | add_biome.prompt.md | biome_ | Environmental themes |
| **Battles** | add_map_block.prompt.md | mapblock_ | Tactical maps |
| **Generation** | add_map_script.prompt.md | mapscript_ | Procedural generation |
| **Visuals** | add_tileset.prompt.md | tileset_ | Sprite collections |
| **AI** | add_ufo_script.prompt.md | ufo_ | UFO behavior, tactics |
| **Tech** | add_research.prompt.md | research_ | Technology trees |
| **Production** | add_manufacturing.prompt.md | manufacturing_ | Craft recipes |
| **Shop** | add_purchase.prompt.md | purchase_ | Marketplace items |
| **Vendors** | add_supplier.prompt.md | supplier_ | Item sellers |
| **Events** | add_event.prompt.md | event_ | Game events, consequences |
| **Quests** | add_quest.prompt.md | quest_ | Objectives, story arcs |
| **NPCs** | add_advisor.prompt.md | advisor_ | Characters, advisors |
| **Org** | add_organization.prompt.md | org_ | Player organization |

---

## 🗂️ By Game System

### Combat & Characters (3)
- add_unit.prompt.md
- add_faction.prompt.md
- add_advisor.prompt.md

### Economy & Tech (4)
- add_item.prompt.md
- add_research.prompt.md
- add_manufacturing.prompt.md
- add_purchase.prompt.md
- add_supplier.prompt.md

### Base Management (3)
- add_facility.prompt.md
- add_service.prompt.md
- add_base_script.prompt.md

### Geoscape & World (4)
- add_world.prompt.md
- add_country.prompt.md
- add_region.prompt.md
- add_craft.prompt.md

### Battlescape (5)
- add_terrain.prompt.md
- add_biome.prompt.md
- add_map_block.prompt.md
- add_map_script.prompt.md
- add_tileset.prompt.md

### Narrative (3)
- add_mission.prompt.md
- add_campaign.prompt.md
- add_quest.prompt.md
- add_event.prompt.md

### Systems (1)
- add_ufo_script.prompt.md

### Organization (1)
- add_organization.prompt.md

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| README.md | Complete guide, index, usage examples |
| SUMMARY.md | Quick stats, file organization, next steps |
| SYSTEM_MAP.md | Visual dependency graph, workflow examples |
| COMPLETION_CHECKLIST.md | Verification checklist, quality metrics |

---

## ⚡ Getting Started

### Step 1: Choose Your Content Type
Find the appropriate prompt from the table above

### Step 2: Open the Prompt
Each prompt file contains:
- Clear instructions
- Required inputs
- TOML template
- Validation criteria
- Testing checklist

### Step 3: Create Content
- Copy TOML template
- Fill in values
- Check against validation
- Test in-game

### Step 4: Validate
- Run through testing checklist
- Check in-game console
- Verify balance
- Document changes

---

## 🎯 Complexity Levels

**Start Here (Beginner)**
- add_item.prompt.md
- add_terrain.prompt.md
- add_research.prompt.md

**Intermediate**
- add_unit.prompt.md
- add_facility.prompt.md
- add_supplier.prompt.md

**Advanced**
- add_mission.prompt.md
- add_campaign.prompt.md
- add_faction.prompt.md

**Expert (Systems)**
- add_map_script.prompt.md
- add_base_script.prompt.md
- add_ufo_script.prompt.md

---

## 🔗 File Locations

### Prompt Storage
```
.github/prompts/
├── *.prompt.md  (26 prompts)
└── *.md         (4 docs)
```

### Content Folders
```
mods/core/
├── economy/        ← items, research, manufacturing, suppliers
├── factions/       ← factions with units
├── campaign/       ← missions, campaigns, quests
├── basescape/      ← facilities, services
├── geoscape/       ← world, countries, regions
├── mapblocks/      ← individual maps
├── mapscripts/     ← procedural generation
├── tilesets/       ← visual tiles
├── battlescape/    ← UFO AI
├── technology/     ← research
├── narrative/      ← events, quests, advisors
└── organizations/  ← org data
```

---

## 📖 Common TOML Pattern

All content follows this pattern:

```toml
[[content_type]]
id = "unique_identifier"
name = "Display Name"
description = "What this does"
type = "category"
tags = ["tag1", "tag2"]

[properties]
property1 = "value"
property2 = 123
```

---

## ✅ Validation Quick Check

Every prompt should:
- ✅ Have unique ID
- ✅ Valid TOML syntax
- ✅ All references exist
- ✅ Balanced values
- ✅ No circular dependencies
- ✅ Pass testing checklist

---

## 🚀 Quick Examples

### Create Simple Item
1. Open: `add_item.prompt.md`
2. File: `mods/core/economy/items.toml`
3. Template: Use provided TOML
4. Validate: Check syntax
5. Test: In-game verification

### Create Mission
1. Open: `add_mission.prompt.md`
2. Prepare: Map (add_map_block)
3. Enemies: Faction units (add_faction)
4. Rewards: Items & tech (add_item, add_research)
5. Test: Launch mission

### Build Campaign
1. Plan: Phases & progression
2. Create: Missions (add_mission)
3. Connect: World, factions, content
4. Add: Narrative (add_quest, add_event)
5. Polish: Advisors (add_advisor)

---

## 📞 Need Help?

1. **Read the prompt** - Each has full instructions
2. **Check README.md** - Comprehensive guide
3. **View examples** - In `mods/core/`
4. **Review SYSTEM_MAP.md** - See dependencies
5. **Check API.md** - Full documentation

---

## 💡 Tips

- Start with beginner-level prompts
- Follow TOML templates exactly
- Validate before testing
- Check console for errors
- Use examples as references
- Keep related content organized
- Document your changes

---

**Version:** 1.0  
**Created:** October 16, 2025  
**Status:** ✅ Production Ready

All prompts ready to use! 🎮
