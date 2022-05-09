--- A module to test out the UI Manager action-slots.
-- @author SirLich

-- Module setup
local testActionUI = {
	-- Required by the UI Manager
	view = nil,

	--  Required by the UI Manager
	name = "Test Action UI"
}

-- Requires
local uiStandardButton = mjrequire "mainThread/ui/uiCommon/uiStandardButton"
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2

-- Local State
local buttonWidth = 180
local buttonHeight = 40
local buttonSize = vec2(buttonWidth, buttonHeight)

-- This function is called automatically from the UI manager
-- The purpose of the function is to define `view`, usually by injecting a new view
-- into one of the other UI arguments.
function testActionUI:initActionElement(viewContainer, gameUI, hubUI, world)
	-- Create a parent container
	self.view = View.new(viewContainer)

	-- Add test button
	local testBUtton = uiStandardButton:create(self.view, buttonSize)
	testBUtton.relativePosition = ViewPosition(MJPositionCenter, MJPositionTop)
	testBUtton.baseOffset = vec3(0, 0, 5) 

	uiStandardButton:setText(testBUtton, "Testing Context-Aware Buttons")
	uiStandardButton:setClickFunction(testBUtton, function()
		spawn("chicken")
	end)
end

-- Module return
return testActionUI