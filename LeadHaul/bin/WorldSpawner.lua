local file = {priority = .11}

WorldSpawner = { }

local function setPlayerViewDir()
	Player.cam.dir = math.angle( Player.x,Player.z, WorldSpawner.playerLookTarget.x,WorldSpawner.playerLookTarget.z ) + rad( 90 )
	Player:parentCamera()
end

local function setPlayerPos( x,z )
	WorldSpawner.playerSpawn = { x = x, z = z }
	Player:setPos( x + .5, Player.y, z + .5 )

	setPlayerViewDir()
end

local function setPlayerLookTarget( x,z )
	WorldSpawner.playerLookTarget = { x = x + .5, z = z + .5 }

	setPlayerViewDir()
end

function WorldSpawner:new( )
	local inst = Class:init( WorldSpawner )
	
	inst.cursor = { x = 0, z = 0 }
	inst.playerSpawn = { x = 0, z = 0 }
	inst.playerLookTarget = { x = 0, z = 0 }

	inst.elementColors = {
	{ 64,64,64 },
	{ 128,128,128 },
	{ 76,255,0 },
	{ 255,0,0 },
	{ 0,38,255 },
	{ 91,127,0 },
	
	{ 127,201,255 },
	{ 127,146,255 },
	
	{ 63,100,127 },
	{ 63,73,127 },
	
	{ 127,51,0 },
	{ 127,0,0 },

	{ 192,192,192 },
	{ 255,255,255 },

	{ 0,255,255 },

	{ 178,0,255 },
	{ 255,0,110 },
	{ 255,0,220 },

	{ 182,255,0 },
	{ 38,127,0 },
	}
	
	inst.elements = {
	{ func = Door.new, args = { Door, false, "/x","/z" } },
	{ func = Door.new, args = { Door, "none", "/x","/z" } },
	{ func = Door.new, args = { Door, "green", "/x","/z" } },
	{ func = Door.new, args = { Door, "red", "/x","/z" } },
	{ func = Door.new, args = { Door, "blue", "/x","/z" } },
	{ func = Door.new, args = { Door, "none", "/x","/z", true } },
	
	{ func = Glass.new, args = { Glass, "/x","/z", false } },
	{ func = Glass.new, args = { Glass, "/x","/z", true } },
	
	{ func = Bars.new, args = { Bars, "/x","/z", false } },
	{ func = Bars.new, args = { Bars, "/x","/z", true } },
	
	{ func = Interactable.new, args = { Interactable, "/x","/z", false } },
	{ func = Interactable.new, args = { Interactable, "/x","/z", true } },
	
	{ func = PushWall.new, args = { PushWall, { 1,1,1, .075 }, "/x","/z", .02 } },
	{ func = PushWall.new, args = { PushWall, { 1,1,1, .11 }, "/x","/z", .06 } },

	{ func = SecretArea.new, args = { SecretArea, "/xp.5","/zp.5" } },

	{ func = Fan.new, args = { Fan, 1.25, "/x","/z" } },
	{ func = Fan.new, args = { Fan, 2, "/x","/z" } },
	{ func = Fan.new, args = { Fan, 5.5, "/x","/z" } },

	{ func = setPlayerPos, args = { "/x","/z" } },
	{ func = setPlayerLookTarget, args = { "/x","/z" } },
	}
	
	inst.entityColors = {
	{ 76,255,0 },
	{ 255,0,0 },
	{ 0,38,255 },
	
	{ 255,178,127 },
	{ 255,127,127 },
	{ 127,201,255 },
	{ 218,255,127 },
	{ 255,233,127 },
	{ 214,127,255 },
	{ 255,127,237 },

	{ 127,255,197 },
	{ 165,255,127 },
	{ 63,127,98 },
	{ 82,127,63 },

	{ 127,63,63 },
	{ 127,89,63 },
	{ 63,100,127 },
	{ 127,63,118 },
	
	{ 255,0,110 },
	{ 255,0,220 },
	{ 178,0,255 },
	{ 72,0,255 },
	{ 127,0,55 },
	{ 20,105,195 },
	}
	
	inst.entities = {
	{ func = Pickup.new, args = { Pickup, pickup_greenkey, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_redkey, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_bluekey, "/x",0,"/z" } },
	
	{ func = Pickup.new, args = { Pickup, pickup_bullets, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_shells, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_energy, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_explosives, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_goldenMelee, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_lootchest, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_vitalitychest, "/x",0,"/z" } },

	{ func = Pickup.new, args = { Pickup, pickup_medkit, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_medpouch, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_rum, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_barrelorum, "/x",0,"/z" } },

	{ func = Pickup.new, args = { Pickup, pickup_shotgun, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_machinegun, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_chargerifle, "/x",0,"/z" } },
	{ func = Pickup.new, args = { Pickup, pickup_rocketlauncher, "/x",0,"/z" } },
	
	{ func = Enemy.new, args = { Enemy, enemy_deckhand, "/xp.5",0,"/zp.5" } },
	{ func = Enemy.new, args = { Enemy, enemy_boatswain, "/xp.5",0,"/zp.5" } },
	{ func = Enemy.new, args = { Enemy, enemy_powdermonkey, "/x",0,"/zp.5" } },
	{ func = Enemy.new, args = { Enemy, enemy_cooper, "/xp.5",0,"/zp.5" } },
	{ func = Enemy.new, args = { Enemy, enemy_striker, "/xp.5",0,"/zp.5" } },
	{ func = Enemy.new, args = { Enemy, enemy_captain, "/xp.5",0,"/zp.5" } },
	}
	
	return inst
end

function WorldSpawner.spawnElement( self, color, x,z )
	self:spawnThing( self.elements, self.elementColors, color, x,z )
end

function WorldSpawner.spawnEntity( self, color, x,z )
	self:spawnThing( self.entities, self.entityColors, color, x,z )
end

function WorldSpawner.spawnThing( self, thingTbl,colorTbl, color, x,z )
	color = { color[1] * 255, color[2] * 255, color[3] * 255 }
	
	self.cursor.x = x
	self.cursor.z = z
	
	for i, ec in pairs( colorTbl ) do
		if ec[1] == color[1] and ec[2] == color[2] and ec[3] == color[3] then
			local args = {}

			for j = 1, #thingTbl[i].args do
				local a = thingTbl[i].args[j]
				args[j] = thingTbl[i].args[j]
			end
			
			for i, arg in pairs( args ) do
				if arg == "/x" then args[i] = self.cursor.x end
				if arg == "/z" then args[i] = self.cursor.z end
				if arg == "/xp.5" then args[i] = self.cursor.x + .5 end
				if arg == "/zp.5" then args[i] = self.cursor.z + .5 end
			end
			
			thingTbl[i].func( unpack( args ) )
			
		end
	end
end


function file:init()
	WorldSpawner = WorldSpawner:new()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file