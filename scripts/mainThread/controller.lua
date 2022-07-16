--- Entrypoint for the mainThread of the creativeMode mod.
--- @author SirLich

local mod = {
	loadOrder = 1,
}

local eventManager = mjrequire "hammerstone/event/eventManager"
local eventTypes = mjrequire "hammerstone/event/eventTypes"

function mod:onload(controller)
	local creativeMode = mjrequire "creativeMode/creativeMode"

	-- eventManager:bind(eventTypes.init, creativeMode.init)
	-- eventManager:bind(eventTypes.worldLoad, creativeMode.worldinit)
end

return mod