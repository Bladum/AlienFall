# System - Universal Patterns & Project Modules

**Purpose:** Project-wide patterns, reusable modules, and architectural standards  
**Audience:** Architects, developers, AI agents  
**Status:** Active documentation  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Relations to Other Modules](#relations-to-other-modules)
- [How to Use](#how-to-use)
- [Quick Reference](#quick-reference)

---

## Overview

The `system/` folder contains **universal system patterns** and **project-specific modules** that apply across the entire project.

**Core Purpose:**
- Document project-wide patterns
- Provide reusable system modules
- Define architectural standards
- Guide system integration

**Note:** For the 9 universal patterns (Separation of Concerns, Pipeline Architecture, etc.), see `docs/system/`.

---

## Folder Structure

```
system/
├── README.md                          ← This file
├── ORGANIZATION.md                    ← System organization guide
│
├── patterns/                          ← Project-Specific Patterns
│   └── README.md
│
├── modules/                           ← Reusable System Modules
│   └── README.md
│
├── systems/                           ← System Documentation
│   └── README.md
│
└── guides/                            ← System Guides
    └── README.md
```

---

## Key Features

- **Architectural Patterns:** Project-wide patterns
- **Reusable Modules:** Shared system modules
- **Integration Guides:** How systems connect
- **Conventions:** Project-wide standards

---

## Relations to Other Modules

| Module | Relationship |
|--------|--------------|
| **docs/system/** | Contains 9 universal patterns |
| **architecture/** | Uses patterns defined here |
| **engine/** | Implements system modules |
| **All modules** | Follow patterns |

---

## How to Use

### For Architects
- Define patterns
- Document systems
- Guide implementation

### For Developers
- Reference patterns
- Use modules
- Follow conventions

### For AI Agents
- **Universal patterns** → See `docs/system/`
- **Project patterns** → See `system/patterns/`
- **Reusable modules** → See `system/modules/`
- **Integration** → See `system/guides/`

---

## Quick Reference

| Folder | Purpose |
|--------|---------|
| `patterns/` | Project patterns |
| `modules/` | Reusable modules |
| `systems/` | System docs |
| `guides/` | Integration guides |

### Related Documentation

- **Universal Patterns:** [docs/system/](../docs/system/) - 9 universal patterns
- **Architecture:** [architecture/README.md](../architecture/README.md) - System architecture
- **Docs:** [docs/README.md](../docs/README.md) - Development guides

---

**Last Updated:** 2025-10-28  
**Questions:** See [ORGANIZATION.md](ORGANIZATION.md) or Discord

