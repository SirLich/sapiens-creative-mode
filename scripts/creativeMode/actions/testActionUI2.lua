--- CreativeMode: testActionUI
--- @author SirLich

local testActionUI2 = {}

-- Math
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2

function testActionUI2:getName(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	return "Test Action 2: " .. tostring(baseObjectInfo)
end

function testActionUI2:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	return true
end

function testActionUI2:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	spawn('apple')
end

return testActionUI2