-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ScreenLibrary v2.0 — Example / Config Script                           ║
-- ║  Edit the CONFIG block below. Do not touch anything below the divider.  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════════════════════════════════
--  CONFIG  ← only edit this block
-- ════════════════════════════════════════════════════════════════════════════
local CONFIG = {

    -- ── Window ──────────────────────────────────────────────────────────
    Title     = "My Script",   -- top-bar title text
    Width     = 360,           -- window width  (buttons scale to this)
    Height    = 500,           -- window height
    Accent    = "3764CC",      -- hex accent colour (no #)
    GuiIcon   = nil,           -- optional asset id e.g. "rbxassetid://XXX"
                               -- set to nil to show title only

    -- ── Creator  (REQUIRED for profile card) ────────────────────────────
    --   Set this to YOUR numeric Roblox User ID.
    --   The library will auto-fetch your username and profile picture.
    --   End-users cannot change this from inside the GUI.
    CreatorId = 1,             -- e.g.  1  =  "Roblox" account

    -- ── Feature flags (true = enabled, false = hidden) ───────────────────
    ShowFPSOverlay  = true,
    ShowConfigTab   = true,
    ShowSearchTab   = true,
}
-- ════════════════════════════════════════════════════════════════════════════
--  END CONFIG  — do not edit below this line unless you know what you're doing
-- ════════════════════════════════════════════════════════════════════════════

-- ── Load the library ─────────────────────────────────────────────────────
-- Replace the URL with your raw GitHub / Pastebin link to ScreenLibrary.lua
local Library = loadstring(game:HttpGet(
    "YOUR_RAW_SCREENLIBRARY_URL_HERE"
))()

-- ── Create window ────────────────────────────────────────────────────────
local Window = Library:CreateWindow({
    Title     = CONFIG.Title,
    Width     = CONFIG.Width,
    Height    = CONFIG.Height,
    Accent    = CONFIG.Accent,
    GuiIcon   = CONFIG.GuiIcon,
    CreatorId = CONFIG.CreatorId,
})

-- ── Grab tabs ─────────────────────────────────────────────────────────────
local MainTab   = Window:GetMainTab()
local ConfigTab = Window:GetConfigTab()   -- pre-built: Save / Load / Auto-Load
local SearchTab = Window:GetSearchTab()  -- pre-built: search bar + results

-- ── Helpers ───────────────────────────────────────────────────────────────
local lp   = game:GetService("Players").LocalPlayer
local char = function() return lp.Character end
local hum  = function() return char() and char():FindFirstChildOfClass("Humanoid") end
local hrp  = function() return char() and char():FindFirstChild("HumanoidRootPart") end

-- ════════════════════════════════════════════════════════════════════════════
--  TAB: Main  →  Section: Movement
-- ════════════════════════════════════════════════════════════════════════════
local MovSec = MainTab:AddSection("Movement")

-- ── AddToggle ──────────────────────────────────────────────────────────────
--   Name        : label shown on the row
--   Description : shown when the user taps the (•••) button
--   Default     : true / false  (initial state; callback fires immediately)
--   Callback    : function(bool)
local FlyToggle = MovSec:AddToggle({
    Name        = "Fly",
    Description = "Lets your character fly freely.",
    Default     = false,
    Callback    = function(on)
        if on then
            Window:Notify("Fly enabled")
            -- your fly logic here
        else
            Window:Notify("Fly disabled")
        end
    end,
})

-- ── AddSlider ──────────────────────────────────────────────────────────────
--   Min / Max / Default : number range and starting value
--   Callback            : function(number)
--   Tip: tap the (•••) button to type an exact value instead of dragging
local WalkSlider = MovSec:AddSlider({
    Name        = "Walk Speed",
    Description = "Sets your humanoid WalkSpeed (16 = default).",
    Min         = 0,
    Max         = 300,
    Default     = 16,
    Callback    = function(v)
        local h = hum()
        if h then h.WalkSpeed = v end
    end,
})

local JumpSlider = MovSec:AddSlider({
    Name        = "Jump Power",
    Description = "Sets your humanoid JumpPower (50 = default).",
    Min         = 0,
    Max         = 500,
    Default     = 50,
    Callback    = function(v)
        local h = hum()
        if h then h.JumpPower = v end
    end,
})

-- ── AddKeybind ─────────────────────────────────────────────────────────────
--   Default  : Enum.KeyCode  (click the button in-GUI to rebind)
--   Callback : function()  — fires when the key is pressed
MovSec:AddKeybind({
    Name        = "Toggle Fly Keybind",
    Description = "Click the key badge to rebind.",
    Default     = Enum.KeyCode.F,
    Callback    = function()
        local cur = FlyToggle:Get()
        FlyToggle:Set(not cur)
    end,
})

-- ── AddSeparator ───────────────────────────────────────────────────────────
MovSec:AddSeparator()

-- ── AddLabel ───────────────────────────────────────────────────────────────
MovSec:AddLabel("Noclip disables part collision.")

MovSec:AddToggle({
    Name     = "Noclip",
    Default  = false,
    Callback = function(on)
        Window:Notify(on and "Noclip ON" or "Noclip OFF")
        -- example:
        -- game:GetService("RunService").Stepped:Connect(function()
        --     if on and char() then
        --         for _, p in ipairs(char():GetDescendants()) do
        --             if p:IsA("BasePart") then p.CanCollide = false end
        --         end
        --     end
        -- end)
    end,
})

MovSec:AddToggle({
    Name     = "Infinite Jump",
    Default  = false,
    Callback = function(on)
        Window:Notify(on and "Infinite Jump ON" or "Infinite Jump OFF")
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  TAB: Main  →  Section: Player
-- ════════════════════════════════════════════════════════════════════════════
local PlrSec = MainTab:AddSection("Player")

-- ── AddButton ──────────────────────────────────────────────────────────────
--   Callback : function()
PlrSec:AddButton({
    Name        = "Reset Character",
    Description = "Sets health to 0.",
    Callback    = function()
        local h = hum()
        if h then h.Health = 0 end
    end,
})

PlrSec:AddButton({
    Name        = "Rejoin Server",
    Description = "Teleports you back to the same place.",
    Callback    = function()
        Window:Notify("Rejoining...")
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
        end)
    end,
})

-- ── AddDropdown ────────────────────────────────────────────────────────────
--   Items    : array of strings
--   Default  : which item is pre-selected
--   Callback : function(string)
local TeamDrop = PlrSec:AddDropdown({
    Name        = "Team",
    Description = "Select which team to join.",
    Items       = { "Red", "Blue", "Green", "Yellow" },
    Default     = "Red",
    Callback    = function(v)
        Window:Notify("Team → " .. v)
    end,
})

-- ── AddInput ───────────────────────────────────────────────────────────────
--   Placeholder : grey hint text
--   Callback    : function(string) — fires on Enter or OK button
PlrSec:AddInput({
    Name        = "Rename Tag",
    Description = "Changes your overhead display name tag (if supported).",
    Placeholder = "Enter display name...",
    Callback    = function(text)
        Window:Notify('Rename → "' .. text .. '"')
    end,
})

-- ── AddCheckbox ────────────────────────────────────────────────────────────
PlrSec:AddCheckbox({
    Name        = "Show Server Info",
    Description = "Toggles the server info overlay.",
    Default     = false,
    Callback    = function(v)
        Window:Notify("Server info: " .. tostring(v))
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  TAB: Main  →  Section: World
-- ════════════════════════════════════════════════════════════════════════════
local WldSec = MainTab:AddSection("World")

WldSec:AddDropdown({
    Name     = "Time of Day",
    Items    = { "Dawn", "Morning", "Noon", "Evening", "Night" },
    Default  = "Noon",
    Callback = function(v)
        local t = { Dawn=6, Morning=9, Noon=14, Evening=18, Night=0 }
        pcall(function() game:GetService("Lighting").ClockTime = t[v] or 14 end)
        Window:Notify("Time → " .. v)
    end,
})

WldSec:AddSlider({
    Name     = "Gravity",
    Description = "Changes workspace gravity (196 = default).",
    Min      = 0,
    Max      = 600,
    Default  = 196,
    Callback = function(v)
        pcall(function() workspace.Gravity = v end)
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  TAB: Main  →  Section: Teleport
-- ════════════════════════════════════════════════════════════════════════════
local TpSec = MainTab:AddSection("Teleport")

TpSec:AddInput({
    Name        = "X Coordinate",
    Placeholder = "X...",
    Callback    = function() end,  -- handled by the Teleport button below
})
TpSec:AddInput({Name="Y Coordinate", Placeholder="Y...", Callback=function()end})
TpSec:AddInput({Name="Z Coordinate", Placeholder="Z...", Callback=function()end})

TpSec:AddButton({
    Name        = "Teleport to XYZ",
    Description = "Fill in X, Y, Z above then press this.",
    Callback    = function()
        -- grab TextBox values by searching the section rows
        Window:Notify("Teleport button pressed — wire up your XYZ inputs!")
    end,
})

-- ── AddListbox ─────────────────────────────────────────────────────────────
TpSec:AddListbox({
    Name        = "Saved Locations",
    Description = "Select a saved location to teleport to.",
    Items       = { "Spawn", "Boss Room", "Shop", "Secret Room" },
    Callback    = function(v)
        Window:Notify("Teleport → " .. v)
        -- your teleport logic here
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  TAB: Main  →  Section: Visuals
-- ════════════════════════════════════════════════════════════════════════════
local VisSec = MainTab:AddSection("Visuals")

VisSec:AddToggle({
    Name        = "ESP Players",
    Description = "Draws boxes/names around all players.",
    Default     = false,
    Callback    = function(on)
        Window:Notify(on and "ESP ON" or "ESP OFF")
        -- your ESP logic here
    end,
})

VisSec:AddSlider({
    Name     = "FOV",
    Description = "Camera field of view (70 = default).",
    Min      = 30,
    Max      = 120,
    Default  = 70,
    Callback = function(v)
        pcall(function() workspace.CurrentCamera.FieldOfView = v end)
    end,
})

-- ── AddProgressBar ─────────────────────────────────────────────────────────
--   Value : 0–100 initial fill %
--   Use :Set(n) to update it from your code
local HealthBar = VisSec:AddProgressBar({
    Name        = "Player Health",
    Description = "Displays current health as a bar.",
    Value       = 100,
})

-- Keep the progress bar in sync with real health
task.spawn(function()
    local RS = game:GetService("RunService")
    while true do
        RS.Heartbeat:Wait()
        pcall(function()
            local h = hum()
            if h then HealthBar:Set(math.floor(h.Health / h.MaxHealth * 100)) end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  TAB: Main  →  Section: Multibox demo
-- ════════════════════════════════════════════════════════════════════════════
local MbSec = MainTab:AddSection("Multi-Select")

-- ── AddMultibox ────────────────────────────────────────────────────────────
--   Callback : function(selectedArray)  — array of all currently ticked items
MbSec:AddMultibox({
    Name        = "Active Effects",
    Description = "Choose which effects to apply simultaneously.",
    Items       = { "Speed Boost", "Jump Boost", "Anti-Gravity", "Ghost Mode" },
    Callback    = function(selected)
        local s = table.concat(selected, ", ")
        Window:Notify("Effects: " .. (s ~= "" and s or "none"))
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  CUSTOM TAB — add as many extra tabs as you need
-- ════════════════════════════════════════════════════════════════════════════
local CombatTab = Window:AddTab("Combat")
local CbtSec    = CombatTab:AddSection("Combat Options")

CbtSec:AddToggle({
    Name     = "Auto-Attack",
    Default  = false,
    Callback = function(on)
        Window:Notify(on and "Auto-Attack ON" or "Auto-Attack OFF")
    end,
})

CbtSec:AddSlider({
    Name     = "Attack Range",
    Min      = 5,
    Max      = 100,
    Default  = 20,
    Callback = function(v)
        Window:Notify("Attack range → " .. v)
    end,
})

CbtSec:AddDropdown({
    Name     = "Target Mode",
    Items    = { "Nearest", "Lowest HP", "Highest HP", "Random" },
    Default  = "Nearest",
    Callback = function(v)
        Window:Notify("Target mode → " .. v)
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  Accent colour switcher example
-- ════════════════════════════════════════════════════════════════════════════
local StyleTab = Window:AddTab("Style")
local StlSec   = StyleTab:AddSection("Accent Colour")

local accents = {
    {"Blue",   "3764CC"},
    {"Purple", "7B2FBE"},
    {"Cyan",   "00BFFF"},
    {"Green",  "2ECC71"},
    {"Red",    "CC3333"},
    {"Orange", "E67E22"},
}
for _, pair in ipairs(accents) do
    StlSec:AddButton({
        Name     = pair[1],
        Callback = function()
            Window:SetAccent(pair[2])
            Window:Notify("Accent → " .. pair[1])
        end,
    })
end

-- ════════════════════════════════════════════════════════════════════════════
--  Done — the library handles the rest
-- ════════════════════════════════════════════════════════════════════════════
