# Pipeline Architecture System
**Pattern: Unidirectional Multi-Stage Information Flow**

**Purpose:** Transform abstract concepts through progressive refinement into executable reality  
**Problem Solved:** Bidirectional dependencies, skipped stages, inconsistent transformations, drift between specification and implementation  
**Universal Pattern:** Applicable to any project where specifications become implementations - software, hardware, content production, manufacturing

---

## 🎯 Core Concept

**Principle:** Information flows in ONE direction through discrete stages, each transforming it closer to executable form. Never skip stages. Never reverse flow.

```
STAGE 1: SPECIFICATION (design/)
    ↓ transforms into
STAGE 2: CONTRACT (api/)
    ↓ transforms into
STAGE 3: BLUEPRINT (architecture/)
    ↓ transforms into
STAGE 4: CODE (engine/)
    ↓ transforms into
STAGE 5: DATA (mods/)
    ↓ validates via
STAGE 6: PROOF (tests2/)
```

**Key Rules:**
1. Each stage ONLY depends on previous stages
2. Never skip stages (maintains consistency)
3. Never reverse flow (prevents circular dependencies)
4. Feedback loops ONLY for corrections, not redesign

**Why This Works:**
- **Progressive Refinement:** Each stage adds precision
- **Clear Dependencies:** Later stages depend on earlier
- **Validation Points:** Check correctness at each boundary
- **Reversible Changes:** Can update earlier stage and flow forward again

---

## 📊 The Six Stages Detailed

### Stage 1: SPECIFICATION → What & Why

**Purpose:** Document WHAT the system should do and WHY

**Input:** Product requirements, user stories, business goals, stakeholder needs  
**Process:** Document functional requirements and design rationale  
**Output:** Design specifications in markdown  
**Folder:** `design/`

**Transformation Example:**
```
Vague idea: "Players should feel progression"
    ↓ refine
Specification: "Units gain 5 XP per kill, promote at 100 XP, +10% stats per rank"
```

**Validation Gate:**
- Is WHAT clear? (mechanic fully defined)
- Is WHY explained? (rationale provided)
- Are edge cases covered? (boundary conditions documented)
- No implementation HOW? (stays abstract)

**Artifacts:**
- design/mechanics/Units.md
- design/mechanics/Combat.md
- design/GLOSSARY.md

---

### Stage 2: CONTRACT → Interface Definition

**Purpose:** Formalize specifications into machine-readable contracts

**Input:** Design specifications from Stage 1  
**Process:** Transform prose into schemas, types, and function signatures  
**Output:** API contracts and TOML schemas  
**Folder:** `api/`

**Transformation Example:**
```
Specification: "Units gain 5 XP per kill"
    ↓ formalize
Contract: 
  - Function: gainExperience(amount: integer) → void
  - Schema: experience = { type = "integer", range = [0, 999999] }
  - Validation: amount >= 0, type must be integer
```

**Validation Gate:**
- All design specs have contracts? (completeness)
- Types clearly defined? (integer, string, boolean, etc.)
- Constraints specified? (ranges, required fields, patterns)
- No implementation details? (interface only)

**Artifacts:**
- api/GAME_API.toml (master schema)
- api/UNITS.md (documentation)
- api/SYNCHRONIZATION_GUIDE.md

---

### Stage 3: BLUEPRINT → Visual Structure

**Purpose:** Visualize system organization and data flows

**Input:** API contracts from Stage 2  
**Process:** Create diagrams showing structure and relationships  
**Output:** Mermaid diagrams, component relationships, sequences  
**Folder:** `architecture/`

**Transformation Example:**
```
Contract: gainExperience(amount: integer) → void
    ↓ visualize
Blueprint: 
  Battle System → Unit Manager → Unit Instance
  Unit → XP Calculator → Promotion Checker
  (Sequence diagram showing call order)
```

**Validation Gate:**
- All APIs shown in diagrams? (coverage)
- Data flows clear? (arrows show direction)
- Integration points identified? (system boundaries)
- No code-level details? (stays architectural)

**Artifacts:**
- architecture/systems/progression.md
- architecture/layers/BATTLESCAPE.md
- Mermaid diagrams embedded in markdown

---

### Stage 4: CODE → Implementation

**Purpose:** Implement the actual working system

**Input:** API contracts + architecture blueprints  
**Process:** Write executable code following specifications  
**Output:** Source code files  
**Folder:** `engine/`

