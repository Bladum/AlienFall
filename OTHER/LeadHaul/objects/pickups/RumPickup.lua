local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/rum.png" ),
}

function pickup.init( self )
	self.sound = sound_drink
end

function pickup.pickup( self )
	local amount = 5
	
	if Player.armor < Player.maxArmor then
		Player.armor = min( Player.maxArmor, Player.armor + amount )
		
		self:destroy()
	end
end


pickup_rum = pickup

return file