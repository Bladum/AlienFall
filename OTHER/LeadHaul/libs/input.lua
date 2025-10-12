local file = {priority = -1}

-- [[ INIT ]] --
function file:init()
	

	presses = {}
	releases = {}
	textInput = {}
	
	mouse = { x = 0,y = 0, worldX = 0,worldY = 0 }
	
	Input = newInputSystem()
end

-- [[ UPDATE ]] --
function file:update()
	Input:run()
end

local function _clearInput()
	--clear presses
	for i,p in pairs(presses) do
		if p.firstFrame then
			table.remove(presses, i)
		else
			p.firstFrame = true
		end
	end
	
	--clear releases
	for i,r in pairs(releases) do
		if r.firstFrame then
			table.remove(releases, i)
		else
			r.firstFrame = true
		end
	end
	
	--clear text input
	for i,t in pairs(textInput) do
		if t.firstFrame then
			table.remove(textInput, i)
		else
			t.firstFrame = true
		end
	end
end

local function _updateMouse( self )
	local x,y = lm.getPosition()
	
	mouse.x = x
	mouse.y = y
	
	mouse.worldX = x
	mouse.worldY = y
end

-- [ OTHER ] --
local function _isDown( self, key )
	if key == "m1" then
		return lm.isDown(1)
	end
	if key == "m2" then
		return lm.isDown(2)
	end
	if key == "m3" then
		return lm.isDown(3)
	end
	
	return lk.isDown(key)
end

local function _isPressed( self, key )
	for i, p in pairs(presses) do
		local p = presses[i]
		if p.key == key then
			return true
		end
	end
	
	return false
end

local function _getPresses()
	return presses
end

local function _isReleased( self, key )
	for i = 1, #releases do
		local r = releases[i]
		
		if r.key == key then
			return true
		end
	end
	
	return false
end

local function _getWheelDelta( self )
	local val = self.wheel.y
	self.wheel.y = 0
	return val
end

local function _getTextInput( self )
	return textInput
end

function love.keypressed(key, scancode, isrepeat)
	table.insert(presses, {key = key, id = "keyboard"})
end

function love.mousepressed(x, y, button, istouch)
	table.insert(presses, {key = "m"..button, id = "mouse"})
end

function love.keyreleased(key)
   table.insert(releases, {key = key})
end

function love.mousereleased(x, y, button)
   table.insert(releases, {key = "m"..button})
end

function love.textinput( t )
    table.insert( textInput, {key = t} )
end

function love.wheelmoved( x,y )
	if y > 0 then
		table.insert(presses, {key = "wheelUp", id = "wheel"})
	end
	if y < 0 then
		table.insert(presses, {key = "wheelDown", id = "wheel"})
	end
end


-- // UPDATE \\ --

local function _run( self )
	_clearInput( self )
	_updateMouse( self )
end

-- // DRAW \\ --

-- // CONSTRUCTOR \\ --
function newInputSystem( )
	local input = {}
	
	-- fields --

	-- getter and setters --
	
	-- public functions --
	input.run = _run
	
	input.isDown = _isDown
	input.isPressed = _isPressed
	input.getPresses = _getPresses
	input.isReleased = _isReleased
	input.getTextInput = _getTextInput
	input.getWheelDelta = _getWheelDelta
	
	return input
end

-- [[ RETURN ]] --
return file