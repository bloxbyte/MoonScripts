local Services, Values, Constants, Objects, Functions, UI_Functions, Loops = {
	Players = game:GetService("Players"),
	TweenService = game:GetService("TweenService"),
	RunService = game:GetService("RunService"),
	Workspace = game:GetService("Workspace"),
}, {
	AutoFarm = false,
	Boosting = false,

	Rounds = 0,
	LastRoundChange = 0,

	OldFallenPartsDestroyHeight = 0,
}, {
	TP_Offset = CFrame.new(-2, -5, 1.6),
	TPTweenInfo = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
}, {
	Camera = Services.Workspace.CurrentCamera,

	CameraSet = false,
	Cooldown = false,

	Player = nil,
	UI = nil,

	Character = nil,
    RootPart = nil,
    Humanoid = nil,

	TargetFrame = nil,
	TargetText = nil,
	TargetVisible = nil,

	Target = nil,
	TargetCharacter = nil,
	TargetRootPart = nil,
	StabTarget = nil,
}, {}, {}, {}

local VotePad = nil

local API_Module = loadstring(game:HttpGet("https://moonscripts.live/scripts/API.lua"))()
local MainObject = API_Module.new("Main", Player.Name, _G.Key, _G.Alts)

----------------------------------------------------------------------------------------------------------

function Functions.Start()
	local UI = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("UI")
	local textD = UI:WaitForChild("textD")

	textD.Changed:Connect(function()
		if textD.Text == "Get Ready!" then
			if tick() - Values.LastRoundChange > 5 and Values.Boosting then
				Values.LastRoundChange = tick()

				Values.Rounds += 1
				MainObject:Update("Rounds", Values.Rounds)

				if Values.Rounds >= 9 then
					Values.Rounds = 0
					MainObject:Update("Rounds", Values.Rounds)

					if Values.AutoFarm then
						UI_Functions.EnableAutoFarm(false)
						task.wait()
						UI_Functions.EnableAutoFarm(true)
					end
				end
			end
		end
	end)

	Services.Players.PlayerRemoving:Connect(function(plr)
		if plr == Player then
			MainObject:ClearData()
		end
	end)
end

function Functions.Init()
	Objects.Player = Services.Players.LocalPlayer
	Objects.UI = Objects.Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("UI")

	Objects.Player.CharacterAdded:Connect(function(Character)  Functions.InitCharacter(Character)  end)

	Objects.TargetFrame = Objects.UI:WaitForChild("Target")
	Objects.TargetText = Objects.TargetFrame:WaitForChild("TargetText")
	Objects.TargetVisible = Objects.TargetFrame.Visible

	Objects.Target = Objects.TargetVisible and Services.Players:FindFirstChild(Objects.TargetText.Text)

	VotePad = Services.Workspace:WaitForChild("Lobby", 10):WaitForChild("VoteStation", 10):WaitForChild("pad3", 10).Position,

	Objects.TargetFrame.Changed:Connect(function()
		Objects.TargetVisible = Objects.TargetFrame.Visible
	end)

	Objects.TargetText.Changed:Connect(function()
		Objects.Target = Services.Players:FindFirstChild(Objects.TargetText.Text)
	end)

	if Loops.Autofarm then  Loops.Autofarm:Disconnect()  end
	Loops.Autofarm = Services.RunService.Heartbeat:Connect(function()  Functions.OnHeartbeat()  end)

	task.spawn(function()
		Services.RunService.Stepped:Connect(function()  Functions.OnStepped()  end)
	end)
end

----------------------------------------------------------------------------------------------------------

function Functions.InitCharacter(Character)
	if typeof Character ~= "Instance" then return end

	Objects.Character = Character
	Objects.RootPart = Character:WaitForChild("HumanoidRootPart")
	Objects.Humanoid = Character:WaitForChild("Humanoid")
end

function Functions.HasTool()
	local Backpack = Objects.Player:WaitForChild("Backpack")
	if Backpack and Backpack:FindFirstChildWhichIsA("Tool") then return true end

	if Objects.Character and Objects.Character:FindFirstChildWhichIsA("Tool") then return true end

	return false
end

----------------------------------------------------------------------------------------------------------

