# 🔄 Git Workflow & Collaboration Best Practices

**Domain:** Version Control & Team Collaboration  
**Focus:** Async git workflows, merge strategies, code review, branch management  
**Version:** 1.0  
**Date:** October 2025

## Table of Contents

1. [Git Fundamentals](#git-fundamentals)
2. [Branch Strategy](#branch-strategy)
3. [Commit Best Practices](#commit-best-practices)
4. [Pull Request Workflow](#pull-request-workflow)
5. [Code Review](#code-review)
6. [Merge Strategies](#merge-strategies)
7. [Conflict Resolution](#conflict-resolution)
8. [Async Development](#async-development)
9. [Stashing & Temporary Work](#stashing--temporary-work)
10. [Git Workflows for AI Agents](#git-workflows-for-ai-agents)
11. [Debugging Git History](#debugging-git-history)
12. [Team Practices](#team-practices)
13. [Performance](#performance)
14. [Disaster Recovery](#disaster-recovery)
15. [Common Git Mistakes](#common-git-mistakes)

---

## Git Fundamentals

### ✅ DO: Atomic Commits with Clear Messages

**What:** Each commit represents ONE logical change.

```bash
# Good: Atomic commits
git commit -m "Fix unit pathfinding corner case

- Quadtree now correctly handles edge cells
- Units no longer get stuck in corners
- Added regression test for corner cases
- Performance impact: none
- Fixes: #542"

# Bad: Multiple unrelated changes
git commit -m "Fixed stuff and updated UI and tweaked balance"
```

**Anatomy of good commit message:**
```
[Type] Brief summary (50 chars max)

Detailed explanation of what changed and why.
- List key changes
- Explain non-obvious decisions
- Reference issue numbers

Fixes: #123
Related: #124
```

**Commit types:**
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code restructure (no behavior change)
- `perf:` Performance improvement
- `test:` Test additions/changes
- `docs:` Documentation
- `chore:` Tooling, config, dependencies

---

### ✅ DO: Sign Commits (Optional but Recommended)

```bash
# Configure git signing
git config --global user.signingkey YOUR_GPG_KEY
git config --global commit.gpgsign true

# Commits are now cryptographically signed
git commit -m "Implement new AI system"

# Verify signature
git log --show-signature
```

**Benefits:**
- Verifies code authenticity
- Prevents impersonation
- Required for many projects

---

### ❌ DON'T: Commit Sensitive Information

**Bad:**
```lua
-- DON'T COMMIT THIS
local apiKey = "sk-1234567890abcdef"
local serverPassword = "admin123"
```

**Good:**
```lua
-- Use environment variables or config files
local apiKey = os.getenv("API_KEY")
if not apiKey then
    error("API_KEY environment variable not set")
end
```

Use `.gitignore`:
```
.env
config/secrets.json
*.key
*.pem
```

---

## Branch Strategy

### ✅ DO: Use Git Flow Strategy

**Three main branches:**

```
main (release branch)
  ↑ (merged from release)
  |
release/1.2.0 (staging)
  ↑ (merged from features)
  |
develop (integration branch)
  ↑ (merged from features)
  |
feature/new-feature (work branch)
feature/fix-bug
feature/performance-tweak
```

**Branch naming conventions:**

```bash
# Features
git checkout -b feature/add-sniper-unit
git checkout -b feature/improve-ai-squad-tactics

# Bug fixes
git checkout -b fix/pathfinding-corner-case
git checkout -b fix/memory-leak-particles

# Performance
git checkout -b perf/reduce-draw-calls
git checkout -b perf/optimize-collision-checks

# Refactoring
git checkout -b refactor/entity-component-system
git checkout -b refactor/consolidate-ui-code
```

---

### ✅ DO: Keep Branches Short-Lived

**Best practice:** Merge within 3-7 days

```bash
# Good workflow
Day 1: git checkout -b feature/new-weapon
Days 2-3: Implement and test
Day 3: Create PR, code review
Day 4: Address feedback and merge

# Bad: Long-lived branches cause issues
# Weeks of work = conflicts, hard to review, blocks others
```

**Why short-lived branches matter:**
- Easier code review (smaller diff)
- Less merge conflicts
- Faster integration
- Better for team coordination

---

## Commit Best Practices

### ✅ DO: Use Interactive Rebase to Clean Up

Before pushing, clean up commits:

```bash
# Rebase last 5 commits
git rebase -i HEAD~5

# Squash intermediate commits:
# pick f7f3f6d Add feature
# squash 310154e Fix typo
# squash a402156 Update test
# squash 7f6e4a9 Fix lint

# Result: 1 clean commit instead of 4
```

**When to use rebase:**
- Before creating PR (clean up local work)
- Squash related commits
- Fix commit messages
- Reorder commits logically

**Don't use if:** Commits already pushed to main branch

---

### ✅ DO: Reference Issues in Commits

```bash
# Reference related issue
git commit -m "Implement new weapon type

- Sniper rifle: high damage, slow reload
- Affects: Unit balancing system
- Fixes: #542
- Related: #541 (equipment system)"

# GitHub automatically links and closes issues
# When PR is merged: issue #542 auto-closes
```

---

### ❌ DON'T: Commit Work-in-Progress Code

**Bad:** Committing broken/incomplete code to main branches

```bash
# DON'T do this:
git commit -m "WIP: Trying new AI approach"

# DO THIS instead:
git stash  # Save work locally
# Or use feature branch:
git checkout -b feature/experimental-ai
git commit -m "Experimental AI approach (not for review yet)"
```

---

## Pull Request Workflow

### ✅ DO: Create Descriptive Pull Requests

**Good PR description:**

```markdown
# Add Sniper Unit Type

## Description
Adds new "sniper" unit type with high damage and slow reload.
This provides tactical diversity - players must choose between
aggressive soldiers and tactical snipers.

## Changes
- Added sniper stats (60 damage, 85 accuracy, 3s reload)
- Created sniper sprite (24x24 pixel art)
- Updated unit factory to spawn sniper units
- Added 3 balance tests

## Performance Impact
- Memory: +2KB per sniper unit (negligible)
- CPU: No change (same AI as soldiers)

## Testing
- Tested in single-player battle
- Verified stats vs. reference values
- Tested with 20 enemy snipers (no FPS drop)

## Breaking Changes
None - purely additive

## Screenshots/Videos
[Link to gameplay video showing sniper]

## Checklist
- [x] Code follows style guide
- [x] Tests added/updated
- [x] Documentation updated
- [x] No console errors
- [x] Performance tested
```

---

### ✅ DO: Use Draft PRs for Feedback

```bash
# Create as draft while still working
git push -u origin feature/new-weapon

# Create PR, mark as "Draft"
# GitHub: "Still in progress" indicator

# When ready: Click "Ready for review"
```

**Use cases for draft PRs:**
- Get early feedback
- Discuss approach before finishing
- Block accidental merges
- Keep team informed of progress

---

### ✅ DO: Rebase Before Merging (When Appropriate)

```bash
# Option 1: Rebase (linear history)
git checkout develop
git pull
git checkout feature/my-feature
git rebase develop
git push -f  # Force push to your feature branch
# Then merge via GitHub: "Rebase and merge"

# Option 2: Merge commit (preserves history)
# GitHub: "Create a merge commit"
```

**When to rebase:** Feature branches (cleaner history)
**When to merge:** Main integration branches (preserve history)

---

## Code Review

### ✅ DO: Constructive Code Review

**As reviewer:**

```markdown
# Code Review Feedback

## ✅ Good (Positive)
- Love the object pooling approach, great performance optimization!
- Clear naming makes this very readable
- Tests are thorough, covers edge cases well

## 🤔 Questions
- Why use `ipairs` here instead of `pairs`? Performance consideration?
- What happens if `dt` is negative? Should we add validation?

## 🛠️ Suggestions
- Consider extracting `calculateDistance()` to utils module (reusable)
- Could use memoization for expensive distance calculations
- Recommend adding error handling for nil entity parameter

## 🚨 Issues
- Line 45: Variable `x` is used before being defined
- Missing bounds check: Could crash if coordinates out of range
- Memory leak: Strings created in loop but not freed

## Summary
Overall great implementation. Address the 3 issues above and this is ready to merge.
```

**Code review tone:**
- ✅ Constructive (help them improve)
- ✅ Specific (show exact line/issue)
- ✅ Educational (explain why)
- ❌ Dismissive ("That's wrong")
- ❌ Vague ("Looks bad")
- ❌ Demands ("Fix it")

---

### ✅ DO: Review for Multiple Dimensions

**What to check:**

1. **Correctness** - Does it do what it claims?
2. **Quality** - Is code readable, maintainable?
3. **Performance** - Any optimization concerns?
4. **Tests** - Is code properly tested?
5. **Style** - Follows project conventions?
6. **Security** - Any security implications?
7. **Documentation** - Is it documented?

---

### ❌ DON'T: Approve Without Understanding

**Bad review:**
```
👍 Looks good to me
```

**Good review:**
```
I reviewed the code and:
- Tested locally with 100 units
- Verified performance impact (2% improvement)
- Checked for memory leaks (none found)
- All tests pass
Approved!
```

---

## Merge Strategies

### ✅ DO: Choose Appropriate Merge Strategy

**Three main options:**

```bash
# 1. Squash and merge (feature branches)
# Combines all commits into one
# Clean history, good for features
git merge --squash feature/my-feature

# 2. Rebase and merge (clean linear history)
# Reapplies commits on top of main
# Very clean, good for small features
git merge --rebase feature/my-feature

# 3. Merge commit (preserve history)
# Creates merge commit
# Preserves branch history, good for main branches
git merge --no-ff feature/my-feature
```

**Recommendation:**
- Feature branches → Squash (clean history)
- Develop → Rebase (linear history)
- Main release → Merge commit (preserve history)

---

### ✅ DO: Auto-Delete Merged Branches

```bash
# Delete local branches after merge
git branch -d feature/my-feature

# Or use GitHub setting: "Automatically delete head branches"
```

**Why:** Prevents branch clutter and confusion.

---

## Conflict Resolution

### ✅ DO: Handle Merge Conflicts Gracefully

**When conflicts occur:**

```bash
# 1. Start merge
git merge feature/other-feature

# 2. Git reports conflicts
# CONFLICT (content): Merge conflict in engine/battle.lua

# 3. Edit conflicted file
# Look for conflict markers:
# <<<<<<< HEAD (current branch)
# our_code_here
# =======
# their_code_here
# >>>>>>> feature/other-feature

# 4. Resolve manually
# Remove conflict markers, keep both changes if appropriate
# Or choose one version

# 5. Complete merge
git add engine/battle.lua
git commit -m "Resolve merge conflict in battle.lua"
```

---

### ✅ DO: Use Merge Tools for Complex Conflicts

```bash
# Configure merge tool
git config merge.tool vimdiff
git config merge.conflictstyle diff3  # Shows base version too

# Launch merge tool
git mergetool engine/battle.lua
```

**Visual merge tools:**
- Vimdiff (terminal)
- Meld (GUI, Linux/Mac)
- KDiff3 (GUI, cross-platform)
- Beyond Compare (GUI, paid)

---

### ✅ DO: Test After Merging

```bash
# After resolving conflicts:
./run_tests.bat  # Verify nothing broke
lovec engine     # Test game runs
```

**Why:** Merge conflicts can introduce bugs silently.

---

## Async Development

### ✅ DO: Structure Work for Parallel Development

**Good structure (minimal conflicts):**

```
engine/
├── battlescape/
│   ├── ai/          ← Person A works here
│   └── units.lua    (only Person A touches)
├── basescape/
│   └── base.lua     ← Person B works here
├── geoscape/
│   └── map.lua      ← Person C works here
└── shared/
    └── utils.lua    (everyone might touch)
```

**Bad structure (many conflicts):**

```
engine/
└── game.lua         ← Everyone touches this one file
                     High conflict probability!
```

---

### ✅ DO: Use Feature Flags for In-Progress Work

```lua
-- In config or environment
local FEATURES = {
    NEW_AI_SYSTEM = false,        -- In development
    SQUAD_TACTICS = true,          -- Complete
    DIFFICULTY_SCALING = false,    -- Not started
}

-- Use in code
if FEATURES.NEW_AI_SYSTEM then
    updateAINewSystem(units, dt)
else
    updateAILegacy(units, dt)
end
```

**Benefits:**
- Incomplete features don't break build
- Can merge to main without affecting players
- Easy to enable during testing

---

### ✅ DO: Create Integration Checkpoints

Every 3-4 days: All branches merge to develop

```bash
# Person A
git checkout develop
git pull
git merge --squash feature/new-weapon
git push

# Person B
git checkout develop
git pull
git merge --squash feature/ai-improvement
git push

# Result: Integrated every few days, not at end of sprint
```

---

## Stashing & Temporary Work

### ✅ DO: Use Stash for Context Switching

```bash
# Interrupted by urgent bug fix
# Save current work
git stash save "WIP: experimental AI approach"

# Switch branches and fix bug
git checkout -b fix/critical-crash
# ... fix and push ...

# Return to original work
git checkout feature/experimental-ai
git stash pop

# Continue where you left off
```

---

### ✅ DO: Use Stash Strategically

```bash
# Stash specific files only
git stash push -m "WIP: UI changes" -- engine/ui/

# List stashes
git stash list
# stash@{0}: WIP: UI changes
# stash@{1}: WIP: AI approach

# Apply specific stash
git stash apply stash@{0}

# Clear old stashes
git stash drop stash@{5}
```

---

## Git Workflows for AI Agents

### ✅ DO: Make Frequent, Small Commits

AI agents should commit often:

```bash
# AI workflow (every 30-60 min of work)
git add .
git commit -m "feat: Add component X to system Y

- Implemented core functionality
- Added tests (50 lines)
- Performance verified: <1ms
- Ready for review"

git push origin feature/my-feature
```

**Benefits:**
- Easy to review incremental progress
- Can restart from checkpoint if issue found
- Shows work progress to team
- Safe to update PR with latest main

---

### ✅ DO: Use Branches for Experiments

```bash
# Try new approach without affecting main work
git checkout -b experimental/quadtree-optimization
# ... implement and test ...

# If successful: cherry-pick changes
# If not: git branch -D experimental/quadtree-optimization

# From main branch:
git cherry-pick experimental/quadtree-optimization~3..experimental/quadtree-optimization
```

---

## Debugging Git History

### ✅ DO: Use Git Log for Investigation

```bash
# View commit history
git log --oneline -10

# View with graph (shows branches)
git log --oneline --graph --all

# View commits by person
git log --author="Person Name"

# View commits in time range
git log --since="2025-01-01" --until="2025-10-16"

# Search commit messages
git log --grep="memory leak"

# Find when bug was introduced
git log -p engine/battle.lua | grep -B5 "bug_code"
```

---

### ✅ DO: Use Bisect to Find Problem Commit

```bash
# Know: bug exists in current code, doesn't exist in v1.0
git bisect start
git bisect bad      # Current (buggy)
git bisect good v1.0  # Known good

# Git checks out middle commit
# Test: is bug present?
git bisect bad      # Bug is here
# ... Git narrows down further ...

# Eventually: found the commit that introduced bug
git bisect reset    # Return to current
```

---

### ✅ DO: Use Reflog to Recover Lost Commits

```bash
# Accidentally deleted branch
git reflog
# abc123d HEAD@{0}: checkout: switching to main
# def456g HEAD@{1}: commit: my important work
# ghi789j HEAD@{2}: checkout: switching to feature/test

# Recover
git checkout -b recovered def456g
```

---

## Team Practices

### ✅ DO: Establish Git Conventions

Document in CONTRIBUTING.md:

```markdown
# Git Conventions

## Branch Naming
- feature/description (new features)
- fix/description (bug fixes)
- perf/description (optimizations)

## Commit Messages
- Use present tense: "Add" not "Added"
- Reference issues: "Fixes #123"
- Be specific: "Fix unit pathfinding" not "Fixed stuff"

## Pull Requests
- Require 1 code review minimum
- Require tests for new code
- Require documentation for new features
- Auto-delete merged branches

## Merging
- Squash commits for features (clean history)
- Rebase for small changes
- Merge commits for integration branches

## When Stuck
- Ask in #git-help
- Use `git reflog` to recover deleted commits
- Use `git bisect` to find problem commit
```

---

### ✅ DO: Code Review in Groups (For Learning)

```bash
# Team review (learning opportunity)
# Share screen and discuss code together
git show feature/my-feature:path/to/file.lua

# Discuss design, patterns, alternatives
# Leave written feedback in PR too
```

---

### ✅ DO: Document Hotfixes

```bash
# Critical bug in production
git checkout -b hotfix/critical-crash main

# Fix immediately
git commit -m "hotfix: Fix crash on save game

Emergency fix for production crash.
Temporary workaround until proper fix in develop."

git push origin hotfix/critical-crash

# PR to main: "Hotfix: Critical crash"
# After merge: also merge back to develop to stay in sync
```

---

## Performance

### ✅ DO: Shallow Clone for Large Repos

```bash
# Only get recent history (much faster)
git clone --depth 1 https://github.com/bladum/projects.git

# Still can access latest code and make commits
git push origin feature/my-feature

# Later, if needed, get full history
git fetch --unshallow
```

---

### ✅ DO: Use git gc Periodically

```bash
# Optimize repository (runs on server automatically)
git gc --aggressive

# Cleans up and compacts repository
# Reduces disk space usage
```

---

## Disaster Recovery

### ✅ DO: Backup Important Branches

```bash
# Create safety tag before big merge
git tag backup/before-major-merge

# If merge goes wrong: recover
git reset --hard backup/before-major-merge
```

---

### ✅ DO: Recover Deleted Commits

```bash
# Find commit you thought was deleted
git reflog

# Recreate branch
git checkout -b recovered-branch abc123d
```

---

## Common Git Mistakes

### ❌ Mistake: Committing to Wrong Branch

```bash
# Oops, committed to main instead of feature branch
git reset HEAD~1  # Undo last commit (keep changes)
git stash         # Save changes
git checkout -b feature/my-feature
git stash pop     # Apply changes
git commit -m "My feature"
```

---

### ❌ Mistake: Large Commits That Break Review

```bash
# DON'T: One massive 50-file commit
git commit -am "Rewrote entire engine"

# DO: Many small commits
git add engine/utils.lua
git commit -m "refactor: Simplify utility functions"

git add engine/entity.lua
git commit -m "refactor: Extract entity pooling logic"

git add engine/battle.lua
git commit -m "refactor: Update battle to use new entity system"
```

---

### ❌ Mistake: Unclear Commit Messages

```bash
# BAD
git commit -m "fix"
git commit -m "updates"
git commit -m "stuff"

# GOOD
git commit -m "Fix pathfinding units getting stuck in corners"
git commit -m "Update UI font sizes for accessibility"
git commit -m "Add comprehensive error handling to parser"
```

---

### ❌ Mistake: Not Using Branches

```bash
# DON'T: Work directly on main
git checkout main
# ...edit file...
git push

# DO: Always use feature branches
git checkout -b feature/my-work
# ...edit file...
git push origin feature/my-work
# Create PR, get review
```

---

## Git Workflow Checklist

- [ ] Use feature branches for all work
- [ ] Commit atomically (one logical change per commit)
- [ ] Write clear commit messages
- [ ] Keep branches short-lived (< 1 week)
- [ ] Reference issues in commits/PRs
- [ ] Require code review before merge
- [ ] Test after merge (especially after conflicts)
- [ ] Delete merged branches
- [ ] Use rebasing to keep history clean
- [ ] Document git conventions for team

---

## References

- Git Official: https://git-scm.com/book/en/v2
- Conventional Commits: https://www.conventionalcommits.org/
- GitHub Flow: https://guides.github.com/introduction/flow/
- Atlassian Git Tutorials: https://www.atlassian.com/git/tutorials

