local file = {priority = 0}

Pawn = { list = {} }

function Pawn:new( x,y,z, w,h )
	local inst = Class:init( Pawn, Entity, { x,y,z } )
	
	local w,h = w or .1, h or .7 * 2
	inst.collisionBox = CollisionBox:new( inst.x,inst.y,inst.z, w,h,w )
	inst.collisionBox:setParent( inst, 0,0,0 )
	inst.collisionBox:setCollisionFilter( "world" )
	
	inst.moveSteps = 8

	table.insert( Pawn.list, inst )
	
	return inst
end


function Pawn.setPos( self, x,y,z )
	Entity.setPos( self, x,y,z )
	self.collisionBox:setPos( x,y,z )
end


function Pawn.collideWithEnvironment( self )
	for i, box in pairs( CollisionBox.list ) do
		if box ~= self.collisionBox and box.collisionFilter == "world" then
			local x,y,z = self.collisionBox:separate( box )
			self:setPos( x,y,z )
			self.collisionBox:setPos( x,y,z )
		end
	end
	local x,y,z = self.collisionBox:separateFromWorld()
	self:setPos( x,y,z )
end

function Pawn.update( self )
	self:collideWithEnvironment()
end


function Pawn.move( self, x,y,z )
	x = x / self.moveSteps
	y = y / self.moveSteps
	z = z / self.moveSteps

	for i = 1, self.moveSteps do
		Entity.move( self, x,y,z )
		self.collisionBox:move( x,y,z )

		self:collideWithEnvironment()
	end
end

function Pawn.destroy( self )
	Entity.destroy( self )
	
	self.collisionBox:destroy()
	
	removeFromTable( Pawn.list, self )
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file