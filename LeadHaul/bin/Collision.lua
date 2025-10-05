local file = {priority = 0}

Collision = { }

function Collision:new( )
	local inst = Class:init( Collision )
	
	return inst
end


function Collision.worldRay( x1,y1,z1, x2,y2,z2, step )
	local x,y,z = x1,y1,z1
	local dist = math.dist3D( x1,y1,z1, x2,y2,z2 )
	local xStep = ( x2 - x1 ) / dist * step
	local yStep = ( y2 - y1 ) / dist * step
	local zStep = ( z2 - z1 ) / dist * step
	
	for i = 0, dist, step do
		x = x + xStep
		y = y + yStep
		z = z + zStep
		
		if World:isOccluded( x,z ) or y < -1 or y > 0 then
			return x,y,z
		end
		
	end
	
	return x2,y2,z2
end

function Collision.entityRay( x1,y1,z1, x2,y2,z2, step, list )
	local x,y,z = x1,y1,z1
	local dist = math.dist3D( x1,y1,z1, x2,y2,z2 )
	local xStep = ( x2 - x1 ) / dist * step
	local yStep = ( y2 - y1 ) / dist * step
	local zStep = ( z2 - z1 ) / dist * step
	
	for i = 0, dist, step do
		x = x + xStep
		y = y + yStep
		z = z + zStep
		
		if y < -1 or y > 0 then
			return nil, x,y,z
		end
		
		for j, entity in pairs( list ) do
			if entity.collisionBox:inBounds( x,y,z ) and not entity.collisionBox.skipOnShotThisFrame then
				return entity, x,y,z
			end
		end
		
	end
	
	return nil, x2,y2,z2
end



function file:init()
	Collision = Collision:new()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file