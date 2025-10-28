# Tasks Folder - File-Based Work Tracking

**Purpose:** Track all project work transparently using version-controlled markdown files  
**Audience:** Developers, project managers, stakeholders, team members  
**Format:** Markdown files organized by state (TODO/, DONE/)

---

## What Goes in tasks/

### Structure
```
tasks/
├── TASK_TEMPLATE.md            Template for new tasks
├── TODO/                        Active and planned tasks
│   ├── IMPLEMENT_FEATURE_X.md  Feature task
│   ├── FIX_BUG_Y.md            Bug fix task
│   ├── REFACTOR_Z.md           Refactor task
│   └── UPDATE_DOCS.md          Documentation task
│
└── DONE/                        Completed tasks (archive)
    ├── IMPLEMENT_PILOT_SYSTEM.md
    ├── FIX_CRASH_ON_LOAD.md
    └── ADD_UNIT_TESTS.md
```

---

## Core Principle: Tasks as Files

**One task = One markdown file. Task state = File location.**

```
Task lifecycle:
1. Create task file in TODO/
2. Update as work progresses
3. Move to DONE/ when complete

All in git:
✓ Version controlled
✓ Searchable
✓ Linked to commits
✓ Transparent to team
```

**Benefits:**
- No external tools needed (just files + git)
- Tasks live near code they describe
- Full history in version control
- Easy to search (grep, find)
- Transparent (anyone can see all work)

---

## Content Guidelines

### What Belongs Here
- ✅ Feature tasks (new functionality)
- ✅ Bug fixes (issues to resolve)
- ✅ Refactoring tasks (code improvements)
- ✅ Documentation tasks (docs to write/update)
- ✅ Testing tasks (tests to add)
- ✅ Research tasks (investigations, spikes)
- ✅ Maintenance tasks (technical debt)

### What Does NOT Belong Here
- ❌ Code implementation - goes in engine/
- ❌ Design specifications - goes in design/
- ❌ Meeting notes - goes elsewhere
- ❌ General ideas/brainstorming - use separate file

---

## Task File Template

```markdown
# TASK: [Type] - Brief Description

**Created:** YYYY-MM-DD
**Priority:** CRITICAL | HIGH | MEDIUM | LOW
**Category:** Feature | Bug | Documentation | Refactor | Performance | Testing
**Estimated Effort:** X hours/days
**Status:** 🟡 TODO | 🟠 In Progress | 🟢 DONE | 🔴 Blocked

---

## Overview
Brief description of what needs to be done and why it matters.
Context: Why is this task needed? What problem does it solve?

## Objectives
- [ ] Primary objective 1 (clear, measurable)
- [ ] Primary objective 2
- [ ] Optional: Secondary objective

## Implementation Plan

### Phase 1: Preparation
- [ ] Review related design documents
- [ ] Check API contracts
- [ ] Verify architecture

### Phase 2: Implementation
- [ ] Core functionality
- [ ] Error handling
- [ ] Unit tests

### Phase 3: Validation
- [ ] Run test suite
- [ ] Update documentation
- [ ] Code review

## Success Criteria
- [ ] All objectives completed
- [ ] Tests pass (>75% coverage for new code)
- [ ] Documentation updated
- [ ] Code reviewed and approved
- [ ] No regressions introduced

## Dependencies
- **Depends on:** TASK_X (must complete first)
- **Blocks:** TASK_Y (waiting for this)
- **Related:** TASK_Z (similar work, coordinate)

## Risks & Mitigation
### Risk 1: [Description]
**Likelihood:** High | Medium | Low
**Impact:** High | Medium | Low  
**Mitigation:** How to prevent or handle

## Notes
- Additional context
- Design decisions
- Alternatives considered
- Links to resources

## Progress Log

### YYYY-MM-DD
- Started implementation
- Completed phase 1
- Encountered issue X, resolved by doing Y

### YYYY-MM-DD
- Completed phase 2
- Submitted for review

---

## Related Files
- **Design:** design/mechanics/[System].md
- **API:** api/[SYSTEM].md
- **Architecture:** architecture/systems/[system].md
- **Engine:** engine/[path]/[file].lua
- **Tests:** tests2/[path]/[file]_test.lua

---

**Status:** 🟡 TODO
**Next Action:** [What to do next]
**Assigned To:** [Person if applicable]
```

---

## Task Workflow

### Creating a Task

