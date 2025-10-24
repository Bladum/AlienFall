# TASK-GAP-006: Compare Engine TODO/FIXME Markers vs Task Management

**Status:** TODO
**Priority:** HIGH
**Created:** October 23, 2025
**Estimated Time:** 3-4 hours
**Task Type:** Code Audit + Inventory

---

## Overview

Find all TODO/FIXME/HACK/BUG markers in engine code and cross-reference against task management system to:
1. Identify orphaned TODOs (no task tracking)
2. Verify existing tasks match code TODOs
3. Prioritize urgent fixes
4. Clean up completed TODOs
5. Create missing tasks

---

## Scope: TWO SOURCES ONLY

**Source A:** `engine/` code (TODO markers in Lua files)
**Source B:** `tasks/tasks.md` + `tasks/TODO/` (task tracking)

---

## Phase 1: Inventory All TODOs (1-2 hours)

**Search engine code for markers:**
- [ ] TODO comments
- [ ] FIXME comments
- [ ] HACK comments
- [ ] BUG comments
- [ ] XXX comments (common in some codebases)

**Grep Search Results Found:**
From previous analysis, these TODO markers exist:

### Critical TODOs

1. **File:** `engine/battlescape/mission_map_generator.lua:262`
   ```lua
   -- TODO: Implement team placement
   ```
   **Status:** Should be task?
   **Severity:** 🔴 High (blocks team spawning)
   **Tracking:** Check if in `tasks/`

2. **File:** `engine/battlescape/systems/abilities_system.lua:96`
   ```lua
   -- TODO: Create turret unit
   ```
   **Status:** Should be task
   **Severity:** 🔴 High (ability missing)
   **Tracking:** Check if in `tasks/`

3. **File:** `engine/battlescape/systems/abilities_system.lua:132`
   ```lua
   -- TODO: Apply marked status effect
   ```
   **Status:** Should be task
   **Severity:** 🔴 High (ability missing)
   **Tracking:** Check if in `tasks/`

4. **File:** `engine/battlescape/systems/abilities_system.lua:167`
   ```lua
   -- TODO: Apply suppression status effect
   ```
   **Status:** Should be task
   **Severity:** 🔴 High (ability missing)
   **Tracking:** Check if in `tasks/`

5. **File:** `engine/battlescape/systems/abilities_system.lua:234`
   ```lua
   -- TODO: Apply fortify status effect
   ```
   **Status:** Should be task
   **Severity:** 🔴 High (ability missing)
   **Tracking:** Check if in `tasks/`

### Medium Priority TODOs

6. **File:** `engine/geoscape/campaign_manager.lua:169`
   ```lua
   -- TODO: Base this on faction relations when FactionManager/RelationsManager exist
   ```
   **Status:** Campaign manager incomplete
   **Severity:** 🟠 Medium (campaign integration)
   **Tracking:** Check if in `tasks/`

7. **File:** `engine/geoscape/campaign_manager.lua:187`
   ```lua
   -- TODO: Replace with faction-based generation when FactionManager exists
   ```
   **Status:** Campaign generation incomplete
   **Severity:** 🟠 Medium (campaign integration)
   **Tracking:** Check if in `tasks/`

8. **File:** `engine/geoscape/campaign_manager.lua:232-233`
   ```lua
   -- TODO: Use actual faction when FactionManager exists
   -- TODO: Select province when World system exists
   ```
   **Status:** Campaign manager has dependencies
   **Severity:** 🟠 Medium (campaign integration)
   **Tracking:** Check if in `tasks/`

9. **File:** `engine/geoscape/systems/detection_manager.lua:126`
   ```lua
   -- TODO: Replace with actual base/craft scanning when those systems are ready
   ```
   **Status:** Detection system incomplete
   **Severity:** 🟠 Medium (detection system)
   **Tracking:** Check if in `tasks/`

10. **File:** `engine/geoscape/systems/detection_manager.lua:268`
    ```lua
    -- TODO: Replace with province graph pathfinding when World system exists
    ```
    **Status:** Detection pathfinding incomplete
    **Severity:** 🟠 Medium (detection system)
    **Tracking:** Check if in `tasks/`

---

## Phase 2: Cross-Reference with Tasks (1 hour)

**For each TODO found, check:**
- [ ] Is there a corresponding task in `tasks/tasks.md`?
- [ ] Is there a task file in `tasks/TODO/`?
- [ ] Is the task in progress, blocked, or planned?
- [ ] Does the task description match the TODO?
- [ ] Is the effort estimate accurate?

**Create Matrix:**
| TODO | File | Line | Severity | Task ID | Status | Tracking |
|------|------|------|----------|---------|--------|----------|
| Team placement | mission_map_generator | 262 | 🔴 High | TASK-??? | ❓ | Check |
| Turret ability | abilities_system | 96 | 🔴 High | TASK-??? | ❓ | Check |
| ... | ... | ... | ... | ... | ... | ... |

---

## Phase 3: Create Missing Tasks (1 hour)

**For each untracked TODO, create task file:**
- [ ] File name: `tasks/TODO/TASK-GAP-XXX-description.md`
- [ ] Link to code TODO
- [ ] Estimate effort
- [ ] Set priority
- [ ] Identify dependencies
- [ ] Create acceptance criteria

**Template for new tasks:**
```markdown
# TASK-GAP-XXX: [Description]

**Status:** TODO
**Priority:** [HIGH/MEDIUM/LOW]
**Created:** October 23, 2025
**Estimated Time:** X hours
**Code Reference:** `engine/path/to/file.lua:LINE`

## TODO in Code
```
[Paste actual TODO from code]
```

## What's Needed
- [ ] Implementation steps

## Success Criteria
- [ ] Code TODO removed
- [ ] Feature working
- [ ] Tests passing

## Blocking Tasks
- [ ] None / [Related task]
```

---

## Phase 4: Cleanup Complete TODOs (Optional, 30 min)

**Check for completed TODOs:**
- [ ] Are there TODOs in code that are actually done?
- [ ] Search for completed features
- [ ] Remove obsolete TODOs
- [ ] Clean up completed task files

---

## Deliverables

### TODO Inventory Report
**File:** `docs/CODE_TODO_INVENTORY.md`

Should contain:
- All TODOs found in code
- Severity assessment
- Task tracking status
- Organization by priority
- Organization by area (battlescape, geoscape, etc)

### New Task Files Created
For each untracked TODO:
- [ ] `tasks/TODO/TASK-GAP-XXX-description.md`

### Updated Task Tracking
- [ ] `tasks/tasks.md` updated with new tasks
- [ ] All TODOs cross-referenced to tasks
- [ ] Task status synchronized with code

---

## Success Criteria

✅ All TODOs found and inventoried
✅ All TODOs cross-referenced to tasks (or new tasks created)
✅ Severity assessed
✅ Effort estimated
✅ Report created
✅ No orphaned TODOs remaining

---

## Related Files

**Compare These:**
- Code search: `grep -r "TODO" engine/` ↔ Task files: `tasks/TODO/`
- Code search: `grep -r "FIXME" engine/` ↔ Task files: `tasks/`
- Code search: `grep -r "HACK" engine/` ↔ Task files: `tasks/`

**Reference Report:**
- Code TODOs found in: `design/gaps/ENGINE_IMPLEMENTATION_GAPS.md`

---

**Task ID:** TASK-GAP-006
**Assignee:** [Developer Lead]
**Due:** October 26, 2025
**Complexity:** Low (systematic inventory)

**Note:** This task should be done EARLY to establish baseline of what's tracked vs untracked
