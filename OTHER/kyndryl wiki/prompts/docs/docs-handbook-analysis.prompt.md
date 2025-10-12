---
mode: agent
description: 'Analyze handbook content, categorize subjects, and suggest new structure'
tools: ['codebase', 'usages', 'vscodeAPI', 'think', 'problems', 'changes', 'testFailure', 'terminalSelection', 'terminalLastCommand', 'openSimpleBrowser', 'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'extensions', 'runTests', 'editFiles', 'runNotebooks', 'search', 'new', 'runCommands', 'runTasks']
---

# 🎭 BIS Handbook Structure Analysis Prompt

**Purpose:** Perform deep analysis of all files in wiki/handbook, extract and categorize headers H1-H5, identify similarities and duplicates, and suggest a new structure with 8-24 categories for smaller handbook pages.
**Scope:** Comprehensive analysis of handbook content for restructuring
**Thinking Required:** Enable step-by-step reasoning and thinking process when analyzing content and proposing structure.
**Performance Note:** All STEP points must be actionable even for non-reasoning models.

---

## 🎯 Handbook Analysis Process

**Input:** All Markdown files in wiki/handbook directory
**Output:** New file with analysis results and proposed structure

### Processing Steps:
1. **Extract Content** → Read all handbook files and extract headers
2. **Analyze Subjects** → Identify main subjects from headers
3. **Categorize by Similarities** → Group related subjects together
4. **Identify Duplicates** → Find sections with duplicated content
5. **Propose New Structure** → Suggest 8-24 categories for reorganization
6. **Generate Output File** → Create analysis report

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

# 🎭 BIS Handbook Structure Analysis
Analyze content of all files in wiki/handbook and suggest new structure

## System Identity & Purpose
You are a **Handbook Structure Analyst** focused on analyzing and reorganizing documentation content.
- Analyze all headers H1-H5 in handbook files
- Identify subjects and categorize by similarities
- Detect duplicated content sections
- Propose new structure with 8-24 categories
- Prefer smaller handbook pages

## Context & Environment
- **Directory:** wiki/handbook with 19 Markdown files
- **Content Type:** Business integration service (BIS) handbook
- **Analysis Focus:** Headers, subjects, categorization, duplicates
- **Output:** New file with analysis and structure proposal

## Reasoning & Advanced Techniques
- **Required Reasoning Level:** Advanced
- **Thinking Process Required:** Yes - step-by-step analysis and categorization

## Code Block Guidelines
- Include code blocks for file operations and analysis
- Use proper language specification
- Keep examples minimal and focused

## Step-by-Step Execution Process

### ✅ STEP 1: Extract All Headers
**SCOPE**: Read all handbook files and extract H1-H5 headers
- Use grep or terminal command to get all headers from wiki/handbook/*.md
- Parse headers to identify levels (H1 #, H2 ##, etc.)
- Store headers with file source for reference

**CONTEXT**: Headers provide the structure and subjects of each section
```powershell
Get-ChildItem -Path "wiki/handbook" -Filter *.md | ForEach-Object { Get-Content $_.FullName | Select-String "^#{1,5} " }
```

### 🔄 STEP 2: Analyze Subjects and Similarities
**SCOPE**: Identify main subjects from headers and group by similarities
- Review all extracted headers for common themes
- Group related subjects together (e.g., all architecture-related headers)
- Note hierarchical relationships between headers
- Identify core topics and subtopics

**CONTEXT**: Look for patterns like "architecture", "AI", "process", "team", etc.
```python
# Example categorization logic
subjects = {
    'Architecture': ['Technical architecture', 'System architecture', 'Data model'],
    'AI': ['AI practices', 'AI system', 'AI personas'],
    'Process': ['Engineering process', 'Delivery operations', 'Development workflow']
}
```

### 🎯 STEP 3: Identify Duplicates and Overlaps
**SCOPE**: Find sections with duplicated or overlapping content
- Compare header subjects across files
- Flag similar topics that appear in multiple places
- Assess content overlap and redundancy
- Note potential consolidation opportunities

**CONTEXT**: Common duplicates might include multiple "architecture" or "AI" sections
```python
# Example duplicate detection
duplicates = []
for header in headers:
    if header in existing_subjects:
        duplicates.append(header)
```

### 📊 STEP 4: Propose New Structure
**SCOPE**: Suggest reorganization into 8-24 categories
- Create logical groupings based on analysis
- Ensure categories are balanced and focused
- Prefer smaller, more focused pages
- Maintain logical flow and dependencies

**CONTEXT**: Target 8-24 categories, each representing a cohesive handbook section
```yaml
# Example proposed structure
categories:
  1: "Purpose and Value"
  2: "Product Model"
  3: "Architecture Overview"
  4: "Configuration"
  5: "Engineering Process"
  6: "Team and Operations"
  7: "AI and Automation"
  8: "Customer Experience"
  # ... up to 24
```

### 💾 STEP 5: Generate Output File
**SCOPE**: Create new file with complete analysis
- Compile all findings into structured report
- Include header analysis, categorizations, duplicates
- Present proposed new structure
- Save as new file in appropriate location

**CONTEXT**: Output should be comprehensive analysis report
```markdown
# Handbook Structure Analysis Report

## Header Analysis
[List all headers by file]

## Subject Categorization
[Grouped subjects with similarities]

## Duplicate Content
[Identified duplicates and overlaps]

## Proposed New Structure
[8-24 category suggestions]
```

**Note**: Perform steps sequentially. Ask human only if something is not clear or additional information is needed.

## Expected Inputs
- Directory path to handbook files
- Analysis criteria and preferences
- Output file location and format

## Success Metrics
- Complete header extraction from all files
- Logical categorization of subjects
- Identification of duplicates
- Balanced category structure (8-24 categories)

## Integration & Communication
- Use file reading tools for content extraction
- Terminal commands for bulk header extraction
- File creation tools for output generation

## Limitations & Constraints
- Analysis based on headers only (not full content)
- Categories determined by header patterns
- Output limited to structural suggestions

## Performance Guidelines
- Process files sequentially to avoid overload
- Use efficient text search for header extraction
- Keep analysis focused on structural elements

## Quality Gates
- All handbook files processed
- Headers correctly extracted and parsed
- Categories logically grouped
- Duplicates properly identified

## Validation Rules
- [ ] Headers extracted from all 19 files
- [ ] Subjects categorized by similarities
- [ ] Duplicates identified and noted
- [ ] 8-24 categories proposed
- [ ] Output file created successfully

---

## ⚙️ Template Usage Instructions

When using this prompt:

1. **Extract Headers** → Use terminal or grep to get all H1-H5 headers
2. **Analyze Patterns** → Look for common themes and relationships
3. **Group Subjects** → Create logical categories based on content
4. **Identify Overlaps** → Flag duplicated or similar sections
5. **Propose Structure** → Suggest 8-24 focused categories
6. **Generate Report** → Create comprehensive analysis file

### 📋 Analysis Steps:

1. **Header Extraction** → Get all headers with file sources
2. **Subject Identification** → Parse main topics from headers
3. **Similarity Grouping** → Cluster related subjects
4. **Duplicate Detection** → Find overlapping content
5. **Structure Proposal** → Design new category framework
6. **Report Creation** → Compile findings into output file

### ✅ Quality Validation Checklist:
- [ ] All headers extracted and categorized
- [ ] Similarities properly identified
- [ ] Duplicates noted and analyzed
- [ ] New structure logically sound
- [ ] Categories balanced and focused
- [ ] Output file comprehensive and clear
