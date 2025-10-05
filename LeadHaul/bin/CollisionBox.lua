local file = {priority = 10}

CollisionBox = { list = {} }

function CollisionBox:new( x,y,z, w,h,l )
	local inst = Class:init( CollisionBox, Entity, { x,y,z } )
	
	inst.w = w * .5
	inst.h = h or .5
	inst.l = l or inst.w
	if inst.l == l then inst.l = l * .5 end
	if inst.h == h then inst.h = h * .5 end
	
	inst.collisionFilter = nil
	
	table.insert( CollisionBox.list, inst )
	
	return inst
end


function CollisionBox.inBounds( self, x,y,z )
	x = x or 0
	y = y or 0
	z = z or 0

	local w = self.w
	local h = self.h
	local l = self.l
	
	return self.x - w < x and
	self.x + w > x and
	self.y - h < y and
	self.y + h > y and
	self.z - l < z and
	self.z + l > z
end

function CollisionBox.collides( box1, box2 )
	return abs( box1.x - box2.x ) < box1.w + box2.w and
	abs( box1.y - box2.y ) < box1.h + box2.h and
	abs( box1.z - box2.z ) < box1.l + box2.l
end

function CollisionBox.separate( box1, box2 ) -- box1 is assumed to be moveable unlike box2
	local x1,z1,w1,l1 = box1.x,box1.z, box1.w,box1.l
	local x2,z2,w2,l2 = box2.x,box2.z, box2.w,box2.l
	local rx,rz = x1,z1
	local diff = w2
		
	if CollisionBox.collides( box1, box2 ) then
		if ( x1 + w1 ) - ( x2 - w2 ) < diff then
			diff = ( x1 + w1 ) - ( x2 - w2 )
			rx,rz = x2 - w1 - w2, z1
		end
		if ( z1 + l1 ) - ( z2 - l2 ) < diff then
			diff = ( z1 + l1 ) - ( z2 - l2 )
			rx,rz = x1, z2 - l1 - l2
		end
		if ( x2 + w2 ) - ( x1 - w1 ) < diff then
			diff = ( x2 + w2 ) - ( x1 - w1 )
			rx,rz = x2 + w1 + w2, z1
		end
		if ( z2 + l2 ) - ( z1 - l1 ) < diff then
			rx,rz = x1, z2 + l1 + l2
		end
	end
	
	return rx,box1.y,rz
end

function CollisionBox.separateFromWorld( self )
	local step = .005
	local angStep = math.pi * 2 / 8
	
	for i = 1, 10 do
		for ang = angStep, math.pi * 2, angStep do
			
			local x = self.x + cos( ang ) * self.w
			local z = self.z + sin( ang ) * self.l
			
			if World:isOccluded( x,z ) then
				self:move( cos( ang + math.pi ) * step, 0, sin( ang + math.pi ) * step )
			end
			
		end
	end
	
	return self.x,self.y,self.z
end


function CollisionBox.update( self )
	self.skipOnShotThisFrame = false
end


function CollisionBox.setCollisionFilter( self, filter )
	self.collisionFilter = filter
end

function CollisionBox.destroy( self )
	Entity.destroy( self )

	removeFromTable( CollisionBox.list, self )
end


function file:init()
	
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file