# Widget Feature Analysis & Commonization Plan (`widgets/common`)

This document analyzes features implemented by each widget in `LOVE/widgets/common`,
checks whether the implementation matches the file-level docstring description, and
identifies common methods/behaviors that can be safely extracted into a shared mixin
or base module. It also proposes a small shared mixin implementation (`interactive_mixin.lua`)
that widgets can optionally use immediately.

Overview & goals
-----------------
- Verify each widget implements or can implement the features described in its header.
- Identify duplicate code (common methods, color setup, input handling, accessibility,
  validator/animation wiring) and propose shared modules/mixins.
- Provide a minimal shared `InteractiveMixin` that covers the most common interactive
  behavior: hover/pressed/focus tracking, tooltip helpers, accessibility label/hint.

Method used
-----------
- Read representative files under `LOVE/widgets/common` and collected constructors,
  public methods and recurring private helpers.
- For each widget, list core features (from docstring and code) and suggested additions
  to match the docstring's promise.

Per-widget synopsis (high level)
--------------------------------
- `button.lua`
  - Features present: styling variants, icons, loading state, animations, accessibility,
    validation hooks.
  - Improvements: ensure consistent `@param`/`@return` on all public methods; extract
    repeated `_setupColors` helper into shared `styled_mixin` when available.

- `label.lua`
  - Features present: wrapping, rich text flags, animation (typewriter), icon support.
  - Improvements: add explicit `@param` for private helpers; consider exposing a
    small `text_anim` helper mixin if other widgets also animate text.

- `textinput.lua` & `textarea.lua`
  - Features present: validation, autocomplete, masking, cursor logic (textarea),
    placeholder and styling.
  - Improvements: `AutoCompleteMixin` already used. Consider adding `InteractiveMixin`
    to unify hover/focus handling and `setTooltipWidget` usage.

- `listbox.lua`, `table.lua`, `dropdown.lua`, `combobox.lua`
  - Features present: selection, scrolling, virtualization in `table.lua`.
  - Improvements: selection-change event pattern is reused; extract a `Selectable` mixin
    that provides `selected`, `select()`, and `onSelect` wiring.

- `panel.lua`, `container.lua`, `tabcontainer.lua`, `tabwidget.lua`, `window.lua`, `dialog.lua`
  - Features present: child management, layout handling, tab management, window state.
  - Improvements: `Container` is the central base; add common method docstrings for
    `add`, `remove`, `forwardMouseEvent`. Consider a small `LayoutHelper` for common
    layout tasks if there is duplicate layout math across multiple containers.

- `scrollbar.lua`, `slider.lua`, `spinner.lua`, `progressbar.lua`
  - Features present: value handling, orientation, rendering helpers.
  - Improvements: many value-type widgets implement `setValue`, `getValue` and animation
    of value changes — create a `StatefulValue` mixin to centralize clamping, animation,
    and validation.

- `tooltip.lua`, `tooltip_manager.lua`
  - Features present: tooltip content, layout & drawing, manager singleton.
  - Improvements: toolbar and widgets call `core.setTooltipWidget`; ensure a single
    documented API is used across widgets. `TooltipManager` is lightweight — add a
    file-level header matching template.

- `validation.lua`
  - Features present: Validator class, common rules.
  - Improvements: Ensure each exported Validator method has `@return` annotations.

- `imagebutton.lua`, `radiobutton.lua`, `checkbox.lua`, `togglebutton.lua`
  - Features present: variations of interactive behavior with hover/press/toggle semantics.
  - Improvements: reuse `InteractiveMixin` for hover/press logic; extract common draw
    ordering for hover/press states where feasible.

Common methods and features found across multiple widgets
--------------------------------------------------------
- Lifecycle methods: `new`, `update(dt)`, `draw()`, `mousepressed`, `mousereleased`,
  `mousemoved`, `keypressed`, `textinput`.
- Styling/color helpers: `_setupColors(options)`, `_getStyleColors(style)`, `colors` table.
- Accessibility fields: `accessibilityLabel`, `accessibilityHint`, `core.announce(...)`.
- Tooltip usage: `core.setTooltipWidget(self)` in `update` when hovered or focused.
- State/value helpers: `setValue`, `getValue`, clamping and animation of value.
- Validation wiring: `validator`, `validationState`, `validationMessage`, `validate()` calls.
- Animation integration: calling `Animation.animateWidget` or `Animation.update`.

