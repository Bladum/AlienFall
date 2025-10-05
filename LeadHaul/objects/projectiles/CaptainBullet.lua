local file = { priority = 0 }

local projectile = {
	friendly = false,
	damage = 8,
	speed = 13,
	size = .25,
	scale = .5
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/captainBullet.png" ), .25 )
end

projectile_captainbullet = projectile

return file