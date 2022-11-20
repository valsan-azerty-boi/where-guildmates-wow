addonName = "WhereGuildmates";

local frame = CreateFrame("Frame");
frame:RegisterEvent("CHAT_MSG_SYSTEM");

local online_msg = ERR_FRIEND_ONLINE_SS:gsub("%%s", "(.-)"):gsub("[%[%]]", "%%%1");
local offline_msg = ERR_FRIEND_OFFLINE_S:gsub("%%s", "(.-)");

local function GetPlayerNameFromMsg(msg)
	local name = nil;

	if(msg:find(online_msg)) then
		_, name = strmatch(msg, online_msg);
	elseif(msg:find(offline_msg)) then
		name = strmatch(msg, offline_msg);
	end

	return name;
end

local function GetPlayerNameFromGuild(index)
	local name = GetGuildRosterInfo(index):match("(.*-)"):gsub('-', '');
	return name;
end

local function LoginCustomRule(playerName)
	local sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\login.ogg";

	if(playerName == "Gorkah") then
		sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\ee\\login_gorkah.ogg";
	elseif(playerName == "Krÿg") then
		sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\ee\\login_kryg.ogg";
	elseif(playerName == "Borsâ") then
		sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\ee\\login_borsa.ogg";
	elseif(playerName == "Ewïlan") then
		sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\ee\\login_ewilan.ogg";
	elseif(playerName == "Klamidiaa") then
		sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\ee\\login_klam.ogg";
	else
		num = math.random() and math.random() and math.random() and math.random(0, 20)
		if(num == 10) then
			sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\ee\\wololo.ogg";
		end
	end

	return sound;
end

local function LogoutCustomRule(playerName)
	local sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\logout.ogg";

	if(playerName == "Gorkah") then
		sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\logout.ogg";
	else
		num = math.random() and math.random() and math.random() and math.random(0, 20)
		if(num == 10) then
			sound = "Interface\\AddOns\\WhereGuildmates\\sounds\\ee\\wololo.ogg";
		end
	end

	return sound;
end

local function EventHandler(self, event, msg)
	local msgPlayerName = GetPlayerNameFromMsg(msg);

	if(msgPlayerName == nil or msgPlayerName == '') then
		-- do nothing
	else
		for i=1,GetNumGuildMembers(true) do
			local guildPlayerName = GetPlayerNameFromGuild(i);
			if((guildPlayerName == msgPlayerName)) then
				if(msg:find(online_msg)) then
					PlaySoundFile(LoginCustomRule(msgPlayerName), "Master");
				elseif(msg:find(offline_msg)) then
					PlaySoundFile(LogoutCustomRule(msgPlayerName), "Master");
				end
				break
			end
		end
	end
end

frame:SetScript("OnEvent", EventHandler);
