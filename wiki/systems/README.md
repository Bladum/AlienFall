# Game Systems Index

**Audience**: Everyone  
**Last Updated**: October 21, 2025  
**Status**: Complete

---

## Overview

Complete index of all 19 game systems. Each document provides comprehensive explanation of how that system works.

---

## Quick Links

### Strategic Layer (Geoscape)
- **[Geoscape](Geoscape.md)** - Global strategy & world map
- **[Crafts](Crafts.md)** - Spacecraft systems
- **[Interception](Interception.md)** - UFO interception mechanics
- **[Politics](Politics.md)** - Diplomatic systems

### Operational Layer (Basescape)
- **[Basescape](Basescape.md)** - Base management
- **[Economy](Economy.md)** - Resource management
- **[Finance](Finance.md)** - Currency & accounting
- **[Items](Items.md)** - Equipment systems

### Tactical Layer (Battlescape)
- **[Battlescape](Battlescape.md)** - Combat mechanics
- **[Units](Units.md)** - Unit progression
- **[AI Systems](AI%20Systems.md)** - AI behavior

### Meta Systems
- **[Integration](Integration.md)** - How systems connect
- **[Analytics](Analytics.md)** - Metrics & telemetry
- **[Assets](Assets.md)** - Asset management
- **[Gui](Gui.md)** - UI systems
- **[Lore](Lore.md)** - Story & narrative
- **[3D](3D.md)** - 3D rendering systems

### Overview
- **[Overview](Overview.md)** - High-level summary of all systems

---

## System Documentation Status

| System | Type | Status | Lines |
|--------|------|--------|-------|
| Overview | Meta | ✅ Complete | ~700 |
| Geoscape | Strategic | ✅ Complete | 558+ |
| Basescape | Operational | ✅ Complete | 501+ |
| Battlescape | Tactical | ✅ Complete | 2031+ |
| Units | Gameplay | ✅ Complete | 805+ |
| Economy | Systems | ✅ Complete | 528+ |
| Crafts | Strategic | ✅ Complete | - |
| Interception | Strategic | ✅ Complete | - |
| Politics | Strategic | ✅ Complete | - |
| Finance | Systems | ✅ Complete | - |
| Items | Tactical | ✅ Complete | - |
| AI Systems | Meta | ✅ Complete | - |
| Integration | Meta | ✅ Complete | - |
| Analytics | Meta | ✅ Complete | - |
| Assets | Meta | ✅ Complete | - |
| Gui | Meta | ✅ Complete | - |
| Lore | Meta | ✅ Complete | - |
| 3D | Rendering | ✅ Complete | - |

**Summary**: All 19 systems fully documented ✅

---

## How to Navigate

### By Layer

**Strategic Layer (Global Strategy)**
- [Geoscape](Geoscape.md) - Main strategic layer
- [Crafts](Crafts.md) - Spacecraft operations
- [Interception](Interception.md) - Air combat
- [Politics](Politics.md) - Diplomatic relations

**Operational Layer (Base Management)**
- [Basescape](Basescape.md) - Main base system
- [Economy](Economy.md) - Resources & trading
- [Finance](Finance.md) - Currency management
- [Items](Items.md) - Equipment & weapons

**Tactical Layer (Combat)**
- [Battlescape](Battlescape.md) - Main combat system
- [Units](Units.md) - Soldiers & characters
- [AI Systems](AI%20Systems.md) - Enemy behavior

**Meta Systems (Enabling)**
- [Integration](Integration.md) - System interactions
- [Analytics](Analytics.md) - Data tracking
- [Assets](Assets.md) - Content management
- [Gui](Gui.md) - User interface
- [3D](3D.md) - Rendering

### By Audience

**For Players**
1. [Overview](Overview.md) - Game explanation
2. Choose layer above (Strategic, Operational, Tactical)
3. [Glossary](../GLOSSARY.md) - Term definitions

**For Designers**
1. [Overview](Overview.md) - System overview
2. Specific system docs (Geoscape, Basescape, etc.)
3. [Balance Reference](../design/BALANCE_REFERENCE.md)

**For Developers**
1. [Integration](Integration.md) - How systems connect
2. System-specific docs as needed
3. [API Reference](../api/) for interfaces

**For Modders**
1. [Learning Examples](../examples/) - Tutorials
2. System-specific docs to understand mechanics
3. [API Reference](../api/) for available functions

---

## System Relationships

```
GEOSCAPE (Strategic)
├─ Generates missions
├─ Deploys crafts
├─ Manages world state
└─ Triggers Battlescape

BASESCAPE (Operational)
├─ Equips units
├─ Researches tech
├─ Manufactures items
└─ Supports Battlescape

BATTLESCAPE (Tactical)
├─ Executes combat
├─ Generates salvage
├─ Provides unit XP
└─ Reports to Geoscape
```

See [Integration](Integration.md) for detailed relationships.

---

## Documentation Coverage

**19 Systems**: All documented ✅
**Total Content**: 6000+ lines
**Quality**: Comprehensive (overview through detail)
**Examples**: Code samples included
**Cross-References**: All systems linked

---

## Contributing

To improve system documentation:

1. Identify the system doc (find it above)
2. Review [DOCUMENTATION_STANDARD.md](../../docs/DOCUMENTATION_STANDARD.md)
3. Make improvements
4. Submit for review

---

## Related Documentation

- **[API Reference](../api/)** - Function & interface reference
- **[Architecture](../architecture/)** - Design decisions
- **[Examples](../examples/)** - Step-by-step tutorials
- **[Design](../design/)** - Design templates & balance

---

**Last Updated**: October 21, 2025  
**Status**: Complete ✅ (all 19 systems documented)  
**Quality**: Comprehensive
