local file = { priority = 0 }

local function continue()
	if World.levelName == "e1m6" then
		Game.state = "mainmenu"
	else
		Game.state = "playing"
		World:loadLevel( World.nextlevel )
		Persistence:save( "Level start" )
	end
end

local function returnToMainMenu()
	Game.state = "mainmenu"
end

local function update( self )
	self.elements.killCount.label = "Kills: "..Enemy.killed.." / "..Enemy.totalCount
	self.elements.secretCount.label = "Secrets: "..SecretArea.secretsFound.." / "..SecretArea.totalSecrets

	if Enemy.killed == Enemy.totalCount then
		self.elements.killCount.color = { 1,230 / 25, 90 / 255 }
	else
		self.elements.killCount.color = { 1,1,1 }
	end
	if SecretArea.secretsFound == SecretArea.totalSecrets then
		self.elements.secretCount.color = { 1,230 / 25, 90 / 255 }
	else
		self.elements.secretCount.color = { 1,1,1 }
	end

	Player:parentCamera()

	if World.levelName == "e1m6" then
		self.elements.continueButton.label = "Return to menu"
	else
		self.elements.continueButton.label = "Continue"
	end
end

local x = 15
local menu = {
	state = "endscreen",
	
	elements = {
	continueButton = MenuButton:new( continue, "Continue", x, 360 - 25 - x ),
	
	MenuText:new( "Completed!", { 219 / 255,244 / 255,252 / 255 }, x,40, "left", 0, 2,2 ),
	killCount = MenuText:new( "Kills: 28 / 35", { 219 / 255,244 / 255,252 / 255 }, x,100, "left", 0, 1,1 ),
	secretCount = MenuText:new( "Secrets: 2 / 5", { 219 / 255,244 / 255,252 / 255 }, x,120, "left", 0, 1,1 ),
	},

	updateMenu = update,
}


menu_endscreen = menu

return file