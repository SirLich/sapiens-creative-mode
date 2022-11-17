--- CreativeMode: serverGOM.lua
--- @author SirLich

local mod =  {
	loadOrder = 1,
}

-- Sapiens
local objectInventory = mjrequire "common/objectInventory"
local gameObject = mjrequire "common/gameObject"
local planManager = mjrequire "server/planManager"

-- Local State
local serverGOM = nil

function mod:onload(serverGOM)
	serverGOM = serverGOM

	local super_completeImmediatelyCheat = serverGOM.completeImmediatelyCheat
	serverGOM.completeImmediatelyCheat = function(self, buildOrCraftObject, constructableType, planStateOrNil, tribeID)

		local inventory = {
			countByObjectType = {},
			objects = {}
		}

		local function addToInventory(index, count)
			inventory.countByObjectType[index] = count

			for i= 1, count do
				table.insert(inventory.objects, {
					objectTypeIndex = index
				})
			end
		end

		local function isValidResourceIndex(index)
			--- Tests whether an index is valid (could be sorted out, due to the currentRestrictedResources!)
			if planManager.currentRestrictedResources ~= nil then

				for resourceIndex, isDisabled in pairs(planManager.currentRestrictedResources) do
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

			for i,object in ipairs(gameObject.validTypes) do
				if object.resourceTypeIndex == resourceTypeIndex then
					table.insert(resourceIndexes, object.index)
				end
			end

			return resourceIndexes
		end

		
		local requiredResources = buildOrCraftObject.sharedState.planStates[tribeID][1].requiredResources

		for i, resource in ipairs(requiredResources) do
			local potentialResources = getGameObjectsByResourceIndex(resource.type)
			
			local indexToUse = nil
			for i,potentialIndex in ipairs(potentialResources) do
				if isValidResourceIndex(potentialIndex) then
					indexToUse = potentialIndex
					break
				end
			end
	
			-- Did we manage to find a valid index? Great! 
			if indexToUse then
				addToInventory(indexToUse, resource.count)
			end
		end

		local realInventory = {
			[objectInventory.locations.availableResource.index] = inventory
		}
		
		
		buildOrCraftObject.sharedState.inventories = realInventory

		super_completeImmediatelyCheat(self, buildOrCraftObject, constructableType, planStateOrNil, tribeID)

	end
end

return mod