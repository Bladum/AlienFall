# BIS Customer Onboarding Questionnaire (Expanded)

## Data Sources & Formats
### Must-Know Questions
1. **What are your primary data sources (e.g., databases, APIs, files, manual entry)?** - Critical for configuring data ingestion connectors in BIS engine
2. **For each data source, what specific systems or platforms are used?** - Essential for selecting appropriate BIS integration methods
3. **What types of data do you collect from each source (e.g., transactional, reference, event logs)?** - Determines DuckDB table structures and processing requirements
4. **What are the primary data formats for each source (CSV, JSON, XML, Parquet, database tables)?** - Essential for setting up data parsers and format converters
5. **Can you provide sample data files or schema definitions for each format?** - Critical for validating BIS schema compatibility and testing parsers
6. **What is the expected daily/weekly/monthly data volume for each source?** - Determines DuckDB partitioning and storage optimization strategies
7. **What is the frequency of data updates for each source (real-time, hourly, daily, weekly)?** - Essential for configuring processing schedules and incremental loading
8. **Are there any data size limits or batch sizes for data transfers?** - Affects BIS processing capacity planning in engine/src/

### Should-Know Questions
9. **What data quality issues exist in your current sources (missing values, duplicates, inconsistencies)?** - Important for configuring data cleansing and validation rules
10. **What data transformations are currently applied to source data?** - Helps map to BIS processing layers and ETL logic
11. **Do you have existing data dictionaries or schema documentation for each source?** - Essential for mapping to BIS YAML configurations in engine/cfg/
12. **What are the key business entities in your data model?** - Supports optimal table design and relationship mapping
13. **What are the relationships between your key business entities?** - Important for designing joins and referential integrity in BIS
14. **Are there any data lineage requirements or audit trails needed?** - Affects provenance tracking configuration
15. **What are your data retention policies for different data types?** - Helps optimize storage and archiving strategies

### Could-Know Questions
16. **Are there any legacy systems that need phased migration or parallel operation?** - Useful for planning integration timelines
17. **What APIs or web services provide your data, and what are their versions?** - For planning API integration and version compatibility
18. **Do you have any data streaming sources (Kafka, Event Hubs, etc.)?** - For real-time processing capabilities
19. **What are your data backup and recovery procedures?** - Helps understand data availability and restoration needs
20. **Are there any data residency or geographical restrictions?** - For compliance and data location planning

## Processing & Analytics Requirements
### Must-Know Questions
21. **What are your top 5 key business metrics or KPIs?** - Fundamental for configuring core analytics logic in BIS processing layers
22. **For each KPI, what is the exact calculation formula?** - Essential for implementing business logic in Python/SQL components
23. **What are the input data fields required for each KPI calculation?** - Critical for mapping data sources to processing requirements
24. **What is the required granularity for each KPI (daily, hourly, transaction-level)?** - Determines aggregation levels and table structures
25. **Do you need predictive analytics capabilities (forecasting, anomaly detection)?** - Determines if advanced DuckDB analytics features are required
26. **What trend analysis requirements do you have (moving averages, growth rates, seasonality)?** - Affects time-series processing configuration
27. **Do you need comparative analysis (period-over-period, year-over-year)?** - Guides historical data processing setup

### Should-Know Questions
28. **What are your current data processing workflows and their dependencies?** - Important for designing ETL pipelines and job scheduling in BIS
29. **Which data processing needs real-time vs batch processing?** - Affects architecture design and resource allocation
30. **What are your performance requirements (processing time, throughput, latency)?** - Guides optimization of DuckDB queries and Python processing
31. **Do you have any complex calculations requiring custom functions?** - Important for extending BIS processing capabilities
32. **What data aggregations are needed (sums, averages, counts, percentiles)?** - Affects query optimization and pre-computation strategies
33. **Are there any statistical calculations required (standard deviation, correlations)?** - Determines analytics library requirements
34. **What are your data quality thresholds and validation rules?** - Important for configuring data quality checks

### Could-Know Questions
35. **Do you need custom algorithms or machine learning models?** - For advanced analytics features and model integration
36. **What are your preferences for data visualization (charts, graphs, heatmaps)?** - Helps configure reporting outputs and GUI components
37. **Do you require geospatial analysis or mapping capabilities?** - For location-based analytics features
38. **What are your requirements for data export and interoperability?** - Affects output format configurations
39. **Do you need interactive data exploration or ad-hoc query capabilities?** - For self-service analytics features

