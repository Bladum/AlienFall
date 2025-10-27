# .github Folder - AI Guidance & Workflows

**Purpose:** Store GitHub-specific configurations, AI instructions, and automation  
**Audience:** AI agents, developers, CI/CD systems  
**Format:** Markdown files, YAML workflows

---

## What Goes in .github/

### Structure
```
.github/
├── copilot-instructions.md      Master AI instructions (10,000+ lines)
│
├── chatmodes/                    AI personas (23 specialized roles)
│   ├── README.md                ChatModes documentation
│   ├── QUICK-REFERENCE.md       Quick reference guide
│   ├── strategic_game_architect.chatmode.md
│   ├── design_game_designer.chatmode.md
│   ├── implementation_engine_developer.chatmode.md
│   ├── testing_engine_tester.chatmode.md
│   └── ... (23 total personas)
│
├── instructions/                 Development practices (24 guides)
│   ├── README.md                Instructions overview
│   ├── INDEX_ALL_24_PRACTICES.md
│   ├── START_HERE.md            Getting started
│   ├── 🛠️ Love2D & Lua.instructions.md
│   ├── 🧪 Testing.instructions.md
│   ├── 🔄 Git Workflow & Collaboration.instructions.md
│   └── ... (24 total practices)
│
├── prompts/                      Content creation templates (27 prompts)
│   ├── README.md                Prompts overview
│   ├── add_unit.prompt.md       Create new unit
│   ├── add_item.prompt.md       Create new item
│   ├── add_mission.prompt.md    Create new mission
│   └── ... (27 total prompts)
│
└── workflows/                    GitHub Actions (CI/CD)
    ├── tests.yml                Run test suite
    ├── validate.yml             Run validators
    └── build.yml                Build releases
```

---

## Core Principle: Autonomous AI Development

**AI agents can work independently with comprehensive instructions:**

```
Master Instructions (copilot-instructions.md):
├─ Complete project context
├─ All conventions and patterns
├─ Autonomous decision-making rules
├─ File organization
├─ Workflows and validation
└─ Tools and commands

ChatModes (specialized personas):
├─ Role-specific knowledge
├─ Workflow patterns
└─ Decision trees

Prompts (content templates):
├─ Step-by-step procedures
└─ Consistent output formats
```

**Key Rule:** AI should know enough to work independently without constant human guidance.

---

## Content Guidelines

### What Belongs Here
- ✅ AI agent instructions (master instructions file)
- ✅ Specialized AI personas (ChatModes)
- ✅ Development practice guides (Instructions)
- ✅ Content creation templates (Prompts)
- ✅ GitHub Actions workflows (CI/CD)
- ✅ Issue/PR templates
- ✅ GitHub-specific configs

### What Does NOT Belong Here
- ❌ Game code - goes in engine/
- ❌ Design docs - goes in design/
- ❌ Tests - goes in tests2/
- ❌ General documentation - goes in docs/

---

## Master Instructions File

### copilot-instructions.md Structure

```markdown
# System Prompt for AlienFall Love2D Development

## 🤖 AUTONOMOUS AGENT MODE
- Take initiative
- Work iteratively
- Self-verify
- Follow workflow
- Document changes

## Project Overview
- Complete structure
- Key resources
- Documentation index

## Master Documentation Index
- Quick Start links
- ChatModes (23 personas)
- Practices (24 guides)
- Prompts (27 templates)

## Running and Debugging
- Commands and shortcuts
- Validation checklist
- Error handling

## File Organization Rules
- Where each type of content goes
- Integration patterns
- Validation rules

## AI Assistant Guidelines
- Autonomous principles
- Context awareness
- Decision trees
- Error handling

## Code Standards
- Lua/Love2D patterns
- Testing requirements
- Documentation rules

## Tools and Workflows
- Available tools
- Common commands
- Integration patterns
```

**Size:** ~10,000-20,000 lines (comprehensive)

**Purpose:** Single source of truth for AI agent behavior

---

## ChatModes System

### 23 Specialized AI Personas

**6 Strategic Layer:**
1. Game Architect - Overall game design
2. API Architect - API design and contracts
3. AI Architect - AI systems architecture
4. Business Architect - Business strategy
5. Knowledge Manager - Documentation management
6. Systems Architect - Technical architecture

**3 Design Layer:**
7. Game Designer - Mechanics and balance
8. Planner - Project planning
9. Tasker - Task management

**7 Implementation Layer:**
10. Engine Developer - Core development
11. AI Developer - AI implementation
12. Writer - Content writing
13. Modder - Mod creation
14. Artist - Visual content
15. UI Designer - Interface design
16. Systems Architect - System implementation

**1 Testing Layer:**
17. Engine Tester - QA and testing

**3 Analysis Layer:**
18. Player - Player perspective
19. Data Analyst - Metrics analysis
20. Business Analyst - Business analysis

**4 Support Layer:**
21. Support Engineer - Technical support
22. Researcher - Research and investigation
23. Marketing - Marketing content
24. Executive Guide - High-level guidance

**Usage:**
```markdown
Load appropriate chatmode based on task:
- Designing mechanics? Use Game Designer
- Implementing code? Use Engine Developer
- Writing tests? Use Engine Tester
- Planning work? Use Planner
```

---

## Instructions System

### 24 Development Practice Guides

**By Category:**

**Programming (5):**
- Love2D & Lua
- Performance
- Debugging
- Testing
- Documentation

