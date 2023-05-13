--- CreativeMode: server.lua
--- @author SirLich, death-rae

local mod = {
	loadOrder = 1,

	--- Local state
	bridge = nil,
	serverWorld = nil,
	server = nil
}

-- Sapiens
local mj = mjrequire "common/mj"


local function unlockSkill(clientID, paramTable)
	--- paramTable Required because net-functions can only pass one argument
	mod.serverWorld:completeDiscoveryForTribe(paramTable.tribeID, paramTable.researchTypeIndex)
end

local function removeGameObject(clientID, objectID)
	--- paramTable Required because net-functions can only pass one argument

	local serverGOM = mjrequire "server/serverGOM"
	serverGOM:removeGameObject(objectID)
end

--- Changes the type of an in-game object, from the client.
--- @param paramTable.objectID string - The object to change
--- @param paramTable.newTypeIndex string - The type index to change to
--- @param paramTable.keepDegradeInfo bool - Used on some objects to indicate how many uses remain (i.e. weapons & tools)
local function changeGameObject(clientID, paramTable)
	local serverGOM = mjrequire "server/serverGOM"
	serverGOM:changeObjectType(paramTable.objectID, paramTable.newTypeIndex, paramTable.keepDegradeInfo)
end

--- ****************************************************************
--- @author death-rae "Rae"
--- created local functions for maxNeeds, growPlant, and replenishPlant
--- maxNeeds: calls sapienUtility to max the needs for all selected sapiens. Called by maxNeedsAction.lua maxNeedsAction:onClick
--- growPlant: an update to forceGrow. Rather than replicating logic from growSapling, just call the growSaplingCheat method. Called by actions.lua forceGrowAction:onClick.
--- note the old instant grow method did not remove the mature timer, so harvestables never grew. 
--- replenishPlant: replenishes the harvestables on the selected plants. Called by actions.lua forceReplenishtAction:onClick
--- removeSapienObject: if we're trying to remove a sapien, we use a different method to handle the inventory aspect.
--- ****************************************************************


--- Allows setting the 'maximum needs' (happiness, loyalty) for a table of sapiens.
local function setMaxNeeds(clientID, objects)
	local sapienUtility = mjrequire "server/sapienUtility"
	sapienUtility:maxSapienNeeds(objects)
end


--- Allows to force-grow a table of saplings.
-- @param plants table - The plants to replenish
local function growPlants(clientID, plants)
	local serverFlora = mjrequire "server/objects/serverFlora"
	for i,element in ipairs(plants) do
		serverFlora:growSaplingCheat(element)
	end
end

--- Allows to replinish the inventory of a plant, such as refilling sticks or fruit.
-- @param paramTable.tribeID string - The tribe the sapiens belong to
-- @param paramTable.plants object - The plants to replenish
local function replenishPlants(clientID, plants)
	local serverFlora = mjrequire "server/objects/serverFlora"
	for i, element in ipairs(plants) do
		serverFlora:refillInventory(element, element.sharedState, true, true)
	end
end

--- Allows for removing a table of sapiens.
-- @param paramTable.tribeID string - The tribe the sapiens belong to
-- @param paramTable.objects object - The sapien objects to remove
local function removeSapiens(clientID, paramTable)
	local sapienUtility = mjrequire "server/sapienUtility"
	--- remove the sapien, do not notify the client, and drop the inventory
	sapienUtility:removeSapiens(paramTable.objects, paramTable.tribeID)
end

--- Allows for removing a table of mobs, such as mammoths.
-- @param paramTable.tribeID string - The tribe the sapiens belong to
-- @param paramTable.objects object - The mob objects to remove
local function removeMobs(clientID, paramTable)	
	local mobUtility = mjrequire "server/mobUtility"
	mobUtility:removeMobs(paramTable.objects, paramTable.tribeID)
end

local function init()
	--- Register net function for cheats
	mod.server:registerNetFunction("unlockSkill", unlockSkill)
	mod.server:registerNetFunction("removeGameObject", removeGameObject)
	mod.server:registerNetFunction("changeGameObject", changeGameObject)
	mod.server:registerNetFunction("setInstantBuild", function(clientID, param)
		mod.serverWorld.completionCheatEnabled = param
	end)

	--- register Rae's functionsf
	mod.server:registerNetFunction("setMaxNeeds", setMaxNeeds)
	mod.server:registerNetFunction("growPlants",growPlants)
	mod.server:registerNetFunction("replenishPlants", replenishPlants)
	mod.server:registerNetFunction("removeSapiens", removeSapiens)
	mod.server:registerNetFunction("removeMobs",removeMobs)
	--- END Rae's changes
end

function mod:onload(server)
	mj:log("CreativeMode: server.lua loaded.")
	mod.server = server
	
	--- Shadow setBridge
	local super_setBridge = server.setBridge
	server.setBridge = function(self, bridge)
		super_setBridge(self, bridge)
		mod.bridge = bridge
		mj:log("CreativeMode: Server bridge set.")
	end

	--- Shadow setServerWorld
	local super_setServerWorld = server.setServerWorld
	server.setServerWorld = function(self, serverWorld)
		super_setServerWorld(self, serverWorld)
		mod.serverWorld = serverWorld

		init()
	end

end

return mod
