local file = { priority = 0 }

local projectile = {
	friendly = false,
	damage = 10,
	speed = 7,
	size = .25,
	scale = .5
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/boatswain.png" ), .25 )
end

projectile_boatswain = projectile

return file