**Art (4):**
- Pixel Art
- UI/UX
- Asset Pipeline
- Audio

**Design (3):**
- Game Mechanics
- Battlescape & AI
- Architecture

**DevOps (3):**
- Git Workflow
- Release & Deployment
- Build Tools

**Management (3):**
- Project Planning
- Analytics
- Refactoring

**Security (2):**
- Asset Protection
- Data Persistence

**Global (2):**
- Localization
- Accessibility

**Community (2):**
- Modding Support
- API Design

**Usage:**
```bash
# Reference in AI prompts:
"Follow practices from 🛠️ Love2D & Lua.instructions.md"
"Use testing patterns from 🧪 Testing.instructions.md"
```

---

## Prompts System

### 27 Content Creation Templates

**By System:**

**Core (6):**
- add_unit
- add_item
- add_craft
- add_mission
- add_faction
- add_campaign

**Base (3):**
- add_facility
- add_service
- add_base_script

**World (3):**
- add_world
- add_country
- add_region

**Tactical (5):**
- add_terrain
- add_biome
- add_map_block
- add_map_script
- add_tileset

**Combat (1):**
- add_ufo_script

**Economy (4):**
- add_research
- add_manufacturing
- add_purchase
- add_supplier

**Narrative (3):**
- add_event
- add_quest
- add_advisor

**Meta (2):**
- add_organization
- update_mechanics

**Usage Example:**
```markdown
# Using add_unit.prompt.md

Step 1: Define unit concept
Step 2: Fill design document (design/mechanics/)
Step 3: Create API entry (api/UNITS.md)
Step 4: Generate TOML (mods/core/rules/units/)
Step 5: Create sprite (mods/core/assets/units/)
Step 6: Test in-game

Result: Complete unit added following all patterns
```

---

## GitHub Actions Workflows

### CI/CD Automation

**tests.yml:**
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Install Love2D
        run: sudo apt-get install love
      
      - name: Run Full Test Suite
        run: lovec tests2/runners run_all
      
      - name: Check Coverage
        run: |
          coverage=$(lovec tests2/runners run_coverage | grep "Overall:" | awk '{print $2}')
          if [ ${coverage%\%} -lt 75 ]; then
            echo "Coverage $coverage below 75% threshold"
            exit 1
          fi
```

**validate.yml:**
```yaml
name: Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Validate TOML
        run: lua tools/validators/toml_validator.lua mods/
      
      - name: Validate Assets
        run: lua tools/validators/asset_validator.lua mods/
      
      - name: Check Imports
        run: lua tools/validators/import_scanner.lua engine/
```

---

## Integration with Development

### AI → Design → Implementation

```
1. AI reads copilot-instructions.md
   └─ Understands project structure, conventions, patterns

2. AI selects appropriate ChatMode
   └─ Loads role-specific knowledge

3. AI follows relevant Instructions
   └─ Applies development practices

4. AI uses Prompts for content
   └─ Creates consistent output

5. AI self-validates
   └─ Checks work against rules
   └─ Runs validators/tests

6. AI documents changes
   └─ Updates affected docs
```

---

## Validation

### .github Quality Checklist

- [ ] copilot-instructions.md complete and current
- [ ] All 23 ChatModes present
- [ ] All 24 Instructions documented
- [ ] All 27 Prompts available
- [ ] GitHub Actions workflows working
- [ ] Issue/PR templates configured
- [ ] Documentation cross-references valid

---

## Tools

### Instruction Updater
```bash
lua tools/github/update_instructions.lua

# Updates copilot-instructions.md with:
# - Latest file counts
# - Updated structure
# - New patterns
```

### ChatMode Generator
```bash
lua tools/github/generate_chatmode.lua "New Role Name"

# Creates new ChatMode file with template
```

### Prompt Validator
```bash
lua tools/validators/prompt_validator.lua .github/prompts/

# Checks:
# - All prompts follow template
# - Steps are clear
# - Examples provided
```

---

## Best Practices

### 1. Keep Master Instructions Current
```
Update copilot-instructions.md when:
- Project structure changes
- New patterns established
- Tools added/changed
- Workflows updated

Frequency: After any significant change
```

### 2. Create Specific ChatModes
```
New ChatMode when:
- New role needed (UI Designer, Sound Engineer)
- Specialized knowledge required
- Distinct workflow exists

Keep focused: One role, clear responsibilities
```

### 3. Document All Patterns
```
Add to Instructions when:
- Pattern used 3+ times
- Team establishes convention
- Best practice identified

Keep updated: Review quarterly
```

### 4. Template All Content Creation
```
Add Prompt when:
- Content type created repeatedly
- Steps are well-defined
- Output should be consistent

Test thoroughly before committing
```

---

## Maintenance

**On Project Change:**
- Update copilot-instructions.md
- Review affected ChatModes
- Update relevant Instructions
- Verify Prompts still accurate

**Monthly:**
- Review AI effectiveness
- Update outdated content
- Add new patterns discovered
- Test workflows still work

**Per Release:**
- Verify all instructions current
- Test all workflows
- Update version references
- Archive old versions

---

**See:** .github/README.md and .github/chatmodes/README.md

**Related:**
- [systems/07_AI_GUIDANCE_SYSTEM.md](../systems/07_AI_GUIDANCE_SYSTEM.md) - AI guidance system pattern

