local file = { priority = 0 }

local projectile = {
	friendly = false,
	damage = 12,
	speed = 5,
	size = .25,
	scale = .5,
	homeSpeed = rad( 180 )
}

function projectile.init( self )
	self.anim = Animation:new( lg.newImage( "assets/projectiles/striker.png" ), .25 )
end

projectile_striker = projectile

return file