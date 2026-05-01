local Services, Values, Functions, UI_Functions, Loops, Objects = {
	Players = game:GetService("Players"),
	TweenService = game:GetService("TweenService"),
	RunService = game:GetService("RunService"),
	Workspace = game:GetService("Workspace"),
}, {
	AutoFarm = false,
	Boosting = true,

	Rounds = 0,
	LastRoundChange = 0,

	OldFallenPartsDestroyHeight = 0,
}, {}, {}, {}, {}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

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

----------------------------------------------------------------------------------------------------------

function Functions.TweenToTarget()
	while Values.AutoFarm and Values.Rounds < 8 do
		task.wait()

		if Player.PlayerGui.ScreenGui.UI.Target.Visible and 
		   (Player.Backpack:FindFirstChild("Knife") or Services.Workspace[Player.Name]:FindFirstChild("Knife")) then
			
			Services.Workspace.Gravity = 20

			local Enemy = Player.PlayerGui.ScreenGui.UI.Target.TargetText.Text
			local enemyHRP = Services.Workspace:FindFirstChild(Enemy) and Services.Workspace[Enemy]:FindFirstChild("HumanoidRootPart")

			if enemyHRP then
				local targetPosition = enemyHRP.Position
				local currentPosition = Player.Character.HumanoidRootPart.Position
				local distance = (currentPosition - targetPosition).Magnitude

				local tweenInfo = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear)
				local tweenGoal = {CFrame = CFrame.new(targetPosition)}

				local tween = Services.TweenService:Create(Player.Character.HumanoidRootPart, tweenInfo, tweenGoal)
				tween:Play()
				tween.Completed:Wait()
			end
		else
			Services.Workspace.Gravity = 196.2
		end
	end

	Services.Workspace.Gravity = 196.2
end

function Functions.AdjustCamera()
	while Values.AutoFarm and Values.Rounds < 8 do
		task.wait()

		if Player.PlayerGui.ScreenGui.UI.Target.Visible and 
		   (Player.Backpack:FindFirstChild("Knife") or Player.Character:FindFirstChild("Knife")) then
			
			local Enemy = Player.PlayerGui.ScreenGui.UI.Target.TargetText.Text
			local targetHRP = Services.Workspace:FindFirstChild(Enemy) and Services.Workspace[Enemy]:FindFirstChild("HumanoidRootPart")

			if targetHRP then
				local direction = (targetHRP.Position - Player.Character.HumanoidRootPart.Position).Unit
				local camera = workspace.CurrentCamera
				camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
			end
		end
	end
end

function Functions.DisableCollisions()
	while Values.AutoFarm and Values.Rounds < 8 do
		for _, v in ipairs(Player.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end

		Services.RunService.Stepped:Wait()
	end
end

function Functions.StabEnemy()
	while Values.AutoFarm and Values.Rounds < 8 do
		task.wait()

		if Player.PlayerGui.ScreenGui.UI.Target.Visible then
			local Enemy = Player.PlayerGui.ScreenGui.UI.Target.TargetText.Text
			local enemyHRP = Services.Workspace:FindFirstChild(Enemy) and Services.Workspace[Enemy]:FindFirstChild("HumanoidRootPart")

			if enemyHRP and Player:DistanceFromCharacter(enemyHRP.Position) <= 6.1 then
				Player.PlayerScripts.localknifehandler.HitCheck:Fire(Services.Workspace[Enemy])
				task.wait(0.73)
			end
		end
	end
end

function Functions.HandleCharacter(character)
	if Loops.AutoFarm_Velocity then
		Loops.AutoFarm_Velocity:Disconnect()
        Loops.AutoFarm_Velocity = nil
	end

	if Values.AutoFarm and Values.Rounds < 8 then
		Loops.AutoFarm_Velocity = Services.RunService.Stepped:Connect(function()
			if Values.AutoFarm and Values.Rounds < 8 then
				local hrp = character:FindFirstChild("HumanoidRootPart")

				if hrp then
					hrp.Velocity = Vector3.new(0, 0, 0)
				end
			end
		end)
	end
end

----------------------------------------------------------------------------------------------------------

function UI_Functions.EnableAutoFarm(Value)
	Values.AutoFarm = Value

	if Value then
		Values.OldFallenPartsDestroyHeight = Services.Workspace.FallenPartsDestroyHeight
		Services.Workspace.FallenPartsDestroyHeight = 0/0 -- NaN safer than math.huge

		task.spawn(Functions.TweenToTarget)
		task.spawn(Functions.AdjustCamera)
		task.spawn(Functions.DisableCollisions)
		task.spawn(Functions.StabEnemy)

		if Player.Character then
			Functions.HandleCharacter(Player.Character)
		end

		if Loops.CharacterAdded_AutoFarm then
			Loops.CharacterAdded_AutoFarm:Disconnect()
		end

		Loops.CharacterAdded_AutoFarm = Player.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			Functions.HandleCharacter(char)
		end)

	else
		Services.Workspace.FallenPartsDestroyHeight = Values.OldFallenPartsDestroyHeight

		if Loops.AutoFarm_Velocity then
			Loops.AutoFarm_Velocity:Disconnect()
			Loops.AutoFarm_Velocity = nil
		end

		if Loops.CharacterAdded_AutoFarm then
			Loops.CharacterAdded_AutoFarm:Disconnect()
			Loops.CharacterAdded_AutoFarm = nil
		end
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
		UI_Functions.EnableAutoFarm(Value)
   end,
})

----------------------------------------------------------------------------------------------------------

Functions.Start()
--UI_Module:LoadConfiguration()