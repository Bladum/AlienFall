local file = {priority = 0}

ProximityMessage = { list = {} }

function ProximityMessage:new( msg, x,z, radius )
	local inst = Class:init( ProximityMessage, Entity, { x,0,z } )
	
	inst.radius = radius or 2
	inst.messageString = msg
	inst.sound = Sound:new( "assets/audio/helpclick.wav" )
	inst.sound:setRelative( true )

	table.insert( ProximityMessage.list, inst )
	
	return inst
end


function ProximityMessage.show( self )
	if self:dist( Player ) < self.radius then
		Message:new( self.messageString, 7 )
		self.sound:play()
		self:destroy()
	end
end

function ProximityMessage.update( self )
	self:show()
end


function ProximityMessage.destroy( self )
	Entity.destroy( self )
	
	removeFromTable( ProximityMessage.list, self )
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file