local file = { priority = 0 }

local particle = {
	timer = 1,
	timerDecrease = 1,
	scale = .5,
	gravity = 5,
}

function particle.init( self )
	self.anim = Animation:new( lg.newImage( "assets/particles/bloodGib.png" ), 1 / self.timerDecrease )

	local dir = random() * math.pi * 2
	self.velocity.x = cos( dir )
	self.velocity.z = sin( dir )

	self.velocity.y = random() * -.6 - .9
end

function particle.update( self )

	self.timer = max( 0, self.timer - self.timerDecrease * hdt )
	
	self.velocity.y = self.velocity.y + self.gravity * hdt

	if self.y > 1 or self.timer == 0 then
		self:destroy()
	end
	
	self:move( self.velocity.x * hdt,self.velocity.y * hdt,self.velocity.z * hdt )

	self.anim:play()
	self.sprite:applyAnimation( self.anim )
	self.sprite:setScale( self.timer * self.scale )
end


particle_bloodGib = particle

return file