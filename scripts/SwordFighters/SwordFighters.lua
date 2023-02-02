local HttpService = game:GetService("HttpService")

------
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Sword Fighters Simulator', Center = true, AutoShow = true })

--// Variables
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character;
local HumanoidRootPart = Character.HumanoidRootPart;
local PlayerGui = LocalPlayer.PlayerGui;
local Workspace = game:GetService("Workspace");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local VirtualInputManager = game:GetService("VirtualInputManager")
local ClickRemotes = ReplicatedStorage.Packages.Knit.Services.ClickService.RF;
local AscendRemotes = ReplicatedStorage.Packages.Knit.Services.AscendService.RF;
local PetRemotes = ReplicatedStorage.Packages.Knit.Services.PetInvService.RF;
local SwordRemotes = ReplicatedStorage.Packages.Knit.Services.WeaponInvService.RF;
local EggRemotes = ReplicatedStorage.Packages.Knit.Services.EggService.RF;
local QuestRemotes = ReplicatedStorage.Packages.Knit.Services.QuestService.RF;
local ForgeRemotes = ReplicatedStorage.Packages.Knit.Services.ForgeService.RF;
local DismantleRemotes = ReplicatedStorage.Packages.Knit.Services.PetLevelingService.RF;
local DungeonShopRemotes = ReplicatedStorage.Packages.Knit.Services.LimitedShopsService.RF;
local Npcs = Workspace.Live.NPCs.Client;
local Pickups = Workspace.Live.Pickups;
local AscendProgress = PlayerGui.Ascend.Background.ImageFrame.Window.Progress.Progress;
local Ascend_Needed = AscendProgress.BG;
local Ascend_Current = AscendProgress.Container.Bar;
local StopButton = PlayerGui.EggEffect.Background.Stop;
local WeaponInv = PlayerGui.WeaponInv.Background.ImageFrame.Window.WeaponHolder.WeaponScrolling;
local PetInv = PlayerGui.PetInv.Background.ImageFrame.Window.PetHolder.PetScrolling;
local PlayerInv = PlayerGui.Inventory.Background.ImageFrame.Window.Frames.ItemsFrame.ItemsHolder.ItemsScrolling
local FloatingEggs = Workspace.Live.FloatingEggs;
-- local Lobby = Workspace.Resources.Gamemodes.DungeonLobby;
local ChatFrame = PlayerGui.Chat.Frame.ChatChannelParentFrame;
local Chat = ChatFrame["Frame_MessageLogDisplay"].Scroller;

local saveFolderName = "BeaastHub"
local saveFileName = "SwordFighters_" .. LocalPlayer.Name .. ".json"
local saveFile = saveFolderName .. "/" .. saveFileName

local defaultSettings = {
	autoFarm = {
		enabled = false
	},
	autoSwing = false,
	autoKillNpc = false,
	autoKillNpcSpecific = false,
	autoRelicPower = false,
	relicPower = "No Relic",
	autoRelicDamage = false,
	relicDamage = "No Relic"
}

if not pcall(function() readfile(saveFile) end) then writefile(saveFile, HttpService:JSONEncode(defaultSettings)) end
local settings = HttpService:JSONDecode(readfile(saveFile))

local function SaveConfig()
	writefile(saveFile, HttpService:JSONEncode(settings))
end

