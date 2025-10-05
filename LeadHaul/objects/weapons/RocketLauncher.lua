local file = { priority = .1 }

mod_chargerifle = g3d.newModel( "assets/models/rocketlauncher.obj", "assets/textures/rocketlauncher.png", { 2,0,2 }, nil ,{ .0006,.0006,.0006 } )

local weapon = {
	name = "Cannon",
	model = mod_chargerifle,
	ammoIndex = 4,	-- explosives
	ammoCost = 1,
	damage = 50,
	attackTimerMax = .65,
	kick = 1.6,
	kickTime = .5,
	kickCooldown = .15,
	aimOffset = 0,
	shotCount = 1,
	chargeTime = 0,
	projectile = projectile_playerrocket,
	muzzleFlash = Animation:new( "assets/muzzleFlashes/rocketlauncher.png", .2 ),
	muzzleOffset = .003,
	sound = Sound:new( "assets/audio/cannon.wav", 1, 0,0,0 ),
	
	crosshair = {
		img = lg.newImage( "assets/hud/crosshairRocketlauncher.png" ),
		count = 4,
		angPosOffset = rad( 45 ),
		angRotOffset = math.pi,
		posOffset = 3
	},
}


weapon_rocketlauncher = weapon

return file