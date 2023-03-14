local StartTick = tick()
repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local request = http_request or request or HttpPost or syn.request or http.request
------
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Anime Star Simulator', Center = true, AutoShow = true })

local saveFolderName = "BeaastHub"
local saveFileName = "AnimeStar_" .. LocalPlayer.Name .. ".json"
local saveFile = saveFolderName .. "/" .. saveFileName

local defaultSettings = {
	autoClick = false,
	removeClickLimit = false,
	autoSuper = false,
	autoUltra = false,
	watermark = false,
	selectedRebirth = "10.00 Chi",
	autoRebirth = false,
	autoBestGemsBeforeRebirth = false,
	autoPractice = false
}

local defaultClickLimit = LocalPlayer.Tapping.Value

if not pcall(function() readfile(saveFile) end) then
	if not isfolder(saveFolderName) then makefolder(saveFolderName) end
	writefile(saveFile, HttpService:JSONEncode(defaultSettings))
end
local settings = HttpService:JSONDecode(readfile(saveFile))

local function SaveConfig()
	writefile(saveFile, HttpService:JSONEncode(settings))
end

local Tabs = {
	["Main"] = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

local Misc = Tabs["Main"]:AddRightGroupbox('Misc')

Misc:AddToggle('autoClick', {
	Text = "Auto Chi",
	Default = settings.autoClick,
	Tooltip = "Auto click to farm Chi"
})

Toggles["autoClick"]:OnChanged(function()
	settings.autoClick = Toggles["autoClick"].Value
	SaveConfig()
end)

Misc:AddToggle('removeClickLimit', {
	Text = "Remove Click Limit",
	Default = settings.removeClickLimit,
	Tooltip = "Remove click limit (Use In-Game Auto Clicker)"
})

Toggles["removeClickLimit"]:OnChanged(function()
	settings.removeClickLimit = Toggles["removeClickLimit"].Value
	SaveConfig()

	if settings.removeClickLimit then
		LocalPlayer.Tapping.Value = 0.1
	else
		LocalPlayer.Tapping.Value = defaultClickLimit
	end
end)

coroutine.resume(coroutine.create(function()
	while task.wait(0.2) do
		if settings.autoClick then
			pcall(function()		
				RemoteEvent:FireServer({ [1] = { [1] = "\5", [2] = "Tapping" } })
			end)
		end
	end
end))

Misc:AddToggle('autoSuper', {
	Text = "Auto Super",
	Default = settings.autoSuper,
	Tooltip = "Auto click to farm Chi"
})

Toggles["autoSuper"]:OnChanged(function()
	settings.autoSuper = Toggles["autoSuper"].Value
	SaveConfig()
end)

coroutine.resume(coroutine.create(function()
	while task.wait(1) do
		if settings.autoSuper then
			pcall(function()
				if PlayerGui.Interface.BottomButtons.Super.Info.Text == "READY!" then
					RemoteEvent:FireServer({ [1] = { [1] = "\5", [2] = "Super" } })
				end
			end)
		end
	end
end))

Misc:AddToggle('autoUltra', {
	Text = "Auto Ultra",
	Default = settings.autoUltra,
	Tooltip = "Auto click to farm Chi"
})

Toggles["autoUltra"]:OnChanged(function()
	settings.autoUltra = Toggles["autoUltra"].Value
	SaveConfig()
end)

coroutine.resume(coroutine.create(function()
	while task.wait(0.2) do
		if settings.autoUltra then
			pcall(function()		
				if PlayerGui.Interface.BottomButtons.Ultra.Info.Text == "READY!" then
					RemoteEvent:FireServer({ [1] = { [1] = "\5", [2] = "Ultra" } })
				end
			end)
		end
	end
end))

Misc:AddToggle('watermark', {
	Text = "Toggle Watermark",
	Default = settings.watermark,
	Tooltip = "Toggle the visibility of the watermark popup"
})

Toggles["watermark"]:OnChanged(function()
	settings.watermark = Toggles["watermark"].Value
	Library:SetWatermarkVisibility(Toggles["watermark"].Value)
	SaveConfig()
end)

local Autos = Tabs["Main"]:AddLeftGroupbox('Autos')

local rebirthsTexts = {}
local rebirths = {}
for i, v in next, PlayerGui.Interface.Guis.Rebirth.MainFrame.List:GetChildren() do
	local listItemName = v.Name
	local rebirthNumber = listItemName:gsub("Rebirth--", "")

	if v.Name ~= "UIGradient" and v.Name ~= "UIListLayout" then
		table.insert(rebirthsTexts, v.Background.Req.Text)

		rebirths[v.Background.Req.Text] = rebirthNumber
	end
end

Autos:AddDropdown('selectedRebirth', {
	Values = rebirthsTexts,
	Default = settings.selectedRebirth,
	Multi = false,

	Text = 'Selected Rebirth',
	Tooltip = 'The rebirth for auto rebirth'
})

Options['selectedRebirth']:OnChanged(function()
	settings.selectedRebirth = Options['selectedRebirth'].Value
    SaveConfig()
end)

Autos:AddToggle('autoRebirth', {
	Text = "Auto Rebirth",
	Default = settings.autoRebirth,
	Tooltip = "Enables Auto Rebirth"
})

Toggles["autoRebirth"]:OnChanged(function()
	settings.autoRebirth = Toggles["autoRebirth"].Value
	SaveConfig()
end)

local sortChiButton = PlayerGui.Interface.Guis.Pets.SideButtons.Chi.MouseButton1Click
local sortGemsButton = PlayerGui.Interface.Guis.Pets.SideButtons.Gems.MouseButton1Click
local equipBestButton = PlayerGui.Interface.Guis.Pets.Buttons.Best.MouseButton1Click

local function equipBest(type: string)
	if type == "gems" then
		firesignal(sortGemsButton)
		task.wait(0.1)
		firesignal(equipBestButton)
	elseif type == "chi" then
		firesignal(sortChiButton)
		task.wait(0.1)
		firesignal(equipBestButton)
	end
end

local canBuyRebirthColor = "0 0 1 0.498039 0 1 0 1 0.498039 0 "
--local cannotBuyRebirthColor = "0 1 0.333333 0.498039 0 1 1 0.333333 0.498039 0 "

coroutine.resume(coroutine.create(function()
	while task.wait(1) do
		if settings.autoRebirth then
			pcall(function()
				local selectedAutoRebirth = rebirths[settings.selectedRebirth]
				
				if tostring(PlayerGui.Interface.Guis.Rebirth.MainFrame.List["Rebirth-" .. selectedAutoRebirth].Background.Button.UIGradient.Color) == canBuyRebirthColor then
					if settings.autoBestGemsBeforeRebirth then
						equipBest("gems")
						task.wait(0.5)
					end
					
					game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer({ [1] = { [1] = "\3", [2] = "Rebirth", [3] = { ["Rebirth"] = tonumber(selectedAutoRebirth) }} })				

					if settings.autoBestGemsBeforeRebirth then
						task.wait(0.5)
						equipBest("chi")
					end
				end
			end)
		end
	end
end))

Autos:AddToggle('autoBestGemsBeforeRebirth', {
	Text = "Auto Equip Best Gems",
	Default = settings.autoBestGemsBeforeRebirth,
	Tooltip = "Equips Best Gems Characters before Rebirthing"
})

Toggles["autoBestGemsBeforeRebirth"]:OnChanged(function()
	settings.autoBestGemsBeforeRebirth = Toggles["autoBestGemsBeforeRebirth"].Value
	SaveConfig()
end)

Autos:AddDropdown('selectedPractice', {
	Values = {'Spawn', 'Skull Mountain'},
	Default = settings.selectedPractice,
	Multi = false,

	Text = 'Selected Practice',
	Tooltip = 'The practice stand for auto practice'
})

Options['selectedPractice']:OnChanged(function()
	settings.selectedPractice = Options['selectedPractice'].Value
    SaveConfig()
end)

Autos:AddToggle('autoPractice', {
	Text = "Auto Practice",
	Default = settings.autoPractice,
	Tooltip = "Enables Auto Practice"
})

Toggles["autoPractice"]:OnChanged(function()
	settings.autoPractice = Toggles["autoPractice"].Value
	SaveConfig()
end)

coroutine.resume(coroutine.create(function()
	while task.wait(0.1) do
		if settings.autoPractice then
			for i, v in next, game:GetService("Workspace")['__GAME']['__STANDS']:GetChildren() do
				if v.Data.Restriction.Value == settings.selectedPractice then
					game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer({
						[1] = {
							[1] = "\5",
							[2] = "Practice",
							[3] = v.Data
						}
					})
				end
			end
		end
	end
end))

--------------------
--------------------
--------------------

Library:OnUnload(function()
	print('Unloaded!')
	Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightControl', NoUI = true, Text = 'Menu keybind' })
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

Library:Notify(string.format('Loaded script in %.2f second(s)!', tick() - StartTick), 5)

task.spawn(function()
    while true do
		task.wait(0.1)
        if Library.Unloaded then break; end

        local Ping = string.split(string.split(game.Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1], ".")[1];
        local Fps = string.split(game.Stats.Workspace.Heartbeat:GetValueString(), ".")[1];
        local AccountName = LocalPlayer.Name;

		if settings.watermark then
			Library:SetWatermark(string.format("%s | %s | %s FPS | %s Ping", GetLocalDateTime(), AccountName, Fps, Ping))
		end
    end
end)