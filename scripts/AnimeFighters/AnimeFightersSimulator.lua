		local AnimeFightersPlaceId = 6299805723
		if game.placeId ~= AnimeFightersPlaceId then return end
		repeat task.wait() until game:IsLoaded()
		local StartTick = tick()

		local HttpService = game:GetService('HttpService')
		local request = http_request or request or HttpPost or syn.request or http.request
		------
		local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
		local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
		local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

		local Window = Library:CreateWindow({ Title = 'Beaast Hub | Anime Fighters Simulator', Center = true, AutoShow = true })
		local Tabs = {
			['Main'] = Window:AddTab('Main'),
			['Dungeon'] = Window:AddTab('Dungeon'),
			['UI Settings'] = Window:AddTab('UI Settings'),
		}

		local saveFolderName = 'BeaastHub'
		local gameFolderName = 'AnimeFighters'
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
			['AutoTower'] = {
				['Enabled'] = false,
				['EnableTeams'] = false
			},
			['AutoRaid'] = {
				['Enabled'] = false,
				['BackPosition'] = '7656.22852, -180.359406, -7856.69971, 1, 3.68046464e-08, 3.72713606e-14, -3.68046464e-08, 1, 5.18453689e-08, -3.53632088e-14, -5.18453689e-08, 1',
				['BackWorld'] = 'OPWano',
				['ToggleAllRaids'] = false,
				['EnableTeams'] = false,
				['raidWorlds'] = {}
			},
			['Dungeon'] = {
				['Enabled'] = false,
				['EnableTeams'] = false,
				['BackPosition'] = '7656.22852, -180.359406, -7856.69971, 1, 3.68046464e-08, 3.72713606e-14, -3.68046464e-08, 1, 5.18453689e-08, -3.53632088e-14, -5.18453689e-08, 1',
				['BackWorld'] = 'OPWano',
				['IgnoreBossUntilKey'] = false
			},
			['Teams'] = {
				['AutoFarmAll'] = 1,
				['AutoFarmChests'] = 1,
				['RaidInside'] = 1,
				['RaidAfter'] = 1,
				['EnableChestTeam'] = false,
				['EnableFarmTeam'] = false
			},
			['AutoStar'] = {
				['SelectedStar'] = 'Z Star'
			},
			['Misc'] = {
				['AutoMount'] = false,
				['DailyTicket'] = false,
				['DailySpin'] = false,
				['DailyGifts'] = false,
				['Merchant'] = false
			},
			['Keybinds'] = {
				['menuKeybind'] = 'LeftShift',
				['AutoFarm'] = 'Unknown'
			},
			watermark = false,
			webhookLink = 'Webhook Link',
			webhookMentionId = 'Mention ID'
		}

		local enabledAutoStar = false
		local enabledMultiOpen = false

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

		local REMOTE = ReplicatedStorage.Remote
		local BINDABLE = ReplicatedStorage.Bindable

		local MAX_SUMMON = 13
		local MAX_EQUIPPED = 10
		local MAX_ROOM = 50
		local KILLING_METEOR = false
		local KILLING_GIFT = false
		local MAX_TIME_TO_CHECK_FOR_METEOR = 30
		local WAIT_BEFORE_GETTING_ENEMIES = 1
		local NUM_BOSS_ATTACKERS = 24
		local HP_TO_SWAP_AT = 1e17
		local HP_THRESH_HOLD = 1e16
		local AUTO_EQUIP_TIME = 300
		local CURRENT_TRIAL = ''

		local statCalc = require(ReplicatedStorage.ModuleScripts.StatCalc)
		local numToString = require(ReplicatedStorage.ModuleScripts.NumToString)
		local petStats = require(ReplicatedStorage.ModuleScripts.PetStats)
		local store = require(ReplicatedStorage.ModuleScripts.LocalDairebStore)
		local enemyStats = require(ReplicatedStorage.ModuleScripts.EnemyStats)
		local worldData = require(ReplicatedStorage.ModuleScripts.WorldData)
		local configValues = require(ReplicatedStorage.ModuleScripts.ConfigValues)
		local passiveStats = require(ReplicatedStorage.ModuleScripts.PassiveStats)
		local eggStats = require(ReplicatedStorage.ModuleScripts.EggStats)
		local enemyDamagedEffect = require(starterPlayerScriptsFolder.LocalPetHandler.EnemyDamagedEffect)

		--local data = store.getStoreProxy('GameData')
		local IGNORED_RARITIES = {'Mythical', 'Secret', 'Raid', 'Divine'}
		local IGNORED_WORLDS = {'Raid', 'Tower', 'Titan', 'Christmas'}
		local IGNORED_METEOR_FARM_WORLDS = {'Tower', 'Raid'}
		local TEMP_METEOR_FARM_IGNORE = {}

		local playerTeamsNames = {}
		local playerTeams = {}
		local currentlyEquippedTeam = ''

		local mobs = {}
		local eggData = {}
		local sentDebounce = {}
		local raidWorlds = {}
		local petsToFuse = {}
		local TRIAL_TARGET = {
			Weakest = false,
			Strongest = false
		}
		local originalEquippedPets = {}
		local originalPetsTab = {}
		local eggDisplayNameToNameLookUp = {}
		local passivesToKeep = {}
		local defenseWorlds = {}
		local damagedEffectFunctions = {
			[true] = function()
				return true
			end,
			[false] = enemyDamagedEffect.DoEffect
		}

		local PASSIVE_FORMAT = '%s (%s)'
		local FIGHTER_FORMAT = 'Pet ID: %s | Display Name: %s'
		local PET_TEXT_FORMAT = '%s (%s) | UID: %s | Level: %s'
		local selectedFuse
		local selectedDefenseWorld
		
		local minute = os.date("%M")

		local towerFarm
		local stopTrial
		local roomToStopAt = 50
		local chestIgnoreRoom = 50
		local goldSwap
		local easyTrial
		local mediumTrial
		local hardTrial
		local ultimateTrial

		local reEquippingPets = false
		local equippingTeam = false

		local bsec1
		local farmAllToggle

		local hidePets
		local fighterFuseDropdown
		local PlayerGui = player.PlayerGui
		local DEFENSE_RESULT = PlayerGui.TitanGui.DefenseResult
		local RAID_RESULT = PlayerGui.RaidGui.RaidResults

		local playerPos = character.HumanoidRootPart.CFrame
		local WORLD = player.World.Value

		local easyTrialTime
		local mediumTrialTime
		local hardTrialTime
		local ultimateTrialTime
		local infinityTowerTime

		local infTowerTimer
		local infTowerFloorNumberText
		local infTowerYesButton
		local towerTime
		local yesButton
		local floorNumberText

		--To reference the countdown in trial
		function InitializeTrial()
			REMOTE.AttemptTravel:InvokeServer('Tower')
			character.HumanoidRootPart.CFrame = Workspace.Worlds.Tower.Spawns.SpawnLocation.CFrame
			Workspace.Worlds.Tower.Water.CanCollide = true

			task.wait(3)

			REMOTE.AttemptTravel:InvokeServer(WORLD)
			character.HumanoidRootPart.CFrame = playerPos

			easyTrialTime = Workspace.Worlds.Tower.Door1.Countdown.SurfaceGui.Background.Time
			mediumTrialTime = Workspace.Worlds.Tower.Door2.Countdown.SurfaceGui.Background.Time
			hardTrialTime = Workspace.Worlds.Tower.Door3.Countdown.SurfaceGui.Background.Time
			ultimateTrialTime = Workspace.Worlds.Tower.Door4.Countdown.SurfaceGui.Background.Time
			infinityTowerTime = Workspace.Worlds.Tower.InfinityDoor.Countdown.SurfaceGui.Background.Time

			infTowerTimer = PlayerGui.MainGui.InfinityTowerTimer.Main.Time
			infTowerFloorNumberText = PlayerGui.MainGui.InfinityTowerTimer.CurrentFloor

			towerTime = PlayerGui.MainGui.TowerTimer.Main.Time
			yesButton = PlayerGui.MainGui.RaidTransport.Main.Yes
			infTowerYesButton = PlayerGui.MainGui.InfinityTowerTeleport.Main.Yes
			floorNumberText = PlayerGui.MainGui.TowerTimer.CurrentFloor.Value
		end

		function ResetPlayerTeams()
			playerTeamsNames = {}
			playerTeams = {}

			for k, v in pairs(PlayerGui.MainGui.Pets.TeamsList.Main.Scroll:GetChildren()) do
				if v.Name == 'TeamTemplate' then
					playerTeams[v.TeamName.Text] = v.Button
					currentlyEquippedTeam = ''
					if not table.find(playerTeamsNames, v.TeamName.Text) then table.insert(playerTeamsNames, v.TeamName.Text) end
				end
			end
		end

		local confirmRaidButton = PlayerGui.RaidGui.RaidResults.Confirm
		local unequipAllButton = PlayerGui.MainGui.Pets.UnequipButton.Button

		local bstEggs = {}
		local bstEggsTable = {
			["Z Star"] = "GokuEgg", ["Ninja Star"] = "NarutoEgg", ["Crazy Star"] = "JojoEgg", ["Pirate Star"] = "OnePieceEgg", ["Hero Star"] = "MHAEgg", ["Attack Star"] = "AOTEgg", ["Demon Star"] = "DemonEgg", ["Ghoul Star"] = "GhoulEgg", ["Hunter Star"] = "HxHEgg", ["Swordsman Star"] = "SAOEgg", ["Empty Star"] = "BleachEgg", ["Cursed Star"] = "JJKEgg", ["Power Star"] = "OPMEgg", ["Sins Star"] = "7DSEgg", ["Destiny Star"] =" FateEgg", ["Luck Star"] = "BCEgg", ["Alchemy Star"] = "FMAEgg", ["Slime Star"] = "SlimeEgg", ["Flame Star"] = "FireForceEgg", ["Champion Star"] = "RoREgg", ["Wizard Star"] = "FairyTailEgg", ["Icy Star"] = "ReZeroEgg", ["Saw Star"] = "ChainsawManEgg", ["Esper Star"] = "Mob100Egg", ["Violent Star"] = "DorohedoroEgg", ["Young Ninja Star"] = "BorutoEgg", ["Gangster Star"] = "TokyoRevengerEgg", ["Inmate Star"] = "JJBAStoneOceanEgg", ["Card Star"] = "YugiohEgg", ["Academy Star"] = "KLKEgg", ["Struggler Star"] = "BerserkEgg", ["Rising Star"] = "ShieldHeroEgg", ["Lord Star"] = "OverlordEgg", ["Soul Star"] = "SoulEaterEgg", ["Knight Star"] = "CodeGeassEgg", ["Abyss Star"] = "MadeInAbyssEgg", ["Blessed Star"] = "HellsParadiseEgg", ["Wanzo Star"] = "OPWanoEgg", ["Demonic Star"] = "DemonSlayer2Egg", ["War Star"] = "BTYBWEgg", ["Summer Star"] = "SummerEgg"
		}

		local enemiesRange = 150

		-- // Functions
		function retreat()
			VirtualInputManager:SendKeyEvent(true, 'R', false, nil)
			task.wait(0.005)
			VirtualInputManager:SendKeyEvent(false, 'R', false, nil)
		end

		function getPetWithUID(uid)
			local pets = getPets()
			for _, pet in pairs(pets) do
				if pet.UID == uid then
					return pet
				end
			end
		end

		function getEquippedPets()
			local equipped = {}
			for _, obj in ipairs(player.Pets:GetChildren()) do
				local pet = obj.Value
				local petTable = getPetWithUID(pet.Data.UID.Value)
				if petTable then
					table.insert(equipped, petTable)
				end
			end

			return equipped
		end

		function unequipPets()
			for i, button in pairs(getconnections(unequipAllButton.Activated)) do
				if i == 1 then
					button:Fire()
					currentlyEquippedTeam = ''
				end
			end
		end

		function sendPet(enemy)
			if sentDebounce[enemy] then return end
			sentDebounce[enemy] = true

			local currWorld = player.World.Value
			local AMOUNT_TO_MOVE_BACK = 10
			local charPos = player.Character.HumanoidRootPart.CFrame
			local x = 0
			local petTab = {}
			local models = {}

			for _, objValue in ipairs(player.Pets:GetChildren()) do
				local p = objValue.Value
				local pet = getPetWithUID(p.Data.UID.Value)
				table.insert(petTab, pet)
			end

			table.sort(petTab, function(pet1, pet2)
				return pet1.Level > pet2.Level
			end)

			for _, pet in pairs(petTab) do
				for _, objValue in ipairs(player.Pets:GetChildren()) do
					model = objValue.Value

					if model.Data.UID.Value == pet.UID then
						table.insert(models, model)
						break
					end
				end
			end

			for _, model in ipairs(models) do
				local cframe = charPos + Vector3.new(x, 0, 0)
				local targetPart = model:FindFirstChild("TargetPart")
				local hrp = model:FindFirstChild("HumanoidRootPart")

				if targetPart and hrp then
					targetPart.CFrame = cframe
					hrp.CFrame = cframe
					x -= AMOUNT_TO_MOVE_BACK
				end
			end

			table.clear(petTab)
			table.clear(models)
			petTab = nil
			models = nil

			repeat
				if enemy:FindFirstChild("Attackers") and enemy:FindFirstChild("AnimationController") then
					BINDABLE.SendPet:Fire(enemy, true)
				end

				task.wait()
			until _G.disabled
			or enemy:FindFirstChild("Attackers") == nil
			or not enemy:IsDescendantOf(workspace)
			or enemy:FindFirstChild("AnimationController") == nil
			or enemy:FindFirstChild("Health") == nil
			or player.World.Value ~= currWorld
			or enemy.Health.Value <= 0
			or (not towerFarm)

			sentDebounce[enemy] = nil
		end

		function GenEggStats()
			local orderedEggs = {
				[1] = "Z Star",
				[2] = "Ninja Star",
				[3] = "Crazy Star",
				[4] = "Pirate Star",
				[5] = "Hero Star",
				[6] = "Attack Star",
				[7] = "Demon Star",
				[8] = "Ghoul Star",
				[9] = "Hunter Star",
				[10] = "Swordsman Star",
				[11] = "Empty Star",
				[12] = "Cursed Star",
				[13] = "Power Star",
				[14] = "Sins Star",
				[15] = "Destiny Star",
				[16] = "Luck Star",
				[17] = "Alchemy Star",
				[18] = "Slime Star",
				[19] = "Flame Star",
				[20] = "Champion Star",
				[21] = "Wizard Star",
				[22] = "Icy Star",
				[23] = "Saw Star",
				[24] = "Esper Star",
				[25] = "Violent Star",
				[26] = "Young Ninja Star",
				[27] = "Gangster Star",
				[28] = "Inmate Star",
				[29] = "Card Star",
				[30] = "Academy Star",
				[31] = "Struggler Star",
				[32] = "Rising Star",
				[33] = "Lord Star",
				[34] = "Soul Star",
				[35] = "Knight Star",
				[36] = "Abyss Star",
				[37] = "Blessed Star",
				[38] = "Wanzo Star",
				[39] = "Demonic Star",
				[40] = "War Star",
				[41] = "Summer Star"
			}

			for k, v in ipairs(orderedEggs) do
				table.insert(bstEggs, v)

				for eggName, eggId in pairs(bstEggsTable) do
					if eggName == v then
						eggDisplayNameToNameLookUp[v] = eggId
					end
				end
			end
		end

		function tp(world, pos)
			if world ~= nil then
				player.World.Value = world
				REMOTE.AttemptTravel:InvokeServer(world)
				character.HumanoidRootPart.CFrame = pos
			end
		end

		function movePetsToPlayer()
			for _, pet in ipairs(player.Pets:GetChildren()) do
				local targetPart = pet.Value:FindFirstChild("TargetPart")
				local humanoidRootPart = pet.Value:FindFirstChild("HumanoidRootPart")

				if targetPart and humanoidRootPart then
					targetPart.CFrame = character.HumanoidRootPart.CFrame
					humanoidRootPart.CFrame = character.HumanoidRootPart.CFrame
				end
			end
		end

		local lastClosest = nil

		function findNearestEnemy()
			local playerWorld = player.World.Value
			local Closest = nil
			local ClosestDistance = math.huge

			if Workspace.Worlds[playerWorld]:FindFirstChild('Enemies') then
				local enemyModels = Workspace.Worlds[playerWorld].Enemies:GetChildren()

				for _, targetEnemy in ipairs(enemyModels) do
					if targetEnemy:FindFirstChild('HumanoidRootPart') and targetEnemy:FindFirstChild('Attackers') then
						local Distance = (character.HumanoidRootPart.Position - targetEnemy.HumanoidRootPart.Position).magnitude

						if Distance <= enemiesRange and Distance < ClosestDistance then
							if targetEnemy.Name == 'Chest' and settings['AutoFarm']['IgnoreChests'] then
								Closest = nil
								ClosestDistance = math.huge
							else
								Closest = targetEnemy
								ClosestDistance = Distance
							end
						end
					end
				end

				if Closest == nil then ClosestDistance = math.huge end

				return Closest, ClosestDistance
			end
		end

		function getMobs()
			for _, enemy in ipairs(Workspace.Worlds[player.World.Value].Enemies:GetChildren()) do
				if not table.find(mobs, enemy.DisplayName.Value) then
					table.insert(mobs, enemy.DisplayName.Value)
				end
			end

			return mobs
		end

		function teleportTo(world)
			local response = REMOTE.AttemptTravel:InvokeServer(world)

			if response then
				character.HumanoidRootPart.CFrame = Workspace.Worlds[world].Spawns.SpawnLocation.CFrame + Vector3.new(0, 15, 0)
			end
		end

		function getTarget(targetName, world)
			if not table.find(IGNORED_WORLDS, world) then
				local enemies = Workspace.Worlds[world].Enemies

				for _, enemy in ipairs(enemies:GetChildren()) do
					if enemy:FindFirstChild('DisplayName') and enemy.DisplayName.Value == name and enemy:FindFirstChild('HumanoidRootPart') then
						return enemy
					end
				end
			end
		end

		function Initialize()
			ResetPlayerTeams()
			task.wait(0.5)
			unequipAllButton.MouseButton1Click:Connect(function()
				unequipPets()
			end)
			task.wait(0.5)
			InitializeTrial()
			task.wait(0.5)
			GenEggStats()
			task.wait(0.5)
			Library:Notify(string.format('Script Loaded in %.2f second(s)!', tick() - StartTick), 5)
		end

		Initialize()

		-- // LIBRARY
		local AutoFarm = Tabs['Main']:AddLeftGroupbox('Auto Farm')
		AutoFarm:AddToggle('autoFarmAll', {
			Text = 'Auto Farm All',
			Default = settings['AutoFarm']['AttackAll'],
			Tooltip = 'Auto farm all enemies',

			Callback = function(value)
				settings['AutoFarm']['AttackAll'] = value
				SaveConfig()
			end
		})

		AutoFarm:AddToggle('ignoreChests', {
			Text = 'Ignore Chests',
			Default = settings['AutoFarm']['IgnoreChests'],
			Tooltip = 'Ignore Chests on auto farm',

			Callback = function(value)
				settings['AutoFarm']['IgnoreChests'] = value
				SaveConfig()
			end
		})

		AutoFarm:AddToggle('autoClick', {
			Text = 'Auto Click',
			Default = settings['AutoFarm']['AutoClick'],
			Tooltip = 'Auto click damage',

			Callback = function(value)
				settings['AutoFarm']['AutoClick'] = value
				SaveConfig()
			end
		})

		AutoFarm:AddToggle('autoCollect', {
			Text = 'Auto Collect',
			Default = settings['AutoFarm']['AutoCollect'],
			Tooltip = 'Auto collect drops',

			Callback = function(value)
				settings['AutoFarm']['AutoCollect'] = value
				SaveConfig()
			end
		})

		AutoFarm:AddToggle('autoUltSkip', {
			Text = 'Ult Skip',
			Default = settings['AutoFarm']['AutoUltSkip'],
			Tooltip = 'Skip ultimate animation',

			Callback = function(value)
				settings['AutoFarm']['AutoUltSkip'] = value
				SaveConfig()
			end
		})

		AutoFarm:AddToggle('boostPetSpeed', {
			Text = 'Boost Pet Speed (Re-Equip)',
			Default = settings['AutoFarm']['BoostPetSpeed'],
			Tooltip = 'Boosts Fighters Speed (Need Passives)',

			Callback = function(value)
				settings['AutoFarm']['BoostPetSpeed'] = value
				SaveConfig()
			end
		})

		local AutoRaid = Tabs['Main']:AddRightGroupbox('Auto Raid')
		AutoRaid:AddToggle('enableAutoRaid', {
			Text = 'Auto Raid',
			Default = settings['AutoRaid']['Enabled'],
			Tooltip = 'Enable Auto Raid',

			Callback = function(value)
				settings['AutoRaid']['Enabled'] = value
				SaveConfig()
			end
		})

		AutoRaid:AddToggle('enableAllRaids', {
			Text = 'Toggle All Raids',
			Default = settings['AutoRaid']['ToggleAllRaids'],
			Tooltip = 'Enable All Raids',

			Callback = function(value)
				settings['AutoRaid']['ToggleAllRaids'] = value
				SaveConfig()
			end
		})

		AutoRaid:AddToggle('equipTeamsOnRaid', {
			Text = 'Equip Teams',
			Default = settings['AutoRaid']['EnableTeams'],
			Tooltip = 'Auto Equip Teams',

			Callback = function(value)
				settings['AutoRaid']['EnableTeams'] = value
				SaveConfig()
			end
		})

		local SelectPositionButton = AutoRaid:AddButton({
			Text = 'Save Back Position',
			Func = function()
				settings['AutoRaid']['BackPosition'] = tostring(character.HumanoidRootPart.CFrame)
				settings['AutoRaid']['BackWorld'] = player.World.Value
				SaveConfig()
				Library:Notify('Saved Position', 5)
			end,
			DoubleClick = false
		})

		function stringToCFrame(string)
			return CFrame.new(table.unpack(string:gsub(' ', ''):split(',')))
		end

		local TestSavedPosition = AutoRaid:AddButton({
			Text = 'Test Back Position',
			Func = function()
				tp(settings['AutoRaid']['BackWorld'], stringToCFrame(settings['AutoRaid']['BackPosition']))
			end,
			DoubleClick = false
		})

		local Teams = Tabs['Main']:AddLeftGroupbox('Teams')

		local raidTeamDrop1 = Teams:AddDropdown('raidTeamDrop1', {
			Values = playerTeamsNames,
			Default = settings['Teams']['RaidInside'],
			Multi = false,

			Text = 'Equip Team on Raid',

			Callback = function(value)
				settings['Teams']['RaidInside'] = value
				SaveConfig()
			end
		})

		local raidTeamDrop2 = Teams:AddDropdown('raidTeamDrop2', {
			Values = playerTeamsNames,
			Default = settings['Teams']['RaidAfter'],
			Multi = false, -- true / false, allows multiple choices to be selected

			Text = 'Equip Team after Raid',

			Callback = function(value)
				settings['Teams']['RaidAfter'] = value
				SaveConfig()
			end
		})

		local autoFarmAllTeamDrop = Teams:AddDropdown('autoFarmAllTeamDrop', {
			Values = playerTeamsNames,
			Default = settings['Teams']['AutoFarmAll'],
			Multi = false,

			Text = 'Equip Team on autofarm/dungeon',

			Callback = function(value)
				settings['Teams']['AutoFarmAll'] = value
				SaveConfig()
			end
		})

		local autoFarmChestsTeamDrop = Teams:AddDropdown('autoFarmChestsTeamDrop', {
			Values = playerTeamsNames,
			Default = settings['Teams']['AutoFarmChests'],
			Multi = false,

			Text = 'Equip Team on chests',

			Callback = function(value)
				settings['Teams']['AutoFarmChests'] = value
				SaveConfig()
			end
		})

		Teams:AddToggle('equipTeamsOnChests', {
			Text = 'Equip Team on AutoFarm Chest',
			Default = settings['Teams']['EnableChestTeam'],
			Tooltip = 'Auto Equip Teams on Auto Farm All Target Chest',

			Callback = function(value)
				settings['Teams']['EnableChestTeam'] = value
				SaveConfig()
			end
		})

		Teams:AddToggle('equipTeamsOnFarm', {
			Text = 'Equip Team on AutoFarm All',
			Default = settings['Teams']['EnableFarmTeam'],
			Tooltip = 'Auto Equip Teams on Auto Farm All Target Enemy',

			Callback = function(value)
				settings['Teams']['EnableFarmTeam'] = value
				SaveConfig()
			end
		})

		Teams:AddButton({
			Text = 'Refresh Teams',
			Func = function()
				ResetPlayerTeams()
				raidTeamDrop1:SetValues(playerTeamsNames)
				raidTeamDrop2:SetValues(playerTeamsNames)
				autoFarmAllTeamDrop:SetValues(playerTeamsNames)
				autoFarmChestsTeamDrop:SetValues(playerTeamsNames)
			end,
			DoubleClick = false
		})

		local AutoStar = Tabs['Main']:AddRightGroupbox('Auto Star')

		AutoStar:AddDropdown('starDropdown', {
			Values = bstEggs,
			Default = settings['AutoStar']['SelectedStar'], -- number index of the value / string
			Multi = false, -- true / false, allows multiple choices to be selected

			Text = 'Selected Star',
			Tooltip = 'Star to open and max open', -- Information shown when you hover over the dropdown

			Callback = function(value)
				settings['AutoStar']['SelectedStar'] = value
				SaveConfig()
			end
		})

		AutoStar:AddToggle('autoStar', {
			Text = 'Auto Star',
			Default = false,
			Tooltip = 'Auto claim Daily Gifts',

			Callback = function(value)
				enabledAutoStar = value
				SaveConfig()
			end
		})

		AutoStar:AddToggle('autoMaxOpen', {
			Text = 'Auto Max Open',
			Default = false,
			Tooltip = 'Auto Max Open',

			Callback = function(value)
				enabledMultiOpen = value
				SaveConfig()
			end
		})

		AutoStar:AddLabel('Disable before teleporting')

		local Claims = Tabs['Main']:AddRightGroupbox('Claims')

		Claims:AddToggle('dailyGifts', {
			Text = 'Daily Gifts',
			Default = settings['Misc']['DailyGifts'],
			Tooltip = 'Auto claim Daily Gifts',

			Callback = function(value)
				settings['Misc']['DailyGifts'] = value
				SaveConfig()
			end
		})

		coroutine.resume(coroutine.create(function()
			while task.wait(5) do
				local claimedText = tostring(PlayerGui.MainGui.FreeGifts.ClaimedText.Text)
				local s1, s2 = claimedText:match("(%d+)/(%d+)")
				local n1, n2 = tonumber(s1), tonumber(s2)

				if n1 ~= n2 then
					local Number = 1

					while settings['Misc']['DailyGifts']do
						if Number > 16 then Number = 1 end

						game:GetService("ReplicatedStorage").Remote.ClaimGift:FireServer(Number)
						Number = Number + 1
						task.wait(0.25)
					end
				end

				if PlayerGui.MainGui.FreeGifts.Reset.Visible then
					REMOTE.ResetFreeGifts:FireServer()
				end
			end
		end))

		Claims:AddToggle('dailyTicket', {
			Text = 'Daily Ticket',
			Default = settings['Misc']['DailyTicket'],
			Tooltip = 'Auto claim Daily Ticket',

			Callback = function(value)
				settings['Misc']['DailyTicket'] = value
				SaveConfig()
			end
		})

		Claims:AddToggle('dailySpin', {
			Text = 'Daily Spin',
			Default = settings['Misc']['DailySpin'],
			Tooltip = 'Auto claim Daily Spin',

			Callback = function(value)
				settings['Misc']['DailySpin'] = value
				SaveConfig()
			end
		})

		Claims:AddToggle('claimMerchant', {
			Text = 'Claim Merchant Boost',
			Default = settings['Misc']['Merchant'],
			Tooltip = 'Auto claim Merchant Boost',

			Callback = function(value)
				settings['Misc']['Merchant'] = value
				SaveConfig()
			end
		})

		Claims:AddToggle('autoMount', {
			Text = 'Auto Mount',
			Default = settings['Misc']['AutoMount'],
			Tooltip = 'Automatically use Mount',

			Callback = function(value)
				settings['Misc']['AutoMount'] = value
				SaveConfig()
			end
		})

		coroutine.resume(coroutine.create(function()
			while task.wait(1) do
				if Library.Unloaded then return end
				
				if settings['Misc']['DailyTicket'] then
					REMOTE.ClaimTicket:FireServer()
				end

				if settings['Misc']['DailySpin'] then
					REMOTE.DailySpin:FireServer()
				end

				if settings['Misc']['Merchant'] then
					REMOTE.ClaimBoost:FireServer()
				end

				if settings['Misc']['AutoMount'] then
					if Workspace.Characters[player.Name]:FindFirstChild('FakeChar') == nil then
						BINDABLE.ToggleMount:Fire()
					end
				end
			end
		end))

		local Misc = Tabs['Main']:AddRightGroupbox('Misc')
		
		Misc:AddLabel('Auto Farm Keybind'):AddKeyPicker('farmKeybind', {
			Default = settings['Keybinds']['AutoFarm'],
			NoUI = true,
			Text = 'Auto Farm Keybind',

			Callback = function(value)
				Toggles['autoFarmAll']:SetValue(value)
				SaveConfig()
			end,

			ChangedCallback = function(value)
				settings['Keybinds']['AutoFarm'] = Options.farmKeybind.Value
				SaveConfig()
			end
		})

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

		Library.ToggleKeybind = Options.MenuKeybind

		-- // DUNGEON TAB
		local Dungeon = Tabs['Dungeon']:AddLeftGroupbox('Auto Dungeon')

		Dungeon:AddToggle('autoDungeon', {
			Text = 'Auto Do Dungeon',
			Default = settings['Dungeon']['Enabled'],
			Tooltip = 'Auto do dungeon',

			Callback = function(value)
				settings['Dungeon']['Enabled'] = value
				SaveConfig()
			end
		})

		Dungeon:AddToggle('autoDungeonTeams', {
			Text = 'Equip Teams',
			Default = settings['Dungeon']['EnableTeams'],
			Tooltip = 'Auto equip dungeon teams',

			Callback = function(value)
				settings['Dungeon']['EnableTeams'] = value
				SaveConfig()
			end
		})

		local AutoTower = Tabs['Dungeon']:AddRightGroupbox('Infinity Tower')

		AutoTower:AddToggle('enableAutoTower', {
			Text = 'Auto Tower',
			Default = settings['AutoTower']['Enabled'],
			Tooltip = 'Enable Auto Tower',

			Callback = function(value)
				settings['AutoTower']['Enabled'] = value
				SaveConfig()
			end
		})

		AutoTower:AddToggle('equipTeamsOnTower', {
			Text = 'Equip Teams',
			Default = settings['AutoTower']['EnableTeams'],
			Tooltip = 'Auto Equip Teams',

			Callback = function(value)
				settings['AutoTower']['EnableTeams'] = value
				SaveConfig()
			end
		})

		do
			-- // INFO UPDATES
			task.spawn(function()
				while task.wait(1) and not Library.Unloaded do
					local opens = tostring(PlayerGui.MainGui.Hatch.Buttons.Open.Price.Text):match('(%d+)')
					MAX_SUMMON = opens
				end
			end)

			function handleAutoInfinityTower(enemies, enemy)
				if Library.Unloaded then return end
				if player.World.Value ~= "InfinityTower" then return end

				character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame

				movePetsToPlayer()
				task.wait()

				local uids
				local conn
				local debounce = false
				local IS_CHEST = string.find(string.lower(enemy.Name), 'chest') ~= nil

				if settings['AutoTower']['EnableTeams'] then
					if IS_CHEST then
						for teamName, teamButton in pairs(playerTeams) do
							if teamName == settings['Teams']['AutoFarmChests'] then
								for i, button in pairs(getconnections(teamButton.Activated)) do
									if i == 1 then
										if currentlyEquippedTeam ~= settings['Teams']['AutoFarmChests'] then
											currentlyEquippedTeam = settings['Teams']['AutoFarmChests']
											button:Fire()
										end
									end
								end
							end
						end
					else
						for teamName, teamButton in pairs(playerTeams) do
							if teamName == settings['Teams']['AutoFarmAll'] then
								for i, button in pairs(getconnections(teamButton.Activated)) do
									if i == 1 then
										if currentlyEquippedTeam ~= settings['Teams']['AutoFarmAll'] then
											currentlyEquippedTeam = settings['Teams']['AutoFarmAll']
											button:Fire()
										end
									end
								end
							end
						end
					end

					repeat
						if enemy:FindFirstChild('Attackers') then
							sendPet(enemy)
						end

						task.wait()
					until Library.Unloaded
					or player.World.Value ~= 'InfinityTower'
					or enemy:FindFirstChild('HumanoidRootPart') == nil
					or enemy:FindFirstChild("Attackers") == nil
					or not settings['AutoTower']['Enabled']
					or #enemies:GetChildre() == 0
					or not enemy:IsDescendantOf(workspace)

					retreat()
				end
			end

			-- // INFINITY TOWER FARM
			task.spawn(function()
				while task.wait() and not Library.Unloaded do
					if settings['AutoTower']['Enabled'] and player.World.Value == 'InfinityTower' then
						if infTowerTimer.Text ~= '00:00' and player.World.Value == 'InfinityTower' then
							local enemies = Workspace.Worlds['InfinityTower'].Enemies
							--local tab = enemies:GetChildren()
							--local floorNumber = tonumber(infTowerFloorNumberText.Text)

							for _, enemy in ipairs(enemies:GetChildren()) do
								pcall(function()
									character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame
									movePetsToPlayer()
			
									repeat
										if enemy:FindFirstChild('Attackers') then
											if settings['AutoFarm']['AttackAll'] then
												task.wait(0.1)
											else
												if settings['AutoTower']['EnableTeams'] then
													if enemy.Name == 'Chest' then
														for teamName, teamButton in pairs(playerTeams) do
															if teamName == settings['Teams']['AutoFarmChests'] then
																for i, button in pairs(getconnections(teamButton.Activated)) do
																	if i == 1 then
																		if currentlyEquippedTeam ~= settings['Teams']['AutoFarmChests'] then
																			currentlyEquippedTeam = settings['Teams']['AutoFarmChests']
																			button:Fire()
																		end
																	end
																end
															end
														end
													else
														for teamName, teamButton in pairs(playerTeams) do
															if teamName == settings['Teams']['AutoFarmAll'] then
																for i, button in pairs(getconnections(teamButton.Activated)) do
																	if i == 1 then
																		if currentlyEquippedTeam ~= settings['Teams']['AutoFarmAll'] then
																			currentlyEquippedTeam = settings['Teams']['AutoFarmAll']
																			button:Fire()
																		end
																	end
																end
															end
														end
													end
			
													BINDABLE.SendPet:Fire(enemy, true)
												else
													BINDABLE.SendPet:Fire(enemy, true)
												end
											end
										end
										task.wait()
									until Library.Unloaded
									or enemy:FindFirstChild('HumanoidRootPart') == nil
									or enemy:FindFirstChild('Health') == nil
									or enemy:FindFirstChild('Attackers') == nil
									or player.World.Value ~= 'Dungeon'
									or not settings['Dungeon']['Enabled']
									or enemy.Health.Value <= 0
										
									retreat()
								end)
							end
							--[[
							if #tab > 0 then
								for _, enemy in ipairs(tab) do
									local expression = not enemy:IsDescendantOf(workspace) or player.World.Value ~= "InfinityTower"

									if not expression then
										pcall(function()
											handleAutoInfinityTower(enemies, enemy)
										end)
									end
								end
							end
							]]--
						end
					end
				end
			end)

			-- // AUTO INFINITY TOWER TP
			task.spawn(function()
				while task.wait() and not Library.Unloaded do
					local shouldStart = false

					if settings['AutoTower']['Enabled'] and infinityTowerTime.Text == '00:45' then
						shouldStart = true
						CURRENT_TRIAL = 'INFINITY'
						
						REMOTE.AttemptTravel:InvokeServer('Tower')
						task.wait(0.5)
						character.HumanoidRootPart.CFrame = Workspace.Worlds['Tower'].Spawns.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
						task.wait(0.5)
						
						local infTowerButton1 = PlayerGui.MainGui.InfinityTowerTransport.Main.Yes
						local infTowerButton2 = PlayerGui.MainGui.InfinityTowerTeleport.Main.Yes

						if minute == '24' or minute == '25' then
							for _, v in pairs(getconnections(infTowerButton2.Activated)) do
								if _ == 1 then
									v:Fire()

									repeat
										task.wait(3)

										if settings['AutoTower']['EnableTeams'] and tostring(settings['Teams']['AutoFarmAll']) ~= '0' then
											for teamName, teamButton in pairs(playerTeams) do
												for i, button in pairs(getconnections(teamButton.Activated)) do
													if i == 1 then
														if currentlyEquippedTeam ~= settings['Teams']['AutoFarmAll'] then
															unequipPets()
															currentlyEquippedTeam = settings['Teams']['AutoFarmAll']
															button:Fire()
															task.wait(0.1)
														end
													end
												end
											end
										end
									until minute == '25' or Library.Unloaded or not settings['AutoTower']['Enabled']
								end
							end
						end
					end
				end
			end)

			-- // AUTO INFINITY TOWER RETURN
			--[[
			task.spawn(function()
				while task.wait() and not Library.Unloaded do
					if player.World.Value == 'InfinityTower' then
						if (infTowerTimer.Text == '00:01') or (CURRENT_TRIAL == 'INFINITY' and stopTrial and tonumber(infTowerFloorNumberText.Text) == settings['AutoTower']['RoomToLeave'])) then
							pcall(function()
								infTowerTimer.Text = '00:00'
								infTowerFloorNumberText.Text = '0'
								CURRENT_TRIAL = ''

								table.clear(sentDebounce)
								tp(settings['AutoRaid']['BackWorld'], stringToCFrame(settings['AutoRaid']['BackPosition']))
								task.wait(1)
							end)
						end
					end
				end
			end)
			]]--

			-- // AUTO DUNGEON
			task.spawn(function()
				while task.wait() and not Library.Unloaded do
					if settings['Dungeon']['Enabled'] and player.World.Value == 'Dungeon' then
						local dungeonWorld = Workspace.Worlds['Dungeon']
						local dungeonEnemies = dungeonWorld.Enemies
						local dungeonMap = dungeonWorld.Map.Model
						local dungeonRooms = dungeonMap:GetChildren()

						if #dungeonEnemies:GetChildren() == 0 then
							for _, room in ipairs(dungeonRooms) do
								if room:FindFirstChild('ConfirmPart') and room.ConfirmPart:FindFirstChild('ProximityPrompt') then
									repeat
										character.HumanoidRootPart.CFrame = room.ConfirmPart.CFrame + Vector3.new(0, 0, 5)
										task.wait()

										pcall(function()
											fireproximityprompt(room.ConfirmPart.ProximityPrompt)
										end)

										task.wait(1)
									until Library.Unloaded
									or not room:FindFirstChild('ConfirmPart')
									or not room:FindFirstChild('ConfirmPart'):FindFirstChild('ProximityPrompt')
									or not settings['Dungeon']['Enabled']
									or player.World.Value ~= 'Dungeon'
									or #dungeonEnemies:GetChildren() ~= 0
								end

								for key, roomItem in ipairs(room:GetDescendants()) do
									if roomItem.Name == 'DungeonRoomDoorRemotePrompt' and roomItem:IsA('ProximityPrompt') then
										character.HumanoidRootPart.CFrame = roomItem.Parent.CFrame

										repeat
											pcall(function()
												fireproximityprompt(roomItem)
											end)

											task.wait(1)
										until Library.Unloaded
										or not settings['Dungeon']['Enabled']
										or player.World.Value ~= 'Dungeon'
										or not roomItem
										or #dungeonEnemies:GetChildren() ~= 0
									end
								end
							end
						else
							for _, enemy in ipairs(dungeonEnemies:GetChildren()) do
								pcall(function()
									character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame
									movePetsToPlayer()

									repeat
										if enemy:FindFirstChild('Attackers') then
											if settings['AutoFarm']['AttackAll'] then
												task.wait(0.1)
											else
												if settings['Dungeon']['EnableTeams'] then
													if enemy.Name == 'Chest' then
														for teamName, teamButton in pairs(playerTeams) do
															if teamName == settings['Teams']['AutoFarmChests'] then
																for i, button in pairs(getconnections(teamButton.Activated)) do
																	if i == 1 then
																		if currentlyEquippedTeam ~= settings['Teams']['AutoFarmChests'] then
																			currentlyEquippedTeam = settings['Teams']['AutoFarmChests']
																			button:Fire()
																		end
																	end
																end
															end
														end
													else
														for teamName, teamButton in pairs(playerTeams) do
															if teamName == settings['Teams']['AutoFarmAll'] then
																for i, button in pairs(getconnections(teamButton.Activated)) do
																	if i == 1 then
																		if currentlyEquippedTeam ~= settings['Teams']['AutoFarmAll'] then
																			currentlyEquippedTeam = settings['Teams']['AutoFarmAll']
																			button:Fire()
																		end
																	end
																end
															end
														end
													end

													BINDABLE.SendPet:Fire(enemy, true)
												else
													BINDABLE.SendPet:Fire(enemy, true)
												end
											end
										end
										task.wait()
									until Library.Unloaded
									or enemy:FindFirstChild('HumanoidRootPart') == nil
									or enemy:FindFirstChild('Health') == nil
									or enemy:FindFirstChild('Attackers') == nil
									or player.World.Value ~= 'Dungeon'
									or not settings['Dungeon']['Enabled']
									or enemy.Health.Value <= 0
										
									retreat()
								end)
							end
						end
					end
				end
			end)

			-- // AUTORAID
			task.spawn(function()
				while task.wait() and not Library.Unloaded do
					if settings['AutoRaid']['Enabled'] and player.World.Value == 'Raid' then
						local raidData = Workspace.Worlds['Raid'].RaidData
						local enemies = Workspace.Worlds['Raid'].Enemies

						for _, enemy in ipairs(enemies:GetChildren()) do
							if raidData.Enemies.Value == 0 and raidData.Forcefield.Value == false and enemy.Name == raidData.BossId.Value then
								pcall(function()
									character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame
									movePetsToPlayer()

									repeat
										if enemy:FindFirstChild('Attackers') then
											if settings['AutoFarm']['AttackAll'] then
												task.wait(0.1)
											else
												BINDABLE.SendPet:Fire(enemy, true)
											end
										end
										task.wait()
									until Library.Unloaded
									or enemy:FindFirstChild('HumanoidRootPart') == nil
									or enemy:FindFirstChild('Health') == nil
									or enemy:FindFirstChild('Attackers') == nil
									or player.World.Value ~= 'Raid'
									or not settings['AutoRaid']['Enabled']
									or raidData.Enemies.Value == 0
									or enemy.Health.Value <= 0

									retreat()
								end)
							elseif raidData.Enemies.Value ~= 0 and raidData.Forcefield.Value == true and enemy.Name ~= raidData.BossId.Value then
								pcall(function()
									character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame
									movePetsToPlayer()

									repeat
										if enemy:FindFirstChild('Attackers') then
											if settings['AutoFarm']['AttackAll'] then
												task.wait(0.1)
											else
												BINDABLE.SendPet:Fire(enemy, true)
											end
										end
										task.wait()
									until Library.Unloaded
									or enemy:FindFirstChild('HumanoidRootPart') == nil
									or enemy:FindFirstChild('Health') == nil
									or enemy:FindFirstChild('Attackers') == nil
									or player.World.Value ~= 'Raid'
									or not settings['AutoRaid']['Enabled']
									or raidData.Enemies.Value == 0
									or enemy.Health.Value <= 0

									retreat()
								end)
							end
						end
					end

					task.wait()
				end
			end)
			
			task.spawn(function()
				while not Library.Unloaded do
					minute = os.date("%M")
					task.wait(0.1)
				end
			end)

			-- // AUTORAID TP
			task.spawn(function()
				while not Library.Unloaded do
					if settings['AutoRaid']['Enabled'] then
						local currentRaidMap = Workspace.Worlds['Raid'].Map:FindFirstChildOfClass('Model')
						if currentRaidMap then
							local worldName = Workspace.Worlds['Raid'].RaidData.CurrentWorld.Value
							
							if settings['AutoRaid']['ToggleAllRaids'] then
								if minute == '14' or minute == '44' then
									for _, v in pairs(getconnections(yesButton.Activated)) do
										if _ == 1 then
											v:Fire()

											repeat
												task.wait(1)
		
												if settings['AutoRaid']['EnableTeams'] and tostring(settings['Teams']['RaidInside']) ~= '0' then
													for teamName, teamButton in pairs(playerTeams) do
														if teamName == settings['Teams']['RaidInside'] then
															for i, button in pairs(getconnections(teamButton.Activated)) do
																if i == 1 then
																	if currentlyEquippedTeam ~= settings['Teams']['RaidInside'] then
																		currentlyEquippedTeam = settings['Teams']['RaidInside']
																		button:Fire()
																	end
																end
															end
														end
													end
												end
											until minute == '15' or minute =='45' or Library.Unloaded or not settings['AutoRaid']['Enabled']
											--until min == '15' or min =='45' or Library.Unloaded or not raidWorlds[worldName]
										end
									end
								else
									repeat
										task.wait()
										minute = os.date("%M")
									until minute == '14' or minute =='44' or Library.Unloaded or not settings['AutoRaid']['Enabled']
									--until min == '14' or min =='44' or Library.Unloaded or not raidWorlds[worldName]
								end
							end
						end
					end

					task.wait()
				end
			end)

			-- // RETURN FROM RAID
			task.spawn(function()
				while not Library.Unloaded do
					if player.World.Value == 'Raid' then
						local enemies = Workspace.Worlds['Raid'].Enemies:GetChildren()

						if PlayerGui.RaidGui.RaidResults.Visible == true then
							for _, v in pairs(getconnections(confirmRaidButton.Activated)) do
								if _ == 1 then
									v:Fire()

									repeat
										pcall(function()
											tp(settings['AutoRaid']['BackWorld'], stringToCFrame(settings['AutoRaid']['BackPosition']))
											task.wait(1)

											if settings['AutoRaid']['EnableTeams'] and tostring(settings['Teams']['RaidAfter']) ~= '0' then
												for teamName, teamButton in pairs(playerTeams) do
													if teamName == settings['Teams']['RaidAfter'] then
														for i, button in pairs(getconnections(teamButton.Activated)) do
															if i == 1 then
																if currentlyEquippedTeam ~= settings['Teams']['RaidAfter'] then
																	currentlyEquippedTeam = settings['Teams']['RaidAfter']
																	button:Fire()
																end
															end
														end
													end
												end
											end
										end)
									until PlayerGui.RaidGui.RaidResults.Visible == false or Library.Unloaded or not settings['AutoRaid']['Enabled']
								end
							end
						end
					end

					task.wait()
				end
			end)

			task.spawn(function()
				while task.wait(0.05) and not Library.Unloaded do
					if settings['AutoFarm']['AttackAll'] then
						if settings['Teams']['EnableChestTeam'] or settings['Teams']['EnableFarmTeam'] then
							local equippedPetsNumber = tostring(PlayerGui.MainGui.Pets.Main.Equipped.Amount.Text)

							local s1, s2 = equippedPetsNumber:match("(%d+)/(%d+)")
							local n1, n2 = tonumber(s1), tonumber(s2)

							if n1 ~= n2 then
								unequipPets()
							end
						end
					end
				end
			end)

			-- // AUTOFARM ALL
			task.spawn(function()
				while task.wait(0.05) and not Library.Unloaded do
					if settings['AutoFarm']['AttackAll'] then
						local Closest, ClosestDistance = findNearestEnemy()
						if Closest then
							if lastClosest == nil then lastClosest = Closest end

							if lastClosest == Closest then
								if Closest.Name == 'Chest' and settings['Teams']['EnableChestTeam'] then
									for teamName, teamButton in pairs(playerTeams) do
										if teamName == settings['Teams']['AutoFarmChests'] then
											for i, button in pairs(getconnections(teamButton.Activated)) do
												if i == 1 then
													if currentlyEquippedTeam ~= settings['Teams']['AutoFarmChests'] then
														unequipPets()
														currentlyEquippedTeam = settings['Teams']['AutoFarmChests']
														button:Fire()
														task.wait(0.1)
													else
														BINDABLE.SendPet:Fire(Closest, true)
													end
												end
											end
										end
									end
								elseif Closest.Name ~= 'Chest' and settings['Teams']['EnableFarmTeam'] then
									for teamName, teamButton in pairs(playerTeams) do
										if teamName == settings['Teams']['AutoFarmAll'] then
											for i, button in pairs(getconnections(teamButton.Activated)) do
												if i == 1 then
													if currentlyEquippedTeam ~= settings['Teams']['AutoFarmAll'] then
														unequipPets()
														currentlyEquippedTeam = settings['Teams']['AutoFarmAll']
														button:Fire()
														task.wait(0.1)
													else
														BINDABLE.SendPet:Fire(Closest, true)
													end
												end
											end
										end
									end
								else
									BINDABLE.SendPet:Fire(Closest, true)
								end
							else
								VirtualInputManager:SendKeyEvent(true, 'R', false, nil)
								task.wait(0.005)
								VirtualInputManager:SendKeyEvent(false, 'R', false, nil)
								lastClosest = Closest

								if Closest.Name == 'Chest' and settings['Teams']['EnableChestTeam'] then
									for teamName, teamButton in pairs(playerTeams) do
										if teamName == settings['Teams']['AutoFarmChests'] then
											for i, button in pairs(getconnections(teamButton.Activated)) do
												if i == 1 then
													if currentlyEquippedTeam ~= settings['Teams']['AutoFarmChests'] then
														currentlyEquippedTeam = settings['Teams']['AutoFarmChests']
														button:Fire()
														task.wait(1)
													end

													BINDABLE.SendPet:Fire(Closest, true)
												end
											end
										end
									end
								elseif Closest.Name ~= 'Chest' and settings['Teams']['EnableFarmTeam'] then
									for teamName, teamButton in pairs(playerTeams) do
										if teamName == settings['Teams']['AutoFarmAll'] then
											for i, button in pairs(getconnections(teamButton.Activated)) do
												if i == 1 then
													if currentlyEquippedTeam ~= settings['Teams']['AutoFarmAll'] then
														currentlyEquippedTeam = settings['Teams']['AutoFarmAll']
														button:Fire()
														task.wait(1)
													end

													BINDABLE.SendPet:Fire(Closest, true)
												end
											end
										end
									end
								else
									BINDABLE.SendPet:Fire(Closest, true)
								end
								--BINDABLE.SendPet:Fire(Closest, true)
							end
						else
							VirtualInputManager:SendKeyEvent(true, 'R', false, nil)
							task.wait(0.005)
							VirtualInputManager:SendKeyEvent(false, 'R', false, nil)
						end
					end
				end
			end)

			-- // AUTO STAR
			task.spawn(function()
				local conn
				conn = RunService.RenderStepped:Connect(function()
					if Library.Unloaded then
						conn:Disconnect()
						conn = nil
						enabledAutoStar = false
						return
					end

					if enabledAutoStar and settings['AutoStar']['SelectedStar'] ~= nil and not table.find(IGNORED_WORLDS, player.World.Value) then
						task.spawn(function()
							if settings['AutoStar']['SelectedStar'] then
								local egg = Workspace.Worlds:FindFirstChild(eggDisplayNameToNameLookUp[settings['AutoStar']['SelectedStar']], true)

								if egg then
									REMOTE.OpenEgg:InvokeServer(egg, MAX_SUMMON)
								end
							end
						end)
					end
				end)
			end)

			-- // AUTO MAX OPEN
			task.spawn(function()
				while not Library.Unloaded do
					if enabledMultiOpen and settings['AutoStar']['SelectedStar'] then
						REMOTE.AttemptMultiOpen:FireServer(eggDisplayNameToNameLookUp[settings['AutoStar']['SelectedStar']])
					end

					task.wait(0.2)
				end

				enabledMultiOpen = false
			end)

			-- // CLICKER DAMAGE
			task.spawn(function()
				while not Library.Unloaded do
					if settings['AutoFarm']['AutoClick'] then
						REMOTE.ClickerDamage:FireServer()
					end

					task.wait(0.05)
				end
			end)

			-- // AUTO COLLECT
			task.spawn(function()
				while not Library.Unloaded do
					if settings['AutoFarm']['AutoCollect'] then
						for _, v in ipairs(Workspace.Effects:GetDescendants()) do
							if v.Name == 'Base' then
								v.CFrame = character.HumanoidRootPart.CFrame
							end
						end
					end

					task.wait()
				end
			end)

			-- // BOOST PET SPEED
			task.spawn(function()
				while not Library.Unloaded do
					if settings['AutoFarm']['BoostPetSpeed'] then
						for _, tab in pairs(passiveStats) do
							if tab.Effects then
								tab.Effects.Speed = 10
							end
						end
					end


					task.wait(1)
				end
			end)

			-- // SKIP ULTIMATE ANIMATION
			task.spawn(function()
				while not Library.Unloaded do
					if settings['AutoFarm']['AutoUltSkip'] then
						for _, pet in ipairs(player.Pets:GetChildren()) do
							task.spawn(function()
								REMOTE.PetAttack:FireServer(pet.Value)
								REMOTE.PetAbility:FireServer(pet.Value)
							end)
						end
					end

					task.wait(0.3)
				end
			end)
		end

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