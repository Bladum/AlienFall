local file = { priority = .1 }

mod_chargerifle = g3d.newModel( "assets/models/chargerifle.obj", "assets/textures/chargerifle.png", { 2,0,2 }, nil ,{ .00075,.00075,.00075 } )

local weapon = {
	name = "Chargerifle",
	model = mod_chargerifle,
	ammoIndex = 3,	-- energy
	ammoCost = 10,
	damage = 50,
	attackTimerMax = .65,
	kick = 2.2,
	aimOffset = 0,
	shotCount = 1,
	chargeTime = .45,
	penetrating = true,
	muzzleFlash = Animation:new( "assets/muzzleFlashes/chargerifle.png", .2 ),
	muzzleOffset = .004,
	muzzleFlashTime = 1.25,
	sound = Sound:new( "assets/audio/chargerifle.wav", 1, 0,0,0 ),
	chargeSound = Sound:new( "assets/audio/charge.wav", 1, 0,0,0 ),
	
	crosshair = {
		img = lg.newImage( "assets/hud/crosshairChargerifle.png" ),
		count = 4,
		angPosOffset = rad( 45 ),
		angRotOffset = math.pi,
		posOffset = 3
	},
}


weapon_chargerifle = weapon

return file