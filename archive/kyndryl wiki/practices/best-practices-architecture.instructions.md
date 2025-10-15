# Architecture Documentation Best Practices & Guidelines for AI Agents - BIS Repository

<a id="top"></a>

**Target Audience:** Enterprise/Solution/Data Architects, Tech Leads, AI documentation agents
**Scope:** Comprehensive Architecture Documentation development and maintenance standards
**Apply to:** All arch_*.md files and related documentation in BIS repository (`**/arch_*.md`)

---

## 📋 Comprehensive Table of Contents
<div align="right"><a href="#top">↑ Back to top</a></div>

- [🎯 Core Principles](#core-principles)
- [🏗️ Design Patterns](#design-patterns)
- [📚 Key Terms](#key-terms)
- [🔗 Industry References](#industry-references)
- [📂 Practice Categories](#practice-categories)
  - [Business & Service Architecture](#business--service-architecture)
    - [✅ Maintain Business-Focused Value Streams](#maintain-business-focused-value-streams)
    - [✅ Include Quantitative Flow Metrics](#include-quantitative-flow-metrics)
    - [✅ Document Manual Approvals and Exceptions](#document-manual-approvals-and-exceptions)
    - [✅ Use Objective Decision Criteria](#use-objective-decision-criteria)
    - [✅ Capture Escalation Paths](#capture-escalation-paths)
    - [✅ Use Verb-Noun Format for Process Steps](#use-verb-noun-format-for-process-steps)
    - [❌ Include Technical Implementation Details in Business Views](#include-technical-implementation-details-in-business-views)
    - [❌ Use Unclear or Ambiguous Process Labels](#use-unclear-or-ambiguous-process-labels)
    - [❌ Include Technical Implementation Details in Business Views](#include-technical-implementation-details-in-business-views)
  - [Solution Architecture](#solution-architecture)
    - [✅ Implement Hierarchical Architecture Views](#implement-hierarchical-architecture-views)
    - [✅ Label Interfaces with Protocols](#label-interfaces-with-protocols)
    - [✅ Identify Trust Boundaries](#identify-trust-boundaries)
    - [✅ Document SLAs for External Systems](#document-slas-for-external-systems)
    - [✅ Maintain Public API Focus](#maintain-public-api-focus)
    - [✅ Include Error Handling Patterns](#include-error-handling-patterns)
    - [✅ Use Consistent Naming Conventions](#use-consistent-naming-conventions)
    - [✅ Define Data Contracts](#define-data-contracts)
    - [✅ Document Observability Integration](#document-observability-integration)
    - [✅ Align UI Flows with User Journeys](#align-ui-flows-with-user-journeys)
    - [✅ Use Appropriate Diagram Types for Technical Views](#use-appropriate-diagram-types-for-technical-views)
    - [❌ Exceed Node Limits in Diagrams](#exceed-node-limits-in-diagrams)
    - [❌ Use Colors or Custom Styling in Diagrams](#use-colors-or-custom-styling-in-diagrams)
    - [❌ Mix Business and Technical Concepts in Single Diagrams](#mix-business-and-technical-concepts-in-single-diagrams)
    - [❌ Exceed Node Limits in Diagrams](#exceed-node-limits-in-diagrams)
  - [Diagram Creation and Quality](#diagram-creation-and-quality)
    - [✅ Use Appropriate Diagram Types for Context](#use-appropriate-diagram-types-for-context)
    - [✅ Maintain Consistent Layout Direction](#maintain-consistent-layout-direction)
    - [✅ Sanitize Labels for Readability](#sanitize-labels-for-readability)
    - [✅ Include Clear Legends and Keys](#include-clear-legends-and-keys)
    - [✅ Validate Diagram Rendering](#validate-diagram-rendering)
    - [❌ Mix Business and Technical Concepts in Single Diagrams](#mix-business-and-technical-concepts-in-single-diagrams)
    - [❌ Use Unclear or Generic Node Names](#use-unclear-or-generic-node-names)
    - [❌ Create Diagrams Without Source References](#create-diagrams-without-source-references)
  - [Business-Technology Alignment](#business-technology-alignment)
    - [✅ Connect Business Objectives to Technical Capabilities](#connect-business-objectives-to-technical-capabilities)
    - [✅ Document Technology Constraints Impacting Business](#document-technology-constraints-impacting-business)
    - [✅ Include Business Context in Technical Decisions](#include-business-context-in-technical-decisions)
    - [✅ Map Business Processes to System Components](#map-business-processes-to-system-components)
    - [❌ Design Technology Without Business Requirements](#design-technology-without-business-requirements)
  - [Service Integration](#service-integration)
    - [✅ Document Service Dependencies and Interactions](#document-service-dependencies-and-interactions)
    - [✅ Include Service Level Agreements in Architecture](#include-service-level-agreements-in-architecture)
    - [✅ Define Service Boundaries and Responsibilities](#define-service-boundaries-and-responsibilities)
    - [✅ Document Service Failure Modes and Recovery](#document-service-failure-modes-and-recovery)
    - [❌ Create Services Without Defined Interfaces](#create-services-without-defined-interfaces)
  - [Product Development](#product-development)
    - [✅ Align Architecture with Product Roadmap](#align-architecture-with-product-roadmap)
    - [✅ Document Product Requirements Traceability](#document-product-requirements-traceability)
    - [✅ Include Product Quality Attributes in Architecture](#include-product-quality-attributes-in-architecture)
    - [✅ Plan for Product Evolution in Architecture](#plan-for-product-evolution-in-architecture)
    - [❌ Ignore Product Backlog in Architecture Planning](#ignore-product-backlog-in-architecture-planning)
  - [Support and Operations](#support-and-operations)
    - [✅ Include Operational Requirements in Architecture](#include-operational-requirements-in-architecture)
    - [✅ Document Support Processes and Procedures](#document-support-processes-and-procedures)
    - [✅ Plan for Operational Monitoring and Alerting](#plan-for-operational-monitoring-and-alerting)
    - [✅ Include Disaster Recovery in Architecture](#include-disaster-recovery-in-architecture)
    - [❌ Design Without Operational Considerations](#design-without-operational-considerations)
  - [Implementation Practices](#implementation-practices)
    - [✅ Document Implementation Constraints](#document-implementation-constraints)
    - [✅ Include Development Guidelines in Architecture](#include-development-guidelines-in-architecture)
    - [✅ Plan for Testing in Architecture Design](#plan-for-testing-in-architecture-design)
    - [✅ Document Deployment and Release Processes](#document-deployment-and-release-processes)
    - [❌ Implement Without Architecture Guidance](#implement-without-architecture-guidance)
  - [People & Operations](#people--operations)
    - [✅ Maintain Consistent Layout Direction](#maintain-consistent-layout-direction)
    - [✅ Sanitize Labels for Readability](#sanitize-labels-for-readability)
    - [✅ Include Clear Legends and Keys](#include-clear-legends-and-keys)
    - [✅ Validate Diagram Rendering](#validate-diagram-rendering)
    - [✅ Use Decision Diamonds for Process Branching](#use-decision-diamonds-for-process-branching)
    - [✅ Represent Queues and Waits as Distinct Nodes](#represent-queues-and-waits-as-distinct-nodes)
    - [✅ Keep Labels Concise and Readable](#keep-labels-concise-and-readable)
  - [Advanced Architectural Views](#advanced-architectural-views)
    - [✅ Implement Configuration Hierarchy](#implement-configuration-hierarchy)
    - [✅ Document Sensitive Data Handling](#document-sensitive-data-handling)
    - [✅ Include Correlation Mechanisms](#include-correlation-mechanisms)
  - [Cross-cutting Standards](#cross-cutting-standards)
    - [✅ Maintain Consistent Diagram Formatting](#maintain-consistent-diagram-formatting)
    - [✅ Validate Link Accuracy](#validate-link-accuracy)
    - [✅ Apply Speculative Labeling](#apply-speculative-labeling)
    - [✅ Include Timestamps for Currency](#include-timestamps-for-currency)
    - [✅ Sanitize Mermaid Labels](#sanitize-mermaid-labels)

---

## 🎯 Core Principles

- **Consistency**: Maintain stable headings and labels to ensure documentation remains predictable and easy to navigate across updates, which is crucial for large-scale architecture documentation where multiple contributors need to find information quickly without confusion from changing structures.
- **Idempotence**: Overwrite only inside designated blocks to preserve the integrity of the document structure and prevent unintended changes to surrounding content, ensuring that automated updates can be applied repeatedly without accumulating errors or duplications.
- **Redaction**: Replace any token, secret, or PII with [REDACTED] to protect sensitive information and comply with security standards, preventing accidental exposure of confidential data in shared documentation repositories.
- **Link Policy**: Use repo-root relative links starting with ./ to create portable references that work across different environments and prevent broken links when documentation is moved or accessed from various locations.
- **Traceability**: Reference the source of truth for all key statements to enable auditability and verification, allowing stakeholders to trace architectural decisions back to their original requirements and implementation details.
- **Currency**: Refresh documentation when module READMEs, configs, or public APIs change to maintain accurate representations of the system, ensuring that architecture views remain relevant as the codebase evolves.
- **AI-Specific Handling**: When inputs are incomplete, mark content as (speculative) and list gaps to transparently communicate uncertainty and guide future improvements, enabling better decision-making based on available information.

---

## 🏗️ Design Patterns

- **Flowchart Pattern**: Use flowchart LR or TD for value streams and processes to visualize sequential steps and decision points, providing clear navigation paths that help stakeholders understand workflow dependencies and identify optimization opportunities.
- **Sequence Diagram Pattern**: Apply sequenceDiagram for end-to-end processing and interactions to show temporal relationships between components, enabling better understanding of system timing, synchronization requirements, and potential bottlenecks in data flows.
- **Class Diagram Pattern**: Utilize classDiagram for module relationships to illustrate inheritance, composition, and collaboration patterns, helping developers understand code organization and identify opportunities for refactoring or consolidation.
- **ER Diagram Pattern**: Implement erDiagram for data models to represent entity relationships and cardinalities, supporting database design decisions and ensuring data integrity across the system architecture.
- **Gantt Chart Pattern**: Employ gantt charts for roadmap visualization to align issues and priorities with user journeys, providing stakeholders with clear timelines and dependencies for project planning and resource allocation.

---

## 📚 Key Terms

- **TOGAF**: An enterprise architecture framework that provides a comprehensive approach to designing, planning, implementing, and governing enterprise information architecture, widely used for ensuring architectural consistency and alignment with business goals.
- **ITIL**: A set of practices for IT service management that focuses on aligning IT services with business needs, providing structured processes for service design, transition, operation, and continual improvement.
- **C4 Model**: A hierarchical approach to software architecture documentation that uses four levels (Context, Containers, Components, Code) to provide different levels of detail for different audiences, improving communication and understanding across technical and non-technical stakeholders.
- **Value Stream**: A sequence of activities required to deliver a product or service to a customer, including all the steps, handoffs, and waiting times, used to identify inefficiencies and improvement opportunities in business processes.
- **Service Model**: A high-level view of how a service delivers value to customers, including the key processes, roles, and interactions that support the service delivery lifecycle.
- **System Context**: A diagram showing the system as a central element surrounded by its users, external systems, and interfaces, providing a high-level understanding of the system's boundaries and relationships.
- **Data Lake**: A storage architecture that holds vast amounts of raw data in its native format until needed, supporting various analytics and processing requirements while maintaining data lineage and quality.
- **Observability Map**: A comprehensive view of how logs, metrics, and traces are generated and correlated across system components, enabling effective monitoring, troubleshooting, and performance optimization.

---

## 🔗 Industry References

- **TOGAF Standard**: Provides a comprehensive framework for enterprise architecture that includes detailed guidance on architecture development, governance, and implementation, serving as the foundation for many organizational architecture practices.
- **ITIL Framework**: Offers best practices for IT service management with specific processes for event management, service design, and continual improvement, widely adopted for operational excellence in technology organizations.
- **C4 Model Documentation**: Presents a practical approach to software architecture diagrams that scales from high-level context to detailed code views, helping teams communicate architecture effectively across different stakeholder groups.
- **Data Lake Architecture Patterns**: Describes proven approaches for building scalable data storage and processing systems, including data ingestion, quality management, and analytics capabilities.
- **Observability Best Practices**: Outlines comprehensive strategies for implementing logging, monitoring, and tracing in distributed systems, enabling proactive issue detection and resolution.

---

## 📂 Practice Categories

### Business & Service Architecture

#### ✅ Maintain Business-Focused Value Streams
- **Reason:** Ensures architecture documentation reflects actual business value delivery rather than technical implementation details
- **Priority:** 🔴 Must
- **Description:** Always structure service models around business outcomes and customer value rather than technical processes, using clear business language that stakeholders can understand without technical expertise. This approach ensures that architecture documentation serves as a bridge between business strategy and technical implementation, enabling better alignment and decision-making. By focusing on business value streams, architects can identify true bottlenecks and improvement opportunities that directly impact customer satisfaction and business results, rather than getting lost in technical details that may not affect the bottom line.

#### ✅ Include Quantitative Flow Metrics
- **Reason:** Provides measurable indicators of process performance and improvement opportunities
- **Priority:** 🟡 Should
- **Description:** Attach 2-3 flow-level KPIs such as lead time, failure rate, and rework percentage to each value stream to enable data-driven improvement decisions. These metrics provide concrete evidence of process efficiency and help prioritize optimization efforts based on actual impact. By quantifying performance, architects can demonstrate the business value of architectural improvements and track progress over time, ensuring that documentation supports continuous improvement initiatives.

#### ✅ Document Manual Approvals and Exceptions
- **Reason:** Ensures transparency of regulatory and compliance requirements in business processes
- **Priority:** 🟡 Should
- **Description:** Explicitly note all manual approval gates, regulatory requirements, and exception handling processes in value streams to ensure compliance and risk management. This documentation helps identify potential bottlenecks and automation opportunities while ensuring that all legal and regulatory requirements are properly addressed. By documenting exceptions upfront, architects can design more resilient processes that handle edge cases appropriately and maintain compliance throughout the service lifecycle.

#### ✅ Use Objective Decision Criteria
- **Reason:** Ensures consistent and auditable decision-making in business processes
- **Priority:** 🟡 Should
- **Description:** Define clear, measurable criteria for all decision points in business models to enable consistent evaluation and reduce subjective judgment. These criteria should be testable and tied to specific business outcomes, ensuring that decisions are made based on data rather than opinion. By establishing objective criteria, architects create more predictable processes and enable better governance and compliance monitoring.

#### ✅ Capture Escalation Paths
- **Reason:** Ensures business continuity when standard processes fail
- **Priority:** 🟢 Could
- **Description:** Document escalation paths for rejected decisions and failed processes to maintain service continuity and customer satisfaction. These paths should include clear triggers, responsible parties, and expected resolution times to ensure timely intervention when issues arise. By planning for escalations, architects can design more resilient business processes that maintain service levels even under adverse conditions.

#### ✅ Use Verb-Noun Format for Process Steps
- **Reason:** Creates clear, actionable process descriptions that stakeholders can easily understand
- **Priority:** 🟡 Should
- **Description:** Format all process steps using verb-noun combinations (e.g., "Ingest Data", "Validate Quality", "Generate Report") to create clear, actionable descriptions. This format makes processes more readable and helps stakeholders understand what actions are being performed at each step. By using consistent verb-noun formatting, architects can create documentation that is both professional and easily comprehensible to all audiences.

#### ❌ Include Technical Implementation Details in Business Views
- **Reason:** Prevents confusion and maintains focus on business value
- **Priority:** ❌ Won't
- **Description:** Avoid mixing technical implementation details with business process documentation as this creates confusion for non-technical stakeholders and dilutes the business focus. Business architecture should remain technology-agnostic to allow for future technology changes without requiring documentation rewrites. By keeping business and technical concerns separate, architects can ensure that business stakeholders understand the value proposition while technical teams have freedom to optimize implementations.

#### ❌ Use Unclear or Ambiguous Process Labels
- **Reason:** Ensures process documentation is understandable and actionable
- **Priority:** ❌ Won't
- **Description:** Never use vague or ambiguous labels for process steps that don't clearly indicate what action is being performed or what outcome is expected. Ambiguous labels like "Process Data" or "Handle Request" provide no useful information to stakeholders and make it difficult to understand process flows. By using specific, descriptive labels, architects can create documentation that clearly communicates process requirements and expectations.

#### ❌ Include Technical Implementation Details in Business Views
- **Reason:** Prevents confusion and maintains focus on business value
- **Priority:** ❌ Won't
- **Description:** Avoid mixing technical implementation details with business process documentation as this creates confusion for non-technical stakeholders and dilutes the business focus. Business architecture should remain technology-agnostic to allow for future technology changes without requiring documentation rewrites. By keeping business and technical concerns separate, architects can ensure that business stakeholders understand the value proposition while technical teams have freedom to optimize implementations.

### Solution Architecture

#### ✅ Implement Hierarchical Architecture Views
- **Reason:** Provides appropriate level of detail for different stakeholder needs
- **Priority:** 🔴 Must
- **Description:** Structure solution architecture using hierarchical views from system context down to class relationships, ensuring each level provides the right amount of detail for its intended audience. This approach prevents information overload while maintaining traceability between high-level decisions and detailed implementations. By organizing information hierarchically, architects can communicate complex systems effectively and support different decision-making processes at various organizational levels.

#### ✅ Label Interfaces with Protocols
- **Reason:** Enables clear understanding of system integration requirements
- **Priority:** 🟡 Should
- **Description:** Clearly label all system interfaces with their protocols (REST, ODBC, File drop) and directionality (in/out/bidirectional) to support integration planning and security design. This labeling ensures that all stakeholders understand the technical requirements and constraints of system interactions. By documenting interface details comprehensively, architects can prevent integration issues and ensure that security and performance requirements are properly addressed.

#### ✅ Identify Trust Boundaries
- **Reason:** Ensures proper security architecture and compliance
- **Priority:** 🔴 Must
- **Description:** Explicitly identify and document all trust boundaries in system architecture to support security design and compliance requirements. These boundaries define where security controls must be implemented and help ensure that sensitive data is properly protected. By mapping trust boundaries, architects can design more secure systems and ensure that regulatory requirements are met throughout the architecture.

#### ✅ Document SLAs for External Systems
- **Reason:** Ensures realistic system design and capacity planning
- **Priority:** 🟡 Should
- **Description:** Include known rate limits and SLAs for all external system interfaces to inform capacity planning and error handling design. This information ensures that the system can handle real-world constraints and provides a basis for performance optimization. By documenting external SLAs, architects can design more resilient systems that meet business requirements under various operating conditions.

#### ✅ Maintain Public API Focus
- **Reason:** Ensures stable and maintainable system interfaces
- **Priority:** 🟡 Should
- **Description:** Focus class relationship diagrams on public APIs and stable interactions, avoiding internal implementation details that may change frequently. This approach ensures that documentation remains relevant as the system evolves and supports better dependency management. By emphasizing public interfaces, architects can create more maintainable systems with clear separation of concerns.

#### ✅ Include Error Handling Patterns
- **Reason:** Ensures system resilience and reliability
- **Priority:** 🟡 Should
- **Description:** Document error modes, idempotency, and retry patterns in class relationships to support robust system design. This information helps ensure that systems can handle failures gracefully and maintain data consistency. By including error handling in architecture documentation, architects can design more reliable systems that meet business continuity requirements.

#### ✅ Use Consistent Naming Conventions
- **Reason:** Enables better system understanding and maintenance
- **Priority:** 🟡 Should
- **Description:** Apply consistent naming conventions for entities, attributes, and layers throughout data models to improve system maintainability and understanding. These conventions should align with business terminology and support automated processing where possible. By establishing naming standards, architects can create more coherent systems that are easier to understand and maintain over time.

#### ✅ Define Data Contracts
- **Reason:** Ensures data quality and system integration reliability
- **Priority:** 🔴 Must
- **Description:** Specify data formats, schemas, and versioning for all data flows to ensure compatibility and quality across system components. These contracts provide a foundation for reliable data exchange and support automated validation. By defining clear data contracts, architects can prevent integration issues and ensure that data quality is maintained throughout the system.

#### ✅ Document Observability Integration
- **Reason:** Enables effective system monitoring and troubleshooting
- **Priority:** 🟡 Should
- **Description:** Include metrics, logs, and correlation IDs in data flow documentation to support monitoring and troubleshooting capabilities. This information ensures that systems can be effectively monitored and problems can be quickly identified and resolved. By documenting observability requirements, architects can design systems that are easier to operate and maintain in production environments.

#### ✅ Align UI Flows with User Journeys
- **Reason:** Ensures user-centric system design
- **Priority:** 🟡 Should
- **Description:** Structure UI flow documentation around complete user journeys rather than individual screens to better support user experience design. This approach ensures that the system meets actual user needs and supports efficient task completion. By focusing on user journeys, architects can create more intuitive and effective user interfaces that improve overall system usability.

#### ✅ Use Appropriate Diagram Types for Technical Views
- **Reason:** Ensures diagrams effectively represent technical concepts and relationships
- **Priority:** 🟡 Should
- **Description:** Select the most appropriate Mermaid diagram type for technical documentation, such as sequenceDiagram for data flows, classDiagram for object relationships, and flowchart for system interactions. This ensures that the visual representation accurately reflects the technical concepts being documented. By choosing appropriate diagram types, architects can create technical documentation that is both accurate and easily understandable by technical audiences.

#### ❌ Exceed Node Limits in Diagrams
- **Reason:** Maintains diagram readability and comprehension
- **Priority:** ❌ Won't
- **Description:** Avoid creating diagrams with more than 25 nodes as this overwhelms viewers and reduces the effectiveness of visual communication. Large diagrams become difficult to understand and navigate, leading to misinterpretation of system relationships. By keeping diagrams focused and concise, architects can ensure that their documentation serves as effective communication tools rather than sources of confusion.

#### ❌ Use Colors or Custom Styling in Diagrams
- **Reason:** Ensures consistent rendering across different environments
- **Priority:** ❌ Won't
- **Description:** Do not use colors or custom styling in Mermaid diagrams as these may not render consistently across different platforms and tools. Colored diagrams can create accessibility issues and may not be visible to all users. By sticking to plain text formatting, architects can ensure that their diagrams are universally readable and maintain professional appearance across all viewing environments.

#### ❌ Mix Business and Technical Concepts in Single Diagrams
- **Reason:** Prevents confusion between different architectural concerns
- **Priority:** ❌ Won't
- **Description:** Avoid combining business process flows with technical implementation details in the same diagram as this creates confusion for different stakeholder groups. Business stakeholders may not understand technical details, while technical teams may miss business context. By keeping concerns separate, architects can create targeted diagrams that effectively communicate with their intended audiences.

#### ❌ Exceed Node Limits in Diagrams
- **Reason:** Maintains diagram readability and comprehension
- **Priority:** ❌ Won't
- **Description:** Avoid creating diagrams with more than 25 nodes as this overwhelms viewers and reduces the effectiveness of visual communication. Large diagrams become difficult to understand and navigate, leading to misinterpretation of system relationships. By keeping diagrams focused and concise, architects can ensure that their documentation serves as effective communication tools rather than sources of confusion.

#### ❌ Use Colors or Custom Styling in Diagrams
- **Reason:** Ensures consistent rendering across different environments
- **Priority:** ❌ Won't
- **Description:** Do not use colors or custom styling in Mermaid diagrams as these may not render consistently across different platforms and tools. Colored diagrams can create accessibility issues and may not be visible to all users. By sticking to plain text formatting, architects can ensure that their diagrams are universally readable and maintain professional appearance across all viewing environments.

### Diagram Creation and Quality

#### ✅ Use Appropriate Diagram Types for Context
- **Reason:** Ensures diagrams effectively communicate the intended architectural concepts
- **Priority:** 🔴 Must
- **Description:** Select the most appropriate Mermaid diagram type based on the architectural view being documented, such as flowchart for processes, sequenceDiagram for interactions, and classDiagram for relationships. This ensures that the visual representation matches the conceptual model and enhances understanding. By choosing the right diagram type, architects can create more effective communication tools that clearly convey complex system concepts to different stakeholder groups.

#### ✅ Maintain Consistent Layout Direction
- **Reason:** Improves diagram readability and navigation
- **Priority:** 🟡 Should
- **Description:** Use consistent layout directions (LR for flows, TD for hierarchies) across all diagrams to create predictable reading patterns for users. This consistency reduces cognitive load and makes it easier to follow diagram flows. By standardizing layout directions, architects can create more intuitive documentation that users can navigate quickly and understand more easily.

#### ✅ Sanitize Labels for Readability
- **Reason:** Ensures diagram labels are clear and professional
- **Priority:** 🟡 Should
- **Description:** Use ASCII characters, spaces, and underscores in Mermaid labels while avoiding special characters that may not render properly. This sanitization ensures labels remain readable across different environments and tools. By maintaining clean, consistent labeling, architects can create professional diagrams that communicate effectively regardless of the viewing platform.

#### ✅ Include Clear Legends and Keys
- **Reason:** Helps users understand diagram notation and symbols
- **Priority:** 🟡 Should
- **Description:** Provide clear legends or keys for diagrams that use special notation, symbols, or abbreviations to ensure all viewers can understand the content. This is particularly important for technical diagrams with complex relationships. By including comprehensive legends, architects can ensure that their diagrams are accessible to all stakeholders, regardless of their technical background.

#### ✅ Validate Diagram Rendering
- **Reason:** Ensures diagrams display correctly in target environments
- **Priority:** 🟡 Should
- **Description:** Test diagram rendering in the actual documentation environment to ensure proper display and readability before finalizing documentation. This validation prevents issues with unsupported syntax or formatting problems. By validating diagrams, architects can ensure that their visual documentation remains effective and professional in the intended usage context.

#### ❌ Mix Business and Technical Concepts in Single Diagrams
- **Reason:** Prevents confusion between different architectural concerns
- **Priority:** ❌ Won't
- **Description:** Avoid combining business process flows with technical implementation details in the same diagram as this creates confusion for different stakeholder groups. Business stakeholders may not understand technical details, while technical teams may miss business context. By keeping concerns separate, architects can create targeted diagrams that effectively communicate with their intended audiences.

#### ❌ Use Unclear or Generic Node Names
- **Reason:** Ensures diagrams provide meaningful information
- **Priority:** ❌ Won't
- **Description:** Do not use vague or generic names like "Process" or "System" for diagram nodes as these provide no useful information to viewers. Generic names reduce the value of diagrams and make them less useful for understanding system relationships. By using specific, descriptive names, architects can create diagrams that provide clear, actionable information to all stakeholders.

#### ❌ Create Diagrams Without Source References
- **Reason:** Maintains traceability and auditability of architectural decisions
- **Priority:** ❌ Won't
- **Description:** Never create diagrams without including source references to the underlying code, configurations, or requirements that substantiate the diagram content. This lack of traceability makes it impossible to verify diagram accuracy or update them when systems change. By always including source references, architects can ensure that their diagrams remain reliable and trustworthy over time.

### Business-Technology Alignment

#### ✅ Connect Business Objectives to Technical Capabilities
- **Reason:** Ensures technology investments support business goals
- **Priority:** 🔴 Must
- **Description:** Explicitly map business objectives to specific technical capabilities and system features to demonstrate how technology enables business value. This mapping ensures that technical decisions are aligned with business priorities and that investments deliver measurable business benefits. By connecting business and technology, architects can ensure that systems are designed to maximize business impact and return on investment.

#### ✅ Document Technology Constraints Impacting Business
- **Reason:** Enables realistic business planning and expectation management
- **Priority:** 🟡 Should
- **Description:** Clearly document how technical constraints, limitations, or dependencies may impact business processes and outcomes. This transparency helps business stakeholders understand technical realities and plan accordingly. By documenting technology constraints, architects can prevent unrealistic expectations and ensure that business plans account for technical limitations.

#### ✅ Include Business Context in Technical Decisions
- **Reason:** Ensures technical solutions support business requirements
- **Priority:** 🔴 Must
- **Description:** Always include business context and requirements when documenting technical architecture decisions to ensure solutions remain aligned with business needs. This context helps justify technical choices and ensures they support business objectives. By maintaining business context in technical documentation, architects can create systems that effectively serve business purposes.

#### ✅ Map Business Processes to System Components
- **Reason:** Provides clear traceability between business and technical layers
- **Priority:** 🟡 Should
- **Description:** Create clear mappings between business processes and the specific system components that support them to enable impact analysis and change management. This mapping helps understand how changes in one layer affect others. By mapping processes to components, architects can ensure that business and technical changes are coordinated effectively.

#### ❌ Design Technology Without Business Requirements
- **Reason:** Prevents misaligned and ineffective technical solutions
- **Priority:** ❌ Won't
- **Description:** Never design or document technical architecture without first understanding and documenting the underlying business requirements. This approach leads to technical solutions that may not meet business needs or provide value. By ensuring business requirements drive technical design, architects can create systems that effectively support business objectives and deliver real value.

### Service Integration

#### ✅ Document Service Dependencies and Interactions
- **Reason:** Ensures reliable service integration and troubleshooting
- **Priority:** 🟡 Should
- **Description:** Clearly document all service dependencies, interaction patterns, and integration points to support reliable system operation and maintenance. This documentation helps identify potential failure points and integration issues. By documenting service interactions, architects can ensure that systems are designed for reliable operation and effective troubleshooting.

#### ✅ Include Service Level Agreements in Architecture
- **Reason:** Sets clear expectations for service performance and availability
- **Priority:** 🟡 Should
- **Description:** Document SLAs for all services including response times, availability requirements, and throughput expectations to guide system design and capacity planning. These SLAs ensure that systems are designed to meet business requirements. By including SLAs in architecture documentation, architects can ensure that service designs meet operational requirements and business expectations.

#### ✅ Define Service Boundaries and Responsibilities
- **Reason:** Prevents service overlap and ensures clear ownership
- **Priority:** 🟡 Should
- **Description:** Clearly define service boundaries, responsibilities, and ownership to prevent overlap and ensure accountability. This clarity helps in system maintenance and evolution. By defining service boundaries, architects can create more maintainable systems with clear separation of concerns and responsibilities.

#### ✅ Document Service Failure Modes and Recovery
- **Reason:** Ensures system resilience and business continuity
- **Priority:** 🟡 Should
- **Description:** Document potential failure modes for each service and the corresponding recovery procedures to support resilient system design. This information ensures that systems can handle failures gracefully. By documenting failure modes and recovery, architects can design systems that maintain business continuity even during service disruptions.

#### ❌ Create Services Without Defined Interfaces
- **Reason:** Prevents integration issues and ensures service interoperability
- **Priority:** ❌ Won't
- **Description:** Never design services without clearly defined and documented interfaces as this leads to integration problems and unreliable service interactions. Undefined interfaces create ambiguity and make it difficult to ensure service compatibility. By defining clear interfaces, architects can ensure that services can interact reliably and maintain system stability.

### Product Development

#### ✅ Align Architecture with Product Roadmap
- **Reason:** Ensures architectural decisions support product evolution
- **Priority:** 🔴 Must
- **Description:** Ensure that architectural documentation reflects and supports the product roadmap, including planned features and capabilities. This alignment ensures that architecture evolves with product needs. By aligning architecture with product roadmap, architects can ensure that systems are designed to support future product development and evolution.

#### ✅ Document Product Requirements Traceability
- **Reason:** Maintains connection between product features and architecture
- **Priority:** 🟡 Should
- **Description:** Create clear traceability between product requirements and architectural components to ensure all requirements are properly addressed. This traceability supports validation and change management. By documenting requirements traceability, architects can ensure that product features are properly implemented and validated.

#### ✅ Include Product Quality Attributes in Architecture
- **Reason:** Ensures architecture supports product quality requirements
- **Priority:** 🟡 Should
- **Description:** Document how architectural decisions support key product quality attributes such as performance, scalability, and usability. This ensures that quality requirements are built into the system design. By including quality attributes in architecture, architects can ensure that systems meet product quality expectations and user needs.

#### ✅ Plan for Product Evolution in Architecture
- **Reason:** Ensures architecture can accommodate future product changes
- **Priority:** 🟡 Should
- **Description:** Design architecture with future product evolution in mind, including extension points and modular design. This foresight reduces technical debt and supports agile product development. By planning for evolution, architects can create systems that can adapt to changing product requirements without major rework.

#### ❌ Ignore Product Backlog in Architecture Planning
- **Reason:** Prevents misalignment between architecture and product development
- **Priority:** ❌ Won't
- **Description:** Never develop architecture without considering the product backlog and upcoming features as this leads to architectural decisions that don't support product evolution. Ignoring the backlog can result in technical debt and implementation difficulties. By considering the product backlog, architects can ensure that architecture supports current and future product needs.

### Support and Operations

#### ✅ Include Operational Requirements in Architecture
- **Reason:** Ensures systems are designed for effective operation and support
- **Priority:** 🟡 Should
- **Description:** Document operational requirements such as monitoring, logging, and maintenance procedures as part of the architectural design. This ensures that systems are designed for operational efficiency. By including operational requirements, architects can ensure that systems are easier to operate and maintain in production environments.

#### ✅ Document Support Processes and Procedures
- **Reason:** Enables effective system support and troubleshooting
- **Priority:** 🟡 Should
- **Description:** Include support processes, escalation procedures, and troubleshooting guides in architecture documentation to support operational teams. This information ensures that systems can be effectively supported. By documenting support processes, architects can ensure that operational teams have the information they need to maintain system availability.

#### ✅ Plan for Operational Monitoring and Alerting
- **Reason:** Ensures proactive system management and issue detection
- **Priority:** 🟡 Should
- **Description:** Design architecture with monitoring and alerting capabilities to enable proactive system management and issue detection. This ensures that problems are identified before they impact users. By planning for monitoring, architects can create systems that are easier to operate and maintain with higher availability.

#### ✅ Include Disaster Recovery in Architecture
- **Reason:** Ensures business continuity during major incidents
- **Priority:** 🟡 Should
- **Description:** Document disaster recovery procedures and capabilities as part of the architectural design to ensure business continuity. This ensures that systems can recover from major incidents. By including disaster recovery in architecture, architects can ensure that systems maintain critical business functions during disruptions.

#### ❌ Design Without Operational Considerations
- **Reason:** Prevents systems that are difficult to operate and support
- **Priority:** ❌ Won't
- **Description:** Never design systems without considering operational requirements as this leads to systems that are difficult to deploy, monitor, and maintain. Operational considerations are crucial for system success in production. By including operational considerations, architects can ensure that systems are designed for real-world operation and support.

### Implementation Practices

#### ✅ Document Implementation Constraints
- **Reason:** Ensures realistic and achievable implementation plans
- **Priority:** 🟡 Should
- **Description:** Clearly document technical constraints, dependencies, and implementation requirements to guide development teams. This ensures that implementations are realistic and achievable. By documenting constraints, architects can prevent implementation issues and ensure successful project delivery.

#### ✅ Include Development Guidelines in Architecture
- **Reason:** Ensures consistent implementation across development teams
- **Priority:** 🟡 Should
- **Description:** Provide development guidelines and best practices as part of architectural documentation to ensure consistent implementation. This ensures that all teams follow the same standards and patterns. By including development guidelines, architects can ensure that implementations are consistent and maintainable.

#### ✅ Plan for Testing in Architecture Design
- **Reason:** Ensures systems are designed for effective testing and validation
- **Priority:** 🟡 Should
- **Description:** Include testing strategies and requirements in architectural design to ensure systems can be effectively tested and validated. This ensures that quality is built into the system from the start. By planning for testing, architects can ensure that systems meet quality requirements and perform as expected.

#### ✅ Document Deployment and Release Processes
- **Reason:** Ensures smooth and reliable system deployment
- **Priority:** 🟡 Should
- **Description:** Include deployment procedures, release processes, and rollback plans in architecture documentation to ensure smooth system deployment. This ensures that systems can be deployed reliably. By documenting deployment processes, architects can ensure that releases are predictable and successful.

#### ❌ Implement Without Architecture Guidance
- **Reason:** Prevents inconsistent and poorly designed implementations
- **Priority:** ❌ Won't
### People & Operations
- **Reason:** Ensures diagrams effectively communicate the intended architectural concepts
- **Priority:** � Must
- **Description:** Select the most appropriate Mermaid diagram type based on the architectural view being documented, such as flowchart for processes, sequenceDiagram for interactions, and classDiagram for relationships. This ensures that the visual representation matches the conceptual model and enhances understanding. By choosing the right diagram type, architects can create more effective communication tools that clearly convey complex system concepts to different stakeholder groups.

#### ✅ Maintain Consistent Layout Direction
- **Reason:** Improves diagram readability and navigation
- **Priority:** 🟡 Should
- **Description:** Use consistent layout directions (LR for flows, TD for hierarchies) across all diagrams to create predictable reading patterns for users. This consistency reduces cognitive load and makes it easier to follow diagram flows. By standardizing layout directions, architects can create more intuitive documentation that users can navigate quickly and understand more easily.

#### ✅ Sanitize Labels for Readability
- **Reason:** Ensures diagram labels are clear and professional
- **Priority:** 🟡 Should
- **Description:** Use ASCII characters, spaces, and underscores in Mermaid diagram labels while avoiding special characters that may not render properly. This sanitization ensures labels remain readable across different environments and tools. By maintaining clean, consistent labeling, architects can create professional diagrams that communicate effectively regardless of the viewing platform.

#### ✅ Include Clear Legends and Keys
- **Reason:** Helps users understand diagram notation and symbols
- **Priority:** 🟡 Should
- **Description:** Provide clear legends or keys for diagrams that use special notation, symbols, or abbreviations to ensure all viewers can understand the content. This is particularly important for technical diagrams with complex relationships. By including comprehensive legends, architects can ensure that their diagrams are accessible to all stakeholders, regardless of their technical background.

#### ✅ Validate Diagram Rendering
- **Reason:** Ensures diagrams display correctly in target environments
- **Priority:** � Should
- **Description:** Test diagram rendering in the actual documentation environment to ensure proper display and readability before finalizing documentation. This validation prevents issues with unsupported syntax or formatting problems. By validating diagrams, architects can ensure that their visual documentation remains effective and professional in the intended usage context.

#### ✅ Use Decision Diamonds for Process Branching
- **Reason:** Clearly represents conditional logic and decision points in processes
- **Priority:** 🟡 Should
- **Description:** Use diamond shapes for decision points in flowcharts to clearly indicate where conditional logic occurs and what factors influence the process flow. This visual convention makes it easier for stakeholders to understand process branching and decision criteria. By using standard flowchart symbols, architects can create diagrams that follow established conventions and are immediately understandable to all viewers.

#### ✅ Represent Queues and Waits as Distinct Nodes
- **Reason:** Makes process bottlenecks and waiting times visible in documentation
- **Priority:** 🟡 Should
- **Description:** Use distinct nodes or symbols to represent queues, waiting states, and bottlenecks in process flows to highlight potential improvement areas. This makes inefficiencies visible and helps prioritize process optimization efforts. By explicitly showing waiting times and queues, architects can create documentation that supports continuous improvement initiatives.

#### ✅ Keep Labels Concise and Readable
- **Reason:** Ensures diagram information is easily digestible
- **Priority:** 🟡 Should
- **Description:** Use short, descriptive labels for diagram elements that clearly convey their purpose without overwhelming the viewer with excessive text. This balance ensures that diagrams remain readable while providing sufficient information. By keeping labels concise, architects can create diagrams that are both informative and visually clean.

#### ❌ Use Unclear or Generic Node Names
- **Reason:** Ensures diagrams provide meaningful information
- **Priority:** ❌ Won't
- **Description:** Never use vague or generic names like "Process" or "System" for diagram nodes as these provide no useful information to viewers. Generic names reduce the value of diagrams and make them less useful for understanding system relationships. By using specific, descriptive names, architects can create diagrams that provide clear, actionable information to all stakeholders.

#### ❌ Create Diagrams Without Source References
- **Reason:** Maintains traceability and auditability of architectural decisions
- **Priority:** ❌ Won't
- **Description:** Never create diagrams without including source references to the underlying code, configurations, or requirements that substantiate the diagram content. This lack of traceability makes it impossible to verify diagram accuracy or update them when systems change. By always including source references, architects can ensure that their diagrams remain reliable and trustworthy over time.

### Business-Technology Alignment

#### ✅ Map Business Capabilities to Technical Components
- **Reason:** Ensures technology supports business needs
- **Priority:** 🔴 Must
- **Description:** Create clear mappings between business capabilities and technical components to ensure that technology investments support business objectives. This alignment ensures that development efforts are focused on capabilities that deliver business value. By mapping capabilities to components, architects can ensure that technology decisions are driven by business requirements and that systems deliver measurable business outcomes.

#### ✅ Include Business Metrics in Technical KPIs
- **Reason:** Ensures technical performance supports business success
- **Priority:** 🟡 Should
- **Description:** Incorporate business-level metrics (lead time, customer satisfaction, revenue impact) alongside technical KPIs to provide comprehensive performance visibility. This ensures that technical performance is measured against business outcomes. By including business metrics, architects can create more effective monitoring systems that support business decision-making.

#### ✅ Validate Technical Decisions Against Business Requirements
- **Reason:** Ensures technology choices support business goals
- **Priority:** 🔴 Must
- **Description:** Evaluate technical architecture decisions against explicit business requirements and success criteria to ensure alignment. This validation ensures that technology choices support business objectives and deliver expected value. By validating decisions against requirements, architects can prevent misaligned technology investments and ensure that systems meet business needs.

#### ✅ Document Business Impact of Technical Changes
- **Reason:** Ensures stakeholders understand change implications
- **Priority:** 🟡 Should
- **Description:** Include business impact assessments in technical change documentation to help stakeholders understand the broader implications of technical decisions. This ensures that business stakeholders can make informed decisions about technical changes. By documenting business impact, architects can facilitate better communication between technical and business teams.

#### ✅ Balance Technical Debt with Business Value
- **Reason:** Ensures sustainable technology evolution
- **Priority:** 🟡 Should
- **Description:** Evaluate technical debt reduction efforts against business value delivery to ensure that refactoring efforts support business objectives. This balance ensures that technical improvements don't interfere with business value delivery. By balancing technical debt with business value, architects can maintain system health while supporting business growth.

#### ✅ Include Business Stakeholders in Architecture Reviews
- **Reason:** Ensures business perspectives are considered in technical decisions
- **Priority:** 🟡 Should
- **Description:** Include business stakeholders in architecture review processes to ensure that technical decisions consider business implications and requirements. This inclusion ensures that architecture decisions are well-rounded and support business success. By involving business stakeholders, architects can create more effective solutions that meet both technical and business needs.

#### ❌ Focus Solely on Technical Optimization
- **Reason:** Ensures technology serves business needs
- **Priority:** ❌ Won't
- **Description:** Never optimize technical architecture without considering business impact, as this can lead to solutions that don't deliver business value. Technical optimization must always be balanced with business requirements to ensure that systems support organizational goals. By considering business impact, architects can create solutions that are both technically sound and business-effective.

#### ❌ Ignore Business Context in Technical Design
- **Reason:** Ensures technical solutions address real business problems
- **Priority:** ❌ Won't
- **Description:** Never design technical solutions without understanding the business context and requirements, as this can result in systems that don't solve actual business problems. Technical design must be informed by business needs to ensure relevance and effectiveness. By understanding business context, architects can create solutions that deliver real business value.

### Service Integration

#### ✅ Document Integration Patterns and Protocols
- **Reason:** Ensures consistent and reliable service interactions
- **Priority:** 🟡 Should
- **Description:** Clearly document the integration patterns (REST, ODBC, File drop) and protocols used between services to ensure consistent implementation. This documentation supports reliable service interactions and simplifies maintenance. By documenting integration patterns, architects can ensure that services work together effectively and that integration issues can be resolved quickly.

#### ✅ Include Trust Boundaries in Architecture Views
- **Reason:** Ensures security considerations are visible in documentation
- **Priority:** 🟡 Should
- **Description:** Identify and document trust boundaries in system context diagrams to highlight security-sensitive zones and compliance requirements. This visibility ensures that security considerations are considered in system design. By including trust boundaries, architects can create more secure system architectures that protect sensitive data and meet compliance requirements.

#### ✅ Document External System SLAs and Rate Limits
- **Reason:** Ensures realistic integration planning
- **Priority:** 🟡 Should
- **Description:** Include known rate limits, SLAs, and performance characteristics of external systems in architecture documentation to support realistic integration planning. This information ensures that integrations are designed to work within system constraints. By documenting external system characteristics, architects can design more reliable integrations that perform well in production environments.

#### ✅ Use Standard Integration Interfaces
- **Reason:** Ensures interoperability and reduces integration complexity
- **Priority:** 🟡 Should
- **Description:** Prefer standard protocols and interfaces (REST APIs, ODBC, standard file formats) over custom integrations to simplify maintenance and improve interoperability. Standard interfaces reduce integration complexity and support better system evolution. By using standard interfaces, architects can create more maintainable and flexible system architectures.

#### ✅ Include Error Handling in Integration Documentation
- **Reason:** Ensures robust service interactions
- **Priority:** 🟡 Should
- **Description:** Document error handling patterns, retry logic, and failure recovery procedures for service integrations to ensure robust operation. This ensures that integrations can handle failures gracefully and maintain system stability. By documenting error handling, architects can design more resilient systems that perform well under adverse conditions.

#### ✅ Validate Integration Contracts
- **Reason:** Ensures service compatibility and prevents integration issues
- **Priority:** 🟡 Should
- **Description:** Validate that integration contracts (APIs, data formats, protocols) are compatible and well-documented before implementation. This validation prevents integration issues and ensures smooth service interactions. By validating contracts, architects can prevent costly integration problems and ensure that services work together effectively.

#### ❌ Assume External Systems Are Always Available
- **Reason:** Ensures realistic integration design
- **Priority:** ❌ Won't
- **Description:** Never design integrations assuming external systems are always available, as this can lead to system failures when external dependencies are unavailable. Integration design must account for external system failures and include appropriate error handling. By planning for unavailability, architects can create more resilient systems that maintain operation during external service disruptions.

#### ❌ Use Inconsistent Integration Patterns
- **Reason:** Creates maintenance complexity and integration issues
- **Priority:** ❌ Won't
- **Description:** Avoid using different integration patterns for similar use cases within the same system, as this creates inconsistency and increases maintenance complexity. Consistent patterns simplify system understanding and maintenance. By using consistent integration patterns, architects can create more maintainable and understandable system architectures.

### Product Development

#### ✅ Structure Backlogs Around User Journeys
- **Reason:** Ensures development focuses on user value
- **Priority:** 🟡 Should
- **Description:** Organize product backlogs and roadmaps around complete user journeys rather than isolated features to ensure holistic value delivery. This approach ensures that development efforts create meaningful user experiences. By focusing on user journeys, architects can ensure that products deliver comprehensive value and meet user needs effectively.

#### ✅ Include Acceptance Criteria in Architecture Decisions
- **Reason:** Ensures technical decisions support user requirements
- **Priority:** 🟡 Should
- **Description:** Reference user acceptance criteria when making architecture decisions to ensure that technical choices support user requirements and expectations. This ensures that architecture decisions contribute to successful product delivery. By considering acceptance criteria, architects can create solutions that meet user needs and pass acceptance testing.

#### ✅ Document Product Evolution in Architecture
- **Reason:** Ensures architecture supports product growth
- **Priority:** 🟡 Should
- **Description:** Include product evolution plans and scaling requirements in architecture documentation to ensure that systems can grow with product needs. This ensures that architecture decisions support long-term product success. By documenting evolution plans, architects can design systems that remain viable as products grow and change.

#### ✅ Align Architecture with Product Vision
- **Reason:** Ensures technical implementation supports product goals
- **Priority:** 🔴 Must
- **Description:** Ensure that architecture decisions and technical implementation align with the overall product vision and strategic objectives. This alignment ensures that technical work supports product success. By aligning architecture with product vision, architects can ensure that technical decisions contribute to achieving product goals.

#### ✅ Include Product Metrics in Architecture KPIs
- **Reason:** Ensures architecture supports product success measurement
- **Priority:** 🟡 Should
- **Description:** Incorporate product-level metrics (user adoption, feature usage, satisfaction scores) into architecture monitoring to ensure systems support product success. This ensures that architecture decisions are evaluated against product outcomes. By including product metrics, architects can create systems that effectively support product objectives.

#### ✅ Plan Architecture for Product Scaling
- **Reason:** Ensures systems can handle product growth
- **Priority:** 🟡 Should
- **Description:** Design architecture with product scaling requirements in mind, including user growth, feature expansion, and performance needs. This ensures that systems remain effective as products scale. By planning for scaling, architects can prevent performance issues and ensure continued product success.

#### ❌ Develop Features Without Architecture Review
- **Reason:** Ensures features fit within overall system design
- **Priority:** ❌ Won't
- **Description:** Never develop new features without architecture review, as this can lead to inconsistent implementations and integration issues. All features must be reviewed for architectural fit and consistency. By conducting architecture reviews, architects can ensure that new features integrate well with existing systems and maintain overall system quality.

#### ❌ Ignore Product Context in Technical Decisions
- **Reason:** Ensures technical decisions support product success
- **Priority:** ❌ Won't
- **Description:** Never make technical decisions without considering the product context and user impact, as this can lead to solutions that don't support product goals. Technical decisions must consider product implications. By considering product context, architects can ensure that technical choices contribute to product success.

### Support and Operations

#### ✅ Include Observability in Architecture Design
- **Reason:** Ensures systems can be effectively monitored and supported
- **Priority:** 🟡 Should
- **Description:** Design systems with observability in mind, including logging, metrics, and tracing capabilities to support effective operations and troubleshooting. This ensures that systems can be monitored and maintained effectively. By including observability, architects can create systems that are easier to support and maintain in production environments.

#### ✅ Document Operational Procedures
- **Reason:** Ensures consistent and effective system operations
- **Priority:** 🟡 Should
- **Description:** Include operational procedures, monitoring guidelines, and troubleshooting steps in architecture documentation to support effective system operations. This ensures that operations teams can maintain systems effectively. By documenting procedures, architects can ensure that systems are operated consistently and efficiently.

#### ✅ Plan for Incident Management
- **Reason:** Ensures effective response to system issues
- **Priority:** 🟡 Should
- **Description:** Include incident response procedures and escalation paths in architecture documentation to support quick issue resolution. This ensures that incidents can be handled effectively and minimize business impact. By planning for incidents, architects can design systems that are more resilient and easier to recover from failures.

#### ✅ Include Capacity Planning Guidelines
- **Reason:** Ensures systems can handle expected loads
- **Priority:** 🟡 Should
- **Description:** Document capacity planning considerations and scaling guidelines in architecture documentation to support effective resource planning. This ensures that systems can handle expected loads and scale appropriately. By including capacity planning, architects can prevent performance issues and ensure system reliability.

#### ✅ Document Backup and Recovery Procedures
- **Reason:** Ensures data protection and business continuity
- **Priority:** 🔴 Must
- **Description:** Include backup and recovery procedures in architecture documentation to ensure data protection and business continuity. This ensures that systems can be recovered from failures and data loss. By documenting backup procedures, architects can ensure that critical data is protected and systems can be restored quickly.

#### ✅ Include Change Management Processes
- **Reason:** Ensures controlled and safe system changes
- **Priority:** 🟡 Should
- **Description:** Document change management processes and approval workflows in architecture documentation to ensure controlled system evolution. This ensures that changes are implemented safely and with minimal risk. By including change management, architects can ensure that system changes are well-planned and executed effectively.

#### ❌ Design Systems Without Monitoring Capabilities
- **Reason:** Ensures systems can be effectively operated and supported
- **Priority:** ❌ Won't
- **Description:** Never design systems without built-in monitoring and observability capabilities, as this makes it impossible to effectively operate and troubleshoot systems. All systems must include appropriate monitoring to support operations. By including monitoring, architects can ensure that systems can be operated effectively and issues can be identified quickly.

#### ❌ Ignore Operational Requirements in Design
- **Reason:** Ensures systems are operable in production
- **Priority:** ❌ Won't
- **Description:** Never design systems without considering operational requirements and constraints, as this can lead to systems that are difficult or impossible to operate effectively. Design must consider operational needs. By considering operations, architects can create systems that are practical to deploy and maintain.

### Implementation Practices

#### ✅ Follow Configuration-First Approach
- **Reason:** Ensures systems are flexible and maintainable
- **Priority:** 🔴 Must
- **Description:** Implement systems using configuration-first principles, with YAML-driven behavior and clear separation of configuration from code. This ensures that systems are flexible and can be adapted without code changes. By following configuration-first principles, architects can create systems that are more maintainable and adaptable to changing requirements.

#### ✅ Maintain Module Separation and Contracts
- **Reason:** Ensures clean architecture and maintainable code
- **Priority:** 🟡 Should
- **Description:** Implement clear module boundaries and contracts between components to ensure clean architecture and maintainable code. This ensures that modules can be developed and maintained independently. By maintaining separation, architects can create systems that are easier to understand, test, and modify.

#### ✅ Include Comprehensive Error Handling
- **Reason:** Ensures robust and reliable system operation
- **Priority:** 🟡 Should
- **Description:** Implement comprehensive error handling and recovery mechanisms throughout the system to ensure robust operation. This ensures that systems can handle failures gracefully and maintain stability. By including error handling, architects can create more reliable systems that perform well under adverse conditions.

#### ✅ Implement Proper Logging and Tracing
- **Reason:** Ensures systems can be effectively monitored and debugged
- **Priority:** 🟡 Should
- **Description:** Implement structured logging and tracing throughout the system to support effective monitoring and debugging. This ensures that system behavior can be understood and issues can be diagnosed quickly. By implementing proper logging, architects can create systems that are easier to operate and troubleshoot.

#### ✅ Use Consistent Coding Standards
- **Reason:** Ensures code quality and maintainability
- **Priority:** 🟡 Should
- **Description:** Apply consistent coding standards and patterns across the codebase to ensure quality and maintainability. This ensures that code is readable and can be maintained by different developers. By using consistent standards, architects can create codebases that are professional and easier to work with.

#### ✅ Include Unit and Integration Tests
- **Reason:** Ensures system reliability and prevents regressions
- **Priority:** 🟡 Should
- **Description:** Implement comprehensive unit and integration tests to ensure system reliability and prevent regressions. This ensures that systems work as expected and changes don't break existing functionality. By including tests, architects can ensure that systems remain reliable as they evolve.

#### ✅ Document Implementation Decisions
- **Reason:** Ensures decisions are traceable and understandable
- **Priority:** 🟡 Should
- **Description:** Document key implementation decisions and trade-offs in code comments and architecture documentation to ensure decisions are traceable. This ensures that future developers can understand why decisions were made. By documenting decisions, architects can create systems that are easier to maintain and evolve.

#### ❌ Implement Without Configuration Validation
- **Reason:** Ensures configuration reliability and prevents runtime errors
- **Priority:** ❌ Won't
- **Description:** Never implement systems without validating configuration files and schemas, as this can lead to runtime errors and unpredictable behavior. All configurations must be validated to ensure system reliability. By validating configurations, architects can prevent configuration-related issues and ensure system stability.

#### ❌ Create Monolithic Code Structures
- **Reason:** Ensures maintainability and scalability
- **Priority:** ❌ Won't
- **Description:** Never create monolithic code structures without clear module boundaries, as this makes systems difficult to maintain and scale. Code must be organized into maintainable modules with clear responsibilities. By avoiding monolithic structures, architects can create systems that are easier to understand, test, and modify.

#### ❌ Ignore Code Quality Standards
- **Reason:** Ensures long-term system maintainability
- **Priority:** ❌ Won't
- **Description:** Never ignore code quality standards and best practices, as this leads to systems that are difficult to maintain and evolve. All code must follow established quality standards. By maintaining quality standards, architects can ensure that systems remain maintainable and reliable over their lifecycle.

### People & Operations

#### ✅ Derive RACI from AI Personas
- **Reason:** Ensures clear accountability in AI-assisted processes
- **Priority:** 🟡 Should
- **Description:** Extract RACI matrices from AI persona files to define clear roles and responsibilities in documentation processes. This ensures that all stakeholders understand their responsibilities and prevents gaps in coverage. By deriving RACI from personas, architects can create more effective governance structures for AI-assisted development and documentation.

#### ✅ Include Escalation Paths in RACI
- **Reason:** Ensures process continuity when issues arise
- **Priority:** 🟡 Should
- **Description:** Document escalation paths and decision hierarchies in organizational diagrams to support effective issue resolution. These paths ensure that problems can be addressed at the appropriate level and prevent bottlenecks in decision-making. By including escalations, architects can design more resilient organizational structures that maintain productivity during challenging situations.

#### ✅ Align Roadmaps with Business Objectives
- **Reason:** Ensures strategic alignment of development efforts
- **Priority:** 🔴 Must
- **Description:** Structure product backlogs and roadmaps around business objectives and user journeys to ensure development efforts support strategic goals. This alignment ensures that resources are focused on high-value activities and that progress can be measured against business outcomes. By connecting roadmaps to business objectives, architects can ensure that development efforts deliver maximum business value.

#### ✅ Document Release Branching Strategy
- **Reason:** Ensures predictable and reliable release processes
- **Priority:** 🟡 Should
- **Description:** Clearly document branching strategies, PR rules, and merge processes in deployment documentation to support consistent release management. This ensures that releases are predictable and that quality standards are maintained. By documenting branching strategies, architects can prevent release-related issues and ensure smooth deployment processes.

#### ✅ Include Rollback Procedures
- **Reason:** Ensures business continuity during deployment failures
- **Priority:** 🔴 Must
- **Description:** Document rollback procedures and recovery processes in deployment documentation to support quick recovery from failed releases. These procedures ensure that systems can be restored to working states quickly, minimizing business impact. By planning for rollbacks, architects can design more resilient deployment processes that maintain service availability.

#### ✅ Plan for Knowledge Transfer
- **Reason:** Ensures organizational knowledge continuity
- **Priority:** 🟡 Should
- **Description:** Include knowledge transfer processes and documentation handoffs in organizational planning to ensure continuity when team members change. This ensures that critical knowledge is preserved and accessible to new team members. By planning for knowledge transfer, architects can maintain organizational effectiveness and prevent knowledge loss.

#### ✅ Include Training Requirements in Architecture
- **Reason:** Ensures team capability to support systems
- **Priority:** 🟡 Should
- **Description:** Document training requirements and skill development needs in architecture documentation to ensure teams have necessary capabilities. This ensures that teams can effectively operate and maintain systems. By including training requirements, architects can ensure that organizational capabilities keep pace with system complexity.

#### ❌ Create Siloed Team Structures
- **Reason:** Ensures effective collaboration and knowledge sharing
- **Priority:** ❌ Won't
- **Description:** Never create organizational structures with excessive silos between teams, as this hinders collaboration and knowledge sharing. Teams must have appropriate cross-functional interactions to support effective system development and operations. By avoiding silos, architects can create more collaborative and effective organizations.

#### ❌ Ignore Team Skill Gaps
- **Reason:** Ensures teams can deliver effectively
- **Priority:** ❌ Won't
- **Description:** Never ignore team skill gaps and capability needs when designing systems, as this can lead to delivery failures and quality issues. Team capabilities must be considered in system design and planning. By addressing skill gaps, architects can ensure that teams have the capabilities needed to deliver successful systems.

#### ❌ Develop Without Change Management
- **Reason:** Ensures controlled and safe organizational changes
- **Priority:** ❌ Won't
- **Description:** Never implement organizational changes without proper change management processes, as this can lead to resistance and implementation failures. All organizational changes must be managed effectively. By using change management, architects can ensure that organizational changes are implemented successfully and sustainably.

### Advanced Architectural Views

#### ✅ Implement Configuration Hierarchy
- **Reason:** Ensures predictable system behavior and configuration management
- **Priority:** 🟡 Should
- **Description:** Document configuration sources and their precedence to support consistent system configuration and troubleshooting. This hierarchy ensures that configuration changes have predictable effects and can be easily managed. By documenting configuration precedence, architects can prevent configuration-related issues and ensure system stability.

#### ✅ Document Sensitive Data Handling
- **Reason:** Ensures compliance with security and privacy requirements
- **Priority:** 🔴 Must
- **Description:** Define rules for handling sensitive information in configurations to support security and compliance requirements. These rules ensure that confidential data is properly protected and that regulatory requirements are met. By documenting sensitive data handling, architects can design systems that maintain security and privacy standards.

#### ✅ Include Correlation Mechanisms
- **Reason:** Enables effective system monitoring and troubleshooting
- **Priority:** 🟡 Should
- **Description:** Document how events are correlated across system components in observability maps to support effective monitoring and issue resolution. This ensures that related events can be connected and analyzed together. By including correlation mechanisms, architects can design systems that are easier to monitor and troubleshoot in production environments.

### Cross-cutting Standards

#### ✅ Maintain Consistent Diagram Formatting
- **Reason:** Ensures professional and readable documentation
- **Priority:** 🟡 Should
- **Description:** Use consistent diagram styles, layouts, and labeling conventions across all architecture documentation to improve readability and professionalism. This consistency helps stakeholders quickly understand different diagrams and reduces cognitive load. By standardizing formatting, architects can create more effective communication tools that serve their intended audiences better.

#### ✅ Validate Link Accuracy
- **Reason:** Prevents broken references and maintains documentation integrity
- **Priority:** 🔴 Must
- **Description:** Verify that all links in architecture documentation resolve to existing files and sections to prevent broken references. This validation ensures that documentation remains useful and trustworthy over time. By maintaining accurate links, architects can ensure that stakeholders can easily access related information and supporting evidence.

#### ✅ Apply Speculative Labeling
- **Reason:** Ensures transparency about documentation uncertainty
- **Priority:** 🟡 Should
- **Description:** Mark incomplete or uncertain content as (speculative) with clear gap descriptions to maintain transparency about documentation limitations. This labeling helps stakeholders understand the reliability of different sections and guides future improvement efforts. By being transparent about gaps, architects can build trust and ensure that documentation is used appropriately.

#### ✅ Include Timestamps for Currency
- **Reason:** Enables assessment of documentation freshness and relevance
- **Priority:** 🟡 Should
- **Description:** Add UTC timestamps to all generated sections to track when content was last updated and assess its currency. This ensures that stakeholders can evaluate the timeliness of architectural information. By including timestamps, architects can maintain documentation that remains relevant as systems and requirements evolve.

#### ✅ Sanitize Mermaid Labels
- **Reason:** Ensures diagram readability and consistency
- **Priority:** 🟡 Should
- **Description:** Use ASCII characters and consistent formatting in Mermaid diagram labels to ensure readability across different environments and tools. This sanitization prevents display issues and maintains professional appearance. By standardizing labels, architects can create diagrams that communicate effectively regardless of the viewing environment.

## Acceptance Criteria

#### ✅ Include Business Sections
- **Reason:** Ensures comprehensive business-focused documentation
- **Priority:** 🔴 Must
- **Description:** Include Service Model and Business Model sections to explain what the service does and how people interact with it from a non-technical perspective. This ensures that documentation covers the business value and customer engagement aspects. By including these sections, architects can provide stakeholders with a complete understanding of the service's purpose and value proposition.

#### ✅ Include Solution Architecture Sections
- **Reason:** Provides complete technical architecture coverage
- **Priority:** 🔴 Must
- **Description:** Include System Context, Modules, Classes, Data Flow, Data Model, and UI Flow sections to cover the solution from high-level context to detailed internals. This ensures that all architectural views are documented with appropriate detail for different audiences. By including these sections, architects can provide comprehensive technical documentation that supports development, maintenance, and evolution.

#### ✅ Include People and Operations Sections
- **Reason:** Ensures organizational and operational aspects are documented
- **Priority:** 🔴 Must
- **Description:** Include Organizational, Product Backlog, and Deployment sections to document roles, responsibilities, roadmaps, and release processes. This ensures that the human and operational elements supporting the service are clearly defined. By including these sections, architects can ensure that teams understand their roles and that operations are well-planned and executed.

#### ✅ Include Advanced Views
- **Reason:** Provides additional specialized architectural perspectives
- **Priority:** 🟡 Should
- **Description:** Include Configuration Management, Service Map, and Observability Map sections to provide deeper insights into system configuration, service relationships, and monitoring capabilities. This ensures that specialized architectural concerns are addressed. By including these views, architects can provide more comprehensive documentation for complex system management and operations.

#### ✅ Provide Structured Text and Diagrams
- **Reason:** Ensures documentation is complete and usable
- **Priority:** 🔴 Must
- **Description:** Include both Mermaid diagrams and structured plain-text descriptions following provided templates for each architectural artifact. This ensures that documentation is both visual and textual, supporting different learning and reference styles. By providing both formats, architects can create more accessible and comprehensive documentation.

#### ✅ Include Source References
- **Reason:** Maintains traceability and auditability
- **Priority:** 🔴 Must
- **Description:** Include links to all sources used (READMEs, configs, code paths) for each architectural statement to enable verification and updates. This ensures that documentation can be traced back to authoritative sources and kept current. By including source references, architects can maintain documentation that is reliable and auditable.

#### ✅ Apply Redaction and Link Policies
- **Reason:** Ensures security and portability
- **Priority:** 🔴 Must
- **Description:** Replace sensitive information with [REDACTED] and use repo-root relative links starting with ./ to ensure documentation is secure and portable. This ensures that documentation can be shared safely and works across different environments. By following these policies, architects can create documentation that is both secure and universally accessible.

## Notes for BIS Repository

#### ✅ Focus on Module Structure
- **Reason:** Ensures documentation reflects actual system organization
- **Priority:** 🔴 Must
- **Description:** Document modules based on folders under ./engine/src/ (e.g., high, low, model, gui, exts) as these represent the architectural layers. This ensures that documentation accurately reflects the system's actual structure. By focusing on the correct module structure, architects can create documentation that matches the implementation and supports effective development.

#### ✅ Reference Quality Gates from Configs
- **Reason:** Ensures documentation reflects actual system constraints
- **Priority:** 🟡 Should
- **Description:** Include quality gates configured in ./engine/cfg/quality.yml when documenting data flows and validation processes. This ensures that documentation reflects the actual system behavior and constraints. By referencing quality configs, architects can create more accurate and useful documentation.

#### ✅ Include GUI Tab Flows
- **Reason:** Ensures complete user interface documentation
- **Priority:** 🟡 Should
- **Description:** Document UI flows per Python file in ./engine/src/gui/ (e.g., gui_loader.py, gui_pipeline.py) with entry point ./engine/src/gui/gui_main.py. This ensures that all user interfaces are properly documented. By documenting GUI flows, architects can ensure that user interactions are well-understood and supported.

#### ✅ Document Delivery Mechanisms
- **Reason:** Ensures external delivery processes are documented
- **Priority:** 🟡 Should
- **Description:** Include Outlook COM delivery mechanisms from ./engine/src/high/report_delivery.py in service models and data flows. This ensures that external delivery processes are properly documented. By including delivery mechanisms, architects can ensure that end-to-end processes are fully understood.

## Alignment with BIS System

#### ✅ Follow AI Agent Workflow
- **Reason:** Ensures consistent documentation generation
- **Priority:** 🟡 Should
- **Description:** Follow the AI workflow steps: scan sources of truth, generate diagram/text, validate links and redact, add timestamp, offer proactive suggestions. This ensures that documentation is generated consistently and reliably. By following the workflow, AI agents can produce high-quality, standardized documentation.

#### ✅ Use Speculative Labeling for Gaps
- **Reason:** Maintains transparency about documentation completeness
- **Priority:** 🟡 Should
- **Description:** Mark content as (speculative) when inputs are incomplete and list explicit gaps (e.g., "Gap: Missing .github/chatmodes/; next step: Consult team for persona files"). This ensures transparency about documentation limitations. By using speculative labeling, architects can communicate uncertainty and guide future improvements.

#### ✅ Maintain Idempotent Updates
- **Reason:** Ensures safe and predictable documentation updates
- **Priority:** 🔴 Must
- **Description:** Overwrite only inside designated blocks to preserve document structure and prevent unintended changes. This ensures that updates can be applied repeatedly without accumulation of errors. By maintaining idempotence, architects can safely update documentation without risking corruption.

#### ✅ Prioritize Secure Outputs
- **Reason:** Ensures documentation meets security requirements
- **Priority:** 🔴 Must
- **Description:** Always prioritize secure, deterministic outputs and flag conflicts with principles rather than proceeding with insecure options. This ensures that documentation maintains security standards. By prioritizing security, architects can prevent exposure of sensitive information and maintain compliance.

## Quick Reference for AI Agents

#### ✅ Enforce All Practices When Requested
- **Reason:** Ensures comprehensive application of best practices
- **Priority:** 🔴 Must
- **Description:** When user explicitly asks to "enforce all practices", apply ALL best practices from this guide to the relevant architecture documentation. This ensures complete adherence to standards. By enforcing all practices, architects can achieve maximum documentation quality and consistency.

#### ✅ Confirm Specific Practice Enforcement
- **Reason:** Ensures clear understanding of requirements
- **Priority:** 🟡 Should
- **Description:** When user asks to enforce a specific practice, confirm which specific practice(s) they want applied by listing available section headers. This ensures that the correct practices are applied. By confirming requirements, architects can provide targeted and effective improvements.

#### ✅ Maintain Detailed Logs
- **Reason:** Enables tracking of practice adoption and compliance
- **Priority:** 🟡 Should
- **Description:** Maintain detailed logs of practice adoption status with timestamps, file paths, and specific practice references. This enables tracking of compliance and improvements over time. By maintaining logs, architects can demonstrate adherence to standards and identify areas for further improvement.

#### ✅ Use Default Agent Decision Making
- **Reason:** Ensures appropriate practice application
- **Priority:** 🟡 Should
- **Description:** By default, decide which practices to apply based on context and documentation analysis without requiring explicit user requests. This ensures that improvements are made proactively. By using judgment, architects can optimize documentation quality efficiently.

#### ✅ Preserve Context in Responses
- **Reason:** Ensures continuity and understanding
- **Priority:** 🟡 Should
- **Description:** Keep conversation history and rationale with decisions to maintain context across interactions. This ensures that responses are coherent and build on previous work. By preserving context, architects can provide more effective and consistent assistance.

#### ✅ Provide Proactive Next Steps
- **Reason:** Guides users forward effectively
- **Priority:** 🟡 Should
- **Description:** In every response, include proactive next steps to guide the user forward, using priority indicators (🔴 MUST, 🟡 SHOULD, 🟢 COULD). This ensures that users know what to do next. By providing next steps, architects can facilitate progress and completion of tasks.

#### ✅ Cite Files and Lines Deterministically
- **Reason:** Ensures verifiable and reliable information
- **Priority:** 🔴 Must
- **Description:** Base decisions on existing repo artifacts and cite files/lines for deterministic claims to ensure reliability and auditability. This ensures that information is verifiable and trustworthy. By citing sources, architects can provide evidence-based guidance and maintain accountability.

#### ✅ Escalate Ambiguous or High-Risk Tasks
- **Reason:** Ensures appropriate handling of complex situations
- **Priority:** 🟡 Should
- **Description:** Escalate to human oversight for ambiguous or high-risk tasks to ensure proper handling and prevent errors. This ensures that critical decisions receive appropriate attention. By escalating when needed, architects can maintain quality and safety in documentation processes.

#### ✅ Use Rich Formatting in Responses
- **Reason:** Improves communication clarity and effectiveness
- **Priority:** 🟡 Should
- **Description:** Employ advanced Markdown features (tables, code blocks, diagrams, lists) for clarity rather than plain text responses. This ensures that information is presented effectively. By using rich formatting, architects can communicate complex information more clearly and efficiently.

#### ✅ Follow Temp File Policy
- **Reason:** Ensures safe and organized temporary file management
- **Priority:** 🔴 Must
- **Description:** Use temp/ directory for temporary files with proper naming convention (temp/<CHATMODE>/<timestamp>_<description>.<ext>) and cleanup files older than 7 days. This ensures safe and organized file management. By following the policy, architects can maintain a clean and secure workspace.

#### ✅ Reference Canonical Files
- **Reason:** Ensures use of authoritative sources
- **Priority:** 🔴 Must
- **Description:** Reference canonical files like wiki/BIS API.yml, wiki/Handbook.md, and module READMEs as single sources of truth. This ensures consistency and accuracy. By using canonical sources, architects can maintain reliable and authoritative documentation.

#### ✅ Validate YAML and Add Tests
- **Reason:** Ensures configuration reliability
- **Priority:** 🟡 Should
- **Description:** Validate YAML schemas against canonical specs and add config parsing tests to ensure reliability. This prevents configuration errors and ensures system stability. By validating configurations, architects can prevent runtime issues and maintain system reliability.

#### ✅ Follow Security Checklist
- **Reason:** Ensures secure system design and implementation
- **Priority:** 🔴 Must
- **Description:** Follow security checklist including no hardcoded secrets, input validation, proper error handling, SQL injection prevention, and path traversal protection. This ensures that systems are secure and compliant. By following the checklist, architects can prevent security vulnerabilities and maintain system integrity.

#### ✅ Maintain Tenant Isolation
- **Reason:** Ensures data security and compliance
- **Priority:** 🔴 Must
- **Description:** Ensure tenant isolation in all deliverables to prevent data leakage and maintain compliance. This ensures that multi-tenant systems are secure and properly segregated. By maintaining isolation, architects can protect sensitive data and meet regulatory requirements.

#### ✅ Update READMEs with Canonical Paths
- **Reason:** Ensures consistent and accurate documentation
- **Priority:** 🟡 Should
- **Description:** Update READMEs to reference canonical paths and mark authoritative files with "Canonical" in their header. This ensures that documentation is consistent and reliable. By maintaining canonical references, architects can prevent confusion and ensure users access correct information.