```bash
# 1. Copy template
cp tasks/TASK_TEMPLATE.md tasks/TODO/IMPLEMENT_PILOT_SYSTEM.md

# 2. Fill in all sections
# - Set priority (based on urgency/impact)
# - Estimate effort (be realistic, use past tasks as reference)
# - Define clear objectives (SMART goals)
# - Plan implementation phases
# - List dependencies
# - Define success criteria

# 3. Commit to git
git add tasks/TODO/IMPLEMENT_PILOT_SYSTEM.md
git commit -m "task: plan pilot system implementation"
git push
```

**Best Practices:**
- Use descriptive file names (VERB_NOUN_CONTEXT)
- Keep scope bounded (task should complete in <1 week)
- Link to relevant documentation
- Include "why" context in Overview

---

### Working on a Task

```markdown
# Update status
**Status:** 🟠 In Progress

# Add progress entries
## Progress Log

### 2025-10-27
- Started implementation
- Created pilot entity class
- Added skill progression logic
- Blocker: Need clarification on skill cap

### 2025-10-28
- Resolved blocker (skill cap = 100)
- Completed skill system
- Started UI integration
```

**Best Practices:**
- Update progress at least daily
- Document decisions made (and why)
- Note blockers immediately
- Reference commits: "Implemented X (commit abc123)"

---

### Completing a Task

```bash
# 1. Verify success criteria
# - All objectives met?
# - Tests pass?
# - Documentation updated?
# - Code reviewed?

# 2. Update task status
**Status:** 🟢 DONE

## Progress Log
### 2025-10-29
- COMPLETED: All objectives met
- Tests: 85% coverage
- Documentation: Updated design/ and api/
- Code review: Approved by 2 reviewers
- Actual effort: 3 days (estimated: 2-3 days)

# 3. Move to DONE/
git mv tasks/TODO/IMPLEMENT_PILOT_SYSTEM.md tasks/DONE/
git commit -m "task: complete pilot system implementation"
git push

# 4. Unblock dependent tasks
# Find tasks waiting on this one
# Update their status
```

---

## Task States

### 🟡 TODO - Planned Work
```
- Task created but not started
- All planning complete
- Ready to begin when time available
- May have dependencies not yet met
```

### 🟠 In Progress - Active Work
```
- Currently being worked on
- Progress log updated regularly
- May encounter blockers
- Should complete soon
```

### 🟢 DONE - Completed Work
```
- All success criteria met
- Moved to tasks/DONE/
- Archived but searchable
- Used for retrospectives and metrics
```

### 🔴 Blocked - Waiting
```
- Cannot proceed due to blocker
- Blocker documented in task
- Waiting for dependency or external factor
- Alternative work should be pursued
```

---

## Integration with Other Folders

### tasks/ → engine/
Tasks drive code changes:
- **Task:** Describes what needs implementing
- **Engine:** Implementation happens here
- **Commits:** Reference task in commit message

### tasks/ → design/
Tasks may require design work:
- **Task:** "Need design for pilot system"
- **Design:** Create design/mechanics/pilots.md
- **Task:** Update with link to design

### tasks/ → tests2/
Tasks include testing:
- **Task:** "Add unit tests for pilot system"
- **Tests:** Create tests2/pilot_test.lua
- **Task:** Check off testing objective

### git → tasks/
Commits reference tasks:
```bash
git commit -m "feat(pilot): add skill progression (ref: IMPLEMENT_PILOT_SYSTEM)"
# Creates bidirectional link: commit ↔ task
```

---

## Task Categories

### Feature Tasks
```markdown
# TASK: Feature - Add Pilot Skill System

**Category:** Feature
**Priority:** HIGH

Adds persistent pilot attributes that improve with flight hours.
```

### Bug Fix Tasks
```markdown
# TASK: Bug - Fix Crash on Mission Load

**Category:** Bug
**Priority:** CRITICAL

Game crashes when loading certain missions. Need to fix immediately.
```

### Refactor Tasks
```markdown
# TASK: Refactor - Improve Unit Manager Performance

**Category:** Refactor
**Priority:** MEDIUM

Current unit manager is slow with >50 units. Refactor for better performance.
```

### Documentation Tasks
```markdown
# TASK: Documentation - Update API Docs for Pilots

**Category:** Documentation
**Priority:** MEDIUM

New pilot system needs API documentation in api/PILOTS.md
```

---

## Task Metrics

