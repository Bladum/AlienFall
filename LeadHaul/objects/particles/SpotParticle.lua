local file = { priority = 0 }

local particle = {
	timer = 1,
	timerDecrease = 3,
	scale = .5
}

function particle.init( self )
	self.anim = Animation:new( lg.newImage( "assets/particles/playerSpotted.png" ), 1 / self.timerDecrease )
end

function particle.update( self )
	self.timer = max( 0, self.timer - self.timerDecrease * hdt )
	
	self.anim:play()
	self.sprite:applyAnimation( self.anim )
	
	if self.timer == 0 then
		self:destroy()
	end
end


particle_playerSpotted = particle

return file