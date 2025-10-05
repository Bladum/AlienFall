local file = {priority = 0}

Explosion = { list = {} }

local function _damageEntities( self )
	for i, e in pairs( Entity.list ) do
		if e.isEnemy or e.isPlayer then
			local dist = math.dist( e.x,e.z, self.x,self.z ) + e.collisionBox.w
			
			if dist < self.radius then
				--	e:damage( ( 1 - ( dist / self.radius ) ) * self.damage ) -- damage diminihes with distance
				local PlayerDamageFactor = .5
				e:damage( self.damage * boolToNumb( e.isEnemy ) * ( 1 - PlayerDamageFactor ) + self.damage * PlayerDamageFactor )
			end
		end
	end
end

function Explosion:new( x,y,z, radius, damage )
	local inst = Class:init( Explosion, Entity, { x,y,z } )
	
	inst.timer = 0
	inst.maxTimer = 1
	inst.particleTimer = 0
	
	inst.radius = radius
	inst.particleRadius = radius * .65
	inst.damage = damage
	inst.volume = 4 / 3 * math.pi * ( inst.radius ^ 3 )
	inst.particleVolume = 4 / 3 * math.pi * ( inst.particleRadius ^ 3 )
	
	sound_explosion:setPos( inst.x,inst.y,inst.z )
	sound_explosion:play()
	
	_damageEntities( inst )
	
	table.insert( Explosion.list, inst )
	
	return inst
end


local function _addParticle( self )
	local particles = { particle_explosionFire, particle_explosionSmoke }
	local radius = self.particleRadius
	
	local x = -radius
	local y = -radius
	local z = -radius
	
	while math.dist3D( x,y,z, self.x,self.y,self.z ) > radius do
		x = self.x + random() * rsign() * radius
		y = self.y + random() * rsign() * radius
		z = self.z + random() * rsign() * radius
	end
	
	local particle = particles[ random( 1, #particles ) ]
	
	if y < 0 and y > -1 then
		local p = Particle:new( particle, x,y,z, 0,0,0 )
		p.timer = p.timer + random() * .5
	end
end
function Explosion.addParticles( self )
	local particleCount = self.particleVolume * 25
	local waveParticleCount = self.radius * 10
	local waveTilt = random() * rsign() * .3
	local waveTiltOffset = random() * math.pi * 2
	
	if self.timer == 0 then
		for i = 1, particleCount do
			_addParticle( self )
		end
		
		for i = 0, math.pi * 2, ( math.pi * 2 ) / waveParticleCount do
			local p = Particle:new( particle_explosionWave,
			self.x,self.y,self.z,
			
			cos( i ), sin( i + waveTiltOffset ) * waveTilt, sin( i ))
			
			p.speed = 1 / p.timerDecrease * self.radius * 4
		end
	end
end

function Explosion.kill( self )
	self.timer = self.timer + hdt
	
	if self.timer > self.maxTimer then
		self:destroy()
	end
end

function Explosion.shake( self )
	Juice:shake( 0.035 * ( 1 - self.timer / self.maxTimer) / self:dist( Player ) )
end

function Explosion.update( self )
	self:addParticles()
	self:shake()
	self:kill()
end


function Explosion.destroy( self )
	Entity.destroy( self )
	
	removeFromTable( Explosion.list, self )
end


function file:init()
	sound_explosion = Sound:new( "assets/audio/explosion.wav", 1, 0,0,0 )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file