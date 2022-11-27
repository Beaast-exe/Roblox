-- // VARIABLES \\ --
local players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = players.LocalPlayer

-- // FEATURE DEFINING \\ --
local settings = {
	autoBlend = false,  -- ab
	autoObby = false,   -- ao
	autoBuy = false,    -- abuy
	autoJar = false,    -- aj
	autoCrate = false,  -- ac
	fastArm = false, 	-- fc
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

local Main = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Updates = Main:AddSection({
	Name = "Updates"
})

local Autos = Main:AddSection({
	Name = "Autos"
})

local plot
local blenders = {}
Updates:AddButton({
	Name = "Atualizar Plot",
	Callback = function()
		for i, v in pairs(Workspace.Tycoons:GetDescendants()) do
			if (v.Name == "Owner" and v.Value == localPlayer) then
				plot = v.Parent
				OrionLib:MakeNotification({
					Name = "Plot atualizado com sucesso",
					Content = 'Podes começar a ativar os Autos',
					Image = "rbxassetid://4483345998",
					Time = 5
				})

				Autos:AddToggle({
					Name = "Auto Blend",
					Default = false,
					Callback = function(value)
						settings.autoBlend = value
						doAutoBlend()
					end
				})
				
				Autos:AddToggle({
					Name = "Auto Jar Door",
					Default = false,
					Callback = function(value)
						settings.autoJar = value
						doAutoJar()
					end
				})
				
				Autos:AddToggle({
					Name = "Auto Crate Door",
					Default = false,
					Callback = function(value)
						settings.autoCrate = value
						doAutoCrate(plot.CratePackager)
					end
				})
				
				Autos:AddToggle({
					Name = "Auto Crate Door (Basement)",
					Default = false,
					Callback = function(value)
						settings.autoCrate = value
						doAutoCrate(plot.CratePackager2)
					end
				})
				
				Autos:AddToggle({
					Name = "Fast Arm",
					Default = false,
					Callback = function(value)
						settings.fastArm = value
						doFastArm()
					end
				})
				
				Autos:AddToggle({
					Name = "Auto Buy",
					Default = false,
					Callback = function(value)
						settings.autoBuy = value
						doAutoBuy()
					end
				})
				
				Autos:AddToggle({
					Name = "Auto Obby",
					Default = false,
					Callback = function(value)
						settings.autoObby = value
						doAutoObby()
				
					end
				})

				Updates:AddButton({
					Name = "Atualizar Blenders",
					Default = false,
					Callback = function()
						updateBlenders()
					end
				})

				updateBlenders()
			end
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

function TeleportToMe(item)
	if localPlayer.Character then
		local hrp = localPlayer.Character.HumanoidRootPart
		item.CFrame = hrp.CFrame
	end
end

function TeleportTo(cframe)
	if localPlayer.Character then
		local hrp = localPlayer.Character.HumanoidRootPart
		hrp.CFrame = cframe
	end
end

function doAutoCrate(crate)
	task.spawn(function()
		while settings.autoCrate and task.wait(10) do
			TeleportTo(crate.Button.Button.CFrame + Vector3.new(-1, 2, 2))
			task.wait(0.2)
			fireproximityprompt(crate.Button.Button.Attachment.OpenDoorPrompt)
			task.wait(0.3)
		end
	end)
end

function doAutoJar()
	task.spawn(function()
		while settings.autoJar and task.wait(1) do
			local jarDoors = {
				[1] = plot.JarFactory,
				[2] = plot.JarFactory2
			}

			for i, v in pairs(jarDoors) do
				if v.Button.Button.Attachment.Cooldown.TextLabel.Text == "0" then
					TeleportTo(v.Button.Button.CFrame + Vector3.new(-1, 2, 2))
					task.wait(0.2)
					fireproximityprompt(v.Button.Button.Attachment.OpenDoorPrompt)
					task.wait(0.3)
				end
			end
		end
	end)
end

function doFastArm()
	task.spawn(function()
		while settings.fastArm and task.wait(0.1) do
			game:GetService("ReplicatedStorage").Remotes.Event.Animations.moveArm:FireServer()
		end
	end)
end

function doAutoBlend()
	task.spawn(function()
		while settings.autoBlend and task.wait(5) do
			for i, v in pairs(blenders) do
				--print(v.Name)
				TeleportTo(v.Button.CFrame + Vector3.new(-1, 2, 2))
				task.wait(0.2)
				fireproximityprompt(v.Button.Attachment.ActivateBlender)
				task.wait(0.8)
			end
		end
	end)
end

function doAutoBuy()
	task.spawn(function()
		while settings.autoBuy and task.wait(5) do
			for i, v in pairs(plot.PurchaseButtons:GetDescendants()) do
				if v.name == "Button" and v:FindFirstChild("TouchInterest") and v.Parent.Name ~= "Toggle Door Gamepass" and v.Parent.Name ~= "Gold Blender" then
					firetouchinterest(v, localPlayer.Character.HumanoidRootPart, 0)
					task.wait(0.2)
					firetouchinterest(v, localPlayer.Character.HumanoidRootPart, 1)
				end
			end
		end
	end)
end

function doAutoObby()
	task.spawn(function()
		while settings.autoObby and task.wait(20) and localPlayer.Character do
			firetouchinterest(localPlayer.Character.Head, Workspace.Obbies.HardObby.Finish.Button, 0)
			task.wait(0.2)
			firetouchinterest(localPlayer.Character.Head, Workspace.Obbies.HardObby.Finish.Button, 1)

			task.wait(2)

			firetouchinterest(localPlayer.Character.Head, Workspace.Obbies.EasyObby.Finish.Button, 0)
			task.wait(0.2)
			firetouchinterest(localPlayer.Character.Head, Workspace.Obbies.EasyObby.Finish.Button, 1)
		end
	end)
end

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

function updateBlenders()
	local purchases = plot.Purchases
	blenders = {}

	print("===========================================================")
	for i, v in pairs(purchases:GetChildren()) do
		if string.find(v.Name, "Blender") then
			table.insert(blenders, v)
			print(v.Name)
		end
	end
end

-- // INITIALIZE THE SCRIPT \\ --
OrionLib:Init()