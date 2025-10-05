local file = {priority = .1}

Sprite = { list = {}, dir = 0, pitch = 0 }

local verts = {
{ -.5, .5, 0, 0,1 },
{ .5, .5, 0, 1,1 },
{ .5, -.5, 0, 1,0 },
{ -.5, -.5, 0, 0,0 },
{ -.5, .5, 0, 0,1 },
{ .5, -.5, 0, 1,0 }
}

function Sprite:new( img, x,y,z, scale, center )
	local inst = Class:init( Sprite, Entity, { x,y,z } )
	
	inst.img = img or i_error
	inst.hitTimer = 0
	
	inst.hidden = false
	
	inst.center = center or false
	inst.scaleX = scale or 1
	inst.scaleY = scale or 1
	inst.scaleZ = scale or 1
	
	if not inst.center then
		inst.y = inst.y - .5 * inst.scaleY
		inst.parentOffset.y = inst.parentOffset.y - .5 * inst.scaleY
	end
	
	inst.model = g3d.newModel( verts, inst.img, { inst.x,inst.y,inst.z }, nil, { inst.scaleX,inst.scaleY,inst.scaleZ } )
	
	table.insert( Sprite.list, inst )
	
	return inst
end


function Sprite.applyAnimation( self, anim )
	Sprite.applySpriteSheet( self, anim )
end

function Sprite.applySpriteSheet( self, sheet )
	local fillColor = self.model.fillColor
	local outlineColor = self.model.outlineColor

	self.img = sheet.img
	self.model = sheet.model
	self.model:setTranslation( self.x,self.y,self.z )
	self.model:setScale( self.scaleX,self.scaleY,self.scaleZ )
	self:setDirection()
	
	self:setHit( self.hitTimer )
	
	self.model.fillColor = fillColor
	self.model.outlineColor = outlineColor
end

function Sprite.setScale( self, sx,sy,sz )
	self.scaleX = sx
	self.scaleY = sy or sx
	self.scaleZ = sz or sx
	
	self.model:setScale( self.scaleX,self.scaleY,self.scaleZ )
end

function Sprite.setPos( self, x,y,z )
	Entity.setPos( self, x,y,z )
	
	self.model:setTranslation( self.x,self.y,self.z )
end

function Sprite.setHit( self, timer )
	self.hitTimer = timer
end

function Sprite.hide( self )
	self.hidden = true
end

function Sprite.reveal( self )
	self.hidden = false
end


function Sprite.setDirection( self )
	local dir = Sprite.dir
	local pitch = 0
	if self.center then
		pitch = Sprite.pitch
	end
	
	self.model:setRotation( 0, dir, pitch  )
end

function Sprite.updateHit( self )
	self.hitTimer = max( 0, self.hitTimer - hdt )
end

function Sprite.update( self )
	self:setDirection()
	self:updateHit()
end


function Sprite.destroy( self )
	Entity.destroy( self )

	removeFromTable( Sprite.list, self )
end


function file:init()
	i_error = lg.newImage( "assets/error.png" )
end

local function _calcSpriteRotation()
	local vx,vy,vz = g3d.camera.getLookVector()
	Sprite.dir = math.pi/2 - math.atan2( vz, vx )
	Sprite.pitch = tan( -vy )
end

local function _updateSprites()
	for i, s in pairs( Sprite.list ) do
		s:update()
	end
end

function file:update()
	_calcSpriteRotation()
	_updateSprites()
end


local function _drawSprites()
	for i, s in pairs( Sprite.list ) do
		if not s.hidden then
			s.model:draw()
		end
	end
end

function file:draw()
	_drawSprites()
end

-- [[ RETURN ]] --
return file