# Python Best Practices & Guidelines for AI Agents - BIS Repository

<a id="top"></a>

**Target Audience:** AI Agents, BIS developers, and contributors working with Python code
**Scope:** All Python modules in BIS repository (`engine/src/`, `tools/`, tests)
**Apply to:** `**/*.py` files

---

## 📋 Comprehensive Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Core Principles](#-core-principles)
- [🏗️ Design Patterns](#️-design-patterns)
- [📚 Key Terms](#-key-terms)
- [🔗 Industry References](#-industry-references)
- [📂 Practice Categories](#-practice-categories)
  - [Architecture & Design](#architecture--design)
    - [✅ Layered Architecture](#layered-architecture)
    - [❌ Mixing Heavy Processing in UI](#mixing-heavy-processing-in-ui)
    - [✅ Idempotent Operations](#idempotent-operations)
    - [✅ Config-Driven Behavior](#config-driven-behavior)
    - [✅ Multithreading for UI Responsiveness](#multithreading-for-ui-responsiveness)
  - [Code Structure & Quality](#code-structure--quality)
    - [✅ Early Returns & Validation](#early-returns--validation)
    - [❌ Mutable Defaults](#mutable-defaults)
    - [✅ Pure Functions & Dependency Injection](#pure-functions--dependency-injection)
    - [✅ Line Length & Formatting](#line-length--formatting)
    - [✅ Avoiding Circular Imports](#avoiding-circular-imports)
  - [Path Handling & File Operations](#path-handling--file-operations)
    - [✅ Use Pathlib](#use-pathlib)
    - [❌ Using os.path](#using-os.path)
    - [✅ Atomic File Operations](#atomic-file-operations)
    - [✅ OS-Specific Operations](#os-specific-operations)
    - [✅ Sibling File Operations](#sibling-file-operations)
  - [UI Best Practices](#ui-best-practices)
    - [✅ Non-Blocking UI](#non-blocking-ui)
    - [✅ Dual Logger Pattern](#dual-logger-pattern)
    - [✅ Tab Refresh Pattern](#tab-refresh-pattern)
    - [✅ Signal/Slot Connections](#signalslot-connections)
  - [File Processing & I/O](#file-processing--io)
    - [✅ Defensive YAML Access](#defensive-yaml-access)
    - [❌ Direct YAML Access](#direct-yaml-access)
    - [✅ Buffered File Reading](#buffered-file-reading)
    - [✅ Path Sanitization](#path-sanitization)
  - [Exception Handling & Logging](#exception-handling--logging)
    - [✅ Loop Isolation](#loop-isolation)
    - [✅ Parameterized Logging](#parameterized-logging)
    - [❌ f-strings in Logging](#f-strings-in-logging)
    - [✅ Logger Names Policy](#logger-names-policy)
    - [✅ Temporary File Policy](#temporary-file-policy)
  - [Security Best Practices](#security-best-practices)
    - [✅ Input Validation & Sanitization](#input-validation--sanitization)
    - [✅ SQL Injection Prevention](#sql-injection-prevention)
    - [❌ String Formatting for SQL](#string-formatting-for-sql)
    - [✅ Secrets Management](#secrets-management)
    - [❌ Hardcoded Secrets](#hardcoded-secrets)
  - [DuckDB Data Processing](#duckdb-data-processing)
    - [✅ SQL-First Approach](#sql-first-approach)
    - [✅ Parameterized Queries](#parameterized-queries)
    - [✅ Cursor Management](#cursor-management)
    - [✅ Temporary Tables Strategy](#temporary-tables-strategy)
  - [DataFrame Operations](#dataframe-operations)
    - [✅ Memory-Efficient DataFrames](#memory-efficient-dataframes)
    - [✅ Vectorized Operations](#vectorized-operations)
    - [❌ Row-by-row Processing](#row-by-row-processing)
  - [Documentation & Comments](#documentation--comments)
    - [✅ Module Docstring Template](#module-docstring-template)
    - [✅ Class and Method Docstrings](#class-and-method-docstrings)
    - [✅ Block Comments](#block-comments)
    - [✅ Inline Comments](#inline-comments)
  - [Testing & Validation](#testing--validation)
    - [✅ Testing Philosophy for BIS](#testing-philosophy-for-bis)
    - [✅ Required Test Structure](#required-test-structure)
    - [✅ Using Engine/Data for Testing](#using-engine-data-for-testing)
    - [✅ Advanced Testing Patterns](#advanced-testing-patterns)
    - [✅ Software Tester Guidelines](#software-tester-guidelines)
    - [✅ Integration Testing with Mocks](#integration-testing-with-mocks)
    - [✅ Logging Validation with caplog](#logging-validation-with-caplog)
  - [Import Management](#import-management)
    - [✅ Import Organization](#import-organization)
    - [✅ Type Hints](#type-hints)
  - [Development Workflow](#development-workflow)
    - [✅ Setting Up Development Environment](#setting-up-development-environment)
    - [✅ Pre-commit Validation](#pre-commit-validation)
    - [✅ AI Agent Enforcement Examples](#ai-agent-enforcement-examples)
  - [Quality Assurance](#quality-assurance)
    - [✅ Quick Validation Checklist](#quick-validation-checklist)
    - [✅ Practice Priority Matrix](#practice-priority-matrix)
    - [✅ Troubleshooting Common Issues](#troubleshooting-common-issues)
    - [✅ Final Note for AI Agents](#final-note-for-ai-agents)

---

## 🎯 Core Principles

- **Layered Architecture**: A design pattern where the application is divided into UI, orchestration, and computation layers with strict separation of concerns to ensure responsiveness and maintainability.
- **Idempotence**: The property that operations can be repeated without causing errors or state corruption, ensuring reliable and predictable behavior.
- **Parameterized Queries**: SQL queries that use placeholders for dynamic values to prevent SQL injection attacks and ensure query correctness.
- **Atomic Operations**: File operations that are guaranteed to either complete fully or not at all, preventing corruption from partial writes or interruptions.
- **Dual Logger Pattern**: A logging approach using two existing loggers—one for high-level summaries and one for detailed errors—to provide clear separation of operational logs and error diagnostics.
- **Config-Driven Behavior**: An approach where application behavior is controlled by external YAML configuration files rather than hard-coded values, enabling flexibility and maintainability.
- **Thread-Safe Operations**: Operations that can be safely executed in multi-threaded environments without causing race conditions or data corruption.
- **Path Sanitization**: The process of validating and normalizing file paths to prevent path traversal attacks and ensure consistent cross-platform behavior.
- **Input Validation**: The process of checking user inputs for correctness, type safety, and security before processing to prevent injection attacks and runtime errors.
- **Defensive Programming**: Writing code that anticipates and handles potential errors gracefully, including malformed inputs, missing resources, and unexpected conditions.

---

## 🏗️ Design Patterns

- **Observer Pattern**: Used in Qt/PySide signal-slot connections for decoupled communication between UI components.
- **Factory Pattern**: Applied in object creation with dependency injection for testability and flexibility.
- **Strategy Pattern**: Used in calculator functions and data processing algorithms for interchangeable implementations.
- **Template Method Pattern**: Applied in processing pipelines with customizable steps while maintaining consistent structure.
- **Command Pattern**: Used in background task execution with QThreadPool for asynchronous operations.
- **Repository Pattern**: Applied in data access layers for consistent database operations and testability.

---

## 📚 Key Terms

- **Layered Architecture**: A design pattern where the application is divided into UI, orchestration, and computation layers with strict separation of concerns to ensure responsiveness and maintainability.
- **Idempotence**: The property that operations can be repeated without causing errors or state corruption, ensuring reliable and predictable behavior.
- **Parameterized Queries**: SQL queries that use placeholders for dynamic values to prevent SQL injection attacks and ensure query correctness.
- **Atomic Operations**: File operations that are guaranteed to either complete fully or not at all, preventing corruption from partial writes or interruptions.
- **Dual Logger Pattern**: A logging approach using two existing loggers—one for high-level summaries and one for detailed errors—to provide clear separation of operational logs and error diagnostics.
- **Config-Driven Behavior**: An approach where application behavior is controlled by external YAML configuration files rather than hard-coded values, enabling flexibility and maintainability.
- **Thread-Safe Operations**: Operations that can be safely executed in multi-threaded environments without causing race conditions or data corruption.
- **Path Sanitization**: The process of validating and normalizing file paths to prevent path traversal attacks and ensure consistent cross-platform behavior.
- **Input Validation**: The process of checking user inputs for correctness, type safety, and security before processing to prevent injection attacks and runtime errors.
- **Defensive Programming**: Writing code that anticipates and handles potential errors gracefully, including malformed inputs, missing resources, and unexpected conditions.
- **Test-Driven Development**: A development approach where tests are written before code implementation to ensure requirements are met and regressions are caught early.
- **Continuous Integration**: Automated testing and validation of code changes to ensure quality and prevent integration issues.
- **Code Coverage**: A metric measuring the percentage of code executed by automated tests to ensure comprehensive validation.

---

## 🔗 Industry References

- **Python Enhancement Proposals (PEPs)**: Official Python standards and best practices, particularly PEP 8 for style guidelines and PEP 484 for type hints, providing authoritative guidance for Python development.
- **OWASP Security Guidelines**: Industry-standard security practices for web applications and data processing, offering comprehensive guidance on preventing common security vulnerabilities.
- **DuckDB Documentation**: Official documentation for DuckDB database operations, providing best practices for SQL queries, performance optimization, and data processing patterns.
- **PySide/Qt Documentation**: Official Qt for Python documentation, offering guidance on GUI development, threading, and signal/slot patterns for responsive desktop applications.
- **Polars Documentation**: Official documentation for Polars DataFrame library, providing guidance on memory-efficient operations, vectorized processing, and performance optimization techniques.
- **pytest Documentation**: Official testing framework documentation providing best practices for test organization, fixtures, and assertion patterns.
- **GitHub Actions Documentation**: Official CI/CD platform documentation for automated testing, deployment, and quality assurance workflows.

---

## 📂 Practice Categories

**Category Description:** Comprehensive Python development practices organized by functional area to ensure consistent, secure, and maintainable code across the BIS repository.

### Architecture & Design

**Category Description:** Practices focused on maintaining proper architectural patterns and design principles for scalable, maintainable applications.

#### ✅ Layered Architecture
- **Reason:** Ensures UI responsiveness and proper separation of concerns by delegating heavy work from GUI to appropriate layers.
- **Priority:** 🔴 Must
- **Description:** Implement strict layered architecture with UI, orchestration, and computation layers where the UI layer handles only user interactions and delegates heavy processing to lower layers. This pattern ensures the application remains responsive by preventing UI thread blocking, maintains clear separation of concerns for better maintainability, and supports proper error handling and user feedback. The layered approach also enables better testing by isolating UI logic from business logic and computation, making the codebase more modular and easier to modify without affecting other layers.

#### ❌ Mixing Heavy Processing in UI
- **Reason:** Causes UI freezing and poor user experience by blocking the main thread with heavy operations.
- **Priority:** ❌ Won't
- **Description:** Avoid placing heavy SQL queries, file I/O operations, or complex computations directly in UI event handlers, as this blocks the main UI thread and makes the application unresponsive to user interactions. This anti-pattern leads to frozen interfaces, poor user experience, and potential application crashes when users attempt to interact with blocked UI elements. Instead, delegate all heavy operations to background threads or worker classes, ensuring the UI remains responsive and providing proper progress indicators and cancellation options for long-running tasks.

#### ✅ Idempotent Operations
- **Reason:** Ensures operations can be safely retried without causing errors or data corruption.
- **Priority:** 🔴 Must
- **Description:** Design all operations to be idempotent, meaning they can be executed multiple times without causing errors or unintended side effects, ensuring system reliability during failures or retries. This principle requires using atomic file operations, proper transaction handling, and defensive programming techniques that check for existing states before making changes. Idempotent operations support reliable error recovery, prevent data corruption from partial operations, and enable safe retry mechanisms in distributed systems or when handling user-initiated retries.

#### ✅ Config-Driven Behavior
- **Reason:** Enables flexibility and maintainability by externalizing behavior configuration.
- **Priority:** 🔴 Must
- **Description:** Implement config-driven behavior where application settings and behavior are controlled by external YAML configuration files rather than hard-coded values. This approach enables runtime flexibility, easier maintenance, and environment-specific customization without code changes. Configuration files should include validation, safe defaults, and clear documentation to ensure reliable operation across different deployment scenarios.

#### ✅ Multithreading for UI Responsiveness
- **Reason:** Prevents UI freezing by offloading heavy operations to background threads.
- **Priority:** 🔴 Must
- **Description:** Use multithreading techniques to keep UI responsive during heavy operations by executing computationally intensive tasks in background threads. This ensures users can continue interacting with the interface while processing occurs, improving overall user experience and preventing application freezing. Proper thread synchronization and communication patterns must be implemented to safely update UI elements from background threads.

### Code Structure & Quality

**Category Description:** Practices for writing clean, maintainable, and efficient Python code with proper structure and patterns.

#### ✅ Early Returns & Validation
- **Reason:** Improves readability and prevents unnecessary processing of invalid inputs.
- **Priority:** 🟡 Should
- **Description:** Use early returns and input validation to fail fast when encountering invalid data, improving code readability and preventing unnecessary computation. This pattern makes code more maintainable by clearly separating validation logic from business logic and provides better error messages to users.

#### ❌ Mutable Defaults
- **Reason:** Dangerous shared object behavior that causes cross-call contamination.
- **Priority:** ❌ Won't
- **Description:** Avoid using mutable objects (like lists or dictionaries) as default parameter values, as they are shared across all function calls and can cause unexpected side effects. This anti-pattern leads to hard-to-debug issues where modifications in one function call affect subsequent calls, potentially causing data corruption or inconsistent behavior.

#### ✅ Pure Functions & Dependency Injection
- **Reason:** Improves testability and maintainability through explicit dependencies.
- **Priority:** 🟢 Could
- **Description:** Write pure functions that have no side effects and explicitly declare their dependencies through parameters. Use dependency injection to make code more testable and modular, allowing different implementations to be swapped for testing or different use cases.

#### ✅ Line Length & Formatting
- **Reason:** Ensures consistent code formatting and readability across the codebase.
- **Priority:** 🟡 Should
- **Description:** Maintain consistent line length (maximum 120 characters) and formatting standards to improve code readability and maintainability. Use proper line wrapping for long function calls and strings to ensure code remains readable on different screen sizes and editors.

#### ✅ Avoiding Circular Imports
- **Reason:** Prevents import-time errors and improves module organization.
- **Priority:** 🟡 Should
- **Description:** Structure imports to avoid circular dependencies by importing modules at the point of use rather than at module level when necessary. This prevents import-time errors and makes the codebase more maintainable by reducing coupling between modules.

### Path Handling & File Operations

**Category Description:** Best practices for file system operations, path handling, and I/O operations with proper error handling and security.

#### ✅ Use Pathlib
- **Reason:** Modern, cross-platform path handling with better readability and functionality.
- **Priority:** 🔴 Must
- **Description:** Use pathlib.Path instead of os.path for all file system operations to ensure cross-platform compatibility, better readability, and access to modern path manipulation methods. Pathlib provides object-oriented path handling that is more intuitive and less error-prone than string-based path operations.

#### ❌ Using os.path
- **Reason:** Less robust and modern compared to pathlib for path operations.
- **Priority:** ❌ Won't
- **Description:** Avoid using os.path functions for path operations when pathlib provides equivalent or better functionality. Os.path requires more verbose code, manual string handling, and is more prone to cross-platform compatibility issues compared to the modern pathlib approach.

#### ✅ Atomic File Operations
- **Reason:** Prevents data corruption from partial writes during system interruptions.
- **Priority:** 🔴 Must
- **Description:** Use atomic file operations by writing to temporary files first, then atomically replacing the target file to prevent corruption from partial writes. This ensures data integrity even when the system crashes or is interrupted during file operations.

#### ✅ OS-Specific Operations
- **Reason:** Ensures proper cross-platform compatibility for system-specific operations.
- **Priority:** 🟡 Should
- **Description:** Handle platform differences explicitly when performing OS-specific operations, using proper system calls and error handling for each supported platform. This ensures consistent behavior across Windows, macOS, and Linux environments.

#### ✅ Sibling File Operations
- **Reason:** Maintains consistent file naming patterns and avoids manual path manipulation.
- **Priority:** 🟡 Should
- **Description:** Use pathlib methods like with_suffix() and with_name() to create related file paths instead of manual string manipulation. This ensures consistent naming patterns and reduces the risk of path-related errors.

### UI Best Practices

**Category Description:** Practices for building responsive, maintainable user interfaces with proper threading and event handling.

#### ✅ Non-Blocking UI
- **Reason:** Prevents UI freezing and ensures responsive user experience.
- **Priority:** 🔴 Must
- **Description:** Ensure all UI operations remain responsive by offloading heavy computations to background threads. Use proper thread synchronization to safely update UI elements from worker threads, providing users with progress indicators and the ability to cancel long-running operations.

#### ✅ Dual Logger Pattern
- **Reason:** Provides clear separation between operational logs and error diagnostics.
- **Priority:** 🔴 Must
- **Description:** Implement dual logging with separate loggers for operational information and error details, ensuring comprehensive observability while maintaining clear separation between normal operations and error conditions.

#### ✅ Tab Refresh Pattern
- **Reason:** Improves performance by loading data only when needed.
- **Priority:** 🟡 Should
- **Description:** Implement lazy loading for tab content to reduce startup time and memory usage by loading data only when tabs become active. This pattern improves perceived performance and reduces unnecessary resource consumption.

#### ✅ Signal/Slot Connections
- **Reason:** Centralizes UI event handling for better maintainability and testing.
- **Priority:** 🟡 Should
- **Description:** Centralize signal/slot connections in dedicated methods to improve code organization and make UI behavior easier to test and maintain. This pattern makes it easier to verify UI interactions and modify event handling logic.

### File Processing & I/O

**Category Description:** Practices for safe and efficient file processing with proper error handling and resource management.

#### ✅ Defensive YAML Access
- **Reason:** Prevents crashes from malformed configuration files and provides safe defaults.
- **Priority:** 🔴 Must
- **Description:** Use defensive programming techniques when accessing YAML configuration files, including proper error handling, safe defaults, and validation of configuration structure to prevent application crashes from malformed or missing configuration files.

#### ❌ Direct YAML Access
- **Reason:** No error handling for malformed YAML or missing keys.
- **Priority:** ❌ Won't
- **Description:** Avoid direct key access on YAML data structures without proper error handling, as this can cause KeyError exceptions when expected keys are missing. Always use defensive access patterns with get() methods and proper validation.

#### ✅ Buffered File Reading
- **Reason:** Prevents memory exhaustion when processing large files.
- **Priority:** 🟡 Should
- **Description:** Process large files incrementally using buffered reading techniques to avoid loading entire files into memory. This approach enables processing of arbitrarily large files while maintaining reasonable memory usage and providing progress feedback.

#### ✅ Path Sanitization
- **Reason:** Prevents path traversal attacks and ensures secure file access.
- **Priority:** 🔴 Must
- **Description:** Validate and sanitize user-provided file paths to prevent directory traversal attacks and ensure paths remain within allowed directories. Use proper path resolution and validation techniques to maintain security.

### Exception Handling & Logging

**Category Description:** Practices for robust error handling and comprehensive logging to ensure observability and maintainability.

#### ✅ Loop Isolation
- **Reason:** Prevents one item failure from stopping entire batch processing.
- **Priority:** 🟡 Should
- **Description:** Isolate errors within loops so that failure of one item doesn't prevent processing of remaining items. This ensures maximum throughput and provides detailed reporting of both successful and failed operations.

#### ✅ Parameterized Logging
- **Reason:** Prevents security vulnerabilities and improves log analysis.
- **Priority:** 🔴 Must
- **Description:** Use parameterized logging instead of f-strings to prevent security vulnerabilities and ensure proper log formatting. Parameterized logging also improves performance by deferring string formatting until log levels are confirmed.

#### ❌ f-strings in Logging
- **Reason:** Can expose sensitive data and reduce logging performance.
- **Priority:** ❌ Won't
- **Description:** Avoid using f-strings in logging statements as they can inadvertently expose sensitive data and reduce performance by formatting strings regardless of log level. Use parameterized logging instead for security and efficiency.

#### ✅ Logger Names Policy
- **Reason:** Ensures consistent logging across the application and prevents logger proliferation.
- **Priority:** 🔴 Must
- **Description:** Use only predefined logger names from the BIS logging policy and never create new logger names. This ensures all logs are properly routed and maintains consistent logging infrastructure across the application.

#### ✅ Temporary File Policy
- **Reason:** Ensures proper cleanup and tenant isolation for temporary files.
- **Priority:** 🔴 Must
- **Description:** Store all temporary files in the designated temp/PYTHON_DEVELOPER/ directory with proper naming conventions. This ensures tenant isolation, proper cleanup, and adherence to BIS temporary file policies.

### Security Best Practices

**Category Description:** Essential security practices to protect against common vulnerabilities and ensure data safety.

#### ✅ Input Validation & Sanitization
- **Reason:** Prevents injection attacks and ensures data integrity.
- **Priority:** 🔴 Must
- **Description:** Validate and sanitize all user inputs before processing to prevent injection attacks, ensure data type correctness, and maintain application security. Use proper validation techniques for different data types and provide clear error messages for invalid inputs.

#### ✅ SQL Injection Prevention
- **Reason:** Protects against SQL injection attacks that can compromise data security.
- **Priority:** 🔴 Must
- **Description:** Use parameterized queries exclusively to prevent SQL injection attacks. Never construct SQL queries using string formatting or concatenation with user inputs, as this creates serious security vulnerabilities.

#### ❌ String Formatting for SQL
- **Reason:** Creates SQL injection vulnerabilities and query correctness issues.
- **Priority:** ❌ Won't
- **Description:** Never use string formatting or f-strings to construct SQL queries, as this creates SQL injection vulnerabilities and can lead to incorrect query execution. Always use parameterized queries with proper placeholder syntax.

#### ✅ Secrets Management
- **Reason:** Prevents accidental exposure of sensitive credentials and API keys.
- **Priority:** 🔴 Must
- **Description:** Store all secrets and credentials in environment variables rather than hard-coding them in source code. Validate that required secrets are present before application startup and never log sensitive information.

#### ❌ Hardcoded Secrets
- **Reason:** Risk of accidental exposure and maintenance difficulties.
- **Priority:** ❌ Won't
- **Description:** Never hard-code passwords, API keys, or other sensitive credentials in source code, as this creates security risks and maintenance challenges. Use environment variables or secure configuration management systems instead.

### DuckDB Data Processing

**Category Description:** Best practices for efficient and secure database operations using DuckDB.

#### ✅ SQL-First Approach
- **Reason:** Leverages database engine optimizations for better performance.
- **Priority:** 🟡 Should
- **Description:** Prefer SQL-based data processing over Python loops when possible to take advantage of database engine optimizations. Use SQL for filtering, aggregation, and transformation operations to improve performance and reduce memory usage.

#### ✅ Parameterized Queries
- **Reason:** Ensures security and query correctness across variable inputs.
- **Priority:** 🔴 Must
- **Description:** Use parameterized queries for all database operations to ensure security and proper handling of variable-length inputs. This prevents SQL injection and ensures consistent query execution across different data types and sizes.

#### ✅ Cursor Management
- **Reason:** Ensures proper resource cleanup and efficient data retrieval.
- **Priority:** 🟡 Should
- **Description:** Properly manage database cursors by checking data existence before fetching and re-executing queries when cursors are consumed. This ensures efficient resource usage and prevents common database operation errors.

#### ✅ Temporary Tables Strategy
- **Reason:** Enables efficient multi-step data processing with automatic cleanup.
- **Priority:** 🟡 Should
- **Description:** Use temporary tables for complex multi-step data processing operations to enable composable transformations and automatic cleanup. This approach improves performance and reduces memory usage compared to in-memory processing.

### DataFrame Operations

**Category Description:** Practices for efficient DataFrame processing using Polars and other libraries.

#### ✅ Memory-Efficient DataFrames
- **Reason:** Prevents memory exhaustion when processing large datasets.
- **Priority:** 🟡 Should
- **Description:** Use lazy evaluation and streaming techniques when processing large DataFrames to prevent memory exhaustion. Implement proper chunking and filtering strategies to handle datasets larger than available memory.

#### ✅ Vectorized Operations
- **Reason:** Leverages CPU optimizations for better performance.
- **Priority:** 🟡 Should
- **Description:** Use vectorized operations instead of row-by-row processing to take advantage of CPU optimizations and parallel processing capabilities. This significantly improves performance for numerical computations and data transformations.

#### ❌ Row-by-row Processing
- **Reason:** Extremely inefficient compared to vectorized operations.
- **Priority:** ❌ Won't
- **Description:** Avoid iterating over DataFrame rows when vectorized operations are available, as this is extremely inefficient and defeats the purpose of using high-performance DataFrame libraries. Always prefer column-wise or vectorized operations for data transformations.

### Documentation & Comments

**Category Description:** Practices for comprehensive and maintainable code documentation.

#### ✅ Module Docstring Template
- **Reason:** Ensures consistent, comprehensive documentation across all modules.
- **Priority:** 🔴 Must
- **Description:** Use the standardized module docstring template for all Python files to ensure consistent documentation structure and comprehensive coverage of purpose, usage, dependencies, and other critical information.

#### ✅ Class and Method Docstrings
- **Reason:** Improves code maintainability and API understanding.
- **Priority:** 🟡 Should
- **Description:** Provide comprehensive docstrings for all public classes and methods following the Google or NumPy docstring conventions. Include parameter types, return values, exceptions, and usage examples.

#### ✅ Block Comments
- **Reason:** Improves code readability by clearly separating logical sections.
- **Priority:** 🟡 Should
- **Description:** Use block comments to separate major sections of code and explain complex algorithms or business logic. Keep comments focused on "why" rather than "what" the code does.

#### ✅ Inline Comments
- **Reason:** Explains complex logic and business rules inline with code.
- **Priority:** 🟢 Could
- **Description:** Use inline comments to explain complex conditional logic, business rules, or non-obvious code behavior. Focus on explaining the rationale behind implementation decisions.

### Testing & Validation

**Category Description:** Comprehensive testing practices to ensure code quality and prevent regressions.

#### ✅ Testing Philosophy for BIS
- **Reason:** Ensures comprehensive, deterministic testing across the codebase.
- **Priority:** 🔴 Must
- **Description:** Follow BIS testing philosophy requiring deterministic, isolated tests that cover constructor, happy path, error path, and edge cases. Use realistic dummy data and avoid external dependencies in unit tests.

#### ✅ Required Test Structure
- **Reason:** Ensures consistent test coverage and maintainability.
- **Priority:** 🔴 Must
- **Description:** Implement comprehensive test structure covering constructor tests, happy path scenarios, error handling, and edge cases for all modules. Use proper test organization and naming conventions.

#### ✅ Using Engine/Data for Testing
- **Reason:** Provides realistic test data without external dependencies.
- **Priority:** 🟡 Should
- **Description:** Use dummy data from the engine/data/ directory for integration tests to ensure realistic scenarios without requiring external systems. This enables deterministic testing with known data sets.

#### ✅ Advanced Testing Patterns
- **Reason:** Improves test coverage and maintainability with modern testing techniques.
- **Priority:** 🟡 Should
- **Description:** Implement advanced testing patterns including parametrized tests, performance testing, and comprehensive mocking strategies to ensure thorough validation and maintainable test suites.

#### ✅ Software Tester Guidelines
- **Reason:** Ensures consistent testing practices across development team.
- **Priority:** 🟡 Should
- **Description:** Follow established software testing guidelines for test planning, execution, and validation. Use proper test data management and ensure tests validate both functionality and performance requirements.

#### ✅ Integration Testing with Mocks
- **Reason:** Enables testing of component interactions without external dependencies.
- **Priority:** 🟡 Should
- **Description:** Use mocking techniques for integration testing to isolate components and test their interactions without requiring complete system setup. This ensures reliable, fast integration tests.

#### ✅ Logging Validation with caplog
- **Reason:** Ensures logging behavior is properly tested and validated.
- **Priority:** 🟡 Should
- **Description:** Use pytest's caplog fixture to validate logging behavior in tests, ensuring that appropriate log messages are generated for different scenarios and error conditions.

### Import Management

**Category Description:** Practices for organizing and managing Python imports for better code organization.

#### ✅ Import Organization
- **Reason:** Improves code readability and prevents import-related issues.
- **Priority:** 🟡 Should
- **Description:** Organize imports following the standard Python convention: standard library, third-party packages, then local modules. Use proper import formatting and avoid wildcard imports.

#### ✅ Type Hints
- **Reason:** Improves code maintainability and enables better IDE support.
- **Priority:** 🟢 Could
- **Description:** Use type hints for function parameters and return values to improve code documentation and enable better static analysis and IDE support. Follow PEP 484 and PEP 585 standards for type annotations.

### Development Workflow

**Category Description:** Practices for development environment setup and code quality assurance.

#### ✅ Setting Up Development Environment
- **Reason:** Ensures consistent development environment across team members.
- **Priority:** 🟡 Should
- **Description:** Follow standardized development environment setup procedures including virtual environment creation, dependency management, and tool configuration to ensure consistent development experience.

#### ✅ Pre-commit Validation
- **Reason:** Catches issues early in the development process.
- **Priority:** 🟡 Should
- **Description:** Implement pre-commit hooks and validation scripts to catch common issues before code is committed. This includes formatting checks, linting, and basic validation tests.

#### ✅ AI Agent Enforcement Examples
- **Reason:** Demonstrates proper AI agent integration and enforcement patterns.
- **Priority:** 🟢 Could
- **Description:** Provide examples of how AI agents should enforce coding standards and best practices, including proper logging of enforcement actions and decision-making processes.

### Quality Assurance

**Category Description:** Practices for ensuring code quality and maintaining standards across the codebase.

#### ✅ Quick Validation Checklist
- **Reason:** Provides fast feedback on code quality compliance.
- **Priority:** 🟡 Should
- **Description:** Use quick validation checklists to ensure code meets basic quality standards before detailed review. This includes checking for mandatory practices and common anti-patterns.

#### ✅ Practice Priority Matrix
- **Reason:** Helps prioritize which practices to apply based on context and impact.
- **Priority:** 🟢 Could
- **Description:** Use practice priority matrix to determine which practices are most important to apply in different contexts, balancing effort against business value and technical impact.

#### ✅ Troubleshooting Common Issues
- **Reason:** Provides guidance for resolving common development and quality issues.
- **Priority:** 🟢 Could
- **Description:** Document common issues and their solutions to help developers troubleshoot problems efficiently and maintain consistent approaches to issue resolution.

#### ✅ Final Note for AI Agents
- **Reason:** Ensures AI agents understand their role in maintaining code quality.
- **Priority:** 🟢 Could
- **Description:** Provide clear guidance for AI agents on their responsibilities in enforcing best practices, decision-making frameworks, and collaboration with human developers.



