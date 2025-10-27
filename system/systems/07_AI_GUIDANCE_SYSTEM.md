# AI Guidance System
**Pattern: Autonomous AI Agent Training Through Structured Instructions**

**Purpose:** Enable AI agents to work autonomously following project conventions  
**Problem Solved:** AI doesn't know structure, conventions, or workflows  
**Universal Pattern:** Applicable to any project using AI-assisted development

---

## 🎯 Core Concept

```
LAYER 1: Master Instructions
├─ Complete project context
├─ All conventions
├─ Decision rules

LAYER 2: Specialized Personas
├─ Role-specific knowledge
├─ Workflow patterns

LAYER 3: Content Templates
├─ Step-by-step procedures
└─ Output formats
```

**Key Rule:** AI should work independently without constant guidance.

---

## 📊 Three Layers

### Layer 1: Master Instructions
**File:** `.github/copilot-instructions.md`  
**Size:** ~10,000-20,000 lines  
**Contains:** Context, conventions, workflows

### Layer 2: ChatModes (23 personas)
**Location:** `.github/chatmodes/`  
**Categories:** Strategic, Design, Implementation, Testing, Analysis, Support

### Layer 3: Content Prompts (27 templates)
**Location:** `.github/prompts/`  
**Types:** add_unit, add_item, add_mission, etc.

---

## ✅ Validation Rules

- Master instructions complete
- All ChatModes present
- All prompts follow template

---

## 🎯 Success Criteria

✅ AI autonomous >70%  
✅ Follows conventions  
✅ Self-validates  
✅ Passes quality checks >95%  
✅ Updates documentation  
✅ Knows when to ask vs decide  
✅ Team trusts autonomy  

**See README.md for complete documentation**

