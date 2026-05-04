local Services, Objects, Constants, Functions = {
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
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
}, {}

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
    local Backpack = Objects.Player:FindFirstChild("Backpack")
    if Backpack and Backpack:FindFirstChildWhichIsA("Tool") then return true end

    if Objects.Character and Objects.Character:FindFirstChildWhichIsA("Tool") then return true end
    return false
end

function Functions.GetSpecialRoundRoles()
    local Infected, Juggernauts = {}, {}

    for _, Player in ipairs(Services.Players:GetPlayers()) do
        if Player == Objects.Player then continue end
        local Character = FFC(workspace, Player.Name)

        local Head = Character and FFC(Character, "Head")
        if not Head then continue end

        local ZombBox = FFCWhichIsA(Head, "SelectionBox")
        if not ZombBox then continue end

        local Root = FFC(Character, "HumanoidRootPart")
        if not Root then continue end

        if (Objects.VotePad - Root.Position).Magnitude <= 300 then continue end

        local Color = ZombBox.Color3
        if Color == Color3.fromRGB(85, 170, 0) then
            table.insert(Infected, Player)
        elseif Color == Color3.fromRGB(110, 0, 255) then
            table.insert(Juggernauts, Player)
        end
    end

    return Infected, Juggernauts
end

function Functions.GetClosestPlayer()
    local Closest, MaxDistance = nil, nil

    for _, Player in next, Services.Players:GetPlayers() do
        if Player == Objects.Player or not Objects.Root then continue end

        local Character = FFC(workspace, Player.Name)
        local Root = Character and FFC(Character, "HumanoidRootPart")
        local Humanoid = Root and FFC(Character, "Humanoid")

        if Humanoid and Humanoid.Health > 0 then
            if (Objects.VotePad - Root.Position).Magnitude > 300 then
                local Distance = (Objects.Root.Position - Root.Position).Magnitude

                if not Closest or Distance < MaxDistance then
                    Closest, MaxDistance = Player, Distance
                end
            end
        end
    end

    return Closest
end

function Functions.GetClosestFromList(List)
    local Closest, ClosestDistance = nil, math.huge

    for _, Player in ipairs(List) do
        local Character = FFC(workspace, Player.Name)
        local Root = Character and FFC(Character, "HumanoidRootPart")

        if Root and Objects.Root then
            if (Objects.VotePad - Root.Position).Magnitude <= 300 then continue end
            local Distance = (Root.Position - Objects.Root.Position).Magnitude

            if Distance < ClosestDistance then
                ClosestDistance, Closest = Distance, Player
            end
        end
    end

    return Closest
end

