repeat task.wait() until game:IsLoaded()

local FreeAutoClick = game:GetService("Players").LocalPlayer.PlayerGui.BottomUI.FreeAutoClick
local AutoClick = game:GetService("Players").LocalPlayer.PlayerGui.BottomUI.AutoClick
local freeAutoClickStatus = false
game:GetService("Players").LocalPlayer.PlayerGui.BottomUI.BuyGamepass:Destroy()

function updateFreeAutoClickStatus()
	if FreeAutoClick.Toggle.Text == "ON" then
		freeAutoClickStatus = true
	end
end

while task.wait(1) do
	updateFreeAutoClickStatus()

	if freeAutoClickStatus == true then
		AutoClick.Toggle.Text = FreeAutoClick.Toggle.Text
		AutoClick.UIGradient.Color = FreeAutoClick.UIGradient.Color
		AutoClick.Toggle.UIGradient.Color = FreeAutoClick.Toggle.UIGradient.Color
		AutoClick.Icon.Image = FreeAutoClick.Icon.Image
		
		repeat task.wait() until FreeAutoClick.Toggle.Text ~= AutoClick.Toggle.Text

		FreeAutoClick:Destroy()
		break
	end
end