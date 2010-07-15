

--[[ ************************* Initialising stuff *************************
		We initialise some stuff right here, since we use quite some variables during the addon
]]
	local options								-- local copy of our SavedVariables
	local _, playerclass = UnitClass('player')	-- we need this for shamans
	
	local LBF = nil								-- ButtonFacade support START
	if (IsAddOnLoaded('ButtonFacade')) then		-- *
		LBF = LibStub("LibButtonFacade")		-- *
	end											-- *
	local PB = "PredatorButtons"				-- *
	local db = {}								-- ButtonFacade support END
	
	local i										-- You need an "i" everytime!!! ;)

	
	--[[ Creating the frames, which will hold our buttons.
			We'll be able to move our bars by positioning these frames.
			To provide more usability, we will update the sizes of these frames later.
	]]
    
	-- main actionbar
	local actionbar = CreateFrame('Frame', 'ActionBar', UIParent)
	actionbar:SetWidth(50)
	actionbar:SetHeight(50)
	actionbar:Show()
	  
	-- left bar
	local multibarleft = CreateFrame('Frame', 'MultiBarLeft', UIParent)
	multibarleft:SetWidth(50)
	multibarleft:SetHeight(50)
	multibarleft:Show()

	-- right bar
	local multibarright = CreateFrame('Frame', 'MultiBarRight', UIParent)
	multibarright:SetWidth(50)
	multibarright:SetHeight(50)
	multibarright:Show()  
  
	-- bottom left bar
	local multibarbottomleft = CreateFrame('Frame', 'MultiBarBottomLeft', UIParent)
	multibarbottomleft:SetWidth(50)
	multibarbottomleft:SetHeight(50)
	multibarbottomleft:Show()

	-- bottom right bar
	local multibarbottomright = CreateFrame('Frame', 'MultiBarBottomRight', UIParent)
	multibarbottomright:SetWidth(50)
	multibarbottomright:SetHeight(50)
	multibarbottomright:Show()
  
	-- pet bar
	local petbar = CreateFrame('Frame', 'PetBar', UIParent)
	petbar:SetWidth(50)
	petbar:SetHeight(50)
  
	-- stance bar (warrior, druids and - possibly - rogues, shadowpriests, death-knights)
	local stancebar = CreateFrame('Frame', 'StanceBar', UIParent)
	stancebar:SetWidth(50)
	stancebar:SetHeight(50)
	
	-- totem bar (shamans only)
	local totembar = CreateFrame('Frame', 'TotemBar', UIParent)
	totembar:SetWidth(230)
	totembar:SetHeight(40)
	
	
	
