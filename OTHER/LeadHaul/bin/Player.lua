local file = {priority = 0}

Player = {}

function Player:new( )
	local inst = Class:init( Player, Pawn, { 3,0,3 } )
	
	inst.cam = {
	eyeLevel = .495,
	height = .5,
	dir = 0,
	pitch = 0,
	tilt = 0,
	fov = rad( 90 )
	}
	
	inst.weapon = weapon_pistol
	
	inst.health = 100
	inst.maxHealth = 100
	inst.armor = 0
	inst.maxArmor = 100
	inst.armorMult = .33
	
	inst.isPlayer = true
	inst.friction = 10
	inst.acceleration = 15 + inst.friction
	inst.maxSpeed = 3.5
	inst.velocity = { x = 0, y = 0, z = 0 }
	inst.gravity = 5
	
	inst.stepTimer = 0
	inst.stepTimerMax = .25
	inst.stepSound = Sound:new( "assets/audio/footstep.wav", .14 )
	inst.stepSound:setRelative( true )

	inst.hitSound = Sound:new( "assets/audio/playerdamage.wav", 1 )
	inst.hitSound:setRelative( true )
	
	inst.attackTimer = 0
	inst.chargeTimer = 0
	inst.switchWeaponTimer = 0
	inst.switchWeaponTimerMax = .5
	inst.nextWeapon = inst.weapon
	inst.weaponIndex = 1
	
	inst.meleeTimer = 0
	inst.meleeTimerMax = 1
	inst.meleeTime = .4
	inst.meleeDir = 0
	inst.meleeSpeed = 0
	inst.meleeSpeedMax = 3.5
	inst.meleeDeacceleration = 8
	inst.meleeRange = .5
	inst.meleeDamage = 10
	inst.meleeJump = -.7
	inst.meleeGolden = false
	inst.meleeGoldenDamage = 80
	inst.meleeGoldenTime = .55
	inst.meleeSound = Sound:new( "assets/audio/melee.wav", 1 )
	inst.meleeSound:setRelative( true )
	
	inst.ammo = {
	{ name = "bullets", count = 300, maxCount = 300 },
	{ name = "shells", count = 50, maxCount = 50 },
	{ name = "energy", count = 300, maxCount = 300 },
	{ name = "explosives", count = 30, maxCount = 30 }
	}
	
	inst.weapons = {
	"Pistol",
	}
	
	inst.keys = {}
	
	return inst
end


function Player.hasKey( self, key )
	for i, k in pairs( self.keys ) do
		if k == key then
			return k
		end
	end
	
	return false
end

function Player.pickupKey( self, key )
	table.insert( self.keys, key )
end

function Player.setGoldenMelee( self, golden )
	self.meleeGolden = golden
	
	if golden then
		ViewModel.meleeModel = mod_goldenMelee
	else
		ViewModel.meleeModel = mod_melee
	end
end

function Player.setToStartState( self )
	self.health = self.maxHealth
	self.armor = 0
	self:setGoldenMelee( false )

	self.weapons = { "Pistol" }
	self.keys = {}

	self.ammo[1].count = 100
	self.ammo[2].count = 0
	self.ammo[3].count = 0
	self.ammo[4].count = 0

	self:switchWeapon( 1 )
end


function Player.look( self )
	-- capture the mouse
    lm.setRelativeMode(true)
	
	local dx,dy = Controller:getCameraDirDelta()
	
    self.cam.dir = self.cam.dir + dx
    self.cam.pitch = max( min( self.cam.pitch - dy, math.pi * .499 ), math.pi * -.499 )

	-- tilt
	local tilt = self.cam.tilt + Juice:getRotation() + .00001
	tilt = tilt * sin( self.cam.pitch + rad( 90 ) )

	g3d.camera.up = { cos( self.cam.dir ) * tilt, -sin( self.cam.pitch + rad( 90 ) ) / abs( tilt ), -sin( self.cam.dir ) * tilt }
end

