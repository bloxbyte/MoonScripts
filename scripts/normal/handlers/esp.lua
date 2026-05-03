local ESP_Module = loadstring(game:HttpGet("https://moonscripts.live/scripts/normal/libraries/esp.lua"))()

local Services, Objects, Functions, Loops = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}, {
    Camera = workspace.CurrentCamera,
    Enemy = ESP_Module.teamSettings.enemy

    Storage = Instance.new("Folder", Services.CoreGui),
}, {}, {}

Objects.Storage.Name = "Highlight_Storage"

----------------------------------------------------------------------------------------------------------

Objects.Enemy.enabled = _G.Values.ESP
Objects.Enemy.box = _G.Values.BoxESP
Objects.Enemy.boxFill = _G.Values.BoxFillESP
Objects.Enemy.tracer = _G.Values.TracerESP
Objects.Enemy.name = _G.Values.NameESP

ESP_Module.Load()

ESP_Module.getCharacter = function(plr)
    return plr and services.Workspace:FindFirstChild(plr.Name)
end

----------------------------------------------------------------------------------------------------------

function Functions.Highlight(Player)
    if _G.Values.Chams then
        local Highlight = Instance.new("Highlight")
        Highlight.Name = plr.Name
        Highlight.FillColor = _G.Values.ChamsColor
        Highlight.DepthMode = DepthMode
        Highlight.FillTransparency = FillTransparency
        Highlight.OutlineColor = _G.Values.ChamsColor
        Highlight.OutlineTransparency = 0
        Highlight.Parent = Storage

        if Player.Character then
            Highlight.Adornee = Player.Character
        end

        Connections[Player] = Player.CharacterAdded:Connect(function(character)
            Highlight.Adornee = character
        end)
    end
end


function Functions.GetTarget()
    local TargetName = Objects.TargetText.Text
    local Target = Services.Players:FindFirstChild(TargetName)

    return Target
end

function Functions.CheckChams() 
    if _G.Values.Chams then
        if _G.Values.TargetChams then
            local Target = Functions.GetTarget()

            if not Target then
                for _, part in pairs(Objects.Storage:GetChildren()) do
                    if part:IsA("Highlight") and part.FillColor == _G.Values.TargetChamsColor then
                        part.FillColor = _G.Values.ChamsColor
                        part.OutlineColor = _G.Values.ChamsColor
                    end
                end
            end

            if Objects.Storage:FindFirstChild(Target) and Objects.Storage:FindFirstChild(Target).IsA("Highlight") then
                local Highlight = Objects.Storage:FindFirstChild(Target)

                if Highlight.FillColor ~= _G.Values.TargetChamsColor then
                    Highlight.FillColor = _G.Values.TargetChamsColor
                    Highlight.OutlineColor = _G.Values.TargetChamsColor
                end
            end
        end

        if #Objects.Storage:GetChildren() == 0 then
            for _, player in pairs(Services.Players:GetPlayers()) do
                Functions.Highlight(player)
            end
        end

        return
    end

    for _, part in pairs(Objects.Storage:GetChildren()) do
        if part:IsA("Highlight") then
            part:Destroy()
        end
    end
end

----------------------------------------------------------------------------------------------------------

Services.Players.PlayerAdded:Connect(function(Player)
    Functions.Highlight(Player)
end)

Services.Players.PlayerRemoving:Connect(function(Player)
    local highlight = Objects.Storage:FindFirstChild(Player.Name)

    if highlight then
        highlight:Destroy()
    end

    if Connections[Player] then
        Connections[Player]:Disconnect()
        Connections[Player] = nil
    end
end)

for _, player in pairs(Services.Players:GetPlayers()) do
    Functions.Highlight(player)
end

----------------------------------------------------------------------------------------------------------

task.spawn(function()
    while task.wait(1) do
        Functions.CheckChams()
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        Objects.Enemy.enabled = _G.Values.ESP
        Objects.Enemy.box = _G.Values.BoxESP
        Objects.Enemy.boxFill = _G.Values.BoxFillESP
        Objects.Enemy.tracer = _G.Values.TracerESP
        Objects.Enemy.name = _G.Values.NameESP
    end
end)