local file = {priority = 15}

MenuButton = { list = {} }

i_menuButton = lg.newImage( "assets/hud/button.png" )
i_menuButtonHover = lg.newImage( "assets/hud/buttonHover.png" )

function MenuButton:new( func, label, x,y,w,h )
	local inst = Class:init( MenuButton )
	
	inst.func = func
	inst.label = label
	inst.x = x
	inst.y = y
	inst.w = w or 200
	inst.h = h or 25
	
	inst.hover = false
	
	if inst.x == "center" then
		inst.x = 320 - inst.w * .5
	end
	
	inst.texture = i_menuButton
	inst.textureHover = i_menuButtonHover
	inst.quadSize = inst.texture:getWidth() / 3

	inst.topLeftQuad = lg.newQuad( 0,0, inst.quadSize,inst.quadSize, inst.texture )
	inst.topMidQuad = lg.newQuad( inst.quadSize,0, inst.quadSize,inst.quadSize, inst.texture )
	inst.topRightQuad = lg.newQuad( inst.quadSize * 2,0, inst.quadSize,inst.quadSize, inst.texture )

	inst.midLeftQuad = lg.newQuad( 0,inst.quadSize, inst.quadSize,inst.quadSize, inst.texture )
	inst.midMidQuad = lg.newQuad( inst.quadSize,inst.quadSize, inst.quadSize,inst.quadSize, inst.texture )
	inst.midRightQuad = lg.newQuad( inst.quadSize * 2,inst.quadSize, inst.quadSize,inst.quadSize, inst.texture )

	inst.botLeftQuad = lg.newQuad( 0,inst.quadSize * 2, inst.quadSize,inst.quadSize, inst.texture )
	inst.botMidQuad = lg.newQuad( inst.quadSize,inst.quadSize * 2, inst.quadSize,inst.quadSize, inst.texture )
	inst.botRightQuad = lg.newQuad( inst.quadSize * 2,inst.quadSize * 2, inst.quadSize,inst.quadSize, inst.texture )

	table.insert( MenuButton.list, inst )
	
	return inst
end


function MenuButton.setHover( self )
	local mx,my = Controller:getCursorPos()
	
	self.hover = mx > self.x and
	mx < self.x + self.w and
	my > self.y and
	my < self.y + self.h
end

function MenuButton.activateButton( self )
	if self.hover and Controller:isMenuSelecting() then
		self.func()
	end
end

function MenuButton.update( self )
	self:setHover()
	self:activateButton()
end


function MenuButton.drawBox( self )
	local texture = self.texture

	lg.setColor( 1,1,1 )
	if self.hover then texture = self.textureHover end
	lg.rectangle( "fill", self.x,self.y,self.w,self.h )

	lg.draw( texture, self.topLeftQuad, self.x,self.y )
	lg.draw( texture, self.topMidQuad, self.x + self.quadSize,self.y, 0, ( self.w - self.quadSize * 2 ) / self.quadSize, 1 )
	lg.draw( texture, self.topRightQuad, self.x + self.w - self.quadSize,self.y )

	lg.draw( texture, self.midLeftQuad, self.x,self.y + self.quadSize, 0, 1,( self.h - self.quadSize * 2 ) / self.quadSize )
	lg.draw( texture, self.midMidQuad, self.x + self.quadSize,self.y + self.quadSize, 0, ( self.w - self.quadSize * 2 ) / self.quadSize, ( self.h ) / self.quadSize - 2 )
	lg.draw( texture, self.midRightQuad, self.x + self.w - self.quadSize,self.y + self.quadSize, 0, 1,( self.h - self.quadSize * 2 ) / self.quadSize  )

	lg.draw( texture, self.botLeftQuad, self.x,self.y + self.h - self.quadSize )
	lg.draw( texture, self.botMidQuad, self.x + self.quadSize,self.y + self.h - self.quadSize, 0, ( self.w - self.quadSize * 2 ) / self.quadSize, 1 )
	lg.draw( texture, self.botRightQuad, self.x + self.w - self.quadSize,self.y + self.h - self.quadSize )
end

function MenuButton.drawLabel( self )
	local stringHeight = 14

	lg.setColor( 200 / 255,225 / 255,235 / 255 )
	lg.printf( self.label, self.x,self.y + ( self.h - stringHeight ) * .5, self.w, "center" )
end

function MenuButton.draw( self )
	self:drawBox()
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