--[[ ************************* Functions *************************
		here are the functions
]]	

	--[[ Debugging to ChatFrame 
			Adds a string to the default chat frame
	]]
	local function debugging(text)
		DEFAULT_CHAT_FRAME:AddMessage('|cffffd700PredatorButtons:|r |cffeeeeee'..text..'|r')
	end
	
	--[[ Hiding all the ugly Blizzard stuff
			We hide the frames and scale them doooown
	]]
	local function HideBlizzardFrames()
		-- debugging('HideBlizzardFrames()')
		MainMenuBar:Hide()
		MainMenuExpBar:Hide()
		MainMenuBarMaxLevelBar:Hide()
		MainMenuBarArtFrame:Hide()
		PetActionBarFrame:Hide()
		ShapeshiftBarFrame:Hide()
		VehicleMenuBar:Hide()
		VehicleMenuBarArtFrame:Hide()
		-- MainMenuBar:Hide()
		-- MainMenuBarArtFrame:Hide()
		-- MainMenuExpBar:Hide()
		-- VehicleMenuBar:Hide()
		-- VehicleMenuBarArtFrame:Hide()
		-- MainMenuBar:SetScale(0.001)
		-- MainMenuBarArtFrame:SetScale(0.001)
		-- MainMenuExpBar:SetScale(0.001)
		-- VehicleMenuBar:SetScale(0.001)
		-- VehicleMenuBarArtFrame:SetScale(0.001)
	end

	--[[ Updating the StanceBar
			I got really no clue, why this is necessary, but without this, everything is fucked up
	]]
	local function StanceBarUpdate()
		_G['ShapeshiftButton1']:SetPoint('TOPLEFT', stancebar, 'TOPLEFT', 0, 0)
		for i=2, NUM_SHAPESHIFT_SLOTS do
			_G['ShapeshiftButton'..i]:SetPoint('LEFT', _G['ShapeshiftButton'..i-1], 'RIGHT', 6, 0)
		end
	end

	local function TotemOnShow()
		debugging('Blizzard tries to move our Totems! Aaaaahhhh!')
		MultiCastActionBarFrame:SetPoint('LEFT', totembar, 'CENTER', 0, 0)
	end
	
	--[[ Toggles the visibility of the main ActionBar
			Necessary for all classes with different stances (warrior, druids, rogues...)
	]]
	local function ToggleActionButtonns(alpha)
		for i=1, 12 do
			_G['ActionButton'..i]:SetAlpha(alpha)
		end
	end
	
	--[[ Moving the bars to their positions
	
	]]
	local function MoveBarToPosition(frame)
		local position = options[frame:GetName()]['position']
		local buttons = options[frame:GetName()]['buttons']
		local columns = options[frame:GetName()]['columns']
		
		if (frame:GetName() == 'TotemBar') then
			buttons = 5
			columns = 5
		elseif (frame:GetName() == 'StanceBar') then
			buttons = NUM_SHAPESHIFT_SLOTS
			columns = NUM_SHAPESHIFT_SLOTS
		end
		
		frame:SetWidth((columns*36)+((columns-1)*6))
		frame:SetHeight(((buttons/columns)*36)+((buttons/columns)-1)*6)
		
		if ((position[4] == nil) or (position[5] == nil)) then
			frame:SetPoint(position[1], UIParent, position[1], position[2], position[3])
		elseif ((position[4] ~= nil) and (position[5] ~= nil)) then
			local anchor = _G[position[4]]
			if anchor then
				frame:SetPoint(position[1], anchor, position[5], position[2], position[3])
			end
		end	
	end
	
	--[[ Setting up the "bars"
			This function will align the buttons of a bar according to the columns-value.
			We're using the default Blizzard bars only, so every bar has 12 buttons on it.
			Since we're not want all those 12 buttons everytime, we'll hide the unwanted ones.
			After that, the bar is moved into its position with MoveBarToPosition()
	]]
	local function BarSetUp(frame, buttonprefix)
		local buttons = options[frame:GetName()]['buttons']
		local columns = options[frame:GetName()]['columns']
		if (buttons > 1) then		
			local multiplicator = 1
			for i=2, 12 do
				local item = _G[buttonprefix..i]
				if (item) then
					item:SetFrameLevel(9)
					if (i > buttons) then
						item:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', -50, 50)
						item:SetAlpha(0)
					elseif (i == multiplicator*columns + 1) then
						item:SetPoint('TOPLEFT', _G[buttonprefix..i-(columns)], 'BOTTOMLEFT', 0, -6)
						multiplicator = multiplicator + 1
					else
						item:SetPoint('TOPLEFT', _G[buttonprefix..i-1], 'TOPRIGHT', 6, 0)
					end
				end
			end
		end
		MoveBarToPosition(frame)
	end
	
	--[[ EventHandler
	
	]]
	local function controlOnEvent(self, event, ...)
		if (event == 'VARIABLES_LOADED') then
			-- debugging('VARIABLES_LOADED')
			-- Initialising the SavedVariables START
			if (PredatorButtonsDB == nil) then
				debugging('Initialising default values! Remember: Bars have to be activated in the Blizzard options panel to actually show them!')
				PredatorButtonsDB = {}
				local init = {}
				
				-- ActionBar
				init = {}
				init['buttons'] = 12
				init['columns'] = 12
				init['padding'] = 6
				init['position'] = {'CENTER', 0, -120, nil}
				PredatorButtonsDB['ActionBar'] = init
				
				-- MultiBarLeft
				init = {}
				init['buttons'] = 12
				init['columns'] = 12
				init['position'] = {'CENTER', 0, -80, nil}
				PredatorButtonsDB['MultiBarLeft'] = init

				-- MultiBarRight
				init = {}
				init['buttons'] = 12
				init['columns'] = 12
				init['position'] = {'CENTER', 0, -40, nil}
				PredatorButtonsDB['MultiBarRight'] = init
				
				-- MultiBarBottomLeft
				init = {}
				init['buttons'] = 12
				init['columns'] = 12
				init['position'] = {'CENTER', 0, 0, nil}
				PredatorButtonsDB['MultiBarBottomLeft'] = init
				
				-- MultiBarBottomRight
				init = {}
				init['buttons'] = 12
				init['columns'] = 12
				init['position'] = {'CENTER', 0, 40, nil}
				PredatorButtonsDB['MultiBarBottomRight'] = init
				
				-- PetBar
				init = {}
				init['buttons'] = 10
				init['columns'] = 10
				init['position'] = {'CENTER', 0, 80, nil}
				PredatorButtonsDB['PetBar'] = init
								
				-- TotemBar
				init = {}
				init['position'] = {'CENTER', 0, 120, nil}
				PredatorButtonsDB['TotemBar'] = init
				
				-- StanceBar
				init = {}
				init['position'] = {'CENTER', 0, 160, nil}
				PredatorButtonsDB['StanceBar'] = init		
			end
			-- Initialising the SavedVariables END
			options = PredatorButtonsDB

			-- Layouting the bars
			BarSetUp(actionbar, 'ActionButton')
			BarSetUp(actionbar, 'BonusActionButton')
			BarSetUp(multibarbottomleft, 'MultiBarBottomLeftButton')
			BarSetUp(multibarbottomright, 'MultiBarBottomRightButton')
			BarSetUp(multibarleft, 'MultiBarLeftButton')
			BarSetUp(multibarright, 'MultiBarRightButton')
			BarSetUp(petbar, 'PetActionButton')
			MoveBarToPosition(totembar)
			MoveBarToPosition(stancebar)
			
		elseif (event == 'PLAYER_ENTERING_WORLD') then	
			-- debugging('PLAYER_ENTERING_WORLD')
			-- ButtonFacade support START
			if (LBF) then
				-- debugging('Found ButtonFacade, initialising the DB')
				PredatorBFDB = PredatorBFDB or {}
				bfdb = PredatorBFDB
				
				if bfdb.dbinit ~= 1 then
					local defaults = {
						groups = {
							['ActionBars'] = {
								skin =  'Blizzard',
								gloss = false,
								backdrop = false,
								colors = {},
							},
						},
						dbinit = 1,
					}
					bfdb = defaults
					PredatorBFDB = bfdb
				end
				self.db = bfdb
							
				local lbfgroup = LBF:Group('PredatorButtons', 'ActionBars')
				lbfgroup:Skin(self.db.groups['ActionBars'].skin, self.db.groups['ActionBars'].gloss, self.db.groups['ActionBars'].backdrop, self.db.groups['ActionBars'].colors)

				for i=1, 12 do
					-- debugging(i)
					lbfgroup:AddButton(_G['ActionButton'..i])
					_G['ActionButton'..i]:SetFrameStrata('HIGH')
					lbfgroup:AddButton(_G['BonusActionButton'..i])
					_G['BonusActionButton'..i]:SetFrameStrata('DIALOG')
					lbfgroup:AddButton(_G['MultiBarBottomLeftButton'..i])
					lbfgroup:AddButton(_G['MultiBarBottomRightButton'..i])
					lbfgroup:AddButton(_G['MultiBarLeftButton'..i])
					lbfgroup:AddButton(_G['MultiBarRightButton'..i])
					if (i <= NUM_SHAPESHIFT_SLOTS) then
						lbfgroup:AddButton(_G['ShapeshiftButton'..i])
					end
					if (i <= 10) then
						lbfgroup:AddButton(_G['PetActionButton'..i])
					end
				end
				
				LBF:RegisterSkinCallback(PB, function(_, SkinID, Gloss, Backdrop, Group, Button, Colors)
					if not Group then return end
					self.db.groups[Group].skin = SkinID
					self.db.groups[Group].gloss = Gloss
					self.db.groups[Group].backdrop = Backdrop
					self.db.groups[Group].colors = Colors
				end, self)	
				
				BonusActionBarFrame:SetFrameLevel(_G["ActionButton1"]:GetFrameLevel() + 1)
			end
			-- ButtonFacade support END
			HideBlizzardFrames()
		else
			-- debugging('some other Event')
			HideBlizzardFrames()
		end
	end
	

	-- ActionBar
	for i=1, 12 do
		_G['ActionButton'..i]:SetParent(actionbar)
	end
	_G['ActionButton1']:ClearAllPoints()
	_G['ActionButton1']:SetPoint('TOPLEFT', actionbar, 'TOPLEFT', 0, 0)
	
	-- BonusBar
	_G['BonusActionBarFrame']:SetParent(actionbar)
	_G['BonusActionBarFrame']:SetWidth(0.01)
	_G['BonusActionBarTexture0']:Hide()
	_G['BonusActionBarTexture1']:Hide()
	_G['BonusActionButton1']:ClearAllPoints()
	_G['BonusActionButton1']:SetPoint('TOPLEFT', actionbar, 'TOPLEFT', 0, 0)
	_G['BonusActionBarFrame']:HookScript("OnShow", function(self) ToggleActionButtonns(0) end)
	_G['BonusActionBarFrame']:HookScript("OnHide", function(self) ToggleActionButtonns(1) end)
	if _G['BonusActionBarFrame']:IsShown() then
		ToggleActionButtonns(0)
	end
	
	-- MulitBarRight
	_G['MultiBarRight']:SetParent(multibarright)
	_G['MultiBarRightButton1']:ClearAllPoints()
	_G['MultiBarRightButton1']:SetPoint('TOPLEFT', multibarright, 'TOPLEFT', 0, 0)
	
	-- MultiBarLeft
	_G['MultiBarLeft']:SetParent(multibarleft)
	_G['MultiBarLeftButton1']:ClearAllPoints()
	_G['MultiBarLeftButton1']:SetPoint('TOPLEFT', multibarleft, 'TOPLEFT', 0, 0)
	
	-- MultiBarBottomLeft
	_G['MultiBarBottomLeft']:SetParent(multibarbottomleft)
	_G['MultiBarBottomLeftButton1']:ClearAllPoints()
	_G['MultiBarBottomLeftButton1']:SetPoint('TOPLEFT', multibarbottomleft, 'TOPLEFT', 0, 0)

	-- MultiBarBottomRight
	_G['MultiBarBottomRight']:SetParent(multibarbottomright)
	_G['MultiBarBottomRightButton1']:ClearAllPoints()
	_G['MultiBarBottomRightButton1']:SetPoint('TOPLEFT', multibarbottomright, 'TOPLEFT', 0, 0)
	
	-- PetBar
	for i=1, 10 do
		_G['PetActionButton'..i]:SetParent(petbar)
	end
	-- _G['PetActionBarFrame']:SetParent(petbar)
	_G['PetActionBarFrame']:SetWidth(0.01)
	_G['PetActionButton1']:ClearAllPoints()
	_G['PetActionButton1']:SetPoint('TOPLEFT', petbar, 'TOPLEFT', 0, 0)
	
	-- StanceBar
	for i=1, NUM_SHAPESHIFT_SLOTS do
		_G['ShapeshiftButton'..i]:SetWidth(36)
		_G['ShapeshiftButton'..i]:SetHeight(36)
		_G['ShapeshiftButton'..i]:SetParent(stancebar)
	end
	-- ShapeshiftBarFrame:SetParent(stancebar)
	ShapeshiftBarFrame:SetWidth(0.01)
	-- ShapeshiftBarFrame:SetScale(0.01)
	ShapeshiftButton1:ClearAllPoints()
	ShapeshiftButton1:SetPoint('TOPLEFT', stancebar, 'TOPLEFT', 0, 0)
	hooksecurefunc("ShapeshiftBar_Update", StanceBarUpdate)
	
	-- PossessBar
	_G['PossessBarFrame']:SetParent(stancebar)
	_G['PossessButton1']:ClearAllPoints()
	_G['PossessButton1']:SetPoint('TOPLEFT', stancebar, 'TOPLEFT', 0, 0)
	
	-- TotemBar
	if (playerclass == 'SHAMAN') then
		local button
		local Totems = {
			MultiCastSummonSpellButton,
			MultiCastActionPage1,
			MultiCastActionPage2,
			MultiCastActionPage3,
			MultiCastSlotButton1,
			MultiCastSlotButton2,
			MultiCastSlotButton3,
			MultiCastSlotButton4,
			MultiCastFlyoutFrame,
			MultiCastFlyoutButton,
			MultiCastRecallSpellButton,
		}
			for _, f in pairs(Totems) do
				f:SetParent(totembar);
			end
			MultiCastSummonSpellButton:ClearAllPoints();
			MultiCastSummonSpellButton:SetPoint("BOTTOMLEFT", 3, 3);
			local page;
			for i = 1, NUM_MULTI_CAST_PAGES do
				page = _G["MultiCastActionPage"..i];
				page:SetPoint("BOTTOMLEFT", 50, 3);
    			end
 			MultiCastRecallSpellButton:SetPoint("BOTTOMLEFT", 50, 3);
	end


--[[ ManagementFrame

]]
	local frame = CreateFrame('Frame', nil, UIParent)
	frame:SetScript('OnEvent', controlOnEvent)
	-- to manage our saved variables
	frame:RegisterEvent('VARIABLES_LOADED')
	-- to hide the default artwork
	frame:RegisterEvent('PLAYER_ENTERING_WORLD')
	frame:RegisterEvent('UNIT_ENTERED_VEHICLE')
	frame:RegisterEvent('UNIT_EXITED_VEHICLE')
	frame:RegisterEvent('UNIT_ENTERING_VEHICLE')
	frame:RegisterEvent('UNIT_EXITING_VEHICLE')
