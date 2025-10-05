local file = { priority = 0 }

local projectile = {
	friendly = false,
	damage = 7,
	speed = 10,
	size = .25,
	scale = .5
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/cooper.png" ), .25 )
end

projectile_cooper = projectile

return file