Proposed shared abstractions (priority order)
--------------------------------------------
1) InteractiveMixin (`interactive_mixin.lua`) — highest priority
   - Purpose: give widgets a consistent implementation for hover/pressed/focus,
     tooltip support, and accessibility helpers.
   - Use cases: Buttons, ImageButton, ToggleButton, CheckBox, RadioButton,
     List items, Tab headers.

2) StyledMixin / ColorHelper (`styled_mixin.lua`) — medium priority
   - Purpose: centralize `_setupColors` and `_getStyleColors` behavior and theme
     fallback logic.
   - Use cases: any widget with `options.colors` and `style`/`variant` fields.

3) StatefulValue mixin (`stateful_value.lua`) — medium priority
   - Purpose: unify `setValue/getValue`, clamping to `min/max`, animation, and
     onChange/onValueChange event handling.

4) Selectable mixin (`selectable_mixin.lua`) — low-medium priority
   - Purpose: unify single-selection and multi-selection APIs for ListBox/Table/Tree.

Minimal `InteractiveMixin` (implementation included)
--------------------------------------------------
The following file `interactive_mixin.lua` provides a lightweight, well-documented
mixin that many existing widgets can use immediately. It intentionally keeps a
small API surface to minimize required changes to existing code.

File: `interactive_mixin.lua`

```lua
local core = require("widgets.core")

local Interactive = {}

--- Attach interactive helpers to a widget
--- @param widget table The widget to attach to
function Interactive.init(widget)
    widget._interactive = widget._interactive or { hovered = false, pressed = false, focused = false }

    -- Helpers
    function widget:_setAccessibility(label, hint)
        self.accessibilityLabel = label or self.accessibilityLabel
        self.accessibilityHint = hint or self.accessibilityHint
    end

    function widget:_updateHover(mx, my)
        local inside = core.isInside(mx, my, self.x or 0, self.y or 0, self.w or 0, self.h or 0)
        self._interactive.hovered = inside
        return inside
    end

    function widget:isHovered()
        return self._interactive.hovered
    end

    function widget:isPressed()
        return self._interactive.pressed
    end

    function widget:_showTooltipWhenHovered()
        if self._interactive.hovered and self.tooltip and core.setTooltipWidget then
            core.setTooltipWidget(self)
        end
    end

    -- Default mousepressed/mousereleased helpers that widgets can call or override
    function widget:_mousepressed(x, y, button)
        if button ~= 1 then return false end
        if core.isInside(x, y, self.x or 0, self.y or 0, self.w or 0, self.h or 0) then
            self._interactive.pressed = true; return true
        end
        return false
    end

    function widget:_mousereleased(x, y, button)
        if button ~= 1 then return false end
        local handled = false
        if self._interactive.pressed and core.isInside(x, y, self.x or 0, self.y or 0, self.w or 0, self.h or 0) then
            -- treat as click
            if type(self.callback) == "function" then pcall(self.callback, self) end
            handled = true
        end
        self._interactive.pressed = false
        return handled
    end
end

return Interactive
```

Notes about adoption
--------------------
- Widgets can adopt the mixin by calling `Interactive.init(self)` in the constructor
  after setting `self.x/y/w/h` and `self.tooltip`/`self.callback` fields.
- This mixin avoids changing widget tables' metatables and is additive: widgets can
  still override `mousepressed`/`mousereleased` and call the mixin helpers.
- Later we can expand the mixin with `focus()` helpers, keyboard navigation glue,
  and ARIA-like accessibility helpers once the base is stable.

Suggested incremental rollout
---------------------------
1. Add `interactive_mixin.lua` (done) and update 2-3 low-risk widgets to call
   `Interactive.init(self)` in their constructors (e.g., `button.lua`, `imagebutton.lua`).
2. Run the widget tests in `LOVE/widgets/common/tests` and ensure no regressions.
3. Add `styled_mixin.lua` to centralize color logic and replace `_setupColors`
   in widgets that use it.
4. Gradually add `StatefulValue` and `Selectable` mixins where appropriate.

Next steps I can perform
-----------------------
- I can update `button.lua` and `imagebutton.lua` to invoke `Interactive.init(self)`
  and convert their existing press/hover code to use the mixin helpers.
- I can add a `styled_mixin.lua` and replace `_setupColors` in `button.lua`.

Files added by this task
-----------------------
- `LOVE/widgets/common/docstring_feature_analysis.md` (this file)
- `LOVE/widgets/common/interactive_mixin.lua` (small, practical mixin)

If you'd like, I will now apply the mixin to `button.lua` and `imagebutton.lua` as a
proof-of-concept and run the existing tests under `LOVE/widgets/common/tests`.
Tell me whether to proceed with the proof-of-concept refactor now.
