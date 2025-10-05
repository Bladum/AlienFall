local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/machinegun.png" ),
	sound = Sound:new( "assets/audio/weaponpickup.wav", 1 ),
}

function pickup.init( self )
end

function pickup.pickup( self )
	local amount = 50
	local index = 1
	local weapon = "Machinegun"
	
	if Player.ammo[ index ].count < Player.ammo[ index ].maxCount or not contains( Player.weapons, weapon ) then
		Player.ammo[ index ].count = min( Player.ammo[ index ].maxCount, Player.ammo[ index ].count + amount )
		
		if not contains( Player.weapons, weapon ) then
			table.insert( Player.weapons, weapon )
		end
		
		Player:switchWeapon( 3 )
		
		self:destroy()
	end
end


pickup_machinegun = pickup

return file