# 🎯 TASK-006 COMPLETE PLANNING DOCUMENTATION

**Project:** AlienFall/XCOM Simple - Engine Restructuring  
**Status:** Planning phases COMPLETE (4 of 7 phases done)  
**Date:** October 25, 2025  

---

## 📚 DOCUMENTATION INDEX

This is your navigation guide to all TASK-006 planning and execution documents.

### 📖 START HERE

**[TASK_006_PHASE_4_COMPLETE.md](TASK_006_PHASE_4_COMPLETE.md)**
- ✅ Current status summary
- ✅ Phase 4 deliverables (7 migration scripts)
- ✅ How to run the migration
- ✅ Overall progress (57% complete)
- **👉 Read this first for current state**

---

## 📋 PLANNING DOCUMENTS (Read in Order)

### 1. Current Problems & Audit

**[temp/engine_structure_audit.md](temp/engine_structure_audit.md)**
- Problem: 16 top-level engine folders, inconsistent organization
- Finding: 8 major organization issues identified
- Scope: Analysis of current structure
- **Read first to understand the problem**

### 2. Organization Standards

**[docs/ENGINE_ORGANIZATION_PRINCIPLES.md](docs/ENGINE_ORGANIZATION_PRINCIPLES.md)**
- Solution: 11 principles for reorganization
- Structure: Hierarchical (core → systems → layers → ui)
- Standards: Naming, dependencies, organization rules
- **Read second to understand the solution**

### 3. Cross-System Impact

**[CROSS_FOLDER_IMPACT_ANALYSIS.md](CROSS_FOLDER_IMPACT_ANALYSIS.md)**
- Impact: What changes in api/, architecture/, design/, tests/, etc.
- Analysis: 6 folders affected, 150+ files, 18-27 hours total
- Risk Assessment: What could break where
- **Read third to understand full scope**

### 4. Detailed Migration Plan

**[PHASE_3_DETAILED_MIGRATION_PLAN.md](PHASE_3_DETAILED_MIGRATION_PLAN.md)**
- Plan: File-by-file breakdown of what moves where
- Scope: 100+ files, 14 directory moves, 50+ import updates
- Checklists: Phase-by-phase execution checklist
- **Read fourth for implementation details**

### 5. What Changes Where

**[RECOMMENDED_CHANGES_BY_FOLDER.md](RECOMMENDED_CHANGES_BY_FOLDER.md)**
- Decisions: What should change, what should stay same
- Folder Guide: Specific recommendations for each folder
- Examples: Before/after code examples
- **Read fifth for guidance on changes**

---

## 🚀 EXECUTION DOCUMENTS

### Migration Automation Tools

**[migrate/](migrate/)** - Automated PowerShell migration scripts
- ✅ [migrate/README.md](migrate/README.md) - Start here
- ✅ [1_PrepareMigration.ps1](migrate/1_PrepareMigration.ps1)
- ✅ [2_CopyFilesToNewStructure.ps1](migrate/2_CopyFilesToNewStructure.ps1)
- ✅ [3_UpdateImportsInEngine.ps1](migrate/3_UpdateImportsInEngine.ps1)
- ✅ [4_UpdateImportsInTests.ps1](migrate/4_UpdateImportsInTests.ps1)
- ✅ [5_ReorganizeTestMock.ps1](migrate/5_ReorganizeTestMock.ps1)
- ✅ [6_DeleteOldDirectories.ps1](migrate/6_DeleteOldDirectories.ps1)
- ✅ [7_ValidateStructure.ps1](migrate/7_ValidateStructure.ps1)
- ✅ [RunAllMigrationSteps.ps1](migrate/RunAllMigrationSteps.ps1) - Master runner

### Execution Guide

**[PHASE_4_COMPLETE_SUMMARY.md](PHASE_4_COMPLETE_SUMMARY.md)**
- Usage: How to run the migration scripts
- Safety: Pre-flight checks and rollback procedures
- Timeline: Estimated time for each phase
- FAQ: Common questions answered
- Troubleshooting: How to fix issues

---

## 🗂️ FOLDER ORGANIZATION AFTER MIGRATION

