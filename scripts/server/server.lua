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


local function init()
	-- Register net function for cheats
	mod.server:registerNetFunction("unlockSkill", unlockSkill)
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