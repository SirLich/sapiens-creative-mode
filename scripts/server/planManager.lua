--- CreativeMode: planManager.lua
--- @author SirLich

local planManagerModule = {
	loadOrder = 1,

	-- Local State
	serverWorld = nil,
	serverGOM = nil
}

-- Sapiens
local serverTerrain = mjrequire "server/serverTerrain"
local plan = mjrequire "common/plan"
local shadow = mjrequire "hammerstone/utils/shadow"

-- Hammerstone
local saveState = mjrequire "hammerstone/state/saveState"

--- @param tribeID string: The ID of the tribe that you are testing for.
--- @return boolean: True if the instant build mode is toggled on for the world.
local function isInstantDig(tribeID)
	return saveState:getValue('cm.instantDig', {
		tribeID = tribeID,
		default = false
	})
end

local function isInstantBuild(tribeID)
	return saveState:getValue('cm.instantBuild', {
		tribeID = tribeID,
		default = false
	})
end

-- Mostly stolen from serverGOM.lua
local function calculateFillOrderResources(fillConstructableTypeIndex, restrictedResourceObjectTypesOrNil)
	local constructable = mjrequire "common/constructable"
	local gameObjectModule = mjrequire "common/gameObject"

	local constructableType = constructable.types[fillConstructableTypeIndex]

	local resourceIndex = constructableType.requiredResources[1].type

	local function isValidResourceIndex(index)
		--- Tests whether an index is valid (could be sorted out, due to the currentRestrictedResources!)
		if restrictedResourceObjectTypesOrNil ~= nil then

			for resourceIndex, isDisabled in pairs(restrictedResourceObjectTypesOrNil) do
				if resourceIndex == index then
					return not isDisabled
				end
			end
		end

		-- Default codepath, assume valid
		return true
	end

	local function getGameObjectsByResourceIndex(resourceTypeIndex)
		--- Searches through the  game object list, and finds game objects matching the resource index
		--- Example: Finds all 'branches' (peach, pine, etc) based on the request for 'branch'
		--- Actual args and returns are ints, represnting type map shit

		local resourceIndexes = {}

		for i,object in ipairs(gameObjectModule.validTypes) do
			if object.resourceTypeIndex == resourceTypeIndex then
				table.insert(resourceIndexes, object.index)
			end
		end

		return resourceIndexes
	end

	local potentialResources = getGameObjectsByResourceIndex(resourceIndex)
			
	local indexToUse = nil
	for i,potentialIndex in ipairs(potentialResources) do
		if isValidResourceIndex(potentialIndex) then
			indexToUse = potentialIndex
			break
		end
	end
	
	local objectTypeCounts = {
		[indexToUse] = 100
	}

	return objectTypeCounts
end

-- local planInfo = {
-- 	planTypeIndex = constructableType.planTypeIndex or plan.types.build.index,
-- 	constructableTypeIndex = constructableTypeIndex,
-- 	pos = buildObjectPos,
-- 	rotation = buildObjectRotation,
-- 	restrictedResourceObjectTypes = restrictedResourceObjectTypes,
-- 	restrictedToolObjectTypes = world:getConstructableRestrictedObjectTypes(constructableTypeIndex, true),
-- 	attachedToTerrain = attachedToTerrain,
-- 	noBuildOrder = noBuildOrderModifierDown,
-- }

---  @shadow
function planManagerModule:init(super, serverGOM, serverWorld, serverSapien, serverCraftArea)
	super(self, serverGOM, serverWorld, serverSapien, serverCraftArea)
	planManagerModule.serverGOM = serverGOM
	planManagerModule.serverWorld = serverWorld
end


--- @shadow
function planManagerModule:addBuildOrPlantPlan(super,tribeID,planTypeIndex, constructableTypeIndex, pos, rotation, sapienIDOrNil, subModelInfosOrNil, attachedToTerrain,decalBlockersOrNil,restrictedResourceObjectTypesOrNil,restrictedToolObjectTypesOrNil,noBuildOrder)

	mj:log("Setting Restricted Resources: ", restrictedResourceObjectTypesOrNil)
	self.currentRestrictedResources = restrictedResourceObjectTypesOrNil

	super(self, tribeID,planTypeIndex, constructableTypeIndex,pos, rotation, sapienIDOrNil, subModelInfosOrNil, attachedToTerrain,decalBlockersOrNil,restrictedResourceObjectTypesOrNil,restrictedToolObjectTypesOrNil,noBuildOrder)
end

--- @shadow
function planManagerModule:addTerrainModificationPlan(super, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
	-- Custom implementation if instant build mode is on. Otherwise, just call the super.
	-- The extra validation is so we don't crash.
	if isInstantDig(tribeID) and vertIDs and vertIDs[1] then
		-- Filling
		if planTypeIndex == plan.types.fill.index then
			local objectTypeCounts = calculateFillOrderResources(fillConstructableTypeIndex, restrictedResourceObjectTypesOrNil)
			
			for i, vertID in ipairs(vertIDs) do

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
			super(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
		end
	else
		super(self, tribeID, planTypeIndex, vertIDs, fillConstructableTypeIndex, researchTypeIndex, restrictedResourceObjectTypesOrNil, restrictedToolObjectTypesOrNil, planOrderIndexOrNil)
	end
end

return shadow:shadow(planManagerModule)
