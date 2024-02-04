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
		['Titans'] = false,
		['World'] = "Cursed Zone"
	},
	['Exchange'] = {
		['Enabled'] = false,
		['Sacrifice'] = "OP Key",
		['Return'] = "OP Key",
		['OPCrate'] = false
	},
	['AutoDungeon'] = {
		['Enabled'] = false
	},
	['AutoDefense'] = {
		['Enabled'] = false
	},
	['Rolls'] = {
		['Titan'] = {
			['Enabled'] = false,
			['Selected'] = {"Beast Titan", "Colossal Titan"},
			['Slot'] = "1"
		},
		['Bloodline'] = {
			['Enabled'] = false,
			['Selected'] = {"Yeager", "Ackerman"}
		}
	},
	['Utils'] = {
		['PlayerPassive'] = false,
		['Element'] = false,
		['Race'] = false,
		['Kagune'] = false,
		['Class'] = false,
		['DailyRewards'] = false,
		['WheelSpin'] = false,
		['AutoMount'] = false,
		['AutoCrew'] = false,
		['Ascend'] = false,
		['Aura'] = false
	},
	['Potions'] = {
		["Damage"] = false,
		["Drop"] = false,
		["Energy"] = false,
		["Luck"] = false,
		["Souls"] = false
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
	"Titan District",
	"XYZ Province"
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
	["Titan District"] = "10",
	["XYZ Province"] = "11"
}

local Items = {
	["Elemental Token"] = "ElementalTokens",
	["Gold Bar"] = "GoldBars",
	["Amulet Shards"] = "AmuletShards",
	["Avatar Spin"] = "AvatarSpins",
	["Class Spin"] = "ClassSpins",
	["Shiny Shard"] = "ShinyShards",
	["Spinal Fluid"] = "SpinalFluids",
	["Spiritual Token"] = "SpiritualTokens",
	["Passive Token"] = "PassiveTokens",
	["Blood"] = "Bloods",
	["Enchantment Token"] = "EnchantmentTokens",
	["Star Balls"] = "StarBalls",
	["OP Key"] = "OPKeys"
}

local Titans = {
	["Smiling Titan"] = "SmilingTitan",
	["Attack Titan"] = "AttackTitan",
	["Female Titan"] = "FemaleTitan",
	["Armored Titan"] = "ArmoredTitan",
	["Warhammer Titan"] = "WarhammerTitan",
	["Beast Titan"] = "BeastTitan",
	["Colossal Titan"] = "ColossalTitan"
}

local Bloodlines = {
	["Blouse"] = "Blouse",
	["Smith"] = "Smith",
	["Zeke"] = "Zeke",
	["Tybur"] = "Tybur",
	["Yeager"] = "Yeager",
	["Ackerman"] = "Ackerman"
}

local ItemsNames = {"OP Key", "Elemental Token", "Gold Bar", "Amulet Shards", "Avatar Spin", "Class Spin", "Shiny Shard", "Spinal Fluid", "Spiritual Token", "Passive Token", "Blood", "Enchantment Token", "Star Balls", }
local TitansNames = {"Smiling Titan", "Attack Titan", "Female Titan", "Armored Titan", "Warhammer Titan", "Beast Titan", "Colossal Titan"}
local BloodlinesNames = {"Blouse", "Smith", "Zeke", "Tybur", "Yeager", "Ackerman"}

local createdDefense = false
local minute = os.date("%M")
local unixTimestamp
local NoClipping = nil
local CLip = true
local playerMode

function Initialize()
	Library:Notify(string.format('Script Loaded in %.2f second(s)!', tick() - StartTick), 5)
	print("[Beaast Hub] Loaded")
end

-- task.spawn(function()
-- 	while task.wait() and not Library.Unloaded do
-- 		playerMode = player:GetAttribute("Mode")
-- 		player.GameplayPaused = false
-- 	end
-- end)

task.spawn(function()
	while not Library.Unloaded do
		minute = os.date("%M")
		unixTimestamp = os.time(os.date("!*t"))
		task.wait(0.1)
	end
end)

