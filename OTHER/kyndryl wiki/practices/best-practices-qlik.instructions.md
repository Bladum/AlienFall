# Qlik Sense Best Practices & Guidelines for AI Agents - BIS Repository

**Target Audience:** AI Agents, Qlik Developers, Data Engineers  
**Scope:** Comprehensive Qlik Sense development and SQL migration standards  
**Apply to:** All Qlik-related files in BIS repository (`wiki/external/qlik/**`)

---

## 📋 Comprehensive Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Core Principles](#-core-principles)
- [🏗️ Design Patterns](#️-design-patterns)
- [📚 Key Terms](#-key-terms)
- [🔗 Industry References](#-industry-references)
- [📂 Practice Categories](#-practice-categories)
  - [📁 Data Model Design](#data-model-design)
    - [✅ Design for Star Schema](#design-for-star-schema)
    - [✅ Eliminate Synthetic Keys](#eliminate-synthetic-keys)
    - [✅ Avoid Circular Joins](#avoid-circular-joins)
    - [✅ Use Master Calendar Scripts](#use-master-calendar-scripts)
    - [✅ Prefer KEEP Over JOIN for Filtering](#prefer-keep-over-join-for-filtering)
    - [✅ Normalize Dimensions Appropriately](#normalize-dimensions-appropriately)
    - [✅ Validate Data Model with Viewer](#validate-data-model-with-viewer)
    - [✅ Implement Data Reduction Techniques](#implement-data-reduction-techniques)
    - [✅ Document Model Assumptions](#document-model-assumptions)
    - [❌ Avoid Over-Normalization](#avoid-over-normalization)
  - [📁 Script Optimization](#script-optimization)
    - [✅ Organize Scripts into Logical Sections](#organize-scripts-into-logical-sections)
    - [✅ Use Variables for Parameterization](#use-variables-for-parameterization)
    - [✅ Standardize Naming Conventions](#standardize-naming-conventions)
    - [✅ Comment Liberally](#comment-liberally)
    - [✅ Use QUALIFY Selectively](#use-qualify-selectively)
    - [✅ Implement Incremental Loads](#implement-incremental-loads)
    - [✅ Test Loads Incrementally](#test-loads-incrementally)
    - [✅ Use QVDs for Intermediate Storage](#use-qvds-for-intermediate-storage)
    - [✅ Handle NULL Values Explicitly](#handle-null-values-explicitly)
    - [✅ Reset QUALIFY with UNQUALIFY](#reset-qualify-with-unqualify)
    - [❌ Do Not Hardcode Values](#do-not-hardcode-values)
  - [📁 Migration Strategies](#migration-strategies)
    - [✅ Embrace ETL Over Direct Translation](#embrace-etl-over-direct-translation)
    - [✅ Use LOAD...FROM FILE for Production](#use-loadfrom-file-for-production)
    - [✅ Push Complex Aggregations to Source](#push-complex-aggregations-to-source)
    - [✅ Choose Strategy Based on Data Volume](#choose-strategy-based-on-data-volume)
    - [✅ Export to Optimized Formats](#export-to-optimized-formats)
    - [✅ Validate Data Post-Migration](#validate-data-post-migration)
    - [✅ Document Migration Rationale](#document-migration-rationale)
    - [✅ Test with Representative Data](#test-with-representative-data)
    - [✅ Plan for Incremental Migrations](#plan-for-incremental-migrations)
    - [✅ Monitor Source Database Impact](#monitor-source-database-impact)
    - [❌ Avoid Direct Query for Interactive Apps](#avoid-direct-query-for-interactive-apps)
  - [📁 Performance Tuning](#performance-tuning)
    - [✅ Leverage QVDs for Fast Loads](#leverage-qvds-for-fast-loads)
    - [✅ Use WHERE EXISTS for Filtered Loads](#use-where-exists-for-filtered-loads)
    - [✅ Pre-Calculate KPIs in Script](#pre-calculate-kpis-in-script)
    - [✅ Monitor Memory Usage](#monitor-memory-usage)
    - [✅ Optimize JOIN Operations](#optimize-join-operations)
    - [✅ Implement Data Reduction](#implement-data-reduction)
    - [✅ Cache Direct Query Results](#cache-direct-query-results)
    - [✅ Use Connection Pooling](#use-connection-pooling)
    - [✅ Avoid DISTINCT in Large Loads](#avoid-distinct-in-large-loads)
    - [✅ Profile Script Execution](#profile-script-execution)
    - [❌ Do Not Force Complex SQL into Qlik](#do-not-force-complex-sql-into-qlik)
  - [📁 Error Handling and Security](#error-handling-and-security)
    - [✅ Implement Section Access](#implement-section-access)
    - [✅ Validate Data Sources](#validate-data-sources)
    - [✅ Log Errors and Warnings](#log-errors-and-warnings)
    - [✅ Handle Fatal Errors Gracefully](#handle-fatal-errors-gracefully)
    - [✅ Sanitize User Inputs](#sanitize-user-inputs)
    - [✅ Test for Data Quality](#test-for-data-quality)
    - [✅ Implement Backup and Recovery](#implement-backup-and-recovery)
    - [✅ Use Dual-Logger Pattern](#use-dual-logger-pattern)
    - [✅ Monitor for Restricted Modes](#monitor-for-restricted-modes)
    - [✅ Validate YAML Schemas](#validate-yaml-schemas)
    - [❌ Never Expose Secrets](#never-expose-secrets)
  - [📁 Integration and Advanced Concepts](#integration-and-advanced-concepts)
    - [✅ Connect to Multiple Databases](#connect-to-multiple-databases)
    - [✅ Use REST APIs for Data Loading](#use-rest-apis-for-data-loading)
    - [✅ Handle Different Data Formats](#handle-different-data-formats)
    - [✅ Automate Workflows](#automate-workflows)
    - [✅ Implement Version Control](#implement-version-control)
    - [✅ Optimize for Multi-Tenant Scenarios](#optimize-for-multi-tenant-scenarios)
    - [✅ Use Mapping Tables for Complex Logic](#use-mapping-tables-for-complex-logic)
    - [✅ Hide Helper Fields](#hide-helper-fields)
    - [✅ Support Incremental QVDs](#support-incremental-qvds)
    - [✅ Document Integration Points](#document-integration-points)
    - [❌ Avoid Blind QUALIFY Usage](#avoid-blind-qualify-usage)

---

## 🎯 Core Principles

- **Architectural Separation**: Recognize the fundamental differences between OLAP engines like DuckDB and Qlik's in-memory associative model, ensuring each tool is used for its intended purpose to avoid performance bottlenecks and maintainability issues.
- **ETL Paradigm Adoption**: Prioritize extract-transform-load workflows where complex transformations occur in specialized engines, followed by clean data loading into Qlik for associative analysis, maximizing efficiency and scalability.
- **In-Memory Optimization**: Design data models and scripts to leverage Qlik's associative engine strengths, focusing on star schemas and avoiding over-normalization to ensure fast, responsive interactive experiences.
- **Migration Strategy Prioritization**: Choose integration methods based on data volume and complexity, favoring file-based ETL for production over direct translations to prevent spaghetti scripts and degraded performance.
- **Code Hygiene and Standardization**: Maintain organized, parameterized scripts with consistent styling and logical sections to improve readability, debugging, and long-term maintainability across teams.

---

## 🏗️ Design Patterns

- **LOAD *; SQL Pattern**: Connect Qlik to external databases like DuckDB using ODBC/JDBC for direct SQL execution, ideal for prototyping with small datasets where simplicity outweighs transfer overhead.
- **LOAD...FROM FILE Pattern**: Execute complex DuckDB queries separately, export results to optimized formats like Parquet, then load into Qlik for scalable production pipelines with decoupled transformation and loading.
- **Direct Query Pattern**: Enable on-demand database querying without in-memory loading for extremely large datasets, sacrificing some Qlik functionalities for reduced memory usage in monitoring scenarios.
- **Resident Load Chains**: Mimic SQL CTEs and subqueries using sequential LOAD RESIDENT statements in Qlik, allowing multi-step transformations while preserving in-memory efficiency.
- **Hybrid ETL Approach**: Combine DuckDB's analytical power for heavy computations with Qlik's associative model, exporting pre-aggregated data to ensure optimal performance and maintainable code.

---

## 📚 Key Terms

- **Associative Engine**: Qlik's core technology that loads unique field values and associations into RAM, enabling instant, interactive data exploration without pre-aggregated cubes.
- **Synthetic Keys**: Automatically generated keys in Qlik when tables share identical field names, potentially causing performance issues and incorrect results if not addressed.
- **QVD Files**: Qlik's proprietary data format for storing loaded data, enabling fast incremental loads and reducing reliance on source databases.
- **Star Schema**: A data modeling approach with fact tables at the center and dimension tables radiating outward, optimized for Qlik's in-memory associative model.
- **Window Functions**: Analytical functions that perform calculations across related rows, often pre-computed in DuckDB before loading into Qlik due to memory-intensive equivalents.
- **QUALIFY Statement**: A Qlik script command that prefixes field names with table names to prevent synthetic keys and clarify field origins.
- **Resident Loads**: Loading data from previously loaded in-memory tables in Qlik, used for transformations and aggregations without re-accessing sources.
- **Direct Query**: A Qlik mode for querying databases on-demand without loading data into memory, suitable for massive datasets but limiting native functionalities.

---

## 🔗 Industry References

- **Qlik Help Documentation**: Official Qlik resources providing tutorials, scripting fundamentals, and best practices for data loading and modeling.
- **Qlik Community Forums**: User-driven discussions on advanced scripting, performance tuning, and real-world migration challenges.
- **Stack Overflow Qlik Tags**: Community Q&A for troubleshooting script issues, join optimizations, and integration patterns.
- **DuckDB Documentation**: Reference for SQL dialect differences, analytical functions, and export capabilities relevant to Qlik migrations.
- **Data Warehousing Best Practices**: Industry standards from sources like Kimball Group for dimensional modeling and ETL design applicable to Qlik.

---

## 📂 Practice Categories

### 📁 Data Model Design

**Category Description:** Practices focused on building clean, efficient data models in Qlik to support associative analysis and prevent performance issues.

#### ✅ Design for Star Schema
- **Reason:** Ensures optimal performance and usability in Qlik's in-memory engine by centralizing facts and radiating dimensions.
- **Priority:** 🔴 Must
- **Description:** Implement a star schema with fact tables at the center and dimension tables branching out to minimize joins and enable fast associative exploration. This structure aligns with Qlik's strengths in handling denormalized data for interactive dashboards, reducing query complexity and memory overhead. Failure to adopt this can lead to circular references, synthetic keys, and sluggish reloads that degrade user experience and increase maintenance costs.

#### ✅ Eliminate Synthetic Keys
- **Reason:** Prevents automatic key generation that can cause performance degradation and incorrect associations in the data model.
- **Priority:** 🔴 Must
- **Description:** Actively identify and resolve synthetic keys through field renaming, QUALIFY statements, or explicit joins to maintain a clean, predictable data model. Synthetic keys often arise from overlapping field names across tables and can lead to unexpected query results and slower associative operations. Addressing them early ensures data integrity and optimal performance, avoiding the need for complex workarounds later in development.

#### ✅ Avoid Circular Joins
- **Reason:** Prevents infinite loops and performance issues in the associative model that can render applications unusable.
- **Priority:** 🔴 Must
- **Description:** Design data models without circular references by carefully planning table relationships and using appropriate join types or KEEP statements. Circular joins can cause Qlik to struggle with associations, leading to incorrect visualizations and slow response times during user interactions. Resolving them through model restructuring improves reliability and ensures the associative engine functions as intended for seamless data exploration.

#### ✅ Use Master Calendar Scripts
- **Reason:** Provides comprehensive date fields for robust time-based analysis from the outset, enhancing dashboard functionality.
- **Priority:** 🟡 Should
- **Description:** Generate a master calendar table with all necessary date dimensions like quarters, weekdays, and fiscal periods to support flexible temporal analysis. This practice ensures consistent date handling across the application and reduces the need for on-the-fly calculations that can slow down performance. Without it, date-related queries may become cumbersome, leading to duplicated logic and potential errors in reporting.

#### ✅ Prefer KEEP Over JOIN for Filtering
- **Reason:** Preserves original table structures while filtering associations, maintaining model flexibility without physical merging.
- **Priority:** 🟡 Should
- **Description:** Use KEEP statements instead of JOIN when filtering tables based on common keys to avoid altering the base data model unnecessarily. This approach keeps tables separate for better associative exploration while still enforcing relationships, improving maintainability and reducing memory usage. Overusing JOIN can flatten the model prematurely, limiting the dynamic nature of Qlik's associative capabilities.

#### ✅ Normalize Dimensions Appropriately
- **Reason:** Balances data redundancy with performance by avoiding over-normalization that hinders in-memory efficiency.
- **Priority:** 🟡 Should
- **Description:** Apply moderate normalization to dimension tables to reduce storage while ensuring the associative model remains performant and intuitive. Excessive normalization can create complex joins that slow down reloads and queries, whereas under-normalization may lead to data duplication. Striking the right balance supports scalable applications with clear, navigable data structures.

#### ✅ Validate Data Model with Viewer
- **Reason:** Ensures the model is free of issues before building visualizations, preventing downstream problems.
- **Priority:** 🟡 Should
- **Description:** Regularly use Qlik's Data Model Viewer to inspect table structures, associations, and potential synthetic keys for proactive corrections. This tool provides visual insights into the model's health, allowing developers to identify and fix flaws early in the process. Neglecting this can result in hidden issues that surface during user testing, requiring time-consuming revisions.

#### ✅ Implement Data Reduction Techniques
- **Reason:** Limits data scope for specific users or scenarios, improving performance and security in large applications.
- **Priority:** 🟢 Could
- **Description:** Apply section access or data reduction to restrict visible data based on user roles, enhancing both speed and compliance. This practice is particularly useful in multi-tenant environments where not all users need full dataset access, reducing memory footprint and query times. Without it, applications may become sluggish for end-users, impacting adoption and satisfaction.

#### ✅ Document Model Assumptions
- **Reason:** Provides clarity for future maintenance and collaboration, reducing misunderstandings in complex models.
- **Priority:** 🟢 Could
- **Description:** Include comments and documentation within scripts explaining key model decisions, relationships, and assumptions for better team knowledge. This fosters consistency across developers and simplifies troubleshooting when issues arise. Undocumented models can lead to confusion and errors during updates or handoffs.

#### ❌ Avoid Over-Normalization
- **Reason:** Prevents excessive table fragmentation that can degrade in-memory performance and complicate associations.
- **Priority:** ❌ Won't
- **Description:** Refrain from creating highly normalized structures that require numerous joins, as Qlik thrives on denormalized data for fast associative queries. Over-normalization can result in slow reloads and complex scripts that are hard to maintain, ultimately hindering the platform's interactive strengths. Opt instead for balanced schemas that leverage Qlik's capabilities effectively.

### 📁 Script Optimization

**Category Description:** Practices for writing clean, efficient Qlik scripts that enhance readability and maintainability.

#### ✅ Organize Scripts into Logical Sections
- **Reason:** Improves readability and debugging by structuring code into manageable, purpose-driven segments.
- **Priority:** 🔴 Must
- **Description:** Divide scripts into tabs or sections for data loading, transformations, and model building to facilitate easier navigation and updates. This organization allows developers to focus on specific areas without sifting through monolithic code, reducing errors and speeding up development cycles. Disorganized scripts can become unmaintainable, leading to increased debugging time and team frustration.

#### ✅ Use Variables for Parameterization
- **Reason:** Enables easy configuration changes and reduces hardcoding, improving script flexibility and portability.
- **Priority:** 🔴 Must
- **Description:** Define variables for paths, connection strings, and thresholds at the script's beginning to allow quick adjustments without code modifications. This practice supports different environments and simplifies refactoring, enhancing overall script robustness. Hardcoded values can cause deployment issues and make scripts brittle in dynamic settings.

#### ✅ Standardize Naming Conventions
- **Reason:** Ensures consistency across scripts, making them easier to understand and collaborate on within teams.
- **Priority:** 🟡 Should
- **Description:** Adopt consistent casing for keywords, field names, and table aliases to improve code readability and reduce confusion. Uppercase for Qlik keywords and lowercase for custom elements creates a professional, uniform appearance that aids in quick comprehension. Inconsistent naming can lead to errors and slow down team productivity during reviews or handoffs.

#### ✅ Comment Liberally
- **Reason:** Provides context and explanations for complex logic, aiding future maintenance and knowledge transfer.
- **Priority:** 🟡 Should
- **Description:** Include detailed comments for transformations, joins, and business rules to explain the why and how behind the code. This documentation ensures that other developers or future maintainers can quickly grasp the script's purpose and logic. Lack of comments can result in prolonged onboarding and increased risk of misinterpretations during updates.

#### ✅ Use QUALIFY Selectively
- **Reason:** Prevents synthetic keys without overcomplicating field names, maintaining model clarity.
- **Priority:** 🟡 Should
- **Description:** Apply QUALIFY to specific fields or tables where needed to avoid unintended associations, rather than blanket qualifying everything. This targeted approach keeps field names clean while resolving conflicts, improving the data model's usability. Overusing QUALIFY can create unwieldy names that complicate front-end development and user interactions.

#### ✅ Implement Incremental Loads
- **Reason:** Reduces reload times and database load by only processing new or changed data.
- **Priority:** 🟡 Should
- **Description:** Use WHERE clauses with date fields or flags to load only recent data, leveraging QVDs for efficient storage and retrieval. This practice is essential for large datasets to maintain performance and minimize resource usage. Without incremental loads, full refreshes can become prohibitively slow, impacting application timeliness.

#### ✅ Test Loads Incrementally
- **Reason:** Catches issues early in the loading process, preventing cascading errors in the full script.
- **Priority:** 🟡 Should
- **Description:** Run and validate sections of the script individually before full execution to ensure data integrity and correct transformations. This step-by-step approach allows for quick fixes and builds confidence in the final model. Skipping incremental testing can lead to undetected problems that surface only during production, causing downtime.

#### ✅ Use QVDs for Intermediate Storage
- **Reason:** Provides fast, optimized data storage that accelerates subsequent loads and reduces source database strain.
- **Priority:** 🟡 Should
- **Description:** Store processed data in QVD format after initial loads to enable quick reloads and incremental updates, acting as a reusable data layer. This format is native to Qlik and supports compressed, indexed storage for better performance. Avoiding QVDs can result in repeated heavy queries against sources, slowing down the entire pipeline.

#### ✅ Handle NULL Values Explicitly
- **Reason:** Prevents unexpected behavior in associations and calculations that can distort analysis results.
- **Priority:** 🟢 Could
- **Description:** Use functions like IsNull() or NullAsValue() to manage missing data consistently across the script, ensuring reliable associative behavior. Proper NULL handling maintains data quality and prevents gaps in visualizations that could mislead users. Ignoring NULLs can lead to incomplete analyses and erroneous conclusions in reports.

#### ✅ Reset QUALIFY with UNQUALIFY
- **Reason:** Prevents field name prefixes from persisting unintentionally across script sections.
- **Priority:** 🟢 Could
- **Description:** End QUALIFY blocks with UNQUALIFY * to reset the state, avoiding prefixed names in subsequent loads. This practice maintains clean field names and prevents confusion in the data model. Failing to reset can carry over prefixes, complicating joins and front-end field selections.

#### ❌ Do Not Hardcode Values
- **Reason:** Creates inflexible scripts that are difficult to adapt for different environments or scenarios.
- **Priority:** ❌ Won't
- **Description:** Avoid embedding fixed paths, dates, or thresholds directly in code, as this makes scripts prone to errors during migrations or updates. Hardcoding reduces reusability and increases maintenance overhead, potentially breaking applications in new deployments. Use variables instead to promote adaptability and reduce long-term costs.

### 📁 Migration Strategies

**Category Description:** Practices for effectively migrating SQL logic to Qlik, focusing on strategic integration over direct translation.

#### ✅ Embrace ETL Over Direct Translation
- **Reason:** Leverages platform strengths by performing complex transformations externally before loading into Qlik.
- **Priority:** 🔴 Must
- **Description:** Shift heavy analytical work to DuckDB or similar engines, then load clean results into Qlik for associative analysis, avoiding inefficient script-based replications. This approach capitalizes on each tool's capabilities, resulting in faster reloads and more maintainable code. Direct translations often create performance bottlenecks and unreadable scripts that hinder scalability.

#### ✅ Use LOAD...FROM FILE for Production
- **Reason:** Decouples transformation from loading, enabling scalable pipelines with optimized data transfer.
- **Priority:** 🔴 Must
- **Description:** Execute complex SQL in DuckDB, export to Parquet or similar, and load into Qlik for reliable, high-performance production environments. This method eliminates transfer bottlenecks and supports incremental QVDs, ensuring consistent data flow. Smaller setups may suffice with direct connections, but production demands this separation for stability.

#### ✅ Push Complex Aggregations to Source
- **Reason:** Utilizes DuckDB's OLAP strengths for efficient processing before Qlik loading.
- **Priority:** 🔴 Must
- **Description:** Perform window functions, CTEs, and intricate subqueries in the source database to simplify Qlik scripts and improve overall performance. This division of labor prevents Qlik from handling tasks it's not optimized for, leading to cleaner, faster applications. Attempting these in Qlik can result in memory-intensive operations and slower associative responses.

#### ✅ Choose Strategy Based on Data Volume
- **Reason:** Ensures the selected method matches workload requirements for optimal efficiency.
- **Priority:** 🟡 Should
- **Description:** Opt for LOAD *; SQL for prototyping small datasets, LOAD...FROM FILE for large-scale production, and Direct Query only for massive, read-only scenarios. This tailored approach maximizes performance and minimizes overhead, avoiding one-size-fits-all solutions that underperform. Incorrect strategy selection can lead to slow reloads or limited functionalities.

#### ✅ Export to Optimized Formats
- **Reason:** Reduces file size and improves load speeds in Qlik through efficient data structures.
- **Priority:** 🟡 Should
- **Description:** Use Parquet or native QVD exports from DuckDB to leverage compression and columnar storage for faster Qlik ingestion. These formats are designed for analytical workloads, ensuring quick data transfer and reduced memory usage. Standard formats like CSV can introduce inefficiencies and slower processing times.

#### ✅ Validate Data Post-Migration
- **Reason:** Ensures accuracy and consistency after translating logic, preventing silent errors in the new environment.
- **Priority:** 🟡 Should
- **Description:** Compare row counts, aggregations, and key metrics between source and Qlik to confirm faithful migration of business logic. This validation step catches discrepancies early, maintaining data integrity across platforms. Skipping validation can lead to incorrect insights and loss of trust in the migrated application.

#### ✅ Document Migration Rationale
- **Reason:** Provides context for future changes and helps teams understand strategic decisions.
- **Priority:** 🟡 Should
- **Description:** Record why specific strategies were chosen and how SQL elements were adapted, aiding in maintenance and knowledge sharing. This documentation ensures continuity when team members change or updates are needed. Undocumented migrations can result in repeated mistakes and confusion during enhancements.

#### ✅ Test with Representative Data
- **Reason:** Simulates real-world conditions to identify performance and logic issues before production deployment.
- **Priority:** 🟢 Could
- **Description:** Use subsets or full datasets that mirror production volumes and complexity for thorough testing of migrations. This practice reveals scalability problems early, allowing for optimizations. Testing with minimal data can mask issues that emerge under load, leading to production failures.

#### ✅ Plan for Incremental Migrations
- **Reason:** Allows phased rollouts, reducing risk and enabling feedback-driven improvements.
- **Priority:** 🟢 Could
- **Description:** Break large migrations into stages, starting with core tables and building complexity gradually. This approach minimizes downtime and allows for adjustments based on initial results. Full migrations without phasing can overwhelm teams and introduce widespread errors.

#### ✅ Monitor Source Database Impact
- **Reason:** Ensures migration doesn't overload external systems, maintaining overall ecosystem health.
- **Priority:** 🟢 Could
- **Description:** Track query performance and resource usage on DuckDB during migrations to avoid disruptions in other dependent processes. This monitoring supports sustainable integration and prevents bottlenecks. Ignoring source impact can lead to degraded performance across interconnected systems.

#### ❌ Avoid Direct Query for Interactive Apps
- **Reason:** Sacrifices Qlik's in-memory strengths for database-dependent performance, limiting associative features.
- **Priority:** ❌ Won't
- **Description:** Refrain from using Direct Query in standard applications, as it ties performance to source latency and restricts native Qlik functionalities. This mode is better suited for niche, massive datasets where in-memory loading is impossible. Using it broadly can result in slow, less interactive experiences that undermine Qlik's value proposition.

### 📁 Performance Tuning

**Category Description:** Practices to optimize Qlik applications for speed, memory efficiency, and scalability.

#### ✅ Leverage QVDs for Fast Loads
- **Reason:** Provides compressed, indexed storage that dramatically speeds up data retrieval and reduces reload times.
- **Priority:** 🔴 Must
- **Description:** Store and reload data using QVD files to enable optimized, incremental loads that minimize database queries and improve application responsiveness. This format is native to Qlik and supports fast reads, essential for maintaining performance in growing datasets. Without QVDs, repeated full loads can become unsustainable, leading to longer wait times and user dissatisfaction.

#### ✅ Use WHERE EXISTS for Filtered Loads
- **Reason:** Optimizes QVD reads by maintaining fast access patterns without breaking the optimized load operation.
- **Priority:** 🟡 Should
- **Description:** Apply WHERE EXISTS when filtering data from QVDs to preserve the file's indexing and compression benefits, ensuring quick data retrieval. This practice is crucial for large datasets where standard WHERE clauses could degrade performance. Neglecting this can result in slower loads and increased resource consumption.

#### ✅ Pre-Calculate KPIs in Script
- **Reason:** Offloads computations from the front-end to load time, improving dashboard responsiveness.
- **Priority:** 🟡 Should
- **Description:** Perform heavy aggregations and calculations during script execution rather than in charts to reduce runtime processing and enhance user experience. This approach leverages load-time resources for better overall performance. Front-end calculations can slow down interactions, especially with complex expressions.

#### ✅ Monitor Memory Usage
- **Reason:** Prevents excessive RAM consumption that can cause application instability or crashes.
- **Priority:** 🟡 Should
- **Description:** Track memory allocation during development and optimize data models to stay within system limits, ensuring stable performance. Qlik's in-memory nature makes this critical for large applications. Unmonitored memory can lead to failures and require costly hardware upgrades.

#### ✅ Optimize JOIN Operations
- **Reason:** Reduces processing time and memory overhead by using efficient join types and structures.
- **Priority:** 🟡 Should
- **Description:** Prefer LEFT JOIN or KEEP over full outer joins when possible, and ensure joined fields are indexed for faster operations. Proper join optimization maintains script efficiency and prevents bottlenecks. Inefficient joins can exponentially increase load times and complicate the data model.

#### ✅ Implement Data Reduction
- **Reason:** Limits data scope to improve load speeds and focus on relevant information for users.
- **Priority:** 🟢 Could
- **Description:** Use section access or calculated reductions to present only necessary data, enhancing performance for specific user groups. This is particularly effective in multi-tenant scenarios. Without reduction, applications may handle unnecessary data, slowing down operations.

#### ✅ Cache Direct Query Results
- **Reason:** Improves response times for repeated queries by storing results temporarily.
- **Priority:** 🟢 Could
- **Description:** Enable caching in Direct Query mode to reduce database round-trips for common requests, balancing performance with real-time needs. This feature mitigates some latency issues inherent in the mode. Disabled caching can make Direct Query feel sluggish for interactive use.

#### ✅ Use Connection Pooling
- **Reason:** Manages database connections efficiently, reducing overhead and improving concurrent load performance.
- **Priority:** 🟢 Could
- **Description:** Configure DirectConnectionMax for ODBC/JDBC to enable pooled connections, allowing multiple simultaneous queries without exhausting resources. This is vital for high-throughput scenarios. Without pooling, connections can become a bottleneck, slowing down the entire pipeline.

#### ✅ Avoid DISTINCT in Large Loads
- **Reason:** Prevents memory-intensive operations that can slow down processing and increase resource usage.
- **Priority:** 🟢 Could
- **Description:** Minimize DISTINCT usage in LOAD statements for big datasets, opting for pre-aggregated data from sources instead. This practice maintains efficiency in Qlik's associative model. Overusing DISTINCT can lead to prolonged load times and potential memory issues.

#### ✅ Profile Script Execution
- **Reason:** Identifies bottlenecks and optimization opportunities through detailed performance analysis.
- **Priority:** 🟢 Could
- **Description:** Use Qlik's built-in tools or logging to measure load times and resource usage for each script section, enabling targeted improvements. Profiling provides data-driven insights for enhancements. Without it, optimizations are guesswork, potentially missing critical issues.

#### ❌ Do Not Force Complex SQL into Qlik
- **Reason:** Avoids inefficient replications that can create memory-intensive, hard-to-maintain scripts.
- **Priority:** ❌ Won't
- **Description:** Refrain from translating intricate CTEs or window functions directly into LOAD RESIDENT chains, as this burdens Qlik's sequential engine. Such attempts often result in slow reloads and spaghetti code that complicates debugging. Delegate complex logic to specialized engines for better outcomes.

### 📁 Error Handling and Security

**Category Description:** Practices for robust error management and secure Qlik development.

#### ✅ Implement Section Access
- **Reason:** Enforces row-level security to protect sensitive data and ensure compliance with access policies.
- **Priority:** 🔴 Must
- **Description:** Use Qlik's Section Access to restrict data visibility based on user roles, integrating with enterprise authentication systems. This practice prevents unauthorized access and supports data governance requirements. Without it, sensitive information may be exposed, leading to security breaches and regulatory issues.

#### ✅ Validate Data Sources
- **Reason:** Ensures data integrity and prevents loading corrupted or malicious content.
- **Priority:** 🟡 Should
- **Description:** Check source file integrity and database connections before loads, using checksums or validation queries to confirm data quality. This step protects against errors that could propagate through the application. Unvalidated sources can introduce inconsistencies that affect all downstream analyses.

#### ✅ Log Errors and Warnings
- **Reason:** Provides traceability for troubleshooting and auditing script execution issues.
- **Priority:** 🟡 Should
- **Description:** Capture and store error messages, load statistics, and warnings in logs for review and resolution, improving script reliability. Detailed logging aids in quick problem identification and resolution. Without logs, issues can go unnoticed, leading to persistent problems.

#### ✅ Handle Fatal Errors Gracefully
- **Reason:** Prevents script failures from leaving applications in unusable states.
- **Priority:** 🟡 Should
- **Description:** Use TRY/CATCH or conditional logic to manage critical errors, ensuring partial loads or alternative paths when possible. This maintains application availability even during issues. Ungraceful error handling can result in complete failures, disrupting user access.

#### ✅ Sanitize User Inputs
- **Reason:** Protects against injection attacks and ensures data consistency in dynamic scenarios.
- **Priority:** 🟡 Should
- **Description:** Validate and clean inputs for variables or parameters used in scripts, preventing malicious or malformed data from causing issues. This is crucial for applications with user-driven configurations. Unsanitized inputs can lead to security vulnerabilities or unexpected script behavior.

#### ✅ Test for Data Quality
- **Reason:** Identifies anomalies early to maintain trustworthy analytical results.
- **Priority:** 🟢 Could
- **Description:** Include checks for duplicates, nulls, and outliers during loads, flagging issues for review or correction. This practice ensures the data model supports accurate insights. Poor data quality can undermine the entire application's value and user confidence.

#### ✅ Implement Backup and Recovery
- **Reason:** Provides resilience against data loss or corruption during loads.
- **Priority:** 🟢 Could
- **Description:** Maintain backup QVDs or snapshots to restore from failures, ensuring continuity in production environments. This safeguards against unexpected issues. Without backups, recoveries can be time-consuming and costly.

#### ✅ Use Dual-Logger Pattern
- **Reason:** Captures both technical and business-level information for comprehensive monitoring.
- **Priority:** 🟢 Could
- **Description:** Implement logging that records system events and business metrics, aiding in performance analysis and issue resolution. This dual approach provides richer context for troubleshooting. Single-focus logging may miss important operational insights.

#### ✅ Monitor for Restricted Modes
- **Reason:** Prevents DuckDB from entering error states that halt processing.
- **Priority:** 🟢 Could
- **Description:** Track database health during migrations to restart sessions if restricted modes occur, maintaining pipeline continuity. Awareness of this behavior ensures smooth operations. Ignoring restricted modes can cause unexpected halts in data flows.

#### ✅ Validate YAML Schemas
- **Reason:** Ensures configuration files adhere to standards, preventing misconfigurations.
- **Priority:** 🟢 Could
- **Description:** Check YAML files against canonical schemas before use in scripts, maintaining consistency and reducing errors. This practice supports reliable configurations. Invalid schemas can lead to script failures or incorrect behaviors.

#### ❌ Never Expose Secrets
- **Reason:** Protects sensitive information from unauthorized access and potential breaches.
- **Priority:** ❌ Won't
- **Description:** Avoid hardcoding passwords, keys, or tokens in scripts, using secure vaults or environment variables instead. Exposure can lead to data theft and compliance violations. Always prioritize security to maintain trust and regulatory adherence.

### 📁 Integration and Advanced Concepts

**Category Description:** Practices for integrating Qlik with other systems and handling advanced scripting scenarios.

#### ✅ Connect to Multiple Databases
- **Reason:** Enables comprehensive data integration from diverse sources for richer analyses.
- **Priority:** 🟡 Should
- **Description:** Use appropriate connectors for various databases, ensuring secure and efficient data pulls into Qlik. This supports holistic views across systems. Limited connectivity can result in incomplete datasets and missed insights.

#### ✅ Use REST APIs for Data Loading
- **Reason:** Facilitates real-time or on-demand data integration with external services.
- **Priority:** 🟡 Should
- **Description:** Implement API calls in scripts for dynamic data sources, handling authentication and error responses properly. This expands Qlik's data reach beyond traditional databases. Improper API integration can lead to unreliable data flows and security risks.

#### ✅ Handle Different Data Formats
- **Reason:** Ensures compatibility and efficiency when loading varied data types.
- **Priority:** 🟡 Should
- **Description:** Use appropriate LOAD options for Excel, CSV, JSON, and other formats, optimizing for performance and data integrity. This flexibility supports diverse data landscapes. Mismatched format handling can cause load failures or data corruption.

#### ✅ Automate Workflows
- **Reason:** Reduces manual effort and ensures consistent, timely data refreshes.
- **Priority:** 🟡 Should
- **Description:** Set up scheduled reloads and integrations using Qlik's tools or external schedulers for automated pipelines. Automation improves reliability and frees up resources. Manual processes can introduce delays and errors.

#### ✅ Implement Version Control
- **Reason:** Tracks changes and enables collaboration on scripts and applications.
- **Priority:** 🟡 Should
- **Description:** Use Git or similar for script versioning, allowing rollbacks and team collaboration on Qlik developments. This practice supports iterative improvements. Without version control, changes can be lost or conflicting.

#### ✅ Optimize for Multi-Tenant Scenarios
- **Reason:** Ensures fair resource allocation and data isolation in shared environments.
- **Priority:** 🟢 Could
- **Description:** Design applications with tenant-specific sections and reductions to maintain performance and security across users. This is key for scalable deployments. Poor multi-tenancy can lead to resource contention and data leaks.

#### ✅ Use Mapping Tables for Complex Logic
- **Reason:** Simplifies expressions by replacing nested IFs with clean lookups.
- **Priority:** 🟢 Could
- **Description:** Create mapping tables for category assignments or transformations, improving script readability and performance. This avoids complex front-end calculations. Overly nested logic can slow down expressions and complicate maintenance.

#### ✅ Hide Helper Fields
- **Reason:** Keeps the data model user-friendly by concealing internal fields.
- **Priority:** 🟢 Could
- **Description:** Use HidePrefix to remove utility fields from user selections, focusing on business-relevant data. This enhances the front-end experience. Visible helper fields can confuse users and clutter interfaces.

#### ✅ Support Incremental QVDs
- **Reason:** Enables efficient updates without full reloads for large datasets.
- **Priority:** 🟢 Could
- **Description:** Implement logic to append new data to existing QVDs, reducing load times and resource usage. This is essential for growing data volumes. Full reloads can become inefficient as data scales.

#### ✅ Document Integration Points
- **Reason:** Provides clarity on external dependencies and data flows.
- **Priority:** 🟢 Could
- **Description:** Detail connections, APIs, and workflows in documentation for easier maintenance and troubleshooting. This supports long-term sustainability. Undocumented integrations can lead to confusion during updates.

#### ❌ Avoid Blind QUALIFY Usage
- **Reason:** Prevents unnecessarily complex field names that can hinder usability and development.
- **Priority:** ❌ Won't
- **Description:** Refrain from applying QUALIFY to all fields without purpose, as it can create unwieldy names and complicate front-end work. Selective use maintains clarity. Over-qualification can make scripts harder to read and maintain.
