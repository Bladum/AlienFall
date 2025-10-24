# Code Quality Assurance System

**Status:** ✅ IMPLEMENTED
**Framework Type:** Comprehensive code analysis and quality checking
**Analysis Types:** Globals, Performance, Style, Complexity, Documentation, Coverage
**Quality Score:** 0-100 scale with weighted severity

---

## Overview

The Code Quality Assurance (QA) System provides:
- **Automated Code Analysis:** Scan for common issues and anti-patterns
- **Style Checking:** Enforce consistent code formatting and conventions
- **Complexity Analysis:** Measure cyclomatic complexity and code metrics
- **Performance Detection:** Identify performance-critical issues
- **Documentation Coverage:** Track documentation completeness
- **Quality Scoring:** Overall code quality on 0-100 scale
- **Detailed Reporting:** Issue breakdown by severity and type
- **Module Analysis:** Per-module quality metrics

---

## Architecture

### QA System Components

```
QASystem (core)
├── Configuration
│   ├── Check toggles
│   ├── Strictness levels
│   └── Custom rules
├── Analysis Engine
│   ├── Global detection
│   ├── Style checker
│   ├── Complexity analyzer
│   ├── Performance analyzer
│   └── Documentation checker
├── Registry
│   ├── Modules analyzed
│   ├── Issues found
│   ├── Metrics collected
│   └── Reports generated
└── Reporting
    ├── Issue categorization
    ├── Severity assessment
    ├── Quality scoring
    └── Detailed reports
```

### Issue Severity Levels

| Level | Weight | Purpose | Examples |
|-------|--------|---------|----------|
| **CRITICAL** | 10 | Must fix | Globals, nil dereference |
| **HIGH** | 5 | Should fix | Performance, complexity |
| **MEDIUM** | 2 | Consider fixing | Documentation, style |
| **LOW** | 1 | Nice to have | Whitespace, conventions |
| **INFO** | 0 | Informational | Metrics, statistics |

---

## API Reference

### Initialization

```lua
local QASystem = require("engine.core.qa_system")

QASystem.init()
```

**Configuration:**
```lua
QASystem.config.check_globals = true        -- Check for globals
QASystem.config.check_performance = true    -- Check for performance issues
QASystem.config.check_style = true          -- Check code style
QASystem.config.check_coverage = true       -- Check coverage
QASystem.config.check_complexity = true     -- Check complexity
QASystem.config.check_documentation = true  -- Check documentation
QASystem.config.strict_mode = false         -- Strict checking
```

### Running Analysis

```lua
QASystem.analyzeModule(filepath)
```
Analyze a single Lua module file.

**Returns:** Module object with issues and metrics

```lua
QASystem.runAll(filepaths)
```
Run analysis on multiple files.

**Parameters:**
- `filepaths` (table): Array of file paths to analyze

### Registering Checks

```lua
QASystem.registerCheck(name, category, check_func)
```
Register a custom quality check.

**Parameters:**
- `name` (string): Check name
- `category` (string): Check category
- `check_func` (function): Function to perform check

**Example:**
```lua
QASystem.registerCheck("no_nil_deref", "critical", function(code)
    -- Check for potential nil dereferences
    local issues = {}
    if code:match("[^_]%.%w+%[") then  -- Simplified check
        table.insert(issues, {
            type = "potential_nil_deref",
            severity = QASystem.severity.CRITICAL,
            message = "Potential nil dereference detected",
        })
    end
    return issues
end)
```

### Analysis Methods

#### Check for Globals

```lua
local issues = QASystem.checkGlobals(code)
```
Detect potential global variable assignments.

**Returns:** Array of global variable issues

#### Check Code Style

```lua
local issues = QASystem.checkStyle(code)
```
Detect style violations (whitespace, indentation, line endings).

**Returns:** Array of style issues

#### Check Documentation

```lua
local issues, functions = QASystem.checkDocumentation(code)
```
Check for missing function documentation.

**Returns:**
- `issues` (table): Documentation issues
- `functions` (table): List of functions found

#### Check Complexity

```lua
local issues, complexity = QASystem.checkComplexity(code)
```
Analyze cyclomatic complexity.

**Returns:**
- `issues` (table): Complexity issues
- `complexity` (number): Cyclomatic complexity score

#### Check Performance

```lua
local issues = QASystem.checkPerformance(code)
```
Detect performance anti-patterns.

**Returns:** Array of performance issues

### Reporting

```lua
QASystem.generateReport()
```
Generate comprehensive QA report.

