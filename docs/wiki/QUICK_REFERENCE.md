# AlienFall Documentation Quick Reference

> **Purpose**: Quick navigation guide to all AlienFall documentation  
> **Last Updated**: October 19, 2025

---

## 📋 Core Documentation

### Primary Design Reference
- **`docs/design.md`** - Comprehensive game design document (4,350+ lines)
  - Updated Table of Contents with 6 categories
  - 6 TL;DR boxes for complex systems
  - All game systems fully documented
  - Cross-system integration map at end

### Terminology Reference
- **`docs/TERMINOLOGY_GLOSSARY.md`** - Complete game terminology (650+ lines)
  - 412+ defined terms
  - 14 major categories
  - Searchable via CTRL+F
  - Recommended for onboarding

### Improvement Documentation
- **`docs/DESIGN_IMPROVEMENTS_SUMMARY.md`** - What changed and why (NEW)
  - 6 major improvements documented
  - Before/after comparison
  - Future work recommendations
  - Quality assurance checklist

---

## 🎮 System Overviews

### Strategic Systems
| System | Description | TL;DR Available |
|--------|-------------|-----------------|
| **Geoscape** | Global strategy layer; world map (80×40 hex), missions, diplomacy | In design.md |
| **Basescape** | Base management; 5×5 grid with facilities, research, manufacturing | In design.md |
| **Interception** | Air combat; turn-based craft vs. UFO/base engagement | In design.md |

### Tactical Systems
| System | Description | TL;DR Available |
|--------|-------------|-----------------|
| **Battlescape** | Tactical combat; procedurally-generated hex maps (60-105×60-105 tiles) | ✅ Line 748 |
| **Combat** | Accuracy, damage, cover, morale, status effects | In design.md |
| **AI System** | 4-level hierarchy: Side → Team → Squad → Unit | In design.md |

### Management Systems
| System | Description | TL;DR Available |
|--------|-------------|-----------------|
| **Finance** | Monthly budgeting, income/expenses, deficits, advisor costs | ✅ Line 2069 |
| **Politics & Diplomacy** | Fame, Karma, Relations, Reputation, Advisors | ✅ Line 1688 |
| **Lore & Campaigns** | Story stages, factions, quests, narrative arcs | In design.md |

### Progression Systems
| System | Description | TL;DR Available |
|--------|-------------|-----------------|
| **Game Balance** | Weapon/armor/unit/difficulty scaling, analytics | ✅ Line 256 |
| **Analytics** | Auto-balance, metrics tracking, dynamic scaling | ✅ Line 401 |
| **Unit Progression** | XP, promotion, traits, specializations | In glossary |

### Technical Systems
| System | Description | TL;DR Available |
|--------|-------------|-----------------|
| **Multiplayer** | Asynchronous turns, cloud persistence, leaderboards | ✅ Line 2888 |
| **UI & Widgets** | Scene system, widget framework, responsive design | In design.md |
| **3D Battlescape** | Optional first-person perspective, identical mechanics | In design.md |

---

## 📖 How to Use This Documentation

### For Designers
1. **System Understanding**: Read relevant TL;DR box (marked ✅ above)
2. **Detailed Study**: Read full system section in design.md
3. **Integration Analysis**: Review cross-system integration map (end of design.md)
4. **Terminology**: Check glossary for specific term definitions

### For Developers
1. **Quick Reference**: Check glossary.md for term definitions
2. **Implementation Guide**: Read system section + integration map
3. **Code Points**: Note integration dependencies in cross-system map
4. **Examples**: Check integration examples in cross-system map

### For Testers
1. **System Primer**: Read TL;DR box for quick understanding
2. **Test Coverage**: Review system section for all mechanics
3. **Integration Testing**: Use cross-system map to identify cascades
4. **Bug Communication**: Use glossary terminology in bug reports

### For Modders
1. **System Boundaries**: Review system independence statement
2. **Mod Points**: Check cross-system map for safe integration points
3. **API Reference**: See modding system section in design.md
4. **Terminology**: Use glossary to understand mod capabilities

