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
	--- Returns true if the instant build mode is toggled on the client.
	-- @param tribeID: The ID of the tribe that you are testing for.
	-- @return nil

	
	local clientID = mod.serverWorld:clientIDForTribeID(tribeID)

	-- TODO: Give this it's own key.
	local res = saveState:getWorldValueFromServer(clientID, "instantBuild")

	mj:log("InstantBuildMode called:")
	mj:log(res)
	return res
	
end

function mod:onload(planManager)
	local super_init = planManager.init
	planManager.init = function(self, serverGOM, serverWorld, serverSapien, serverCraftArea)
		super_init(self, serverGOM, serverWorld, serverSapien, serverCraftArea)
		mod.serverWorld = serverWorld
	end

	local super_addTerrainModificationPlan = planManager.addTerrainModificationPlan
	planManager.addTerrainModificationPlan = function(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
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
