local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/explosives.png" ),
}

function pickup.init( self )
	self.sound = sound_ammopickup
end

function pickup.pickup( self )
	local amount = 4
	local index = 4
	
	if Player.ammo[ index ].count < Player.ammo[ index ].maxCount then
		Player.ammo[ index ].count = min( Player.ammo[ index ].maxCount, Player.ammo[ index ].count + amount )
		
		self:destroy()
	end
end


pickup_explosives = pickup

return file