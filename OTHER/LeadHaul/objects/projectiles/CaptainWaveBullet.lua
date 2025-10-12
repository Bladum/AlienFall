local file = { priority = 0 }

local projectile = {
	friendly = false,
	damage = 14,
	speed = 6,
	size = .25,
	scale = .5
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/captainWave.png" ), .25 )
end

projectile_captainwavebullet = projectile

return file