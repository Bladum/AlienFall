local file = {priority = -1}

Game = {}

function Game:new( )
	local inst = Class:init( Game )
	
	lg.setMeshCullMode( "back" )
	inst.state = "mainmenu" -- playing, gameover, mainmenu, paused, endscreen, settings, levelselect
	
	return inst
end


function Game.update( self )
end


function file:init()
	Game = Game:new()
end

function file:update()
	Game:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file