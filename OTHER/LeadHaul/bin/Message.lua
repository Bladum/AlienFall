local file = {priority = 10}

Message = { list = {} }

function Message:new( str, timer )
	local inst = Class:init( Message )
	
	inst.str = str
	inst.timer = timer or 4
	
	table.insert( Message.list, inst )
	
	return inst
end


function Message.dissapear( self )
	self.timer = max( 0, self.timer - hdt )
	
	if self.timer == 0 then
		self:destroy()
	end
end

function Message.update( self )
	self:dissapear()
end


function Message.destroy( self )		
	removeFromTable( Message.list, self )
end


function file:init()
end

local function _updateMessages()
	for i, m in pairs( Message.list ) do
		m:update()
	end
end

function file:update()
	
	_updateMessages()
	
end

local function _drawMessages()
	local w,h = Screen.width,Screen.height
	local scaleX = Screen.width / Screen.baseWidth * 2
	local scaleY = Screen.height / Screen.baseHeight * 2
	local spacing = 14 * scaleY
	
	for i, m in pairs( Message.list ) do
		local y = ( i - 1 ) * spacing + 10
		local alpha = min( 1, m.timer )
		
		lg.setColor( 1,1,1, alpha )
		
		lg.printf( m.str, 0, y, w / scaleX, "center", 0, scaleX,scaleY )
	end
end

function file:draw()
	_drawMessages()
end

-- [[ RETURN ]] --
return file