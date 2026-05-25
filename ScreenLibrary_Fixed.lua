-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ScreenLibrary v2.1 — LimitHub Style (Fixed)                            ║
-- ║  Tab-based, mobile-first Roblox UI Library                              ║
-- ║  Wide layout, dark purple theme, working RGB                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local ScreenLibrary = {}
ScreenLibrary.__index = ScreenLibrary

-- ── Services ──────────────────────────────────────────────────────────────
local Players    = game:GetService("Players")
local TweenSvc   = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpSvc    = game:GetService("HttpService")
local lp         = Players.LocalPlayer

-- ── Theme (LimitHub style - dark purple/blue) ─────────────────────────────
local TH = {
    font     = Enum.Font.Gotham,
    fontBold = Enum.Font.GothamBold,
    bg       = Color3.fromRGB(25, 25, 40),      -- Main background
    panel    = Color3.fromRGB(20, 20, 35),      -- Darker panels
    btn      = Color3.fromRGB(30, 30, 50),      -- Buttons
    input    = Color3.fromRGB(35, 35, 55),      -- Input fields
    txt      = Color3.fromRGB(220, 220, 240),   -- Primary text
    sub      = Color3.fromRGB(150, 150, 170),   -- Secondary text
    accent   = Color3.fromRGB(100, 120, 255),   -- Purple-blue accent
    red      = Color3.fromRGB(200, 50, 50),
    green    = Color3.fromRGB(80, 200, 120),
}

-- ── Utility Functions ─────────────────────────────────────────────────────
local function corner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = i
    return c
end

local function stroke(i, t, col, tr)
    local s = Instance.new("UIStroke")
    s.Thickness = t or 1
    s.Color = col or TH.accent
    s.Transparency = tr or 0.6
    s.Parent = i
    return s
end

local function tw(i, t, p)
    return TweenSvc:Create(i, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
end

local function frame(par, bg, sz, pos, zi)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = bg or TH.btn
    f.Size = sz or UDim2.new(1, 0, 0, 36)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BorderSizePixel = 0
    f.ZIndex = zi or 2
    f.Parent = par
    return f
end

local function lbl(par, txt, sz, pos, fs, col, font, xa, zi)
    local l = Instance.new("TextLabel")
    l.Text = txt or ""
    l.Size = sz or UDim2.new(1, 0, 1, 0)
    l.Position = pos or UDim2.new(0, 0, 0, 0)
    l.TextSize = fs or 13
    l.TextColor3 = col or TH.txt
    l.Font = font or TH.font
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.BackgroundTransparency = 1
    l.ZIndex = zi or 3
    l.Parent = par
    return l
end

local function btn(par, txt, sz, pos, bg, fs, zi)
    local b = Instance.new("TextButton")
    b.Text = txt or ""
    b.Size = sz or UDim2.new(1, 0, 0, 32)
    b.Position = pos or UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3 = bg or TH.btn
    b.TextColor3 = TH.txt
    b.TextSize = fs or 13
    b.Font = TH.font
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = zi or 3
    b.Parent = par
    return b
end

local function listlayout(par, dir, pad, sort)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = sort or Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, pad or 6)
    l.Parent = par
    return l
end

local function pad(par, t, r, b, ll)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, ll or 0)
    p.Parent = par
    return p
end

local function resolveParent()
    local p
    pcall(function()
        if type(gethui) == "function" then
            p = gethui()
        elseif type(get_hidden_gui) == "function" then
            p = get_hidden_gui()
        end
    end)
    return p or game:GetService("CoreGui")
end

-- Global component registry
local _registry = {}

