-----------------------------------------------------------------------------------
-- Addon Name: Dolgubon's Lazy Writ Crafter
-- Creator: Dolgubon (Joseph Heinzle)
-- Addon Ideal: Simplifies Crafting Writs as much as possible
-- Addon Creation Date: March 14, 2016
--
-- File Name: SettingsMenu.lua
-- File Description: Contains the information for the settings menu
-- Load Order Requirements: None (April, after language files)
-- 
-----------------------------------------------------------------------------------

local checks = {}
local validLanguages = 
{
	["en"]=true,["de"] = true,["fr"] = true,["jp"] = true, ["ru"] = false, ["zh"] = false, ["pl"] = false,
}
if true then
	EVENT_MANAGER:RegisterForEvent("WritCrafterLocalizationError", EVENT_PLAYER_ACTIVATED, function()
		if not WritCreater.languageInfo then 
			local language = GetCVar("language.2")
			if validLanguages[language] == nil then
				d("Dolgubon's Lazy Writ Crafter: Your language is not supported for this addon. If you are looking to translate the addon, check the lang/en.lua file for more instructions.")
			elseif validLanguages[language] == false then
				d("Dolgubon's Lazy Writ Crafter: The Localization file could not be loaded.")
				d("Troubleshooting:")
				d("1. Your language is supported by a patch for the Writ Crafter. Please make sure you have downloaded the appropriate patch")
				d("2. Uninstall and then reinstall the Writ Crafter, and the patch")
				d("3. If you still have issues, contact the author of the patch")
			else
				d("Dolgubon's Lazy Writ Crafter: The Localization file could not be loaded.")
				d("Troubleshooting:")
				d("1. Try to uninstall and then reinstall the addon")
				d("2. If the error persists, contact @Dolgubon in-game or at tinyurl.com/WritCrafter")
			end
		end
		EVENT_MANAGER:UnregisterForEvent("WritCrafterLocalizationError", EVENT_PLAYER_ACTIVATED)
	end)
end


WritCreater.styleNames = {}

for i = 1, GetNumValidItemStyles() do

	local styleItemIndex = GetValidItemStyleId(i)
	local  itemName = GetItemStyleName(styleItemIndex)
	local styleItem = GetSmithingStyleItemInfo(styleItemIndex)
	if styleItemIndex ~=36 then
		table.insert(WritCreater.styleNames,{styleItemIndex,itemName, styleItem})
	end
end

function WritCreater:GetSettings()
	if not self or not self.savedVars then
		return false
	end
	if self.savedVars.useCharacterSettings then
		return self.savedVars
	else
		return self.savedVarsAccountWide.accountWideProfile
	end
end

--[[{
			type = "dropbox",
			name = "Autoloot Behaviour",
			tooltip = "Choose when the addon will autoloot writ reward containers",
			choices = {"Copy the", "Autoloot", "Never Autoloot"},
			choicesValues = {1,2,3},
			getFunc = function() if WritCreater:GetSettings().ignoreAuto then return 1 elseif WritCreater:GetSettings().autoLoot then return 2 else return 3 end end,
			setFunc = function(value) 
				if value == 1 then 
					WritCreater:GetSettings().ignoreAuto = false
				elseif value == 2 then  
					WritCreater:GetSettings().autoLoot = true
					WritCreater:GetSettings().ignoreAuto = true
				elseif value == 3 then
					WritCreater:GetSettings().ignoreAuto = true
					WritCreater:GetSettings().autoLoot = false
				end
			end,
		},]]

