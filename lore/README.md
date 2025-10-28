# Lore - Game Narrative & Storytelling

**Purpose:** Story content, narrative events, and world-building for AlienFall  
**Audience:** Writers, designers, AI agents  
**Status:** Early development  
**Last Updated:** 2025-10-28

---

## 📋 Quick Reference

- **Purpose:** Game story, narrative progression, world lore
- **Content:** Story documents, event scripts, character backgrounds
- **Format:** Markdown files, narrative structure
- **Related:** `design/mechanics/Lore.md`, `api/LORE.md`, `engine/lore/`

---

## Folder Structure

```
lore/
├── README.md                          ← This file
├── story/                             ← Main storyline
│   ├── introduction.md               ← Game opening
│   ├── act1.md                       ← Story arc 1
│   ├── act2.md                       ← Story arc 2
│   ├── act3.md                       ← Story arc 3
│   └── endings/                      ← Multiple endings
│
└── images/                            ← Story illustrations
    └── [concept art, diagrams]
```

---

## Content

| Type | Files | Purpose |
|------|-------|---------|
| **Story** | ~5 files | Main narrative arc |
| **Images** | ~10 files | Concept art, diagrams |

---

## Relations to Other Modules

| Module | Relationship |
|--------|--------------|
| **design/mechanics/Lore.md** | Design specifications for narrative systems |
| **api/LORE.md** | Lore system API contracts |
| **engine/lore/** | Narrative system implementation |
| **mods/core/rules/events/** | Story events in TOML |

---

## How to Use

### For Writers

1. **Read existing lore:** Understand world setting
2. **Create new content:** Follow narrative structure
3. **Link to mechanics:** Connect story to gameplay
4. **Review for consistency:** Maintain tone and continuity

### For AI Agents

- **When to read:** Understanding game context, creating narrative content
- **How to use:** Reference for event creation, character development
- **Output:** Story events, character backgrounds, world-building

---

## Quick Commands

```bash
# Read main story
cat lore/story/introduction.md

# Find story element
grep -r "keyword" lore/
```

---

**Questions:** See [design/mechanics/Lore.md](../design/mechanics/Lore.md) or ask in project Discord
