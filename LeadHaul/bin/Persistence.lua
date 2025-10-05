local file = {priority = .1}

Persistence = {}

function Persistence:new(  )
	local inst = Class:init( Persistence )

	inst.location = "savegames"
	lf.createDirectory( inst.location )

	return inst
end

function Persistence.save( self, name, location )
	name = name or os.date("%c", os.time())
	location = location or self.location
	lf.createDirectory( location )

	local path = location.."/"..name

	local saveString = "return function ()\n\n print('loading...')\n\n"
	
	-- save level
	saveString = saveString.."World:loadLevel( '"..World.levelName.."' )\n\n"

	-- save weapons
	saveString = saveString.."Player.weapons = {"
	for i, w in pairs( Player.weapons ) do
		saveString = saveString.."'"..w.."',"
	end
	saveString = saveString.."}\n\n"
	
	-- save ammo
	for i, a in pairs( Player.ammo ) do
		saveString = saveString.."Player.ammo["..i.."].count = "..a.count.."\n"
	end
	saveString = saveString.."\n"

	-- save golden melee
	saveString = saveString.."Player:setGoldenMelee("..tostring( Player.meleeGolden )..")\n\n"

	-- set health and armor
	saveString = saveString.."Player.health = "..Player.health.."\n"
	saveString = saveString.."Player.armor = "..Player.armor.."\n\n"

	-- set holding weapon
	saveString = saveString.."Player:switchWeapon( 1 )\n\n"

	-- finish
	saveString = saveString.."end"
	print("Save string: "..saveString)
	lf.write( path, saveString )
end


function Persistence.load( self, name, location )
	location = location or self.location
	local path = location.."/"..name

	local loadString = lf.read( path )

	if loadString then
		local ok, loadFunc = pcall( load( loadString ) )
		if ok then
			loadFunc( )
		else
			print( "Error loading file :/" )
		end
	else
		print( "File does not exist" )
		Player:setToStartState()
		World:loadLevel( "e1m1" )
		Persistence:save( name, location )
	end
end

function file:init()
	Persistence = Persistence:new()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file