local file = {priority = .1}

Particle = { list = {} }

local verts = {
{ -.5, .5, 0, 0,1 },
{ .5, .5, 0, 1,1 },
{ .5, -.5, 0, 1,0 },
{ -.5, .5, 0, 0,1 },
{ -.5, -.5, 0, 0,0 },
{ .5, -.5, 0, 1,0 }
}

function Particle:new( object, x,y,z, xv,yv,zv, anim )
	local inst = Class:init( Particle, Entity, { x,y,z } )
	
	inst.velocity = { x = xv or 0, y = yv or 0, z = zv or 0 }
	
	inst.object = object
	
	for key, value in pairs( object ) do
		if type( value ) ~= "function" then
			inst[ key ] = value
		end
	end
	
	inst.scale = inst.scale or 1
	
	inst.sprite = Sprite:new( inst.img or i_invis, x,y,z, inst.scale, true )
	inst.sprite:setParent( inst )
	
	inst.object.init( inst )
	
	inst.anim = inst.anim or anim
	
	if inst.anim then
		inst.anim:setLooping( false )
	end
	
	table.insert( Particle.list, inst )
	
	return inst
end


function Particle.hideAtHighTimer( self )
	if self.timer > 1 then
		self.sprite:hide()
	else
		self.sprite:reveal()
	end
end

function Particle.update( self )
	self:hideAtHighTimer()
	
	self.object.update( self )
end


function Particle.destroy( self )
	Entity.destroy( self )
	
	self.sprite:destroy()
	
	removeFromTable( Particle.list, self )
end


function file:init()
	i_error = lg.newImage( "assets/error.png" )
	i_invis = lg.newImage( "assets/invis.png" )
end

function file:update()
end


function file:draw()
end

-- [[ RETURN ]] --
return file