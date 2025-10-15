# Steps 

1) load data
- read BIS API.yml and think / reason about content 
- read *.yml 
- read *.sql 
- read *_format*.yml 


2) Perform analysis of all content and try to summrize and create specification in markdown format. This deep and reason a lot, we need verbose answer. 

Perform deep analyzis of SQL code and fetch:
- list of tables with schema_name.table_name
- schema table of each table in format COLUMN_NAME | FORMAT 
- reltion between one table and the other table (anything like JOIN, FROM etc) 
- each table must have clear parents tables calculated and child table calculated depends on their relations
- columns which are used in more then one table 
- columns which are used to JOIN tables ( COLUMN_NAME | TABLE_A | TABLE_B )

3) Based on above data now calculate:
- rank of each table, which means number of other tables that must be first calculated to calculate this one. So if tables are A -> B -> C then A = 1, B = 2 and C = 3 in terms of ranks. Ensure that if more then one table is needed as input, then you will get MAX rank of all inputs + 1 to get current table. Output would be TABLE_NAME | RANK. This will be used to calculate dependency graph. 

4) create readme.md in the same folder as *.yml file

Section of the readme.md 

## Table of Contents
- [Table List](#table-list)
- [Dependency Tree](#dependency-tree)
- [Dependency Tree Reversed](#dependency-tree-reversed)
- [Data Schema](#data-schema)
- [Columns Used Many Times](#columns-used-many-times)
- [Errors](#errors)

- Table list in form of a table 
    - anything that is created on data base with SCHEMA_NAME.TABLE NAME
    - type of component (sympton, snapshot, action, trend) 
    - rank (order of calculations) 
    - dependencies on other tables (use schema_name.table_name format 

## Table names 

| Table Name                                     | Type    |   Rank | Dependencies              |
|------------------------------------------------|---------|--------|---------------------------|
| SECURITY.INCIDENT_DETAILS                      | SYMPTOM |      1 | SNOW.INCSYS, SNOW.TASKSLA |

- dependency tree graph in this format 

##  DEPENDENCY TREE

```text
CFG.MONTHS
└─> OPS63.TREND_HISTORY_PIVOT
CUSTOM.INFRASTRUCTURE
└─> OPS63.INFRA
CUSTOM.SERVICES
└─> OPS63.DETAILS
OPS63.TREND
└─> OPS63.TREND_HISTORY
    └─> OPS63.TREND_HISTORY_PIVOT
```

- reverse dependency graph in this format 

##  DEPENDENCY TREE REVERSED

```text
OPS63.DETAILS
└─> CUSTOM.SERVICES
OPS63.INFRA
└─> CUSTOM.INFRASTRUCTURE
OPS63.TREND_HISTORY_PIVOT
├─> CFG.MONTHS
└─> OPS63.TREND_HISTORY
    └─> OPS63.TREND
```

- schema of all tables in this format 

## SCHEAMS 

```text
## SCHEMA_NAME.TABLE_NAME
|    | column_name   | column_type   |
|----|---------------|---------------|
|  0 | PERIOD        | VARCHAR       |
|  1 | KOMPONENTEN   | VARCHAR       |
|  2 | UBERWACHTE    | INTEGER       |
|  3 | ANZAHL_ALLE   | INTEGER       |
|  4 | TOTAL         | INTEGER       |
```


# BALLUFF Patching Report System

## Overview
The Patching Report System is designed to track and report on the patching status of various servers in the BALLUFF environment. This monthly report provides visibility into the patching compliance status across different server types (Windows, Linux, VMware) and identifies servers that are patched, not patched, or excluded from patching requirements.

## Business Purpose
The primary purpose of this report is to:
1. Track patching compliance across the server infrastructure
2. Identify servers that have not been patched according to schedule
3. Monitor patching exceptions and exclusions
4. Ensure compliance with SLA requirements related to system patching

## System Components

### Data Sources
- **ScienceLogic Device Data** - Information about servers and their configurations
- **Patch Status Data** - Records of patching activities for Windows and Linux systems
- **VMware Patching Data** - Records for VMware system patching
- **Exclusion Lists** - Servers excluded from standard patching requirements
- **Restricted Reboot Data** - Servers with special reboot/patching considerations

### Processing Pipeline

#### Data Transformation
The system processes data through several SQL views:
- **PATCH.BASELINE** - Consolidates device information with patching status
- **PATCH.SLA** - Calculates SLA compliance metrics for patching
- **PATCH.WINDOWS_PATCHING** - Windows-specific patching details
- **PATCH.LINUX_PATCHING** - Linux-specific patching details

### Report Output
The transformed data is formatted into a standardized Excel report:
- **File Name**: MD_BLF_PATCHING.xlsx
- **Title**: BAL Monthly Patching Report
- **Frequency**: Monthly

### Key Metrics & SLAs Tracked
- Percentage of servers patched within required timeframes
- Exception tracking and justifications
- SLA compliance for BAL_SLA_02_08_01, BAL_SLA_02_06_01, and BAL_SLA_02_07_01



