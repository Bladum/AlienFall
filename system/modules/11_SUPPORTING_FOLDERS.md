# Supporting Folders - Infrastructure & Utilities

**Purpose:** Provide operational utilities supporting the main development pipeline  
**Audience:** All team members  
**Format:** Mixed (markdown, scripts, temporary files, logs)

---

## What Are Supporting Folders?

### The Three Supporting Folders

```
Supporting Infrastructure:
├── logs/      Runtime output for debugging, analytics, and AI agents
├── temp/      Working space for transient analysis and reports
└── run/       Automation scripts for common commands
```

**Key Distinction:** Supporting folders enable development but don't create permanent artifacts (except logs for analysis).

**Note:** `docs/` is now a full Documentation Hub (see project root), not a supporting folder.

---

## Folder 1: logs/ - Runtime Output & Analytics

### Purpose
Centralized storage for all runtime output, enabling debugging, analytics, and AI-driven improvements

### Structure
```
logs/
├── README.md                          Documentation (see full details)
│
├── game/                              Game runtime logs
│   ├── game_YYYY-MM-DD_HH-MM-SS.log
│   └── crash_YYYY-MM-DD_HH-MM-SS.log
│
├── tests/                             Test execution logs
│   ├── test_run_YYYY-MM-DD_HH-MM-SS.log
│   ├── test_failures_YYYY-MM-DD.log
│   └── coverage_YYYY-MM-DD.json
│
├── mods/                              Mod loading logs
│   ├── mod_load_YYYY-MM-DD_HH-MM-SS.log
│   └── mod_errors_YYYY-MM-DD.log
│
├── system/                            Engine/core logs
│   ├── engine_YYYY-MM-DD_HH-MM-SS.log
│   └── performance_YYYY-MM-DD.json
│
└── analytics/                         Aggregated metrics
    ├── gameplay_metrics_YYYY-MM-DD.json
    ├── balance_data_YYYY-MM-DD.json
    └── user_behavior_YYYY-MM-DD.json
```

---

### Content Guidelines

**What Goes in logs/:**
- ✅ **game/:** Player actions, missions, combat, state transitions
- ✅ **tests/:** Test runs, failures, coverage, performance
- ✅ **mods/:** Mod loading, conflicts, content registration
- ✅ **system/:** Engine startup, performance, warnings
- ✅ **analytics/:** Aggregated metrics (JSON format)

**What Does NOT Go in logs/:**
- ❌ Source code - goes in engine/
- ❌ Design docs - goes in design/
- ❌ Analysis reports - goes in temp/
- ❌ Test definitions - goes in tests2/

---

### Critical: AI Agent Usage

**AI agents MUST read logs for:**

1. **Error Fixing:**
   - Read `logs/tests/test_failures_*.log` for failing tests
   - Read `logs/game/crash_*.log` for runtime crashes
   - Read `logs/mods/mod_errors_*.log` for mod issues
   - Identify patterns, fix root causes

2. **Test Improvement:**
   - Read `logs/tests/coverage_*.json` for untested modules
   - Generate tests for gaps
   - Improve test quality

3. **Game Balancing:**
   - Read `logs/analytics/balance_data_*.json` for usage patterns
   - Identify overpowered/underpowered content
   - Update balance in `mods/core/rules/`

4. **Performance Optimization:**
   - Read `logs/system/performance_*.json` for bottlenecks
   - Optimize slow code
   - Verify improvements

5. **Mod Compatibility:**
   - Read `logs/mods/` for conflicts
   - Fix loader issues
   - Improve error messages

---

### Log Format Standard

**Text Logs:**
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] [COMPONENT] Message

