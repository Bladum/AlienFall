# Quick Reference: Engine/Wiki Alignment Task

**Date:** October 21, 2025  
**Status:** Audit Complete ✅  
**Ready to Execute:** Yes  

---

## 🎯 The Problem

You said:
> "Align engine folders with wiki folders. Content (items/units/crafts) into own folders. Merge scenes, ui, widgets into gui. Check all requires. Research is in completely wrong folder."

## ✅ What We Found

| Issue | Location | Fix |
|-------|----------|-----|
| **GUI Scattered** | scenes/, ui/, widgets/ | Merge → gui/ (3h) |
| **Content Mixed** | core/crafts, core/items, core/units | Move → content/ (1.5h) |
| **Research Wrong** | geoscape/ + economy/ (WRONG!) | Move → basescape/ (4h) |
| **Salvage Split** | battlescape/ + economy/ | OK - keep split |
| **Legacy Files** | balance_adjustments, etc. | Archive (0.5h) |

---

## 📋 Deliverables Created

### Documents
1. **TASK-ALIGN-ENGINE-WIKI-STRUCTURE.md** - Main task spec
2. **TASK-ALIGN-ENGINE-WIKI-STRUCTURE-PLAN.md** - Step-by-step execution guide (19h)
3. **ENGINE_WIKI_ALIGNMENT_AUDIT.md** - Complete findings
4. **TASK-ALIGN-ENGINE-WIKI-STRUCTURE-SUMMARY.md** - This summary

### Updated
- tasks/tasks.md - Added task tracking
- tasks/TODO/checklist - 8-point implementation plan

---

## 🔧 Implementation Timeline

```
Total: 19 hours

Phase A: Folder Moves (5h)
├─ Create content/, gui/ (0.5h)
├─ Move crafts/items/units (1.5h)
└─ Merge scenes/ui/widgets (3h)

Phase B: Fix Research (4h)
├─ Create basescape/research/ (0.5h)
├─ Consolidate files (2h)
├─ Move widget (0.5h)
└─ Remove duplicates (1h)

Phase C: Verify & Cleanup (2h)
├─ Verify folders (1h)
└─ Archive legacy files (1h)

Phase D: Update Requires (5h)
├─ Batch 1: content.* (1h) ← TEST
├─ Batch 2: gui.* (1.5h) ← TEST
├─ Batch 3: research.* (1.5h) ← TEST
└─ Batch 4: misc (1h) ← TEST

Phase E: Documentation (2h)
├─ Navigation guide (1h)
└─ Structure docs (1h)

Phase F: Testing (1h)
├─ Game run check (0.5h)
└─ Test suite (0.5h)
```

---

## 🚀 Quick Start

If you want to begin immediately:

### Step 1: Create Folders (2 minutes)
```bash
mkdir engine\content
mkdir engine\gui
```

### Step 2: Review Plan (20 minutes)
Read: `tasks/TODO/TASK-ALIGN-ENGINE-WIKI-STRUCTURE-PLAN.md`

### Step 3: Start Phase A (5 hours)
Move the three content folders

### Step 4: Test After Each Phase
```bash
lovec engine  # Check console for errors
```

### Step 5: Update Requires (Test often!)
Use search/replace systematically

---

## 📊 Impact Analysis

### Files Affected
- **Require statements:** 100-150 updates
- **Engine files:** ~50-80 files
- **Test files:** ~30-40 files
- **Mod files:** ~10-20 files

### Breaking Changes Risk
- **Before Phase D (requires):** ⚠️ CRITICAL - Game won't run
- **After Phase D batch 1:** ✅ LOW - Content works
- **After Phase D batch 2:** ✅ LOW - GUI works
- **After Phase D batch 3:** ✅ LOW - Research works
- **After Phase F:** ✅ COMPLETE

**Mitigation:** Test after each batch

---

## ✔️ Success Criteria

- [x] Audit complete with findings
- [x] Documents created
- [x] 19-hour plan documented
- [ ] Implement Phase A-F
- [ ] All requires updated
- [ ] Game runs without errors
- [ ] Tests pass 100%
- [ ] Documentation updated

