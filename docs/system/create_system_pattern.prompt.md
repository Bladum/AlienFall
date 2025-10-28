# Create System Pattern Prompt
**Purpose:** Generate a new universal system pattern document  
**Output:** A `NN_PATTERN_NAME_SYSTEM.md` file in `docs/system/`  
**Audience:** Architects, teams replicating the system

---

## 📋 Instructions

When creating a new system pattern, provide the following information:

### 1. Pattern Identification
- **Pattern Name:** What is this pattern called?
- **Pattern Number:** Sequential number (10, 11, 12...)
- **Problem Solved:** What specific problem does this solve?
- **Universal Applicability:** How does this apply to different domains?

### 2. Core Concept
- **Principle:** The fundamental idea (1-2 sentences)
- **Key Insight:** The "aha!" moment that makes this work
- **Trade-offs:** What do you give up for what you gain?

### 3. Architecture
- **Components:** What are the key parts?
- **Relationships:** How do parts interact?
- **Data Flow:** How does information move through the system?
- **Validation Rules:** What constraints must be enforced?

### 4. Implementation
- **Folder Structure:** What folders/files are needed?
- **Tooling:** What tools support this pattern?
- **Integration Points:** How does this connect to other patterns?

### 5. Universal Adaptation
- **Game Development:** How to use in games
- **Web Applications:** How to use in web apps
- **Data Pipelines:** How to use in data systems
- **Embedded Systems:** How to use in hardware/firmware

---

## 📝 Template Structure

```markdown
# [Pattern Name] System
**Pattern: [One-line description]**

**Purpose:** [What this pattern achieves]  
**Problem Solved:** [Specific problems this addresses]  
**Universal Pattern:** [Why this works everywhere]

---

## 🎯 Core Concept

**Principle:** [Fundamental idea]

**Diagram:**
```
[ASCII or Mermaid diagram showing concept]
```

**Key Insight:** [The crucial realization]

---

## 📁 Architecture

### Components

**Component 1: [Name]**
**Purpose:** [What it does]

**Contains:**
- [Item 1]
- [Item 2]
- [Item 3]

**Input:** [What goes in]  
**Output:** [What comes out]

**Validation Rules:**
- ✅ [Rule 1]
- ✅ [Rule 2]
- ❌ [Anti-pattern 1]
- ❌ [Anti-pattern 2]

[Repeat for all components...]

---

### Relationships

**How Components Interact:**
```
Component 1
  ↓ [Relationship]
Component 2
  ↓ [Relationship]
