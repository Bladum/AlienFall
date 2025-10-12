local file = {priority = -1}

-- [ OTHER ] --
function math.dist(x1,y1,x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5 
end

function math.dist3D(x1,y1,z1, x2,y2,z2)
	return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5
end
	
function math.angle(x1,y1, x2,y2)
	return math.atan2(y2-y1, x2-x1)
end
	
function collision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
	   y1 < y2+h2 and
	   x2 < x1+w1 and
	   y2 < y1+h1
end

function circleCollision(x1,y1,r1, x2,y2,r2)
	return math.dist(x1,y1, x2,y2) < r1 + r2
end

function boolToNumb(x, neg)	-- returns 1 if x is true, 0 if x is false, -1 if x is false and neg is true
	return x and 1 or ( neg and -1 or 0 )
end

function even(n)	
	return n % 2 == 0 and n or n + 1
end

function lerp(a,b,t) return (1-t)*a + t*b end

function sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function rsign() return love.math.random(2) == 2 and 1 or -1 end

function clamp(low, n, high) return min(max(low, n), high) end

function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

function contains(tbl, item)
	for i = 1, #tbl do
		if compare(tbl[i], item) then
			return true, i
		end
	end
	return false
end

function compare(t1,t2,ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not compare(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not compare(v1,v2) then return false end
	end
	return true
end

function minDist(x,y, tbl)	--each entry in table needs to include an x and y component
	local dist = math.dist(x,y, tbl[1].x,tbl[1].y)
	
	for i = 2, #tbl do
		local t = tbl[i]
		local d = math.dist(x,y, t.x,t.y)
		
		dist = d < dist and d or dist
	end
	
	return dist
end

-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
	local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
	local det,x,y = a1*b2 - a2*b1
	if det==0 then return false, "The lines are parallel." end
	x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
	if seg1 or seg2 then
		local min,max = math.min, math.max
		if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
		   seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
			return false, "The lines don't intersect."
		end
	end
	return x,y
end

-- Save copied tables in `copies`, indexed by original table.
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function floatRand(minimum,maximum,scale)
	scale = scale or 10000
	return math.random(minimum * scale, maximum * scale) / scale
end

function freeze(t)
	lt.sleep(t or (1 / 60))
end

function split( str, split )
	local list = {}
	local obj = ""
	local cha = ""
	
	for i = 1, #str do
		cha = str:sub( i, i )
		if cha == split then
			table.insert( list, obj )
			obj = ""
		else
			obj = obj..cha
		end
		
	end
	table.insert( list, obj )
	
	return list
end

function trim( str )
   return ( str:gsub( "^%s*(.-)%s*$", "%1" ) )
end

function removeFromTable( tbl, item )
	for i, o in pairs( tbl ) do
		if o == item then
			table.remove( tbl, i )
		end
	end
end

audioSources = {}
function playSound(sound,volume,pitch,minPitch)
	pitch = pitch or 1
	if minPitch == nil then
		minPitch = 0.1
	end
	if pitch < minPitch then
		pitch = minPitch
	end
	s = sound:clone()
	s:setVolume(volume)
	s:setPitch(pitch)
	
	table.insert( audioSources, {sound = s, timer = 0} )
	
	love.audio.play(s)

end

function file:update()
	for i, a in pairs( audioSources ) do
		a.timer = a.timer + hdt
		
		if a.timer > 5 then
			la.stop(a.sound)
			table.remove( audioSources,i )
		end
	end
end

-- [[ RETURN ]] --
return file