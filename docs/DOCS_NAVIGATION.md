# Developer Documentation Navigation

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

A comprehensive guide to all developer-focused documentation in the `docs/` folder.

---

## Quick Navigation

### 📋 Documentation Structure

```
docs/                           -- Developer tools and guides
├── README.md                  -- Overview and orientation
├── CODE_STANDARDS.md          -- Code style and best practices
├── COMMENT_STANDARDS.md       -- Comment and documentation conventions
├── DOCUMENTATION_STANDARD.md  -- Documentation format standards
├── PERFORMANCE.md             -- Performance optimization guide
├── Glossary.md                -- Developer and game terminology
├── DOCS_NAVIGATION.md         -- This file
├── developers/                -- Developer setup and workflow
│   ├── README.md              -- Developer overview
│   ├── DEBUGGING.md           -- Debugging techniques and tools
│   ├── SETUP_WINDOWS.md       -- Windows environment setup
│   ├── TROUBLESHOOTING.md     -- Common issues and solutions
│   └── WORKFLOW.md            -- Development workflow
└── systems/                   -- System documentation
    └── Overview.md            -- Systems overview
```

---

## Main Documentation Categories

### 1. **Getting Started**

**For New Developers**:
- [README.md](README.md) - Start here for overview
- [developers/SETUP_WINDOWS.md](developers/SETUP_WINDOWS.md) - Set up your development environment
- [developers/WORKFLOW.md](developers/WORKFLOW.md) - Understand the development workflow
- [CODE_STANDARDS.md](CODE_STANDARDS.md) - Learn code style expectations

**Quick Links**:
- Love2D installation and setup
- Project dependencies
- Running the game with console
- Building and testing

### 2. **Code Quality**

**Standards and Best Practices**:
- [CODE_STANDARDS.md](CODE_STANDARDS.md) - Lua coding standards, file organization, patterns
- [COMMENT_STANDARDS.md](COMMENT_STANDARDS.md) - How to write effective comments
- [DOCUMENTATION_STANDARD.md](DOCUMENTATION_STANDARD.md) - Markdown documentation standards
- [PERFORMANCE.md](PERFORMANCE.md) - Performance optimization techniques

**Key Topics**:
- Variable naming conventions (local, camelCase, PascalCase)
- Error handling with pcall and assert
- Comment conventions and LuaDoc format
- File structure and module organization

### 3. **Development Workflow**

**Common Tasks**:
- [developers/WORKFLOW.md](developers/WORKFLOW.md) - Daily development workflow
- [developers/DEBUGGING.md](developers/DEBUGGING.md) - Debugging techniques
- [developers/TROUBLESHOOTING.md](developers/TROUBLESHOOTING.md) - Solving common problems
- [PERFORMANCE.md](PERFORMANCE.md) - Profiling and optimization

**Workflow Steps**:
1. Plan your task and create documentation
2. Create a branch for your work
3. Make incremental commits
4. Run tests and check for errors
5. Write or update documentation
6. Submit pull request for review

### 4. **Game Design Reference**

**For Understanding Game Systems**:
- See [wiki/README.md](../wiki/README.md) - Game design documentation hub
- [wiki/systems/Overview.md](../wiki/systems/Overview.md) - Overview of all game systems
- [wiki/GLOSSARY.md](../wiki/GLOSSARY.md) - Game terminology

**Note**: Game design and systems documentation is in the `wiki/` folder. Developer tools and setup guides are in `docs/`.

---

## Document Quick Reference

### By Purpose

**Understanding the Project**:
- [docs/README.md](README.md)
- [docs/systems/Overview.md](systems/Overview.md)
- [wiki/systems/Overview.md](../wiki/systems/Overview.md)

**Setting Up Development**:
- [docs/developers/SETUP_WINDOWS.md](developers/SETUP_WINDOWS.md)
- [docs/developers/WORKFLOW.md](developers/WORKFLOW.md)

**Writing Code**:
- [docs/CODE_STANDARDS.md](CODE_STANDARDS.md)
- [docs/COMMENT_STANDARDS.md](COMMENT_STANDARDS.md)
- [docs/developers/DEBUGGING.md](developers/DEBUGGING.md)

**Writing Documentation**:
- [docs/DOCUMENTATION_STANDARD.md](DOCUMENTATION_STANDARD.md)
- [docs/COMMENT_STANDARDS.md](COMMENT_STANDARDS.md)

**Debugging Issues**:
- [docs/developers/DEBUGGING.md](developers/DEBUGGING.md)
- [docs/developers/TROUBLESHOOTING.md](developers/TROUBLESHOOTING.md)

**Optimizing Performance**:
- [docs/PERFORMANCE.md](PERFORMANCE.md)
- [docs/developers/WORKFLOW.md](developers/WORKFLOW.md#performance-checklist)

**Understanding Terminology**:
- [docs/Glossary.md](Glossary.md) - Developer and technical terms
- [wiki/GLOSSARY.md](../wiki/GLOSSARY.md) - Game design terms

---

## Common Tasks

### "I'm new, where do I start?"

1. Read [docs/README.md](README.md)
2. Read [docs/developers/SETUP_WINDOWS.md](developers/SETUP_WINDOWS.md)
3. Read [docs/developers/WORKFLOW.md](developers/WORKFLOW.md)
4. Read [docs/CODE_STANDARDS.md](CODE_STANDARDS.md)

### "How do I set up my environment?"

See [docs/developers/SETUP_WINDOWS.md](developers/SETUP_WINDOWS.md)

### "What are the code standards?"

See [docs/CODE_STANDARDS.md](CODE_STANDARDS.md) and [docs/COMMENT_STANDARDS.md](COMMENT_STANDARDS.md)

### "How do I find and fix a bug?"

See [docs/developers/DEBUGGING.md](developers/DEBUGGING.md) and [docs/developers/TROUBLESHOOTING.md](developers/TROUBLESHOOTING.md)

### "How do I optimize performance?"

See [docs/PERFORMANCE.md](PERFORMANCE.md)

### "What's the development workflow?"

See [docs/developers/WORKFLOW.md](developers/WORKFLOW.md)

### "How do I write documentation?"

See [docs/DOCUMENTATION_STANDARD.md](DOCUMENTATION_STANDARD.md)

### "What game system does this relate to?"

Check [wiki/systems/Overview.md](../wiki/systems/Overview.md) or the [wiki/GLOSSARY.md](../wiki/GLOSSARY.md)

---

## File Organization

### Development Tools (`docs/` folder)

All files in the `docs/` folder are for **developers working on the codebase**:
- Setup instructions for Windows
- Code standards and best practices
- Debugging and troubleshooting guides
- Documentation format standards
- Performance optimization techniques

### Game Design (`wiki/` folder)

All files in the `wiki/` folder are for **understanding the game design**:
- Game systems documentation (19 systems documented)
- API references for game systems
- Design decisions and architecture
- Design guidelines and examples
- Game-specific terminology

---

## Related Documentation

- **[docs/README.md](README.md)** - Developer documentation overview
- **[developers/WORKFLOW.md](developers/WORKFLOW.md)** - Development process
- **[wiki/README.md](../wiki/README.md)** - Game design documentation
- **[wiki/NAVIGATION.md](../wiki/NAVIGATION.md)** - Game documentation navigation

---

## Maintenance

**Last Updated**: October 2025
**Status**: Active
**Version**: 1.0

This navigation guide is maintained as the primary entry point for developers. When adding new developer documentation, update this file to include links to the new content.

---

**Questions?** Check the [docs/developers/TROUBLESHOOTING.md](developers/TROUBLESHOOTING.md) or open an issue on GitHub.
