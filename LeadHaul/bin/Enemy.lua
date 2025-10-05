local file = {priority = 0}

Enemy = { list = {}, killed = 0, totalCount = 0, killedBossTimer = 0 }

function Enemy:new( object, x,y,z )
	local inst = Class:init( Enemy, Pawn, { x,y,z, object.w,object.h } )
	
	inst.object = object
	
	for key, value in pairs( object ) do
		if type( value ) ~= "function" then
			inst[ key ] = value
		end
	end
	
	inst.wakeState = inst.state
	inst.state = "idle"
	
	inst.isEnemy = true
	inst.sprite = Sprite:new( nil, x,y,z )
	inst.sprite:setParent( inst )
	inst.sprite.model.fillColor = { 1,1,1, 0 }
	inst.sprite.model.outlineColor = { 1,1,1, .05 }
	
	inst.maxHealth = inst.health
	
	inst.hit = 0
	inst.hitDecrease = 1
	inst.hitMax = .16
	inst.flashTime = .06
	inst.wakeDist = 12
	inst.updateDist = 14

	inst.runAnim = Animation:new( inst.object.filePath.."run.png", .75 )
	inst.idleAnim = Animation:new( inst.object.filePath.."idle.png", 1 )
	inst.fireAnim = Animation:new( inst.object.filePath.."fire.png", .35 )
	inst.fireAnticipationAnim = Animation:new( inst.object.filePath.."fireAnticipation.png", 1 )
	inst.corpse = lg.newImage( inst.object.filePath.."corpse.png" )
	
	inst.stepTimer = 0
	inst.stepTimerMax = inst.runAnim.playTime * .5
	inst.stepSound = sound_enemyStep:clone()
	inst.stepSound:setParent( inst )
	inst.stepSound:setPitch( .85 )
	inst.stepSound:setAttenuationDistances( 0, 10 )

	inst.shotSound = sound_enemyShot:clone()
	inst.shotSound:setParent( inst )
	inst.shotSound:setAttenuationDistances( 0, 10 )

	inst.hitSound = sound_enemyHit:clone()
	inst.hitSound:setRelative( true )
	inst.deathSound = sound_enemyDeath

	inst.spottedSound = sound_enemySpot:clone()
	inst.spottedSound:setParent( inst )
	
	inst.gibs = {}
	local gibNames = lf.getDirectoryItems( inst.object.filePath.."/gibs" )
	for i, gn in pairs( gibNames ) do
		inst.gibs[#inst.gibs + 1] = Animation:new( inst.object.filePath.."/gibs/"..gn, .1 )
	end
	
	Enemy.totalCount = Enemy.totalCount + 1

	table.insert( Enemy.list, inst )
	
	return inst
end


function Enemy.updateAnimations( self )
	self.runAnim:play()
	self.idleAnim:play()
	self.fireAnim:play()
	self.fireAnticipationAnim:play()
end

function Enemy.updateHit( self )
	self.hit = max( 0, self.hit - self.hitDecrease * hdt )
	
	self.sprite:setScale( 1 + self.hit * 1.25, 1 - self.hit, 1 )
	self.sprite.parentOffset.y = -.5 + self.hit * .5
	
	if self.hit > self.hitMax - self.flashTime then
		self.sprite.model.fillColor[4] = .275
	else
		self.sprite.model.fillColor[4] = 0
	end
end

function Enemy.spawnDeathEffects( self )
	local gibCount = 12
	for i = 1, gibCount do
		Particle:new( particle_gib, self.x,-.5,self.z, 0,0,0, deepcopy( self.gibs[random( 1, #self.gibs )] ) )
	end	
	
	local splatCount = 5
	local splatOffset = .24
	for i = 1, splatCount do
		Particle:new( 
		particle_bloodsplat,
		
		self.x + random() * rsign() * splatOffset,
		-.5 + random() * rsign() * splatOffset,
		self.z + random() * rsign() * splatOffset
		)
	end
end

function Enemy.die( self )
	if self.health <= 0 then
		self:destroy()
		
		self:spawnDeathEffects()
		
		self.deathSound:setPos( self.x,self.y,self.z )
		self.deathSound:play()
		
		Juice:freeze( 1 / 30 )
		Juice:shake( .06 )
		Juice:zoom( 1.24 )

		for i = 1, min( self.maxHealth, 300 ) * .5 do
			Particle:new(
			particle_bloodGib,
			
			self.x,
			self.y - random() * self.collisionBox.h * .9,
			self.z
			)
		end

		Enemy.killed = Enemy.killed + 1

		if self.isBoss then
			MusicPlayer:stop()
			Enemy.killedBossTimer = 5
			Enemy.bossIsDead = true
		end

		Corpse:new( self.corpse, self.x,self.y,self.z )
	end
end

function Enemy.wakeUp( self )
	if self.state == "idle" and random() < .1 and self:dist( Player ) < self.wakeDist then
		local startX,startY,startZ = Player.x,Player.y,Player.z
		local endX,endY,endZ = self.x,self.y,self.z
		local step = .15

		local wx,wy,wz = Collision.worldRay( startX,startY,startZ, endX,endY,endZ, step )
		local door, dx,dy,dz = Collision.entityRay( startX,startY,startZ, endX,endY,endZ, step, Door.list )
		
		local selfDist = self:dist( Player )
		local worldDist = math.dist( wx,wz, Player.x,Player.z )
		local doorDist = door and math.dist( dx,dz, Player.x,Player.z ) or 10^9
		local minDist = min( selfDist,doorDist,worldDist )

		if minDist == selfDist then
			self.state = "react"

			self.spottedSound:play()

			Particle:new( 
			particle_playerSpotted,
		
			self.x,
			self.y - self.collisionBox.h - .1,
			self.z
			)
		end
	end
end

function Enemy.playStepSound( self )
	if self.state == "wander" or self.state == "chase" then
		self.stepTimer = self.stepTimer + hdt
		if self.stepTimer > self.stepTimerMax then
			self.stepTimer = self.stepTimer - self.stepTimerMax
			self.stepSound:play()
		end
	end
end

function Enemy.react( self )
	if self.state == "react" then
		self.reactTimer = self.reactTimer or random() * .3 + .3

		self.reactTimer = self.reactTimer - hdt

		if self.reactTimer <= 0 then
			self.state = self.wakeState
		end
	end
end

function Enemy.update( self )
	if self:dist( Player) < self.updateDist then
		self:wakeUp()
		self:react()
		self:updateAnimations()
		self:updateHit()
		self:playStepSound()
		self:die()
		
		self.object.update( self )
		
		Pawn.update( self )
	end
end


function Enemy.damage( self, damage )
	self.health = self.health - damage
	
	self.sprite:setHit( self.hitMax )
	
	self.hitSound:setPitch( 1 + ( 1 - ( self.health / self.maxHealth ) ) * .8 )
	self.hitSound:play()
	
	for i = 1, damage * .6 do
		Particle:new(
		particle_bloodGib,
		
		self.x,
		self.y - random() * self.collisionBox.h * .9,
		self.z
		)
	end

	Juice:shake( .025 )
	Juice:zoom( 1.01 )

	self.hit = self.hitMax
end

function Enemy.move( self, dx,dy,dz )
	local nx,ny,nz = self.x + dx, self.y + dy, self.z + dz
	
	if not World:isOccluded( nx,nz ) then
		Pawn.move( self, dx,dy,dz )
	end
end

function Enemy.destroy( self )
	Pawn.destroy( self )
	
	removeFromTable( Enemy.list, self )
	
	self.sprite:destroy()
end


function Enemy.wander( self, changeDirInterval )
	changeDirInterval = changeDirInterval or .8

	self.wanderDir = self.wanderDir or random() * math.pi * 2
	self.wanderTimer = self.wanderTimer or 0
	
	self.wanderTimer = self.wanderTimer + hdt
	
	if self.wanderTimer >= changeDirInterval then
		self.wanderTimer = self.wanderTimer - changeDirInterval
		self.wanderDir = random() * math.pi * 2
	end
	
	self:move( cos( self.wanderDir ) * self.speed * hdt, 0, sin( self.wanderDir ) * self.speed * hdt )
end

function Enemy.chase( self, target )
	target = target or Player
	
	local ang = math.angle( self.x,self.z, target.x,target.z )
	
	self:move( cos( ang ) * self.speed * hdt, 0, sin( ang ) * self.speed * hdt )
end



function file:init()
	sound_enemyHit = Sound:new( "assets/audio/hit.wav", 1, 0,0,0 )
	sound_enemyDeath = Sound:new( "assets/audio/enemydeath.wav", 1, 0,0,0 )
	sound_enemyDeath:setAttenuationDistances( 3, 25 )
end


function _endLevelAfterBoss()
	if Enemy.killedBossTimer > 0 then
		Enemy.killedBossTimer = max( 0, Enemy.killedBossTimer - hdt )

		if Enemy.killedBossTimer == 0 then
			MusicPlayer:setSong( Interactable.endSong )
			MusicPlayer:play()
			Game.state = "endscreen"
		end
	end
end

function file:update()
	_endLevelAfterBoss()
end

function file:draw()
end

-- [[ RETURN ]] --
return file