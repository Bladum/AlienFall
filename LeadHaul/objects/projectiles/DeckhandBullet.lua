local file = { priority = 0 }

local projectile = {
	friendly = false,
	damage = 10,
	speed = 9.5,
	size = .25,
	scale = .5
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/deckhand.png" ), .25 )
end

projectile_deckhand = projectile

return file