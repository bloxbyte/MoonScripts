local ESP_Module = loadstring(game:HttpGet("https://moonscripts.live/scripts/assassin/libraries/esp.lua"))()

local Services, Objects, Values, Functions, Loops = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}, {
    Camera = workspace.CurrentCamera,
    Enemy = ESP_Module.teamSettings.enemy,

    Storage = Instance.new("Folder")
}, {
    Chams = false,
    TargetChams = false,

    ChamsColor = Color3.fromRGB(255,255,255),
    TargetChamsColor = Color3.fromRGB(255,0,0)
}, {}, {}

Objects.Storage.Name = "Highlight_Storage"
Objects.Storage.Parent = Services.CoreGui

----------------------------------------------------------------------------------------------------------

Objects.Enemy.enabled = false
Objects.Enemy.box = false
Objects.Enemy.boxFill = false
Objects.Enemy.tracer = false
Objects.Enemy.name = false

ESP_Module.Load()

ESP_Module.getCharacter = function(plr)
    return plr and Services.Workspace:FindFirstChild(plr.Name)
end

----------------------------------------------------------------------------------------------------------

function Functions.Highlight(Player)
    if Values.Chams then
        local Highlight = Instance.new("Highlight")
        Highlight.Name = plr.Name
        Highlight.FillColor = Values.ChamsColor
        Highlight.DepthMode = DepthMode
        Highlight.FillTransparency = FillTransparency
        Highlight.OutlineColor = Values.ChamsColor
        Highlight.OutlineTransparency = 0
        Highlight.Parent = Storage

        if Player.Character then
            Highlight.Adornee = Player.Character
        end

        Loops[Player] = Player.CharacterAdded:Connect(function(character)
            Highlight.Adornee = character
        end)
    end
end


function Functions.GetTarget()
    local TargetName = Objects.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("UI").Target.TargetText
    local Target = Services.Players:FindFirstChild(TargetName.Text)

    return Target
end

function Functions.CheckChams() 
    if Values.Chams then
        if Values.TargetChams then
            local Target = Functions.GetTarget()

            if not Target then
                for _, part in pairs(Objects.Storage:GetChildren()) do
                    if part:IsA("Highlight") and part.FillColor ~= _G.Values.ChamsColor then
                        part.FillColor = _G.Values.ChamsColor
                        part.OutlineColor = _G.Values.ChamsColor
                    end
                end
            end

            if Objects.Storage:FindFirstChild(Target) and Objects.Storage:FindFirstChild(Target).IsA("Highlight") then
                local Highlight = Objects.Storage:FindFirstChild(Target)

                if Highlight.FillColor ~= Values.TargetChamsColor then
                    Highlight.FillColor = Values.TargetChamsColor
                    Highlight.OutlineColor = Values.TargetChamsColor
                end
            end
        end

        for _, part in pairs(Objects.Storage:GetChildren()) do
            if part:IsA("Highlight") and part.FillColor ~= Values.ChamsColor then
                part.FillColor = Values.ChamsColor
                part.OutlineColor = Values.ChamsColor
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

    if Loops[Player] then
        Loops[Player]:Disconnect()
        Loops[Player] = nil
    end
end)

for _, player in pairs(Services.Players:GetPlayers()) do
    Functions.Highlight(player)
end

----------------------------------------------------------------------------------------------------------

