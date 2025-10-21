# Design Documentation Index

**Audience**: Game Designers, Balance Team  
**Last Updated**: October 21, 2025  
**Status**: Expanding (template complete, others pending)

---

## Overview

Design documentation, templates, and specifications for AlienFall game development.

---

## Design Resources

### Templates & Processes

**[Design Template](DESIGN_TEMPLATE.md)**
- Process for designing new features
- Design document structure
- How to approach design

**Status**: ✅ Complete

### Balance & Parameters

**[Balance Reference](BALANCE_REFERENCE.md)**
- All game balance parameters
- Tuning values by system
- Economic formulas

**Status**: ⏳ Pending (content needed)

### Testing & Verification

**[Testing Methodology](TESTING_METHODOLOGY.md)**
- How to test game mechanics
- Balance testing procedures
- Playtesting protocols

**Status**: ⏳ Pending (content needed)

### Quick Reference

**[Designer Quick Reference](DESIGNER_QUICKREF.md)**
- One-page quick reference
- Common tasks
- Quick links to resources

**Status**: ⏳ Pending (content needed)

---

## Quick Reference Table

| Resource | Purpose | Status |
|----------|---------|--------|
| Design Template | Design process | ✅ Ready |
| Balance Reference | Game parameters | ⏳ Pending |
| Testing Methodology | Testing procedures | ⏳ Pending |
| Designer Quick Ref | One-page cheat sheet | ⏳ Pending |

**Overall Completion**: 25% (1 of 4 docs)

---

## How to Use

### Starting a New Design
1. Use [Design Template](DESIGN_TEMPLATE.md)
2. Reference [Game Systems](../systems/) for mechanics
3. Check [Balance Reference](BALANCE_REFERENCE.md) for current values
4. Document your design in template

### Testing Your Design
1. Review [Testing Methodology](TESTING_METHODOLOGY.md)
2. Set up test environment
3. Execute test procedures
4. Document results

### Quick Reference
1. Check [Designer Quick Reference](DESIGNER_QUICKREF.md)
2. Find relevant system in [Game Systems](../systems/)
3. Use [API Reference](../api/) if implementing

---

## Game Design Principles

From system documentation, key design principles:

1. **Turn-Based**: All systems are turn-based (no real-time)
2. **Deterministic**: Outcomes derive from rules (not random)
3. **Meaningful Choices**: Player decisions have consequences
4. **Multiple Playstyles**: Many valid approaches exist
5. **Resource Scarcity**: Tension from limited resources
6. **Progression**: Systems support long-term advancement

See [Overview](../systems/Overview.md) for detailed principles.

---

## Balance Considerations

Key balance areas (from system documentation):

**Geoscape Balance**
- Monthly funding levels (0-10 scale)
- Mission difficulty scaling
- Craft performance parameters
- Diplomatic relation impacts

**Basescape Balance**
- Base construction costs & times
- Facility service generation
- Research timelines
- Manufacturing costs

**Battlescape Balance**
- Unit accuracy ranges (5-95% clamped)
- Weapon damage values
- Unit movement & AP costs
- Armor effectiveness

**Economy Balance**
- Income sources & amounts
- Expense scaling
- Technology cost multipliers
- Manufacturing profit margins

See [Balance Reference](BALANCE_REFERENCE.md) for all values (when completed).

---

## Contributing

Want to help complete design documentation?

1. **Balance Reference**: Extract balance values from code/systems
2. **Testing Methodology**: Document how you test mechanics
3. **Designer Quick Ref**: Summarize common tasks and links

Review [DOCUMENTATION_STANDARD.md](../../docs/DOCUMENTATION_STANDARD.md) first.

---

## Related Documentation

- **[Game Systems](../systems/)** - Detailed mechanics
- **[API Reference](../api/)** - Implementation interfaces
- **[Examples](../examples/)** - Step-by-step tutorials
- **[Architecture](../architecture/)** - Design decisions

---

**Last Updated**: October 21, 2025  
**Status**: Template complete, others expanding  
**Completeness**: 25% (1/4 docs)
