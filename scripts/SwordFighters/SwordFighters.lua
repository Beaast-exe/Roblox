local HttpService = game:GetService("HttpService")

------
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Sword Fighters Simulator', Center = true, AutoShow = true })

local settings = {
	autoRelicPower = false,
	relicPower = "No Relic",
	autoRelicDamage = false,
	relicDamage = "No Relic"
}

local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character;
local HumanoidRootPart = Character.HumanoidRootPart;
local PlayerGui = LocalPlayer.PlayerGui;
local Workspace = game:GetService("Workspace");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local PlayerInv = PlayerGui.Inventory.Background.ImageFrame.Window.Frames.ItemsFrame.ItemsHolder.ItemsScrolling

local Tabs = {
	["Main"] = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

local AutoRelics = Tabs["Main"]:AddLeftGroupbox('Auto Relics')

AutoRelics:AddToggle('autoRelicPower', {
	Text = 'Auto Relic Power',
	Default = false
})

AutoRelics:AddToggle('autoRelicDamage', {
	Text = 'Auto Relic Damage',
	Default = false
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

Toggles["autoRelicPower"]:OnChanged(function()
	--print(Toggles["autoRelicPower"].Value)
	settings.autoRelicPower = Toggles["autoRelicPower"].Value
end)

AutoRelics:AddButton('Select Relic Power', function()
	if getEquippedRelic() == "No Relic" then
		Library:Notify("Equip a relic before doing this")
	else
		Library:Notify("Equipped Relic: " .. getEquippedRelic(), 5)
		settings.relicPower = getEquippedRelic()
	end
end)

Toggles["autoRelicDamage"]:OnChanged(function()
	--print(Toggles["autoRelicDamage"].Value)
	settings.autoRelicDamage = Toggles["autoRelicDamage"].Value
end)

AutoRelics:AddButton('Select Relic Damage', function()
	if getEquippedRelic() == "No Relic" then
		Library:Notify("Equip a relic before doing this")
	else
		Library:Notify("Equipped Relic: " .. getEquippedRelic(), 5)
		settings.relicDamage = getEquippedRelic()
	end
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
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
--SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
--SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
--SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('BeaastHub')
--SaveManager:SetFolder('BeaastHub/SwordFighters')

-- Builds our config menu on the right side of our tab
--SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
--ThemeManager:ApplyToTab(Tabs['UI Settings'])
local settingsRightBox = Tabs["UI Settings"]:AddRightGroupbox("Themes")
ThemeManager:ApplyToGroupbox(settingsRightBox)

-- You can use the SaveManager:LoadAutoloadConfig() to load a con