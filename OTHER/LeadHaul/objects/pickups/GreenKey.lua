local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/greenKey.png" )
}

function pickup.init( self )
	self.keyItem = true
	self.sound = sound_keypickup
end

function pickup.pickup( self )
	local key = "green"
	
	if not Player:hasKey( key ) then
		Player:pickupKey( key )
	end
	
	for i, d in pairs( Door.list ) do
		d:checkPlayerKey()
		d:setTexture()
	end
	
	self:destroy()
end

pickup_greenkey = pickup

return file