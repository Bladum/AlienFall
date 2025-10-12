local file = { priority = 0 }

local pickup = {
	img = lg.newImage( "assets/pickups/goldenKnife.png" )
}

function pickup.init( self )
	self.magical = true
	self.sound = sound_exoticpickup
end

function pickup.pickup( self )
	
	Player:setGoldenMelee( true )
	self:destroy()
end


pickup_goldenMelee = pickup

return file