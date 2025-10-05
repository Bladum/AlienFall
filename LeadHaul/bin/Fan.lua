local file = {priority = 1}

Fan = { list = {} }

function Fan.addWind( self )
    for dir = 0, math.pi * 1.5, math.pi * .5 do
        local cursor = { x = self.x + cos( dir ),z = self.z + sin( dir ) }
        local priority = 1

        while not World:isOccluded( cursor.x,cursor.z ) do
            priority = priority - 1 / Wind.maxPriority

            for i, d in pairs( Door.list ) do
                if d.x - .5 == cursor.x and d.z - .5 == cursor.z then
                    cursor.x = 0
                    cursor.z = 0
                end
            end

            Wind:new( dir, self.force, cursor.x,cursor.z, priority )

            cursor.x = cursor.x + cos( dir )
            cursor.z = cursor.z + sin( dir )
        end

    end
end

function Fan:new( force, x,z )
	local inst = Class:init( Fan, Entity, { x,0,z } )
    
    inst.force = force
    inst.timer = 0

    inst.model = mod_cube:clone()
    inst.model:setTranslation( inst.x + .5,-.5,inst.z + .5 )

    inst.frames = { i_fanFrame1,i_fanFrame2 }
    inst.frameIndex = 1
    inst.frameTime = 1 / ( force * 20 ) + .04

    inst.swingSound = sound_fanSwing:clone()
    inst.swingSound:setPitch( inst.force * .12 + .9 )
    inst.swingSound:setPos( inst.x,-.5,inst.z )
    inst.swingSound:setVolume( 1 / inst.swingSound:getPitch() )
    inst.swingSound:setLooping( true )
    inst.swingSound:setAttenuationDistances( 0, 5 )
    inst.swingSound:start()

	table.insert( Fan.list, inst )
	
	return inst
end



function Fan.addWindOnFirstFrame( self )
    if self.timer == 0 then
        self:addWind()
    end

    self.timer = self.timer + hdt
end

function Fan.setModelTexture( self )
    if self.timer > self.frameTime then
        self.timer = self.timer - self.frameTime
        self.frameIndex = ( self.frameIndex + 1 ) % #self.frames

        self.model:setTexture( self.frames[self.frameIndex + 1] )
    end
end

function Fan.update( self )
    self:addWindOnFirstFrame()
    self:setModelTexture()
end

function Fan.destroy( self )
    Entity.destroy( self )
    self.swingSound:destroy()
end


function Fan.draw( self )
    self.model:draw()
end

function file:init()
    sound_fanSwing = Sound:new( "assets/audio/fanswing.wav", 1 )

    mod_cube = g3d.newModel( "assets/models/cube.obj", "assets/textures/doorUnlocked.png", { 2,0,2 }, nil ,{ .52,.52,.52 } )
    i_fanFrame1 = lg.newImage( "assets/textures/fan1.png" )
    i_fanFrame2 = lg.newImage( "assets/textures/fan2.png" )
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file