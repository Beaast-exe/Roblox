--#region SCRIPT SETUP
local StartTick = tick()
repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local request = http_request or request or HttpPost or syn.request or http.request

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
------
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Grass Cutting Incremental', Center = true, AutoShow = true })
local Tabs = {
	['Main'] = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

local saveFolderName = 'BeaastHub'
local gameFolderName = 'GrassCuttingIncremental'
local saveFileName = LocalPlayer.Name .. '.json'
local saveFile = saveFolderName .. '/' .. gameFolderName .. '/' .. saveFileName

local defaultSettings = {
	['AutoCollect'] = {
		['Grass'] = false,
		['AntiGrass'] = false
	},
	['Keybinds'] = {
		['menuKeybind'] = 'LeftShift'
	},
	['Watermark'] = false
}

if not isfolder(saveFolderName) then makefolder(saveFolderName) end
if not isfolder(saveFolderName .. '/' .. gameFolderName) then makefolder(saveFolderName .. '/' .. gameFolderName) end
if not isfile(saveFile) then writefile(saveFile, HttpService:JSONEncode(defaultSettings)) end

local settings = HttpService:JSONDecode(readfile(saveFile))
local function SaveConfig()
	writefile(saveFile, HttpService:JSONEncode(settings))
end
--#endregion

 --#region WORKING AREA

--#endregion
local Misc = Tabs['Main']:AddRightGroupbox('Misc')

Misc:AddToggle('watermark', {
	Text = 'Toggle Watermark',
	Default = settings['watermark'],
	Tooltip = 'Toggle Watermark Visibility',

	Callback = function(value)
		settings['watermark'] = value
		Library:SetWatermarkVisibility(value)
		SaveConfig()
	end
})

--#region END OF SCRIPT
Library:OnUnload(function()
	print('Unloaded!')
	Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
	Default = settings['Keybinds']['menuKeybind'],
	NoUI = true,
	Text = 'Menu keybind',

	ChangedCallback = function(value)
		settings['Keybinds']['menuKeybind'] = Options.MenuKeybind.Value
		SaveConfig()
	end
})

Library.ToggleKeybind = Options.MenuKeybind

-- Addons:
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('BeaastHub')
local settingsRightBox = Tabs["UI Settings"]:AddRightGroupbox("Themes")
ThemeManager:ApplyToGroupbox(settingsRightBox)

local function GetLocalTime()
	local Time = os.date("*t")
	local Hour = Time.hour;
	local Minute = Time.min;
	local Second = Time.sec;

	local AmPm = nil;
	if Hour >= 12 then
		Hour = Hour - 12;
		AmPm = "PM";
	else
		Hour = Hour == 0 and 12 or Hour;
		AmPm = "AM";
	end

	return string.format("%s:%02d:%02d %s", Hour, Minute, Second, AmPm);
end

local DayMap = {"st", "nd", "rd", "th"}
local function FormatDay(Day)
	local LastDigit = Day % 10
	if LastDigit >= 1 and LastDigit <= 3 then
		return string.format("%s%s", Day, DayMap[LastDigit])
	end

	return string.format("%s%s", Day, DayMap[4])
end

local MonthMap = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
local function GetLocalDate()
	local Time = os.date("*t")
	local Day = Time.day

	local Month = nil;
	if Time.month >= 1 and Time.month <= 12 then
		Month = MonthMap[Time.month]
	end

	return string.format("%s %s", Month, FormatDay(Day))
end

local function GetLocalDateTime()
	return GetLocalDate() .. " " .. GetLocalTime()
end

task.spawn(function()
	while task.wait(0.1) and not Library.Unloaded do
		local Ping = string.split(string.split(game.Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1], ".")[1];
		local Fps = string.split(game.Stats.Workspace.Heartbeat:GetValueString(), ".")[1];
		local AccountName = LocalPlayer.Name;

		if settings['watermark'] then
			Library:SetWatermark(string.format("%s | %s | %s FPS | %s Ping", GetLocalDateTime(), AccountName, Fps, Ping))
		end
	end
end)
--#endregion