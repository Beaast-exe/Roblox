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
		['Enabled'] = false,
		['World'] = "Cursed Zone"
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

local player = Players.LocalPlayer
local character = player.Character
local PlayerGui = player.PlayerGui

local manaCrystal = Vector3.new(230.972, 1080.2, 4611.74)
local worldsNames = {
	"Cursed Zone",
	"Bizarre Area",
	"Ninja Village",
	"Hunter Zone",
	"Spirit Society",
	"Dragon City",
	"Ghoul Town",
	"Marine Station",
	"Leveling City",
	"Titan District"
}
local worldsTable = {
	["Cursed Zone"] = "1",
	["Bizarre Area"] = "2",
	["Ninja Village"] = "3",
	["Hunter Zone"] = "4",
	["Spirit Society"] = "5",
	["Dragon City"] = "6",
	["Ghoul Town"] = "7",
	["Marine Station"] = "8",
	["Leveling City"] = "9",
	["Titan District"] = "10"
}

local createdDefense = false
local minute = os.date("%M")
local playerMode

function Initialize()
	Library:Notify(string.format('Script Loaded in %.2f second(s)!', tick() - StartTick), 5)
	print("Loaded Beaast Hub")
end

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		playerMode = player:GetAttribute("Mode")
		player.GameplayPaused = false
	end
end)

task.spawn(function()
	while not Library.Unloaded do
		minute = os.date("%M")
		task.wait(0.1)
	end
end)

-- // FUNCTIONS
local getClosestEnemyDungeon = (newcclosure(function(dungeon)
	local distance = 1000
	local enemy

	for i, v in pairs(Workspace._ENEMIES['Dungeon'][dungeon]:GetDescendants()) do
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

local getEnemies = (newcclosure(function(world)
	local distance = 1000
	local enemy

	for i, v in pairs(Workspace['_ENEMIES'][world]:GetChildren()) do
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

local AutoFarm = Tabs['Main']:AddLeftGroupbox('Auto Farm')
AutoFarm:AddDropdown('autoFarmWorld', {
	Text = 'Auto Farm World',
	Tooltip = 'Select world to auto farm',
	Default = settings['AutoFarm']['World'],
	Multi = false,
	Values = worldsNames,

	Callback = function(value)
		settings['AutoFarm']['World'] = worldsTable[value]
		print(settings['AutoFarm']['World'])
	end
})

AutoFarm:AddToggle('enableAutoFarm', {
	Text = 'Enable Auto Farm',
	Default = settings['AutoFarm']['Enabled'],
	Tooltip = 'Enable Auto Farm',

	Callback = function(value)
		settings['AutoFarm']['Enabled'] = value
		SaveConfig()
	end
})

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoFarm']['Enabled'] then
			local enemy = getEnemies(settings['AutoFarm']['World'])
				if enemy == nil then return end
				-- 	repeat
				-- 		enemy = getEnemies(settings['AutoFarm']['World'])
				-- 	until enemy ~= nil
				-- 	or getEnemies(settings['AutoFarm']['World']) ~= nil
				-- end
			-- 	local args = {
			-- 		[1] = {
			-- 			[1] = {
			-- 				[1] = "\3",
			-- 				[2] = "Teleport",
			-- 				[3] = "To",
			-- 				[4] = tonumber(settings['AutoFarm']['World'])
			-- 			}
    		-- 		}
			-- 	}

			-- 	ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			-- 	task.wait(5)
			-- else
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
			-- end
		end
	end
end)

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

function AbrirEntrarDefense()
	if not createdDefense then
		--if playerMode ~= "Defense" and playerMode ~= "Dungeon" then
		local argsOpen = {
			[1] = { [1] = { [1] = "\3", [2] = "Defense", [3] = "Open", [4] = true } } }
	
		local argsJoin = { [1] = { [1] = { [1] = "\3", [2] = "Defense", [3] = "Join" } } }

		ReplicatedStorage.RemoteEvent:FireServer(unpack(argsOpen))
		task.wait(3)
		ReplicatedStorage.RemoteEvent:FireServer(unpack(argsJoin))
		task.wait(3)

		createdDefense = true
		task.wait(60)
		createdDefense = false
		--end
	end
end

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoDefense']['Enabled'] then
			--if playerMode == "Defense" or playerMode == "Dungeon" then return end
			AbrirEntrarDefense()
		end
	end
end)

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoDefense']['Enabled'] then
			--if playerMode == "Dungeon" then return end
			local enemy = getClosestEnemyDefense()

			if #Workspace['_ENEMIES']['Defense']:GetChildren() <= 0 then
				--if playerMode ~= "Defense" then
					local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
					local cf = CFrame.new(manaCrystal)
					local a = TweenService:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
					a:Play()
					character.HumanoidRootPart.CFrame = CFrame.new(manaCrystal)
				--end
			end

			if enemy and enemy:FindFirstChild("HumanoidRootPart") then
				if character and character:FindFirstChild("HumanoidRootPart") then

					local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
					local cf = enemy.HumanoidRootPart.CFrame
					local a = TweenService:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
					a:Play()

					-- character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame

					local args = { [1] = { [1] = { [1] = "\3", [2] = "Click", [3] = "Execute", [4] = enemy } } }

					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end
		end
		--task.wait()
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

-- // TP TO DUNGEON
task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoDungeon']['Enabled'] then
			if minute == '00' or minute == '0' or minute == '30' then
				if playerMode == "Dungeon" then return end
				local argsJoin = { [1] = { [1] = { [1] = "\3", [2] = "Dungeon", [3] = "Join", [4] = 'Easy' }}}
				ReplicatedStorage.RemoteEvent:FireServer(unpack(argsJoin))
			else
				repeat
					task.wait()
					minute = os.date("%M")
				until minute == '00' or minute == '0' or minute == '30' or Library.Unloaded or not settings['AutoDungeon']['Enabled']
			end
		end
	end
end)

-- // AUTO DUNGEON
task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoDungeon']['Enabled'] then
			if minute == '00' or minute == '0' or minute == '30' or Library.Unloaded or not settings['AutoDungeon']['Enabled'] then
				repeat
					task.wait()
					minute = os.date("%M")
				until minute == '01' or minute == '1' or minute == '31'
			else
				local enemy = getClosestEnemyDungeon('Easy')

				if enemy and enemy:FindFirstChild("HumanoidRootPart") then
					if character and character:FindFirstChild("HumanoidRootPart") then

						local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
						local cf = enemy.HumanoidRootPart.CFrame
						local a = TweenService:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
						a:Play()

						-- character.HumanoidRootPart.CFrame = enemy.CFrame

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

local OtherScripts = Tabs['UI Settings']:AddLeftGroupbox('Other Scripts')
OtherScripts:AddButton('Banana Hub', function()
	task.spawn(loadstring(game:HttpGet('https://raw.githubusercontent.com/diepedyt/bui/main/temporynewkeysystem.lua', true)))
end)

Library.ToggleKeybind = Options.MenuKeybind

-- Addons:
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('BeaastHub')
local settingsRightBox = Tabs["UI Settings"]:AddRightGroupbox("Themes")
ThemeManager:ApplyToGroupbox(settingsRightBox)

game:GetService('Players').LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

Initialize()