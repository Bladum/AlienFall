local file = { priority = .1 }

mod_shotgun = g3d.newModel( "assets/models/shotgun.obj", "assets/textures/shotgun.png", { 2,0,2 }, nil ,{ .0006,.0006,.0006 } )

local weapon = {
	name = "Shotgun",
	model = mod_shotgun,
	ammoIndex = 2,	-- shells
	ammoCost = 1,
	damage = 4.5,
	attackTimerMax = .75,
	kick = 1.5,
	aimOffset = rad( 5.5 ),
	shotCount = 8,
	chargeTime = 0,
	kickTime = .25,
	kickCooldown = .13,
	muzzleFlash = Animation:new( "assets/muzzleFlashes/shotgun.png", .2 ),
	muzzleOffset = .003,
	sound = Sound:new( "assets/audio/shotgun.wav", 1, 0,0,0 ),
	cockSound = Sound:new( "assets/audio/cockshotgun1.wav", 1, 0,0,0 ),
	unCockSound = Sound:new( "assets/audio/cockshotgun2.wav", 1, 0,0,0 ),
	
	crosshair = {
		img = lg.newImage( "assets/hud/crosshairShotgun.png" ),
		count = 8,
		angPosOffset = rad( 45 ),
		angRotOffset = 0,
		posOffset = 0
	},
}


weapon_shotgun = weapon

return file