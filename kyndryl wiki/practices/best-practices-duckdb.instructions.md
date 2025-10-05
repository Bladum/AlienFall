# DuckDB Best Practices & Guidelines for AI Agents - BIS Repository

<a id="top"></a>

**Target Audience:** AI Agents, Data Engineers, Python Developers  
**Scope:** Comprehensive DuckDB usage and integration standards  
**Apply to:** All DuckDB-related files and code in BIS repository (`engine/src/**/duckdb*`, `engine/data/**/*.db`, `engine/data/**/*.parquet`, `engine/data/**/*.csv`)

---

## 📋 Comprehensive Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Core Principles](#-core-principles)
- [🏗️ Design Patterns](#️-design-patterns)
- [📚 Key Terms](#-key-terms)
- [🔗 Industry References](#-industry-references)
- [📂 Practice Categories](#-practice-categories)
  - [📁 Data Import and Export](#data-import-and-export)
    - [✅ Use Compression for Input Files](#use-compression-for-input-files)
    - [✅ Provide Column Names for Headerless Files](#provide-column-names-for-headerless-files)
    - [❌ Import Files with Unknown or Unsupported Encoding](#import-files-with-unknown-or-unsupported-encoding)
    - [✅ Use Parquet and JSON Readers for Direct Analysis](#use-parquet-and-json-readers-for-direct-analysis)
    - [✅ Use COPY for Schema Enforcement](#use-copy-for-schema-enforcement)
    - [❌ Use Default Settings for Non-Standard Files](#use-default-settings-for-non-standard-files)
    - [✅ Use Bulk Loading Methods for Large Data](#use-bulk-loading-methods-for-large-data)
    - [✅ Specify Column Types Explicitly When Needed](#specify-column-types-explicitly-when-needed)
    - [✅ Use Auto-Detection for Standard CSVs](#use-auto-detection-for-standard-csvs)
    - [✅ Use the CSV Sniffer for Complex Files](#use-the-csv-sniffer-for-complex-files)
    - [✅ Use `union_by_name` for Schema Evolution](#use-union_by_name-for-schema-evolution)
    - [❌ Use INSERT for Bulk Data Loads](#use-insert-for-bulk-data-loads)
    - [❌ Ignore CSV Errors Without Review](#ignore-csv-errors-without-review)
    - [❌ Overwrite Data Without Backups](#overwrite-data-without-backups)
  - [📁 Data Quality and Validation](#data-quality-and-validation)
    - [✅ Use Error Tables for Faulty CSVs](#use-error-tables-for-faulty-csvs)
    - [✅ Use Projection Pushdown for Selective Import](#use-projection-pushdown-for-selective-import)
    - [❌ Ignore CSV Structure Warnings](#ignore-csv-structure-warnings)
    - [✅ Use Rejects Limit for Large Imports](#use-rejects-limit-for-large-imports)
    - [✅ Use Strict Mode for Critical Imports](#use-strict-mode-for-critical-imports)
    - [❌ Ignore Warnings About Truncated or Corrupt Rows](#ignore-warnings-about-truncated-or-corrupt-rows)
    - [✅ Validate Data Types and Schemas](#validate-data-types-and-schemas)
    - [✅ Use Rejects Table for Faulty CSVs](#use-rejects-table-for-faulty-csvs)
    - [✅ Override Auto-Detection When Needed](#override-auto-detection-when-needed)
    - [✅ Store and Analyze Faulty Rows](#store-and-analyze-faulty-rows)
    - [❌ Ignore Data Type Mismatches](#ignore-data-type-mismatches)
    - [❌ Suppress or Discard Error Messages](#suppress-or-discard-error-messages)
  - [📁 Performance Optimization](#performance-optimization)
    - [✅ Use Out-of-Core Processing for Large Data](#use-out-of-core-processing-for-large-data)
    - [✅ Use Appender for High-Volume Inserts](#use-appender-for-high-volume-inserts)
    - [✅ Use Parquet for Analytical Workloads](#use-parquet-for-analytical-workloads)
    - [✅ Leverage Parallel CSV Reading](#leverage-parallel-csv-reading)
    - [✅ Profile Queries for Bottlenecks](#profile-queries-for-bottlenecks)
    - [✅ Tune Buffer and Sample Size for Large Files](#tune-buffer-and-sample-size-for-large-files)
    - [❌ Overuse Small Transactions](#overuse-small-transactions)
  - [📁 Advanced Usage and Configuration](#advanced-usage-and-configuration)
    - [✅ Use Custom Delimiters and Quote Characters](#use-custom-delimiters-and-quote-characters)
    - [✅ Use Hive Partitioning for Directory-Based Data](#use-hive-partitioning-for-directory-based-data)
    - [✅ Use Union by Name for Multi-File Loads](#use-union-by-name-for-multi-file-loads)
    - [❌ Disable Parallel Import Without Reason](#disable-parallel-import-without-reason)
    - [✅ Use Custom Date and Timestamp Formats](#use-custom-date-and-timestamp-formats)
    - [✅ Use Parallel Import for Multi-File Loads](#use-parallel-import-for-multi-file-loads)
    - [❌ Disable Auto-Detection Without Providing Alternatives](#disable-auto-detection-without-providing-alternatives)
    - [✅ Use Appender API for Programmatic Bulk Loads](#use-appender-api-for-programmatic-bulk-loads)
    - [✅ Tune Buffer and Sample Size for Large Files](#tune-buffer-and-sample-size-for-large-files)
    - [✅ Use Virtual Columns for Provenance Tracking](#use-virtual-columns-for-provenance-tracking)
    - [❌ Ignore File Encoding Issues](#ignore-file-encoding-issues)
  - [📁 Concurrency and Transactions](#concurrency-and-transactions)
    - [✅ Use Single-Process Writes](#use-single-process-writes)
    - [✅ Handle Transaction Conflicts Gracefully](#handle-transaction-conflicts-gracefully)
    - [✅ Use Transactions for Data Integrity](#use-transactions-for-data-integrity)
    - [❌ Write from Multiple Processes Simultaneously](#write-from-multiple-processes-simultaneously)
  - [📁 Data Export and Interoperability](#data-export-and-interoperability)
    - [✅ Use `COPY ... TO` for Efficient Data Export](#use-copy--to-for-efficient-data-export)
    - [✅ Specify Compression for Large Exports](#specify-compression-for-large-exports)
  - [📁 Security and Compliance](#security-and-compliance)
    - [✅ Validate All External Data Sources](#validate-all-external-data-sources)
    - [✅ Audit Data Lineage with Virtual Columns](#audit-data-lineage-with-virtual-columns)
    - [❌ Store Sensitive Data in Unencrypted Files](#store-sensitive-data-in-unencrypted-files)
  - [📁 Operations, Maintenance, and Troubleshooting](#operations-maintenance-and-troubleshooting)
    - [✅ Schedule Regular Backups of Persistent Databases](#schedule-regular-backups-of-persistent-databases)
    - [✅ Monitor Disk Space and Resource Usage](#monitor-disk-space-and-resource-usage)
    - [✅ Test Upgrades in Staging Before Production](#test-upgrades-in-staging-before-production)
    - [✅ Document and Automate Recovery Procedures](#document-and-automate-recovery-procedures)
    - [✅ Log All Import and Export Operations](#log-all-import-and-export-operations)
    - [❌ Ignore DuckDB Release Notes and Known Issues](#ignore-duckdb-release-notes-and-known-issues)
    - [❌ Operate Without Monitoring or Alerting](#operate-without-monitoring-or-alerting)
  - [📁 Query Optimization and Analytics](#query-optimization-and-analytics)
    - [✅ Use Indexes for Frequent Queries](#use-indexes-for-frequent-queries)
    - [✅ Optimize Joins and Aggregations](#optimize-joins-and-aggregations)
    - [✅ Use DuckDB Extensions for External Integrations](#use-duckdb-extensions-for-external-integrations)
    - [❌ Execute Complex Queries Without Profiling](#execute-complex-queries-without-profiling)
  - [📁 Security and Data Protection](#security-and-data-protection)
    - [✅ Use Parameterized Queries to Prevent Injection](#use-parameterized-queries-to-prevent-injection)
    - [✅ Implement Access Controls and Encryption](#implement-access-controls-and-encryption)
    - [❌ Expose DuckDB Databases Directly to Untrusted Users](#expose-duckdb-databases-directly-to-untrusted-users)
  - [📁 Advanced Features and Best Practices](#advanced-features-and-best-practices)
    - [✅ Use DuckDB's JSON Functions for Complex Data](#use-duckdbs-json-functions-for-complex-data)
    - [✅ Implement Data Partitioning for Large Tables](#implement-data-partitioning-for-large-tables)
    - [❌ Over-Rely on In-Memory Mode for Persistent Data](#over-rely-on-in-memory-mode-for-persistent-data)
- [🏗️ Design Patterns](#️-design-patterns)
- [📚 Key Terms](#-key-terms)
- [🔗 Industry References](#-industry-references)
- [📂 Practice Categories](#-practice-categories)
  - [📁 Data Import and Export](#data-import-and-export)
    - [✅ Use Compression for Input Files](#use-compression-for-input-files)
    - [✅ Provide Column Names for Headerless Files](#provide-column-names-for-headerless-files)
    - [❌ Import Files with Unknown or Unsupported Encoding](#import-files-with-unknown-or-unsupported-encoding)
    - [✅ Use Parquet and JSON Readers for Direct Analysis](#use-parquet-and-json-readers-for-direct-analysis)
    - [✅ Use COPY for Schema Enforcement](#use-copy-for-schema-enforcement)
    - [❌ Use Default Settings for Non-Standard Files](#use-default-settings-for-non-standard-files)
    - [✅ Use Bulk Loading Methods for Large Data](#use-bulk-loading-methods-for-large-data)
    - [✅ Specify Column Types Explicitly When Needed](#specify-column-types-explicitly-when-needed)
    - [✅ Use Auto-Detection for Standard CSVs](#use-auto-detection-for-standard-csvs)
    - [✅ Use the CSV Sniffer for Complex Files](#use-the-csv-sniffer-for-complex-files)
    - [✅ Use `union_by_name` for Schema Evolution](#use-union_by_name-for-schema-evolution)
    - [❌ Use INSERT for Bulk Data Loads](#use-insert-for-bulk-data-loads)
    - [❌ Ignore CSV Errors Without Review](#ignore-csv-errors-without-review)
    - [❌ Overwrite Data Without Backups](#overwrite-data-without-backups)
  - [📁 Data Quality and Validation](#data-quality-and-validation)
    - [✅ Use Error Tables for Faulty CSVs](#use-error-tables-for-faulty-csvs)
    - [✅ Use Projection Pushdown for Selective Import](#use-projection-pushdown-for-selective-import)
    - [❌ Ignore CSV Structure Warnings](#ignore-csv-structure-warnings)
    - [✅ Use Rejects Limit for Large Imports](#use-rejects-limit-for-large-imports)
    - [✅ Use Strict Mode for Critical Imports](#use-strict-mode-for-critical-imports)
    - [❌ Ignore Warnings About Truncated or Corrupt Rows](#ignore-warnings-about-truncated-or-corrupt-rows)
    - [✅ Validate Data Types and Schemas](#validate-data-types-and-schemas)
    - [✅ Use Rejects Table for Faulty CSVs](#use-rejects-table-for-faulty-csvs)
    - [✅ Override Auto-Detection When Needed](#override-auto-detection-when-needed)
    - [✅ Store and Analyze Faulty Rows](#store-and-analyze-faulty-rows)
    - [❌ Ignore Data Type Mismatches](#ignore-data-type-mismatches)
    - [❌ Suppress or Discard Error Messages](#suppress-or-discard-error-messages)
  - [📁 Performance Optimization](#performance-optimization)
    - [✅ Use Out-of-Core Processing for Large Data](#use-out-of-core-processing-for-large-data)
    - [✅ Use Appender for High-Volume Inserts](#use-appender-for-high-volume-inserts)
    - [✅ Use Parquet for Analytical Workloads](#use-parquet-for-analytical-workloads)
    - [✅ Leverage Parallel CSV Reading](#leverage-parallel-csv-reading)
    - [✅ Profile Queries for Bottlenecks](#profile-queries-for-bottlenecks)
    - [✅ Tune Buffer and Sample Size for Large Files](#tune-buffer-and-sample-size-for-large-files)
    - [❌ Overuse Small Transactions](#overuse-small-transactions)
  - [📁 Advanced Usage and Configuration](#advanced-usage-and-configuration)
    - [✅ Use Custom Delimiters and Quote Characters](#use-custom-delimiters-and-quote-characters)
    - [✅ Use Hive Partitioning for Directory-Based Data](#use-hive-partitioning-for-directory-based-data)
    - [✅ Use Union by Name for Multi-File Loads](#use-union-by-name-for-multi-file-loads)
    - [❌ Disable Parallel Import Without Reason](#disable-parallel-import-without-reason)
    - [✅ Use Custom Date and Timestamp Formats](#use-custom-date-and-timestamp-formats)
    - [✅ Use Parallel Import for Multi-File Loads](#use-parallel-import-for-multi-file-loads)
    - [❌ Disable Auto-Detection Without Providing Alternatives](#disable-auto-detection-without-providing-alternatives)
    - [✅ Use Appender API for Programmatic Bulk Loads](#use-appender-api-for-programmatic-bulk-loads)
    - [✅ Tune Buffer and Sample Size for Large Files](#tune-buffer-and-sample-size-for-large-files)
    - [✅ Use Virtual Columns for Provenance Tracking](#use-virtual-columns-for-provenance-tracking)
    - [❌ Ignore File Encoding Issues](#ignore-file-encoding-issues)
  - [📁 Concurrency and Transactions](#concurrency-and-transactions)
    - [✅ Use Single-Process Writes](#use-single-process-writes)
    - [✅ Handle Transaction Conflicts Gracefully](#handle-transaction-conflicts-gracefully)
    - [✅ Use Transactions for Data Integrity](#use-transactions-for-data-integrity)
    - [❌ Write from Multiple Processes Simultaneously](#write-from-multiple-processes-simultaneously)
  - [📁 Data Export and Interoperability](#data-export-and-interoperability)
    - [✅ Use `COPY ... TO` for Efficient Data Export](#use-copy--to-for-efficient-data-export)
    - [✅ Specify Compression for Large Exports](#specify-compression-for-large-exports)
  - [📁 Security and Compliance](#security-and-compliance)
    - [✅ Validate All External Data Sources](#validate-all-external-data-sources)
    - [✅ Audit Data Lineage with Virtual Columns](#audit-data-lineage-with-virtual-columns)
    - [❌ Store Sensitive Data in Unencrypted Files](#store-sensitive-data-in-unencrypted-files)

---

## 🎯 Core Principles

- **Data Integrity First**: Always prioritize the accuracy and consistency of data when using DuckDB, as errors in data import or schema can propagate through analytical workflows and lead to incorrect results.
- **Efficient Data Handling**: Use DuckDB's optimized bulk loading and columnar storage features to handle large datasets efficiently, minimizing memory and processing overhead.
- **Explicitness Over Implicitness**: Prefer explicit configuration of data types, file formats, and connection modes to avoid ambiguity and ensure reproducible results.
- **Safe Concurrency**: Respect DuckDB's concurrency model by limiting writes to a single process and handling transaction conflicts appropriately to prevent data corruption.
- **Transparent Error Handling**: Always review and address errors during data import, using rejects tables and validation tools to ensure data quality and traceability.

---

## 🏗️ Design Patterns

- **Bulk Loading Pattern**: Use `COPY` or `read_csv` for efficient ingestion of large datasets, reducing per-row overhead and improving performance compared to row-wise inserts.
- **Schema-First Pattern**: Define table schemas explicitly before importing data to ensure correct data types and prevent auto-detection errors, especially with ambiguous or inconsistent files.
- **Single-Writer Pattern**: Restrict write operations to a single process or use application-level locking to avoid concurrency issues, following DuckDB's recommended model for safe writes.
- **Rejects Table Pattern**: Enable and review rejects tables when importing data to capture and analyze faulty rows, supporting robust data cleaning and validation workflows.
- **Parquet-First Pattern**: Prefer Parquet files for analytical workloads due to their efficient columnar storage and fast query performance in DuckDB.

---

## 📚 Key Terms

- **Persistent Database**: A DuckDB database stored on disk, ensuring data is retained across sessions and process restarts.
- **In-Memory Database**: A DuckDB database that exists only in RAM, providing fast access but losing all data when the process ends.
- **Bulk Loading**: The process of importing large volumes of data efficiently using methods like `COPY` or `read_csv`, as opposed to row-wise `INSERT` statements.
- **Rejects Table**: Temporary tables created by DuckDB to store information about faulty lines encountered during CSV import, aiding in data cleaning and error analysis.
- **Auto-Detection**: DuckDB's feature for automatically inferring file formats, delimiters, and data types when importing data, which can be overridden for greater control.
- **Transaction Conflict**: An error that occurs when multiple threads or processes attempt to modify the same data simultaneously, requiring conflict resolution or retries.
- **Parquet File**: A columnar storage file format optimized for analytical queries, supported natively by DuckDB for fast data access.
- **CSV Sniffer**: DuckDB's tool for analyzing CSV files to detect delimiters, headers, and data types automatically before import.

---

## 🔗 Industry References

- **DuckDB Official Documentation**: Comprehensive resource for DuckDB features, usage, and best practices ([duckdb.org](https://duckdb.org/)).
- **DuckDB GitHub Repository**: Source code and issue tracker for DuckDB development ([github.com/duckdb/duckdb](https://github.com/duckdb/duckdb)).
- **Parquet Format Specification**: Details on the Parquet file format, widely used for analytical data storage ([parquet.apache.org](https://parquet.apache.org/)).
- **CSV on the Web (W3C)**: Industry standard for CSV file structure and best practices ([w3.org/TR/tabular-data-model/](https://www.w3.org/TR/tabular-data-model/)).
- **OWASP Data Validation Cheat Sheet**: Security best practices for data validation and import ([owasp.org](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html)).

---

## 📂 Practice Categories

**Category Description:** This section organizes DuckDB best practices into logical categories, covering connection management, data import/export, concurrency, performance, and data validation for robust analytics in BIS.

### 📁 Data Import and Export

#### ✅ Use Compression for Input Files
- **Reason:** Reduces storage and speeds up import of large files.
- **Priority:** 🟢 Could
- **Description:** When importing large CSV, Parquet, or JSON files, use supported compression formats (gzip, zstd) to save disk space and accelerate data transfer. In BIS, this is especially useful for cloud-based or bandwidth-constrained environments.

#### ✅ Provide Column Names for Headerless Files
- **Reason:** Ensures correct column mapping and prevents auto-generated names.
- **Priority:** 🟡 Should
- **Description:** For files without headers, always provide explicit column names using the `names` option. This avoids confusion and ensures data is mapped correctly in BIS workflows.

#### ❌ Import Files with Unknown or Unsupported Encoding
- **Reason:** Unsupported encodings can cause silent data corruption or import failures.
- **Priority:** ❌ Won't
- **Description:** Never import files with unknown or unsupported encodings. Always convert files to UTF-8, UTF-16, or Latin-1 before import. In BIS, this prevents subtle data loss and ensures compatibility.

### 📁 Data Quality and Validation

#### ✅ Use Error Tables for Faulty CSVs
- **Reason:** Enables detailed analysis and remediation of import errors.
- **Priority:** 🟡 Should
- **Description:** Configure DuckDB to store faulty lines in error tables (`rejects_table`, `rejects_scan`) for later review. In BIS, this supports robust data cleaning and auditability.

#### ✅ Use Projection Pushdown for Selective Import
- **Reason:** Improves performance and avoids unnecessary type errors.
- **Priority:** 🟡 Should
- **Description:** When only a subset of columns is needed, use projection pushdown (selecting only required columns) to speed up import and avoid errors in irrelevant columns. In BIS, this is useful for partial data loads and targeted analytics.

#### ❌ Ignore CSV Structure Warnings
- **Reason:** Structural warnings (e.g., missing/extra columns) can indicate data quality issues.
- **Priority:** ❌ Won't
- **Description:** Never ignore warnings about CSV structure. Always investigate and resolve issues with missing or extra columns to ensure data integrity in BIS.

### 📁 Advanced Usage and Configuration

#### ✅ Use Custom Delimiters and Quote Characters
- **Reason:** Ensures correct parsing of non-standard CSVs.
- **Priority:** 🟡 Should
- **Description:** For CSV files with unusual delimiters or quote characters, always specify these options explicitly. In BIS, this prevents misinterpretation and data corruption.

#### ✅ Use Hive Partitioning for Directory-Based Data
- **Reason:** Enables automatic partition detection and efficient querying.
- **Priority:** 🟢 Could
- **Description:** When importing data organized in Hive-style partitioned directories, enable `hive_partitioning` to automatically extract partition columns. In BIS, this simplifies analytics on large, partitioned datasets.

#### ✅ Use Union by Name for Multi-File Loads
- **Reason:** Handles schema drift and missing columns across files.
- **Priority:** 🟡 Should
- **Description:** When importing multiple files with varying schemas, use `union_by_name` to align columns by name and fill missing columns with NULLs. In BIS, this is essential for evolving data sources and historical data integration.

#### ❌ Disable Parallel Import Without Reason
- **Reason:** Disabling parallel import can significantly slow down large data loads.
- **Priority:** ❌ Won't
- **Description:** Never disable parallel import unless required for compatibility or resource constraints. In BIS, parallel import maximizes throughput for large-scale analytics.

### 📁 Security and Compliance

#### ✅ Validate All External Data Sources
- **Reason:** Prevents injection of malicious or malformed data.
- **Priority:** 🔴 Must
- **Description:** Always validate and sanitize data from external sources before import. In BIS, this is critical for security, compliance, and maintaining trusted analytics.

#### ✅ Audit Data Lineage with Virtual Columns
- **Reason:** Supports traceability and compliance requirements.
- **Priority:** 🟡 Should
- **Description:** Use virtual columns (e.g., `filename`) to track the origin of each row when importing from multiple files. In BIS, this enables full data lineage and supports regulatory audits.

#### ❌ Store Sensitive Data in Unencrypted Files
- **Reason:** Unencrypted files are vulnerable to unauthorized access.
- **Priority:** ❌ Won't
- **Description:** Never store sensitive or regulated data in unencrypted files. Always use encryption at rest and in transit for sensitive BIS datasets.
### 📁 Data Import and Export

#### ✅ Use Parquet and JSON Readers for Direct Analysis
- **Reason:** Enables direct querying of Parquet and JSON files without prior import.
- **Priority:** 🟡 Should
- **Description:** Use DuckDB's ability to query Parquet and JSON files directly (e.g., `SELECT * FROM 'file.parquet'`) for fast, ad-hoc analysis and to avoid unnecessary data duplication. In BIS, this is valuable for exploratory analytics and integrating external data sources efficiently.

#### ✅ Use COPY for Schema Enforcement
- **Reason:** Ensures imported data matches a predefined schema.
- **Priority:** 🟡 Should
- **Description:** Prefer the `COPY` statement when you need to enforce a specific table schema during import. This prevents type inference errors and ensures data consistency, especially when onboarding critical datasets in BIS.

#### ❌ Use Default Settings for Non-Standard Files
- **Reason:** Default import settings may misinterpret delimiters, encodings, or headers in non-standard files.
- **Priority:** ❌ Won't
- **Description:** Never rely on default import settings for files with unusual delimiters, encodings, or missing headers. Always specify options explicitly to avoid data corruption or misinterpretation in BIS workflows.

### 📁 Performance Optimization

#### ✅ Use Out-of-Core Processing for Large Data
- **Reason:** Enables analysis of datasets larger than available memory.
- **Priority:** 🟡 Should
- **Description:** Leverage DuckDB's out-of-core processing (automatic disk spilling) for analytical workloads that exceed RAM. This allows BIS to process very large datasets efficiently without manual intervention.

#### ✅ Use Appender for High-Volume Inserts
- **Reason:** Reduces overhead for programmatic bulk data ingestion.
- **Priority:** 🟡 Should
- **Description:** For high-frequency inserts from code, use the Appender API instead of repeated SQL `INSERT` statements. This approach is more efficient and scalable for ETL and streaming scenarios in BIS.

### 📁 Data Quality and Validation

#### ✅ Use Rejects Limit for Large Imports
- **Reason:** Prevents excessive memory usage and log bloat during error-prone imports.
- **Priority:** 🟡 Should
- **Description:** Set the `rejects_limit` parameter when importing large or messy files to cap the number of faulty rows stored in the rejects table. In BIS, this helps manage resources and keeps error logs actionable.

#### ✅ Use Strict Mode for Critical Imports
- **Reason:** Enforces strict validation and halts on any data inconsistency.
- **Priority:** 🟡 Should
- **Description:** Enable `strict_mode` when importing critical datasets to ensure that any structural or type error halts the import. This guarantees only valid data enters BIS analytics pipelines.

#### ❌ Ignore Warnings About Truncated or Corrupt Rows
- **Reason:** Truncated or corrupt rows can lead to silent data loss or misinterpretation.
- **Priority:** ❌ Won't
- **Description:** Never ignore warnings about truncated or corrupt rows during import. Always investigate and resolve such issues to maintain data integrity in BIS.

### 📁 Advanced Usage and Configuration

#### ✅ Use Custom Date and Timestamp Formats
- **Reason:** Ensures correct parsing of non-ISO date and timestamp fields.
- **Priority:** 🟡 Should
- **Description:** Specify `dateformat` and `timestampformat` options when importing files with non-standard date or timestamp formats. In BIS, this prevents misinterpretation of temporal data and supports internationalization.

#### ✅ Use Parallel Import for Multi-File Loads
- **Reason:** Maximizes throughput when importing many files.
- **Priority:** 🟡 Should
- **Description:** When importing data from multiple files, enable or tune parallel import settings to utilize available CPU resources. In BIS, this accelerates onboarding of large, partitioned datasets.

#### ❌ Disable Auto-Detection Without Providing Alternatives
- **Reason:** Disabling auto-detection without specifying options can cause import failures or misinterpretation.
- **Priority:** ❌ Won't
- **Description:** Never disable auto-detection (e.g., `auto_detect=false`) unless you provide all necessary options (delimiter, header, types, etc.). In BIS, this ensures robust and predictable data import behavior.


### 📁 Database Connection and Persistence

#### ✅ Use Persistent Databases for Production
- **Reason:** Ensures data durability and recoverability across sessions and system restarts.
- **Priority:** 🔴 Must
- **Description:** Always use persistent DuckDB databases (by specifying a file path) for production workloads or any scenario where data must be retained. This practice prevents accidental data loss and supports reliable analytics pipelines. In BIS, persistent databases are essential for maintaining tenant data and supporting reproducible results.

#### ✅ Prefer In-Memory Databases for Testing
- **Reason:** Provides fast, isolated environments for development and testing.
- **Priority:** 🟡 Should
- **Description:** Use in-memory DuckDB databases (by passing `:memory:`) for unit tests, prototyping, or temporary data processing where persistence is not required. This approach speeds up test execution and avoids polluting production data. In BIS, in-memory databases are ideal for isolated test runs and rapid prototyping.

#### ❌ Rely on In-Memory Databases for Critical Data
- **Reason:** In-memory databases lose all data when the process ends, risking permanent data loss.
- **Priority:** ❌ Won't
- **Description:** Never use in-memory DuckDB databases for production or critical data storage, as all data will be lost on process termination. This can lead to irrecoverable data loss and failed analytics workflows in BIS.

### 📁 Data Import and Export

#### ✅ Use Bulk Loading Methods for Large Data
- **Reason:** Significantly improves data import performance and reduces resource usage.
- **Priority:** 🔴 Must
- **Description:** Always use DuckDB's `COPY` statement or `read_csv` function for importing large datasets, as these methods are optimized for bulk loading and avoid the overhead of row-wise `INSERT` statements. In BIS, this ensures efficient ingestion of analytical data and supports scalable data pipelines.

#### ✅ Specify Column Types Explicitly When Needed
- **Reason:** Prevents type inference errors and ensures data consistency.
- **Priority:** 🟡 Should
- **Description:** Explicitly define column types when importing data with ambiguous or inconsistent formats, especially for dates and numbers. This avoids auto-detection mistakes and ensures correct schema enforcement. In BIS, explicit typing is critical for reliable analytics and downstream processing.

#### ✅ Use Auto-Detection for Standard CSVs
- **Reason:** Simplifies import workflows for well-formed files.
- **Priority:** 🟢 Could
- **Description:** Leverage DuckDB's auto-detection features for standard, clean CSV files to streamline data import. This reduces manual configuration and speeds up onboarding of new datasets. In BIS, auto-detection is useful for rapid prototyping and exploratory analysis.

#### ❌ Use INSERT for Bulk Data Loads
- **Reason:** Row-wise inserts are slow and resource-intensive for large datasets.
- **Priority:** ❌ Won't
- **Description:** Avoid using `INSERT` statements for loading large volumes of data, as this approach incurs significant overhead and can bottleneck analytics workflows. Always prefer bulk loading methods in BIS for efficiency.

#### ❌ Ignore CSV Errors Without Review
- **Reason:** Unchecked errors can lead to data corruption and inaccurate analytics.
- **Priority:** ❌ Won't
- **Description:** Never ignore errors encountered during CSV import. Always review rejects tables and error logs to identify and address faulty rows. In BIS, ignoring import errors can compromise data quality and lead to misleading results.

### 📁 Concurrency and Transactions

#### ✅ Use Single-Process Writes
- **Reason:** Prevents data corruption and ensures safe concurrent access.
- **Priority:** 🔴 Must
- **Description:** Restrict write operations to a single process when using DuckDB, as multi-process writes are not supported natively. This practice avoids transaction conflicts and maintains database integrity. In BIS, single-process writes are essential for reliable analytics pipelines.

#### ✅ Handle Transaction Conflicts Gracefully
- **Reason:** Ensures robust error handling and data consistency.
- **Priority:** 🟡 Should
- **Description:** Implement logic to detect and handle transaction conflicts, such as retrying failed transactions or alerting users. DuckDB uses optimistic concurrency control, so conflicts may occur during simultaneous updates. In BIS, graceful conflict handling prevents data loss and supports reliable multi-threaded analytics.

#### ✅ Use Transactions for Data Integrity
- **Reason:** Guarantees atomicity and consistency of database operations.
- **Priority:** 🔴 Must
- **Description:** Always use transactions for operations that modify data, ensuring that changes are either fully applied or rolled back in case of errors. This practice maintains data integrity and prevents partial updates in BIS workflows.

#### ❌ Write from Multiple Processes Simultaneously
- **Reason:** Multi-process writes can corrupt the database and are not supported by DuckDB.
- **Priority:** ❌ Won't
- **Description:** Never attempt to write to the same DuckDB database file from multiple processes at once. This can result in transaction conflicts, data corruption, and unpredictable behavior. In BIS, always coordinate writes through a single process or use external locking mechanisms if necessary.

### 📁 Performance Optimization

#### ✅ Use Parquet for Analytical Workloads
- **Reason:** Parquet files offer efficient columnar storage and fast query performance.
- **Priority:** 🟡 Should
- **Description:** Prefer Parquet files for storing and querying large analytical datasets, as DuckDB is optimized for this format. Parquet enables fast scans, efficient compression, and supports advanced analytics in BIS.

#### ✅ Leverage Parallel CSV Reading
- **Reason:** Improves import speed for large files.
- **Priority:** 🟡 Should
- **Description:** Enable parallel CSV reading (default in DuckDB) to speed up data import, especially for large files. This practice maximizes resource utilization and reduces load times in BIS data pipelines.

#### ✅ Profile Queries for Bottlenecks
- **Reason:** Identifies slow operations and guides optimization efforts.
- **Priority:** 🟡 Should
- **Description:** Use DuckDB's query profiling tools to analyze and optimize slow queries. Focus on indexing, join strategies, and file formats to improve performance. In BIS, regular profiling ensures efficient analytics workflows.

#### ❌ Overuse Small Transactions
- **Reason:** Frequent small transactions increase overhead and reduce throughput.
- **Priority:** ❌ Won't
- **Description:** Avoid breaking up large operations into many small transactions, as this can degrade performance and increase processing time. In BIS, batch operations and bulk loading are preferred for efficiency.

### 📁 Data Quality and Validation

#### ✅ Validate Data Types and Schemas
- **Reason:** Ensures imported data matches expected formats and prevents downstream errors.
- **Priority:** 🔴 Must
- **Description:** Always validate data types and schemas before and after import, using explicit type definitions and schema checks. This practice prevents silent data corruption and supports reliable analytics in BIS.

#### ✅ Use Rejects Table for Faulty CSVs
- **Reason:** Facilitates error analysis and data cleaning.
- **Priority:** 🟡 Should
- **Description:** Enable and review rejects tables when importing CSV files to capture faulty rows and error details. This supports robust data cleaning and ensures only valid data enters BIS analytics workflows.

#### ✅ Override Auto-Detection When Needed
- **Reason:** Prevents misinterpretation of ambiguous or non-standard files.
- **Priority:** 🟡 Should
- **Description:** Manually override auto-detected settings (delimiter, header, types) for files with unusual formats or when auto-detection fails. In BIS, this ensures accurate data import and schema alignment.

#### ❌ Ignore Data Type Mismatches
- **Reason:** Type mismatches can cause data loss, errors, or incorrect analytics.
- **Priority:** ❌ Won't
- **Description:** Never ignore or suppress data type mismatches during import. Always resolve mismatches by correcting schemas or data formats. In BIS, unaddressed type mismatches can compromise data quality and analytics accuracy.
## 📁 Advanced Data Import and Export

#### ✅ Use the CSV Sniffer for Complex Files
- **Reason:** Ensures correct delimiter, header, and type detection for non-standard CSVs.
- **Priority:** 🟡 Should
- **Description:** Use DuckDB's `sniff_csv` function to analyze complex or ambiguous CSV files before import. This helps detect the correct delimiter, quote character, and column types, reducing manual trial and error. In BIS, this practice improves reliability when onboarding diverse external datasets.

#### ✅ Use `union_by_name` for Schema Evolution
- **Reason:** Allows seamless import of files with evolving or mismatched schemas.
- **Priority:** 🟢 Could
- **Description:** When importing multiple CSV files with different or evolving schemas, use the `union_by_name` option to align columns by name and fill missing columns with NULLs. This is especially useful in BIS for incremental data loads and historical data integration.

#### ❌ Overwrite Data Without Backups
- **Reason:** Data overwrites can lead to irreversible loss.
- **Priority:** ❌ Won't
- **Description:** Never overwrite existing DuckDB databases or tables without creating a backup. Always implement backup and restore procedures before performing destructive operations. In BIS, this prevents accidental loss of critical analytics data.

## 📁 Error Handling and Fault Tolerance

#### ✅ Use `ignore_errors` with Caution
- **Reason:** Skipping errors can hide data quality issues.
- **Priority:** 🟡 Should
- **Description:** If you must use the `ignore_errors` option during CSV import, always review the resulting data and the rejects table to ensure no critical information was lost. In BIS, this practice helps maintain data quality while allowing flexible ingestion.

#### ✅ Store and Analyze Faulty Rows
- **Reason:** Enables targeted data cleaning and correction.
- **Priority:** 🟡 Should
- **Description:** Configure DuckDB to store faulty CSV rows in a rejects table for later analysis and remediation. This supports iterative data cleaning and improves the reliability of analytics in BIS.

#### ❌ Suppress or Discard Error Messages
- **Reason:** Hiding errors can lead to undetected data corruption.
- **Priority:** ❌ Won't
- **Description:** Never suppress or ignore error messages during data import or query execution. Always log and review errors to identify root causes and prevent recurring issues in BIS workflows.

## 📁 Query Optimization and Analytics

#### ✅ Use Indexes for Frequent Queries
- **Reason:** Improves query performance for large datasets.
- **Priority:** 🟡 Should
- **Description:** Create indexes on columns frequently used in WHERE clauses, JOINs, or ORDER BY statements. In BIS, this accelerates analytical queries and reduces response times for dashboards and reports.

#### ✅ Optimize Joins and Aggregations
- **Reason:** Reduces query execution time and resource usage.
- **Priority:** 🟡 Should
- **Description:** Use efficient join strategies and minimize unnecessary aggregations. In BIS, optimize complex analytical queries to handle large datasets effectively.

#### ✅ Use DuckDB Extensions for External Integrations
- **Reason:** Enables seamless integration with external databases and systems.
- **Priority:** 🟡 Should
- **Description:** Leverage DuckDB extensions (e.g., MySQL, PostgreSQL, SQLite) for querying external data sources directly. In BIS, this supports federated analytics and reduces data duplication.

#### ❌ Execute Complex Queries Without Profiling
- **Reason:** Unoptimized queries can consume excessive resources and slow down the system.
- **Priority:** ❌ Won't
- **Description:** Never run complex analytical queries in production without profiling and optimization. In BIS, this ensures efficient resource usage and prevents performance bottlenecks.

## 📁 Security and Data Protection

#### ✅ Use Parameterized Queries to Prevent Injection
- **Reason:** Protects against SQL injection attacks.
- **Priority:** 🔴 Must
- **Description:** Always use parameterized queries or prepared statements when executing dynamic SQL. In BIS, this is critical for security when handling user inputs or external data.

#### ✅ Implement Access Controls and Encryption
- **Reason:** Protects sensitive data from unauthorized access.
- **Priority:** 🔴 Must
- **Description:** Use encryption for sensitive data at rest and in transit, and implement proper access controls. In BIS, this ensures compliance with data protection regulations.

#### ❌ Expose DuckDB Databases Directly to Untrusted Users
- **Reason:** Direct access can lead to data breaches or corruption.
- **Priority:** ❌ Won't
- **Description:** Never expose DuckDB databases directly to untrusted users or external applications. In BIS, always use secure APIs or middleware for data access.

## 📁 Advanced Features and Best Practices

#### ✅ Use DuckDB's JSON Functions for Complex Data
- **Reason:** Enables efficient handling of semi-structured data.
- **Priority:** 🟢 Could
- **Description:** Leverage DuckDB's JSON functions for querying and manipulating JSON data. In BIS, this is useful for processing API responses or nested data structures.

#### ✅ Implement Data Partitioning for Large Tables
- **Reason:** Improves query performance and manageability.
- **Priority:** 🟡 Should
- **Description:** Partition large tables by date, category, or other logical keys to speed up queries and maintenance. In BIS, this optimizes analytical workloads on historical data.

#### ❌ Over-Rely on In-Memory Mode for Persistent Data
- **Reason:** In-memory databases are volatile and unsuitable for long-term storage.
- **Priority:** ❌ Won't
- **Description:** Never use in-memory mode for data that needs to persist beyond the session. In BIS, this prevents data loss and ensures reliability for critical analytics.

## 📁 Data Export and Interoperability

#### ✅ Use `COPY ... TO` for Efficient Data Export
- **Reason:** Ensures fast and reliable export to CSV, Parquet, or JSON.
- **Priority:** 🟡 Should
- **Description:** Use DuckDB's `COPY ... TO` statement to export data efficiently in the desired format. This method is optimized for large datasets and supports a variety of file types, making it ideal for BIS data sharing and reporting.

#### ✅ Specify Compression for Large Exports
- **Reason:** Reduces storage costs and speeds up data transfer.
- **Priority:** 🟢 Could
- **Description:** When exporting large datasets, specify a compression method (e.g., gzip, zstd) to minimize file size and improve transfer speeds. In BIS, this practice is beneficial for archiving and distributing analytical results.

## 📁 Advanced Usage and Configuration

#### ✅ Use Appender API for Programmatic Bulk Loads
- **Reason:** Enables efficient, programmatic data ingestion from code.
- **Priority:** 🟡 Should
- **Description:** For high-throughput programmatic data ingestion, use DuckDB's Appender API instead of executing many SQL statements. This approach reduces overhead and is ideal for ETL pipelines in BIS.

#### ✅ Tune Buffer and Sample Size for Large Files
- **Reason:** Optimizes import speed and type detection accuracy.
- **Priority:** 🟡 Should
- **Description:** Adjust the `buffer_size` and `sample_size` parameters when importing very large files to balance memory usage and improve type inference. In BIS, tuning these parameters can significantly speed up large-scale data onboarding.

#### ✅ Use Virtual Columns for Provenance Tracking
- **Reason:** Tracks data origin for audit and debugging.
- **Priority:** 🟢 Could
- **Description:** Leverage DuckDB's `filename` virtual column when importing from multiple files to track the source of each row. This is valuable in BIS for data lineage, auditing, and troubleshooting.

#### ❌ Ignore File Encoding Issues
- **Reason:** Mismatched encodings can corrupt data and cause import failures.
- **Priority:** ❌ Won't
- **Description:** Never ignore file encoding mismatches. Always ensure files are in UTF-8, UTF-16, or Latin-1 as supported by DuckDB, and convert encodings as needed before import. In BIS, encoding errors can silently corrupt analytical results.
