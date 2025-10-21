# API Reference Index

**Audience**: Developers, Modders  
**Last Updated**: October 21, 2025  
**Status**: Expanding (stubs created, content pending)

---

## Overview

Complete API reference for AlienFall systems. Use these documents to understand the available interfaces for extending the game.

---

## API Documentation

### Core Systems

**[Core API](CORE.md)**
- Main engine functions
- Lifecycle management
- System initialization
- Game state management

**Status**: ✅ Available

### Strategic Layer

**[Geoscape API](GEOSCAPE.md)**
- World map functions
- Craft management
- Mission generation
- Strategic decision making

**Status**: ✅ Available

### Operational Layer

**[Basescape API](BASESCAPE.md)**
- Base management
- Facility operations
- Unit recruitment
- Research & manufacturing

**Status**: ⏳ Pending (stub created)

### Tactical Layer

**[Battlescape API](BATTLESCAPE.md)**
- Combat mechanics
- Unit actions
- Map generation
- Combat resolution

**Status**: ⏳ Pending (stub created)

### Gameplay Systems

**[Units API](UNITS.md)**
- Unit creation & management
- Experience & progression
- Equipment & inventory
- Unit statistics

**Status**: ⏳ Pending (stub created)

**[Economy API](ECONOMY.md)**
- Resource management
- Research system
- Manufacturing
- Marketplace

**Status**: ⏳ Pending (stub created)

### Architecture

**[Architecture API](ARCHITECTURE.md)**
- Core architecture patterns
- System integration
- Component interactions
- Extension points

**Status**: ⏳ Pending (stub created)

---

## Quick Reference Table

| API | Coverage | Status | Purpose |
|-----|----------|--------|---------|
| Core | 100% | ✅ Ready | Engine & lifecycle |
| Geoscape | 100% | ✅ Ready | Strategic layer |
| Basescape | 0% | ⏳ Pending | Base management |
| Battlescape | 0% | ⏳ Pending | Tactical combat |
| Units | 0% | ⏳ Pending | Unit system |
| Economy | 0% | ⏳ Pending | Resources & economy |
| Architecture | 0% | ⏳ Pending | Core patterns |

**Overall**: 28% coverage (2 of 7 APIs)

---

## How to Use

### For Getting Started
1. Read [Core API](CORE.md) first - understand the game engine
2. Read [Geoscape API](GEOSCAPE.md) - understand strategic layer
3. Then system-specific APIs for your use case

### For Modding
1. Review [Architecture API](ARCHITECTURE.md) - understand patterns
2. Use system-specific APIs for your mod scope
3. Refer to [examples/](../examples/) for step-by-step tutorials

### For Contributing
1. Check which APIs need content ([Status](#quick-reference-table) section)
2. Review [DOCUMENTATION_STANDARD.md](../../docs/DOCUMENTATION_STANDARD.md)
3. Create/update the API doc following examples

---

## Contributing Documentation

Want to help complete the API reference?

1. Choose an unfinished API (status = ⏳ Pending)
2. Review the corresponding system doc
3. Document function signatures, parameters, return values, and examples
4. Reference the system documentation in your API doc
5. Submit for review

See [DOCUMENTATION_STANDARD.md](../../docs/DOCUMENTATION_STANDARD.md) for documentation standards.

---

## Related Documentation

- **[Game Systems](../systems/)** - Detailed mechanics documentation
- **[Architecture Decisions](../architecture/)** - Design reasoning
- **[Learning Examples](../examples/)** - Implementation tutorials
- **[Development Tools](../../docs/)** - Developer workflow

---

**Last Updated**: October 21, 2025  
**Status**: Stubs complete, content in progress  
**Completeness**: 28% (2/7 APIs)
