local file = {priority = 0}

Bars = { list = {} }

function Bars:new( x,z, rotated )
	local inst = Class:init( Bars, Entity, { x + .5, 0, z + .5 } )
	
	inst.rotated = rotated
	
	inst.model = mod_Bars:clone()
	inst.model:setTranslation( inst.x,inst.y,inst.z )
	
	inst.collisionBox = CollisionBox:new( inst.x,0,inst.z, 1,2,.25 )
	inst.collisionBox:setCollisionFilter( "world" )
	
	if inst.rotated then
		inst.model:setRotation( 0, math.rad( 90 ), 0 )
		
		local w = inst.collisionBox.w
		inst.collisionBox.w = inst.collisionBox.l
		inst.collisionBox.l = w
	end
	
	table.insert( Bars.list, inst )
	
	return inst
end


function Bars.destroy( self )
	Entity.destroy( self )
	
	removeFromTable( Bars.list, self )
end

function Bars.draw( self )
	lg.setMeshCullMode( "none" )
	self.model:draw()
	lg.setMeshCullMode( "back" )
end


function file:init()
	mod_Bars = g3d.newModel( "assets/models/bars.obj", "assets/textures/bars.png", { 2,0,2 }, nil ,{ .5,.5,.5 } )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file