**Returns:**
```lua
{
    total = number,         -- Total issues
    critical = number,      -- Critical issues
    high = number,          -- High priority issues
    medium = number,        -- Medium priority issues
    low = number,           -- Low priority issues
    info = number,          -- Informational items
}
```

### Results Retrieval

```lua
QASystem.getModuleReport(filepath)
```
Get analysis results for specific module.

```lua
QASystem.getAllIssues()
```
Get all detected issues across all modules.

```lua
QASystem.getIssuesBySeverity(severity)
```
Get issues filtered by severity level.

```lua
QASystem.getQualityScore()
```
Get overall quality score (0-100).

---

## Using the QA System

### Step 1: Initialize

```lua
local QASystem = require("engine.core.qa_system")
QASystem.init()
```

### Step 2: Register Modules

```lua
QASystem.registerModule("engine/my_system/my_module.lua")
QASystem.registerModule("engine/other/utils.lua")
```

### Step 3: Run Analysis

```lua
local files = {
    "engine/my_system/my_module.lua",
    "engine/other/utils.lua",
}

QASystem.runAll(files)
```

### Step 4: Review Results

```lua
-- Get quality score
local score = QASystem.getQualityScore()
print("Quality Score: " .. score .. "/100")

-- Get critical issues
local critical = QASystem.getIssuesBySeverity(QASystem.severity.CRITICAL)
for _, item in ipairs(critical) do
    print("CRITICAL: " .. item.issue.message)
end

-- Generate report
QASystem.generateReport()
```

---

## Quality Checks

### 1. Global Variable Detection

**Purpose:** Find potential global variables (anti-pattern)

**Detects:**
- Unqualified assignments outside functions
- Missing `local` keyword
- Potential state pollution

**Example Issue:**
```
Line 42: Potential global variable detected: 'gameState'
```

### 2. Code Style Checking

**Purpose:** Enforce consistent formatting

**Checks:**
- Trailing whitespace
- Tab vs space indentation
- Line ending consistency
- Empty line patterns

**Example Issue:**
```
Line 15: Trailing whitespace
Line 28: Tab character used for indentation (use spaces)
```

### 3. Complexity Analysis

**Purpose:** Identify overly complex functions

**Metrics:**
- Cyclomatic complexity (CC)
- Decision points (if/for/while)
- Nesting depth

**Thresholds:**
- CC > 10: High complexity warning
- CC > 15: Critical refactoring needed

**Example Issue:**
```
High cyclomatic complexity: 12 (threshold: 10)
Consider breaking function into smaller pieces
```

### 4. Performance Analysis

**Purpose:** Detect performance anti-patterns

**Detects:**
- String concatenation in loops
- Inefficient table operations
- Redundant function calls
- Unnecessary object allocations

**Example Issue:**
```
String concatenation in loop - use table and concat()
```

### 5. Documentation Checking

**Purpose:** Track documentation coverage

**Checks:**
- Missing function documentation
- Missing parameter descriptions
- Missing return value documentation

**Example Issue:**
```
Missing documentation for 3 of 15 functions
Functions: calculateDamage, applyModifier, getWeaponStats
```

### 6. Coverage Analysis

**Purpose:** Measure test coverage

**Tracks:**
- Lines covered by tests
- Functions covered by tests
- Branch coverage

---

## Quality Score Calculation

Quality Score (0-100) is calculated by weighting issues:

```
Score = 100 - (Critical × 10 + High × 5 + Medium × 2 + Low × 1)
```

### Score Ranges

| Score | Rating | Status |
|-------|--------|--------|
| 90-100 | Excellent | ✅ Production ready |
| 80-89 | Good | ✅ Minor issues |
| 70-79 | Fair | ⚠️ Needs attention |
| 60-69 | Poor | ⚠️ Significant issues |
| < 60 | Critical | ❌ Major problems |

---

## Output Example

```
Code Quality Report
======================================================================

ISSUE SUMMARY
----------------------------------------------------------------------
Total Issues: 8
  🔴 Critical: 0
  🟠 High: 2
  🟡 Medium: 3
  🔵 Low: 3
  ⚪ Info: 0

MODULE ANALYSIS
----------------------------------------------------------------------
engine/core/my_module.lua
  Lines: 245 | Functions: 8 | Complexity: 7 | Issues: 5
    🟠 [HIGH] Potential global variable: gameState
    🟡 [MEDIUM] Missing documentation for calculateDamage
    🔵 [LOW] Trailing whitespace on line 42

engine/utils/helpers.lua
  Lines: 178 | Functions: 12 | Complexity: 4 | Issues: 3
    🟠 [HIGH] String concatenation in loop (line 89)
    🟡 [MEDIUM] Missing parameter docs for processData
    🔵 [LOW] Tab indentation on line 156

======================================================================
Quality Score: 87/100 ✅
```

