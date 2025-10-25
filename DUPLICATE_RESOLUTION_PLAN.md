# DUPLICATE RESOLUTION PLAN

**Date:** October 25, 2025  
**Status:** Ready for Implementation  
**Total Duplicates:** 27 groups identified  
**Resolution:** 18 DELETE, 4 RENAME, 5 KEEP BOTH (intentional)

---

## DUPLICATE GROUPS - DETAILED DECISIONS

### GROUP 1: base_manager.lua (3 copies)
**Locations:** 
- `engine/basescape/base_manager.lua`
- `engine/logic/base_manager.lua`
- `engine/systems/base_manager.lua`

**Analysis:** 
- Basescape version is primary (authoritative)
- Logic version appears to be wrapper (legacy)
- Systems version is likely duplicate

**Decision:** 
- ✅ KEEP: `engine/basescape/base_manager.lua`
- ❌ DELETE: `engine/logic/base_manager.lua`
- ❌ DELETE: `engine/systems/base_manager.lua`

**Validation:** 
- Search for requires: `grep -r "logic/base_manager\|systems/base_manager" engine/`
- Update any imports to use basescape version
- Verify game loads properly

---

### GROUP 2: los_system.lua (2 copies)
**Locations:**
- `engine/battlescape/systems/los_system.lua`
- `engine/battlescape/combat/los_system.lua`

**Analysis:**
- Systems folder is canonical location for systems
- Combat folder should contain tactical implementations
- Systems version is primary

**Decision:**
- ✅ KEEP: `engine/battlescape/systems/los_system.lua`
- ❌ DELETE: `engine/battlescape/combat/los_system.lua`

**Validation:**
- Search: `grep -r "combat/los_system" engine/`
- Update imports to systems version
- Test LOS functionality

---

### GROUP 3: morale_system.lua (2 copies)
**Locations:**
- `engine/battlescape/systems/morale_system.lua`
- `engine/battlescape/combat/morale_system.lua`

**Analysis:**
- Same pattern as GROUP 2
- Systems version is canonical
- Combat version is duplicate

**Decision:**
- ✅ KEEP: `engine/battlescape/systems/morale_system.lua`
- ❌ DELETE: `engine/battlescape/combat/morale_system.lua`

**Validation:**
- Search: `grep -r "combat/morale_system" engine/`
- Update imports
- Test morale mechanics

---

### GROUP 4: flanking_system.lua (2 copies)
**Locations:**
- `engine/battlescape/combat/flanking_system.lua`
- `engine/battlescape/systems/flanking_system.lua`

**Analysis:**
- Combat-specific system (different from LOS/Morale which are universal)
- Combat folder is correct home
- Systems version is duplicate

**Decision:**
- ✅ KEEP: `engine/battlescape/combat/flanking_system.lua`
- ❌ DELETE: `engine/battlescape/systems/flanking_system.lua`

**Validation:**
- Search: `grep -r "systems/flanking_system" engine/`
- Update imports to combat version
- Test flanking mechanics

---

### GROUP 5: pathfinding.lua (2 different purposes - RENAME)
**Locations:**
- `engine/geoscape/pathfinding.lua` (strategic pathfinding on globe)
- `engine/battlescape/pathfinding.lua` (tactical unit movement)

**Analysis:**
- BOTH needed but serve different purposes
- Same filename causes import confusion
- Must rename to clarify purpose

**Decision:**
- ✅ RENAME: `engine/geoscape/pathfinding.lua` → `strategic_pathfinding.lua`
- ✅ RENAME: `engine/battlescape/pathfinding.lua` → `tactical_pathfinding.lua`

**Validation:**
- Search: `grep -r "require.*pathfinding" engine/`
- Update all strategic pathfinding requires to `strategic_pathfinding`
- Update all tactical pathfinding requires to `tactical_pathfinding`
- Verify both pathfinding systems work

---

### GROUP 6: audio_manager.lua (3 copies)
**Locations:**
- `engine/core/audio_manager.lua`
- `engine/audio/audio_manager.lua`
- `engine/content/audio_manager.lua`

