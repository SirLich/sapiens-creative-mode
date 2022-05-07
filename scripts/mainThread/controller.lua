--- Entrypoint for the cheatManager.
-- We need to shadow the controller file to hook up the lifecycle events.
-- @author SirLich

local mod = {
	loadOrder = 1,
}

function mod:onload(controller)
	local cheatManager = mjrequire "cheatManager/cheatManager"
	cheatManager:init()
end

return mod