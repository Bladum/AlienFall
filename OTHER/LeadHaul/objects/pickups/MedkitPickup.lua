local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/medkit.png" )
}

function pickup.init( self )
	self.sound = sound_medkit
end

function pickup.pickup( self )
	local amount = 35
	
	if Player.health < Player.maxHealth then
		Player.health = min( Player.maxHealth, Player.health + amount )
		
		self:destroy()
	end
end


pickup_medkit = pickup

return file