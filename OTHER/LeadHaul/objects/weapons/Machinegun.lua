local file = { priority = .1 }

mod_machinegun = g3d.newModel( "assets/models/machinegun.obj", "assets/textures/machinegun.png", { 2,0,2 }, nil ,{ .001,.001,.001 } )

local weapon = {
	name = "Machinegun",
	model = mod_machinegun,
	ammoIndex = 1,	-- bullets
	ammoCost = 1,
	damage = 5,
	attackTimerMax = .1,
	kick = .7,
	aimOffset = rad( 2 ),
	shotCount = 1,
	chargeTime = 0,
	muzzleFlash = Animation:new( "assets/muzzleFlashes/machinegun.png", .2 ),
	muzzleOffset = .0033,
	sound = Sound:new( "assets/audio/machinegun.wav", 1, 0,0,0 ),
	
	crosshair = {
		img = lg.newImage( "assets/hud/crosshairMachinegun.png" ),
		count = 4,
		angPosOffset = rad( 45 ),
		angRotOffset = 0,
		posOffset = 0
	},
}


weapon_machinegun = weapon

return file