local file = {priority = 15}

MenuRect = { list = {} }

function MenuRect:new( color, x,y,w,h )
	local inst = Class:init( MenuRect )
	
	inst.color = color
	inst.x = x
	inst.y = y
	inst.w = w
	inst.h = h
	
	table.insert( MenuRect.list, inst )
	
	return inst
end


function MenuRect.drawRect( self )
	lg.setColor( self.color )
	lg.rectangle( "fill", self.x,self.y, self.w,self.h )
end

function MenuRect.draw( self )
	self:drawRect()
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file