**Transformation Example:**
```
Blueprint: Battle → Unit → gainExperience()
    ↓ implement
Code:
  function Unit:gainExperience(amount)
      assert(type(amount) == "number", "Amount must be integer")
      assert(amount >= 0, "Amount must be non-negative")
      self.experience = self.experience + amount
      if self.experience >= 100 then
          self.can_promote = true
      end
  end
```

**Validation Gate:**
- Implements ALL API contracts? (completeness)
- Follows architecture structure? (no drift)
- No hardcoded values? (uses config)
- Error handling present? (robustness)

**Artifacts:**
- engine/battlescape/units/unit.lua
- engine/core/state_manager.lua
- Implementation code

---

### Stage 5: DATA → Configuration

**Purpose:** Separate configurable data from code logic

**Input:** API schemas from Stage 2  
**Process:** Create data files matching schemas  
**Output:** TOML configs and asset files  
**Folder:** `mods/`

**Transformation Example:**
```
Schema: experience = { type = "integer", range = [0, 999999] }
    ↓ configure
Data:
  [unit.rookie]
  experience = 0
  xp_to_next_rank = 100
  
  [unit.veteran]
  experience = 250
  xp_to_next_rank = 100
```

**Validation Gate:**
- Validates against schema? (type, range, required fields)
- All required fields present? (completeness)
- Values in valid ranges? (constraints)
- Assets exist and correct format? (PNG, OGG, etc.)

**Artifacts:**
- mods/core/rules/units/soldiers.toml
- mods/core/assets/units/rookie.png
- Configuration data

---

### Stage 6: PROOF → Validation

**Purpose:** Verify implementation correctness through testing

**Input:** Implemented code from Stage 4  
**Process:** Test execution and measure coverage  
**Output:** Test results and coverage reports  
**Folder:** `tests2/`

**Transformation Example:**
```
Code: function Unit:gainExperience(amount) ... end
    ↓ test
Proof:
  suite:testMethod("gainExperience", "Adds XP correctly", function()
      local unit = Unit.new()
      unit.experience = 100
      unit:gainExperience(50)
      assert(unit.experience == 150)
  end)
  
  Result: ✓ PASS (Coverage: 85%)
```

**Validation Gate:**
- Tests exist for all public functions? (coverage)
- Coverage >75% per module? (thoroughness)
- All tests pass? (correctness)
- Fast execution (<1s full suite)? (performance)

**Artifacts:**
- tests2/battlescape/unit_test.lua
- Test results and coverage reports
- Continuous validation

---

## 🔄 Information Flow Rules

### Rule 1: Unidirectional Flow

**Correct Flow:**
```
✓ Design → API → Architecture → Engine → Content → Tests
  (Each stage builds on previous)
```

**Incorrect Flows:**
```
✗ Engine → Architecture (backwards!)
  Problem: Implementation dictating structure

✗ Design → Engine (skipping stages!)
  Problem: No formal contract, no validation

✗ API ← Engine (reverse dependency)
  Problem: Tail wagging dog
```

**Why Unidirectional:**
- **Predictable:** Always know what depends on what
- **Maintainable:** Changes flow forward naturally
- **Testable:** Can validate at each boundary
- **Scalable:** Adding stages doesn't break flow

---

### Rule 2: Stage Dependencies

**Dependency Matrix:**
```
Stage 2 (API) can depend on:
  ✓ Stage 1 (Design) - specs inform contracts
  ✗ Stage 3 (Architecture) - doesn't exist yet!
  ✗ Stage 4 (Engine) - implementation comes later
  
Stage 4 (Engine) can depend on:
  ✓ Stage 2 (API) - implements contracts
  ✓ Stage 3 (Architecture) - follows structure
  ✓ Stage 1 (Design) - for context only
  ✗ Stage 5 (Content) - engine loads content, not vice versa
```

**Why Dependencies Matter:**
- **Build Order:** Can't build roof before walls
- **Change Impact:** Know what needs updating
- **Validation:** Each stage validates against dependencies
- **Parallel Work:** Independent stages can work simultaneously

---

### Rule 3: Feedback Loops (Corrections Only)

**Allowed Feedback:**
```
✓ Implementation reveals API gap → Update API → Re-implement
  (Discovered missing contract)

✓ Testing finds design flaw → Update design → Flow forward again
  (Correction of mistake)

✓ Architecture shows structure problem → Redesign → Flow forward
  (Found better approach)
```

