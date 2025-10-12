local file = {priority = 0}

Corpse = { list = {} }

function Corpse:new( img, x,y,z )
	local inst = Class:init( Corpse, Entity, { x,y,z } )
	
	inst.img = img
	
	inst.sprite = Sprite:new( inst.img, x,y,z )
	
	inst.morph = .3
	inst.morphChange = 1
	
	table.insert( Corpse.list, inst )
	
	return inst
end


function Corpse.updateHit( self )
	self.morph = math.max( 0, self.morph - self.morphChange * hdt )
	
	self.sprite:setScale(
	1 + self.morph,
	1 - self.morph,
	1 
	)
	
	self.sprite:setPos(
	self.x,
	self.y - .5 + self.morph * .5,
	self.z
	)
end

function Corpse.update( self )
	self:updateHit()
end


function Corpse.destroy( self )
	Entity.destroy( self )
	
	self.sprite:destroy()
	
	removeFromTable( Corpse.list, self )
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file