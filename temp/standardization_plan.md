# Design Document Standardization Plan

## Standard Structure for All design/mechanics/*.md Files

### Template Structure

```markdown
# [System Name]

> **Status**: [Draft | In Progress | Complete]  
> **Last Updated**: YYYY-MM-DD  
> **Related Systems**: [List of related .md files]

## Table of Contents

- [Overview](#overview)
- [Section 2](#section-2)
- [Section 3](#section-3)
- ...
- [Design Philosophy](#design-philosophy) (if applicable)
- [Integration](#integration) (if applicable)
- [Future Enhancements](#future-enhancements) (if applicable)

---

## Overview

### [Subsection if needed]

[Content starts here]

---

## [Next Section]

[Content]
```

### Key Standardization Rules

1. **Title**: H1 with system name (capitalize properly)
2. **Metadata Block**: Use blockquote with status, date, related systems
3. **Table of Contents**: Always present, H2 level
4. **Separator**: Three dashes (---) after ToC
5. **Overview**: Always first section after ToC
6. **Consistent H2 for main sections**: All top-level sections use ##
7. **Consistent H3 for subsections**: All subsections use ###

### Files to Standardize (25 files)

1. 3D.md
2. ai_systems.md
3. Analytics.md
4. Assets.md
5. Basescape.md
6. Battlescape.md
7. Countries.md
8. Crafts.md
9. DiplomaticRelations_Technical.md
10. Economy.md
11. Finance.md
12. FutureOpportunities.md
13. Geoscape.md
14. Glossary.md
15. Gui.md
16. hex_vertical_axial_system.md
17. Integration.md
18. Interception.md
19. Items.md
20. Lore.md
21. Overview.md
22. PilotSystem_Technical.md
23. Politics.md
24. README.md
25. Units.md

### Standardization Process

For each file:
1. Extract current title and content
2. Create metadata block
3. Ensure ToC exists and is formatted correctly
4. Add separator after ToC
5. Ensure Overview section exists as first section
6. Verify heading hierarchy (H2 for main, H3 for sub)
7. Update file


