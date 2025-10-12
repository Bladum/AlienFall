local file = {priority = 0}

Juice = { list = {} }

function Juice:new( )
	local juice = Class:init( Juice )
	
	juice.offset = { x = 0, y = 0, z = 0 }
	juice.rot = 0
	juice.scale = 1
	
	juice.shakeAmount = 0
	juice.shakeDecrease = .4
	
	juice.rotAmount = 0
	juice.rotChange = 1
	
	juice.scaleChange = 1
	
	return juice
end


function Juice.getOffset( self )
	return self.offset.x, self.offset.y, self.offset.z
end

function Juice.getRotation( self )
	return self.rot
end

function Juice.getScale( self )
	return self.scale
end


function Juice.freeze( self, t )
	t = t or ( 1 / 30 )
	love.timer.sleep( t )
end

function Juice.shake( self, amount )
	self.shakeAmount = amount or 0
end

function Juice.tilt( self, tilt )
	self.rotAmount = tilt or 0
end

function Juice.zoom( self, zoom )
	self.scale = zoom or 1
end


function Juice.updateScale( self )
	if self.scale > 1 then
		self.scale = max( self.scale - self.scaleChange * hdt, 1 )
	end
	if self.scale < 1 then
		self.scale = min( self.scale + self.scaleChange * hdt, 1 )
	end
end

function Juice.updateRotation( self )
	self.rotAmount = max( self.rotAmount - self.rotChange * hdt, 0 )
	self.rot = math.random() * self.rotAmount * rsign()
end

function Juice.updateShake( self )
	self.shakeAmount = max( self.shakeAmount - self.shakeDecrease * hdt, 0 )
	
	local dir = random() * pi * 2
	
	self.offset.x = cos( dir ) * self.shakeAmount
	self.offset.y = random() * self.shakeAmount
	self.offset.z = sin( dir ) * self.shakeAmount
end

function Juice.update( self )
	self:updateScale()
	self:updateRotation()
	self:updateShake()
end


function file:init()
	Juice = Juice:new()
end

function file:update()
	Juice:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file