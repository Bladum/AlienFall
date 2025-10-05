local file = {priority = 0}

Projectile = { list = {} }

function Projectile:new( object, x,y,z, xDir,yDir,zDir )
	local inst = Class:init( Projectile, Entity, { x,y,z } )
	
	inst.dir = { x = xDir, y = yDir, z = zDir }
	
	inst.object = object
	
	for key, value in pairs( object ) do
		if type( value ) ~= "function" then
			inst[ key ] = value
		end
	end
	
	inst.object.init( inst )
	
	inst.collisionBox = CollisionBox:new( x,y,z, inst.size,inst.size,inst.size )
	inst.collisionBox:setParent( inst )
	
	inst.scale = inst.scale or 1
	
	inst.sprite = Sprite:new( inst.anim.img, x,y,z, inst.scale, true )
	inst.sprite:setParent( inst )
	
	table.insert( Projectile.list, inst )
	
	return inst
end


function Projectile.updateAnim( self )
	self.anim:play()
	self.sprite:applyAnimation( self.anim )
end

function Projectile.moveForward( self )
	self:move(
	self.dir.x * self.speed * hdt,
	self.dir.y * self.speed * hdt,
	self.dir.z * self.speed * hdt
	)
end

function Projectile.homeIn( self )
	if self.homeSpeed then
		local dir = math.angle( 0,0, self.dir.x, self.dir.z )
		local playerDir = math.angle( self.x,self.z, Player.x,Player.z )
		
		local diffAng = dir - playerDir
		if diffAng > math.pi then diffAng = diffAng - math.pi * 2 end
		if diffAng < -math.pi then diffAng = diffAng + math.pi * 2 end
		
		local dirChange = -diffAng * self.homeSpeed
		
		dir = dir + dirChange * hdt
		
		self.dir.x = cos( dir )
		self.dir.z = sin( dir )
	end
end

function Projectile.collideWithWorld( self )
	if World:isOccluded( self.x,self.z ) then
		self:hit()
	end
end

function Projectile.collideWithFloorAndCeiling( self )
	if self.y + self.collisionBox.h > 0 or
	self.y - self.collisionBox.h < -1 then
		self:hit()
	end
end

function Projectile.collideWithBoxes( self )
	for i, box in pairs( CollisionBox.list ) do
		if box ~= self.collisionBox and self.collisionBox:collides( box ) then
			
			if not self.friendly and box.parent and box.parent.isPlayer then
				self:hit()
				Player:damage( self.damage )
			end
			if self.friendly and box.parent and box.parent.isEnemy then
				self:hit()
				box.parent:damage( self.damage )
			end
			
			if not box.parent and box.collisionFilter == "world" then
				self:hit()
			end
			
		end
	end
end

function Projectile.update( self )
	self:updateAnim()
	self:moveForward()
	self:homeIn()
	
	self:collideWithWorld()
	self:collideWithFloorAndCeiling()
	self:collideWithBoxes()
end


function Projectile.hit( self )
	if self.explosion then
		Explosion:new( self.x,self.y,self.z, self.explosion.radius,self.explosion.damage )
	end

	self:destroy()
end


function Projectile.destroy( self )
	Entity.destroy( self )
	
	self.sprite:destroy()
	
	removeFromTable( Projectile.list, self )
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file