-- ══════════════════════════════════════════════════════════════════════════
--  CreateWindow
-- ══════════════════════════════════════════════════════════════════════════
function ScreenLibrary:CreateWindow(opts)
    opts = opts or {}
    local Title = opts.Title or "ScreenLibrary"
    local W = opts.Width or 550  -- Wider default
    local H = opts.Height or 420
    local CreatorId = opts.CreatorId or 0
    
    -- Fixed RGB parsing
    local Accent
    local _accentRaw = opts.Accent
    if type(_accentRaw) == "string" and #_accentRaw >= 6 then
        -- Remove # if present
        _accentRaw = _accentRaw:gsub("#", "")
        -- Parse hex to RGB (0-255 range, then convert to 0-1)
        local r = tonumber(_accentRaw:sub(1, 2), 16) or 100
        local g = tonumber(_accentRaw:sub(3, 4), 16) or 120
        local b = tonumber(_accentRaw:sub(5, 6), 16) or 255
        Accent = Color3.fromRGB(r, g, b)
    else
        Accent = _accentRaw or TH.accent
    end
    
    local GuiIcon = opts.GuiIcon

    -- ── ScreenGui ─────────────────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name = "SL_" .. Title:gsub("%s", "")
    SG.ResetOnSpawn = false
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() SG.IgnoreGuiInset = true end)
    SG.Parent = resolveParent()

    -- ── Main Frame ────────────────────────────────────────────────────
    local TBAR_H = 45
    local SIDEBAR_W = 170
    
    local Main = frame(SG, TH.bg, UDim2.new(0, W, 0, H), UDim2.new(0.5, -W/2, 0.5, -H/2), 2)
    Main.Name = "Main"
    Main.ClipsDescendants = true
    corner(Main, 12)
    
    -- Accent line at top
    local AccLine = frame(Main, Accent, UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, TBAR_H), 4)

    -- ── Title Bar (draggable) ─────────────────────────────────────────
    local _drag, _ds, _dp = false, nil, nil
    local TBar = frame(Main, TH.panel, UDim2.new(1, 0, 0, TBAR_H), UDim2.new(0, 0, 0, 0), 3)
    TBar.Name = "TBar"
    
    TBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            _drag = true
            _ds = inp.Position
            _dp = Main.AbsolutePosition
        end
    end)
    
    UIS.InputChanged:Connect(function(inp)
        if _drag then
            local d = inp.Position - _ds
            Main.Position = UDim2.new(0, _dp.X + d.X, 0, _dp.Y + d.Y)
        end
    end)
    
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            _drag = false
        end
    end)

    -- Title text
    lbl(TBar, Title, UDim2.new(1, -100, 1, 0), UDim2.new(0, 15, 0, 0),
        16, TH.txt, TH.fontBold, Enum.TextXAlignment.Left, 4)
    
    -- Close button
    local BtnClose = btn(TBar, "×", UDim2.new(0, 30, 0, 30),
        UDim2.new(1, -38, 0.5, -15), TH.red, 20, 5)
    corner(BtnClose, 8)
    BtnClose.MouseButton1Click:Connect(function()
        tw(Main, 0.2, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(0.25, function() SG:Destroy() end)
    end)

    -- ── Sidebar ───────────────────────────────────────────────────────
    local Sidebar = frame(Main, TH.panel,
        UDim2.new(0, SIDEBAR_W, 1, -TBAR_H),
        UDim2.new(0, 0, 0, TBAR_H), 3)
    Sidebar.Name = "Sidebar"

    -- ── Content Panel ─────────────────────────────────────────────────
    local ContentPanel = frame(Main, TH.bg,
        UDim2.new(1, -SIDEBAR_W, 1, -TBAR_H),
        UDim2.new(0, SIDEBAR_W, 0, TBAR_H), 3)
    ContentPanel.Name = "ContentPanel"

    -- Tab storage
    local tabs = {}
    local activeTab = nil
    
    local function setActiveTab(name)
        for tname, tdata in pairs(tabs) do
            tdata.content.Visible = (tname == name)
            if tdata.btn then
                if tname == name then
                    tdata.btn.BackgroundColor3 = TH.btn
                else
                    tdata.btn.BackgroundColor3 = TH.panel
                end
            end
        end
        activeTab = name
    end

    -- ── Add Tab Function ──────────────────────────────────────────────
    local function addTab(name, icon)
        if tabs[name] then return tabs[name].api end
        
        -- Nav button
        local navBtn = btn(Sidebar, "  " .. name,
            UDim2.new(1, -16, 0, 38),
            UDim2.new(0, 8, 0, 8 + (#tabs * 46)),
            TH.panel, 13, 4)
        corner(navBtn, 8)
        navBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        navBtn.MouseEnter:Connect(function()
            if activeTab ~= name then
                navBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
            end
        end)
        
        navBtn.MouseLeave:Connect(function()
            if activeTab ~= name then
                navBtn.BackgroundColor3 = TH.panel
            end
        end)
        
        -- Content scroll frame
        local content = Instance.new("ScrollingFrame")
        content.Name = name .. "Content"
        content.Parent = ContentPanel
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.Size = UDim2.new(1, 0, 1, 0)
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = TH.accent
        content.Visible = false
        content.ZIndex = 4
        
        listlayout(content, nil, 8)
        pad(content, 12, 12, 12, 12)
        
        -- Auto-resize canvas
        content:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, content.UIListLayout.AbsoluteContentSize.Y + 24)
        end)
        
        navBtn.MouseButton1Click:Connect(function()
            setActiveTab(name)
        end)
        
        -- Tab API
        local Tab = {}
        
        function Tab:AddSection(secName)
            local Section = {}
            
            -- Section header
            local secHeader = frame(content, Color3.fromRGB(0, 0, 0, 0),
                UDim2.new(1, 0, 0, 28), nil, 5)
            secHeader.BackgroundTransparency = 1
            
            lbl(secHeader, secName, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
                14, TH.txt, TH.fontBold, Enum.TextXAlignment.Left, 6)
            
            local function createRow(height)
                local row = frame(content, TH.btn,
                    UDim2.new(1, 0, 0, height or 42), nil, 5)
                corner(row, 8)
                return row
            end
            
            -- ── AddButton ─────────────────────────────────────────────
            function Section:AddButton(o)
                o = o or {}
                local n = o.Name or "Button"
                local cb = o.Callback or function() end
                
                local row = createRow(40)
                local button = btn(row, n, UDim2.new(1, -16, 1, -8),
                    UDim2.new(0, 8, 0, 4), TH.input, 13, 6)
                corner(button, 6)
                
                button.MouseButton1Click:Connect(function()
                    tw(button, 0.1, {BackgroundColor3 = Accent}):Play()
                    task.delay(0.15, function()
                        tw(button, 0.1, {BackgroundColor3 = TH.input}):Play()
                    end)
                    pcall(cb)
                end)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
            end
            
            -- ── AddToggle ─────────────────────────────────────────────
            function Section:AddToggle(o)
                o = o or {}
                local n = o.Name or "Toggle"
                local def = o.Default or false
                local cb = o.Callback or function() end
                
                local row = createRow(42)
                
                lbl(row, n, UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0),
                    13, TH.txt, TH.font, Enum.TextXAlignment.Left, 6)
                
                -- Toggle switch
                local toggleBg = frame(row, TH.panel,
                    UDim2.new(0, 44, 0, 24), UDim2.new(1, -56, 0.5, -12), 6)
                corner(toggleBg, 12)
                
                local toggleCircle = frame(toggleBg, TH.sub,
                    UDim2.new(0, 20, 0, 20), UDim2.new(0, 2, 0, 2), 7)
                corner(toggleCircle, 10)
                
                local state = def
                
                local function updateToggle()
                    if state then
                        tw(toggleBg, 0.2, {BackgroundColor3 = Accent}):Play()
                        tw(toggleCircle, 0.2, {
                            Position = UDim2.new(1, -22, 0, 2),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        }):Play()
                    else
                        tw(toggleBg, 0.2, {BackgroundColor3 = TH.panel}):Play()
                        tw(toggleCircle, 0.2, {
                            Position = UDim2.new(0, 2, 0, 2),
                            BackgroundColor3 = TH.sub
                        }):Play()
                    end
                end
                
                updateToggle()
                
                local toggleBtn = btn(toggleBg, "", UDim2.new(1, 0, 1, 0),
                    UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 0, 0, 0), 1, 8)
                toggleBtn.BackgroundTransparency = 1
                
                toggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    updateToggle()
                    pcall(cb, state)
                end)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Set = function(_, v)
                        state = v
                        updateToggle()
                    end,
                    Get = function() return state end,
                }
            end
            
            -- ── AddSlider ─────────────────────────────────────────────
            function Section:AddSlider(o)
                o = o or {}
                local n = o.Name or "Slider"
                local min = o.Min or 0
                local max = o.Max or 100
                local def = o.Default or min
                local cb = o.Callback or function() end
                
                local row = createRow(60)
                
                lbl(row, n, UDim2.new(1, -60, 0, 18), UDim2.new(0, 12, 0, 4),
                    13, TH.txt, TH.font, Enum.TextXAlignment.Left, 6)
                
                local valueLbl = lbl(row, tostring(def), UDim2.new(0, 50, 0, 18),
                    UDim2.new(1, -56, 0, 4), 12, Accent, TH.fontBold,
                    Enum.TextXAlignment.Right, 6)
                
                local sliderBg = frame(row, TH.panel,
                    UDim2.new(1, -24, 0, 6), UDim2.new(0, 12, 0, 36), 6)
                corner(sliderBg, 3)
                
                local sliderFill = frame(sliderBg, Accent,
                    UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), 7)
                corner(sliderFill, 3)
                
                local value = def
                
                local function updateSlider()
                    local percent = (value - min) / (max - min)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    valueLbl.Text = tostring(math.floor(value))
                end
                
                updateSlider()
                
                local dragging = false
                
                sliderBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
                       inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                
                UIS.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
                       inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                UIS.InputChanged:Connect(function(inp)
                    if dragging then
                        local relX = math.clamp((inp.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                        value = min + (max - min) * relX
                        updateSlider()
                        pcall(cb, math.floor(value))
                    end
                end)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Set = function(_, v)
                        value = math.clamp(v, min, max)
                        updateSlider()
                    end,
                    Get = function() return math.floor(value) end,
                }
            end
            
            -- ── AddDropdown ───────────────────────────────────────────
            function Section:AddDropdown(o)
                o = o or {}
                local n = o.Name or "Dropdown"
                local items = o.Items or {"Option 1", "Option 2"}
                local def = o.Default or items[1]
                local cb = o.Callback or function() end
                
                local row = createRow(42)
                
                lbl(row, n, UDim2.new(1, -120, 0, 18), UDim2.new(0, 12, 0, 4),
                    13, TH.txt, TH.font, Enum.TextXAlignment.Left, 6)
                
                local dropdown = btn(row, def, UDim2.new(0, 100, 0, 28),
                    UDim2.new(1, -112, 0.5, -14), TH.input, 12, 6)
                corner(dropdown, 6)
                dropdown.TextXAlignment = Enum.TextXAlignment.Center
                
                local selected = def
                local dropOpen = false
                local dropList = nil
                
                dropdown.MouseButton1Click:Connect(function()
                    if dropOpen then
                        if dropList then dropList:Destroy() end
                        dropOpen = false
                    else
                        dropList = frame(row, TH.panel,
                            UDim2.new(0, 100, 0, math.min(#items * 26, 130)),
                            UDim2.new(1, -112, 1, 4), 20)
                        corner(dropList, 6)
                        stroke(dropList, 1, Accent, 0.4)
                        
                        local sf = Instance.new("ScrollingFrame")
                        sf.Parent = dropList
                        sf.Size = UDim2.new(1, 0, 1, 0)
                        sf.BackgroundTransparency = 1
                        sf.BorderSizePixel = 0
                        sf.ScrollBarThickness = 3
                        sf.CanvasSize = UDim2.new(0, 0, 0, #items * 26)
                        sf.ZIndex = 21
                        
                        listlayout(sf, nil, 2)
                        
                        for _, item in ipairs(items) do
                            local itemBtn = btn(sf, item,
                                UDim2.new(1, 0, 0, 24), nil, TH.btn, 11, 22)
                            itemBtn.TextXAlignment = Enum.TextXAlignment.Center
                            
                            itemBtn.MouseButton1Click:Connect(function()
                                selected = item
                                dropdown.Text = item
                                dropList:Destroy()
                                dropOpen = false
                                pcall(cb, item)
                            end)
                        end
                        
                        dropOpen = true
                    end
                end)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Set = function(_, v)
                        selected = v
                        dropdown.Text = v
                    end,
                    Get = function() return selected end,
                }
            end
            
            -- ── AddInput ──────────────────────────────────────────────
            function Section:AddInput(o)
                o = o or {}
                local n = o.Name or "Input"
                local ph = o.Placeholder or "Enter text..."
                local cb = o.Callback or function() end
                
                local row = createRow(60)
                
                lbl(row, n, UDim2.new(1, -24, 0, 18), UDim2.new(0, 12, 0, 4),
                    13, TH.txt, TH.font, Enum.TextXAlignment.Left, 6)
                
                local input = Instance.new("TextBox")
                input.Parent = row
                input.Size = UDim2.new(1, -24, 0, 28)
                input.Position = UDim2.new(0, 12, 0, 28)
                input.BackgroundColor3 = TH.input
                input.BorderSizePixel = 0
                input.Text = ""
                input.PlaceholderText = ph
                input.TextColor3 = TH.txt
                input.PlaceholderColor3 = TH.sub
                input.Font = TH.font
                input.TextSize = 12
                input.TextXAlignment = Enum.TextXAlignment.Left
                input.ZIndex = 6
                corner(input, 6)
                pad(input, 0, 8, 0, 8)
                
                input.FocusLost:Connect(function(enter)
                    if enter then
                        pcall(cb, input.Text)
                    end
                end)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Set = function(_, v) input.Text = v end,
                    Get = function() return input.Text end,
                }
            end
            
            -- ── AddLabel ──────────────────────────────────────────────
            function Section:AddLabel(text)
                local row = createRow(32)
                row.BackgroundTransparency = 1
                lbl(row, text, UDim2.new(1, -24, 1, 0), UDim2.new(0, 12, 0, 0),
                    12, TH.sub, TH.font, Enum.TextXAlignment.Left, 6)
            end
            
            -- ── AddSeparator ──────────────────────────────────────────
            function Section:AddSeparator()
                local sep = frame(content, TH.panel,
                    UDim2.new(1, 0, 0, 1), nil, 5)
            end
            
            -- ── AddKeybind ────────────────────────────────────────────
            function Section:AddKeybind(o)
                o = o or {}
                local n = o.Name or "Keybind"
                local def = o.Default or Enum.KeyCode.F
                local cb = o.Callback or function() end
                
                local row = createRow(42)
                
                lbl(row, n, UDim2.new(1, -80, 1, 0), UDim2.new(0, 12, 0, 0),
                    13, TH.txt, TH.font, Enum.TextXAlignment.Left, 6)
                
                local keyBtn = btn(row, def.Name,
                    UDim2.new(0, 70, 0, 28), UDim2.new(1, -82, 0.5, -14),
                    TH.input, 11, 6)
                corner(keyBtn, 6)
                keyBtn.TextXAlignment = Enum.TextXAlignment.Center
                
                local currentKey = def
                local binding = false
                
                keyBtn.MouseButton1Click:Connect(function()
                    if not binding then
                        binding = true
                        keyBtn.Text = "..."
                        
                        local conn; conn = UIS.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Keyboard then
                                currentKey = inp.KeyCode
                                keyBtn.Text = inp.KeyCode.Name
                                binding = false
                                conn:Disconnect()
                            end
                        end)
                    end
                end)
                
                UIS.InputBegan:Connect(function(inp)
                    if inp.KeyCode == currentKey and not binding then
                        pcall(cb)
                    end
                end)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Set = function(_, k)
                        currentKey = k
                        keyBtn.Text = k.Name
                    end,
                    Get = function() return currentKey end,
                }
            end
            
            -- ── AddCheckbox ───────────────────────────────────────────
            function Section:AddCheckbox(o)
                o = o or {}
                local n = o.Name or "Checkbox"
                local def = o.Default or false
                local cb = o.Callback or function() end
                
                local row = createRow(40)
                
                local checkBox = frame(row, TH.panel,
                    UDim2.new(0, 20, 0, 20), UDim2.new(0, 12, 0.5, -10), 6)
                corner(checkBox, 4)
                stroke(checkBox, 1, Accent, 0.5)
                
                local check = lbl(checkBox, "", UDim2.new(1, 0, 1, 0),
                    UDim2.new(0, 0, 0, 0), 16, Accent, TH.fontBold,
                    Enum.TextXAlignment.Center, 7)
                
                lbl(row, n, UDim2.new(1, -50, 1, 0), UDim2.new(0, 40, 0, 0),
                    13, TH.txt, TH.font, Enum.TextXAlignment.Left, 6)
                
                local state = def
                
                local function updateCheck()
                    check.Text = state and "✓" or ""
                end
                
                updateCheck()
                
                local checkBtn = btn(row, "", UDim2.new(1, 0, 1, 0),
                    UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 0, 0, 0), 1, 8)
                checkBtn.BackgroundTransparency = 1
                
                checkBtn.MouseButton1Click:Connect(function()
                    state = not state
                    updateCheck()
                    pcall(cb, state)
                end)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Set = function(_, v)
                        state = v
                        updateCheck()
                    end,
                    Get = function() return state end,
                }
            end
            
            -- ── AddProgressBar ────────────────────────────────────────
            function Section:AddProgressBar(o)
                o = o or {}
                local n = o.Name or "Progress"
                local val = o.Value or 0
                
                local row = createRow(50)
                
                lbl(row, n, UDim2.new(1, -60, 0, 18), UDim2.new(0, 12, 0, 4),
                    13, TH.txt, TH.font, Enum.TextXAlignment.Left, 6)
                
                local percentLbl = lbl(row, val .. "%",
                    UDim2.new(0, 50, 0, 18), UDim2.new(1, -56, 0, 4),
                    12, Accent, TH.fontBold, Enum.TextXAlignment.Right, 6)
                
                local progBg = frame(row, TH.panel,
                    UDim2.new(1, -24, 0, 8), UDim2.new(0, 12, 0, 32), 6)
                corner(progBg, 4)
                
                local progFill = frame(progBg, Accent,
                    UDim2.new(math.clamp(val / 100, 0, 1), 0, 1, 0),
                    UDim2.new(0, 0, 0, 0), 7)
                corner(progFill, 4)
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Set = function(_, v)
                        v = math.clamp(v, 0, 100)
                        progFill.Size = UDim2.new(v / 100, 0, 1, 0)
                        percentLbl.Text = v .. "%"
                    end,
                    Get = function()
                        return math.floor(progFill.Size.X.Scale * 100)
                    end,
                }
            end
            
            -- ── AddListbox ────────────────────────────────────────────
            function Section:AddListbox(o)
                o = o or {}
                local n = o.Name or "Listbox"
                local items = o.Items or {}
                local cb = o.Callback or function() end
                
                local lbH = 30 + math.min(#items, 4) * 26
                local row = createRow(lbH)
                
                lbl(row, n, UDim2.new(1, -24, 0, 20), UDim2.new(0, 12, 0, 4),
                    13, TH.txt, TH.fontBold, Enum.TextXAlignment.Left, 6)
                
                local sf = Instance.new("ScrollingFrame")
                sf.Parent = row
                sf.Size = UDim2.new(1, -24, 0, lbH - 30)
                sf.Position = UDim2.new(0, 12, 0, 26)
                sf.BackgroundColor3 = TH.panel
                sf.BorderSizePixel = 0
                sf.ScrollBarThickness = 3
                sf.CanvasSize = UDim2.new(0, 0, 0, #items * 26)
                sf.ZIndex = 6
                corner(sf, 6)
                
                listlayout(sf, nil, 2)
                
                local selected = nil
                
                for _, item in ipairs(items) do
                    local itemBtn = btn(sf, item,
                        UDim2.new(1, 0, 0, 24), nil, TH.btn, 11, 7)
                    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    pad(itemBtn, 0, 8, 0, 8)
                    
                    itemBtn.MouseButton1Click:Connect(function()
                        selected = item
                        tw(itemBtn, 0.1, {BackgroundColor3 = Accent}):Play()
                        task.delay(0.2, function()
                            tw(itemBtn, 0.1, {BackgroundColor3 = TH.btn}):Play()
                        end)
                        pcall(cb, item)
                    end)
                end
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {Get = function() return selected end}
            end
            
            -- ── AddMultibox ───────────────────────────────────────────
            function Section:AddMultibox(o)
                o = o or {}
                local n = o.Name or "Multibox"
                local items = o.Items or {}
                local cb = o.Callback or function() end
                
                local mbH = 30 + math.min(#items, 4) * 26
                local row = createRow(mbH)
                
                lbl(row, n, UDim2.new(1, -24, 0, 20), UDim2.new(0, 12, 0, 4),
                    13, TH.txt, TH.fontBold, Enum.TextXAlignment.Left, 6)
                
                local sf = Instance.new("ScrollingFrame")
                sf.Parent = row
                sf.Size = UDim2.new(1, -24, 0, mbH - 30)
                sf.Position = UDim2.new(0, 12, 0, 26)
                sf.BackgroundColor3 = TH.panel
                sf.BorderSizePixel = 0
                sf.ScrollBarThickness = 3
                sf.CanvasSize = UDim2.new(0, 0, 0, #items * 26)
                sf.ZIndex = 6
                corner(sf, 6)
                
                listlayout(sf, nil, 2)
                
                local selected = {}
                
                for _, item in ipairs(items) do
                    local itemBtn = btn(sf, "[ ] " .. item,
                        UDim2.new(1, 0, 0, 24), nil, TH.btn, 11, 7)
                    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    pad(itemBtn, 0, 8, 0, 8)
                    
                    itemBtn.MouseButton1Click:Connect(function()
                        if selected[item] then
                            selected[item] = nil
                            itemBtn.Text = "[ ] " .. item
                        else
                            selected[item] = true
                            itemBtn.Text = "[✓] " .. item
                        end
                        
                        local out = {}
                        for k in pairs(selected) do
                            table.insert(out, k)
                        end
                        pcall(cb, out)
                    end)
                end
                
                table.insert(_registry, {name=n, tabName=name, secName=secName, row=row})
                
                return {
                    Get = function()
                        local out = {}
                        for k in pairs(selected) do
                            table.insert(out, k)
                        end
                        return out
                    end
                }
            end
            
            return Section
        end
        
        return Tab
    end

    -- ══════════════════════════════════════════════════════════════════
    --  Built-in Tabs
    -- ══════════════════════════════════════════════════════════════════
    local MainTab = addTab("Main")
    local ConfigTab = addTab("Config")
    local SearchTab = addTab("Search")
    
    -- Config tab content
    do
        local CS = ConfigTab:AddSection("Config")
        CS:AddButton({
            Name = "Save Config",
            Callback = function()
                pcall(function()
                    if writefile then
                        writefile("SL_config.json", HttpSvc:JSONEncode({}))
                    end
                end)
            end
        })
        CS:AddButton({
            Name = "Load Config",
            Callback = function()
                pcall(function()
                    if readfile then
                        local _ = HttpSvc:JSONDecode(readfile("SL_config.json"))
                    end
                end)
            end
        })
    end
    
    -- Search tab content
    do
        local SS = SearchTab:AddSection("Search")
        local resultSec = SearchTab:AddSection("Results")
        local lastResults = {}
        
        SS:AddInput({
            Name = "Search Components",
            Placeholder = "Component name...",
            Callback = function(text)
                for _, ctrl in ipairs(lastResults) do
                    pcall(function() ctrl.row:Destroy() end)
                end
                lastResults = {}
                
                local q = text:lower()
                for _, entry in ipairs(_registry) do
                    if entry.name:lower():find(q, 1, true) then
                        local lctrl = resultSec:AddLabel(
                            entry.name .. " [" .. entry.tabName .. "/" .. entry.secName .. "]"
                        )
                        table.insert(lastResults, {row = lctrl})
                    end
                end
            end,
        })
    end
    
    -- Set Main as default active
    setActiveTab("Main")

    -- ══════════════════════════════════════════════════════════════════
    --  Window API
    -- ══════════════════════════════════════════════════════════════════
    local Window = {}
    
    function Window:GetMainTab() return tabs["Main"].api end
    function Window:GetConfigTab() return tabs["Config"].api end
    function Window:GetSearchTab() return tabs["Search"].api end
    
    function Window:AddTab(name, iconId)
        return addTab(name, iconId)
    end
    
    function Window:Notify(msg, dur)
        dur = dur or 3
        local notif = frame(SG, TH.panel,
            UDim2.new(0, 250, 0, 50),
            UDim2.new(1, -260, 1, -60), 30)
        corner(notif, 10)
        stroke(notif, 1, Accent, 0.5)
        
        lbl(notif, tostring(msg), UDim2.new(1, -20, 1, 0),
            UDim2.new(0, 10, 0, 0), 12, TH.txt, TH.font,
            Enum.TextXAlignment.Left, 31)
        
        notif.BackgroundTransparency = 1
        tw(notif, 0.2, {BackgroundTransparency = 0}):Play()
        
        task.delay(dur, function()
            tw(notif, 0.2, {BackgroundTransparency = 1}):Play()
            task.delay(0.25, function()
                pcall(function() notif:Destroy() end)
            end)
        end)
    end
    
    function Window:SetAccent(hex)
        -- Fixed RGB parsing
        hex = hex:gsub("#", "")
        local r = tonumber(hex:sub(1, 2), 16) or 100
        local g = tonumber(hex:sub(3, 4), 16) or 120
        local b = tonumber(hex:sub(5, 6), 16) or 255
        Accent = Color3.fromRGB(r, g, b)
        AccLine.BackgroundColor3 = Accent
    end
    
    function Window:SetTitle(t)
        -- Update title
    end
    
    -- Store tab APIs
    tabs["Main"] = {btn = nil, content = MainTab:GetSection(""), api = MainTab}
    tabs["Config"] = {btn = nil, content = ConfigTab:GetSection(""), api = ConfigTab}
    tabs["Search"] = {btn = nil, content = SearchTab:GetSection(""), api = SearchTab}
    
    return Window
end

return ScreenLibrary
