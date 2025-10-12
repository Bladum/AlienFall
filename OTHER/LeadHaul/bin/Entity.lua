local file = {priority = 0}

Entity = { list = {} }

function Entity:new( x,y,z )
	local inst = Class:init( Entity )
	
	inst.x = x or 0
	inst.y = y or 0
	inst.z = z or 0
	
	inst.parentOffset = { x = 0, y = 0, z = 0 }
	
	table.insert( Entity.list, inst )
	
	return inst
end


function Entity.destroyAll( self )
	while #Entity.list > 0 do
		for i, e in pairs( Entity.list ) do
			e:destroy()
		end
	end
end


function Entity.getPos( self )
	return self.x,self.y,self.z
end

function Entity.setPos( self, x,y,z )
	self.x = x or self.x or 0
	self.y = y or self.y or 0
	self.z = z or self.z or 0
end

function Entity.move( self, dx,dy,dz, steps )
	self.x = self.x + ( dx or 0 )
	self.y = self.y + ( dy or 0 )
	self.z = self.z + ( dz or 0 )
end

function Entity.dist( self, other )
	return math.dist( self.x,self.z, other.x,other.z )
end

function Entity.setParent( self, parent, offsetX,offsetY,offsetZ )
	self.parent = parent
	
	self.parentOffset.x = offsetX or self.parentOffset.x or 0
	self.parentOffset.y = offsetY or self.parentOffset.y or 0
	self.parentOffset.z = offsetZ or self.parentOffset.z or 0
end

function Entity.destroy( self )
	for i,e in pairs( Entity.list ) do
		if e == self then
			table.remove( Entity.list, i )
		end
	end
	
	-- update Entity list
	local list = {}
	for i,e in pairs( Entity.list ) do
		list[i] = e
	end
	
	Entity.list = list
end


function Entity.updateToParent( self )
	if self.parent then
		self:setPos(
		self.parent.x + self.parentOffset.x,
		self.parent.y + self.parentOffset.y,
		self.parent.z + self.parentOffset.z
		)
	end
end




function file:init()
end


local function _updateEntities()
	for i, e in pairs( Entity.list ) do
		if e.update and Game.state == "playing" then
			e:update()
		end
		e:updateToParent( )
	end
end

function file:update()
	_updateEntities()
end


local function _drawEntities()
	for i, e in pairs( Entity.list ) do
		if e.draw then
			e:draw()
		end
	end
end

function file:draw()
	_drawEntities()
end

-- [[ RETURN ]] --
return file