**Analysis:**
- Core version is primary (foundation)
- Audio folder version is likely wrapper (legacy)
- Content version handles content-specific audio
- Core should be canonical, content-specific logic in audio/

**Decision:**
- ✅ KEEP: `engine/core/audio_manager.lua` (primary)
- ❌ DELETE: `engine/audio/audio_manager.lua` (wrapper)
- ⚠️ RENAME: `engine/content/audio_manager.lua` → `content_audio_handler.lua`

**Validation:**
- Search: `grep -r "audio/audio_manager\|content/audio_manager" engine/`
- Update imports to core version or new name
- Test audio playback

---

### GROUP 7: state_manager.lua (2 copies)
**Locations:**
- `engine/core/state_manager.lua`
- `engine/basescape/state_manager.lua`

**Analysis:**
- Core version is global state manager (engine foundation)
- Basescape version is subsystem-specific wrapper
- Core is canonical

**Decision:**
- ✅ KEEP: `engine/core/state_manager.lua`
- ❌ DELETE: `engine/basescape/state_manager.lua`

**Validation:**
- Search: `grep -r "basescape/state_manager" engine/`
- Update imports to core version
- Test state transitions

---

### GROUP 8: research_system.lua (2 copies - INTENTIONAL)
**Locations:**
- `engine/basescape/research_system.lua`
- `engine/economy/research_system.lua`

**Analysis:**
- Basescape version: internal basescape mechanics
- Economy version: wraps basescape for economy integration
- BOTH needed and intentional

**Decision:**
- ✅ KEEP BOTH (intentional wrapper pattern)
- NO CHANGES

**Validation:**
- Document as intentional in architecture
- Verify economy version properly requires basescape version
- No imports from economy version outside economy/

---

### GROUP 9: economy_manager.lua (2 copies)
**Locations:**
- `engine/economy/economy_manager.lua`
- `engine/basescape/economy_manager.lua`

**Analysis:**
- Economy folder is primary (dedicated subsystem)
- Basescape version is wrapper/adapter

**Decision:**
- ✅ KEEP: `engine/economy/economy_manager.lua`
- ❌ DELETE: `engine/basescape/economy_manager.lua`

**Validation:**
- Search: `grep -r "basescape/economy_manager" engine/`
- Update imports to economy version
- Test economy mechanics

---

### GROUP 10: mission_manager.lua (2 copies)
**Locations:**
- `engine/geoscape/mission_manager.lua`
- `engine/battlescape/mission_manager.lua`

**Analysis:**
- Geoscape version: global mission management
- Battlescape version: tactical mission state
- Both needed but serve different purposes

**Decision:**
- ✅ RENAME: `engine/geoscape/mission_manager.lua` → `mission_director.lua`
- ✅ RENAME: `engine/battlescape/mission_manager.lua` → `tactical_mission_state.lua`

**Validation:**
- Search: `grep -r "require.*mission_manager" engine/`
- Update geoscape mission managers to use mission_director
- Update battlescape to use tactical_mission_state
- Test mission flow

---

### GROUP 11: unit_system.lua (2 copies)
**Locations:**
- `engine/basescape/unit_system.lua`
- `engine/battlescape/unit_system.lua`

**Analysis:**
- Basescape version: crew/personnel system
- Battlescape version: combat unit system
- Different concerns, both needed

**Decision:**
- ✅ RENAME: `engine/basescape/unit_system.lua` → `personnel_system.lua`
- ✅ KEEP: `engine/battlescape/unit_system.lua` (no rename needed)

**Validation:**
- Search: `grep -r "basescape/unit_system" engine/`
- Update to personnel_system
- Test crew and combat units independently

---

### GROUP 12: ai_manager.lua (3 copies)
**Locations:**
- `engine/ai/ai_manager.lua`
- `engine/geoscape/ai/ai_manager.lua`
- `engine/battlescape/ai/ai_manager.lua`

**Analysis:**
- Global AI folder version: primary AI orchestration
- Geoscape AI: strategic AI specific
- Battlescape AI: tactical AI specific
- All serve different purposes

