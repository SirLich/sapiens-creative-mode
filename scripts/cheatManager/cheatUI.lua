--- GameView which will be used to display the cheat UI.
-- Lifecycle events will be called automatically by the uiManager.
-- @author SirLich

-- Module setup
local cheatUI = {
	gameUI = nil,
	name = "cheatUI",
	mainView = nil,
}

-- Requires
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2
local model = mjrequire "common/model"
local timer = mjrequire "common/timer"
local uiCommon = mjrequire "mainThread/ui/uiCommon/uiCommon"
local uiStandardButton = mjrequire "mainThread/ui/uiCommon/uiStandardButton"
local eventManager = mjrequire "mainThread/eventManager"

-- Local state
local mainView = nil
local mainViewWidth = 1140
local mainViewHeight = 640
local mainViewSize = vec2(mainViewWidth, mainViewHeight)

local mainContentView = nil

local tabHeight = mainViewHeight - 80.0
local tabWidth = 180.0
local tabSize = vec2(tabWidth, tabHeight)

-- Called when the UI is ready to be geneated
function cheatUI:init(gameUI)
	mj:log("Initializing Cheat UI...")

	-- Main View
	self.mainView = View.new(gameUI.view)
	self.mainView.hidden = false
	self.mainView.relativePosition = ViewPosition(MJPositionCenter, MJPositionCenter)
	self.mainView.size = mainViewSize

	-- Main Content View
	mainContentView = ModelView.new(self.mainView )
    mainContentView:setModel(model:modelIndexForName("ui_bg_lg_16x9"))
    local scaleToUse = mainViewHeight * 0.5
    mainContentView.scale3D = vec3(scaleToUse,scaleToUse,scaleToUse)
    mainContentView.relativePosition = ViewPosition(MJPositionCenter, MJPositionTop)
    mainContentView.size = mainViewSize

	-- Clost Button
    local closeButton = uiStandardButton:create(mainContentView, vec2(50,50), uiStandardButton.types.markerLike)
    closeButton.relativePosition = ViewPosition(MJPositionInnerRight, MJPositionAbove)
    closeButton.baseOffset = vec3(30, -20, 0)
    uiStandardButton:setIconModel(closeButton, "icon_cross")
    uiStandardButton:setClickFunction(closeButton, function()
		self.mainView.hidden = true
    end)

	-- Spawn Entities View
	local spawnEntityView = View.new(self.mainView)
    spawnEntityView.size = tabSize
    spawnEntityView.baseOffset = vec3(0,0, 4)

	local testButton = uiStandardButton:create(spawnEntityView, vec2(180.0, 40))
    testButton.relativePosition = ViewPosition(MJPositionCenter, MJPositionTop)
    testButton.baseOffset = vec3(0,-10, 0)
    uiStandardButton:setText(testButton, "WOW")
	uiStandardButton:setClickFunction(testButton, function()
		self.mainView.hidden = true
    end)

	mj:log("Cheat UI Initialized.")
end

-- Called every frame
function cheatUI:update(gameUI)
	-- Do nothing
end

-- Module return
return cheatUI