local Tabs = {
	["Main"] = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

local GAME_CONSTANTS = {
	Egg_Table = {
        ["Weak Egg"] = "Egg 1",
        ["Strong Egg"] = "Egg 2",
        ["Paradise Egg"] = "Egg 3",
        ["Bamboo Egg"] = "Egg 5",
        ["Frozen Egg"] = "Egg 7",
        ["Soft Egg"] = "Egg 9",
        ["Lava Egg"] = "Egg 11",
        ["Mummified Egg"] = "Egg 13",
        ["Lost Egg"] = "Egg 15",
        ["Ore Egg"] = "Egg 17",
        ["Leaf Egg"] = "Egg 19",
        ["Aquatic Egg"] = "Egg 21",
        ["Holy Egg"] = "Egg 23",
        ["Volcano Egg"] = "Egg 25",
        ["Canyon Egg"] = "Egg 26"
    },

    Game_Areas = {
        ["Dark Forest"] = CFrame.new(326, 150, -0),
        ["Skull Cove"] = CFrame.new(2234, 149, -573),
        ["Demon Hill"] = CFrame.new(3948, 150, -384),
        ["Polar Tundra"] = CFrame.new(5965, 150, -538),
        ["Aether City"] = CFrame.new(8952, 609, -515),
        ["Underworld"] = CFrame.new(13588, 154, 86),
        ["Ancient Sands"] = CFrame.new(533, 150, -2874),
        ["Enchanted Woods"] = CFrame.new(4034, 148, -4356),
        ["Mystic Mines"] = CFrame.new(7191, -113, -4646),
        ["Sacred Land"] = CFrame.new(9397, 150, -4349),
        ["Marine Castle"] = CFrame.new(13202, 167, -3421),
        ["High Havens"] = CFrame.new(16389, 308, -3530),
        ["Cracked Canyons"] = CFrame.new(20501, 194, -3591)
    },

    Game_Npcs = {
        "Dark Commander",
        "Adurite Warden",
        "King Pharaoh",
        "Orc",
        "Skeleton",
        "Necromancer",
        "Blood Zombie",
        "Skye Knight",
        "Blood Knight",
        "Mummy",
        "Monk",
        "Imp",
        "Pirate Thief",
        "Purple Dragon",
        "Ninja",
        "Santa Claus",
        "Ice King",
        "Penguin",
        "Pirate Admiral",
        "Warlock",
        "Guardian",
        "Desert Beast",
        "Spirit Lord",
        "Red Devil",
        "Marine",
        "Mutant Insect",
        "Paladin",
        "Samurai Master",
        "The Grinch",
        "Angel",
        "Blood Vampire",
        "Oni",
        "Cyclops",
        "Snow Warrior",
        "Zombie Miner",
        "Demon",
        "Yeti",
        "Pirate Captain",
        "Power Force",
        "Samurai",
        "Royal Warrior",
        "Lost Soul",
        "Lava Golem",
        "Green Insect",
        "Mushy",
        "Brown Insect",
        "Malevolent Spirit",
        "Dark Knight",
        "Satyr",
        "Master Wizard",
        "Golem",
        "Zeus the God",
        "Lost Titan",
        "Elf",
        "Barbarian Pirate",
        "Treasure Chest",
        "Madman",
        "Goblin",
        "Feathered Warrior",
        "Cthulhu",
        "Centaur King",
        "Celestial Gatekeeper",
        "Skywatcher",
        "Stormbringer",
        "Vulcanus Maximus",
        "Lich Spirit",
        "Fallen Star",
        "Demonic Altar",
        "Dune Critter",
        "Reptilian Beast",
        "Sandstone Golem",
        "Scorpion Queen",
        "Haunted Witch",
        "Haunted Reaper",
        "Nightstalker",
        "Forsaken Hunter"
    },

    DungeonShopItems = {
        ["2x Coin Boost"] = 1,
        ["Super Luck Boost"] = 2,
        ["2x Power Boost"] = 3,
        ["Raid Tickets"] = 4,
        ["2x Secret Luck Boost"] = 5
    }
}

local AUTOFARM_FUNCTIONS = {
	hasProperty = function(a, b)
        local c = a[b];
    end,
    
    Closest_NPC = function()
        local Closest = nil;
        local Distance = 9e9;
        
        for i, v in next, Npcs:GetChildren() do
            if v:IsA("Model") then
                local Magnitude = (HumanoidRootPart.Position - v:FindFirstChild("HumanoidRootPart").Position).Magnitude;
    
                if Magnitude < Distance then
                    Closest = v;
                    Distance = Magnitude;
                end
            end
        end
        return Closest;
    end,
    
    Get_Specific_Closest = function()
        local Closest = nil;
        local Distance = 9e9;
        
        for a, b in next, Npcs:GetChildren() do
            if b:IsA("Model") then
                local Npc_Name = b:WaitForChild("HumanoidRootPart"):WaitForChild("NPCTag"):WaitForChild("NameLabel");
                for c, d in next, Game_Npcs do
                    if string.match(d, Npc_Name.Text) == getgenv().NpcToFarm then
                        local Magnitude = (HumanoidRootPart.Position - b.HumanoidRootPart.Position).Magnitude;
                        if Magnitude < Distance then
                            Closest = b;
                            Distance = Magnitude;
                        end
                    end
                end
            end
        end
        return Closest;
    end
}

local AutoFarm = Tabs["Main"]:AddLeftGroupbox('Auto Farm')

AutoFarm:AddToggle('autoSwing', {
	Text = "Auto Swing",
	Default = settings.autoSwing
})

Toggles["autoSwing"]:OnChanged(function()
	settings.autoSwing = Toggles["autoSwing"].Value
	SaveConfig()
end)

AutoFarm:AddToggle('autoKillClosestNpcs', {
	Text = "Auto Farm Closest NPCs",
	Default = settings.autoKillNpc
})

Toggles["autoKillClosestNpcs"]:OnChanged(function()
	settings.autoKillNpc = Toggles["autoKillClosestNpcs"].Value
	SaveConfig()
end)

local AutoRelics = Tabs["Main"]:AddRightGroupbox('Auto Relics')

AutoRelics:AddToggle('autoRelicPower', {
	Text = 'Auto Relic Power',
	Default = settings.autoRelicPower
})

AutoRelics:AddToggle('autoRelicDamage', {
	Text = 'Auto Relic Damage',
	Default = settings.autoRelicDamage
})

local function getEquippedRelic()
	local relicFound = "No Relic"

	for i, v in next, PlayerInv:GetDescendants() do
		if v:IsA("Frame") and v.Parent == PlayerInv then
			if v:FindFirstChild("Frame", true) then
				if v.Frame:FindFirstChild("Equipped", true).Visible == true then
					if v.Frame:FindFirstChild("Lock", true).Visible == true then
						relicFound = v.Name
					end
				end
			end
		end
	end

	return relicFound
end

local function getRelicName(relic: string)
	for i, v in next, PlayerInv:GetDescendants() do
		if v.Parent == PlayerInv and v.Name == relic then
			return v.TextLabel1.Text
		end
	end
end

Toggles["autoRelicPower"]:OnChanged(function()
	settings.autoRelicPower = Toggles["autoRelicPower"].Value
	SaveConfig()
end)

local equippedPowerRelicForLabel = settings.relicPower
if equippedPowerRelicForLabel ~= "No Relic" then equippedPowerRelicForLabel = getRelicName(settings.relicPower) end
local equippedDamageRelicForLabel = settings.relicDamage
if equippedDamageRelicForLabel ~= "No Relic" then equippedDamageRelicForLabel = getRelicName(settings.relicDamage) end

local relicPowerLabel = AutoRelics:AddLabel("Power Relic: " .. equippedPowerRelicForLabel, true)
local relicDamageLabel = AutoRelics:AddLabel("Damage Relic: " .. equippedDamageRelicForLabel, true)

AutoRelics:AddButton('Select Power Relic', function()
	if getEquippedRelic() == "No Relic" then
		Library:Notify("Equip a relic before doing this")
	else
		Library:Notify("Equipped Relic: " .. getRelicName(getEquippedRelic()), 5)
		settings.relicPower = getEquippedRelic()
		relicPowerLabel:SetText("Power Relic: " .. getRelicName(settings.relicPower))
		SaveConfig()
	end
end)

Toggles["autoRelicDamage"]:OnChanged(function()
	settings.autoRelicDamage = Toggles["autoRelicDamage"].Value
	SaveConfig()
end)

AutoRelics:AddButton('Select Damage Relic', function()
	if getEquippedRelic() == "No Relic" then
		Library:Notify("Equip a relic before doing this")
	else
		Library:Notify("Equipped Relic: " .. getRelicName(getEquippedRelic()), 5)
		settings.relicDamage = getEquippedRelic()
		relicDamageLabel:SetText("Damage Relic: " .. getRelicName(settings.relicDamage))
		SaveConfig()
	end
end)

AutoRelics:AddButton('Equip Power Relic', function()
	local equippedRelic = tostring(getEquippedRelic())
	local RelicEquipRemote = game:GetService("ReplicatedStorage").Packages.Knit.Services.RelicInvService.RF.EquipRelic

	if settings.relicDamage == "No Relic" then
		Library:Notify("Select a relic before doing this")
	else
		if equippedRelic == "No Relic" then
			local relicPower = { [1] = settings.relicPower }

			RelicEquipRemote:InvokeServer(unpack(relicPower))
			Library:Notify("Equipped Relic: " .. getRelicName(settings.relicPower), 5)
		else
			local relicPower = { [1] = settings.relicPower }
			local relicEquipped = { [1] = equippedRelic }

			RelicEquipRemote:InvokeServer(unpack(relicEquipped))
			task.wait(1)
			RelicEquipRemote:InvokeServer(unpack(relicPower))
			Library:Notify("Equipped Relic: " .. getRelicName(settings.relicPower), 5)
		end
	end
end)

AutoRelics:AddButton('Equip Damage Relic', function()
	local equippedRelic = tostring(getEquippedRelic())
	local RelicEquipRemote = game:GetService("ReplicatedStorage").Packages.Knit.Services.RelicInvService.RF.EquipRelic


	if settings.relicDamage == "No Relic" then
		Library:Notify("Select a relic before doing this")
	else
		if equippedRelic == "No Relic" then
			local relicDamage = { [1] = settings.relicDamage }

			RelicEquipRemote:InvokeServer(unpack(relicDamage))
			Library:Notify("Equipped Relic: " .. getRelicName(settings.relicDamage), 5)
		else
			local relicDamage = { [1] = settings.relicDamage }
			local relicEquipped = { [1] = equippedRelic }

			RelicEquipRemote:InvokeServer(unpack(relicEquipped))
			task.wait(1)
			RelicEquipRemote:InvokeServer(unpack(relicDamage))
			Library:Notify("Equipped Relic: " .. getRelicName(settings.relicDamage), 5)
		end
	end
end)

task.spawn(function()
	RunService.Heartbeat:Connect(function()
		if settings.autoSwing then
			ClickRemotes.Click:InvokeServer()
		end

		if settings.autoKillNpc and AUTOFARM_FUNCTIONS.Closest_NPC() ~= nil then
			ClickRemotes.Click:InvokeServer(AUTOFARM_FUNCTIONS.Closest_NPC().Name)
		end

		if settings.autoKillNpcSpecific and AUTOFARM_FUNCTIONS.Get_Specific_Closest() ~= nil then
			ClickRemotes.Click:InvokeServer(AUTOFARM_FUNCTIONS.Get_Specific_Closest().Name)
		end
	end)
end)

coroutine.resume(coroutine.create(function()
	while task.wait(1) do
		local StreakTime = PlayerGui.Streak.Background.Frame.TimeLabel.Text
		local equippedRelic = tostring(getEquippedRelic())
		local RelicEquipRemote = game:GetService("ReplicatedStorage").Packages.Knit.Services.RelicInvService.RF.EquipRelic

		if settings.autoRelicPower then
			if StreakTime == "1 Sec" then
				if settings.autoRelicDamage then
					if equippedRelic == "No Relic" then
						local relicDamage = { [1] = settings.relicDamage }
	
						RelicEquipRemote:InvokeServer(unpack(relicDamage))
					elseif equippedRelic == settings.relicPower then
						local relicDamage = { [1] = settings.relicDamage }
						local relicEquipped = { [1] = equippedRelic }
	
						RelicEquipRemote:InvokeServer(unpack(relicEquipped))
						task.wait(1)
						RelicEquipRemote:InvokeServer(unpack(relicDamage))
					end
				end
			else
				if equippedRelic == "No Relic" then
					local relicPower = { [1] = settings.relicPower }

					RelicEquipRemote:InvokeServer(unpack(relicPower))
				elseif equippedRelic == settings.relicDamage then
					local relicPower = { [1] = settings.relicPower }
					local relicEquipped = { [1] = equippedRelic }

					RelicEquipRemote:InvokeServer(unpack(relicEquipped))
					task.wait(1)
					RelicEquipRemote:InvokeServer(unpack(relicPower))
				end
			end
		end
	end
end))

--Library:SetWatermarkVisibility(false)
--Library:SetWatermark('Beaast Hub | SFS')
Library:OnUnload(function()
	print('Unloaded!')
	Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind
--Options.MenuKeybind:OnClick(function()
--    print('Keybind clicked!', Options.MenuKeybind.Value)
--end)

-- Addons:
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('BeaastHub')
local settingsRightBox = Tabs["UI Settings"]:AddRightGroupbox("Themes")
ThemeManager:ApplyToGroupbox(settingsRightBox)