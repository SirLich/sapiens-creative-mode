--- Entrypoint for the creativeMode.
-- We need to shadow the controller file to hook up the lifecycle events.
-- @author SirLich

local mod = {
	loadOrder = 1,
}

function mod:onload(controller)
	local creativeMode = mjrequire "creativeMode/creativeMode"
	creativeMode:init()
end

return mod