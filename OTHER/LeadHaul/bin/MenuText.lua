local file = {priority = 15}

MenuText = { list = {} }

function MenuText:new( label, color, x,y, align, r,sx,sy )
	local inst = Class:init( MenuText )
	
	inst.label = label
	inst.color = color or { 1,1,1,1 }
	inst.x = x or "center"
	inst.y = y or 0
	inst.align = align or "center"
	inst.r = r or 0
	inst.sx = sx or 1
	inst.sy = sy or inst.sx
	
	if inst.x == "center" then
		inst.x = 320
	end
	
	table.insert( MenuText.list, inst )
	
	return inst
end


function MenuText.drawLabel( self )
	local w = 10^5
	local x = self.align == "center" and self.x - w * .5 * self.sx or self.x

	local shadowOffset = 2
	lg.setColor( 0,0,0, .5 )
	lg.printf( self.label, x + shadowOffset,self.y + shadowOffset, w, self.align, self.r, self.sx,self.sy )

	lg.setColor( self.color )
	lg.printf( self.label, x,self.y, w, self.align, self.r, self.sx,self.sy )
end

function MenuText.draw( self )
	self:drawLabel()
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file