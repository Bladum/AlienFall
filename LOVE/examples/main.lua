-- Example usage of the simple GUI library

-- Add the GUI library paths to package.path so we can require modules
-- Support running from examples/ or LOVE/ directory
package.path = package.path .. ";../GUI/common/button/?.lua;../GUI/common/button/init.lua"
package.path = package.path .. ";./GUI/common/button/?.lua;./GUI/common/button/init.lua"

local gui = require("init")

local button
local checkbox
local radio1, radio2, radio3
local label
local radioGroup = {}

function love.load()
  -- Create a button
  button = gui.Button.new(100, 100, 100, 30, "Click Me", function()
    print("Button clicked!")
  end)

  -- Create a checkbox
  checkbox = gui.Checkbox.new(100, 150, 20, "Enable Feature", false, function(checked)
    print("Checkbox is now: " .. tostring(checked))
  end)

  -- Create radio buttons
  radio1 = gui.RadioButton.new(100, 200, 20, "Option 1", radioGroup, true, function(rb)
    print("Selected: " .. rb.text)
  end)
  radio2 = gui.RadioButton.new(100, 230, 20, "Option 2", radioGroup, false, function(rb)
    print("Selected: " .. rb.text)
  end)
  radio3 = gui.RadioButton.new(100, 260, 20, "Option 3", radioGroup, false, function(rb)
    print("Selected: " .. rb.text)
  end)

  table.insert(radioGroup, radio1)
  table.insert(radioGroup, radio2)
  table.insert(radioGroup, radio3)

  -- Create a label
  label = gui.Label.new(100, 50, "Simple GUI Demo")
end

function love.update(dt)
  button:update(dt)
  checkbox:update(dt)
  radio1:update(dt)
  radio2:update(dt)
  radio3:update(dt)
end

function love.draw()
  label:draw()
  button:draw()
  checkbox:draw()
  radio1:draw()
  radio2:draw()
  radio3:draw()
end

function love.mousepressed(x, y, mouseButton)
  if mouseButton == 1 then
    if button:mousepressed(x, y, mouseButton) then return end
    if checkbox:mousepressed(x, y, mouseButton) then return end
    if radio1:mousepressed(x, y, mouseButton) then return end
    if radio2:mousepressed(x, y, mouseButton) then return end
    if radio3:mousepressed(x, y, mouseButton) then return end
  end
end

function love.mousereleased(x, y, mouseButton)
  if mouseButton == 1 then
    button:mousereleased(x, y, mouseButton)
    checkbox:mousereleased(x, y, mouseButton)
    radio1:mousereleased(x, y, mouseButton)
    radio2:mousereleased(x, y, mouseButton)
    radio3:mousereleased(x, y, mouseButton)
  end
end
