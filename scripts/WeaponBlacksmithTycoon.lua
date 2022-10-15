-- // VARIABLES \\ --
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local localPlayer = game:GetService("Players").LocalPlayer
local Mouse = localPlayer:GetMouse()

-- // FEATURE DEFINING \\ --
local settings = {
	autoSwing = {
		enabled = false,
		interval = 0.6
	},
	autoFarm = {
		enabled = false,
		interval = 5
	},
	autoClick = {
		enabled = false,
		x = 0,
		y = 0,
		interval = 0.01
	},
	walkspeed = 16,
	jumppower = 50
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

-- // AUTOS TAB \\ --
local Main = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Autos = Main:AddSection({
	Name = "Autos"
})

Autos:AddSlider({
	Name = "Auto Farm Interval",
	Min = 5,
	Max = 60,
	Default = 10,
	Color = Color3.fromRGB(0, 255, 255),
	Increment = 5,
	Callback = function(value)
		settings.autoFarm.interval = value
	end
})

local farm = Autos:AddToggle({
	Name = "Enable Auto Farm",
	Default = false,
	Callback = function(bool)
		settings.autoFarm.enabled = bool
	end
})

Autos:AddBind({
	Name = "Toggle Auto Farm BIND",
	Default = Enum.KeyCode.R,
	Hold = false,
	Callback = function()
		if settings.autoFarm.enabled then
			settings.autoFarm.enabled = false
			farm:Set(false)
		else
			settings.autoFarm.enabled = true
			farm:Set(true)
		end
	end
})

Autos:AddToggle({
	Name = "Enable Auto Swing",
	Default = false,
	Callback = function(bool)
		settings.autoSwing.enabled = bool
	end
})

-- // TELEPORTS TAB \\ --
local TeleportsTab = Window:MakeTab({
	Name = "Teleports",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local TeleportSection = TeleportsTab:AddSection({
	Name = "Teleports"
})

local teleportsDropdown = TeleportSection:AddDropdown({
	Name = "Teleports",
	Default = "Enemy",
	Options = {"Enemy", "BanshieHouse", "PickupCircle", "RebirthCircle", "SellCircle", "SpellSchoolCircle", "UpgradeCircle"}
})

TeleportSection:AddButton({
	Name = "Teleport to Selected",
	Callback = function()
		doTeleport(teleportsDropdown.Value)
	end
})

-- // CLICKER TAB \\ --
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

local MISC = Misc:AddSection({
	Name = "Misc Options"
})

MISC:AddSlider({
	Name = "Walk Speed",
	Min = 16,
	Max = 200,
	Default = 16,
	Color = Color3.fromRGB(0, 255, 255),
	Increment = 1,
	Callback = function(value)
		settings.walkspeed = value
	end
})

MISC:AddSlider({
	Name = "Jump Power",
	Min = 50,
	Max = 200,
	Default = 50,
	Color = Color3.fromRGB(0, 255, 255),
	Increment = 1,
	Callback = function(value)
		settings.jumppower = value
	end
})

-- // CREDITS TAB \\ --
local credits = Window:MakeTab({
	Name = "Credits",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local CREDITS = credits:AddSection({
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

local UIOptions = Misc:AddSection({
	Name = "UI Options"
})

UIOptions:AddBind({
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

UIOptions:AddButton({
	Name = "Destroy UI",
	Callback = function()
		OrionLib:Destroy()
  	end
})

-- // CHEAT FUNCTIONS \\ --
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

function doAutoClick()
	task.spawn(function()
		while settings.autoClick.enabled do
			VirtualInputManager:SendMouseButtonEvent(settings.autoClick.x, settings.autoClick.y, 0, true, game, 1)
			VirtualInputManager:SendMouseButtonEvent(settings.autoClick.x, settings.autoClick.y, 0, false, game, 1)
			task.wait(settings.autoClick.interval)
		end
	end)
end

function getPlayerTycoon()
	local tycoon = Workspace:WaitForChild("Tycoons")[getTycoonName()]
	return tycoon
end

function getTycoonName()
	for _, tycoon in next, Workspace:WaitForChild("Tycoons"):GetChildren() do
		if tycoon.Configuration.Owner.Value == localPlayer then
			return tycoon.Name
		end
	end
end

function getEnemyLocation()
	for _, enemy in next, getPlayerTycoon().Enemies:GetChildren() do
		if enemy then
			return enemy.Hitbox.CFrame * CFrame.new(0, 5, 0)
		end
	end
end

local playerTycoonInfo = {
	spawn = getPlayerTycoon().Spawn.CFrame,
	enemyLocation = getEnemyLocation(),
	interactiveCircles = {
		BanshieHouse = getPlayerTycoon().InteractiveCircles.BanshieHouse.CFrame,
		PickupCircle = getPlayerTycoon().InteractiveCircles.PickupCircle.CFrame,
		RebirthCircle = getPlayerTycoon().InteractiveCircles.RebirthCircle.CFrame,
		SellCircle = getPlayerTycoon().InteractiveCircles.SellCircle.CFrame,
		SpellSchoolCircle = getPlayerTycoon().InteractiveCircles.SpellSchoolCircle.CFrame,
		UpgradeCircle = getPlayerTycoon().InteractiveCircles.UpgradeCircle.CFrame
	}

}

function doTeleport(teleport)
	if teleport == "Enemy" then
		teleportTo(playerTycoonInfo.enemyLocation)
	elseif teleport == "BanshieHouse" then
		teleportTo(playerTycoonInfo.interactiveCircles.BanshieHouse)
	elseif teleport == "PickupCircle" then
		teleportTo(playerTycoonInfo.interactiveCircles.PickupCircle)
	elseif teleport == "RebirthCircle" then
		teleportTo(playerTycoonInfo.interactiveCircles.RebirthCircle)
	elseif teleport == "SellCircle" then
		teleportTo(playerTycoonInfo.interactiveCircles.SellCircle)
	elseif teleport == "SpellSchoolCircle" then
		teleportTo(playerTycoonInfo.interactiveCircles.SpellSchoolCircle)
	elseif teleport == "UpgradeCircle" then
		teleportTo(playerTycoonInfo.interactiveCircles.UpgradeCircle)
	end
end

function doAutoFarm()
	teleportTo(playerTycoonInfo.interactiveCircles.PickupCircle)

	task.wait(0.2)
	game:GetService("ReplicatedStorage").Remotes.PickupWeapons:InvokeServer("pickup")

	task.wait(1)
	teleportTo(playerTycoonInfo.interactiveCircles.SellCircle)

	task.wait(1)
	teleportTo(playerTycoonInfo.enemyLocation)

	task.wait(settings.autoFarm.interval)
end

task.spawn(function()
	while task.wait(0.1) do
		if settings.autoSwing.enabled then
			game:GetService("Workspace"):FindFirstChild(localPlayer.Name).Weapon.WeaponActivated:FireServer(0.6)
		end

		if settings.autoFarm.enabled then
			doAutoFarm()
		end
	end
end)

RunService.Stepped:Connect(function()
	if localPlayer.Character then
		local Humanoid = localPlayer.Character:FindFirstChild("Humanoid")
		if Humanoid then
			Humanoid.WalkSpeed = tonumber(settings.walkspeed)
			Humanoid.JumpPower = tonumber(settings.jumppower)
			if Humanoid.UseJumpPower ~= true then
				Humanoid.UseJumpPower = true
			end
		end
	end
end)

-- // INITIALIZE THE SCRIPT \\ --
OrionLib:Init()