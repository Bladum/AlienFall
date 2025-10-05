local file = {priority = 0}

Animation = { list = {} }



local function buildModels( inst )
	local models = {}
	local vs = deepcopy( verts )

	for i = 1, inst.frames do
	
		local u = ( i - 1 ) * inst.frameWidth
		local nu = i * inst.frameWidth
	
		local verts = {
		{ -.5, .5, 0, u,1 },
		{ .5, .5, 0, nu,1 },
		{ .5, -.5, 0, nu,0 },
		{ -.5, -.5, 0, u,0 },
		{ -.5, .5, 0, u,1 },
		{ .5, -.5, 0, nu,0 }
		}
		
		models[ i ] = g3d.newModel( verts, inst.img )
	end
	
	return models
end

function Animation:new( img, playTime )
	local inst = Class:init( Animation )
	
	if type( img ) == "string" then
		inst.img = lg.newImage( img )
	else
		inst.img = img
	end
	
	inst.playTime = playTime or 1
	inst.timer = 0
	inst.looping = true
	
	inst.frames = inst.img:getWidth() / inst.img:getHeight()
	inst.frameWidth = 1 / inst.frames
	
	inst.models = buildModels( inst )
	inst.model = inst.models[1]
	
	return inst
end


function Animation.setLooping( self, looping )
	self.looping = looping
end


function Animation.play( self )
	self.timer = ( self.timer + hdt )
	
	if self.looping then
		self.timer = self.timer % self.playTime
	end
	
	self.timer = min( self.playTime - .000001, self.timer )
	
	local index = floor( self.timer / self.playTime * self.frames ) + 1
	
	self.model = self.models[ index ]
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file