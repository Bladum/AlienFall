# AlienFall Game Design Documentation

**Welcome to the game design documentation hub.**

This folder contains all documentation about how the game works: game systems, mechanics, balance, API reference, architecture decisions, and learning examples.

---

## Quick Navigation

### For Players & Designers
- **[Overview](systems/Overview.md)** - Complete game overview
- **[Game Systems](systems/)** - All 19 game systems
- **[Glossary](GLOSSARY.md)** - Game terminology

### For Developers & Modders
- **[API Reference](api/)** - Complete API documentation
- **[Architecture Decisions](architecture/)** - Design decisions (ADRs)
- **[Learning Examples](examples/)** - Step-by-step tutorials

### For Designers & Balance Team
- **[Design Templates](design/DESIGN_TEMPLATE.md)** - How to design features
- **[Balance Reference](design/BALANCE_REFERENCE.md)** - Game balance parameters
- **[Testing Methodology](design/TESTING_METHODOLOGY.md)** - How to test mechanics

---

## Documentation Map

### Game Systems (19 documents)

All major game systems are documented in detail. See [systems/](systems/README.md) for complete index.

Key systems:
- [Geoscape](systems/Geoscape.md) - Strategic layer
- [Basescape](systems/Basescape.md) - Base management
- [Battlescape](systems/Battlescape.md) - Tactical combat
- [Units](systems/Units.md) - Unit progression
- [Economy](systems/Economy.md) - Resource management

### API Reference (7 documents)

Comprehensive API documentation for developers and modders. See [api/](api/README.md) for complete index.

Available APIs:
- [Core API](api/CORE.md) - Core engine APIs
- [Geoscape API](api/GEOSCAPE.md) - Strategic layer APIs
- [Basescape API](api/BASESCAPE.md) - Base management APIs
- [Battlescape API](api/BATTLESCAPE.md) - Tactical combat APIs
- [Units API](api/UNITS.md) - Unit system APIs
- [Economy API](api/ECONOMY.md) - Resource system APIs
- [Architecture API](api/ARCHITECTURE.md) - Core architecture

### Architecture Decisions (5 documents)

Design decisions explaining why key architectural choices were made. See [architecture/](architecture/README.md) for complete index.

- [ADR-001: Hexagonal Grid](architecture/ADR-001-HEXGRID.md)
- [ADR-002: Turn-Based vs Real-Time](architecture/ADR-002-TURNBASED.md)
- [ADR-003: Module Separation](architecture/ADR-003-MODULES.md)
- [ADR-004: Data Persistence](architecture/ADR-004-PERSISTENCE.md)
- [ADR-005: AI Architecture](architecture/ADR-005-AI.md)

### Design Documentation (4 documents)

Design tools, templates, and specifications. See [design/](design/README.md) for complete index.

- [Design Template](design/DESIGN_TEMPLATE.md) - Template for designing features
- [Balance Reference](design/BALANCE_REFERENCE.md) - All balance parameters
- [Testing Methodology](design/TESTING_METHODOLOGY.md) - How to test mechanics
- [Designer Quick Reference](design/DESIGNER_QUICKREF.md) - One-page quick ref

### Learning Examples (5 tutorials)

Step-by-step tutorials for extending the game. See [examples/](examples/README.md) for complete index.

- [Adding a Unit Class](examples/ADDING_UNIT_CLASS.md)
- [Adding a Weapon](examples/ADDING_WEAPON.md)
- [Adding Research](examples/ADDING_RESEARCH.md)
- [Adding a Mission](examples/ADDING_MISSION.md)
- [Adding a UI Element](examples/ADDING_UI.md)

---

## For Different Audiences

### 👾 Players Learning the Game
1. Start: [Overview](systems/Overview.md)
2. Explore: [Game Systems](systems/)
3. Reference: [Glossary](GLOSSARY.md)

### 👨‍💻 Developers
1. Start: [API Reference](api/)
2. Architecture: [Design Decisions](architecture/)
3. Code: [Back to docs/](../docs/)

### 🎮 Game Designers
1. Start: [Design Template](design/DESIGN_TEMPLATE.md)
2. Learn: [Game Systems](systems/)
3. Balance: [Balance Reference](design/BALANCE_REFERENCE.md)
4. Test: [Testing Methodology](design/TESTING_METHODOLOGY.md)

### 🔧 Modders
1. Start: [Learning Examples](examples/)
2. Reference: [API Reference](api/)
3. Design: [Design System](design/DESIGN_TEMPLATE.md)

---

## Navigation Guide

**Complete documentation map**: See [NAVIGATION.md](NAVIGATION.md)

**Developer tools**: See [../docs/](../docs/)

**Glossary**: See [GLOSSARY.md](GLOSSARY.md)

---

## Contents Summary

| Folder | Files | Purpose |
|--------|-------|---------|
| `systems/` | 19 | Game system documentation |
| `api/` | 7 | API reference |
| `architecture/` | 5 | Architecture decisions |
| `design/` | 4 | Design tools & templates |
| `examples/` | 5 | Learning tutorials |

**Total**: 40+ game design documents

---

## Contributing

**To add documentation**: See [../docs/DOCUMENTATION_STANDARD.md](../docs/DOCUMENTATION_STANDARD.md)

**To report issues**: Create an issue referencing the file path

**To suggest improvements**: Create a pull request

---

## Related Resources

- **Developer Tools**: [../docs/](../docs/) - Setup, workflow, code standards
- **Project Management**: [../tasks/](../tasks/) - Task tracking and planning
- **Tests**: [../tests/](../tests/) - Automated tests and test documentation
- **Tools**: [../tools/](../tools/) - Development tools

---

**Last Updated**: October 21, 2025  
**Status**: Active - Stubs complete, content pending  
**Version**: 1.0