-- // FUNCTIONS
function findNearestEnemy()
	local Closest = nil
	local ClosestDistance = math.huge

	local enemyModels = Workspace['_ENEMIES']:GetDescendants()

	for _, targetEnemy in ipairs(enemyModels) do
		if targetEnemy:IsA("Model") and targetEnemy:FindFirstChild('HumanoidRootPart') and targetEnemy:FindFirstChild('_STATS')  and tonumber(targetEnemy['_STATS']['CurrentHP'].Value) > 0 then
			local Distance = (character.HumanoidRootPart.Position - targetEnemy.HumanoidRootPart.Position).magnitude

			if Distance <= 1500 and Distance < ClosestDistance then
				Closest = targetEnemy
				ClosestDistance = Distance
			end
		end
	end

	if Closest == nil then ClosestDistance = math.huge end

	return Closest, ClosestDistance
end


function findNearestEnemyInWorld(world)
	local Closest = nil
	local ClosestDistance = math.huge

	for _, targetEnemy in ipairs(world) do
		if targetEnemy:IsA("Model") and targetEnemy:FindFirstChild('HumanoidRootPart') and targetEnemy:FindFirstChild('_STATS')  and tonumber(targetEnemy['_STATS']['CurrentHP'].Value) > 0 then
			local Distance = (character.HumanoidRootPart.Position - targetEnemy.HumanoidRootPart.Position).magnitude

			if Distance <= 1500 and Distance < ClosestDistance then
				Closest = targetEnemy
				ClosestDistance = Distance
			end
		end
	end

	if Closest == nil then ClosestDistance = math.huge end

	return Closest, ClosestDistance
end

local getClosestEnemyDungeon = (newcclosure(function(dungeon)
	local distance = 1000
	local enemy

	for i, v in pairs(Workspace._ENEMIES['Dungeon'][dungeon]:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild('_STATS')  and tonumber(v['_STATS']['CurrentHP'].Value) > 0 then
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
	local distance = 9e9
	local enemy

	for i, v in pairs(Workspace._ENEMIES['Defense']:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild('_STATS') and tonumber(v['_STATS']['CurrentHP'].Value) > 0 then
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
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild('_STATS') and tonumber(v['_STATS']['CurrentHP'].Value) > 0 then
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
		settings['AutoFarm']['World'] = value
		SaveConfig()
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

AutoFarm:AddToggle('enableBetterTitans', {
	Text = 'Enable Better Titans',
	Default = settings['AutoFarm']['Titans'],
	Tooltip = 'Titans always attack closest enemy',

	Callback = function(value)
		settings['AutoFarm']['Titans'] = value
		SaveConfig()
	end
})

local AutoExchange = Tabs['Main']:AddLeftGroupbox('Auto Exchange')
AutoExchange:AddDropdown('autoExchangeSacrifice', {
	Text = 'Exchange Item (Sacrifice)',
	Tooltip = 'The item you will lose',
	Default = settings['Exchange']['Sacrifice'],
	Multi = false,
	Values = ItemsNames,

	Callback = function(value)
		settings['Exchange']['Sacrifice'] = value
		SaveConfig()
	end
})

AutoExchange:AddDropdown('autoExchangeReturn', {
	Text = 'Exchange Item (Receive)',
	Tooltip = 'The item you will lose',
	Default = settings['Exchange']['Return'],
	Multi = false,
	Values = ItemsNames,

	Callback = function(value)
		settings['Exchange']['Return'] = value
		SaveConfig()
	end
})

AutoExchange:AddToggle('enableAutoExchange', {
	Text = 'Enable Auto Exchange',
	Default = settings['Exchange']['Enabled'],
	Tooltip = 'Activate Auto Exchange',

	Callback = function(value)
		settings['Exchange']['Enabled'] = value
		SaveConfig()
	end
})

AutoExchange:AddToggle('enableOPCrate', {
	Text = 'Enable OP Crate',
	Default = settings['Exchange']['OPCrate'],
	Tooltip = 'Rolls on OP Crate',

	Callback = function(value)
		settings['Exchange']['OPCrate'] = value
		SaveConfig()
	end
})

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['Exchange']['Enabled'] then
			local sacrificeItem = Items[settings['Exchange']['Sacrifice']]
			local returnItem = Items[settings['Exchange']['Return']]

			if tonumber(player.Exchange:GetAttribute("Amount")) < 1000 then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Exchange", [3] = "Make", [4] = sacrificeItem, [5] = returnItem } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			else
				if tonumber(player.Exchange:GetAttribute("TimeToReset")) < tonumber(unixTimestamp) then
					local args = { [1] = { [1] = { [1] = "\3", [2] = "Exchange", [3] = "Reset" } } }
					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['Exchange']['OPCrate'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "OPCrate", [3] = "Spin" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end
	end
end)

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoFarm']['Enabled'] then
			local enemy = getEnemies(worldsTable[settings['AutoFarm']['World']])
			if enemy == nil then return end
			local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
			local cf = enemy.HumanoidRootPart.CFrame
			local a = TweenService:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
			a:Play()

			local args = { [1] = { [1] = { [1] = "\3", [2] = "Click", [3] = "Execute", [4] = enemy } } }
			local titan1Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "1", [5] = enemy } } }
			local titan2Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "2", [5] = enemy } } }

			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			ReplicatedStorage.RemoteEvent:FireServer(unpack(titan1Args))
			ReplicatedStorage.RemoteEvent:FireServer(unpack(titan2Args))
		end
	end
