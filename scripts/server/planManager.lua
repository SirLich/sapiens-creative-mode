--- CreativeMode: planManager.lua
--- @author SirLich

local mod = {
	loadOrder = 1,
	serverWorld = nil
}

-- Sapiens
local serverTerrain = mjrequire "server/serverTerrain"
local plan = mjrequire "common/plan"

-- Hammerstone
local saveState = mjrequire "hammerstone/state/saveState"

local function isInstantDig(tribeID)
	--- @param tribeID string: The ID of the tribe that you are testing for.
	--- @return boolean: True if the instant build mode is toggled on for the world.
		
	return saveState:getValue('cm.instantDig', {
		tribeID = tribeID,
		default = false
	})
end

function mod:onload(planManager)
	local super_init = planManager.init
	planManager.init = function(self, serverGOM, serverWorld, serverSapien, serverCraftArea)
		super_init(self, serverGOM, serverWorld, serverSapien, serverCraftArea)
		mod.serverWorld = serverWorld
	end

	local super_addTerrainModificationPlan = planManager.addTerrainModificationPlan
	planManager.addTerrainModificationPlan = function(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
		-- Custom implementation if instant build mode is on. Otherwise, just call the super.
		-- The extra validation is so we don't crash.
		if isInstantDig(tribeID) and vertIDs and vertIDs[1] then
			-- Filling
			if planTypeIndex == plan.types.fill.index then
				for i, vertID in ipairs(vertIDs) do

					local objectTypeCounts = {}
					objectTypeCounts[fillConstructableTypeIndex] = 100

					-- local constructableType = constructable.types[fillConstructableTypeIndex]
					serverTerrain:fillVertex(vertID, objectTypeCounts, tribeID)
				end

			-- Digging
			elseif planTypeIndex == plan.types.dig.index or
				planTypeIndex == plan.types.mine.index then

				for i, vertID in ipairs(vertIDs) do
					serverTerrain:digVertex(vertID, tribeID)
				end

			-- Clearing
			elseif planTypeIndex == plan.types.clear.index then
				for i, vertID in ipairs(vertIDs) do
					serverTerrain:removeVegetationForVertex(vertID)
					serverTerrain:removeSnowForVertex(vertID)
				end

			-- Unknown
			else
				super_addTerrainModificationPlan(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
			end
		else
			super_addTerrainModificationPlan(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
		end
	end
end

return mod
