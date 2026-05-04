local Services, Objects, Values, Functions, Loops = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
}, {
    FOV_Circle = Drawing.new("Circle"),

    Camera = workspace.CurrentCamera,

    Player = nil,
    Mouse = nil,
}, {
    SilentAim = false,
}, {}, {}

Objects.FOV_Circle.Color = Color3.fromRGB(255,255,255)
Objects.FOV_Circle.Thickness = 1
Objects.FOV_Circle.Radius = 100
Objects.FOV_Circle.Visible = false
Objects.FOV_Circle.Filled = false

----------------------------------------------------------------------------------------------------------

function Functions.Init(Tab)
    Objects.Player = Services.Players.LocalPlayer
    Objects.Mouse = Objects.Player:GetMouse()

    Objects["SilentAim_Section"] = MainTab:CreateSection("Silent Aim")

    Objects["SilentAim_Toggle"] = MainTab:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Flag = "SilentAim_Toggle",
        Callback = function(Value)
            Values.SilentAim = Value
        end,
    })

    Objects["FOVCircle_Toggle"] = MainTab:CreateToggle({
        Name = "FOV Circle",
        CurrentValue = false,
        Flag = "FOVCircle_Toggle",
        Callback = function(Value)
            Objects.FOV_Circle.Visible = Value
        end,
    })

    Objects["FOVSize_Slider"] = MainTab:CreateSlider({
        Name = "FOV Circle Size",
        Range = {50, 250},
        Increment = 2,
        Suffix = "Circle Size",
        CurrentValue = 100,
        Flag = "FOVSize_Slider", 
        Callback = function(Value)
            Objects.FOV_Circle.Radius = Value
        end,
    })

    Objects["FOVThickness_Slider"] = MainTab:CreateSlider({
        Name = "FOV Thickness Size",
        Range = {1, 5},
        Increment = 1,
        Suffix = "Circle Thickness",
        CurrentValue = 1,
        Flag = "FOVThickness_Slider", 
        Callback = function(Value)
            Objects.FOV_Circle.Thickness = Value
        end,
    })

    Objects["FOVColor_Picker"] = MainTab:CreateColorPicker({
        Name = "FOV Circle Color",
        Color = Color3.fromRGB(255,255,255),
        Flag = "FOVColor_Picker", 
        Callback = function(Value)
            Objects.FOV_Circle.Color = Value
        end
    })

    services.RunService.Heartbeat:connect(function()
        if Objects.FOV_Circle.Visible then
           Objects.FOV_Circle.Position = Vector2.new(Objects.Mouse.X, Objects.Mouse.Y + 37)
        end

        if Values.SilentAim then
            local ClosestToMouse = Functions.ClosestPlayerToMouse()

            if ClosestToMouse then
                task.wait(0.05)

                for i,v in pairs(services.Workspace.KnifeHost:GetDescendants()) do
                    if v:IsA("Part") and Values.SilentAim == true then
                        v.CFrame = ClosestToMouse.Head.CFrame
                    end
                end
            else 
                return 
            end
        end
    end)
end

----------------------------------------------------------------------------------------------------------

function Functions.ClosestPlayerToMouse()
    local closest = nil
    local distance = 9e9

    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= player then
            local character = Services.Workspace:FindFirstChild(p.Name)

            if character then
                local head = character:FindFirstChild("HumanoidRootPart")

                if head then
                    local screenPos, onScreen = Objects.Camera:WorldToScreenPoint(head.Position)

                    if onScreen then
                        local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Objects.Mouse.X, Objects.Mouse.Y)).Magnitude

                        if magnitude < distance and magnitude < Objects.FOV_Circle.Radius then
                            closest = character
                            distance = magnitude
                        end
                    end
                end
            end
        end
    end
    return closest
end

----------------------------------------------------------------------------------------------------------

return Functions