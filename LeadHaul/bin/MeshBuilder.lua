local file = {priority = .1}

MeshBuilder = {}

function MeshBuilder:new( )
	local inst = Class:init( MeshBuilder )
	
	inst.textureStep = World.textureSize / World.textureAtlas:getWidth()
	
	return inst
end

function MeshBuilder.getUVs( self, u,v )
	return u * self.textureStep, v * self.textureStep, ( u + 1 ) * self.textureStep, ( v + 1 ) * self.textureStep
end

function MeshBuilder.buildFloor( self, verts, x,z, w, quadX,quadY )
	local u,v,nu,nv = self:getUVs( quadX,quadY )
	u = u + .5
	nu = nu + .5
	

	verts[#verts + 1] = { x,0,z, u,v }
	verts[#verts + 1] = { x + w,0,z, nu,v }
	verts[#verts + 1] = { x + w,0,z + w, nu,nv }
	
	verts[#verts + 1] = { x,0,z + w, u,nv }
	verts[#verts + 1] = { x,0,z, u,v }
	verts[#verts + 1] = { x + w,0,z + w, nu,nv }
	
	return verts
end

function MeshBuilder.buildCeiling( self, verts, x,z, w, quadX,quadY )
	local u,v,nu,nv = self:getUVs( quadX,quadY )
	u = u + .5
	nu = nu + .5
	v = v + .5
	nv = nv + .5
	
	
	verts[#verts + 1] = { x + w,-w,z, nu,v }
	verts[#verts + 1] = { x,-w,z, u,v }
	verts[#verts + 1] = { x + w,-w,z + w, nu,nv }
	
	verts[#verts + 1] = { x,-w,z, u,v }
	verts[#verts + 1] = { x,-w,z + w, u,nv }
	verts[#verts + 1] = { x + w,-w,z + w, nu,nv }
	
	return verts
end


function MeshBuilder.buildWallNorth( self, verts, x,z, w, quadX,quadY )
	local u,v,nu,nv = self:getUVs( quadX,quadY )

	verts[#verts + 1] = { x + w,0,z, u,nv }
	verts[#verts + 1] = { x,0,z, nu,nv }
	verts[#verts + 1] = { x + w,-w,z, u,v }
	
	verts[#verts + 1] = { x,0,z, nu,nv }
	verts[#verts + 1] = { x,-w,z, nu,v }
	verts[#verts + 1] = { x + w,-w,z, u,v }
	
	return verts
end

function MeshBuilder.buildWallSouth( self, verts, x,z, w, quadX,quadY )
	local u,v,nu,nv = self:getUVs( quadX,quadY )

	verts[#verts + 1] = { x,0,z + w, u,nv }
	verts[#verts + 1] = { x + w,0,z + w, nu,nv }
	verts[#verts + 1] = { x + w,-w,z + w, nu,v }
	
	verts[#verts + 1] = { x,-w,z + w, u,v }
	verts[#verts + 1] = { x,0,z + w, u,nv }
	verts[#verts + 1] = { x + w,-w,z + w, nu,v }
	
	return verts
end

function MeshBuilder.buildWallWest( self, verts, x,z, w, quadX,quadY )
	local u,v,nu,nv = self:getUVs( quadX,quadY )
	v = v + .5
	nv = nv + .5
	
	verts[#verts + 1] = { x,0,z, u,nv }
	verts[#verts + 1] = { x,0,z + w, nu,nv }
	verts[#verts + 1] = { x,-w,z + w, nu,v }
	
	verts[#verts + 1] = { x,-w,z, u,v }
	verts[#verts + 1] = { x,0,z, u,nv }
	verts[#verts + 1] = { x,-w,z + w, nu,v }
	
	return verts
end

function MeshBuilder.buildWallEast( self, verts, x,z, w, quadX,quadY )
	local u,v,nu,nv = self:getUVs( quadX,quadY )
	v = v + .5
	nv = nv + .5
	
	verts[#verts + 1] = { x + w,0,z + w, u,nv }
	verts[#verts + 1] = { x + w,0,z, nu,nv }
	verts[#verts + 1] = { x + w,-w,z + w, u,v }
	
	verts[#verts + 1] = { x + w,0,z, nu,nv }
	verts[#verts + 1] = { x + w,-w,z, nu,v }
	verts[#verts + 1] = { x + w,-w,z + w, u,v }
	
	return verts
end



function file:init()
	MeshBuilder = MeshBuilder:new()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file