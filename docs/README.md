# Documentation Hub

**Purpose:** Central documentation for development practices, AI personas, prompts, and system patterns  
**Audience:** Developers, AI agents, designers, contributors  
**Status:** Active maintenance  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Content](#content)
- [Relations to Other Modules](#relations-to-other-modules)
- [How to Use](#how-to-use)
- [AI Agent Instructions](#ai-agent-instructions)
- [Quick Reference](#quick-reference)

---

## Overview

The `docs/` folder is the **central documentation hub** containing development guides, AI agent personas, content creation templates, and universal system patterns.

**Core Purpose:**
- Provide development best practices (24 instruction guides)
- Define AI agent personas (23 chatmodes)
- Offer content creation templates (27 prompts)
- Document universal system patterns (9 patterns)
- Centralize project processes and handbook

---

## Folder Structure

```
docs/
├── README.md                          ← This file
│
├── chatmodes/                         ← AI Agent Personas (23 files)
│   ├── README.md
│   ├── QUICK-REFERENCE.md
│   └── *.chatmode.md (Strategic, Design, Implementation, Testing, Analysis, Support)
│
├── instructions/                      ← Development Practices (24 files)
│   ├── README.md
│   ├── START_HERE.md
│   ├── INDEX_ALL_24_PRACTICES.md
│   └── *.instructions.md (Programming, Art, Design, DevOps, Management, etc.)
│
├── prompts/                           ← Content Creation Templates (27 files)
│   ├── README.md
│   └── add_*.prompt.md (unit, item, craft, mission, facility, etc.)
│
├── system/                            ← Universal System Patterns (9 files + 4 creation prompts)
│   ├── 01-09_*_SYSTEM.md
│   └── create_*.prompt.md
│
├── handbook/                          ← Project Handbook
│   └── README.md
│
├── processes/                         ← Development Workflows
│   └── README.md
│
└── WIP/                              ← Work In Progress
    └── README.md
```

**Total:** 23 chatmodes + 24 instructions + 27 prompts + 9 patterns + 4 creation prompts = 87 files

---

## Key Features

- **AI Agent Personas (23):** Specialized roles for different tasks
- **Development Practices (24):** Comprehensive guides
- **Content Prompts (27):** Structured templates
- **System Patterns (9):** Universal architectural patterns
- **Creation Prompts (4):** Templates for new docs
- **Handbook:** Project-wide conventions
- **Processes:** Step-by-step workflows

---

## Content

| Type | Count | Purpose | Location |
|------|-------|---------|----------|
| **ChatModes** | 23 | AI agent personas | `chatmodes/` |
| **Instructions** | 24 | Development practices | `instructions/` |
| **Prompts** | 27 | Content creation | `prompts/` |
| **Patterns** | 9 | System architectures | `system/` |
| **Meta Prompts** | 4 | Create docs | `system/` |

### Documentation by Audience

| Audience | Folders | Use Cases |
|----------|---------|-----------|
| **Developers** | instructions/, system/ | Code standards, patterns |
| **AI Agents** | chatmodes/, prompts/, system/ | Persona selection, tasks |
| **Designers** | instructions/, prompts/ | Design guidelines, content |
| **Modders** | prompts/, instructions/ | Content creation |
| **All** | handbook/, processes/ | Standards, workflows |

---

## Relations to Other Modules

| Module | Relationship | Details |
|--------|--------------|---------|
| **design/** | Reference | Instructions guide design process |
| **api/** | Reference | Instructions for API docs |
| **architecture/** | Reference | System patterns inform architecture |
| **engine/** | Reference | Code standards |
| **mods/** | Output | Prompts create content |
| **tests2/** | Reference | Testing practices |

---

## How to Use

### For Developers

```bash
# Find guidance
ls docs/instructions/*.md | grep -i [topic]

# Read testing guide
cat docs/instructions/🧪\ Testing.instructions.md
```

**Using Instructions:**
1. Browse `instructions/INDEX_ALL_24_PRACTICES.md`
2. Read `instructions/START_HERE.md` if new
3. Select relevant guide
4. Follow best practices
5. Reference while working

### For AI Agents

```bash
# Find chatmode
cat docs/chatmodes/QUICK-REFERENCE.md

# Load persona
cat docs/chatmodes/engine_developer.chatmode.md

# Use prompt
cat docs/prompts/add_unit.prompt.md
```

### For Content Creators

```bash
# Find prompt
ls docs/prompts/add_*.md

# Read template
cat docs/prompts/add_[type].prompt.md

# Fill template → Output to mods/
```

---

## AI Agent Instructions

### Navigation

```
1. Identify task type:
   - Implementation? → chatmodes/ + instructions/
   - Content creation? → prompts/
   - Architecture? → system/
   - Process? → processes/

2. Select documentation:
   - ChatMode for persona
   - Instruction for practices
   - Prompt for creation
   - Pattern for architecture

3. Apply to task
```

### Common Workflows

| Task | Documentation Path |
|------|-------------------|
| **Implement feature** | chatmodes/engine_developer.chatmode.md → instructions/🛠️ Love2D & Lua |
| **Create content** | chatmodes/modder.chatmode.md → prompts/add_[type].prompt.md |
| **Design system** | chatmodes/game_designer.chatmode.md → instructions/🎮 Game Mechanics |
| **Write tests** | chatmodes/engine_tester.chatmode.md → instructions/🧪 Testing |

---

## Quick Reference

### Essential Documentation

| File | Purpose |
|------|---------|
| `chatmodes/QUICK-REFERENCE.md` | Persona selection |
| `instructions/START_HERE.md` | Beginner guide |
| `instructions/INDEX_ALL_24_PRACTICES.md` | Complete index |
| `prompts/README.md` | Prompt overview |

### Most Used

| Guide | Audience |
|-------|----------|
| 🛠️ Love2D & Lua | Developers |
| 🧪 Testing | Developers, QA |
| 🎮 Game Mechanics | Designers |
| 🔄 Git Workflow | All |
| 🔌 Modding Support | Modders |

### Quick Commands

```bash
# Find instruction
grep -r "keyword" docs/instructions/

# List chatmodes
ls docs/chatmodes/*.chatmode.md

# Find prompt
ls docs/prompts/add_*.md

# Read pattern
cat docs/system/01_*.md
```

### Related Documentation

- **Design:** [design/README.md](../design/README.md) - What to build
- **API:** [api/README.md](../api/README.md) - System contracts
- **Architecture:** [architecture/README.md](../architecture/README.md) - System architecture
- **Tests:** [tests2/README.md](../tests2/README.md) - Testing

---

**Last Updated:** 2025-10-28  
**Questions:** See [handbook/README.md](handbook/README.md) or Discord