end)

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['AutoFarm']['Titans'] then
			local Closest, ClosestDistance = findNearestEnemy()

			if Closest then
				if lastClosest == nil then lastClosest = Closest end

				if lastClosest == Closest then
					local titan1Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "1", [5] = Closest } } }
					local titan2Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "2", [5] = Closest } } }
					ReplicatedStorage.RemoteEvent:FireServer(unpack(titan1Args))
					task.wait(0.005)
					ReplicatedStorage.RemoteEvent:FireServer(unpack(titan2Args))
				else
					lastClosest = Closest
					local titan1Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "1", [5] = Closest } } }
					local titan2Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "2", [5] = Closest } } }
					ReplicatedStorage.RemoteEvent:FireServer(unpack(titan1Args))
					task.wait(0.005)
					ReplicatedStorage.RemoteEvent:FireServer(unpack(titan2Args))
				end
			else
				local titan1Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "1" } } }
				local titan2Args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Attack", [4] = "2" } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(titan1Args))
				task.wait(0.005)
				ReplicatedStorage.RemoteEvent:FireServer(unpack(titan2Args))
			end

		end
	end
end)

AutoFarm:AddToggle('enableAutoDefense', {
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

			if #Workspace['_ENEMIES']['Defense']:GetChildren() <= 0 then
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

					local args = { [1] = { [1] = { [1] = "\3", [2] = "Click", [3] = "Execute", [4] = enemy } } }
					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end
		end
	end
end)

--[[
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
]]--

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

						local args = { [1] = { [1] = { [1] = "\3", [2] = "Click", [3] = "Execute", [4] = enemy } } }
						ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
					end
				end
			end
		end
	end
end)

-- // ROLLS
local Rolls = Tabs['Main']:AddRightGroupbox("Auto Rolls")
Rolls:AddDropdown('selectedTitanToGet', {
	Text = 'Selected Titans',
	Tooltip = 'Select Titan to roll',
	Default = settings['Rolls']['Titan']['Selected'],
	Multi = true,
	Values = TitansNames,

	Callback = function(value)
		settings['Rolls']['Titan']['Selected'] = value
		SaveConfig()
	end
})

Rolls:AddDropdown('selectedTitanToRollOn', {
	Text = 'Titan Slot',
	Tooltip = 'Select slot to roll titan',
	Default = settings['Rolls']['Titan']['Slot'],
	Multi = false,
	Values = {"1", "2"},

	Callback = function(value)
		settings['Rolls']['Titan']['Slot'] = value
		SaveConfig()
	end
})

Rolls:AddToggle('enableTitanRoll', {
	Text = 'Auto Roll Titan',
	Default = false, --settings['Rolls']['Titan']['Enabled'],
	Tooltip = 'Rerolls your Titans',

	Callback = function(value)
		settings['Rolls']['Titan']['Enabled'] = value
		SaveConfig()
	end
})

local selectedTitansToGet = {}
task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['Rolls']['Titan']['Enabled'] then
			local equippedTitan = nil
			table.clear(selectedTitansToGet)

			for i, v in pairs(settings['Rolls']['Titan']['Selected']) do
				table.insert(selectedTitansToGet, Titans[i])
			end

			if settings['Rolls']['Titan']['Slot'] == "1" then equippedTitan = player:GetAttribute("Titan1") end
			if settings['Rolls']['Titan']['Slot'] == "2" then 
				if player:GetAttribute("BuyedTitan2") then
					equippedTitan = player:GetAttribute("Titan2")
				else
					equippedTitan = nil
				end
			end
			
			if equippedTitan ~= nil then
				if not table.find(selectedTitansToGet, equippedTitan) then
					local args = { [1] = { [1] = { [1] = "\3", [2] = "Titan", [3] = "Spin", [4] = settings['Rolls']['Titan']['Slot'] } } }
					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end
		end
	
		task.wait(0.1)
	end
