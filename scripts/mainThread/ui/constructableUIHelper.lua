--- CreativeMode: constructableUIHelper.lua
--- @author SirLich

local mod = {
	loadOrder = 1
}

-- Sapiens
local mj = mjrequire "common/mj"

local function isUIUnlocked()
	local saveState = mjrequire "hammerstone/state/saveState"
	local isUnlocked =  saveState:getValue('cm.uiUnlocked', {
		default=false
	})

	return isUnlocked
end

function mod:onload(constructableUIHelper)

	-- Shadow checkHasSeenRequiredResources
	local super_checkHasSeenRequiredResources = constructableUIHelper.checkHasSeenRequiredResources
	constructableUIHelper.checkHasSeenRequiredResources = function(self, constructableType, missingResourceGroups)
		return isUIUnlocked() or super_checkHasSeenRequiredResources(self, constructableType, missingResourceGroups)
	end
	
	-- Shadow checkHasSeenRequiredTools
	local super_checkHasSeenRequiredTools = constructableUIHelper.checkHasSeenRequiredTools
	constructableUIHelper.checkHasSeenRequiredTools = function(self, constructableType, missingTools)
		return isUIUnlocked() or super_checkHasSeenRequiredTools(self, constructableType, missingTools)
	end
--- ****************************************************************
-- @author death-rae "Rae"

	-- Shadow checkHasRequiredDiscoveries
	-- this removes the need to unlock skills for unlocking the build UI
	local super_checkHasRequiredDiscoveries = constructableUIHelper.checkHasRequiredDiscoveries
	constructableUIHelper.checkHasRequiredDiscoveries = function(self, constructableType)
		return isUIUnlocked() or super_checkHasRequiredDiscoveries(self, constructableType)
	end
--- ****************************************************************
end

return mod