---

## Integration with Development

### Pre-Commit Checks

```lua
-- In pre-commit hook
local QASystem = require("engine.core.qa_system")
QASystem.init()

local files = getChangedFiles()  -- Get files to check
QASystem.runAll(files)

local score = QASystem.getQualityScore()
if score < 80 then
    print("Quality score below threshold. Please review issues.")
    os.exit(1)
end
```

### CI/CD Pipeline Integration

```bash
# In CI pipeline
love . --qa --strict
# Exits with 1 if critical issues found
```

### Manual Code Review

```lua
-- Review specific module
local report = QASystem.getModuleReport("engine/my_system/module.lua")
if report then
    print("Issues found: " .. #report.issues)
    for _, issue in ipairs(report.issues) do
        print(issue.type .. ": " .. issue.message)
    end
end
```

---

## Custom Quality Rules

### Adding Custom Checks

```lua
-- Check for specific anti-pattern
QASystem.registerCheck("no_unvalidated_input", "high", function(code)
    local issues = {}

    -- Look for direct use of input without validation
    if code:match("userInput[%w_]*%s*[%[.]") and
       not code:match("validateInput") then
        table.insert(issues, {
            type = "unvalidated_input",
            severity = QASystem.severity.HIGH,
            message = "User input used without validation",
        })
    end

    return issues
end)
```

### Custom Severity Levels

```lua
-- Define custom severity for your project
local CUSTOM_SEVERITY = {
    SECURITY = 1,
    PERFORMANCE = 2,
    MAINTAINABILITY = 3,
    STYLE = 4,
}
```

---

## Best Practices

### ✅ Do

- Run QA checks regularly (at least before commits)
- Address critical issues immediately
- Set quality score targets for your project
- Use QA results for code review guidance
- Document quality requirements
- Track quality metrics over time
- Fix root causes, not just symptoms
- Use QA as learning tool

### ❌ Don't

- Ignore critical issues
- Disable all checks for convenience
- Let quality score gradually decrease
- Chase perfection (80+ is good)
- Suppress legitimate warnings
- Use QA to blame developers
- Make QA checks overly strict

---

## Performance Considerations

### Analysis Performance

- Small files (< 1KB): < 1ms
- Medium files (1-10KB): 1-5ms
- Large files (> 10KB): 5-50ms

### Optimization Tips

- Analyze files in parallel when possible
- Cache analysis results
- Only re-analyze changed files
- Use selective checks for quick feedback

---

## Troubleshooting

### Too Many Issues

- Start with one check enabled
- Address highest severity first
- Don't try to fix everything at once
- Use selective analysis for feedback

### False Positives

- Review issue carefully
- Context matters (e.g., intentional globals)
- Can disable specific checks
- File issues with examples

### Performance Issues

- Check large file limits
- Profile analysis time
- Reduce check count
- Run async if possible

---

## Configuration Examples

### Strict Mode (Production)

```lua
QASystem.config = {
    check_globals = true,
    check_performance = true,
    check_style = true,
    check_coverage = true,
    check_complexity = true,
    check_documentation = true,
    strict_mode = true,
}
```

### Relaxed Mode (Development)

```lua
QASystem.config = {
    check_globals = true,
    check_performance = false,
    check_style = false,
    check_coverage = false,
    check_complexity = true,
    check_documentation = false,
    strict_mode = false,
}
```

---

## Metrics Tracked

### Per-Module Metrics

- Lines of code
- Number of functions
- Average function length
- Cyclomatic complexity
- Documentation coverage
- Code duplication

### System-Wide Metrics

- Total lines analyzed
- Total functions
- Average complexity
- Quality score trend
- Issue density

---

## Integration with Other Tools

### Test Framework

QA results complement testing:
- Tests verify behavior
- QA verifies code quality
- Combined provides confidence

### UI Testing

QA checks UI code:
- Element registration
- Event handlers
- Style consistency

### Performance Testing

QA identifies:
- Potential bottlenecks
- Inefficient patterns
- Memory leaks

---

## Summary

The Code Quality Assurance System provides:

✅ **Automated Analysis:** Detect issues automatically
✅ **Multiple Check Types:** Globals, style, complexity, performance, documentation
✅ **Severity Classification:** 5-level severity system
✅ **Quality Scoring:** 0-100 scale
✅ **Detailed Reporting:** Comprehensive issue breakdown
✅ **Custom Rules:** Extensible check system
✅ **Integration:** Works with development workflow
✅ **Actionable:** Clear, specific issue descriptions

Ready for production quality assurance!
