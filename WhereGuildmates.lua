addonName = "WhereGuildmates"

local L = {}

local function LoadLocale()
    local locale = GetLocale()
    if locale == "frFR" then
        L["PRESENTATION_TEXT"] = "Cet addon joue un son amusant de péon lorsqu'un membre de ta guilde se connecte ou se déconnecte. Tu peux également ajouter des sons pour chaque membre de ta guilde dans le dossier \"custom\" de cet addon (format ogg/vorbis)."
        L["DROPDOWN_EXPLANATION"] = "Change le canal audio pour les notifications:"
        L["SOUND_CHANNEL"] = "Canal audio"
    else
        L["PRESENTATION_TEXT"] = "Play a fun peon sound when a guildmate login or logout. You can also add your own custom sounds for each guild member in the \"custom\" folder of this addon (ogg/vorbis)."
        L["DROPDOWN_EXPLANATION"] = "Select the audio channel for notifications:"
        L["SOUND_CHANNEL"] = "Sound channel"
    end
end

LoadLocale()

local soundBasePath = "Interface\\AddOns\\".. addonName .. "\\sounds\\"
local soundFileExt = ".ogg"

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SYSTEM")

local onlineSysMsg = ERR_FRIEND_ONLINE_SS:gsub("%%s", "(.-)"):gsub("[%[%]]", "%%%1")
local offlineSysMsg = ERR_FRIEND_OFFLINE_S:gsub("%%s", "(.-)")

if not WhereGuildmatesDB then
    WhereGuildmatesDB = {}
end

if not WhereGuildmatesDB.audioChannel then
    WhereGuildmatesDB.audioChannel = "Master"
end

local function TransformName(name)
    local transformedName = name
    transformedName = transformedName:gsub("á", "a")
    transformedName = transformedName:gsub("à", "a")
    transformedName = transformedName:gsub("ä", "a")
    transformedName = transformedName:gsub("â", "a")
    transformedName = transformedName:gsub("å", "a")
    transformedName = transformedName:gsub("ã", "a")
    transformedName = transformedName:gsub("æ", "ae")
    transformedName = transformedName:gsub("ç", "c")
    transformedName = transformedName:gsub("é", "e")
    transformedName = transformedName:gsub("è", "e")
    transformedName = transformedName:gsub("ë", "e")
    transformedName = transformedName:gsub("ê", "e")
    transformedName = transformedName:gsub("í", "i")
    transformedName = transformedName:gsub("ì", "i")
    transformedName = transformedName:gsub("ï", "i")
    transformedName = transformedName:gsub("î", "i")
    transformedName = transformedName:gsub("ñ", "n")
    transformedName = transformedName:gsub("ó", "o")
    transformedName = transformedName:gsub("ò", "o")
    transformedName = transformedName:gsub("ö", "o")
    transformedName = transformedName:gsub("ô", "o")
    transformedName = transformedName:gsub("õ", "o")
    transformedName = transformedName:gsub("ú", "u")
    transformedName = transformedName:gsub("ù", "u")
    transformedName = transformedName:gsub("ü", "u")
    transformedName = transformedName:gsub("û", "u")
    transformedName = transformedName:gsub("ý", "y")
    transformedName = transformedName:gsub("ÿ", "y")
    transformedName = transformedName:gsub("Á", "A")
    transformedName = transformedName:gsub("À", "A")
    transformedName = transformedName:gsub("Ä", "A")
    transformedName = transformedName:gsub("Â", "A")
    transformedName = transformedName:gsub("Å", "A")
    transformedName = transformedName:gsub("Ã", "A")
    transformedName = transformedName:gsub("Æ", "AE")
    transformedName = transformedName:gsub("Ç", "C")
    transformedName = transformedName:gsub("É", "E")
    transformedName = transformedName:gsub("È", "E")
    transformedName = transformedName:gsub("Ë", "E")
    transformedName = transformedName:gsub("Ê", "E")
    transformedName = transformedName:gsub("Í", "I")
    transformedName = transformedName:gsub("Ì", "I")
    transformedName = transformedName:gsub("Ï", "I")
    transformedName = transformedName:gsub("Î", "I")
    transformedName = transformedName:gsub("Ñ", "N")
    transformedName = transformedName:gsub("Ó", "O")
    transformedName = transformedName:gsub("Ò", "O")
    transformedName = transformedName:gsub("Ö", "O")
    transformedName = transformedName:gsub("Ô", "O")
    transformedName = transformedName:gsub("Õ", "O")
    transformedName = transformedName:gsub("Ú", "U")
    transformedName = transformedName:gsub("Ù", "U")
    transformedName = transformedName:gsub("Ü", "U")
    transformedName = transformedName:gsub("Û", "U")
    transformedName = transformedName:gsub("Ý", "Y")
    transformedName = transformedName:gsub("Œ", "Oe")
    transformedName = transformedName:gsub("œ", "oe")
    transformedName = transformedName:gsub("ß", "ss")
    transformedName = transformedName:gsub("ø", "o")
    transformedName = transformedName:gsub("Ø", "O")
    transformedName = transformedName:gsub("-", "")
    transformedName = transformedName:gsub(" ", "")
    -- print("Original name: " .. name)
    -- print("Transformed name: " .. transformedName)
    return transformedName
