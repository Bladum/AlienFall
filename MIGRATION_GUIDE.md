# Engine Restructure - Migration Guide

This guide explains how to use the automated migration scripts to restructure the `engine/` folder.

## 📋 Prerequisites

- ✅ All changes committed to git
- ✅ PowerShell available
- ✅ Love2D 12.0+ installed
- ✅ Backup of important work (scripts create backup branch, but be safe!)

## 🚀 Quick Start (Recommended)

### Step 1: Test with Dry Run

First, see what would happen without making changes:

```powershell
# From project root: c:\Users\tombl\Documents\Projects\
.\migrate_engine_structure.ps1 -DryRun
```

This will show you:
- Which folders will be created
- Which files will be moved
- What cleanup will happen

### Step 2: Run the Migration

If dry run looks good, run for real:

```powershell
.\migrate_engine_structure.ps1
```

This will:
1. ✅ Create backup branch `backup/pre-restructure-TIMESTAMP`
2. ✅ Create new folder structure
3. ✅ Move all files to new locations
4. ✅ Clean up empty folders
5. ✅ Show summary of changes

**Time:** ~2-3 minutes

### Step 3: Fix Require Paths

Test what require paths will be updated:

```powershell
.\fix_require_paths.ps1 -DryRun
```

Then run for real:

```powershell
.\fix_require_paths.ps1
```

This automatically updates ~50+ require() statements in all Lua files.

**Time:** ~1 minute

### Step 4: Verify and Test

Run the game with Love2D console:

```powershell
lovec engine
```

Check console output for:
- ❌ "module 'X' not found" errors (bad - need to fix require paths)
- ✅ Clean launch with no errors (good!)

Test all game modes:
- Main Menu
- Geoscape
- Battlescape (create battle, move units)
- Basescape
- Map Editor
- Widget Showcase

### Step 5: Manual Fixes (If Needed)

If you see "module not found" errors:

1. **Check the error message** - tells you which module failed
2. **Find the file** using Quick Reference guide
3. **Update require path** according to mapping table
4. **Re-run game** and verify

Example:
```
Error: module 'systems.weapon_system' not found
→ Change to: require("battlescape.combat.weapon_system")
```

### Step 6: Commit Changes

Once everything works:

```powershell
git add .
git commit -m "Complete engine restructure - all modes functional"
```

---

## 📖 Reference Documents

- **`tasks/TODO/TASK-ENGINE-RESTRUCTURE.md`** - Complete implementation plan
- **`tasks/TODO/ENGINE-RESTRUCTURE-QUICK-REFERENCE.md`** - File location lookup table
- **`tasks/TODO/ENGINE-RESTRUCTURE-VISUAL-COMPARISON.md`** - Before/after comparison

---

## 🔧 Script Options

### migrate_engine_structure.ps1

```powershell
# Dry run (safe - no changes)
.\migrate_engine_structure.ps1 -DryRun

# Full migration
.\migrate_engine_structure.ps1

# Skip backup branch (NOT RECOMMENDED)
.\migrate_engine_structure.ps1 -SkipBackup
```

### fix_require_paths.ps1

```powershell
# Dry run (safe - no changes)
.\fix_require_paths.ps1 -DryRun

# Fix all require paths
.\fix_require_paths.ps1
```

---

## ⚠️ Troubleshooting

### "Module not found" errors

**Problem:** Game crashes with "module 'X' not found"

**Solution:**
1. Check which module is missing from error message
2. Look up correct path in `ENGINE-RESTRUCTURE-QUICK-REFERENCE.md`
3. Update require statement in the file
4. Re-run game

### Files in wrong location

**Problem:** File ended up in wrong folder after migration

**Solution:**
```powershell
# Move manually
Move-Item engine\old\path\file.lua engine\new\path\file.lua

# Update require paths again
.\fix_require_paths.ps1
```

### Need to rollback

**Problem:** Something went wrong, need to undo

**Solution:**
```powershell
# Find your backup branch
git branch | Select-String "backup/pre-restructure"

# Restore from backup
git checkout backup/pre-restructure-TIMESTAMP

# Create new working branch
git checkout -b restructure-attempt-2
```

### Some files weren't moved

**Problem:** Migration script missed some files

**Solution:**
1. Check if files existed before migration
2. Manually move using `Move-Item`
3. Update require paths
4. Report issue so script can be improved

---

## 🎯 Success Criteria

- [x] Game launches without errors
- [x] All modes accessible (Menu, Geoscape, Battlescape, Basescape)
- [x] Can create battle and move units
- [x] Map editor opens and works
- [x] Widget showcase displays correctly
- [x] No console errors or warnings
- [x] Tests run successfully: `love scripts/run_test.lua`

---

## 📊 What Gets Changed

### New Folders Created
- `engine/core/` - Essential systems
- `engine/shared/` - Multi-mode systems
- `engine/battlescape/` - Consolidated tactical combat
- `engine/geoscape/` - Strategic layer
- `engine/basescape/` - Base management
- `engine/interception/` - Future craft combat
- `engine/menu/` - Menu screens
- `engine/tools/` - Development tools
- `engine/scripts/` - Utility scripts

### Files Moved
- ~50+ files reorganized
- All `battle/` files → `battlescape/`
- `modules/battlescape/` → `battlescape/ui/`
- Core systems → `core/`
- Shared systems → `shared/`
- Combat systems → `battlescape/combat/`
- Tools and scripts → dedicated folders

### Require Paths Updated
- ~100+ require statements across all Lua files
- Automatic pattern matching and replacement
- All paths updated to match new structure

---

## 💡 Tips

1. **Run dry runs first** - Always use `-DryRun` to preview changes
2. **Keep backup branch** - Don't delete until fully validated
3. **Test incrementally** - Test after each phase if needed
4. **Watch console** - Love2D console shows all errors clearly
5. **Use quick reference** - Keep quick reference guide open
6. **Commit often** - Commit after each successful phase

---

## 📝 After Migration Checklist

- [ ] Run migration script successfully
- [ ] Fix require paths with script
- [ ] Game launches without errors
- [ ] All modes tested and working
- [ ] Tools functional (map editor, etc.)
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Changes committed to git
- [ ] Backup branch can be deleted
- [ ] Update `wiki/DEVELOPMENT.md` with new structure

---

## 🆘 Getting Help

If you encounter issues:

1. Check console output for specific errors
2. Review quick reference guide for correct paths
3. Look at visual comparison for structure overview
4. Check task document for detailed migration steps
5. Restore from backup branch if needed

---

## ⏱️ Time Estimate

| Phase | Time | Difficulty |
|-------|------|------------|
| Dry runs | 5 min | Easy |
| Run migration | 3 min | Easy |
| Fix require paths | 2 min | Easy |
| Test and verify | 15 min | Medium |
| Manual fixes (if needed) | 10-30 min | Medium |
| **Total** | **25-55 min** | **Medium** |

*Much faster than manual migration (estimated 5.5 hours)!*

---

## 🎉 Benefits After Migration

- ✅ **Clear organization** - Each mode in its own folder
- ✅ **Scalable structure** - Easy to add new modes
- ✅ **Better discoverability** - Obvious where to find code
- ✅ **Clean root** - No clutter in engine/ root
- ✅ **Mod-friendly** - Clear separation for mod hooks
- ✅ **Maintainable** - Related code grouped together

---

Generated: October 13, 2025
Part of TASK-ENGINE-RESTRUCTURE
