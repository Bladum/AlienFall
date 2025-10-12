local file = { priority = 0 }

local particle = {
	preShrinkTimer = 7,
	timer = 1,
	timerDecrease = .3,
	scale = .5,
	ySpeed = 0,
	xSpeed = 0,
	zSpeed = 0,
	gravity = 4,
	timerStart = false,
}

function particle.init( self )
	local dir = random() * math.pi * 2
	local horSpeed = random()
	self.xSpeed = cos( dir ) * horSpeed
	self.zSpeed = sin( dir ) * horSpeed

	self.ySpeed = -random() * .8 - .4
end

function particle.update( self )
	
	if self.timerStart then
		self.preShrinkTimer = max( 0, self.preShrinkTimer - hdt )
	end
	if self.preShrinkTimer == 0 then
		self.timer = max( 0, self.timer - self.timerDecrease * hdt )
		self.sprite:setScale( min( 1, self.timer ) * self.scale )
	end
	
	self.ySpeed = self.ySpeed + self.gravity * hdt
	
	self.y = self.y + self.ySpeed * hdt
	self:move( self.xSpeed * hdt,self.ySpeed * hdt,self.zSpeed * hdt )
	
	if self.y > 0 then
		self.y = 0
		self.ySpeed = -self.ySpeed * .5
		self.xSpeed = self.zSpeed * .5
		self.zSpeed = self.xSpeed * .5
		
		self.timerStart = true
	end
	
	if self.timer == 0 then
		self:destroy()
	end
	
	self.anim:play()
	self.sprite:applyAnimation( self.anim )
end


particle_gib = particle

return file