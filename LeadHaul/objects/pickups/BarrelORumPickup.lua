local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/barrelORum.png" ),
}

function pickup.init( self )
	self.sound = sound_barreldrink
end

function pickup.pickup( self )
	local amount = 50
	
	if Player.armor < Player.maxArmor then
		Player.armor = min( Player.maxArmor, Player.armor + amount )
		
		self:destroy()
	end
end


pickup_barrelorum = pickup

return file