function Functions.ResolveTarget(Infected, Juggernauts)
	Objects.Target = nil

	if GameModes.FFA then
		Objects.Target = _G.Values.FFA_AutoFarm and Objects.ClosestPlayer or nil
	elseif GameModes.Juggernaut then
		Objects.Target = _G.Values.JuggernautAutoFarm and Objects.ClosestPlayer or nil
	elseif GameModes.JuggernautEnemy then
		Objects.Target = _G.Values.JuggernautAutoFarm and (#Juggernauts > 0 and Functions.GetClosestFromList(Juggernauts)) or nil
	elseif GameModes.Infection then
		Objects.Target = _G.Values.InfectionAutoFarm and (#Infected > 0 and Functions.GetClosestFromList(Infected)) or nil
	elseif GameModes.Infected then
		if _G.Values.InfectionAutoFarm then
			local InfectedSet, Survivors = {}, {}

			for _, p in ipairs(Infected) do InfectedSet[p] = true end
			for _, p in ipairs(Services.Players:GetPlayers()) do
				if p ~= Objects.Player and not InfectedSet[p] then
					table.insert(Survivors, p)
				end
			end

			Objects.Target = #Survivors > 0 and Functions.GetClosestFromList(Survivors) or nil
		end
	else
		Objects.Target = Objects.TargetVisible and FFC(Services.Players, Objects.TargetText.Text) or nil
	end
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

    if _G.GhostCoinsLoop then
        _G.GhostCoinsLoop:Disconnect()
        _G.GhostCoinsLoop = nil
    end

    _G.GhostCoinsLoop = Objects.Player.CharacterAdded:Connect(function()
        if if _G.Values.GhostCoins == true then
            Services.ReplicatedStorage.Remotes.RequestGhostSpawn:InvokeServer()
        end

        task.spawn(function()
            Services.RunService.Heartbeat:Connect(function()
                if _G.Values.GhostCoins == true then
                    for i,v in pairs(Services.Workspace.GhostCoins:GetDescendants()) do
                        if v:IsA("TouchTransmitter") then
                            firetouchinterest(player.Character.HumanoidRootPart, v.Parent, 0) 
                            task.wait()
                            firetouchinterest(player.Character.HumanoidRootPart, v.Parent, 1)
                        end 
                    end
                end
            end)
        end)
    end)

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
    if not Functsions.HasTool() then return end

    if Objects.Player.Character and not Objects.Cooldown and Objects.StabTarget and _G.Values.AutoFarm then
        pcall(function()
            local Head = Objects.StabTarget and Objects.StabTarget:FindFirstChild("Head")
            if not Head then return end

            if Objects.Player:DistanceFromCharacter(Head.Position) <= 6.5 then
                local Scripts = Objects.Player:FindFirstChild("PlayerScripts")
                local Handler = Scripts and Scripts:FindFirstChild("localknifehandler")
                local HitCheck = Handler and Handler:FindFirstChild("HitCheck")
                
                if not HitCheck then return end
                HitCheck:Fire(Objects.StabTarget)

                coroutine.wrap(function()
                    Objects.Cooldown = true

                    task.wait(0.75)
                    Objects.Cooldown = false
                end)()
            end
        end)
    end
end

function Functions.OnHeartbeat()
    if not _G.Values.AutoFarm then
        Services.Workspace.Gravity = 196.2

        if Objects.CameraSet then
            Objects.Camera.CameraType = Enum.CameraType.Custom
            Objects.Camera.CameraSubject = Objects.LocalHumanoid

            Objects.CameraSet = false
        end

        return
    end

    if not Functions.HasTool() then return end
    if not Objects.Root then return end

    Objects.ClosestPlayer = Functions.GetClosestPlayer()

    local InsideLobby = (Objects.VotePad - Objects.Root.Position).Magnitude <= 300
    Services.Workspace.Gravity = InsideLobby and 196.2 or 0

    local Infected, Juggernauts = Functions.GetSpecialRoundRoles()
    Functions.ResolveTarget(Infected, Juggernauts)

    local IsSpecialRound = GameModes.Juggernaut or GameModes.JuggernautEnemy
        or GameModes.Infection or GameModes.Infected or GameModes.FFA

    if (Objects.TargetVisible or IsSpecialRound) and Objects.Target and Objects.Character and Objects.Root and Objects.Humanoid then
        Objects.TargetCharacter = FFC(Services.Workspace, Objects.Target.Name)
        Objects.TargetRootPart = Objects.TargetCharacter and FFC(Objects.TargetCharacter, "HumanoidRootPart")
        Objects.StabTarget = Objects.TargetCharacter

        local TargetHumanoid = Objects.TargetCharacter and FFC(Objects.TargetCharacter, "Humanoid")
        if Objects.Camera.CameraSubject ~= TargetHumanoid then
            Objects.Camera.CameraType = Enum.CameraType.Custom
            Objects.Camera.CameraSubject = TargetHumanoid

            CameraSet = true
        end

        Objects.Humanoid:SetStateEnabled(0, false)

        Services.TweenService:Create(
            Objects.Root,
            Constants.TPTweenInfo,
            {CFrame = Objects.TargetRootPart.CFrame * Constants.TPOffset}
        ):Play()
    else
        Objects.StabTarget = nil

        if Objects.Camera.CameraSubject ~= Objects.Humanoid then
            Objects.Camera.CameraType = Enum.CameraType.Custom
            Objects.Camera.CameraSubject = Objects.Humanoid

            CameraSet = false
        end
    end
end