## Reporting & SLA Requirements
### Must-Know Questions
40. **What specific reports do you need (list each report name and purpose)?** - Critical for configuring automated reporting workflows in BIS
41. **For each report, what is the required output format (Excel, PDF, HTML, dashboard)?** - Essential for selecting appropriate BIS rendering engines
42. **What are the required delivery frequencies for each report (daily, weekly, monthly, ad-hoc)?** - Essential for scheduling configuration in BIS engine
43. **What are the specific delivery times for each report?** - Critical for automated scheduling setup
44. **What are your SLA targets for report delivery timeliness?** - Fundamental for configuring monitoring and alert thresholds
45. **What are your SLA targets for data freshness in reports?** - Essential for data processing and caching strategies
46. **Who are the recipients for each report and their preferred delivery methods?** - Affects distribution configuration (email, portals, APIs)

### Should-Know Questions
47. **Do you have existing report specifications or mockups for each report?** - Important for mapping to BIS YAML configurations and templates
48. **What are the specific data fields and calculations needed in each report?** - Essential for report generation logic
49. **Are there any specific formatting requirements (colors, fonts, logos)?** - Guides Qt/PySide GUI and Excel formatting setup
50. **What are the distribution requirements (email groups, file shares, APIs)?** - Affects delivery mechanism configuration
51. **Do reports need to be archived or have version control?** - Important for retention and audit requirements
52. **Are there any conditional formatting or highlighting rules needed?** - Affects styling and conditional logic configuration

### Could-Know Questions
53. **Do you need interactive dashboards with drill-down capabilities?** - For advanced GUI features and user interaction
54. **What are your requirements for historical report archiving and access?** - For long-term data retention and retrieval
55. **Do you need report scheduling flexibility (custom dates, conditional triggers)?** - For advanced scheduling features
56. **What are your requirements for report security and access controls?** - For user authentication and authorization
57. **Do you need report comparison or variance analysis features?** - For advanced reporting capabilities

## SLA & Monitoring Setup
### Must-Know Questions
58. **What are your specific SLA targets for each service or process?** - Critical for configuring SLA monitoring thresholds in BIS
59. **How are SLA targets currently measured and tracked?** - Essential for understanding measurement methodologies
60. **What systems provide availability and performance monitoring data?** - Essential for integrating monitoring sources and APIs
61. **What specific metrics are used to calculate availability (uptime, response time)?** - Critical for configuring monitoring calculations
62. **Do you require automated alerts for SLA breaches?** - Determines action delivery and notification configuration
63. **What are the escalation procedures for different SLA breach severities?** - Essential for automated action workflows

### Should-Know Questions
64. **What is the contract language regarding SLA measurement and penalties?** - Important for compliance and penalty calculation configuration
65. **How are availability metrics currently calculated (manual, automated, sampling)?** - Affects data processing and calculation logic
66. **What is the reporting frequency for SLA metrics?** - Important for monitoring dashboard configuration
67. **Are there different SLA targets for different time periods or customer segments?** - Affects conditional logic and segmentation
68. **What historical SLA performance data is available?** - Important for baseline analysis and trend identification
69. **Do you need SLA forecasting or predictive breach detection?** - For advanced monitoring capabilities

### Could-Know Questions
70. **Do you need predictive SLA monitoring with early warning systems?** - For advanced analytics and proactive monitoring
71. **What are your requirements for SLA reporting and visualization?** - For dashboard and reporting configuration
72. **Do you need SLA integration with other business systems?** - For enterprise-wide monitoring
73. **What are your requirements for SLA audit trails and compliance reporting?** - For regulatory and audit requirements

## Technical Integration & Access
### Must-Know Questions
74. **What specific systems require technical integration (list each system and purpose)?** - Critical for configuring data sources and connection methods in BIS
75. **For each system, what type of access is needed (read-only, read-write, API, database)?** - Essential for determining integration approach and permissions
76. **Can you provide technical access credentials or connection details for each system?** - Essential for setting up secure connections and testing
77. **What authentication methods are used for each system (username/password, API keys, certificates)?** - Fundamental for secure configuration and credential management
78. **Are there any network security requirements (VPN, IP whitelisting, encryption)?** - Critical for connectivity and security setup

### Should-Know Questions
79. **Are there firewall or network restrictions affecting data access?** - Important for connectivity troubleshooting and proxy configuration
80. **What API rate limits or usage quotas apply to each system?** - Affects data collection scheduling and throttling
81. **Do you use ServiceNow (SNOW) and what specific modules/tables are needed?** - Specific to common BIS integrations and field mapping
82. **What are the data transfer protocols supported (REST, SOAP, ODBC, JDBC)?** - Important for selecting appropriate BIS connectors
83. **Are there any data encryption requirements for transmission or storage?** - Affects security configuration and compliance
84. **What are the system uptime and maintenance windows for each integration?** - Important for scheduling and error handling

