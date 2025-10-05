local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/medPouch.png" )
}

function pickup.init( self )
	self.sound = sound_medpouch
end

function pickup.pickup( self )
	local amount = 10
	
	if Player.health < Player.maxHealth then
		Player.health = min( Player.maxHealth, Player.health + amount )
		
		self:destroy()
	end
end


pickup_medpouch = pickup

return file