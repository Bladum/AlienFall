local file = { priority = -100 }

local function copyClassFunctions( class, super, superClassArgs )
	local instance = {}
	if super then
		local superClassArgs = superClassArgs or {}
		instance = super:new( unpack( superClassArgs ) )
		instance.super = super
	end

	for key, value in pairs( class ) do
		if type( value ) == "function" then
			instance[ key ] = value
		end
	end
	
	return instance
end

Class = {}

function Class:init( class, superClass, superClassArgs )

	local instance = copyClassFunctions( class, superClass, superClassArgs )
	instance.new = function () end
	
	return instance
end

-- [[ RETURN ]] --
return file