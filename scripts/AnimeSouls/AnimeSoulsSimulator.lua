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

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Anime Souls Simulator', Center = true, AutoShow = true })

local saveFolderName = "BeaastHub"
local saveFileName = "AnimeSouls_" .. LocalPlayer.Name .. ".json"
local saveFile = saveFolderName .. "/" .. saveFileName

local defaultSettings = {
	hideName = false,
	watermark = false,
	teleportGamepass = false,
	noRobuxPrompt = false,
	webhookLink = "Webhook Link",
	webhookDelay = 5,
	webhookMentionId = "Mention ID",
	enableWebhookInterval = false
}

if not isfolder(saveFolderName) then makefolder(saveFolderName) end
if not isfile(saveFile) then writefile(saveFile, HttpService:JSONEncode(defaultSettings)) end

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

local Webhook = Tabs["Main"]:AddRightGroupbox('Webhook')

Webhook:AddToggle('enableWebhookInterval', {
	Text = "Enable Webhook Interval",
	Default = settings.enableWebhookInterval,
	Tooltip = "Enable auto webhook in the interval below"
})

Toggles["enableWebhookInterval"]:OnChanged(function()
	settings.enableWebhookInterval = Toggles["enableWebhookInterval"].Value
	SaveConfig()
end)

Webhook:AddInput('webhookLink', {
    Default = settings.webhookLink,
    Numeric = false, -- true / false, only allows numbers
    Finished = true, -- true / false, only calls callback when you press enter

    Text = 'Webhook Link',
    Tooltip = 'Insert Webhook Link (Press ENTER)', -- Information shown when you hover over the textbox

    Placeholder = 'Insert Webhook Link (Press ENTER)', -- placeholder text when the box is empty
    -- MaxLength is also an option which is the max length of the text
})

Options["webhookLink"]:OnChanged(function()
	settings.webhookLink = Options["webhookLink"].Value
	SaveConfig()
end)

Webhook:AddInput('webhookDelay', {
    Default = settings.webhookDelay,
    Numeric = true, -- true / false, only allows numbers
    Finished = true, -- true / false, only calls callback when you press enter

    Text = 'Webhook Delay',
    Tooltip = 'Delay in minutes between webhooks', -- Information shown when you hover over the textbox

    Placeholder = 'Delay (minutes)', -- placeholder text when the box is empty
    -- MaxLength is also an option which is the max length of the text
})

Options["webhookDelay"]:OnChanged(function()
	settings.webhookDelay = Options["webhookDelay"].Value
	SaveConfig()
end)

Webhook:AddInput('webhookMentionId', {
    Default = settings.webhookMentionId,
    Numeric = true, -- true / false, only allows numbers
    Finished = true, -- true / false, only calls callback when you press enter

    Text = 'Webhook Mention ID',
    Tooltip = 'User ID to mention when sending webhook', -- Information shown when you hover over the textbox

    Placeholder = 'Mention ID', -- placeholder text when the box is empty
    -- MaxLength is also an option which is the max length of the text
})

Options["webhookMentionId"]:OnChanged(function()
	settings.webhookMentionId = Options["webhookMentionId"].Value
	SaveConfig()
end)

local function runeCodeToString(rune_code, amount)
	local RuneTranslated = ""
	local RunesTranslations = {
		rune_yellow = "🟨 **Yellow Rune:** `",
		rune_pink = "~ **Pink Rune:** `",
		rune_green = "🟩 **Green Rune:** `",
		rune_blue = "🟦 **Blue Rune:** `",
		rune_orange = "🟧 **Orange Rune:** `",
		rune_purple = "🟪 **Purple Rune:** `",
		rune_red = "🟥 **Red Rune:** `"
	}

	for key, Translation in next, RunesTranslations do
		if rune_code == key then
			RuneTranslated = tostring(Translation .. amount .. "`")
		end
	end

	return RuneTranslated
end

local function getMention(mention)
	local translatedMention = ""
	
	if mention == "Mention ID" or mention == "" then
		translatedMention = ""
	else
		translatedMention = "<@" .. mention .. ">"
	end

	return translatedMention
end

