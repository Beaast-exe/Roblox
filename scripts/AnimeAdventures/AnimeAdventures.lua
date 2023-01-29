local version = "1.0.0"

---// Loading Section \\---
task.wait(2)
repeat  task.wait() until game:IsLoaded()
if game.PlaceId == 8304191830 then
    repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
    repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("collection"):FindFirstChild("grid"):FindFirstChild("List"):FindFirstChild("Outer"):FindFirstChild("UnitFrames")
else
    repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
    game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
    repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
end
------------------------------

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace") 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local mouse = game.Players.LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

getenv().configFolder = "Beaast Hub/Anime Adventures/"
getenv().saveFileName = "AnimeAdventures_" .. Players.LocalPlayer.Name .. ".json"
getenv().door = "_lobbytemplategreen1"

--#region Webhook Sender
function sendWebhook()
	pcall(function()
		local url = tostring(getenv().weburl) -- webhook
		if url == "" then
			return
		end

		local xp = tostring(Players.LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.XPReward.Main.Amount.Text)
		local gems = tostring(Players.LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.getRealNumber.Main.Amount.Text)
		local wavesCompleted = Players.LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.WavesCompleted.Text
		local timeCompleted = Players.LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.Timer.Text
		local waves = wavesCompleted:split(": ")
		local totalTime = timeCompleted:split(": ")

		local data = {
			["content"] = "",
			["username"] = "Anime Adventures",
			["avatar_url"] = "https://tr.rbxcdn.com/e5b5844fb26df605986b94d87384f5fb/150/150/Image/Jpeg",
			["embeds"] = {
				{
					["author"] = {
						["name"] = "Anime Adventures | Result",
						["icon_url"] = "https://cdn.discordapp.com/emojis/997123585476927558.webp?size=96&quality=lossless"
					},
					["description"] = "🎮 ||**" .. Players.LocalPlayer.Name .. "**|| 🎮",
					["color"] = 110335,
					["thumbnail"] = {
						["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Players.LocalPlayer.UserId .. "&width=420&height=420&format=png"
					},
					["fields"] = {
						{
							["name"] = "Total Waves:",
							["value"] = "<:waves:1052893845345538068> " .. tostring(waves[2]),
							["inline"] = true
						},
						{
							["name"] = "Received Gems:",
							["value"] = "<:gems:1052893843315507274> " .. gems,
							["inline"] = true
						},
						{
							["name"] = "Received XP:",
							["value"] = "🧪 " .. xp,
							["inline"] = true
						},
						{
							["name"] = "Total Time:",
							["value"] = "⏳ " .. tostring(totalTime[2]),
							["inline"] = true
						},
						{
							["name"] = "Current Gems:",
							["value"] = "<:gems:1052893843315507274> " .. tostring(Players.LocalPlayer["_stats"].gem_amount.Value),
							["inline"] = true
						},
						{
							["name"] = "Current Level:",
							["value"] = "✨ " .. tostring(Players.LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text),
							["inline"] = true
						}
					}
				}
			}
		}

		local encodedWebhook = HttpService:JSONEncode(data)
		local headers = { ["content-type"] = "application/json" }
		local request = http_request or request or HttpPost or syn.request or http.request
		local requestObject = {
			Url = url,
			Body = encodedWebhook,
			Method = "POST",
			Headers = headers
		}
		warn("[Beaast Hub] Sending Webhook")
		request(requestObject)
	end)
end
--#endregion

getenv().UnitCache = {}
for _, Module in next, ReplicatedStorage:WaitForChild("src"):WaitForChild("Data"):WaitForChild("Units"):GetDescendants() do
	if Module:IsA("ModuleScript") and Module.Name ~= "UnitPresets" then
		for UnitName, UnitStats in next, require(Module) do
			getenv().UnitCache[UnitName] = UnitStats
		end
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

function config()
	local jsonData = readfile(getenv().configFolder .. getenv().saveFileName)
	local data = HttpService:JSONDecode(jsonData)

	--#region Global Values

	-- DEVIL CITY aka CHAINSAW MAN
	getenv().portalName = data.portalName
	getenv().portalFarm = data.portalFarm
	getenv().portalBuy = data.portalBuy
	getenv().portalID = data.portalID

	getenv().autoLeave = data.autoLeave
	getenv().autoReplay = data.autoReplay
	getenv().autoChallenge = data.autoChallenge
	getenv().selectedReward = data.selectedReward
	getenv().autoChallengeAll = data.autoChallengeAll
	getenv().disableAutoFarm = false
	getenv().autoSell = data.autoSell
	getenv().autoSellWave = data.autoSellWave
	getenv().autoFarm = data.autoFarm
	getenv().autoFarmIC = data.autoFarmIC
	getenv().autoFarmTP = data.autoFarmTP
	getenv().autoLoadTP = data.autoLoadTP
	getenv().weburl = data.webhook
	getenv().autoStart = data.autoStart
	getenv().autoUpgrade = data.autoUpgrade
	getenv().selectedDifficulty = data.selectedDifficulty
	getenv().selectedWorld = data.selectedWorld
	getenv().selectedLevel = data.selectedLevel

	getenv().SpawnUnitPos = data.xspawnUnitPos
	getenv().SelectedUnits = data.xselectedUnits
	getenv().autoAbilities = data.autoAbilities
	--#endregion

	--#region update json
	function updateJson()
		local xData = {
			portalName = getenv().portalName,
			portalFarm = getenv().portalFarm,
			portalBuy = getenv().portalBuy,
			portalID = getenv().portalID,

			autoLoadTP = getenv().autoLoadTP,
			autoLeave = getenv().autoLeave,
			autoReplay = getenv().autoReplay,
			autoChallenge = getenv().autoChallenge,
			selectedReward = getenv().selectedReward,
			autoChallengeAll = getenv().autoChallengeAll,
			autoSellWave = getenv().autoSellWave,
			autoSell = getenv().autoSell,
			webhook = getenv().weburl,
			autoFarm = getenv().autoFarm,
			autoFarmIC = getenv().autoFarmIC,
			autoFarmTP = getenv().autoFarmTP,
			autoStart = getenv().autoStart,
			autoUpgrade = getenv().autoUpgrade,
			selectedDifficulty = getenv().selectedDifficulty,
			selectedWorld = getenv().selectedWorld,
			selectedLevel = getenv().selectedLevel,

			xspawnUnitPos = getenv().SpawnUnitPos,
			xselectedUnits = getenv().SelectedUnits,
			autoAbilities = getenv().autoAbilities
		}

		local json = HttpService:JSONEncode(xData)
		writefile(getenv().configFolder .. getenv().saveFileName)
	end
	--#endregion

	--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
    --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

    -- Uilib Shits
	local exec = tostring(identifyexecutor())
	
	local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
	local Window = OrionLib:MakeWindow({
		Name = "Beaast Hub",
		HidePremium = true,
		SaveConfig = true,
		ConfigFolder = "Beaast Hub"
	})

	local autoFarmTab = Window:MakeTab({
		Name = "Main"
	})

	local settings = Window:MakeTab({
		Name = "Settings"
	})

	if game.PlaceId == 8304191830 then
		local unitSelectTab = autoFarmTab:AddSection({Name = "👷 Select Units"})
        local selectWorld = autoFarmTab:AddSection({Name = "🌎 Select World"})
        local devilCity = autoFarmTab:AddSection({Name = "👿 Devil City"})
        local autofarmTab = autoFarmTab:AddSection({Name = "🤖 Auto Farm"})
        local autoChallengeTab = autoFarmTab:AddSection({Name = "🎯 Auto Challenge"})

		--#region Select Units Tab
		local Units = {}

		local function loadUnits()
			repeat task.wait() until Players.LocalPlayer.PlayerGui:FindFirstChild("collection"):FindFirstChild("grid"):FindFirstChild("List"):FindFirstChild("Outer"):FindFirstChild("UnitFrames")
			task.wait(2)
			table.clear(Units)
			for i, v in pairs(Players[Players.LocalPlayer.Name].PlayerGui.collection.grid.List.Outer.UnitFrames:GetChildren()) do
				if v.Name == "CollectionUnitFrame" then
					repeat task.wait() until v:FindFirstChild("_uuid")
					table.insert(Units, v.name.Text .. " #" .. v._uuid.Value)
				end
			end
		end

		loadUnits()

		local function Check(x, y)
			for i, v in ipairs(Players.LocalPlayer.PlayerGui.collection.grid.List.Outer.UnitFrames:GetChildren()) do
				if v:IsA("ImageButton") then
					if v.EquippedList.Equipped.Visible == true then
						if v.Main.petimage:GetChildren()[2].Name == x then
							--print(v.name.Text .. " #" .. v._uuid.Value)
							getenv().SelectedUnits["U" .. tostring(y)] = tostring(v.name.Text .. " #" .. v._uuid.Value)
							updateJson()
							return true
						end
					end
				end
			end
		end

		local function Equip()
			ReplicatedStorage.endpoints.client_to_server.unequip_all:InvokeServer()

			for i = 1, 6 do
				local unitInfo = getenv().SelectedUnits["U" .. i]
				warn(unitInfo)
				if unitInfo ~= nil then
					local unitInfo_ = unitInfo:split(" #")
					task.wait(0.5)
					ReplicatedStorage.endpoints.client_to_server.equip_unit:InvokeServer(unitinfo_[2])
				end
			end
			updateJson()
		end

		unitSelectTab:AddButton({
			Name = "Select Equipped Units",
			Callback = function()
				for i, v in ipairs(Players.LocalPlayer.PlayerGui["spawn_units"].Lives.Frame.Units:GetChildren()) do
					if v:IsA("ImageButton") then
						local unitxx = v.Main.petimage.WorldModel:GetChildren()[1]
						if unitxx ~= nil then
							if Check(unitxx.Name, v) then
								print(unitxx, v)
							end
						end
					end
				end

				OrionLib:MakeNotification({
					Name = "Equipped Units Selected!",
					Content = "Dropdowns may not show but it will show next execute",
					Time = 5
				})
			end
		})

		local drop1 = unitSelectTab:AddDropdown({
			Name = "Unit 1",
			Default = Units,
			Options = getenv().SelectedUnits["U1"],
			Callback = function(bool)
				getenv().SelectedUnits["U1"] = bool
				Equip()
			end
		})

		local drop2 = unitSelectTab:AddDropdown({
			Name = "Unit 2",
			Default = Units,
			Options = getenv().SelectedUnits["U2"],
			Callback = function(bool)
				getenv().SelectedUnits["U2"] = bool
				Equip()
			end
		})

		local drop3 = unitSelectTab:AddDropdown({
			Name = "Unit 3",
			Default = Units,
			Options = getenv().SelectedUnits["U3"],
			Callback = function(bool)
				getenv().SelectedUnits["U3"] = bool
				Equip()
			end
		})

		local drop4 = unitSelectTab:AddDropdown({
			Name = "Unit 4",
			Default = Units,
			Options = getenv().SelectedUnits["U4"],
			Callback = function(bool)
				getenv().SelectedUnits["U4"] = bool
				Equip()
			end
		})

		local axx = Players.LocalPlayer.PlayerGui["spawn_units"].Lives.Main.Desc.Level.Text:split(" ")
		_G.drop5 = nil
		_G.drop6 = nil

		if tonumber(axx[2]) >= 20 then
			_G.drop5 = unitSelectTab:AddDropdown({
				Name = "Unit 5",
				Default = Units,
				Options = getenv().SelectedUnits["U5"],
				Callback = function(bool)
					getenv().SelectedUnits["U5"] = bool
					Equip()
				end
			})
		end

        if tonumber(axx[2]) >= 50 then
            _G.drop6 = unitSelectTab:AddDropdown({
				Name = "Unit 6",
				Default = Units,
				Options = getenv().SelectedUnits["U6"],
				Callback = function(bool)
					getenv().SelectedUnits["U6"] = bool
					Equip()
				end
			})
        end

--------------// Refresh Unit List \\-------------
		unitSelectTab:AddButton({
			Name = "Refresh Unit List",
			Callback = function()
				drop1:Refresh({"None"}, true)
				drop2:Refresh({"None"}, true)
				drop3:Refresh({"None"}, true)
				drop4:Refresh({"None"}, true)
				if _G.drop5 ~= nil then
					drop5:Refresh({"None"}, true)
				end
				if _G.drop6 ~= nil then
					drop6:Refresh({"None"}, true)
				end

				loadUnits()
				ReplicatedStorage.endpoints.client_to_server.unequip_all:InvokeServer()

				local unitsToAdd = {}
				for i, v in ipairs(Units) do
					table.insert(unitsToAdd, v)
				end
				
				drop1:Refresh(unitsToAdd, true)
				drop2:Refresh(unitsToAdd, true)
				drop3:Refresh(unitsToAdd, true)
				drop4:Refresh(unitsToAdd, true)
				if _G.drop5 ~= nil then
					drop5:Refresh(unitsToAdd, true)
				end
				if _G.drop6 ~= nil then
					drop6:Refresh(unitsToAdd, true)
				end

				getenv().SelectedUnits = {
					U1 = nil,
					U2 = nil,
					U3 = nil,
					U4 = nil,
					U5 = nil,
					U6 = nil,
				}
			end
		})
		--#endregion
		--------------------------------------------------
		--------------- Select World Tab -----------------
		--------------------------------------------------
		--#region Select World Tab
		getenv().levels = {"nil"}
		getenv().diff = selectWorld:AddDropdown({
			Name = "Select Difficulty",
			Default = getenv().difficulty,
			Options = {"Normal", "Hard"},
			Callback = function(diff)
				getenv().selectedDifficulty = diff
				updateJson()
			end
		})

		local worldsDropdown = selectWorld:AddDropdown({
			Name = "Select World",
			Options = {"Plannet Namak", "Shiganshinu District", "Snowy Town","Hidden Sand Village", "Marine's Ford",
			"Ghoul City", "Hollow World", "Ant Kingdom", "Magic Town", "Cursed Academy","Clover Kingdom", "Clover Legend - HARD","Hollow Legend - HARD","Cape Canaveral"},
			Default = getenv().selectedWorld,
			Callback = function(world)
				getenv().selectedWorld = world
				updateJson()

				if world == "Plannet Namak" then
					getenv().leveldrop:Refresh({"None"}, true)
					table.clear(getenv().levels)
					getenv().levels = {"namek_infinite", "namek_level_1", "namek_level_2", "namek_level_3", "namek_level_4", "namek_level_5", "namek_level_6"}
					getenv().leveldrop:Refresh(getenv().levels, true)
				elseif world == "Shiganshinu District" then
					getenv().leveldrop:Refresh({"None"}, true)
					table.clear(getenv().levels)
					getgenv().levels = {"aot_infinite", "aot_level_1", "aot_level_2", "aot_level_3", "aot_level_4", "aot_level_5", "aot_level_6"}
					getenv().leveldrop:Refresh(getenv().levels, true)
				elseif world == "Snowy Town" then
					getenv().leveldrop:Refresh({"None"}, true)
					table.clear(getenv().levels)
					getgenv().levels = {"demonslayer_infinite", "demonslayer_level_1", "demonslayer_level_2","demonslayer_level_3", "demonslayer_level_4", "demonslayer_level_5", "demonslayer_level_6"}
					getenv().leveldrop:Refresh(getenv().levels, true)
				end
			end
		})
		--#endregion
	end
end