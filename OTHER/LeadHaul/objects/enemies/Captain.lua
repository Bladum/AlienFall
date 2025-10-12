local file = { priority = .1 }


local enemy = {
	filePath = "assets/enemies/captain/",
	
	fireRocketAnim = Animation:new( "assets/enemies/captain/fireRocket.png", 1 ),
	fireBulletAnim = Animation:new( "assets/enemies/captain/fire.png", 1 ),

	w = 1,
	h = .8 * 2,

	music = la.newSource( "assets/audio/music/Boss.wav", "static" ),
	
	health = 2750,
	speed = 1.2,
	
	state = "wander",
	timer = 0,
	shotCount = 0,

	isBoss = true,
	
	projectile = projectile_striker,

	wanderTime = 1.8,
	fireWindup = .08,
	fireTime = .07,
	burstCount = 10,
	fireCooldown = .2,
	shotOffset = 0,

	musicStarted = false,
	
	projectileOffset = .32
}

function enemy.update( self )
	self.timer = self.timer + hdt * ( 1 + ( 1 - self.health / self.maxHealth ) )
	
	self.projectileX = self.x + cos( -Sprite.dir + rad(180) ) * self.projectileOffset
	self.projectileZ = self.z + sin( -Sprite.dir + rad(180) ) * self.projectileOffset
	
	if self.state == "idle" then
		self.sprite:applyAnimation( self.idleAnim )
	end
	
	if self.state == "wander" then
		if not self.musicStarted then
			self.musicStarted = true
			MusicPlayer:stop()
			MusicPlayer:setSong( self.music )
			MusicPlayer:play()
		end

		if self.timer < self.wanderTime then
			self.sprite:applyAnimation( self.runAnim )
			self:wander( )
		else
			self.timer = 0

			local randomAttackValue = random()
			if randomAttackValue < .33 then
				self.projectile = projectile_captainrocket
				self.projectileOffset = abs( self.projectileOffset )
				self.burstCount = 4
				self.fireAnim = self.fireRocketAnim
				self.shotOffset = rad(10)

				self.state = "fireAnticipation"
			elseif randomAttackValue < .66 then
				self.projectile = projectile_captainwavebullet
				self.projectileOffset = -abs( self.projectileOffset )
				self.burstCount = 20
				self.fireAnim = self.fireBulletAnim

				self.state = "fireWave"
			else
				self.projectile = projectile_captainbullet
				self.projectileOffset = -abs( self.projectileOffset )
				self.burstCount = 10
				self.fireAnim = self.fireBulletAnim
				self.shotOffset = rad(2)

				self.state = "fireAnticipation"
			end
		end
	end
	
	if self.state == "fireWave" then
		for ang = 0, math.pi * 2, math.pi * 2 / self.burstCount do
			Projectile:new(
			self.projectile,
			
			self.projectileX,
			-.30,
			self.projectileZ,
			
			cos( ang ),
			0,
			sin( ang )
			)
			
			self.shotSound:play()

			self.timer = 0

			self.state = "fireCooldown"
		end
	end

	if self.state == "fireAnticipation" then
		if self.timer < self.fireWindup then
			self.sprite:applyAnimation( self.fireAnticipationAnim )
		else
			local ang = math.angle( self.projectileX,self.projectileZ, Player.x,Player.z ) + random() * rsign() * self.shotOffset * .5
			Projectile:new(
			self.projectile,
			
			self.projectileX,
			-.30,
			self.projectileZ,
			
			cos( ang ),
			0,
			sin( ang )
			)
			
			self.shotSound:play()

			self.timer = 0

			self.state = "fire"
		end
	end
	
	if self.state == "fire" then
		if self.timer < self.fireTime then			
			self.sprite:applyAnimation( self.fireAnim )
		else
			if self.shotCount < self.burstCount - 1 then
				self.timer = 0
				self.state = "fireAnticipation"
				self.shotCount = self.shotCount + 1
			else
				self.timer = 0
				self.state = "fireCooldown"
				self.shotCount = 0
			end
		end
	end
	
	if self.state == "fireCooldown" then
		if self.timer < self.fireCooldown then
			self.sprite:applyAnimation( self.fireAnticipationAnim )
		else
			self.timer = 0
			self.state = "wander"
		end
	end
end

enemy_captain = enemy


return file