local Objects = {}

----------------------------------------------------------------------------------------------------------

local UI_Module = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

Objects["Window"] = UI_Module:CreateWindow({
   Name = "MoonScripts - Assassin",
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
Objects["Misc"] = Objects["Window"]:CreateTab("Misc", "ellipsis")
Objects["Settings"] = Objects["Window"]:CreateTab("Settings", "settings")

----------------------------------------------------------------------------------------------------------

local ESP = loadstring(game:HttpGet("https://moonscripts.live/scripts/assassin/handlers/esp.lua"))()
local SilentAim = loadstring(game:HttpGet("https://moonscripts.live/scripts/assassin/handlers/silentaim.lua"))()
--loadstring(game:HttpGet("https://moonscripts.live/scripts/assassin/handlers/autofarm.lua"))()

print(ESP)
print(SilentAim)