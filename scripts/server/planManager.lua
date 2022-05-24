--- Shadow of planManager.lua
-- @author SirLich

-- function planManager:addTerrainModificationPlan(tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)

local mod = {
	loadOrder = 1
}

-- Sapiens
local serverTerrain = mjrequire "server/serverTerrain"
local plan = mjrequire "common/plan"
local constructable = mjrequire "common/constructable"


function mod:onload(planManager)
	local superAddTerrainModificationPlan = planManager.addTerrainModificationPlan
	planManager.addTerrainModificationPlan = function(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
		-- TODO: Replace this with a server-compatible check for instant-build mode.
		if vertIDs and vertIDs[1] then
			for i, vertID in ipairs(vertIDs) do
				-- Filling
				if planTypeIndex == plan.types.fill.index then
					local objectTypeCounts = {
						[fillConstructableTypeIndex] = 1
					}

					-- local constructableType = constructable.types[fillConstructableTypeIndex]
					serverTerrain:fillVertex(vertID, objectTypeCounts, tribeID)

			    -- Digging
				else
					serverTerrain:digVertex(vertID, tribeID)
				end
			end
		else
			superAddTerrainModificationPlan(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
		end
	end
end


return mod
