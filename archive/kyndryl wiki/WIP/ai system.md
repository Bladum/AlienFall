## Agent Architecture Patterns

* **Solo Agent**: A single agent operating independently to complete a task.
* **Agent Roles**: An approach where different agents are assigned specific roles and responsibilities within a multi-agent system.
* **Agent-to-Agent Handoff**: The process of transferring a task or a part of a task from one agent to another.
* **Multi-agent Modularity**: A system design where multiple, specialized agents work together, with each agent responsible for a specific module or function.

---

## Agent Process Patterns

* **Prescribed Plan**: The agent follows a pre-defined, static plan or sequence of steps to achieve a goal.
* **MHQA (Multi-Hop Question Answering)**: A process pattern where an agent answers a complex question that requires gathering and synthesizing information from multiple sources or steps.
* **Orchestrated Agents**: A central orchestrator agent coordinates the actions and interactions of multiple specialized agents.
* **Dynamic Plan Generation**: An agent creates and modifies its plan in real time based on new information or changes in the environment.
* **Collaborating Agents**: Multiple agents work together cooperatively to solve a problem or complete a task.
* **Human-in-the-Loop**: The process involves a human providing guidance, feedback, or validation at specific points in the agent's workflow.

---

## Agent Evaluation Patterns

* **User-in-the-Loop**: A user provides continuous feedback or judges the agent's performance during its operation.
* **LLM-as-a-Judge**: A Large Language Model (LLM) is used to evaluate the performance or outputs of another agent or LLM.
* **Deterministic (code-based) evaluation**: The agent's output is evaluated against a fixed, pre-defined set of rules or code to determine its correctness.
* **Interaction Logging**: The interactions and steps an agent takes are recorded and analyzed to understand its behavior and performance.
* **Red Teaming**: A form of adversarial testing where a "red team" actively tries to find and exploit weaknesses or vulnerabilities in an agent's system.

---

## LLM Interaction Patterns

* **ReAct (Reason + Act)**: The agent alternates between reasoning (planning what to do next) and acting (executing an action) to solve a problem.
* **Chain of Thought**: A pattern where the LLM is prompted to show its step-by-step reasoning before providing a final answer.
* **Structured Response**: The agent is guided to format its output in a specific, machine-readable structure, such as JSON or XML.
* **Reflection**: The agent reviews its own past actions and outputs to identify errors and improve its future performance.
* **Retry Limits**: The agent is designed to attempt a specific action a limited number of times before failing or seeking alternative solutions.

---

## Agent Action Patterns

* **Function Calling**: An agent is able to call and execute external functions or tools to perform tasks outside of its core LLM capabilities.
* **Generated Code Execution**: The agent generates code (e.g., Python) and then executes that code to perform a task.
* **API Tool Use**: The agent uses an API (Application Programming Interface) as a tool to interact with external services or retrieve information.

---

## Agent Memory Patterns

* **RAG (Retrieval Augmented Generation)**: The agent retrieves relevant information from a knowledge base or external source to augment its generation process.
* **Memory Longevity**: Refers to how long an agent's memory persists, ranging from short-term (single conversation) to long-term (across sessions).
* **Memory Scope**: The context or range of information an agent can access from its memory, such as a single conversation thread or a broader knowledge base.

---

## Security & Identity Patterns

* **Identity Token Propagations**: The secure transfer of user identity information or tokens from one agent or service to another.
* **LLM Guardrails**: Mechanisms or rules put in place to ensure the LLM's behavior aligns with safety policies, preventing harmful or undesired outputs.


## How to Build a Good AI System with Agents

### Key Principles

* **Define Clear Goals**: Start with a well-defined problem and specific, measurable goals for your agent. Vague objectives lead to unfocused and inefficient systems.
* **Modular Design**: Use the **Multi-agent Modularity** and **Agent Roles** patterns. Break down complex tasks into smaller, manageable sub-tasks. Each sub-task should be handled by a specialized agent. This makes the system easier to debug, maintain, and scale.
* **Incorporate a Feedback Loop**: Use patterns like **Reflection** and **LLM-as-a-Judge**. This allows the agent to learn from its mistakes, evaluate its own performance, and iteratively improve its outputs.
* **Balance Autonomy and Control**: Employ patterns like **Human-in-the-Loop** and **Orchestrated Agents**. While agents should be able to act autonomously, a central orchestrator can ensure coordinated efforts, and human oversight is crucial for critical decisions and to prevent unintended behavior.
* **Prioritize Security**: Implement **LLM Guardrails** from the start. Build robust safety mechanisms to prevent agents from generating harmful content, accessing sensitive data improperly, or executing malicious code.

