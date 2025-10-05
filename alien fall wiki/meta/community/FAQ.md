# Frequently Asked Questions (FAQ)

**Tags:** #faq #community #help  
**Last Updated:** September 30, 2025

---

## General Questions

### What is Alien Fall?
Alien Fall is an open-source, X

COM-inspired turn-based strategy game built with Love2D and Lua. It combines strategic world management with tactical combat, featuring deterministic gameplay, extensive modding support, and pixel art aesthetics.

### What platforms does it support?
Love2D runs on Windows, macOS, and Linux. The game is developed and tested primarily on Windows but should work on all platforms.

### Is it really free?
Yes! Alien Fall is released under GPL-3.0 license. It's completely free to play, modify, and distribute.

### How can I support the project?
- Contribute code or documentation
- Create and share mods
- Report bugs
- Spread the word
- Donate (if option available)

---

## Gameplay Questions

### How do I start playing?
See the [[../tutorials/QuickStart_Guide]] for a complete introduction.

### What's the goal of the game?
Defend Earth from alien invasion by managing bases, researching technology, and commanding tactical missions.

### How long is a campaign?
A typical campaign lasts 60-90 in-game months (10-20 hours of gameplay) depending on difficulty and playstyle.

### Can I save anytime?
Yes, you can save during the geoscape (strategic layer). Tactical missions use autosaves at turn start.

### What difficulty should I choose?
- **Easy**: Forgiving, learn mechanics
- **Normal**: Balanced challenge
- **Hard**: For experienced players
- **Impossible**: Extreme challenge

---

## Technical Questions

### System Requirements?
**Minimum:**
- OS: Windows 7+, macOS 10.12+, Linux
- CPU: 2 GHz dual-core
- RAM: 2 GB
- Storage: 500 MB
- Graphics: OpenGL 2.1 support

**Recommended:**
- CPU: 3 GHz quad-core
- RAM: 4 GB
- SSD storage
- Dedicated GPU

### The game won't start!
1. Ensure Love2D 11.5 is installed
2. Check console for error messages (`lovec.exe` instead of `love.exe`)
3. Verify all files extracted correctly
4. Check [[../community/Known_Issues]]

### How do I report bugs?
1. Check [[../community/Known_Issues]] first
2. Create GitHub issue with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Save file (if applicable)
   - Console logs

### Performance issues?
- Lower resolution in settings
- Disable visual effects
- Update graphics drivers
- Close background applications
- Check for mods causing issues

---

## Modding Questions

### How do I install mods?
1. Download mod folder
2. Place in `/mods/` directory
3. Enable in mod manager (in-game)
4. Restart game

### How do I create mods?
See [[../../mods/Getting_Started]] for complete tutorial.

### Can mods break my save?
Yes, some mods may be incompatible with existing saves. Always backup saves before adding mods.

### Where do I find mods?
- GitHub releases page
- Community forums
- Discord mod channel

### My mod isn't loading!
1. Check `manifest.toml` syntax
2. Verify mod structure matches template
3. Check console for error messages
4. Ensure no mod conflicts

---

## Strategy Questions

### Best starting research?
1. Alien Materials (unlocks everything)
2. Laser Weapons (improved combat)
3. Advanced Armor (soldier survivability)

### How many bases should I build?
Start with 1, expand to 3-4 bases for global coverage.

### Best soldier build?
- Balanced squads: 2 assault, 2 support, 2 snipers
- Early game: Focus on assault rifles
- Late game: Specialize roles

### How do I deal with Chryssalids?
- Keep distance, use overwatch
- Bring explosives
- Focus fire to eliminate quickly
- Never let them reach melee range

### Economy tips?
- Sell alien corpses and tech early
- Build workshops for manufacturing
- Don't over-expand bases
- Balance research with practical needs

---

## Content Questions

### How many missions are there?
Procedurally generated missions provide infinite variety. Story missions: 10-15 critical path.

### How many enemy types?
Currently: 15+ alien types with variants. More planned!

### Can I recruit more soldiers?
Yes, hire from barracks (costs money) or receive from council rewards.

### What happens if I lose?
Mission failure: Lose soldiers/equipment, increase panic. Lose game: Global panic reaches 100% or all bases destroyed.

### Is there multiplayer?
Not currently. Future consideration for hot-seat tactical mode.

---

## Development Questions

### What's the current status?
Active development. Core systems complete, content expansion ongoing. See [[../community/Roadmap]].

### When is the next release?
Check [[../community/Roadmap]] for planned milestones.

### Can I contribute?
Yes! See [[../community/Contributing_Guidelines]].

### What language is it written in?
Lua (game logic) with Love2D framework (C++ engine).

### Why Lua/Love2D?
- Easy to learn and mod
- Cross-platform
- Great 2D performance
- Active community

---

## Troubleshooting

### Black screen on startup
- Update graphics drivers
- Try running with `lovec.exe` (console version)
- Check OpenGL support

### Crashes during missions
- Update to latest version
- Disable mods
- Check save file isn't corrupted
- Report with error logs

### Save won't load
- Version incompatibility (update game)
- Mod conflicts (disable mods)
- Corrupted save (restore backup)

### Mouse input not working
- Check resolution scaling
- Verify window mode settings
- Restart game

---

## Still Have Questions?

- Check other documentation: [[../tutorials/]], [[../../geoscape/]], [[../../battlescape/]]
- Ask on GitHub Discussions
- Join Discord community
- Read source code (it's open source!)

---

**Last Updated:** September 30, 2025  
**Maintainer:** Community Team
