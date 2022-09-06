--- CreativeMode: world.lua
--- Only really around to shadow some UI stuff, and make them exposed.
--- @author SirLich

local mod = {
	loadOrder = 1
}

-- TODO: This could be combined with the function in constructableUIHelper.lua
local function isUIUnlocked()
	local saveState = mjrequire "hammerstone/state/saveState"
	local isUnlocked =  saveState:getValue('cm.uiUnlocked', {
		default=false
	})

	return isUnlocked
end

function mod:onload(world)
	local super_tribeHasSeenResource = world.tribeHasSeenResource
	world.tribeHasSeenResource = function(self, resourceTypeIndex)
		return isUIUnlocked() or super_tribeHasSeenResource(self, resourceTypeIndex)
	end

	local super_tribeHasSeenResourceObjectTypeIndex = world.tribeHasSeenResourceObjectTypeIndex
	world.tribeHasSeenResourceObjectTypeIndex = function(self, resourceTypeIndex)
		return isUIUnlocked() or super_tribeHasSeenResourceObjectTypeIndex(self, resourceTypeIndex)
	end
end

return mod