Example:
[2025-10-27 14:32:15] [INFO] [MISSION] Mission started: Terror Site
[2025-10-27 14:32:20] [ERROR] [COMBAT] Invalid target: Unit not found
```

**JSON Logs (Analytics):**
```json
{
  "date": "2025-10-27",
  "weapon_usage": {
    "rifle": 0.45,
    "shotgun": 0.25
  }
}
```

---

### Lifecycle & Retention

**Policy:**
- Keep last 30 days of logs
- Archive logs 30-90 days old to `logs/archive/`
- Compress archives (`.log.gz`)
- Delete archives >90 days old

**Auto-cleanup:** Run `tools/log_cleanup.lua` weekly

---

### Version Control

**NOT in Git:**
- All log files are runtime-generated
- Add `logs/*.log` to `.gitignore`
- Keep `logs/README.md` in git

**Exception:** Sample logs for testing/documentation

---

### Example Use Cases

**Developer Debugging:**
```bash
# Run game
lovec "engine"

# Check logs after crash
cat logs/game/crash_2025-10-27_14-32-15.log

# Find error, fix code
```

**AI Agent Auto-Balance:**
```bash
# AI reads analytics
logs/analytics/balance_data_2025-10-27.json

# Identifies: weapon_usage["rifle"] = 0.78 (overpowered)
# Updates: mods/core/rules/items/weapons.toml (reduce accuracy)
# Verifies: Next analytics show weapon_usage["rifle"] = 0.52 (balanced)
```

**Test Coverage Improvement:**
```bash
# AI reads coverage
logs/tests/coverage_2025-10-27.json

# Identifies untested modules: engine/battlescape/fog_of_war.lua
# Generates: tests2/battlescape/fog_of_war_test.lua
# Runs tests, verifies pass
```

---

### Integration Points

**Related Systems:**
- [Logging & Analytics System](../systems/09_LOGGING_AND_ANALYTICS_SYSTEM.md) - Full pattern documentation
- engine/core/logger.lua - Logger implementation
- engine/analytics/ - Analytics aggregator
- tools/qa_system/ - Automated log analysis

---

## Folder 2: temp/ - Temporary Working Directory

### Purpose
Sandboxed space for analysis, reports, investigations, and transient work

### Structure
```
temp/
├── analysis_YYYY_MM_DD.md       Gap analysis reports
├── investigation_[topic].md     Research notes
├── benchmark_[feature].md       Performance data
├── draft_[document].md          Working drafts
└── report_[topic].md            Generated reports
```

---

### Content Guidelines

**What Goes in temp/:**
- ✅ Gap analysis results
- ✅ Investigation notes
- ✅ Performance benchmarks
- ✅ Working drafts
- ✅ Generated reports
- ✅ Experimental data
- ✅ Temporary calculations

**What Does NOT Go in temp/:**
- ❌ Permanent documentation - goes in docs/
- ❌ Code - goes in engine/
- ❌ Design specs - goes in design/
- ❌ Test results - goes in tests2/reports/

---

### Naming Convention

```
temp/[PURPOSE]_[SUBJECT]_[TYPE].md

Examples:
- analysis_design_api_gaps_2025_10_27.md
- investigation_performance_bottleneck.md
- benchmark_unit_creation_performance.md
- draft_new_feature_design.md
- report_code_coverage_summary.md
```

**Purpose:** Descriptive names make files self-documenting

---

### Lifecycle

```
Creation → Use → Review → Action
    ↓        ↓       ↓        ↓
  Analysis  Work   Decide   Cleanup

Actions:
1. Archive (move to permanent location if valuable)
2. Summarize (extract key points to permanent docs)
3. Delete (if no longer needed)
```

**Cleanup Policy:** Monthly review, archive/delete files >30 days old

---

### Example Use Cases

**Gap Analysis:**
```bash
# Generate gap analysis
lua tools/validators/design_api_gap_check.lua design/ api/ > temp/analysis_design_api_gaps_2025_10_27.md

# Review findings
# Create tasks for identified gaps
# Archive analysis in temp/ for future reference
```

**Performance Investigation:**
```bash
# Profile performance
lua tools/profiler.lua > temp/benchmark_unit_creation_2025_10_27.md

# Analyze results
# Optimize slow code
# Keep benchmark for comparison
```

**Working Drafts:**
```bash
# Draft new feature design in temp/
temp/draft_pilot_system_design.md

# Iterate and refine
# When complete, move to design/mechanics/pilots.md
# Delete draft from temp/
```

---

### Version Control

**Partially Versioned:**
- Important analyses: Commit to git
- Temporary investigations: Add to .gitignore
- Working drafts: Commit or not (developer choice)

**Pattern:**
```gitignore
# temp/ folder handling
temp/draft_*               # Don't commit drafts
temp/investigation_*       # Don't commit investigations
temp/analysis_*            # DO commit analyses (valuable)
temp/report_*              # DO commit reports (valuable)
```

---

## Folder 3: run/ - Automation Scripts

### Purpose
Convenient shortcuts for common development tasks

### Structure
```
run/
├── run_xcom.bat                  Launch game
├── run_tests2_all.bat            Run all tests
├── run_tests2_subsystem.bat      Run subsystem tests
├── run_tests2_single.bat         Run single test
├── run_validate_toml.bat         Validate TOML
├── run_validate_assets.bat       Validate assets
├── run_qa_full.bat               Full QA suite
└── README.md                     Script documentation
```

---

### Content Guidelines

**What Goes in run/:**
- ✅ Batch/shell scripts for common commands
- ✅ Shortcuts to frequently-used tools
- ✅ Build/test automation
- ✅ Validation runners
- ✅ Development utilities

**What Does NOT Go in run/:**
- ❌ Complex tools - goes in tools/
- ❌ Source code - goes in engine/
- ❌ CI/CD configs - goes in .github/workflows/

---

### Script Pattern

```batch
@echo off
REM run_tests2_all.bat - Run complete test suite

echo Running all tests...
lovec "tests2/runners" run_all

if %errorlevel% neq 0 (
    echo.
    echo ============================================
    echo TESTS FAILED
    echo ============================================
    exit /b 1
)

echo.
echo ============================================
echo ALL TESTS PASSED
echo ============================================
exit /b 0
```

**Features:**
- Clear echo messages (user knows what's happening)
- Error handling (return codes)
- Documentation (REM comments)
- Simple (wraps complex commands)

---

### Common Scripts

**Game Execution:**
```batch
# run_xcom.bat
lovec "engine"
```

**Testing:**
```batch
# run_tests2_all.bat
lovec "tests2/runners" run_all

# run_tests2_subsystem.bat <subsystem>
lovec "tests2/runners" run_subsystem %1

# run_tests2_single.bat <test_file>
lovec "tests2/runners" run_single_test %1
```

**Validation:**
```batch
# run_validate_toml.bat
lua tools/validators/toml_validator.lua mods/

# run_validate_assets.bat
lua tools/validators/asset_validator.lua mods/

# run_validate_all.bat
call run_validate_toml.bat
call run_validate_assets.bat
call run_tests2_all.bat
```

**Quality Assurance:**
```batch
# run_qa_full.bat
echo Running full QA suite...
call run_validate_all.bat
call run_tests2_all.bat
lua tools/qa/coverage_report.lua
lua tools/qa/code_quality.lua
```

---

### Platform Differences

**Windows (.bat):**
```batch
@echo off
lovec "engine"
```

**Linux/Mac (.sh):**
```bash
#!/bin/bash
love engine/
```

**Best Practice:** Provide both if cross-platform

---

## Folder 4: docs/ - Meta-Documentation

### Purpose
Document the documentation system itself (this folder!)

### Structure
```
docs/
├── README.md                    Master index
├── ORGANIZATION.md              Structure overview
│
├── systems/                     8 core system patterns
│   ├── 01_SEPARATION_OF_CONCERNS_SYSTEM.md
│   ├── 02_PIPELINE_ARCHITECTURE_SYSTEM.md
│   ├── 03_DATA_DRIVEN_CONTENT_SYSTEM.md
│   ├── 04_HIERARCHICAL_TESTING_SYSTEM.md
│   ├── 05_TASK_MANAGEMENT_SYSTEM.md
│   ├── 06_AUTOMATION_TOOLS_SYSTEM.md
│   ├── 07_AI_GUIDANCE_SYSTEM.md
│   └── 08_SUPPORTING_INFRASTRUCTURE_SYSTEM.md
│
├── modules/                     11 folder explanations
│   ├── 01_DESIGN_FOLDER.md
│   ├── 02_API_FOLDER.md
│   ├── 03_ARCHITECTURE_FOLDER.md
│   ├── 04_ENGINE_FOLDER.md
│   ├── 05_MODS_FOLDER.md
│   ├── 06_TESTS2_FOLDER.md
│   ├── 07_TASKS_FOLDER.md
│   ├── 08_TOOLS_FOLDER.md
│   ├── 09_LORE_FOLDER.md
│   ├── 10_GITHUB_FOLDER.md
│   └── 11_SUPPORTING_FOLDERS.md (this file!)
│
├── patterns/                    Future: Advanced patterns
│   └── README.md
│
└── guides/                      Future: Tech-stack guides
    └── README.md
```

---

### Content Guidelines

**What Goes in docs/:**
- ✅ System pattern documentation (how systems work)
- ✅ Folder purpose explanations (what goes where and why)
- ✅ Integration guides (how folders connect)
- ✅ Universal patterns (replicable to other projects)
- ✅ Meta-documentation (docs about docs)

**What Does NOT Go in docs/:**
- ❌ Game design - goes in design/
- ❌ API documentation - goes in api/
- ❌ Architecture diagrams - goes in architecture/
- ❌ Specific game content - goes in mods/

---

### Purpose: Explain the SYSTEM

**Difference from other documentation:**

```
design/: Explains WHAT the game is
api/: Explains WHAT data structures exist
architecture/: Explains HOW systems connect
engine/: IS the implementation

docs/: Explains WHY folders exist and HOW to use the system
```

**Key Insight:** docs/ is about the SYSTEM, not the GAME

---

### systems/ - 8 Core Patterns

**Purpose:** Document universal system patterns

Each pattern document includes:
- Core concept
- Detailed architecture
- Workflows
- Integration points
- Validation rules
- Anti-patterns
- Tools
- Metrics
- Universal adaptation (how to use in ANY project)
- Success criteria
- Implementation checklist

**Goal:** Anyone can replicate these patterns in their own project

---

### modules/ - 11 Folder Explanations

**Purpose:** Explain each folder's purpose and usage

Each module document includes:
- What goes in the folder (and what doesn't)
- Core principle
- Content guidelines
- Example content
- Integration with other folders
- Common patterns
- Validation
- Tools
- Best practices
- Maintenance

**Goal:** Clear understanding of where everything goes

---

### Usage: Onboarding and Replication

**For New Team Members:**
```
1. Read docs/README.md (master index)
2. Read systems/ (understand patterns)
3. Read modules/ (understand folders)
4. Start contributing with clear mental model
```

**For Replicating System:**
```
1. Read all 8 systems/ documents
2. Identify which patterns apply to your domain
3. Adapt folder names to your tech stack
4. Follow implementation checklists
5. Create your own modules/ documentation
```

---

## Integration: How Supporting Folders Work Together

### temp/ → Tasks → Permanent Docs

```
1. Investigation in temp/investigation_feature.md
2. Decision made → Create task in tasks/TODO/
3. Task completed → Update design/ or api/
4. Archive temp/ investigation (or delete if no longer needed)
```

### run/ → Development Workflow

```
Developer workflow:
1. Make changes to engine/
2. Run: run_validate_all.bat (quick check)
3. Run: run_tests2_all.bat (full validation)
4. If pass → commit
5. If fail → fix and repeat
```

### docs/ → Understanding → All Folders

```
New developer:
1. Read docs/README.md
2. Understand systems (why things are organized this way)
3. Understand modules (what goes where)
4. Navigate project with confidence
5. Contribute following patterns
```

---

## Validation

### Supporting Folders Health

**temp/:**
- [ ] Files have descriptive names
- [ ] No files >60 days old (cleanup policy)
- [ ] Important analyses committed to git
- [ ] Drafts either completed or deleted

**run/:**
- [ ] All scripts documented (header comments)
- [ ] Scripts return proper exit codes
- [ ] Error messages clear
- [ ] All common tasks have scripts
- [ ] Scripts tested and working

**docs/:**
- [ ] All systems documented (8 files)
- [ ] All modules documented (11 files)
- [ ] README up to date
- [ ] Cross-references valid
- [ ] Examples clear and accurate

---

## Tools

### temp/ Cleanup
```bash
lua tools/temp/cleanup.lua

# Reviews temp/ folder
# Lists files >30 days old
# Suggests archive/delete
```

### run/ Validator
```bash
lua tools/validators/script_validator.lua run/

# Checks:
# - Scripts have documentation
# - Error handling present
# - Return codes correct
```

### docs/ Link Checker
```bash
lua tools/validators/docs_validator.lua docs/

# Checks:
# - All cross-references valid
# - No broken links
# - All files referenced
```

---

## Best Practices

### temp/: Keep Clean

```
Monthly review:
1. Archive valuable analyses
2. Summarize findings to permanent docs
3. Delete obsolete files
4. Keep folder lean (<20 files ideal)
```

### run/: Make Simple

```
Script checklist:
- [ ] One clear purpose
- [ ] Header comment explaining usage
- [ ] Echo messages (user knows what's happening)
- [ ] Error handling (proper return codes)
- [ ] Tested and working
```

### docs/: Stay Current

```
Update when:
- Folder structure changes
- New patterns established
- Tools added/changed
- Best practices updated

Review: Monthly for accuracy
```

---

## Maintenance

**Weekly:**
- Review temp/ for cleanup
- Test run/ scripts still work
- Verify docs/ accuracy

**Monthly:**
- Cleanup temp/ (archive/delete)
- Update run/ scripts if needed
- Review docs/ for updates
- Check cross-references

**Per Release:**
- Archive valuable temp/ analyses
- Verify all run/ scripts work
- Update docs/ with changes
- Remove obsolete content

---

## Success Criteria

Supporting folders working correctly when:

✅ temp/ stays clean (<20 files, <30 days old)  
✅ run/ has scripts for all common tasks  
✅ docs/ explains system clearly to new team members  
✅ Scripts work reliably across platforms  
✅ Documentation current (<6 months since update)  
✅ Overhead minimal (<5% of development time)  
✅ Team uses all three folders effectively  

---

**See:** README files in temp/, run/, and docs/

**Related:**
- [systems/08_SUPPORTING_INFRASTRUCTURE_SYSTEM.md](../systems/08_SUPPORTING_INFRASTRUCTURE_SYSTEM.md) - Supporting infrastructure pattern
- All other modules/ files - Explain main project folders
- All systems/ files - Explain core patterns

