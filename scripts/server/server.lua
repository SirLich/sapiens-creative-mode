--- CreativeMode: server.lua
--- @author SirLich

local mod = {
	loadOrder = 1,

	-- Local state
	bridge = nil,
	serverWorld = nil,
	server = nil
}

local function unlockSkill(clientID, paramTable)
	--- paramTable Required because net-functions can only pass one argument
	mod.serverWorld:completeDiscoveryForTribe(paramTable.tribeID, paramTable.skillTypeIndex)
end

local function removeGameObject(clientID, objectID)
	--- paramTable Required because net-functions can only pass one argument

	local serverGOM = mjrequire "server/serverGOM"
	serverGOM:removeGameObject(objectID)
end

local function changeGameObject(clientID, paramTable)
	--- Changes the type of an in-game object, from the client.
	--- @param paramTable.objectID string - The object to change
	--- @param paramTable.newTypeIndex string - The type index to change to
	--- @param paramTable.keepDegradeInfo bool - Unknown

	local serverGOM = mjrequire "server/serverGOM"
	serverGOM:changeObjectType(paramTable.objectID, paramTable.newTypeIndex, paramTable.keepDegradeInfo)
end




local function init()
	-- Register net function for cheats
	mod.server:registerNetFunction("unlockSkill", unlockSkill)
	mod.server:registerNetFunction("removeGameObject", removeGameObject)
	mod.server:registerNetFunction("changeGameObject", changeGameObject)
	mod.server:registerNetFunction("setInstantBuild", function(clientID, param)
		mod.serverWorld.completionCheatEnabled = param
	end)
end

function mod:onload(server)
	mj:log("CreativeMode: server.lua loaded.")
	mod.server = server
	
	-- Shadow setBridge
	local super_setBridge = server.setBridge
	server.setBridge = function(self, bridge)
		super_setBridge(self, bridge)
		mod.bridge = bridge
		mj:log("CreativeMode: Server bridge set.")
	end

	-- Shadow setServerWorld
	local super_setServerWorld = server.setServerWorld
	server.setServerWorld = function(self, serverWorld)
		super_setServerWorld(self, serverWorld)
		mod.serverWorld = serverWorld

		init()
	end
end

return mod