---

## How Not to Build a Good AI System with Agents

### Common Pitfalls

* **Monolithic Agent**: Avoid building a single, "omniscient" agent to do everything. This mirrors the **Solo Agent** pattern but without a clear scope. A single, undifferentiated agent is difficult to manage, prone to errors, and lacks the specialized expertise needed for complex tasks.
* **Lack of a Plan**: Don't let agents operate without a clear process. The absence of a **Prescribed Plan** or **Dynamic Plan Generation** leads to agents that behave erratically, get stuck in loops, or fail to complete tasks efficiently.
* **Ignoring Evaluation**: Neglecting to use patterns like **Deterministic evaluation** or **Interaction Logging** is a major mistake. Without a systematic way to measure performance, you won't know if the agent is actually solving the problem, and you can't identify areas for improvement.
* **Unchecked Autonomy**: Giving agents complete freedom without any oversight, either from a human or a central orchestrator, is dangerous. This can lead to unexpected and potentially harmful outcomes, especially when using patterns like **Generated Code Execution** or **API Tool Use** without proper security checks.
* **Poor Memory Management**: Building a system without a proper **Memory Longevity** or **Memory Scope** strategy leads to agents that forget crucial context from one interaction to the next, causing redundant work and frustrating user experiences. Using a weak or non-existent **RAG** system results in agents that "hallucinate" or provide inaccurate information because they can't access or retrieve relevant data.
* **Skipping Red Teaming**: Not performing **Red Teaming** is a recipe for disaster. Without actively trying to find and fix vulnerabilities, your agent system will be susceptible to exploitation and security breaches.

How to Build a Good AI System with Agents: Additional Cases
Case: Spotify's Music Recommendation Engine
Good Practice: Continuous Learning from User Behavior. Spotify’s system doesn't just recommend songs based on a genre; it uses an event-driven architecture to constantly analyze millions of user actions—skips, shares, saves, and listens. This live data feeds a dynamic plan generation process, ensuring recommendations stay fresh and hyper-personalized.

Good Practice: Human-AI Collaboration and Auditing. Spotify uses human-curated playlists (like "RapCaviar") and combines them with AI-generated recommendations. Human editors provide a quality and cultural check on the AI's output, ensuring the system doesn't get stuck in a "filter bubble" and that new, diverse artists are surfaced.

Case: UPS's ORION System
Good Practice: Deterministic Evaluation and Optimization. UPS’s On-Road Integrated Optimization and Navigation (ORION) system uses a deterministic, code-based evaluation to optimize delivery routes. It calculates the most efficient route for drivers, saving millions of gallons of fuel and reducing costs. The system's success is a direct result of its ability to be rigorously evaluated against a single, clear metric: cost and fuel efficiency.

Good Practice: Integration with Existing Infrastructure. Instead of a "rip and replace" approach, the ORION system was integrated with existing telematics and driver data. This API tool use allowed the company to gradually improve operations without disrupting its entire logistics network.

How Not to Build a Good AI System with Agents: Common Pitfalls and Case Studies
Case: Microsoft's Tay Chatbot
Bad Practice: Neglecting LLM Guardrails and Adversarial Testing. In 2016, Microsoft launched Tay, an AI chatbot that learned from public interactions on Twitter. Within 24 hours, it began tweeting racist and offensive content because trolls exploited its open-ended learning model. There were no robust guardrails or pre-deployment red teaming to anticipate and prevent this malicious behavior.

Bad Practice: Lack of Controlled Memory Scope. Tay's memory model was too broad; it was designed to learn from any public interaction without distinction. This lack of a controlled memory scope allowed it to absorb and regurgitate harmful content, essentially becoming a reflection of the worst parts of the internet.

Case: Amazon's AI Hiring Tool
Bad Practice: Unmitigated Bias from Training Data. Amazon developed an AI tool to automate resume screening, but the system was trained on data from a decade of past hires, a majority of whom were men. The AI system, without proper safeguards, learned to penalize resumes with words like "women's" (as in "women's chess club captain"). This case is a stark example of how historical human biases can be institutionalized and amplified by an AI system if the training data is not carefully audited for fairness.