### Could-Know Questions
85. **What backup and disaster recovery requirements exist for integrated systems?** - For high-availability and failover configuration
86. **Are there compliance requirements (GDPR, SOX, HIPAA) affecting data handling?** - For security and audit configurations
87. **Do you need integration with identity providers or single sign-on systems?** - For enterprise authentication integration
88. **What monitoring and logging requirements exist for integrations?** - For operational visibility and troubleshooting
89. **Are there any third-party tools or middleware that facilitate integrations?** - For understanding the integration ecosystem

## Business Configuration & Workspace Setup
### Must-Know Questions
90. **What is your organizational structure (departments, divisions, hierarchy levels)?** - Critical for tenant workspace configuration and access controls
91. **Who are the key stakeholders and what are their specific roles?** - Essential for user role setup and permissions
92. **What access levels are needed for different user types (view, edit, admin)?** - Fundamental for security and authorization configuration
93. **What are your business hours and primary timezone?** - Affects scheduling, reporting, and user interface localization
94. **Are there multiple business units requiring separate configurations?** - Critical for multi-tenant setup and workspace isolation

### Should-Know Questions
95. **Do you have existing data governance policies or data stewardship roles?** - Important for data quality and ownership configuration
96. **What are your change management and approval processes for configurations?** - Affects deployment workflows and version control
97. **Do you need department-specific or role-based data access controls?** - Guides workspace isolation and security policies
98. **What are your requirements for audit logging and compliance tracking?** - Important for security and regulatory requirements
99. **Do you have existing user management systems or directories?** - Affects authentication integration and user provisioning

### Could-Know Questions
100. **What training or documentation needs exist for different user roles?** - For user adoption planning and knowledge management
101. **Are there specific branding or customization requirements for the interface?** - For GUI personalization and user experience
102. **Do you need integration with existing user portals or intranets?** - For seamless user experience and single sign-on
103. **What are your requirements for user onboarding and offboarding processes?** - For automated user lifecycle management
104. **Do you need multi-language support or localization?** - For international user requirements

## AI & Automation Requirements
### Should-Know Questions
105. **Do you want AI-assisted report generation or content summarization?** - Important for configuring AI integration in BIS
106. **What level of automation do you require for routine data processing tasks?** - Affects workflow automation and scheduling
107. **Are there specific AI model preferences or restrictions in your organization?** - Guides AI integration and compliance considerations

### Could-Know Questions
108. **Do you need AI-powered anomaly detection for KPIs or data quality?** - For advanced monitoring capabilities
109. **What are your requirements for automated insights or recommendations?** - For AI-driven business intelligence features
110. **Do you have existing AI or machine learning models that need integration?** - For model deployment and orchestration

## Performance & Scalability
### Should-Know Questions
111. **What are your peak usage periods and expected user concurrency?** - Important for capacity planning and resource allocation
112. **What is your projected data growth over the next 1-3 years?** - Affects scalability planning and architecture decisions
113. **What are your backup and recovery time objectives (RTO/RPO)?** - Critical for disaster recovery configuration

### Could-Know Questions
114. **Do you have seasonal or cyclical usage patterns?** - For optimizing resource allocation and scaling
115. **What are your requirements for high availability and failover?** - For enterprise-grade reliability
116. **Do you need geographic distribution or edge processing capabilities?** - For global operations and performance optimization

## Integration & Ecosystem
### Should-Know Questions
117. **What existing BI or analytics tools do you currently use?** - Important for integration planning and data consistency
118. **Do you need integration with ERP, CRM, or other business systems?** - Affects enterprise integration scope
119. **What notification or communication channels are preferred (email, Slack, Teams)?** - Guides alert and notification configuration

### Could-Know Questions
120. **Do you use any data catalog or metadata management tools?** - For enhanced data governance and discovery
121. **What are your requirements for data sharing with external partners?** - For secure data exchange capabilities
122. **Do you need integration with IoT or sensor data sources?** - For industrial or operational data integration

## Suggested Improvements to Question List

### Enhanced Question Types
1. **Quantitative Questions**
   - "What percentage of your reports require real-time data?"
   - "How many users will need concurrent access to dashboards?"

2. **Scenario-Based Questions**
   - "Describe your process for handling a critical SLA breach"
   - "Walk through a typical report generation and distribution workflow"
   - "Explain how you currently handle data quality issues"

3. **Priority Ranking Questions**
   - "Rank these integration priorities: ServiceNow, ERP, CRM, Custom APIs"
   - "Which SLA metrics have the highest business impact?"

4. **Conditional Follow-Up Questions**
   - If they mention predictive analytics: "What historical timeframe is available for model training?"
   - If they need real-time processing: "What is your acceptable latency for real-time updates?"
   - If they use ServiceNow: "What specific tables, fields, and relationships do you need?"

