local AutoComplete = {}

--- Mixin to provide simple autocomplete behavior for text-like widgets.
--- Widgets using this mixin should implement: getText(), setSuggestion(list), showSuggestions(list)

local M = {}

--- Initialize autocomplete state on a widget
--- @param widget table The widget to attach autocomplete to
function M.init(widget)
  widget._autocomplete = widget._autocomplete or { suggestions = {}, visible = false }

  function widget:showAutoComplete(list)
    self._autocomplete.suggestions = list or {}
    self._autocomplete.visible = (#self._autocomplete.suggestions > 0)
    if self.showSuggestions then self:showSuggestions(self._autocomplete.suggestions) end
  end

  function widget:hideAutoComplete()
    self._autocomplete.visible = false
    if self.hideSuggestions then self:hideSuggestions() end
  end

  function widget:isAutoCompleteVisible()
    return self._autocomplete.visible
  end
end

return M