**Forbidden Feedback:**
```
✗ Engine convenience dictates API
  (Implementation driving interface - wrong!)

✗ Content format forces API changes
  (Data format shouldn't dictate contract)

✗ Tests require design changes
  (Tests verify design, don't create it)
```

**Why Feedback Rules:**
- **Corrections vs Redesign:** Fix mistakes, don't redesign backwards
- **Authority:** Earlier stages are authoritative
- **Change Management:** All changes flow forward after correction
- **Documentation:** Corrections get documented in design

---

## 🔁 Complete Pipeline Example

### Feature: Unit Promotion System

**STAGE 1: SPECIFICATION**
```markdown
File: design/mechanics/Units.md

## Promotion System

### Mechanic
- Units promoted at 100 XP threshold
- Stats increase 10% per promotion
- Maximum 7 ranks (Rookie → Colonel)

### Rationale
- 100 XP = ~20 kills = 2-3 missions (meaningful achievement)
- 10% increase noticeable but not overpowered
- 7 ranks provides long-term progression

### Edge Cases
- Q: Exactly 100 XP earned mid-mission?
- A: Promotion eligibility set, applied after mission

### Player Experience
- Early: Protect rookies, build veterans
- Late: Elite squads dominate
```

**↓ transforms into**

**STAGE 2: CONTRACT**
```toml
File: api/GAME_API.toml

[entities.unit.functions.promote]
parameters = []
returns = "boolean"
description = "Promote unit to next rank if eligible"
validation = [
    "can_promote must be true",
    "rank < 7 (max rank)"
]

[entities.unit.fields]
rank = { type = "integer", range = [1, 7], required = true }
experience = { type = "integer", range = [0, 999999] }
can_promote = { type = "boolean", default = false }
xp_to_next_rank = { type = "integer", default = 100 }
```

**↓ transforms into**

**STAGE 3: BLUEPRINT**
```mermaid
File: architecture/systems/progression.md

sequenceDiagram
    participant Player
    participant Battle
    participant Unit
    participant XPCalc
    participant UI
    
    Battle->>Unit: gainExperience(5)
    Unit->>Unit: experience += 5
    Unit->>XPCalc: checkThreshold(105)
    XPCalc->>XPCalc: 105 >= 100?
    XPCalc->>Unit: setPromotable(true)
    Unit->>Battle: promotion available
    Battle->>UI: show promotion button
    Player->>Unit: promote()
    Unit->>Unit: rank += 1
    Unit->>Unit: stats *= 1.1
    Unit->>Unit: can_promote = false
```

**↓ transforms into**

**STAGE 4: CODE**
```lua
File: engine/battlescape/units/unit.lua

-- Implements api/UNITS.md → promote() function
function Unit:promote()
    -- Validation per API contract
    if not self.can_promote then
        return false -- Not eligible
    end
    
    if self.rank >= 7 then
        return false -- Max rank reached
    end
    
    -- Implementation per design spec (10% stat increase)
    self.strength = math.floor(self.strength * 1.1)
    self.dexterity = math.floor(self.dexterity * 1.1)
    self.constitution = math.floor(self.constitution * 1.1)
    
    -- Update state
    self.rank = self.rank + 1
    self.can_promote = false
    
    return true
end
```

**↓ transforms into**

**STAGE 5: DATA**
```toml
File: mods/core/rules/units/soldiers.toml

[unit.rookie]
id = "rookie"
name = "Rookie Soldier"
rank = 1
experience = 0
xp_to_next_rank = 100
can_promote = false

# Starting stats from design spec
strength = 8
dexterity = 7
constitution = 9

sprite = "units/rookie.png"
```

**↓ validates via**

**STAGE 6: PROOF**
```lua
File: tests2/battlescape/unit_test.lua

-- Test: Happy path
suite:testMethod("promote", "Increases rank and stats", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.strength = 10
    unit.can_promote = true
    unit.rank = 1
    
    local result = unit:promote()
    
    suite:assert(result == true, "Should succeed")
    suite:assert(unit.rank == 2, "Rank should increase")
    suite:assert(unit.strength == 11, "Strength should increase 10%")
    suite:assert(unit.can_promote == false, "Flag should reset")
end)

-- Test: Error case
suite:testMethod("promote", "Rejects when not eligible", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.can_promote = false
    
    local result = unit:promote()
    
    suite:assert(result == false, "Should fail")
    suite:assert(unit.rank == 1, "Rank unchanged")
end)

-- Test: Edge case
suite:testMethod("promote", "Rejects at max rank", function()
    local unit = Unit.new("colonel", "Test", 7)
    unit.can_promote = true
    
    local result = unit:promote()
    
    suite:assert(result == false, "Should fail at max rank")
    suite:assert(unit.rank == 7, "Rank stays at max")
end)
```

