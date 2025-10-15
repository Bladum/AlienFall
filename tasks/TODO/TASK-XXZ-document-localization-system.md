# Task: Document Localization System

**Status:** TODO  
**Priority:** Medium  
**Created:** October 15, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent / Developer

---

## Overview

Create comprehensive documentation for the Localization System in `docs/localization/` based on the existing implementation in `engine/localization/` and the design notes in `wiki/wiki/translation.md`.

---

## Purpose

The Localization System is **fully implemented** in the engine but **lacks documentation** in the docs/ folder (docs/localization/ is empty). This creates a gap where:
- Translators cannot understand how to contribute translations
- Modders cannot understand how to add localized content
- Developers don't have documentation for the localization workflow
- Game designers don't know what text needs localization

This task creates the missing documentation to close that gap.

---

## Requirements

### Functional Requirements
- [ ] Document translation file format and structure
- [ ] Document supported languages
- [ ] Document localization workflow (how to add/edit translations)
- [ ] Document pluralization and gender rules
- [ ] Document context-specific translations
- [ ] Document right-to-left (RTL) language support (if applicable)
- [ ] Document cultural adaptation guidelines
- [ ] Document testing localized content

### Technical Requirements
- [ ] Follow docs/ folder structure and format standards
- [ ] Include examples of translation files
- [ ] Cross-reference UI systems that use localization
- [ ] Include links to implementation (`engine/localization/`)
- [ ] Include translator guidelines
- [ ] Include modding guidelines for localized content

### Acceptance Criteria
- [ ] Complete localization documentation in `docs/localization/`
- [ ] Translation workflow clearly explained
- [ ] Examples provided for common scenarios
- [ ] Guidelines for translators included
- [ ] After completion, `wiki/wiki/translation.md` can be removed

---

## Plan

### Step 1: Analyze Implementation
**Description:** Read and understand the current localization implementation  
**Files to review:**
- `engine/localization/` (all localization files)
- `engine/ui/` (how UI uses localization)
- `wiki/wiki/translation.md` (design notes if available)
- Check for translation files in `assets/` or `data/`

**Estimated time:** 45 minutes

### Step 2: Create Documentation Structure
**Description:** Set up folder structure and main files  
**Files to create:**
- `docs/localization/README.md` (main localization documentation)
- `docs/localization/translation-guide.md` (for translators)
- `docs/localization/workflow.md` (how to add/test translations - optional)

**Estimated time:** 15 minutes

### Step 3: Write Core Documentation
**Description:** Document all localization mechanics and systems  
**Content to include:**
- Translation file format (JSON, TOML, Lua tables?)
- Supported languages and language codes
- Key naming conventions
- Pluralization rules
- Gender-specific translations (if applicable)
- Context-specific translations
- Fallback language behavior
- How to add a new language
- How to test translations in-game

**Estimated time:** 1 hour

### Step 4: Write Translator Guidelines
**Description:** Create guidelines for contributors  
**Content to include:**
- How to contribute translations
- Translation best practices
- Cultural adaptation notes
- Character limits for UI elements
- Testing checklist for translators
- Common pitfalls to avoid

**Estimated time:** 30 minutes

### Step 5: Add Examples and Cross-References
**Description:** Enhance documentation with examples and links  
**Tasks:**
- Add example translation files
- Add example key naming patterns
- Add example pluralization rules
- Cross-reference UI documentation
- Link to implementation files
- Add table of supported languages

**Estimated time:** 30 minutes

### Step 6: Review and Verify
**Description:** Verify documentation against implementation  
**Tasks:**
- Check file format matches implementation
- Verify language codes are correct
- Ensure workflow steps are accurate
- Validate examples work correctly
- Get review from team member if available

**Estimated time:** 20 minutes

---

## Implementation Details

### Architecture
This is a **documentation task** - no code changes required. The localization system is already implemented in:
- `engine/localization/` - Localization system implementation
- `engine/ui/` - UI components using localized strings
- `assets/` or `data/` - Translation files (possibly)

The documentation will be created in:
- `docs/localization/` - Folder for localization documentation (currently empty)

### Key Components
- **Translation Files:** Format, structure, location
- **Language Support:** Supported languages and codes
- **Localization API:** How code accesses translated strings
- **Workflow:** How to add/edit/test translations
- **Guidelines:** Best practices for translators
- **Modding:** How mods can provide localized content

### Dependencies
- UI system (displays localized text)
- Asset loading system (loads translation files)
- Mod system (may provide additional translations)

---

## Testing Strategy

