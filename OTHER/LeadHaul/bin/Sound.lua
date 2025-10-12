local file = {priority = 0}

Sound = { list = {} }

function Sound:new( source, volume, x,y,z )
	x,y,z = x or 0,y or 0,z or 0
	local inst = Class:init( Sound, Entity, { x,y,z } )
	
	if type( source ) == "string" then
		inst.source = la.newSource( source, "static" )
	else
		inst.source = source:clone()
	end
	
	inst.volume = volume or 1
	
	inst.source:setVolume( inst.volume )
	inst.source:setPosition( x,y,z )
	
	table.insert( Sound.list, inst )
	
	return inst
end


function Sound.setPos( self, x,y,z )
	Entity.setPos( self )
	self.source:setPosition( x,y,z )
end

function Sound.setPitch( self, pitch )
	self.source:setPitch( pitch )
end

function Sound.setVolume( self, volume )
	self.source:setVolume( volume )
	self.volume = volume
end

function Sound.setLooping( self, looping )
	self.source:setLooping( looping )
end

function Sound.setRelative( self, relative )
	self.source:setRelative( relative )
end

function Sound.setAttenuationDistances( self, ref, maximum )
	self.source:setAttenuationDistances( ref, maximum )
end

function Sound.fitDuration( self, duration )
	local selfDuration = self.source:getDuration()
	self.source:setPitch( selfDuration / duration )
end


function Sound.getPitch( self )
	return self.source:getPitch()
end


function Sound.start( self )
	self.source:play()
end

function Sound.stop( self )
	self.source:stop()
end

function Sound.play( self, x,y,z )
	if x and y and z then
		self:setPos( x,y,z )
	end
	self.source:clone():play()
end

function Sound.clone( self )
	local clone = Sound:new( self.source,self.volume,self.x,self.y,self.z )
	return clone
end

function Sound.update( self )
end


function Sound.destroy( self )
	Entity.destroy( self )
	self.source:stop()
	removeFromTable( Sound.list, self )
end


function file:init()
	sound_explosion = Sound:new( "assets/audio/explosion.wav", 1, 3,-.5,3 )
	sound_ammopickup = Sound:new( "assets/audio/ammopickup.wav", 1 )
	sound_keypickup = Sound:new( "assets/audio/keypickup.wav", 1 )
	sound_exoticpickup = Sound:new( "assets/audio/exoticpickup.wav", 1 )
	sound_drink = Sound:new( "assets/audio/drink.wav", 1 )
	sound_barreldrink = Sound:new( "assets/audio/barreldrink.wav", 1 )
	sound_medpouch = Sound:new( "assets/audio/medpouch.wav", 1 )
	sound_medkit = Sound:new( "assets/audio/medkit.wav", 1 )
	sound_enemyStep = Sound:new( "assets/audio/footstep.wav", .2 )
	sound_enemyShot = Sound:new( "assets/audio/enemyshot.wav", .6 )
	sound_enemySpot = Sound:new( "assets/audio/spottedplayer.wav", 1 )


	la.setDistanceModel( "linear" )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file