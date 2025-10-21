# ListBox Widget

Scrollable list for selecting items from always-visible options.

## Purpose

ListBox displays a scrollable list of selectable items. Unlike dropdown, all items (or as many as fit) are always visible. Used for file browsers, inventory lists, unit rosters, settings lists, and any scenario where users need to see multiple options simultaneously.

## Constructor

```lua
local ListBox = require("widgets.navigation.listbox")
local listbox = ListBox.new(x, y, width, height)
```

### Parameters

- **x** (number): X position in pixels (multiple of 24)
- **y** (number): Y position in pixels (multiple of 24)
- **width** (number): ListBox width in pixels (multiple of 24)
- **height** (number): ListBox height in pixels (multiple of 24)

### Returns

- **ListBox**: New listbox instance

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | table | {} | Array of item strings or tables |
| `selectedIndex` | number | 0 | Currently selected item index (0 = none) |
| `scroll Offset` | number | 0 | First visible item index for scrolling |
| `itemHeight` | number | 24 | Height per item in pixels |
| `multiSelect` | boolean | false | Allow multiple selections |
| `selectedItems` | table | {} | Set of selected indices (multiSelect only) |
| `onChange` | function | nil | Callback when selection changes |
| `backgroundColor` | string | "background" | Theme color for background |
| `selectedColor` | string | "primary" | Theme color for selected item |
| `hoverColor` | string | "backgroundLight" | Theme color for hover |

## Methods

### setItems(items)

Set the list of items to display.

```lua
listbox:setItems({"Alpha", "Beta", "Gamma", "Delta"})

-- Or with data objects
listbox:setItems({
    {id = 1, name = "Item 1", value = 100},
    {id = 2, name = "Item 2", value = 200}
})
```

**Parameters:**
- items (table): Array of strings or data tables

### getSelectedItem()

Get currently selected item.

```lua
local item = listbox:getSelectedItem()  -- Returns "Alpha"
```

**Returns:**
- any: Selected item (string or table), or nil if none

### getSelectedIndex()

Get index of selected item.

```lua
local index = listbox:getSelectedIndex()  -- Returns 1
```

**Returns:**
- number: Selected index (0 if none)

### setSelectedIndex(index)

Set selection by index.

```lua
listbox:setSelectedIndex(3)  -- Select third item
```

**Parameters:**
- index (number): Item index to select (1-based)

### getSelectedItems()

Get all selected items (multiSelect mode).

```lua
local items = listbox:getSelectedItems()  -- Returns array
```

**Returns:**
- table: Array of selected items

### clearSelection()

Clear all selections.

```lua
listbox:clearSelection()
```

### addItem(item)

Add single item to end of list.

```lua
listbox:addItem("Epsilon")
```

**Parameters:**
- item (any): Item to add

### removeItem(index)

Remove item by index.

```lua
listbox:removeItem(2)  -- Remove second item
```

**Parameters:**
- index (number): Item index to remove (1-based)

### setOnChange(callback)

Set callback for selection changes.

```lua
listbox:setOnChange(function(item, index)
    print("Selected:", item, "at", index)
end)
```

**Parameters:**
- callback (function): Function called with (item, index)

### scrollTo(index)

Scroll to make item visible.

```lua
listbox:scrollTo(10)  -- Scroll to 10th item
```

**Parameters:**
- index (number): Item index to scroll to

### mousepressed(x, y, button)

Handle mouse click events.

```lua
listbox:mousepressed(x, y, 1)
```

**Parameters:**
- x (number): Mouse X coordinate
- y (number): Mouse Y coordinate
- button (number): Mouse button (1=left)

### wheelmoved(x, y)

Handle mouse wheel scrolling.

```lua
listbox:wheelmoved(0, -1)  -- Scroll down
```

**Parameters:**
- x (number): Horizontal scroll (unused)
- y (number): Vertical scroll (-1=down, 1=up)

### keypressed(key)

Handle keyboard navigation.

```lua
listbox:keypressed("down")  -- Move selection down
```

**Parameters:**
- key (string): Key name ("up", "down", "home", "end", "return")

### draw()

Render listbox and items.

```lua
listbox:draw()
```

## Events

### onChange(item, index)

Triggered when selection changes.

```lua
listbox:setOnChange(function(item, index)
    if item then
        loadFile(item)
    end
end)
```

**Parameters:**
- item (any): Selected item
- index (number): Selected index

## Complete Example