function Player.walk( self )
	local dir = Controller:getMoveDir()
	
	if dir and self.meleeTimer == 1 then
		
		local x = cos( dir + self.cam.dir ) * self.acceleration * hdt
		local z = sin( dir + self.cam.dir + math.pi ) * self.acceleration * hdt
		
		self.velocity.x = self.velocity.x + x
		self.velocity.z = self.velocity.z + z
		
	end
	
	local speed = min( self.maxSpeed, max( 0, math.dist( self.velocity.x,self.velocity.z, 0,0 ) - self.friction * hdt ) )
	local dir = math.angle( 0,0, self.velocity.x,self.velocity.z )
		
	self.velocity.x = cos( dir ) * speed
	self.velocity.z = sin( dir ) * speed
	
	self:move(
	self.velocity.x * hdt,
	0,
	self.velocity.z * hdt
	)
	
	self.collisionBox:setPos( self.x,self.y,self.z )
	
	self.stepTimer = self.stepTimer + speed / self.maxSpeed * hdt
	if self.stepTimer > self.stepTimerMax then
		self.stepTimer = self.stepTimer - self.stepTimerMax
		
		self.stepSound:setPitch( 1 + random() * rsign() * .1 )
		self.stepSound:play()
	end
end

function Player.viewBob( self )
	local speed = math.dist( 0,0, Player.velocity.x,Player.velocity.z ) / Player.maxSpeed
	local bobFrequency = 1 / Player.stepTimerMax * 2
	local bobFactor = .025
	local tiltFactor = .07
	local bob = sin( time * bobFrequency ) * speed

	Player.cam.height = Player.cam.eyeLevel + abs( bob ) * bobFactor * speed
	Player.cam.tilt = bob * tiltFactor
end

function Player.fall( self )
	self.velocity.y = self.velocity.y + self.gravity * hdt

	self:move(
	0,
	self.velocity.y * hdt,
	0
	)
	
	if self.y > 0 then
		self:setPos( self.x,0,self.z )
		self.collisionBox:setPos( self.x, 0, self.z )
		self.velocity.y = 0
	end
end

function Player.parentCamera( self )
	local x,y,z = self.x,self.y - self.cam.height,self.z
	local jx,jy,jz = Juice:getOffset()
	x = x + jx
	y = y + jy
	z = z + jz

	g3d.camera.lookInDirection( x,y,z, self.cam.dir,self.cam.pitch )
	g3d.camera.fov = Player.cam.fov * Juice:getScale()
	
	la.setPosition( x,y,z )
	
	local vx,vy,vz = g3d.camera.getLookVector()
	g3d.camera.lookInDirection( nil,nil,nil, self.cam.dir,self.cam.pitch + rad(90) )
	local uvx,uvy,uvz = g3d.camera.getLookVector()
	g3d.camera.lookInDirection( nil,nil,nil, self.cam.dir,self.cam.pitch )
	
	la.setOrientation( vx,vy,vz, uvx,uvy,uvz )
	
	g3d.camera.updateProjectionMatrix()
end

