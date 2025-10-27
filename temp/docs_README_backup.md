# Documentation Hub - AlienFall Project

**Purpose:** Centralized documentation covering all aspects of development, processes, and system architecture  
**Audience:** Developers, AI agents, contributors, project managers  
**Last Updated:** 2025-10-27

---

## 📁 Documentation Structure

```
docs/
├── README.md                          ← You are here (Documentation Hub)
│
├── chatmodes/                         AI Agent Personas (23 specialized roles)
│   ├── README.md
│   ├── QUICK-REFERENCE.md
│   └── *.chatmode.md
│
├── instructions/                      Development Practices (24 guides)
│   ├── README.md
│   ├── START_HERE.md
│   ├── INDEX_ALL_24_PRACTICES.md
│   └── *.instructions.md
│
├── prompts/                           Content Creation Templates (27 prompts)
│   ├── README.md
│   └── *.prompt.md
│
├── system/                            Universal System Patterns (9 patterns)
│   ├── 01_SEPARATION_OF_CONCERNS_SYSTEM.md
│   ├── 02_PIPELINE_ARCHITECTURE_SYSTEM.md
│   ├── 03_DATA_DRIVEN_CONTENT_SYSTEM.md
│   ├── 04_HIERARCHICAL_TESTING_SYSTEM.md
│   ├── 05_TASK_MANAGEMENT_SYSTEM.md
│   ├── 06_AUTOMATION_TOOLS_SYSTEM.md
│   ├── 07_AI_GUIDANCE_SYSTEM.md
│   ├── 08_SUPPORTING_INFRASTRUCTURE_SYSTEM.md
│   └── 09_LOGGING_AND_ANALYTICS_SYSTEM.md
│
├── handbook/                          Project Handbook (policies, conventions)
│   └── README.md
│
├── processes/                         Development Processes (workflows, procedures)
│   └── README.md
│
└── WIP/                              Work In Progress (draft documentation)
    └── README.md
```

---

## 🎯 Quick Navigation

### For AI Agents
- **Start:** [chatmodes/](chatmodes/README.md) - Load appropriate persona
- **Practices:** [instructions/](instructions/START_HERE.md) - Coding standards
- **Content:** [prompts/](prompts/README.md) - Content creation templates
- **Architecture:** [system/](system/) - Universal patterns

### For Developers
- **Onboarding:** [handbook/](handbook/README.md) - Project conventions
- **Workflows:** [processes/](processes/README.md) - How we work
- **Coding:** [instructions/](instructions/START_HERE.md) - Best practices
- **Drafts:** [WIP/](WIP/README.md) - Work in progress docs

### For Architects
- **System Patterns:** [system/](system/) - 9 universal patterns
- **Architecture:** [instructions/🏗️ Architecture & Modularity.instructions.md](instructions/🏗️%20Architecture%20&%20Modularity.instructions.md)
- **Processes:** [processes/](processes/README.md) - Design workflows

---

## 📚 Documentation Categories

### 1. ChatModes - AI Agent Personas
**Location:** `docs/chatmodes/`  
**Purpose:** 23 specialized AI personas for different development tasks  
**Layers:** Strategic, Design, Implementation, Testing, Analysis, Support

**Quick Start:**
```
Load appropriate chatmode:
- Game Designer → chatmodes/game_designer.chatmode.md
- Engine Developer → chatmodes/engine_developer.chatmode.md
- Tester → chatmodes/engine_tester.chatmode.md
```

[📖 Full ChatModes Documentation](chatmodes/README.md)

---

### 2. Instructions - Development Practices
**Location:** `docs/instructions/`  
**Purpose:** 24 best practice guides covering all aspects of development  
**Categories:** Programming, Art, Design, DevOps, Management, Security, Global, Community

**Quick Start:**
```
Essential guides:
- Love2D & Lua → instructions/🛠️ Love2D & Lua.instructions.md
- Testing → instructions/🧪 Testing.instructions.md
- Git Workflow → instructions/🔄 Git Workflow & Collaboration.instructions.md
```

[📖 Full Instructions Index](instructions/INDEX_ALL_24_PRACTICES.md)

---

### 3. Prompts - Content Creation Templates
**Location:** `docs/prompts/`  
**Purpose:** 27 structured templates for creating game content  
**Systems:** Core, Base, World, Tactical, Combat, Economy, Narrative, Meta

**Quick Start:**
```
Create content:
- New unit → prompts/add_unit.prompt.md
- New weapon → prompts/add_item.prompt.md
- New mission → prompts/add_mission.prompt.md
```

[📖 Full Prompts Documentation](prompts/README.md)

---

### 4. System - Universal Patterns
**Location:** `docs/system/`  
**Purpose:** 9 reusable architectural patterns that work in ANY project  
**Audience:** Architects, teams replicating this system

