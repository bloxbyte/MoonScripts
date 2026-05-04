local Objects = {}

_G.Values = {
   AutoFarm = false,
   SilentAim = false,
   ESP = false,

   FOV_Circle = false,
   FOV_Radius = 100,
   FOV_Color = Color3.fromRGB(255, 255, 255),
   FOV_Thickness = 1,

   InfectionAutoFarm = false,
   JuggernautAutoFarm = false,
   FFA_AutoFarm = false,

   Chams = false,
   TargetChams = false,

   ChamsColor = Color3.fromRGB(255, 255, 255),
   TargetChamsColor = Color3.fromRGB(255, 0, 0),

   BoxESP = false,
   BoxFillESP = false,
   TracerESP = false,
   NameESP = false,
}

----------------------------------------------------------------------------------------------------------

loadstring(game:HttpGet("https://moonscripts.live/scripts/normal/handlers/autofarm.lua"))()
loadstring(game:HttpGet("https://moonscripts.live/scripts/normal/handlers/silentaim.lua"))()
loadstring(game:HttpGet("https://moonscripts.live/scripts/normal/handlers/esp.lua"))()

----------------------------------------------------------------------------------------------------------

local UI_Module = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

Objects["Window"] = UI_Module:CreateWindow({
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
      Enabled = true,
      FolderName = "Moon",
      FileName = "MoonScripts_Boosting"
   },
})

UI_Module:Notify({
   Title = "Assassin Script",
   Content = "Loaded successfully.",
   Duration = 3,
   Image = "moon",
})

----------------------------------------------------------------------------------------------------------

Objects["MainTab"] = Objects["Window"]:CreateTab("Main", "app-window")
Objects["Client"] = Objects["Window"]:CreateTab("Client", "user")
Objects["Auto"] = Objects["Window"]:CreateTab("Auto", "refresh-ccw")
Objects["Misc"] = Objects["Window"]:CreateTab("Misc", "message-circle-question-mark")
Objects["Settings"] = Objects["Window"]:CreateTab("Settings", "settings")

----------------------------------------------------------------------------------------------------------

Objects["ESP_Section"] = Objects["MainTab"]:CreateSection("ESP")

Objects["PlayerESP_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP_Toggle",
   Callback = function(Value)
      _G.Values.ESP = Value
   end,
})

Objects["BoxESP_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Box ESP",
   CurrentValue = false,
   Flag = "BoxESP_Toggle",
   Callback = function(Value)
      _G.Values.BoxESP = Value
   end,
})

Objects["BoxFillESP_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Box Fill ESP",
   CurrentValue = false,
   Flag = "BoxFillESP_Toggle",
   Callback = function(Value)
      _G.Values.BoxFillESP = Value
   end,
})

Objects["NameESP_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Name ESP",
   CurrentValue = false,
   Flag = "NameESP_Toggle",
   Callback = function(Value)
      _G.Values.NameESP = Value
   end,
})

Objects["TracerESP_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Tracer ESP",
   CurrentValue = false,
   Flag = "TracerESP_Toggle",
   Callback = function(Value)
      _G.Values.TracerESP = Value
   end,
})

----------------------------------------------------------------------------------------------------------

Objects["Chams_Section"] = Objects["MainTab"]:CreateSection("Chams")

Objects["NormalChams_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Player Chams",
   CurrentValue = false,
   Flag = "NormalChams_Toggle",
   Callback = function(Value)
      _G.Values.Chams = Value
   end,
})

Objects["TargetChams_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Target Chams",
   CurrentValue = false,
   Flag = "TargetChams_Toggle",
   Callback = function(Value)
      _G.Values.TargetChams = Value
   end,
})

Objects["PlayerChams_Picker"] = Objects["MainTab"]:CreateColorPicker({
   Name = "Player Chams Color",
   Color = Color3.fromRGB(255,255,255),
   Flag = "PlayerChams_Picker", 
   Callback = function(Value)
      _G.Values.ChamsColor = Value
   end
})

Objects["TargetChams_Picker"] = Objects["MainTab"]:CreateColorPicker({
   Name = "Target Chams Color",
   Color = Color3.fromRGB(255,0,0),
   Flag = "TargetChams_Picker", 
   Callback = function(Value)
      _G.Values.TargetChamsColor = Value
   end
})

----------------------------------------------------------------------------------------------------------

Objects["SilentAim_Section"] = Objects["MainTab"]:CreateSection("Silent Aim")

Objects["SilentAim_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Flag = "SilentAim_Toggle",
   Callback = function(Value)
      _G.Values.SilentAim = Value
   end,
})

Objects["FOVCircle_Toggle"] = Objects["MainTab"]:CreateToggle({
   Name = "FOV Circle",
   CurrentValue = false,
   Flag = "FOVCircle_Toggle",
   Callback = function(Value)
      _G.Values.FOV_Circle = Value
   end,
})

Objects["FOVSize_Slider"] = Objects["MainTab"]:CreateSlider({
   Name = "FOV Circle Size",
   Range = {50, 250},
   Increment = 2,
   Suffix = "Circle Size",
   CurrentValue = 100,
   Flag = "FOVSize_Slider", 
   Callback = function(Value)
      _G.Values.FOV_Radius = Value
   end,
})

Objects["FOVThickness_Slider"] = Objects["MainTab"]:CreateSlider({
   Name = "FOV Circle Size",
   Range = {1, 5},
   Increment = 0.5,
   Suffix = "Circle Thickness",
   CurrentValue = 100,
   Flag = "FOVThickness_Slider", 
   Callback = function(Value)
      _G.Values.FOV_Thickness = Value
   end,
})

Objects["FOVColor_Picker"] = Objects["MainTab"]:CreateColorPicker({
   Name = "FOV Circle Color",
   Color = Color3.fromRGB(255,255,255),
   Flag = "FOVColor_Picker", 
   Callback = function(Value)
      _G.Values.FOV_Color = Value
   end
})