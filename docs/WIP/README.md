# Work In Progress (WIP)

**Purpose:** Draft documentation, experimental ideas, pending approvals  
**Audience:** Active contributors, documentation authors  
**Last Updated:** 2025-10-27

---

## 📋 What Goes in WIP/

### Draft Documents
- Design proposals awaiting approval
- Instruction guides being written
- System patterns being documented
- Process documents under development

### Experimental Ideas
- New patterns being explored
- Alternative approaches being tested
- Research notes and findings
- Proof-of-concept documentation

### Pending Approvals
- Documents awaiting review
- RFCs (Request for Comments)
- Design proposals under discussion
- Documentation updates awaiting merge

---

## 🔄 Workflow

### 1. Draft Creation
```
Create draft in docs/WIP/[name]_draft.md
```

**Naming Convention:**
- `[topic]_design_draft.md` - Design documents
- `[topic]_instruction_draft.md` - Instruction guides
- `[topic]_pattern_draft.md` - System patterns
- `[topic]_process_draft.md` - Process documents
- `[topic]_rfc.md` - Request for comments

### 2. Iteration
- Write and refine content
- Gather feedback from team
- Incorporate changes
- Keep revision history in git

### 3. Review
- Request review from appropriate team members
- Address feedback
- Make final revisions

### 4. Approval
- Get sign-off from relevant stakeholders
- Ensure all quality standards met

### 5. Promotion
- Move to appropriate permanent location:
  - Design → `design/mechanics/`
  - Instruction → `docs/instructions/`
  - Pattern → `docs/system/`
  - Process → `docs/processes/`
  - Handbook → `docs/handbook/`
- Update all relevant indexes
- Add cross-references
- Remove from WIP/ or mark as archived

---

## 📝 Document Status Tags

Mark document status clearly:

**🟡 DRAFT** - Actively being written  
**🟠 REVIEW** - Ready for review  
**🔵 RFC** - Request for comments  
**🟢 APPROVED** - Approved, ready to move  
**🔴 REJECTED** - Not approved, archived  
**⚪ ARCHIVED** - Historical reference

---

## 🎯 Quality Checklist

Before requesting review:
- [ ] Purpose clearly stated
- [ ] All required sections complete
- [ ] Examples provided where needed
- [ ] Cross-references to related docs
- [ ] Spelling and grammar checked
- [ ] Code examples tested (if applicable)
- [ ] Follows project standards

---

## 📂 Organization

### Current WIP Documents
List active drafts here:

- (None yet - this is a new system)

### Recently Promoted
List documents recently moved to permanent locations:

- (None yet - this is a new system)

### Archived
List rejected or superseded documents:

- (None yet - this is a new system)

---

## 💡 Tips for Effective Drafting

1. **Start with Template:** Use appropriate creation prompt:
   - [create_chatmode.prompt.md](../system/create_chatmode.prompt.md)
   - [create_instruction.prompt.md](../system/create_instruction.prompt.md)
   - [create_prompt.prompt.md](../system/create_prompt.prompt.md)
   - [create_system_pattern.prompt.md](../system/create_system_pattern.prompt.md)

2. **Iterate Quickly:** Don't aim for perfection in first draft

3. **Get Early Feedback:** Share early drafts with team

4. **Keep Revisions:** Use git commits to track evolution

5. **Mark Sections:** Use comments like `<!-- TODO: Add examples -->` for incomplete sections

6. **Link Liberally:** Cross-reference related docs even in draft

---

## 🚀 Quick Actions

**Start new draft:**
```bash
# 1. Choose appropriate template from docs/system/create_*.prompt.md
# 2. Create file in docs/WIP/
# 3. Mark status as 🟡 DRAFT
# 4. Commit to version control
```

**Request review:**
```bash
# 1. Mark status as 🟠 REVIEW
# 2. Add reviewers as comment in file
# 3. Notify reviewers
# 4. Address feedback
```

**Promote to permanent location:**
```bash
# 1. Ensure all quality checks pass
# 2. Mark status as 🟢 APPROVED
# 3. Move to appropriate folder
# 4. Update indexes and cross-references
# 5. Remove from WIP/ or mark archived
```

---

## 📚 Related Documentation

- **Creation Templates:** [docs/system/create_*.prompt.md](../system/)
- **Documentation Hub:** [docs/README.md](../README.md)
- **Handbook:** [docs/handbook/](../handbook/)
- **Processes:** [docs/processes/](../processes/)

---

## ⚠️ Important Notes

1. **WIP is temporary:** Documents should not stay here indefinitely
2. **Regular cleanup:** Review WIP/ monthly, promote or archive
3. **Version control:** All WIP documents must be in git
4. **Collaboration:** Use git for collaboration, not separate copies
5. **Status updates:** Keep status tags current

---

**Status:** 🟢 Active  
**Policy:** Review and cleanup monthly  
**Next Review:** End of month
# Project Handbook

**Purpose:** Project-specific policies, standards, and conventions  
**Audience:** All team members, new contributors  
**Last Updated:** 2025-10-27

---

## 📋 Contents

This handbook contains the project's conventions, standards, and policies that all contributors should follow.

### Sections (To Be Developed)

1. **Code Style Guide**
   - Naming conventions
   - File organization
   - Comment standards
   - Code formatting

2. **Team Communication**
   - Communication channels
   - Response time expectations
   - Meeting schedules
   - Documentation requirements

3. **Decision Making**
   - Decision process
   - Approval workflows
   - Escalation paths
   - RFC (Request for Comments) process

4. **Contribution Guidelines**
   - How to contribute
   - Pull request process
   - Code review standards
   - Testing requirements

5. **Quality Standards**
   - Code quality metrics
   - Test coverage requirements
   - Performance benchmarks
   - Documentation standards

6. **Onboarding**
   - New contributor guide
   - Required reading
   - Setup checklist
   - First tasks

---

## 🚀 Quick Start for New Contributors

1. **Read:** [Instructions/START_HERE.md](../instructions/START_HERE.md)
2. **Study:** [System Patterns](../system/)
3. **Review:** [Processes](../processes/)
4. **Follow:** Code style guide (when created)
5. **Ask:** Questions in team channels

---

## 📚 Related Documentation

- **Development Practices:** [docs/instructions/](../instructions/)
- **System Architecture:** [docs/system/](../system/)
- **Development Processes:** [docs/processes/](../processes/)
- **AI Agent Personas:** [docs/chatmodes/](../chatmodes/)

---

## 💡 Philosophy

This handbook embodies the project's values:

1. **Clarity over Cleverness:** Write obvious code
2. **Documentation First:** If it's not documented, it doesn't exist
3. **Test Everything:** Trust but verify
4. **Automate Repetition:** Humans are for thinking, machines for doing
5. **Fail Fast:** Catch errors early
6. **Universal Patterns:** Use proven patterns, not custom solutions

---

## 🔄 Living Document

This handbook is continuously updated as the project evolves. If you find gaps or outdated information:

1. Create issue or discussion
2. Propose changes
3. Submit pull request
4. Update this README

---

**Status:** 🟡 In Development  
**Priority:** High  
**Next Steps:** 
- Define code style guide
- Document team communication standards
- Create contribution guidelines

