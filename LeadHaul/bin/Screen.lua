local file = {priority = -1}

Screen = { }

function Screen:new( )
	local inst = Class:init( Screen )
	
	inst.baseWidth = 1280
	inst.baseHeight = 720
	
	inst.width = 640 * 3
	inst.height = 360 * 3
	
	inst.canvas = lg.newCanvas( inst.width, inst.height )
	
	return inst
end


function Screen.setResolutionScale( self, scale )
	local baseW,baseH = 1920,1080
	self.width = baseW * scale
	self.height = baseH * scale

	self.canvas = lg.newCanvas( self.width, self.height )
end


function Screen.applySettings( self )
	lg.setCanvas( { self.canvas, depth = true } )
	lg.clear( 0,0,0,0 )
end

function Screen.update( self )
	
end


function Screen.draw( self )
	self:applySettings()
end


function file:init()
	Screen = Screen:new()
end

function file:update()
	Screen:update()
end

function file:draw()
	Screen:draw()
end

-- [[ RETURN ]] --
return file