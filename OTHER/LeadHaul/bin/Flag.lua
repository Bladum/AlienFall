local file = {priority = .1}

Flag = { list = {} }

function Flag:new( id )
	local inst = Class:init( Flag )

	inst.id = id

	table.insert( Flag.list, inst )

	return inst
end


function Flag.isSet( self, id )
	for i, f in pairs( Flag.list ) do
		if f.id == id then
			return f
		end
	end
	
	return false
end


function Flag.destroy( self )
	removeFromTable( Flag.list, self )
end


function file:init()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file