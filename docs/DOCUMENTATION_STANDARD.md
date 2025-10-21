# Documentation Standards for AlienFall

This document defines the standards and conventions for all AlienFall documentation. Following these standards ensures consistency, clarity, and maintainability across the entire documentation suite.

---

## Table of Contents

1. [Overview](#overview)
2. [Markdown Conventions](#markdown-conventions)
3. [Document Structure](#document-structure)
4. [Audience Guidelines](#audience-guidelines)
5. [Code Examples](#code-examples)
6. [Cross-References](#cross-references)
7. [Terminology](#terminology)
8. [Style Guide](#style-guide)
9. [Review Checklist](#review-checklist)

---

## Overview

**Purpose**: Ensure all documentation is clear, consistent, and accessible to diverse audiences (players, developers, designers, modders).

**Scope**: All Markdown documentation in the `/docs` folder.

**Maintenance**: Update these standards as the project evolves; communicate changes to all contributors.

---

## Markdown Conventions

### File Naming
- Use `PascalCase` for file names: `MyDocument.md`
- Use hyphens for multi-word file names: `My-Document.md`
- Use `UPPERCASE` for special files: `README.md`, `INDEX.md`, `TEMPLATE.md`

### File Structure
```markdown
# Main Title (H1)

Brief introduction (1-2 sentences).

---

## Table of Contents

- [Section 1](#section-1)
- [Section 2](#section-2)

---

## Section 1

Content here.

### Subsection 1.1

More content.

---

## Section 2

Content here.

---

**Last Updated**: October 2025 | **Status**: Active
```

### Heading Hierarchy
- `# H1` - Document title (one per document)
- `## H2` - Major sections
- `### H3` - Subsections
- `#### H4` - Sub-subsections
- Avoid `##### H5` and deeper unless necessary

### Code Formatting
- **Inline code**: Use backticks: `variable`, `functionName()`, `file.lua`
- **Code blocks**: Use triple backticks with language specifier:
  ```lua
  -- Lua example
  local myVar = 42
  ```
- **Commands**: Highlight shell commands in code blocks:
  ```bash
  lovec "engine"
  ```

### Lists and Formatting
- **Bullet lists**: Use hyphens (`-`) for consistency
- **Numbered lists**: Use `1.`, `2.` for ordered sequences
- **Bold text**: Use `**bold**` for emphasis
- **Italic text**: Use `*italic*` for mild emphasis
- **Links**: Use `[text](url)` format

### Whitespace
- Use blank lines to separate major sections
- Use `---` (horizontal rule) between major sections
- Indent nested lists with 2 spaces
- No trailing whitespace at end of lines

---

## Document Structure

### Standard Document Template

```markdown
# Document Title

**Audience**: [Players | Developers | Designers | Modders]
**Status**: [Draft | Active | Archived]
**Last Updated**: [Date]

One-paragraph overview of what this document covers.

---

## Table of Contents

- [Section 1](#section-1)
- [Section 2](#section-2)

---

## Section 1

### Subsection 1.1

Content with explanation.

#### Example

Code or example here.

---

## Related Documents

- [Link to related doc](link)
- [Another related doc](link)

---

**Last Updated**: [Date] | **Status**: [Status] | **Audience**: [Audience]
```

### Standard Sections (Use as Needed)

**For System Documentation**:
- Overview
- Key Concepts
- Mechanics (how it works)
- Examples (with code/walkthrough)
- Common Tasks
- Edge Cases
- Related Documents

**For API Documentation**:
- Overview
- Functions (with signatures)
- Data Structures
- Examples
- Error Handling
- Related APIs

**For Developer Guides**:
- Prerequisites
- Step-by-Step Instructions
- Troubleshooting
- Common Mistakes
- Advanced Topics
- Related Guides

---

## Audience Guidelines

All documentation should be tagged with its primary audience:

### For Players
- **Language**: Casual, game-focused
- **Tone**: Encouraging, explanatory
- **Focus**: "How do I...?" and "What is...?"
- **Examples**: Game scenarios, mechanics explanations
- **Avoid**: Technical jargon, code references

### For Developers
- **Language**: Technical, precise
- **Tone**: Clear, functional
- **Focus**: "How does it work?" and "How do I implement...?"
- **Examples**: Code samples, API signatures
- **Include**: Error handling, edge cases, performance notes

### For Designers
- **Language**: Game design terminology
- **Tone**: Analytical, balance-focused
- **Focus**: "What are the mechanics?" and "How is it balanced?"
- **Examples**: Balance formulas, tuning ranges
- **Include**: Design rationale, balance parameters

### For Modders
- **Language**: Technical but accessible
- **Tone**: Empowering, example-driven
- **Focus**: "How do I mod this?" and "What can I change?"
- **Examples**: Mod configuration files, examples
- **Include**: API references, common patterns

---

## Code Examples

### Lua Code Examples

**Format**:
```lua
-- Clear comment explaining the code
local function doSomething(parameter)
    -- Implementation
    return result
end
```

**Standards**:
- Always include comments explaining non-obvious logic
- Use meaningful variable names
- Show complete, executable examples
- Test examples before including them
- Include both simple and complex examples
- Show error handling patterns

### Example with Output

```lua
-- Print a greeting
print("Hello, AlienFall!")

-- Output:
-- Hello, AlienFall!
```

### Configuration File Examples

```yaml
# Clear YAML example
item:
  id: weapon_rifle
  name: "Assault Rifle"
  damage: 45
```

### Shell Command Examples

```bash
# Run the game
lovec "engine"

# Run tests
lua tests/runners/run_all_tests.lua
```

---

## Cross-References

### Internal Links (Relative Paths)

Use relative paths from the current document:

```markdown
# Current document location: docs/systems/Battlescape.md

## Related to Geoscape
See [Geoscape](../Geoscape.md) for strategic layer details.

## API Reference
Check the [Battlescape API](../api/BATTLESCAPE.md).

## Developer Guide
Read [Development Workflow](../developers/WORKFLOW.md).
```

### Linking to Code

Reference code files with relative paths:

```markdown
See the implementation in [engine/main.lua](../../engine/main.lua).

The state manager is in [engine/core/state_manager.lua](../../engine/core/state_manager.lua).
```

### Linking to Sections

Link to specific sections within documents:

```markdown
[See the Economy System](#economy-system)

[Back to Overview](#overview)
```

### "Related Documents" Section

Every document should have a Related Documents section:

```markdown
---

## Related Documents

- [Document Name](path/to/document.md) - Brief description
- [Another Document](path/to/another.md) - Brief description
- [More Reading](path/to/more.md) - Brief description
```

---

## Terminology

### Glossary Integration
- All non-standard terms should be defined in [Glossary](../wiki/GLOSSARY.md)
- Link to glossary terms on first usage in long documents:
  ```markdown
  A [UFO](../wiki/GLOSSARY.md#ufo) is an unidentified flying object.
  ```
- Acronyms should be defined on first use: "UFO (Unidentified Flying Object)"

### Consistent Term Usage
- Use the same term consistently throughout a document
- For example, use "squad" not "squad" and "team" interchangeably
- Check the Glossary for the canonical term

### Avoid Ambiguous Language
- Instead of "it", use specific nouns
- Instead of "this", be explicit: "this system" not just "this"
- Instead of "there is", restructure: "The system includes..." not "There is a system that..."

---

## Style Guide

### Voice and Tone

**Professional but Accessible**
- Write for intelligent readers who may not have game/code background
- Explain acronyms and jargon
- Use active voice: "The player builds a base" not "A base is built"
- Use specific examples instead of abstract language

### Paragraph Structure
- Start with topic sentence
- Use 3-5 sentences per paragraph
- Vary sentence length for readability
- One main idea per paragraph

### Emphasis
- Use **bold** for important terms and definitions
- Use *italic* for mild emphasis or non-English words
- Use > quotes for player-visible text:
  ```markdown
  The UI shows: > "Research Complete"
  ```

### Common Phrases

Use these standardized phrases for consistency:

| Phrase | Usage |
|--------|-------|
| "See [doc](link)" | Cross-reference |
| "Read [section](#section)" | Internal reference |
| "Refer to" | Technical documentation |
| "Note:" | Important information |
| "Warning:" | Caution about consequences |
| "Tip:" | Helpful suggestion |
| "Example:" | Code or scenario example |
| "Related:" | Document relationships |

### Numbering and Ordering
- Number lists when sequence matters (steps, priorities)
- Use bullets for non-sequential lists
- Organize by importance or logical flow

### Punctuation
- Use Oxford comma: "A, B, and C"
- Use em-dash for breaks: "Text—more text"
- Use colon for lists: "Items include:"
- Use periods consistently in list items (all or none)

---

## Review Checklist

### Before Publishing Documentation

- [ ] Document has H1 title at top
- [ ] Document has Audience tag
- [ ] Document has Table of Contents (if long)
- [ ] All headings follow hierarchy (no H1→H3 jumps)
- [ ] All code examples are correct and tested
- [ ] All links use relative paths and work
- [ ] All acronyms defined on first use
- [ ] All terms defined in Glossary or inline
- [ ] Document is cross-referenced from parent docs
- [ ] No undefined terminology
- [ ] No trailing whitespace
- [ ] Spell-checked and proofread
- [ ] Related Documents section included
- [ ] Last Updated date is current

### Link Verification
```bash
# Test relative links on your system before publishing
# Check that all [text](path) links are valid
# Verify no broken references
```

### Tone Check
- [ ] Language appropriate for audience
- [ ] No unexplained jargon
- [ ] Examples match audience level
- [ ] Professional but accessible
- [ ] Active voice used predominantly
- [ ] Specific instead of vague

---

## Examples of Good Documentation

### Effective System Description
```markdown
## Escalation Meter

The escalation meter tracks how aware the alien threat is of your
organization. As your organization becomes more effective, the meter
increases, triggering harder missions and more frequent attacks.

**How it works**:
1. Meter starts at 0%
2. Completing missions increases it by 10-20%
3. At certain thresholds (25%, 50%, 75%), alien behavior changes
4. Maximum is 100%, causing maximum-difficulty missions

**Related**: [Difficulty Scaling](../wiki/design/BALANCE_REFERENCE.md)
```

### Effective API Documentation
```markdown
## createUnit(unitData)

Creates a new unit with the provided data.

**Parameters**:
- `unitData` (table): Unit configuration
  - `id` (string): Unique identifier
  - `name` (string): Display name
  - `class` (string): Unit class ("soldier", "heavy", etc.)

**Returns**: Unit object or nil on error

**Example**:
```lua
local soldier = createUnit({
    id = "soldier_001",
    name = "John Smith",
    class = "soldier"
})
```

**Related**: [Units API](../wiki/api/UNITS.md)
```

---

## Maintenance and Updates

### When to Update
- When systems change, update related documentation immediately
- When new features are added, add documentation in this PR
- When terminology changes, update Glossary and all references
- When procedures change, update step-by-step guides

### Versioning
- Documentation versions are implicit (reflects current game state)
- Date updates track when docs were last verified
- Use Git for historical versions

### Deprecation
Mark deprecated documentation with a warning:

```markdown
> ⚠️ **Deprecated**: This system was replaced by [New System](link) in v2.0.
> For legacy information, see [Archived Version](old-doc.md).
```

---

## Tools and Validation

### Recommended Tools
- **Markdown Linter**: `npm install -g markdownlint`
- **Link Checker**: `npm install -g markdown-link-check`
- **Spell Checker**: Built into most editors

### Validation Commands
```bash
# Check markdown syntax
markdownlint docs/**/*.md

# Check all links are valid
markdown-link-check docs/**/*.md
```

---

## Questions?

If you have questions about these standards, consult:
1. This document
2. Similar existing documents as examples
3. The main [Documentation README](README.md)
4. Ask in the project's communication channel

---

**Last Updated**: October 2025 | **Status**: Active | **Version**: 1.0