### BIS-Specific Technical Deep Dives
1. **YAML Configuration Mapping**
   - Questions that directly map to specific BIS YAML structures in engine/cfg/
   - Validation questions against BIS API schema requirements

2. **DuckDB Optimization Questions**
   - "Do you need columnar storage optimizations for specific query patterns?"
   - "What are your requirements for in-memory vs persistent processing?"
   - "Do you need custom DuckDB extensions or functions?"

3. **Python Processing Questions**
   - "What Python libraries or frameworks do you require?"
   - "Do you have existing Python scripts that need migration?"
   - "What are your requirements for custom Python processing logic?"

4. **Qt/PySide GUI Questions**
   - "What specific UI components do you need (charts, tables, forms)?"
   - "Do you require custom widgets or interactive elements?"
   - "What are your accessibility and usability requirements?"

### Advanced Analytics Questions
1. **Time-Series Analysis**
   - "What temporal aggregations do you need (hourly, daily, weekly, monthly)?"
   - "Do you require time-series forecasting or seasonality analysis?"

2. **Statistical Analysis**
   - "What statistical methods do you need (regression, correlation, hypothesis testing)?"
   - "Do you require confidence intervals or statistical significance testing?"

3. **Machine Learning Integration**
   - "What types of ML models do you need (classification, regression, clustering)?"
   - "Do you have existing ML models that need operationalization?"

### Security & Compliance Deep Dive
1. **Data Protection Questions**
   - "What data classification levels do you have (public, internal, confidential, restricted)?"
   - "Do you need row-level security or data masking capabilities?"

2. **Audit & Compliance Questions**
   - "What regulatory requirements apply to your data (GDPR, SOX, HIPAA)?"
   - "Do you need detailed audit trails for data access and modifications?"

3. **Access Control Questions**
   - "What authentication methods do you support (SAML, OAuth, LDAP)?"
   - "Do you need role-based access control or attribute-based access control?"

### Implementation & Deployment Questions
1. **Environment Questions**
   - "Do you need development, staging, and production environments?"
   - "What are your requirements for environment isolation and data synchronization?"

2. **Deployment Questions**
   - "What is your preferred deployment method (containerized, VM, cloud)?"
   - "Do you have existing CI/CD pipelines that need integration?"

3. **Monitoring & Observability Questions**
   - "What application monitoring tools do you use?"
   - "Do you need integration with existing logging and monitoring platforms?"

### User Experience & Adoption Questions
1. **Training Questions**
   - "What is the technical skill level of your user base?"
   - "Do you need role-specific training programs?"

2. **Change Management Questions**
   - "How do you typically handle technology adoption and change management?"
   - "What are your success metrics for user adoption?"

3. **Support Questions**
   - "What level of ongoing support do you require?"
   - "Do you have existing help desk or support processes?"

### Cost & ROI Questions
1. **Business Value Questions**
   - "What are your expected outcomes from BIS implementation?"
   - "How will you measure the ROI of the BIS solution?"

2. **Cost Optimization Questions**
   - "What are your budget constraints for the implementation?"
   - "Do you have preferences for cloud vs on-premises deployment?"

### Future-Proofing Questions
1. **Scalability Questions**
   - "What is your 3-5 year vision for data and analytics capabilities?"
   - "Do you anticipate significant changes in data sources or volumes?"

2. **Technology Evolution Questions**
   - "How do you approach technology evaluation and adoption?"
   - "Do you have a roadmap for analytics and BI capabilities?"

### Questionnaire Enhancement Recommendations
1. **Digital Implementation**
   - Create an interactive web-based questionnaire using BIS GUI components
   - Implement conditional logic to show/hide questions based on previous answers
   - Add validation rules to ensure data quality and completeness

2. **Integration with BIS Configuration**
   - Map questionnaire responses directly to BIS YAML configuration templates
   - Generate initial configuration files based on questionnaire answers
   - Validate responses against BIS schema requirements

3. **Progressive Disclosure**
   - Start with high-level strategic questions
   - Drill down into technical details based on initial responses
   - Use answer clustering to identify similar customer profiles

4. **Analytics-Driven Improvements**
   - Track which questions have the highest impact on configuration quality
   - Use response analytics to identify patterns and optimize question flow
   - Implement A/B testing for different question formulations

5. **Documentation Integration**
   - Link questions to relevant BIS handbook sections
   - Provide contextual help and examples for complex questions
   - Include references to wiki/ documentation and best practices

6. **Feedback Loop Implementation**
   - Include mechanisms for customers to provide feedback on questionnaire clarity
   - Track onboarding success metrics correlated with questionnaire responses
   - Regularly update questions based on lessons learned from implementations
