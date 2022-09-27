-- // VARIABLES \\ --
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local localPlayer = game:GetService("Players").LocalPlayer
local Mouse = localPlayer:GetMouse()
local attackEvent = game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.4.7").knit.Services.WeaponService.RE.Swing

-- // FEATURE DEFINING \\ --
local settings = {
	autoFarm = false,
	autoLevel = false,
	autoSkills = {
		enraged = {
			enabled = false,
			text = "Enraged"
		},
		eruption = {
			enabled = false,
			text = "Eruption"
		},
		misfortune = {
			enabled = false,
			text = "Misfortune"
		},
		goldenRain = {
			enabled = false,
			text = "Golden Rain"
		},
		goldPotion = {
			enabled = false,
			text = "Gold Potion"
		}
	},
	autoClick = {
		enabled = false,
		x = 0,
		y = 0,
		interval = 0.01
	}
}

-- // UI SETUP \\ --
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
	Name = "Beaast Hub",
	HidePremium = false,
	SaveConfig = false,
	IntroEnabled = false,
	IntroText = "Beaast Hub"
})

local Main = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Autos = Main:AddSection({
	Name = "Autos"
})

Autos:AddToggle({
	Name = "Enable Auto Farm",
	Default = false,
	Callback = function(bool)
		settings.autoFarm = bool
	end
})

Autos:AddToggle({
	Name = "Enable Auto Level",
	Default = false,
	Callback = function(bool)
		settings.autoLevel = bool
	end
})