local function sendWebhook()
	local url = tostring(settings.webhookLink)
	if url == "Webhook Link" then return end

	local mention = getMention(tostring(settings.webhookMentionId))

	local playerThumbnails = request({
		Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. LocalPlayer.UserId .. "&size=48x48&format=Png&isCircular=false",
		Method = "GET"
	}).Body
	local imageUrl = HttpService:JSONDecode(playerThumbnails).data[1].imageUrl

	local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
	local Energy = PlayerGui.SideUI.Displays.EnergyDisplay.Shadow.Amount.Text
	local Souls = PlayerGui.SideUI.Displays.SoulsDisplay.Shadow.Amount.Text

	local Potions = PlayerGui.CenterUI.Potions.Main.Scroll
	local EnergyPotions = tostring(string.match(Potions.energy.button.title.Text, "%d+"))
	local SoulsPotions = tostring(string.match(Potions.souls.button.title.Text, "%d+"))
	local DamagePotions = tostring(string.match(Potions.damage.button.title.Text, "%d+"))
	local LuckyPotions = tostring(string.match(Potions.lucky.button.title.Text, "%d+"))

	local Backpack = PlayerGui.CenterUI.Backpack.Main.Scroll

	local runes = {}
	
	for i, v in next, Backpack:GetChildren() do
		if v.Name ~= "UIGridLayout" and v.Name ~= "UIPadding" and v.Name ~= "template" then
			local item = v:GetChildren()[1]
			if #item:FindFirstChild("shadow"):FindFirstChild("view"):FindFirstChild("model"):GetChildren() < 1 then
				local textToInsert = runeCodeToString(item.Name, tostring(string.match(item._amount.Text, "%d+")))
				table.insert(runes, textToInsert)
			end
		end
	end

	local data = {
		["content"] = mention,
		["username"] = "Beaast Hub | " .. LocalPlayer.Name,
		["avatar_url"] = imageUrl,
		["embeds"] = {
			{
				["fields"] = {
					{
						["name"] = "Currencies:",
						["value"] = "⚡ `" .. Energy .. "`\n👻 `" .. Souls .. "`",
						["inline"] = false
					},
					{
						["name"] = "Potions:",
						["value"] = "⚡ **Energy:** `" .. EnergyPotions .. "`\n👻 **Souls:** `" .. SoulsPotions .. "`\n⚔️ **Damage:** `" .. DamagePotions .. "`\n🍀 **Lucky:** `" .. LuckyPotions .. "`",
						["inline"] = false
					},
					{
						["name"] = "Runes:",
						["value"] = table.concat(runes, "\n"),
						["inline"] = false
					}
				}
			}
		}
	}

	local encodedJson = HttpService:JSONEncode(data)
	local headers = {["content-type"] = "application/json"}
	local options = {
		Url = url,
		Body = encodedJson,
		Method = "POST",
		Headers = headers
	}

	Library:Notify("Sending Webhook...", 5)
	request(options)
end

Webhook:AddButton('Test Webhook', function()
	sendWebhook()
end)

coroutine.resume(coroutine.create(function()
	while task.wait(settings.webhookDelay * 60) do
		if settings.enableWebhookInterval then
			sendWebhook()
		end
	end
end))

local info = Tabs["Main"]:AddRightGroupbox("Info")

local function getPrice(type: string)
	if type == "class" then
		local classGui = LocalPlayer.PlayerGui.CenterUI.Class.Main.Mid

		if classGui["maxed"].Visible then
			return "MAXED"
		else
			local classPriceSouls = classGui["can_upgrade"].price.price.Text

			return "" .. classPriceSouls .. " 👻"
		end
	elseif type == "sword" then
		local swordsGui = LocalPlayer.PlayerGui.CenterUI.Swords.Main.Mid

		if swordsGui["maxed"].Visible then
			return "MAXED"
		else
			local swordPriceSouls = swordsGui["can_upgrade"].price.price.Text

			return "" .. swordPriceSouls .. " 👻"
		end
	elseif type == "aura" then
		local aurasGui = LocalPlayer.PlayerGui.CenterUI.Auras.Main.Mid

		if aurasGui["maxed"].Visible then
			return "MAXED"
		else
			local auraPriceSouls = aurasGui["can_upgrade"]["price_souls"].price.Text
			local auraPriceRunes = aurasGui["can_upgrade"]["price_rune"].price.Text

			return "" .. auraPriceSouls .. " 👻 + " .. auraPriceRunes .. " ✨"
		end
	end
end

local function getMultipliers(type: string)
	if type == "class" then
		local classGui = LocalPlayer.PlayerGui.CenterUI.Class.Main.Mid
		local currentClassMultiplier = classGui["can_upgrade"]["current"].multiplier.Text
		local nextClassMultiplier = classGui["can_upgrade"]["next"].multiplier.Text

		if classGui["maxed"].Visible then
			return "" .. currentClassMultiplier
		else
			return "" .. currentClassMultiplier .. " >> " .. nextClassMultiplier
		end
	elseif type == "sword" then
		local swordsGui = LocalPlayer.PlayerGui.CenterUI.Swords.Main.Mid
		local currentSwordMultiplier = swordsGui["can_upgrade"]["current"].multiplier.Text
		local nextSwordMultiplier = swordsGui["can_upgrade"]["next"].multiplier.Text

		if swordsGui["maxed"].Visible then
			return "" .. currentSwordMultiplier
		else
			return "" .. currentSwordMultiplier .. " >> " .. nextSwordMultiplier
		end
	elseif type == "aura" then
		local aurasGui = LocalPlayer.PlayerGui.CenterUI.Auras.Main.Mid
		local currentAuraMultiplier = aurasGui["can_upgrade"]["current"].multiplier.Text
		local nextAuraMultiplier = aurasGui["can_upgrade"]["next"].multiplier.Text

		if aurasGui["maxed"].Visible then
			return "" .. currentAuraMultiplier
		else
			return "" .. currentAuraMultiplier .. " >> " .. nextAuraMultiplier
		end
	end
end

local nextClassLabel = info:AddLabel("Next Class: 0")
local classMultipliers = info:AddLabel("Multipliers: 0")
local nextSwordLabel = info:AddLabel("Next Sword: 0")
local swordMultipliers = info:AddLabel("Multipliers: 0")
local nextAuraLabel = info:AddLabel("Next Aura: 0")
local auraMultipliers = info:AddLabel("Multipliers: 0")

coroutine.resume(coroutine.create(function()
	while task.wait(5) do
		nextClassLabel:SetText("Next Class: " .. getPrice("class"))
		classMultipliers:SetText("Multipliers: " .. getMultipliers("class"))
		nextSwordLabel:SetText("Next Sword: " .. getPrice("sword"))
		swordMultipliers:SetText("Multipliers: " .. getMultipliers("sword"))
		nextAuraLabel:SetText("Next Aura: " .. getPrice("aura"))
		auraMultipliers:SetText("Multipliers: " .. getMultipliers("aura"))
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