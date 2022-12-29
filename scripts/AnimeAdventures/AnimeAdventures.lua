task.wait(2)
repeat task.wait() until game:IsLoaded()
if game.PlaceId == 8304191830 then
	repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
	repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("collection"):FindFirstChild("grid"):FindFirstChild("List"):FindFirstChild("Outer"):FindFirstChild("UnitFrames")
elseif game.PlaceId == 8349889591 then
	repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
	game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
	repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
end

---------------------------------------------------------------------------------------------------------------

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Mouse = game.Players.LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local settingsFile = "BeaastHub_AnimeAdventures_" .. localPlayer.Name .. ".json"

-- Webhook Sender
local function sendWebhook()
	pcall(function()
		local url = tostring(getenv().weburl) -- webhook url
		if url == "" then
			return
		end

		local results = localPlayer.PlayerGui.ResultsUI.Holder
		Xp = tostring(results.GoldGemXP.XPReward.Main.Amount.Text)
		
	end)
end