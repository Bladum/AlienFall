# SQL Best Practices & Guidelines for AI Agents - BIS Repository

<a id="top"></a>

**Target Audience:** AI Agents, Data Analysts, Data Engineers, and BIS contributors authoring SQL
**Scope:** Comprehensive DuckDB SQL development and maintenance standards for BIS repository
**Apply to:** `**/*.sql`, `**/*.duckdb.sql`, repository SQL snippets embedded in code

---

## 📋 Comprehensive Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Core Principles](#-core-principles)
- [🏗️ Design Patterns](#️-design-patterns)
- [📚 Key Terms](#-key-erms)
- [🔗 Industry References](#-industry-references)
- [📂 Practice Categories](#-practice-categories)
  - [Style & Formatting](#style--formatting)
    - [✅ Use UPPERCASE Keywords](#use-uppercase-keywords)
    - [✅ Apply UPPER_SNAKE_CASE Identifiers](#apply-upper_snake_case-identifiers)
    - [✅ Implement Clause-Per-Line Style](#implement-clause-per-line-style)
    - [✅ Use TRY_CAST for Type Safety](#use-try_cast-for-type-safety)
    - [✅ Implement SAFE_DIV Macro for Division Protection](#implement-safe_div-macro-for-division-protection)
    - [✅ Use Trailing Commas in Multi-Line Lists](#use-trailing-commas-in-multi-line-lists)
    - [✅ Limit Line Length to 120 Characters](#limit-line-length-to-120-characters)
    - [❌ Avoid SELECT DISTINCT Without Justification](#avoid-select-distinct-without-justification)
    - [❌ Avoid Leading Commas in Multi-Line Lists](#avoid-leading-commas-in-multi-line-lists)
    - [❌ Don't Use Tabs for Indentation](#dont-use-tabs-for-indentation)
    - [❌ Avoid Overlong Lines Without Wrapping](#avoid-overlong-lines-without-wrapping)
  - [Modeling & Design](#modeling--design)
    - [✅ Design Schema-First Architecture](#design-schema-first-architecture)
    - [✅ Use Canonical Keys and Time Columns](#use-canonical-keys-and-time-columns)
    - [❌ Avoid Generic One-Size-Fits-All Datasets](#avoid-generic-one-size-fits-all-datasets)
    - [✅ Use Columnar Storage Patterns](#use-columnar-storage-patterns)
    - [✅ Include Watermark Columns for Incremental Processing](#include-watermark-columns-for-incremental-processing)
    - [✅ Implement Rolling-Window KPIs](#implement-rolling-window-kpis)
    - [✅ Use Deterministic Categorization](#use-deterministic-categorization)
    - [✅ Implement Multi-Stage Aggregation](#implement-multi-stage-aggregation)
    - [❌ Don't Rely on Excel Pivots for Logic](#dont-rely-on-excel-pivots-for-logic)
    - [❌ Don't Use Wide Tables with Sparse Measures](#dont-use-wide-tables-with-sparse-measures)
  - [Build & Materialization](#build--materialization)
    - [✅ Implement Idempotent Operations](#implement-idempotent-operations)
    - [✅ Use CTE Layering Strategy](#use-cte-layering-strategy)
    - [✅ Include Provenance Columns](#include-provenance-columns)
    - [✅ Use Pre-Aggregation Before Joins](#use-pre-aggregation-before-joins)
    - [✅ Implement Safe Division Patterns](#implement-safe-division-patterns)
    - [✅ Use Deterministic Window Functions](#use-deterministic-window-functions)
    - [❌ Don't Use SELECT * in Production Views](#dont-use-select--in-production-views)
    - [❌ Avoid Commented-Out Code](#avoid-commented-out-code)
  - [Performance & Optimization](#performance--optimization)
    - [✅ Apply Predicate Pushdown](#apply-predicate-pushdown)
    - [✅ Use Deterministic Deduplication](#use-deterministic-deduplication)
    - [✅ Implement Explicit Join Types](#implement-explicit-join-types)
    - [✅ Use ARG_MAX/ARG_MIN for Efficient Aggregations](#use-arg_maxarg_min-for-efficient-aggregations)
    - [✅ Implement ASOF Joins for Time-Series Matching](#implement-asof-joins-for-time-series-matching)
    - [✅ Use LATERAL Joins for Per-Row Subqueries](#use-lateral-joins-for-per-row-subqueries)
    - [✅ Implement Window Functions with Deterministic ORDER BY](#implement-window-functions-with-deterministic-order-by)
    - [✅ Use Explicit ORDER BY Tie-Breakers](#use-explicit-order-by-tie-breakers)
    - [✅ Use Pre-Aggregation Before Joins](#use-pre-aggregation-before-joins)
    - [✅ Document PRAGMA Usage](#document-pragma-usage)
    - [❌ Avoid Implicit File Replacement Scans](#avoid-implicit-file-replacement-scans)
    - [❌ Don't Use SELECT * in Core Layers](#dont-use-select--in-core-layers)
    - [❌ Don't Use Correlated Subqueries in SELECT When LATERAL is Better](#dont-use-correlated-subqueries-in-select-when-lateral-is-better)
    - [❌ Avoid Using MAX on Non-Temporal Values to Infer Recency](#avoid-using-max-on-non-temporal-values-to-infer-recency)
  - [Data Quality & Testing](#data-quality--testing)
    - [✅ Enforce Single-Object Policy](#enforce-single-object-policy)
    - [✅ Validate Data Quality Assertions](#validate-data-quality-assertions)
    - [✅ Document Data Lineage](#document-data-lineage)
    - [✅ Implement PK Uniqueness Validation](#implement-pk-uniqueness-validation)
    - [✅ Validate Referential Integrity](#validate-referential-integrity)
    - [✅ Check for Unexpected NULL Values](#check-for-unexpected-null-values)
    - [❌ Don't Use Blanket DISTINCT](#dont-use-blanket-distinct)
    - [❌ Avoid Leading Commas in Lists](#avoid-leading-commas-in-lists)
  - [Data Visualization & Reporting](#data-visualization--reporting)
    - [✅ Use SQL for Pivoting and Aggregation](#use-sql-for-pivoting-and-aggregation)
    - [✅ Document Sheet Layout and Dataset Mapping](#document-sheet-layout-and-dataset-mapping)
    - [✅ Separate Data and Presentation Logic](#separate-data-and-presentation-logic)
    - [✅ Use Long-Form Data for Charts](#use-long-form-data-for-charts)
    - [✅ Implement Deterministic Categorization](#implement-deterministic-categorization)
    - [❌ Don't Mix Presentation Logic in SQL](#dont-mix-presentation-logic-in-sql)
    - [❌ Don't Leave Pivoting for Excel](#dont-leave-pivoting-for-excel)
    - [❌ Don't Use Compressed Single-File Exports](#dont-use-compressed-single-file-exports)

---

## 🎯 Core Principles

- **Deterministic Execution**: Ensure all SQL queries produce consistent, reproducible results through explicit tie-breakers and stable ordering, eliminating non-deterministic behavior that can cause data quality issues and testing failures.
- **Schema-First Design**: Build data models starting from business requirements and final outputs, working backward through processing layers to ensure alignment with analytical needs and efficient columnar storage patterns.
- **Performance-Driven Architecture**: Optimize for DuckDB's columnar storage and query execution model by implementing predicate pushdown, pre-aggregation, and explicit projection to minimize I/O and maximize query performance.
- **Business Logic Separation**: Keep business rules in SQL code rather than UI layers, ensuring testability, version control, and consistent application across different consumption patterns.
- **Proactive Analytics Foundation**: Design data structures that support preventive, predictive, and SLA monitoring through proper time-series handling, windowing functions, and deterministic scoring mechanisms.

---

## 🏗️ Design Patterns

- **Layered CTE Architecture**: Structure queries with SRC (ingestion), CANON (normalization), AGG (aggregation), and FINAL (presentation) CTEs to create maintainable, testable SQL that clearly separates concerns and enables step-by-step validation.
- **Snapshot Materialization Pattern**: Create immutable KPI/SLA snapshots with RUN_TS and SOURCE_SNAPSHOT_TS columns to provide auditable, point-in-time analytics that support trend analysis and historical reporting requirements.
- **Window Function Determinism**: Use explicit window frames with stable ORDER BY clauses and tie-breakers to ensure reproducible results in ranking, aggregation, and time-series calculations across different execution environments.
- **ASOF Join Pattern**: Implement time-series matching using ASOF joins for robust handling of event-to-dimension relationships where exact timestamp alignment cannot be guaranteed, ensuring complete data capture in analytical queries.
- **Pivoting Strategy**: Transform tall-form metrics to wide-form tables using conditional aggregation rather than dynamic SQL, enabling predictable column structures and efficient columnar storage utilization.

---

## 📚 Key Terms

- **Predicate Pushdown**: Technique of pushing filter conditions into data source operations (like read_parquet FILTERS) to reduce I/O by filtering data at the storage level before loading into memory.
- **CTE Layering**: Common Table Expression architecture that organizes SQL logic into SRC (source), CANON (canonical), AGG (aggregation), and FINAL (presentation) layers for maintainable query construction.
- **Deterministic Deduplication**: Explicit deduplication using ROW_NUMBER() with stable ORDER BY clauses instead of DISTINCT to ensure consistent, reproducible results in data processing pipelines.
- **Schema-on-Read**: Data modeling approach that defers schema definition until query time, allowing flexible reuse of raw data across different analytical use cases without rigid upfront schema constraints.
- **Provenance Tracking**: Inclusion of RUN_TS and SOURCE_SNAPSHOT_TS columns in materialized tables to maintain audit trails and enable incremental processing and data lineage analysis.
- **ARG_MAX/ARG_MIN**: DuckDB aggregate functions that return the value associated with the maximum/minimum key, enabling efficient retrieval of correlated data points in time-series and ranking scenarios.
- **ASOF Join**: Time-series join that matches records based on the nearest preceding timestamp, ideal for joining event data with slowly changing dimension data where exact timestamp alignment is not guaranteed.
- **LATERAL Join**: Per-row subquery execution that allows correlated subqueries to be expressed as joins, enabling efficient row-by-row calculations and lookups in analytical queries.

---

## 🔗 Industry References

- **SQL:2016 Standard**: ISO/IEC 9075:2016 specification defining the Structured Query Language standard, providing the foundation for SQL syntax and semantics used in relational database systems.
- **DuckDB Documentation**: Official documentation for DuckDB analytical database, covering advanced features like columnar storage, vectorized execution, and specialized functions for time-series analytics.
- **Data Warehouse Design Patterns**: Industry best practices for dimensional modeling and star schema design, providing proven patterns for analytical data structures and query optimization.
- **OLAP Design Principles**: Online Analytical Processing guidelines focusing on query performance, data aggregation strategies, and multi-dimensional analysis capabilities.
- **Time-Series Database Patterns**: Best practices for handling temporal data, including window functions, time bucketing, and efficient storage of chronological event data.

---

## 📂 Practice Categories

**Category Description:** Comprehensive SQL development practices covering formatting, modeling, build processes, performance optimization, and data quality assurance for DuckDB-based analytics in the BIS repository.

### Style & Formatting

**Category Description:** Code formatting and style practices that ensure consistency, readability, and maintainability across SQL files in the BIS repository.

#### ✅ Use UPPERCASE Keywords
- **Reason:** Ensures consistent SQL syntax and improves code readability across the development team.
- **Priority:** 🔴 Must
- **Description:** All SQL keywords (SELECT, FROM, WHERE, GROUP BY, ORDER BY, etc.) must be written in uppercase to maintain consistent formatting and improve code readability. This practice follows SQL coding standards and makes queries easier to scan and understand. Keywords in uppercase provide clear visual separation from identifiers and improve the overall professional appearance of SQL code. Consistent keyword casing also helps with automated parsing and syntax highlighting in development tools, reducing the likelihood of syntax errors and improving code maintainability across different team members and development environments.

#### ✅ Apply UPPER_SNAKE_CASE Identifiers
- **Reason:** Provides consistent naming conventions and prevents identifier conflicts.
- **Priority:** 🔴 Must
- **Description:** All schema names, table names, column names, and aliases must use UPPER_SNAKE_CASE format (words separated by underscores, all uppercase) to ensure consistency and prevent naming conflicts. This convention aligns with SQL best practices and improves code readability by making identifier boundaries clear. UPPER_SNAKE_CASE prevents issues with case-sensitive databases and provides a professional, standardized appearance. The practice also helps with automated code generation and maintenance scripts, ensuring that all identifiers follow the same predictable pattern throughout the codebase.

#### ✅ Implement Clause-Per-Line Style
- **Reason:** Improves code readability and version control diffs.
- **Priority:** 🔴 Must
- **Description:** Each major SQL clause (SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY) must be placed on its own line with proper indentation to enhance readability and make version control diffs more meaningful. This formatting style breaks long queries into logical, scannable sections and makes it easier to identify specific parts of complex queries during code review. The clause-per-line approach also facilitates automated formatting tools and ensures consistent code structure across different developers. By placing each clause on a separate line, developers can quickly locate specific query components and understand the query logic flow more efficiently.

#### ✅ Use TRY_CAST for Type Safety
- **Reason:** Prevents runtime errors and ensures robust data processing.
- **Priority:** 🔴 Must
- **Description:** Use TRY_CAST() function for type conversions instead of CAST() to handle conversion failures gracefully and prevent query failures from unexpected data types. TRY_CAST returns NULL for failed conversions rather than throwing errors, allowing queries to continue processing with partial results. This practice improves query robustness and enables better error handling in data pipelines. By using TRY_CAST early in data processing, teams can identify and handle type conversion issues before they propagate through the analytical pipeline.

#### ✅ Implement SAFE_DIV Macro for Division Protection
- **Reason:** Prevents division by zero errors and ensures mathematical operation safety.
- **Priority:** 🔴 Must
- **Description:** Implement SAFE_DIV macro (numerator * 1.0 / NULLIF(denominator, 0)) for all division operations to prevent division by zero errors and ensure consistent handling of edge cases. This pattern provides predictable results and prevents query failures from unexpected zero denominators. SAFE_DIV enables robust ratio calculations and percentage computations across analytical queries. By standardizing division operations, teams can ensure consistent behavior and avoid runtime errors in production environments.

#### ✅ Use Trailing Commas in Multi-Line Lists
- **Reason:** Improves maintainability and reduces merge conflicts in collaborative development.
- **Priority:** 🟡 Should
- **Description:** Use trailing commas in multi-line column lists, CTE definitions, and other comma-separated constructs to make it easier to add, remove, or reorder items without affecting other lines. Trailing commas reduce merge conflicts in version control and improve code maintainability. This practice follows modern coding standards and makes collaborative development more efficient. By using trailing commas, teams can modify lists without touching adjacent lines, reducing the likelihood of merge conflicts.

#### ✅ Limit Line Length to 120 Characters
- **Reason:** Ensures code readability and compatibility with various development tools.
- **Priority:** 🟡 Should
- **Description:** Keep SQL lines to a maximum of 120 characters to ensure readability across different screen sizes and development environments. Long lines become difficult to read and may not display properly in various tools. This practice improves code review effectiveness and ensures consistent formatting. By limiting line length, teams can maintain readable code that works well in different development contexts.

#### ❌ Avoid SELECT DISTINCT Without Justification
- **Reason:** Hides data quality issues and can mask underlying problems with duplicate records.
- **Priority:** ❌ Won't
- **Description:** Avoid using SELECT DISTINCT without justification, as it hides data quality issues and can mask underlying problems with duplicate records. Instead, use explicit deduplication with ROW_NUMBER() to understand and address the root cause of duplicates. This practice ensures that data quality issues are identified and resolved rather than hidden. By avoiding blanket DISTINCT, teams can maintain awareness of data quality and implement proper deduplication strategies.

#### ❌ Avoid Leading Commas in Multi-Line Lists
- **Reason:** Creates maintenance issues and hinders code readability in team environments.
- **Priority:** ❌ Won't
- **Description:** Avoid using leading commas in multi-line lists, as they create maintenance issues when adding or removing items and hinder code readability. Instead, use trailing commas which are more maintainable and reduce merge conflicts. This practice ensures that SQL code is easy to modify and maintain in collaborative environments. By avoiding leading commas, teams can reduce the likelihood of syntax errors during code modifications.

#### ❌ Don't Use Tabs for Indentation
- **Reason:** Ensures consistent formatting across different development environments and tools.
- **Priority:** ❌ Won't
- **Description:** Never use tabs for indentation in SQL files, as they can display differently across various editors and environments. Instead, use spaces (typically 2 spaces) for consistent indentation. This practice ensures that code looks the same regardless of the development environment. By using spaces instead of tabs, teams can maintain consistent code formatting and avoid display issues.

#### ❌ Avoid Overlong Lines Without Wrapping
- **Reason:** Maintains code readability and prevents display issues in development tools.
- **Priority:** ❌ Won't
- **Description:** Avoid lines longer than 120 characters without proper wrapping, as they become difficult to read and may not display properly in various development tools. Instead, break long lines logically using proper SQL formatting conventions. This practice ensures that code remains readable and maintainable. By avoiding overlong lines, teams can improve code review effectiveness and ensure consistent formatting across the codebase.

#### ❌ Avoid Implicit File Replacement Scans
- **Reason:** Prevents performance issues and ensures explicit data source handling.
- **Priority:** ❌ Won't
- **Description:** Avoid using implicit file replacement scans (FROM 'file.csv') without explicit options, as they lack control over data types, headers, and schema evolution. Instead, use explicit functions like read_csv_auto() with proper parameters to ensure predictable data ingestion. Implicit scans can lead to performance issues, type conversion problems, and unreliable results. By avoiding implicit scans, teams maintain better control over data processing and ensure consistent behavior across different environments.

#### ❌ Don't Use SELECT * in Core Layers
- **Reason:** Prevents projection pushdown issues and ensures explicit column selection.
- **Priority:** ❌ Won't
- **Description:** Avoid using SELECT * in core data processing layers, as it prevents projection pushdown optimization and can lead to unnecessary data transfer. Instead, use explicit column lists to enable query optimization and improve performance. SELECT * in core layers also makes queries brittle to schema changes and reduces code clarity. By specifying explicit columns, teams can optimize data access patterns and maintain more maintainable code.

#### ❌ Avoid Commented-Out Code
- **Reason:** Maintains code clarity and prevents confusion in version control.
- **Priority:** ❌ Won't
- **Description:** Remove all commented-out code from production SQL files, as it creates confusion, clutters the codebase, and complicates version control diffs. Commented-out code should be either implemented or completely removed. This practice ensures that all code in the repository is active and relevant. By maintaining clean code without commented remnants, teams can focus on current implementations and reduce maintenance overhead.

#### ✅ Use ARG_MAX/ARG_MIN for Efficient Aggregations
- **Reason:** Provides efficient retrieval of correlated values in analytical queries.
- **Priority:** 🟡 Should
- **Description:** Use ARG_MAX() and ARG_MIN() functions to efficiently retrieve values associated with maximum or minimum keys, particularly useful for time-series analysis and ranking scenarios. These functions provide better performance than subqueries and ensure deterministic results. ARG_MAX/ARG_MIN are especially valuable when you need both the key value and its associated data point. By leveraging these functions, teams can write more efficient analytical queries with clearer intent.

#### ✅ Implement ASOF Joins for Time-Series Matching
- **Reason:** Enables robust time-series analysis with non-aligned timestamps.
- **Priority:** 🟡 Should
- **Description:** Use ASOF joins for matching time-series data where exact timestamp alignment cannot be guaranteed, ensuring complete data capture in analytical queries. ASOF joins find the nearest preceding record based on timestamp, making them ideal for event-to-dimension relationships. This practice prevents data loss from timing mismatches and provides more comprehensive analytical results. By using ASOF joins appropriately, teams can handle real-world timing variations in their data.

#### ✅ Use LATERAL Joins for Per-Row Subqueries
- **Reason:** Improves performance and clarity for row-by-row calculations.
- **Priority:** 🟡 Should
- **Description:** Use LATERAL joins instead of correlated subqueries in SELECT clauses when performing per-row calculations or lookups, as they provide better performance and clearer intent. LATERAL joins allow subqueries to reference columns from the left side of the join, enabling efficient row-by-row processing. This practice improves query readability and optimization opportunities. By using LATERAL joins, teams can write more maintainable and performant analytical queries.

#### ✅ Use EXCLUDE/REPLACE in Presentation Layers
- **Reason:** Enables clean data presentation without compromising core layer performance.
- **Priority:** 🟡 Should
- **Description:** Use SELECT * EXCLUDE() and REPLACE() only in final presentation layers to hide internal columns and rename fields for end-user consumption. This practice maintains performance in core processing layers while providing clean output formatting. EXCLUDE/REPLACE should never be used in core data processing to avoid interfering with projection pushdown. By reserving these features for presentation layers, teams can optimize performance while providing user-friendly column names.

#### ✅ Implement Robust CSV Ingestion with read_csv_auto
- **Reason:** Ensures reliable data ingestion with proper type handling and schema evolution.
- **Priority:** 🟡 Should
- **Description:** Use read_csv_auto() with explicit parameters (header=True, union_by_name=True, sample_size=100000) for CSV file ingestion to handle schema drift and ensure consistent typing. This practice provides better control over data import compared to implicit file replacement scans. Robust CSV ingestion prevents type conversion errors and handles evolving schemas gracefully. By using explicit parameters, teams can ensure reliable data processing across different CSV sources.

#### ✅ Use Compressed Partitioned Parquet for Storage
- **Reason:** Optimizes storage efficiency and query performance for analytical workloads.
- **Priority:** 🟡 Should
- **Description:** Export data using compressed, partitioned Parquet format with appropriate compression algorithms (ZSTD) and partitioning strategies to optimize downstream read performance. Partitioned Parquet enables efficient data pruning and reduces I/O for analytical queries. This practice significantly improves storage efficiency and query performance. By using compressed partitioned formats, teams can reduce storage costs while maintaining fast analytical query performance.

#### ❌ Don't Use Bare File Replacement Scans
- **Reason:** Prevents unreliable data processing and type conversion issues.
- **Priority:** ❌ Won't
- **Description:** Avoid using bare file replacement scans (FROM 'file.csv') without explicit options, as they provide no control over typing, headers, or schema evolution. Instead, use explicit functions with proper parameters for reliable data ingestion. Bare scans can lead to unpredictable results and performance issues. By avoiding bare scans, teams ensure consistent and reliable data processing across different file sources.

#### ❌ Avoid Uncompressed Single-File Exports
- **Reason:** Prevents inefficient storage and poor query performance.
- **Priority:** ❌ Won't
- **Description:** Never export data as uncompressed single-file formats (like CSV) for analytical workloads, as they waste storage space and provide poor query performance. Instead, use compressed, partitioned columnar formats like Parquet. Uncompressed single-file exports are inefficient for analytical use cases and can lead to performance bottlenecks. By using appropriate storage formats, teams can optimize both storage costs and analytical query performance.

#### ❌ Don't Use Correlated Subqueries in SELECT When LATERAL is Better
- **Reason:** Improves performance and code clarity for per-row operations.
- **Priority:** ❌ Won't
- **Description:** Avoid using correlated subqueries in SELECT clauses when LATERAL joins provide better performance and clarity for per-row calculations. Correlated subqueries can be less efficient and harder to optimize than LATERAL joins. This practice ensures that queries use the most appropriate and performant constructs. By preferring LATERAL joins, teams can write more efficient and maintainable analytical queries.

#### ❌ Avoid Using MAX on Non-Temporal Values to Infer Recency
- **Reason:** Prevents incorrect results in time-series analysis.
- **Priority:** ❌ Won't
- **Description:** Never use MAX() on non-temporal columns (like status or category) to infer the most recent record, as MAX operates lexicographically and doesn't consider time. Instead, use ARG_MAX() with explicit timestamp columns for proper temporal ordering. This practice prevents incorrect analytical results and ensures proper time-series handling. By using appropriate functions for temporal analysis, teams can ensure accurate and reliable analytical outputs.

#### ❌ Don't Use EXCLUDE to Mask SELECT * in Core Layers
- **Reason:** Prevents performance degradation from broad column selection.
- **Priority:** ❌ Won't
- **Description:** Avoid using SELECT * EXCLUDE() in core data processing layers, as it encourages broad scans and prevents projection pushdown optimization. EXCLUDE should only be used in final presentation layers. Using EXCLUDE in core layers undermines query performance and optimization opportunities. By reserving EXCLUDE for presentation layers, teams maintain optimal performance in their data processing pipelines.

#### ✅ Document PRAGMA Usage in Headers
- **Reason:** Ensures transparency and reproducibility of performance tuning settings.
- **Priority:** 🟡 Should
- **Description:** Document all PRAGMA settings (threads, memory_limit, enable_object_cache) in SQL file headers to ensure reproducibility and performance tuning transparency. This practice helps other developers understand performance expectations and system requirements. Documented PRAGMA usage enables consistent performance across different environments. By documenting these settings, teams can ensure that performance tuning decisions are transparent and reproducible.

#### ✅ Use Pre-Aggregation Before Joins
- **Reason:** Reduces data volume and improves join performance.
- **Priority:** 🟡 Should
- **Description:** Perform aggregations before joining tables to reduce the data volume being processed and improve overall query performance. Pre-aggregation minimizes the rows that need to be joined and can significantly speed up analytical queries. This practice is particularly important when working with large datasets. By aggregating data before joins, teams can achieve better performance and more efficient resource utilization.

#### ✅ Implement Window Functions with Deterministic ORDER BY
- **Reason:** Ensures reproducible results in analytical calculations.
- **Priority:** 🟡 Should
- **Description:** Always use explicit ORDER BY clauses with tie-breakers in window functions to ensure deterministic, reproducible results across different execution environments. Deterministic window functions prevent inconsistent results and ensure reliable analytical outputs. This practice is crucial for ranking, running totals, and other windowed calculations. By using deterministic ORDER BY clauses, teams can ensure consistent and reliable analytical results.

#### ✅ Use Columnar Storage Patterns
- **Reason:** Optimizes storage efficiency and query performance for analytical workloads.
- **Priority:** 🟡 Should
- **Description:** Design tables using long-and-narrow patterns (fewer columns, more rows) to leverage columnar storage efficiency and improve analytical query performance. Columnar storage patterns enable better compression and faster scans for analytical workloads. This practice optimizes data layout for the typical access patterns in analytical systems. By using columnar-friendly designs, teams can achieve better storage efficiency and query performance.

#### ✅ Include Watermark Columns for Incremental Processing
- **Reason:** Enables efficient incremental data processing and change detection.
- **Priority:** 🟡 Should
- **Description:** Include watermark columns (like LAST_UPDATED_TS or HIGH_WATER_MARK) in tables to support incremental processing and efficient change detection. Watermarks enable queries to process only new or changed data, improving performance and reducing resource consumption. This practice is essential for scalable data processing pipelines. By including watermarks, teams can implement efficient incremental processing strategies.

#### ❌ Avoid Leading Commas in Multi-Line Lists
- **Reason:** Prevents merge conflicts and improves code readability.
- **Priority:** ❌ Won't
- **Description:** Never use leading commas in multi-line column lists or other constructs, as they create merge conflicts and reduce code readability. Instead, use trailing commas for better diff management. Leading commas make version control diffs harder to read and can cause merge conflicts. By using trailing commas, teams can maintain cleaner version control history and better code readability.

#### ❌ Don't Use Tabs for Indentation
- **Reason:** Ensures consistent formatting across different editors and environments.
- **Priority:** ❌ Won't
- **Description:** Never use tab characters for indentation, as they can display differently across editors and cause formatting inconsistencies. Instead, use spaces (typically 2 spaces) for consistent indentation. Tab-based indentation leads to formatting issues when code is viewed in different environments. By using spaces, teams ensure consistent code formatting across all development tools and environments.

#### ❌ Avoid Overlong Lines Without Wrapping
- **Reason:** Maintains code readability and follows formatting standards.
- **Priority:** ❌ Won't
- **Description:** Never create lines longer than 120 characters without proper line wrapping, as they reduce code readability and violate formatting standards. Instead, break long lines appropriately using indentation. Overlong lines make code difficult to read and review. By maintaining reasonable line lengths, teams ensure better code readability and maintainability.

#### ✅ Use Explicit ORDER BY Tie-Breakers
- **Reason:** Ensures deterministic results in ranking and sorting operations.
- **Priority:** 🔴 Must
- **Description:** Always include tie-breaker columns in ORDER BY clauses to ensure deterministic, reproducible results when sorting or ranking data. Tie-breakers prevent inconsistent results across different execution environments. This practice is essential for any query that requires stable ordering. By using explicit tie-breakers, teams can ensure consistent and predictable query results.

#### ✅ Implement SAFE_DIV for Ratio Calculations
- **Reason:** Prevents division by zero errors in mathematical operations.
- **Priority:** 🔴 Must
- **Description:** Use SAFE_DIV pattern (numerator * 1.0 / NULLIF(denominator, 0)) for all ratio and percentage calculations to prevent division by zero errors and ensure robust mathematical operations. This pattern provides predictable results and prevents query failures. SAFE_DIV is essential for reliable analytical calculations. By implementing SAFE_DIV, teams can ensure robust and error-free mathematical operations in their queries.

### Modeling & Design

**Category Description:** Data modeling practices that ensure efficient, scalable, and business-aligned database designs for analytical workloads.

#### ✅ Design Schema-First Architecture
- **Reason:** Ensures data models serve specific business purposes and support efficient querying.
- **Priority:** 🔴 Must
- **Description:** Design data models by first defining the final analytical outputs and working backward through processing layers, ensuring that every table serves a clear business purpose and supports efficient columnar storage patterns. This approach prevents the creation of generic, unfocused datasets that become maintenance burdens. Schema-first design requires documenting row grain, primary keys, refresh cadences, and data provenance for each table. The practice ensures that data structures align with analytical requirements and support predictable query performance. By starting with outputs and working backward, teams create more focused, efficient data models that directly support business objectives.

#### ✅ Use Canonical Keys and Time Columns
- **Reason:** Enables stable joins and reproducible time-based analytics.
- **Priority:** 🔴 Must
- **Description:** Implement canonical entity keys (like ENTITY_ID, CUSTOMER_ID) and explicit time columns (DAY, WINDOW_START, WINDOW_END) to ensure stable, predictable joins and time-series analysis across the data model. Canonical keys provide consistent identification of business entities while explicit time columns enable reliable temporal analysis and windowing operations. This practice prevents join failures due to inconsistent key formats and ensures that time-based calculations produce reproducible results. The use of canonical keys also simplifies data integration and reduces the complexity of analytical queries by providing standardized entity identification across different data sources.

#### ❌ Avoid Generic One-Size-Fits-All Datasets
- **Reason:** Prevents bloated, unfocused data structures that hinder performance and usability.
- **Priority:** ❌ Won't
- **Description:** Avoid creating generic dashboard datasets that attempt to serve all possible analytical needs, as these become maintenance burdens and perform poorly. Instead, design focused tables for specific business purposes with clear scope and refresh cadences. Generic datasets often include unnecessary columns, complex joins, and unclear business logic that makes them difficult to understand and maintain. This anti-pattern leads to performance issues and data quality problems as the dataset grows. By creating purpose-specific tables, teams can optimize each dataset for its intended use case and maintain clearer data lineage and business logic.

#### ✅ Implement Rolling-Window KPIs
- **Reason:** Enables time-series analysis with proper temporal context and deterministic calculations.
- **Priority:** 🟡 Should
- **Description:** Use DATE_TRUNC and WINDOW functions with explicit frames and deterministic ORDER BY clauses to compute rolling-window KPIs that provide temporal context for business metrics. Rolling-window calculations enable trend analysis and early warning systems by maintaining historical context in analytical queries. This practice ensures that time-series calculations are reproducible and include proper window boundaries for accurate temporal analysis. By implementing rolling-window KPIs, teams can detect trends, seasonality, and anomalies in their business metrics with confidence in the calculation accuracy.

#### ✅ Use Deterministic Categorization
- **Reason:** Prevents gaps, overlaps, and ambiguity in categorical data classification.
- **Priority:** 🟡 Should
- **Description:** Implement explicit CASE statements with clear boundaries and fallback categories to ensure deterministic, gap-free categorization of continuous values into discrete buckets. Deterministic categorization prevents classification inconsistencies and ensures that all values are properly assigned to appropriate categories. This practice is essential for reporting consistency and prevents gaps or overlaps in categorical assignments that can lead to incorrect analytical conclusions. By using explicit boundaries and fallbacks, teams can ensure that categorization logic is transparent and produces consistent results across different execution environments.

#### ✅ Implement Multi-Stage Aggregation
- **Reason:** Controls memory usage and clarifies aggregation hierarchy in complex analytical queries.
- **Priority:** 🟡 Should
- **Description:** Use multi-stage aggregation patterns with intermediate CTEs to control memory consumption and clearly define aggregation hierarchies in complex analytical queries. Multi-stage aggregation breaks down complex calculations into manageable steps, making queries easier to understand and optimize. This practice prevents memory issues with large datasets and enables step-by-step validation of aggregation logic. By implementing multi-stage aggregation, teams can handle complex analytical requirements while maintaining query performance and readability.

#### ❌ Don't Rely on Excel Pivots for Logic
- **Reason:** Violates reproducibility, moves business rules into UI, and breaks CI/testing workflows.
- **Priority:** ❌ Won't
- **Description:** Never rely on Excel pivot tables or filters to implement business logic, as this hides important calculations in the user interface and prevents proper testing and version control. Excel-based logic cannot be validated through automated testing and creates dependencies on specific UI configurations. This practice ensures that all business logic remains in SQL where it can be properly tested, reviewed, and maintained. By keeping calculations in SQL, teams maintain auditability and ensure that business rules are consistently applied across different reporting interfaces.

#### ❌ Don't Use Wide Tables with Sparse Measures
- **Reason:** Creates inefficient storage patterns and poor query performance in columnar databases.
- **Priority:** ❌ Won't
- **Description:** Avoid creating wide tables that mix many sparsely populated measures and dimensions, as this creates inefficient storage patterns in columnar databases like DuckDB. Wide sparse tables lead to poor compression ratios and slow query performance due to excessive null value handling. Instead, use long-form tables with canonical metric shapes that optimize for columnar storage efficiency. This practice ensures that data structures align with the underlying storage engine's strengths and provide optimal query performance for analytical workloads.

### Build & Materialization

**Category Description:** Practices for building and materializing data structures with proper error handling, documentation, and operational considerations.

#### ✅ Implement Idempotent Operations
- **Reason:** Ensures safe re-execution and prevents data corruption from duplicate runs.
- **Priority:** 🔴 Must
- **Description:** Use CREATE OR REPLACE syntax for all views and tables to ensure operations can be safely re-executed without manual cleanup or state management. Idempotent operations prevent data corruption from accidental duplicate runs and simplify deployment processes. This practice eliminates the need for manual DROP statements and reduces the risk of deployment failures. By making all operations idempotent, teams can confidently re-run scripts during development, testing, and production deployments without worrying about state conflicts or data inconsistencies.

#### ✅ Use CTE Layering Strategy
- **Reason:** Creates maintainable, testable SQL with clear separation of concerns.
- **Priority:** 🔴 Must
- **Description:** Structure complex queries using Common Table Expressions organized into SRC (source ingestion), CANON (data normalization), AGG (aggregation), and FINAL (presentation) layers to improve maintainability and testing. Each CTE layer has a specific responsibility, making it easier to debug and modify individual components. The layering approach also facilitates code reuse and enables step-by-step validation of query logic. By organizing queries into logical layers, developers can isolate data quality issues and performance problems to specific processing stages, simplifying troubleshooting and optimization efforts.

#### ✅ Include Provenance Columns
- **Reason:** Maintains audit trails and enables incremental processing capabilities.
- **Priority:** 🔴 Must
- **Description:** Include RUN_TS (execution timestamp) and SOURCE_SNAPSHOT_TS (source data timestamp) columns in all materialized tables to maintain data lineage and support incremental processing. Provenance columns enable audit trails, help with debugging data issues, and support time-travel queries. This practice ensures that users can understand when data was processed and what source data was used. Provenance tracking also enables efficient incremental updates by identifying what data has changed since the last run, reducing processing time and resource consumption.

#### ✅ Implement Safe Division Patterns
- **Reason:** Prevents division by zero errors and ensures robust mathematical operations.
- **Priority:** 🟡 Should
- **Description:** Use NULLIF() function in division operations to prevent division by zero errors and handle edge cases gracefully in analytical calculations. Safe division patterns ensure that mathematical operations are robust and don't fail due to unexpected zero values. This practice is essential for KPI calculations, ratio computations, and percentage calculations where denominators might be zero. By implementing safe division patterns, teams can prevent runtime errors and ensure that analytical queries produce reliable results even with imperfect source data.

#### ✅ Use Deterministic Window Functions
- **Reason:** Ensures reproducible results and prevents non-deterministic behavior in analytical queries.
- **Priority:** 🟡 Should
- **Description:** Always include explicit ORDER BY clauses in window functions with stable tie-breakers to ensure deterministic, reproducible results across different execution environments. Deterministic window functions prevent subtle bugs and ensure consistent analytical outputs. This practice is crucial for ranking, running totals, and other analytical calculations where result order matters. By using explicit ORDER BY with tie-breakers, developers can ensure that window function results are predictable and reliable.

#### ❌ Don't Use SELECT * in Production Views
- **Reason:** Prevents projection pushdown issues and improves query performance.
- **Priority:** ❌ Won't
- **Description:** Avoid using SELECT * in production views as it prevents projection pushdown optimizations and can lead to unnecessary data transfer. Instead, explicitly list required columns to enable better query optimization. This practice improves performance by allowing DuckDB to only read necessary columns from storage. By avoiding SELECT * in production views, teams can ensure more efficient queries and better resource utilization.

#### ❌ Avoid Commented-Out Code
- **Reason:** Maintains clean, maintainable code without obsolete or confusing remnants.
- **Priority:** ❌ Won't
- **Description:** Remove all commented-out code from production SQL files to maintain clean, readable code without obsolete or confusing remnants. Commented-out code creates maintenance overhead and can confuse developers about which code is actually active. This practice ensures that SQL files contain only active, relevant code that serves the current business purpose. By removing commented-out code, teams can maintain cleaner version control history and reduce confusion during code reviews and maintenance activities.

### Performance & Optimization

**Category Description:** Query optimization practices that leverage DuckDB's capabilities for efficient analytical processing.

#### ✅ Apply Predicate Pushdown
- **Reason:** Reduces I/O and improves query performance by filtering data at the source.
- **Priority:** 🔴 Must
- **Description:** Use FILTERS parameters in read_parquet() and similar functions to push filter conditions into data source operations, reducing the amount of data that needs to be loaded into memory. Predicate pushdown leverages DuckDB's columnar storage and file format capabilities to minimize I/O operations. This practice significantly improves query performance, especially when working with large datasets stored in Parquet or other columnar formats. By filtering data at the storage level, queries can avoid loading unnecessary rows and columns, resulting in faster execution times and reduced memory usage.

#### ✅ Use Deterministic Deduplication
- **Reason:** Ensures consistent, reproducible results and prevents data quality issues.
- **Priority:** 🔴 Must
- **Description:** Replace SELECT DISTINCT with explicit deduplication using ROW_NUMBER() and stable ORDER BY clauses to ensure deterministic, reproducible results. Deterministic deduplication provides explicit control over which duplicate records are retained and ensures consistent behavior across different execution environments. This practice prevents non-deterministic results that can occur with DISTINCT, especially when dealing with complex data types or floating-point values. By using ROW_NUMBER() with explicit tie-breakers, developers can ensure that deduplication logic is transparent and predictable.

#### ✅ Implement Explicit Join Types
- **Reason:** Prevents accidental cross joins and clarifies query intent.
- **Priority:** 🔴 Must
- **Description:** Always specify explicit join types (INNER JOIN, LEFT JOIN, etc.) instead of using implicit joins in the WHERE clause to prevent accidental cross joins and make query intent clear. Explicit joins improve code readability and help prevent performance issues from unintended Cartesian products. This practice also makes it easier to understand the relationship between tables and identify potential data quality issues. By being explicit about join types, developers can ensure that queries behave as intended and perform efficiently.

#### ✅ Use ARG_MAX/ARG_MIN for Efficient Aggregations
- **Reason:** Provides efficient aggregation with value retrieval for analytical queries.
- **Priority:** 🟡 Should
- **Description:** Use ARG_MAX() and ARG_MIN() functions to efficiently retrieve values associated with maximum or minimum keys, particularly useful for finding values at specific timestamps or conditions. These functions are optimized for columnar processing and provide better performance than equivalent window function approaches. ARG_MAX/ARG_MIN are especially valuable in time-series analysis and analytical queries where you need both the key value and associated data. This practice leverages DuckDB's analytical capabilities to write more efficient and concise queries.

#### ✅ Implement ASOF Joins for Time-Series Matching
- **Reason:** Enables robust time-series data matching with proper temporal alignment.
- **Priority:** 🟡 Should
- **Description:** Use ASOF joins to match records based on the nearest timestamp that doesn't exceed the reference timestamp, ensuring proper temporal relationships in time-series data. ASOF joins handle irregular time intervals and missing data points more gracefully than exact equality joins. This practice is essential for financial data, sensor readings, and any time-series analysis where exact timestamp alignment isn't guaranteed. By using ASOF joins, developers can ensure accurate temporal analysis and prevent data loss from misaligned timestamps.

#### ✅ Use LATERAL Joins for Per-Row Subqueries
- **Reason:** Improves performance and clarity for row-specific calculations and lookups.
- **Priority:** 🟡 Should
- **Description:** Use LATERAL joins instead of correlated subqueries when performing per-row calculations or lookups that depend on values from the left table. LATERAL joins provide better performance and clearer intent than correlated subqueries in the SELECT clause. This practice is particularly useful for top-N queries, conditional aggregations, and complex per-row transformations. By using LATERAL joins, queries become more readable and can benefit from better optimization opportunities in DuckDB.

#### ✅ Implement Window Functions with Deterministic ORDER BY
- **Reason:** Ensures reproducible results and prevents non-deterministic behavior in analytical queries.
- **Priority:** 🟡 Should
- **Description:** Always include explicit ORDER BY clauses in window functions with stable tie-breakers to ensure deterministic, reproducible results across different execution environments. Deterministic window functions prevent subtle bugs and ensure consistent analytical outputs. This practice is crucial for ranking, running totals, and other analytical calculations where result order matters. By using explicit ORDER BY with tie-breakers, developers can ensure that window function results are predictable and reliable.

#### ✅ Use Explicit ORDER BY Tie-Breakers
- **Reason:** Prevents non-deterministic results in ranking and deduplication operations.
- **Priority:** 🟡 Should
- **Description:** Include stable tie-breaking columns in ORDER BY clauses for ranking functions and deduplication to ensure consistent results when values are equal. Explicit tie-breakers prevent non-deterministic behavior and ensure reproducible query results. This practice is essential for data quality and auditability, especially in production environments where consistent results are critical. By using explicit tie-breakers, teams can avoid subtle bugs and ensure reliable analytical outputs.

#### ✅ Use Pre-Aggregation Before Joins
- **Reason:** Reduces data volume and improves join performance in analytical queries.
- **Priority:** 🟡 Should
- **Description:** Pre-aggregate data before performing joins to reduce the volume of data being processed and improve query performance. This practice minimizes the computational complexity of joins and can significantly speed up analytical queries. Pre-aggregation should be done at the appropriate granularity to maintain analytical accuracy while optimizing performance. By aggregating before joining, teams can achieve better query performance and more efficient resource utilization.

#### ✅ Document PRAGMA Usage
- **Reason:** Ensures transparency and portability of performance tuning configurations.
- **Priority:** 🟡 Should
- **Description:** Document all PRAGMA settings (threads, memory_limit, enable_object_cache) used in SQL files to ensure transparency and maintain portability across different execution environments. PRAGMA documentation helps other developers understand performance tuning decisions and ensures consistent behavior. This practice prevents configuration drift and enables better troubleshooting of performance issues. By documenting PRAGMA usage, teams can maintain awareness of performance tuning decisions and their impact on query execution.

#### ❌ Avoid Implicit File Replacement Scans
- **Reason:** Prevents unreliable data processing and type conversion issues.
- **Priority:** ❌ Won't
- **Description:** Avoid using bare file replacement scans (FROM 'file.csv') without explicit options, as they provide no control over typing, headers, or schema evolution. Instead, use explicit functions with proper parameters for reliable data ingestion. Bare scans can lead to unpredictable results and performance issues. By avoiding bare scans, teams ensure consistent and reliable data processing across different file sources.

#### ❌ Don't Use SELECT * in Core Layers
- **Reason:** Prevents projection pushdown issues and improves query performance.
- **Priority:** ❌ Won't
- **Description:** Avoid using SELECT * in core data processing layers as it prevents projection pushdown optimizations and can lead to unnecessary data transfer. Instead, explicitly list required columns to enable better query optimization. This practice improves performance by allowing DuckDB to only read necessary columns from storage. By avoiding SELECT *, teams can ensure more efficient queries and better resource utilization.

#### ❌ Don't Use Correlated Subqueries in SELECT When LATERAL is Better
- **Reason:** Improves performance and code clarity for per-row operations.
- **Priority:** ❌ Won't
- **Description:** Avoid using correlated subqueries in SELECT clauses when LATERAL joins provide better performance and clarity for per-row calculations. Correlated subqueries can be less efficient and harder to optimize than LATERAL joins. This practice ensures that queries use the most appropriate and performant constructs. By preferring LATERAL joins, teams can write more efficient and maintainable analytical queries.

#### ❌ Avoid Using MAX on Non-Temporal Values to Infer Recency
- **Reason:** Prevents incorrect results in time-series analysis.
- **Priority:** ❌ Won't
- **Description:** Never use MAX() on non-temporal columns (like status or category) to infer the most recent record, as MAX operates lexicographically and doesn't consider time. Instead, use ARG_MAX() with explicit timestamp columns for proper temporal ordering. This practice prevents incorrect analytical results and ensures proper time-series handling. By using appropriate functions for temporal analysis, teams can ensure accurate and reliable analytical outputs.

### Data Quality & Testing

**Category Description:** Practices for ensuring data quality, validation, and testing throughout the SQL development lifecycle.

#### ✅ Enforce Single-Object Policy
- **Reason:** Improves maintainability, enables clear ownership, and supports CI validation.
- **Priority:** 🔴 Must
- **Description:** Each SQL file must contain exactly one CREATE statement with its associated header and explanatory comments, ensuring clear ownership and maintainability. The single-object policy prevents file sprawl and makes it easier to track changes and dependencies. This practice also enables automated validation and CI checks that can verify file structure and content. By limiting each file to one object, teams can maintain cleaner version control history and simplify code review processes.

#### ✅ Validate Data Quality Assertions
- **Reason:** Ensures data integrity and prevents downstream processing errors.
- **Priority:** 🔴 Must
- **Description:** Define and validate primary key uniqueness, NOT NULL constraints, and other data quality assertions to ensure data integrity throughout the processing pipeline. Data quality validation helps catch issues early in the process and prevents corrupted data from affecting downstream analytics. This practice includes implementing checks for expected data ranges, referential integrity, and business rule compliance. By validating data quality assertions, teams can maintain trust in their analytical results and reduce the time spent debugging data issues.

#### ✅ Document Data Lineage
- **Reason:** Maintains transparency and enables impact analysis for changes.
- **Priority:** 🔴 Must
- **Description:** Document data sources, transformation logic, and consumer relationships in SQL headers and comments to maintain clear data lineage and enable impact analysis. Data lineage documentation helps teams understand how data flows through the system and identify downstream effects of changes. This practice includes documenting input sources, processing steps, and output consumers for each SQL object. By maintaining comprehensive data lineage documentation, teams can make informed decisions about changes and ensure that modifications don't break dependent processes.

#### ✅ Implement PK Uniqueness Validation
- **Reason:** Ensures data integrity and prevents duplicate records in analytical datasets.
- **Priority:** 🟡 Should
- **Description:** Implement validation checks for primary key uniqueness to ensure data integrity and prevent duplicate records that can skew analytical results. Primary key validation helps identify data quality issues early in the processing pipeline and ensures that analytical calculations are based on clean, deduplicated data. This practice is essential for maintaining trust in business metrics and preventing incorrect analytical conclusions. By validating primary key uniqueness, teams can ensure that their analytical datasets are reliable and accurate.

#### ✅ Validate Referential Integrity
- **Reason:** Ensures consistent relationships between tables and prevents orphaned records.
- **Priority:** 🟡 Should
- **Description:** Implement checks for referential integrity between related tables to ensure consistent relationships and prevent orphaned records that can cause analytical errors. Referential integrity validation ensures that foreign key relationships are maintained and that analytical queries produce consistent results. This practice helps identify data quality issues and ensures that joins between tables work as expected. By validating referential integrity, teams can maintain data consistency and prevent analytical errors caused by broken relationships.

#### ✅ Check for Unexpected NULL Values
- **Reason:** Prevents analytical errors and ensures complete data coverage in calculations.
- **Priority:** 🟡 Should
- **Description:** Implement validation checks for unexpected NULL values in critical columns to prevent analytical errors and ensure complete data coverage in calculations. NULL value validation helps identify data quality issues that could affect business metrics and ensures that analytical calculations account for missing data appropriately. This practice is essential for maintaining the accuracy of KPIs and preventing incorrect conclusions from incomplete datasets. By checking for unexpected NULL values, teams can ensure that their analytical results are reliable and comprehensive.

#### ❌ Don't Use Blanket DISTINCT
- **Reason:** Hides data quality issues and can mask underlying problems with duplicate records.
- **Priority:** ❌ Won't
- **Description:** Avoid using SELECT DISTINCT without justification, as it hides data quality issues and can mask underlying problems with duplicate records. Instead, use explicit deduplication with ROW_NUMBER() to understand and address the root cause of duplicates. This practice ensures that data quality issues are identified and resolved rather than hidden. By avoiding blanket DISTINCT, teams can maintain awareness of data quality and implement proper deduplication strategies.

#### ❌ Avoid Leading Commas in Lists
- **Reason:** Creates maintenance issues and hinders code readability in team environments.
- **Priority:** ❌ Won't
- **Description:** Avoid using leading commas in multi-line lists, as they create maintenance issues when adding or removing items and hinder code readability. Instead, use trailing commas which are more maintainable and reduce merge conflicts. This practice ensures that SQL code is easy to modify and maintain in collaborative environments. By avoiding leading commas, teams can reduce the likelihood of syntax errors during code modifications.

### Data Visualization & Reporting

**Category Description:** Practices for creating professional reports and visualizations with proper separation of data and presentation logic.

#### ✅ Use SQL for Pivoting and Aggregation
- **Reason:** Keeps business rules in code and supports CI, review, and reproducibility.
- **Priority:** 🔴 Must
- **Description:** Perform all pivoting and aggregation operations in SQL rather than Excel to maintain business logic in code. This practice ensures that data transformations are testable, version-controlled, and reproducible. By keeping complex logic in SQL, teams can apply proper testing and validation before data reaches reporting layers. This approach also enables better performance optimization and maintains a single source of truth for business calculations.

#### ✅ Document Sheet Layout and Dataset Mapping
- **Reason:** Aligns data outputs with reporting artifacts and reduces ambiguity.
- **Priority:** � Should
- **Description:** Document the mapping between SQL outputs, Excel sheets, tables, and charts in file headers or design documentation. Clear documentation ensures that report consumers understand the data sources and transformations applied. This practice helps maintain report integrity when SQL queries are modified and provides context for future report updates. By documenting the complete data flow, teams can ensure that changes to underlying data don't break report layouts unexpectedly.

#### ✅ Separate Data and Presentation Logic
- **Reason:** Enables clean separation of concerns and maintainable code.
- **Priority:** 🔴 Must
- **Description:** Keep data processing logic in SQL and handle all presentation concerns (formatting, styling, layout) in separate configuration files or reporting tools. This separation allows SQL to focus on business logic while presentation layers handle visual formatting. Teams can modify report appearance without touching data logic, and vice versa. This practice also enables better testing of business logic independently from presentation concerns.

#### ❌ Don't Mix Presentation Logic in SQL
- **Reason:** Mixing presentation logic in SQL creates maintenance problems and prevents non-technical users from modifying report layouts.
- **Priority:** ❌ Won't
- **Description:** Avoid embedding presentation concerns like cell formatting, colors, or layout instructions directly in SQL queries. Instead, use clean data outputs that can be styled by reporting tools. Mixing presentation logic in SQL makes queries harder to maintain and prevents separation of concerns. This practice ensures that SQL focuses on data processing while presentation layers handle visual formatting and layout.

#### ❌ Don't Leave Pivoting for Excel
- **Reason:** Hides logic in UI, makes it brittle and untestable, and breaks single source of truth.
- **Priority:** ❌ Won't
- **Description:** Never leave complex pivoting, aggregation, or business logic calculations for Excel to handle, as this hides important business rules in the UI layer. Excel-based logic cannot be properly tested, version-controlled, or reviewed through standard development processes. This practice ensures that all business logic remains in SQL where it can be properly validated and maintained. By keeping calculations in SQL, teams maintain auditability and reproducibility of business metrics.

#### ✅ Use Long-Form Data for Charts
- **Reason:** Enables flexible charting and better data visualization capabilities.
- **Priority:** 🟡 Should
- **Description:** Structure data in long-form format (entity, date, metric_name, value) for chart consumption, as this provides maximum flexibility for visualization tools and enables dynamic chart creation. Long-form data allows users to easily create different chart types and filter data without requiring additional data transformations. This practice supports interactive dashboards and provides better visualization capabilities. By using long-form data structures, teams can create more flexible and user-friendly reporting solutions.

#### ✅ Implement Deterministic Categorization
- **Reason:** Ensures consistent and predictable data grouping in reports and visualizations.
- **Priority:** 🟡 Should
- **Description:** Use explicit CASE statements with clear boundaries for categorizing continuous values into discrete buckets to ensure consistent grouping across reports and visualizations. Deterministic categorization prevents visual inconsistencies and ensures that data is grouped predictably. This practice is essential for maintaining report reliability and preventing confusion from inconsistent categorization. By implementing deterministic categorization, teams can ensure that their reports and visualizations present data consistently and accurately.

#### ❌ Don't Use Compressed Single-File Exports
- **Reason:** Prevents efficient analytical processing and query performance issues.
- **Priority:** ❌ Won't
- **Description:** Avoid exporting data as compressed single-file formats for analytical workloads, as they prevent efficient querying and data access patterns. Instead, use partitioned columnar formats like Parquet that support selective scanning and better analytical performance. Single-file exports are inefficient for analytical use cases and can lead to performance bottlenecks. By using appropriate storage formats, teams can optimize both storage costs and analytical query performance.

---

## 🎯 Final Note for AI Agents

This guide serves as the comprehensive standard for SQL development in the BIS repository. When applying these practices:

1. **Prioritize mandatory practices** - formatting, structure, headers, and idempotent operations
2. **Apply context-aware optimizations** - DuckDB-specific features and performance patterns
3. **Ensure deterministic behavior** - explicit deduplication and stable ordering
4. **Maintain data quality** - validation, lineage, and single-object policy
5. **Document enforcement actions** - log what practices were applied and their impact

**Success Indicators:**
- SQL files pass automated validation and CI checks
- Queries demonstrate predictable performance and results
- Data models support efficient analytical workloads
- Code maintains consistency across team members
- Business stakeholders can trust analytical outputs

**Key Principles:**
- Start with business requirements, not technical constraints
- Prefer explicit, readable code over clever optimizations
- Design for testability and maintainability
- Document decisions and trade-offs
- Focus on delivering business value through reliable analytics



