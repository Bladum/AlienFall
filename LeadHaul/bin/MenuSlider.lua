local file = {priority = 15}

i_menuSlider = lg.newImage( "assets/hud/slider.png" )
i_menuSliderHover = lg.newImage( "assets/hud/sliderHover.png" )

MenuSlider = { list = {} }

function MenuSlider:new( func, label, x,y,w,h, steps, defaultValue )
	local inst = Class:init( MenuSlider )
	
	inst.func = func
	inst.label = label
	inst.x = x
	inst.y = y
	inst.w = w or 200
	inst.h = h or 25
	inst.steps = steps or 0.0001
	
	inst.value = defaultValue or .5
	
	inst.hover = false
	
	if inst.x == "center" then
		inst.x = 320 - inst.w * .5
	end
	
	table.insert( MenuSlider.list, inst )
	
	return inst
end


function MenuSlider.setHover( self )
	local mx,my = Controller:getCursorPos()
	
	self.hover = mx > self.x and
	mx < self.x + self.w and
	my > self.y and
	my < self.y + self.h
end

function MenuSlider.setValue( self )
	local mx,my = Controller:getCursorPos()

	if self.hover and Controller:isMenuHolding() then
		self.value = floor( ( mx - self.x ) / self.w / self.steps + .5 ) * self.steps
	
		self.func( self.value )
	end
end

function MenuSlider.update( self )
	self:setHover()
	self:setValue()
end


function MenuSlider.drawSlide( self )
	local slideWidth = 8
	local lineHeight = 2
	local img = i_menuSlider

	if self.hover then img = i_menuSliderHover end
	
	lg.setColor( 1,1,1 )
	lg.rectangle( "fill", self.x,self.y + self.h * .5 - lineHeight * .5,self.w,lineHeight )
	
	lg.setColor( 1,1,1 )
	local slideX = self.x + self.w * self.value - slideWidth * .5
	lg.draw( img, slideX,self.y, 0, slideWidth / img:getWidth(),1, 0,0 )
end

function MenuSlider.drawLabel( self )
	local stringHeight = 14
	local labelOffset = 6

	lg.setColor( 1,1,1 )
	lg.printf( self.label, self.x + self.w + labelOffset,self.y + ( self.h - stringHeight ) * .5, self.w, "left" )
end

function MenuSlider.draw( self )
	self:drawSlide()
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