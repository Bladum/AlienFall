# Python Best Practices & Guidelines for AI Agents - BIS Repository
<a id="top"></a>

**Target Audience:** AI Agents, BIS developers, and contributors working with Python code  
**Scope:** All Python modules in BIS repository (`engine/src/`, `tools/`, tests)  
**Apply to:** `**/*.py` files

---

## 📋 Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Agent Mission & Usage Guide](#-agent-mission--usage-guide)
  - [Purpose](#purpose)
  - [How AI Agents Should Use This Guide](#how-ai-agents-should-use-this-guide)
  - [Decision-Making Framework](#decision-making-framework)
- [🏗️ Core Principles & Architecture](#️-core-principles--architecture)
  - [Layered Architecture (MANDATORY)](#layered-architecture-mandatory)
  - [Core Design Principles (MANDATORY)](#core-design-principles-mandatory)
- [⚙️ AI Agent Adaptation Guide](#️-ai-agent-adaptation-guide)
  - [🎯 Agent Decision Framework](#-agent-decision-framework)
  - [🔄 Rewrite vs Incremental Rules](#-rewrite-vs-incremental-rules)
  - [🎨 Practice Categorization for Agents](#-practice-categorization-for-agents)
  - [📊 Enforcement Actions & Logging](#-enforcement-actions--logging)
  - [🔧 Context-Aware Practice Selection](#-context-aware-practice-selection)
- [🧩 Python Code Structure](#-python-code-structure)
  - [Early Returns & Validation (CONTEXTUAL)](#early-returns--validation-contextual)
  - [Avoid Mutable Defaults (MANDATORY)](#avoid-mutable-defaults-mandatory)
  - [Pure Functions & Dependency Injection (ENHANCEMENT)](#pure-functions--dependency-injection-enhancement)
  - [Line Length & Formatting (CONTEXTUAL)](#line-length--formatting-contextual)
- [📁 Path Handling & File Operations](#-path-handling--file-operations)
  - [Use Pathlib (MANDATORY)](#use-pathlib-mandatory)
  - [Sibling File Operations (CONTEXTUAL)](#sibling-file-operations-contextual)
  - [Atomic File Operations (MANDATORY)](#atomic-file-operations-mandatory)
  - [OS-Specific Operations (CONTEXTUAL)](#os-specific-operations-contextual)
- [🖥️ PySide/Qt UI Best Practices](#️-pysideqt-ui-best-practices)
  - [Non-Blocking UI (MANDATORY)](#non-blocking-ui-mandatory)
  - [Dual Logger Pattern (MANDATORY)](#dual-logger-pattern-mandatory)
  - [Tab Refresh Pattern (CONTEXTUAL)](#tab-refresh-pattern-contextual)
  - [Signal/Slot Connections (CONTEXTUAL)](#signalslot-connections-contextual)
- [📄 File Processing & I/O](#-file-processing--io)
  - [Defensive YAML Access (MANDATORY)](#defensive-yaml-access-mandatory)
  - [Buffered File Reading (CONTEXTUAL)](#buffered-file-reading-contextual)
  - [Path Sanitization (MANDATORY)](#path-sanitization-mandatory)
- [🔍 Exception Handling & Logging](#-exception-handling--logging)
  - [Dual Logger Pattern (MANDATORY)](#dual-logger-pattern-mandatory-1)
  - [Loop Isolation (CONTEXTUAL)](#loop-isolation-contextual)
  - [Parameterized Logging (MANDATORY)](#parameterized-logging-mandatory)
- [🔒 Security Best Practices](#-security-best-practices)
  - [Input Validation & Sanitization (MANDATORY)](#input-validation--sanitization-mandatory)
  - [SQL Injection Prevention (MANDATORY)](#sql-injection-prevention-mandatory)
  - [Secrets Management (MANDATORY)](#secrets-management-mandatory)
- [🗄️ DuckDB Data Processing](#️-duckdb-data-processing)
  - [SQL-First Approach (CONTEXTUAL)](#sql-first-approach-contextual)
  - [Parameterized Queries (MANDATORY)](#parameterized-queries-mandatory)
  - [Cursor Management (CONTEXTUAL)](#cursor-management-contextual)
  - [Temporary Tables Strategy (CONTEXTUAL)](#temporary-tables-strategy-contextual)
- [📊 DataFrame Operations](#-dataframe-operations)
  - [Memory-Efficient DataFrames (CONTEXTUAL)](#memory-efficient-dataframes-contextual)
  - [Vectorized Operations (CONTEXTUAL)](#vectorized-operations-contextual)
- [📝 Documentation & Comments](#-documentation--comments)
  - [Module Docstring Template (MANDATORY)](#module-docstring-template-mandatory)
  - [Class and Method Docstrings (CONTEXTUAL)](#class-and-method-docstrings-contextual)
  - [Block Comments (CONTEXTUAL)](#block-comments-contextual)
  - [Inline Comments (ENHANCEMENT)](#inline-comments-enhancement)
- [🧪 Testing & Validation - Comprehensive Guide](#-testing--validation---comprehensive-guide)
  - [🎯 Testing Philosophy for BIS](#-testing-philosophy-for-bis)
  - [🏗️ Required Test Structure (MANDATORY)](#️-required-test-structure-mandatory)
  - [🗂️ Using engine/data Data for Testing](#️-using-wikidummy-data-for-testing)
  - [🔬 Advanced Testing Patterns](#-advanced-testing-patterns)
  - [🧑‍💻 Software Tester Guidelines](#-software-tester-guidelines)
- [📦 Import Management](#-import-management)
  - [Import Organization (CONTEXTUAL)](#import-organization-contextual)
  - [Type Hints (ENHANCEMENT)](#type-hints-enhancement)
  - [Avoiding Circular Imports (CONTEXTUAL)](#avoiding-circular-imports-contextual)
- [✅ Quick Validation Checklist](#-quick-validation-checklist)
  - [Architecture & Design ✅](#architecture--design-)
  - [Code Structure ✅](#code-structure-)
  - [Logging & Error Handling ✅](#logging--error-handling-)
  - [Security ✅](#security-)
  - [UI (if applicable) ✅](#ui-if-applicable-)
  - [Data Processing ✅](#data-processing-)
  - [Documentation ✅](#documentation-)
  - [Testing ✅](#testing-)
  - [AI Agent Compliance ✅](#ai-agent-compliance-)
- [🛠️ Development Workflow](#️-development-workflow)
  - [Setting Up Development Environment](#setting-up-development-environment)
  - [Pre-commit Validation](#pre-commit-validation)
  - [AI Agent Enforcement Examples](#ai-agent-enforcement-examples)
- [🎯 Practice Priority Matrix](#-practice-priority-matrix)
- [🔍 Troubleshooting Common Issues](#-troubleshooting-common-issues)
- [🎯 Final Note for AI Agents](#-final-note-for-ai-agents)

---

## 🎯 Agent Mission & Usage Guide
<div align="right"><a href="#top">↑ Back to top</a></div>

### Purpose
<div align="right"><a href="#top">↑ Back to top</a></div>

This guide provides comprehensive Python coding standards for AI agents working on the BIS repository. It combines architectural principles, security practices, and specific coding patterns to ensure consistent, maintainable, and secure code generation.

### How AI Agents Should Use This Guide
<div align="right"><a href="#top">↑ Back to top</a></div>

**Decision-Making Framework:**
- **MANDATORY PRACTICES**: Must always be applied (security, layered architecture, logging patterns)
- **CONTEXTUAL PRACTICES**: Apply based on code context (UI patterns for GUI modules, SQL patterns for data processing)
- **ENHANCEMENT PRACTICES**: Apply when improving existing code or when explicitly requested

**User Prompts & Enforcement:**
- **"Apply all practices"**: Agent MUST implement ALL applicable practices from this guide
- **"Force update X"**: Agent MUST overwrite existing code/comments/docstrings completely
- **"Enforce best practices"**: Agent selects and applies relevant practices based on code context

**Scope of Autonomy:**
- Agents can decide which practices are relevant to the current task
- When in doubt, err on the side of applying more practices rather than fewer
- Always log what practices were applied for transparency

---

## 🏗️ Core Principles & Architecture
<div align="right"><a href="#top">↑ Back to top</a></div>

### Layered Architecture (MANDATORY)
<div align="right"><a href="#top">↑ Back to top</a></div>

The BIS application follows a **layered monolith** design with strict separation of concerns:

```
┌─────────────────────────────┐
│     UI Layer (gui/)         │  ← Thin, responsive, user interaction
├─────────────────────────────┤
│ Orchestration Layer         │  ← Coordination, workflow, state management
│ (high/, model/)             │
├─────────────────────────────┤
│ Computation Layer           │  ← Heavy processing, I/O, business logic
│ (low/, tool/)               │
└─────────────────────────────┘
```

**✅ Correct Implementation:**
*Reason: This correctly implements the layered architecture by delegating heavy work from GUI to appropriate layers, ensuring UI responsiveness and proper separation of concerns.*
```python
# GUI -> High -> Low delegation
class GuiLoader:
    def on_run_clicked(self):
        """Delegate to orchestration layer."""
        LoaderOrchestrator().start_pipeline()

class LoaderOrchestrator:
    def start_pipeline(self):
        """Coordinate workflow without heavy processing."""
        config = self._load_config()
        return DataProcessor().process(config)

class DataProcessor:
    def process(self, config):
        """Heavy computation and I/O operations."""
        return self._run_sql_transforms(config)
```

**❌ Wrong Implementation:**
*Reason: This violates the layered architecture by placing heavy processing directly in the UI layer, which will freeze the GUI and make the application unresponsive to user interactions. The UI layer should only handle user events and delegate work to lower layers.*
```python
# UI mixing heavy processing
class GuiLoader:
    def on_run_clicked(self):
        # WRONG: Heavy SQL and file I/O in UI - will freeze the interface
        # This blocks the UI thread and violates separation of concerns
        con = duckdb.connect()
        data = con.execute("SELECT * FROM huge_table").fetchall()
        with open("output.csv", "w") as f:
            f.write(process_data(data))
```

### Core Design Principles (MANDATORY)
<div align="right"><a href="#top">↑ Back to top</a></div>

#### 1. Idempotence
Operations must be repeatable without errors or state corruption.

**✅ Correct Implementation:**
*Reason: This ensures atomicity by writing to a temporary file first, then atomically replacing the target file. This prevents corruption from partial writes if the process is interrupted.*
```python
def atomic_write(filepath: Path, content: str) -> None:
    """Write content atomically to prevent partial writes."""
    temp_file = filepath.with_suffix(filepath.suffix + ".tmp")
    temp_file.write_text(content, encoding="utf-8")
    temp_file.replace(filepath)  # Atomic operation
```

#### 2. Config-Driven Behavior
Behavior should be driven by YAML configuration, not hard-coded values.


**✅ Correct Implementation:**
*Reason: This implementation loads configuration from YAML with safe defaults, ensuring the code is config-driven and robust to missing or incomplete config files. It avoids hard-coded values and supports maintainability and flexibility.*
```python
def load_settings(config_path: Path) -> dict:
    """Load configuration with safe defaults."""
    config = yaml.safe_load(config_path.read_text()) if config_path.exists() else {}
    return {
        'retry_attempts': config.get('retry_attempts', 3),
        'timeout_seconds': config.get('timeout_seconds', 30),
        'batch_size': config.get('batch_size', 1000)
    }
```

#### 3. Multithreading for UI Responsiveness
Heavy operations must be offloaded from the UI thread.

**✅ Correct Implementation:**
*Reason: This implementation offloads heavy processing to a background thread using QThreadPool, ensuring the UI remains responsive and does not freeze during long-running operations. This is essential for good user experience in GUI applications.*
```python
from PySide6.QtCore import QThreadPool

class GuiProcessor:
    def __init__(self):
        self.threadpool = QThreadPool.globalInstance()
    
    def start_heavy_task(self):
        """Offload heavy work to background thread."""
        worker = Worker(self._process_data)
        self.threadpool.start(worker)
```

---

## ⚙️ AI Agent Adaptation Guide
<div align="right"><a href="#top">↑ Back to top</a></div>

### 🎯 Agent Decision Framework
<div align="right"><a href="#top">↑ Back to top</a></div>

#### Trigger Word Recognition (MANDATORY)
**AI agents MUST recognize these user prompts and respond accordingly:**

| User Prompt Pattern | Agent Action | Scope | Rewrite Level |
|---------------------|--------------|-------|---------------|
| **"apply all practices"** | Apply ALL applicable practices | Entire codebase/file | Complete rewrite |
| **"enforce best practices"** | Apply relevant practices based on context | Current file/module | Selective updates |
| **"force update [X]"** | Completely rewrite specified component | Named component only | Complete rewrite |
| **"add/fix [practice]"** | Apply specific practice only | Targeted area | Incremental update |
| **"improve code quality"** | Apply enhancement practices | Current context | Selective updates |
| **"make it production ready"** | Apply all mandatory + security practices | Full scope | Complete rewrite |
| **"standardize documentation"** | Apply all documentation practices | All docstrings/comments | Complete rewrite |
| **"secure this code"** | Apply all security practices | Security-related code | Targeted updates |

#### Decision Tree for Practice Application

```
User Request
    ├── Contains "all" or "force" or "production ready"?
    │   ├── YES → Apply ALL practices, Complete rewrite
    │   └── NO → Continue evaluation
    │
    ├── Mentions specific practice (e.g., "docstrings", "logging")?
    │   ├── YES → Apply only that practice category
    │   └── NO → Continue evaluation
    │
    ├── Context-based application
    │   ├── GUI file → Apply UI practices
    │   ├── Database code → Apply SQL/security practices
    │   ├── New file → Apply all mandatory practices
    │   └── Existing file → Apply relevant practices only
```

### 🔄 Rewrite vs Incremental Rules
<div align="right"><a href="#top">↑ Back to top</a></div>

#### Complete Rewrite Triggers (MANDATORY)
**Agent MUST completely rewrite when:**
- User says "force", "rewrite", "from scratch", "start over"
- User says "apply all practices" 
- User says "make it production ready"
- Current code violates multiple mandatory practices
- Security vulnerabilities are present

#### Incremental Update Triggers (CONTEXTUAL)
**Agent SHOULD update incrementally when:**
- User mentions specific practice ("add logging", "fix docstrings")
- Code mostly follows practices but needs minor improvements
- User says "improve" or "enhance" without "all"
- Working with legacy code that functions correctly

### 🎨 Practice Categorization for Agents
<div align="right"><a href="#top">↑ Back to top</a></div>

#### MANDATORY Practices (Always Apply)
```yaml
security:
  - input_validation
  - sql_parameterization
  - secrets_management
  - path_sanitization

architecture:
  - layered_separation
  - idempotent_operations
  - config_driven_behavior

logging:
  - dual_logger_pattern
  - parameterized_logging
  - existing_logger_names

error_handling:
  - specific_exceptions
  - loop_isolation
  - early_returns
```

#### CONTEXTUAL Practices (Apply Based on Code Context)
```yaml
ui_code:
  - non_blocking_operations
  - qtimer_updates
  - signal_slot_connections
  - tab_refresh_pattern

data_processing:
  - sql_first_approach
  - temp_tables
  - vectorized_operations
  - memory_efficient_dtypes

file_operations:
  - pathlib_usage
  - atomic_writes
  - context_managers
```

#### ENHANCEMENT Practices (Apply When Improving)
```yaml
code_quality:
  - pure_functions
  - dependency_injection
  - comprehensive_docstrings
  - block_comments

testing:
  - additional_test_cases
  - integration_tests
  - performance_tests
```

### 📊 Enforcement Actions & Logging
<div align="right"><a href="#top">↑ Back to top</a></div>

#### Logging Requirements (MANDATORY)
**Agent MUST log enforcement actions in this format:**

```text
[ENFORCEMENT LOG - YYYY-MM-DD HH:MM:SS]
=====================================
Trigger: "{user_prompt}"
Action Level: {complete_rewrite | incremental_update | targeted_fix}
Scope: {file_path | module_name | function_name}

Files Modified:
- {file_path_1}
  Practices Applied:
  ✅ {practice_name}: {specific_change_description}
  ✅ {practice_name}: {specific_change_description}
  
- {file_path_2}
  Practices Applied:
  ✅ {practice_name}: {specific_change_description}

Summary:
- Total Files: {count}
- Total Practices Applied: {count}
- Mandatory Practices: {count}
- Contextual Practices: {count}
- Enhancement Practices: {count}
- Estimated Impact: {Low | Medium | High}
- Quality Score Improvement: {percentage}%
```

#### Agent Self-Validation Checklist
**Before completing enforcement, agent MUST verify:**
- [ ] All mandatory practices for file type applied
- [ ] No new logger names created
- [ ] Temporary files go to `temp/PYTHON_DEVELOPER/`
- [ ] User prompt requirements fully addressed
- [ ] Code remains functional after changes
- [ ] All examples follow ✅/❌ pattern from this guide

### 🔧 Context-Aware Practice Selection
<div align="right"><a href="#top">↑ Back to top</a></div>

#### File Type Detection
```python
# Agent logic for practice selection
def select_practices(file_path: str, user_prompt: str, file_content: str = "") -> list:
    practices = []
    
    # Always apply mandatory practices
    practices.extend(MANDATORY_PRACTICES)
    
    # Context-based selection
    if 'gui' in file_path.lower():
        practices.extend(UI_PRACTICES)
    
    if any(keyword in file_content for keyword in ['duckdb', 'SELECT', 'INSERT']):
        practices.extend(SQL_PRACTICES)
    
    if 'test' in file_path.lower():
        practices.extend(TESTING_PRACTICES)
    
    # User prompt-based selection
    if 'all' in user_prompt.lower():
        practices.extend(ALL_PRACTICES)
    
    return list(set(practices))  # Remove duplicates
```

#### 4. Logger Names (MANDATORY)
**Do NOT create new logger names.** Use existing canonical names:
- `GUI_LOAD_LOG`, `GUI_LOAD_ERROR`
- `GUI_ADMIN_LOG`, `GUI_ADMIN_ERROR`
- `GUI_PRACTICE_LOG`, `GUI_PRACTICE_ERROR`
- `TABLE_LOG`, `TABLE_ERROR`
- `INDICATOR_LOG`, `INDICATOR_ERROR`

**✅ Correct Implementation:**
*Reason: This code uses only existing, canonical logger names as required by BIS policy, ensuring all logs are routed correctly and preventing logger proliferation.*
```python
import logging
logger_log = logging.getLogger("GUI_LOAD_LOG")
logger_error = logging.getLogger("GUI_LOAD_ERROR")
```

#### 5. Temporary File Policy (MANDATORY)
**All AI agent outputs MUST go to:** `temp/PYTHON_DEVELOPER/`

**✅ Correct Implementation:**
*Reason: This code ensures all AI agent outputs are written to the required temp/PYTHON_DEVELOPER/ directory, enforcing tenant isolation and BIS temporary file policy.*
```python
output_path = Path("temp/PYTHON_DEVELOPER/analysis_results.txt")
output_path.parent.mkdir(parents=True, exist_ok=True)
output_path.write_text(results)
```

---

## 🧩 Python Code Structure
<div align="right"><a href="#top">↑ Back to top</a></div>

### Early Returns & Validation (CONTEXTUAL)
<div align="right"><a href="#top">↑ Back to top</a></div>

**✅ Correct Implementation:**
*Reason: Demonstrates fail-fast validation and early returns to avoid running expensive work on invalid input, improving readability and error handling.*
```python
def process_batch(items: list, config: dict) -> list:
    """Process batch with early validation."""
    # Early validation and returns
    if not items:
        logger_log.warning("Empty batch received")
        return []
    
    if not config:
        raise ValueError("Configuration required")
    
    batch_size = config.get('batch_size', 100)
    if batch_size <= 0:
        raise ValueError("Batch size must be positive")
    
    # Main processing logic
    results = []
    for item in items:
        result = process_item(item)
        results.append(result)
    
    return results
```

### Avoid Mutable Defaults (MANDATORY)
<div align="right"><a href="#top">↑ Back to top</a></div>

**✅ Correct Implementation:**
*Reason: Using None as default and checking for it prevents the dangerous pattern of mutable defaults. Each function call gets a fresh dictionary instead of sharing the same mutable object across calls.*
```python
def process_data(items: list, options: dict = None) -> dict:
    """Process data with safe defaults."""
    options = options or {}
    # Processing logic here
    return {"processed": len(items), "options": options}
```

**❌ Wrong Implementation:**
*Reason: Using a mutable object (dict) as a default argument is dangerous because the same dictionary instance is reused across all function calls. This causes unintended side effects where modifications in one call affect subsequent calls, leading to hard-to-debug issues.*
```python
def process_data(items: list, options: dict = {}) -> dict:
    """WRONG: Mutable default causes cross-call contamination."""
    options["processed_at"] = datetime.now()  # Modifies shared default!
    return options
```

### Pure Functions & Dependency Injection (ENHANCEMENT)

**✅ Correct Implementation:**
*Reason: This demonstrates clean dependency injection where the calculation logic is passed as a parameter, making the function pure, testable, and reusable with different calculation strategies.*
```python
def calculate_metrics(data: list, calculator: Callable) -> dict:
    """Pure function with explicit dependencies."""
    return {
        'total': calculator(data),
        'count': len(data),
        'average': calculator(data) / len(data) if data else 0
    }

# Usage
result = calculate_metrics(sales_data, sum)
```

### Line Length & Formatting (CONTEXTUAL)

**Maximum 120 characters per line.**

**✅ Correct Implementation:**
*Reason: Wraps long lines and function arguments to improve readability and comply with the 120-character guideline, making diffs and reviews easier.*
```python
# Long function calls
result = complicated_function(
    parameter_one=value_one,
    parameter_two=value_two,
    parameter_three=value_three,
    parameter_four=value_four
)

# Long strings
message = (
    "This is a very long message that needs to be wrapped "
    "across multiple lines for better readability and "
    "to stay within the 120 character limit."
)
```

---

## 📁 Path Handling & File Operations
<div align="right"><a href="#top">↑ Back to top</a></div>

### Use Pathlib (MANDATORY)

**✅ Correct Implementation:**
*Reason: Pathlib provides a modern, object-oriented approach to file operations with better readability, cross-platform compatibility, and built-in methods for common operations like exists(), read_text(), and glob().*
```python
from pathlib import Path

def process_files(base_dir: str) -> list:
    """Process all CSV files in directory."""
    base_path = Path(base_dir)
    csv_files = list(base_path.glob("*.csv"))
    
    results = []
    for file_path in csv_files:
        if file_path.exists():
            content = file_path.read_text(encoding="utf-8")
            results.append(content)
    
    return results
```

**❌ Wrong Implementation:**
*Reason: Using os.path requires more verbose code, manual path joining, and explicit file handling. It's more error-prone, less readable, and doesn't provide the modern conveniences of pathlib like automatic encoding handling and cross-platform path operations.*
```python
import os

def process_files(base_dir: str) -> list:
    """WRONG: Using os.path instead of pathlib."""
    csv_files = [f for f in os.listdir(base_dir) if f.endswith('.csv')]
    results = []
    for filename in csv_files:
        filepath = os.path.join(base_dir, filename)  # Manual path joining
        with open(filepath, 'r') as f:  # Manual file handling
            results.append(f.read())  # No encoding specified
    return results
```

### Sibling File Operations (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: This uses pathlib's built-in methods like with_suffix() and with_name() to create related file paths, ensuring consistent naming patterns and avoiding manual string manipulation.*
```python
def process_sql_file(sql_path: Path) -> Path:
    """Process SQL file and create related output."""
    # Create sibling files using pathlib methods
    log_path = sql_path.with_suffix('.log')
    output_path = sql_path.with_name(f"{sql_path.stem}_output.csv")
    
    # Ensure parent directories exist
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    return output_path
```

### Atomic File Operations (MANDATORY)

**✅ Correct Implementation:**
*Reason: Uses the temp-file-then-atomic-replace pattern to ensure idempotence and avoid partial-write corruption in case of crashes or interruptions.*
```python
def safe_file_write(filepath: Path, data: str) -> None:
    """Write file atomically to prevent corruption."""
    temp_path = filepath.with_suffix(filepath.suffix + ".tmp")
    
    try:
        # Write to temporary file first
        temp_path.write_text(data, encoding="utf-8")
        # Atomic replace
        temp_path.replace(filepath)
        logger_log.info("File written successfully: %s", filepath)
    except Exception as e:
        # Clean up temp file on error
        if temp_path.exists():
            temp_path.unlink()
        logger_error.error("Failed to write file %s: %s", filepath, e)
        raise
```

### OS-Specific Operations (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Handles platform differences explicitly, using the correct system call per OS and logging results; this avoids platform-specific errors and improves portability.*
```python
import sys
import subprocess
import os

def open_file_with_system(filepath: Path) -> None:
    """Open file with system default application."""
    try:
        if sys.platform.startswith("win"):
            os.startfile(filepath)  # type: ignore[attr-defined]
        elif sys.platform == "darwin":
            subprocess.run(["open", str(filepath)], check=True)
        else:
            subprocess.run(["xdg-open", str(filepath)], check=True)
        
        logger_log.info("Opened file: %s", filepath)
    except Exception as e:
        logger_log.warning("Failed to open file: %s", filepath)
            logger_error.info("Error details: %s", e)
```

---

## 🖥️ PySide/Qt UI Best Practices
<div align="right"><a href="#top">↑ Back to top</a></div>

> **🔗 See Also**: For stakeholder analysis and user-centered design principles, refer to the [Business Analysis Stakeholder Management](best-practices-business-analysis.instructions.md#-stakeholder-analysis--management) section.

### Non-Blocking UI (MANDATORY)

**✅ Correct Implementation:**
*Reason: Offloads heavy work to background threads and marshals UI updates back to the main thread, preventing UI freezes and ensuring thread-safety for GUI updates.*
```python
from PySide6.QtCore import QThreadPool, QTimer
from PySide6.QtWidgets import QWidget, QPushButton, QLabel

class ProcessorWidget(QWidget):
    def __init__(self):
        super().__init__()
        self.threadpool = QThreadPool.globalInstance()
        self._init_ui()
    
    def _init_ui(self):
        self.process_button = QPushButton("Start Processing")
        self.status_label = QLabel("Ready")
        self.process_button.clicked.connect(self._start_processing)
    
    def _start_processing(self):
        """Start heavy processing in background thread."""
        self.process_button.setEnabled(False)
        self.status_label.setText("Processing...")
        
        worker = Worker(self._heavy_computation)
        worker.signals.finished.connect(self._on_processing_finished)
        worker.signals.error.connect(self._on_processing_error)
        self.threadpool.start(worker)
    
    def _heavy_computation(self):
        """Heavy computation that runs in background."""
        # Simulate heavy work
        import time
        time.sleep(5)
        return "Processing complete"
    
    def _on_processing_finished(self, result):
        """Handle completion on main thread."""
        QTimer.singleShot(0, lambda: self._update_ui_after_processing(result))
    
    def _update_ui_after_processing(self, result):
        """Update UI safely from main thread."""
        self.status_label.setText(result)
        self.process_button.setEnabled(True)
```

### Dual Logger Pattern (MANDATORY)

**✅ Correct Implementation:**
*Reason: This implementation uses the dual logger pattern in a GUI context, ensuring that all logs go to the correct, pre-defined logger names. This supports clear separation of normal operation logs and error diagnostics, and enforces the BIS policy of not creating new logger names.*
```python
import logging

class GuiModule:
    def __init__(self):
        # Use existing logger names - DO NOT create new ones
        self.logger_log = logging.getLogger("GUI_LOAD_LOG")
        self.logger_error = logging.getLogger("GUI_LOAD_ERROR")
    
    def process_data(self):
        """Process data with proper logging."""
        self.logger_log.info("Starting data processing")
        
        try:
            # Processing logic
            result = self._perform_processing()
            self.logger_log.info("Processing completed successfully")
            return result
        except Exception as e:
            self.logger_log.error("Processing failed")
            self.logger_error.error("Detailed error: %s", e, exc_info=True)
            raise
```

### Tab Refresh Pattern (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Shows lazy loading to reduce startup time and unnecessary work until the tab is active, improving perceived performance.*
```python
class DataTab(QWidget):
    def __init__(self):
        super().__init__()
        self._data_loaded = False
        self._init_ui()
    
    def tab_refresh(self):
        """Lazy loading when tab becomes active."""
        if not self._data_loaded:
            self._load_data()
            self._data_loaded = True
    
    def _load_data(self):
        """Load data in background thread."""
        worker = Worker(self._fetch_data)
        worker.signals.finished.connect(self._on_data_loaded)
        self.threadpool.start(worker)
```

### Signal/Slot Connections (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Centralizes signal/slot wiring in one method to improve discoverability and makes it easier to verify UI behavior during testing.*
```python
class MainWindow(QMainWindow):
    def _init_connections(self):
        """Set up signal/slot connections."""
        self.run_button.clicked.connect(self._on_run_clicked)
        self.settings_action.triggered.connect(self._show_settings)
        self.data_timer.timeout.connect(self._refresh_data)
    
    def _on_run_clicked(self):
        """Handle run button click - delegate to worker."""
        self._start_background_task()
    
    def _show_settings(self):
        """Show settings dialog."""
        dialog = SettingsDialog(self)
        dialog.exec()
```

---

## 📄 File Processing & I/O
<div align="right"><a href="#top">↑ Back to top</a></div>

### Defensive YAML Access (MANDATORY)

**✅ Correct Implementation:**
*Reason: Uses safe_load with defensive defaults and error handling so malformed or missing configs won't crash the app and defaults are applied predictably.*
```python
import yaml
from pathlib import Path

def load_config(config_path: Path) -> dict:
    """Load YAML configuration with safe defaults."""
    try:
        if not config_path.exists():
            logger_log.warning("Config file not found: %s", config_path)
            return {}
        
        config = yaml.safe_load(config_path.read_text(encoding="utf-8"))
        if config is None:
            return {}
        
        # Defensive access with defaults
        settings = {
            'database': {
                'host': config.get('database', {}).get('host', 'localhost'),
                'port': config.get('database', {}).get('port', 5432),
                'timeout': config.get('database', {}).get('timeout', 30)
            },
            'processing': {
                'batch_size': config.get('processing', {}).get('batch_size', 1000),
                'max_retries': config.get('processing', {}).get('max_retries', 3)
            }
        }
        
        return settings
        
    except yaml.YAMLError as e:
        logger_error.error("Invalid YAML in config file %s: %s", config_path, e)
        return {}
    except Exception as e:
        logger_error.error("Failed to load config %s: %s", config_path, e)
        return {}
```

**❌ Wrong Implementation:**
*Reason: This approach has multiple serious flaws: no error handling for file reading or YAML parsing, direct key access without checking if keys exist (will raise KeyError), and no validation of the configuration structure. This will cause the application to crash on malformed YAML or missing configuration keys.*
```python
def load_config(config_path: Path) -> dict:
    """WRONG: Direct access without error handling."""
    config = yaml.safe_load(config_path.read_text())
    # These will raise KeyError if keys don't exist
    host = config['database']['host']
    port = config['database']['port']
    return {'host': host, 'port': port}
```

### Buffered File Reading (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Processes the file incrementally to avoid high memory usage and supports progress logging for large files.*
```python
def process_large_file(filepath: Path) -> int:
    """Process large file without loading everything into memory."""
    line_count = 0
    
    try:
        with filepath.open('r', encoding='utf-8') as file:
            for line in file:
                # Process line by line
                process_line(line.strip())
                line_count += 1
                
                # Progress logging for large files
                if line_count % 10000 == 0:
                    logger_log.info("Processed %d lines", line_count)
        
        return line_count
        
    except Exception as e:
        logger_error.error("Failed to process file %s: %s", filepath, e)
        raise
```

### Path Sanitization (MANDATORY)

**✅ Correct Implementation:**
*Reason: Resolves and normalizes paths to prevent path traversal and ensures consistent cross-platform behavior.*
```python
def safe_path_join(base_dir: Path, user_path: str) -> Path:
    """Safely join user-provided path to base directory."""
    # Normalize and resolve the paths
    base_resolved = base_dir.resolve()
    candidate_path = (base_dir / user_path).resolve()
    
    # Ensure the candidate path is within the base directory
    try:
        candidate_path.relative_to(base_resolved)
        return candidate_path
    except ValueError:
        raise ValueError(f"Path traversal attempt detected: {user_path}")

# Usage
try:
    safe_file = safe_path_join(Path("data"), user_input)
    content = safe_file.read_text()
except ValueError as e:
    logger_error.error("Security violation: %s", e)
    raise
```

---

## 🔍 Exception Handling & Logging
<div align="right"><a href="#top">↑ Back to top</a></div>

### Dual Logger Pattern (MANDATORY)

**✅ Correct Implementation:**
*Reason: This pattern uses two existing loggers—one for high-level summaries and one for detailed errors—ensuring clear separation of normal operation logs and error diagnostics. It improves observability, supports troubleshooting, and enforces the BIS policy of not creating new logger names.*
```python
import logging

# Use existing logger names - never create new ones
logger_log = logging.getLogger("TABLE_LOG")  # High-level summaries
logger_error = logging.getLogger("TABLE_ERROR")  # Detailed errors

def process_table(table_name: str) -> bool:
    """Process table with comprehensive logging."""
    logger_log.info("Starting table processing: %s", table_name)
    
    try:
        # Processing logic
        result = perform_table_operations(table_name)
        logger_log.info("Table processing completed: %s", table_name)
        return result
        
    except ValueError as e:
        logger_log.error("Invalid table configuration: %s", table_name)
        logger_error.error("Validation error details: %s", e, exc_info=True)
        return False
        
    except Exception as e:
        logger_log.error("Table processing failed: %s", table_name)
        logger_error.error("Unexpected error: %s", e, exc_info=True)
        raise
```

### Loop Isolation (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Isolates errors per item so one failure doesn't stop batch processing and preserves overall progress reporting.*
```python
def process_batch_items(items: list) -> list:
    """Process items with isolated error handling."""
    results = []
    failed_count = 0
    
    for i, item in enumerate(items):
        try:
            result = process_single_item(item)
            results.append(result)
            
        except ValueError as e:
            logger_log.warning("Item %d validation failed", i)
            logger_error.info("Validation error: %s", e)
            results.append(None)
            failed_count += 1
            
        except Exception as e:
            logger_log.error("Item %d processing failed", i)
            logger_error.error("Processing error: %s", e, exc_info=True)
            results.append(None)
            failed_count += 1
    
    logger_log.info("Batch complete: %d items, %d failed", len(items), failed_count)
    return results
```

### Parameterized Logging (MANDATORY)

**✅ Correct Implementation:**
*Reason: Parameterized logging is safer because the logging framework handles the string formatting only if the log level is enabled, and it prevents accidental exposure of sensitive data through format string vulnerabilities.*
```python
# Use parameterized logging - never f-strings
logger_log.info("Processing table %s with %d rows", table_name, row_count)
logger_error.error("Database connection failed for host %s port %d", host, port)
```

**❌ Wrong Implementation:**
*Reason: Using f-strings in logging is dangerous because: 1) The string formatting happens regardless of log level (performance issue), 2) It can expose sensitive data if variables contain credentials, 3) It's vulnerable to format string attacks, and 4) It makes log analysis and filtering more difficult.*
```python
# WRONG: f-strings in logging can expose sensitive data
logger_log.info(f"Processing table {table_name} with {row_count} rows")
logger_error.error(f"Database connection failed for {host}:{port}")
```

---

## 🔒 Security Best Practices
<div align="right"><a href="#top">↑ Back to top</a></div>

> **🔗 See Also**: For SQL-specific security practices including parameterized queries and performance optimization, refer to the [SQL Performance & Optimization](best-practices_sql.instructions.md#performance-optimization) section.

### Input Validation & Sanitization (MANDATORY)

**✅ Correct Implementation:**
*Reason: Validates and sanitizes input early to prevent injection and downstream failures, enforcing secure defaults.*
```python
import re
from typing import Union

def validate_table_name(table_name: str) -> str:
    """Validate and sanitize table name."""
    if not isinstance(table_name, str):
        raise ValueError("Table name must be a string")
    
    # Remove dangerous characters
    sanitized = re.sub(r'[^a-zA-Z0-9_]', '', table_name)
    
    if not sanitized:
        raise ValueError("Table name contains no valid characters")
    
    if len(sanitized) > 64:
        raise ValueError("Table name too long (max 64 characters)")
    
    return sanitized

def validate_numeric_input(value: Union[str, int, float], min_val: float = None, max_val: float = None) -> float:
    """Validate and convert numeric input."""
    try:
        num_value = float(value)
    except (ValueError, TypeError):
        raise ValueError(f"Invalid numeric value: {value}")
    
    if min_val is not None and num_value < min_val:
        raise ValueError(f"Value {num_value} below minimum {min_val}")
    
    if max_val is not None and num_value > max_val:
        raise ValueError(f"Value {num_value} above maximum {max_val}")
    
    return num_value
```

### SQL Injection Prevention (MANDATORY)

**✅ Correct Implementation:**
*Reason: Uses parameterized queries to avoid SQL injection and ensures query parameters are passed safely to the DB layer.*
```python
import duckdb

def safe_query_execution(connection: duckdb.DuckDBPyConnection, user_id: int, status: str) -> list:
    """Execute query with parameterized values."""
    # ALWAYS use parameterized queries
    query = """
        SELECT id, name, created_at 
        FROM users 
        WHERE user_id = ? AND status = ?
        ORDER BY created_at DESC
    """
    
    try:
        result = connection.execute(query, [user_id, status]).fetchall()
        logger_log.info("Query executed successfully for user %d", user_id)
        return result
        
    except Exception as e:
        logger_error.error("Query execution failed: %s", e)
        raise
```

**❌ Incorrect Implementation:**
```python
def unsafe_query(connection: duckdb.DuckDBPyConnection, user_id: int, status: str) -> list:
    """WRONG: String formatting creates SQL injection risk."""
    query = f"SELECT * FROM users WHERE user_id = {user_id} AND status = '{status}'"
    return connection.execute(query).fetchall()
```

### Secrets Management (MANDATORY)

**✅ Correct Implementation:**
*Reason: Stores credentials in environment variables and validates presence to avoid hardcoded secrets and leakage.*
```python
import os
from pathlib import Path

def get_database_credentials() -> dict:
    """Get database credentials from environment."""
    credentials = {
        'host': os.environ.get('DB_HOST', 'localhost'),
        'port': int(os.environ.get('DB_PORT', '5432')),
        'username': os.environ.get('DB_USERNAME'),
        'password': os.environ.get('DB_PASSWORD')
    }
    
    # Validate required credentials
    if not credentials['username'] or not credentials['password']:
        raise ValueError("Database credentials not found in environment")
    
    return credentials

def log_connection_attempt(host: str, port: int, username: str) -> None:
    """Log connection attempt without exposing credentials."""
    logger_log.info("Attempting database connection to %s:%d as user %s", host, port, username)
    # NEVER log passwords or sensitive data
```

**❌ Wrong Implementation:**
*Reason: Hardcoded secrets and logging credentials risk leakage and violate BIS policy.*
```python
# WRONG: Hardcoded secrets
DB_PASSWORD = "supersecret123"

def log_credentials(username: str, password: str) -> None:
    # WRONG: Logging sensitive data
    logger_log.info(f"Connecting with {username}:{password}")
```

---

## 🗄️ DuckDB Data Processing
<div align="right"><a href="#top">↑ Back to top</a></div>

> **🔗 See Also**: For comprehensive SQL patterns and DuckDB-specific optimization techniques, refer to the [SQL Build & Materialization](best-practices_sql.instructions.md#build-materialization) and [SQL Performance & Optimization](best-practices_sql.instructions.md#performance-optimization) sections.

### SQL-First Approach (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Keeps business logic in SQL where appropriate, using temporary staging and views to make transformations explicit and performant within DuckDB.*
```python
import duckdb
from pathlib import Path

def process_sales_data(connection: duckdb.DuckDBPyConnection, start_date: str, end_date: str) -> Path:
    """Process sales data using SQL-first approach."""
    
    # Step 1: Create temporary staging table
    staging_sql = """
        CREATE OR REPLACE TEMP TABLE sales_staging AS
        SELECT 
            customer_id,
            product_id,
            sale_date,
            amount,
            region
        FROM read_csv_auto('data/sales.csv')
        WHERE sale_date BETWEEN ? AND ?
    """
    connection.execute(staging_sql, [start_date, end_date])
    
    # Step 2: Apply business logic in SQL
    aggregation_sql = """
        CREATE OR REPLACE TEMP TABLE sales_summary AS
        SELECT 
            region,
            customer_id,
            COUNT(*) as transaction_count,
            SUM(amount) as total_amount,
            AVG(amount) as avg_amount,
            MAX(sale_date) as last_sale_date
        FROM sales_staging
        GROUP BY region, customer_id
        HAVING total_amount > 1000
        ORDER BY total_amount DESC
    """
    connection.execute(aggregation_sql)
    
    # Step 3: Create final view
    view_sql = """
        CREATE OR REPLACE VIEW v_sales_summary AS
        SELECT * FROM sales_summary
    """
    connection.execute(view_sql)
    
    # Step 4: Export with proper options
    output_path = Path("temp/PYTHON_DEVELOPER/sales_summary.parquet")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    export_sql = """
        COPY v_sales_summary
        TO ?
        (FORMAT PARQUET, COMPRESSION ZSTD, USE_TMP_FILE TRUE, 
         KV_METADATA '{"description":"Sales summary report","generated_by":"BIS"}')
    """
    connection.execute(export_sql, [str(output_path)])
    
    logger_log.info("Sales data processed and exported to %s", output_path)
    return output_path
```

### Parameterized Queries (MANDATORY)

**✅ Correct Implementation:**
*Reason: Demonstrates parameterized query construction and safe parameter passing to avoid SQL injection and ensure query correctness across variable-length inputs.*
```python
def get_user_data(connection: duckdb.DuckDBPyConnection, user_ids: list, min_score: float) -> list:
    """Get user data with parameterized query."""
    
    # Use placeholders for all dynamic values
    placeholders = ','.join(['?' for _ in user_ids])
    query = f"""
        SELECT user_id, name, score, last_login
        FROM users 
        WHERE user_id IN ({placeholders})
        AND score >= ?
        ORDER BY score DESC
    """
    
    # Pass all parameters as a list
    parameters = user_ids + [min_score]
    
    try:
        result = connection.execute(query, parameters).fetchall()
        logger_log.info("Retrieved %d users with score >= %f", len(result), min_score)
        return result
        
    except Exception as e:
        logger_error.error("User data query failed: %s", e)
        raise
```

### Cursor Management (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Validates identifier and checks table existence via information_schema; avoids parameterizing identifiers which DuckDB doesn't support; then fetches safely.*
```python
def check_and_fetch_data(connection: duckdb.DuckDBPyConnection, table_name: str) -> list:
    """Check for data existence, then fetch if present."""
    
    # Step 1: Check if data exists
    check_query = "SELECT COUNT(*) FROM ? LIMIT 1"
    cursor = connection.execute(check_query, [table_name])
    
    if cursor.fetchone()[0] == 0:
        logger_log.info("No data found in table %s", table_name)
        return []
    
    # Step 2: Re-execute query to fetch all data (cursor was consumed)
    fetch_query = "SELECT * FROM ?"
    cursor = connection.execute(fetch_query, [table_name])
    results = cursor.fetchall()
    
    logger_log.info("Fetched %d rows from table %s", len(results), table_name)
    return results
```

### Temporary Tables Strategy (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Uses TEMP tables for staging and transformations, enabling clear, composable steps and automatic cleanup within the session.*
```python
def build_report_pipeline(connection: duckdb.DuckDBPyConnection) -> None:
    """Build report using temporary tables for intermediate steps."""
    
    # Step 1: Raw data staging
    connection.execute("""
        CREATE OR REPLACE TEMP TABLE raw_data AS
        SELECT * FROM read_csv_auto('data/transactions.csv')
    """)
    
    # Step 2: Data cleaning
    connection.execute("""
        CREATE OR REPLACE TEMP TABLE clean_data AS
        SELECT transaction_id, customer_id, CAST(amount AS DECIMAL(10,2)) AS amount
        FROM raw_data WHERE amount > 0
        """
    )

    # Publish final view
    connection.execute(
        """
        CREATE OR REPLACE VIEW v_customer_report AS
        SELECT customer_id, SUM(amount) AS total_spent FROM clean_data GROUP BY customer_id
        """
    )
    # ...existing code...
```

---

## 📊 DataFrame Operations
<div align="right"><a href="#top">↑ Back to top</a></div>

### Memory-Efficient DataFrames (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Uses Polars lazy frames to define the query plan upfront and optimize execution, significantly improving performance and memory usage for large datasets.*
```python
import polars as pl

def process_large_dataset_polars(file_path: str) -> pl.DataFrame:
    """Process large dataset efficiently with Polars."""
    # Lazy plan: scan → filter → derive → group → aggregate
    lazy_df = (
        pl.scan_csv(file_path)
        .filter(pl.col('amount') > 0)
        .with_columns(pl.col('amount').round(2).alias('amount_rounded'))
        .group_by(['customer_id'])
        .agg(pl.col('amount').sum().alias('total_spent'))
    )
    result = lazy_df.collect()
    # ...existing code...
    return result
```

### Vectorized Operations (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Demonstrates the use of Polars vectorized operations for efficient computation across entire columns or groups, taking advantage of CPU optimizations and reducing the need for explicit loops.*
```python
import polars as pl

def calculate_customer_metrics(df: pl.DataFrame) -> pl.DataFrame:
    """Calculate customer metrics using vectorized operations."""
    return df.with_columns([
        (pl.col('total_spent') / pl.col('transaction_count')).alias('avg_per_transaction'),
        pl.when(pl.col('total_spent') > 10000).then('Premium').otherwise('Bronze').alias('customer_tier'),
    ])
    # ...existing code...
```

**❌ Wrong Implementation:**
*Reason: Row-by-row iteration is slow and memory-inefficient; prefer vectorized expressions to leverage Polars' engine.*
```python
def calculate_metrics_slow(df: pl.DataFrame) -> pl.DataFrame:
    """WRONG: Row-by-row processing instead of vectorized operations."""
    
    # Don't iterate over DataFrame rows - use vectorized operations instead
    metrics = []
    for row in df.iter_rows(named=True):
        tier = 'Bronze'
        if row['total_spent'] > 10000:
            tier = 'Premium'
        elif row['total_spent'] > 5000:
            tier = 'Gold'
        elif row['total_spent'] > 1000:
            tier = 'Silver'
        
        metrics.append({
            'customer_id': row['customer_id'],
            'tier': tier,
            'avg_transaction': row['total_spent'] / row['transaction_count']
        })
    
    return pl.DataFrame(metrics)
```

---

## 📝 Documentation & Comments
<div align="right"><a href="#top">↑ Back to top</a></div>

### Module Docstring Template (MANDATORY)

**Every Python file MUST have a structured module docstring using this template:**

```python
"""
Brief description of the module's core purpose and role in the layered architecture.

Design Principles:
- [1-6 bullet points on core architectural decisions and principles applied]
- [Explain adherence to layered architecture and separation of concerns]
- [Describe implementation of multithreading, idempotence, or config-driven behavior]
- [Note security, performance, or maintainability design choices]
- [Explain any design patterns or architectural patterns used]

Purpose:
- [1-6 bullet points describing the module's primary role in the BIS system]
- [Explain what specific problem it solves and its position in the layered architecture]
- [Describe how it fits into the overall system workflow and dependencies]
- [Explain architectural significance and why this module exists]

Business Value:
- [1-6 bullet points on tangible benefits to business operations]
- [Quantify efficiency gains, reliability improvements, or cost savings where possible]
- [Describe how it supports business goals and operational excellence]
- [Explain risk mitigation or compliance benefits]

Functional:
- [1-6 bullet points detailing key capabilities and core functions]
- [Describe primary workflows and processing logic at high level]
- [Explain data transformations, calculations, or business rules implemented]
- [Note any specialized algorithms, patterns, or methodologies used]

Usage:
- [1-6 bullet points describing practical usage scenarios and integration examples]
- [Explain how to instantiate and use the module in code]
- [Describe common use cases and workflow integration]
- [Note configuration requirements and setup steps]

Inputs:
- [1-6 bullet points listing primary inputs with types, sources, and validation]
- [Specify data formats, file types, or API endpoints expected]
- [Describe configuration parameters and their validation rules]
- [If no inputs: No specific inputs required for this module]

Outputs:
- [1-6 bullet points listing primary outputs with formats and locations]
- [Describe generated files, data structures, or API responses]
- [Specify output destinations (files, databases, UI updates)]
- [If no outputs: No specific outputs generated by this module]

Dependencies:
- [1-6 bullet points listing key classes, modules, or systems this module interacts with]
- [Describe integration patterns and communication protocols]
- [Note shared data structures or interfaces]
- [Explain dependencies on other BIS components]

Execution Flow:
- [1-6 bullet points describing high-level sequence of operations]
- [Outline the main processing pipeline and key decision points]
- [Describe initialization, configuration, and setup steps]
- [Explain core processing logic and transformation steps]
- [If no execution flow: Module provides utility functions without sequential execution]

Data Processing:
- [1-6 bullet points describing SQL-based data processing operations]
- [Describe external SQL files loaded and executed by this module]
- [Explain data transformations, aggregations, or business logic in SQL]
- [Note database operations, table manipulations, or query patterns]
- [If no SQL processing: No external SQL files processed by this module]

User Interactions:
- [1-6 bullet points describing how users interact with this module's functionality]
- [Describe UI elements, menus, or interface components provided]
- [Explain user commands, actions, or workflow triggers available]
- [If no user interactions: Module operates without direct user interface]

AI Agent Usage:
- [1-6 bullet points explaining how AI agents can utilize this module]
- [Describe code generation opportunities based on docstrings and patterns]
- [Explain debugging assistance available from structured documentation]
- [Note refactoring suggestions that can be derived from design principles]
- [Describe testing strategies that can be automated using module structure]
"""
```

### Class and Method Docstrings (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: This class-level docstring demonstrates the required structured template and initializes dual loggers for observability and testability.*
```python
class TableProcessor:
    """Manages table lifecycle operations including validation and publishing.
    
    Coordinates between data loading, validation rules, and output generation
    while maintaining data integrity and audit trails.
    """
    
    def __init__(self, config: dict):
        """Initialize processor with configuration settings."""
        self.config = config
        self.logger_log = logging.getLogger("TABLE_LOG")
        self.logger_error = logging.getLogger("TABLE_ERROR")
    
    def validate_table(self, table_path: Path, rules: dict = None) -> bool:
        """Validate table data against business rules.
        
        Args:
            table_path: Path to table file for validation
            rules: Optional validation rules dict, uses defaults if None
            
        Returns:
            True if validation passes, False otherwise
            
        Raises:
            ValueError: If table_path is invalid or file not found
        """
        pass
    
    def _internal_helper(self) -> None:
        """Internal helper method for processing logic."""
        pass
```

### Block Comments (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Uses clear block comments to separate stages and improve readability for reviewers and maintainers.*
```python
class DataProcessor:
    def process_pipeline(self):
    # ----------------------- INPUT VALIDATION -----------------------
    # ...existing code...
    # ----------------------- DATA LOADING -----------------------
    # ...existing code...
    # ----------------------- TRANSFORMATION -----------------------
    # ...existing code...
    # ----------------------- OUTPUT GENERATION -----------------------
    # ...existing code...
```

### Inline Comments (ENHANCEMENT)

**✅ Correct Implementation:**
*Reason: Inline comments explain the rationale for branching logic and edge-case handling, improving maintainability.*
```python
def calculate_sla_score(incidents: list, target_resolution_hours: int) -> float:
    """Calculate SLA compliance score based on incident resolution times."""
    
    if not incidents:
        return 100.0  # Perfect score when no incidents
    
    compliant_count = 0
    
    for incident in incidents:
        resolution_time = incident.get('resolution_hours', 0)
        
        # Apply SLA discount for enterprise customers per BR-2023-045
        if incident.get('customer_tier') == 'enterprise':
            effective_target = target_resolution_hours * 0.8
        else:
            effective_target = target_resolution_hours
        
        if resolution_time <= effective_target:
            compliant_count += 1
    
    # Calculate percentage compliance
    compliance_rate = (compliant_count / len(incidents)) * 100
    
    return round(compliance_rate, 2)
```

**❌ Wrong Implementation:**
*Reason: This example uses unclear, procedural looping without early validation and misses fail-fast checks, making it error-prone and hard to maintain.*
```python
def calculate_sla_score(incidents: list, target: int) -> float:
    # Missing validation, verbose comments, no fail-fast
    compliant = 0
    for inc in incidents:
        time = inc.get('resolution_hours', 0)
        if time <= target:
            compliant += 1
    return (compliant / len(incidents)) * 100
```

---

## 🧪 Testing & Validation - Comprehensive Guide
<div align="right"><a href="#top">↑ Back to top</a></div>

> **🔗 See Also**: For business validation frameworks and acceptance criteria patterns, refer to the [Business Analysis Quality Assurance & Validation](best-practices-business-analysis.instructions.md#-quality-assurance--validation) section.

### 🎯 Testing Philosophy for BIS

**Every Python module in BIS MUST have comprehensive test coverage following these principles:**
- **Deterministic**: Tests produce same results every run
- **Isolated**: No dependencies on external systems in unit tests  
- **Realistic**: Integration tests use actual dummy data from `engine/data/`
- **Comprehensive**: Cover constructor, happy path, error path, edge cases
- **Observable**: Validate logs, outputs, and side effects

### 🏗️ Required Test Structure (MANDATORY)

**Every module MUST have at least these test categories:**

```python
# File: engine/tests/test_{module_name}.py
import pytest
import logging
from pathlib import Path
from unittest.mock import patch, MagicMock, call
import duckdb
import yaml

# Module under test
from engine.src.{layer}.{module_name} import {ClassName}

class Test{ClassName}:
    """Comprehensive test suite for {ClassName}."""
    
    # ----------------------- CONSTRUCTOR TESTS -----------------------
    def test_constructor_smoke(self):
        """Test basic instantiation without errors."""
        
    def test_constructor_with_config(self):
        """Test instantiation with various configurations."""
        
    def test_constructor_invalid_config(self):
        """Test constructor handles invalid configurations gracefully."""
    
    # ----------------------- HAPPY PATH TESTS -----------------------
    def test_main_workflow_success(self, tmp_path, caplog):
        """Test successful execution of main workflow."""
        
    def test_data_processing_valid_input(self, tmp_path):
        """Test data processing with valid inputs."""
        
    def test_configuration_loading(self):
        """Test configuration loading and parsing."""
    
    # ----------------------- ERROR PATH TESTS -----------------------
    def test_invalid_input_handling(self, caplog):
        """Test graceful handling of invalid inputs."""
        
    def test_file_not_found_error(self, tmp_path, caplog):
        """Test behavior when required files are missing."""
        
    def test_database_connection_failure(self, monkeypatch, caplog):
        """Test handling of database connection failures."""
    
    # ----------------------- EDGE CASES -----------------------
    def test_empty_data_handling(self):
        """Test behavior with empty datasets."""
        
    def test_large_data_performance(self):
        """Test performance with large datasets."""
        
    def test_concurrent_access(self):
        """Test thread safety and concurrent access."""
    
    # ----------------------- INTEGRATION TESTS -----------------------
    def test_end_to_end_workflow(self, tmp_path):
        """Test complete workflow with realistic data."""
        
    def test_dummy_data_integration(self):
        """Test with actual dummy data from engine/data/."""
```

### 🗂️ Using engine/data Data for Testing

Explanation of required categories:
- Constructor tests: verify objects initialize with defaults, accept valid configs, and reject invalid configs with clear errors.
- Happy path: execute the main workflow end-to-end on valid inputs; assert outputs, side effects, and key log lines.
- Error path: simulate failures (bad input, missing files, DB errors); assert exceptions and error logs are correct.
- Edge cases: cover empty/minimal datasets, large inputs, and concurrency-related behavior for thread safety.
- Integration: wire modules together with dummy data; keep IO mocked or temp-based and assert realistic results.

#### Available Dummy Data Sources
```python
# Standard dummy data files available for testing
DUMMY_DATA_FILES = {
    'sla_metrics': 'engine/data/data/sla_metrics.csv',
    'server_monitoring': 'engine/data/data/server_monitoring.csv', 
    'incident_data': 'engine/data/data/incident_data.csv',
    'customer_surveys': 'engine/data/data/customer_surveys.csv',
    'financial_transactions': 'engine/data/data/financial_transactions.csv',
    'network_traffic': 'engine/data/data/network_traffic.csv',
    'security_incidents': 'engine/data/data/security_incidents.csv'
}

DUMMY_CONFIG_FILES = {
    'tables': 'engine/data/tables.yml',
    'indicators': 'engine/data/indicators.yml',
    'practices': 'engine/data/practices.yml',
    'pipelines': 'engine/data/pipelines.yml',
    'workspaces': 'engine/data/workspaces.yml'
}
```

#### Data-Driven Test Examples

**✅ Correct Implementation:**
*Reason: Uses repository dummy CSV files for realistic, deterministic tests; validates structure and key bounds, and skips gracefully when data is unavailable.*
```python
import polars as pl
import duckdb
from pathlib import Path

class TestDataProcessor:
    """Test data processing with realistic dummy data."""
    
    def test_sla_metrics_processing(self):
        """Test SLA metrics calculation with dummy data."""
        dummy_file = Path('engine/data/data/sla_metrics.csv')
        if not dummy_file.exists():
            pytest.skip("Dummy SLA data not available")
        
        # Test with Polars
        df = pl.read_csv(dummy_file)
        processor = SLAProcessor()
        
        result = processor.calculate_compliance(df)
        
        # Validate key expectations
        assert 'compliance_rate' in result.columns
        assert 0.0 <= result['compliance_rate'].min() <= 100.0
    
    def test_server_monitoring_alerts(self):
        """Test alert generation with server monitoring data."""
        dummy_file = Path('engine/data/data/server_monitoring.csv')
        if not dummy_file.exists():
            pytest.skip("Dummy server data not available")
        
        # Test with DuckDB
        con = duckdb.connect(':memory:')
        con.execute(f"""
            CREATE TABLE servers AS 
            SELECT * FROM read_csv_auto('{dummy_file}')
        """)
        
        alerter = ServerAlerter()
        alerts = alerter.generate_alerts(con)
        
        # Validate alert structure
        assert isinstance(alerts, list)
        for alert in alerts:
            assert {'server_id','alert_type','severity'}.issubset(alert)
            assert alert['severity'] in ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
    
    def test_financial_transactions_analysis(self):
        """Test financial analysis with transaction data."""
        dummy_file = Path('engine/data/data/financial_transactions.csv')
        if not dummy_file.exists():
            pytest.skip("Dummy financial data not available")
        
        analyzer = FinancialAnalyzer()
        
        # Test data loading and validation
        transactions = analyzer.load_transactions(dummy_file)
        assert len(transactions) > 0 and {'amount','transaction_date'}.issubset(transactions.columns)
        
        # Test aggregation logic
        summary = analyzer.monthly_summary(transactions)
        assert {'month','total_amount','transaction_count'}.issubset(summary.columns)
        
        # Validate business logic
        assert all(total >= 0 for total in summary['total_amount'].to_list())
```

**✅ Correct Implementation:**
*Reason: Loads dummy YAML configs to validate schema and wiring; exercises processors without external systems and skips when assets are missing.*
```python
def test_table_configurations():
    """Test table processing with dummy YAML configurations."""
    config_file = Path('engine/data/tables.yml')
    if not config_file.exists():
        pytest.skip("Dummy table config not available")
    
    config = yaml.safe_load(config_file.read_text())
    processor = TableProcessor()
    
    # Test each table configuration
    for table_name, table_config in config.get('tables', {}).items():
        # Validate configuration structure
        assert isinstance(table_name, str)
        assert len(table_name) > 0
        assert 'sql_code' in table_config or 'source_file' in table_config
        
        # Test configuration processing
        result = processor.validate_config(table_config)
        assert result.is_valid
        assert len(result.errors) == 0

def test_indicator_configurations():
    """Test indicator processing with dummy configurations."""
    config_file = Path('engine/data/indicators.yml')
    if not config_file.exists():
        pytest.skip("Dummy indicator config not available")
    
    config = yaml.safe_load(config_file.read_text())
    processor = IndicatorProcessor()
    
    for indicator_name, indicator_config in config.get('indicators', {}).items():
        # Test indicator creation
        indicator = processor.create_indicator(indicator_name, indicator_config)
        assert indicator is not None
        assert indicator.name == indicator_name
        
        # Test indicator calculation with dummy data
        if 'calculation_sql' in indicator_config:
            con = duckdb.connect(':memory:')
            # Load relevant dummy data
            con.execute("CREATE TABLE dummy_metrics AS SELECT 1 as id, 100.0 as value")
            
            result = indicator.calculate(con)
            assert result is not None
            assert isinstance(result, (int, float))
```

### 🔬 Advanced Testing Patterns

#### Parametrized Testing with Dummy Data

**✅ Correct Implementation:**
*Reason: Parametrization reduces duplication and broadens coverage across datasets and configs with concise test code.*
```python
import pytest

class TestDataValidation:
    """Test data validation across multiple dummy datasets."""
    
    @pytest.mark.parametrize("data_file,expected_columns", [
        ("engine/data/data/sla_metrics.csv", ["incident_id", "sla_met", "resolution_time"]),
        ("engine/data/data/server_monitoring.csv", ["server_id", "cpu_usage", "memory_usage"]),
        ("engine/data/data/incident_data.csv", ["incident_id", "priority", "status"]),
        ("engine/data/data/customer_surveys.csv", ["customer_id", "satisfaction_score", "survey_date"])
    ])
    def test_csv_structure_validation(self, data_file, expected_columns):
        """Test that all dummy CSV files have expected structure."""
        file_path = Path(data_file)
        if not file_path.exists():
            pytest.skip(f"Data file {data_file} not available")
        
        df = pl.read_csv(file_path)
        
        # Validate required columns exist
        for col in expected_columns:
            assert col in df.columns, f"Missing column {col} in {data_file}"
        
        # Validate data quality
        assert len(df) > 0, f"Empty dataset in {data_file}"
        assert df.null_count().sum_horizontal()[0] < len(df) * 0.5, f"Too many nulls in {data_file}"
    
    @pytest.mark.parametrize("config_file,required_keys", [
        ("engine/data/tables.yml", ["tables"]),
        ("engine/data/indicators.yml", ["indicators"]),
        ("engine/data/practices.yml", ["practices"]),
        ("engine/data/workspaces.yml", ["workspaces"])
    ])
    def test_yaml_config_structure(self, config_file, required_keys):
        """Test that all dummy YAML configs have expected structure."""
        file_path = Path(config_file)
        if not file_path.exists():
            pytest.skip(f"Config file {config_file} not available")
        
        config = yaml.safe_load(file_path.read_text())
        
        for key in required_keys:
            assert key in config, f"Missing key {key} in {config_file}"
            assert isinstance(config[key], dict), f"Key {key} should be dict in {config_file}"
            assert len(config[key]) > 0, f"Empty config for {key} in {config_file}"
```

#### Performance Testing with Dummy Data

**✅ Correct Implementation:**
*Reason: Measures runtime characteristics against pragmatic thresholds using locally available dummy data; keeps tests deterministic and fast.*
```python
import time
from concurrent.futures import ThreadPoolExecutor

class TestPerformance:
    """Performance tests using dummy data."""
    
    def test_large_dataset_processing_time(self):
        """Test processing time with large dummy datasets."""
        # Combine multiple dummy files to create larger dataset
        dummy_files = [
            'engine/data/data/server_monitoring.csv',
            'engine/data/data/network_traffic.csv',
            'engine/data/data/security_incidents.csv'
        ]
        
        available_files = [f for f in dummy_files if Path(f).exists()]
        if not available_files:
            pytest.skip("No dummy data files available for performance testing")
        
        processor = DataProcessor()
        
        t0 = time.time()
        for file_path in available_files:
            processor.process_file(Path(file_path))
        processing_time = time.time() - t0
        
        # Keep thresholds pragmatic and adjustable
        assert processing_time < 30.0, f"Processing took too long: {processing_time:.2f}s"
    
    def test_concurrent_processing(self):
        """Test concurrent processing with dummy data."""
        dummy_files = [
            Path('engine/data/data/sla_metrics.csv'),
            Path('engine/data/data/incident_data.csv'),
            Path('engine/data/data/customer_surveys.csv')
        ]
        
        available_files = [f for f in dummy_files if f.exists()]
        if len(available_files) < 2:
            pytest.skip("Need at least 2 dummy files for concurrency testing")
        
        processor = DataProcessor()
        
        def process_file(file_path):
            return processor.process_file(file_path)
        
        start_time = time.time()
        
        # Test concurrent processing
        with ThreadPoolExecutor(max_workers=3) as executor:
            futures = [executor.submit(process_file, f) for f in available_files]
            results = [future.result() for future in futures]
        
        concurrent_time = time.time() - start_time
        
        # Test sequential processing
        start_time = time.time()
        sequential_results = [process_file(f) for f in available_files]
        sequential_time = time.time() - start_time
        
        # Verify concurrency benefits (should be faster or similar)
        assert concurrent_time <= sequential_time * 1.2
        assert len(results) == len(sequential_results)
```

### 🧑‍💻 Software Tester Guidelines

#### Test Planning & Strategy

**✅ Correct Implementation:**
*Reason: Provides a concise, reusable template that aligns to BIS-required categories and helps plan complete coverage.*
```python
"""
Test Case Template for BIS Python Modules

TEST CATEGORIES (All modules must have):
1. Constructor Tests
   - Valid instantiation
   - Invalid configuration handling
   - Default parameter validation

2. Happy Path Tests  
   - Normal workflow execution
   - Valid input processing
   - Expected output generation

3. Error Path Tests
   - Invalid input handling
   - External system failures
   - Resource unavailability

4. Edge Cases
   - Empty data handling
   - Boundary value testing
   - Large dataset performance

5. Integration Tests
   - Module interaction testing
   - Dummy data workflow validation
   - End-to-end scenario testing

6. Observability Tests
   - Log message validation
   - Error reporting verification
   - Performance metric collection
"""

class TestCaseGenerator:
    """Helper class for generating comprehensive test cases."""
    
    @staticmethod
    def generate_test_matrix(module_name: str, module_functions: list) -> dict:
        """Generate comprehensive test matrix for a module."""
        test_matrix = {
            'module': module_name,
            'test_categories': {}
        }
        
        for function in module_functions:
            test_matrix['test_categories'][function] = {
                'constructor': ['valid_config', 'invalid_config', 'missing_config'],
                'happy_path': ['valid_input', 'typical_workflow', 'expected_output'],
                'error_path': ['invalid_input', 'system_failure', 'resource_error'],
                'edge_cases': ['empty_data', 'large_data', 'boundary_values'],
                'integration': ['module_interaction', 'dummy_data', 'end_to_end']
            }
        
        return test_matrix
```

#### Test Data Management

**✅ Correct Implementation:**
*Reason: Centralizes discovery and lightweight validation of dummy datasets, enabling repeatable fixtures and scenarios.*
```python
class DummyDataManager:
    """Centralized management of dummy data for testing."""
    
    def __init__(self):
        self.base_path = Path('engine/data')
        self.data_path = self.base_path / 'data'
        self.config_path = self.base_path
    
    def get_available_datasets(self) -> dict:
        """Get all available dummy datasets with metadata."""
        datasets = {}
        
        if self.data_path.exists():
            for csv_file in self.data_path.glob('*.csv'):
                try:
                    df = pl.read_csv(csv_file, n_rows=5)  # Sample for metadata
                    datasets[csv_file.stem] = {
                        'file_path': csv_file,
                        'columns': df.columns,
                        'sample_data': df.to_dict(),
                        'row_count': self._get_row_count(csv_file)
                    }
                except Exception as e:
                    datasets[csv_file.stem] = {'error': str(e)}
        
        return datasets
    
    def get_test_scenarios(self, dataset_name: str) -> list:
        """Generate test scenarios for a specific dataset."""
        if dataset_name == 'sla_metrics':
            return [
                {'name': 'compliance_calculation', 'focus': 'sla_met column'},
                {'name': 'resolution_time_analysis', 'focus': 'resolution_time column'},
                {'name': 'incident_categorization', 'focus': 'incident_type grouping'}
            ]
        elif dataset_name == 'server_monitoring':
            return [
                {'name': 'cpu_threshold_alerts', 'focus': 'cpu_usage > 80%'},
                {'name': 'memory_usage_trends', 'focus': 'memory_usage over time'},
                {'name': 'server_health_scoring', 'focus': 'overall health metrics'}
            ]
        elif dataset_name == 'financial_transactions':
            return [
                {'name': 'fraud_detection', 'focus': 'anomalous transaction patterns'},
                {'name': 'monthly_summaries', 'focus': 'aggregation by time period'},
                {'name': 'customer_spending_analysis', 'focus': 'per-customer metrics'}
            ]
        
        return [{'name': 'generic_processing', 'focus': 'basic data validation'}]
    
    def create_test_fixture(self, dataset_name: str, scenario: str) -> str:
        """Generate pytest fixture code for specific test scenario."""
        return f"""
@pytest.fixture
def {dataset_name}_{scenario}_data():
    \"\"\"Fixture providing {dataset_name} data for {scenario} testing.\"\"\"
    file_path = Path('engine/data/data/{dataset_name}.csv')
    if not file_path.exists():
        pytest.skip(f"Dummy data file {{file_path}} not available")
    
    df = pl.read_csv(file_path)
    
    # Validate data structure for {scenario}
    required_columns = {self._get_required_columns(dataset_name, scenario)}
    for col in required_columns:
        assert col in df.columns, f"Missing required column {{col}}"
    
    return df
"""
```

#### Test Quality Assurance

**✅ Correct Implementation:**
*Reason: Automated validation of test modules to catch missing categories and common quality gaps early.*
```python
class TestQualityValidator:
    """Validates test quality and completeness."""
    
    def validate_test_module(self, test_file_path: Path) -> dict:
        """Validate a test module against BIS standards."""
        validation_result = {
            'file': str(test_file_path),
            'issues': [],
            'score': 0,
            'categories_covered': []
        }
        
        if not test_file_path.exists():
            validation_result['issues'].append("Test file does not exist")
            return validation_result
        
        test_content = test_file_path.read_text()
        
        # Check required test categories
        required_patterns = {
            'constructor_test': r'def test_.*constructor.*\(',
            'happy_path_test': r'def test_.*(?:success|happy|valid).*\(',
            'error_path_test': r'def test_.*(?:error|invalid|fail).*\(',
            'caplog_usage': r'caplog\.',
            'monkeypatch_usage': r'monkeypatch\.',
            'dummy_data_usage': r'engine/data/',
            'tmp_path_usage': r'tmp_path'
        }
        
        for category, pattern in required_patterns.items():
            if re.search(pattern, test_content, re.IGNORECASE):
                validation_result['categories_covered'].append(category)
            else:
                validation_result['issues'].append(f"Missing {category}")
        
        # Calculate quality score
        validation_result['score'] = (
            len(validation_result['categories_covered']) / 
            len(required_patterns) * 100
        )
        
        return validation_result
    
    def generate_missing_tests(self, module_path: Path) -> str:
        """Generate template for missing test cases."""
        module_name = module_path.stem
        
        return f"""
# Generated test templates for {module_name}
# Add these test methods to your test class:

def test_{module_name}_constructor_smoke(self):
    \"\"\"Test basic instantiation.\"\"\"
    obj = {module_name.title()}()
    assert obj is not None

def test_{module_name}_happy_path(self, tmp_path, caplog):
    \"\"\"Test successful operation.\"\"\"
    caplog.set_level(logging.INFO)
    obj = {module_name.title()}()
    result = obj.main_operation()
    assert result is not None
    assert "completed" in caplog.text.lower()

def test_{module_name}_error_handling(self, monkeypatch, caplog):
    \"\"\"Test error handling.\"\"\"
    def mock_failure(*args, **kwargs):
        raise ValueError("Simulated error")
    
    monkeypatch.setattr({module_name.title()}, 'dependency_method', mock_failure)
    
    obj = {module_name.title()}()
    with pytest.raises(ValueError):
        obj.main_operation()

def test_{module_name}_with_dummy_data(self):
    \"\"\"Test with realistic dummy data.\"\"\"
    dummy_file = Path('engine/data/data/relevant_data.csv')
    if not dummy_file.exists():
        pytest.skip("Dummy data not available")
    
    obj = {module_name.title()}()
    result = obj.process_data(dummy_file)
    assert result is not None
"""
```

### Integration Testing with Mocks (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: The integration test mocks external systems and verifies end-to-end behavior while keeping IO isolated for determinism.*
```python
def test_data_pipeline_integration(monkeypatch, caplog, tmp_path):
    """Test integration between loader, processor, and output modules."""
    
    # Mock external dependencies
    mock_database = MagicMock()
    mock_database.execute.return_value.fetchall.return_value = [
        (1, 'Product A', 100.0),
        (2, 'Product B', 200.0)
    ]
    
    monkeypatch.setattr('duckdb.connect', lambda: mock_database)
    
    # Mock file system operations
    def mock_write_file(path, content):
        test_output = tmp_path / "output.csv"
        test_output.write_text(content)
        return test_output
    
    monkeypatch.setattr('engine.src.low.file_writer.write_csv', mock_write_file)
    
    # Test the integration
    from engine.src.high.data_pipeline import DataPipeline
    
    pipeline = DataPipeline({'output_dir': str(tmp_path)})
    result = pipeline.run()
    
    # Verify integration points
    assert result is True
    assert mock_database.execute.called
    assert (tmp_path / "output.csv").exists()
    assert "Pipeline completed" in caplog.text
```

### Using Dummy Data for Tests (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Demonstrates using repository dummy data for realistic integration tests while skipping when data is absent.*
```python
import duckdb
import yaml
from pathlib import Path

def test_sql_processing_with_dummy_data():
    """Test SQL processing using realistic dummy data."""
    
    # Use actual dummy data from the repository
    dummy_data_path = Path("engine/data/data/sla_metrics.csv")
    if not dummy_data_path.exists():
        pytest.skip("Dummy data not available")
    
    # Create in-memory database with dummy data
    con = duckdb.connect(':memory:')
    con.execute(f"""
        CREATE TABLE sla_metrics AS 
        SELECT * FROM read_csv_auto('{dummy_data_path}')
    """)
    
    # Test the actual SQL logic
    result = con.execute("""
        SELECT 
            COUNT(*) as total_incidents,
            AVG(CASE WHEN sla_met = 'Yes' THEN 1.0 ELSE 0.0 END) as compliance_rate
        FROM sla_metrics
    """).fetchone()
    
    # Verify realistic results
    assert result[0] > 0  # Should have incidents
    assert 0.0 <= result[1] <= 1.0  # Compliance rate should be between 0-100%

def test_yaml_config_processing():
    """Test YAML configuration processing with dummy configs."""
    
    dummy_config_path = Path("engine/data/tables.yml")
    if not dummy_config_path.exists():
        pytest.skip("Dummy config not available")
    
    # Load and validate dummy configuration
    config = yaml.safe_load(dummy_config_path.read_text())
    
    # Test configuration structure
    assert 'tables' in config
    for table_name, table_config in config['tables'].items():
        assert 'sql_code' in table_config or 'source_file' in table_config
        assert isinstance(table_name, str)
        assert len(table_name) > 0
```

### Logging Validation with caplog (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Validates logging behavior and ensures errors are captured by the dual logger pattern for observability.*
```python
def test_error_logging(caplog):
    """Test that errors are logged correctly with dual logger pattern."""
    
    processor = TableProcessor({'timeout': 1})
    
    # Set up logging capture
    caplog.set_level(logging.INFO)
    
    # Trigger an error condition
    with pytest.raises(FileNotFoundError):
        processor.process_table(Path("nonexistent.csv"))
    
    # Verify logging behavior
    log_messages = [record.message for record in caplog.records]
    error_messages = [record.message for record in caplog.records if record.levelname == 'ERROR']
    
    assert any("File not found" in msg for msg in log_messages)
    assert len(error_messages) > 0
    
    # Verify logger names are correct
    logger_names = [record.name for record in caplog.records]
    assert "TABLE_LOG" in logger_names or "TABLE_ERROR" in logger_names
```

---

## 📦 Import Management
<div align="right"><a href="#top">↑ Back to top</a></div>

### Import Organization (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: Groups and orders imports clearly (stdlib, third-party, local) for readability and reduces merge conflicts.*
```python
# Standard library imports
import logging
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Union
from datetime import datetime, timedelta

# Third-party imports
import duckdb
import polars as pl
import yaml
from PySide6.QtCore import QTimer, QThreadPool
from PySide6.QtWidgets import QWidget, QPushButton

# Local application imports
from engine.src.high.indicator import TIndicator
from engine.src.low.table import TableManager
from engine.src.model.world import World
```

### Type Hints (ENHANCEMENT)

**✅ Correct Implementation:**
*Reason: Uses explicit type hints and callable signatures to improve static analysis and testability.*
```python
from typing import Dict, List, Optional, Union, Callable
from pathlib import Path

def process_data_files(
    file_paths: List[Path], 
    processor: Callable[[Path], Dict[str, Union[str, int]]], 
    config: Optional[Dict[str, any]] = None
) -> List[Dict[str, Union[str, int]]]:
    """Process multiple data files with type safety."""
    
    config = config or {}
    results = []
    
    for file_path in file_paths:
        if file_path.exists():
            result = processor(file_path)
            results.append(result)
    
    return results
```

### Avoiding Circular Imports (CONTEXTUAL)

**✅ Correct Implementation:**
*Reason: This approach resolves circular imports by importing classes within methods at the point of use, rather than at module level. This breaks the circular dependency chain while maintaining type safety and avoiding import-time issues.*
```python
# Method 1: Import within method when actually needed
def process_indicator_data(indicator_config: dict) -> bool:
    """Process indicator data with lazy import to avoid circular dependencies."""
    # Import only when needed, not at module level
    from engine.src.high.indicator import TIndicator
    
    indicator = TIndicator(indicator_config)
    return indicator.process()

# Method 2: Use string-based type hints for type checking only
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from engine.src.high.indicator import TIndicator

def process_indicator(indicator: 'TIndicator') -> bool:
    """Process indicator with forward reference - no runtime import."""
    # Import within method for actual usage
    from engine.src.high.indicator import TIndicator
    if not isinstance(indicator, TIndicator):
        raise ValueError("Invalid indicator type")
    return indicator.validate_and_process()
```

**❌ Wrong Implementation:**
*Reason: Module-level imports create circular dependencies that can cause import failures and unpredictable behavior. Using a "class_name" string method approach is fragile and bypasses type safety.*
```python
# WRONG: Module-level imports that create circular dependencies
from engine.src.high.indicator import TIndicator  # This causes circular import
from engine.src.low.table import TableManager    # Another circular import

def unsafe_approach(indicator_class_name: str) -> bool:
    """WRONG: Using string class names is error-prone and breaks type safety."""
    # WRONG: String-based class resolution is fragile and hard to maintain
    if indicator_class_name == "TIndicator":
        # This bypasses type checking and is prone to typos/errors
        return True
    return False
```

---

## ✅ Quick Validation Checklist
<div align="right"><a href="#top">↑ Back to top</a></div>

**Before committing any Python code, verify:**

### Architecture & Design ✅
- [ ] Layered architecture respected (UI → Orchestration → Computation)
- [ ] No heavy processing in UI layer
- [ ] Orchestration layer is thin and delegates to workers
- [ ] Operations are idempotent (safe to retry)
- [ ] Behavior is config-driven via YAML

### Code Structure ✅
- [ ] Early returns used for validation
- [ ] No mutable defaults in function signatures
- [ ] Line length ≤ 120 characters
- [ ] `pathlib` used for all path operations
- [ ] Context managers used for file/resource handling

### Logging & Error Handling ✅
- [ ] Dual logger pattern implemented (summary + error logs)
- [ ] Existing logger names used (no new logger creation)
- [ ] Parameterized logging (no f-strings in log statements)
- [ ] Loop failures are isolated (don't crash entire batch)
- [ ] Specific exceptions caught (avoid bare `except:`)

### Security ✅
- [ ] Input validation and sanitization implemented
- [ ] SQL queries use parameterized statements
- [ ] No secrets in code or logs
- [ ] Path traversal protection in place
- [ ] User inputs are validated and sanitized

### UI (if applicable) ✅
- [ ] Heavy operations run in background threads
- [ ] UI updates use QTimer or signals
- [ ] Tab refresh pattern for lazy loading
- [ ] Proper signal/slot connections
- [ ] Resource cleanup in closeEvent

### Data Processing ✅
- [ ] SQL-first approach for heavy transformations
- [ ] Temporary tables for intermediate steps
- [ ] COPY operations include proper metadata
- [ ] Cursor re-queried after fetchone() checks
- [ ] DataFrame operations are vectorized

### Documentation ✅
- [ ] Module docstring follows structured template
- [ ] Class docstrings are concise (1-3 sentences)
- [ ] Method docstrings include Args/Returns for public methods
- [ ] Inline comments explain "why" not "what"
- [ ] Block comments used for major sections

### Testing ✅
- [ ] Constructor smoke test exists
- [ ] Happy path test exists
- [ ] Error path test exists
- [ ] External dependencies are mocked
- [ ] Log output is validated with caplog

### AI Agent Compliance ✅
- [ ] Temporary files go to `temp/PYTHON_DEVELOPER/`
- [ ] Enforcement actions are logged
- [ ] Existing logger names are reused
- [ ] Practices are applied when requested

---

## 🛠️ Development Workflow
<div align="right"><a href="#top">↑ Back to top</a></div>

### Setting Up Development Environment

```bash
# Create virtual environment
python -m venv bis_venv
source bis_venv/bin/activate  # Linux/Mac
# or
bis_venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Verify critical dependencies
python -c "import duckdb, polars, PySide6; print('All dependencies OK')"
```

### Pre-commit Validation

```bash
# Format code
black --line-length 120 engine/src/

# Lint code
flake8 engine/src/ --max-line-length=120

# Run tests
pytest engine/tests/ -v

# Validate dummy data
python tools/validate_dummy.py

# Validate the Best Practices Guide structure (Reasons, ToC, Back-to-top)
python tools/validate_best_practices_guide.py
```

### AI Agent Enforcement Examples

This section intentionally avoids embedding change logs. Agents should follow the Enforcement Actions & Logging format when needed, but do not store enforcement logs inside this guide.

---

## 🎯 Practice Priority Matrix
<div align="right"><a href="#top">↑ Back to top</a></div>

### For AI Agents: Practice Application Priority

| Priority Level | When to Apply | Practice Categories | User Triggers |
|----------------|---------------|-------------------|---------------|
| **🔴 CRITICAL** | Always apply | Security, Architecture, Logging | Any code modification |
| **🟡 HIGH** | Apply when relevant | Error handling, File operations | Context-specific work |
| **🟢 MEDIUM** | Apply when improving | Documentation, Testing | Code quality requests |
| **🔵 LOW** | Apply when requested | Code formatting, Type hints | Explicit user requests |

### Practice Application Matrix

```yaml
file_types:
  gui_modules:
    mandatory: [dual_logger_pattern, non_blocking_ui, signal_connections]
    contextual: [tab_refresh, qtimer_updates, resource_cleanup]
    enhancement: [comprehensive_docstrings, performance_optimization]
  
  data_processing:
    mandatory: [sql_parameterization, input_validation, atomic_writes]
    contextual: [sql_first_approach, temp_tables, vectorized_ops]
    enhancement: [performance_tests, memory_optimization]
  
  low_level_modules:
    mandatory: [exception_handling, pathlib_usage, config_driven]
    contextual: [pure_functions, dependency_injection]
    enhancement: [comprehensive_tests, documentation]

user_prompts:
  "make production ready":
    apply: [all_mandatory, all_security, comprehensive_tests]
    rewrite_level: complete
  
  "improve code quality":
    apply: [contextual_practices, documentation, testing]
    rewrite_level: selective
  
  "add error handling":
    apply: [exception_handling, logging, input_validation]
    rewrite_level: targeted
```

---

## 🔍 Troubleshooting Common Issues
<div align="right"><a href="#top">↑ Back to top</a></div>

### Agent Decision-Making Problems

**❌ Problem: Agent doesn't know which practices to apply**
```text
User says: "make this better"
Agent response: "I'm not sure which practices to apply"
```

**✅ Solution: Use context clues and default to mandatory practices**
*Reason: Gives agents a deterministic fallback when scope is vague, ensuring mandatory safeguards are always applied.*
```python
# Agent logic
def determine_practices(user_prompt, file_context):
    practices = MANDATORY_PRACTICES.copy()
    
    if "better" in user_prompt.lower():
        practices.extend(ENHANCEMENT_PRACTICES)
    
    if "gui" in file_context or "qt" in file_context:
        practices.extend(UI_PRACTICES)
    
    return practices
```

**❌ Problem: Agent applies wrong rewrite level**
```text
User says: "fix the logging" 
Agent response: Rewrites entire file instead of just logging
```

**✅ Solution: Match rewrite level to request scope**
*Reason: Prevents over-rewrites; limits change surface to user intent and reduces regression risk.*
```python
# Agent logic
def determine_rewrite_level(user_prompt):
    complete_triggers = ["all", "force", "rewrite", "from scratch", "production ready"]
    targeted_triggers = ["fix", "add", "update", "improve"]
    
    if any(trigger in user_prompt.lower() for trigger in complete_triggers):
        return "complete_rewrite"
    elif any(trigger in user_prompt.lower() for trigger in targeted_triggers):
        return "targeted_update"
    else:
        return "selective_update"
```

### Testing Implementation Issues

**❌ Problem: Tests don't use dummy data effectively**
```python
def test_processor():
    # Creates fake data instead of using dummy data
    data = [{"id": 1, "value": 100}]
    processor.process(data)
```

**✅ Solution: Always prefer realistic dummy data**
*Reason: Increases test fidelity and catches real-world edge cases without relying on external systems.*
```python
def test_processor():
    dummy_file = Path('engine/data/data/relevant_data.csv')
    if not dummy_file.exists():
        pytest.skip("Dummy data not available")
    
    df = pl.read_csv(dummy_file)
    result = processor.process(df)
    
    # Validate with realistic expectations
    assert len(result) > 0
    assert all(isinstance(row, dict) for row in result)
```

**❌ Problem: Tests don't validate logging**
```python
def test_function():
    result = my_function()
    assert result == expected
    # Missing: No log validation
```

**✅ Solution: Always validate logs with caplog**
*Reason: Ensures observability contracts are verified, not just functional outputs.*
```python
def test_function(caplog):
    caplog.set_level(logging.INFO)
    result = my_function()
    
    assert result == expected
    assert "Processing started" in caplog.text
    assert "Processing completed" in caplog.text
```

### Documentation Problems

**❌ Problem: Module docstrings are inconsistent**
```python
"""
This module does data processing.
Created by: John Doe
Last updated: 2025-09-01
"""
```

**✅ Solution: Use structured template always**
*Reason: Standardized docstrings enable automation, easier reviews, and consistent agent behavior.*
```python
"""
Processes customer data for business intelligence reporting and analysis.

Design Principles:
- SQL-first approach for heavy data transformations
- Idempotent operations with atomic file writes
- Config-driven behavior through YAML configuration
- Secure input validation and sanitization

Purpose:
- Transform raw customer data into analytical datasets
- Generate standardized reports for business stakeholders
- Ensure data quality and consistency across processing pipeline
- Provide audit trail for all data transformations

[... rest of structured template ...]
"""
```

### Performance and Quality Issues

**❌ Problem: Code doesn't follow layered architecture**
```python
# GUI class doing SQL and file operations
class DataTab(QWidget):
    def load_data(self):
        con = duckdb.connect()
        data = con.execute("SELECT * FROM huge_table").fetchall()
        self.table_widget.setData(data)  # UI freezes
```

**✅ Solution: Delegate to appropriate layers**
*Reason: Preserves UI responsiveness and enforces separation of concerns.*
```python
class DataTab(QWidget):
    def load_data(self):
        # Delegate to orchestration layer
        worker = Worker(lambda: DataOrchestrator().load_data())
        worker.signals.finished.connect(self._on_data_loaded)
        self.threadpool.start(worker)
    
    def _on_data_loaded(self, data):
        QTimer.singleShot(0, lambda: self.table_widget.setData(data))
```

**❌ Problem: Security vulnerabilities in SQL**
```python
def get_user_data(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return connection.execute(query).fetchall()
```

**✅ Solution: Always parameterize queries**
*Reason: Eliminates injection risks and improves query plan stability.*
```python
def get_user_data(user_id: int) -> list:
    # Validate input
    if not isinstance(user_id, int) or user_id <= 0:
        raise ValueError("Invalid user ID")
    
    # Parameterized query
    query = "SELECT * FROM users WHERE id = ?"
    return connection.execute(query, [user_id]).fetchall()
```

### Agent Logging and Compliance

**❌ Problem: Agent creates new logger names**
```text
Agent applies practices but provides no log of what was changed
```

**✅ Solution: Agent must always log enforcement**
*Reason: Provides traceability of automated changes while keeping logs out of this guide.*
```text
[ENFORCEMENT LOG - 2025-09-01 15:30:22]
========================================
Trigger: "improve error handling"
Action Level: targeted_update
Scope: process_data() function

Changes Made:
✅ exception_handling: Added specific ValueError and IOError handling
✅ loop_isolation: Wrapped item processing in individual try-catch blocks
✅ logging: Added error logging with dual logger pattern

Impact: Medium - Improved error resilience and observability
```

---

## 🎯 Final Note for AI Agents
<div align="right"><a href="#top">↑ Back to top</a></div>

This guide is the single source of truth for Python development in BIS. When in doubt:
1. Apply mandatory practices first
2. Use context to select relevant practices
3. Prefer realistic dummy data for tests
4. Follow the structured templates exactly
5. Keep examples minimal and focused



