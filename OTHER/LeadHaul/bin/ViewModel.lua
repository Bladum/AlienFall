local file = {priority = 10}

ViewModel = { }

local verts = {
{ 0, .5, -.5, 0,1 },
{ 0, .5, .5, 1,1 },
{ 0, -.5, .5, 1,0 },
{ 0, .5, -.5, 0,1 },
{ 0, -.5, -.5, 0,0 },
{ 0, -.5, .5, 1,0 }
}

function ViewModel:new( )
	local inst = Class:init( ViewModel )
	
	inst.flashScale = .003
	inst.flashModel = g3d.newModel( verts, i_error, nil, nil ,{ inst.flashScale,inst.flashScale,inst.flashScale }  )
	
	inst.meleeModel = mod_melee
	
	inst.fov = rad( 50 )
	inst.offset = { x = 0, y = 0, z = 0 }
	inst.rotation = { x = 0, y = 0, z = 0 }
	
	inst.afterKickOffset = 0
	inst.outOfAmmo = false
	
	return inst
end


function ViewModel.setOffset( self )
	local x,y,z = .0055,.0021,-.0025
	
	local playerSpeed = math.dist( Player.velocity.x,Player.velocity.z, 0,0 )
	local playerSpeedMult = playerSpeed / Player.maxSpeed

	-- idle sway
	local swayFactor = .00015
	x = x + cos( time * .7 ) * swayFactor * .3
	y = y + sin( time * .9 ) * swayFactor * .6 * ( 1 - playerSpeedMult )
	z = z + sin( time + .25 ) * swayFactor
	
	-- kick
	local kickFactor = .0012
	local kickPower = 1.5
	local attackTimerMax = Player.weapon.kickTime or Player.weapon.attackTimerMax
	local attack = min( 1, Player.attackTimer / attackTimerMax )
	local kick =  ( 1 - ( attack ^ kickPower ) ) * kickFactor * Player.weapon.kick
	x = x - kick
	
	-- after kick
	local afterKickXFactor = -.0010
	local afterKickYFactor = .00022
	local afterKickMax = .7
	if Player.attackTimer > attackTimerMax then
		self.prevAfterKickOffset = self.afterKickOffset

		local afterKick = Player.weapon.kickTime - Player.weapon.attackTimerMax + Player.weapon.kickCooldown
		local normKick = min( 1, ( attackTimerMax - Player.attackTimer ) / afterKick )
		local afterKickOffset = min( afterKickMax, sin( normKick * math.pi ) ) / afterKickMax
		
		self.afterKickOffset = afterKickOffset

		-- play shotgun cock sound effect
		if Player.weapon.cockSound and self.prevAfterKickOffset ~= self.afterKickOffset and self.prevAfterKickOffset < 0.0001 then
			Player.weapon.cockSound:setRelative( true )
		--	Player.weapon.cockSound:play()
		end
		if Player.weapon.unCockSound and self.prevAfterKickOffset ~= self.afterKickOffset and self.prevAfterKickOffset == 1 then
			Player.weapon.unCockSound:setRelative( true )
		--	Player.weapon.unCockSound:play()
		end
	end
	
	x = x + self.afterKickOffset * afterKickXFactor or 0
	y = y + self.afterKickOffset * afterKickYFactor or 0
	
	-- charge
	local charge = 0
	local chargeFactor = .0005
	local chargeShakeFactor = .000065
	local chargeShakeFrequency = 50
	if Player.weapon.chargeTime > 0 then
		charge = Player.chargeTimer / Player.weapon.chargeTime
	end
	
	x = x - charge * chargeFactor
	z = z + sin( time * chargeShakeFrequency ) * charge * chargeShakeFactor
	
	-- run bob
	local bobFactor = .00012
	local bobFrequency = 9
	local bob = sin( time * bobFrequency ) * bobFactor * playerSpeedMult
	y = y + bob
	
	-- switch weapon
	local switchFactor = .0016
	local switchOffset = sin( Player.switchWeaponTimer * math.pi ) * switchFactor
	y = y + switchOffset
	
	-- out of ammo
	local ammoOffset = 0.0006
	self.outOfAmmo = Player.ammo[Player.weapon.ammoIndex].count < Player.weapon.ammoCost and Player.attackTimer == Player.weapon.attackTimerMax
	
	if self.outOfAmmo then
		y = y + ammoOffset
	end
	
	-- melee swing
	local meleePower = .5
	local meleeTimer = abs( ( Player.meleeTimer ^ meleePower ) - .5 ) * 2
	local meleeZFactor = .001
	local meleeYFactor = -.001
	local melee = ( 1 - meleeTimer )
	
	z = z - melee * meleeZFactor
	y = y - melee * meleeYFactor
	
	-- move with player
	local moveFactor = .0002
	local dir = math.angle( 0,0, Player.velocity.x,Player.velocity.z ) + Player.cam.dir + rad( 90 )
	local dist = math.dist( 0,0, Player.velocity.x,Player.velocity.z ) / Player.maxSpeed
	local dx = cos( dir ) * dist * moveFactor
	local dz = sin( dir ) * dist * moveFactor
	
	x = x + dx
	z = z + dz
	
	-- add to offset
	self.offset.x = x
	self.offset.y = y
	self.offset.z = z
