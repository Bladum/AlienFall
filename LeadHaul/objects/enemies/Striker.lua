local file = { priority = 0 }


local enemy = {
	filePath = "assets/enemies/striker/",
	
	w = .6,
	h = .7 * 2,
	
	health = 120,
	speed = .9,
	
	state = "wander",
	timer = 0,
	shotCount = 0,
	
	wanderTime = 2.8,
	fireWindup = .16,
	fireTime = .16,
	burstCount = 2,
	fireCooldown = .2,
	
	projectileOffset = .27
}

function enemy.update( self )
	self.timer = self.timer + hdt
	
	self.projectileX = self.x + cos( -Sprite.dir + rad(180) ) * self.projectileOffset
	self.projectileZ = self.z + sin( -Sprite.dir + rad(180) ) * self.projectileOffset
	
	if self.state == "idle" then
		self.sprite:applyAnimation( self.idleAnim )
	end
	
	if self.state == "wander" then
		if self.timer < self.wanderTime then
			self.sprite:applyAnimation( self.runAnim )
			self:wander( )
		else
			self.timer = 0
			self.state = "fireAnticipation"
		end
	end
	
	if self.state == "fireAnticipation" then
		if self.timer < self.fireWindup then
			self.sprite:applyAnimation( self.fireAnticipationAnim )
		else
			local ang = math.angle( self.projectileX,self.projectileZ, Player.x,Player.z )
			Projectile:new(
			projectile_striker,
			
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
			if self.projectileOffset < 0 then
				self.fireAnim.timer = 0
			else
				self.fireAnim.timer = self.fireAnim.playTime * .6
			end
		
			self.sprite:applyAnimation( self.fireAnim )
		else
			if self.shotCount < self.burstCount - 1 then
				self.timer = 0
				self.state = "fireAnticipation"
				self.shotCount = self.shotCount + 1
				self.projectileOffset = -self.projectileOffset
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

enemy_striker = enemy


return file