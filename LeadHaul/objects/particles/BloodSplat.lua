local file = { priority = 0 }

local particle = {
	timer = 1,
	timerDecrease = 3,
	scale = .75
}

function particle.init( self )
	self.anim = Animation:new( lg.newImage( "assets/particles/bloodSplat.png" ), 1 / self.timerDecrease )
	self.sprite.model.fillColor = { 1, 230 / 255, 90 / 255, 1 }
end

function particle.update( self )
	self.timer = max( 0, self.timer - self.timerDecrease * hdt )
	
	self.anim:play()
	self.sprite:applyAnimation( self.anim )
	
	if self.timer == 0 then
		self:destroy()
	end
end


particle_bloodsplat = particle

return file