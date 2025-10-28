# Game Design Documentation

**Purpose:** Define game mechanics, balance parameters, and design decisions
**Audience:** Game designers, developers, AI agents, balance testers
**Status:** Active development
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

The `design/` folder contains **all game design documentation**, defining mechanics, rules, balance parameters, and design rationale. This is the **first step** in the development workflow: Design → API → Architecture → Engine → Mods → Tests.

**Core Purpose:**
- Define game mechanics and rules
- Specify balance parameters and costs
- Document design decisions and rationale
- Identify implementation gaps
- Provide consistent terminology (glossary)

---

## Folder Structure

```
design/
├── README.md                          ← This file
├── DESIGN_TEMPLATE.md                 ← Template for new designs
├── GLOSSARY.md                        ← Game terminology reference
│
├── mechanics/                         ← System Design Specs (25 files)
│   ├── README.md                     ← Mechanics overview
│   ├── Overview.md                   ← High-level game design
│   ├── Geoscape.md, Basescape.md, Battlescape.md
│   ├── Units.md, Items.md, Crafts.md
│   ├── Economy.md, Finance.md, Politics.md
│   └── [other systems]
│
├── gaps/                              ← Design-to-Implementation Gap Analysis
│   └── README.md
│
└── ideas/                             ← Future Ideas & Concepts
    └── [idea files]
```

---

## Key Features

- **Comprehensive Mechanics:** 25+ system designs covering all game aspects
- **Balance Parameters:** Numbers, costs, probabilities, difficulty settings
- **Design Rationale:** Why decisions were made
- **Gap Analysis:** Tracks what's designed vs. implemented
- **Consistent Terminology:** GLOSSARY.md for standard terms
- **Template System:** DESIGN_TEMPLATE.md for new designs

---

## Content

| Category | Files | Purpose |
|----------|-------|---------|
| **Game Layers** | 5 files | Geoscape, Basescape, Battlescape, Interception, 3D |
| **Core Systems** | 7 files | Units, Items, Crafts, Economy, Finance, Politics, Countries |
| **Supporting** | 8 files | AI, GUI, Lore, Analytics, Assets, Pilots, HexSystem |
| **Meta Docs** | 4 files | Integration, Relations, Future, Glossary |

---

## Input/Output

### Inputs
- Game vision from project goals
- Player feedback from playtesting
- Technical constraints from engine
- Reference games (X-COM)
- Balance data from `logs/analytics/`

### Outputs
- Mechanic specs → `api/*.md`
- System requirements → `architecture/**/*.md`
- Implementation tasks → `engine/**/*.lua`
- Content needs → `mods/core/rules/**/*.toml`
- Test scenarios → `tests2/**/*_test.lua`

---

## Relations to Other Modules

```
design/mechanics/*.md → api/*.md → architecture/**/*.md → engine/**/*.lua → mods/ → tests2/
```