**The 9 Patterns:**
1. **Separation of Concerns** - Isolate design, interface, implementation
2. **Pipeline Architecture** - Unidirectional workflow (design → code → tests)
3. **Data-Driven Content** - Separate engine from configuration
4. **Hierarchical Testing** - 3-level test organization (75%+ coverage)
5. **Task Management** - File-based work tracking
6. **Automation Tools** - Validators, generators, editors
7. **AI Guidance** - Autonomous AI agent training
8. **Supporting Infrastructure** - temp/, run/, logs/
9. **Logging & Analytics** - Runtime observability and AI intelligence

**Universal Adaptation:** Copy these patterns to games, web apps, data pipelines, embedded systems

[📖 Full System Patterns](system/)

---

### 5. Handbook - Project Conventions
**Location:** `docs/handbook/`  
**Purpose:** Project-specific policies, standards, and conventions  
**Audience:** All team members, new contributors

**Contents:**
- Code style guide
- Naming conventions
- File organization
- Team communication
- Decision making process
- Contribution guidelines

[📖 Handbook](handbook/README.md)

---

### 6. Processes - Development Workflows
**Location:** `docs/processes/`  
**Purpose:** Step-by-step procedures for common development tasks  
**Audience:** Developers, project managers

**Contents:**
- Feature development workflow
- Bug fixing procedure
- Release process
- Code review process
- Design approval process
- Testing workflow

[📖 Processes](processes/README.md)

---

### 7. WIP - Work In Progress
**Location:** `docs/WIP/`  
**Purpose:** Draft documentation, experimental ideas, pending approvals  
**Audience:** Active contributors

**Contents:**
- Draft design documents
- Experimental patterns
- RFC (Request for Comments)
- Pending documentation updates

[📖 WIP Documentation](WIP/README.md)

---

## 🔄 Documentation Workflow

### Creating New Documentation

```
1. Identify type:
   - AI Persona → docs/chatmodes/
   - Best Practice → docs/instructions/
   - Content Template → docs/prompts/
   - System Pattern → docs/system/
   - Project Policy → docs/handbook/
   - Process/Workflow → docs/processes/

2. Draft in WIP/:
   - Create draft in docs/WIP/[name].md
   - Iterate and refine
   
3. Review:
   - Get feedback from team
   - Validate accuracy
   
4. Publish:
   - Move to appropriate folder
   - Update relevant README files
   - Link from this hub
```

---

## 📊 Documentation Statistics

| Category | Files | Status |
|----------|-------|--------|
| ChatModes | 23 personas | 🟢 Complete |
| Instructions | 24 practices | 🟢 Complete |
| Prompts | 27 templates | 🟢 Complete |
| System Patterns | 9 patterns | 🟢 Complete |
| Handbook | TBD | 🟡 In Progress |
| Processes | TBD | 🟡 In Progress |
| WIP | Variable | 🔄 Active |

---

## 🎓 Learning Paths

### For New Contributors
1. Read [handbook/](handbook/README.md) - Understand project conventions
2. Study [instructions/START_HERE.md](instructions/START_HERE.md) - Learn coding practices
3. Review [system/](system/) - Understand architecture
4. Explore [processes/](processes/README.md) - Learn workflows

### For AI Agents
1. Load appropriate [chatmode](chatmodes/README.md) for task
2. Follow [instructions/](instructions/) for coding standards
3. Use [prompts/](prompts/) for content creation
4. Read [system/09_LOGGING_AND_ANALYTICS_SYSTEM.md](system/09_LOGGING_AND_ANALYTICS_SYSTEM.md) for log usage

### For Architects
1. Study all [system/ patterns](system/) - Understand core architecture
2. Review [processes/](processes/README.md) - Design workflows
3. Read [handbook/](handbook/README.md) - Project standards

---

## 🔗 Related Resources

**Project Root:**
- Main README: `../README.md`
- API Documentation: `../api/README.md`
- Architecture: `../architecture/README.md`
- Design: `../design/README.md`

**Development:**
- Engine Code: `../engine/`
- Tests: `../tests2/`
- Tools: `../tools/`
- Mods: `../mods/`

**Infrastructure:**
- Logs: `../logs/`
- Temp: `../temp/`
- Tasks: `../tasks/`
- Run Scripts: `../run/`

---

## 💡 Key Principles

1. **Single Source of Truth:** Each topic documented once, linked everywhere
2. **Living Documentation:** Keep docs in sync with code
3. **Universal Patterns:** System patterns work in ANY project
4. **AI-First:** Documentation optimized for AI agent consumption
5. **Structured Templates:** Use prompts for consistency
6. **Clear Organization:** Everything has a place

---

## 🚀 Quick Actions

**I want to...**
- Create a new unit → Use [prompts/add_unit.prompt.md](prompts/add_unit.prompt.md)
- Learn testing → Read [instructions/🧪 Testing.instructions.md](instructions/🧪%20Testing.instructions.md)
- Understand architecture → Study [system/](system/)
- Fix a bug → Follow [processes/](processes/README.md) (when available)
- Contribute → Read [handbook/](handbook/README.md) (when available)

---

**Total Documentation:** 83+ documents (23 chatmodes + 24 instructions + 27 prompts + 9 patterns)  
**Status:** 🟢 Core complete, expansion areas ready  
**Last Updated:** 2025-10-27  
**Maintainer:** Project Team

