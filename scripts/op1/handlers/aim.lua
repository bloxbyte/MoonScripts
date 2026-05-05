local dwEntities = game:GetService("Players")
local dwLocalPlayer = dwEntities.LocalPlayer
local dwMouse = dwLocalPlayer:GetMouse()
local dwUIS = game:GetService("UserInputService")
local dwRunService = game:GetService("RunService")
local dwCamera = workspace.CurrentCamera

local settings = {
    Aimbot = true,
    Aiming = false,
    Aimbot_AimPart = "collision3",
    Aimbot_TeamCheck = true,
    Aimbot_Draw_FOV = true,
    Aimbot_FOV_Radius = 200,
    Aimbot_FOV_Color = Color3.fromRGB(255, 255, 255)
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = settings.Aimbot_Draw_FOV
fovCircle.Radius = settings.Aimbot_FOV_Radius
fovCircle.Color = settings.Aimbot_FOV_Color
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Transparency = 1

fovCircle.Position = Vector2.new(
    dwCamera.ViewportSize.X / 2,
    dwCamera.ViewportSize.Y / 2
)

dwUIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = true
    end
end)

dwUIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = false
    end
end)

dwRunService.RenderStepped:Connect(function()
    local dist = math.huge
    local closest_char = nil

    if settings.Aiming then
        for _, v in next, dwEntities:GetChildren() do
            if v ~= dwLocalPlayer
                and v.Character
                and v.Character:FindFirstChild("HumanoidRootPart")
                and v.Character:FindFirstChild("Humanoid")
                and v.Character.Humanoid.Health > 0 then

                if (settings.Aimbot_TeamCheck and v.Team ~= dwLocalPlayer.Team)
                    or (not settings.Aimbot_TeamCheck) then

                    local char = v.Character
                    local part = char:FindFirstChild(settings.Aimbot_AimPart)

                    if part then
                        local screenPos, onScreen = dwCamera:WorldToViewportPoint(part.Position)

                        if onScreen then
                            local mag = (Vector2.new(dwMouse.X, dwMouse.Y)
                                - Vector2.new(screenPos.X, screenPos.Y)).Magnitude

                            if mag < dist and mag < settings.Aimbot_FOV_Radius then
                                dist = mag
                                closest_char = char
                            end
                        end
                    end
                end
            end
        end

        if closest_char
            and closest_char:FindFirstChild("HumanoidRootPart")
            and closest_char:FindFirstChild("Humanoid")
            and closest_char.Humanoid.Health > 0 then

            local targetPart = closest_char:FindFirstChild(settings.Aimbot_AimPart)

            if targetPart then
                dwCamera.CFrame = CFrame.new(
                    dwCamera.CFrame.Position,
                    targetPart.Position
                )
            end
        end
    end
end)