local ESP_Module = loadstring(game:HttpGet("https://gist.githubusercontent.com/LuvNarcc/0bae8ec0f5ff7a40af447a3520dc029d/raw/fb3a9620e26247e70546704af3fa08c419ce4b4d/Assassin-ESP.lua"))()

local Services, Objects, Values, Functions, Loops = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}, {
    Camera = workspace.CurrentCamera,
    Storage = Instance.new("Folder")
}, {
    Chams = false,
    TargetChams = false,

    ChamsColor = Color3.fromRGB(255,255,255),
    TargetChamsColor = Color3.fromRGB(255,0,0)
}, {}, {}

Objects.Storage.Name = "Highlight_Storage"
Objects.Storage.Parent = Services.CoreGui

ESP_Module.Cfg.FPS = 40

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
    Objects["ESP_Section"] = MainTab:CreateSection("ESP")

    Objects["PlayerESP_Toggle"] = MainTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "PlayerESP_Toggle",
        Callback = function(Value)
            ESP_Module.Cfg.Enabled = Value
        end,
    })

    Objects["BoxESP_Toggle"] = MainTab:CreateToggle({
        Name = "Box ESP",
        CurrentValue = false,
        Flag = "BoxESP_Toggle",
        Callback = function(Value)
            ESP_Module.Cfg.Boxes = Value
        end,
    })

    Objects["SkeletonESP_Toggle"] = MainTab:CreateToggle({
        Name = "Skeleton ESP",
        CurrentValue = false,
        Flag = "SkeletonESP_Toggle",
        Callback = function(Value)
            ESP_Module.Cfg.Skeleton = Value
        end,
    })

    Objects["NameESP_Toggle"] = MainTab:CreateToggle({
        Name = "Name ESP",
        CurrentValue = false,
        Flag = "NameESP_Toggle",
        Callback = function(Value)
            ESP_Module.Cfg.Names = Value
        end,
    })

    Objects["TracerESP_Toggle"] = MainTab:CreateToggle({
        Name = "Tracer ESP",
        CurrentValue = false,
        Flag = "TracerESP_Toggle",
        Callback = function(Value)
            ESP_Module.Cfg.Tracers = Value
        end,
    })

    Objects["Chams_Section"] = MainTab:CreateSection("Chams")

    Objects["NormalChams_Toggle"] = MainTab:CreateToggle({
        Name = "Player Chams",
        CurrentValue = false,
        Flag = "NormalChams_Toggle",
        Callback = function(Value)
            Values.Chams = Value

            for i, player in ipairs(Services.Players:GetPlayers()) do
                Functions.Highlight(player)
            end
        end,
    })

    Objects["TargetChams_Toggle"] = MainTab:CreateToggle({
        Name = "Target Chams",
        CurrentValue = false,
        Flag = "TargetChams_Toggle",
        Callback = function(Value)
            Values.TargetChams = Value
        end,
    })

    Objects["PlayerChams_Picker"] = MainTab:CreateColorPicker({
        Name = "Player Chams Color",
        Color = Color3.fromRGB(255,255,255),
        Flag = "PlayerChams_Picker", 
        Callback = function(Value)
            Values.ChamsColor = Value
        end
    })

    Objects["TargetChams_Picker"] = MainTab:CreateColorPicker({
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