end)

Rolls:AddDropdown('selectedBloodlineToGet', {
	Text = 'Selected Bloodlines',
	Tooltip = 'Select Bloodlines to roll',
	Default = settings['Rolls']['Bloodline']['Selected'],
	Multi = true,
	Values = BloodlinesNames,

	Callback = function(value)
		settings['Rolls']['Bloodline']['Selected'] = value
		SaveConfig()
	end
})

Rolls:AddToggle('enableBoodlineRoll', {
	Text = 'Auto Roll Bloodline',
	Default = false,
	Tooltip = 'Rerolls your Bloodlines',

	Callback = function(value)
		settings['Rolls']['Bloodline']['Enabled'] = value
		SaveConfig()
	end
})

local selectedBloodlinesToGet = {}
task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['Rolls']['Bloodline']['Enabled'] then
			local equippedBloodline = nil
			table.clear(selectedBloodlinesToGet)

			for i, v in pairs(settings['Rolls']['Bloodline']['Selected']) do
				table.insert(selectedBloodlinesToGet, Bloodlines[i])
			end
			
			equippedBloodline = player:GetAttribute("Bloodline")

			if equippedBloodline ~= nil then
				if not table.find(selectedBloodlinesToGet, equippedBloodline) then
					local args = { [1] = { [1] = { [1] = "\3", [2] = "Bloodline", [3] = "Spin" } } }
					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end
		end
		
		task.wait(0.1)
	end
end)