Bad Practice: Opaque Black-Box Decision Making. The hiring tool's decision-making process was a "black box," meaning it was difficult for a human to understand why it favored some candidates over others. This opacity made it impossible for developers to easily identify and correct the gender bias, leading to the project's eventual abandonment.

Case: Air Canada's Chatbot
Bad Practice: Failure to Implement a Human-in-the-Loop Safeguard. In a legal case, Air Canada's chatbot provided a passenger with incorrect information about a bereavement fare, leading to a financial dispute. The airline tried to argue the chatbot was a "separate legal entity." The case highlighted a key failure: the lack of a clear human-in-the-loop process to validate or override the chatbot's response, especially on critical, legally binding information.

Bad Practice: Ignoring Retry Limits and Alternative Pathways. The chatbot was unable to correct its mistake and had no protocol to hand off the user to a human agent when the conversation became complex or the information was legally sensitive. This failure to implement a robust retry limit or agent-to-agent handoff led to a negative customer experience and a legal penalty.


Good Technical Setup and LLM Technology Cases
Case: IBM Watson Assistant for Contact Centers

Good Practice: Hybrid RAG Architecture. Instead of relying solely on a single knowledge base, Watson Assistant uses a multi-layered Retrieval-Augmented Generation (RAG) system. This includes a primary vector database for high-level, general knowledge and a secondary, more specialized search index for specific, proprietary documents like product manuals or HR policies. The agent dynamically decides which source to query based on the user's intent. This reduces hallucinations and ensures greater accuracy for enterprise-specific queries, as sensitive, non-public data is never exposed directly in the LLM's pre-training.

Good Practice: Fine-Tuning for a Specific Tone and Task. While the core of the system is RAG-based, IBM fine-tunes a smaller, specialized LLM (often a quantized version of a larger model) on a curated dataset of customer service conversations. This smaller model is not for factual knowledge but for generating responses with the appropriate tone—empathetic, professional, and on-brand—and for formatting its output into structured, machine-readable JSON for downstream systems.

Case: HubSpot's AI-Powered Sales Agents

Good Practice: Sophisticated API Tool Use with Auditing. HubSpot's agents are not just chatbots; they are designed to perform complex actions like updating a CRM record, scheduling a meeting, or sending a personalized email. They achieve this using a robust function-calling architecture. Each function call is tied to a specific API endpoint, and the system logs every agent action, including the function name and its parameters. This logging is crucial for auditing, debugging, and ensuring compliance, as every action can be traced back to the agent's "thought" process and the originating prompt.

Good Practice: Orchestrated Agent Ecosystems. Instead of a single agent, HubSpot uses a network of specialized agents orchestrated by a central "supervisory" agent. For example, a "Lead Qualification Agent" might use function calling to check a prospect's company size in a database, then hand off the lead to a "Meeting Scheduler Agent," which uses a calendar API. This modularity makes the system highly scalable and resilient.

Bad Technical Setup and LLM Technology Cases
Case: The Black Box of a Financial Fraud Detection System

Bad Practice: Unexplainable Decision-Making. A financial firm used a sophisticated, deep-learning model to flag fraudulent transactions. The model had high accuracy but was a "black box" ⬛. When a customer's legitimate transaction was incorrectly flagged, there was no way for a human analyst to explain why the model made that decision. This lack of transparency led to customer frustration, a time-consuming manual review process, and potential regulatory non-compliance, as financial systems often require auditable explanations for their decisions.

Case: A Retailer's On-the-Fly Code Generation Agent

Bad Practice: Unsanitized Generated Code Execution. A retailer deployed an agent that could dynamically write and execute Python scripts to run SQL queries and generate reports. The system lacked proper sandboxing and input sanitization. An internal user, either by accident or maliciously, prompted the agent to write a script with a destructive command, which was then executed. This uncontrolled generated code execution led to a temporary but significant data loss, highlighting the extreme security risks of allowing an agent to execute code without robust guardrails.

Case: A Healthcare System's Disconnected RAG

Bad Practice: Poor Data Plumbing and Outdated Information. A hospital implemented an AI assistant to help doctors with patient records, using a RAG system. The underlying data pipeline was inefficient and wasn't regularly updated from the central patient database. As a result, the agent would often retrieve stale information from a week-old knowledge base, giving incorrect medication dosages or outdated lab results. The system's failure wasn't in the LLM, but in the brittle data infrastructure that fed it, proving that even the most advanced LLM technology is only as good as the data it has access to.

