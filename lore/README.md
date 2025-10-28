# Lore - Game Narrative & Storytelling

**Purpose:** Story content, narrative events, and world-building for AlienFall
**Audience:** Writers, designers, AI agents
**Status:** Early development
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Content](#content)
- [Input/Output](#inputoutput)
- [Relations to Other Modules](#relations-to-other-modules)
- [Format Standards](#format-standards)
- [How to Use](#how-to-use)
- [How to Contribute](#how-to-contribute)
- [AI Agent Instructions](#ai-agent-instructions)
- [Good Practices](#good-practices)
- [Bad Practices](#bad-practices)
- [Quick Reference](#quick-reference)

---

## Overview

The `lore/` folder contains **story content, narrative events, and world-building** for AlienFall. This includes campaign narratives, faction backgrounds, world descriptions, and character stories that provide context and immersion for the game.

**Core Purpose:**
- Define the game's narrative framework
- Provide world-building and lore
- Create immersive storytelling elements
- Support procedural narrative generation
- Document faction and character backgrounds

---

## Folder Structure

```
lore/
├── README.md                          ← This file
│
├── story/                             ← Main storyline content
│   ├── introduction.md               ← Game opening narrative
│   ├── act1.md                       ← Story arc 1
│   ├── act2.md                       ← Story arc 2
│   ├── act3.md                       ← Story arc 3
│   └── endings/                      ← Multiple ending scenarios
│
└── images/                            ← Story illustrations and assets
    ├── factions/                     ← Faction artwork
    ├── worlds/                       ← World/environment images
    ├── characters/                   ← Character portraits
    └── concepts/                     ← Concept art and diagrams
```

---

## Key Features

- **Campaign Narrative:** Multi-act story progression
- **Faction Lore:** Detailed faction backgrounds and histories
- **World Building:** Planetary and environmental descriptions
- **Character Stories:** NPC backgrounds and motivations
- **Visual Assets:** Supporting artwork and illustrations
- **Narrative Integration:** Ties into game mechanics and events

---

## Content

| Category | Files | Purpose |
|----------|-------|---------|
| **Story Arcs** | 4+ files | Main narrative progression |
| **Faction Lore** | 5+ files | Faction backgrounds and histories |
| **World Descriptions** | 3+ files | Planetary and environmental lore |
| **Character Stories** | 10+ files | NPC backgrounds and motivations |
| **Visual Assets** | 50+ files | Supporting artwork and illustrations |

---

## Input/Output

### Inputs
- Game design requirements from `design/mechanics/Lore.md`
- Faction definitions from `api/POLITICS.md`
- World generation parameters from `api/GEOSCAPE.md`
- Character templates from `api/UNITS.md`

### Outputs
- Narrative content → `engine/lore/` (loaded by narrative system)
- Story events → `mods/core/rules/events/` (TOML events)
- Character backgrounds → `mods/core/rules/units/` (unit lore)
- World descriptions → `mods/core/rules/countries/` (country lore)

---

## Relations to Other Modules

```
design/mechanics/Lore.md → lore/story/*.md → engine/lore/ → mods/core/rules/events/
    ↓                          ↓                      ↓                      ↓
Requirements              Content              Loading              Events
```

| Module | Relationship | Details |
|--------|--------------|---------|
| **design/mechanics/Lore.md** | Input | Defines narrative requirements and structure |
| **api/LORE.md** | Contract | API for narrative system integration |
| **engine/lore/** | Implementation | Loads and manages lore content |
| **mods/core/rules/events/** | Output | Story events in TOML format |
| **mods/core/rules/units/** | Output | Character backgrounds in unit definitions |

---

## Format Standards

**Story Files:**
- Use Markdown format
- Include narrative hooks for gameplay integration
- Reference game mechanics and systems
- Maintain consistent tone and style

**Image Assets:**
- PNG format with transparent backgrounds
- Consistent art style
- Proper naming conventions
- Include metadata in accompanying text files

**File Naming:**
- `snake_case.md` for story files
- `PascalCase.png` for character images
- `kebab-case.png` for concept art

---

## How to Use

### For Writers

1. **Read design requirements:** `cat design/mechanics/Lore.md`
2. **Understand narrative structure:** Review existing story arcs
3. **Create content:** Write in Markdown format
4. **Add visual assets:** Create supporting illustrations
5. **Test integration:** Ensure narrative hooks work with game systems

### For Designers

1. **Reference lore:** Use for world-building and immersion
2. **Create events:** Base story events on lore content
3. **Balance narrative:** Ensure story progression matches gameplay
4. **Visual consistency:** Maintain art style across assets

### For AI Agents

See [AI Agent Instructions](#ai-agent-instructions) below.

---

## How to Contribute

### Adding New Lore

1. **Check requirements:** Read `design/mechanics/Lore.md`
2. **Choose location:** `story/` for narrative, `images/` for assets
3. **Follow format:** Use standard Markdown/image formats
4. **Add references:** Link to game systems and mechanics
5. **Update README:** Add new content to content tables

### Story Writing Guidelines

1. **Maintain consistency:** Follow established lore and tone
2. **Include hooks:** Add gameplay integration points
3. **Reference mechanics:** Mention game systems naturally
4. **Keep modular:** Allow for different playthroughs
5. **Document sources:** Note inspiration and references

### Visual Asset Guidelines

1. **Style consistency:** Match existing art direction
2. **Technical specs:** Follow resolution and format requirements
3. **Naming:** Use descriptive, consistent naming
4. **Metadata:** Include creation notes and usage context

---

## AI Agent Instructions

### When to Read Lore

| Scenario | Action |
|----------|--------|
| Creating story events | Read relevant story arcs |
| Writing character backgrounds | Read faction and character lore |
| World-building | Read planetary descriptions |
| Creating narrative content | Read existing patterns and style |

### Narrative Creation Workflow

```
User asks for story content
    ↓
1. Read design requirements: design/mechanics/Lore.md
    ↓
2. Review existing content: lore/story/*.md
    ↓
3. Check integration points: api/LORE.md
    ↓
4. Create content: lore/story/new_content.md
    ↓
5. Add visual assets: lore/images/new_asset.png
    ↓
6. Test integration: engine/lore/ loading
```

### Content Analysis

```markdown
When reading lore content, identify:
- Narrative hooks (gameplay integration points)
- Character motivations (AI behavior guides)
- World elements (procedural generation seeds)
- Faction relationships (diplomacy system inputs)
- Historical events (timeline references)
```

---

## Good Practices

### ✅ Content Creation
- Maintain consistent narrative voice
- Include gameplay integration points
- Reference established lore
- Keep content modular and reusable
- Document sources and inspiration

### ✅ Visual Assets
- Follow established art style
- Use consistent resolutions
- Include transparent backgrounds
- Provide metadata and context
- Optimize file sizes

### ✅ Organization
- Use clear file naming conventions
- Group related content logically
- Update documentation when adding content
- Cross-reference between related files
- Maintain version history

---

## Bad Practices

### ❌ Content Issues
- Don't contradict established lore
- Don't create unintegrated content
- Don't use inconsistent tone or style
- Don't include spoilers inappropriately
- Don't create content without design approval

### ❌ Technical Issues
- Don't use unsupported file formats
- Don't exceed size limits
- Don't forget metadata
- Don't use inconsistent naming
- Don't duplicate existing content

### ❌ Organization Issues
- Don't create content without updating README
- Don't place files in wrong directories
- Don't forget cross-references
- Don't ignore integration requirements
- Don't work in isolation

---

## Quick Reference

### Essential Files

| File | Purpose |
|------|---------|
| `story/introduction.md` | Game opening narrative |
| `story/act1.md` | First story arc |
| `story/act2.md` | Second story arc |
| `story/act3.md` | Third story arc |
| `story/endings/` | Multiple endings |

### Content Types

| Type | Location | Format |
|------|----------|--------|
| **Story Arcs** | `story/act*.md` | Markdown |
| **Faction Lore** | `story/factions/` | Markdown |
| **World Lore** | `story/worlds/` | Markdown |
| **Character Stories** | `story/characters/` | Markdown |
| **Visual Assets** | `images/` | PNG |

### Quick Commands

```bash
# Read main story
cat lore/story/introduction.md

# Find story element
grep -r "keyword" lore/story/

# List visual assets
ls lore/images/

# Check story structure
find lore/story/ -name "*.md" | head -10
```

### Related Documentation

- **Design:** [design/mechanics/Lore.md](../design/mechanics/Lore.md) - Narrative design requirements
- **API:** [api/LORE.md](../api/LORE.md) - Lore system API contracts
- **Engine:** [engine/lore/](../engine/lore/) - Lore system implementation
- **Mods:** [mods/core/rules/events/](../mods/core/rules/events/) - Story events in TOML
- **Events:** [mods/core/rules/events/](../mods/core/rules/events/) - Narrative event definitions

---

**Last Updated:** 2025-10-28
**Questions:** See [design/mechanics/Lore.md](../design/mechanics/Lore.md) or ask in Discord