-- // UTILS
local Utils = Tabs['Main']:AddRightGroupbox('Utilities')
Utils:AddToggle('enableAutoPassive', {
	Text = 'Auto Passive (Player)',
	Default = settings['Utils']['PlayerPassive'],
	Tooltip = 'Rerolls your Player Passive',

	Callback = function(value)
		settings['Utils']['PlayerPassive'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoElement', {
	Text = 'Auto Element',
	Default = settings['Utils']['Element'],
	Tooltip = 'Rerolls your Ninja Element',

	Callback = function(value)
		settings['Utils']['Element'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoRace', {
	Text = 'Auto Race',
	Default = settings['Utils']['Race'],
	Tooltip = 'Rerolls your Dragon Race',

	Callback = function(value)
		settings['Utils']['Race'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoKagune', {
	Text = 'Auto Kagune',
	Default = settings['Utils']['Kagune'],
	Tooltip = 'Rerolls your Kagune',

	Callback = function(value)
		settings['Utils']['Kagune'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoClass', {
	Text = 'Auto Class',
	Default = settings['Utils']['Class'],
	Tooltip = 'Rerolls your Class',

	Callback = function(value)
		settings['Utils']['Class'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableClaimDailyRewards', {
	Text = 'Claim Daily Rewards',
	Default = settings['Utils']['DailyRewards'],
	Tooltip = 'Automatically claims your daily rewards',

	Callback = function(value)
		settings['Utils']['DailyRewards'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoSpinWheel', {
	Text = 'Auto Spin Wheel',
	Default = settings['Utils']['WheelSpin'],
	Tooltip = 'Automatically spins your Daily Wheel',

	Callback = function(value)
		settings['Utils']['WheelSpin'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoMount', {
	Text = 'Auto Mount',
	Default = settings['Utils']['AutoMount'],
	Tooltip = 'Automatically uses your Mount',

	Callback = function(value)
		settings['Utils']['AutoMount'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoCrew', {
	Text = 'Auto Crew',
	Default = settings['Utils']['AutoCrew'],
	Tooltip = 'Automatically claims and resends your Crew',

	Callback = function(value)
		settings['Utils']['AutoCrew'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoAscend', {
	Text = 'Auto Ascend',
	Default = settings['Utils']['Ascend'],
	Tooltip = 'Automatically upgrades your Ascension',

	Callback = function(value)
		settings['Utils']['Ascend'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableAutoAura', {
	Text = 'Auto Aura',
	Default = settings['Utils']['Aura'],
	Tooltip = 'Automatically upgrades your Aura',

	Callback = function(value)
		settings['Utils']['Aura'] = value
		SaveConfig()
	end
})

Utils:AddToggle('enableNoclip', {
	Text = 'Enable Noclip',
	Default = settings['Utils']['Noclip'],
	Tooltip = 'Enables Noclip',

	Callback = function(value)
		settings['Utils']['Noclip'] = value
		SaveConfig()
	end
})

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['Utils']['PlayerPassive'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "Passive", [3] = "PlayerSpin" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end

		if settings['Utils']['Element'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "Element", [3] = "Spin" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end

		if settings['Utils']['Race'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "Race", [3] = "Spin" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end

		if settings['Utils']['Kagune'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "Kagune", [3] = "Spin" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end

		if settings['Utils']['Class'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "Class", [3] = "Spin" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end

		if settings['Utils']['DailyRewards'] then
			local Counter = tonumber(player.DailyRewards:GetAttribute("Counter"))
			local TimeToReset = tonumber(player.DailyRewards:GetAttribute("TimeToReset"))
			local List = player.DailyRewards.List

			for i, v in pairs(List:GetChildren()) do
				if not v:GetAttribute("Claimed") then
					if Counter > tonumber(v:GetAttribute("Timer")) then
						local args = { [1] = { [1] = { [1] = "\3", [2] = "DailyRewards", [3] = "Claim", [4] = v.Name } } }
						ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
					end
				end
			end

			if TimeToReset < tonumber(unixTimestamp) then
				if List["1"]:GetAttribute("Claimed") and List["2"]:GetAttribute("Claimed") and List["3"]:GetAttribute("Claimed") and List["4"]:GetAttribute("Claimed") and List["5"]:GetAttribute("Claimed") and List["6"]:GetAttribute("Claimed") and List["7"]:GetAttribute("Claimed") and List["8"]:GetAttribute("Claimed") then
					local args = { [1] = { [1] = { [1] = "\3", [2] = "DailyRewards",  [3] = "Reset" } } }
					ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
				end
			end

			--[[
			local DailyRewards = PlayerGui['_CENTER'].DailyRewards
			local Buttons = DailyRewards.Time.Content.Scroll

			for i, v in pairs(Buttons:GetChildren()) do
				if v.Name ~= "UIGridLayout" and v.Name ~= "UIPadding" then
					if v['Button'].BackgroundColor3 ~= Color3.fromRGB(0, 255, 0) and v['Button'].BackgroundColor3 ~= Color3.fromRGB(255, 0, 0) then
						local args = { [1] = { [1] = { [1] = "\3", [2] = "DailyRewards", [3] = "Claim", [4] = v.Name } } }
						ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
					end
				end
			end

			if DailyRewards.Time.Reset.Visible and Buttons['8'].Button.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "DailyRewards",  [3] = "Reset" } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
			]]
		end

		if settings['Utils']['WheelSpin'] then
			if tonumber(PlayerGui._CENTER.DailyRewards.Wheel.Info.Amount.Text) > 0 then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Wheel", [3] = "Spin" } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
		end

		if settings['Utils']['AutoMount'] then
			if not player:GetAttribute("OnMount") then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Mount", [3] = "Add" } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
		end

		if settings['Utils']['AutoCrew'] then
			if tonumber(player.Crew:GetAttribute("TimeToBack")) == 0 then
				local claimRewards = { [1] = { [1] = { [1] = "\3", [2] = "Crew", [3] = "ClaimRewards" } } }
				local sendCrew = { [1] = { [1] = { [1] = "\3", [2] = "Crew", [3] = "Send" } } }

				ReplicatedStorage.RemoteEvent:FireServer(unpack(claimRewards))
				task.wait(0.2)
				ReplicatedStorage.RemoteEvent:FireServer(unpack(sendCrew))
			end
		end

		if settings['Utils']['Ascend'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "Ascension", [3] = "Make" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end

		if settings['Utils']['Aura'] then
			local args = { [1] = { [1] = { [1] = "\3", [2] = "Aura", [3] = "Upgrade" } } }
			ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
		end
	end
end)

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		if settings['Utils']['Noclip'] then
			Clip = false
			task.wait(0.1)
			local function NoclipLoop()
				if Clip == false and character ~= nil then
					for _, child in pairs(character:GetDescendants()) do
						if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
							child.CanCollide = false
						end
					end
				end
			end

			NoClipping = RunService.Stepped:Connect(NoclipLoop)
		else
			if NoClipping then
				NoClipping:Disconnect()
			end
			Clip = true
		end
	end
end)


local Potions = Tabs['Main']:AddRightGroupbox('Auto Potions')
Potions:AddToggle('damagePotion', {
	Text = 'Use Damage Potion',
	Default = settings['Potions']['Damage'],
	Tooltip = 'Automatically uses Damage Boost',

	Callback = function(value)
		settings['Potions']['Damage'] = value
		SaveConfig()
	end
})

Potions:AddToggle('dropPotion', {
	Text = 'Use Drop Potion',
	Default = settings['Potions']['Drop'],
	Tooltip = 'Automatically uses Drop Boost',

	Callback = function(value)
		settings['Potions']['Drop'] = value
		SaveConfig()
	end
})

Potions:AddToggle('energyPotion', {
	Text = 'Use Energy Potion',
	Default = settings['Potions']['Energy'],
	Tooltip = 'Automatically uses Energy Boost',

	Callback = function(value)
		settings['Potions']['Energy'] = value
		SaveConfig()
	end
})

Potions:AddToggle('luckPotion', {
	Text = 'Use Luck Potion',
	Default = settings['Potions']['Luck'],
	Tooltip = 'Automatically uses Luck Boost',

	Callback = function(value)
		settings['Potions']['Luck'] = value
		SaveConfig()
	end
})

Potions:AddToggle('soulsPotion', {
	Text = 'Use Souls Potion',
	Default = settings['Potions']['Souls'],
	Tooltip = 'Automatically uses Souls Boost',

	Callback = function(value)
		settings['Potions']['Souls'] = value
		SaveConfig()
	end
})

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		task.wait(5)
		
		if settings['Potions']['Damage'] then
			if tonumber(player.Potions:GetAttribute("Damage")) == 0 then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Potion", [3] = "Use", [4] = "Damage", [5] = 1 } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
		end
		
		if settings['Potions']['Drop'] then
			if tonumber(player.Potions:GetAttribute("Drop")) == 0 then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Potion", [3] = "Use", [4] = "Drop", [5] = 1 } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
		end
		
		if settings['Potions']['Energy'] then
			if tonumber(player.Potions:GetAttribute("Energy")) == 0 then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Potion", [3] = "Use", [4] = "Energy", [5] = 1 } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
		end
		
		if settings['Potions']['Luck'] then
			if tonumber(player.Potions:GetAttribute("Luck")) == 0 then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Potion", [3] = "Use", [4] = "Luck", [5] = 1 } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
		end
		
		if settings['Potions']['Souls'] then
			if tonumber(player.Potions:GetAttribute("Soul")) == 0 then
				local args = { [1] = { [1] = { [1] = "\3", [2] = "Potion", [3] = "Use", [4] = "Soul", [5] = 1 } } }
				ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
			end
		end
	end
end)

-- // TIMERS
local Timers = Tabs['Main']:AddLeftGroupbox('Timers')
local CenterGUI = PlayerGui['_CENTER']
local ExchangeTimer = Timers:AddLabel("EXCHANGE >> ", true)
local CrewTimer = Timers:AddLabel("CREW >> ", true)
--local ChestTimer = Timers:AddLabel("GROUP CHEST >> ", true)

task.spawn(function()
	while task.wait() and not Library.Unloaded do
		local exchangeTimerResetText = CenterGUI.Exchange.ResetTime.Label.Text
		local crewTimerReset = CenterGUI.Crew.State
		local crewTimerText = "LOADING"

		if CenterGUI.Exchange.ResetTime.Label.TextColor3 == Color3.fromRGB(255, 0, 0) then
			exchangeTimerResetText = exchangeTimerResetText:gsub("%b<>", "")
			exchangeTimerResetText = exchangeTimerResetText:match(': (.+)')
			exchangeTimerResetText = "Available in: " .. exchangeTimerResetText
		end

		if crewTimerReset.Ready.Visible then
			crewTimerText = "READY"
		else
			crewTimerText = crewTimerReset.Sailing.Text
			crewTimerText = crewTimerText:gsub("%b<>", "")
			crewTimerText = crewTimerText:match('at (.+)')
			crewTimerText = "Available in: " .. crewTimerText
		end
		
		ExchangeTimer:SetText("EXCHANGE >> " .. exchangeTimerResetText)
		CrewTimer:SetText("CREW >> " .. crewTimerText)
	end
end)

Library:OnUnload(function()
	print('[Beaast Hub] Unloaded')
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

OtherScripts:AddButton('Simple Spy', function()
	task.spawn(loadstring(game:HttpGet('https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua', true)))
end)

OtherScripts:AddButton('Dark Dex', function()
	task.spawn(loadstring(game:HttpGet('https://raw.githubusercontent.com/Deniied0/Dex/master/source.lua', true)))
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