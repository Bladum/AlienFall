local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/shotgun.png" ),
	sound = Sound:new( "assets/audio/weaponpickup.wav", 1 ),
}

function pickup.init( self )
end

function pickup.pickup( self )
	local amount = 10
	local index = 2
	local weapon = "Shotgun"
	
	if Player.ammo[ index ].count < Player.ammo[ index ].maxCount or not contains( Player.weapons, weapon ) then
		Player.ammo[ index ].count = min( Player.ammo[ index ].maxCount, Player.ammo[ index ].count + amount )
		
		if not contains( Player.weapons, weapon ) then
			table.insert( Player.weapons, weapon )
		end
		
		Player:switchWeapon( 2 )
		
		self:destroy()
	end
end


pickup_shotgun = pickup

return file