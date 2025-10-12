local file = { priority = .1 }

Door = { list = {} }


function Door:new( lock, x,z, endDoor )
	local inst = Class:init( Door, Entity, { x + .5, 0, z + .5 } )
	
	inst.endDoor = endDoor
	
	inst.model = mod_door:clone()
	if lock == "none" then
		inst.model = mod_doorNoLock:clone()
	end
	
	inst:lock( lock )
	
	inst.unlockedTexture = inst.model.texture
	inst.hasKeyTexture = inst.model.texture
	inst.lockedTexture = inst.model.texture
	
	inst.collisionBox = CollisionBox:new( self.x,0,self.z, 1,2,.25 )
	inst.collisionBox:setCollisionFilter( "world" )
	
	inst.openOffset = 0
	inst.openOffsetMax = 31 / 32
	inst.speed = 2
	inst.interactDist = 1
	inst.holdOpenDist = .7
	inst.openTimerMax = 3
	inst.openTimer = 0
	inst.hasBeenOpened = false
	
	inst.openSound = Sound:new( "assets/audio/dooropen.wav", 1, inst.x,-.5,inst.z )
	inst.openSound:fitDuration( 1 / inst.speed )
	inst.closeSound = Sound:new( "assets/audio/doorclose.wav", 1, inst.x,-.5,inst.z )
	inst.closeSound:fitDuration( 1 / inst.speed )
	inst.lockedSound = Sound:new( "assets/audio/locked.wav", 1, inst.x,-.5,inst.z )
	
	inst.rotated = World:isOccluded( x,z + 1 )
	if inst.rotated then
		inst.model:setRotation( 0, math.rad( 90 ), 0 )
		
		local w = inst.collisionBox.w
		inst.collisionBox.w = inst.collisionBox.l
		inst.collisionBox.l = w
	end
	
	if inst.endDoor then
		World:setTexture( x,z, 6,7 )
	else
		World:setTexture( x,z, 7,7 )
	end
	
	table.insert( Door.list, inst )
	
	return inst
end


function Door.lock( self, lock )
	self.lock = lock or World:getId( self.x, self.z )
	if lock ~= "none" then self.isLocked = true end
	self:setTextureSet()
	self:setTexture()
end

function Door.checkPlayerKey( self )
	if ( Player:hasKey( "blue" ) and self.lock == "blue" ) or
	( Player:hasKey( "green" ) and self.lock == "green" ) or
	( Player:hasKey( "red" ) and self.lock == "red" ) then
		self.isLocked = false
	end
end

function Door.setTextureSet( self )
	self.unlockedTexture = lg.newImage( "assets/textures/doorUnlocked.png" )
	self.lockedTexture = lg.newImage( "assets/textures/doorLocked.png" )
	self.hasKeyTexture = lg.newImage( "assets/textures/doorHasKey.png" )

	if self.lock == "blue" then
		self.unlockedTexture = lg.newImage( "assets/textures/doorBlueUnlocked.png" )
		self.lockedTexture = lg.newImage( "assets/textures/doorBlueLocked.png" )
		self.hasKeyTexture = lg.newImage( "assets/textures/doorBlueHasKey.png" )
	end
	if self.lock == "red" then
		self.unlockedTexture = lg.newImage( "assets/textures/doorRedUnlocked.png" )
		self.lockedTexture = lg.newImage( "assets/textures/doorRedLocked.png" )
		self.hasKeyTexture = lg.newImage( "assets/textures/doorRedHasKey.png" )
	end
	if self.lock == "green" then
		self.unlockedTexture = lg.newImage( "assets/textures/doorGreenUnlocked.png" )
		self.lockedTexture = lg.newImage( "assets/textures/doorGreenLocked.png" )
		self.hasKeyTexture = lg.newImage( "assets/textures/doorGreenHasKey.png" )
	end
	if self.lock == "none" then
		self.unlockedTexture = lg.newImage( "assets/textures/door.png" )
		self.lockedTexture = lg.newImage( "assets/textures/door.png" )
		self.hasKeyTexture = lg.newImage( "assets/textures/door.png" )
	end
	
	if self.endDoor then
		self.unlockedTexture = lg.newImage( "assets/textures/doorExit.png" )
		self.lockedTexture = lg.newImage( "assets/textures/doorExit.png" )
		self.hasKeyTexture = lg.newImage( "assets/textures/doorExit.png" )
	end
end

function Door.setTexture( self )
	self:setTextureSet()

	if self.isLocked then
		self.model:setTexture( self.lockedTexture )
	elseif not self.hasBeenOpened then
		self.model:setTexture( self.hasKeyTexture )
	else
		self.model:setTexture( self.unlockedTexture )
	end
end


function Door.open( self )
	local dist = self:dist( Player )
	
	self.openTimer = max( 0, self.openTimer - hdt )
	if dist <= self.interactDist and Controller:isInteracting() then
		if not self.lock or not self.isLocked then
			self.openTimer = self.openTimerMax
			self.hasBeenOpened = true
			self:setTexture()
			
			if self.openOffset == 0 then
				self.openSound:play()
			end
		else
			local str = "Locked"
			if type( self.lock ) == "string" then
				str = str..". Come back with a "..self.lock.." key"
			end
			
			self.lockedSound:play()
			Message:new( str )
		end
	end
	
	if self.openTimer > 0 then
		self.openOffset = min( self.openOffsetMax, self.openOffset + self.speed * hdt )
	elseif dist > self.holdOpenDist then
		if self.openOffset == self.openOffsetMax then
			self.closeSound:play()
		end
		self.openOffset = max( 0, self.openOffset - self.speed * hdt )
	end
	
	self.model:setTranslation(
	self.x - self.openOffset * boolToNumb( not self.rotated ),
	self.y,
	self.z - self.openOffset * boolToNumb( self.rotated )
	)
	
	self.collisionBox:setPos(
	self.x - self.openOffset * boolToNumb( not self.rotated ),
	self.y,
	self.z - self.openOffset * boolToNumb( self.rotated )
	)
end

function Door.checkFlags( self )
	if self.isLocked and Flag:isSet( self.lock ) then
		self.isLocked = false
		self:setTexture()
	end
end


function Door.destroy( self )
	Entity.destroy( self )

	self.collisionBox:destroy()

	removeFromTable( Door.list, self )
end


function Door.update( self )
	self:open()
	self:checkFlags()
end

function Door.draw( self )
	self.model:draw()
end


function file:init()
	mod_door = g3d.newModel( "assets/models/door.obj", "assets/textures/doorUnlocked.png", { 2,0,2 }, nil ,{ .5,.5,.5 } )
	mod_doorNoLock = g3d.newModel( "assets/models/doornolock.obj", "assets/textures/door.png", { 2,0,2 }, nil ,{ .5,.5,.5 } )
end


function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file