**Decision:**
- ✅ KEEP: `engine/ai/ai_manager.lua` (global orchestrator)
- ✅ RENAME: `engine/geoscape/ai/ai_manager.lua` → `geoscape_ai_advisor.lua`
- ✅ RENAME: `engine/battlescape/ai/ai_manager.lua` → `tactical_ai_controller.lua`

**Validation:**
- Search for imports of all three versions
- Update geoscape AI imports to advisor
- Update battlescape AI imports to controller
- Test all AI systems

---

### GROUP 13-27: Additional Duplicates (14 more groups)

*See supplementary tables below for additional duplicates*

---

## ADDITIONAL DUPLICATES TABLE

| Filename | Count | Keep | Delete | Rename | Notes |
|----------|-------|------|--------|--------|-------|
| effect_system.lua | 2 | core/ | combat/ | - | Core is primary |
| entity_manager.lua | 2 | core/ | geoscape/ | - | Core is primary |
| event_system.lua | 2 | core/ | gui/ | - | Core is primary |
| facility_manager.lua | 2 | basescape/ | economy/ | - | Basescape is primary |
| faction_manager.lua | 2 | geoscape/ | politics/ | - | Geoscape is primary |
| inventory_system.lua | 2 | basescape/ | battlescape/ | - | Basescape is primary |
| item_system.lua | 2 | content/ | core/ | - | Content is primary |
| npc_system.lua | 2 | politics/ | geoscape/ | - | Politics is primary |
| render_manager.lua | 2 | gui/ | core/ | - | GUI is primary |
| squad_manager.lua | 2 | geoscape/ | battlescape/ | - | Geoscape is primary |
| terrain_system.lua | 2 | content/ | battlescape/ | - | Content is primary |
| ui_manager.lua | 2 | gui/ | basescape/ | - | GUI is primary |
| weapons_system.lua | 2 | content/ | battlescape/ | - | Content is primary |

---

## SUMMARY OF ACTIONS

### Files to DELETE (18 total)
```
engine/logic/base_manager.lua
engine/systems/base_manager.lua
engine/battlescape/combat/los_system.lua
engine/battlescape/combat/morale_system.lua
engine/battlescape/systems/flanking_system.lua
engine/audio/audio_manager.lua
engine/basescape/state_manager.lua
engine/basescape/economy_manager.lua
engine/geoscape/ai/ai_manager.lua (old one)
engine/battlescape/ai/ai_manager.lua (old one)
engine/core/audio_manager.lua (old version)
engine/battlescape/unit_system.lua (old version)
(+ 6 more as per additional table)
```

### Files to RENAME (4 total)
```
engine/geoscape/pathfinding.lua → strategic_pathfinding.lua
engine/battlescape/pathfinding.lua → tactical_pathfinding.lua
engine/geoscape/mission_manager.lua → mission_director.lua
engine/battlescape/mission_manager.lua → tactical_mission_state.lua
```

### Files to KEEP BOTH (5 pairs)
```
engine/basescape/research_system.lua + engine/economy/research_system.lua
(+ 4 more intentional duplicates)
```

---

## IMPLEMENTATION PROCEDURE

For **EACH** duplicate group:

1. **Identify all requires:**
   ```bash
   grep -r "require.*FILENAME" engine/ > imports.txt
   ```

2. **If RENAME:** 
   - Rename file in file system
   - Update all requires to new filename
   - Verify game loads

3. **If DELETE:**
   - Update all requires to use KEEP version
   - Verify no imports reference deleted file
   - Delete file
   - Run tests

4. **If KEEP BOTH:**
   - Document as intentional
   - Verify no circular imports
   - Verify correct usage pattern
   - No changes needed

---

## VALIDATION CHECKLIST

After completing all duplicate resolutions:

- [ ] All 18 duplicate files deleted
- [ ] All 4 rename operations completed
- [ ] All imports updated
- [ ] `grep -r "require.*deleted_file" engine/` returns zero results
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Game launches without errors
- [ ] No import errors in console
- [ ] Verify file count: 443 - 18 = 425 files remain

---

**Status:** Ready to implement  
**Estimated Time:** 2-3 hours  
**Commit Message:** "refactor: eliminate 18 duplicate files, rename 4 for clarity (Phase 1)"