end

local function GetPlayerFromMsg(msg)
	local name = nil
	local isOnline = nil
	if(msg:find(onlineSysMsg)) then
		isOnline = true
		_, name = strmatch(msg, onlineSysMsg)
	elseif(msg:find(offlineSysMsg)) then
		isOnline = false
		name = strmatch(msg, offlineSysMsg)
	end
    -- print("GetPlayerFromMsg: Msg:", msg, "Name:", name, "Online:", isOnline)
	return name, isOnline
end

local function GetPlayerNameFromGuild(index)
	local name = GetGuildRosterInfo(index):match("(.*-)"):gsub('-', '')
    -- print("GetPlayerNameFromGuild: Index:", index, "Name:", name)
	return name
end

local function ApplySoundRule(playerName, isNowOnline)
    local sound = nil
    local transformedName = TransformName(playerName)
    -- print("ApplySoundRule: PlayerName:", playerName, "TransformedName:", transformedName, "IsNowOnline:", isNowOnline)
	-- print("Original Name: ", playerName, " | Transformed Name: ", transformedName)
    if isNowOnline then
        local customSoundPathLogin = soundBasePath .. "custom\\login_" .. transformedName .. soundFileExt
        -- print("ApplySoundRule: Checking sound:", customSoundPathLogin)
        if not PlaySoundFile(customSoundPathLogin, WhereGuildmatesDB.audioChannel) then
            -- print("ApplySoundRule: Custom login sound not found, using default login sound")
            sound = soundBasePath .. "login" .. soundFileExt
        else
            sound = customSoundPathLogin
        end
    else
        local customSoundPathLogout = soundBasePath .. "custom\\logout_" .. transformedName .. soundFileExt
        -- print("ApplySoundRule: Checking sound:", customSoundPathLogout)
        if not PlaySoundFile(customSoundPathLogout, WhereGuildmatesDB.audioChannel) then
            -- print("ApplySoundRule: Custom logout sound not found, using default logout sound")
            sound = soundBasePath .. "logout" .. soundFileExt
        else
            sound = customSoundPathLogout
        end
    end
    if sound then
        -- print("ApplySoundRule: Playing sound:", sound)
        PlaySoundFile(sound, WhereGuildmatesDB.audioChannel)
    end
    return sound
end

local function EventHandler(self, event, msg)
	local msgPlayerName, isNowOnline = GetPlayerFromMsg(msg)
	if((msgPlayerName == nil) or (msgPlayerName == '') or (isNowOnline == nil)) then
        -- print("EventHandler: Invalid message or status, doing nothing")
	else
		for i=1,GetNumGuildMembers(true) do
			if(msgPlayerName == GetPlayerNameFromGuild(i)) then
                -- print("EventHandler: Match found for:", msgPlayerName)
				local sound = ApplySoundRule(msgPlayerName, isNowOnline)
				PlaySoundFile(sound, WhereGuildmatesDB.audioChannel)
				break
			end
		end
	end
end

frame:SetScript("OnEvent", EventHandler)

local optionsPanelCreated = false

local function CreateOptionsPanel()
    if optionsPanelCreated then return end
    local panel = CreateFrame("Frame", addonName .. "OptionsPanel", UIParent)
    panel:SetSize(400, 300)
    panel:SetPoint("CENTER")
    panel.name = addonName
    panel:Hide()
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addonName)
    local presText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    presText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    presText:SetWidth(360)
    presText:SetJustifyH("LEFT")
    presText:SetText(L["PRESENTATION_TEXT"])
    local dropdownExplanationText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownExplanationText:SetPoint("TOPLEFT", presText, "BOTTOMLEFT", 0, -20)
    dropdownExplanationText:SetText(L["DROPDOWN_EXPLANATION"])
    local dropdown = CreateFrame("Frame", addonName .. "AudioChannelDropdown", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", dropdownExplanationText, "BOTTOMLEFT", 0, -10)
    local function OnClick(self)
        WhereGuildmatesDB.audioChannel = self.value
        UIDropDownMenu_SetText(dropdown, self.value or L["SOUND_CHANNEL"])
    end
    local function InitializeDropdown(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        local channels = {"Master", "Music", "SFX", "Ambience", "Dialog"}
        for _, channel in pairs(channels) do
            info.text = channel
            info.value = channel
            info.checked = channel == WhereGuildmatesDB.audioChannel
            info.func = OnClick
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_SetWidth(dropdown, 100)
    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
    local function UpdateDropdownText()
        UIDropDownMenu_SetText(dropdown, WhereGuildmatesDB.audioChannel or L["SOUND_CHANNEL"])
    end
    panel:SetScript("OnShow", UpdateDropdownText)
    local function ShowOptionsPanel()
        -- print("Slash command triggered: Showing options panel...")
        panel:Show()
    end
    SLASH_WHEREGUILDMATES1 = "/" .. addonName
    SlashCmdList.WHEREGUILDMATES = ShowOptionsPanel
    if Settings and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, addonName)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    -- else
        -- print("Failed to register options panel.")
    end
    optionsPanelCreated = true
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon == addonName then
        CreateOptionsPanel()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

CreateOptionsPanel()