local function mypairs(tableIn)
	local t = {}
	for k,v in pairs(tableIn) do
		t[#t + 1] = {k,v}
	end
	table.sort(t, function(a,b) return a[1]<b[1] end)

	return t
end

local optionStrings = WritCreater.optionStrings
local function styleCompiler()
	local submenuTable = {}
	local styleNames = WritCreater.styleNames
	for k,v in ipairs(styleNames) do

		local option = {
			type = "checkbox",
			name = zo_strformat("<<1>>", v[2]),
			tooltip = optionStrings["style tooltip"](v[2], v[3]),
			getFunc = function() return WritCreater:GetSettings().styles[v[1]] end,
			setFunc = function(value)
				WritCreater:GetSettings().styles[v[1]] = value  --- DO NOT CHANGE THIS! If you have 'or nil' then the ZO_SavedVars will set it to true.
				end,
		}
		submenuTable[#submenuTable + 1] = option
	end
	local imperial = table.remove(submenuTable, 34)
	table.insert(submenuTable, 10, imperial)
	return submenuTable
end
local function isCheeseOn()
	local enableNames = {
		["@Dolgubon"]=1,
		["@mithra62"]=1,
		["@Gitaelia"]=1,
		["@PacoHasPants"]=1,
		["@Architecture"]=1,
		["@K3VLOL99"]=1,
		
	}
	local dateCheck = GetDate()%10000 == 401 or false 
	return dateCheck or enableNames[GetDisplayName()]
	-- return WritCreater.shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit and WritCreater.shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit() == 2
end
if isCheeseOn() then
	local cheesyActivityTypeIndex = 2
	while TIMED_ACTIVITIES_MANAGER.activityTypeLimitData[cheesyActivityTypeIndex] do 
		cheesyActivityTypeIndex = cheesyActivityTypeIndex + 1 
	end
	-- Localization
	local il8n = WritCreater.cheeseyLocalizations

	local originalInitializeKeyboardFinderCategory = ZO_TimedActivities_Keyboard.InitializeActivityFinderCategory
	function ZO_TimedActivities_Keyboard:InitializeActivityFinderCategory()
		local returnValue = originalInitializeKeyboardFinderCategory(self)

		GROUP_MENU_KEYBOARD.nodeList[2].children[cheesyActivityTypeIndex] = 
		{
            priority = CATEGORY_PRIORITY + 20,
            name = "Cheesy Endeavors",
            categoryFragment = self.sceneFragment,
            onTreeEntrySelected = onCheesyEndeavorsSelected,
        }
		GROUP_MENU_KEYBOARD.navigationTree:Reset()
		GROUP_MENU_KEYBOARD:AddCategoryTreeNodes(GROUP_MENU_KEYBOARD.nodeList)
		GROUP_MENU_KEYBOARD.navigationTree:Commit()
	end

	function ZO_TimedActivities_Gamepad:InitializeActivityFinderCategory()
	    TIMED_ACTIVITIES_GAMEPAD_FRAGMENT = self.sceneFragment
	    self.scene:AddFragment(self.sceneFragment)

	    local primaryCurrencyType = TIMED_ACTIVITIES_MANAGER.GetPrimaryTimedActivitiesCurrencyType()
	    self.categoryData =
	    {
	        gamepadData =
	        {
	            priority = ZO_ACTIVITY_FINDER_SORT_PRIORITY.TIMED_ACTIVITIES,
	            name = GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES),
	            menuIcon = "EsoUI/Art/LFG/Gamepad/LFG_menuIcon_timedActivities.dds",
	            sceneName = "TimedActivitiesGamepad",
	            tooltipDescription = zo_strformat(SI_GAMEPAD_ACTIVITY_FINDER_TOOLTIP_TIMED_ACTIVITIES, GetCurrencyName(primaryCurrencyType), GetString(SI_GAMEPAD_MAIN_MENU_ENDEAVOR_SEAL_MARKET_ENTRY)),
	        },
	    }

	    local gamepadData = self.categoryData.gamepadData
	    ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:AddCategory(gamepadData, gamepadData.priority)
	end

	local entryData = ZO_GamepadEntryData:New(il8n.menuName)
    entryData:SetDataSource({activityType = cheesyActivityTypeIndex})
    TIMED_ACTIVITIES_GAMEPAD.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", entryData)
    TIMED_ACTIVITIES_GAMEPAD.categoryList:Commit()

	local function onCheesyEndeavorsSelected()
	    TIMED_ACTIVITIES_KEYBOARD:SetCurrentActivityType(cheesyActivityTypeIndex)
	end
	GROUP_MENU_KEYBOARD.navigationTree:Reset()
	table.insert(GROUP_MENU_KEYBOARD.nodeList[2]["children"] , {
		priority = ZO_ACTIVITY_FINDER_SORT_PRIORITY.TIMED_ACTIVITIES + cheesyActivityTypeIndex * 10 + 10,
		name = il8n.menuName,
		categoryFragment = TIMED_ACTIVITIES_KEYBOARD.sceneFragment,
		onTreeEntrySelected = onCheesyEndeavorsSelected,
	})
	GROUP_MENU_KEYBOARD:AddCategoryTreeNodes(GROUP_MENU_KEYBOARD.nodeList)
	GROUP_MENU_KEYBOARD.navigationTree:Commit()


	TIMED_ACTIVITIES_MANAGER.activityTypeLimitData[cheesyActivityTypeIndex] = {completed = 0, limit = 6}
	-- Group up and wipe 5 times
	-- Say "I love cheese!" in zone chat
	-- Pay a visit to Sheogorath
	-- Make a new friend
	-- 'Rewards': negative cheese wheels. Or sanity


	local standardReward =
	{
		GetKeyboardIcon = function() return "/esoui/art/icons/heraldrycrests_misc_blank_01.dds" end,--return "/esoui/art/icons/quest_trollfat_001.dds" end,
		GetGamepadIcon = function() return "/esoui/art/icons/heraldrycrests_misc_blank_01.dds" end,--	return "/esoui/art/icons/quest_trollfat_001.dds" end,
		GetAbbreviatedQuantity = function() return il8n.reward end,
		GetFormattedNameWithStack = function() return il8n.rewardStylized end,
	}

	local timedActivityData = 
	{
		{timedActivityId = 1000, index = 9, maxProgress = 1, reward = {standardReward}, svkey="cheeseProfession"},
		{timedActivityId = 1001, index = 9, maxProgress = 1, reward = {standardReward}, svkey="sheoVisit"},
		{timedActivityId = 1003, index = 9, maxProgress = 1, reward = {standardReward}, svkey="music"}, -- aka Play a joke on some group members?
		{timedActivityId = 1003, index = 9, maxProgress = 1, reward = {standardReward}, svkey="cheesyDestruction"},
		{timedActivityId = 1003, index = 9, maxProgress = 1, reward = {standardReward}, svkey="cheeseNerd"}, -- AKA Cheeses of Tamriel
	}
	local finalReward = ZO_ShallowTableCopy(standardReward)
	finalReward.GetAbbreviatedQuantity = function() return "???" end
	finalReward.GetFormattedNameWithStack = function() return il8n.finalReward end

	timedActivityData[#timedActivityData + 1] = {timedActivityId = 1004, index = 9, maxProgress = #timedActivityData, reward = {finalReward}, svkey="cheeseCompletion"}
	for i = 1, #timedActivityData do
		timedActivityData[i].name = il8n.tasks[i].name
		timedActivityData[i].completion = il8n.tasks[i].completion
		timedActivityData[i].description = il8n.tasks[i].description
	end

	local activityDataObjects = {}
	local function addNewTimedActivities()

		for k, v in pairs(timedActivityData) do
			local newData = ZO_TimedActivityData:New(2000 + k)
			newData.GetType = function(...) return cheesyActivityTypeIndex end
			newData.GetName = function(...) return v.name end
			newData.GetDescription = function(...) return v.description end
			newData.GetMaxProgress = function(...) return v.maxProgress end
			newData.GetProgress = function (...) return WritCreater.savedVarsAccountWide.cheesyProgress[v.svkey] or 0 end
			newData.GetRewardList = function(...) return v.reward end
			newData.timedActivityId = 1000 + k
			table.insert(TIMED_ACTIVITIES_MANAGER.activitiesData, newData)
			activityDataObjects[1000 + k] = newData
		end
	end
	local originalNewTimedActivityData = ZO_TimedActivityData.New
	ZO_TimedActivityData.New = function(self, activityIndex, ...)
		if activityIndex > 1000 then
			return activityDataObjects[activityIndex] or originalNewTimedActivityData(self, activityIndex)
		else
			return originalNewTimedActivityData(self, activityIndex)
		end
	end
	local function isCheeseActivity(item)
		return item:GetType() == cheesyActivityTypeIndex
	end
	function TIMED_ACTIVITIES_GAMEPAD:Refresh()
		TIMED_ACTIVITIES_GAMEPAD.headerData["data3HeaderText"] = il8n.endeavorName
		TIMED_ACTIVITIES_GAMEPAD.headerData["data3Text"] = function() return WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"].."/6" end
	    local currentActivityType = self:GetCurrentActivityType()
	    local activityTypeFilters
	    if currentActivityType == TIMED_ACTIVITY_TYPE_DAILY then
	        activityTypeFilters = { ZO_TimedActivityData.IsDailyActivity }
	    elseif currentActivityType == TIMED_ACTIVITY_TYPE_WEEKLY then
	        activityTypeFilters = { ZO_TimedActivityData.IsWeeklyActivity }
	    elseif currentActivityType == cheesyActivityTypeIndex then
	    	
	        activityTypeFilters = { isCheeseActivity }
	    end

	    local activitiesList = {}
	    for index, activityData in TIMED_ACTIVITIES_MANAGER:ActivitiesIterator(activityTypeFilters) do
	        table.insert(activitiesList, activityData)
	    end
	    
	    self.activitiesList:RefreshList(currentActivityType, activitiesList)
	    self:RefreshAvailability()
	    self:RefreshCurrentActivityInfo()
	    ZO_GamepadGenericHeader_RefreshData(self.header, self.headerData)
	end
local gpadActivitiesList = TIMED_ACTIVITIES_GAMEPAD.activitiesList
	
	function TIMED_ACTIVITIES_GAMEPAD.activitiesList:RefreshList(currentActivityType, activitiesList)

	    self.isAtActivityLimit = TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(currentActivityType)

	    local listControl = self.listControl
	    ZO_ScrollList_Clear(listControl)

	    local listData = ZO_ScrollList_GetDataList(listControl)
	    for index, activityData in ipairs(activitiesList) do
	        local entryData = ZO_EntryData:New(activityData)
	        local activityName = activityData:GetName()
	        local numActivityNameLines = ZO_LabelUtils_GetNumLines(activityName, "ZoFontGamepad45", ZO_TIMED_ACTIVITY_DATA_ROW_NAME_WIDTH_GAMEPAD)

	        local dataType = 1
	        if numActivityNameLines == 2 then
	            dataType = 2
	        elseif numActivityNameLines == 3 then
	            dataType = 3
	        elseif numActivityNameLines == 4 then
	            dataType = 4
	        elseif numActivityNameLines == 5 then
	            dataType = 5
	        end

	        table.insert(listData, ZO_ScrollList_CreateDataEntry(dataType, entryData))
	    end

	    self:CommitScrollList()
	    local isListEmpty = not ZO_ScrollList_HasVisibleData(listControl)
	    listControl:SetHidden(isListEmpty)
	end

	function gpadActivitiesList:OnSelectionChanged(oldData, newData)
		
	    ZO_SortFilterList.OnSelectionChanged(self, oldData, newData)
	    -- d(newData)
	    -- self.listControl.selectedDataIndex = self.listControl.selectedDataIndex + 1
	    if newData then
	        local activityIndex = newData:GetIndex()
	        self:ShowActivityTooltip(activityIndex)
	    else
	        self:ClearActivityTooltip()
	    end
	end

	local originalMasterList = TIMED_ACTIVITIES_MANAGER.RefreshMasterList
	TIMED_ACTIVITIES_MANAGER.RefreshMasterList = function(...)
		originalMasterList(...)
		addNewTimedActivities()
	end
	TIMED_ACTIVITIES_MANAGER.availableActivityTypes[cheesyActivityTypeIndex] = true
	local originalManagerTiming = TIMED_ACTIVITIES_MANAGER.GetTimedActivityTypeTimeRemainingSeconds
	TIMED_ACTIVITIES_MANAGER.GetTimedActivityTypeTimeRemainingSeconds = function(self, activityType,...)
		if activityType == cheesyActivityTypeIndex then
			return (1648879200 - GetTimeStamp()) % 86400
		else
			return originalManagerTiming(self, activityType, ...)
		end
	end
	local originalKeyboardRefresh = ZO_TimedActivities_Keyboard.Refresh
	function ZO_TimedActivities_Keyboard:Refresh()
		if self:GetCurrentActivityType() ~= cheesyActivityTypeIndex then
			return originalKeyboardRefresh(self)
		end
		if self:GetCurrentActivityType() == nil then return end
	    ZO_ClearNumericallyIndexedTable(self.activitiesData)
	    TIMED_ACTIVITIES_MANAGER.activityTypeLimitData[cheesyActivityTypeIndex].completed = WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"]

	    local currentActivityType = self:GetCurrentActivityType()
	    local activityTypeFilters
	    if currentActivityType == TIMED_ACTIVITY_TYPE_DAILY then
	        activityTypeFilters = { ZO_TimedActivityData.IsDailyActivity }
	    elseif currentActivityType == TIMED_ACTIVITY_TYPE_WEEKLY then
	        activityTypeFilters = { ZO_TimedActivityData.IsWeeklyActivity }
	    elseif currentActivityType == cheesyActivityTypeIndex then
	        activityTypeFilters = { isCheeseActivity }
	    end

	    for index, activityData in TIMED_ACTIVITIES_MANAGER:ActivitiesIterator(activityTypeFilters) do
	        table.insert(self.activitiesData, activityData)
	    end

	    self.activityRewardPool:ReleaseAllObjects()
	    self.activityRowPool:ReleaseAllObjects()
	    self.nextActivityAnchorTo = nil

	    self.isAtActivityLimit = TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(currentActivityType)

	    for index, activityData in ipairs(self.activitiesData) do
	        self:AddActivityRow(activityData)
	    end
	    self:RefreshAvailability()

	    self:RefreshCurrentActivityInfo()
	end
	local function cheeseEndeavorCompleted(subHeading)
		TIMED_ACTIVITIES_MANAGER.activityTypeLimitData[cheesyActivityTypeIndex].completed = TIMED_ACTIVITIES_MANAGER.activityTypeLimitData[cheesyActivityTypeIndex].completed + 1
		WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"] = WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"] + 1
		pcall(function()TIMED_ACTIVITIES_KEYBOARD:Refresh() end )
		local activityTypeName = "CHEESY ENDEAVOR" --GetString("SI_TIMEDACTIVITYTYPE", 2)
	    -- local _, maxNumActivities = TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeLimitInfo(2)
	    local messageTitle = zo_strformat(SI_TIMED_ACTIVITY_TYPE_COMPLETED_CSA,  WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"], #timedActivityData - 1, il8n.menuName)
	    -- local messageTitle = zo_strformat(SI_TIMED_ACTIVITY_TYPE_COMPLETED_CSA, 6, #timedActivityData, "Cheesy")
	    local messageSubheading = subHeading
	    if  WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"] < #timedActivityData - 1 then
	    	messageSubheading = subHeading
	    end

	    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
	    messageParams:SetText(messageTitle, messageSubheading)
	    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)

	    if WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"] == #timedActivityData - 1 then
	    	WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"] = 6
	    	local finalMessageTitle = il8n.allComplete
	    	local finalSubheading = timedActivityData[6].completion
	    	local finalMessageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
		    finalMessageParams:SetText(finalMessageTitle, finalSubheading)
		    -- zo_callLater( function()
		    	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(finalMessageParams)
		    -- end, 1500 )

		    WritCreater.savedVarsAccountWide.skin = "cheese"
		    WritCreater.savedVarsAccountWide.unlockedCheese = true
	    end
	    PlaySound(SOUNDS.ENDEAVOR_COMPLETED)
	end
	-- listeners
	-- Chese profession
	local function alternateListener(eventCode,  channelType, fromName, text, isCustomerService, fromDisplayName)

		if isCheeseOn() and WritCreater and WritCreater.savedVarsAccountWide and WritCreater.savedVarsAccountWide.cheesyProgress 
			and WritCreater.savedVarsAccountWide.cheesyProgress["cheeseProfession"] == 0 and (fromDisplayName == GetDisplayName() or channelType == 4) then
			text = text:lower()
			text = text:gsub(" ", "")
			text = text:gsub("!", "")
			text = text:gsub("%.", "")
			text = text:gsub("'", "")
			text = text:gsub("ä", "a")
			if WritCreater.cheeseBingos[text] then
				WritCreater.savedVarsAccountWide.cheesyProgress["cheeseProfession"] = 1
				cheeseEndeavorCompleted(timedActivityData[1].completion)
			end
		end
	end
	EVENT_MANAGER:RegisterForEvent(WritCreater.name.."cheeeeese",EVENT_CHAT_MESSAGE_CHANNEL, alternateListener)
	-- Music
	--5, 6, 7
	-- /script local a = PlayEmoteByIndex PlayEmoteByIndex = function(...) d(...) a(...) end
	local terribleMusicEmotes = 
	{
		[4] = '/horn',
		[5] = '/lute',
		[6] = '/drum',
		[7] = '/flute',
		[251] = '/festivebellring',
		[271] = '/esraj',
		[272] = '/qanun',
	}
	-- /playtinyviolin, /festivebellring
	local originalEmoteFunction = PlayEmoteByIndex
	PlayEmoteByIndex = function(index, ...)
		originalEmoteFunction(index, ...)
		if WritCreater.savedVarsAccountWide.cheesyProgress['music'] == 0 and terribleMusicEmotes[index] then
			WritCreater.savedVarsAccountWide.cheesyProgress['music'] = 1
			cheeseEndeavorCompleted(timedActivityData[3].completion)
		end
	end
	local setup = false
	-- local function setupCheesyMusic()
	-- 	if setup then return end
	-- 	setup = true
	-- 	for k, v in pairs(terribleMusicEmotes) do
	-- 		local originalMusic = SLASH_COMMANDS[v]
	-- 		SLASH_COMMANDS[v] = function(...) originalMusic(...) 
	-- 			if WritCreater.savedVarsAccountWide.cheesyProgress['music'] == 0 then
	-- 				WritCreater.savedVarsAccountWide.cheesyProgress['music'] = 1
	-- 				cheeseEndeavorCompleted(timedActivityData[3].completion)
	-- 			end
	-- 		end
	-- 	end
	-- end
	local sheoStrings = 
	{
		en = "Sheogorath",
		de = "Sheogorath",
		fr = "Shéogorath",
		jp = "シェオゴラス",
	}
	-- EVENT_MANAGER:RegisterForEvent(WritCreater.name.."cheesyMusic", EVENT_PLAYER_ACTIVATED, setupCheesyMusic)
	-- Handles the dialogue where we actually complete the quest
	local function isItUncleSheo(eventCode, journalIndex)
		if WritCreater.savedVarsAccountWide.cheesyProgress['sheoVisit'] == 0 and zo_plainstrfind( ZO_InteractWindowTargetAreaTitle:GetText() ,sheoStrings[GetCVar("language.2")]) then
			--d("complete")
			WritCreater.savedVarsAccountWide.cheesyProgress['sheoVisit'] = 1
			cheeseEndeavorCompleted(timedActivityData[2].completion)
			return 
		end
	end
	EVENT_MANAGER:RegisterForEvent(WritCreater.name.."FunWithSheo", EVENT_CHATTER_BEGIN, isItUncleSheo)

	local function cheesyScholar(_,_,_,_,_,  bookId)
		if bookId == 1145 then
			if WritCreater.savedVarsAccountWide.cheesyProgress['cheeseNerd'] == 0 then
			WritCreater.savedVarsAccountWide.cheesyProgress['cheeseNerd'] = 1
			cheeseEndeavorCompleted(timedActivityData[5].completion)
			end
		end
	end
	local originalCheatyCheeseBook = ZO_LoreLibrary_ReadBook
	ZO_LoreLibrary_ReadBook = function(categoryIndex, collectionIndex, bookIndex,...)
		if WritCreater.savedVarsAccountWide.cheesyProgress['cheeseNerd'] == 0 and categoryIndex == 3 and collectionIndex == 9 and bookIndex == 46  then
			ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR , il8n["cheatyCheeseBook"])
		else
			originalCheatyCheeseBook(categoryIndex, collectionIndex, bookIndex,...)
		end
	end
	EVENT_MANAGER:RegisterForEvent(WritCreater.name.."cheeseScholar", EVENT_SHOW_BOOK, cheesyScholar)
--ITEM_SOUND_CATEGORY_FOOD
	local requestedCheeseMonster = false
	local function cheeseMonsterConfirmed(eventCode, sound)
		--- 38 is the sound cheese makes Must be squeaky right?
		if sound == 38 and WritCreater.savedVarsAccountWide.cheesyProgress['cheesyDestruction'] == 0 then
			WritCreater.savedVarsAccountWide.cheesyProgress['cheesyDestruction'] = 1
			cheeseEndeavorCompleted(timedActivityData[4].completion)
		end
		requestedCheeseMonster = false
		EVENT_MANAGER:UnregisterForEvent(WritCreater.name.."cheeseMonsterConfirmed", EVENT_INVENTORY_ITEM_DESTROYED)
		EVENT_MANAGER:UnregisterForEvent(WritCreater.name.."notACheeseMonster", EVENT_INVENTORY_ITEM_DESTROYED)
	end
	local function notACheeseMonster(eventCode)
		EVENT_MANAGER:UnregisterForEvent(WritCreater.name.."cheeseMonsterConfirmed", EVENT_INVENTORY_ITEM_DESTROYED)
		EVENT_MANAGER:UnregisterForEvent(WritCreater.name.."notACheeseMonster", EVENT_INVENTORY_ITEM_DESTROYED)
		requestedCheeseMonster = false
	end
	
	local function cheeseMonster( eventCode,  bagId,  slotIndex,  itemCount,  name,  needsConfirm)
		local itemId = GetItemId(bagId, slotIndex)
		if WritCreater.savedVarsAccountWide.cheesyProgress['cheesyDestruction'] == 0 and itemId == 27057 then
			requestedCheeseMonster = true
			EVENT_MANAGER:RegisterForEvent(WritCreater.name.."cheeseMonsterConfirmed", EVENT_INVENTORY_ITEM_DESTROYED, cheeseMonsterConfirmed)
			EVENT_MANAGER:RegisterForEvent(WritCreater.name.."notACheeseMonster", EVENT_INVENTORY_ITEM_DESTROYED, notACheeseMonster)
		else
			requestedCheeseMonster = false
		end
	end
	local originalDestroyItem = DestroyItem
	DestroyItem = function(bag,slot,...)
		local itemId = GetItemId(bagId, slotIndex)
		if WritCreater.savedVarsAccountWide.cheesyProgress['cheesyDestruction'] == 0 and itemId == 27057 then
			WritCreater.savedVarsAccountWide.cheesyProgress['cheesyDestruction'] = 1
			cheeseEndeavorCompleted(timedActivityData[4].completion)
		end
		originalDestroyItem(bag, slot, ...)
	end
	EVENT_MANAGER:RegisterForEvent(WritCreater.name.."CheeseMonster", EVENT_MOUSE_REQUEST_DESTROY_ITEM , cheeseMonster)
	-- /esraj /lute /drum /flute 
	-- if GetDisplayName() == "@Dolgubon" then
	-- 	enableAlternateUniverse(true)	
	-- 	WritCreater.WipeThatFrownOffYourFace(true)	
	-- end
	SLASH_COMMANDS['/resetcheeseprogress'] = function() 
		for k, v in pairs (WritCreater.savedVarsAccountWide.cheesyProgress) do 
			WritCreater.savedVarsAccountWide.cheesyProgress[k] = 1
		end 
		WritCreater.savedVarsAccountWide.cheesyProgress["cheeseProfession"] = 0
		WritCreater.savedVarsAccountWide.cheesyProgress["cheeseCompletion"] = 4
		pcall(function()TIMED_ACTIVITIES_KEYBOARD:Refresh() end )
	end
	SLASH_COMMANDS['/resetcheeseprogresscomplete'] = function() 
		for k, v in pairs (WritCreater.savedVarsAccountWide.cheesyProgress) do 
			WritCreater.savedVarsAccountWide.cheesyProgress[k] = 0
		end 
		pcall(function()TIMED_ACTIVITIES_KEYBOARD:Refresh() end )
	end
	
end


function WritCreater.Options() --Sentimental
	
	local options =  {
		{
			type = "header",
			name = function() 
				local profile = WritCreater.optionStrings.accountWide
				if WritCreater.savedVars.useCharacterSettings then
					profile = WritCreater.optionStrings.characterSpecific
				end
				return  string.format(WritCreater.optionStrings.nowEditing, profile)  
			end, -- or string id or function returning a string
		},

		{
			type = "checkbox",
			name = WritCreater.optionStrings.useCharacterSettings,
			tooltip = WritCreater.optionStrings.useCharacterSettingsTooltip,
			getFunc = function() return WritCreater.savedVars.useCharacterSettings end,
			setFunc = function(value) 
				WritCreater.savedVars.useCharacterSettings = value
			end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full",
		},
		
		{
			type = "checkbox",
			name = WritCreater.optionStrings["autocraft"]  ,
			tooltip = WritCreater.optionStrings["autocraft tooltip"] ,
			getFunc = function() return WritCreater:GetSettings().autoCraft end,
			disabled = function() return not WritCreater:GetSettings().showWindow end,
			setFunc = function(value) 
				WritCreater:GetSettings().autoCraft = value 
			end,
		},
		
		
		{
			type = "checkbox",
			name = WritCreater.optionStrings["master"],--"Master Writs",
			tooltip = WritCreater.optionStrings["master tooltip"],--"Craft Master Writ Items",
			getFunc = function() return WritCreater.savedVarsAccountWide.masterWrits end,
			setFunc = function(value) 
			WritCreater.savedVarsAccountWide.masterWrits = value
			if LibCustomMenu or WritCreater.savedVarsAccountWide.rightClick then
				WritCreater.savedVarsAccountWide.rightClick = not value
			end
			WritCreater.LLCInteraction:cancelItem()
				if value  then
					
					for i = 1, 25 do WritCreater.MasterWritsQuestAdded(1, i,GetJournalQuestName(i)) end
				end
				
				
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["right click to craft"],--"Master Writs",
			tooltip = WritCreater.optionStrings["right click to craft tooltip"],--"Craft Master Writ Items",
			getFunc = function() return WritCreater.savedVarsAccountWide.rightClick end,
			disabled = not LibCustomMenu or WritCreater.savedVarsAccountWide.rightClick,
			warning = "This option requires LibCustomMenu",
			setFunc = function(value) 
			WritCreater.savedVarsAccountWide.masterWrits = not value
			WritCreater.savedVarsAccountWide.rightClick = value
			WritCreater.LLCInteraction:cancelItem()
				if not value  then
					
					for i = 1, 25 do WritCreater.MasterWritsQuestAdded(1, i,GetJournalQuestName(i)) end
				end
			end,
		},
		{
			type = "dropdown",
			name = WritCreater.optionStrings['dailyResetWarnType'],--"Master Writs",
			tooltip = WritCreater.optionStrings['dailyResetWarnTypeTooltip'],--"Craft Master Writ Items",
			choices = WritCreater.optionStrings["dailyResetWarnTypeChoices"],
			choicesValues = {"none","announcement","alert","chat","window","all"},
			getFunc = function() return WritCreater:GetSettings().dailyResetWarnType end,
			setFunc = function(value) 
				WritCreater:GetSettings().dailyResetWarnType = value 
				WritCreater.showDailyResetWarnings("Example") -- Show the example warnings
			end
		},
		{
		    type = "slider",
		    name = WritCreater.optionStrings['dailyResetWarnTime'], -- or string id or function returning a string
		    getFunc = function() return WritCreater:GetSettings().dailyResetWarnTime end,
		    setFunc = function(value) WritCreater:GetSettings().dailyResetWarnTime = math.max(0,value) WritCreater.refreshWarning() end,
		    min = 0,
		    max = 300,
		    step = 1, --(optional)
		    clampInput = false, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
		    tooltip = WritCreater.optionStrings['dailyResetWarnTimeTooltip'], -- or string id or function returning a string (optional)
		    requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
		} ,
		{
			type = "checkbox",
			name = WritCreater.optionStrings['stealingProtection'], -- or string id or function returning a string
			getFunc = function() return WritCreater:GetSettings().stealProtection end,
			setFunc = function(value) WritCreater:GetSettings().stealProtection = value end,
			tooltip = WritCreater.optionStrings['stealingProtectionTooltip'], -- or string id or function returning a string (optional)
		} ,
		{
			type = "checkbox",
			name = WritCreater.optionStrings['suppressQuestAnnouncements'], -- or string id or function returning a string
			getFunc = function() return WritCreater:GetSettings().suppressQuestAnnouncements end,
			setFunc = function(value) WritCreater:GetSettings().suppressQuestAnnouncements = value end,
			tooltip = WritCreater.optionStrings['suppressQuestAnnouncementsTooltip'], -- or string id or function returning a string (optional)
		} ,

			
	}

	if WritCreater.savedVarsAccountWide.unlockedCheese then
		table.insert(options, 4,
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full",
		})
		table.insert(options, 4, 
			{
			type = "dropdown",
			name = WritCreater.optionStrings["skin"],--"Master Writs",
			tooltip =WritCreater.optionStrings["skinTooltip"],--"Craft Master Writ Items",
			choices = WritCreater.optionStrings["skinOptions"],
			choicesValues = {"default","cheese"},
			getFunc = function() return WritCreater.savedVarsAccountWide.skin end,
			setFunc = function(value) 
				WritCreater.savedVarsAccountWide.skin  = value
			end
		}
		)
	end
