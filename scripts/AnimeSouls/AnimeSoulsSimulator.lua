local StartTick = tick()
repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
------
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Anime Souls Simulator', Center = true, AutoShow = true })

local saveFolderName = "BeaastHub"
local saveFileName = "AnimeSouls_" .. LocalPlayer.Name .. ".json"
local saveFile = saveFolderName .. "/" .. saveFileName

local defaultSettings = {
	hideName = false,
	watermark = false,
	teleportGamepass = false,
	noRobuxPrompt = false
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

local Misc = Tabs["Main"]:AddRightGroupbox('Misc')

Misc:AddToggle('hideName', {
	Text = "Hide Name",
	Default = settings.hideName,
	Tooltip = "Remove your over head name & class info"
})

Toggles["hideName"]:OnChanged(function()
	settings.hideName = Toggles["hideName"].Value

	if settings.hideName == false then
		pcall(function()
			if workspace[LocalPlayer.Name].Head:FindFirstChild("player_tag") then
				workspace[LocalPlayer.Name].Head:FindFirstChild("player_tag"):Destroy()
			end
		end)
	end
	SaveConfig()
end)

Misc:AddButton('Reset Name', function()
	pcall(function()
		if workspace[LocalPlayer.Name].Head:FindFirstChild("player_tag") then
			workspace[LocalPlayer.Name].Head:FindFirstChild("player_tag"):Destroy()
		end
	end)
end):AddTooltip('Reset your name & class info over the head.')

coroutine.resume(coroutine.create(function()
	while task.wait(1) do
		if settings.hideName then
			pcall(function()
				if workspace[game.Players.LocalPlayer.Name].Head:FindFirstChild("player_tag") then
				   for i, v in next, workspace[game.Players.LocalPlayer.Name].Head["player_tag"]:GetChildren() do
					   v:Destroy()
				   end
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

Misc:AddToggle('teleportGamepass', {
	Text = "Teleport Gamepass",
	Default = settings.teleportGamepass,
	Tooltip = "Enable the teleport"
})

Toggles["teleportGamepass"]:OnChanged(function()
	settings.teleportGamepass = Toggles["teleportGamepass"].Value
	SaveConfig()
end)

local function OpenTeleportGui()
    local Teleport = game:GetService("Players").LocalPlayer.PlayerGui.CenterUI.Teleport;

    if not Teleport.Visible then
        Teleport.Visible = true;

        local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out);

        game.TweenService:Create(Teleport, TweenInfo, {
            Position = UDim2.fromScale(0.5, 0.5)
        }):Play();
    else
        local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In);

        game.TweenService:Create(Teleport, TweenInfo, {
            Position = UDim2.fromScale(0.5, -0.5)
        }):Play();

        task.wait(0.2)

        Teleport.Visible = false;
    end
end

local TeleportButton = game:GetService("Players").LocalPlayer.PlayerGui.SideUI.Left.Teleport
TeleportButton.MouseButton1Click:Connect(function()
	if settings.teleportGamepass then
		OpenTeleportGui()
	end
end)

local Notification = game:GetService("Players").LocalPlayer.PlayerGui.Notification.Messages

task.spawn(function()
	while task.wait() do
		if settings.teleportGamepass then
			TeleportButton.ImageTransparency = 0
			TeleportButton.Background.ImageTransparency = 0
			TeleportButton.Icon.ImageTransparency = 0
			if Notification:FindFirstChild("Error") then
				if Notification["Error"].Text.Text == "You don't have teleport gamepass!" then
					Notification["Error"]:Destroy()
				end
			end
		end
	end
end)

Misc:AddToggle('noRobuxPrompt', {
	Text = "No Robux Prompt",
	Default = settings.noRobuxPrompt,
	Tooltip = "Prevent payment prompts from appearing (recommended with Teleport)"
})

Toggles["noRobuxPrompt"]:OnChanged(function()
	settings.noRobuxPrompt = Toggles["noRobuxPrompt"].Value
	SaveConfig()
end)

coroutine.resume(coroutine.create(function()
	local COREGUI = game:GetService("CoreGui")
	if settings.noRobuxPrompt == true then
		COREGUI.PurchasePrompt.Enabled = false
	elseif settings.noRobuxPrompt == false then
		COREGUI.PurchasePrompt.Enabled = true
	end
end))

--Library:SetWatermarkVisibility(settings.watermark)
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