local file = { priority = .1 }

local function loadRecentSave()
	Game.state = "playing"
end

local function e1m1()
	Game.state = "playing"
	World:loadLevel( "e1m1" )
	Player:setToStartState()
end

local function e1m2()
	Game.state = "playing"
	World:loadLevel( "e1m2" )
	Player:setToStartState()
end

local function e1m3()
	Game.state = "playing"
	World:loadLevel( "e1m3" )
	Player:setToStartState()
end

local function e1m4()
	Game.state = "playing"
	World:loadLevel( "e1m4" )
	Player:setToStartState()
end

local function e1m5()
	Game.state = "playing"
	World:loadLevel( "e1m5" )
	Player:setToStartState()
end

local function e1m6()
	Game.state = "playing"
	World:loadLevel( "e1m6" )
	Player:setToStartState()
end

local function returnToMainMenu()
	Game.state = "mainmenu"
end

local x = 15
local y = 100
local w,h = 75,30
local spacing = 5
local menu = {
	state = "levelselect",
	
	elements = {
	MenuButton:new( returnToMainMenu, "Back", x, 360 - 25 - x ),

	MenuButton:new( e1m1, "Level 1", x, y, w,h ),
	MenuButton:new( e1m2, "Level 2", x + ( w + spacing ), y, w,h ),
	MenuButton:new( e1m3, "Level 3", x + ( w + spacing ) * 2, y, w,h ),
	MenuButton:new( e1m4, "Level 4", x + ( w + spacing ) * 0, y + h + spacing, w,h ),
	MenuButton:new( e1m5, "Level 5", x + ( w + spacing ) * 1, y + h + spacing, w,h ),
	MenuButton:new( e1m6, "Final", x + ( w + spacing ) * 2, y + h + spacing, w,h ),

	MenuText:new( "Level select", { 219 / 255,244 / 255,252 / 255 }, x + spacing,40, "left", 0, 2,2 ),
	},
}


menu_levelselect = menu

return file