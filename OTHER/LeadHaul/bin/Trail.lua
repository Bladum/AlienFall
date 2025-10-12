local file = {priority = 0}

Trail = { }

local function _createTrail( particle, x,y,z, ex,ey,ez, step )
	step = step or .25
	
	local dist = math.dist3D( x,y,z, ex,ey,ez )
	local xStep = ( ex - x ) / dist * step
	local yStep = ( ey - y ) / dist * step
	local zStep = ( ez - z ) / dist * step
	
	for i = 0, dist, step do
		x = x + xStep
		y = y + yStep
		z = z + zStep
		
		Particle:new( particle, x,y,z, 0,0,0 )
		
	end
end

function Trail:new( particle, x,y,z, endX,endY,endZ, step )
	local inst = Class:init( Trail )
	
	_createTrail( particle, x,y,z, endX,endY,endZ, step )
	
	return inst
end



function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file