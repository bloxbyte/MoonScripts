_G.ESP_ENABLED = true
_G.ESPInitialized = false
_G.espSkeletons = true
_G.ESP_Table = {}

_G.destroyESP = function()
   for _,ui in pairs(_G.ESP_Table) do
      pcall(function() if ui.Box then ui.Box:Remove() end end)
      pcall(function() if ui.Tracer then ui.Tracer:Remove() end end)
      pcall(function() if ui.Health then ui.Health:Remove() end end)
      pcall(function() if ui.Name then ui.Name:Remove() end end)
   end
   table.clear(_G.ESP_Table)
   _G.ESP_ENABLED = false
end

local function setupESP()
   if _G.ESPInitialized then return end
   _G.ESPInitialized = true
   
   local Players = game:GetService("Players")
   local RunService = game:GetService("RunService")
   local UserInputService = game:GetService("UserInputService")
   local Camera = workspace.CurrentCamera
   local LocalPlayer = Players.LocalPlayer
   local ESP = _G.ESP_Table
   local TEAM_CHECK = true
   local MAX_STUCK_TIME = 1.5
   local TOGGLE_KEY = Enum.KeyCode.RightAlt

   local function newDrawing(type, props)
      local obj = Drawing.new(type)
      for k,v in pairs(props) do obj[k] = v end
      return obj
   end

   local function hide(ui)
      ui.Box.Visible = false
      ui.Tracer.Visible = false
      ui.Health.Visible = false
      ui.Name.Visible = false
   end

   local function hideAll()
      for _,ui in pairs(ESP) do hide(ui) end
   end

   UserInputService.InputBegan:Connect(function(input)
      if input.KeyCode == TOGGLE_KEY then
         _G.ESP_ENABLED = not _G.ESP_ENABLED
         if not _G.ESP_ENABLED then hideAll() end
      end
   end)

   local function createESP(player)
      if player == LocalPlayer or ESP[player] then return end
      ESP[player] = {
         Player = player,
         Box = newDrawing("Square", {Thickness = 1, Filled = false, Color = Color3.new(1,1,1), Visible = false}),
         Tracer = newDrawing("Line", {Thickness = 1, Color = Color3.new(1,1,1), Visible = false}),
         Health = newDrawing("Line", {Thickness = 3, Visible = false}),
         Name = newDrawing("Text", {Size = 13, Center = true, Outline = true, Font = 2, Visible = false}),
         LastPosition = nil,
         StuckTime = 0
      }
   end

   for _,player in ipairs(Players:GetPlayers()) do createESP(player) end
   Players.PlayerAdded:Connect(createESP)

   local function findCharacter(player)
      for _,model in ipairs(workspace:GetChildren()) do
         if model:IsA("Model") and model.Name == player.Name then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root then return model, hum, root end
         end
      end
      return nil
   end

   local function getBox(character)
      local cf, size = character:GetBoundingBox()
      local top = cf.Position + Vector3.new(0, size.Y/2, 0)
      local bottom = cf.Position - Vector3.new(0, size.Y/2, 0)
      local topPos, vis1 = Camera:WorldToViewportPoint(top)
      local bottomPos, vis2 = Camera:WorldToViewportPoint(bottom)
      if not vis1 or not vis2 then return nil end
      local height = math.abs(topPos.Y - bottomPos.Y)
      local width = height / 2
      return Vector2.new(topPos.X - width/2, topPos.Y), width, height
   end

   RunService.RenderStepped:Connect(function(dt)
      if not _G.ESP_ENABLED then return end
      for player,ui in pairs(ESP) do
         pcall(function()
            if TEAM_CHECK and player.Team == LocalPlayer.Team then hide(ui) return end
            
            local character, humanoid, root = findCharacter(player)
            if not character or not humanoid or humanoid.Health <= 0 then hide(ui) return end
            
            local pos, width, height = getBox(character)
            if not pos then hide(ui) return end
            
            if ui.LastPosition and (ui.LastPosition - pos).Magnitude < 1 then
               ui.StuckTime = ui.StuckTime + dt
            else
               ui.StuckTime = 0
            end
            if ui.StuckTime >= MAX_STUCK_TIME then hide(ui) return end
            ui.LastPosition = pos

            ui.Box.Size = Vector2.new(width, height)
            ui.Box.Position = pos
            ui.Box.Visible = true -- Bound directly to master ESP toggle now

            ui.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            ui.Tracer.To = Vector2.new(pos.X + width/2, pos.Y)
            ui.Tracer.Visible = true -- Bound directly to master ESP toggle now

            local hp = humanoid.Health / humanoid.MaxHealth
            local healthHeight = height * hp
            ui.Health.From = Vector2.new(pos.X - 5, pos.Y + height)
            ui.Health.To = Vector2.new(pos.X - 5, pos.Y + height - healthHeight)
            ui.Health.Color = Color3.fromRGB(255 - (255*hp), 255*hp, 0)
            ui.Health.Visible = true

            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            ui.Name.Text = myRoot and player.Name .. " [" .. math.floor((myRoot.Position - root.Position).Magnitude) .. "m]" or player.Name
            ui.Name.Position = Vector2.new(pos.X + width/2, pos.Y - 15)
            ui.Name.Visible = true
         end)
      end
   end)
end

-- Viewmodel ESP
local cloneref_support = cloneref ~= nil
local gethui_support = gethui ~= nil
local runservice = cloneref_support and cloneref(game:GetService("RunService")) or game:GetService("RunService")

local bones = {
    { "torso", "head" }, { "torso", "shoulder1" }, { "torso", "shoulder2" },
    { "shoulder1", "arm1" }, { "shoulder2", "arm2" }, { "torso", "hip1" },
    { "torso", "hip2" }, { "hip1", "leg1" }, { "hip2", "leg2" }
}
local required_bones = { "torso", "head", "shoulder1", "shoulder2", "arm1", "arm2", "hip1", "hip2", "leg1", "leg2" }

