local AnimeSoulsXPlaceId = 15367026228
if game.placeId ~= AnimeSoulsXPlaceId then return end
repeat task.wait() until game:IsLoaded()
local StartTick = tick()

local HttpService = game:GetService('HttpService')
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Anime Souls X', Center = true, AutoShow = true })
local Tabs = {
	['Main'] = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings')
}

local saveFolderName = 'BeaastHub'
local gameFolderName = 'AnimeSoulsX'
local saveFileName = game:GetService('Players').LocalPlayer.Name .. '.json'
local saveFile = saveFolderName .. '/' .. gameFolderName .. '/' .. saveFileName

local defaultSettings = {
	['AutoFarm'] = {
		['Enabled'] = false
	},
	['AutoDungeon'] = {
		['Enabled'] = false
	},
	['AutoDefense'] = {
		['Enabled'] = false
	},
	['Keybinds'] = {
		['menuKeybind'] = 'LeftShift'
	},
	watermark = false
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
local manaCrystal = Vector3.new(230.972, 1080.2, 4611.74)

local player = Players.LocalPlayer
local character = player.Character
local PlayerGui = player.PlayerGui
local playerHrp = character and character:FindFirstChild("HumanoidRootPart")

-- // FUNCTIONS
local getClosestEnemy = (newcclosure(function(world)
	local distance = 1000
	local enemy

	for i, v in pairs(Workspace._ENEMIES[world]:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
			local mag = (character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude

			if mag < distance then
				distance = mag
				enemy = v
			end
		end
	end

	return enemy
end))

local getClosestEnemyDungeon = (newcclosure(function()
	local distance = 9e9
	local enemy

	for i, v in pairs(Workspace._ENEMIES['Dungeon']['Easy']:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and tonumber(v['_STATS']['CurrentHP'].Value) > 0 then
			local mag = (character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude

			if mag < distance then
				distance = mag
				enemy = v
			end
		end
	end

	return enemy
end))

local getClosestEnemyDefense = (newcclosure(function()
	local distance = 1000
	local enemy

	for i, v in pairs(Workspace._ENEMIES['Defense']:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and tonumber(v['_STATS']['CurrentHP'].Value) > 0 then
			local mag = (manaCrystal - v.HumanoidRootPart.Position).magnitude

			if mag < distance then
				distance = mag
				enemy = v
			end
		end
	end

	return enemy
end))

function Initialize()
	--game.Players.LocalPlayer:SetAttribute("Teleporting", true)
	print("Loaded Beaast Hub")
	task.wait(0.5)

	--for k, v in pairs(player:GetAttributes()) do
	--	print(k, v)
	--end

	Library:Notify(string.format('Script Loaded in %.2f second(s)!', tick() - StartTick), 5)
end

local AutoDefense = Tabs['Main']:AddRightGroupbox('Auto Defense')
AutoDefense:AddToggle('enableAutoDefense', {
	Text = 'Auto Defense',
	Default = settings['AutoDefense']['Enabled'],
	Tooltip = 'Enable Auto Farm',

	Callback = function(value)
		settings['AutoDefense']['Enabled'] = value
		SaveConfig()
	end
})

local createdDefense = false

function AbrirEntrarDefense()
	if not createdDefense then
		local argsOpen = {
			[1] = {
				[1] = {
					[1] = "\3",
					[2] = "Defense",
					[3] = "Open",
					[4] = true
				}
			}
		}
	
		local argsJoin = {
			[1] = {
				[1] = {
					[1] = "\3",
					[2] = "Defense",
					[3] = "Join"
				}
			}
		}
		
		ReplicatedStorage.RemoteEvent:FireServer(unpack(argsOpen))
		task.wait(5)
		ReplicatedStorage.RemoteEvent:FireServer(unpack(argsJoin))

		createdDefense = true
		task.wait(60)
		createdDefense = false
	end
end

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoDefense']['Enabled'] then
			AbrirEntrarDefense()
		end
	end
end)

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoDefense']['Enabled'] then
			local enemy = getClosestEnemyDefense()

			if #Workspace._ENEMIES.Defense:GetChildren() <= 0 then
				local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
				local cf = CFrame.new(manaCrystal)
				local a = TweenService:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
				a:Play()
				character.HumanoidRootPart.CFrame = CFrame.new(manaCrystal)
			end

			if enemy and enemy:FindFirstChild("HumanoidRootPart") then
				if character and character:FindFirstChild("HumanoidRootPart") then

					local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
					local cf = enemy.HumanoidRootPart.CFrame
					local a = TweenService:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
					a:Play()

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

					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end
		end
		--task.wait(1)
	end
end)

local AutoDungeon = Tabs['Main']:AddLeftGroupbox('Auto Dungeon')
AutoDungeon:AddToggle('enableAutoDungeon', {
	Text = 'Auto Dungeon',
	Default = settings['AutoDungeon']['Enabled'],
	Tooltip = 'Enable Auto Farm',

	Callback = function(value)
		settings['AutoDungeon']['Enabled'] = value
		SaveConfig()
	end
})

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoDungeon']['Enabled'] then
			local argsJoin = {
				[1] = {
					[1] = {
						[1] = "\3",
						[2] = "Dungeon",
						[3] = "Join",
						[4] = "Easy"
					}
				}
			}
			
			ReplicatedStorage.RemoteEvent:FireServer(unpack(argsJoin))
			local enemy = getClosestEnemyDungeon()

			if enemy and enemy:FindFirstChild("HumanoidRootPart") then
				if character and character:FindFirstChild("HumanoidRootPart") then

					local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
					local cf = enemy.HumanoidRootPart.CFrame
					local a = TweenService:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
					a:Play()

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

					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end
		end
		--task.wait(1)
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

Initialize()

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