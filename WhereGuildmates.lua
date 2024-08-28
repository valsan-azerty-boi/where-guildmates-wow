addonName = "WhereGuildmates";

local soundBasePath = "Interface\\AddOns\\WhereGuildmates\\sounds\\";
local soundFileExt = ".ogg";

local frame = CreateFrame("Frame");
frame:RegisterEvent("CHAT_MSG_SYSTEM");

local onlineSysMsg = ERR_FRIEND_ONLINE_SS:gsub("%%s", "(.-)"):gsub("[%[%]]", "%%%1");
local offlineSysMsg = ERR_FRIEND_OFFLINE_S:gsub("%%s", "(.-)");

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
	return name, isOnline;
end

--- Get player from a guild.
-- The function will get a guildmate/character name from the actual player guild.
-- @param index An integer index value.
-- @return Guildmate/character name.
local function GetPlayerNameFromGuild(index)
	local name = GetGuildRosterInfo(index):match("(.*-)"):gsub('-', '');
	return name;
end

--- Apply some rules and get sound.
-- The function will apply rules and get the correct sound path.
-- @param playerName The player/character name.
-- @param isNowOnline The player/character online status.
-- @return Path to a sound.
local function ApplySoundRule(playerName, isNowOnline)
    local sound = nil;
    if isNowOnline then
        local customSoundPathLogin = soundBasePath .. "custom\\login_" .. playerName .. soundFileExt;
        if not PlaySoundFile(customSoundPathLogin, "Master") then
            sound = soundBasePath .. "login" .. soundFileExt;
        else
            sound = customSoundPathLogin;
        end
    else
        local customSoundPathLogout = soundBasePath .. "custom\\logout_" .. playerName .. soundFileExt;
        if not PlaySoundFile(customSoundPathLogout, "Master") then
            sound = soundBasePath .. "logout" .. soundFileExt;
        else
            sound = customSoundPathLogout;
        end
    end
    if sound then
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
		-- Do nothing
	else
		for i=1,GetNumGuildMembers(true) do
			if(msgPlayerName == GetPlayerNameFromGuild(i)) then
				local sound = ApplySoundRule(msgPlayerName, isNowOnline);
				PlaySoundFile(sound, "Master");
				break
			end
		end
	end
end

frame:SetScript("OnEvent", EventHandler);
