# Configuration

> **BIS Handbook 2.0** — Config-First Architecture, API Specifications, and Workspaces  
> **Last Updated:** September 13, 2025  
> **Navigation:** [🏠 Main Handbook](../README.md) | [Previous: Technical Architecture](04-Technical-Architecture.md) | [Next: Engineering Processes](06-Engineering-Processes.md)

---

## Section Overview

**Overview:** Config-first architecture guide covering YAML playbooks, API structures, workspace management, and validation frameworks.

**Target Audience:** Developers, DevOps engineers, system administrators, and AI agents working with configuration.

**How to Use:** Use for setting up workspaces, writing playbooks, validating configurations, and understanding API structures. Reference for config-driven development.

**Key Content:** YAML and playbook development, API structure and validation, workspaces and tenancy, specifications and documentation, Everything-as-Code inventory, secrets and environment management.

**Use Cases:** Workspace setup, playbook development, configuration validation, API integration, environment management.

---

## Table of Contents

- [Report as Code](#report-as-code)
- [BIS API](#bis-api)
- [Workspaces and Tenancy](#workspaces-and-tenancy)
- [Specifications and Documentation](#specifications-and-documentation)
- [Everything-as-Code](#everything-as-code)
- [Secrets and Environment](#secrets-and-environment)
- [Navigation](#navigation)

---

## Report as Code

Workspaces and practices authored as YAML using declarative API. Validate against schema and keep IDs, anchors, and names stable.

- Example: See sample jobs under `workspace/*/*.yml` and formats in `workspace/*/formats.yml`

### Authoring Style
- Keep names stable, IDs unique, and anchors meaningful
- Prefer small, testable additions; avoid breaking changes without release plan

---

## BIS API

The BIS API provides authoritative schema definition for the Business Intelligence System. This document ensures **bidirectional consistency** between:

- **API Schema** ↔ **Python Implementation**
- **API Schema** ↔ **Dummy Data** (AI-generated for testing)
- **API Schema** ↔ **Production Jobs** (human-created configurations)
- **Python Code** ↔ **Input Data** (runtime validation)

> **⚠️ CRITICAL**: All validation must be bidirectional. Keywords in jobs must exist in API, and all API keywords must be supported by Python code.

### Primary Components

| Component | Purpose | Validation Context | Python Implementation |
|-----------|---------|-------------------|---------------------|
| **table** | SQL data extraction with DuckDB | Referenced by snapshots/symptoms/actions | `engine/src/low/table.py` |
| **symptom** | Data quality issue detection | Core business logic validation | `engine/src/low/symptom.py` |
| **action** | Automated remediation workflows | Engine-forced column validation | `engine/src/low/action.py` |
| **snapshots** | KPI time-series tracking | Numeric analytics validation | `engine/src/low/snapshot.py` |
| **trends** | Historical data accumulation | Persistent storage validation | `engine/src/low/trend.py` |
| **indicator** | End-to-end processing pipeline | Complete workflow orchestration | `engine/src/high/indicator.py` |

### Supporting Components

| Component | Purpose | Validation Context | Python Implementation |
|-----------|---------|-------------------|---------------------|
| **styler** | Excel report formatting | Layout and positioning | `engine/src/low/styler.py` |
| **formats_class** | Excel format templates | Reusable styling rules | `engine/src/excl/excel_format.py` |
| **rules_class** | Conditional formatting rules | XlsxWriter validation | `engine/src/excl/excel_table.py` |
| **column_formatting** | Report-specific formatting | Template application | `engine/src/excl/excel_table.py` |
| **practice** | Indicator grouping | Orchestration logic | `engine/src/high/practice.py` |
| **workspace** | Tenant configuration | Multi-tenant isolation | `engine/src/high/workspace.py` |
| **pipeline** | Execution orchestration | Task scheduling | `engine/src/high/pipeline.py` |
| **scheduler** | Time-based triggers | Cron validation | `engine/src/high/scheduler.py` |
| **data_model** | ETL configuration | Data pipeline validation | `engine/src/model/data_model.py` |

### Validation Workflows

#### 1. Schema vs Python Code Validation
Ensure Python implementation supports all API keywords and data structures.

#### 2. API vs Dummy Data Validation
Ensure AI-generated test data conforms to API schema for reliable testing.

#### 3. API vs Production Jobs Validation
Ensure human-created job configurations are valid and complete.

#### 4. Python Code Testing with Dummy Data
Use dummy data to test Python implementation during development.

### Practical Usage Guidelines

#### For AI Agents (Primary Audience)
- **Job Generation Workflow**: Requirement Analysis → Schema-Compliant Generation → Bidirectional Validation → Python Compatibility Check

---

## Configuration Examples

### Complete Workspace Configuration

```yaml
# Example BIS Workspace Configuration
workspace:
  name: "Customer_Satisfaction_Monitoring"
  description: "Monitor and analyze customer satisfaction metrics"
  version: "1.0.0"
  
  # Data sources
  tables:
    - name: "customer_feedback"
      source: "snowflake://customer_db.feedback_table"
      columns:
        - name: "customer_id"
          type: "integer"
          required: true
        - name: "satisfaction_score"
          type: "decimal"
          range: [1, 5]
        - name: "feedback_date"
          type: "date"
          required: true
        - name: "feedback_text"
          type: "string"
          max_length: 1000
  
  # Business logic
  indicators:
    - name: "avg_satisfaction"
      description: "Average customer satisfaction score"
      table: "customer_feedback"
      calculation: "AVG(satisfaction_score)"
      schedule: "daily"
      
      # Quality checks
      symptoms:
        - name: "low_satisfaction_alert"
          condition: "avg_satisfaction < 3.0"
          severity: "high"
          message: "Customer satisfaction below threshold"
      
      # Automated actions
      actions:
        - name: "escalate_low_satisfaction"
          trigger: "low_satisfaction_alert"
          type: "email"
          recipients: ["manager@company.com"]
          template: "satisfaction_alert"
      
      # Historical tracking
      snapshots:
        - name: "daily_satisfaction"
          frequency: "daily"
          retention: "90_days"
      
      trends:
        - name: "satisfaction_trend"
          period: "30_days"
          calculation: "linear_regression"
  
  # Report generation
  reports:
    - name: "weekly_satisfaction_report"
      format: "excel"
      schedule: "weekly"
      recipients: ["stakeholders@company.com"]
      
      # Excel formatting
      styling:
        header_format:
          bold: true
          background_color: "#4472C4"
          font_color: "white"
        data_format:
          number_format: "0.00"
```

### Indicator Configuration Example

```yaml
# Example Indicator for SLA Monitoring
indicator:
  name: "sla_compliance_monitor"
  description: "Monitor service level agreement compliance"
  
  # Data extraction
  table:
    name: "service_requests"
    query: |
      SELECT 
        request_id,
        created_date,
        resolved_date,
        priority,
        CASE 
          WHEN priority = 'Critical' THEN 4
          WHEN priority = 'High' THEN 8
          WHEN priority = 'Medium' THEN 24
          WHEN priority = 'Low' THEN 72
        END as sla_hours
      FROM service_requests
      WHERE status = 'Resolved'
  
  # Business rules
  symptoms:
    - name: "sla_breach"
      condition: "TIMESTAMPDIFF(HOUR, created_date, resolved_date) > sla_hours"
      severity: "critical"
      message: "SLA breach detected for request {request_id}"
  
  # Automated response
  actions:
    - name: "notify_sla_breach"
      trigger: "sla_breach"
      type: "teams_message"
      channel: "sla-alerts"
      message: "🚨 SLA Breach Alert: Request {request_id} exceeded SLA by {TIMESTAMPDIFF(HOUR, created_date, resolved_date) - sla_hours} hours"
  
  # Excel report configuration
  excel_config:
    worksheet: "SLA_Compliance"
    columns:
      - name: "Request ID"
        field: "request_id"
        width: 15
      - name: "Created Date"
        field: "created_date"
        format: "date"
        width: 12
      - name: "Resolved Date"
        field: "resolved_date"
        format: "date"
        width: 12
      - name: "Priority"
        field: "priority"
        width: 10
      - name: "SLA Hours"
        field: "sla_hours"
        format: "number"
        width: 10
      - name: "Actual Hours"
        field: "TIMESTAMPDIFF(HOUR, created_date, resolved_date)"
        format: "number"
        width: 12
      - name: "SLA Status"
        field: "CASE WHEN TIMESTAMPDIFF(HOUR, created_date, resolved_date) > sla_hours THEN 'BREACHED' ELSE 'COMPLIANT' END"
        format: "conditional"
        width: 12
```

### Practice Configuration Example

```yaml
# Example Practice for IT Operations Dashboard
practice:
  name: "it_operations_dashboard"
  description: "Comprehensive IT operations monitoring and reporting"
  
  indicators:
    - "server_uptime_monitor"
    - "network_performance"
    - "security_incidents"
    - "backup_success_rate"
    - "ticket_resolution_time"
  
  # Combined reporting
  report:
    name: "it_operations_weekly"
    format: "excel"
    schedule: "weekly"
    template: "it_dashboard_template.xlsx"
    
    # Multi-sheet configuration
    worksheets:
      - name: "Executive_Summary"
        indicators: ["server_uptime_monitor", "ticket_resolution_time"]
        charts:
          - type: "line"
            title: "Server Uptime Trend"
            data: "server_uptime_monitor.snapshots"
          - type: "bar"
            title: "Ticket Resolution by Priority"
            data: "ticket_resolution_time.distribution"
      
      - name: "Detailed_Metrics"
        indicators: ["network_performance", "security_incidents", "backup_success_rate"]
        pivot_tables:
          - name: "Performance_by_Department"
            source: "network_performance"
            rows: ["department"]
            values: ["avg_response_time", "error_rate"]
```

---
- **Common Patterns**: Indicator Generation, Schema-Compliant Generation, Bidirectional Validation

---

## Workspaces and Tenancy

Tenants live under `workspace/<tenant_id>`. Isolation is strict and schema evolution is additive. Avoid cross-tenant references; keep macros and formats per tenant unless explicitly shared.

### Tenant Benefits
- Crystal-clear boundaries that protect data, performance, and trust
- Autonomy to evolve at different speeds without entanglement

---

## Specifications and Documentation

Use stable names and anchors consistently. Generate or refresh docs by referencing module READMEs and architecture doc; keep examples minimal and link to living sources.

### Documentation Promise
- Clear, current, and connected. Every spec points to its implementation and examples

---

## Everything-as-Code

Why this matters: Consistency, auditability, and speed—all from one playbook.

### ELT as Code
- Pipelines, schedulers, and SQL templates: Data extraction, loading, and transformation defined in code for automation and reliability

### Lake as Code
- Views and paths: Data lake structures codified, enabling consistent data access and management across environments

### Indicator as Code
- YAML specs for practices and indicators: KPIs and metrics specified in YAML for easy modification and reuse, supporting agile indicator development

### Visualization as Code
- Excel formats and widgets: Report layouts and styles defined in code for professional, consistent outputs that adapt to data changes

### Delivery as Code
- Email templates and policies: Communication and distribution automated with templated policies, ensuring timely and personalized delivery

### Analytics as Code
- Benchmarks and composite indices: Analytical computations scripted for accuracy and repeatability, incorporating business logic seamlessly

### API as Code
- BIS API YAML: Interfaces defined in schema for interoperability and validation, facilitating integrations and extensions

### Docs as Code
- Wiki and module READMEs: Documentation maintained as code, ensuring it stays current with changes and is version-controlled

### AI Agents as Code
- Chatmodes and prompts: AI interactions scripted for consistency and safety, with guardrails for responsible use

### Quality as Code
- Quality.yml and checks: Data quality rules codified for automated validation, preventing issues at scale

### Schedules as Code
- Scheduler rules: Execution timing defined in code for predictable runs, with flexibility for business needs

### Release as Code
- Release.yml: Deployment and versioning managed through code for controlled releases and rollback capabilities

---

## Secrets and Environment

| Do | Do not |
|---|---|
| Use Windows credential stores or secret managers | Commit secrets or tokens |
| Gate Outlook COM usage and handle headless | Assume Outlook is present in CI |
| Keep per-tenant configuration separated | Mix tenant data or configs |
| Rotate credentials regularly | Leave long-lived access unattended |

---

## Navigation

**[🏠 Main Handbook](../README.md)** | **[Previous: Technical Architecture](04-Technical-Architecture.md)** | **[Next: Engineering Processes](06-Engineering-Processes.md)**

### Quick Links
- [📋 Complete Table of Contents](../README.md#table-of-contents)
- [🎯 Executive Summary](../README.md#executive-summary)
- [🔗 Key Resources](../README.md#key-resources)
- [📚 All Handbook Sections](../README.md#handbook-sections)

---

## BIS API Schema Components and Validation

### Schema Architecture Overview

The BIS API implements a comprehensive YAML schema system with anchors, validation rules, and type-safe configurations designed for AI-assisted development.

#### Core Schema Structure
```yaml
meta:
  schema_version: "1.0"
  updated: "2025-09-13"
  owner: "BIS Team"
  id: "BIS-API-v2"

# Anchors for reusability
workspace_formats: &API_WORKSPACE_FORMATS
  colors: &API_COLORS
    primary: "#FF0000"
    secondary: "#00FF00"
  formats_class: &API_WORKSPACE_FORMAT
    header_fmt:
      font_name: "Arial"
      font_size: 12
      bold: true
  rules_class: &API_WORKSPACE_RULES
    - name: "highlight_negative"
      type: "cell"
      operator: "<"
      value: "0"
```

### YAML Validation Rules and Best Practices

#### Type System and Validation

##### Data Types
- **string**: Text values, identifiers, and descriptions
- **integer**: Numeric values, counts, and sizes
- **bool**: Boolean flags (true/false)
- **list**: Arrays of values or objects
- **object**: Complex nested structures

##### Validation Patterns
```yaml
# Required fields validation
table:
  active: bool           # Must be present
  schema_table: string   # Required identifier
  description: string    # Required documentation

# Optional fields with defaults
table:
  min_rows?: integer     # Optional with default 1
  max_rows?: integer     # Optional constraint

# Enum validation
type: string            # Must be one of: "cell", "formula", "text", "date"
operator: string        # Must be one of: "<", ">", "<=", ">=", "==", "!="
```

#### Schema Validation Rules

##### Structural Validation
- **Required vs Optional**: Clear distinction between mandatory and optional fields
- **Type Safety**: Strict type checking for all values
- **Reference Integrity**: Anchors and references must resolve correctly
- **Dependency Validation**: Cross-component dependencies verified

##### Business Logic Validation
- **Range Checks**: Numeric values within acceptable bounds
- **Format Validation**: Strings matching expected patterns (dates, emails, URLs)
- **Reference Checks**: Foreign key relationships and dependencies
- **Consistency Rules**: Business logic constraints across components

### Configuration Management Best Practices

#### YAML Authoring Guidelines

##### Naming Conventions
```yaml
# Use kebab-case for file names
workspace-config.yml
indicator-definition.yml

# Use snake_case for identifiers
schema_table: "sla.incidents"
column_name: "incident_id"

# Use PascalCase for class names
TExcelReport
TWorkspace

# Use UPPER_CASE for constants
MAX_RETRY_COUNT: 3
DEFAULT_TIMEOUT: 300
```

##### Structure Organization
```yaml
# Group related configurations
workspace:
  metadata:
    name: "Production Workspace"
    version: "1.0"
  settings:
    timezone: "UTC"
    locale: "en-US"
  components:
    indicators: [...]
    reports: [...]
```

#### Configuration Patterns

##### Template Reuse with Anchors
```yaml
# Define reusable templates
base_table: &BASE_TABLE
  active: true
  replace_na: "N/A"
  min_rows: 1

# Extend templates
incident_table:
  <<: *BASE_TABLE
  schema_table: "sla.incidents"
  description: "Incident tracking data"
  sql_file: "queries/incidents.sql"
```

##### Environment-Specific Overrides
```yaml
# Base configuration
base_config: &BASE_CONFIG
  database:
    host: "localhost"
    port: 5432
  logging:
    level: "INFO"

# Environment overrides
development:
  <<: *BASE_CONFIG
  database:
    host: "dev-db.example.com"

production:
  <<: *BASE_CONFIG
  database:
    host: "prod-db.example.com"
  logging:
    level: "ERROR"
```

### Advanced Configuration Features

#### Dynamic Configuration with Templates

##### Jinja2 Template Integration
```yaml
# Template variables
template_vars:
  tenant_id: "ACME_CORP"
  report_date: "{{ today() }}"

# Dynamic SQL generation
table:
  sql_code: |
    SELECT *
    FROM {{ tenant_id | lower }}_incidents
    WHERE created_date >= '{{ report_date }}'
```

##### Conditional Logic
```yaml
# Conditional configuration based on environment
{% if environment == "production" %}
database:
  host: "prod-db.example.com"
  ssl: true
{% else %}
database:
  host: "dev-db.example.com"
  ssl: false
{% endif %}
```

#### Configuration Versioning and Migration

##### Version Management
```yaml
meta:
  schema_version: "2.0"
  migration_path: "1.0_to_2.0"
  breaking_changes: false

# Backward compatibility markers
deprecated_fields:
  - "old_field_name"

# Migration helpers
migration_helpers:
  field_mappings:
    old_field: "new_field"
  value_transforms:
    "old_value": "new_value"
```

### Configuration Testing and Validation

#### Automated Validation

##### Schema Validation
```python
import yaml
import jsonschema

def validate_config(config_file, schema_file):
    with open(config_file) as f:
        config = yaml.safe_load(f)

    with open(schema_file) as f:
        schema = yaml.safe_load(f)

    jsonschema.validate(config, schema)
    return True
```

##### Business Rule Validation
```python
def validate_business_rules(config):
    # Check cross-component consistency
    indicators = config.get('indicators', [])
    for indicator in indicators:
        # Validate table references exist
        table_ref = indicator.get('table')
        if table_ref not in config.get('tables', {}):
            raise ValueError(f"Table {table_ref} not found")

        # Validate column references
        columns = indicator.get('columns', [])
        table_columns = config['tables'][table_ref].get('columns', [])
        for col in columns:
            if col not in table_columns:
                raise ValueError(f"Column {col} not in table {table_ref}")
```

#### Configuration Testing Patterns

##### Unit Testing Configurations
```python
def test_indicator_config():
    config = load_config('indicator.yml')

    # Test required fields
    assert 'name' in config
    assert 'table' in config

    # Test data types
    assert isinstance(config['active'], bool)
    assert isinstance(config['description'], str)

    # Test business rules
    validate_business_rules(config)
```

##### Integration Testing
```python
def test_config_integration():
    # Load complete workspace configuration
    workspace = load_workspace_config()

    # Test component interactions
    test_table_indicator_integration(workspace)
    test_report_generation(workspace)

    # Test end-to-end pipeline
    test_pipeline_execution(workspace)
```

### Configuration Security and Compliance

#### Secrets Management

##### Secure Storage Patterns
```yaml
# Reference external secrets
database:
  host: "{{ vault('db/host') }}"
  password: "{{ vault('db/password') }}"

# Environment variable injection
api_keys:
  openai: "{{ env('OPENAI_API_KEY') }}"
  database: "{{ env('DB_PASSWORD') }}"
```

##### Access Control
```yaml
# Role-based configuration access
access_control:
  roles:
    - name: "admin"
      permissions: ["read", "write", "delete"]
    - name: "analyst"
      permissions: ["read"]
  policies:
    - resource: "sensitive_data"
      roles: ["admin"]
      conditions: ["ip_whitelist"]
```

#### Compliance Validation

##### Audit Trail Configuration
```yaml
audit:
  enabled: true
  log_level: "INFO"
  retention_days: 365
  fields:
    - "user_id"
    - "timestamp"
    - "action"
    - "resource"
```

##### Data Privacy Controls
```yaml
privacy:
  pii_fields:
    - "customer_name"
    - "email_address"
    - "phone_number"
  masking_rules:
    - field: "email_address"
      method: "partial_mask"
      pattern: "***@***.com"
  retention_policies:
    - data_type: "logs"
      retention_days: 90
```

### Configuration Deployment and Operations

#### Deployment Strategies

##### Blue-Green Deployment
```yaml
deployment:
  strategy: "blue_green"
  blue_config: "config_v1.yml"
  green_config: "config_v2.yml"
  traffic_split: 0.1  # 10% to green
  rollback_timeout: 300
```

##### Canary Deployment
```yaml
deployment:
  strategy: "canary"
  canary_config: "config_new.yml"
  rollout_percentage: 5
  success_metrics:
    - name: "error_rate"
      threshold: 0.01
    - name: "latency"
      threshold: 1000
```

#### Operational Monitoring

##### Configuration Drift Detection
```yaml
monitoring:
  drift_detection:
    enabled: true
    check_interval: 3600  # seconds
    alert_threshold: 0.05  # 5% drift
  compliance_checks:
    - name: "schema_validation"
      frequency: "daily"
    - name: "security_scan"
      frequency: "weekly"
```

This comprehensive configuration framework ensures reliable, maintainable, and secure BIS deployments with strong validation and operational controls.

---

## Practical Configuration Templates and Examples

### Complete Workspace Configuration Template

#### Basic Workspace Setup Template

```yaml
# workspace/{tenant_id}/workspace.yml
# Complete workspace configuration template

workspace:
  id: "acme_corp"  # Unique tenant identifier
  name: "ACME Corporation"
  description: "Manufacturing and operations analytics"
  version: "1.0.0"
  owner: "operations@acme.com"
  
  # Environment settings
  environment:
    type: "production"  # development, staging, production
    region: "us-east-1"
    timezone: "America/New_York"
    
  # Data sources configuration
  data_sources:
    primary_database:
      type: "postgresql"
      host: "prod-db.acme.com"
      port: 5432
      database: "operations"
      schema: "analytics"
      connection_pool:
        min_connections: 5
        max_connections: 20
        connection_timeout: 30
        
    data_lake:
      type: "s3"
      bucket: "acme-data-lake"
      region: "us-east-1"
      prefix: "analytics/"
      compression: "snappy"
      
  # Security and access control
  security:
    authentication:
      method: "oauth2"
      provider: "azure_ad"
      client_id: "${AZURE_CLIENT_ID}"
      tenant_id: "${AZURE_TENANT_ID}"
      
    authorization:
      roles:
        - name: "admin"
          permissions: ["read", "write", "delete", "admin"]
        - name: "analyst"
          permissions: ["read", "write"]
        - name: "viewer"
          permissions: ["read"]
          
    encryption:
      data_at_rest: true
      data_in_transit: true
      key_rotation_days: 90
      
  # Processing configuration
  processing:
    engine: "duckdb"
    memory_limit_gb: 64
    cpu_cores: 16
    temp_directory: "/tmp/bis_processing"
    
    # Query optimization settings
    optimization:
      enable_caching: true
      cache_ttl_minutes: 60
      enable_parallel_processing: true
      max_parallel_queries: 8
      
  # Output and delivery configuration
  delivery:
    excel:
      template_path: "templates/standard_report.xlsx"
      max_rows_per_sheet: 1000000
      compression: "zip"
      
    email:
      smtp_server: "smtp.acme.com"
      smtp_port: 587
      use_tls: true
      from_address: "bis-reports@acme.com"
      
    api:
      base_url: "https://api.acme.com/bis"
      authentication: "bearer_token"
      rate_limit_per_minute: 100
      
  # Monitoring and alerting
  monitoring:
    enable_metrics: true
    metrics_retention_days: 90
    
    alerts:
      - name: "query_performance"
        condition: "avg_query_time > 300"
        severity: "warning"
        channels: ["email", "slack"]
        
      - name: "data_quality"
        condition: "error_rate > 0.05"
        severity: "critical"
        channels: ["email", "pagerduty"]
        
  # Backup and recovery
  backup:
    schedule: "daily"
    retention_days: 30
    encryption: true
    destinations:
      - type: "s3"
        bucket: "acme-bis-backups"
      - type: "local"
        path: "/backups/bis"
        
  # Logging configuration
  logging:
    level: "INFO"
    format: "json"
    destinations:
      - type: "file"
        path: "/logs/bis.log"
        max_size_mb: 100
        max_files: 10
      - type: "cloudwatch"
        log_group: "/bis/production"
```

#### Indicator Configuration Template

```yaml
# workspace/{tenant_id}/indicators/customer_satisfaction.yml
# Customer satisfaction indicator configuration

indicator:
  id: "customer_satisfaction"
  name: "Customer Satisfaction Index"
  description: "Tracks customer satisfaction across all touchpoints"
  category: "customer_experience"
  owner: "customer_success@acme.com"
  
  # Data sources
  data_sources:
    - name: "survey_data"
      type: "database"
      table: "customer_surveys"
      columns:
        - name: "customer_id"
          type: "string"
        - name: "survey_date"
          type: "date"
        - name: "nps_score"
          type: "integer"
        - name: "satisfaction_rating"
          type: "integer"
          
    - name: "support_tickets"
      type: "database"
      table: "support_tickets"
      columns:
        - name: "customer_id"
          type: "string"
        - name: "ticket_date"
          type: "date"
        - name: "resolution_time_hours"
          type: "float"
        - name: "satisfaction_score"
          type: "integer"
          
  # Symptoms (early warning indicators)
  symptoms:
    - id: "low_nps_trend"
      name: "Declining NPS Trend"
      description: "NPS score declining over 3 consecutive periods"
      query: |
        SELECT 
          customer_id,
          AVG(nps_score) as avg_nps,
          COUNT(*) as survey_count
        FROM survey_data
        WHERE survey_date >= CURRENT_DATE - INTERVAL '90 days'
        GROUP BY customer_id
        HAVING AVG(nps_score) < 7
      threshold: 7
      operator: "less_than"
      severity: "warning"
      
    - id: "high_support_volume"
      name: "High Support Ticket Volume"
      description: "Customer generating excessive support tickets"
      query: |
        SELECT 
          customer_id,
          COUNT(*) as ticket_count
        FROM support_tickets
        WHERE ticket_date >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY customer_id
        HAVING COUNT(*) > 10
      threshold: 10
      operator: "greater_than"
      severity: "critical"
      
  # Actions (automated responses)
  actions:
    - id: "send_followup_survey"
      name: "Send Follow-up Satisfaction Survey"
      description: "Send additional survey to understand satisfaction drivers"
      trigger_symptoms: ["low_nps_trend"]
      type: "email"
      template: "followup_survey.html"
      recipients: ["customer_success@acme.com"]
      priority: "high"
      
    - id: "escalate_to_management"
      name: "Escalate to Customer Success Manager"
      description: "Escalate high-volume support cases to management"
      trigger_symptoms: ["high_support_volume"]
      type: "notification"
      recipients: ["customer_manager@acme.com", "support_lead@acme.com"]
      priority: "urgent"
      
  # Trends and analytics
  trends:
    - id: "nps_trend"
      name: "NPS Trend Analysis"
      description: "Monthly NPS trend with seasonal adjustments"
      calculation: |
        SELECT 
          DATE_TRUNC('month', survey_date) as month,
          AVG(nps_score) as avg_nps,
          COUNT(*) as survey_count,
          STDDEV(nps_score) as nps_volatility
        FROM survey_data
        WHERE survey_date >= CURRENT_DATE - INTERVAL '12 months'
        GROUP BY DATE_TRUNC('month', survey_date)
        ORDER BY month
      chart_type: "line"
      
  # Benchmarks and targets
  benchmarks:
    - id: "nps_target"
      name: "NPS Target Achievement"
      description: "Comparison against target NPS score"
      target_value: 8.5
      comparison: "greater_than"
      tolerance: 0.5
      
  # Report configuration
  report:
    format: "excel"
    template: "customer_satisfaction_template.xlsx"
    sheets:
      - name: "Executive Summary"
        charts:
          - type: "gauge"
            metric: "avg_nps"
            target: 8.5
          - type: "trend"
            metric: "nps_trend"
            period: "12_months"
            
      - name: "Detailed Analysis"
        tables:
          - name: "Customer Breakdown"
            columns: ["customer_id", "avg_nps", "survey_count", "last_survey_date"]
            sort_by: "avg_nps"
            sort_order: "ascending"
            
      - name: "Action Items"
        data_source: "actions"
        columns: ["action_id", "description", "priority", "status", "due_date"]
        
  # Schedule configuration
  schedule:
    frequency: "daily"
    time: "06:00"
    timezone: "America/New_York"
    retry_count: 3
    retry_delay_minutes: 15
```

### Environment Setup and Validation Checklists

#### Development Environment Setup Guide

```markdown
# BIS Development Environment Setup Checklist

## Prerequisites Check
- [ ] Python 3.8+ installed
- [ ] Git client installed and configured
- [ ] VS Code with Python and YAML extensions
- [ ] Docker Desktop installed (for local testing)
- [ ] Access to development databases granted

## Repository Setup
- [ ] Clone BIS repository: `git clone https://github.com/acme/bis.git`
- [ ] Checkout development branch: `git checkout develop`
- [ ] Install dependencies: `pip install -r requirements.txt`
- [ ] Install development dependencies: `pip install -r requirements-dev.txt`

## Local Development Environment
- [ ] Create virtual environment: `python -m venv .venv`
- [ ] Activate virtual environment: `.venv\Scripts\activate` (Windows)
- [ ] Install BIS package in development mode: `pip install -e .`
- [ ] Configure environment variables in `.env` file

## Database Configuration
- [ ] Install DuckDB: `pip install duckdb`
- [ ] Create local database: `duckdb data/dev.db`
- [ ] Configure database connection in `config/local.yml`
- [ ] Test database connectivity

## Testing Setup
- [ ] Install pytest: `pip install pytest pytest-cov`
- [ ] Run initial test suite: `pytest tests/`
- [ ] Configure test database: `pytest --setup-db`
- [ ] Verify test coverage requirements met

## IDE Configuration
- [ ] Configure VS Code Python interpreter to use virtual environment
- [ ] Install recommended extensions:
  - Python (Microsoft)
  - Pylance
  - YAML
  - GitLens
  - Python Docstring Generator
- [ ] Configure linting: flake8, black, mypy
- [ ] Set up debugging configuration for BIS applications

## Security Configuration
- [ ] Generate development API keys
- [ ] Configure local authentication (if required)
- [ ] Set up secure credential storage
- [ ] Configure firewall rules for development ports

## Documentation Setup
- [ ] Install MkDocs: `pip install mkdocs`
- [ ] Build local documentation: `mkdocs serve`
- [ ] Verify documentation builds without errors
- [ ] Test cross-references and links

## Validation Steps
- [ ] Run basic health check: `python -m bis.health_check`
- [ ] Execute sample indicator: `python -c "import bis; bis.run_sample()"`
- [ ] Verify logging configuration
- [ ] Test error handling and recovery

## Troubleshooting Common Issues
- **Import Errors**: Check PYTHONPATH includes project root
- **Database Connection**: Verify connection string and credentials
- **Permission Errors**: Ensure proper file permissions on data directories
- **Memory Issues**: Adjust DuckDB memory settings in configuration
- **Network Timeouts**: Check proxy settings and firewall rules
```

#### Configuration Validation Framework

```python
"""
BIS Configuration Validation Framework
Validates YAML configurations against schema and business rules
"""

import yaml
import jsonschema
from typing import Dict, List, Any, Optional
from pathlib import Path
import logging

logger = logging.getLogger(__name__)

class BISConfigurationValidator:
    """Comprehensive validator for BIS YAML configurations"""
    
    def __init__(self, schema_path: str = "schemas/bis_config_schema.json"):
        self.schema_path = Path(schema_path)
        self.schema = self._load_schema()
        self.validation_rules = {
            'workspace': self._validate_workspace_config,
            'indicator': self._validate_indicator_config,
            'data_source': self._validate_data_source_config,
            'security': self._validate_security_config
        }
    
    def _load_schema(self) -> Dict[str, Any]:
        """Load JSON schema for validation"""
        try:
            with open(self.schema_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.warning(f"Schema file not found: {self.schema_path}")
            return {}
    
    def validate_config_file(self, config_path: str) -> Dict[str, Any]:
        """
        Validate a BIS configuration file
        
        Args:
            config_path: Path to YAML configuration file
            
        Returns:
            Validation result with errors and warnings
        """
        try:
            # Load configuration
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
            
            # Validate against JSON schema
            schema_errors = self._validate_against_schema(config)
            
            # Validate against business rules
            business_errors = self._validate_business_rules(config)
            
            # Combine results
            all_errors = schema_errors + business_errors
            
            return {
                'valid': len(all_errors) == 0,
                'errors': all_errors,
                'warnings': self._generate_warnings(config),
                'config_type': self._detect_config_type(config),
                'recommendations': self._generate_recommendations(config)
            }
            
        except yaml.YAMLError as e:
            return {
                'valid': False,
                'errors': [{'type': 'yaml_error', 'message': str(e)}],
                'warnings': [],
                'config_type': 'unknown'
            }
        except Exception as e:
            return {
                'valid': False,
                'errors': [{'type': 'validation_error', 'message': str(e)}],
                'warnings': [],
                'config_type': 'unknown'
            }
    
    def _validate_against_schema(self, config: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Validate configuration against JSON schema"""
        errors = []
        try:
            jsonschema.validate(config, self.schema)
        except jsonschema.ValidationError as e:
            errors.append({
                'type': 'schema_error',
                'field': '.'.join(str(x) for x in e.absolute_path),
                'message': e.message,
                'expected': str(e.schema) if hasattr(e, 'schema') else None
            })
        except jsonschema.SchemaError as e:
            errors.append({
                'type': 'schema_error',
                'message': f"Schema error: {e.message}"
            })
        
        return errors
    
    def _validate_business_rules(self, config: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Validate configuration against business rules"""
        errors = []
        config_type = self._detect_config_type(config)
        
        if config_type in self.validation_rules:
            validator = self.validation_rules[config_type]
            errors.extend(validator(config))
        
        return errors
    
    def _validate_workspace_config(self, config: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Validate workspace configuration"""
        errors = []
        
        # Check required fields
        required_fields = ['id', 'name', 'environment']
        for field in required_fields:
            if field not in config:
                errors.append({
                    'type': 'missing_field',
                    'field': field,
                    'message': f"Required field '{field}' is missing"
                })
        
        # Validate workspace ID format
        if 'id' in config:
            workspace_id = config['id']
            if not workspace_id.replace('_', '').replace('-', '').isalnum():
                errors.append({
                    'type': 'invalid_format',
                    'field': 'id',
                    'message': "Workspace ID must contain only alphanumeric characters, underscores, and hyphens"
                })
        
        # Validate environment settings
        if 'environment' in config:
            env = config['environment']
            valid_env_types = ['development', 'staging', 'production']
            if env.get('type') not in valid_env_types:
                errors.append({
                    'type': 'invalid_value',
                    'field': 'environment.type',
                    'message': f"Environment type must be one of: {', '.join(valid_env_types)}"
                })
        
        return errors
    
    def _validate_indicator_config(self, config: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Validate indicator configuration"""
        errors = []
        
        # Check required fields
        required_fields = ['id', 'name', 'data_sources']
        for field in required_fields:
            if field not in config:
                errors.append({
                    'type': 'missing_field',
                    'field': field,
                    'message': f"Required field '{field}' is missing"
                })
        
        # Validate data sources
        if 'data_sources' in config:
            for i, ds in enumerate(config['data_sources']):
                if 'name' not in ds:
                    errors.append({
                        'type': 'missing_field',
                        'field': f'data_sources[{i}].name',
                        'message': f"Data source {i} missing required 'name' field"
                    })
        
        # Validate symptoms
        if 'symptoms' in config:
            for i, symptom in enumerate(config['symptoms']):
                if 'query' not in symptom:
                    errors.append({
                        'type': 'missing_field',
                        'field': f'symptoms[{i}].query',
                        'message': f"Symptom {i} missing required 'query' field"
                    })
        
        return errors
    
    def _validate_data_source_config(self, config: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Validate data source configuration"""
        errors = []
        
        # Check required fields
        required_fields = ['type', 'connection']
        for field in required_fields:
            if field not in config:
                errors.append({
                    'type': 'missing_field',
                    'field': field,
                    'message': f"Required field '{field}' is missing"
                })
        
        # Validate connection based on type
        if 'type' in config and 'connection' in config:
            ds_type = config['type']
            connection = config['connection']
            
            if ds_type == 'postgresql':
                required_conn_fields = ['host', 'port', 'database']
                for field in required_conn_fields:
                    if field not in connection:
                        errors.append({
                            'type': 'missing_field',
                            'field': f'connection.{field}',
                            'message': f"PostgreSQL connection missing required '{field}' field"
                        })
            elif ds_type == 's3':
                required_conn_fields = ['bucket', 'region']
                for field in required_conn_fields:
                    if field not in connection:
                        errors.append({
                            'type': 'missing_field',
                            'field': f'connection.{field}',
                            'message': f"S3 connection missing required '{field}' field"
                        })
        
        return errors
    
    def _validate_security_config(self, config: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Validate security configuration"""
        errors = []
        
        # Check authentication configuration
        if 'authentication' in config:
            auth = config['authentication']
            if auth.get('method') == 'oauth2':
                required_fields = ['provider', 'client_id']
                for field in required_fields:
                    if field not in auth:
                        errors.append({
                            'type': 'missing_field',
                            'field': f'authentication.{field}',
                            'message': f"OAuth2 authentication missing required '{field}' field"
                        })
        
        # Check authorization configuration
        if 'authorization' in config:
            authz = config['authorization']
            if 'roles' in authz:
                for i, role in enumerate(authz['roles']):
                    if 'name' not in role:
                        errors.append({
                            'type': 'missing_field',
                            'field': f'authorization.roles[{i}].name',
                            'message': f"Role {i} missing required 'name' field"
                        })
        
        return errors
    
    def _detect_config_type(self, config: Dict[str, Any]) -> str:
        """Detect the type of BIS configuration"""
        if 'workspace' in config:
            return 'workspace'
        elif 'indicator' in config:
            return 'indicator'
        elif 'data_sources' in config:
            return 'data_source'
        elif 'security' in config:
            return 'security'
        else:
            return 'unknown'
    
    def _generate_warnings(self, config: Dict[str, Any]) -> List[str]:
        """Generate warnings for potential issues"""
        warnings = []
        
        # Check for deprecated features
        if 'legacy_field' in str(config):
            warnings.append("Configuration contains deprecated fields that should be updated")
        
        # Check for security best practices
        if 'password' in str(config).lower():
            warnings.append("Consider using environment variables or secret management for sensitive data")
        
        # Check for performance optimizations
        if 'select *' in str(config).lower():
            warnings.append("Consider specifying explicit columns instead of SELECT * for better performance")
        
        return warnings
    
    def _generate_recommendations(self, config: Dict[str, Any]) -> List[str]:
        """Generate recommendations for configuration improvements"""
        recommendations = []
        
        config_type = self._detect_config_type(config)
        
        if config_type == 'indicator':
            recommendations.append("Consider adding data quality checks to prevent processing invalid data")
            recommendations.append("Add performance monitoring to track query execution times")
        
        elif config_type == 'workspace':
            recommendations.append("Configure automated backups for critical data")
            recommendations.append("Set up monitoring alerts for system health")
        
        return recommendations

# Usage example
if __name__ == "__main__":
    validator = BISConfigurationValidator()
    
    # Validate a configuration file
    result = validator.validate_config_file("workspace/acme_corp/indicators/customer_satisfaction.yml")
    
    print(f"Configuration Valid: {result['valid']}")
    print(f"Configuration Type: {result['config_type']}")
    
    if result['errors']:
        print("\nErrors:")
        for error in result['errors']:
            print(f"  - {error['type']}: {error['message']}")
    
    if result['warnings']:
        print("\nWarnings:")
        for warning in result['warnings']:
            print(f"  - {warning}")
    
    if result['recommendations']:
        print("\nRecommendations:")
        for rec in result['recommendations']:
            print(f"  - {rec}")
```

### Environment-Specific Configuration Templates

#### Production Environment Template

```yaml
# config/production.yml
# Production environment configuration

environment:
  name: "production"
  type: "production"
  region: "us-east-1"
  availability_zones: ["us-east-1a", "us-east-1b", "us-east-1c"]
  
# High availability and performance settings
processing:
  engine: "duckdb"
  memory_limit_gb: 128
  cpu_cores: 32
  temp_directory: "/mnt/processing_temp"
  
  optimization:
    enable_caching: true
    cache_ttl_minutes: 120
    enable_parallel_processing: true
    max_parallel_queries: 16
    query_timeout_seconds: 300
    
# Production database configuration
database:
  primary:
    type: "postgresql"
    host: "${DB_HOST}"
    port: 5432
    database: "${DB_NAME}"
    ssl_mode: "require"
    connection_pool:
      min_connections: 10
      max_connections: 50
      connection_timeout: 60
      
  read_replica:
    type: "postgresql"
    host: "${DB_REPLICA_HOST}"
    port: 5432
    database: "${DB_NAME}"
    ssl_mode: "require"
    
# Production data lake
data_lake:
  type: "s3"
  bucket: "${DATA_LAKE_BUCKET}"
  region: "us-east-1"
  prefix: "production/"
  compression: "snappy"
  encryption: "AES256"
  versioning: true
  
# Enhanced security for production
security:
  authentication:
    method: "oauth2"
    provider: "azure_ad"
    client_id: "${AZURE_CLIENT_ID}"
    tenant_id: "${AZURE_TENANT_ID}"
    multi_factor_required: true
    
  authorization:
    enable_rbac: true
    audit_logging: true
    session_timeout_minutes: 60
    
  encryption:
    data_at_rest: true
    data_in_transit: true
    key_rotation_days: 30
    kms_key_id: "${KMS_KEY_ID}"
    
# Production monitoring and alerting
monitoring:
  enable_detailed_metrics: true
  metrics_retention_days: 365
  
  alerts:
    - name: "high_cpu_usage"
      condition: "cpu_usage_percent > 80"
      duration_minutes: 5
      severity: "warning"
      channels: ["email", "slack", "pagerduty"]
      
    - name: "memory_pressure"
      condition: "memory_usage_percent > 85"
      duration_minutes: 3
      severity: "critical"
      channels: ["email", "slack", "pagerduty"]
      
    - name: "query_timeout"
      condition: "query_timeout_count > 5"
      duration_minutes: 10
      severity: "warning"
      channels: ["email", "slack"]
      
  dashboards:
    - name: "system_health"
      metrics: ["cpu_usage", "memory_usage", "disk_usage", "network_io"]
      refresh_interval_seconds: 60
      
    - name: "query_performance"
      metrics: ["avg_query_time", "query_count", "error_rate"]
      refresh_interval_seconds: 300
      
# Production backup strategy
backup:
  schedule: "daily"
  retention_days: 90
  encryption: true
  compression: true
  
  destinations:
    - type: "s3"
      bucket: "${BACKUP_BUCKET}"
      region: "us-east-1"
      storage_class: "STANDARD_IA"
      
    - type: "s3"
      bucket: "${BACKUP_BUCKET}"
      region: "us-west-2"
      storage_class: "GLACIER"
      
  verification:
    enable_integrity_checks: true
    enable_restore_testing: true
    test_frequency_days: 30
    
# Production logging
logging:
  level: "INFO"
  format: "json"
  
  destinations:
    - type: "cloudwatch"
      log_group: "/bis/production"
      retention_days: 365
      
    - type: "s3"
      bucket: "${LOG_BUCKET}"
      prefix: "production/"
      compression: "gzip"
      
  structured_fields:
    - "request_id"
    - "user_id"
    - "operation"
    - "duration_ms"
    - "error_code"
    
# Production deployment settings
deployment:
  strategy: "blue_green"
  health_check_endpoint: "/health"
  readiness_probe:
    path: "/ready"
    initial_delay_seconds: 30
    period_seconds: 10
    timeout_seconds: 5
    success_threshold: 1
    failure_threshold: 3
    
  rolling_update:
    max_unavailable_percentage: 25
    max_surge_percentage: 25
    timeout_seconds: 600
```

This comprehensive enhancement provides developers and administrators with practical configuration templates, validation frameworks, environment setup guides, and best practices that make BIS configuration management significantly more accessible and reliable.
