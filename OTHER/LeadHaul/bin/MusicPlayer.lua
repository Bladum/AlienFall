local file = {priority = 0}

MusicPlayer = { }

function MusicPlayer:new( )
	local inst = Class:init( MusicPlayer )
	
	inst.volume = 1
	
	inst:setSong( la.newSource( "assets/audio/music/Song2.wav", "static" ) )
	
	
	return inst
end


function MusicPlayer.play( self )
	self.song:play()
end

function MusicPlayer.resume( self, song )
	if not self.song:isPlaying() then

		if song then
			self:setSong( song )
		end

		self:play()
	end
end

function MusicPlayer.stop( self )
	self.song:stop()
end

function MusicPlayer.setSong( self, song, stop )
	if song ~= self.song then
		if stop then
			self:stop()
		end

		self.song = song
		self.song:setVolume( self.volume )
		self.song:setLooping( true )
		
		if self.song:getChannelCount() == 1 then
			self.song:setRelative( true )
		end
	end
end

function MusicPlayer.setVolume( self, value )
	self.volume = value
	self.song:setVolume( self.volume )
end



function file:init()
	MusicPlayer = MusicPlayer:new()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file