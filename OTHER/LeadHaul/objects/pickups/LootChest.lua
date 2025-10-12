local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/lootChest.png" ),
	sound = Sound:new( "assets/audio/chestpickup.wav", 1 ),
}

function pickup.init( self )
end

function pickup.pickup( self )
	local amount = 10
	
	local fullAmmo = true
	for i, a in pairs( Player.ammo ) do
		if a.count < a.maxCount then
			fullAmmo = false
		end
	end
	
	if not fullAmmo then
		for i, a in pairs( Player.ammo ) do
			a.count = min( floor ( a.count + a.maxCount * .2 ), a.maxCount )
		end
		
		self:destroy()
	end
end


pickup_lootchest = pickup

return file