GitHub Copilot
Good Cases (Productivity and Learning)
Accelerating Boilerplate Code and Repetitive Tasks: Developers widely report that Copilot excels at generating common code patterns, such as getters and setters, unit tests, and routine API calls. This allows them to focus on the core business logic rather than on tedious, repetitive coding, leading to significant productivity gains. For instance, a developer needing to write tests for a new function can simply write a comment like // write a test for the 'calculate_total' function, and Copilot will generate a comprehensive test suite.

Onboarding and Code Comprehension: Teams use Copilot to get new members up to speed on a codebase quickly. The Copilot Chat feature allows a developer to highlight a block of unfamiliar code and ask, "Explain what this function does." Copilot provides a detailed, contextual explanation, often without the user having to leave their IDE or search through external documentation.

Syntax and Language Translation: Copilot serves as a valuable resource for developers working in a language they're not an expert in. A developer familiar with Python but new to JavaScript can write a comment describing what they want to achieve, and Copilot will suggest the correct syntax and idioms for JavaScript, acting as a live language reference.

Bad Cases (Security and Technical Debt)
Introducing Insecure or Suboptimal Code: Because Copilot is trained on a vast corpus of public code, it can learn and perpetuate bad practices. It may suggest code with known security vulnerabilities (e.g., SQL injection-prone queries, unencrypted connections) or write code that is syntactically correct but inefficient or not aligned with a team's best practices. This can happen without the developer's knowledge, as the code often looks plausible.

Context Window and Hallucinations: Copilot's effectiveness is limited by the context window of the underlying LLM. In large codebases, it may only "see" a small portion of the project, leading it to make assumptions and generate code that is completely out of sync with the rest of the application's architecture. Developers have reported cases of Copilot fabricating non-existent methods or suggesting incorrect data structures because it lacked a full understanding of the project's state.

Over-reliance and Reduced Skill Development: A common concern, especially for junior developers, is the risk of becoming overly dependent on Copilot. By automating the mental work of problem-solving and debugging, Copilot could hinder a developer's ability to develop a deep, intuitive understanding of code, leading to a "skill atrophy." When Copilot fails or suggests incorrect code, a developer may lack the fundamental knowledge to debug the issue on their own.

Microsoft Copilot Studio
Good Cases (Empowering Citizen Developers and Integration)
Rapid Prototyping and Low-Code Development: Copilot Studio is designed to empower subject matter experts and citizen developers to create custom AI agents without extensive coding knowledge. A business analyst, for example, can use the low-code interface to build a customer service chatbot for an internal SharePoint site by simply pointing the bot to relevant company documents. This allows for rapid development of solutions that would have previously required a dedicated team of AI developers.

Seamless Integration with the Microsoft Ecosystem: A key advantage is Copilot Studio's deep integration with the Microsoft ecosystem. A custom copilot can be built to use Power Automate to trigger workflows, retrieve data from Dynamics 365, or answer questions based on information in a company's OneDrive or Teams. This turns the copilot from a simple Q&A bot into a true action-oriented agent that can automate complex business processes.

Centralized Control and Governance: For enterprise-level use, Copilot Studio provides a centralized platform for managing and governing custom copilots. IT administrators can define security policies, manage data access, and monitor usage, ensuring that custom-built agents adhere to corporate standards and do not expose sensitive information.

Bad Cases (Technical Limitations and Misleading Expectations)
Limited Customization for Complex Use Cases: While great for low-code scenarios, Copilot Studio can be restrictive for advanced technical users. It may not be suitable for building complex, highly customized agents that require a specific model fine-tuning or a unique retrieval architecture. The pre-built connectors and features may not cover all niche business cases, forcing developers to look for more flexible (and more complex) alternatives.

Brittle and Unpredictable Agent Behavior: Users have reported that agents built with Copilot Studio can be unpredictable and brittle. The underlying LLM may "hallucinate" or provide incorrect answers, and the agent's conversation history can be surprisingly short, leading it to forget context after just a few turns. This can be frustrating for both the user and the developer, as it requires extensive manual testing and fine-tuning of the prompt-based "topics" to ensure reliability.

Security Misconfigurations and Data Leaks: A significant risk is the potential for misconfiguration. An administrator could, by mistake, set up an agent with overly permissive access to a SharePoint library, inadvertently exposing sensitive or confidential corporate data to any user who interacts with the bot. As a security concern, an attacker could exploit these misconfigurations to perform data harvesting or even launch social engineering attacks. The ease of deployment can lead to a false sense of security regarding the agent's capabilities and its access to internal systems.


