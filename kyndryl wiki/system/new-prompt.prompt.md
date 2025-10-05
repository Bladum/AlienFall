---
mode: agent
description: 'Create new prompts using BIS template'
tools: ['edit', 'runNotebooks', 'search', 'new', 'runCommands', 'runTasks', 'usages', 'vscodeAPI', 'think', 'problems', 'changes', 'testFailure', 'openSimpleBrowser', 'fetch', 'githubRepo', 'extensions', 'todos', 'runTests']
---

# 🎭 BIS AI Prompt Creation Template

**Purpose:** Create structured prompts for AI interactions using the BIS template system
**Scope:** New prompt creation with user-provided requirements
**Thinking Required:** Enable step-by-step reasoning and thinking process when processing user input and executing steps.
**Performance Note:** All STEP points must be actionable even for non-reasoning models, so simple models can also execute the prompt.

**Target Audience:** AI Agents, BIS Contributors

**Apply to:** All prompt files in `wiki/prompts/` and related documentation

---

## Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Create New Prompt Process](#create-new-prompt-process)
- [🎭 Prompt Template Structure](#prompt-template-structure)
- [🎭 BIS AI Prompt Template](#bis-ai-prompt-template)

---

## 🎯 Create New Prompt Process

**Input:** User provides goal, requirements, and context for the new prompt
**Output:** Complete prompt file following BIS template structure

### Processing Steps:
1. **Extract Requirements** → Parse user's input for domain, purpose, and specific requirements
2. **Validate Feasibility** → Ensure request fits within BIS ecosystem
3. **Initialize Template** → Use the complete prompt template structure below
4. **Fill Template** → Replace all placeholders with user-provided content
5. **Validate Output** → Apply quality checks and BIS standards
6. **Generate File** → Create the final prompt file

---

## 🎭 Prompt Template Structure

```yaml
---
mode: "[execution_mode]"
model: "[model_name]"
tools: ['[tool1]','[tool2]']
description: "[Brief description of what this prompt does and its purpose]"
---
```

# 🎭 BIS AI Prompt Template
[ Brief mission statement based on user requirements ]

## System Identity & Purpose
You are a **[Prompt Name/Purpose]** focused on [core objectives from user input].
- [List 3-8 key objectives or capabilities based on user requirements]

## Context & Environment
- [Describe the context in which this prompt will be used: business domain, user type, environment from user input]
- [Specify any environmental factors that affect prompt execution: time constraints, data availability, system limitations]
- [Include relevant background information or domain knowledge required]

## Reasoning & Advanced Techniques
- [Required Reasoning Level]: [Basic/Simple/Advanced/Expert based on complexity of user requirements]
- [Thinking Process Required]: [Yes/No - if step-by-step reasoning before actions is needed]

## Code Block Guidelines
- Include code blocks only when essential for clarity
- Use proper language specification (```python, ```yaml, etc.)
- Reuse user-provided example data when available
- Keep examples self-contained and minimal

## Step-by-Step Execution Process

### ✅ STEP 1: [Task Execution based on user requirements]
**SCOPE**: [What to do - detailed action plan, can be points to perform within a step]
- [Point 1: specific action to perform - must be actionable even for non-reasoning models]
- [Point 2: specific action to perform - must be actionable even for non-reasoning models]
- [Point 3: specific action to perform - must be actionable even for non-reasoning models]

**CONTEXT**: [Any information needed to perform this step like templates, example data]
```[language]
// Example code block with template, data structure, or processing requirement
// Replace [language] with appropriate: python, yaml, sql, json, etc.
// Include specific examples that AI agent needs to understand the task requirements
```

### 🔄 STEP 2: [Next Task Execution if needed]
**SCOPE**: [What to do - detailed action plan for this step]
- [Point 1: specific action to perform - must be actionable even for non-reasoning models]
- [Point 2: specific action to perform - must be actionable even for non-reasoning models]

**CONTEXT**: [Any information needed to perform this step]
```[language]
// Example code block for this step's requirements
```

### 🎯 STEP 3: [Final Processing if needed]
**SCOPE**: [What to do - detailed action plan for completion]
- [Point 1: specific action to perform - must be actionable even for non-reasoning models]
- [Point 2: specific action to perform - must be actionable even for non-reasoning models]

**CONTEXT**: [Any information needed to perform this step]
```[language]
// Example code block for final processing requirements
```

**Note**: Perform steps sequentially. Ask human only if something is not clear or additional information is needed.

## Expected Inputs
- [List required inputs: data formats, prerequisites, dependencies]
- [Include code blocks for data format examples when needed]

## Success Metrics
- [Define measurable outcomes: accuracy %, processing time, error rate]
- [Specify validation criteria and thresholds]
- [Include performance benchmarks]

## Integration & Communication
- [List required tools and integration points]
- [Describe interaction patterns and communication style]

## Limitations & Constraints
- [List limitations, constraints, and key assumptions]

## Performance Guidelines
- Keep total prompt length under 2000 tokens for optimal performance
- Use specific examples rather than generic placeholders
- Include concrete file paths and data formats
- Define clear success/failure criteria

## Quality Gates
- [List validation points and success criteria]

## Validation Rules
- [ ] STEP points contain specific, measurable actions
- [ ] CONTEXT includes concrete examples or templates
- [ ] All placeholders replaced with domain-specific content
- [ ] Error handling covers at least 3 common failure scenarios

---

## ⚙️ Template Usage Instructions

When creating a new prompt using this template:

1. **Use User Input** → Replace all `[placeholder]` text with content derived from user's requirements
2. **Customize Sections** → Adapt each section to match the specific goal and context provided
3. **Validate Content** → Ensure no placeholder text remains and content is specific to the task
4. **Apply Guidelines** → Follow the code block and example guidelines throughout
5. **Quality Check** → Verify the prompt meets BIS standards and user requirements

### 📋 Template Completion Steps:

1. **Identity & Purpose** → Replace placeholders with user requirements
2. **Reuse User Data** → Scan and reuse any provided examples/code
3. **Context Setup** → Define domain, environment, and constraints
4. **Execution Design** → Create SCOPE/CONTEXT steps with actionable points
5. **I/O Specification** → Define inputs, outputs, and quality criteria
6. **Integration** → Configure tools and error handling

### ✅ Quality Validation Checklist:
- [ ] All placeholders replaced with specific, relevant content
- [ ] No placeholder text remaining
- [ ] Clear, actionable instructions for AI agents
- [ ] Integration with BIS ecosystem standards
- [ ] User requirements fully addressed
- [ ] Code examples properly formatted and placed
- [ ] Workflow logic is sound and complete
- [ ] Error handling and edge cases considered