**Result:** Complete feature implemented through full pipeline with validation at every stage.

---

## ✅ Validation Between Stages

### Design → API Validation

**Rule:** Every design decision has corresponding API contract

**Check Tool:**
```bash
tools/validators/design_api_gap.lua design/ api/

# Checks:
# - design/ mentions "promotion" → api/ defines promote()?
# - design/ specifies "7 ranks" → api/ has rank range [1,7]?
# - design/ mentions "XP threshold" → api/ defines xp_to_next_rank?
```

**Common Violations:**
- Design describes mechanic, no API contract exists
- API defines function, no design rationale
- Design mentions value, API doesn't define field

**Fix Process:**
1. Identify gap
2. Update API (Stage 2)
3. Re-validate
4. Flow forward to remaining stages

---

### API → Architecture Validation

**Rule:** All APIs appear in architecture diagrams

**Check Tool:**
```bash
tools/validators/api_architecture_coverage.lua api/ architecture/

# Checks:
# - api/ defines promote() → architecture/ shows where it's called?
# - api/ defines relationships → architecture/ diagrams them?
# - api/ specifies data flow → architecture/ visualizes it?
```

**Common Violations:**
- API function exists, no sequence diagram
- API relationship defined, no component diagram
- Complex flow not visualized

**Fix Process:**
1. Identify missing diagrams
2. Create architecture documentation (Stage 3)
3. Verify coverage
4. Update as needed

---

### Architecture → Engine Validation

**Rule:** Code structure matches architecture diagrams

**Check Tool:**
```bash
tools/validators/architecture_engine_drift.lua architecture/ engine/

# Checks:
# - Architecture: Battle → UnitManager → Unit
# - Engine: Does code follow this structure?
# - Architecture: EventBus pattern shown
# - Engine: Is EventBus actually used?
```

**Common Violations:**
- Architecture shows pattern X, engine uses pattern Y
- Architecture shows Manager layer, engine has direct calls
- Diagram shows component, code doesn't have it

**Fix Process:**
1. Detect drift
2. Decide: Update architecture OR refactor engine
3. Choose one direction (usually refactor engine)
4. Re-validate

---

### Engine → Content Validation

**Rule:** TOML content validates against API schema

**Check Tool:**
```bash
tools/validators/toml_validator.lua mods/ api/GAME_API.toml

# Checks:
# - rank = 8 → OUT OF RANGE [1,7] ✗
# - experience = "100" → WRONG TYPE (string vs integer) ✗
# - missing 'name' field → REQUIRED FIELD MISSING ✗
```

**Common Violations:**
- Value exceeds schema range
- Wrong data type
- Missing required field
- Unknown field not in schema

**Fix Process:**
1. Run validator
2. Correct TOML to match schema
3. Re-validate
4. Test in-game

---

### Code → Tests Validation

**Rule:** Test coverage meets threshold

**Check Tool:**
```bash
lovec tests2/runners run_coverage

# Checks:
# - promote() function exists → has tests?
# - Tests cover: happy path, errors, edge cases?
# - Coverage percentage: >75%?
```

**Common Violations:**
- Function exists, no tests
- Tests exist but insufficient scenarios
- Coverage below threshold

**Fix Process:**
1. Run coverage analyzer
2. Generate test stubs for untested functions
3. Implement test scenarios
4. Verify coverage >75%

---

## 🚫 Pipeline Anti-Patterns

### Anti-Pattern 1: Skipping Stages

**Wrong:**
```
Design → Engine (skipped API and Architecture!)

Problems:
- No schema to validate content against
- No architectural guidance for structure
- No clear contracts
- Drift inevitable
```

**Right:**
```
Design → API → Architecture → Engine

Benefits:
- Clear contracts at each stage
- Validation possible
- Structure guided
- Consistency maintained
```

**Why It Matters:**
Each skipped stage loses information and validation opportunities.

---

### Anti-Pattern 2: Reverse Flow

**Wrong:**
```
Engine implementation complete → Now write API to match code

Problems:
- API serves implementation, not design
- Design intent lost
- Tail wagging dog
- Impossible to validate
```

