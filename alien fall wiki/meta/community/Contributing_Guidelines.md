# Contributing Guidelines

**Tags:** #contributing #development #community  
**Last Updated:** September 30, 2025

---

## How to Contribute

Alien Fall welcomes contributions! This guide explains how to contribute code, documentation, assets, and more.

---

## Quick Start

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. **Create** a feature branch (`git checkout -b feature/my-feature`)
4. **Make** your changes
5. **Test** thoroughly
6. **Commit** with clear messages
7. **Push** to your fork
8. **Submit** a pull request

---

## Types of Contributions

### Code Contributions
- Bug fixes
- New features
- Performance improvements
- Refactoring

**Requirements:**
- Follow Lua coding standards (see below)
- Add tests for new features
- Update documentation
- No breaking changes without discussion

### Documentation
- Fix typos and clarify wording
- Add examples and tutorials
- Improve diagrams
- Translate content

**Requirements:**
- Follow documentation template
- Use proper Markdown formatting
- Test all links work
- Add to table of contents

### Assets (Art/Audio)
- Pixel art sprites (10×10 px base)
- UI elements
- Sound effects
- Music

**Requirements:**
- Follow style guide
- Open-source compatible licenses
- Provide source files (.ase, etc.)
- Optimize file sizes

### Mods
- Create example mods
- Improve mod API
- Write mod tutorials
- Test mod system

---

## Coding Standards

### Lua Style Guide

**Naming Conventions:**
```lua
-- Variables and functions: snake_case
local player_health = 100
function calculate_damage(base, armor)
    return math.max(0, base - armor)
end

-- Classes and modules: PascalCase
local UnitManager = {}
function UnitManager:new()
    return setmetatable({}, {__index = self})
end

-- Constants: UPPER_CASE
local MAX_SQUAD_SIZE = 8
local TILE_SIZE = 20
```

**Code Structure:**
```lua
-- File header
--[[
    Module: Unit Manager
    Purpose: Manages all unit entities in game
    Author: Contributor Name
    Date: 2025-09-30
]]

-- Imports
local class = require("lib.middleclass")
local Component = require("ecs.Component")

-- Constants
local MAX_UNITS = 100

-- Module definition
local UnitManager = class("UnitManager")

-- Public methods
function UnitManager:initialize()
    self.units = {}
end

function UnitManager:addUnit(unit)
    assert(unit, "Unit cannot be nil")
    table.insert(self.units, unit)
end

-- Private methods
local function validateUnit(unit)
    return unit and unit.id
end

return UnitManager
```

**Best Practices:**
- Use `local` for all variables unless global needed
- Validate function inputs with `assert()`
- Return early on error conditions
- Prefer readability over cleverness
- Comment complex logic
- Keep functions under 50 lines

---

## Testing Requirements

### Unit Tests
```lua
-- test/test_unit_manager.lua
local UnitManager = require("systems.UnitManager")

function test_add_unit()
    local manager = UnitManager:new()
    local unit = {id = 1, name = "Soldier"}
    
    manager:addUnit(unit)
    
    assert(#manager.units == 1)
    assert(manager.units[1] == unit)
end
```

### Running Tests
```bash
# Run all tests
love . --test

# Run specific test file
love . --test test/test_unit_manager.lua
```

---

## Pull Request Process

### Before Submitting
- [ ] Code follows style guide
- [ ] Tests pass (`love . --test`)
- [ ] Documentation updated
- [ ] No console errors
- [ ] Tested in-game
- [ ] Commit messages are clear

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Performance improvement

## Testing
How you tested the changes

## Screenshots (if applicable)
Visual changes

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes
```

### Review Process
1. Automated tests run
2. Code review by maintainers
3. Feedback addressed
4. Approved and merged
5. Acknowledged in [[Credits]]

---

## Commit Message Format

```
type(scope): Short description

Longer explanation if needed.

Fixes #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (formatting)
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

**Examples:**
```
feat(combat): Add flanking bonus mechanic

Soldiers now get +20% aim when flanking enemies.

Fixes #45

---

fix(save): Prevent crash on corrupted save files

Added validation and error handling.

---

docs(tutorial): Add base building guide

Complete tutorial for new players.
```

---

## Communication

### Before Starting Work
- Check existing issues/PRs to avoid duplicates
- Open an issue to discuss major changes
- Ask questions in discussions
- Claim issues you want to work on

### During Development
- Update issue with progress
- Ask for help if stuck
- Share work-in-progress for feedback

### After Submission
- Respond to review comments
- Make requested changes
- Be patient (reviews take time)

---

## Getting Help

- **Questions**: GitHub Discussions
- **Bug Reports**: GitHub Issues
- **Real-time Chat**: Discord (link in README)
- **Documentation**: This wiki

---

## Code of Conduct

### Expected Behavior
- Be welcoming and inclusive
- Respect differing viewpoints
- Accept constructive criticism
- Focus on what's best for community

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or insulting comments
- Publishing private information
- Unprofessional conduct

### Enforcement
Violations may result in temporary or permanent ban from project.

---

## Recognition

Contributors are recognized in:
- [[Credits]] page
- GitHub contributors graph
- Release notes
- Special roles in Discord

Significant contributors may be invited to join core team!

---

## License

By contributing, you agree that your contributions will be licensed under GPL-3.0 (code) and CC BY-SA 4.0 (documentation/assets).

---

**Questions?** Ask in GitHub Discussions or Discord!

---

**Last Updated:** September 30, 2025  
**Maintainer:** Project Lead
