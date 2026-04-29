local Services, Values, Loops, Functions, Objects = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}, {
    OldFallenPartsDestroyHeight = 0,

    Rounds = 0,
    LastRoundChange = 0,

    AutoFarm = true,
    Boosting = true,
}, {}, {}, {}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local API_Module = loadstring(game:HttpGet("https://moonscripts.live/scripts/API.lua"))()
local AltObject = API_Module.new("Alt", Player.Name, _G.Key, _G.MainAccount)

Objects["Debounce"] = false

----------------------------------------------------------------------------------------------------------

function Functions.Start()
    if not _G.MainAccount or not _G.Key then
        Player:Kick("Main account or API key not set.")
        return
    end

    if not Services.Players:FindFirstChild(_G.MainAccount) then
        Player:Kick("Main account not found in the game.")
        return
    end

    local UI = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("UI")
    local textD = UI:WaitForChild("textD")

    textD.Changed:Connect(function()
        if textD.Text == "Get Ready!" then
            if tick() - Values.LastRoundChange > 5 and Values.Boosting then
                Values.LastRoundChange = tick()

                local Rounds = AltObject:Get("Rounds")
                Values.Rounds = Rounds

                if Rounds == 8 then
                    local Target = Player.PlayerGui.ScreenGui.UI.Target

                    repeat 
                        task.wait()
                    until Target.Visible == true and Services.Players:FindFirstChild(Target.Text)

                    AltObject:Update("Target", Player.Name, Target.Text)
                end
            end
        end
    end)

    Services.Players.PlayerRemoving:Connect(function(plr)
        if plr == Services.Players:FindFirstChild(_G.MainAccount) then
            Player:Kick("Main account left the game, boosting stopped.")
        end
    end)
end

----------------------------------------------------------------------------------------------------------

function Functions.TweenToTarget(Name)
	if Player.PlayerGui.ScreenGui.UI.Target.Visible and 
		(Player.Backpack:FindFirstChild("Knife") or Services.Workspace[Player.Name]:FindFirstChild("Knife")) then
			
		Services.Workspace.Gravity = 20

		local Enemy = Player.PlayerGui.ScreenGui.UI.Target.TargetText.Text
		local enemyHRP = Services.Workspace:FindFirstChild(Name) and Services.Workspace[Name]:FindFirstChild("HumanoidRootPart")

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
	end

	Services.Workspace.Gravity = 196.2
end

function Functions.AdjustCamera(Name)
	while Values.Rounds == 8 do
		task.wait()

		if Player.PlayerGui.ScreenGui.UI.Target.Visible and 
		   (Player.Backpack:FindFirstChild("Knife") or Player.Character:FindFirstChild("Knife")) then
			
			local targetHRP = Services.Workspace:FindFirstChild(Name) and Services.Workspace[Name]:FindFirstChild("HumanoidRootPart")

			if targetHRP then
				local direction = (targetHRP.Position - Player.Character.HumanoidRootPart.Position).Unit
				local camera = workspace.CurrentCamera
				camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
			end
		end
	end
end

function Functions.DisableCollisions()
	Loops.Collisions = Services.RunService.Stepped:Connect(function()
         for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function Functions.StabEnemy(Name)
	task.wait()

	if Player.PlayerGui.ScreenGui.UI.Target.Visible then
		local enemyHRP = Services.Workspace:FindFirstChild(Name) and Services.Workspace[Name]:FindFirstChild("HumanoidRootPart")

		if enemyHRP and Player:DistanceFromCharacter(enemyHRP.Position) <= 6.1 then
			Player.PlayerScripts.localknifehandler.HitCheck:Fire(Services.Workspace[Name])
		end
	end
end

function Functions.HandleCharacter(character)
	if Loops.AutoFarm_Velocity then
		Loops.AutoFarm_Velocity:Disconnect()
        Loops.AutoFarm_Velocity = nil
	end

	if Values.Rounds == 8 then
		Loops.AutoFarm_Velocity = Services.RunService.Stepped:Connect(function()
			if Values.Rounds < 8 then
				local hrp = character:FindFirstChild("HumanoidRootPart")

				if hrp then
					hrp.Velocity = Vector3.new(0, 0, 0)
				end
			end
		end)
	end
end

----------------------------------------------------------------------------------------------------------

Service.RunService.Heartbeat:Connect(function()
    if Objects["Debounce"] then return end

    Objects["Debounce"] = true
    mouse1click()

    task.wait(360)
    Objects["Debounce"] = false
end)

----------------------------------------------------------------------------------------------------------

Functions.Start()