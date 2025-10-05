local M = require("widgets.common.autocomplete_mixin")

local obj = {}
M.init(obj)
print("visible initially", obj:isAutoCompleteVisible())
obj:showAutoComplete({ "one", "two" })
print("visible after show", obj:isAutoCompleteVisible())
obj:hideAutoComplete()
print("visible after hide", obj:isAutoCompleteVisible())
return obj
