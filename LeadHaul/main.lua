function love.load()
	--shorthands
	lg = love.graphics
	la = love.audio
	lm = love.mouse
	lk = love.keyboard
	lf = love.filesystem
	li = love.image
	lt = love.timer
	lw = love.window
	max = math.max
	min = math.min
	rad = math.rad
	deg = math.deg
	sin = math.sin
	cos = math.cos
	tan = math.tan
	atan = math.atan
	floor = math.floor
	ceil = math.ceil
	abs = math.abs
	random = love.math.random
	time = 0
	pi = math.pi
	
	lg.setDefaultFilter("nearest")
	
	--require files
	g3d = require( "g3d" )
	
	fileHandler = require("libs.fileHandler")
	fileHandler:requireFiles("bin")
	fileHandler:requireFiles("libs")
	fileHandler:requireFiles("objects")
	fileHandler:initScripts()
	
	lg.setCanvas()

	--set fullscreen
	love.window.setFullscreen( true )
end

function love.update(dt)

	hdt = min( dt, 1 / 15 )

	time = time + hdt
	fileHandler:updateScripts()
end

function love.draw(dt)
	fileHandler:drawScripts()
	
	-- temp dev stuff
	lg.setColor( 1,0,1 )
	--lg.print( "FPS: "..love.timer.getFPS()..", X: "..floor(Player.x)..", Z: "..floor(Player.z), 10,10 )
end