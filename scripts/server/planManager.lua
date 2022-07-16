--- Shadow of planManager.lua
-- @author SirLich

local mod = {
	loadOrder = 1,
	serverWorld = nil
}

-- Base
local serverTerrain = mjrequire "server/serverTerrain"
local plan = mjrequire "common/plan"

-- Hammerstone
local saveState = mjrequire "hammerstone/state/saveState"

local function isInstantBuildMode(tribeID)
	-- @param tribeID: The ID of the tribe that you are testing for.
	-- @return boolean: True if the instant build mode is toggled on for the world.
	
	-- local clientID = mod.serverWorld:clientIDForTribeID(tribeID)
	-- local clientState = mod.serverWorld:getClientStates()[clientID]
	
	local ret = saveState.getValue('instantBuild')

	mj:log("InstantBuildMode called:")
	mj:log(ret)
	return ret
	
end

function mod:onload(planManager)
	local super_init = planManager.init
	planManager.init = function(self, serverGOM, serverWorld, serverSapien, serverCraftArea)
		super_init(self, serverGOM, serverWorld, serverSapien, serverCraftArea)
		mod.serverWorld = serverWorld
	end

	local super_addTerrainModificationPlan = planManager.addTerrainModificationPlan
	planManager.addTerrainModificationPlan = function(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
		mj:log("Calling Terrain Modification plan!")
		if isInstantBuildMode(tribeID) and vertIDs and vertIDs[1] then
			for i, vertID in ipairs(vertIDs) do
				-- Filling
				if planTypeIndex == plan.types.fill.index then
					local objectTypeCounts = {
						-- TODO: This is always filling the same thing.
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
			super_addTerrainModificationPlan(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
		end
	end
end

return mod
