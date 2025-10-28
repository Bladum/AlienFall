# Development Processes

**Purpose:** Step-by-step workflows and procedures for common development tasks  
**Audience:** Developers, project managers, contributors  
**Last Updated:** 2025-10-27

---

## 📋 Process Categories

### 1. Feature Development
- [ ] Feature Request → Design → Implementation → Testing → Release
- [ ] Design approval process
- [ ] Implementation workflow
- [ ] Testing requirements
- [ ] Documentation requirements

### 2. Bug Fixing
- [ ] Bug report → Investigation → Fix → Verification → Release
- [ ] Bug triage process
- [ ] Priority assignment
- [ ] Fix validation
- [ ] Regression testing

### 3. Code Review
- [ ] Pull request creation
- [ ] Review checklist
- [ ] Approval criteria
- [ ] Merge process
- [ ] Post-merge validation

### 4. Release Management
- [ ] Version planning
- [ ] Release preparation
- [ ] Testing phase
- [ ] Deployment
- [ ] Post-release monitoring

### 5. Design Workflow
- [ ] Design proposal
- [ ] Review and feedback
- [ ] Approval process
- [ ] Implementation handoff
- [ ] Validation

---

## 🔄 Standard Workflow

**All development follows this pipeline:**

```
Design → API → Architecture → Engine → Mods → Tests → Logs
  ↓       ↓         ↓           ↓       ↓       ↓       ↓
  📝      📋        📐         💻      📦      🧪      📊
```

### Phase 1: Design
**Location:** `design/mechanics/`  
**Output:** Design specification document  
**Approval:** Design team  

### Phase 2: API
**Location:** `api/`  
**Output:** TOML schema + API documentation  
**Approval:** API architect  

### Phase 3: Architecture
**Location:** `architecture/`  
**Output:** System diagrams + integration docs  
**Approval:** System architect  

### Phase 4: Engine
**Location:** `engine/`  
**Output:** Implementation code  
**Validation:** Unit tests pass  

### Phase 5: Mods
**Location:** `mods/core/rules/`  
**Output:** Game content (TOML + assets)  
**Validation:** Content loads without errors  

### Phase 6: Tests
**Location:** `tests2/`  
**Output:** Test suite for new feature  
**Validation:** 75%+ coverage, all tests pass  

### Phase 7: Logs
**Location:** `logs/`  
**Output:** Runtime verification  
**Validation:** No errors in logs, metrics normal  

---

## 📚 Process Templates

### Feature Development Template
```markdown
# Feature: [Name]

## Design Phase
- [ ] Create design doc: design/mechanics/[feature].md
- [ ] Review design with team
- [ ] Get approval from design lead

## API Phase
- [ ] Define TOML schema in api/GAME_API.toml
- [ ] Document API in api/[SYSTEM].md
- [ ] Validate schema with tools

## Architecture Phase
- [ ] Create architecture doc: architecture/[layer]/[system].md
- [ ] Create Mermaid diagrams
- [ ] Document integration points

## Implementation Phase
- [ ] Implement in engine/[layer]/[module].lua
- [ ] Follow coding standards
- [ ] Add logging calls

## Content Phase
- [ ] Create TOML in mods/core/rules/[type]/
- [ ] Add required assets
- [ ] Validate against schema

## Testing Phase
- [ ] Write tests in tests2/[subsystem]/[module]_test.lua
- [ ] Run subsystem tests: lovec "tests2/runners" run_subsystem [name]
- [ ] Achieve 75%+ coverage

## Validation Phase
- [ ] Run game with feature enabled
- [ ] Check logs/ for errors
- [ ] Verify metrics in logs/analytics/
- [ ] Performance acceptable

## Documentation Phase
- [ ] Update all affected docs
- [ ] Update README if needed
- [ ] Create changelog entry

## Review Phase
- [ ] Create pull request
- [ ] Code review by 2+ reviewers
- [ ] Address feedback
- [ ] Get approval

## Release Phase
- [ ] Merge to develop
- [ ] Verify in develop branch
- [ ] Tag release if appropriate
```

---

## 🎯 Quality Gates

**Each phase has quality gates that must pass:**

### Design Gate
- ✅ Design document complete
- ✅ Balance parameters defined
- ✅ Edge cases considered
- ✅ Design approved

### API Gate
- ✅ Schema validated
- ✅ API documented
- ✅ Breaking changes flagged

### Architecture Gate
- ✅ Diagrams created
- ✅ Integration points documented
- ✅ Dependencies identified

### Implementation Gate
- ✅ Code compiles
- ✅ No lint errors
- ✅ Logging added

### Content Gate
- ✅ TOML validates
- ✅ Assets exist
- ✅ Content loads in game

### Testing Gate
- ✅ Tests written
- ✅ All tests pass
- ✅ 75%+ coverage

### Release Gate
- ✅ All gates passed
- ✅ Logs clean
- ✅ Documentation updated
- ✅ Code reviewed

---

## 🚀 Quick Reference

**Start new feature:**
```bash
# 1. Create design doc
docs/WIP/[feature]_design.md

# 2. When approved, move to
design/mechanics/[feature].md

# 3. Follow standard workflow above
```

**Fix a bug:**
```bash
# 1. Read logs to understand issue
cat logs/game/crash_*.log

# 2. Create fix in engine/
# 3. Add test in tests2/
# 4. Verify in logs/
```

**Review code:**
```bash
# 1. Check all phases completed
# 2. Run tests
# 3. Check logs
# 4. Review code quality
# 5. Approve or request changes
```

---

## 📚 Related Documentation

- **Development Practices:** [docs/instructions/](../instructions/)
- **System Patterns:** [docs/system/](../system/)
- **Project Handbook:** [docs/handbook/](../handbook/)
- **Content Creation:** [docs/prompts/](../prompts/)

---

**Status:** 🟡 In Development  
**Priority:** High  
**Next Steps:**
- Create detailed process documents
- Add workflow diagrams
- Document approval criteria
- Create checklists for each process

