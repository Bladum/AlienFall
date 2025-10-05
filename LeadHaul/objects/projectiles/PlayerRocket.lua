local file = { priority = 0 }

local projectile = {
	friendly = true,
	damage = 30,
	speed = 10,
	size = .25,
	scale = .5,
	
	explosion = {
	radius = 1.2,
	damage = 50
	}
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/playerrocket.png" ), .25 )
end

projectile_playerrocket = projectile

return file