---

## 🔍 Quick Lookup

### By System Name
| System | Location in design.md | Glossary | Notes |
|--------|----------------------|----------|-------|
| Advisors | Politics section | Yes (8 types) | Detailed cost/benefit table |
| Armor | Game Balance | Yes | Defense points + resistances |
| Base Sizes | Basescape | Yes | 4 tiers: Small-Huge |
| Battlescape | Line 748 | Yes | ✅ TL;DR available |
| Campaigns | Lore section | Yes | 1-3 months, faction-attached |
| Cover | Battlescape | Yes | Light/Medium/Heavy/Full |
| Crafts | Shared Content | Yes | 4 types documented |
| Difficulty | Game Balance | ✅ Line 256 | 4 tiers: Rookie-Impossible |
| Facilities | Basescape | Yes | 11 types documented |
| Finance | Line 2069 | ✅ TL;DR available | Monthly cycle |
| Factions | Lore section | Yes | Lifecycle + relations |
| Fame | Politics | Yes | 5 levels: Unknown-Legendary |
| Game Balance | Line 256 | ✅ TL;DR available | Scaling principles |
| Geoscape | Line 2686 | Yes | 80×40 hex world map |
| Interception | Line 2663 | Yes | Air combat mechanics |
| Karma | Politics | Yes | -1000 to +1000 scale |
| Missions | Geoscape | Yes | 3 types: UFO/Site/Base |
| Multiplayer | Line 2888 | ✅ TL;DR available | Asynchronous turns |
| Politics | Line 1688 | ✅ TL;DR available | Fame/Karma/Relations |
| Quests | Lore section | Yes | 4 types documented |
| Relations | Politics | Yes | -3 to +3 scale |
| Research | Basescape | Yes | Tech tree + complexity |
| Units | Shared Content | Yes | Classes + progression |
| Weapons | Game Balance | Yes | 5+ categories |

### By Acronym
| Acronym | Full Term | Location |
|---------|-----------|----------|
| **AP** | Action Points | Combat/glossary |
| **CDO** | Chief Diplomatic Officer | Advisors/glossary |
| **CFO** | Chief Financial Officer | Advisors/glossary |
| **CIO** | Chief Intelligence Officer | Advisors/glossary |
| **CMO** | Chief Military Officer | Advisors/glossary |
| **COO** | Chief Operations Officer | Advisors/glossary |
| **CRO** | Chief Recruitment Officer | Advisors/glossary |
| **CTO** | Chief Technology Officer | Advisors/glossary |
| **EP** | Energy Points | Combat/glossary |
| **FOW** | Fog of War | Combat/glossary |
| **HP** | Hit Points | Combat/glossary |
| **LOS** | Line of Sight | Combat/glossary |
| **LOF** | Line of Fire | Combat/glossary |
| **MP** | Movement Points | Combat/glossary |
| **NPC** | Non-Player Character | Glossary |
| **RNG** | Random Number Generator | Glossary |
| **UFO** | Unidentified Flying Object | Missions/glossary |
| **XP** | Experience Points | Units/glossary |

---

## 🔗 Cross-System Dependencies

For understanding how systems interact, see **"Cross-System Integration Map"** section near end of design.md:

### Key Integrations to Understand
1. **Victory → Relations → Funding → Research** (Success Spiral)
2. **Defeat → Relations → Funding → Crisis** (Crisis Spiral)
3. **Organization Level → Corruption → Budget Pressure** (Scale Trap)
4. **Research → Manufacturing → Combat → Standing** (Tech Chain)

### Integration Examples (Design.md, end of document)
- **Mission Victory Cascade**: 8-step outcome chain
- **Defeat Cascade**: 8-step consequence chain  
- **Advisor Synergy**: 5-step benefit chain

---

## 📊 Key Numbers & Ranges

