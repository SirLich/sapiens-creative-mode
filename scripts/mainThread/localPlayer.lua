--- CreativeMode: localPlayer.lua
--- @author SirLich

local mod = {
	loadOrder = 1,
}

local creativeMode = mjrequire "creativeMode/creativeMode"

function mod:onload(localPlayer)
	local super_setBridge = localPlayer.setBridge
	localPlayer.setBridge = function(self, bridge, clientState)
		super_setBridge(localPlayer, bridge, clientState)

		creativeMode:init(clientState)
	end
end

return mod