### Documentation Quality Checks
- [ ] Translation file format documented correctly
- [ ] Workflow steps are clear and actionable
- [ ] Examples are accurate and helpful
- [ ] Translator guidelines are comprehensive
- [ ] Cross-references work correctly

### Verification Against Implementation
- [ ] Read `engine/localization/` to verify system design
- [ ] Check translation file format matches docs
- [ ] Verify supported languages list is correct
- [ ] Confirm workflow steps work as documented

### Manual Review Steps
1. Read through all created documentation
2. Compare with implementation code
3. Try following workflow steps to verify accuracy
4. Check examples match actual translation files
5. Ensure formatting follows docs/ standards

### Expected Results
- Complete localization documentation in `docs/localization/`
- Clear workflow for adding translations
- Guidelines for translators included
- Ready to remove `wiki/wiki/translation.md`

---

## How to Run/Debug

This is a documentation task - no game execution required unless testing workflow.

### Reviewing Implementation
```bash
# Open localization implementation
ls engine/localization/

# Search for translation usage
grep -r "translate\|localization\|i18n\|t(" engine/

# Find translation files
find . -name "*translation*" -o -name "*locale*" -o -name "*lang*"
```

### Testing Workflow (Optional)
```bash
# Run game with console
lovec "engine"

# Change language in-game (if supported)
# Verify translated strings appear correctly
```

### Verifying Documentation
- Read created docs in VS Code
- Check markdown rendering with preview
- Verify links work (Ctrl+Click in VS Code)
- Review with docs/OVERVIEW.md for consistency

---

## Documentation Updates

### Files to Create
- [ ] `docs/localization/README.md` - Main localization documentation
- [ ] `docs/localization/translation-guide.md` - Translator guidelines
- [ ] `docs/localization/workflow.md` - Translation workflow (optional)

### Files to Update
- [ ] `docs/OVERVIEW.md` - Add link to localization documentation
- [ ] `docs/ui/README.md` - Add cross-reference to localization (if UI docs exist)
- [ ] `docs/mods/README.md` - Add info about localized mod content (if applicable)

### Files to Remove (After Completion)
- [ ] `wiki/wiki/translation.md` - Design notes superseded by docs

---

## Notes

**Source Materials:**
- `wiki/wiki/translation.md` - Design notes (if exists)
- `engine/localization/` - Actual implementation

**Key Localization Topics to Document:**

1. **Translation File Format:**
   - File format (JSON, TOML, Lua, YAML?)
   - Key naming conventions
   - File location and structure
   - Example file structure

2. **Supported Languages:**
   - List of currently supported languages
   - Language codes (ISO 639-1 or similar)
   - Default/fallback language

3. **Localization Features:**
   - Pluralization (if supported)
   - Gender-specific text (if supported)
   - Context-specific translations
   - Variable substitution in strings
   - RTL language support (if applicable)

4. **Workflow:**
   - How to add a new language
   - How to edit existing translations
   - How to test translations in-game
   - How to contribute translations

5. **Translator Guidelines:**
   - Translation best practices
   - Cultural adaptation notes
   - Character limits for UI
   - Tone and style guidelines
   - Testing checklist

6. **Modding Support:**
   - How mods can provide translations
   - Override behavior for mod translations
   - Best practices for mod localization

**Documentation Format:**
Follow the format established in other docs/ folders with:
- Clear sections with headers
- Code examples for translation files
- Step-by-step workflow instructions
- Cross-references to related systems
- Implementation links at the top

**Important Notes:**
- If `engine/localization/` is empty or minimal, document the **intended** localization system based on design notes
- If implementation is incomplete, note which features are planned vs. implemented
- This task is lower priority because localization is often added later in development

---

## Blockers

None - Information available in implementation or can be documented as planned feature.

**Dependencies:**
- None - This is a documentation task

**Open Questions:**
- Is localization fully implemented or partially implemented? (Check `engine/localization/` contents)
- What translation file format is used? (Determine from implementation)
- Are there any existing translation files to use as examples?

---

## Review Checklist

- [ ] Translation file format documented
- [ ] Supported languages listed
- [ ] Localization workflow clearly explained
- [ ] Translator guidelines comprehensive
- [ ] Examples provided for translation files
- [ ] Variable substitution explained (if supported)
- [ ] Pluralization rules documented (if supported)
- [ ] Cultural adaptation guidelines included
- [ ] Testing process documented
- [ ] Modding support explained
- [ ] Cross-references to UI docs added
- [ ] Implementation links included
- [ ] Formatting follows docs/ standards
- [ ] Markdown renders correctly
- [ ] Ready to remove wiki/wiki/translation.md

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
