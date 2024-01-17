if game.placeId ~= 14433762945 then return end
repeat task.wait() until game:IsLoaded()
local StartTick = tick()

local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

local Window = Library:CreateWindow({ Title = 'Beaast Hub | Anime Champions Simulator', Center = true, AutoShow = true })
local Tabs = {
	['Main'] = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

game:GetService("Players").LocalPlayer:WaitForChild('PlayerGui')
game:GetService("Players").LocalPlayer:WaitForChild('MainGui')

local Settings = {
	['AutoFarm'] = {
		['Enabled'] = false,
		['World'] = 'Green Planet',
		['Enemies'] = {},
		['Auto Join World'] = false,
		['Teleport [Farm in Range]'] = false,
		['Range [Farm in Range]'] = 150
	},
	['Raids'] = {
		['Enabled'] = false,
		['Private'] = false,
		['World'] = 'Green Planet',
		['Difficulty'] = 'Easy',
		['Collect Chest'] = false,
		['TP to Mob Head'] = false
	},
	['Items'] = {
		['Auto Scrap Skin'] = false,
		['Auto Scrap Rarities'] = {},
		['Ignore Types'] = {}
	},
	['Tower'] = {
		['Enabled'] = false,
		['Collect Chest'] = false
	},
	['Misc'] = {
		['Auto Click'] = false,
		['Auto Ability'] = false,
		['Auto Collect'] = false,
		['Instant Tp'] = false,
		['Bypass Attack Range'] = false,
		['Auto Collect Spirit'] = false,
		['TP to Spirit World'] = false
	},
	['Orbs'] = {
		['Orb'] = 'Dragon Orb',
		['Amount'] = 1,
		['Enabled'] = false,
		['TP to Orb'] = false
	},
	['Pets'] = {
		['Selected Pet'] = '',
		['Selected Rarities'] = {'Common'},
		['Auto Feed'] = false,

		['Selected Pet [Quirk]'] = '',
		['Selected Rarity'] = {},
		['Selected Slot'] = 1,
		['Premium  Medal'] = false,
		['Auto Reroll Quirks'] = false,

		['Selected Talent'] = {},
		['Selected Pet [Talent]'] = '',
		['Auto Reroll Talent'] = false,

		['Selected Rarities [Essence]'] = {},
		['Auto Essence'] = false,
		['Ignore Godly [Essence]'] = false
	},
	['Settings'] = {
		['menuKeybind'] = 'LeftShift',
		['FPS Value'] = 60,
		['FPS Cap'] = false,
		['Low CPU'] = false
	},
	watermark = false,
	webhookLink = 'Webhook Link',
	webhookMentionId = 'Mention ID'
}

local saveFolderName = 'BeaastHub'
local gameFolderName = 'AnimeChampions'
local saveFileName = Players.LocalPlayer.Name .. '.json'
local saveFile = saveFolderName .. '/' .. gameFolderName .. '/' .. saveFileName

function Load()
	if readfile and writefile and isfile and isfolder then
		if not isfolder(saveFolderName) then
			makefolder(saveFolderName)
		end

		if not isfolder(saveFolderName .. '/' .. gameFolderName) then
			makefolder(saveFolderName .. '/' .. gameFolderName)
		end

		if not isfile(saveFile) then
			writefile(saveFile, game:GetService('HttpService'):JSONEncode(Settings))
		else
			local Decode = game:GetService('HttpService'):JSONDecode(readfile(saveFile))

			for i, v in pairs(Decode) do
				Settings[i] = v
			end
		end
	else
		warn('Beaast Hub - Failed Loading')
		return false
	end
end

function Save()
	if readfile and writefile and isfile then
		if isfile(saveFile) == false then
			Load()
		else
			local Decode = game:GetService('HttpService'):JSONDecode(readfile(saveFile))
			local Array = {}

			for i, v in pairs(Settings) do
				Array[i] = v
			end

			writefile(saveFile, game:GetService('HttpService'):JSONEncode(Array))
		end
	else
		warn('Beaast Hub - Failed Saving')
		return false
	end
end

Load()
Save()

------------------------------------------------------ [[ Values ]] ------------------------------------------------------
local LocalPlayer = game:GetService('Players').LocalPlayer
local VirtualUser = game:GetService('VirtualUser')

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

