local file = {priority = 0}

Glass = { list = {} }

function Glass:new( x,z, rotated )
	local inst = Class:init( Glass, Entity, { x + .5, 0, z + .5 } )
	
	inst.rotated = rotated
	
	inst.model = mod_glass:clone()
	inst.model:setTranslation( inst.x,inst.y,inst.z )
	
	inst.collisionBox = CollisionBox:new( inst.x,0,inst.z, 1,2,.25 )
	inst.collisionBox:setCollisionFilter( "world" )
	
	if inst.rotated then
		inst.model:setRotation( 0, math.rad( 90 ), 0 )
		
		local w = inst.collisionBox.w
		inst.collisionBox.w = inst.collisionBox.l
		inst.collisionBox.l = w
	end
	
	table.insert( Glass.list, inst )
	
	return inst
end


function Glass.destroy( self )
	Entity.destroy( self )
	
	removeFromTable( Glass.list, self )
end

function Glass.draw( self )
	lg.setMeshCullMode( "none" )
	self.model:draw()
	lg.setMeshCullMode( "back" )
end


function file:init()
	mod_glass = g3d.newModel( "assets/models/glass.obj", "assets/textures/glass.png", { 2,0,2 }, nil ,{ .5,.5,.5 } )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file