function Player.fire( self )
	local particleOffset = .15
	
	self.attackTimer = min( self.weapon.attackTimerMax, self.attackTimer + hdt )
	
	if Controller:isFiring() and	-- charge
	self.attackTimer == self.weapon.attackTimerMax and
	self.switchWeaponTimer == 0 and
	self.meleeTimer == self.meleeTimerMax and
	Player.ammo[Player.weapon.ammoIndex].count >= Player.weapon.ammoCost then
		Player.chargeTimer = min( Player.weapon.chargeTime, Player.chargeTimer + hdt )
	else
		Player.chargeTimer = max( 0, Player.chargeTimer - hdt )
	end

	if Player.weapon.chargeSound then
		if Player.chargeTimer > 0 then
			Player.weapon.chargeSound.source:setRelative( true )
			Player.weapon.chargeSound:setPos( 0,0,1 )
			Player.weapon.chargeSound:start()
		else
			Player.weapon.chargeSound:stop()
		end
		
		Player.weapon.chargeSound:setVolume( ( Player.chargeTimer / Player.weapon.chargeTime ) ^ .5 )
		Player.weapon.chargeSound:setPitch( 1 + ( Player.chargeTimer / Player.weapon.chargeTime * .4 ) )
	end
	
	if Controller:isFiring() and	-- fire
	self.attackTimer == self.weapon.attackTimerMax and
	self.switchWeaponTimer == 0 and
	self.meleeTimer == self.meleeTimerMax and
	Player.ammo[Player.weapon.ammoIndex].count >= Player.weapon.ammoCost and
	Player.chargeTimer == Player.weapon.chargeTime then
	
		Player.ammo[Player.weapon.ammoIndex].count = Player.ammo[Player.weapon.ammoIndex].count - Player.weapon.ammoCost
		Player.chargeTimer = 0
		
		Player.weapon.sound.source:setRelative( true )
		Player.weapon.sound:setPos( 0,0,1 )
		Player.weapon.sound:setPitch( 1 - random() * rsign() * .065 )
		Player.weapon.sound:play()

		local shotCount = self.weapon.shotCount
		local i = 1
		while i <= shotCount do
			i = i + 1
			
			self.attackTimer = 0
		
			local step = .1
			local dist = 20
			
			-- get aim vectors with random offset
			local dirOffset = Player.weapon.aimOffset
			local pitchOffset = Player.weapon.aimOffset
			while math.dist( dirOffset,pitchOffset, 0,0 ) > self.weapon.aimOffset do
				dirOffset = Player.weapon.aimOffset * random() * rsign()
				pitchOffset = Player.weapon.aimOffset * random() * rsign()
			end
			g3d.camera.lookInDirection( nil,nil,nil, self.cam.dir + dirOffset, self.cam.pitch + pitchOffset )
			
			local vx,vy,vz = g3d.camera.getLookVector()
			g3d.camera.lookInDirection( nil,nil,nil, self.cam.dir, self.cam.pitch )
			
			
			local startX,startY,startZ = self.x,self.y - self.cam.height,self.z
			
			local endX = vx * dist + startX
			local endY = vy * dist + startY 
			local endZ = vz * dist + startZ
			
			if Player.weapon.projectile then	-- projectile
				local projectileOffset = .3
			
				Projectile:new(
				Player.weapon.projectile, 
				startX + vx * projectileOffset,
				startY + vy * projectileOffset,
				startZ + vz * projectileOffset,
				
				vx,vy,vz
				)
			else	-- hit scan
				-- fire rays
				local wx,wy,wz = Collision.worldRay( startX,startY,startZ, endX,endY,endZ, step )
				local enemy, ex,ey,ez = Collision.entityRay( startX,startY,startZ, endX,endY,endZ, step, Enemy.list )
				local door, dx,dy,dz = Collision.entityRay( startX,startY,startZ, endX,endY,endZ, step, Door.list )
				local glass, gx,gy,gz = Collision.entityRay( startX,startY,startZ, endX,endY,endZ, step, Glass.list )
				local pushWall, px,py,pz = Collision.entityRay( startX,startY,startZ, endX,endY,endZ, step, PushWall.list )
				
				
				local glassDist = math.dist3D( gx,gy,gz, startX,startY,startZ )
				local doorDist = math.dist3D( dx,dy,dz, startX,startY,startZ )
				local worldDist = math.dist3D( wx,wy,wz, startX,startY,startZ )
				local enemyDist = math.dist3D( ex,ey,ez, startX,startY,startZ )
				local pushDist = math.dist3D( px,py,pz, startX,startY,startZ )
				local minDist = min( enemyDist, worldDist, doorDist, glassDist, pushDist )
				
				-- hit
				if minDist == enemyDist and enemy then
					enemy:damage( Player.weapon.damage )
					
					Particle:new( particle_enemyHit,
					ex - vx * particleOffset,
					ey - vy * particleOffset,
					ez - vz * particleOffset
					)
					
					if Player.weapon.penetrating then
						enemy.collisionBox.skipOnShotThisFrame = true
						shotCount = shotCount + 1
					end
				end
				if minDist == worldDist then
					Particle:new( particle_wallHit,
					wx - vx * particleOffset,
					wy - vy * particleOffset,
					wz - vz * particleOffset
					)
				end
				if minDist == doorDist then
					Particle:new( particle_wallHit,
					dx - vx * particleOffset,
					dy - vy * particleOffset,
					dz - vz * particleOffset
					)
				end
				if minDist == glassDist then
					Particle:new( particle_wallHit,
					gx - vx * particleOffset,
					gy - vy * particleOffset,
					gz - vz * particleOffset
					)
				end
				if minDist == pushDist then
					Particle:new( particle_wallHit,
					px - vx * particleOffset,
					py - vy * particleOffset,
					pz - vz * particleOffset
					)
				end
			end
			
		end
	end
	