end

function ViewModel.setRotation( self )
	local x,y,z = 0,0,0

	-- idle sway
	
	-- kick
	
	-- after kick
	local afterKickXFactor = -rad( 7 )
	local afterKickZFactor = rad( 3 )
	x = x + self.afterKickOffset * afterKickXFactor
	z = z + self.afterKickOffset * afterKickZFactor
	
	-- run bob
	
	-- switch weapon
	local switchXFactor = rad( 30 )
	local switchZFactor = -rad( 80 )
	local switchOffset = sin( Player.switchWeaponTimer * math.pi )
	x = x + switchOffset * switchXFactor
	z = z + switchOffset * switchZFactor
	
	-- out of ammo
	local ammoOffsetX = rad( 15 )
	if self.outOfAmmo then
		x = x + ammoOffsetX
	end
	
	-- melee swing
	local meleePower = .5
	local meleeTimer = abs( ( Player.meleeTimer ^ meleePower ) - .5 ) * 2
	local meleeXFactor = rad( -0 )
	local meleeYFactor = rad( -15 )
	local melee = ( 1 - meleeTimer )
	
	x = x + melee * meleeXFactor
	y = y - melee * meleeYFactor
	
	-- add to rotation
	self.rotation.x = x
	self.rotation.y = y
	self.rotation.z = z
	
end

function ViewModel.updateMuzzleFlash( self )
	local flashTime = .15 * ( Player.weapon.muzzleFlashTime or 1 )

	if Player.attackTimer < Player.weapon.attackTimerMax then
		Player.weapon.muzzleFlash:play()
		
		Player.weapon.muzzleFlash.playTime = flashTime
		
		self.flashModel = Player.weapon.muzzleFlash.model
		
		local scale = self.flashScale * max( 0, 1 - ( Player.attackTimer / flashTime ) )
		self.flashModel:setScale( scale,scale,scale )
		
		self.flashModel:setRotation( 0,rad(90),0 )
	else
		self.flashModel:setScale(0,0,0)
	end
end

function ViewModel.updateMeleeModel( self )
	local x,y,z = 0, .0015, .00095
	local xr,yr,zr = rad(0),rad(0),rad(0)
	local meleeDist = .004
	local meleeXRot = rad(-10)
	local meleeYRot = rad(0)
	local timer = ( 1 - ( Player.meleeTimer * Player.meleeTime / .3 ) ) ^ .7
	
	x = x + timer * meleeDist
	xr = xr + timer * meleeXRot
	yr = yr + timer * meleeYRot
	
	self.meleeModel:setTranslation( x,y,z )
	self.meleeModel:setRotation( xr,yr,zr )
end

function ViewModel.update( self )
	self:setOffset()
	self:setRotation()
	self:updateMeleeModel()
	
	self:updateMuzzleFlash()
end


function ViewModel.setTranslation( self )
	g3d.camera.fov = self.fov
	g3d.camera.updateProjectionMatrix()

	g3d.camera.lookAt( 0,0,0, 1,0,0 )
	g3d.camera.up = {0,-1,0}
	
	-- apply offset
	local x,y,z = self.offset.x,self.offset.y,self.offset.z

	Player.weapon.model:setTranslation( x,y,z )
	self.flashModel:setTranslation( x + Player.weapon.muzzleOffset,y,z )
	
	local xr,yr,zr = 0,0,0
	
	-- apply rotation
	xr = self.rotation.x
	yr = self.rotation.y
	zr = self.rotation.z
	
	Player.weapon.model:setRotation( xr,yr,zr )
end

function ViewModel.draw( self )
	if Game.state == "playing" then
		self:setTranslation()
		
		Player.weapon.model:draw()
		self.flashModel:draw()
		self.meleeModel:draw()
	end
end


function file:init()
	mod_melee = g3d.newModel( "assets/models/knife.obj", "assets/textures/knife.png", nil,nil,{.0005,.0005,.0005} )
	mod_goldenMelee = g3d.newModel( "assets/models/knife.obj", "assets/textures/goldenKnife.png", nil,nil,{.0005,.0005,.0005} )

	ViewModel = ViewModel:new()
end

function file:update()
	ViewModel:update()
end

function file:draw()
	if Game.state == "playing" then
		ViewModel:draw()
	end
end

-- [[ RETURN ]] --
return file