local file = { priority = 0 }

local function loadRecentSave()
	Game.state = "playing"
	Persistence:load( "Level start" )
end

local function pistolStart()
	Game.state = "playing"
	Persistence:load( "Level start" )
	Player:setToStartState()
	Persistence:save( "Level start" )
end

local function returnToMainMenu()
	Game.state = "mainmenu"
end

local menu = {
	state = "gameover",
	
	elements = {
	MenuRect:new( { 0,0,0,.3 }, 0,80,640,30 ),
	MenuButton:new( loadRecentSave, "Restart", "center",160 ),
	MenuButton:new( pistolStart, "Pistol start", "center",195 ),
	MenuButton:new( returnToMainMenu, "Return to main menu", "center",230 ),
	
	MenuText:new( "You are dead", { 215 / 255,45 / 255,45 / 255 }, "center",80, "center", 0, 2,2 ),
	},
}


menu_gameover = menu

return file