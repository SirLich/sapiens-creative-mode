--- CreativeMode: world.lua
--- Only really around to shadow some UI stuff, and make them exposed.
--- @author SirLich

local worldModule = {
	loadOrder = 1
}

-- Hammerstone
local shadow = mjrequire "hammerstone/utils/shadow"

-- TODO: This could be combined with the function in constructableUIHelper.lua
local function isUIUnlocked()
	local saveState = mjrequire "hammerstone/state/saveState"
	local isUnlocked =  saveState:getValue('cm.uiUnlocked', {
		default=false
	})

	return isUnlocked
end

--- @shadow
function worldModule:tribeHasSeenResource(super, resourceTypeIndex)
	return isUIUnlocked() or super(self, resourceTypeIndex)
end

--- @shadow
function worldModule:tribeHasSeenResourceObjectTypeIndex(super, resourceTypeIndex)
	return isUIUnlocked() or super(self, resourceTypeIndex)
end

return shadow:shadow(worldModule)