--- Docstring Template for AlienFall Widget Library

--- This template defines the standard format for documentation in all widget files.

=== FILE-LEVEL DOCSTRING TEMPLATE ===

--[[
widgets/{subfolder}/{filename}.lua
{Short description of the widget/module}

{Detailed description of the widget's purpose and functionality.
Explain what it does and why it exists in the context of the game UI.}

PURPOSE:
- {Key purpose point 1}
- {Key purpose point 2}
- {Key purpose point 3}

KEY FEATURES:
- {Feature 1 with brief description}
- {Feature 2 with brief description}
- {Feature 3 with brief description}

@see widgets.core
@see {other relevant modules}
]]

=== METHOD-LEVEL DOCSTRING TEMPLATE ===

--- {Brief description of what the method does}
--- @param {paramName} {type} {description of parameter}
--- @param {paramName2} {type} {description of parameter}
--- @return {returnType} {description of return value}
function Class:methodName(paramName, paramName2)
    -- implementation
end

=== CONSTRUCTOR TEMPLATE ===

--- Creates a new {WidgetName} instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the widget
--- @param h number The height of the widget
--- @param {otherParams} {type} {description}
--- @return {WidgetName} A new widget instance
function WidgetName:new(x, y, w, h, otherParams)
    -- implementation
end

=== PRIVATE METHOD TEMPLATE ===

--- {Brief description} (private method)
--- @param {paramName} {type} {description}
--- @return {returnType} {description}
function WidgetName:_privateMethod(paramName)
    -- implementation
end

=== BEST PRACTICES ===

1. FILE-LEVEL DOCSTRINGS:
   - Always include the file path as first line
   - Use @module tag with full module path
   - Include PURPOSE section with 3-5 bullet points
   - Include KEY FEATURES section with main capabilities
   - Add @see references to related modules
   - Keep description focused on the widget's role in game UI

2. METHOD-LEVEL DOCSTRINGS:
   - Use --- (triple dash) for method comments
   - Start with brief description (one line)
   - Document all parameters with @param
   - Document return values with @return
   - For constructors, specify what gets created
   - For private methods, note "(private method)" in description

3. PARAMETER DOCUMENTATION:
   - Use Lua type names: number, string, table, boolean, function
   - For table parameters, describe structure if complex
   - For optional parameters, note in description

4. MARKDOWN FORMATTING IN DOCSTRINGS:
   - **Line Length**: Limit comment lines to 80 characters for readability. Break long descriptions into multiple lines.
   - **Lists**: Use bullet points (-) for lists in descriptions. Ensure proper indentation for nested items.
   - **Code Blocks**: Use fenced code blocks (```lua) for code examples in docstrings. Specify language for syntax highlighting.
   - **Links**: Use markdown link syntax [text](url) for references. Ensure links are valid and descriptive.
   - **Whitespace**: Use blank lines to separate sections within multi-line comments. Avoid excessive whitespace.
   - **Headings**: Avoid H1 (#) in docstrings; use plain text or simple formatting. Do not use H2+ as docstrings are not full documents.
   - **Inline Code**: Use backticks (`) for code references, variable names, or short code snippets.

5. CONSISTENCY:
   - All public methods must have docstrings
   - Private methods (_prefix) should have docstrings
   - Follow existing naming conventions
   - Keep descriptions clear and concise

6. EXAMPLES:
   - See existing files like core.lua, button.lua for reference
   - Maintain the professional, game-focused tone
   - Avoid overly technical jargon; focus on usability in game context
