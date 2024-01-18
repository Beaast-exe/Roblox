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
		['Enabled'] = false
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
--local starterPlayerScriptsFolder = player.PlayerScripts.StarterPlayerScriptsFolder

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

local getClosestEnemy = (newcclosure(function()
	local distance = 9e9
	local enemy

	for i, v in pairs(Workspace['_ENEMIES']['4']:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
			local mag = (game.Players.LocalPlayer.character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude

			if mag < distance then
				distance = mag
				enemy = v
			end
		end
	end

	return enemy
end))

function getEnemy(world)
	local distance = 9e9
	local enemy = nil

	for i, v in pairs(Workspace['_ENEMIES'][world]:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
			local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude

			if mag <= distance then
				distance = mag
				enemy = v
			end
		end
	end

	if enemy == nil then distance = 9e9 end
	return enemy
end

local lastClosest = nil

function Initialize()
	GenEnemyStats()
	task.wait(0.5)
	Library:Notify(string.format('Script Loaded in %.2f second(s)!', tick() - StartTick), 5)
end

local AutoFarm = Tabs['Main']:AddLeftGroupbox('Auto Farm')
AutoFarm:AddToggle('enableAutoFarm', {
	Text = 'Auto Farm',
	Default = settings['AutoFarm']['Enabled'],
	Tooltip = 'Enable Auto Farm',

	Callback = function(value)
		settings['AutoFarm']['Enabled'] = value
		SaveConfig()
	end
})

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

player:GetAttributeChangedSignal("CurrentArea"):Connect(function()
	table.clear(Enemies)
	
	task.wait(0.1)
	for i, v in pairs(Workspace['_ENEMIES'][player:GetAttribute("CurrentArea")]:GetChildren()) do
		if table.find(Enemies, v.Name) then
			
		else
			table.insert(Enemies, v.Name)
		end
	end
end)

-- // AUTO FARM
task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoFarm']['Enabled'] then
			local enemy = getClosestEnemy()

			if enemy:FindFirstChild('HumanoidRootPart') then
				character.HumanoidRootPart.CFrame = getClosestEnemy().HumanoidRootPart.CFrame

				local args = {[1] = {[1] = {[1] = "\3",[2] = "Click",[3] = "Execute",[4] = getClosestEnemy()}}}
				game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(args))

				task.wait(0.3)
			end
		end
	end
end)

-- // AUTO DEFENSE
task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if not settings['AutoDefense']['Enabled'] then return end
		local enemy = getEnemy('Defense')
		
		if enemy == nil then return end
		if enemy:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame

			local args = {
				[1] = {
					[1] = {
						[1] = "\3",
						[2] = "Click",
						[3] = "Execute",
						[4] = enemy
					}
				}
			}

			game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
			task.wait(0.3)
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