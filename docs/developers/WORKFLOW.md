# AlienFall Development Workflow

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

This guide covers the standard workflow for contributing to AlienFall: git, branching, committing, testing, and submitting changes.

---

## Table of Contents

- [Overview](#overview)
- [Git Branching Model](#git-branching-model)
- [Daily Workflow](#daily-workflow)
- [Commit Standards](#commit-standards)
- [Testing Workflow](#testing-workflow)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Common Scenarios](#common-scenarios)
- [Troubleshooting](#troubleshooting)

---

## Overview

**Goal**: Maintain clean history, enable collaboration, ensure quality through code review.

**Key Principles**:
- Use feature branches for all work
- Write clear commit messages
- Test before submitting
- Keep pull requests focused
- Respond to code reviews promptly

---

## Git Branching Model

### Branch Types

We use a simplified Git Flow model with these branch types:

| Branch | Purpose | Created From | Example |
|--------|---------|--------------|---------|
| **main** | Production-ready code | N/A (protected) | `main` |
| **develop** | Integration branch | `main` | `develop` |
| **feature/** | New features | `develop` | `feature/new-weapon-type` |
| **bugfix/** | Bug fixes | `develop` | `bugfix/line-of-sight-calc` |
| **hotfix/** | Emergency fixes to main | `main` | `hotfix/critical-crash` |
| **docs/** | Documentation updates | `develop` | `docs/battlescape-guide` |
| **refactor/** | Code organization | `develop` | `refactor/unit-system` |

### Branch Naming Convention

Use lowercase with hyphens:

```
feature/descriptive-name
bugfix/what-is-broken
docs/what-document
refactor/what-changes
hotfix/critical-issue
```

**Good examples**:
- `feature/stealth-system`
- `bugfix/crash-on-base-load`
- `docs/api-reference`

**Bad examples**:
- `Feature_NewWeapon` (capital, underscore)
- `fix` (too vague)
- `myBranch` (camelCase)

---

## Daily Workflow

### 1. Starting Your Day

```powershell
# Update local main from remote
cd C:\Dev\AlienFall
git checkout main
git pull origin main

# Check what branch you're on
git branch
# Output: * main

# Update develop
git checkout develop
git pull origin develop
```

### 2. Creating a Feature Branch

Always branch from `develop` (except hotfixes):

```powershell
# Create and switch to feature branch
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Verify you're on correct branch
git status
# On branch feature/my-feature
```

### 3. Regular Work Pattern

During your development session:

```powershell
# Make changes to files in your editor

# Check what changed
git status
# Shows: modified: engine/file.lua

# Preview changes
git diff

# Stage changes (add to commit)
git add engine/file.lua

# Or stage all changes
git add .

# Commit with clear message
git commit -m "Add new feature: [description]"

# Repeat: make changes → stage → commit
```

### 4. Before Submitting

```powershell
# Ensure your branch has latest develop
git fetch origin develop
git rebase origin/develop

# Verify all changes are committed
git status
# Should show: On branch feature/... nothing to commit

# Push to remote
git push origin feature/my-feature

# If branch doesn't exist on remote yet:
git push -u origin feature/my-feature
```

### 5. Completing Work

Once code is reviewed and ready to merge:

```powershell
# Merge typically done through pull request UI, but local merge:
git checkout develop
git pull origin develop
git merge feature/my-feature
git push origin develop

# Delete merged branch (optional, can also delete on GitHub)
git branch -d feature/my-feature
git push origin --delete feature/my-feature
```

---

## Commit Standards

### Commit Message Format

Use clear, descriptive commit messages following this format:

```
[Category] Brief description (50 chars max)

Optional detailed explanation (wrap at 72 chars).
Explain what and why, not how.

- Bullet points for multiple changes
- Keep related changes together
- Separate unrelated changes into multiple commits

Fixes: #123 (if closing an issue)
```

### Commit Categories

Use these prefixes for consistency:

| Category | Usage | Example |
|----------|-------|---------|
| **feat** | New feature | `feat: Add stealth system` |
| **fix** | Bug fix | `fix: Correct LOS calculation` |
| **docs** | Documentation | `docs: Update API reference` |
| **refactor** | Code restructuring | `refactor: Simplify unit init` |
| **perf** | Performance | `perf: Optimize pathfinding` |
| **test** | Test additions | `test: Add unit class tests` |
| **chore** | Maintenance | `chore: Update dependencies` |
| **ci** | CI/build changes | `ci: Add Windows test matrix` |
| **style** | Formatting/style | `style: Apply code formatting` |

### Good Commit Message Examples

**Example 1: Simple feature**
```
feat: Add weapon accuracy modifiers

Implement system for accuracy penalties based on:
- Distance to target
- Cover usage
- Weapon type

Modifiers stack to create realistic accuracy model.
```

**Example 2: Bug fix**
```
fix: Prevent nil reference in state transitions

The state manager was not checking for nil before
calling state methods. This caused crashes when
transitioning to states that aren't loaded yet.

Now validates state exists before transitioning.

Fixes: #234
```

**Example 3: Documentation**
```
docs: Document Battlescape accuracy system

Added comprehensive guide to accuracy calculation
including all modifiers and example scenarios.
```

### Commit Frequency

- Commit logical units of work (one feature ≠ one commit)
- Group related changes together
- Separate unrelated changes
- Aim for 3-10 commits per feature branch
- Each commit should work independently (don't break tests mid-branch)

---

## Testing Workflow

### Before Committing

```powershell
# 1. Run the game to verify no crashes
lovec "engine"

# 2. Check console for errors
# (Window should show debug output with no [ERROR] messages)

# 3. Test your specific changes manually
# (Load a save game, try the feature, verify it works)

# 4. Run tests (if applicable)
lua tests/runners/run_all_tests.lua
```

### Before Pushing

```powershell
# Verify no uncommitted changes
git status

# Review all commits before push
git log origin/develop..

# Run tests one more time
lua tests/runners/run_all_tests.lua

# Push when ready
git push origin feature/my-feature
```

### Testing Best Practices

- **Always test locally** before pushing
- **Verify with Love2D console** running (`lovec "engine"`)
- **Run full test suite** if you modified core systems
- **Test edge cases** your change might affect
- **Test on different platforms** if possible (Windows, Linux, macOS)

---

## Pull Request Process

### Creating a Pull Request

1. **Push your branch**:
   ```powershell
   git push origin feature/my-feature
   ```

2. **Go to GitHub** (or your platform)

3. **Create Pull Request**:
   - Select `develop` as target branch
   - Fill title and description
   - Link related issues with `Fixes: #123`

4. **PR Description Template**:
   ```markdown
   ## Description
   Brief summary of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation
   - [ ] Performance improvement
   - [ ] Refactoring

   ## Testing
   How did you test this?

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex logic
   - [ ] Documentation updated
   - [ ] Tests added/updated
   - [ ] All tests passing
   - [ ] No console errors when running
   ```

### During Review

- **Respond to feedback** promptly
- **Make requested changes** in new commits (don't rebase)
- **Mark conversations as resolved** after addressing
- **Request re-review** when ready
- **Don't merge your own PRs** (wait for approval)

### Merging

- **Merge strategy**: Use "Squash and Merge" for feature branches (keeps history clean)
- **Or use "Rebase and Merge"** for bug fixes
- **Avoid "Create a merge commit"** on GitHub (creates unnecessary commits)
- Delete branch after merging

---

## Code Review Guidelines

### Reviewing Others' Code

**As a reviewer, check for**:
- [ ] Code follows [Code Standards](../CODE_STANDARDS.md)
- [ ] Logic is correct and handles edge cases
- [ ] No performance regressions
- [ ] Comments explain non-obvious code
- [ ] Tests are included for new logic
- [ ] Documentation updated if needed
- [ ] No console errors when running

**How to leave feedback**:
```
Good: "This logic could use a bounds check for safety"
Bad: "This is wrong"

Good: "Consider extracting this into a helper function for reusability"
Bad: "Extract this function"
```

### Requesting Changes

- **Be specific** about what needs changing
- **Suggest solutions** but allow author flexibility
- **Approve improvements** that strengthen the code
- **Comment, don't block** for style preferences
- **Approve once addressed** to keep PRs moving

---

## Common Scenarios

### Scenario 1: Working on Multiple Features

```powershell
# You're on feature-1, need to start feature-2
git add .
git commit -m "WIP: feature-1 progress"
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# Later, switch back to feature-1
git checkout feature/feature-1

# You'll have exactly where you left it
```

### Scenario 2: Fixing Merge Conflicts

Merge conflicts occur when two branches change the same lines.

```powershell
# Pull latest develop
git fetch origin develop

# Try to rebase (clean way)
git rebase origin/develop

# Git shows conflict markers in files:
# <<<<<<< HEAD
# your code
# =======
# their code
# >>>>>>> origin/develop

# Edit files to resolve (or use VS Code's merge tool)
# Then:
git add resolved_file.lua
git rebase --continue

# Or abort if too complex:
git rebase --abort
git merge origin/develop  # Try regular merge instead
```

### Scenario 3: Accidentally Committed to Wrong Branch

```powershell
# You committed to main instead of feature branch
git reset HEAD~  # Undo the commit (keeps changes)

# Switch to correct branch
git checkout -b feature/correct-branch

# Commit changes on correct branch
git add .
git commit -m "feat: your changes"
```

### Scenario 4: Need to Update Branch from Develop

```powershell
# Make sure all your changes are committed
git status

# Update your branch with latest develop
git fetch origin develop
git rebase origin/develop

# If conflicts, resolve them (see Scenario 2)

# Force push your updated branch
git push -f origin feature/your-feature

# Note: -f (force push) only OK on your feature branches
# Never force push to main or develop
```

### Scenario 5: Oops, Pushed to Wrong Branch

```powershell
# You pushed commits to develop instead of feature branch
# First, undo the push (this requires permission)
git reset --hard HEAD~1  # Replace 1 with number of commits

# Create feature branch with those commits
git checkout -b feature/correct-branch

# Push to feature branch
git push -u origin feature/correct-branch

# Notify team - they may need to reset develop
```

---

## Troubleshooting

### "fatal: Your local changes to the following files would be overwritten"

**Problem**: Git won't switch branches because you have uncommitted changes.

**Solution**:
```powershell
# Option 1: Commit changes
git add .
git commit -m "WIP: current work"

# Option 2: Stash changes (temporarily store)
git stash
git checkout develop
# Later, restore:
git checkout your-branch
git stash pop
```

### "error: Your branch has diverged"

**Problem**: Your branch and remote have conflicting histories.

**Solution**:
```powershell
# Rebase to align histories
git fetch origin
git rebase origin/develop

# If that doesn't work:
git reset --hard origin/develop
```

### "Can't push - rejected by remote"

**Problem**: Push rejected, usually needs merge.

**Solution**:
```powershell
# Pull latest first
git pull origin feature/my-feature

# Then push
git push origin feature/my-feature
```

### "Can't merge - conflicts"

**Problem**: Merge conflicts when merging branches.

**Solution**:
```powershell
# See conflicts in files (<<<<<<< / ======= / >>>>>>>)
# Edit each file to resolve

# Mark as resolved
git add resolved_file.lua

# Complete merge
git commit
```

---

## Useful Git Commands Reference

```powershell
# View history
git log                              # Full log
git log --oneline                    # Compact log
git log --graph --decorate           # Visual graph
git log -p engine/file.lua           # Changes in specific file

# Compare changes
git diff                             # Unstaged changes
git diff --staged                    # Staged changes
git diff main feature/my-feature     # Between branches

# Branches
git branch                           # List local branches
git branch -a                        # List all branches
git branch -d branch-name            # Delete branch
git branch -m old-name new-name      # Rename branch

# Undoing things
git checkout filename.lua            # Discard changes in file
git reset HEAD filename.lua          # Unstage file
git reset --soft HEAD~1              # Undo commit, keep changes
git reset --hard HEAD~1              # Undo commit, discard changes
git revert HEAD~1                    # Create new commit undoing changes

# Remote operations
git fetch                            # Update from remote
git pull                             # Fetch + merge
git push                             # Push to remote
git push --force-with-lease          # Safer than force push
```

---

## Related Documentation

- **[Code Standards](../CODE_STANDARDS.md)** - Code style and naming
- **[Comment Standards](../COMMENT_STANDARDS.md)** - How to write comments
- **[Debugging Guide](DEBUGGING.md)** - Testing and debugging
- **[Setup Guide](SETUP_WINDOWS.md)** - Initial setup
- **[GitHub Help](https://docs.github.com/en)** - Git and GitHub documentation

---

**Last Updated**: October 2025 | **Status**: Active | **Difficulty**: Intermediate