function Functions.OnHeartbeat()
	if not Values.AutoFarm or not Values.Boosting then
        Services.Workspace.Gravity = 196.2

        if CameraSet then
            Objects.Camera.CameraType = Enum.CameraType.Custom
            Objects.Camera.CameraSubject = Objects.Humanoid
            CameraSet = false
        end

        return
    end

	Objects.Target = nil

	if not Functions.HasTool() then return end
	if not Objects.RootPart then return end

	local InLobby = (VotePad - Objects.RootPart.Position).Magnitude <= 300
	Services.Workspace.Gravity = InLobby and 196.2 or 0

	Objects.Target = Objects.TargetVisible and Services.Players:FindFirstChild(Objects.TargetText.Text) or nil

	local Statement = Objects.TargetVisible and Objects.Target and Objects.Character and Objects.RootPart and Objects.Humanoid

	if Statement then
		Objects.TargetCharacter = Services.Workspace:FindFirstChild(Objects.Target.Name)
		Objects.TargetRootPart = Objects.TargetCharacter and Objects.TargetCharacter:FindFirstChild("HumanoidRootPart")	
		Objects.StabTarget = self.TargetCharacter

		local Humanoid = Objects.TargetCharacter and Objects.TargetCharacter:FindFirstChild("Humanoid")

		if Objects.Camera.CameraSubject ~= Humanoid then
			Objects.Camera.CameraType = Enum.CameraType.Custom
			Objects.Camera.CameraSubject = Humanoid

			CameraSet = true
		end

		Objects.Humanoid:SetStateEnabled(0, false)

		Objects.TweenService:Create(
			Objects.RootPart, 
			Objects.TPTweenInfo, 
			{CFrame = Objects.TargetRootPart.CFrame * Objects.TP_Offset}
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

function Functions.OnStepped()
	if not Functions.HasTool() then return end

	if Objects.Player.Character and not Objects.Cooldown and Objects.StabTarget and Values.AutoFarm and Values.Boosting then
		pcall(function()
            local head = Objects.StabTarget and Objects.StabTarget:FindFirstChild("Head")
            if not head then return end

            if Objects.LocalPlayer:DistanceFromCharacter(head.Position) <= 6.5 then
                local scripts = Objects.Player:FindFirstChild("PlayerScripts")
                local handler = scripts and scripts:FindFirstChild("localknifehandler")
                local hitCheck = handler and handler:FindFirstChild("HitCheck")

                if not hitCheck then return end

                hitCheck:Fire(Objects.StabTarget)

                coroutine.wrap(function()
                    Objects.Cooldown = true
					
                    task.wait(0.8)
                    Objects.Cooldown = false
                end)()
            end
        end)
	end
end

----------------------------------------------------------------------------------------------------------

local UI_Module = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = UI_Module:CreateWindow({
   Name = "MoonScripts - Boosting Bot",
   Icon = 0, 
   LoadingTitle = "MoonScripts",
   LoadingSubtitle = "by idfk",
   ShowText = "Rayfield", 
   Theme = "Default", 

   ToggleUIKeybind = "K", 

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, 

   ConfigurationSaving = {
      Enabled = false,
      FolderName = "Moon",
      FileName = "MoonScripts_Boosting"
   },
})

UI_Module:Notify({
   Title = "Main Account Script",
   Content = "Only enable boosting if you have all your accounts in the game and you have the right account with the main script.",
   Duration = 3,
   Image = "moon",
})

----------------------------------------------------------------------------------------------------------

UI_Module:Notify({
   Title = "Boosting Bot",
   Content = "Waiting for all acounts to load and join the game.",
   Duration = 10,
   Image = "moon",
})

function Functions.AllAltsInGame()
    for _, Alt in ipairs(_G.Alts) do
        if not Services.Players:FindFirstChild(Alt) then
            return false
        end
    end
	
    return true
end

repeat
    task.wait()
until Functions.AllAltsInGame()

----------------------------------------------------------------------------------------------------------

Objects["MainTab"] = Window:CreateTab("Main", "app-window")

Objects["BoostingToggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Enable Boosting",
   CurrentValue = false,
   Flag = "Boosting_Nigger", 
   Callback = function(Value)
		Values.Boosting = Value
		Values.AutoFarm = Value
   end,
})

----------------------------------------------------------------------------------------------------------

Functions.Init()
Functions.Start()