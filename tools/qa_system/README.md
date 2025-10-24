# QA System - Code Quality Assurance

Automated quality checking for AlienFall codebase.

## Features

- **30+ Quality Checks:**
  - Code style compliance (naming, indentation, whitespace)
  - Documentation completeness (module docs, function docs)
  - Code complexity (cyclomatic complexity, function length)
  - Performance anti-patterns (nested loops, string concat)
  - Security issues (hardcoded secrets, eval operations)

- **Categorized Issues:**
  - Style, Documentation, Complexity, Performance, Security

- **Detailed Reporting:**
  - Summary with severity breakdown
  - Code grade (A-F)
  - Top files with issues
  - Detailed issue list with file/line/message

- **Multiple Output Formats:**
  - Text (console)
  - JSON (machine-readable)
  - HTML (visual report)

## Files

- `qa_engine.lua` - Core QA engine with all checks
- `qa_runner.lua` - Command-line runner for analysis

## Usage

### Text Report (Console)
```bash
lua tools/qa_system/qa_runner.lua engine text
```

### JSON Output
```bash
lua tools/qa_system/qa_runner.lua engine json
```

### HTML Report
```bash
lua tools/qa_system/qa_runner.lua engine html > report.html
```

## Configuration

Modify `QAEngine.config` in `qa_engine.lua` to adjust:
- Max cyclomatic complexity: default 10
- Max function length: default 100 lines
- Max line length: default 120 characters
- Directories to scan

## Quality Thresholds

| Metric | Threshold |
|--------|-----------|
| Cyclomatic Complexity | ≤ 10 |
| Cognitive Complexity | ≤ 15 |
| Function Length | ≤ 100 lines |
| Nesting Depth | ≤ 4 levels |
| Parameter Count | ≤ 5 params |
| Line Length | ≤ 120 chars |

## Code Grades

- **A**: Excellent (0 issues)
- **B+**: Very Good (1-5 medium issues)
- **B**: Good (6-10 medium issues)
- **B-**: Fair (11+ medium issues)
- **C**: Poor (1+ high issues)
- **D**: Very Poor (5+ high issues)
- **F**: Critical (1+ critical issues)

## Checks Implemented

### Style (8 checks)
1. Global variable detection
2. Indentation consistency
3. Trailing whitespace
4. Variable naming conventions
5. Comment formatting
6. Operator spacing
7. Blank line consistency
8. String quote consistency

### Documentation (5 checks)
9. Module docstring presence
10. Function documentation
11. Parameter documentation
12. Return value documentation
13. Complex logic comments

### Complexity (5 checks)
14. Cyclomatic complexity
15. Cognitive complexity
16. Function length
17. Nesting depth
18. Parameter count

### Performance (4 checks)
19. Nested loop detection
20. String concatenation in loops
21. Repeated table lookups
22. Inefficient patterns

### Security (3 checks)
23. Hardcoded secrets
24. Eval-like operations
25. Unvalidated input

## Example Output

```
============================================================
ALIENFALL QA REPORT
============================================================

SUMMARY
  Files Scanned: 293
  Issues Found: 45
    🔴 Critical: 0
    ⚠️  High: 8
    📋 Medium: 35
    ℹ️  Low: 2

CODE GRADE: B

ISSUES BY CATEGORY:
  style: 15 issues
  documentation: 20 issues
  complexity: 7 issues
  performance: 3 issues
  security: 0 issues

TOP FILES WITH ISSUES:
  1. engine/battlescape/rendering/view_3d.lua (8 issues)
  2. engine/geoscape/logic/world.lua (6 issues)
  3. engine/core/mod_manager.lua (5 issues)
```

## Future Enhancements

- [ ] Custom rule sets via configuration file
- [ ] CI/CD integration
- [ ] Trending reports over time
- [ ] Auto-fix suggestions
- [ ] IDE integration
- [ ] Real-time linting

## See Also

- `CODE_STANDARDS.md` - Development standards
- `ARCHITECTURE.md` - Code organization
- `DOCUMENTATION_STANDARD.md` - Doc standards