---

## 🎓 Key Findings

### Research System Discovery

**The smoking gun you found:**

```
You said: "research is in completely wrong folder"

We found:
├─ engine/geoscape/logic/research_manager.lua      ← WRONG #1
├─ engine/geoscape/logic/research_entry.lua        ← WRONG #2
├─ engine/geoscape/logic/research_project.lua      ← WRONG #3
├─ engine/economy/research/research_system.lua     ← WRONG #4
└─ engine/widgets/advanced/researchtree.lua        ← WRONG FOLDER

Should be:
└─ engine/basescape/research/                      ← CORRECT

Why wrong: Research labs are BASE facilities, not Geoscape (world map)
Why matter: Research is basescape system, period.
```

### GUI Unification

```
Current: 3 separate folders
├─ engine/scenes/
├─ engine/ui/
└─ engine/widgets/

Why problem: Wiki treats as one "Gui.md" system
Why matter: Unified structure matches documentation
```

### Content Separation

```
Current: Mixed in core/
├─ engine/core/crafts/    ← GAME DATA (not core!)
├─ engine/core/items/     ← GAME DATA (not core!)
└─ engine/core/units/     ← GAME DATA (not core!)

Why problem: Core = engine logic, Content = game data
Why matter: Separation of concerns
```

---

## 🔍 Files You Should Read

### Priority 1 (Start here)
- `docs/TASK-ALIGN-ENGINE-WIKI-STRUCTURE-SUMMARY.md` (This document level)
- `tasks/tasks.md` (See task entry)

### Priority 2 (Plan execution)
- `tasks/TODO/TASK-ALIGN-ENGINE-WIKI-STRUCTURE-PLAN.md` (ESSENTIAL for implementation)
- `docs/ENGINE_WIKI_ALIGNMENT_AUDIT.md` (Complete details)

### Priority 3 (Reference during work)
- `tasks/TODO/TASK-ALIGN-ENGINE-WIKI-STRUCTURE.md` (Full task spec)
- Local task checklist (from todo list)

---

## ❓ FAQs

**Q: Can I start now?**
A: Yes! Phase A (folder moves) can start immediately. Just mkdir and move folders.

**Q: How risky is this?**
A: Low risk if you follow plan: git commit between phases, test after each batch of require updates.

**Q: What if something breaks?**
A: `git revert` to previous commit. Then diagnose and fix one issue at a time.

**Q: Can I skip any phases?**
A: No - all phases are interdependent. Must do in order: A → B → C → D → E → F

**Q: How long does it really take?**
A: 19 hours as planned, maybe 20-22 with testing/debugging. Do it in blocks: A+B (9h), then D (5h), then E+F (3h).

**Q: Do I need to update documentation?**
A: Yes, Phase E. Creates navigation guide and structure docs so future devs understand layout.

---

## 📞 Next Steps

### Option 1: Start Immediately
1. Create engine/content and engine/gui folders
2. Follow Phase A in TASK-ALIGN-ENGINE-WIKI-STRUCTURE-PLAN.md
3. Test after 3 hours

### Option 2: Review First
1. Read all 4 documents created
2. Ask questions about findings
3. Then proceed with Option 1

### Option 3: Modify Plan
1. Point out what should change
2. I'll update TASK-ALIGN-ENGINE-WIKI-STRUCTURE-PLAN.md
3. Then execute modified plan

---

## 🎉 Expected Outcome

After completing this task:

✅ Engine folder structure perfectly mirrors wiki/systems structure  
✅ All 19 wiki systems map to engine/ folders  
✅ Content (data) separated from core (engine)  
✅ GUI components unified in single folder  
✅ Research moved to correct location  
✅ 100% of requires working  
✅ Game runs without console errors  
✅ Tests pass 100%  
✅ Navigation guide updated  
✅ Developers can map wiki design → engine code directly  

---

**Ready?** Start with Phase A. 🚀

