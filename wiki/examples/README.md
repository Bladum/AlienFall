# Learning Examples Index

**Audience**: Modders, Developers  
**Last Updated**: October 21, 2025  
**Status**: Expanding (stubs created, content pending)

---

## Overview

Step-by-step tutorials for extending AlienFall. Each tutorial walks through adding a new game element from start to finish.

---

## Example Tutorials

### Adding Game Content

**[Adding a Unit Class](ADDING_UNIT_CLASS.md)**
- Create a new unit type
- Set up stats and progression
- Configure abilities
- Test implementation

**Difficulty**: Intermediate  
**Time**: 30-45 minutes

**[Adding a Weapon](ADDING_WEAPON.md)**
- Create a new weapon
- Define stats and effects
- Set up manufacturing
- Balance against existing weapons

**Difficulty**: Intermediate  
**Time**: 30-45 minutes

**[Adding Research](ADDING_RESEARCH.md)**
- Create new research project
- Set up requirements and costs
- Configure unlocks
- Integrate with tech tree

**Difficulty**: Intermediate  
**Time**: 30-45 minutes

### Advanced Topics

**[Adding a Mission](ADDING_MISSION.md)**
- Create mission type
- Set up generation rules
- Configure rewards
- Test difficulty

**Difficulty**: Advanced  
**Time**: 60-90 minutes

**[Adding a UI Element](ADDING_UI.md)**
- Create new UI screen or widget
- Set up layout & styling
- Add interactivity
- Connect to game state

**Difficulty**: Advanced  
**Time**: 60-90 minutes

---

## Quick Reference

| Tutorial | Topic | Difficulty | Time |
|----------|-------|------------|------|
| Adding Unit Class | Unit System | Intermediate | 30-45 min |
| Adding Weapon | Items/Equipment | Intermediate | 30-45 min |
| Adding Research | Economy/Tech | Intermediate | 30-45 min |
| Adding Mission | Geoscape/Missions | Advanced | 60-90 min |
| Adding UI | UI/Widgets | Advanced | 60-90 min |

**Total Examples**: 5 tutorials  
**Coverage**: Most common modding tasks  
**Status**: ⏳ Pending (stubs created, walkthroughs coming)

---

## How to Use Tutorials

### Get Started with Modding
1. Choose a tutorial matching your interest
2. Have the game running with console enabled
3. Follow steps sequentially
4. Test each step before moving forward
5. Troubleshoot using the Troubleshooting section

### Prerequisites
Before starting any tutorial, have:
- ✅ Development environment set up ([setup guide](../../docs/developers/SETUP_WINDOWS.md))
- ✅ Game running with console enabled (`lovec "engine"`)
- ✅ Text editor with Lua support (VS Code recommended)
- ✅ Basic understanding of Lua (optional but helpful)

### After Completing
- Review [API Reference](../api/) to understand available functions
- Create your own custom content
- Share examples with the community

---

## Prerequisite Knowledge

### For All Tutorials
- Basic game navigation
- How to run the game with console
- How to edit text files

### For Content Modding (Units, Weapons, Research)
- Basic Lua syntax
- Table structure basics
- Comment syntax

### For Advanced Topics (Missions, UI)
- Intermediate Lua
- Understanding of game systems
- Familiarity with existing code

---

## Related Resources

### Documentation
- **[Game Systems](../systems/)** - Understand how systems work
- **[API Reference](../api/)** - Available functions and interfaces
- **[Architecture](../architecture/)** - Design decisions
- **[Design Guide](DESIGN_TEMPLATE.md)** - Design process

### Configuration Files
- Look in `engine/assets/data/` for existing content structure
- Use existing items as templates
- Reference configuration schema in system docs

### Code Examples
- Study existing units in data files
- Reference weapon definitions
- Examine research projects
- Review UI implementations

---

## Tutorial Status

All tutorials are scaffolded with:
- ✅ Prerequisites section
- ✅ Step-by-step guide outline
- ✅ Testing procedures outline
- ✅ Troubleshooting outline
- ⏳ Detailed walkthroughs (content pending)

**Next Steps**: Fill in detailed content and test procedures

---

## Contributing Tutorials

Found a gap or want to improve tutorials?

1. Complete tutorial as written
2. Take notes on confusing parts
3. Update tutorial with clarifications
4. Add new examples if useful
5. Submit for review

See [DOCUMENTATION_STANDARD.md](../../docs/DOCUMENTATION_STANDARD.md) for guidelines.

---

## Quick Troubleshooting

**"Game won't load my changes"**
→ Check console for error messages; See Debugging guide in [docs/](../../docs/developers/DEBUGGING.md)

**"Where do I put my new files?"**
→ Check the relevant system documentation; Place files in appropriate engine/ subdirectory

**"How do I test my changes?"**
→ Run `lovec "engine"` and use console to verify; Reference [Testing Methodology](TESTING_METHODOLOGY.md)

**"I need more help"**
→ Review the [API Reference](../api/) for available functions; Check [Game Systems](../systems/) for mechanics

---

## Related Documentation

- **[Game Systems](../systems/)** - How each system works
- **[API Reference](../api/)** - Available functions
- **[Design Guide](../design/)** - Design process
- **[Architecture](../architecture/)** - Design decisions

---

**Last Updated**: October 21, 2025  
**Status**: Stubs complete, walkthroughs pending  
**Completeness**: 0% (structure ready, content pending)

To contribute: See [DOCUMENTATION_STANDARD.md](../../docs/DOCUMENTATION_STANDARD.md)
