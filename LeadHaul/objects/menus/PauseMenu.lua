local file = { priority = 0 }

local function resume()
	Game.state = "playing"
end

local function returnToMainMenu()
	Game.state = "mainmenu"
end

local menu = {
	state = "paused",
	
	elements = {
	MenuButton:new( resume, "Resume", "center",160 ),
	MenuButton:new( returnToMainMenu, "Exit level", "center",195 ),
	
	MenuText:new( "Paused", { 219 / 255,244 / 255,252 / 255 }, "center",80, "center", 0, 2,2 ),
	},
}


menu_pause = menu

return file