local esp_list = {}
local skeleton_list = {}

local viewmodels = workspace:FindFirstChild("Viewmodels")
local camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() camera = workspace.CurrentCamera end)

local teammate_highlights = {}
workspace.ChildAdded:Connect(function(child) if child:IsA("Highlight") then teammate_highlights[child] = true end end)
workspace.ChildRemoved:Connect(function(child) if child:IsA("Highlight") then teammate_highlights[child] = nil end end)

local function is_teammate(model)
    for highlight in pairs(teammate_highlights) do
        if highlight.Adornee == model then return true end
    end
    return false
end

local function is_valid(model)
    if not model or not model.Parent or model.Name == "LocalViewmodel" or not viewmodels or model.Parent ~= viewmodels then return false end
    local torso = model:FindFirstChild("torso")
    return torso and torso:IsA("BasePart")
end

local function rand_str(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for i = 1, len do result[i] = chars:sub(math.random(1, #chars), math.random(1, #chars)) end
    return table.concat(result)
end

local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = rand_str(12)
screen_gui.Parent = gethui_support and gethui() or game:GetService("CoreGui")

local function remove_skeleton(character)
    local data = skeleton_list[character]
    if not data then return end
    for _, line in ipairs(data.lines) do line:Remove() end
    skeleton_list[character] = nil
end

local function create_skeleton(character)
    if not character or skeleton_list[character] or not is_valid(character) then return end
    local char_bones = {}
    for _, name in ipairs(required_bones) do
        local b = character:FindFirstChild(name)
        if not b or not b:IsA("BasePart") then return end
        char_bones[name] = b
    end
    
    local lines = {}
    for i = 1, #bones do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1
        line.Transparency = 1
        lines[i] = line
    end
    skeleton_list[character] = { lines = lines, bones = char_bones }
end

local function create_esp(character)
    if not character or not is_valid(character) or esp_list[character] then return end
    
    local folder = Instance.new("Folder", screen_gui)
    local box = Instance.new("Frame", folder)
    local stroke = Instance.new("UIStroke", box)
    
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 1
    
    esp_list[character] = { folder = folder, box = box }
end

runservice.RenderStepped:Connect(function()
    for character, data in pairs(esp_list) do
        local box = data.box
        local folder = data.folder
        
        if not character or not character.Parent or not is_valid(character) then
            box.Visible = false
            folder:Destroy()
            esp_list[character] = nil
            remove_skeleton(character)
            continue
        end
        
        local torso = character:FindFirstChild("torso")
        if not torso or torso.Transparency >= 1 or is_teammate(character) then
            box.Visible = false
            continue
        end
        
        local pos, on_screen = camera:WorldToScreenPoint(torso.Position)
        
        if on_screen and (camera.CFrame.Position - torso.Position).Magnitude <= 3571.4 then
            if _G.espSkeletons then
                if not skeleton_list[character] then create_skeleton(character) end
                local skel = skeleton_list[character]
                
                if skel then
                    local min_x, min_y = math.huge, math.huge
                    local max_x, max_y = -math.huge, -math.huge
                    
                    for i, conn in ipairs(bones) do
                        local b1, b2 = skel.bones[conn[1]], skel.bones[conn[2]]
                        if b1 and b2 then
                            local p1 = camera:WorldToViewportPoint(b1.Position)
                            local p2 = camera:WorldToViewportPoint(b2.Position)
                            local s1 = camera:WorldToScreenPoint(b1.Position)
                            local s2 = camera:WorldToScreenPoint(b2.Position)
                            
                            if s1.Z > 0 then
                                if s1.X < min_x then min_x = s1.X end
                                if s1.X > max_x then max_x = s1.X end
                                if s1.Y < min_y then min_y = s1.Y end
                                if s1.Y > max_y then max_y = s1.Y end
                            end
                            if s2.Z > 0 then
                                if s2.X < min_x then min_x = s2.X end
                                if s2.X > max_x then max_x = s2.X end
                                if s2.Y < min_y then min_y = s2.Y end
                                if s2.Y > max_y then max_y = s2.Y end
                            end
                            
                            if p1.Z > 0 and p2.Z > 0 then
                                skel.lines[i].From = Vector2.new(p1.X, p1.Y)
                                skel.lines[i].To = Vector2.new(p2.X, p2.Y)
                                skel.lines[i].Visible = true
                            else
                                skel.lines[i].Visible = false
                            end
                        else
                            skel.lines[i].Visible = false
                        end
                    end
                    
                    if _G.ESP_ENABLED and min_x ~= math.huge then
                        local pad = 4
                        box.Visible = true
                        box.Position = UDim2.fromOffset(min_x - pad, min_y - pad)
                        box.Size = UDim2.fromOffset(max_x - min_x + pad * 2, max_y - min_y + pad * 2)
                    else
                        box.Visible = false
                    end
                end
            else
                remove_skeleton(character)
                box.Visible = false
            end
        else
            box.Visible = false
            remove_skeleton(character)
        end
    end
end)

if viewmodels then
    for _, v in ipairs(viewmodels:GetChildren()) do
        if v:IsA("Model") then task.delay(0.1, create_esp, v) end
    end
    viewmodels.ChildAdded:Connect(function(v)
        if v:IsA("Model") then task.delay(0.2, create_esp, v) end
    end)
    viewmodels.ChildRemoved:Connect(function(v)
        if esp_list[v] then esp_list[v].folder:Destroy() esp_list[v] = nil end
        remove_skeleton(v)
    end)
end

setupESP()