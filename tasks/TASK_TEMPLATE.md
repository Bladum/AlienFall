# Task: [Task Name]

**Status:** TODO | IN_PROGRESS | TESTING | DONE  
**Priority:** Low | Medium | High | Critical  
**Created:** [Date]  
**Completed:** [Date or N/A]  
**Assigned To:** [Developer/AI Agent]

---

## Overview

Brief description of what this task aims to accomplish.

---

## Purpose

Why is this task necessary? What problem does it solve?

---

## Requirements

### Functional Requirements
- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

### Technical Requirements
- [ ] Technical requirement 1
- [ ] Technical requirement 2

### Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Criteria 3

---

## Plan

### Step 1: [Phase Name]
**Description:** What needs to be done  
**Files to modify/create:**
- `path/to/file1.lua`
- `path/to/file2.lua`

**Estimated time:** X hours

### Step 2: [Phase Name]
**Description:** What needs to be done  
**Files to modify/create:**
- `path/to/file3.lua`

**Estimated time:** X hours

### Step 3: Testing
**Description:** How to verify the implementation  
**Test cases:**
- Test case 1
- Test case 2

**Estimated time:** X hours

---

## Implementation Details

### Architecture
Describe the technical approach, patterns used, and how it integrates with existing code.

### Key Components
- **Component 1:** Description
- **Component 2:** Description

### Dependencies
- Dependency 1
- Dependency 2

---

## Testing Strategy

### Unit Tests
- Test 1: Description
- Test 2: Description

### Integration Tests
- Test 1: Description
- Test 2: Description

### Manual Testing Steps
1. Step 1
2. Step 2
3. Step 3

### Expected Results
- Result 1
- Result 2

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print()` statements for debugging output
- Check console window for errors and debug messages
- Use `love.graphics.print()` for on-screen debug info

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - If adding new API functions
- [ ] `wiki/FAQ.md` - If addressing common issues
- [ ] `wiki/DEVELOPMENT.md` - If changing dev workflow
- [ ] `README.md` - If user-facing changes
- [ ] Code comments - Add inline documentation

---

## Notes

Any additional notes, considerations, or concerns.

---

## Blockers

Any blockers or dependencies that need to be resolved before this task can be completed.

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console

---

## Post-Completion

### What Worked Well
- Point 1
- Point 2

### What Could Be Improved
- Point 1
- Point 2

### Lessons Learned
- Lesson 1
- Lesson 2
