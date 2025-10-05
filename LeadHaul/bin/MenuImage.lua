local file = {priority = 15}

MenuImage = { list = {} }

function MenuImage:new( img, x,y )
	local inst = Class:init( MenuImage )
	
	inst.img = img
	inst.x = x
	inst.y = y
	
	table.insert( MenuImage.list, inst )
	
	return inst
end


function MenuImage.draw( self )
	lg.setColor( 1,1,1 )
	lg.draw( self.img, self.x,self.y )
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file