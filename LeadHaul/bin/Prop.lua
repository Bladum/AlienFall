local file = {priority = 0}

Prop = { list = {}, atlas = lg.newImage( "assets/props/props.png" ) }

local function buildModel( atlas, u,v )
	local img = Prop.atlas
	local uUnit = 1 / ( img:getWidth() / 32 )
	local vUnit = 1 / ( img:getHeight() / 32 )

	u = u * uUnit
	v = v * vUnit
	local nu = u + uUnit
	local nv = v + vUnit

	local verts = {
	{ -.5, .5, 0, u,nv },
	{ .5, .5, 0, nu,nv },
	{ .5, -.5, 0, nu,v },
	{ -.5, -.5, 0, u,v },
	{ -.5, .5, 0, u,nv },
	{ .5, -.5, 0, nu,v }
	}

	return g3d.newModel( verts, img )
end

function Prop:new( x,z, u,v )
	local inst = Class:init( Prop, Entity, { x + .5, 0, z + .5 } )
	
	inst.atlas = Prop.atlas

	inst.u = u
	inst.v = v

	inst.drawDist = 5

	inst.model = buildModel( atlas, inst.u,inst.v )

	inst.sprite = Sprite:new( inst.atlas, inst.x,inst.y,inst.z )
	inst.sprite:setParent( inst )
	inst.sprite:applySpriteSheet( { img = inst.atlas, model = inst.model } )

	if v == 0 then
		inst.collisionBox = CollisionBox:new( inst.x,inst.y,inst.z, .25,1,.25 )
		inst.collisionBox:setParent( inst, 0,0,0 )
		inst.collisionBox:setCollisionFilter( "world" )
	end

	table.insert( Prop.list, inst )

	return inst
end


function Prop.destroy( self )
	Entity.destroy( self )
	self.sprite:destroy()
	 
	if self.collisionBox then
		self.collisionBox:destroy()
	end

	removeFromTable( Prop.list, self )
end


function Prop.handleVis( self )
	--self.sprite.hidden = self:dist( Player ) > self.drawDist
end

function Prop.update( self )
	self:handleVis()
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file