Component 3
```

**Data Flow:**
```
[Step-by-step data transformation]
```

---

## 🔄 Workflow

**Typical Process:**
```
Input → [Step 1] → [Step 2] → [Step 3] → Output
```

**Detailed Steps:**

1. **[Step Name]:**
   - [Action 1]
   - [Action 2]
   - [Validation]

[Continue for all steps...]

---

## 🛠️ Implementation

### Folder Structure
```
[folder_name]/
├── [subfolder1]/    [Purpose]
├── [subfolder2]/    [Purpose]
└── [file].ext      [Purpose]
```

### Tooling
- **[Tool 1]:** [Purpose]
- **[Tool 2]:** [Purpose]
- **[Tool 3]:** [Purpose]

### Code Example
```[language]
[Minimal working example]
```

---

## 🔗 Integration Points

**Related Patterns:**
- **[Pattern N]:** [How they work together]
- **[Pattern M]:** [How they work together]

**Dependencies:**
- **Requires:** [Pattern(s) that must exist first]
- **Enables:** [Pattern(s) that build on this]

---

## 🌍 Universal Adaptation

### For Game Development
**Adaptation:**
- [Folder] → [Game equivalent]
- [Component] → [Game equivalent]

**Example:**
```
[Game-specific implementation]
```

### For Web Applications
**Adaptation:**
- [Folder] → [Web equivalent]
- [Component] → [Web equivalent]

**Example:**
```
[Web-specific implementation]
```

### For Data Pipelines
**Adaptation:**
- [Folder] → [Data equivalent]
- [Component] → [Data equivalent]

**Example:**
```
[Data-specific implementation]
```

### For Embedded Systems
**Adaptation:**
- [Folder] → [Hardware equivalent]
- [Component] → [Hardware equivalent]

**Example:**
```
[Embedded-specific implementation]
```

---

## 📊 Success Metrics

**This pattern is working when:**
- ✅ [Metric 1]
- ✅ [Metric 2]
- ✅ [Metric 3]

**Measurements:**
- [Quantifiable metric 1]: [Target]
- [Quantifiable metric 2]: [Target]

---

## 🚧 Implementation Checklist

### Phase 1: Foundation
- [ ] [Task 1]
- [ ] [Task 2]
- [ ] [Task 3]

### Phase 2: Integration
- [ ] [Task 1]
- [ ] [Task 2]
- [ ] [Task 3]

### Phase 3: Validation
- [ ] [Task 1]
- [ ] [Task 2]
- [ ] [Task 3]

---

## ⚠️ Common Pitfalls

**Pitfall 1: [Name]**
**Problem:** [What goes wrong]  
**Solution:** [How to avoid]

[Continue for 5+ pitfalls...]

---

## 🎓 Key Takeaways

1. **[Takeaway 1]:** [Explanation]
2. **[Takeaway 2]:** [Explanation]
3. **[Takeaway 3]:** [Explanation]
4. **[Takeaway 4]:** [Explanation]
5. **[Takeaway 5]:** [Explanation]

---

## 📚 References

**Related Patterns:**
- [Pattern 1]
- [Pattern 2]
- [Pattern 3]

**External Resources:**
- [Resource 1]
- [Resource 2]

**Project Files:**
- [Relevant files]

---

**Last Updated:** YYYY-MM-DD  
**Status:** 🟢 Pattern documented, ready for implementation  
**Next Step:** [What to implement next]
```

---

## 🚀 Usage

**AI Agent:** When asked to create a system pattern, use this template and fill in all sections based on the pattern being documented.

**Output Filename:** `docs/system/[NN]_[PATTERN_NAME]_SYSTEM.md`

**Numbering:** Use next available number (current highest + 1)

**After Creation:**
1. Add entry to `docs/system/README.md` (if exists)
2. Update pattern count in `docs/README.md`
3. Update integration map showing relationships
4. Add cross-references from related patterns

---

## ✅ Validation Checklist

Before finalizing a pattern:
- [ ] Clear problem statement
- [ ] Core concept explained with diagram
- [ ] All components documented
- [ ] Data flow visualized
- [ ] Validation rules specified
- [ ] Implementation example provided
- [ ] Universal adaptations for 4+ domains
- [ ] Success metrics defined
- [ ] Common pitfalls documented
- [ ] Integration points identified
- [ ] Implementation checklist complete
- [ ] Key takeaways summarized

---

## 💡 Pattern Quality Standards

**A good pattern:**
- Solves ONE problem well
- Works in multiple domains (universal)
- Has clear validation rules
- Includes working examples
- Defines success metrics
- Documents common mistakes
- Shows integration with other patterns

**Avoid:**
- Vague, abstract concepts
- Domain-specific solutions
- Missing validation rules
- No examples
- Unclear success criteria

---

**Created:** 2025-10-27  
**Purpose:** Standardize system pattern documentation  
**Location:** `docs/system/create_system_pattern.prompt.md`
# Create ChatMode Prompt
**Purpose:** Generate a new AI agent persona/chatmode for specialized development tasks  
**Output:** A `.chatmode.md` file in `docs/chatmodes/`  
**Audience:** AI agents, documentation maintainers

---

## 📋 Instructions

When creating a new chatmode, provide the following information:

### 1. Basic Information
- **Name:** The role/persona name (e.g., "Game Designer", "Engine Developer")
- **Layer:** Which layer? (Strategic, Design, Implementation, Testing, Analysis, Support)
- **Purpose:** What does this persona do? (1-2 sentences)
- **Primary Responsibilities:** 3-5 key tasks this persona handles

### 2. Core Competencies
- **Skills:** What technical/domain skills does this persona have?
- **Knowledge Areas:** What domains must this persona understand?
- **Tools:** What tools/systems does this persona use?