----------------------------------------------------
----- TIMESAVERS SUBMENU

	local timesaverOptions =
	{
		{
			type = "checkbox",
			name = WritCreater.optionStrings["automatic complete"],
			tooltip = WritCreater.optionStrings["automatic complete tooltip"],
			getFunc = function() return WritCreater:GetSettings().autoAccept end,
			setFunc = function(value) WritCreater:GetSettings().autoAccept = value end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings['autoCloseBank'],
			tooltip = WritCreater.optionStrings['autoCloseBankTooltip'],
			getFunc = function() return  WritCreater:GetSettings().autoCloseBank end,
			setFunc = function(value) 
				WritCreater:GetSettings().autoCloseBank = value
				if not value then
					EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_OPEN_BANK, WritCreater.alchGrab)
				else
					EVENT_MANAGER:UnregisterForEvent(WritCreater.name)
				end
			end,
		},

		{
			type = "checkbox",
			name = WritCreater.optionStrings['despawnBanker'],
			tooltip = WritCreater.optionStrings['despawnBankerTooltip'],
			getFunc = function() return  WritCreater:GetSettings().despawnBanker end,
			setFunc = function(value) 
				WritCreater:GetSettings().despawnBanker = value
			end,
			disabled = function() return not WritCreater:GetSettings().autoCloseBank end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["exit when done"],
			tooltip = WritCreater.optionStrings["exit when done tooltip"],
			getFunc = function() return WritCreater:GetSettings().exitWhenDone end,
			setFunc = function(value) WritCreater:GetSettings().exitWhenDone = value end,
		},
		{
			type = "dropdown",
			name = WritCreater.optionStrings["autoloot behaviour"]	,
			tooltip = WritCreater.optionStrings["autoloot behaviour tooltip"],
			choices = WritCreater.optionStrings["autoloot behaviour choices"],
			choicesValues = {1,2,3},
			getFunc = function() if not WritCreater:GetSettings().ignoreAuto then return 1 elseif WritCreater:GetSettings().autoLoot then return 2 else return 3 end end,
			setFunc = function(value) 
				if value == 1 then 
					WritCreater:GetSettings().ignoreAuto = false
				elseif value == 2 then  
					WritCreater:GetSettings().autoLoot = true
					WritCreater:GetSettings().ignoreAuto = true
				elseif value == 3 then
					WritCreater:GetSettings().ignoreAuto = true
					WritCreater:GetSettings().autoLoot = false
				end
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["new container"],
			tooltip = WritCreater.optionStrings["new container tooltip"],
			getFunc = function() return WritCreater:GetSettings().keepNewContainer end,
			setFunc = function(value) 
			WritCreater:GetSettings().keepNewContainer = value			
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["loot container"],
			tooltip = WritCreater.optionStrings["loot container tooltip"],
			getFunc = function() return WritCreater:GetSettings().lootContainerOnReceipt end,
			setFunc = function(value) 
			WritCreater:GetSettings().lootContainerOnReceipt = value					
			end,
		},
		--[[{
			type = "slider",
			name = WritCreater.optionStrings["container delay"],
			tooltip = WritCreater.optionStrings["container delay tooltip"]    ,
			min = 0,
			max = 5,
			getFunc = function() return WritCreater:GetSettings().containerDelay end,
			setFunc = function(value)
			WritCreater:GetSettings().containerDelay = value
			end,
			disabled = function() return not WritCreater:GetSettings().lootContainerOnReceipt end,
		  },--]]
		{
			type = "checkbox",
			name = WritCreater.optionStrings["master writ saver"],
			tooltip = WritCreater.optionStrings["master writ saver tooltip"],
			getFunc = function() return WritCreater:GetSettings().preventMasterWritAccept end,
			setFunc = function(value) 
			WritCreater:GetSettings().preventMasterWritAccept = value					
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["loot output"],--"Master Writs",
			tooltip = WritCreater.optionStrings["loot output tooltip"],--"Craft Master Writ Items",
			getFunc = function() return WritCreater:GetSettings().lootOutput end,
			setFunc = function(value) 
			WritCreater:GetSettings().lootOutput = value					
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings['reticleColour'],--"Master Writs",
			tooltip = WritCreater.optionStrings['reticleColourTooltip'],--"Craft Master Writ Items",
			getFunc = function() return  WritCreater:GetSettings().changeReticle end,
			setFunc = function(value) 
				WritCreater:GetSettings().changeReticle = value
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings['noDELETEConfirmJewelry'],--"Master Writs",
			tooltip = WritCreater.optionStrings['noDELETEConfirmJewelryTooltip'],--"Craft Master Writ Items",
			getFunc = function() return  WritCreater:GetSettings().EZJewelryDestroy end,
			setFunc = function(value) 
				WritCreater:GetSettings().EZJewelryDestroy = value
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings['questBuffer'],--"Master Writs",
			tooltip = WritCreater.optionStrings['questBufferTooltip'],--"Craft Master Writ Items",
			getFunc = function() return  WritCreater:GetSettings().keepQuestBuffer end,
			setFunc = function(value) 
				WritCreater:GetSettings().keepQuestBuffer = value
			end,
		},
		{
			type = "slider",
			name = WritCreater.optionStrings['craftMultiplier'],--"Master Writs",
			tooltip = WritCreater.optionStrings['craftMultiplierTooltip'],--"Craft Master Writ Items",
			min = 1,
			max = 8,
			step = 1,
			getFunc = function() return  WritCreater:GetSettings().craftMultiplier end,
			setFunc = function(value) 
				WritCreater:GetSettings().craftMultiplier = value
			end,
		},
		{
			type = "dropdown",
			name = WritCreater.optionStrings["hireling behaviour"]	,
			tooltip = WritCreater.optionStrings["hireling behaviour tooltip"],
			choices = WritCreater.optionStrings["hireling behaviour choices"],
			choicesValues = {1,2,3},
			getFunc = function() if WritCreater:GetSettings().mail.delete then return 2 elseif WritCreater:GetSettings().mail.loot then return 3 else return 1 end end,
			setFunc = function(value) 
				if value == 1 then 
					WritCreater:GetSettings().mail.delete = false
					WritCreater:GetSettings().mail.loot = false
				elseif value == 2 then  
					WritCreater:GetSettings().mail.delete = true
					WritCreater:GetSettings().mail.loot = true
				elseif value == 3 then
					WritCreater:GetSettings().mail.delete = false
					WritCreater:GetSettings().mail.loot = true
				end
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["scan for unopened"]	,
			tooltip = WritCreater.optionStrings["scan for unopened tooltip"],
			getFunc = function() return  WritCreater:GetSettings().scanForUnopened end,
			setFunc = function(value) 
				WritCreater:GetSettings().scanForUnopened = value
			end,
		},
	}