function Functions.Init(MainTab)
    Objects["ESP_Section"] = Objects["MainTab"]:CreateSection("ESP")

    Objects["PlayerESP_Toggle"] = Objects["MainTab"]:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "PlayerESP_Toggle",
        Callback = function(Value)
            Objects.Enemy.enabled = Value
        end,
    })

    Objects["BoxESP_Toggle"] = Objects["MainTab"]:CreateToggle({
        Name = "Box ESP",
        CurrentValue = false,
        Flag = "BoxESP_Toggle",
        Callback = function(Value)
            Objects.Enemy.box = Value
        end,
    })

    Objects["BoxFillESP_Toggle"] = Objects["MainTab"]:CreateToggle({
        Name = "Box Fill ESP",
        CurrentValue = false,
        Flag = "BoxFillESP_Toggle",
        Callback = function(Value)
            Objects.Enemy.boxFill = Value
        end,
    })

    Objects["NameESP_Toggle"] = Objects["MainTab"]:CreateToggle({
        Name = "Name ESP",
        CurrentValue = false,
        Flag = "NameESP_Toggle",
        Callback = function(Value)
            Objects.Enemy.name = Value
        end,
    })

    Objects["TracerESP_Toggle"] = Objects["MainTab"]:CreateToggle({
        Name = "Tracer ESP",
        CurrentValue = false,
        Flag = "TracerESP_Toggle",
        Callback = function(Value)
            Objects.Enemy.tracer = Value
        end,
    })

    Objects["Chams_Section"] = Objects["MainTab"]:CreateSection("Chams")

    Objects["NormalChams_Toggle"] = Objects["MainTab"]:CreateToggle({
        Name = "Player Chams",
        CurrentValue = false,
        Flag = "NormalChams_Toggle",
        Callback = function(Value)
            Values.Chams = Value

            for i, player in ipairs(Players:GetPlayers()) do
                Functions.Highlight(player)
            end
        end,
    })

    Objects["TargetChams_Toggle"] = Objects["MainTab"]:CreateToggle({
        Name = "Target Chams",
        CurrentValue = false,
        Flag = "TargetChams_Toggle",
        Callback = function(Value)
            Values.TargetChams = Value
        end,
    })

    Objects["PlayerChams_Picker"] = Objects["MainTab"]:CreateColorPicker({
        Name = "Player Chams Color",
        Color = Color3.fromRGB(255,255,255),
        Flag = "PlayerChams_Picker", 
        Callback = function(Value)
            Values.ChamsColor = Value
        end
    })

    Objects["TargetChams_Picker"] = Objects["MainTab"]:CreateColorPicker({
        Name = "Target Chams Color",
        Color = Color3.fromRGB(255,0,0),
        Flag = "TargetChams_Picker", 
        Callback = function(Value)
            Values.TargetChamsColor = Value
        end
    })
end

----------------------------------------------------------------------------------------------------------

local Frame = Services.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("UI").Target

Services.RunService.Heartbeat:Connect(function()
    if Values.TargetChams == true then
        if Frame.Visible == true then
            local Text = Frame.TargetText.Text

            if Services.Players:FindFirstChild(Text) then
                local Object = Objects.Storage:FindFirstChild(Text)
                local Player = Services.Players:FindFirstChild(Text)
                
                if Object then
                    local Highlight = Objects.Storage:FindFirstChild(Text):IsA("Highlight") and Object or nil
                    
                    if Highlight.FillColor ~= Values.TargetChamsColor then
                        Highlight.FillColor = Values.TargetChamsColor
                        Highlight.OutlineColor = Values.TargetChamsColor
                    end
                else
                    Functions.Highlight(Player, "Target")

                    for _, Highlight in pairs(Objects.Storage:GetChildren()) do
                        if Highlight:IsA("Highlight") and Highlight.Name ~= Text then
                            if Values.Chams then
                                Highlight.FillColor = Values.ChamsColor
                                Highlight.OutlineColor = Values.ChamsColor
                            else
                                Highlight:Destroy()

                                if Loops[Highlight.Name] ~= nil then
                                    Loops[Highlight.Name]:Disconnect()
                                    Loops[Highlight.Name] = nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if Values.Chams == false then
        for _, Highlight in pairs(Objects.Storage:GetChildren()) do
            if Highlight:IsA("Highlight") then
                if Highlight.FillColor == Values.ChamsColor then
                    Highlight:Destroy()
                end
            end
        end
    else
         for _, Highlight in pairs(Objects.Storage:GetChildren()) do
            if Highlight:IsA("Highlight") then
                if Highlight.FillColor ~= Values.ChamsColor and Frame.TargetText.Text ~= Highlight.Name then
                    Highlight.FillColor = Values.ChamsColor
                    Highlight.OutlineColor = Values.ChamsColor
                end
            end
        end
    end
end)

return Functions