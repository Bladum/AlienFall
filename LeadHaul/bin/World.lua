local file = {priority = 0}

World = {}

function World:new( )
	local inst = Class:init( World )
	
	inst.textureAtlas = lg.newImage( "assets/worldAtlas.png" )
	inst.textureSize = 32

	inst.occlusionArray = {}

	inst.fillColor = { 1,1,1, .03 }
	
	return inst
end

function World.buildOcclusionArray( self )
	local map = self.occlusionMap
	local w,h = map:getWidth(),map:getHeight()
	local array = {}

	for x = 0, w - 1 do
		array[x] = {}
		for z = 0, h - 1 do
			local pixel = Canvas.getPixel( map, x,z )

			array[x][z] = pixel == 0
		end
	end

	self.occlusionArray = array
end
function World.addElements( self, map )
	local w,h = map:getWidth(),map:getHeight()
	
	for x = 0, w - 1 do
		for z = 0, h - 1 do
			local cr,cg,cb = Canvas.getPixel( map, x,z )
			
			WorldSpawner:spawnElement( { cr,cg,cb }, x,z )
		end
	end
end
function World.addEntities( self, map )
	local w,h = map:getWidth(),map:getHeight()
	
	for x = 0, w - 1 do
		for z = 0, h - 1 do
			local cr,cg,cb = Canvas.getPixel( map, x,z )
			
			WorldSpawner:spawnEntity( { cr,cg,cb }, x,z )
		end
	end
end
function World.addProps( self, map )
	local w,h = map:getWidth(),map:getHeight()
	
	for x = 0, w - 1 do
		for z = 0, h - 1 do
			local cr,cg,cb,ca = Canvas.getPixel( map, x,z )
			
			if ca > 0 then
				Prop:new( x,z, cr / self.textureSize * Prop.atlas:getWidth(),cg > 0 and 1 or 0 )
			end
		end
	end
end
function World.loadLevel( self, level )
	local path = "levels/"..level
	
	MusicPlayer:stop()

	self:clear()

	self.occlusionMap = Canvas.fromImage( lg.newImage( path.."/occ.png" ) ):newImageData()
	self.textureMap = Canvas.fromImage( lg.newImage( path.."/texture.png" ) ):newImageData()
	self.elementMap = Canvas.fromImage( lg.newImage( path.."/elements.png" ) ):newImageData()
	self.entityMap = Canvas.fromImage( lg.newImage( path.."/entities.png" ) ):newImageData()
	self.idMap = Canvas.fromImage( lg.newImage( path.."/ids.png" ) ):newImageData()
	self.propMap = Canvas.fromImage( lg.newImage( path.."/props.png" ) ):newImageData()
	
	if lf.getInfo( path.."/onstart.txt" ) then
		local ok, onStartFunc = pcall( load( lf.read( path.."/onstart.txt" ) ) )
		if ok then
			onStartFunc( )
		end
	end

	self.levelName = level
	self.nextlevel = lf.read( path.."/nextlevel.txt" )

	self:buildOcclusionArray()
	self:build( )

	self:addElements( self.elementMap )
	self:addEntities( self.entityMap )
	self:addProps( self.propMap )

	if lf.read( path.."/song.txt" ) ~= "" then
		MusicPlayer:setSong( la.newSource( "assets/audio/music/"..lf.read( path.."/song.txt" ), "static" ) )
		MusicPlayer:play()
	end

	Player.keys = {}
end

function World.build( self, map )
	map = map or self.occlusionMap
	
	local verts = {}
	local texture = self.textureAtlas
	local mapW,mapL = map:getWidth(), map:getHeight()
	
	for x = 0, mapW - 1 do
		for z = 0, mapL - 1 do
			
			local pixel = Canvas.getPixel( map, x,z )
			local pixelNorth = Canvas.getPixel( map, x,z - 1 )
			local pixelSouth = Canvas.getPixel( map, x,z + 1 )
			local pixelWest = Canvas.getPixel( map, x - 1,z )
			local pixelEast = Canvas.getPixel( map, x + 1,z )
			
			local quadX,quadY = self:getTexture( x,z )
			
			if pixel == 1 then
				verts = MeshBuilder:buildFloor( verts, x,z, 1, quadX,quadY )
				verts = MeshBuilder:buildCeiling( verts, x,z, 1, quadX,quadY )
				
				if pixelNorth == 0 then
					verts = MeshBuilder:buildWallNorth( verts, x,z, 1, quadX,quadY )
				end
				if pixelSouth == 0 then
					verts = MeshBuilder:buildWallSouth( verts, x,z, 1, quadX,quadY )
				end
				if pixelWest == 0 then
					verts = MeshBuilder:buildWallWest( verts, x,z, 1, quadX,quadY )
				end
				if pixelEast == 0 then
					verts = MeshBuilder:buildWallEast( verts, x,z, 1, quadX,quadY )
				end
			end
			
		end
	end
	
	self.model = g3d.newModel( verts, texture )
	self.model.fillColor = self.fillColor
	
end

function World.clear( self )
	for j = 1, 10 do
		for i, e in pairs( Entity.list ) do
			if not e.isPlayer and not e.parent then
				e:destroy()
			end
		end
		Wind.map = lg.newCanvas( 300,300 ):newImageData()
	end
	Flag.list = {}

	SecretArea.totalSecrets = 0
	SecretArea.secretsFound = 0
	Enemy.killed = 0
	Enemy.totalCount = 0
end

function World.getTexture( self, x,z )
	local tr,tg,tb,ta = Canvas.getPixel( self.textureMap, x,z )
	local step = 8
	
	return floor( tr * step + .5 ), floor( tg * step + .5 )
end

function World.setTexture( self, x,z, tx,ty )
	local step = 8

	Canvas.setPixel( self.textureMap, x,z, { tx / step,ty / step, 0 } )
	
	self:build()
end

function World.isOccluded( self, x,z )
	x = min( max( 0, x ), #self.occlusionArray -1 )
	z = min( max( 0, z ), #self.occlusionArray[1] -1 )

	return self.occlusionArray[floor( x )][floor( z )]
end

function World.getId( self, x,z )
	local r,g,b = Canvas.getPixel( self.idMap, x,z )
	local val = r + g * 10 + b * 100
	
	return val
end



function file:init()
	World = World:new()
end

function file:update()
end

function file:draw()
	World.model:draw()
end

-- [[ RETURN ]] --
return file