# ServiceNow Best Practices & Guidelines for AI Agents - BIS Repository

**Target Audience:** AI Agents, Data Engineers, Python Developers  
**Scope:** Comprehensive ServiceNow API data extraction and pipeline development standards  
**Apply to:** All ServiceNow-related files in BIS repository (`wiki/external/SNOW.md`, `engine/src/**/servicenow*.py`, `temp/BIS_AGENT/*snow*`)

---

## 📋 Comprehensive Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Core Principles](#-core-principles)
- [🏗️ Design Patterns](#️-design-patterns)
- [📚 Key Terms](#-key-terms)
- [🔗 Industry References](#-industry-references)
- [📂 Practice Categories](#-practice-categories)
  - [📁 API Connection and Security](#api-connection-and-security)
    - [✅ Implement OAuth 2.0 Authentication](#implement-oauth-20-authentication)
    - [✅ Set Appropriate API Timeouts](#set-appropriate-api-timeouts)
    - [✅ Use Specific Field Selection](#use-specific-field-selection)
    - [✅ Handle Authentication Errors Gracefully](#handle-authentication-errors-gracefully)
    - [✅ Store Credentials Securely](#store-credentials-securely)
    - [❌ Use Basic Authentication in Production](#use-basic-authentication-in-production)
    - [❌ Hardcode Credentials in Source Code](#hardcode-credentials-in-source-code)
    - [❌ Ignore SSL Certificate Validation](#ignore-ssl-certificate-validation)
  - [📁 Error Handling and Resilience](#error-handling-and-resilience)
    - [✅ Implement Exponential Backoff](#implement-exponential-backoff)
    - [✅ Handle HTTP Status Codes Properly](#handle-http-status-codes-properly)
    - [✅ Implement Retry Logic for Transient Errors](#implement-retry-logic-for-transient-errors)
    - [✅ Monitor API Rate Limits](#monitor-api-rate-limits)
    - [✅ Log Errors Comprehensively](#log-errors-comprehensively)
    - [❌ Don't Implement Retry Logic](#dont-implement-retry-logic)
    - [❌ Ignore Timeout Configurations](#ignore-timeout-configurations)
    - [❌ Fail Silently on API Errors](#fail-silently-on-api-errors)
  - [📁 Pagination Strategy](#pagination-strategy)
    - [✅ Use Dynamic Pagination Loop](#use-dynamic-pagination-loop)
    - [✅ Leverage X-Total-Count Header](#leverage-x-total-count-header)
    - [✅ Set Optimal Page Size](#set-optimal-page-size)
    - [✅ Handle Empty Responses](#handle-empty-responses)
    - [✅ Validate Pagination Consistency](#validate-pagination-consistency)
    - [❌ Request All Fields Without sysparm_fields](#request-all-fields-without-sysparm_fields)
    - [❌ Use Fixed Pagination Without Checking Total Count](#use-fixed-pagination-without-checking-total-count)
  - [📁 Data Ingestion and Normalization](#data-ingestion-and-normalization)
    - [✅ Normalize JSON with Pandas](#normalize-json-with-pandas)
    - [✅ Handle Nested Data Structures](#handle-nested-data-structures)
    - [✅ Validate Data Schema](#validate-data-schema)
    - [✅ Process Data in Batches](#process-data-in-batches)
    - [✅ Ensure Data Type Consistency](#ensure-data-type-consistency)
    - [❌ Process JSON Manually Without Pandas](#process-json-manually-without-pandas)
    - [❌ Ignore Nested Data Structures](#ignore-nested-data-structures)
    - [❌ Skip Data Validation](#skip-data-validation)
  - [📁 Data Transformation with SQL](#data-transformation-with-sql)
    - [✅ Use DuckDB for Transformations](#use-duckdb-for-transformations)
    - [✅ Create Temporary Tables](#create-temporary-tables)
    - [✅ Optimize SQL Queries](#optimize-sql-queries)
    - [✅ Handle Date Conversions](#handle-date-conversions)
    - [✅ Perform Data Cleaning](#perform-data-cleaning)
    - [❌ Use Only Pandas for Complex Transformations](#use-only-pandas-for-complex-transformations)
    - [❌ Ignore SQL Optimization](#ignore-sql-optimization)
  - [📁 DuckDB Integration](#duckdb-integration)
    - [✅ Leverage Replacement Scans](#leverage-replacement-scans)
    - [✅ Use In-Memory Database](#use-in-memory-database)
    - [✅ Combine Pandas and DuckDB](#combine-pandas-and-duckdb)
    - [✅ Optimize Memory Usage](#optimize-memory-usage)
    - [✅ Close Connections Properly](#close-connections-properly)
    - [❌ Don't Close Database Connections](#dont-close-database-connections)
    - [❌ Use Persistent Databases for Temporary Data](#use-persistent-databases-for-temporary-data)
  - [📁 Data Storage Optimization](#data-storage-optimization)
    - [✅ Choose Parquet Format](#choose-parquet-format)
    - [✅ Implement Compression](#implement-compression)
    - [✅ Partition Data Strategically](#partition-data-strategically)
    - [✅ Disable Index Saving](#disable-index-saving)
    - [✅ Optimize File Structure](#optimize-file-structure)
    - [❌ Save Data in CSV Format](#save-data-in-csv-format)
    - [❌ Don't Compress Parquet Files](#dont-compress-parquet-files)
    - [❌ Include DataFrame Index in Parquet](#include-dataframe-index-in-parquet)
  - [📁 Parquet File Management](#parquet-file-management)
    - [✅ Use Snappy Compression](#use-snappy-compression)
    - [✅ Implement Partition Pruning](#implement-partition-pruning)
    - [✅ Handle Large Datasets](#handle-large-datasets)
    - [✅ Ensure Schema Compatibility](#ensure-schema-compatibility)
    - [✅ Validate File Integrity](#validate-file-integrity)
    - [❌ Use Gzip Compression for Read-Heavy Workloads](#use-gzip-compression-for-read-heavy-workloads)
    - [❌ Don't Partition Large Datasets](#dont-partition-large-datasets)
  - [📁 Pipeline Orchestration](#pipeline-orchestration)
    - [✅ Modularize Pipeline Components](#modularize-pipeline-components)
    - [✅ Implement Logging Throughout](#implement-logging-throughout)
    - [✅ Handle Pipeline Failures](#handle-pipeline-failures)
    - [✅ Monitor Performance Metrics](#monitor-performance-metrics)
    - [✅ Automate Pipeline Execution](#automate-pipeline-execution)
    - [❌ Write Monolithic Pipeline Scripts](#write-monolithic-pipeline-scripts)
    - [❌ Don't Log Pipeline Execution](#dont-log-pipeline-execution)
    - [❌ Ignore Pipeline Failure Recovery](#ignore-pipeline-failure-recovery)
  - [📁 Security and Compliance](#security-and-compliance)
    - [✅ Encrypt Sensitive Data](#encrypt-sensitive-data)
    - [✅ Implement Access Controls](#implement-access-controls)
    - [✅ Audit API Interactions](#audit-api-interactions)
    - [✅ Comply with Data Regulations](#comply-with-data-regulations)
    - [✅ Regularly Update Dependencies](#regularly-update-dependencies)
    - [❌ Store Data Unencrypted](#store-data-unencrypted)
    - [❌ Grant Excessive Permissions](#grant-excessive-permissions)

---

## 🎯 Core Principles

- **Security-First Approach**: Prioritize secure authentication and data handling to protect sensitive ServiceNow data from unauthorized access and breaches, ensuring compliance with enterprise security standards and minimizing risks associated with API interactions.
- **Resilience and Scalability**: Design pipelines that can handle API failures, rate limits, and large datasets through robust error handling and efficient pagination, enabling reliable operation at scale without manual intervention.
- **Data Quality and Integrity**: Ensure extracted data maintains its accuracy and structure through proper normalization and validation, preventing downstream issues in analytics and reporting workflows.
- **Performance Optimization**: Leverage efficient tools like DuckDB and Parquet to minimize processing time and storage costs, balancing speed with resource consumption for optimal pipeline performance.
- **Maintainability and Documentation**: Structure code with clear modularity and comprehensive logging to facilitate future updates and troubleshooting, ensuring long-term sustainability of the data extraction solution.

---

## 🏗️ Design Patterns

- **Resilient API Client Pattern**: Implement a client with built-in retry mechanisms and exponential backoff to handle transient failures, ensuring consistent data extraction despite network issues or API downtime.
- **Dynamic Pagination Pattern**: Use offset-based pagination with total count tracking to efficiently retrieve large datasets in manageable chunks, optimizing API calls and preventing timeouts.
- **ETL Pipeline Pattern**: Structure the extraction, transformation, and loading process as modular components using Pandas for ingestion, DuckDB for transformation, and Parquet for storage, creating a flexible and maintainable workflow.
- **Columnar Storage Pattern**: Employ Parquet's columnar format with compression and partitioning to optimize storage efficiency and query performance for analytical workloads.
- **Embedded SQL Transformation Pattern**: Integrate DuckDB's in-process SQL engine with Pandas DataFrames for complex data manipulations, combining the ease of SQL with Python's flexibility.

---

## 📚 Key Terms

- **ServiceNow Table API**: The RESTful interface for querying and manipulating data in ServiceNow tables, supporting GET, POST, PUT, and DELETE operations with various parameters for filtering and pagination.
- **OAuth 2.0**: A secure authorization framework that enables applications to obtain limited access to user accounts on an HTTP service, using access tokens instead of credentials for API authentication.
- **Exponential Backoff**: A retry strategy that increases the wait time between retries exponentially, preventing system overload during API failures or rate limiting.
- **JSON Normalization**: The process of flattening nested JSON structures into tabular format using tools like pandas.json_normalize, essential for converting API responses into analyzable data.
- **DuckDB**: An in-process SQL OLAP database engine designed for analytical queries, providing high performance for data transformation and analysis within Python applications.
- **Parquet**: A columnar storage file format optimized for analytics, offering efficient compression, partitioning, and query performance for large datasets.
- **Pagination**: The technique of dividing large result sets into smaller, sequential pages to manage memory usage and API limits during data extraction.
- **Schema Drift**: Changes in data structure over time that can break pipelines, requiring proactive schema validation and field selection to maintain data integrity.

---

## 🔗 Industry References

- **ServiceNow Developer Documentation**: Official API reference providing comprehensive details on endpoints, parameters, and best practices for ServiceNow integration (servicenow.com/developers).
- **OAuth 2.0 Authorization Framework (RFC 6749)**: The definitive specification for OAuth 2.0 implementation, essential for secure API authentication (tools.ietf.org/html/rfc6749).
- **DuckDB Documentation**: Official guides and API reference for efficient SQL operations in analytical workflows (duckdb.org/docs).
- **Apache Parquet Format Specification**: Technical details on the Parquet file format for optimized data storage and processing (parquet.apache.org/documentation).
- **Pandas Documentation**: Comprehensive reference for data manipulation and JSON processing in Python (pandas.pydata.org/docs).

---

## 📂 Practice Categories

### 📁 API Connection and Security

#### ✅ Implement OAuth 2.0 Authentication
- **Reason:** Provides secure, temporary access tokens that reduce the risk of credential exposure in production environments.
- **Priority:** 🔴 Must
- **Description:** Always implement OAuth 2.0 authentication for ServiceNow API access instead of basic authentication to obtain short-lived access tokens that automatically expire, significantly reducing the window of exposure if tokens are compromised. This approach requires setting up client credentials and implementing token refresh logic programmatically, ensuring continuous secure access without storing long-lived passwords. By following OAuth 2.0 standards, the pipeline adheres to modern security practices and enables better audit trails for API interactions, making it easier to track and revoke access when necessary.

#### ✅ Set Appropriate API Timeouts
- **Reason:** Prevents scripts from hanging indefinitely and ensures timely failure detection.
- **Priority:** 🔴 Must
- **Description:** Configure reasonable timeout values for all ServiceNow API requests to avoid indefinite hangs that can block pipeline execution and consume system resources unnecessarily. A typical timeout of 120 seconds balances the need for completion with the reality of potential network delays or server issues. Implement timeouts at the session level using requests library configuration, ensuring all API calls respect this limit consistently. This practice prevents resource exhaustion and allows the pipeline to fail fast, enabling quicker recovery through retry mechanisms.

#### ✅ Use Specific Field Selection
- **Reason:** Reduces payload size, prevents timeouts, and avoids schema drift issues.
- **Priority:** 🔴 Must
- **Description:** Always specify exact fields to retrieve using the sysparm_fields parameter instead of requesting all available fields, which dramatically reduces the API response size and prevents timeouts on wide tables. This targeted approach minimizes data transfer and processing overhead while ensuring consistent schema across extractions. By explicitly defining required fields, the pipeline becomes more resilient to ServiceNow table schema changes and improves overall performance. This practice also facilitates better data governance by only extracting necessary information.

#### ✅ Handle Authentication Errors Gracefully
- **Reason:** Ensures proper error reporting and prevents silent failures in authentication processes.
- **Priority:** 🔴 Must
- **Description:** Implement specific error handling for authentication failures, distinguishing between invalid credentials, expired tokens, and permission issues to provide clear diagnostic information. Use try-except blocks around authentication logic and log detailed error messages that can guide troubleshooting without exposing sensitive information. This approach enables quick identification and resolution of access issues, maintaining pipeline reliability. Proper authentication error handling also supports automated recovery mechanisms like token refresh.

#### ✅ Store Credentials Securely
- **Reason:** Protects sensitive authentication information from unauthorized access and accidental exposure.
- **Priority:** 🔴 Must
- **Description:** Never hardcode credentials in source code; instead, use environment variables or secure credential management systems to store ServiceNow authentication details. Implement proper credential loading at runtime with fallback error handling for missing values. This security practice prevents accidental commits of sensitive data to version control and supports different credential sets for development, testing, and production environments. Secure credential storage is fundamental to maintaining compliance with enterprise security policies and protecting organizational data.

#### ❌ Use Basic Authentication in Production
- **Reason:** Avoids security vulnerabilities from persistent credential exposure.
- **Priority:** ❌ Won't
- **Description:** Refrain from using basic authentication for ServiceNow API access in production environments, as it sends credentials with every request and increases the risk of interception or unauthorized access. This method lacks the security benefits of token-based authentication and can lead to credential compromise if network traffic is monitored. Instead, implement OAuth 2.0 for secure, temporary access tokens that reduce exposure windows. Using basic authentication in production violates security best practices and can result in data breaches or compliance violations.

#### ❌ Hardcode Credentials in Source Code
- **Reason:** Prevents accidental exposure of sensitive authentication information.
- **Priority:** ❌ Won't
- **Description:** Never embed ServiceNow credentials directly in source code files, as this creates significant security risks through version control exposure, code sharing, and accidental commits. Hardcoded credentials can be easily discovered by unauthorized users and are difficult to rotate when compromised. This practice violates security standards and can lead to widespread credential exposure across development teams. Always use environment variables, secure vaults, or configuration management systems for credential storage.

#### ❌ Ignore SSL Certificate Validation
- **Reason:** Ensures secure communication and prevents man-in-the-middle attacks.
- **Priority:** ❌ Won't
- **Description:** Never disable SSL certificate validation when connecting to ServiceNow APIs, as this exposes communications to interception and tampering by malicious actors. Disabling validation removes the security guarantee that you're connecting to the legitimate ServiceNow instance and can lead to data theft or injection attacks. Always verify SSL certificates to maintain secure, encrypted connections. Ignoring certificate validation fundamentally compromises the security of API interactions and should never be done in production environments.

### 📁 Error Handling and Resilience

#### ✅ Implement Exponential Backoff
- **Reason:** Prevents API server overload and ensures successful recovery from transient failures.
- **Priority:** 🔴 Must
- **Description:** Implement exponential backoff retry logic for all ServiceNow API calls to handle rate limiting and temporary server issues without overwhelming the system. Start with a base delay and exponentially increase wait times between retries, adding random jitter to prevent thundering herd problems. This strategy allows the API server to recover while ensuring the pipeline eventually succeeds for recoverable errors. Exponential backoff is particularly crucial for handling HTTP 429 (Too Many Requests) responses and improves overall system stability.

#### ✅ Handle HTTP Status Codes Properly
- **Reason:** Enables appropriate responses to different types of API errors and prevents incorrect data processing.
- **Priority:** 🔴 Must
- **Description:** Implement comprehensive HTTP status code handling, treating 4xx errors as client issues (requiring code fixes) and 5xx errors as server issues (suitable for retries). Use response.raise_for_status() combined with specific exception handling for different status codes. This granular approach ensures that permanent failures are not retried unnecessarily while transient issues are handled appropriately. Proper status code handling also provides better error reporting for debugging and monitoring purposes.

#### ✅ Implement Retry Logic for Transient Errors
- **Reason:** Maximizes pipeline success rate by automatically recovering from temporary network or server issues.
- **Priority:** 🔴 Must
- **Description:** Configure retry mechanisms specifically for transient errors like timeouts, network failures, and server errors (5xx status codes) while avoiding retries for permanent failures. Set a maximum retry count (typically 3-5 attempts) to prevent infinite loops. This practice significantly improves pipeline reliability in production environments where intermittent connectivity issues are common. Retry logic should be combined with exponential backoff and proper logging for effective troubleshooting.

#### ✅ Monitor API Rate Limits
- **Reason:** Prevents service disruption and ensures fair resource usage across API consumers.
- **Priority:** 🟡 Should
- **Description:** Track API usage against ServiceNow's rate limits and implement throttling mechanisms to stay within allowed thresholds. Monitor response headers for rate limit information and adjust request frequency accordingly. This proactive approach prevents account suspension and maintains good API citizenship. Rate limit monitoring also provides valuable metrics for capacity planning and performance optimization.

#### ✅ Log Errors Comprehensively
- **Reason:** Enables effective troubleshooting and monitoring of pipeline health.
- **Priority:** 🟡 Should
- **Description:** Implement detailed logging for all API errors, including request parameters, response status codes, and error messages while avoiding sensitive data exposure. Use structured logging with appropriate log levels to distinguish between informational messages and critical errors. Comprehensive error logging facilitates post-mortem analysis and helps identify patterns in API failures. This practice is essential for maintaining pipeline reliability and supporting continuous improvement.

#### ❌ Don't Implement Retry Logic
- **Reason:** Avoids permanent pipeline failures from transient network issues.
- **Priority:** ❌ Won't
- **Description:** Never omit retry mechanisms for ServiceNow API calls, as this leads to pipeline failures from temporary network glitches, server overloads, or brief connectivity issues. Without retries, the pipeline becomes fragile and unreliable in production environments where intermittent failures are common. This practice results in unnecessary manual interventions and reduces overall system resilience. Always implement appropriate retry logic with exponential backoff for robust API interactions.

#### ❌ Ignore Timeout Configurations
- **Reason:** Prevents indefinite hangs and ensures timely failure detection.
- **Priority:** ❌ Won't
- **Description:** Never remove or ignore timeout settings on ServiceNow API requests, as this can cause scripts to hang indefinitely during network issues or server problems. Without timeouts, the pipeline becomes unresponsive and can consume system resources unnecessarily. This practice leads to poor user experience and complicates pipeline monitoring. Always configure appropriate timeouts to ensure predictable and controllable API interactions.

#### ❌ Fail Silently on API Errors
- **Reason:** Ensures proper error reporting and prevents undetected failures.
- **Priority:** ❌ Won't
- **Description:** Never allow ServiceNow API errors to go unhandled or unreported, as silent failures mask critical issues and prevent timely resolution. Failing silently can lead to incomplete data extraction, corrupted datasets, and undetected security breaches. This practice severely impacts pipeline reliability and makes debugging extremely difficult. Always implement comprehensive error handling with proper logging and alerting mechanisms.

### 📁 Pagination Strategy

#### ✅ Use Dynamic Pagination Loop
- **Reason:** Efficiently handles large datasets without memory exhaustion or API timeouts.
- **Priority:** 🔴 Must
- **Description:** Implement a dynamic pagination loop that continues fetching data until all records are retrieved, using offset increments based on the configured page size. This approach ensures complete data extraction regardless of dataset size while respecting API limits. The loop should track total records and current progress for better monitoring and error recovery. Dynamic pagination is fundamental for scalable ServiceNow data extraction pipelines.

#### ✅ Leverage X-Total-Count Header
- **Reason:** Provides accurate progress tracking and prevents unnecessary API calls.
- **Priority:** 🔴 Must
- **Description:** Use the X-Total-Count response header to determine the total number of records and calculate exact pagination requirements upfront. This metadata enables precise loop termination conditions and progress reporting. By leveraging this header, the pipeline can avoid guessing the total count and ensure all data is captured efficiently. This practice also supports better user experience through accurate progress indicators.

#### ✅ Set Optimal Page Size
- **Reason:** Balances API efficiency with memory usage and timeout prevention.
- **Priority:** 🟡 Should
- **Description:** Configure sysparm_limit to an optimal value (typically 5000 records) that maximizes throughput while staying within ServiceNow's 10,000 record limit and timeout constraints. Test different page sizes to find the sweet spot for specific table structures and network conditions. Optimal page sizing reduces total API calls and improves overall extraction performance. This setting should be configurable to allow tuning based on specific use cases.

#### ✅ Handle Empty Responses
- **Reason:** Ensures proper loop termination and prevents infinite processing.
- **Priority:** 🟡 Should
- **Description:** Implement logic to detect empty result sets and terminate pagination appropriately, avoiding unnecessary API calls when no more data exists. Check both the response length and the relationship between offset and total count. This practice prevents resource waste and ensures the pipeline completes successfully. Empty response handling is particularly important for dynamic datasets where record counts may change during extraction.

#### ✅ Validate Pagination Consistency
- **Reason:** Detects data integrity issues and API inconsistencies during extraction.
- **Priority:** 🟢 Could
- **Description:** Implement checks to ensure pagination returns consistent results and detect any data skipping or duplication issues. Compare record counts against expected totals and validate offset calculations. This validation helps maintain data integrity and provides early warning of API behavior changes. Pagination consistency validation is valuable for critical data pipelines where accuracy is paramount.

#### ❌ Request All Fields Without sysparm_fields
- **Reason:** Prevents timeouts and reduces unnecessary data transfer.
- **Priority:** ❌ Won't
- **Description:** Never request all available fields from ServiceNow tables without using sysparm_fields, as this leads to massive response payloads that can cause timeouts, especially on wide tables with hundreds of columns. Requesting excessive fields wastes bandwidth, increases processing time, and can trigger API rate limits. This practice results in inefficient pipelines and potential service disruptions. Always specify only the required fields to optimize performance and reliability.

#### ❌ Use Fixed Pagination Without Checking Total Count
- **Reason:** Ensures complete data extraction without missing records.
- **Priority:** ❌ Won't
- **Description:** Never implement pagination with a fixed loop that doesn't verify the total record count, as this can result in incomplete data extraction or unnecessary API calls. Without checking the X-Total-Count header, the pipeline may stop prematurely or continue indefinitely. This practice leads to data loss or inefficient resource usage. Always use dynamic pagination that accounts for the actual dataset size.

### 📁 Data Ingestion and Normalization

#### ✅ Normalize JSON with Pandas
- **Reason:** Converts complex nested JSON into flat tabular format for analysis.
- **Priority:** 🔴 Must
- **Description:** Use pandas.json_normalize() to flatten ServiceNow's nested JSON responses into clean DataFrames, handling complex data structures with record_path and meta parameters. This transformation is essential for converting API responses into analyzable tabular data. Normalization ensures consistent data structure and enables standard data processing techniques. This practice is fundamental for any ServiceNow data pipeline requiring further analysis or transformation.

#### ✅ Handle Nested Data Structures
- **Reason:** Preserves all relevant data from complex ServiceNow records.
- **Priority:** 🟡 Should
- **Description:** Configure json_normalize with appropriate record_path and meta parameters to properly extract data from nested objects and arrays in ServiceNow responses. This ensures no valuable information is lost during flattening. Proper handling of nested structures maintains data completeness and prevents information loss. This practice is particularly important for tables with complex reference fields and related records.

#### ✅ Validate Data Schema
- **Reason:** Ensures data consistency and prevents downstream processing errors.
- **Priority:** 🟡 Should
- **Description:** Implement schema validation after JSON normalization to verify expected columns and data types match the target structure. Use pandas dtypes and custom validation functions to catch schema drift early. This practice prevents runtime errors in downstream processing and ensures data quality. Schema validation is crucial for maintaining pipeline reliability over time.

#### ✅ Process Data in Batches
- **Reason:** Manages memory usage for large datasets and improves processing efficiency.
- **Priority:** 🟢 Could
- **Description:** Divide large result sets into manageable batches for processing, especially when dealing with memory constraints or very large tables. Implement batch processing logic that maintains data integrity across chunks. This approach enables processing of datasets larger than available memory. Batch processing is beneficial for optimizing resource usage in constrained environments.

#### ✅ Ensure Data Type Consistency
- **Reason:** Maintains data integrity and prevents type-related errors in analysis.
- **Priority:** 🟢 Could
- **Description:** Apply consistent data type conversions after normalization, ensuring dates, numbers, and strings are properly typed for downstream processing. Use pandas to_numeric, to_datetime, and astype methods appropriately. This practice prevents unexpected behavior in calculations and queries. Data type consistency is important for reliable analytical results.

#### ❌ Process JSON Manually Without Pandas
- **Reason:** Avoids error-prone and inefficient manual parsing.
- **Priority:** ❌ Won't
- **Description:** Never manually parse ServiceNow JSON responses using basic Python dictionaries or custom loops, as this leads to fragile code that's prone to errors with complex nested structures. Manual processing is time-consuming, error-prone, and doesn't handle edge cases well. This practice results in unreliable data extraction and maintenance nightmares. Always use pandas.json_normalize or similar libraries for robust JSON processing.

#### ❌ Ignore Nested Data Structures
- **Reason:** Preserves all relevant data from complex ServiceNow records.
- **Priority:** ❌ Won't
- **Description:** Never flatten ServiceNow JSON data without properly handling nested objects and arrays, as this leads to data loss and incomplete records. Ignoring nested structures can miss critical reference data and related information. This practice results in incomplete datasets and reduced analytical value. Always configure normalization to extract data from all relevant nested levels.

#### ❌ Skip Data Validation
- **Reason:** Ensures data quality and prevents downstream processing errors.
- **Priority:** ❌ Won't
- **Description:** Never omit schema validation and data quality checks after JSON normalization, as this allows corrupted or malformed data to propagate through the pipeline. Skipping validation can lead to runtime errors, incorrect calculations, and unreliable analytics. This practice severely impacts data trustworthiness and pipeline reliability. Always implement comprehensive validation to catch issues early.

### 📁 Data Transformation with SQL

#### ✅ Use DuckDB for Transformations
- **Reason:** Provides powerful SQL capabilities for complex data manipulations within Python.
- **Priority:** 🔴 Must
- **Description:** Leverage DuckDB's SQL engine for data transformations instead of complex pandas operations, enabling declarative and optimized data processing. DuckDB's columnar processing provides superior performance for analytical queries. This approach simplifies complex transformations and improves code readability. Using DuckDB is essential for efficient data transformation in ServiceNow pipelines.

#### ✅ Create Temporary Tables
- **Reason:** Enables complex multi-step SQL transformations with stable schema.
- **Priority:** 🟡 Should
- **Description:** Load DataFrames into DuckDB temporary tables using CREATE TEMP TABLE AS SELECT syntax for multi-step transformations and joins. This provides a stable, queryable schema for complex operations. Temporary tables facilitate advanced SQL analytics and data cleaning. This practice is valuable for sophisticated data transformation requirements.

#### ✅ Optimize SQL Queries
- **Reason:** Maximizes performance and minimizes processing time for large datasets.
- **Priority:** 🟡 Should
- **Description:** Write efficient SQL queries with appropriate WHERE clauses, indexes, and join strategies to optimize DuckDB performance. Avoid unnecessary columns and use LIMIT for testing. Query optimization significantly improves pipeline execution speed. This practice is crucial for time-sensitive data processing workflows.

#### ✅ Handle Date Conversions
- **Reason:** Ensures proper date handling for time-based analysis and filtering.
- **Priority:** 🟡 Should
- **Description:** Use DuckDB's TO_TIMESTAMP function to properly convert ServiceNow date strings into timestamp format for analysis. Handle timezone considerations and format inconsistencies. Proper date conversion enables accurate temporal analysis. This practice is essential for incident management and trend analysis use cases.

#### ✅ Perform Data Cleaning
- **Reason:** Removes invalid or irrelevant data to improve analysis quality.
- **Priority:** 🟢 Could
- **Description:** Implement SQL-based data cleaning operations like NULL handling, duplicate removal, and value standardization within DuckDB. Use CASE statements and string functions for data normalization. Data cleaning ensures high-quality output for downstream consumers. This practice enhances the overall value of extracted ServiceNow data.

#### ❌ Use Only Pandas for Complex Transformations
- **Reason:** Leverages SQL power for efficient complex data manipulations.
- **Priority:** ❌ Won't
- **Description:** Never rely solely on pandas for complex data transformations involving joins, aggregations, or multi-step operations, as this leads to verbose, error-prone code that's slower than SQL equivalents. Pandas is not optimized for complex analytical queries and can become unwieldy. This practice results in inefficient and hard-to-maintain transformation code. Always use DuckDB or similar SQL engines for complex data manipulations.

#### ❌ Ignore SQL Optimization
- **Reason:** Maximizes query performance and reduces processing time.
- **Priority:** ❌ Won't
- **Description:** Never write SQL queries without considering performance optimization, as unoptimized queries can run orders of magnitude slower on large datasets. Ignoring proper indexing, join strategies, and query structure leads to excessive processing time and resource consumption. This practice severely impacts pipeline efficiency and scalability. Always optimize SQL queries for the specific data patterns and volumes being processed.

### 📁 DuckDB Integration

#### ✅ Leverage Replacement Scans
- **Reason:** Enables seamless querying of Pandas DataFrames with SQL.
- **Priority:** 🟡 Should
- **Description:** Use DuckDB's replacement scan feature to query Pandas DataFrames directly with SQL without explicit table creation. This simplifies single-query operations and reduces code complexity. Replacement scans provide a convenient bridge between pandas and SQL. This practice is ideal for simple transformations and ad-hoc queries.

#### ✅ Use In-Memory Database
- **Reason:** Provides fast, temporary storage for transformation operations.
- **Priority:** 🟡 Should
- **Description:** Configure DuckDB to use in-memory databases for temporary data processing, ensuring fast access and automatic cleanup. Use :memory: connection string for transient operations. In-memory databases optimize performance for ETL workflows. This practice is suitable for most ServiceNow data transformation scenarios.

#### ✅ Combine Pandas and DuckDB
- **Reason:** Leverages strengths of both tools for optimal data processing.
- **Priority:** 🟡 Should
- **Description:** Use pandas for initial data ingestion and DuckDB for complex transformations, combining Python's flexibility with SQL's power. Pass DataFrames to DuckDB and retrieve results as DataFrames. This hybrid approach maximizes processing efficiency. Combining tools provides the best of both worlds for data pipelines.

#### ✅ Optimize Memory Usage
- **Reason:** Prevents memory exhaustion during large dataset processing.
- **Priority:** 🟢 Could
- **Description:** Configure DuckDB memory settings and use streaming operations for very large datasets to manage memory consumption effectively. Monitor memory usage during processing. Memory optimization ensures pipeline stability with large data volumes. This practice is important for enterprise-scale ServiceNow extractions.

#### ✅ Close Connections Properly
- **Reason:** Prevents resource leaks and ensures clean pipeline execution.
- **Priority:** 🟢 Could
- **Description:** Always close DuckDB connections in finally blocks or using context managers to release resources properly. Implement proper connection lifecycle management. Connection cleanup prevents memory leaks and database locks. This practice maintains system health during repeated pipeline executions.

#### ❌ Don't Close Database Connections
- **Reason:** Prevents resource leaks and connection pool exhaustion.
- **Priority:** ❌ Won't
- **Description:** Never leave DuckDB database connections open without proper cleanup, as this leads to resource leaks, memory consumption, and potential connection pool exhaustion. Unclosed connections can cause system instability and performance degradation over time. This practice results in unreliable pipeline execution and maintenance issues. Always implement proper connection lifecycle management with try-finally blocks or context managers.

#### ❌ Use Persistent Databases for Temporary Data
- **Reason:** Avoids unnecessary disk I/O and simplifies temporary data handling.
- **Priority:** ❌ Won't
- **Description:** Never use persistent database files for temporary ServiceNow data processing, as this creates unnecessary disk I/O, complicates cleanup, and can lead to data persistence issues. Persistent databases are meant for long-term data storage, not ETL transformations. This practice results in inefficient processing and potential data contamination. Always use in-memory databases for temporary operations.

### 📁 Data Storage Optimization

#### ✅ Choose Parquet Format
- **Reason:** Provides efficient columnar storage for analytical workloads.
- **Priority:** 🔴 Must
- **Description:** Save transformed data in Parquet format instead of CSV or JSON for optimal storage efficiency and query performance. Parquet's columnar structure enables fast analytical queries. This format is specifically designed for data analytics use cases. Choosing Parquet is essential for modern data pipeline architectures.

#### ✅ Implement Compression
- **Reason:** Reduces storage costs and improves I/O performance.
- **Priority:** 🔴 Must
- **Description:** Enable compression when saving to Parquet to minimize file size and optimize storage utilization. Choose appropriate compression codecs based on use case. Compression significantly reduces storage requirements. This practice is crucial for cost-effective data management.

#### ✅ Partition Data Strategically
- **Reason:** Enables efficient querying by organizing data for partition pruning.
- **Priority:** 🟡 Should
- **Description:** Partition Parquet files by relevant dimensions like date or category to enable query optimization through partition pruning. Choose partition keys that align with common query patterns. Strategic partitioning dramatically improves query performance. This practice is valuable for time-series ServiceNow data.

#### ✅ Disable Index Saving
- **Reason:** Prevents unnecessary bloat in Parquet files.
- **Priority:** 🟡 Should
- **Description:** Set index=False when saving DataFrames to Parquet to avoid storing meaningless row indices that increase file size. This reduces storage overhead and improves compression efficiency. Disabling index saving is a best practice for analytical data storage. This setting optimizes file size without losing functionality.

#### ✅ Optimize File Structure
- **Reason:** Balances file size with query performance for optimal access patterns.
- **Priority:** 🟢 Could
- **Description:** Configure Parquet writer settings like row group size and page size for optimal performance based on expected query patterns. Test different configurations for specific use cases. File structure optimization enhances overall system performance. This practice fine-tunes storage for particular analytical workloads.

#### ❌ Save Data in CSV Format
- **Reason:** Avoids inefficient storage and poor analytical performance.
- **Priority:** ❌ Won't
- **Description:** Never save ServiceNow data in CSV format for analytical purposes, as it lacks compression, has poor query performance, and doesn't support complex data types efficiently. CSV files are uncompressed, leading to massive storage requirements and slow analytical queries. This practice results in inefficient data pipelines and poor performance. Always use Parquet or similar columnar formats for analytical data storage.

#### ❌ Don't Compress Parquet Files
- **Reason:** Reduces storage costs and improves I/O performance.
- **Priority:** ❌ Won't
- **Description:** Never save Parquet files without compression, as this leads to unnecessarily large file sizes and increased storage costs. Uncompressed Parquet files waste disk space and slow down data transfer operations. This practice is economically inefficient and reduces overall system performance. Always enable appropriate compression when saving Parquet files.

#### ❌ Include DataFrame Index in Parquet
- **Reason:** Prevents unnecessary file bloat and improves storage efficiency.
- **Priority:** ❌ Won't
- **Description:** Never save pandas DataFrame indices to Parquet files, as this adds meaningless columns that increase file size and complicate queries. DataFrame indices are typically auto-generated row numbers that provide no analytical value. This practice results in bloated files and unnecessary storage consumption. Always set index=False when saving to Parquet.

### 📁 Parquet File Management

#### ✅ Use Snappy Compression
- **Reason:** Provides good compression ratio with fast read/write performance.
- **Priority:** 🟡 Should
- **Description:** Select Snappy compression for Parquet files to balance compression efficiency with processing speed, making it suitable for most analytical workloads. Snappy offers better performance than gzip for read operations. This compression codec is optimized for modern hardware. Choosing Snappy maximizes overall pipeline efficiency.

#### ✅ Implement Partition Pruning
- **Reason:** Dramatically reduces query time by reading only relevant data.
- **Priority:** 🟡 Should
- **Description:** Design partition schemes that align with common query filters to enable automatic partition pruning in analytical tools. Use date-based partitions for temporal queries. Partition pruning can reduce query time by orders of magnitude. This practice is essential for large ServiceNow datasets.

#### ✅ Handle Large Datasets
- **Reason:** Ensures efficient processing and storage of massive ServiceNow extractions.
- **Priority:** 🟢 Could
- **Description:** Implement chunked reading and writing strategies for datasets that exceed memory capacity, using tools like pyarrow for large file handling. Monitor system resources during processing. Large dataset handling ensures pipeline scalability. This practice supports enterprise-level data volumes.

#### ✅ Ensure Schema Compatibility
- **Reason:** Maintains data consistency across multiple Parquet files and versions.
- **Priority:** 🟢 Could
- **Description:** Validate Parquet schema compatibility when appending or merging files to prevent data type conflicts and ensure successful queries. Use schema evolution practices for changing data structures. Schema compatibility prevents runtime errors in data access. This practice is important for long-term data management.

#### ✅ Validate File Integrity
- **Reason:** Ensures data reliability and prevents corruption issues.
- **Priority:** 🟢 Could
- **Description:** Implement checksum validation and file size checks after Parquet creation to detect corruption or incomplete writes. Use verification tools to confirm data integrity. File integrity validation provides confidence in stored data. This practice is crucial for critical business data.

#### ❌ Use Gzip Compression for Read-Heavy Workloads
- **Reason:** Optimizes for read performance in analytical scenarios.
- **Priority:** ❌ Won't
- **Description:** Never use gzip compression for Parquet files in read-heavy analytical workloads, as it provides slower decompression speeds compared to Snappy or other codecs optimized for reads. Gzip prioritizes compression ratio over speed, leading to poor query performance. This practice results in slow analytical queries and frustrated users. Always choose compression codecs that balance compression with read performance.

#### ❌ Don't Partition Large Datasets
- **Reason:** Enables efficient querying through partition pruning.
- **Priority:** ❌ Won't
- **Description:** Never save large ServiceNow datasets as single Parquet files without partitioning, as this prevents partition pruning and forces full file scans for most queries. Single large files are inefficient for analytical workloads with selective queries. This practice leads to poor query performance and wasted computational resources. Always implement appropriate partitioning strategies for large datasets.

### 📁 Pipeline Orchestration

#### ✅ Modularize Pipeline Components
- **Reason:** Improves maintainability and enables component reuse.
- **Priority:** 🟡 Should
- **Description:** Break the ServiceNow pipeline into discrete functions for connection, extraction, transformation, and storage to facilitate testing and maintenance. Use clear function names and docstrings. Modularization enables easier debugging and updates. This practice supports long-term pipeline evolution.

#### ✅ Implement Logging Throughout
- **Reason:** Provides visibility into pipeline execution and aids troubleshooting.
- **Priority:** 🟡 Should
- **Description:** Add comprehensive logging at each pipeline stage, including API calls, data volumes, and processing times for monitoring and debugging. Use structured logging with appropriate levels. Logging throughout enables effective pipeline monitoring. This practice is essential for production pipeline management.

#### ✅ Handle Pipeline Failures
- **Reason:** Ensures graceful degradation and enables recovery from errors.
- **Priority:** 🟡 Should
- **Description:** Implement try-except blocks and failure recovery mechanisms throughout the pipeline to handle partial failures and enable resumption. Use checkpointing for long-running processes. Failure handling maintains pipeline reliability. This practice prevents complete pipeline failures.

#### ✅ Monitor Performance Metrics
- **Reason:** Enables optimization and capacity planning for the ServiceNow pipeline.
- **Priority:** 🟢 Could
- **Description:** Track key metrics like API response times, data processing rates, and storage efficiency to identify bottlenecks and optimization opportunities. Implement performance monitoring tools. Metrics monitoring supports continuous improvement. This practice helps maintain optimal pipeline performance.

#### ✅ Automate Pipeline Execution
- **Reason:** Reduces manual effort and ensures consistent, timely data extraction.
- **Priority:** 🟢 Could
- **Description:** Schedule automated pipeline runs using tools like cron, Apache Airflow, or Prefect for regular ServiceNow data updates. Implement proper error notification. Automation ensures reliable data freshness. This practice is valuable for operational data pipelines.

#### ❌ Write Monolithic Pipeline Scripts
- **Reason:** Improves maintainability and enables easier testing and debugging.
- **Priority:** ❌ Won't
- **Description:** Never create single, monolithic scripts for ServiceNow data pipelines, as this leads to unmaintainable code that's difficult to test, debug, and modify. Monolithic scripts mix concerns and make it hard to isolate issues. This practice results in fragile pipelines that are expensive to maintain. Always break pipelines into modular, reusable components.

#### ❌ Don't Log Pipeline Execution
- **Reason:** Enables monitoring, troubleshooting, and performance analysis.
- **Priority:** ❌ Won't
- **Description:** Never omit logging from ServiceNow pipelines, as this makes it impossible to monitor execution, troubleshoot issues, or analyze performance. Without logs, pipeline failures become mysterious and resolution takes much longer. This practice leads to poor operational visibility and increased downtime. Always implement comprehensive logging throughout the pipeline.

#### ❌ Ignore Pipeline Failure Recovery
- **Reason:** Ensures pipeline resilience and minimizes data loss.
- **Priority:** ❌ Won't
- **Description:** Never deploy ServiceNow pipelines without proper failure recovery mechanisms, as this leads to complete pipeline stops and potential data loss during errors. Ignoring recovery means every failure requires manual intervention. This practice results in unreliable data delivery and operational inefficiency. Always implement checkpointing, retry logic, and graceful failure handling.

### 📁 Security and Compliance

#### ✅ Encrypt Sensitive Data
- **Reason:** Protects confidential ServiceNow information from unauthorized access.
- **Priority:** 🔴 Must
- **Description:** Implement encryption for sensitive fields during storage and transmission to comply with data protection regulations and organizational security policies. Use appropriate encryption standards for data at rest and in transit. Data encryption prevents information leakage. This practice is mandatory for handling sensitive business data.

#### ✅ Implement Access Controls
- **Reason:** Ensures only authorized users can access ServiceNow data and pipeline outputs.
- **Priority:** 🔴 Must
- **Description:** Configure proper file permissions and access controls for Parquet files and pipeline artifacts to prevent unauthorized data access. Use role-based access control where applicable. Access controls maintain data security throughout the pipeline. This practice supports compliance with security frameworks.

#### ✅ Audit API Interactions
- **Reason:** Provides accountability and enables security monitoring of ServiceNow access.
- **Priority:** 🟡 Should
- **Description:** Log all API interactions with timestamps, user context, and operation details for security auditing and compliance purposes. Implement audit trails without exposing sensitive data. API auditing supports incident investigation and compliance reporting. This practice is important for regulated environments.

#### ✅ Comply with Data Regulations
- **Reason:** Ensures legal compliance when handling ServiceNow data.
- **Priority:** 🟡 Should
- **Description:** Adhere to relevant data protection regulations like GDPR or HIPAA when processing ServiceNow data, implementing appropriate data handling and retention policies. Consult legal requirements for specific data types. Regulatory compliance prevents legal and financial risks. This practice is essential for enterprise data pipelines.

#### ✅ Regularly Update Dependencies
- **Reason:** Maintains security and performance through current library versions.
- **Priority:** 🟢 Could
- **Description:** Keep Python libraries like requests, pandas, and pyarrow updated to benefit from security patches and performance improvements. Monitor for deprecated features. Dependency updates prevent security vulnerabilities. This practice ensures long-term pipeline stability.

#### ❌ Store Data Unencrypted
- **Reason:** Protects sensitive ServiceNow data from unauthorized access.
- **Priority:** ❌ Won't
- **Description:** Never store ServiceNow data without proper encryption, as this leaves sensitive information vulnerable to unauthorized access and breaches. Unencrypted data can be easily read by anyone with file access. This practice violates data protection regulations and exposes organizations to significant security risks. Always implement encryption for sensitive data at rest and in transit.

#### ❌ Grant Excessive Permissions
- **Reason:** Minimizes security risks through the principle of least privilege.
- **Priority:** ❌ Won't
- **Description:** Never provide ServiceNow API credentials or file access with more permissions than necessary, as this increases the blast radius of potential security incidents. Excessive permissions can lead to accidental data modification or broader access than required. This practice violates security best practices and increases compliance risks. Always implement least privilege access controls.