### 3. Behavioral Guidelines
- **Communication Style:** How should this persona communicate?
- **Decision Making:** How does this persona make decisions?
- **Collaboration:** How does this persona work with other roles?
- **Quality Standards:** What quality bars must this persona maintain?

### 4. Task Examples
Provide 5-10 example tasks this persona handles:
- "Design unit progression system"
- "Implement combat resolver"
- "Write integration tests"
- etc.

### 5. Success Criteria
How do you measure if this persona is doing well?
- Code quality metrics
- Documentation standards
- Test coverage
- Performance benchmarks
- etc.

---

## 📝 Template Structure

```markdown
# [Role Name] ChatMode
**Layer:** [Strategic/Design/Implementation/Testing/Analysis/Support]  
**Focus:** [Primary domain/responsibility]  
**Autonomy Level:** [High/Medium/Low]

---

## 🎯 Role Definition

**Purpose:** [What this persona does]

**Primary Responsibilities:**
1. [Responsibility 1]
2. [Responsibility 2]
3. [Responsibility 3]

**Key Deliverables:**
- [Deliverable 1]
- [Deliverable 2]
- [Deliverable 3]

---

## 🧠 Core Competencies

**Technical Skills:**
- [Skill 1]
- [Skill 2]
- [Skill 3]

**Knowledge Areas:**
- [Domain 1]
- [Domain 2]
- [Domain 3]

**Tools & Systems:**
- [Tool 1]
- [Tool 2]
- [Tool 3]

---

## 📐 Behavioral Guidelines

### Communication Style
[How this persona communicates]

### Decision Making
[How decisions are made]

### Collaboration
[How to work with other roles]

### Quality Standards
[Quality expectations]

---

## 🔄 Workflow

**Typical Task Flow:**
```
Input → Analysis → Planning → Implementation → Validation → Documentation → Output
```

**Detailed Steps:**
1. [Step 1 description]
2. [Step 2 description]
3. [Step 3 description]

---

## 📚 Reference Documentation

**Must Read:**
- [Document 1]
- [Document 2]
- [Document 3]

**Related ChatModes:**
- [Role 1] - [Relationship]
- [Role 2] - [Relationship]

---

## ✅ Success Criteria

**This persona is successful when:**
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]

**Quality Metrics:**
- [Metric 1]: [Target]
- [Metric 2]: [Target]
- [Metric 3]: [Target]

---

## 🎯 Example Tasks

### Task 1: [Task Name]
**Input:** [What's provided]  
**Process:** [How to approach]  
**Output:** [What's delivered]

### Task 2: [Task Name]
**Input:** [What's provided]  
**Process:** [How to approach]  
**Output:** [What's delivered]

[Continue for 5-10 example tasks]

---

## ⚠️ Common Pitfalls

**Avoid:**
- [Pitfall 1]
- [Pitfall 2]
- [Pitfall 3]

**Instead:**
- [Best practice 1]
- [Best practice 2]
- [Best practice 3]

---

**Status:** [Draft/Active/Deprecated]  
**Last Updated:** YYYY-MM-DD  
**Maintainer:** [Name/Role]
```

---

## 🚀 Usage

**AI Agent:** When asked to create a chatmode, use this template and fill in all sections based on user requirements.

**Output Filename:** `docs/chatmodes/[role_name_lowercase].chatmode.md`

**After Creation:**
1. Add entry to `docs/chatmodes/README.md`
2. Add entry to `docs/chatmodes/QUICK-REFERENCE.md`
3. Update count in `docs/README.md`

---

## ✅ Validation Checklist

Before finalizing a chatmode:
- [ ] All sections filled in
- [ ] Clear, actionable responsibilities
- [ ] Specific, measurable success criteria
- [ ] 5+ example tasks provided
- [ ] Related chatmodes identified
- [ ] Reference documentation linked
- [ ] Communication style defined
- [ ] Quality standards explicit

---

**Created:** 2025-10-27  
**Purpose:** Standardize chatmode creation  
**Location:** `docs/system/create_chatmode.prompt.md`

