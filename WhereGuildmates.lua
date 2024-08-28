addonName = "WhereGuildmates";

local soundBasePath = "Interface\\AddOns\\WhereGuildmates\\sounds\\";
local soundFileExt = ".ogg";

local frame = CreateFrame("Frame");
frame:RegisterEvent("CHAT_MSG_SYSTEM");

local onlineSysMsg = ERR_FRIEND_ONLINE_SS:gsub("%%s", "(.-)"):gsub("[%[%]]", "%%%1");
local offlineSysMsg = ERR_FRIEND_OFFLINE_S:gsub("%%s", "(.-)");

--- Remove special characters from string.
-- The function replaces special characters with non-special equivalents.
-- @param name The original player name.
-- @return A transformed player name.
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

--- Get player from a blizzard sys message.
-- The function will extract a player/character name and his online status from a blizzard sys message.
-- @param msg The blizzard sys message.
-- @return Targeted player/character name and his online status.
local function GetPlayerFromMsg(msg)
	local name = nil;
	local isOnline = nil;
	if(msg:find(onlineSysMsg)) then
		isOnline = true;
		_, name = strmatch(msg, onlineSysMsg);
	elseif(msg:find(offlineSysMsg)) then
		isOnline = false;
		name = strmatch(msg, offlineSysMsg);
	end
    -- print("GetPlayerFromMsg: Msg:", msg, "Name:", name, "Online:", isOnline)
	return name, isOnline;
end

--- Get player from a guild.
-- The function will get a guildmate/character name from the actual player guild.
-- @param index An integer index value.
-- @return Guildmate/character name.
local function GetPlayerNameFromGuild(index)
	local name = GetGuildRosterInfo(index):match("(.*-)"):gsub('-', '');
    -- print("GetPlayerNameFromGuild: Index:", index, "Name:", name)
	return name;
end

--- Apply some rules and get sound.
-- The function will apply rules and get the correct sound path.
-- @param playerName The player/character name.
-- @param isNowOnline The player/character online status.
-- @return Path to a sound.
local function ApplySoundRule(playerName, isNowOnline)
    local sound = nil;
    local transformedName = TransformName(playerName)
    -- print("ApplySoundRule: PlayerName:", playerName, "TransformedName:", transformedName, "IsNowOnline:", isNowOnline)
	-- print("Original Name: ", playerName, " | Transformed Name: ", transformedName)
    if isNowOnline then
        local customSoundPathLogin = soundBasePath .. "custom\\login_" .. transformedName .. soundFileExt;
        -- print("ApplySoundRule: Checking sound:", customSoundPathLogin)
        if not PlaySoundFile(customSoundPathLogin, "Master") then
            -- print("ApplySoundRule: Custom login sound not found, using default login sound")
            sound = soundBasePath .. "login" .. soundFileExt;
        else
            sound = customSoundPathLogin;
        end
    else
        local customSoundPathLogout = soundBasePath .. "custom\\logout_" .. transformedName .. soundFileExt;
        -- print("ApplySoundRule: Checking sound:", customSoundPathLogout)
        if not PlaySoundFile(customSoundPathLogout, "Master") then
            -- print("ApplySoundRule: Custom logout sound not found, using default logout sound")
            sound = soundBasePath .. "logout" .. soundFileExt;
        else
            sound = customSoundPathLogout;
        end
    end
    if sound then
        -- print("ApplySoundRule: Playing sound:", sound)
        PlaySoundFile(sound, "Master");
    end
    return sound;
end

--- Main event handler function.
-- If event have been caught, this function runs.
-- @param self Self.
-- @param event Event.
-- @param msg Message.
local function EventHandler(self, event, msg)
	local msgPlayerName, isNowOnline = GetPlayerFromMsg(msg);
	if((msgPlayerName == nil) or (msgPlayerName == '') or (isNowOnline == nil)) then
        -- print("EventHandler: Invalid message or status, doing nothing")
	else
		for i=1,GetNumGuildMembers(true) do
			if(msgPlayerName == GetPlayerNameFromGuild(i)) then
                -- print("EventHandler: Match found for:", msgPlayerName)
				local sound = ApplySoundRule(msgPlayerName, isNowOnline);
				PlaySoundFile(sound, "Master");
				break
			end
		end
	end
end

frame:SetScript("OnEvent", EventHandler);
