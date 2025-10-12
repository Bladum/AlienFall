local file = { priority = .1 }

local pickup = {
	img = lg.newImage( "assets/pickups/energy.png" ),
}

function pickup.init( self )
	self.sound = sound_ammopickup
end

function pickup.pickup( self )
	local amount = 50
	local index = 3
	
	if Player.ammo[ index ].count < Player.ammo[ index ].maxCount then
		Player.ammo[ index ].count = min( Player.ammo[ index ].maxCount, Player.ammo[ index ].count + amount )
		
		self:destroy()
	end
end



pickup_energy = pickup

return file