**Right:**
```
Design defines intent → API formalizes → Engine implements

Benefits:
- Implementation serves design
- Intent preserved throughout
- Proper dependency direction
- Validation at each stage
```

**Why It Matters:**
Direction of authority determines who serves whom.

---

### Anti-Pattern 3: Stage Mixing

**Wrong:**
```
Design document contains:
- "Use hash table for O(1) lookup" (implementation!)
- "function promote() returns boolean" (API!)
- "Battle → Unit flow diagram" (architecture!)

Everything mixed together in one place.
```

**Right:**
```
design/: WHAT and WHY (mechanics, rationale)
api/: HOW (interface contracts)
architecture/: HOW (visual structure)
engine/: HOW (executable code)

Each stage pure and focused.
```

**Why It Matters:**
Mixing stages prevents clean separation and validation.

---

### Anti-Pattern 4: Bidirectional Dependencies

**Wrong:**
```
API ← Engine (engine dictates API)
Design ← API (API dictates design)

Result: Circular dependencies, impossible to change
```

**Right:**
```
Design → API → Engine (unidirectional)

Result: Clear dependency chain, easy to change upstream
```

**Why It Matters:**
Circular dependencies create deadlock when changes needed.

---

## 🔧 Tools for Pipeline Integrity

### 1. Stage Completion Checker

**Tool:** `tools/validators/pipeline_completion.lua [feature_name]`

**Checks:**
```
For feature "unit_promotion":
✓ Stage 1: design/mechanics/Units.md mentions promotion
✓ Stage 2: api/GAME_API.toml defines promote()
✓ Stage 3: architecture/systems/progression.md diagrams it
✓ Stage 4: engine/battlescape/units/unit.lua implements it
✓ Stage 5: mods/core/rules/units/ configures it
✓ Stage 6: tests2/battlescape/unit_test.lua tests it

Result: Pipeline COMPLETE ✓
```

**Usage:**
```bash
lua tools/validators/pipeline_completion.lua unit_promotion
```

---

### 2. Flow Direction Validator

**Tool:** `tools/validators/flow_direction.lua`

**Checks:**
```
Analyzing dependencies...

✓ design/ files don't import from api/
✓ api/ files don't import from architecture/
✓ architecture/ files don't import from engine/
✗ engine/unit.lua imports from design/ (VIOLATION!)

Error: Reverse dependency detected
File: engine/unit.lua line 5
Fix: Remove design/ import, reference via comment only
```

**Usage:**
```bash
lua tools/validators/flow_direction.lua
```

---

### 3. Stage Synchronization Checker

**Tool:** `tools/validators/pipeline_sync.lua`

**Checks:**
```
Checking synchronization...

✓ Design mentions "7 ranks" → API defines range [1,7]
✓ API defines promote() → Engine implements promote()
✗ Design mentions "medals" → API has no medal schema (GAP!)

Gaps found: 1
Action: Create api/MEDALS.md
```

**Usage:**
```bash
lua tools/validators/pipeline_sync.lua
```

---

### 4. Integration Test

**Tool:** `tools/validators/pipeline_integration.lua`

**Tests:**
```
Running integration tests...

1. Design → API
   ✓ All design decisions have API contracts
   
2. API → Architecture
   ✓ All APIs shown in diagrams
   
3. Architecture → Engine
   ✓ Code structure matches architecture
   
4. Engine → Content
   ✓ All TOML validates against schema
   
5. Code → Tests
   ✓ Coverage >75% for all modules

Pipeline integrity: 100% ✓
```

**Usage:**
```bash
lua tools/validators/pipeline_integration.lua
```

---

## 📊 Pipeline Health Metrics

### Metric 1: Stage Completion

**Target:**
```
Features completing all 6 stages: >90%
Features skipping stages: <10%
Emergency skip rate (hotfixes): <5%
```

**Measurement:**
```bash
lua tools/reports/pipeline_completion_rate.lua

# Output:
Analyzed 150 features:
- Complete pipeline: 142 (94.7%) ✓
- Skipped stages: 8 (5.3%) ✓
- Emergency skips: 3 (2.0%) ✓

Status: HEALTHY
```

---

### Metric 2: Flow Direction

**Target:**
```
Forward references: 100%
Backward references: 0%
Circular dependencies: 0
```

