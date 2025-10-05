local file = {priority = 0}

Wind = { map = lg.newCanvas( 300,300 ):newImageData(), forceCap = 10, maxPriority = 100 }

function Wind:new( dir, force, x,z, priority )
	local inst = Class:init( Wind )
    
    local cr,cg,cb,ca = Wind.map:getPixel( x,z )
    if ca < priority then
        Wind.map:setPixel( x,z, ( cos(dir) + 1 ) / 2, ( sin(dir) + 1 ) / 2, force / Wind.forceCap, priority )
    end
	
	return inst
end


function Wind.pushEntities( self )
    for i, e in pairs( Entity.list ) do
        if ( e.isPlayer or e.isEnemy ) then
            local cr,cg,cb,ca = Wind.map:getPixel( e.x,e.z )

            if ca ~= 0 then
                local xDir = cr * 2 - 1
                local zDir = cg * 2 - 1
                local force = cb * Wind.forceCap

                e:move( xDir * force * hdt, 0, zDir * force * hdt )
            end
            
        end
    end
end

function Wind.update( self )
    self:pushEntities()
end


function file:init()
end


local function updateWind()
    Wind:update()
end

function file:update()
    updateWind()
end

function file:draw()
end

-- [[ RETURN ]] --
return file