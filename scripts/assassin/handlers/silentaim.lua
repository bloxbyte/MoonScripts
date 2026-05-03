local Services, Objects, Functions, Loops = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
}, {
    FOV_Circle = Drawing.new("Circle"),

    Player = nil,
    Mouse = nil,
}, {}, {}

Objects.FOV_Circle.Color = _G.Values.FOV_Color
Objects.FOV_Circle.Thickness = _G.Values.FOV_Thickness
Objects.FOV_Circle.Radius = _G.Values.FOV_Size
Objects.FOV_Circle.Visible = _G.Values.FOV_Circle
Objects.FOV_Circle.Filled = false

----------------------------------------------------------------------------------------------------------

function Functions.Init()
    Objects.Player = Services.Players.LocalPlayer
    Objects.Mouse = Objects.Player:GetMouse()

    services.RunService.Heartbeat:connect(function()
        if _G.Values.SilentAim then
            local ClosestToMouse = Functions.ClosestPlayerToMouse()

            if ClosestToMouse then
                task.wait(0.05)

                for i,v in pairs(services.Workspace.KnifeHost:GetDescendants()) do
                    if v:IsA("Part") and _G.Values.SilentAim == true then
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

    for _, p in pairs(services.Players:GetPlayers()) do
        if p ~= player then
            local character = services.Workspace:FindFirstChild(p.Name)

            if character then
                local head = character:FindFirstChild("HumanoidRootPart")

                if head then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)

                    if onScreen then
                        local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                        if magnitude < distance and magnitude < components["FOV_Circle"].Radius then
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

Functions.Init()

task.spawn(function()
    while task.wait(1) do
        Objects.FOV_Circle.Color = _G.Values.FOV_Color
        Objects.FOV_Circle.Thickness = _G.Values.FOV_Thickness
        Objects.FOV_Circle.Radius = _G.Values.FOV_Size
        Objects.FOV_Circle.Visible = _G.Values.FOV_Circle
    end
end)