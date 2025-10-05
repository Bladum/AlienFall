local file = {priority = 0}

SecretArea = { list = {}, totalSecrets = 0, secretsFound = 0 }

function SecretArea:new( x,z )
	local inst = Class:init( SecretArea, Entity, { x,0,z } )
    
    inst.radius = 1.2
    inst.triggered = false

    inst.sound = sound_secretRevealed
    inst.sound:setRelative( true )

    SecretArea.totalSecrets = SecretArea.totalSecrets + 1

	table.insert( SecretArea.list, inst )
	
	return inst
end


function SecretArea.checkForPlayer( self )
    if self:dist( Player ) < self.radius and not self.triggered then
        self.triggered = true

        SecretArea.secretsFound = SecretArea.secretsFound + 1

        Message:new( "Secret revealed!" )
        self.sound:play()
    end
end

function SecretArea.update( self )
    self:checkForPlayer()
end


function SecretArea.destroy( self )
    Entity.destroy( self )

    self.sound:destroy()

    removeFromTable( SecretArea.list, self )
end


function file:init()
    sound_secretRevealed = Sound:new( "assets/audio/secretrevealed.wav", 1 )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file