# Quick Task Reference - Alien Fall

## All Tasks at a Glance

| ID | Priority | Task Name | Hours | Status |
|----|----------|-----------|-------|--------|
| 012 | 🔴 Critical | Fix LOS/FOW System | 48 | TODO |
| 001 | 🟠 High | Add Docstrings & READMEs | 44 | TODO |
| 002 | 🟠 High | Comprehensive Testing | 64 | TODO |
| 004 | 🟠 High | Split Game/Editor/Tester | 40 | TODO |
| 006 | 🟠 High | Unit Info Panel | 28 | TODO |
| 007 | 🟠 High | Unit Stats System | 25 | TODO |
| 008 | 🟠 High | Camera & Turn System | 29 | TODO |
| 009 | 🟠 High | Enemy Spotting & Notifications | 32 | TODO |
| 010 | 🟠 High | Move Modes System | 40 | TODO |
| 011 | 🟠 High | Action Panel RMB System | 49 | TODO |
| 003 | 🟡 Medium | Game Icon & Rename | 14 | TODO |
| 005 | 🟡 Medium | Fix IDE Problems | 27 | TODO |
| 013 | 🟢 Low | Reduce Menu Button Size | 12 | TODO |

**Total: 13 tasks, 428 hours (~11 weeks full-time)**

---

## By Priority

### 🔴 Critical (1 task, 48 hours)
- **TASK-012:** Fix LOS/FOW System

### 🟠 High (9 tasks, 337 hours)
- **TASK-001:** Add Docstrings & READMEs
- **TASK-002:** Comprehensive Testing
- **TASK-004:** Split Game/Editor/Tester
- **TASK-006:** Unit Info Panel
- **TASK-007:** Unit Stats System
- **TASK-008:** Camera & Turn System
- **TASK-009:** Enemy Spotting & Notifications
- **TASK-010:** Move Modes System
- **TASK-011:** Action Panel RMB System

### 🟡 Medium (2 tasks, 41 hours)
- **TASK-003:** Game Icon & Rename
- **TASK-005:** Fix IDE Problems

### 🟢 Low (1 task, 12 hours)
- **TASK-013:** Reduce Menu Button Size

---

## By System

### Documentation (1 task, 44 hours)
- TASK-001: Docstrings & READMEs

### Testing (1 task, 64 hours)
- TASK-002: Comprehensive Testing

### Project Structure (1 task, 40 hours)
- TASK-004: Split Game/Editor/Tester

### UI/Widgets (4 tasks, 136 hours)
- TASK-006: Unit Info Panel (28h)
- TASK-009: Notifications (32h)
- TASK-011: Action Panel (49h)
- TASK-013: Menu Buttons (12h)

### Combat Systems (5 tasks, 193 hours)
- TASK-007: Unit Stats (25h)
- TASK-008: Camera & Turn (29h)
- TASK-010: Move Modes (40h)
- TASK-012: LOS/FOW (48h)
- TASK-009: Enemy Spotting (32h) *overlaps with UI*

### Branding/Polish (2 tasks, 26 hours)
- TASK-003: Icon & Rename (14h)
- TASK-005: IDE Problems (27h)

---

## Suggested Sprint Plan

### Sprint 1: Critical Foundation (Week 1-2, 48 hours)
- [ ] TASK-012: Fix LOS/FOW System (48h)

### Sprint 2: Code Quality (Week 3-6, 149 hours)
- [ ] TASK-003: Game Icon & Rename (14h)
- [ ] TASK-005: Fix IDE Problems (27h)
- [ ] TASK-001: Add Docstrings & READMEs (44h)
- [ ] TASK-002: Comprehensive Testing (64h)

### Sprint 3: Structure (Week 7, 40 hours)
- [ ] TASK-004: Split Game/Editor/Tester (40h)

### Sprint 4: Core Combat (Week 8-10, 82 hours)
- [ ] TASK-007: Unit Stats System (25h)
- [ ] TASK-008: Camera & Turn System (29h)
- [ ] TASK-006: Unit Info Panel (28h)

### Sprint 5: Advanced Combat (Week 11-15, 121 hours)
- [ ] TASK-010: Move Modes System (40h)
- [ ] TASK-009: Enemy Spotting & Notifications (32h)
- [ ] TASK-011: Action Panel RMB System (49h)

### Sprint 6: Polish (Week 15, 12 hours)
- [ ] TASK-013: Reduce Menu Button Size (12h)

---

## Quick Start Guide

### To Start a Task:
1. Open task document in `tasks/TODO/TASK-XXX-name.md`
2. Read full task document
3. Update status in `tasks/tasks.md` to `IN_PROGRESS`
4. Create TODO list items with `manage_todo_list` tool
5. Follow implementation steps in task document

### To Complete a Task:
1. Complete all checklist items in task document
2. Run game with Love2D console: `lovec "engine"`
3. Test all functionality
4. Update documentation (wiki files)
5. Update status in `tasks/tasks.md` to `DONE`
6. Move task file to `tasks/DONE/`
7. Fill in "Post-Completion" section

---

## File Locations

### Task Documents
- `tasks/TODO/TASK-XXX-*.md` - All task documents
- `tasks/tasks.md` - Central tracking file
- `tasks/TASK_TEMPLATE.md` - Template for new tasks
- `tasks/TASK_PLANNING_SUMMARY.md` - This summary

### Documentation to Update
- `wiki/API.md` - API documentation
- `wiki/FAQ.md` - Game mechanics
- `wiki/DEVELOPMENT.md` - Development workflow
- `wiki/QUICK_REFERENCE.md` - Quick reference

### Key Code Locations
- `engine/` - Main game code
- `engine/systems/` - Core systems
- `engine/battle/` - Battle systems
- `engine/widgets/` - UI widgets
- `engine/modules/` - Game screens/states
- `mods/` - Game content (TOML files)

---

## Important Reminders

✅ **Always use Love2D console:** `lovec "engine"`  
✅ **All positions/sizes are 24×24 grid multiples**  
✅ **Temporary files go to:** `os.getenv("TEMP")`  
✅ **Update wiki documentation** after each task  
✅ **Use Google-style docstrings** for all functions  
✅ **Write tests** for all new functionality  
✅ **Task documents are the source of truth** - follow them!  

---

## Contact/Questions

Refer to:
- Task documents in `tasks/TODO/`
- `wiki/DEVELOPMENT.md` - Development guide
- `.github/copilot-instructions.md` - System prompt
- `wiki/API.md` - API reference

---

**Created:** October 12, 2025  
**Status:** Ready for Implementation ✅