### Common Value Ranges
- **Health (HP)**: 20-40 per unit (Soldiers: 30, Heavy: 40, Scouts: 20)
- **Action Points (AP)**: 4 per turn (5 elite)
- **Accuracy Base**: 40-95% → snapped to 5-95%
- **Critical Chance**: 5-10% base
- **Cover Reduction**: Light 20%, Medium 40%, Heavy 60%, Full 99 (blocks)
- **Morale Scale**: 0-100 (Panicked 0-30, Broken 31-49, Cautious 50-79, Confident 80-100)
- **Unit Stats Range**: 6-12 in each stat category

### Time Scales
- **Turn**: 1 day (Geoscape), 10 seconds (Battlescape), 5 minutes (Interception)
- **Week**: 6 days
- **Month**: 30 days (5 weeks)
- **Year**: 360 days (12 months)

### Economic Values
- **Base Maintenance**: 50K per month
- **Unit Maintenance**: 5K per month
- **Craft Maintenance**: 10K per month
- **Mission Reward Range**: 10K-150K (scales with difficulty)

### Organization Level Scale
- **Level 1-5**: 1→8 bases, 2→16 crafts, 16→128 units, 1→5 advisors
- **Corruption Tax**: Level 1: 0%, Level 4: 30%

---

## 🎯 Navigation Tips

### Finding Information Quickly
1. **Want system overview?** → Check TL;DR box (if available) at system start
2. **Need term definition?** → Search glossary.md (CTRL+F)
3. **Confused about acronym?** → Check "Abbreviations & Acronyms" in glossary
4. **Want to understand integration?** → Check cross-system map at end of design.md
5. **Learning the game?** → Read TL;DR boxes, then system sections sequentially

### Search Strategies
- **By System**: "## [System Name]" in design.md
- **By Term**: CTRL+F in glossary.md
- **By Acronym**: See "Abbreviations & Acronyms" section in glossary
- **By Integration**: See "Cross-System Integration Map" at end of design.md

---

## 📝 Documentation Version History

| Document | Created | Updated | Status | Size |
|----------|---------|---------|--------|------|
| design.md | Earlier | Oct 19, 2025 | ✅ Current | 4,350 lines |
| glossary.md | Oct 19, 2025 | Oct 19, 2025 | ✅ NEW | 650 lines |
| improvements_summary.md | Oct 19, 2025 | Oct 19, 2025 | ✅ NEW | 350 lines |
| quick_reference.md | Oct 19, 2025 | Oct 19, 2025 | ✅ YOU ARE HERE | 350 lines |

---

## 🚀 Getting Started

### For First-Time Readers
1. Start here (quick_reference.md) - You're reading it!
2. Read relevant system TL;DR box (marked ✅ above)
3. Read full system section in design.md
4. Check glossary.md for unfamiliar terms
5. Review cross-system integration map

### For Returning Reference
1. Use Table of Contents in design.md to navigate
2. Use "Quick Lookup" section above for fast access
3. Use CTRL+F in glossary.md to search terms
4. Bookmark the sections you use most frequently

### For Questions
1. Check glossary first (most terms defined there)
2. Read TL;DR box for system overview
3. Read detailed system section for specifics
4. Review cross-system map for integration context

---

## ✅ Quality Checklist

This documentation has been verified for:
- ✅ Completeness (all major systems documented)
- ✅ Consistency (terminology standardized across documents)
- ✅ Accuracy (cross-checked between sections)
- ✅ Navigability (ToC, glossary, cross-references)
- ✅ Accessibility (TL;DR boxes, quick lookups)
- ✅ Clarity (professional tone, clear examples)

---

## 📞 Support

For documentation questions or suggestions:
1. Check the relevant system section in design.md
2. Search glossary.md for term definitions
3. Review cross-system integration map for context
4. Refer to DESIGN_IMPROVEMENTS_SUMMARY.md for recent changes

---

**Last Updated**: October 19, 2025  
**Maintained By**: AlienFall Documentation Team  
**Audience**: Designers, Developers, Testers, Modders  
**Status**: ✅ Ready for Distribution
