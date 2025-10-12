local file = { priority = .1 }

mod_pistol = g3d.newModel( "assets/models/pistol.obj", "assets/textures/pistol.png", { 2,0,2 }, nil ,{ .001,.001,.001 } )

local weapon = {
	name = "Pistol",
	model = mod_pistol,
	ammoIndex = 1,	-- bullets
	ammoCost = 1,
	damage = 4,
	attackTimerMax = .2,
	kick = .8,
	aimOffset = rad( .5 ),
	shotCount = 1,
	chargeTime = 0,
	muzzleFlash = Animation:new( "assets/muzzleFlashes/pistol.png", .2 ),
	muzzleOffset = .0022,
	sound = Sound:new( "assets/audio/pistol.wav", 1, 0,0,0 ),
	
	crosshair = {
		img = lg.newImage( "assets/hud/crosshairPistol.png" ),
		count = 4,
		angPosOffset = rad( 45 ),
		angRotOffset = 0,
		posOffset = 1
	},
}


weapon_pistol = weapon

return file