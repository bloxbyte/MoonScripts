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
   FFAAutoFarm = false,

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

