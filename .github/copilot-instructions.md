
# System Prompt for AlienFall Love2D Development

## Project Overview

AlienFall is an open-source, turn-based strategy game inspired by the X-COM series, developed using the Love2D framework in Lua. The game features:

- **Geoscape**: Global strategic layer for managing bases, intercepting UFOs, and planetary operations.
- **Battlescape**: Tactical turn-based combat against alien forces.
- **Base Management**: Building facilities, researching technologies, and managing resources.
- **Economy and Finance**: Detailed cost management, salaries, and resource allocation.
- **Open-Ended Gameplay**: No fixed win/loss conditions, sandbox elements.

The project emphasizes AI-assisted development, moddability, and comprehensive documentation.

## Technologies and Tools

- **Love2D**: 2D game framework (version 11.5+) providing graphics, audio, input, and window management.
- **Lua**: Programming language (version 5.1+), with focus on clean, modular code.
- **Widgets Library**: Custom UI framework for game interfaces (located in `widgets/`).
- **VS Code**: Primary IDE with GitHub Copilot for AI-assisted coding.
- **Git**: Version control with feature branches and pull requests.

## Code Standards and Best Practices

### Lua Language Best Practices

- **Variable Scope**: Use `local` for all variables to avoid global pollution. Only use globals for Love2D callbacks or when absolutely necessary.
- **Naming Conventions**: 
  - Functions and variables: `camelCase` (e.g., `calculateDamage`).
  - Constants: `UPPER_CASE` (e.g., `MAX_HEALTH`).
  - Modules and classes: `PascalCase` (e.g., `GameState`).
- **Error Handling**: Use `pcall` or `xpcall` for risky operations. Provide meaningful error messages.
- **Performance**: Minimize table creations in hot loops. Reuse objects where possible. Use `ipairs` for arrays, `pairs` for dictionaries.
- **Code Style**: Consistent indentation (4 spaces), line length < 100 characters. Use meaningful comments for complex logic.

### Love2D Specific Practices

- **Callback Structure**: Organize code around Love2D callbacks (`love.load`, `love.update`, `love.draw`, etc.).
- **Separation of Concerns**: 
  - Game logic in `love.update(dt)`.
  - Rendering in `love.draw()`.
  - Input handling in `love.keypressed`, `love.mousepressed`, etc.
- **Resource Management**: Load assets in `love.load`, clean up in `love.quit`.
- **Graphics**: Use `love.graphics` for all drawing. Batch operations for performance. Consider pixel art scaling.
- **Audio**: Use `love.audio` for sound effects and music. Manage audio sources properly.
- **File System**: Use `love.filesystem` for game data. Store user data in save directories.

### Code Organization

- **Modules**: Use `require()` for code organization. Structure as `folder.module` (e.g., `widgets.common.button`).
- **File Structure**: 
  - `main.lua`: Entry point and module loading.
  - `widgets/`: UI components and game-specific widgets.
  - `assets/`: Images, sounds, fonts.
  - `scripts/`: Game logic modules.
  - `tests/`: Unit and integration tests.
- **State Management**: Implement a state machine for different game screens (menu, geoscape, battlescape).
- **Entity System**: Use tables for game objects (units, aliens, facilities). Implement component-based architecture where appropriate.

### Game Development Patterns

- **Turn-Based Mechanics**: Clear phases for player actions, AI turns, and resolution.
- **Event System**: Use callbacks or observers for game events (missions, research completions).
- **Data-Driven Design**: Store game data in Lua tables or external files for easy modding.
- **UI Consistency**: Use the widgets library for all interfaces. Maintain 16x16 pixel art style, upscaled to 32x32.
- **Balance and Tuning**: Make values configurable for testing and balancing.

## Development Workflow

- **Planning**: Use TODO lists for complex features. Break down tasks into manageable steps.
- **Coding**: Write modular, testable code. Add comments for non-obvious logic.
- **Testing**: Run the game frequently using `lovec.exe` for console output. Use the logger module for debugging output. Write unit tests for critical functions.
- **Validation**: Check for syntax errors, performance issues, and adherence to best practices.
- **Documentation**: Update wiki pages for new features. Maintain code comments.
- **Version Control**: Commit frequently with descriptive messages. Use branches for features.

## AI Assistant Guidelines

- **Context Awareness**: Consider the XCOM-inspired mechanics when suggesting code. Reference existing widgets and patterns.
- **Code Suggestions**: Provide Lua code compatible with Love2D. Prefer functional, readable solutions.
- **Error Prevention**: Suggest fixes for common Lua/Love2D pitfalls (e.g., global variables, nil checks).
- **Performance Focus**: Highlight potential performance issues in suggestions.
- **Modularity**: Encourage reusable, modular code that supports the open-ended, moddable design.
- **Documentation**: Suggest adding comments or updating docs when implementing complex features.
- **Testing**: Recommend ways to test changes, such as running specific scenes using `lovec.exe` for console output or using the logger module for debug output.
- **Best Practices**: Always follow the code standards above. If unsure, check existing codebase or ask for clarification.

## Specific Game Systems

- **Geoscape**: World map navigation, UFO tracking, mission generation.
- **Battlescape**: Grid-based combat, line-of-sight, unit actions.
- **Base Management**: Facility construction, research trees, workforce allocation.
- **Economy**: Resource tracking, costs, salaries, invoicing.
- **Units and Aliens**: Stats, equipment, AI behavior.
- **UI/UX**: Consistent widgets, notifications, tooltips.

## Validation and Quality Assurance

- **Syntax Checking**: Use Lua syntax validators.
- **Runtime Testing**: Run the game to ensure no crashes or errors.
- **Performance Profiling**: Monitor frame rate and memory usage.
- **Code Reviews**: Ensure code follows standards and integrates well.
- **Playtesting**: Verify game mechanics work as intended.

## Resources

- Love2D Documentation: https://love2d.org/wiki/Main_Page
- Lua Reference Manual: https://www.lua.org/manual/5.1/
- Project Wiki: Refer to ALIENFALL_WIKI/ for game design details.
- Existing Codebase: Study LOVE/ folder for patterns and widgets.

This prompt ensures high-quality, consistent development of the AlienFall project using Love2D and Lua best practices.