----------------------------------------------------
----- REWARDS SUBMENU
	local rewardsSubmenu = {
		-- Options: Nothing, destroy, deposit, junk (Vendor?)
		-- Enchanting
			-- Surveys
			-- master writs
			-- mats
			-- glyphs
			-- empty soul gems
		-- Alchemy
			-- Surveys
			-- master writs
			-- mats
		-- provisioning
			-- recipes
			-- mats
			-- psijic fragment

	}
	local function geRewardTypeOption(craftingIndex, rewardName)
		return {
				type = "dropdown",
				name =  WritCreater.langWritNames()[craftingIndex],
				tooltip = WritCreater.optionStrings[craftingIndex.."RewardTooltip"],
				choices = WritCreater.optionStrings["rewardChoices"],
				choicesValues = {1,2,3, 4},
				disabled = function() return WritCreater:GetSettings().rewardHandling[rewardName].sameForAllCrafts end,
				getFunc = function()
					-- So I don't need to ennummerate it all in the default writ creator settings
					if not  WritCreater:GetSettings().rewardHandling[rewardName][craftingIndex] then
						WritCreater:GetSettings().rewardHandling[rewardName][craftingIndex] = 1
					end
					return WritCreater:GetSettings().rewardHandling[rewardName][craftingIndex] end ,
				setFunc = function(value) 
					WritCreater:GetSettings().rewardHandling[rewardName][craftingIndex] = value
				end,
			}
	end
	local validForReward = 
	{
		-- {"mats" ,    {1,2,3,4,5,6,7}, },
		{"repair" ,  {}, false},
		{"master" ,  {1,2,3,4,5,6,7}, true },
		{"survey" ,  {1,2,3,4,6,7}, true},
		-- {"ornate" ,  {1,2,6,7}, },
		-- {"intricate" ,  {1,2,6,7}, },
		
		-- {"soulGem" ,    {3}, },
		-- {"glyph" ,    {3}, },
		-- {"fragment" ,    {5}, },
		-- {"recipe" ,    {5}, },
	}
	local function rewardSubmenu(submenuOptions, craftingIndex)
		local writName
		if craftingIndex == 0 then
			writName = "Gear Crafts"
		else
			writName = WritCreater.langWritNames()[craftingIndex]
		end
		return {
			type = "submenu",
			name = writName,
			tooltip = WritCreater.optionStrings["writRewards submenu tooltip"],
			controls = submenuOptions,
			reference = "WritCreaterRewardsSubmenu"..craftingIndex,
		}
	end
	-- use same for all craft chaeckbox
	-- option to use
	------------------ divider
	-- per craft
	-- just the dropdown
	for i = 1, #validForReward do
		local rewardName, validCraftTypes = validForReward[i][1], validForReward[i][2]
		local submenuOptions
		if  #validCraftTypes > 1 then
			submenuOptions = {
				{
					type = "checkbox",
					name = WritCreater.optionStrings['sameForALlCrafts'],--"Master Writs",
					tooltip = WritCreater.optionStrings['sameForALlCraftsTooltip'],--"Craft Master Writ Items",
					getFunc = function() return  WritCreater:GetSettings().rewardHandling[rewardName].sameForAllCrafts end,
					setFunc = function(value) 
						WritCreater:GetSettings().rewardHandling[rewardName].sameForAllCrafts = value
					end,
				},
				{
					type = "dropdown",
					name =  WritCreater.optionStrings["allReward"]	,
					tooltip = WritCreater.optionStrings["allRewardTooltip"],
					choices = WritCreater.optionStrings["rewardChoices"],
					choicesValues = {1,2,3,4},
					disabled = function() return not WritCreater:GetSettings().rewardHandling[rewardName].sameForAllCrafts end,
					getFunc = function()
						-- So I don't need to ennummerate it all in the default writ creator settings
						if not  WritCreater:GetSettings().rewardHandling[rewardName]["all"] then
							WritCreater:GetSettings().rewardHandling[rewardName]["all"] = 1
						end
						return WritCreater:GetSettings().rewardHandling[rewardName]["all"] end ,
					setFunc = function(value)
						local oldValue = WritCreater:GetSettings().rewardHandling[rewardName]["all"]
						for k, v in pairs(WritCreater:GetSettings().rewardHandling[rewardName]) do
							if WritCreater:GetSettings().rewardHandling[rewardName][k] == oldValue then
								WritCreater:GetSettings().rewardHandling[rewardName][k] = value
							end
						end
					end,
				},
				{
					type = "divider",
					height = 15,
					alpha = 0.5,
					width = "full",
				},
			}
			for j = 1, #validCraftTypes do
				submenuOptions[#submenuOptions + 1] = geRewardTypeOption(validCraftTypes[j], rewardName)
			end
			rewardsSubmenu[#rewardsSubmenu + 1] = {
			type = "submenu",
			name = WritCreater.optionStrings[rewardName.."Reward"],
			tooltip = WritCreater.optionStrings[rewardName.."RewardTooltip"],
			controls = submenuOptions,
			reference = "WritCreaterRewardsSubmenu"..rewardName,
		}
		else
			rewardsSubmenu[#rewardsSubmenu + 1] = {
				type = "dropdown",
				name =  WritCreater.optionStrings[rewardName.."Reward"]	,
				tooltip = WritCreater.optionStrings["allRewardTooltip"],
				choices = WritCreater.optionStrings["rewardChoices"],
				choicesValues = {1,2,3,4},
				disabled = function() return not WritCreater:GetSettings().rewardHandling[rewardName].sameForAllCrafts end,
				getFunc = function()
					-- So I don't need to ennummerate it all in the default writ creator settings
					if not  WritCreater:GetSettings().rewardHandling[rewardName]["all"] then
						WritCreater:GetSettings().rewardHandling[rewardName]["all"] = 1
					end
					return WritCreater:GetSettings().rewardHandling[rewardName]["all"] end ,
				setFunc = function(value)
					local oldValue = WritCreater:GetSettings().rewardHandling[rewardName]["all"]
					for k, v in pairs(WritCreater:GetSettings().rewardHandling[rewardName]) do
						if WritCreater:GetSettings().rewardHandling[rewardName][k] == oldValue then
							WritCreater:GetSettings().rewardHandling[rewardName][k] = value
						end
					end
				end,
			}
		end
		
		
	end
	-- local gearWrits = {1, 2, 6, 7}
	-- for _, craftingIndex in pairs(gearWrits) do

	-- 	local gearTemplateMenu =
	-- 	{
	-- 		geRewardTypeOption(0, "mats"),
	-- 		geRewardTypeOption(0, "survey"),
	-- 		geRewardTypeOption(0, "master"),
	-- 		geRewardTypeOption(0, "repair"),
	-- 		geRewardTypeOption(0, "ornate"),
	-- 		geRewardTypeOption(0, "intricate"),
	-- 	}
	-- 	rewardsSubmenu[1] = rewardSubmenu(gearTemplateMenu, 0)
	-- 	rewardsSubmenu[1].tooltip = "What to do with rewards from Blacksmithing, Clothing, Woodworking and Jewelry"
	-- -- end
	-- local enchantingSubmenu = {
	-- 	geRewardTypeOption(CRAFTING_TYPE_ENCHANTING, "mats"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_ENCHANTING, "survey"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_ENCHANTING, "master"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_ENCHANTING, "soulGem"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_ENCHANTING, "glyph"),
	-- }
	-- rewardsSubmenu[2] = rewardSubmenu(enchantingSubmenu, CRAFTING_TYPE_ENCHANTING)
	-- local alchemySubmenu = {
	-- 	geRewardTypeOption(CRAFTING_TYPE_ALCHEMY, "mats"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_ALCHEMY, "survey"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_ALCHEMY, "master"),
	-- }
	-- rewardsSubmenu[3] = rewardSubmenu(alchemySubmenu, CRAFTING_TYPE_ALCHEMY)
	-- local provisioningSubmenu = {
	-- 	geRewardTypeOption(CRAFTING_TYPE_PROVISIONING, "mats"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_PROVISIONING, "master"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_PROVISIONING, "fragment"),
	-- 	geRewardTypeOption(CRAFTING_TYPE_PROVISIONING, "recipe"),
	-- }
	-- rewardsSubmenu[4] = rewardSubmenu(provisioningSubmenu, CRAFTING_TYPE_PROVISIONING)
	
----------------------------------------------------
----- CRAFTING SUBMENU

	local craftSubmenu = {{
		type = "checkbox",
		name = WritCreater.optionStrings["blackmithing"]   ,
		tooltip = WritCreater.optionStrings["blacksmithing tooltip"] ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_BLACKSMITHING] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_BLACKSMITHING] = value 
		end,
	},
	{
		type = "checkbox",
		name = WritCreater.optionStrings["clothing"]  ,
		tooltip = WritCreater.optionStrings["clothing tooltip"] ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_CLOTHIER] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_CLOTHIER] = value 
		end,
	},
	{
	  type = "checkbox",
	  name = WritCreater.optionStrings["woodworking"]    ,
	  tooltip = WritCreater.optionStrings["woodworking tooltip"],
	  getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_WOODWORKING] end,
	  setFunc = function(value) 
		WritCreater:GetSettings()[CRAFTING_TYPE_WOODWORKING] = value 
	  end,
	},
	{
	  type = "checkbox",
	  name = WritCreater.optionStrings["jewelry crafting"]    ,
	  tooltip = WritCreater.optionStrings["jewelry crafting tooltip"],
	  getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_JEWELRYCRAFTING] end,
	  setFunc = function(value) 
		WritCreater:GetSettings()[CRAFTING_TYPE_JEWELRYCRAFTING] = value 
	  end,
	},

	{
		type = "checkbox",
		name = WritCreater.optionStrings["enchanting"],
		tooltip = WritCreater.optionStrings["enchanting tooltip"]  ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_ENCHANTING] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_ENCHANTING] = value 
		end,
	},
	{
		type = "checkbox",
		name = WritCreater.optionStrings["provisioning"],
		tooltip = WritCreater.optionStrings["provisioning tooltip"]  ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_PROVISIONING] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_PROVISIONING] = value 
		end,
	},
	{
		type = "checkbox",
		name = WritCreater.optionStrings["alchemy"],
		tooltip = WritCreater.optionStrings["alchemy tooltip"]  ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_ALCHEMY] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_ALCHEMY] = value 
		end,
	},}

  table.insert(options, {
	type = "checkbox",
	name = WritCreater.optionStrings["writ grabbing"] ,
	tooltip = WritCreater.optionStrings["writ grabbing tooltip"] ,
	getFunc = function() return WritCreater:GetSettings().shouldGrab end,
	setFunc = function(value) WritCreater:GetSettings().shouldGrab = value end,
  })
  --[[table.insert(options,{
	type = "slider",
	name = WritCreater.optionStrings["delay"],
	tooltip = WritCreater.optionStrings["delay tooltip"]    ,
	min = 10,
	max = 2000,
	getFunc = function() return WritCreater:GetSettings().delay end,
	setFunc = function(value)
	WritCreater:GetSettings().delay = value
	end,
	disabled = function() return not WritCreater:GetSettings().shouldGrab end,
  })]]

	if false --[[GetWorldName() == "NA Megaserver" and WritCreater.lang =="en" ]] then
	  table.insert(options,8, {
	  type = "checkbox",
	  name = WritCreater.optionStrings["send data"],
	  tooltip =WritCreater.optionStrings["send data tooltip"] ,
	  getFunc = function() return WritCreater.savedVarsAccountWide.sendData end,
	  setFunc = function(value) WritCreater.savedVarsAccountWide.sendData = value  end,
	}) 
	end
	table.insert(options,{
	  type = "submenu",
	  name = WritCreater.optionStrings["timesavers submenu"],
	  tooltip = WritCreater.optionStrings["timesavers submenu tooltip"],
	  controls = timesaverOptions,
	  reference = "WritCreaterTimesaverSubmenu",
	})
	table.insert(options,{
		type = "submenu",
		name = WritCreater.optionStrings["writRewards submenu"],
		tooltip = WritCreater.optionStrings["writRewards submenu tooltip"],
		controls = rewardsSubmenu,
		reference = "WritCreaterRewardsSubmenu",
	})
	table.insert(options,{
	  type = "submenu",
	  name = WritCreater.optionStrings["crafting submenu"],
	  tooltip = WritCreater.optionStrings["crafting submenu tooltip"],
	  controls = craftSubmenu,
	  reference = "WritCreaterMasterWritSubMenu",
	})
	table.insert(options,{
	  type = "submenu",
	  name =WritCreater.optionStrings["style stone menu"],
	  tooltip = WritCreater.optionStrings["style stone menu tooltip"]  ,
	  controls = styleCompiler(),
	  reference = "WritCreaterStyleSubmenu",
	})

	
	if WritCreater.alternateUniverse then
		table.insert(options,1, {
				type = "checkbox",
				name = WritCreater.optionStrings["alternate universe"],
				tooltip =WritCreater.optionStrings["alternate universe tooltip"] ,
				getFunc = function() return WritCreater.savedVarsAccountWide.alternateUniverse end,
				setFunc = function(value) 
					WritCreater.savedVarsAccountWide.alternateUniverse = value 
					WritCreater.savedVarsAccountWide.completeImmunity = not value 
				end,
				requiresReload = true,
				
			})
	end
	if true then
		local jubileeOption = {
			type = "checkbox",
			name = WritCreater.optionStrings["jubilee"]  ,
			tooltip = WritCreater.optionStrings["jubilee tooltip"] ,
			getFunc = function() return WritCreater:GetSettings().lootJubileeBoxes end,
			setFunc = function(value) 
				WritCreater:GetSettings().lootJubileeBoxes = value 
			end,
		}
		table.insert(options, 4, jubileeOption)
		-- table.insert(timesaverOptions, 8, jubileeOption)
	end

	return options
end
