local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/vitalityChest.png" ),
	sound = Sound:new( "assets/audio/chestpickup.wav", 1 ),
}

function pickup.init( self )
end

function pickup.pickup( self )
	local fullVitality = Player.health == Player.maxHealth and Player.armor == Player.maxArmor
	
	if not fullVitality then
		Player.health = Player.maxHealth
		Player.armor = Player.maxArmor
		
		self:destroy()
	end
end


pickup_vitalitychest = pickup

return file