-- // AUTO SKILLS TAB \\ --
local Autoskills = Window:MakeTab({
	Name = "Auto Skills",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local AUTOSKILLS = Autoskills:AddSection({
	Name = "Auto Skills"
})

AUTOSKILLS:AddToggle({
	Name = "AUTO - Enraged",
	Default = false,
	Callback = function(bool)
		settings.autoSkills.enraged.enabled = bool
	end
})

AUTOSKILLS:AddToggle({
	Name = "AUTO - Eruption",
	Default = false,
	Callback = function(bool)
		settings.autoSkills.eruption.enabled = bool
	end
})

AUTOSKILLS:AddToggle({
	Name = "AUTO - Misfortune",
	Default = false,
	Callback = function(bool)
		settings.autoSkills.misfortune.enabled = bool
	end
})

AUTOSKILLS:AddToggle({
	Name = "AUTO - Golden Rain",
	Default = false,
	Callback = function(bool)
		settings.autoSkills.goldenRain.enabled = bool
	end
})

AUTOSKILLS:AddToggle({
	Name = "AUTO - Gold Potion",
	Default = false,
	Callback = function(bool)
		settings.autoSkills.goldPotion.enabled = bool
	end
})

-- // AUTO CLICKER TAB \\ --

local Autoclicker = Window:MakeTab({
	Name = "Auto Clicker",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local AUTOCLICK = Autoclicker:AddSection({
	Name = "Auto Clicker"
})

AUTOCLICK:AddSlider({
	Name = "Auto Click Delay",
	Min = 0.01,
	Max = 1,
	Default = 0.01,
	Increment = 0.01,
	Color = Color3.fromRGB(0, 255, 255),
	Callback = function(value)
		settings.autoClick.interval = value
	end
})

AUTOCLICK:AddBind({
	Name = "Toggle Auto Clicker",
	Default = Enum.KeyCode.F,
	Hold = false,
	Callback = function()
		settings.autoClick.x = Mouse.X
		settings.autoClick.y = Mouse.Y

		if settings.autoClick.enabled then
			settings.autoClick.enabled = false
			doAutoClick()
		else
			settings.autoClick.enabled = true
			doAutoClick()
		end
	end
})

-- // MISC TAB \\ --
local Misc = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local CREDITS = Misc:AddSection({
	Name = "Credits"
})

CREDITS:AddButton({
	Name = "COPY DISCORD LINK",
	Callback = function()
		setclipboard('https://discord.gg/MeAXMSCc9Q')
		OrionLib:MakeNotification({
			Name = "COPIED!",
			Content = "Discord link copied to your clipboard!",
			Time = 5
		})
  	end
})

CREDITS:AddLabel("Created by: Beaast#6458")

local UI = Misc:AddSection({
	Name = "UI Options"
})

UI:AddBind({
	Name = "Toggle UI",
	Default = Enum.KeyCode.RightControl,
	Hold = false,
	Callback = function()
		local UI = game:GetService("CoreGui"):FindFirstChild("Orion")
		if UI then
			UI.Enabled = not UI.Enabled
		end
	end
})

UI:AddButton({
	Name = "Destroy UI",
	Callback = function()
		OrionLib:Destroy()
  	end
})

-- // CHEAT FUNCTIONS \\ --
function doAutoClick()
	spawn(function()
		while settings.autoClick.enabled do
			VirtualInputManager:SendMouseButtonEvent(settings.autoClick.x, settings.autoClick.y, 0, true, game, 1)
			VirtualInputManager:SendMouseButtonEvent(settings.autoClick.x, settings.autoClick.y, 0, false, game, 1)
			wait(settings.autoClick.interval)
		end
	end)
end

function getPlot()
	for _, plot in next, Workspace:WaitForChild("Plots"):GetChildren() do
		if plot.Owner.Value == localPlayer then
			return plot.Name
		end
	end
end

function getEnemyName()
	for _, enemy in next, Workspace:WaitForChild("Plots")[getPlot()].Enemy:GetChildren() do
		if enemy and enemy:IsA("BasePart") then
			return enemy.Name
		end
	end
end

function attackEnemy()
	local enemyPlot = getPlot()
	local enemyName  = getEnemyName()

	if enemyPlot and enemyName then
		attackEvent:FireServer(Workspace.Plots[enemyPlot].Enemy[enemyName])
	end
end

function isPlayerAlive()
	local humanoid = localPlayer.Character and localPlayer.Character.Humanoid
	local root = localPlayer.Character and localPlayer.Character:WaitForChild("HumanoidRootPart", 5)

	if root and (humanoid and humanoid.Health > 0) then
		return true
	end
end

function teleportTo(part)
	if part and isPlayerAlive() then
		localPlayer.Character.PrimaryPart:PivotTo(part)
	end
end

function getEnemyLocation()
	for _, enemy in next, Workspace:WaitForChild("Plots")[getPlot()].Enemy:GetChildren() do
		if enemy and enemy:IsA("BasePart") then
			return enemy.CFrame * CFrame.new(0, 0, -5)
		end
	end
end

function autoFarm()
	teleportTo(getEnemyLocation()) do
		attackEnemy()
	end
end

function canLevelUp()
	for _, button in next, Workspace:WaitForChild("Plots")[getPlot()].Buttons:GetChildren() do
		local levelButton = string.find(button.Name, "NextLevel")
		if levelButton then
			return true
		end
	end
end

function levelPosition()
	if isPlayerAlive() and canLevelUp() then
		for _, level in next, Workspace:WaitForChild("Plots")[getPlot()].Buttons.NextLevel:GetChildren() do
			if level:IsA("Part") and level.Name:find("Touch") then
				return level.CFrame
			end
		end
	end
end

function autolevel()
	if isPlayerAlive() and canLevelUp() then
		for _, level in next, Workspace:WaitForChild("Plots")[getPlot()].Buttons.NextLevel:GetChildren() do
			local touch = string.find(level.Name, "Touch")
			if touch then
				teleportTo(levelPosition())
			end
		end
	end
end

function useSkill(skillName)
	local skillEvent = game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.4.7").knit.Services.HeroService.RE.UseSkill
	skillEvent:FireServer(skillName)
end

-- // FEATURES HANDLING \\ --
task.spawn(function()
	while task.wait() do
		if settings.autoFarm then
			autoFarm()
		end

		if settings.autoLevel then
			autolevel()
		end

		if settings.autoSkills.enraged.enabled then
			useSkill(settings.autoSkills.enraged.text)
		end
	
		if settings.autoSkills.eruption.enabled then
			useSkill(settings.autoSkills.eruption.text)
		end
	
		if settings.autoSkills.misfortune.enabled then
			useSkill(settings.autoSkills.misfortune.text)
		end
	
		if settings.autoSkills.goldenRain.enabled then
			useSkill(settings.autoSkills.goldenRain.text)
		end

		if settings.autoSkills.goldPotion.enabled then
			useSkill(settings.autoSkills.goldPotion.text)
		end
	end
end)

-- // INITIALIZE THE SCRIPT \\ --
OrionLib:Init()