local file = {priority = -1}

shader_screen = lg.newShader[[
    vec4 effect( vec4 color, Image texture, vec2 tc, vec2 sc ){
		
		vec4 pixel = Texel( texture, tc );

    // return 
		return pixel;

    }
]]



function file:init()
end

local function sendToShaderEveryFrame()
  --shader_screen:send( "time", time )
  --shader_screen:send( "health", Player.health )
  --shader_screen:send( "maxHealth", Player.maxHealth )
end

function file:update()
  sendToShaderEveryFrame()
end

function file:draw()
end

-- [[ RETURN ]] --
return file