| Module | Relationship | Details |
|--------|--------------|---------|
| **api/** | Output | Design specs become API contracts |
| **architecture/** | Output | Design requires technical architecture |
| **engine/** | Output | Design is implemented in code |
| **mods/** | Output | Design is configured in TOML |
| **tests2/** | Output | Design defines test cases |
| **logs/** | Input | Analytics inform balance decisions |

---

## Format Standards

Use **[DESIGN_TEMPLATE.md](DESIGN_TEMPLATE.md)** for all new designs.

Standard sections:
- Overview
- Core Mechanics
- Rules & Constraints
- Balance Parameters (in tables)
- User Interactions
- Integration Points
- Design Rationale
- Examples
- Future Enhancements
- See Also (cross-references)

---

## How to Use

### For Game Designers

1. Copy template: `cp DESIGN_TEMPLATE.md mechanics/My_System.md`
2. Fill all sections (Overview, Mechanics, Balance, Integration)
3. Add new terms to GLOSSARY.md
4. Cross-reference with related designs

### For Developers

1. Read design: `cat design/mechanics/[System].md`
2. Understand mechanics, parameters, integration points
3. Follow workflow: Design → API → Architecture → Engine → Mods → Tests
4. Update gap analysis when implemented

### For AI Agents

See [AI Agent Instructions](#ai-agent-instructions) below.

---

## How to Contribute

### Creating New Design

1. Use template: `cp DESIGN_TEMPLATE.md mechanics/[System].md`
2. Fill all sections (don't skip, mark "TBD" if unknown)
3. Add new terms to GLOSSARY.md
4. Update this README (folder structure, content tables)
5. Cross-reference in related designs

### Updating Existing Design

1. Version properly (semantic versioning)
2. Document what changed and why
3. Update balance parameters with reasoning
4. Keep terminology consistent with GLOSSARY.md
5. Check downstream: API, architecture, engine, mods

---

## AI Agent Instructions

### When to Read Design

| Scenario | Action |
|----------|--------|
| Implementing new feature | Read design FIRST, then API/architecture |
| Balancing game | Read balance parameters + analytics logs |
| Understanding system | Read design overview and mechanics |
| Creating content | Read design for parameters and constraints |

### Design-First Workflow

```
User asks to implement feature
    ↓
1. Check if design exists: ls design/mechanics/*.md | grep -i [system]
    ↓
2a. If exists: Read thoroughly → Proceed to API
2b. If missing: Create design FIRST → Get review → Then API
    ↓
3. Follow: Design → API → Architecture → Engine → Mods → Tests
    ↓
4. Update gap analysis when implemented
```

### Reading Balance Parameters

```markdown
| Stat | Base Value | Range | Notes |
|------|------------|-------|-------|
| Health | 100 | 50-150 | Rookie to Elite |

AI Action:
1. Extract: health=100
2. Note range: 50-150
3. Understand context: "Rookie to Elite" means progression
4. Apply to implementation
```

---

## Good Practices

### ✅ Documentation
- Use DESIGN_TEMPLATE.md
- Fill all sections
- Document rationale (why, not just what)
- Keep balance parameters in tables
- Version properly

### ✅ Balance Parameters
- Provide concrete numbers
- Document why each value chosen
- Include min/max constraints
- Reference analytics data
- Mark experimental values

---

## Bad Practices

### ❌ Documentation
- Don't skip template sections
- Don't forget to version changes
- Don't mix design with implementation details
- Don't create designs after code is written
- Don't use inconsistent terminology

### ❌ Balance Parameters
- Don't use vague terms ("high", "low")
- Don't skip rationale
- Don't ignore analytics data
- Don't hard-code numbers in multiple places
- Don't balance in isolation

---

## Quick Reference

### Essential Files

| File | Purpose |
|------|---------|
| `DESIGN_TEMPLATE.md` | Template for new designs |
| `GLOSSARY.md` | Game terminology |
| `mechanics/Overview.md` | High-level game design |
| `mechanics/Integration.md` | System connections |
| `gaps/README.md` | Implementation tracking |

### Most Common Designs

| System | File |
|--------|------|
| Units | `mechanics/Units.md` |
| Items | `mechanics/Items.md` |
| Battlescape | `mechanics/Battlescape.md` |
| Geoscape | `mechanics/Geoscape.md` |
| Economy | `mechanics/Economy.md` |

### Quick Commands

```bash
# Find design
ls design/mechanics/*.md | grep -i [system]

# Create new design
cp design/DESIGN_TEMPLATE.md design/mechanics/[New_System].md

# Check term
grep -i "term" design/GLOSSARY.md
```

### Related Documentation

- **API:** [api/README.md](../api/README.md) - Contracts from designs
- **Architecture:** [architecture/README.md](../architecture/README.md) - Technical implementation
- **Engine:** Implementation of designs
- **Mods:** [mods/README.md](../mods/README.md) - Content based on designs
- **Tests:** [tests2/README.md](../tests2/README.md) - Verification

---

**Last Updated:** 2025-10-28
**Questions:** See [DESIGN_TEMPLATE.md](DESIGN_TEMPLATE.md) or ask in Discord
