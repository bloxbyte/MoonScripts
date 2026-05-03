local Services, Objects, Constants, Functions = {
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService"),
}, {
    Camera = Services.Workspace.CurrentCamera,
    VotePad = Services.Workspace:WaitForChild("Lobby", 10):WaitForChild("VoteStation", 10):WaitForChild("pad3", 10).Position,
    
    Player = nil, 
    Character = nil,
    Root = nil,
    Humanoid = nil,
       
    CameraSet = false,
    Cooldown = false,

    Target = nil,
    TargetCharacter = nil,
    TargetRootPart = nil,
    StabTarget = nil,
    ClosestPlayer = nil,

    UI = nil,
    TargetFrame = nil,
    TargetVisible = false,
    TargetText = nil,
    GameModeLabel = nil,
}, {
    TPTweenInfo = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
    TPOffset = CFrame.new(-2, -5, 1.6),
}

local GameModes, ModeMessages = {
    Juggernaut = false,
    JuggernautEnemy = false,
    Infection = false,
    Infected = false,
    FFA = false,
}, {
    ["Team up to defeat the Juggernaut!"]          = "JuggernautEnemy",
    ["You are the Juggernaut! Eliminate all players!"] = "Juggernaut",
    ["No targets. Last one standing wins."]        = "FFA",
    ["Protect yourself from the Infected!"]        = "Infection",
    ["You are Infected! Hunt the surviving players."]  = "Infected",
}

local FFC = function(instance, name) return instance:FindFirstChild(name) end,
local FFCWhichIsA = function(instance, class) return instance:FindFirstChildWhichIsA(class) end,

----------------------------------------------------------------------------------------------------------

function Functions.HasTool()
    local backpack = Objects.Player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChildWhichIsA("Tool") then return true end

    if Objects.Character and Objects.Character:FindFirstChildWhichIsA("Tool") then return true end
    return false
end

----------------------------------------------------------------------------------------------------------

function Functions.Init()
    Objects.Player = Services.Players.LocalPlayer
    
    Objects.UI = Objects.Player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("UI")
    Objects.TargetFrame = Objects.UI.Target
    Objects.TargetText = Objects.TargetFrame.TargetText
    Objects.TargetVisible = Objects.TargetFrame.Visible
    Objects.GameModeLabel = Objects.Player.PlayerGui.ScreenGui.UI.GamemodeMessage.TextLabel
    Objects.Target = Objects.TargetVisible and Services.Players:FindFirstChild(Objects.TargetText.Text)

    Functions.InitCharacter(Objects.Player.Character)
    Objects.Player.CharacterAdded:Connect(Functions.InitCharacter)

    Objects.TargetFrame.Changed:Connect(function()
        Objects.TargetVisible = Objects.TargetFrame.Visible
    end)

    Objects.TargetText.Changed:Connect(function()
        Objects.Target = FFC(Objects.Players, Objects.TargetText.Text)
    end)

    Objects.GameModeLabel.Changed:Connect(function()
        local modeType = Objects.ModeMessages[Objects.GameModeLabel.Text]
        for mode in pairs(Objects.GameModes) do Objects.GameModes[mode] = false end
        if modeType then Objects.GameModes[modeType] = true end
    end)

    if _G.AutoFarmLoop then 
        _G.AutoFarmLoop:Disconnect()
        _G.AutoFarmLoop = nil
    end

    _G.AutoFarmLoop = Services.RunService.Heartbeat:Connect(function()  Functions.OnHeartbeat()  end)

    task.spawn(function()
        Services.RunService.Stepped:Connect(function()  Functions.OnStepped()  end)
    end)
end

function Functions.InitCharacter(Character)
    if Character and typeof(Character) == "Instance" then
        Objects.Character = Character
        Objects.Root = Character:WaitForChild("HumanoidRootPart")
        Objects.Humanoid = Character:WaitForChild("Humanoid")
    end
end

----------------------------------------------------------------------------------------------------------

function Functions.OnStepped()

end

function Functions.OnHeartbeat()

end