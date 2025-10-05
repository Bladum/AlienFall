local file = { priority = 0 }

local function loadRecentSave()
	Game.state = "playing"
	Persistence:load( "Level start" )
end

local function levelSelect()
	Game.state = "levelselect"
end

local function quit()
	love.event.quit()
end

local function goToSettings()
	Game.state = "settings"
end

local function updateMenu( self )
	local mx,my = Controller:getCursorPos()
	local factor = .15

	mx = ( mx / Hud.defaultW - .5 ) * factor
	my = ( -my / Hud.defaultH + .25 ) * factor

	g3d.camera.lookInDirection( 22.3,-.5,20.7, rad(160) + mx,my )
end

local function initMenu( self )
	if World.levelName ~= "menu" then World:loadLevel( "menu" ) end
	g3d.camera.lookInDirection( 22.3,-.5,20.7, rad(160),0 )
end

local menu = {
	state = "mainmenu",
	
	elements = {
	MenuImage:new( lg.newImage( "assets/hud/logo.png" ), 10,10 ),

	MenuButton:new( loadRecentSave, "Continue", 15,150 ),
	MenuButton:new( levelSelect, "Level Select", 15,185 ),
	MenuButton:new( goToSettings, "Settings", 15,220 ),
	MenuButton:new( quit, "Quit", 15,255 ),
	},

	updateMenu = updateMenu,
	initMenu = initMenu,
}


menu_main = menu

return file