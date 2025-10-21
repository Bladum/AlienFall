# AlienFall Documentation

Welcome to the AlienFall documentation for developers.

---

## Quick Start

**First Time Setup?**
- [Setup Guide (Windows)](developers/SETUP_WINDOWS.md) - 30-45 minutes
- [Setup Guide (Linux)](developers/SETUP_LINUX.md) 
- [Setup Guide (macOS)](developers/SETUP_MAC.md)

**Then Read:**
- [Development Workflow](developers/WORKFLOW.md) - Git, branching, contributing
- [Code Standards](CODE_STANDARDS.md) - Naming, style, organization
- [Comment Standards](COMMENT_STANDARDS.md) - How to write good comments

**When You Need Help:**
- [Debugging Guide](developers/DEBUGGING.md) - Console debugging
- [Troubleshooting](developers/TROUBLESHOOTING.md) - Common issues

---

## Full Documentation

Everything else is in the **`wiki/`** folder:

| Folder | Contents |
|--------|----------|
| `wiki/systems/` | Game system docs (19 documented systems) |
| `wiki/api/` | API reference (ARCHITECTURE, BASESCAPE, BATTLESCAPE, ECONOMY, UNITS) |
| `wiki/architecture/` | Architecture decisions (ADRs 1-5) |
| `wiki/design/` | Design guidelines and references |
| `wiki/examples/` | Learning examples and tutorials |

**Also in wiki/**:
- `GLOSSARY.md` - Merged, authoritative game terminology reference
- `NAVIGATION.md` - Complete documentation reference map
- `README.md` - Game design documentation hub

**In docs/ (Developer Tools)**:
- `DOCUMENTATION_STANDARD.md` - How to write documentation
- `DOCS_NAVIGATION.md` - Developer guide navigation
- `PERFORMANCE.md` - Performance optimization guide
- `Glossary.md` - Developer terminology reference
- `api/README.md` - Developer API links

**NEW: Implementation Status & Audits**:
- `WIKI_ENGINE_ALIGNMENT_AUDIT.md` - Complete audit of wiki vs engine (89% aligned ✅)
- `ENGINE_IMPLEMENTATION_STATUS.md` - Quick reference showing what's built vs planned
- `GEOSCAPE_IMPLEMENTATION_STATUS.md` - Geoscape system status (74% complete, Relations gap identified)

---

## File Structure

```
docs/                          ← Developer tools (You are here)
├── README.md                  ← This file (entry point)
├── DOCUMENTATION_STANDARD.md  ← Documentation format standards
├── DOCS_NAVIGATION.md         ← Developer guide navigation
├── CODE_STANDARDS.md          ← Code conventions
├── COMMENT_STANDARDS.md       ← Comment guidelines
├── PERFORMANCE.md             ← Performance optimization
├── Glossary.md                ← Developer terminology
├── api/
│   └── README.md              ← Links to game APIs (wiki/api/)
└── developers/                ← Developer setup & workflow
    ├── SETUP_WINDOWS.md       ← Start here (first time)
    ├── SETUP_LINUX.md
    ├── SETUP_MAC.md
    ├── WORKFLOW.md            ← Then read this
    ├── DEBUGGING.md
    └── TROUBLESHOOTING.md

wiki/                          ← Game design documentation
├── systems/                   ← Game mechanics (19 documented)
├── api/                       ← Game system APIs
├── architecture/              ← Design decisions (ADRs 1-5)
├── design/                    ← Design guidelines & specs
├── examples/                  ← Learning guides & tutorials
├── README.md                  ← Game design hub
├── NAVIGATION.md              ← Game documentation map
├── GLOSSARY.md                ← Authoritative game terminology
```

---

## 👨‍💻 For Developers

1. **Set up your environment** → `developers/SETUP_WINDOWS.md` (or your OS)
2. **Learn the workflow** → `developers/WORKFLOW.md`
3. **Write code** → Reference `CODE_STANDARDS.md` and `COMMENT_STANDARDS.md`
4. **Debug issues** → Use `developers/DEBUGGING.md` + console
5. **Explore systems** → Check `wiki/systems/` and `wiki/api/` for details
6. **Find architecture** → Read `wiki/architecture/README.md` for ADRs

---

## 🎮 For Game Designers

1. Read game system docs in `wiki/systems/`
2. Use design template in `wiki/design/DESIGN_TEMPLATE.md`
3. Check balance reference in `wiki/design/BALANCE_REFERENCE.md` (when available)
4. Test using methodology in `wiki/design/TESTING_METHODOLOGY.md` (when available)

---

## 🤖 For Everyone

- **Need to know what something is?** → `wiki/GLOSSARY.md` (game terms) or `Glossary.md` (developer terms)
- **Want to find a specific doc?** → `wiki/NAVIGATION.md` (game docs) or `DOCS_NAVIGATION.md` (developer docs)
- **Need documentation standards?** → `DOCUMENTATION_STANDARD.md`
- **Performance concerns?** → `PERFORMANCE.md`

---

## Key Files in This Folder

| File | Purpose |
|------|---------|
| `CODE_STANDARDS.md` | How to write code (naming, style, organization) |
| `COMMENT_STANDARDS.md` | How to write comments and docstrings |
| `DOCUMENTATION_STANDARD.md` | How to write documentation |
| `DOCS_NAVIGATION.md` | Developer documentation navigation guide |
| `PERFORMANCE.md` | Performance optimization techniques |
| `Glossary.md` | Developer and technical terminology |
| `developers/SETUP_*.md` | Installation & environment setup (Windows, Linux, macOS) |
| `developers/WORKFLOW.md` | Git workflow and collaboration |
| `developers/DEBUGGING.md` | How to debug with Love2D console |
| `developers/TROUBLESHOOTING.md` | Common issues & fixes |

Everything else → `wiki/` (Game design documentation)

---

**Last Updated**: October 2025  
**Status**: Clean, focused, minimal

