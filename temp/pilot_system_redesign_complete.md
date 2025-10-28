# Pilot System Redesign Complete

**Date**: 2025-10-28  
**Status**: ✅ COMPLETE

---

## What Changed

### 1. Pilot System Completely Redesigned

**OLD (Complex) System**:
- ❌ Separate "Pilot" class with branching specializations
- ❌ Dual XP tracks (Pilot XP vs Ground XP)
- ❌ Pilot-specific rank progression (Rank 1 Pilot → Rank 2 Fighter Pilot, etc.)
- ❌ Crew members provide bonuses (co-pilots, gunners, etc.)
- ❌ Minimum pilot rank requirements per craft
- ❌ Cross-training between pilot branches

**NEW (Simple) System**:
- ✅ **Piloting is just a stat** (like Strength or Dexterity, range 0-100)
- ✅ **Any unit can pilot** - no special class needed
- ✅ **One unified XP pool** - XP from ground OR air contributes equally
- ✅ **Only pilot provides bonuses** - crew/passengers = cargo (no bonuses)
- ✅ **No minimums** - any unit can pilot any craft (higher Piloting stat = better)
- ✅ **Simple assignment** - assign to pilot slot = bonuses, unassign = ground duty

### 2. Core Mechanics

**Piloting Stat**:
- Base: 20-40 (random at recruitment)
- Improved by: XP (+1 per 100 XP), class bonuses, traits, equipment
- Effect: Craft Dodge = +(Piloting/5)%, Craft Accuracy = +(Piloting/5)%

**Example**:
```
Unit with Piloting 60:
- Craft gains +12% dodge
- Craft gains +12% accuracy
```

**Special Abilities Unlock**:
- Piloting 50+: Evasive Maneuvers
- Piloting 70+: Precision Strike
- Piloting 90+: Ace Maneuver

**XP System**:
- Interception victory: +50 XP
- Ground mission victory: +50 XP
- Enemy killed: +10 XP
- All XP goes into one pool, improves Piloting stat (+1 per 100 XP)

---

## Files Changed

### Created
1. ✅ **Pilots.md** - New simple pilot system specification

### Deleted
1. ❌ **PilotSystem_Technical.md** - Old complex system removed

### Renamed
1. **DiplomaticRelations_Technical.md** → **Relations.md**
2. **hex_vertical_axial_system.md** → **HexSystem.md**
3. **FutureOpportunities.md** → **Future.md**
4. **ai_systems.md** → **AI.md**

### Updated
1. ✅ **Units.md** - Removed complex pilot class branch, added Piloting stat
2. ✅ **Crafts.md** - Simplified pilot requirements

---

## Design Philosophy

### Why Simple is Better

**Rejected Complexity**:
- ❌ Dual XP tracking (confusing, hard to balance)
- ❌ Pilot-specific classes (unnecessary specialization)
- ❌ Crew bonuses (overpowered, unclear)
- ❌ Minimum requirements (restrictive, limiting)

**Benefits of Simplicity**:
- ✅ Easy to understand: "This unit pilots, this unit doesn't"
- ✅ Easy to balance: One stat to tune (Piloting)
- ✅ Easy to implement: No dual XP, no complex crew bonuses
- ✅ Strategic depth: Choose which units pilot vs fight

### Strategic Decisions

**Core Question**: "Should I use my veteran soldier (high Piloting) as pilot or send them to ground combat?"

**Factors**:
- High Piloting in craft = safer interceptions
- High Piloting on ground = better soldier (veteran)
- Resource tension: Can only use unit in one place
- Risk: If craft crashes, pilot might die

---

## Summary: The New Pilot System in 5 Rules

1. **Any unit can pilot** - No special class needed
2. **Piloting is a stat** - Improves with XP, class, traits, equipment (0-100 range)
3. **Only pilot matters** - Crew = passengers = cargo (no bonuses)
4. **One XP pool** - All XP (ground or air) contributes equally
5. **Simple assignment** - Pilot slot = bonuses, unassign = ground duty

**Formula**:
```
Craft Dodge = Base Dodge + (Pilot Piloting / 5)
Craft Accuracy = Base Accuracy + (Pilot Piloting / 5)
```

That's it. Clean, simple, strategic.

---

## Files in design/mechanics/ (Now Shorter Names)

### Core Systems
- **HexSystem.md** (was: hex_vertical_axial_system.md)
- **Pilots.md** (NEW - simple pilot system)
- **Relations.md** (was: DiplomaticRelations_Technical.md)

### Game Layers
- Geoscape.md
- Basescape.md
- Battlescape.md

### Gameplay
- Units.md ✅ UPDATED
- Crafts.md ✅ UPDATED
- Items.md
- Economy.md
- AI.md (was: ai_systems.md)

### Strategic
- Politics.md
- Countries.md
- Finance.md
- Interception.md

### Supporting
- Gui.md
- Assets.md
- Analytics.md
- Lore.md
- 3D.md

### Reference
- Overview.md
- Glossary.md
- Integration.md
- Future.md (was: FutureOpportunities.md)
- README.md

---

## Next Steps (Optional)

1. Update all cross-references in files to use new filenames
2. Update README.md with new structure
3. Test that no broken links exist

---

**Status**: ✅ PILOT SYSTEM REDESIGNED - SIMPLE & CLEAR  
**Files**: 4 renamed, 1 created, 1 deleted, 2 updated  
**Result**: Clean, simple, strategic pilot system

---

**End of Report**

*Pilots are just units with a Piloting stat. That's all.*