end

function Player.melee( self )
	local meleeTime = self.meleeGolden and self.meleeGoldenTime or self.meleeTime
	
	self.meleeTimer = min( self.meleeTimer + hdt / meleeTime, self.meleeTimerMax )

	if Controller:isMeleeing() and self.meleeTimer == self.meleeTimerMax then
		self.meleeDir = -self.cam.dir + rad( 90 )
		self.meleeTimer = 0
		self.meleeSpeed = self.meleeSpeedMax
		self.velocity.y = self.meleeJump
		
		self.meleeSound:play()
		
		for i, e in pairs( Enemy.list ) do
			local vx,vy,vz = g3d.camera.getLookVector()
			vx = vx * self.meleeRange + self.x
			vy = vy * self.meleeRange - self.cam.height
			vz = vz * self.meleeRange + self.z
			
			if e.collisionBox:inBounds( vx,vy,vz ) then
				e:damage( self.meleeGolden and self.meleeGoldenDamage or self.meleeDamage )
			end
		end
	end
	
	self.meleeSpeed = max( 0, self.meleeSpeed - self.meleeDeacceleration * hdt )
	
	self:move( 
	cos( self.meleeDir ) * self.meleeSpeed * hdt,
	0,
	sin( self.meleeDir ) * self.meleeSpeed * hdt )
end

function Player.switchWeapon( self, index )
	local newWeapon = Controller:getSwappedWeapon( index )

	if newWeapon and newWeapon ~= self.weapon and self.switchWeaponTimer == 0 and self.attackTimer == self.weapon.attackTimerMax and contains( self.weapons, newWeapon.name ) then
		self.switchWeaponTimer = 1
		
		self.nextWeapon = newWeapon
	end
	
	if self.switchWeaponTimer < .5 and self.nextWeapon ~= self.weapon then
		self.weapon = self.nextWeapon
		self.attackTimer = self.weapon.attackTimerMax
	end
	
	self.switchWeaponTimer = max( 0, self.switchWeaponTimer - hdt / self.switchWeaponTimerMax )
end

function Player.pause( self )
	if Controller:toggledPause() then
		Game.state = "paused"
	end
end

function Player.update( self )
	self:walk()
	
	Pawn.update( self )
	
	self:fall()
	self:look()
	self:viewBob()
	self:parentCamera()
	self:fire()
	self:melee()
	self:switchWeapon()

	self:pause()
end


function Player.damage( self, damage )
	if self.armor > 0 then
		self.armor = floor( max( 0, self.armor - max( 0, damage * self.armorMult ) ) )
		
		damage = damage * ( 1 - self.armorMult )
	end
	
	self.health = max( 0, self.health - max( 0, damage ) )

	if self.health == 0 then
		self.cam.height = .15
		self:parentCamera()
		Game.state = "gameover"
	end

	local impactFactor = damage / 15
	Juice:shake( .03 * impactFactor )
	Juice:zoom( .95 )
	Juice:tilt( .35 * impactFactor )
	Juice:freeze( 1/ 60 )

	self.hitSound:setPitch( 1 + random() * .1 )
	self.hitSound:play()
end


function file:init()
	Player = Player:new()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file