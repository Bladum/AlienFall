local file = {priority = 14}

Menu = { list = {} }

function Menu:new( object )
	local inst = Class:init( Menu )
	
	inst.object = object
	
	for key, value in pairs( inst.object ) do
		inst[ key ] = value
	end

	inst.updateMenu = inst.updateMenu or function() end
	
	table.insert( Menu.list, inst )
	
	return inst
end


function Menu.initMenuAtFirstFrame( self )
	if self.state == Game.state then
		if self.lastUpdateTime ~= time - hdt and self.initMenu then
			self:initMenu()
		end

		self.lastUpdateTime = time
	end
	
end

function Menu.setMouseMode( self )
	lm.setRelativeMode( false )
end

function Menu.updateElements( self )
	for i, e in pairs( self.elements ) do
		if e.update then
			e:update()
		end
	end
end

function Menu.update( self )
	self:initMenuAtFirstFrame()
	self:setMouseMode()
	self:updateMenu()
	self:updateElements()
end


function Menu.applyDrawaingSettings( self )
	lm.setVisible( false )
end

function Menu.drawElements( self )
	for i, e in pairs( self.elements ) do
		if e.draw then
			e:draw()
		end
	end
end

function Menu.drawCursor( self )
	local mx,my = Controller:getCursorPos()
	local img = i_cursor

	for i, e in pairs( self.elements ) do
		if e.hover then
			img = i_cursorHover
			
			if Controller:isMenuHolding() then
				img = i_cursorActive
			end
		end
	end

	lg.setColor( 1,1,1 )
	lg.draw( img, mx,my, 0, 1,1, img:getWidth() * .5,img:getHeight() * .5 )
end

function Menu.draw( self )
	self:applyDrawaingSettings()
	self:drawElements()
	self:drawCursor()
end



function file:init()
	i_cursor = lg.newImage( "assets/hud/cursor.png" )
	i_cursorHover = lg.newImage( "assets/hud/cursorHover.png" )
	i_cursorActive = lg.newImage( "assets/hud/cursorHoverActive.png" )
	
	Menu:new( menu_gameover )
	Menu:new( menu_main )
	Menu:new( menu_pause )
	Menu:new( menu_endscreen )
	Menu:new( menu_settings )
	Menu:new( menu_levelselect )
end


local function updateMenus()
	for i, m in pairs( Menu.list ) do
		if Game.state == m.state then
			m:update()
		end
	end
end

function file:update()
	updateMenus()
end


local function drawMenus()
	for i, m in pairs( Menu.list ) do
		if Game.state == m.state then
			m:draw()
		end
	end
end

function file:draw()
	drawMenus()
end

-- [[ RETURN ]] --
return file