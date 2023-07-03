--- CreativeMode: constructableUIHelper.lua
--- @author SirLich

local mod = {
	loadOrder = 1
}

-- Sapiens
local shadow = mjrequire "hammerstone/utils/shadow"

local function isUIUnlocked()
	local saveState = mjrequire "hammerstone/state/saveState"
	local isUnlocked =  saveState:getValue('cm.uiUnlocked', {
		default=false
	})

	return isUnlocked
end

--- @shadow
function mod:checkHasSeenRequiredResources(super, constructableType, missingResourceGroups)
	return isUIUnlocked() or super(self, constructableType, missingResourceGroups)
end

--- @shadow
function mod:checkHasSeenRequiredTools(super, constructableType, missingTools)
	return isUIUnlocked() or super(self, constructableType, missingTools)
end

--- @shadow
function mod:checkHasRequiredDiscoveries(super, constructableType)
	return isUIUnlocked() or super(self, constructableType)
end


return shadow:shadow(mod)