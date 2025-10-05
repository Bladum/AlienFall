local file = { priority = 0 }

local particle = {
	timer = 1,
	timerDecrease = 1.3,
	scale = .5,
	riseSpeed = .5
}

function particle.init( self )
	self.anim = Animation:new( lg.newImage( "assets/particles/explosionSmoke.png" ), 1 / self.timerDecrease )
end

function particle.update( self )
	self.timer = max( 0, self.timer - self.timerDecrease * hdt )
	
	if self.timer < 1 then
		self.anim:play()
		self.sprite:applyAnimation( self.anim )
	end
	
	self:move( 0, - self.riseSpeed * hdt, 0 )
	
	if self.timer == 0 then
		self:destroy()
	end
end


particle_explosionSmoke = particle

return file