local handler = {scriptList = {}}

function handler:requireFiles(dir)
	local items = lf.getDirectoryItems( dir )
	
	for i = 1, #items do
		local item = items[i]
		
		if item:sub(item:len()-3) == ".lua" then
			if item ~= "fileHandler.lua" then
				print("required: "..item.." in "..dir)
				
				local script = require(dir.."/"..item:sub(1, item:len() - 4))
				if script and script ~= true and not script.ignore then
					table.insert(handler.scriptList, script)
				end
			end
		else
			handler:requireFiles(dir.."/"..item)
		end
		
	end
end

local function sortScriptList(o1, o2)
	if o1.priority and o2.priority then
		return o1.priority < o2.priority
	else
		return true
	end
end
function handler:initScripts()
	table.sort(handler.scriptList, sortScriptList)
	for i = 1, #handler.scriptList do
		local script = handler.scriptList[i]
		
		if script.init then
			script:init()
		end
	end
end

function handler:updateScripts()
	for i = 1, #handler.scriptList do
		local script = handler.scriptList[i]
		
		if script.update then
			script:update()
		end
	end
end

function handler:drawScripts()
	for i = 1, #handler.scriptList do
		local script = handler.scriptList[i]
		
		if script.draw then
			script:draw()
		end
	end
end

return handler