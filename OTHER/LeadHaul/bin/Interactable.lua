local file = {priority = 10}

Interactable = { list = {}, endSong = la.newSource( "assets/audio/music/Song2.wav", "static" ) }

function Interactable:new( x,z, endLevel )
	local inst = Class:init( Interactable, Entity, { x + .5,-.42,z + .5 } )
	
	inst.id = World:getId( x,z )
	
	inst.endLevel = endLevel
	inst.isOn = false
	
	if inst.endLevel then
		inst.modelOn = mod_endSwitchOn:clone()
		inst.modelOff = mod_endSwitchOff:clone()
	else
		inst.modelOn = mod_leverOn:clone()
		inst.modelOff = mod_leverOff:clone()
	end
	
	inst.model = inst.modelOff
	
	inst.interactDist = .6
	inst.interactSound = Sound:new( "assets/audio/switch.wav", .8, inst.x,inst.y,inst.z )
	
	inst.w = 9 / 32
	inst.l = 4 / 32
	inst.collisionBox = CollisionBox:new( inst.x,inst.y,inst.z, inst.w,inst.w,inst.l )
	inst.collisionBox:setCollisionFilter( "world" )
	
	inst:setModelPos()
	
	table.insert( Interactable.list, inst )
	
	return inst
end

function Interactable.setModelPos( self )
	local x,z = self.x,self.z
	local ang = 0
	
	if World:isOccluded( x + 1,z ) then
		x = x + .5
		ang = rad( 270 )
	elseif World:isOccluded( x - 1,z ) then
		x = x - .5
		ang = rad( 90 )
	elseif World:isOccluded( x,z + 1 ) then
		z = z + .5
		ang = rad( 180 )
	elseif World:isOccluded( x,z - 1 ) then
		z = z - .5
		ang = 0
	end
	
	if x % 1 == 0 then
		self.collisionBox.w = self.l
		self.collisionBox.l = self.w
	end
	
	self.collisionBox:setPos( x,self.y,z )
	self.model:setTranslation( x,self.y,z )
	self.model:setRotation( 0, ang, 0 )
end

function Interactable.interact( self )
	if Player:dist( self ) < self.interactDist and Controller:isInteracting() and not self.isOn then
		self.isOn = true
		self.model = self.modelOn
		
		Flag:new( self.id )
		
		self:setModelPos()
		
		self.interactSound:play()
		
		if self.endLevel then
			MusicPlayer:stop()
			MusicPlayer:setSong( Interactable.endSong )
			MusicPlayer:play()
			Game.state = "endscreen"
		end
	end
end

function Interactable.update( self )
	self:interact()
end


function Interactable.draw( self )
	self.model:draw()
end


function Interactable.destroy( self )
	Entity.destroy( self )	
	removeFromTable( Interactable.list, self )
end


function file:init()
	mod_leverOn = g3d.newModel( "assets/models/leveron.obj", "assets/textures/lever.png", nil, nil, { .5,.5,.5 } )
	mod_leverOff = g3d.newModel( "assets/models/leveroff.obj", "assets/textures/lever.png", nil, nil, { .5,.5,.5 } )
	mod_endSwitchOn = g3d.newModel( "assets/models/endswitchon.obj", "assets/textures/endswitch.png", nil, nil, { .5,.5,.5 } )
	mod_endSwitchOff = g3d.newModel( "assets/models/endswitchoff.obj", "assets/textures/endswitch.png", nil, nil, { .5,.5,.5 } )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file