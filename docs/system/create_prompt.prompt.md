# Create Prompt Template Prompt
**Purpose:** Generate a new content creation template/prompt  
**Output:** A `.prompt.md` file in `docs/prompts/`  
**Audience:** AI agents, content creators, designers

---

## 📋 Instructions

When creating a new prompt template, provide the following information:

### 1. Basic Information
- **Content Type:** What is being created? (unit, item, mission, facility, etc.)
- **System:** Which game system? (Core, Base, World, Tactical, Combat, Economy, Narrative, Meta)
- **Purpose:** Why would someone use this prompt?
- **Output:** What files/content are generated?

### 2. Required Information
- **Mandatory Fields:** What information MUST be provided?
- **Optional Fields:** What information CAN be provided?
- **Dependencies:** What must exist first? (e.g., faction before unit)

### 3. TOML Schema
- **Schema Reference:** Link to api/GAME_API.toml section
- **Required Fields:** Which TOML fields are mandatory?
- **Optional Fields:** Which TOML fields are optional?
- **Valid Values:** Enums, ranges, constraints

### 4. Design Considerations
- **Balance Guidelines:** What makes this balanced?
- **Common Patterns:** What are typical configurations?
- **Edge Cases:** What unusual scenarios to consider?

---

## 📝 Template Structure

```markdown
# Add [Content Type] Prompt

**System:** [Core/Base/World/Tactical/Combat/Economy/Narrative/Meta]  
**Output:** TOML file in `mods/core/rules/[category]/`  
**Schema:** `api/GAME_API.toml` → `[[type.[content_type]]]`

---

## 🎯 Purpose

**Use this prompt to:** [What this helps create]

**Output Location:**
- TOML: `mods/core/rules/[category]/[name].toml`
- Assets: `mods/core/assets/[category]/[name].[ext]`
- Design Doc: `design/mechanics/[system].md` (update if needed)

---

## 📋 Required Information

Provide the following details:

### 1. Basic Info
- **ID:** Unique identifier (lowercase, underscores)
- **Name:** Display name
- **Description:** Short description (1-2 sentences)

### 2. [Category-Specific Fields]
- **[Field 1]:** [What is this?]
- **[Field 2]:** [What is this?]
- **[Field 3]:** [What is this?]

### 3. [Optional Details]
- **[Optional Field 1]:** [What is this?]
- **[Optional Field 2]:** [What is this?]

---

## 📐 TOML Schema

**Reference:** `api/GAME_API.toml` → `[[type.[content_type]]]`

**Required Fields:**
```toml
[[type.[content_type]]]
id = "string"              # Unique identifier
name = "string"            # Display name
[additional required fields...]
```

**Optional Fields:**
```toml
[optional_section]
field = value              # Description
[additional optional fields...]
```

**Valid Values:**
- `id`: lowercase, underscores, unique
- `name`: any string, user-visible
- [additional constraints...]

---

## 🎨 Design Guidelines

### Balance Considerations
- [Guideline 1]
- [Guideline 2]
- [Guideline 3]

### Common Patterns
**[Pattern Name]:**
- [Characteristic 1]
- [Characteristic 2]
- [Example configuration]

### Edge Cases
- **[Edge Case 1]:** [How to handle]
- **[Edge Case 2]:** [How to handle]

---

## 📝 Example: [Example Name]

**Concept:** [Description of example]

**TOML:**
```toml
[[type.[content_type]]]
id = "example_id"
name = "Example Name"
[full example configuration...]
```

**Assets:**
- [Asset 1]: `path/to/asset1.ext`
- [Asset 2]: `path/to/asset2.ext`

**Design Rationale:** [Why these values?]

---

## 🔄 Creation Workflow

1. **Design:** Define concept in `design/mechanics/[system].md`
2. **Schema:** Verify schema in `api/GAME_API.toml`
3. **TOML:** Create TOML file in `mods/core/rules/[category]/`
4. **Assets:** Add required assets to `mods/core/assets/[category]/`
5. **Test:** Run game, verify content loads
6. **Document:** Update design doc with implementation notes

---

## ✅ Validation Checklist

Before finalizing:
- [ ] ID is unique and follows naming convention
- [ ] All required fields provided
- [ ] Values within valid ranges
- [ ] Assets exist and referenced correctly
- [ ] TOML validates against schema
- [ ] Design doc updated (if significant)
- [ ] Tested in game

---

## 🔗 Related Prompts

- [Related Prompt 1]
- [Related Prompt 2]
- [Related Prompt 3]

---

## 📚 References

**API Schema:**
- `api/GAME_API.toml` → `[[type.[content_type]]]`
- `api/[SYSTEM].md`

**Design:**
- `design/mechanics/[system].md`

**Examples:**
- `mods/core/rules/[category]/[example].toml`

---

**Created:** YYYY-MM-DD  
**Status:** Active  
**Maintainer:** [Name/Role]
```

---

## 🚀 Usage

**AI Agent:** When asked to create a content prompt, use this template and fill in all sections based on the content type being created.

**Output Filename:** `docs/prompts/add_[content_type].prompt.md`

**After Creation:**
1. Add entry to `docs/prompts/README.md`
2. Update count in `docs/README.md`
3. Link from related system documentation

---

## ✅ Validation Checklist

Before finalizing a prompt:
- [ ] Clear purpose statement
- [ ] All required information documented
- [ ] TOML schema fully specified
- [ ] Valid values and constraints listed
- [ ] At least one complete example
- [ ] Design guidelines provided
- [ ] Validation checklist included
- [ ] Related prompts linked
- [ ] References to API/design docs

---

**Created:** 2025-10-27  
**Purpose:** Standardize content prompt creation  
**Location:** `docs/system/create_prompt.prompt.md`

