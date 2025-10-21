# Documentation Navigation Guide

This guide provides a complete map of AlienFall documentation, including cross-references and recommended reading paths.

---

## Quick Navigation Paths

### "I want to..." Navigation

**Play the game**
→ [Overview](systems/Overview.md) → [FAQ](../README.md#faq) → [Glossary](Glossary.md)

**Set up the development environment**
→ [Setup Guide (Windows)](developers/SETUP_WINDOWS.md) → [Development Workflow](developers/WORKFLOW.md)

**Understand the architecture**
→ [System Architecture](architecture/SYSTEM_INTERACTION.md) → [Architecture Decisions](architecture/README.md)

**Add a new game feature**
→ [Design Template](design/DESIGN_TEMPLATE.md) → [Relevant API docs](api/CORE.md) → [Examples](examples/)

**Debug a problem**
→ [Troubleshooting](developers/TROUBLESHOOTING.md) → [Debugging Guide](developers/DEBUGGING.md)

**Contribute to documentation**
→ [Documentation Standards](DOCUMENTATION_STANDARD.md) → [This guide](#)

---

## Complete Documentation Map

### Core Hub
```
docs/README.md (START HERE)
├── For Players
├── For Developers
├── For Designers
├── For Modders
└── Master Index
```

### Game Systems (Alphabetical)

| System | Player Doc | Developer Doc | Designer Doc |
|--------|-----------|---------------|--------------|
| **3D Rendering** | [3D.md](systems/3D.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | - |
| **AI Systems** | [AI Systems.md](systems/AI%20Systems.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Analytics** | [Analytics.md](systems/Analytics.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | - |
| **Assets** | [Assets.md](systems/Assets.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | - |
| **Base Management** | [Basescape.md](systems/Basescape.md) | [api/BASESCAPE.md](api/BASESCAPE.md) | [examples/ADDING_RESEARCH.md](examples/ADDING_RESEARCH.md) |
| **Tactical Combat** | [Battlescape.md](systems/Battlescape.md) | [api/BATTLESCAPE.md](api/BATTLESCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Aircraft** | [Crafts.md](systems/Crafts.md) | [api/GEOSCAPE.md](api/GEOSCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Economy** | [Economy.md](systems/Economy.md) | [api/ECONOMY.md](api/ECONOMY.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Finance** | [Finance.md](systems/Finance.md) | [api/ECONOMY.md](api/ECONOMY.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Strategy Layer** | [Geoscape.md](systems/Geoscape.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **System Integration** | [Integration.md](systems/Integration.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | - |
| **Air Combat** | [Interception.md](systems/Interception.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Equipment** | [Items.md](systems/Items.md) | [api/BATTLESCAPE.md](api/BATTLESCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Story & Lore** | [Lore.md](systems/Lore.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | - |
| **Politics** | [Politics.md](systems/Politics.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Characters & Units** | [Units.md](systems/Units.md) | [api/UNITS.md](api/UNITS.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **UI Systems** | [Gui.md](systems/Gui.md) | [api/ARCHITECTURE.md](api/ARCHITECTURE.md) | - |

### Developer Documentation

```
developers/
├── SETUP_WINDOWS.md ........... Windows installation
├── SETUP_LINUX.md ............ Linux installation
├── SETUP_MAC.md .............. macOS installation
├── WORKFLOW.md ............... Git workflow & collaboration
├── DEBUGGING.md .............. Console debugging & techniques
└── TROUBLESHOOTING.md ........ Common issues & solutions
```

### API Reference

```
api/
├── README.md ................. API index & quick links
├── ARCHITECTURE.md ........... Core architecture APIs
├── BASESCAPE.md .............. Base management APIs
├── BATTLESCAPE.md ............ Tactical combat APIs
├── ECONOMY.md ................ Economy & finance APIs
└── UNITS.md .................. Unit system APIs
```

### Architecture Documentation

```
architecture/
├── README.md ................. Index of ADRs
├── ADR-001-HEXGRID.md ........ Hexagonal grid decision
├── ADR-002-TURNBASED.md ...... Turn-based vs real-time
├── ADR-003-MODULES.md ........ Module separation
├── ADR-004-PERSISTENCE.md .... Data persistence
└── ADR-005-AI.md ............. AI decision-making
```

### Learning Examples

```
examples/
├── ADDING_UNIT_CLASS.md ...... New unit type walkthrough
├── ADDING_WEAPON.md ......... New weapon type walkthrough
├── ADDING_RESEARCH.md ....... New research project walkthrough
├── ADDING_MISSION.md ........ New mission type walkthrough
└── ADDING_UI.md ............ New UI element walkthrough
```

### Design Documentation

```
design/
├── README.md ................ Design documentation index
├── BALANCE_REFERENCE.md ...... Balance parameters
├── TESTING_METHODOLOGY.md .... How to test mechanics
└── DESIGNER_QUICKREF.md ...... One-page cheat sheet
```

### Core Reference

```
wiki/
├── README.md ................. Game design documentation hub (START HERE)
├── NAVIGATION.md ............ This file
├── GLOSSARY.md ............... Game terminology (merged reference)
├── systems/ .................. All 19 game systems
├── api/ ...................... API references
├── architecture/ ............ Design decisions & ADRs
├── design/ ................... Design documentation
└── examples/ ................. Learning examples

docs/ (Developer Tools)
├── README.md ................. Developer documentation hub
├── DOCS_NAVIGATION.md ........ Developer guide navigation
├── DOCUMENTATION_STANDARD.md . Standards & conventions
├── CODE_STANDARDS.md ......... Code style & naming
├── COMMENT_STANDARDS.md ...... Comment conventions
├── PERFORMANCE.md ............ Performance & optimization
├── Glossary.md ............... Developer terminology
└── api/README.md ............ Developer API links
```

---

## Cross-Reference Map by Topic

### Geoscape (Strategic Layer)

**Mechanics Overview**: [Geoscape.md](systems/Geoscape.md)
**API Reference**: [api/ARCHITECTURE.md](api/ARCHITECTURE.md)
**Example Implementation**: [examples/ADDING_MISSION.md](examples/ADDING_MISSION.md)
**Balance Parameters**: [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md)
**Related Systems**: [Crafts.md](systems/Crafts.md), [Interception.md](systems/Interception.md), [Economy.md](systems/Economy.md)

### Basescape (Base Management)

**Mechanics Overview**: [Basescape.md](systems/Basescape.md)
**API Reference**: [api/BASESCAPE.md](api/BASESCAPE.md)
**Example Implementation**: [examples/ADDING_RESEARCH.md](examples/ADDING_RESEARCH.md)
**Balance Parameters**: [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md)
**Related Systems**: [Economy.md](systems/Economy.md), [Items.md](systems/Items.md), [Units.md](systems/Units.md)

### Battlescape (Tactical Combat)

**Mechanics Overview**: [Battlescape.md](systems/Battlescape.md)
**API Reference**: [api/BATTLESCAPE.md](api/BATTLESCAPE.md)
**Example Implementation**: [examples/ADDING_WEAPON.md](examples/ADDING_WEAPON.md)
**Balance Parameters**: [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md)
**Related Systems**: [Units.md](systems/Units.md), [Items.md](systems/Items.md), [AI Systems.md](systems/AI%20Systems.md)

### Economy & Finance

**Mechanics Overview**: [Economy.md](systems/Economy.md), [Finance.md](systems/Finance.md)
**Balance Parameters**: [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md)
**Related Systems**: [Basescape.md](systems/Basescape.md), [Politics.md](systems/Politics.md)

### Units & Characters

**Mechanics Overview**: [Units.md](systems/Units.md)
**API Reference**: [api/UNITS.md](api/UNITS.md)
**Example Implementation**: [examples/ADDING_UNIT_CLASS.md](examples/ADDING_UNIT_CLASS.md)
**Balance Parameters**: [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md)
**Related Systems**: [Battlescape.md](systems/Battlescape.md), [Basescape.md](systems/Basescape.md)

### AI Systems

**Overview**: [AI Systems.md](systems/AI%20Systems.md)
**Balance & Difficulty**: [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md)
**Architecture**: [architecture/ADR-005-AI.md](architecture/ADR-005-AI.md)
**Related Systems**: [Battlescape.md](systems/Battlescape.md), [Geoscape.md](systems/Geoscape.md)

---

## By Audience

### Players Starting Out
1. [Overview](systems/Overview.md) - Game basics
2. [FAQ](../README.md#faq) - Common questions
3. [Glossary](Glossary.md) - Terminology
4. System docs as needed: [Geoscape](systems/Geoscape.md), [Basescape](systems/Basescape.md), [Battlescape](systems/Battlescape.md)

### New Developers
1. [Setup Guide (Windows)](developers/SETUP_WINDOWS.md) - Get running
2. [Development Workflow](developers/WORKFLOW.md) - How to work
3. [Code Standards](../docs/CODE_STANDARDS.md) - How to code
4. [System Architecture](architecture/README.md) - How systems fit together
5. [Debugging Guide](developers/DEBUGGING.md) - How to debug
6. [API Reference](api/README.md) - Available APIs
7. Relevant API docs for your task

### Game Designers
1. [Design Template](design/README.md) - Design documentation index
2. [Balance Reference](design/BALANCE_REFERENCE.md) - Current parameters
3. System mechanics docs: [Geoscape](systems/Geoscape.md), [Basescape](systems/Basescape.md), [Battlescape](systems/Battlescape.md)
4. [Testing Methodology](design/TESTING_METHODOLOGY.md) - How to verify balance
5. [Designer Quick Reference](design/DESIGNER_QUICKREF.md) - Cheat sheet

### Modders
1. [Mod Creation Guide](../mods/README.md) - Get started
2. [API Reference](api/README.md) - What you can use
3. [Code Standards](../docs/CODE_STANDARDS.md) - Conventions
4. System docs as needed
5. [Design System](design/README.md) - How customization works

---

## Dependency Graph

```
Game Design Hub (wiki/README.md)
├── Audience Paths
│   ├── Players → Overview → Glossary → System Docs
│   ├── Developers → Setup → Workflow → Code Standards → API Docs
│   ├── Designers → Design Template → Balance Reference → System Docs
│   └── Modders → Mod Guide → API Reference
├── System Docs (19 systems documented)
│   └── Link to: API Docs, Architecture, Balance Params
├── API Docs
│   ├── Architecture → State Management & Core
│   ├── Basescape → Items, Research, Facilities
│   ├── Battlescape → Units, Combat, Weapons
│   ├── Economy → Finance & Trading
│   └── Units → Unit progression & classes
├── Architecture
│   ├── ADRs → Design decisions
│   │   ├── ADR-001: Hexgrid decision
│   │   ├── ADR-002: Turn-based vs real-time
│   │   ├── ADR-003: Module separation
│   │   ├── ADR-004: Data persistence
│   │   └── ADR-005: AI decision-making
├── Examples
│   ├── Adding Unit → Units API
│   ├── Adding Weapon → Battlescape API
│   ├── Adding Research → Basescape API
│   ├── Adding Mission → Geoscape/Architecture
│   └── Adding UI → Architecture
└── Design Docs
    ├── Balance Reference → System docs
    ├── Testing Methodology → Testing
    └── Designer Quick Reference → Cheat sheet

Developer Tools Hub (docs/README.md)
├── Setup Guides
│   ├── SETUP_WINDOWS.md
│   └── SETUP_LINUX.md
├── Workflow Docs
│   ├── WORKFLOW.md → Git & collaboration
│   ├── DEBUGGING.md → Debugging techniques
│   └── TROUBLESHOOTING.md → Common issues
├── Standards
│   ├── CODE_STANDARDS.md
│   ├── COMMENT_STANDARDS.md
│   └── DOCUMENTATION_STANDARD.md
├── Reference
│   ├── PERFORMANCE.md
│   ├── Glossary.md (developer terms)
│   └── DOCS_NAVIGATION.md
```

---

## Search Tips

**Looking for something specific?**

| If you want to find... | Look here... |
|----------------------|-------------|
| A game mechanic | System docs (Geoscape.md, etc.) or GLOSSARY.md |
| An API function | api/README.md, api/ARCHITECTURE.md, etc. |
| How to do something | examples/ folder or relevant API docs |
| A design decision | architecture/ folder (ADRs) |
| Balance parameters | design/BALANCE_REFERENCE.md |
| A term definition | GLOSSARY.md or docs/Glossary.md |
| Setup help | docs/developers/SETUP_*.md |
| Troubleshooting | docs/developers/TROUBLESHOOTING.md |
| Code style rules | docs/CODE_STANDARDS.md or docs/COMMENT_STANDARDS.md |
| How to write docs | docs/DOCUMENTATION_STANDARD.md |

---

## Link Format Reference

All links use relative paths from the current document. Examples:

```markdown
# From: docs/developers/WORKFLOW.md

## Cross-references

[Main documentation](../README.md)              # Up one level
[Setup guide](SETUP_WINDOWS.md)                # Same level
[Glossary](../Glossary.md)                     # Up one level
[API Reference](../api/CORE.md)                # Up one level, different folder
[Code standards](../CODE_STANDARDS.md)         # Up one level
```

---

## Document Status Indicators

Documents include status in their footer:

| Status | Meaning |
|--------|---------|
| Active | Current and maintained |
| Draft | Work in progress |
| Archived | Old information, not updated |
| Deprecated | Use newer version instead |

---

## Maintenance and Updates

### When Documentation Changes
- Docs are organized by topic and audience
- Updates apply to all related cross-references
- Navigation guide updated when new docs added
- Glossary updated when terminology changes

### Adding New Documentation
1. Create file in appropriate folder
2. Add to master index in [README.md](README.md)
3. Add cross-references in related documents
4. Add to this Navigation guide
5. Update Glossary if new terminology

---

## Related Resources

- [Main README](../README.md) - Project overview
- [Project Structure](../wiki/PROJECT_STRUCTURE.md) - Folder organization  
- [Tasks & Planning](../tasks/README.md) - Development tasks
- [Tools Guide](../tools/README.md) - Development tools

---

## Quick Reference Cards

### Most-Used Links

**For Players**
- [Overview](systems/Overview.md)
- [GLOSSARY](GLOSSARY.md)
- [FAQ](../README.md#faq)

**For Developers**
- [Setup (Windows)](../docs/developers/SETUP_WINDOWS.md)
- [Workflow](../docs/developers/WORKFLOW.md)
- [API Reference](api/README.md)

**For Designers**
- [Balance Reference](design/BALANCE_REFERENCE.md)
- [Testing Methodology](design/TESTING_METHODOLOGY.md)
- [System Docs](systems/)

**For Modders**
- [Mod Guide](../mods/README.md)
- [API Reference](api/README.md)
- [Examples](examples/)

---

**Last Updated**: October 2025 | **Navigation Version**: 1.0 | **Status**: Active

