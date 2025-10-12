local file = { priority = 0 }

local particle = {
	timer = 1,
	timerDecrease = 2.2,
	scale = .75
}

function particle.init( self )
	self.anim = Animation:new( lg.newImage( "assets/particles/explosionFire.png" ), 1 / self.timerDecrease )
end

function particle.update( self )
	self.timer = max( 0, self.timer - self.timerDecrease * hdt )
	
	if self.timer < 1 then
		self.anim:play()
		self.sprite:applyAnimation( self.anim )
	end
	
	if self.timer == 0 then
		self:destroy()
	end
end


particle_explosionFire = particle

return file