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
		['AutoStar'] = {
			--['Enabled'] = false,
			--['EnabledMultiOpen'] = false,
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

	local playerWorldEnemies = {}
	local playerClosestEnemy = nil
	local playerClosestEnemyDistance = math.huge
	local attackingMob = nil


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

	--To reference the countdown in trial
	function InitializeTrial()
		REMOTE.AttemptTravel:InvokeServer('Tower')
		character.HumanoidRootPart.CFrame = Workspace.Worlds.Tower.Spawns.SpawnLocation.CFrame
		Workspace.Worlds.Tower.Water.CanCollide = true

		task.wait(3)

		REMOTE.AttemptTravel:InvokeServer(WORLD)
		character.HumanoidRootPart.CFrame = playerPos

		local easyTrialTime = Workspace.Worlds.Tower.Door1.Countdown.SurfaceGui.Background.Time
		local mediumTrialTime = Workspace.Worlds.Tower.Door2.Countdown.SurfaceGui.Background.Time
		local hardTrialTime = Workspace.Worlds.Tower.Door3.Countdown.SurfaceGui.Background.Time
		local ultimateTrialTime = Workspace.Worlds.Tower.Door4.Countdown.SurfaceGui.Background.Time

		local towerTime = PlayerGui.MainGui.TowerTimer.Main.Time
		local yesButton = PlayerGui.MainGui.RaidTransport.Main.Yes
		local floorNumberText = PlayerGui.MainGui.TowerTimer.CurrentFloor.Value
	end

	local bstEggs = {}
	local bstEggsTable = {
		["Z Star"] = "GokuEgg", ["Ninja Star"] = "NarutoEgg", ["Crazy Star"] = "JojoEgg", ["Pirate Star"] = "OnePieceEgg", ["Hero Star"] = "MHAEgg", ["Attack Star"] = "AOTEgg", ["Demon Star"] = "DemonEgg", ["Ghoul Star"] = "GhoulEgg", ["Hunter Star"] = "HxHEgg", ["Swordsman Star"] = "SAOEgg", ["Empty Star"] = "BleachEgg", ["Cursed Star"] = "JJKEgg", ["Power Star"] = "OPMEgg", ["Sins Star"] = "7DSEgg", ["Destiny Star"] =" FateEgg", ["Luck Star"] = "BCEgg", ["Alchemy Star"] = "FMAEgg", ["Slime Star"] = "SlimeEgg", ["Flame Star"] = "FireForceEgg", ["Champion Star"] = "RoREgg", ["Wizard Star"] = "FairyTailEgg", ["Icy Star"] = "ReZeroEgg", ["Saw Star"] = "ChainsawManEgg", ["Esper Star"] = "Mob100Egg", ["Violent Star"] = "DorohedoroEgg", ["Young Ninja Star"] = "BorutoEgg", ["Gangster Star"] = "TokyoRevengerEgg", ["Inmate Star"] = "JJBAStoneOceanEgg", ["Card Star"] = "YugiohEgg", ["Academy Star"] = "KLKEgg", ["Struggler Star"] = "BerserkEgg", ["Rising Star"] = "ShieldHeroEgg", ["Lord Star"] = "OverlordEgg", ["Soul Star"] = "SoulEaterEgg", ["Knight Star"] = "CodeGeassEgg", ["Abyss Star"] = "MadeInAbyssEgg", ["Blessed Star"] = "HellsParadiseEgg", ["Wanzo Star"] = "OPWanoEgg", ["Summer Star"] = "SummerEgg"
	}

	local enemiesRange = 150

	-- // Functions
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
			[39] = "Summer Star"
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
							ClosestDistance = nil
						else
							Closest = targetEnemy
							ClosestDistance = Distance
						end
					end
				end
			end

			if Closest == nil then ClosestDistance = nil end

			print(Closest)
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
		--InitializeTrial()
		--task.wait(1)
		GenEggStats()
		task.wait(1)
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

	local AutoStar = Tabs['Main']:AddLeftGroupbox('Auto Star')

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

	local Keybinds = Tabs['Main']:AddRightGroupbox('Keybinds')
	
	Keybinds:AddLabel('Auto Farm Keybind'):AddKeyPicker('farmKeybind', {
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

	Library.ToggleKeybind = Options.MenuKeybind

	coroutine.resume(coroutine.create(function()
		while task.wait(5) do
			local opens = tostring(PlayerGui.MainGui.Hatch.Buttons.Open.Price.Text):match('(%d+)')
			MAX_SUMMON = opens
		end
	end))

	do
		-- // AUTOFARM ALL
		task.spawn(function()
			while task.wait(0.05) and not Library.Unloaded do
				if settings['AutoFarm']['AttackAll'] then
					local Closest, ClosestDistance = findNearestEnemy()
					if Closest then
						if lastClosest == nil then lastClosest = Closest end

						if lastClosest == Closest then
							BINDABLE.SendPet:Fire(Closest, true)
						else
							VirtualInputManager:SendKeyEvent(true, 'R', false, nil)
							task.wait(0.005)
							VirtualInputManager:SendKeyEvent(false, 'R', false, nil)
							BINDABLE.SendPet:Fire(Closest, true)
							lastClosest = Closest
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