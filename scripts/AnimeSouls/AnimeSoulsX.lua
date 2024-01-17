local AnimeSoulsXPlaceId = 15367026228
if game.placeId ~= AnimeSoulsXPlaceId then return end
repeat task.wait() until game:IsLoaded()
local StartTick = tick()

local HttpService = game:GetService('HttpService')
local request = http_request or request or HttpPost or syn.request or http.request
------
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Anime Souls X', Center = true, AutoShow = true })
local Tabs = {
	['Main'] = Window:AddTab('Main'),
	['Dungeon'] = Window:AddTab('Dungeon'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

local saveFolderName = 'BeaastHub'
local gameFolderName = 'AnimeSoulsX'
local saveFileName = game:GetService('Players').LocalPlayer.Name .. '.json'
local saveFile = saveFolderName .. '/' .. gameFolderName .. '/' .. saveFileName

local defaultSettings = {
	['AutoFarm'] = {
		['Enabled'] = false,
		['AttackAll'] = false,
		['IgnoreChests'] = false,
		['AutoClick'] = false,
		['AutoCollect'] = false,
		['AutoUltSkip'] = false,
		['BoostPetSpeed'] = false
	},
	['AutoDefense'] = {
		['Enabled'] = false
	},
	['Keybinds'] = {
		['menuKeybind'] = 'LeftShift',
		['AutoFarm'] = 'Unknown'
	},
	watermark = false,
	webhookLink = 'Webhook Link',
	webhookMentionId = 'Mention ID'
}

if not isfolder(saveFolderName) then makefolder(saveFolderName) end
if not isfolder(saveFolderName .. '/' .. gameFolderName) then makefolder(saveFolderName .. '/' .. gameFolderName) end
if not isfile(saveFile) then writefile(saveFile, HttpService:JSONEncode(defaultSettings)) end

local settings = HttpService:JSONDecode(readfile(saveFile))
local function SaveConfig()
	writefile(saveFile, HttpService:JSONEncode(settings))
end

-- // VARIABLES
local HttpService = game:GetService('HttpService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Workspace = game:GetService('Workspace')
local Players = game:GetService('Players')
local VirtualUser = game:GetService('VirtualUser')
local VirtualInputManager = game:GetService('VirtualInputManager')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local player = Players.LocalPlayer
local originalCameraZoomDistance = player.CameraMaxZoomDistance
local character = player.Character
local starterPlayerScriptsFolder = player.PlayerScripts.StarterPlayerScriptsFolder

local PlayerGui = player.PlayerGui
---

local defenseGui = PlayerGui["_CENTER"]['Defense']
---

local isPlayerInDefense = false

-- // STORAGE
local Enemies = {}
function GenEnemyStats()
	for i, v in pairs(Workspace['_ENEMIES'][player:GetAttribute("CurrentArea")]:GetChildren()) do
		if table.find(Enemies, v.Name) then
			
		else
			table.insert(Enemies, v.Name)
		end
	end
end

local GetClosestEnemies = (newcclosure(function()
	local distance = 9e9
	local enemy

	for i, v in pairs(Workspace['_ENEMIES'][player:GetAttribute("CurrentArea")]:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
			local mag = (character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude

			if mag < distance then
				distance = mag
				enemy = v
			end
		end
	end
end))

function findNearestEnemy()
	local playerWorld = player.World.Value
	local Closest = nil
	local ClosestDistance = math.huge

	if Workspace.Worlds[playerWorld]:FindFirstChild('Enemies') then
		local enemyModels = Workspace['_ENEMIES'][player:GetAttribute("CurrentArea")]:GetChildren(); -- Workspace.Worlds[playerWorld].Enemies:GetChildren()

		for _, targetEnemy in ipairs(enemyModels) do
			if targetEnemy:IsA("Model") and targetEnemy:FindFirstChild("HumanoidRootPart") then
				local Distance = (character.HumanoidRootPart.Position - targetEnemy.HumanoidRootPart.Position).magnitude

				if Distance <= 1000 and Distance < ClosestDistance then
					Closest = targetEnemy
					ClosestDistance = Distance
				end
			end
		end

		if Closest == nil then ClosestDistance = math.huge end

		return Closest, ClosestDistance
	end
end

function Initialize()
	GenEnemyStats()
	task.wait(0.5)
	Library:Notify(string.format('Script Loaded in %.2f second(s)!', tick() - StartTick), 5)
end

local AutoDefense = Tabs['Main']:AddRightGroupbox('Auto Defense')
AutoDefense:AddToggle('enableAutoDefense', {
	Text = 'Auto Defense',
	Default = settings['AutoDefense']['Enabled'],
	Tooltip = 'Enable Auto Defense',

	Callback = function(value)
		settings['AutoDefense']['Enabled'] = value
		SaveConfig()
	end
})

Initialize()

-- // AUTO DEFENSE
task.spawn(function()
	while task.wait() and not Library.Unloaded do
		local enemies = Workspace['_ENEMIES']['Defense']
		
		if #enemies > 0 then
			for _, enemy in ipairs(enemies:GetChildren()) do
				pcall(function()
					character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame

					repeat
						character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame
					until Library.Unloaded
					or enemy:FindFirstChild("HumanoidRootPart") == nil
					or enemy:FindFirstChild("_STATS") == nil
					or not settings['AutoDefense']['Enabled']
				end)
			end
		end
	end
end)

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
		local AccountName = player.Name;

		if settings['watermark'] then
			Library:SetWatermark(string.format("%s | %s | %s FPS | %s Ping", GetLocalDateTime(), AccountName, Fps, Ping))
		end
	end
end)