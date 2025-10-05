local file = { priority = .1 }

PushWall = { list = {} }


function PushWall.buildModel( self, u,v )
	local texture = World.textureAtlas
	local verts = {}
	local x,z = -.5,-.5

	verts = MeshBuilder:buildWallNorth( verts, x,z, 1, u,v )
	verts = MeshBuilder:buildWallSouth( verts, x,z, 1, u,v )
	verts = MeshBuilder:buildWallWest( verts, x,z, 1, u,v )
	verts = MeshBuilder:buildWallEast( verts, x,z, 1, u,v )
	
	self.model = g3d.newModel( verts, texture )
end

function PushWall:new( fillColor, x,z, flashMult )
	local inst = Class:init( PushWall, Entity, { x + .5, 0, z + .5 } )
	
	local u,v = World:getTexture( inst.x,inst.z )

	inst:buildModel( u,v )
	inst.model:setTranslation( inst.x,inst.y,inst.z )
	inst.fillColor = fillColor or { 1,1,1, 0 }
	inst.model.fillColor = inst.fillColor

	inst.collisionBox = CollisionBox:new( self.x,0,self.z, 1,2,1 )
	inst.collisionBox:setCollisionFilter( "world" )
	inst.collisionBox:setParent( inst )
	
	inst.moveSound = sound_wallMoving:clone()
	inst.moveSound:setParent( inst )
	inst.moveSound:setLooping( true )

	inst.moving = false
	inst.dir = 0
	inst.speed = 1
	inst.interactDist = 1.5
	inst.flashMult = flashMult
	
	table.insert( PushWall.list, inst )
	
	return inst
end


function PushWall.destroy( self )
	Entity.destroy( self )

	self.collisionBox:destroy()

	removeFromTable( PushWall.list, self )
end


function PushWall.checkForInteract( self )
	if self:dist( Player ) < self.interactDist and Controller:isInteracting() and not self.moving then
		local ang = math.angle( self.x,self.z, Player.x,Player.z ) + rad( 45 )
		local moveDir = floor( ang / rad( 360 ) * 4 ) / 4 * rad( 360 ) + math.pi
		
		local occDist = self.collisionBox.w
		if not World:isOccluded( self.x + cos( moveDir + math.pi ) * occDist, self.z + sin( moveDir + math.pi ) * occDist ) then
			self.moving = true
			self.dir = moveDir
			self.moveSound:start()
			Juice:zoom( 1.1 )
		end
		
	end
end

function PushWall.moveInDir( self )
	if self.moving then
		local speed = self.speed
		self:move( cos( self.dir ) * speed * hdt, 0, sin( self.dir ) * speed * hdt )
		self.collisionBox:setPos( self.x,self.y,self.z )

		if self:dist( Player ) < 5 then
			Juice:shake( .005 )
		end
	end
end

function PushWall.stopMoving( self )
	if self.moving then
		local dist = self.collisionBox.w
		self.moving = not World:isOccluded( self.x + cos( self.dir ) * dist, self.z + sin( self.dir ) * dist )
		
		if not self.moving then
			self:setPos(
			floor( self.x ) + .5,
			0,
			floor( self.z ) + .5
			)

			self.moveSound:stop()
			Juice:zoom( 1 )
			Juice:shake( .015 )
		end
	end
end

function PushWall.parentModel( self )
	self.model:setTranslation( self.x,self.y,self.z )
end

function PushWall.updateFlash( self )
	self.model.fillColor = { 1,1,1, self.fillColor[4] + abs( sin( time * 3.5 ) ) * self.flashMult }
end

function PushWall.update( self )
	self:checkForInteract()
	self:moveInDir()
	self:stopMoving()
	self:parentModel()
	self:updateFlash()
end


function PushWall.draw( self )
	lg.setMeshCullMode( "none" )
	self.model:draw()
	lg.setMeshCullMode( "back" )
end


function file:init()
	sound_wallMoving = Sound:new( "assets/audio/wallmoving.wav", 1 )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file