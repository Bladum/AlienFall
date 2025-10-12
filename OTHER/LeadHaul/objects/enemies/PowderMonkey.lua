local file = { priority = 0 }


local enemy = {
	filePath = "assets/enemies/powdermonkey/",
	
	w = .55,
	h = .5 * 2,
	
	health = 40,
	speed = 2,
	meleeDamage = 15,
	attackDist = .5,
	
	state = "wander",
	timer = 0,
	
	wanderTime = .4,
	chaseTime = 1.8,
	attackWindup = .3,
	attackTime = .2
}

function enemy.update( self )
	self.timer = self.timer + hdt
	
	local dist = math.dist( self.x,self.z, Player.x,Player.z )
	
	if self.state == "idle" then
		self.sprite:applyAnimation( self.idleAnim )
	end
	
	if self.state == "wander" then
		self.sprite:applyAnimation( self.runAnim )
		self:wander( )
		
		if dist < self.attackDist then
			self.timer = 0
			self.state = "attackAnticipation"
		end
		if self.timer > self.wanderTime then
			self.timer = 0
			self.state = "chase"
		end
	end
	
	if self.state == "chase" then
		self.sprite:applyAnimation( self.runAnim )
		self:chase( )
		
		if dist < self.attackDist then
			self.timer = 0
			self.state = "attackAnticipation"
		end
		if self.timer > self.chaseTime then
			self.timer = 0
			self.state = "wander"
		end
	end
	
	if self.state == "attackAnticipation" then
		if self.timer < self.attackWindup then
			self.sprite:applyAnimation( self.fireAnticipationAnim )
		else
			
			if dist < self.attackDist then
				Player:damage( self.meleeDamage )
			end
			
			self.timer = 0
			self.state = "attack"
		end
	end
	
	if self.state == "attack" then
		if self.timer < self.attackTime then
			self.sprite:applyAnimation( self.fireAnim )
		else
			self.timer = 0
			self.state = "wander"
		
			if dist < self.attackDist then
				self.state = "attackAnticipation"
			end
			
		end
	end
	
end

enemy_powdermonkey = enemy


return file