```lua
local ListBox = require("widgets.navigation.listbox")

-- File browser
local fileList = ListBox.new(24, 24, 288, 600)
fileList:setItems(love.filesystem.getDirectoryItems("maps"))

fileList:setOnChange(function(filename, index)
    print("Selected file:", filename)
    loadMap(filename)
end)

-- Unit roster
local unitList = ListBox.new(336, 24, 240, 600)
local units = {
    {name = "Soldier 1", class = "Assault", hp = 100},
    {name = "Soldier 2", class = "Sniper", hp = 85},
    {name = "Soldier 3", class = "Heavy", hp = 120}
}
unitList:setItems(units)

-- Multi-select inventory
local inventory = ListBox.new(600, 24, 240, 600)
inventory.multiSelect = true
inventory:setItems({"Rifle", "Pistol", "Grenade", "Med Kit"})

-- In love.mousepressed(x, y, button)
function love.mousepressed(x, y, button)
    fileList:mousepressed(x, y, button)
    unitList:mousepressed(x, y, button)
    inventory:mousepressed(x, y, button)
end

-- In love.wheelmoved(x, y)
function love.wheelmoved(x, y)
    fileList:wheelmoved(x, y)
    unitList:wheelmoved(x, y)
    inventory:wheelmoved(x, y)
end

-- In love.keypressed(key)
function love.keypressed(key)
    fileList:keypressed(key)
end

-- In love.draw()
function love.draw()
    fileList:draw()
    unitList:draw()
    inventory:draw()
end
```

## Grid Examples

```lua
-- Sidebar list (10×25 cells = 240×600 pixels)
local sidebar = ListBox.new(24, 24, 240, 600)

-- Wide list (12×10 cells = 288×240 pixels)
local wide = ListBox.new(24, 24, 288, 240)

-- Full height (12×29 cells = 288×696 pixels)
local tall = ListBox.new(24, 24, 288, 696)

-- Each item is 24px tall (1 grid cell)
-- Visible items = height / 24
```

## File Browser Example

```lua
local browser = ListBox.new(24, 24, 384, 600)

function loadDirectory(path)
    local items = love.filesystem.getDirectoryItems(path)
    table.insert(items, 1, "..")  -- Add parent directory
    browser:setItems(items)
end

browser:setOnChange(function(item, index)
    if item == ".." then
        -- Go up one directory
        currentPath = getParentPath(currentPath)
    elseif love.filesystem.getInfo(currentPath .. "/" .. item).type == "directory" then
        -- Enter directory
        currentPath = currentPath .. "/" .. item
    else
        -- Load file
        loadFile(currentPath .. "/" .. item)
    end
    loadDirectory(currentPath)
end)

loadDirectory(".")
```

## Custom Item Rendering

```lua
-- Override draw to show custom content
function listbox:drawItem(item, index, x, y, width, height)
    -- Background
    if index == self.selectedIndex then
        Theme.setColor("primary")
    elseif index == self.hoverIndex then
        Theme.setColor("backgroundLight")
    else
        Theme.setColor("background")
    end
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Custom content for unit
    if type(item) == "table" then
        Theme.setColor("text")
        love.graphics.print(item.name, x + 4, y + 4)
        love.graphics.print(item.class, x + 150, y + 4)
        
        -- HP bar
        local hpPercent = item.hp / item.maxHp
        love.graphics.setColor(hpPercent > 0.5 and 0 or 1, hpPercent, 0)
        love.graphics.rectangle("fill", x + width - 54, y + 4, 50 * hpPercent, 16)
    end
end
```

## Search/Filter Example

```lua
local allItems = {"Apple", "Banana", "Cherry", "Date", "Elderberry"}
local listbox = ListBox.new(24, 72, 192, 240)
local searchText = ""

function updateFilter()
    local filtered = {}
    for _, item in ipairs(allItems) do
        if item:lower():find(searchText:lower(), 1, true) then
            table.insert(filtered, item)
        end
    end
    listbox:setItems(filtered)
end

function love.textinput(text)
    searchText = searchText .. text
    updateFilter()
end

function love.keypressed(key)
    if key == "backspace" then
        searchText = searchText:sub(1, -2)
        updateFilter()
    end
end

updateFilter()
```

## Multi-Select Operations

```lua
local listbox = ListBox.new(24, 24, 240, 600)
listbox.multiSelect = true
listbox:setItems(units)

-- Select all button
local btnSelectAll = Button.new(288, 24, 96, 48, "Select All")
btnSelectAll:setOnClick(function()
    listbox.selectedItems = {}
    for i = 1, #listbox.items do
        listbox.selectedItems[i] = true
    end
end)

-- Delete selected button
local btnDelete = Button.new(288, 96, 96, 48, "Delete")
btnDelete:setOnClick(function()
    local selected = listbox:getSelectedItems()
    for i = #selected, 1, -1 do
        listbox:removeItem(selected[i])
    end
    listbox:clearSelection()
end)
```

## Sorting Example

```lua
local sortKey = "name"
local sortAscending = true

function sortList()
    table.sort(items, function(a, b)
        if sortAscending then
            return a[sortKey] < b[sortKey]
        else
            return a[sortKey] > b[sortKey]
        end
    end)
    listbox:setItems(items)
end

-- Sort buttons
local btnSortName = Button.new(24, 648, 96, 48, "Name")
btnSortName:setOnClick(function()
    sortKey = "name"
    sortAscending = not (sortKey == sortKey and sortAscending)
    sortList()
end)
```

## See Also

- [Dropdown](dropdown.md) - Collapsible selection menu
- [Table](table.md) - Multi-column data grid
- [ScrollBox](scrollbox.md) - Scrollable container
- [ComboBox](combobox.md) - Dropdown with search
