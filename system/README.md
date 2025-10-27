# System Patterns & Documentation Architecture

**Purpose:** Universal system patterns and project-specific documentation structure  
**Audience:** Architects, teams replicating the system  
**Last Updated:** 2025-10-27

---

## 📁 Contents

This folder contains universal system patterns that can be replicated across any project type (games, web apps, data pipelines, embedded systems).

```
system/
├── systems/              9 universal system patterns
├── modules/              Project-specific folder documentation (11 files)
├── patterns/             Advanced pattern variations (placeholder)
├── guides/               Implementation guides (placeholder)
└── ORGANIZATION.md       Documentation organization guide
```

---

## 🎯 The 9 Universal System Patterns

Located in `system/systems/`:

1. **01_SEPARATION_OF_CONCERNS_SYSTEM.md** - Isolate design, interface, implementation, content
2. **02_PIPELINE_ARCHITECTURE_SYSTEM.md** - Unidirectional workflow (design → code → tests)
3. **03_DATA_DRIVEN_CONTENT_SYSTEM.md** - Separate engine from configuration
4. **04_HIERARCHICAL_TESTING_SYSTEM.md** - 3-level test organization (75%+ coverage)
5. **05_TASK_MANAGEMENT_SYSTEM.md** - File-based work tracking
6. **06_AUTOMATION_TOOLS_SYSTEM.md** - Validators, generators, editors
7. **07_AI_GUIDANCE_SYSTEM.md** - Autonomous AI agent training
8. **08_SUPPORTING_INFRASTRUCTURE_SYSTEM.md** - temp/, run/, logs/
9. **09_LOGGING_AND_ANALYTICS_SYSTEM.md** - Runtime observability and AI intelligence

**These patterns work in ANY project domain** - copy and adapt folder names to your technology.

---

## 📋 Project-Specific Modules

Located in `system/modules/`:

Explains folder structure and conventions for THIS specific project (AlienFall game). If you're adapting the system to a different project, these are reference only.

---

## 🔗 Related Documentation

**Primary Documentation Hub:** `docs/` folder (new central location)
- ChatModes: `docs/chatmodes/`
- Instructions: `docs/instructions/`
- Prompts: `docs/prompts/`
- Creation Templates: `docs/system/create_*.prompt.md`
- Handbook: `docs/handbook/`
- Processes: `docs/processes/`

**This folder (system/):** Universal patterns that work everywhere

---

## 💡 Key Insight

**docs/** = Project-specific documentation (how WE work)  
**system/** = Universal patterns (how ANYONE can work this way)

---

**Status:** 🟢 Complete  
**Usage:** Study patterns, adapt to your project

