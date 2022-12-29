local Notify
local utils = {
    init = function()
        local NotificationHolder = Instance.new("ScreenGui")
        NotificationHolder.Name = "notiHolder"
        NotificationHolder.Parent = game.CoreGui
        NotificationHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local NotificationFrame = game:GetObjects("rbxassetid://6924028278")[1]
        NotificationFrame.ZIndex = 4
        NotificationFrame.Parent = NotificationHolder
        script = NotificationFrame.NotifScript
        Notify = loadstring(NotificationFrame.NotifScript.Source)()
    end,
    warn = function(method, ...)
        Notify:New("Cranium Debug - "..method, ...)
    end,
    newWindow = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/sol"))
}

function loadFileSystem()
    if not isfolder("Cranium") then
        makefolder("Cranium")
    end
end

loadFileSystem()

return utils