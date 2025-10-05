local file = {priority = 0}

Canvas = {}

function Canvas:new( )
	local inst = Class:init( Canvas )
	
	return inst
end

function Canvas.fromImage( img, color )
	color = color or { 1,1,1 }

	local canvas = lg.newCanvas( img:getWidth(), img:getHeight() )
	local c_def = lg.getCanvas()
	local cr,cg,cb,ca = lg.getColor()
	
	lg.setCanvas( canvas )
	lg.scale( 1 / Hud.scaleX, 1 / Hud.scaleY )

	lg.setColor( color )
	lg.draw( img, 0,0 )
	
	lg.scale( Hud.scaleX, Hud.scaleY )
	lg.setCanvas( c_def )
	lg.setColor( cr,cg,cb,ca )
	
	return canvas
end

function Canvas.getPixel( data, x,y )
	if not data then return 0,0,0,0 end

	local w,h = data:getWidth(),data:getHeight()

	local r,g,b,a = data:getPixel(
	max( 0, min( w - .00001, x ) ),
	max( 0, min( h - .00001, y ) )
	)
	
	return r,g,b,a
end

function Canvas.setPixel( data, x,y, color )
	data:setPixel( x,y, color[1],color[2],color[3], color[4] or 1 )
end



function file:init()
	Canvas = Canvas:new()
end

function file:update()
end

function file:draw()
end

-- [[ RETURN ]] --
return file