### Current Structure (Before)
```
engine/
├── core/                  ← foundation systems
├── utils/                 ← general utilities (MOVE to core/utils)
├── ai/                    ← game systems (MOVE to systems/)
├── economy/               ← game systems (MOVE to systems/)
├── politics/              ← game systems (MOVE to systems/)
├── analytics/             ← game systems (MOVE to systems/)
├── content/               ← game systems (MOVE to systems/)
├── lore/                  ← game systems (MOVE to systems/)
├── tutorial/              ← game systems (MOVE to systems/)
├── geoscape/              ← game layers (MOVE to layers/)
├── basescape/             ← game layers (MOVE to layers/)
├── battlescape/           ← game layers (MOVE to layers/)
├── interception/          ← game layers (MOVE to layers/)
├── gui/                   ← UI systems (MOVE to ui/)
├── widgets/               ← UI widgets (MOVE to ui/widgets/)
└── [other folders]
```

### New Structure (After)
```
engine/
├── core/                  ← Foundation systems
│   ├── state_manager.lua
│   ├── event_system.lua
│   ├── time_manager.lua
│   └── utils/             ← General utilities (moved from root)
├── systems/               ← ✨ NEW: Horizontal game systems
│   ├── ai/
│   ├── economy/
│   ├── politics/
│   ├── analytics/
│   ├── content/
│   ├── lore/
│   └── tutorial/
├── layers/                ← ✨ NEW: Vertical game layers
│   ├── geoscape/
│   ├── basescape/
│   ├── battlescape/
│   └── interception/
├── ui/                    ← ✨ RENAMED from gui/
│   ├── framework.lua
│   ├── elements.lua
│   └── widgets/           ← Nested under ui/
├── accessibility/         ← Infrastructure (no change)
├── mods/                  ← Infrastructure (no change)
├── network/               ← Infrastructure (no change)
├── portal/                ← Infrastructure (no change)
├── assets/                ← Infrastructure (no change)
├── localization/          ← Infrastructure (no change)
├── main.lua               ← Entry point
└── conf.lua               ← Love2D config
```

---

## 📊 PROGRESS TRACKING

### TASK-006 Phases

| # | Phase | Status | Output | Hours |
|---|-------|--------|--------|-------|
| 0 | Audit | ✅ DONE | engine_structure_audit.md | 2-3 |
| 1 | Principles | ✅ DONE | ENGINE_ORGANIZATION_PRINCIPLES.md | 2-3 |
| 2 | Cross-Folder | ✅ DONE | CROSS_FOLDER_IMPACT_ANALYSIS.md | 2-3 |
| 3 | Detailed Plan | ✅ DONE | PHASE_3_DETAILED_MIGRATION_PLAN.md | 2-3 |
| 4 | Tools | ✅ DONE | 7 migration scripts + docs | 3-4 |
| 5 | Execute Engine | ⏳ NEXT | Restructure engine folders | 7-10 |
| 6 | Execute Tests | ⏳ NEXT | Update 50+ test files | 4-6 |
| 7 | Execute Docs | ⏳ NEXT | Update 20+ doc files | 3-4 |

**Completion: 57% (Phases 0-4 complete, ready for 5-7)**

### Related Tasks

| Task | Status | Related To | Blocked By |
|------|--------|-----------|-----------|
| TASK-004 | ✅ COMPLETE | Content validator | None |
| TASK-005 | ✅ COMPLETE | TOML IDE setup | None |
| **TASK-006** | 🟡 IN PROGRESS | Engine restructuring | None (ready) |
| TASK-007 | ❌ NOT STARTED | Engine READMEs | TASK-006 Phase 5 |
| TASK-008 | ❌ NOT STARTED | Architecture review | TASK-006 Phase 5 |
| TASK-009 | ✅ COMPLETE | Mods organization | None |
| TASK-010 | ✅ COMPLETE | Validators | None |

**Overall: 4/7 tasks complete (57%)**

---

## 🎯 KEY DECISIONS

### What Changes
- ✅ Folder structure (hierarchical)
- ✅ Import paths (28 patterns updated)
- ✅ Test mock structure (mirrors engine)
- ✅ Documentation references (path updates)
- ✅ Tool configurations (import scanner)

### What Stays the Same
- ✅ Game logic (no behavior changes)
- ✅ TOML configuration format (no changes)
- ✅ System interfaces (same contracts)
- ✅ Data structures (same entities)
- ✅ Code standards (same practices)

### Why This Structure?
1. **Hierarchical** - Easier to navigate
2. **Layered** - Separates concerns
3. **Scalable** - Easy to add new systems
4. **Discoverable** - Logical folder names
5. **Documented** - Clear organization principles

---

## ⏱️ TIMELINE ESTIMATE

### Planning Phase (DONE)
- Phase 0-4 complete: 11-16 hours
- All documents ready

### Execution Phase (READY)
- Phase 5-7 execution: 14-20 hours
- Includes testing and fixes