**Measurement:**
```bash
lua tools/reports/dependency_analysis.lua

# Output:
Dependency Analysis:
- Forward deps: 487 (100%) ✓
- Backward deps: 0 (0%) ✓
- Circular deps: 0 (0%) ✓

Status: CLEAN
```

---

### Metric 3: Synchronization

**Target:**
```
Design-API sync: 100%
API-Architecture sync: >95%
Architecture-Engine sync: >95%
Engine-Content validation: 100%
```

**Measurement:**
```bash
lua tools/reports/sync_analysis.lua

# Output:
Synchronization Status:
- Design ↔ API: 100% (147/147) ✓
- API ↔ Architecture: 97% (143/147) ⚠
- Architecture ↔ Engine: 96% (141/147) ⚠
- Engine ↔ Content: 100% (523/523) ✓

Action: Review 4 architecture diagrams (outdated)
```

---

### Metric 4: Validation Pass Rate

**Target:**
```
TOML validation: 100%
Test coverage: >75% per module
All tests passing: 100%
Architecture matches engine: >95%
```

**Measurement:**
```bash
lua tools/reports/validation_summary.lua

# Output:
Validation Summary:
- TOML validation: 100% (0 errors) ✓
- Test coverage: 82% (>75% target) ✓
- Tests passing: 100% (2493/2493) ✓
- Arch-Engine match: 96% (141/147) ⚠

Status: GOOD (1 minor issue)
```

---

## 🌍 Universal Adaptation

### Pattern in Different Domains

**Software Product:**
```
Requirements → API Specs → System Design → Code → Config → Tests
```

**Data Pipeline:**
```
Data Spec → Schema → Flow Diagram → Transforms → Sources → Validation
```

**Hardware Product:**
```
Requirements → Interface Spec → Circuit Design → PCB → BOM → Testing
```

**Content Production:**
```
Brief → Content Spec → Structure → Writing → Assets → QA
```

**Manufacturing:**
```
Design → Specifications → CAD → Production → Parts → QC
```

**Key Insight:** The STAGES remain constant. The NAMES adapt to domain. The PATTERN is universal.

---

## 🎯 Success Criteria

Pipeline is working correctly when:

✅ **Completeness:** All features flow through all stages sequentially  
✅ **Direction:** No backwards dependencies detected  
✅ **Validation:** Each stage validates against previous successfully  
✅ **Synchronization:** All stages remain synchronized (no drift)  
✅ **Quality:** Stage outputs meet defined standards  
✅ **Speed:** Pipeline doesn't slow development significantly  
✅ **Skip Rate:** <10% of features skip stages (only emergencies)  
✅ **Team Understanding:** Everyone knows and follows the pipeline  

---

## 📝 Implementation Checklist

To implement this pattern in your project:

### Phase 1: Define Stages
- [ ] Identify your 4-6 stages
- [ ] Name stages appropriately for your domain
- [ ] Define purpose of each stage
- [ ] Establish clear outputs for each stage

### Phase 2: Create Folders
- [ ] Create folder for each stage
- [ ] Document what goes in each folder
- [ ] Create templates for common artifacts
- [ ] Set up folder structure

### Phase 3: Define Validation
- [ ] Define validation rules between stages
- [ ] Build or adapt validation tools
- [ ] Set up automated validation
- [ ] Establish quality thresholds

### Phase 4: Train Team
- [ ] Document the pipeline
- [ ] Explain WHY each stage matters
- [ ] Train on tools and validation
- [ ] Establish code review for compliance

### Phase 5: Enforce and Monitor
- [ ] Integrate validation into CI/CD
- [ ] Track metrics (completion rate, sync, etc.)
- [ ] Review regularly for compliance
- [ ] Iterate on process based on feedback

---

**Related Systems:**
- [01_SEPARATION_OF_CONCERNS_SYSTEM.md](01_SEPARATION_OF_CONCERNS_SYSTEM.md) - Defines the 5 concerns the pipeline connects
- [04_HIERARCHICAL_TESTING_SYSTEM.md](04_HIERARCHICAL_TESTING_SYSTEM.md) - Stage 6 of the pipeline
- [03_DATA_DRIVEN_CONTENT_SYSTEM.md](03_DATA_DRIVEN_CONTENT_SYSTEM.md) - Stage 5 of the pipeline

**See:** modules/README.md for folder-specific usage

**Last Updated:** 2025-10-27  
**Pattern Maturity:** Production-Proven

---

*"A pipeline is not about bureaucracy—it's about transforming vague ideas into precise reality through progressive refinement."*

