# Phase 4 Migration Tools - PowerShell Automation

## MIGRATION TOOLKIT

This directory contains PowerShell scripts to automate the engine restructuring migration.

### Scripts Overview

1. **1_PrepareMigration.ps1** - Validation and preparation
2. **2_CopyFilesToNewStructure.ps1** - Copy files to new locations
3. **3_UpdateImportsInEngine.ps1** - Update requires() in engine files
4. **4_UpdateImportsInTests.ps1** - Update requires() in test files
5. **5_ReorganizeTestMock.ps1** - Reorganize test mock data
6. **6_DeleteOldDirectories.ps1** - Clean up old directories
7. **7_ValidateStructure.ps1** - Verify migration completed
8. **RunAllMigrationSteps.ps1** - Master script to run all steps

### Before Running

1. Ensure you're in project root: `c:\Users\tombl\Documents\Projects`
2. Backup everything: `git stash` or create backup branch
3. Review Phase 3 plan: `PHASE_3_DETAILED_MIGRATION_PLAN.md`
4. Have Love2D console ready for testing

### Running Migration

```powershell
# Option 1: Run individual scripts
.\migrate\1_PrepareMigration.ps1
.\migrate\2_CopyFilesToNewStructure.ps1
# etc...

# Option 2: Run everything at once
.\migrate\RunAllMigrationSteps.ps1 -Verbose

# Option 3: Dry-run mode (see what would change, don't do it)
.\migrate\1_PrepareMigration.ps1 -DryRun
```

### Critical Assumptions

- Running from project root
- Git repository initialized (for backup capability)
- Love2D console available at `C:\Program Files\LOVE\lovec.exe`
- PowerShell 5.1+ (Windows native)

### Rollback

If anything goes wrong:

```powershell
# Undo recent commits
git reset --hard HEAD~1

# Or restore from backup
git checkout migration-backup
```
