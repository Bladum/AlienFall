local file = {priority = .1}

Pickup = { list = {} }

function Pickup:new( object, x,y,z )
	local inst = Class:init( Pickup, Entity, { x + .5,y,z + .5 } )
	
	inst.object = object
	
	inst.img = inst.object.img
	inst.pickupDist = .65
	
	for key, value in pairs( inst.object ) do
		if type( value ) ~= "function" then
			inst[ key ] = value
		end
	end
	
	inst.sprite = Sprite:new( inst.img, inst.x, inst.y, inst.z )
	inst.sprite:setParent( inst )
	inst.sprite.model.fillColor = { 1,1,1, .05 }
	
	inst.object.init( inst )
	
	table.insert( Pickup.list, inst )
	
	return inst
end


function Pickup.triggerPickup( self )
	local dist = math.dist( Player.x,Player.z, self.x,self.z )
	
	if dist < self.pickupDist then
		self.object.pickup( self )
		
		if self.sound and self.destroyed then
			self.sound:setRelative( true )
			self.sound:play( )
		end
	end
end

function Pickup.keyItemFlash( self )
	if self.keyItem then
		local flashMult = .2
		
		local alpha = abs( sin( time * 1.5 ) ) * flashMult
		
		self.sprite.model.fillColor = { 1,1,1, alpha }
	end
end

function Pickup.magicalHover( self )
	if self.magical then
		local height = .05
		self.y = sin( time * 1.75 ) * height - height
	end
end

function Pickup.update( self )
	if self.object.update then
		self.object.update( self )
	end
	
	self:triggerPickup()
	self:keyItemFlash()
	self:magicalHover()
end


function Pickup.destroy( self )
	Entity.destroy( self )
	
	self.destroyed = true
	self.sprite:destroy()
	
	removeFromTable( Pickup.list, self )
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file