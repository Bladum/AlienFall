local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/redKey.png" )
}

function pickup.init( self )
	self.keyItem = true
	self.sound = sound_keypickup
end

function pickup.pickup( self )
	local key = "red"
	
	if not Player:hasKey( key ) then
		Player:pickupKey( key )
	end
	
	for i, d in pairs( Door.list ) do
		d:checkPlayerKey()
		d:setTexture()
	end
	
	self:destroy()
end

pickup_redkey = pickup

return file