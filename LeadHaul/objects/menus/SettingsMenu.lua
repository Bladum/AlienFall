local file = { priority = .1 }

local function toggleFullscreen()
	lw.setFullscreen( not lw.getFullscreen() )
end

local function returnToMainMenu()
	Game.state = "mainmenu"
end

local function setResolutionScale( scale )
	Screen:setResolutionScale( scale * .75 + .25 )
end

local function setAudioVolume( volume )
	la.setVolume( volume )
end

local function setAimSensitivity( sensitivity )
	Controller:setAimSensitivity( sensitivity * 2 + .05 )
end


local x = 15
local menu = {
	state = "settings",
	
	elements = {
	MenuButton:new( toggleFullscreen, "Fullscreen", x,150 ),
	MenuSlider:new( setResolutionScale, "Resolution scale", x,185, nil,nil, .1, 1 ),
	MenuSlider:new( setAudioVolume, "Audio volume", x,220, nil,nil, .1, 1 ),
	MenuSlider:new( setAimSensitivity, "Aim sensitivity", x,255, nil,nil, .05, .5 ),
	MenuButton:new( returnToMainMenu, "Back", x,360 - 25 - x ),

	MenuText:new( "Settings", { 219 / 255,244 / 255,252 / 255 }, x,40, "left", 0, 2,2 ),
	},

	updateMenu = menu_main.updateMenu,
}


menu_settings = menu

return file