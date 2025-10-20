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
| **3D Rendering** | [3D.md](systems/3D.md) | [api/CORE.md](api/CORE.md) | - |
| **AI Systems** | [AI Systems.md](systems/AI%20Systems.md) | [api/CORE.md](api/CORE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Analytics** | [Analytics.md](systems/Analytics.md) | [api/CORE.md](api/CORE.md) | - |
| **Assets** | [Assets.md](systems/Assets.md) | [api/CORE.md](api/CORE.md) | - |
| **Base Management** | [Basescape.md](systems/Basescape.md) | [api/BASESCAPE.md](api/BASESCAPE.md) | [examples/ADDING_RESEARCH.md](examples/ADDING_RESEARCH.md) |
| **Tactical Combat** | [Battlescape.md](systems/Battlescape.md) | [api/BATTLESCAPE.md](api/BATTLESCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Aircraft** | [Crafts.md](systems/Crafts.md) | [api/GEOSCAPE.md](api/GEOSCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Economy** | [Economy.md](systems/Economy.md) | [api/CORE.md](api/CORE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Finance** | [Finance.md](systems/Finance.md) | [api/CORE.md](api/CORE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Strategy Layer** | [Geoscape.md](systems/Geoscape.md) | [api/GEOSCAPE.md](api/GEOSCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **System Integration** | [Integration.md](systems/Integration.md) | [architecture/SYSTEM_INTERACTION.md](architecture/SYSTEM_INTERACTION.md) | - |
| **Air Combat** | [Interception.md](systems/Interception.md) | [api/GEOSCAPE.md](api/GEOSCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Equipment** | [Items.md](systems/Items.md) | [api/BATTLESCAPE.md](api/BATTLESCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Story & Lore** | [Lore.md](systems/Lore.md) | [api/CORE.md](api/CORE.md) | - |
| **Politics** | [Politics.md](systems/Politics.md) | [api/GEOSCAPE.md](api/GEOSCAPE.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **Characters & Units** | [Units.md](systems/Units.md) | [api/UNITS.md](api/UNITS.md) | [design/BALANCE_REFERENCE.md](design/BALANCE_REFERENCE.md) |
| **UI Systems** | [Gui.md](systems/Gui.md) | [api/CORE.md](api/CORE.md) | - |

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
├── CORE.md ................... Main engine & lifecycle
├── GEOSCAPE.md ............... Strategic layer APIs
├── BASESCAPE.md .............. Base management APIs
├── BATTLESCAPE.md ............ Tactical combat APIs
└── UNITS.md .................. Unit system APIs
```

### Architecture Documentation

```
architecture/
├── README.md ................. Index of ADRs
├── SYSTEM_INTERACTION.md ..... System flow diagrams
├── DATA_FLOW.md .............. Data movement patterns
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
├── DESIGN_TEMPLATE.md ........ Template for all designs
├── BALANCE_REFERENCE.md ...... Balance parameters
├── TESTING_METHODOLOGY.md .... How to test mechanics
└── DESIGNER_QUICKREF.md ...... One-page cheat sheet
```

### Core Reference

```
docs/
├── README.md ................. Documentation hub (START HERE)
├── DOCUMENTATION_STANDARD.md . Standards & conventions
├── NAVIGATION.md ............. This file
├── CODE_STANDARDS.md ......... Code style & naming
├── COMMENT_STANDARDS.md ...... Comment conventions
├── PERFORMANCE.md ............ Performance & optimization
├── Glossary.md ............... Game terminology
└── DOCUMENTATION_STANDARD.md . Style & format rules
```

---

## Cross-Reference Map by Topic

### Geoscape (Strategic Layer)

**Mechanics Overview**: [Geoscape.md](systems/Geoscape.md)
**API Reference**: [api/GEOSCAPE.md](api/GEOSCAPE.md)
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
3. [Project Structure](../wiki/PROJECT_STRUCTURE.md) - Where things are
4. [Code Standards](CODE_STANDARDS.md) - How to code
5. [System Architecture](architecture/SYSTEM_INTERACTION.md) - How systems fit together
6. [Debugging Guide](developers/DEBUGGING.md) - How to debug
7. Relevant API docs for your task

### Game Designers
1. [Design Template](design/DESIGN_TEMPLATE.md) - For planning features
2. [Balance Reference](design/BALANCE_REFERENCE.md) - Current parameters
3. System mechanics docs: [Geoscape](systems/Geoscape.md), [Basescape](systems/Basescape.md), [Battlescape](systems/Battlescape.md)
4. [Testing Methodology](design/TESTING_METHODOLOGY.md) - How to verify balance
5. [Designer Quick Reference](design/DESIGNER_QUICKREF.md) - Cheat sheet

### Modders
1. [Mod Creation Guide](../mods/README.md) - Get started
2. [API Reference](api/CORE.md) - What you can use
3. [Code Standards](CODE_STANDARDS.md) - Conventions
4. System docs as needed
5. [Design System](design/DESIGN_TEMPLATE.md) - How customization works

---

## Dependency Graph

```
Documentation Hub (README.md)
├── Audience Paths
│   ├── Players → Overview → Glossary → System Docs
│   ├── Developers → Setup → Workflow → Code Standards → API Docs
│   ├── Designers → Design Template → Balance Reference → System Docs
│   └── Modders → Mod Guide → API Reference
├── System Docs (Geoscape, Basescape, Battlescape, etc.)
│   └── Link to: API Docs, Architecture, Balance Params
├── Developer Docs
│   ├── Setup → Workflow → Debugging
│   ├── Code Standards → Comment Standards
│   └── Project Structure
├── API Docs
│   ├── Core → State Management
│   ├── Geoscape → Interception, Crafts
│   ├── Basescape → Items, Research
│   └── Battlescape → Units, Combat
├── Architecture
│   ├── System Interaction → All systems
│   ├── Data Flow → All systems
│   └── ADRs → Design decisions
├── Examples
│   ├── Adding Unit → Units API
│   ├── Adding Weapon → Battlescape API
│   ├── Adding Research → Basescape API
│   ├── Adding Mission → Geoscape API
│   └── Adding UI → Core API
└── Design Docs
    ├── Template → Design process
    ├── Balance Reference → System docs
    └── Methodology → Testing
```

---

## Search Tips

**Looking for something specific?**

| If you want to find... | Look here... |
|----------------------|-------------|
| A game mechanic | System docs (Geoscape.md, etc.) or Glossary |
| An API function | api/CORE.md, api/GEOSCAPE.md, etc. |
| How to do something | examples/ folder or relevant API docs |
| A design decision | architecture/ folder (ADRs) |
| Balance parameters | design/BALANCE_REFERENCE.md |
| A term definition | Glossary.md |
| Setup help | developers/SETUP_*.md |
| Troubleshooting | developers/TROUBLESHOOTING.md |
| Code style rules | CODE_STANDARDS.md or COMMENT_STANDARDS.md |
| How to write docs | DOCUMENTATION_STANDARD.md |

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
- [Overview](Overview.md)
- [Glossary](Glossary.md)
- [FAQ](../README.md#faq)

**For Developers**
- [Setup (Windows)](developers/SETUP_WINDOWS.md)
- [Workflow](developers/WORKFLOW.md)
- [API Reference](api/CORE.md)

**For Designers**
- [Design Template](design/DESIGN_TEMPLATE.md)
- [Balance Reference](design/BALANCE_REFERENCE.md)
- [System Docs](Geoscape.md)

**For Modders**
- [Mod Guide](../mods/README.md)
- [API Reference](api/CORE.md)
- [Examples](examples/)

---

**Last Updated**: October 2025 | **Navigation Version**: 1.0 | **Status**: Active

