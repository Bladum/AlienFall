local file = {priority = 11}

Hud = { }


function Hud:new( )
	local inst = Class:init( Hud )
	
	inst.defaultW,inst.defaultH = 1280,720
	inst.scale = 2
	inst.scaleX = 1
	inst.scaleY = 1
	inst.w,inst.h = inst.defaultW / inst.scale, inst.defaultH / inst.scale
	
	local font = lg.newImageFont("assets/fonts/default.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#.,!?: ]['%/=+ö?", 2)
	lg.setFont( font )
	
	return inst
end


function Hud.scaleCoords( self, scaleX,scaleY )
	self.scaleX = self.scaleX * scaleX
	self.scaleY = self.scaleY * scaleY
	lg.scale( scaleX,scaleY )
end


function Hud.drawScreen( self )
	lg.setCanvas()
	local w,h = lg.getDimensions()
	self:scaleCoords( w / Screen.width, h / Screen.height )

	lg.setColor( 1,1,1 )
	lg.setShader( shader_screen )
	lg.draw( Screen.canvas, 0,0 )
	lg.setShader()
end

function Hud.applyHudDrawingSettings( self )
	self:scaleCoords(
	Screen.width / self.defaultW * self.scale,
	Screen.height / self.defaultH * self.scale
	)
end

function Hud.drawCrosshair( self )
	local crosshair = Player.weapon.crosshair
	
	local img = crosshair.img
	local count = crosshair.count
	local angPosOffset = crosshair.angPosOffset
	local angRotOffset = crosshair.angRotOffset
	local posOffset = crosshair.posOffset
	local midX,midY = self.w * .5, self.h * .5
	
	local kickFactor = 1.5
	local kickPower = 2.5
	local attackTimerMax = Player.weapon.kickTime or Player.weapon.attackTimerMax
	local attack = min( 1, Player.attackTimer / attackTimerMax )
	local kick =  ( 1 - ( attack ^ kickPower ) ) * kickFactor * Player.weapon.kick
	
	local charge = 0
	if Player.weapon.chargeTime > 0 then
		charge = Player.chargeTimer / Player.weapon.chargeTime * rad( 90 )
	end
	
	local dist = sin( Player.weapon.aimOffset ) * 200 + posOffset + kick
	
	lg.setColor( 1,1,1 )
	for a = 0, math.pi * 2, math.pi * 2 / count do
		local ang = a + charge
	
		local x = midX + cos( ang + angPosOffset ) * dist
		local y = midY + sin( ang + angPosOffset ) * dist
	
		lg.draw( img, x,y, ang + angRotOffset, 1,1, img:getWidth() * .5, img:getHeight() * .5 )
	end
	
end

function Hud.drawHealth( self )
	local fontSpacing = 2
	local w,h = 100, 14
	local x,y = 10, self.h - 10 - h
	local str = "+"..floor( Player.health )
	
	-- bg
	lg.setColor( 25 / 255, 30 / 255, 60 / 255 )
	lg.rectangle( "fill", x,y, w,h )
	
	-- bar
	lg.setColor( 215 / 255, 45 / 255, 45 / 255 )
	lg.rectangle( "fill", x,y, w * Player.health / Player.maxHealth, h )
	
	lg.setColor( 1,1,1 )
	lg.print( str, x + fontSpacing,y )
	
end

function Hud.drawArmor( self )
	local fontSpacing = 2
	local w,h = 100, 14
	local x,y = 10, self.h - 28 - h
	local str = "?"..floor( Player.armor )
	
	-- bg
	lg.setColor( 25 / 255, 30 / 255, 60 / 255 )
	lg.rectangle( "fill", x,y, w,h )
	
	-- bar
	lg.setColor( 65 / 255, 205 / 255, 115 / 255 )
	lg.rectangle( "fill", x,y, w * Player.armor / Player.maxArmor, h )
	
	lg.setColor( 1,1,1 )
	lg.print( str, x + fontSpacing,y )
	
end

function Hud.drawAmmo( self )
	local ammo = Player.ammo[Player.weapon.ammoIndex]
	local fontSpacing = 2
	local w,h = 100, 14
	local x,y = self.w - w - 10, self.h - 10 - h
	local str = floor( ammo.count ).."ö"
	
	-- bg
	lg.setColor( 25 / 255, 30 / 255, 60 / 255 )
	lg.rectangle( "fill", x,y, w,h )
	
	-- bar
	lg.setColor( 255 / 255, 170 / 255, 50 / 255 )
	lg.rectangle( "fill", x + w - w * ammo.count / ammo.maxCount,y, w * ammo.count / ammo.maxCount, h )
	
	lg.setColor( 1,1,1 )
	lg.printf( str, x,y, w, "right" )
	
end

function Hud.drawKeys( self )
	local imgs = { i_hudRedKey,i_hudGreenKey,i_hudBlueKey }
	local keys = { "red","green","blue" }
	local spacing = 18
	local x,y = self.w - 18, self.h - 30
	
	lg.setColor( 1,1,1 )
	for i, pk in pairs( Player.keys ) do
		for j, k in pairs( keys ) do
			if k == pk then
				local img = imgs[j]
				
				lg.draw( img, x - spacing * ( i - 1 ),y, 0, 2,2, img:getWidth() * .5,img:getHeight() )
			end
		end
	end
end

function Hud.drawBossHealth( self )
	for i, e in pairs( Enemy.list ) do
		if e.isBoss and e.state ~= "idle" then
			local spacing = 100
			local width = self.w - spacing * 2
			local height = 10
			local y = 10
			local x = self.w * .5 - width * .5

			-- bg
			lg.setColor( 25 / 255, 30 / 255, 60 / 255 )
			lg.rectangle( "fill", x, y, width,height )
			
			-- bar
			lg.setColor( 215 / 255, 45 / 255, 45 / 255 )
			lg.rectangle( "fill", x,y, width * e.health / e.maxHealth,height )
		end
	end
end

function Hud.resetScale( self )
	self.scaleX = 1
	self.scaleY = 1
end

function Hud.drawEndGraphic( self )
	if World.levelName == "e1m6" and Enemy.killed == 1 then
		local img = i_hudEndText

		lg.setColor( 1,1,1 )
		lg.draw( img, self.w * .5,0, 0, 1,1, img:getWidth() * .5,0 )
	end
end

function Hud.draw( self )
	self:resetScale()

	self:drawScreen()

	self:applyHudDrawingSettings()

	if Game.state == "playing" then
		self:drawCrosshair()
		self:drawHealth()
		self:drawArmor()
		self:drawAmmo()
		self:drawKeys()
		self:drawBossHealth()
	end

	self:drawEndGraphic()
end


function file:init()
	i_hudGreenKey = lg.newImage( "assets/pickups/greenKey.png" )
	i_hudBlueKey = lg.newImage( "assets/pickups/blueKey.png" )
	i_hudRedKey = lg.newImage( "assets/pickups/redKey.png" )
	i_hudEndText = lg.newImage( "assets/hud/end.png" )

	Hud = Hud:new()
end

function file:update()
end

function file:draw()
	Hud:draw()
end

-- [[ RETURN ]] --
return file