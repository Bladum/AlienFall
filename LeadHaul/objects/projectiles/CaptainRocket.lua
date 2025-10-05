local file = { priority = 0 }

local projectile = {
	friendly = false,
	damage = 5,
	speed = 7,
	size = .25,
	scale = .5,

	explosion = {
	radius = .8,
	damage = 20
	}
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/captainRocket.png" ), .25 )
end

projectile_captainrocket = projectile

return file