### Total Project
- **18-27 hours** (distributed over 2-3 days recommended)
- Automated: 30-60 minutes
- Manual: 16-25 hours

---

## 🚀 HOW TO PROCEED

### Option A: Run Everything Now

1. Read PHASE_4_COMPLETE_SUMMARY.md (30 min)
2. Run migration scripts:
   ```powershell
   .\migrate\RunAllMigrationSteps.ps1
   ```
   (30-60 min)
3. Test game runs (5-15 min)
4. Run test suite (10-20 min)
5. Update documentation (3-4 hours)
6. Create PR (30 min)

**Total: 6-8 hours in one session**

### Option B: Run Over Multiple Days

- **Day 1 (2-3 hours):** Run migration scripts + initial testing
- **Day 2 (1-2 hours):** Fix test failures
- **Day 3 (3-4 hours):** Update documentation
- **Day 4 (0.5 hours):** Final verification + PR

**Total: 6-10 hours distributed**

### Getting Started

```powershell
# Create backup branch
cd c:\Users\tombl\Documents\Projects
git checkout -b engine-restructure
git branch migration-backup

# Review critical documents
# - PHASE_3_DETAILED_MIGRATION_PLAN.md
# - PHASE_4_COMPLETE_SUMMARY.md

# When ready, run migration
.\migrate\RunAllMigrationSteps.ps1
```

---

## 🔗 DOCUMENT RELATIONSHIPS

```
├─ Problem Analysis
│  └─ temp/engine_structure_audit.md (current issues)
│
├─ Solution Design
│  ├─ docs/ENGINE_ORGANIZATION_PRINCIPLES.md (11 standards)
│  └─ CROSS_FOLDER_IMPACT_ANALYSIS.md (what changes where)
│
├─ Execution Planning
│  ├─ PHASE_3_DETAILED_MIGRATION_PLAN.md (file-by-file)
│  └─ RECOMMENDED_CHANGES_BY_FOLDER.md (per-folder guidance)
│
├─ Automation
│  ├─ migrate/ (7 PowerShell scripts)
│  ├─ migrate/README.md (how to use scripts)
│  └─ PHASE_4_COMPLETE_SUMMARY.md (comprehensive guide)
│
└─ Tracking
   ├─ TASK_006_PHASE_4_COMPLETE.md (current status)
   └─ This file (INDEX)
```

---

## 📞 CONTACT & SUPPORT

### Questions About Planning?
- Review PHASE_3_DETAILED_MIGRATION_PLAN.md (execution details)
- Check RECOMMENDED_CHANGES_BY_FOLDER.md (specific decisions)

### Questions About Execution?
- See PHASE_4_COMPLETE_SUMMARY.md (FAQ section)
- Check migrate/README.md (usage examples)

### Script Not Working?
- Review troubleshooting in PHASE_4_COMPLETE_SUMMARY.md
- Check PowerShell execution policy:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
  ```

---

## ✅ READINESS CHECKLIST

Before proceeding to Phase 5 (Execution):

- [ ] Read all planning documents (time estimate: 2-3 hours)
- [ ] Understand new folder structure
- [ ] Review migration scripts
- [ ] Team approval obtained
- [ ] Calendar time blocked (18-27 hours total)
- [ ] Git backup strategy confirmed
- [ ] Rollback procedure understood
- [ ] Love2D console available
- [ ] Test runner works
- [ ] Ready to commit to execution

---

## 🎓 LESSONS LEARNED / BEST PRACTICES

### What Went Well
- ✅ Comprehensive impact analysis caught all affected areas
- ✅ Phase-by-phase approach allows incremental progress
- ✅ Dry-run mode provides confidence before actual changes
- ✅ Detailed planning reduced execution risks

### Key Success Factors
1. **Plan before implementing** - All decisions documented
2. **Automate what's repetitive** - 7 scripts handle 80% of work
3. **Validate at each step** - Catch issues early
4. **Easy rollback** - Git integration enables safety

### Recommendations
1. Run Phase 5-7 all together (don't split across days)
2. Have team do code review after migration
3. Monitor test suite closely during Phase 6
4. Commit frequently (one logical change per commit)

---

## 📝 VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 25, 2025 | Initial phase 4 completion |

---

**Document:** TASK_006_PLANNING_INDEX.md  
**Status:** Complete - Ready for Execution  
**Last Updated:** October 25, 2025  

**👉 Next Step:** Review PHASE_4_COMPLETE_SUMMARY.md for execution guide.
