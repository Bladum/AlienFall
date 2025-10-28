# Create Instruction Prompt
**Purpose:** Generate a new development practice/instruction guide  
**Output:** A `.instructions.md` file in `docs/instructions/`  
**Audience:** Developers, AI agents, contributors

---

## 📋 Instructions

When creating a new instruction guide, provide the following information:

### 1. Basic Information
- **Title:** Guide name with emoji (e.g., "🛠️ Love2D & Lua", "🧪 Testing")
- **Category:** Which category? (Programming, Art, Design, DevOps, Management, Security, Global, Community)
- **Purpose:** What problem does this guide solve? (1-2 sentences)
- **Audience:** Who should read this? (Beginners, Intermediate, Advanced, All)

### 2. Core Content
- **Principles:** 3-5 core principles/rules
- **Best Practices:** 10-20 specific best practices
- **Anti-Patterns:** 5-10 things to AVOID
- **Examples:** Code examples, before/after comparisons

### 3. Practical Guidance
- **Tools:** What tools are used?
- **Workflow:** Step-by-step process
- **Common Pitfalls:** What goes wrong?
- **Troubleshooting:** How to fix common issues?

### 4. Integration
- **Related Guides:** Links to other instructions
- **Project Context:** How does this fit in the project?
- **Dependencies:** What must be learned first?

---

## 📝 Template Structure

```markdown
# [Emoji] [Guide Title]

**Category:** [Programming/Art/Design/DevOps/Management/Security/Global/Community]  
**Audience:** [Beginners/Intermediate/Advanced/All]  
**Prerequisites:** [None or list prerequisites]

---

## 🎯 Purpose

**Problem:** [What problem does this solve?]

**Solution:** [How does this guide help?]

**When to Use:** [Applicable situations]

---

## 💡 Core Principles

1. **[Principle 1]:** [Explanation]
2. **[Principle 2]:** [Explanation]
3. **[Principle 3]:** [Explanation]
4. **[Principle 4]:** [Explanation]
5. **[Principle 5]:** [Explanation]

---

## ✅ Best Practices

### [Category 1]
1. **[Practice]:** [Description]
   ```[language]
   [Code example]
   ```

2. **[Practice]:** [Description]
   ```[language]
   [Code example]
   ```

### [Category 2]
[Continue pattern...]

---

## ❌ Anti-Patterns

### [Anti-Pattern 1]: [Name]
**Problem:** [Why is this bad?]

**Bad Example:**
```[language]
[Code showing anti-pattern]
```

**Good Example:**
```[language]
[Code showing correct approach]
```

**Why:** [Explanation of improvement]

---

## 🔧 Tools & Setup

**Required Tools:**
- [Tool 1] - [Purpose]
- [Tool 2] - [Purpose]
- [Tool 3] - [Purpose]

**Installation:**
```bash
[Installation commands]
```

**Configuration:**
```[format]
[Configuration examples]
```

---

## 🔄 Workflow

**Step-by-Step Process:**

1. **[Step 1]:** [Description]
   - [Detail 1]
   - [Detail 2]

2. **[Step 2]:** [Description]
   - [Detail 1]
   - [Detail 2]

[Continue for all steps...]

---

## 🎯 Real-World Examples

### Example 1: [Use Case]
**Scenario:** [Description]

**Implementation:**
```[language]
[Code example]
```

**Explanation:** [Why this works]

---

## ⚠️ Common Pitfalls

1. **[Pitfall]:** [What happens]
   - **Solution:** [How to fix]

2. **[Pitfall]:** [What happens]
   - **Solution:** [How to fix]

[Continue...]

---

## 🔍 Troubleshooting

### Problem: [Issue description]
**Symptoms:** [What you see]  
**Cause:** [Why it happens]  
**Solution:** [How to fix]

[Repeat for common issues...]

---

## 📚 Reference

**Related Guides:**
- [Guide 1]
- [Guide 2]
- [Guide 3]

**External Resources:**
- [Resource 1]
- [Resource 2]
- [Resource 3]

**Project Files:**
- [Relevant code files]
- [Configuration files]

---

## ✅ Checklist

**Before committing code:**
- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]

---

## 📊 Success Metrics

**You're following this guide successfully when:**
- [Metric 1]
- [Metric 2]
- [Metric 3]

---

**Status:** [Active/Draft/Deprecated]  
**Last Updated:** YYYY-MM-DD  
**Maintainer:** [Name/Role]
```

---

## 🚀 Usage

**AI Agent:** When asked to create an instruction guide, use this template and fill in all sections based on user requirements.

**Output Filename:** `docs/instructions/[emoji]_[title].instructions.md`

**After Creation:**
1. Add entry to `docs/instructions/README.md`
2. Add entry to `docs/instructions/INDEX_ALL_24_PRACTICES.md`
3. Update count in `docs/README.md`
4. Consider adding to `docs/instructions/START_HERE.md` if essential

---

## ✅ Validation Checklist

Before finalizing an instruction guide:
- [ ] Clear problem statement
- [ ] 3-5 core principles defined
- [ ] 10+ best practices with examples
- [ ] 5+ anti-patterns with fixes
- [ ] Code examples tested and working
- [ ] Related guides linked
- [ ] Common pitfalls documented
- [ ] Troubleshooting section complete
- [ ] Success metrics defined
- [ ] Category assigned correctly

---

**Created:** 2025-10-27  
**Purpose:** Standardize instruction guide creation  
**Location:** `docs/system/create_instruction.prompt.md`

