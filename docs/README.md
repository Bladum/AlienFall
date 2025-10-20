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
| `wiki/systems/` | Game system docs (Geoscape, Basescape, Battlescape, etc.) |
| `wiki/api/` | API reference (CORE, GEOSCAPE, and more) |
| `wiki/architecture/` | Architecture decisions (ADRs 1-5) |
| `wiki/design/` | Design templates and specifications |
| `wiki/examples/` | Learning examples and tutorials |

**Also in wiki/**:
- `DOCUMENTATION_STANDARD.md` - How to write documentation
- `NAVIGATION.md` - Complete reference map
- `PERFORMANCE.md` - Performance optimization guide
- `Glossary.md` - Game terminology

---

## File Structure

```
docs/                          ← You are here
├── README.md                  ← This file (entry point)
├── CODE_STANDARDS.md          ← Code conventions
├── COMMENT_STANDARDS.md       ← Comment guidelines
└── developers/                ← Developer guides
    ├── SETUP_WINDOWS.md       ← Start here (first time)
    ├── SETUP_LINUX.md
    ├── SETUP_MAC.md
    ├── WORKFLOW.md            ← Then read this
    ├── DEBUGGING.md
    └── TROUBLESHOOTING.md

wiki/                          ← Full documentation
├── systems/                   ← Game mechanics (18 docs)
├── api/                       ← APIs & interfaces
├── architecture/              ← Design decisions
├── design/                    ← Templates & specs
├── examples/                  ← Learning guides
├── DOCUMENTATION_STANDARD.md
├── NAVIGATION.md
├── PERFORMANCE.md
└── Glossary.md
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

- **Need to know what something is?** → `wiki/Glossary.md`
- **Want to find a specific doc?** → `wiki/NAVIGATION.md`
- **Need documentation standards?** → `wiki/DOCUMENTATION_STANDARD.md`
- **Performance concerns?** → `wiki/PERFORMANCE.md`

---

## Key Files in This Folder

| File | Purpose |
|------|---------|
| `CODE_STANDARDS.md` | How to write code (naming, style, organization) |
| `COMMENT_STANDARDS.md` | How to write comments and docstrings |
| `developers/SETUP_*.md` | Installation & environment setup |
| `developers/WORKFLOW.md` | Git workflow and collaboration |
| `developers/DEBUGGING.md` | How to debug with Love2D console |
| `developers/TROUBLESHOOTING.md` | Common issues & fixes |

Everything else → `wiki/`

---

**Last Updated**: October 2025  
**Status**: Clean, focused, minimal

