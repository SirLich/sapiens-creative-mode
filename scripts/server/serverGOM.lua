-- CreativeMode: serverGOM.lua

local mod =  {
	loadOrder = 1,
}

-- Sapiens
local objectInventory = mjrequire "common/objectInventory"
local gameObject = mjrequire "common/gameObject"
local planManager = mjrequire "server/planManager"

-- Local State
local serverGOM = nil

-- inventories = {
-- 	[1841] = {
-- 		countsByObjectType = {
-- 			[45] = 2,
-- 		},
-- 		objects = {
-- 			[1] = {
-- 				degradeReferenceTime = 17036.27585112,
-- 				fractionDegraded = 0.085663955556845,
-- 				objectTypeIndex = 45,
-- 			},
-- 			[2] = {
-- 				degradeReferenceTime = 17029.36755642,
-- 				fractionDegraded = 0.085364116377158,
-- 				objectTypeIndex = 45,
-- 			},
-- 		},
-- 	},
-- 	[1842] = {
-- 		countsByObjectType = {
-- 			[45] = 6,
-- 			[844] = 4,
-- 		},
-- 		objects = {
-- 			[1] = {
-- 				objectTypeIndex = 844,
-- 			},
-- 			[2] = {
-- 				objectTypeIndex = 844,
-- 			},
-- 			[3] = {
-- 				objectTypeIndex = 844,
-- 			},
-- 			[4] = {
-- 				objectTypeIndex = 844,
-- 			},
-- 			[5] = {
-- 				degradeReferenceTime = 17089.66764162,
-- 				fractionDegraded = 0.087625366351117,
-- 				objectTypeIndex = 45,
-- 			},
-- 			[6] = {
-- 				degradeReferenceTime = 17089.66764162,
-- 				fractionDegraded = 0.012837648684896,
-- 				objectTypeIndex = 45,
-- 			},
-- 			[7] = {
-- 				degradeReferenceTime = 17056.99628322,
-- 				fractionDegraded = 0.086344177392783,
-- 				objectTypeIndex = 45,
-- 			},
-- 			[8] = {
-- 				degradeReferenceTime = 17056.99628322,
-- 				fractionDegraded = 0.086344177392783,
-- 				objectTypeIndex = 45,
-- 			},
-- 			[9] = {
-- 				degradeReferenceTime = 17056.99628322,
-- 				fractionDegraded = 0.086207338642783,
-- 				objectTypeIndex = 45,
-- 			},
-- 			[10] = {
-- 				degradeReferenceTime = 17001.00123462,
-- 				fractionDegraded = 0,
-- 				objectTypeIndex = 45,
-- 			},
-- 		},
-- 	},
-- },

-- sharedState = {
-- 	planStates = {
-- 		bcd5 = {
-- 			[1] = {
-- 				planTypeIndex = 376,
-- 				constructableTypeIndex = 534,
-- 				canComplete = true,
-- 				requiredSkill = 352,
-- 				optionalFallbackSkill = 341,
-- 				tribeID = bcd5,
-- 				requiredResources = {
-- 					[1] = {
-- 						type = 145,
-- 						count = 4,
-- 						afterAction = {
-- 							actionTypeIndex = 452,
-- 							durationWithoutSkill = 10,
-- 						},
-- 					},
-- 					[2] = {
-- 						type = 159,
-- 						count = 8,
-- 						afterAction = {
-- 							actionTypeIndex = 452,
-- 							durationWithoutSkill = 10,
-- 						},
-- 					},
-- 				},
-- 				planID = 336,
-- 			},
-- 		},
-- 	},

-- requiredResources = {
-- 	{
-- 		type = resource.types.branch.index,
-- 		count = 4,
-- 		afterAction = {
-- 			actionTypeIndex = action.types.inspect.index,
-- 			durationWithoutSkill = 10.0,
-- 		}
-- 	},
-- 	{
-- 		type = resource.types.hay.index,
-- 		count = 8,
-- 		afterAction = {
-- 			actionTypeIndex = action.types.inspect.index,
-- 			durationWithoutSkill = 10.0,
-- 		}
-- 	},
-- }

-- requiredResources = {
-- 	[1] = {
-- 		type = 145,
-- 		count = 4,
-- 		afterAction = {
-- 			actionTypeIndex = 452,
-- 			durationWithoutSkill = 10,
-- 		},
-- 	},
-- 	[2] = {
-- 		type = 159,
-- 		count = 8,
-- 		afterAction = {
-- 			actionTypeIndex = 452,
-- 			durationWithoutSkill = 10,
-- 		},
-- 	},
-- },

-- branch_pine
function mod:onload(serverGOM)
	serverGOM = serverGOM

	local super_completeImmediatelyCheat = serverGOM.completeImmediatelyCheat
	serverGOM.completeImmediatelyCheat = function(self, buildOrCraftObject, constructableType, planStateOrNil, tribeID)
		mj:log("Restricted Resources: ", planManager.currentRestrictedResources)

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
					mj:log("Checking ", index, " against, ", resourceIndex, " --> ", isDisabled)

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
		mj:log("Required Resources: ", requiredResources)
		
		for i, resource in ipairs(requiredResources) do
			local potentialResources = getGameObjectsByResourceIndex(resource.type)
			
			mj:log("potentialResources Resources: ", potentialResources)

			local indexToUse = nil
			for i,potentialIndex in ipairs(potentialResources) do
				if isValidResourceIndex(potentialIndex) then
					indexToUse = potentialIndex
					break
				end
			end

			mj:log("indexToUse: ", indexToUse)

	
			-- Did we manage to find a valid index? Great! 
			if indexToUse then
				addToInventory(indexToUse, resource.count)
			end
		end

		local realInventory = {
			[objectInventory.locations.availableResource.index] = inventory
		}
		
		
		buildOrCraftObject.sharedState.inventories = realInventory

		mj:log("Real Inventory ", realInventory)

		super_completeImmediatelyCheat(self, buildOrCraftObject, constructableType, planStateOrNil, tribeID)
	end
end

return mod