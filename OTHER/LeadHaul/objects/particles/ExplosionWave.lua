local file = { priority = 0 }

local particle = {
	timer = 1,
	timerDecrease = 1.5,
	scale = 0,
	maxScale = .5,
	riseSpeed = .5,
	speed = 3
}

function particle.init( self )
	self.anim = Animation:new( lg.newImage( "assets/particles/explosionWave.png" ), 1 / self.timerDecrease )
end

function particle.update( self )
	self.timer = max( 0, self.timer - self.timerDecrease * hdt )
	
	self.scale = min( 1, self.timer ) * self.maxScale
	self.sprite:setScale( self.scale )
	
	if self.timer < 1 then
		self.anim:play()
		self.sprite:applyAnimation( self.anim )
		
		self:move(
		self.velocity.x * self.speed * hdt,
		self.velocity.y * self.speed * hdt,
		self.velocity.z * self.speed * hdt
		)
	end
	
	if self.timer == 0 then
		self:destroy()
	end
end


particle_explosionWave = particle

return file