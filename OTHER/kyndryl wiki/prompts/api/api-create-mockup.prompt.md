---
mode: agent
model: Grok Code Fast 1 (Preview)
tools: ['codebase', 'search', 'editFiles', 'runCommands', 'runTasks']
description: 'Generate comprehensive mockup data from BIS API.yml schema, create referenced files, and load into DuckDB database'
---

# 🎭 BIS Mockup Data Generator

**Purpose:** Generate comprehensive mockup data from BIS API.yml schema for testing and validation
**Scope:** Create YAML examples, referenced CSV/SQL/Python files, and load data into DuckDB database
**Input:** BIS API.yml file path and repository structure
**Output:** Complete mockup dataset with database and coverage report

## Context & Environment
- **Repository:** BIS repository with canonical BIS API.yml in `wiki/`
- **Mockup Data:** YAML files in `engine/data/` named after API sections
- **CSV Files:** Stored in `engine/data/data/` with folder names as schema names, file names as table names
- **SQL Files:** Test files in `engine/data/sql/` with CREATE OR REPLACE TABLE statements
- **Python Files:** Test files in `engine/data/scripts/` with DataFrame-returning methods
- **Database:** DuckDB database at `engine/data/db/duckdb.db`
- **Documentation:** Update `engine/data/readme.md` with created file details

**Key Requirements:**
- No subfolders in `data/`, `sql/`, or `scripts/` directories
- CSV files must contain 10-30 rows with exact column specifications
- All data source references in YAML files must be validated and created

## Reasoning & Advanced Techniques
- **Required Reasoning Level:** Advanced
- **Thinking Process:** Analyze schema structure, validate coverage, ensure data consistency
- **Decision Making:** Compare existing files against schema, prioritize missing sections, validate data integrity

