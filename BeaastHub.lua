repeat task.wait() until game:IsLoaded()
local placeID = game.PlaceId

-- // ANTI-AFK \\ --
local VirtualUser = game:GetService('VirtualUser')
game:GetService('Players').LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

-- // SLIME TOWER TYCOON \\ --
if placeID == 10675066724 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Beaast-exe/Roblox/master/scripts/SlimeTowerTycoon.lua"))()
-- // RACE CLICKER \\ --
elseif placeID == 9285238704 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Beaast-exe/Roblox/master/scripts/RaceClicker.lua"))()
-- // IDLE HEROES SIMULATOR \\ --
elseif placeID == 9264596435 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Beaast-exe/Roblox/master/scripts/IdleHeroesSimulator.lua"))()
end