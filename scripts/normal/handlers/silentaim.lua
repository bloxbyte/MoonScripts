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



----------------------------------------------------------------------------------------------------------