## Code Block Guidelines
- Include code blocks for YAML examples, Python methods, SQL queries
- Use proper language specification (```yaml, ```python, ```sql)
- Reuse schema examples when available
- Keep examples self-contained and minimal but comprehensive

## Step-by-Step Execution Process

### ✅ STEP 1: Analyze BIS API.yml Schema
**SCOPE:** Parse complete BIS API.yml to understand structure and requirements
- Read entire BIS API.yml file to identify all top-level sections
- Parse nested structures, data types, and required fields for each section
- Document anchors, references, and relationships between sections
- Count total keys per section for coverage tracking
- Identify any complex nested structures that need special handling

**CONTEXT:** Use `read_file` tool on `wiki/BIS API.yml`
**Commands:**
- `read_file(filePath="wiki/BIS API.yml", startLine=1, endLine=100)` - Read schema header
- `grep_search(query="^[a-zA-Z_]+:", includePattern="wiki/BIS API.yml")` - Find top-level sections

**Expected Schema Analysis:**
```yaml
schema_analysis:
  sections_found:
    - column_formatting: 45 keys
    - rules_class: 32 keys  
    - data_model: 28 keys
    - indicators: 67 keys
    - meta: 23 keys
  total_sections: 15
  complex_structures:
    - nested_rules_in_column_formatting
    - conditional_logic_in_indicators
    - cross_references_between_sections
```

### 🔄 STEP 2: Validate Existing Mockup Files
**SCOPE:** Check current YAML files against schema and identify gaps
- List all existing YAML files in `engine/data/` directory
- Compare each file's structure against BIS API.yml schema
- Flag files with missing keys, type mismatches, or outdated structures
- Generate list of sections needing creation or updates
- Preserve valid existing examples while updating incomplete ones

**CONTEXT:** Use `list_dir` and `read_file` tools on `engine/data/`
**Commands:**
- `list_dir(path="engine/data/")` - List existing YAML files
- `read_file(filePath="engine/data/column_formatting.yml", startLine=1, endLine=50)` - Check existing content

**Validation Results Template:**
```yaml
validation_results:
  column_formatting.yml: 
    status: partial
    missing_keys: [template, rules]
    valid_examples: 15
    needs_update: true
    
  rules_class.yml:
    status: valid
    coverage: 100%
    examples_count: 25
    
  new_section.yml:
    status: missing
    needs_creation: true
    required_keys: [name, type, active, conditions]
```
```yaml
# Example validation result
validation_results:
  column_formatting.yml: valid
  rules_class.yml: missing_keys [priority, multi_range]
  new_section.yml: needs_creation
```

### 🎯 STEP 3: Generate Comprehensive Mockup Data
**SCOPE:** Create YAML files with extensive examples covering all API scenarios
- Generate 20-50 examples per API section to ensure comprehensive coverage
- Include all keys from BIS API.yml schema with realistic variations
- Add human-like comments explaining each field and example context
- Create examples that represent different use cases and edge cases
- Ensure examples look organic and suitable for testing various scenarios

**CONTEXT:** Use `create_file` for new YAML files, `replace_string_in_file` for updates
**Commands:**
- `create_file(filePath="engine/data/column_formatting.yml", content=yaml_examples)` - Create section files
- `read_file(filePath="wiki/BIS API.yml", startLine=1, endLine=50)` - Reference schema structure

**YAML Example Structure:**
```yaml
# engine/data/column_formatting.yml
- name: basic_text_column
  # Standard text column formatting for incident descriptions
  label: "Description"
  template: "text_area"
  width: 300
  format: "text"
  rules: []
  
- name: numeric_priority_column
  # Numeric column with conditional formatting rules
  label: "Priority Score"
  template: "numeric_display"
  width: 100
  format: "number"
  rules:
    - condition: "value > 8"
      style: "high_priority"
    - condition: "value <= 3"  
      style: "low_priority"
      
- name: date_created_column
  # Date column with custom formatting
  label: "Created Date"
  template: "date_display"
  width: 120
  format: "date"
  rules: []
  
# ... continue with 20-50 examples covering all variations
```
```yaml
# Example mockup structure
- name: example_scenario_1
  # This example shows basic column formatting
  label: "Incident ID"
  template: "default_col"
  width: 24
  # ... all other keys
- name: example_scenario_2
  # Advanced formatting with rules
  # ... variation
```

### ⚙️ STEP 4: Handle Referenced Files and Tests
**SCOPE:** Analyze YAML content for file references and create all necessary supporting files
- Scan all generated YAML files for mentions of CSV, SQL, or Python files
- Create CSV files in `engine/data/data/<schema>/<table>.csv` format
- Create SQL files in `engine/data/sql/` with proper CREATE OR REPLACE TABLE statements
- Create Python files in `engine/data/scripts/` with DataFrame-returning methods
- Ensure CSV files contain 10-30 rows with exact column specifications
- Validate no subfolders exist in data/, sql/, or scripts/ directories
- Update `engine/data/readme.md` with documentation of all created files

**CONTEXT:** Use `grep_search` for finding references, `create_file` for new files
**Commands:**
- `grep_search(query="\.csv|\.sql|\.py", includePattern="engine/data/*.yml")` - Find file references
- `create_file(filePath="engine/data/scripts/example.py", content=python_template)` - Create Python files

**File Creation Examples:**

**Python File Template:**
```python
# engine/data/scripts/get_mock_data.py
import pandas as pd

def get_mock_data():
    """Returns pandas DataFrame with mock data for testing"""
    return pd.DataFrame({
        'incident_id': ['INC001', 'INC002', 'INC003'],
        'priority': ['High', 'Medium', 'Low'],
        'status': ['Open', 'Resolved', 'Closed'],
        'created_date': ['2025-01-01', '2025-01-02', '2025-01-03']
    })
```

**SQL File Template:**
```sql
-- engine/data/sql/create_incidents_table.sql
-- Creates or replaces incidents table with proper schema
CREATE OR REPLACE TABLE incidents.incidents (
    incident_id STRING,
    priority STRING,
    status STRING,
    created_date DATE
);
```

**CSV File Structure:**
```csv
-- engine/data/data/incidents/incidents.csv
incident_id,priority,status,created_date
INC001,High,Open,2025-01-01
INC002,Medium,Resolved,2025-01-02
INC003,Low,Closed,2025-01-03
INC004,Critical,Open,2025-01-04
INC005,High,In Progress,2025-01-05
-- ... continue to 10-30 rows
```
```python
# Example Python file in engine/data/scripts/
import pandas as pd

def get_mock_data():
    """Returns pandas DataFrame with mock data for testing"""
    return pd.DataFrame({
        'column1': ['value1', 'value2', 'value3'],
        'column2': [1, 2, 3],
        'column3': [True, False, True]
    })
```

```sql
-- Example SQL file in engine/data/sql/
-- Creates or replaces table with schema.table naming
CREATE OR REPLACE TABLE schema_name.table_name (
    column1 STRING,
    column2 INTEGER,
    column3 BOOLEAN
);
```

```csv
-- Example CSV file in engine/data/data/schema_name/table_name.csv
column1,column2,column3
value1,1,true
value2,2,false
value3,3,true
-- ... 10-30 rows total
```

### 📊 STEP 5: Final Validation and Coverage Report
**SCOPE:** Validate all created files and generate comprehensive coverage report
- Re-validate all mockup YAML files against BIS API.yml for 100% key coverage
- Verify all referenced CSV files exist in `engine/data/data/` with correct structure
- Confirm all SQL and Python files are properly created and functional
- Calculate coverage percentage per section and overall
- Generate markdown report documenting what was created and validation results

**CONTEXT:** Use `read_file` and `list_dir` tools for validation
**Commands:**
- `list_dir(engine/data/)` - Check all created files
- `read_file(engine/data/readme.md)` - Verify documentation updates

**Example Report:**
```markdown
# Mockup Data Generation Report
## Coverage Summary
- Total API sections: 20
- Fully covered: 18 (90%)
- Missing coverage: 2 (10%)

## Files Created
- YAML files: 15
- CSV files: 8 (in 3 schemas)
- SQL files: 5
- Python files: 3

## Database Status
- DuckDB database: Created
- Tables loaded: 8
- SQL scripts executed: 5
```

### 🗄️ STEP 6: Load Mock Data into DuckDB Database
**SCOPE:** Create DuckDB database and load all mock data with proper schema structure
- Create DuckDB database at `engine/data/db/duckdb.db`
- Scan `engine/data/data/` folder structure automatically
- Load CSV files using folder names as schema names, file names as table names
- Execute all SQL files from `engine/data/sql/` to create/modify tables
- Generate and run Python scripts using DuckDB API for data processing

**CONTEXT:** Use `run_in_terminal` for DuckDB commands, `create_file` for loading scripts
**Commands:**
- `run_in_terminal(command="python load_duckdb.py")` - Execute loading script
- `run_in_terminal(command="duckdb engine/data/db/duckdb.db -c 'SHOW TABLES;'")` - Verify tables

**Example Loading Script:**
```python
import duckdb
import os

def load_all_data():
    conn = duckdb.connect('engine/data/db/duckdb.db')
    
    # Load CSV files
    data_dir = 'engine/data/data/'
    for schema_name in os.listdir(data_dir):
        schema_path = os.path.join(data_dir, schema_name)
        if os.path.isdir(schema_path):
            for csv_file in os.listdir(schema_path):
                if csv_file.endswith('.csv'):
                    table_name = csv_file.replace('.csv', '')
                    csv_path = os.path.join(schema_path, csv_file)
                    conn.execute(f"""
                        CREATE OR REPLACE TABLE {schema_name}.{table_name} 
                        AS SELECT * FROM read_csv_auto('{csv_path}')
                    """)
    
    # Execute SQL files
    sql_dir = 'engine/data/sql/'
    for sql_file in os.listdir(sql_dir):
        if sql_file.endswith('.sql'):
            with open(os.path.join(sql_dir, sql_file), 'r') as f:
                sql_content = f.read()
                conn.execute(sql_content)
    
    conn.close()
    print("Database loading complete")
```

**Note:** Execute steps sequentially. If any step fails validation, stop and report the issue. Ask for human clarification only when encountering unexpected repository structures or unclear API specifications.

## Expected Inputs
- **Primary:** BIS API.yml file path (`wiki/BIS API.yml`)
- **Optional:** Specific API sections to focus on
- **Context:** Access to BIS repository structure and write permissions

## Success Metrics
- ✅ **100% API Coverage:** All BIS API.yml keys represented in mockup examples
- ✅ **File Integrity:** All referenced CSV, SQL, and Python files created with correct structure
- ✅ **Data Quality:** CSV files contain 10-30 rows with exact column specifications from YAML/SQL
- ✅ **Database Ready:** DuckDB database populated with all mock data and SQL scripts executed
- ✅ **Documentation:** `engine/data/readme.md` updated with complete file inventory
- ✅ **Validation Passed:** Coverage report shows >95% completion with no critical errors

## Integration & Communication
- **File Operations:** Use `read_file`, `create_file`, `list_dir` for file management
- **Command Execution:** Use `run_in_terminal` for DuckDB operations and script execution
- **Progress Updates:** Report completion status after each major step
- **Error Handling:** Stop and report issues if validation fails

## Limitations & Constraints
- **Repository Scope:** Operate only within BIS repository structure
- **File Permissions:** Require write access to `engine/data/`, `engine/data/db/` directories
- **Schema Compliance:** Must maintain exact key names and types from BIS API.yml
- **Data Volume:** CSV files limited to 10-30 rows for testing purposes
- **Dependencies:** Requires pandas, duckdb, and PyYAML libraries
- **Performance:** Large schemas may require multiple tool calls for complete processing

## Performance Guidelines
- **Token Management:** Keep prompt focused to avoid exceeding token limits
- **File Processing:** Read large files in chunks using startLine/endLine parameters
- **Batch Operations:** Process multiple similar files together when possible
- **Validation Efficiency:** Use grep_search for bulk file reference checking
- **Memory Usage:** Generate examples incrementally for large schemas

## Quality Gates
- [ ] **Schema Analysis Complete:** All BIS API.yml sections identified with key counts
- [ ] **Existing Files Validated:** All current YAML files checked against schema
- [ ] **Mockup Examples Generated:** 20-50 examples per section with 100% key coverage
- [ ] **Referenced Files Created:** All CSV, SQL, and Python files created with correct structure
- [ ] **Data Integrity Verified:** CSV files contain 10-30 rows with exact column specifications
- [ ] **Database Operations:** DuckDB database created and populated successfully
- [ ] **Documentation Updated:** `engine/data/readme.md` reflects all created files
- [ ] **Final Validation:** Coverage report generated with >95% completion metrics

## Validation Rules
- [ ] **STEP Execution:** Each step contains specific, measurable actions with clear commands
- [ ] **Schema Coverage:** All BIS API.yml keys covered in generated examples with variations
- [ ] **File References:** All YAML file references resolved to actual files with correct structure
- [ ] **Data Integrity:** CSV files validated for row count (10-30) and column specifications
- [ ] **SQL Validation:** Files contain proper CREATE OR REPLACE TABLE statements with schema.table names
- [ ] **Python Validation:** Files contain methods returning pandas DataFrames with correct signatures
- [ ] **Folder Structure:** No subfolders in data/, sql/, or scripts/ directories
- [ ] **DuckDB Operations:** Database creation, CSV loading, and SQL execution validated
- [ ] **Documentation:** `engine/data/readme.md` updated with complete file inventory and purposes