### Throughput
```bash
lua tools/task/report.lua

# Output:
Last 30 days:
- Tasks completed: 42
- Average per week: 9.8
- Average duration: 3.2 days
- Estimation accuracy: ±22%
```

### Health
```bash
lua tools/task/health.lua

# Output:
Current status:
- TODO: 15
- In Progress: 5
- Blocked: 2
- Stale (>30 days): 0

Health: GOOD ✓
```

### Priority Distribution
```bash
lua tools/task/priority.lua

# Output:
- CRITICAL: 2 (4%)
- HIGH: 12 (27%)
- MEDIUM: 20 (44%)
- LOW: 11 (24%)

Distribution: HEALTHY ✓
```

---

## Validation

### Task Quality Checklist

- [ ] Template completely filled out
- [ ] Priority set appropriately
- [ ] Effort estimated (use past tasks)
- [ ] Objectives clear and measurable
- [ ] Success criteria defined
- [ ] Dependencies identified
- [ ] Related files linked
- [ ] Progress log maintained
- [ ] Status current and accurate

---

## Tools

### Task Reporter
```bash
lua tools/task/report.lua

# Generates:
# - Status overview (TODO/In Progress/DONE counts)
# - Completion rate
# - Average task duration
# - Blocked tasks list
```

### Task Creator
```bash
lua tools/task/create_task.lua "Implement Feature X" --priority=HIGH

# Creates: tasks/TODO/IMPLEMENT_FEATURE_X.md
# Pre-filled with template and metadata
```

### Task Lister
```bash
lua tools/task/list_tasks.lua --status=TODO --priority=CRITICAL

# Lists:
# 1. IMPLEMENT_SAVE_SYSTEM.md (In Progress, 3 days)
# 2. FIX_CRITICAL_BUG.md (TODO, 1 day)
```

### Dependency Visualizer
```bash
lua tools/task/dependency_graph.lua

# Generates visual graph showing:
# - Task dependencies
# - Critical path
# - Blocked tasks
```

---

## Best Practices

### 1. Keep Tasks Small
```
GOOD: "Add pilot skill attribute" (2-3 days)
BAD: "Implement entire pilot system" (6 months)

Break large tasks into smaller subtasks.
```

### 2. Link Everything
```markdown
## Related Files
- Design: design/mechanics/pilots.md
- API: api/PILOTS.md
- Engine: engine/geoscape/pilots/pilot.lua

## Progress Log
- Implemented skill system (commit abc123)
- Added UI display (commit def456)
```

### 3. Document Decisions
```markdown
## Notes
Decided to use integer skill level (0-100) instead of float.
Rationale: Simpler balance, easier to display in UI.
Alternative: Float (0.0-1.0) rejected - too granular.
```

### 4. Update Regularly
```
Daily: Add progress log entry
Weekly: Review objectives and adjust if needed
On completion: Document actual vs estimated effort
```

### 5. Clear Success Criteria
```markdown
## Success Criteria
- [ ] Pilots have skill_level property (0-100)
- [ ] Skill increases +1 per 10 flight hours
- [ ] UI displays pilot skill
- [ ] Tests pass (>75% coverage)
- [ ] Documentation updated
```

---

## Troubleshooting

### Task Taking Too Long
```
Check:
1. Was scope underestimated?
2. Are there unexpected blockers?
3. Should task be split into smaller tasks?
4. Need help from team member?

Action: Update task with findings, adjust plan
```

### Stale Tasks
```
Check:
1. Is task still relevant?
2. Is it blocked? Document blocker
3. Is priority too low? Adjust priority
4. Should it be archived?

Action: Update or move to DONE/ if obsolete
```

### Blocked Tasks
```
Document:
1. What is blocking?
2. Who can unblock?
3. Expected resolution date?
4. Alternative task to work on?

Action: Update task, notify team, work on something else
```

---

## Maintenance

**Daily:**
- Update progress on active tasks
- Check for new tasks
- Review blocked tasks

**Weekly:**
- Review all TODO tasks
- Update priorities
- Archive completed tasks
- Generate metrics report

**Monthly:**
- Retrospective on completed tasks
- Review estimation accuracy
- Clean up stale tasks
- Update template if needed

---

**See:** tasks/README.md

**Related:**
- [systems/05_TASK_MANAGEMENT_SYSTEM.md](../systems/05_TASK_MANAGEMENT_SYSTEM.md) - Task management system pattern

