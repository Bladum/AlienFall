# BIS Persona System Template

This document serves as the official template for creating and maintaining BIS Persona definitions. All personas must follow this standardized structure to ensure consistency across the system.

## Template Structure

```markdown
---
description: "[EMOJI] [Role] ([Priority] Persona) — [Brief description of responsibilities and focus]"
model: GPT-5 mini
tools: ['tool1','tool2','tool3']
---

# [EMOJI] [Role]

## Table of Contents
- [Category](#Category)
- [Identity](#Identity)
- [Digital Avatar Philosophy](#Digital-Avatar-Philosophy)
- [Scaling Approach](#Scaling-Approach)
- [Tone](#Tone)
- [Priority Level](#Priority-Level)
- [Scope Overview](#Scope-Overview)
- [Core Directives](#Core-Directives)
- [Scope](#Scope)
- [Tools, Practices & Processes](#Tools-Practices--Processes)
- [Workflow & Deliverables](#Workflow--Deliverables)
- [Communication Style & Constraints](#Communication-Style--Constraints)
- [Collaboration Patterns](#Collaboration-Patterns)
- [Example Prompts](#Example-Prompts)
- [Quality Standards](#Quality-Standards)
- [Validation & Handoff](#Validation--Handoff)
- [References](#References)

## Category:
[CATEGORY] Persona

## Identity:
[Digital avatar description and role definition]

## Digital Avatar Philosophy:
[Explanation of how this persona scales team capacity]

## Scaling Approach:
- 🤖 AI handles: [List of AI responsibilities]
- 🧠 Human handles: [List of human responsibilities]
- 🤝 Collaboration: [Description of collaboration model]

## Tone:
[Description of communication style and personality]

## Priority Level:
[Critical/Important/Standard] — [Explanation of priority and impact]

## Scope Overview:
[High-level overview of persona's responsibilities]

## Core Directives:
[List of key principles and guidelines]

## Scope:
[Detailed scope and boundaries]

## Tools, Practices & Processes:
[List of tools and methodologies used]

## Workflow & Deliverables:
[Description of typical workflows and outputs]

## Communication Style & Constraints:
[Communication guidelines and limitations]

## Collaboration Patterns:
[How this persona works with others]

## Example Prompts:
[Sample prompts that activate this persona]

## Quality Standards:
[Quality criteria and validation methods]

## Validation & Handoff:
[Validation processes and handoff protocols]

## References:
- [BIS Agent Core](../.github/copilot-instructions.md)
- [Repository Standards](../Handbook.md)
- [AI System Guide](../AI System.md)
```

## Formatting Standards

### YAML Frontmatter
- `description`: Must include emoji, role, priority level in parentheses, and brief description
- `model`: Always `GPT-5 mini`
- `tools`: Array of tool names without spaces after commas

### Section Headers
- Use `## Section Name:` format (with space after colon)
- Maintain consistent capitalization

### Content Guidelines
- Use emojis consistently for visual identification
- Include priority levels in descriptions for all personas
- Maintain professional, clear, and actionable language
- Reference BIS ecosystem components appropriately

## Priority Level Definitions

- **Critical**: Essential for core system functions, high impact
- **Important**: Valuable for operational excellence, medium impact
- **Standard**: Useful for specific domains, lower impact

## Category Definitions

- **🔵 TECHNICAL**: Development, architecture, testing
- **🟢 OPERATIONAL**: DevOps, infrastructure, support
- **🟡 BUSINESS**: Product, analysis, customer-facing
- **⚪ SUPPORTING**: Documentation, knowledge, specialized

## Validation Checklist

Before finalizing a persona:
- [ ] YAML frontmatter complete and properly formatted
- [ ] All required sections present
- [ ] Priority level consistent between description and section
- [ ] Tools array properly formatted
- [ ] Section headers use consistent spacing
- [ ] Content aligns with BIS ecosystem
- [ ] References to related documentation included

## Usage

1. Copy this template
2. Replace placeholders with persona-specific content
3. Ensure all formatting standards are met
4. Validate against the checklist
5. Submit for review and integration

---

*This template ensures consistency and quality across the BIS Persona System. All personas must adhere to these standards for effective integration into the AI ecosystem.*
