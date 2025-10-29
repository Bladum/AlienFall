# Tasks - Project Task Management

**Purpose:** Track project tasks, TODOs, and completed work  
**Audience:** Developers, project managers, AI agents  
**Status:** Active tracking  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Task Format](#task-format)
- [How to Use](#how-to-use)
- [Relations to Other Modules](#relations-to-other-modules)
- [Quick Reference](#quick-reference)

---

## Overview

The `tasks/` folder contains **project task management** - tracking TODOs, work in progress, and completed tasks.

**Core Purpose:**
- Track project tasks
- Manage TODO lists
- Document completed work
- Organize development priorities

---

## Folder Structure

```
tasks/
├── README.md                          ← This file
├── tasks.md                           ← Main task list (TASK-001, TASK-002, etc.)
├── TASK_TEMPLATE.md                   ← Template for new tasks
│
├── TODO/                              ← Pending Tasks
│   ├── design_analysis_followup_tasks.md     ← TASK-002: 15 tasks, 206 hours
│   ├── design_analysis_README.md             ← Quick reference
│   ├── design_analysis_CHECKLIST.md          ← Progress tracking
│   ├── design_analysis_EXECUTIVE_SUMMARY.md  ← One-pager for management
│   └── [other task files]
│
└── DONE/                              ← Completed Tasks
    └── pilot_craft_redesign_tasks.md  ← TASK-001: Completed 2025-10-28
```

---

## Active Tasks

### TASK-002: Design Analysis Follow-Up & Auto-Balance Implementation
**Status:** 🔄 IN PROGRESS (20% complete)  
**Priority:** HIGH  
**Files:**
- [Detailed Tasks](TODO/design_analysis_followup_tasks.md) - 15 tasks, 206 hours
- [Quick Reference](TODO/design_analysis_README.md) - Overview & next steps
- [Checklist](TODO/design_analysis_CHECKLIST.md) - Progress tracking
- [Executive Summary](TODO/design_analysis_EXECUTIVE_SUMMARY.md) - One-pager

**Completed:**
- ✅ Comprehensive analysis (48 files)
- ✅ FAQ_ANALYTICS.md (560 lines)
- ✅ GLOSSARY.md updates (27 terms)
- ✅ KPI configuration (20 metrics)

**Next:** Team review + Add template sections (Week 1, 3 hours)

### TASK-001: Pilot-Craft System Redesign
**Status:** ✅ COMPLETE (100%)  
**Completed:** 2025-10-28  
**Files:** [DONE/pilot_craft_redesign_tasks.md](DONE/pilot_craft_redesign_tasks.md)

---

## Task Format

```markdown
# Task: [Title]

**Status:** TODO/IN_PROGRESS/DONE  
**Priority:** High/Medium/Low  
**Assigned:** [Name]  
**Due:** YYYY-MM-DD

## Description
What needs to be done

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Related
- Design: design/mechanics/[system].md
- API: api/[SYSTEM].md
```

---

## How to Use

### Creating Task
1. Copy `TASK_TEMPLATE.md`
2. Fill details
3. Save to `TODO/`
4. Add to `tasks.md`

### Completing Task
1. Mark all criteria
2. Move `TODO/` → `DONE/`
3. Update `tasks.md`

### For AI Agents
- **When to read:** Understanding priorities
- **When to update:** After completing tasks
- **Format:** Follow TASK_TEMPLATE.md

---

## Relations to Other Modules

| Module | Relationship |
|--------|--------------|
| **docs/system/05_TASK_MANAGEMENT_SYSTEM.md** | Task pattern |
| **docs/chatmodes/tasker.chatmode.md** | AI task persona |
| **All modules** | Tasks reference all |

---

## Quick Reference

### Quick Commands

```bash
# View tasks
cat tasks/tasks.md

# Find TODOs
ls tasks/TODO/

# Check completed
ls tasks/DONE/
```

### Related Documentation

- **System Pattern:** [docs/system/05_TASK_MANAGEMENT_SYSTEM.md](../docs/system/05_TASK_MANAGEMENT_SYSTEM.md)
- **ChatMode:** [docs/chatmodes/tasker.chatmode.md](../docs/chatmodes/tasker.chatmode.md)

---

**Last Updated:** 2025-10-28  
**Questions:** See [TASK_TEMPLATE.md](TASK_TEMPLATE.md) or Discord

