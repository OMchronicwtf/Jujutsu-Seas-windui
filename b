-- ============================================================
-- ChronosUI — Roblox UI Library
-- Part 1 of N: Core, Icons, Theme, Window, Sidebar, Tab System
-- ============================================================
-- Usage:
--   local ChronosUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--   local Window = ChronosUI:CreateWindow({ ... })
--   local Tab = Window:Tab({ Title = "General", Icon = "lucide:house" })
--   Tab:Button({ ... })
-- ============================================================

local ChronosUI = {}
ChronosUI.__index = ChronosUI

-- ============================================================
-- SERVICES
-- ============================================================

local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")

-- ============================================================
-- ICON SYSTEM (Footages Icons v2 compatible)
-- ============================================================

local Icons = {}
Icons._defaultType = "lucide"
Icons._packs = {}
Icons._spritesheets = {}
Icons._loaded = false

function Icons:Load()
    if self._loaded then return end
    self._loaded = true
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
        ))()
    end)
    if ok and result then
        self._v2 = result
    else
        -- Fallback: try individual packs
        local packs = {
            lucide    = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
            solar     = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua",
            craft     = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua",
            geist     = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua",
            sfsymbols = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua",
            gravity   = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua",
        }
        for name, url in pairs(packs) do
            pcall(function()
                local r = loadstring(game:HttpGet(url))()
                if type(r) ~= "table" then return end
                if r.Spritesheets and r.Icons then
                    self._spritesheets[name] = { sheets = r.Spritesheets, icons = r.Icons }
                    self._packs[name] = r.Icons
                else
                    self._packs[name] = r
                end
            end)
        end
    end
end

function Icons:SetDefaultType(packName)
    self._defaultType = packName
end

-- Returns the image asset string for an icon name.
-- Supports:  "house"  =>  default pack
--            "lucide:house"
--            "sfsymbols:HouseFill"
function Icons:Get(name)
    if not name or name == "" then return "" end
    -- v2 API
    if self._v2 then
        local colonPos = string.find(name, ":", 1, true)
        if colonPos then
            local packName = string.sub(name, 1, colonPos - 1)
            local iconName = string.sub(name, colonPos + 1)
            self._v2.SetIconsType(packName)
            local ok, img = pcall(function() return self._v2.GetIcon(iconName) end)
            if ok and img then return img end
        else
            self._v2.SetIconsType(self._defaultType)
            local ok, img = pcall(function() return self._v2.GetIcon(name) end)
            if ok and img then return img end
        end
        return ""
    end
    -- Fallback: manual packs
    local colonPos = string.find(name, ":", 1, true)
    if colonPos then
        local packName = string.sub(name, 1, colonPos - 1)
        local iconName = string.sub(name, colonPos + 1)
        local sprite = self._spritesheets[packName] and self._spritesheets[packName].icons[iconName]
        if sprite then
            return self._spritesheets[packName].sheets[tostring(sprite.Image)] or ""
        end
        local pack = self._packs[packName]
        if pack and pack[iconName] then return pack[iconName] end
        return ""
    end
    local pack = self._packs[self._defaultType] or self._packs.lucide
    if pack and pack[name] then return pack[name] end
    return ""
end

-- ============================================================
-- DEFAULT THEME (ChronosHUB Dark Purple/Teal)
-- ============================================================

local DefaultTheme = {
    -- Window
    WindowBG        = Color3.fromHex("#1f1a2e"),
    WindowBG2       = Color3.fromHex("#1a2433"),
    TitleBarBG      = Color3.fromHex("#272036"),
    -- Sidebar
    SidebarBG       = Color3.fromHex("#1a1528"),
    SidebarHover    = Color3.fromHex("#2a223f"),
    SidebarActive   = Color3.fromHex("#352a52"),
    SidebarAccent   = Color3.fromHex("#d4a940"),   -- active tab indicator stripe
    -- Content / cards
    ContentBG       = Color3.fromHex("#1a1528"),
    CardBG          = Color3.fromHex("#221c33"),
    SectionBG       = Color3.fromHex("#1d1830"),
    -- Text
    TextPrimary     = Color3.fromHex("#ebe8f2"),
    TextSecondary   = Color3.fromHex("#c9c3da"),
    TextMuted       = Color3.fromHex("#9489b0"),
    TextDim         = Color3.fromHex("#6e6489"),
    -- Accents
    AccentPrimary   = Color3.fromHex("#d4a940"),   -- gold
    AccentPrimaryH  = Color3.fromHex("#e8be58"),
    AccentSuccess   = Color3.fromHex("#5eb88a"),
    AccentDanger    = Color3.fromHex("#a02a40"),
    AccentWarning   = Color3.fromHex("#a07028"),
    AccentInfo      = Color3.fromHex("#1c6878"),
    -- Buttons
    ButtonDark      = Color3.fromHex("#2d2542"),
    ButtonDarkH     = Color3.fromHex("#3a3055"),
    ButtonDanger    = Color3.fromHex("#a02a40"),
    ButtonDangerH   = Color3.fromHex("#bd3550"),
    ButtonWarning   = Color3.fromHex("#a07028"),
    ButtonWarningH  = Color3.fromHex("#bd8530"),
    ButtonSuccess   = Color3.fromHex("#1c6878"),
    ButtonSuccessH  = Color3.fromHex("#247b8e"),
    -- Borders
    Border          = Color3.fromHex("#3a3050"),
    BorderLight     = Color3.fromHex("#4a3f68"),
    -- Toggle
    ToggleOff       = Color3.fromHex("#3a3050"),
    ToggleOn        = Color3.fromHex("#d4a940"),
    ToggleKnob      = Color3.fromHex("#ebe8f2"),
    -- Slider
    SliderTrack     = Color3.fromHex("#3a3050"),
    SliderFill      = Color3.fromHex("#d4a940"),
    SliderKnob      = Color3.fromHex("#ebe8f2"),
    -- Progress
    ProgressTrack   = Color3.fromHex("#3a3050"),
    ProgressFill    = Color3.fromHex("#d4a940"),
    -- Input
    InputBG         = Color3.fromHex("#1d1830"),
    -- Dropdown
    DropdownBG      = Color3.fromHex("#221c33"),
    DropdownItemH   = Color3.fromHex("#2a223f"),
    -- Toast / Notify
    ToastBG         = Color3.fromHex("#221c33"),
    -- Divider
    DividerColor    = Color3.fromHex("#3a3050"),
    -- Modal
    ModalOverlay    = Color3.fromHex("#000000"),
    -- Icon default colour
    IconColor       = Color3.fromHex("#d4a940"),
}

local DefaultFonts = {
    Title    = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    Header   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    Body     = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
    BodyBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
    Code     = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular),
}

-- ============================================================
-- HELPERS
-- ============================================================

local H = {}

function H.tween(obj, props, t, style, dir)
    return TweenService:Create(obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
end

function H.stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color           = color
    s.Thickness       = thickness or 1
    s.Transparency    = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = parent
    return s
end

function H.corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent       = parent
    return c
end

function H.pad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent        = parent
    return p
end

function H.hover(btn, normal, hov)
    btn.MouseEnter:Connect(function() H.tween(btn, { BackgroundColor3 = hov }):Play() end)
    btn.MouseLeave:Connect(function() H.tween(btn, { BackgroundColor3 = normal }):Play() end)
end

function H.icon(iconName, size, color)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Size        = size or UDim2.fromOffset(16, 16)
    img.Image       = Icons:Get(iconName or "")
    img.ImageColor3 = color or Color3.new(1,1,1)
    img.ScaleType   = Enum.ScaleType.Fit
    return img
end

function H.draggable(handle, target)
    local dragging, dragStart, startPos, dragInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

function H.label(parent, text, font, size, color, xAlign, yAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = text or ""
    l.FontFace       = font or DefaultFonts.Body
    l.TextSize       = size or 12
    l.TextColor3     = color or DefaultTheme.TextPrimary
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = yAlign or Enum.TextYAlignment.Center
    l.TextWrapped    = false
    l.Parent         = parent
    return l
end

function H.list(parent, dir, padding, hAlign, vAlign)
    local l = Instance.new("UIListLayout")
    l.FillDirection       = dir or Enum.FillDirection.Vertical
    l.Padding             = UDim.new(0, padding or 0)
    l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = vAlign or Enum.VerticalAlignment.Top
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.Parent              = parent
    return l
end

function H.frame(parent, size, pos, bg, zindex)
    local f = Instance.new("Frame")
    f.Size                = size or UDim2.fromScale(1,1)
    f.Position            = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3    = bg or Color3.new(0,0,0)
    f.BackgroundTransparency = bg and 0 or 1
    f.BorderSizePixel     = 0
    f.ZIndex              = zindex or 1
    f.Parent              = parent
    return f
end

function H.clipFrame(parent, size, pos, bg, zindex)
    local f = H.frame(parent, size, pos, bg, zindex)
    f.ClipsDescendants = true
    return f
end

function H.scrollFrame(parent, size, pos, zindex)
    local sf = Instance.new("ScrollingFrame")
    sf.Size                  = size or UDim2.fromScale(1,1)
    sf.Position              = pos or UDim2.new(0,0,0,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel       = 0
    sf.ScrollBarThickness    = 3
    sf.ScrollBarImageColor3  = DefaultTheme.Border
    sf.CanvasSize            = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    sf.ZIndex                = zindex or 1
    sf.Parent                = parent
    return sf
end

-- ============================================================
-- LIBRARY INIT — called once
-- ============================================================

local _initialized = false

function ChronosUI:Init()
    if _initialized then return end
    _initialized = true
    Icons:Load()
end

-- ============================================================
-- WINDOW CLASS
-- ============================================================

local Window = {}
Window.__index = Window

--[[
    ChronosUI:CreateWindow(opts)

    opts:
        Title               string
        Subtitle            string          (shown under title)
        Icon                string          (icon name, e.g. "lucide:moon-star")
        Theme               table           (override DefaultTheme keys)
        Size                UDim2           default 900x560
        MinSize             Vector2         default 700x440
        SidebarWidth        number          default 52 (icon-only collapsed sidebar)
        TopbarHeight        number          default 46
        Resizable           boolean         default true
        Draggable           boolean         default true
        OpenButton          table | false   floating restore button opts
            .Enabled        bool
            .Icon           string
            .Position       UDim2
]]

function ChronosUI:CreateWindow(opts)
    self:Init()
    opts = opts or {}

    local T = setmetatable({}, { __index = DefaultTheme })
    if opts.Theme then
        for k, v in pairs(opts.Theme) do T[k] = v end
    end

    local F = DefaultFonts
    local sidebarW    = opts.SidebarWidth  or 52
    local topbarH     = opts.TopbarHeight  or 46
    local defaultSize = opts.Size          or UDim2.fromOffset(900, 560)
    local minSize     = opts.MinSize       or Vector2.new(700, 440)
    local resizable   = opts.Resizable ~= false
    local draggable   = opts.Draggable  ~= false

    -- Destroy old instance
    pcall(function()
        local old = CoreGui:FindFirstChild("__ChronosUI__")
        if old then old:Destroy() end
    end)
    pcall(function()
        if gethui then
            local old = gethui():FindFirstChild("__ChronosUI__")
            if old then old:Destroy() end
        end
    end)

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "__ChronosUI__"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder   = 9999
    ScreenGui.IgnoreGuiInset = true

    local parentTarget = CoreGui
    pcall(function()
        if gethui and typeof(gethui) == "function" then
            local hui = gethui()
            if hui then parentTarget = hui end
        end
    end)
    ScreenGui.Parent = parentTarget
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)

    -- ── Main Window Frame ──────────────────────────────────
    local Main = Instance.new("Frame")
    Main.Name             = "Main"
    Main.AnchorPoint      = Vector2.new(0.5, 0.5)
    Main.Size             = defaultSize
    Main.Position         = UDim2.fromScale(0.5, 0.5)
    Main.BackgroundColor3 = T.WindowBG
    Main.BorderSizePixel  = 0
    Main.ClipsDescendants = true
    Main.Parent           = ScreenGui
    -- Sharp corners on the window itself
    -- (no UICorner — sharp window edges)
    H.stroke(Main, T.BorderLight, 1)

    -- Gradient
    local mainGrad = Instance.new("UIGradient")
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.WindowBG),
        ColorSequenceKeypoint.new(1, T.WindowBG2),
    })
    mainGrad.Rotation = 45
    mainGrad.Parent   = Main

    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size               = UDim2.new(1, 60, 1, 60)
    shadow.Position           = UDim2.new(0, -30, 0, -30)
    shadow.BackgroundTransparency = 1
    shadow.Image              = "rbxassetid://5554236805"
    shadow.ImageColor3        = Color3.new(0,0,0)
    shadow.ImageTransparency  = 0.45
    shadow.ScaleType          = Enum.ScaleType.Slice
    shadow.SliceCenter        = Rect.new(23, 23, 277, 277)
    shadow.ZIndex             = 0
    shadow.Parent             = Main

    -- ── Top Bar ───────────────────────────────────────────
    local TopBar = Instance.new("Frame")
    TopBar.Name             = "TopBar"
    TopBar.Size             = UDim2.new(1, 0, 0, topbarH)
    TopBar.BackgroundColor3 = T.TitleBarBG
    TopBar.BorderSizePixel  = 0
    TopBar.ZIndex           = 10
    TopBar.Parent           = Main

    -- Bottom border on topbar
    local topBorder = H.frame(TopBar, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), T.Border, 11)

    -- Icon
    local titleIconImg = H.icon(opts.Icon or "lucide:layout-dashboard", UDim2.fromOffset(20,20), T.AccentPrimary)
    titleIconImg.Position = UDim2.new(0, 14, 0.5, -10)
    titleIconImg.ZIndex   = 11
    titleIconImg.Parent   = TopBar

    -- Title
    local titleLabel = H.label(TopBar, opts.Title or "ChronosUI", F.Title, 14, T.TextPrimary)
    titleLabel.Size             = UDim2.fromOffset(220, topbarH)
    titleLabel.Position         = UDim2.new(0, 42, 0, 0)
    titleLabel.ZIndex           = 11

    -- Subtitle badge (optional)
    if opts.Subtitle then
        local subLabel = H.label(TopBar, opts.Subtitle, F.Body, 10, T.TextMuted)
        subLabel.Size     = UDim2.fromOffset(220, topbarH)
        subLabel.Position = UDim2.new(0, 42, 0, 0)
        subLabel.TextYAlignment = Enum.TextYAlignment.Bottom
        H.pad(subLabel, 0, 8, 0, 0)
        subLabel.ZIndex   = 11
    end

    -- Window control buttons (right side) — sharp corners
    local function makeCtrlBtn(icon, xOff, bg, bgH, callback)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.fromOffset(32, 26)
        btn.Position         = UDim2.new(1, xOff, 0.5, -13)
        btn.BackgroundColor3 = bg
        btn.BorderSizePixel  = 0
        btn.Text             = ""
        btn.AutoButtonColor  = false
        btn.ZIndex           = 11
        btn.Parent           = TopBar
        H.corner(btn, 4)
        local ic = H.icon(icon, UDim2.fromOffset(13,13), T.TextPrimary)
        ic.AnchorPoint = Vector2.new(0.5,0.5)
        ic.Position    = UDim2.new(0.5,0,0.5,0)
        ic.ZIndex      = 12
        ic.Parent      = btn
        H.hover(btn, bg, bgH)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local CloseBtn   = makeCtrlBtn("lucide:x",     -10,  T.ButtonDanger,  T.ButtonDangerH,  function() end)
    local MinBtn     = makeCtrlBtn("lucide:minus",  -46, T.ButtonWarning, T.ButtonWarningH, function()
        Main.Visible = false
    end)

    if draggable then H.draggable(TopBar, Main) end

    -- ── Body ──────────────────────────────────────────────
    local Body = H.frame(Main,
        UDim2.new(1, 0, 1, -topbarH),
        UDim2.new(0, 0, 0, topbarH),
        nil, 5)

    -- ── Sidebar ───────────────────────────────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Name             = "Sidebar"
    Sidebar.Size             = UDim2.new(0, sidebarW, 1, 0)
    Sidebar.BackgroundColor3 = T.SidebarBG
    Sidebar.BorderSizePixel  = 0
    Sidebar.ZIndex           = 10
    Sidebar.Parent           = Body

    -- Right border on sidebar
    H.frame(Sidebar, UDim2.new(0,1,1,0), UDim2.new(1,0,0,0), T.Border, 11)

    -- Top tab list (scrollable)
    local SidebarTop = H.scrollFrame(Sidebar,
        UDim2.new(1, 0, 1, -54),
        UDim2.new(0,0,0,0),
        11)
    SidebarTop.ScrollBarThickness = 0
    H.list(SidebarTop, Enum.FillDirection.Vertical, 4,
        Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
    H.pad(SidebarTop, 10, 10, 0, 0)

    -- Bottom tab list (settings etc.)
    local SidebarBottom = H.frame(Sidebar,
        UDim2.new(1,0,0,54),
        UDim2.new(0,0,1,-54),
        nil, 11)
    H.list(SidebarBottom, Enum.FillDirection.Vertical, 4,
        Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
    H.pad(SidebarBottom, 6, 6, 0, 0)

    -- ── Content ───────────────────────────────────────────
    local Content = H.clipFrame(Body,
        UDim2.new(1, -sidebarW, 1, 0),
        UDim2.new(0, sidebarW, 0, 0),
        T.ContentBG, 5)

    -- ── Toast Container ───────────────────────────────────
    -- Sits above content, anchored bottom-right, padded so resize handle isn't covered
    local ToastContainer = H.frame(Content,
        UDim2.new(1,0,1,0),
        UDim2.new(0,0,0,0),
        nil, 600)
    ToastContainer.ClipsDescendants = false

    -- ── Resize Handle ─────────────────────────────────────
    local resizeHandle, resizeIcon
    if resizable then
        resizeHandle = Instance.new("TextButton")
        resizeHandle.Size                = UDim2.fromOffset(20, 20)
        resizeHandle.Position            = UDim2.new(1, -22, 1, -22)
        resizeHandle.BackgroundTransparency = 1
        resizeHandle.Text                = ""
        resizeHandle.AutoButtonColor     = false
        resizeHandle.ZIndex              = 50
        resizeHandle.Parent              = Main

        resizeIcon = H.icon("lucide:move-diagonal-2", UDim2.fromOffset(14,14), T.TextMuted)
        resizeIcon.AnchorPoint = Vector2.new(0.5,0.5)
        resizeIcon.Position    = UDim2.new(0.5,0,0.5,0)
        resizeIcon.ZIndex      = 51
        resizeIcon.Parent      = resizeHandle

        resizeHandle.MouseEnter:Connect(function()
            H.tween(resizeIcon, { ImageColor3 = T.AccentPrimary }):Play()
        end)
        resizeHandle.MouseLeave:Connect(function()
            H.tween(resizeIcon, { ImageColor3 = T.TextMuted }):Play()
        end)

        local resizing, rStart, rSize, rInput, lastResize = false, nil, nil, nil, 0
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                rStart   = input.Position
                rSize    = Main.AbsoluteSize
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then resizing = false end
                end)
            end
        end)
        resizeHandle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                rInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == rInput and resizing then
                local now = tick()
                if now - lastResize < 0.016 then return end
                lastResize = now
                local d = input.Position - rStart
                local w  = math.max(rSize.X + d.X, minSize.X)
                local hh = math.max(rSize.Y + d.Y, minSize.Y)
                Main.Size = UDim2.fromOffset(w, hh)
            end
        end)
    end

    -- ── Floating Restore Button ────────────────────────────
    local openBtnOpts = opts.OpenButton or {}
    local FloatIcon
    if openBtnOpts.Enabled ~= false then
        FloatIcon = Instance.new("Frame")
        FloatIcon.AnchorPoint      = Vector2.new(0.5, 0.5)
        FloatIcon.Size             = UDim2.fromOffset(44, 44)
        FloatIcon.Position         = openBtnOpts.Position or UDim2.new(0, 60, 0, 80)
        FloatIcon.BackgroundColor3 = T.TitleBarBG
        FloatIcon.BorderSizePixel  = 0
        FloatIcon.Visible          = false
        FloatIcon.ZIndex           = 50
        FloatIcon.ClipsDescendants = true
        FloatIcon.Parent           = ScreenGui
        H.corner(FloatIcon, 8)
        H.stroke(FloatIcon, T.AccentPrimary, 1)

        local floatGrad = Instance.new("UIGradient")
        floatGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#2d1250")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#0e4550")),
        })
        floatGrad.Rotation = 45
        floatGrad.Parent   = FloatIcon

        local floatBtn = Instance.new("TextButton")
        floatBtn.Size                = UDim2.fromScale(1,1)
        floatBtn.BackgroundTransparency = 1
        floatBtn.Text                = ""
        floatBtn.AutoButtonColor     = false
        floatBtn.ZIndex              = 52
        floatBtn.Parent              = FloatIcon

        local floatImg = H.icon(openBtnOpts.Icon or opts.Icon or "lucide:layout-dashboard",
            UDim2.fromOffset(22,22), T.AccentPrimary)
        floatImg.AnchorPoint = Vector2.new(0.5,0.5)
        floatImg.Position    = UDim2.new(0.5,0,0.5,0)
        floatImg.ZIndex      = 53
        floatImg.Parent      = FloatIcon

        H.draggable(floatBtn, FloatIcon)

        floatBtn.MouseButton1Click:Connect(function()
            FloatIcon.Visible = false
            Main.Visible      = true
        end)

        -- Wire minimize to show float
        MinBtn.MouseButton1Click:Connect(function()
            Main.Visible      = false
            FloatIcon.Visible = true
        end)
    end

    -- ── Toast System ──────────────────────────────────────

    local toastQueue   = {}
    local toastRunning = false
    local TOAST_PADDING_BOTTOM = 28 -- above resize handle

    local TOAST_KINDS = {
        success = { icon = "lucide:check",        color = T.AccentSuccess },
        error   = { icon = "lucide:circle-alert",  color = T.AccentDanger  },
        warning = { icon = "lucide:triangle-alert", color = T.AccentWarning },
        info    = { icon = "lucide:info",           color = T.AccentInfo    },
    }

    local function showToast(text, kind)
        kind = kind or "info"
        local k = TOAST_KINDS[kind] or TOAST_KINDS.info
        table.insert(toastQueue, { text = text, icon = k.icon, color = k.color })
        if toastRunning then return end
        toastRunning = true
        task.spawn(function()
            while #toastQueue > 0 do
                local item = table.remove(toastQueue, 1)
                local pill = Instance.new("Frame")
                pill.Size             = UDim2.fromOffset(260, 36)
                pill.Position         = UDim2.new(1, -280, 1, 20)
                pill.BackgroundColor3 = T.ToastBG
                pill.BorderSizePixel  = 0
                pill.ZIndex           = 601
                pill.ClipsDescendants = true
                pill.Parent           = ToastContainer
                H.stroke(pill, T.BorderLight, 1)
                H.corner(pill, 6)

                local pillList = H.list(pill, Enum.FillDirection.Horizontal, 8,
                    Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
                H.pad(pill, 0, 0, 10, 10)

                local ic = H.icon(item.icon, UDim2.fromOffset(13,13), item.color)
                ic.LayoutOrder = 1
                ic.ZIndex      = 602
                ic.Parent      = pill

                local lbl = Instance.new("TextLabel")
                lbl.AutomaticSize          = Enum.AutomaticSize.X
                lbl.Size                   = UDim2.fromOffset(0, 36)
                lbl.BackgroundTransparency = 1
                lbl.Text                   = item.text
                lbl.TextColor3             = T.TextPrimary
                lbl.FontFace               = DefaultFonts.BodyBold
                lbl.TextSize               = 11
                lbl.LayoutOrder            = 2
                lbl.ZIndex                 = 602
                lbl.Parent                 = pill

                local targetY = -(TOAST_PADDING_BOTTOM + 36)
                H.tween(pill, { Position = UDim2.new(1, -280, 1, targetY) },
                    0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                task.wait(2.3)
                H.tween(pill, { Position = UDim2.new(1, -280, 1, 20) }, 0.18):Play()
                task.wait(0.2)
                pill:Destroy()
                task.wait(0.06)
            end
            toastRunning = false
        end)
    end

    -- ── Notification (center modal style) ─────────────────

    local notifQueue   = {}
    local notifRunning = false

    local function showNotification(opts2)
        opts2 = opts2 or {}
        table.insert(notifQueue, opts2)
        if notifRunning then return end
        notifRunning = true
        task.spawn(function()
            while #notifQueue > 0 do
                local item = notifQueue[1]
                table.remove(notifQueue, 1)

                local NW, NH = 300, 80
                local notifFrame = Instance.new("Frame")
                notifFrame.Size             = UDim2.fromOffset(NW, NH)
                notifFrame.AnchorPoint      = Vector2.new(1, 0)
                notifFrame.Position         = UDim2.new(1, -10, 0, -NH)
                notifFrame.BackgroundColor3 = T.CardBG
                notifFrame.BorderSizePixel  = 0
                notifFrame.ZIndex           = 620
                notifFrame.ClipsDescendants = true
                notifFrame.Parent           = Content
                H.stroke(notifFrame, T.BorderLight, 1)
                H.corner(notifFrame, 6)

                -- Icon strip (left colored accent)
                local kindColor = T.AccentInfo
                if item.Kind == "success" then kindColor = T.AccentSuccess
                elseif item.Kind == "error" then kindColor = T.AccentDanger
                elseif item.Kind == "warning" then kindColor = T.AccentWarning end

                local strip = H.frame(notifFrame, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), kindColor, 621)

                -- Icon
                if item.Icon and item.Icon ~= "" then
                    local nic = H.icon(item.Icon, UDim2.fromOffset(16,16), kindColor)
                    nic.Position = UDim2.new(0, 14, 0, 14)
                    nic.ZIndex   = 621
                    nic.Parent   = notifFrame
                end

                local tx = (item.Icon and item.Icon ~= "") and 36 or 12

                local titleL = H.label(notifFrame, item.Title or "", DefaultFonts.BodyBold, 12, T.TextPrimary)
                titleL.Size     = UDim2.new(1, -(tx+8), 0, 18)
                titleL.Position = UDim2.new(0, tx, 0, 10)
                titleL.ZIndex   = 621

                if item.Content and item.Content ~= "" then
                    local contentL = H.label(notifFrame, item.Content, DefaultFonts.Body, 10, T.TextMuted)
                    contentL.Size       = UDim2.new(1, -(tx+8), 0, 32)
                    contentL.Position   = UDim2.new(0, tx, 0, 30)
                    contentL.TextWrapped = true
                    contentL.ZIndex     = 621
                end

                H.tween(notifFrame, { Position = UDim2.new(1,-10,0,10) },
                    0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

                local dur = item.Duration or 3
                task.wait(dur)
                H.tween(notifFrame, { Position = UDim2.new(1,-10,0,-NH) }, 0.18):Play()
                task.wait(0.2)
                notifFrame:Destroy()
                task.wait(0.05)
            end
            notifRunning = false
        end)
    end

    -- ── Confirm Dialog ─────────────────────────────────────

    local function showConfirm(title, message, onConfirm, onCancel)
        local DW, DH, DTH = 380, 190, 36

        local overlay = Instance.new("Frame")
        overlay.Size                   = UDim2.fromScale(1,1)
        overlay.BackgroundColor3       = T.ModalOverlay
        overlay.BackgroundTransparency = 1
        overlay.BorderSizePixel        = 0
        overlay.ZIndex                 = 500
        overlay.ClipsDescendants       = false
        overlay.Parent                 = Content

        local blocker = Instance.new("TextButton")
        blocker.Size                   = UDim2.fromScale(1,1)
        blocker.BackgroundTransparency = 1
        blocker.Text                   = ""
        blocker.AutoButtonColor        = false
        blocker.ZIndex                 = 500
        blocker.Parent                 = overlay

        local dlg = Instance.new("Frame")
        dlg.Size             = UDim2.fromOffset(DW, DH)
        dlg.AnchorPoint      = Vector2.new(0.5,0.5)
        dlg.Position         = UDim2.fromScale(0.5,0.5)
        dlg.BackgroundColor3 = T.SidebarBG
        dlg.BorderSizePixel  = 0
        dlg.ZIndex           = 501
        -- Sharp corners on dialog (window-like)
        dlg.Parent           = overlay
        H.stroke(dlg, T.BorderLight, 1)

        local dlgTop = H.frame(dlg, UDim2.new(1,0,0,DTH), nil, T.TitleBarBG, 502)
        H.frame(dlgTop, UDim2.new(1,0,0,1), UDim2.new(0,0,1,0), T.Border, 502)

        local hic = H.icon("lucide:circle-alert", UDim2.fromOffset(15,15), T.AccentPrimary)
        hic.Position = UDim2.new(0,12,0.5,-7)
        hic.ZIndex   = 503
        hic.Parent   = dlgTop

        local htl = H.label(dlgTop, title, DefaultFonts.Title, 12, T.TextPrimary)
        htl.Size     = UDim2.new(1,-36,1,0)
        htl.Position = UDim2.new(0,34,0,0)
        htl.ZIndex   = 503

        local msgL = H.label(dlg, message, DefaultFonts.Body, 11, T.TextSecondary)
        msgL.Size        = UDim2.new(1,-32,0,60)
        msgL.Position    = UDim2.new(0,16,0,DTH+12)
        msgL.TextWrapped = true
        msgL.ZIndex      = 502

        local btnRow = H.frame(dlg, UDim2.new(1,-32,0,32), UDim2.new(0,16,1,-46), nil, 502)
        H.list(btnRow, Enum.FillDirection.Horizontal, 10,
            Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

        local function close()
            H.tween(overlay, { BackgroundTransparency = 1 }, 0.12):Play()
            task.wait(0.13)
            overlay:Destroy()
        end

        local cancelB = Instance.new("TextButton")
        cancelB.Size             = UDim2.fromOffset(88, 30)
        cancelB.BackgroundColor3 = T.ButtonDark
        cancelB.BorderSizePixel  = 0
        cancelB.Text             = "Cancel"
        cancelB.TextColor3       = T.TextPrimary
        cancelB.FontFace         = DefaultFonts.BodyBold
        cancelB.TextSize         = 11
        cancelB.AutoButtonColor  = false
        cancelB.LayoutOrder      = 1
        cancelB.ZIndex           = 503
        cancelB.Parent           = btnRow
        H.corner(cancelB, 4)
        H.stroke(cancelB, T.BorderLight, 1)
        H.hover(cancelB, T.ButtonDark, T.ButtonDarkH)
        cancelB.MouseButton1Click:Connect(function() close(); if onCancel then onCancel() end end)

        local okB = Instance.new("TextButton")
        okB.Size             = UDim2.fromOffset(100, 30)
        okB.BackgroundColor3 = T.ButtonDanger
        okB.BorderSizePixel  = 0
        okB.Text             = ""
        okB.AutoButtonColor  = false
        okB.LayoutOrder      = 2
        okB.ZIndex           = 503
        okB.Parent           = btnRow
        H.corner(okB, 4)
        H.stroke(okB, T.BorderLight, 1, 0.4)
        H.hover(okB, T.ButtonDanger, T.ButtonDangerH)

        local okRow = H.list(okB, Enum.FillDirection.Horizontal, 6,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
        local okIc = H.icon("lucide:check", UDim2.fromOffset(12,12), T.TextPrimary)
        okIc.LayoutOrder = 1; okIc.ZIndex = 504; okIc.Parent = okB
        local okLbl = H.label(okB, "Confirm", DefaultFonts.BodyBold, 11, T.TextPrimary)
        okLbl.AutomaticSize = Enum.AutomaticSize.X
        okLbl.Size          = UDim2.fromOffset(0,12)
        okLbl.LayoutOrder   = 2; okLbl.ZIndex = 504

        H.tween(overlay, { BackgroundTransparency = 0.5 }, 0.15):Play()
        blocker.MouseButton1Click:Connect(close)
        okB.MouseButton1Click:Connect(function() close(); if onConfirm then onConfirm() end end)
    end

    -- Wire close button
    CloseBtn.MouseButton1Click:Connect(function()
        showConfirm(
            "Close window?",
            "Are you sure you want to close? Re-execute the script to reopen.",
            function() ScreenGui:Destroy() end
        )
    end)

    -- ── Tab / Module system ───────────────────────────────
    local registeredTabs = {}  -- { id, label, icon, bottom, init, onShow, onHide }
    local tabFrames      = {}
    local tabButtons     = {}
    local activeTab      = nil

    -- Returns the public Tab API for building elements into it
    local function makeTabAPI(tabFrame, theme, fonts, _winRef)
        local tabAPI = {}
        tabAPI._frame = tabFrame
        tabAPI._theme = theme
        tabAPI._fonts = fonts

        -- Internal scroll container for all elements
        local scrollArea = H.scrollFrame(tabFrame,
            UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 6)
        scrollArea.ScrollBarImageColor3 = theme.Border
        tabAPI._scroll = scrollArea

        local innerPad = H.frame(scrollArea, UDim2.fromScale(1,1), nil, nil, 6)
        innerPad.AutomaticSize = Enum.AutomaticSize.Y
        H.list(innerPad, Enum.FillDirection.Vertical, 0,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
        H.pad(innerPad, 12, 16, 12, 12)
        tabAPI._inner = innerPad

        -- ─── Section header builder ──────────────────────
        local function addSectionHeader(title, iconName)
            local headerH = 36
            local headerF = H.frame(tabAPI._inner,
                UDim2.new(1,0,0,headerH), nil, nil, 7)
            headerF.AutomaticSize = Enum.AutomaticSize.Y

            local hlist = H.list(headerF, Enum.FillDirection.Horizontal, 8,
                Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

            if iconName and iconName ~= "" then
                local ic = H.icon(iconName, UDim2.fromOffset(14,14), theme.AccentPrimary)
                ic.LayoutOrder = 1; ic.ZIndex = 8; ic.Parent = headerF
            end

            local ht = H.label(headerF, title, fonts.BodyBold, 11, theme.TextMuted)
            ht.AutomaticSize = Enum.AutomaticSize.X
            ht.Size          = UDim2.fromOffset(0,36)
            ht.LayoutOrder   = 2; ht.ZIndex = 8

            local divider = H.frame(tabAPI._inner, UDim2.new(1,0,0,1), nil, theme.DividerColor, 7)
            return headerF
        end

        -- ─── Card welcome element ───────────────────────
        function tabAPI:Card(opts2)
            opts2 = opts2 or {}
            local cW = opts2.Width or 420
            local cH = opts2.Height or 200

            local card = Instance.new("Frame")
            card.Size             = UDim2.new(1,-24,0,cH)
            card.BackgroundColor3 = theme.CardBG
            card.BorderSizePixel  = 0
            card.ZIndex           = 7
            card.Parent           = tabAPI._inner
            H.stroke(card, theme.Border, 1, 0.4)
            H.corner(card, 8)

            if opts2.Icon and opts2.Icon ~= "" then
                local cardIc = H.icon(opts2.Icon, UDim2.fromOffset(44,44), theme.TextDim)
                cardIc.AnchorPoint = Vector2.new(0.5,0)
                cardIc.Position    = UDim2.new(0.5,0,0,20)
                cardIc.ZIndex      = 8
                cardIc.Parent      = card
            end

            if opts2.Title then
                local ct = H.label(card, opts2.Title, fonts.Header, 14, theme.TextPrimary,
                    Enum.TextXAlignment.Center)
                ct.Size     = UDim2.new(1,-20,0,22)
                ct.Position = UDim2.new(0,10,0,78)
                ct.ZIndex   = 8
            end

            if opts2.Description then
                local cd = H.label(card, opts2.Description, fonts.Body, 11, theme.TextMuted,
                    Enum.TextXAlignment.Center)
                cd.Size        = UDim2.new(1,-40,0,40)
                cd.Position    = UDim2.new(0,20,0,108)
                cd.TextWrapped = true
                cd.ZIndex      = 8
            end

            return card
        end

        -- ─── Divider ─────────────────────────────────────
        function tabAPI:Divider(spacing)
            spacing = spacing or 8
            local wrap = H.frame(tabAPI._inner, UDim2.new(1,0,0,spacing*2+1), nil, nil, 7)
            H.frame(wrap, UDim2.new(1,0,0,1), UDim2.new(0,0,0.5,-0.5), theme.DividerColor, 8)
            return wrap
        end

        -- ─── Spacer ──────────────────────────────────────
        function tabAPI:Spacer(height)
            return H.frame(tabAPI._inner, UDim2.new(1,0,0,height or 16), nil, nil, 7)
        end

        -- ─── Paragraph/Label ─────────────────────────────
        function tabAPI:Label(opts2)
            opts2 = opts2 or {}
            local wrap = H.frame(tabAPI._inner, UDim2.new(1,0,0,0), nil, nil, 7)
            wrap.AutomaticSize = Enum.AutomaticSize.Y
            H.pad(wrap, 4, 4, 2, 2)

            if opts2.Title then
                local tl = H.label(wrap, opts2.Title, fonts.BodyBold, 12, theme.TextPrimary)
                tl.Size          = UDim2.new(1,0,0,18)
                tl.ZIndex        = 8
            end

            if opts2.Text then
                local bl = H.label(wrap, opts2.Text, fonts.Body, 11, theme.TextSecondary)
                bl.Size          = UDim2.new(1,0,0,0)
                bl.AutomaticSize = Enum.AutomaticSize.Y
                bl.Position      = UDim2.new(0,0,0, opts2.Title and 20 or 0)
                bl.TextWrapped   = true
                bl.ZIndex        = 8
            end

            return wrap
        end

        -- ─── Section container ───────────────────────────
        function tabAPI:Section(opts2)
            opts2 = opts2 or {}
            local sectionWrap = H.frame(tabAPI._inner, UDim2.new(1,0,0,0), nil, nil, 7)
            sectionWrap.AutomaticSize = Enum.AutomaticSize.Y

            if opts2.Title then
                addSectionHeader(opts2.Title, opts2.Icon)
            end

            -- Inner section card
            local sectionCard = Instance.new("Frame")
            sectionCard.Size             = UDim2.new(1,0,0,0)
            sectionCard.BackgroundColor3 = theme.SectionBG
            sectionCard.BorderSizePixel  = 0
            sectionCard.AutomaticSize    = Enum.AutomaticSize.Y
            sectionCard.ZIndex           = 7
            sectionCard.Parent           = sectionWrap
            H.stroke(sectionCard, theme.Border, 1, 0.5)
            H.corner(sectionCard, 6)
            H.list(sectionCard, Enum.FillDirection.Vertical, 0,
                Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
            H.pad(sectionCard, 8, 8, 10, 10)

            -- Returns a sub-tab-API scoped to this section card
            local subAPI = makeTabAPI(sectionCard, theme, fonts, _winRef)
            subAPI._inner = sectionCard  -- write directly into sectionCard

            return subAPI
        end

        -- ─── Button ──────────────────────────────────────
        function tabAPI:Button(opts2)
            opts2 = opts2 or {}
            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(1,0,0,38)
            btn.BackgroundColor3 = theme.ButtonDark
            btn.BorderSizePixel  = 0
            btn.Text             = ""
            btn.AutoButtonColor  = false
            btn.ZIndex           = 8
            btn.Parent           = tabAPI._inner
            H.corner(btn, 6)
            H.stroke(btn, theme.Border, 1, 0.6)
            H.hover(btn, theme.ButtonDark, theme.ButtonDarkH)

            local blist = H.list(btn, Enum.FillDirection.Horizontal, 8,
                Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
            H.pad(btn, 0,0,12,12)

            if opts2.Icon and opts2.Icon ~= "" then
                local ic = H.icon(opts2.Icon, UDim2.fromOffset(15,15),
                    opts2.IconColor or theme.AccentPrimary)
                ic.LayoutOrder = 1; ic.ZIndex = 9; ic.Parent = btn
            end

            local textWrap = H.frame(btn, UDim2.new(1,0,1,0), nil, nil, 9)
            textWrap.AutomaticSize = Enum.AutomaticSize.X
            textWrap.LayoutOrder   = 2

            local tl = H.label(textWrap, opts2.Title or "Button",
                fonts.BodyBold, 12, theme.TextPrimary)
            tl.Size   = UDim2.fromOffset(0,38)
            tl.AutomaticSize = Enum.AutomaticSize.X
            tl.ZIndex = 9

            if opts2.Description and opts2.Description ~= "" then
                tl.Size          = UDim2.fromOffset(0,20)
                tl.TextYAlignment = Enum.TextYAlignment.Bottom
                local dl = H.label(textWrap, opts2.Description, fonts.Body, 10, theme.TextMuted)
                dl.Size          = UDim2.new(1,0,0,18)
                dl.Position      = UDim2.new(0,0,0,20)
                dl.AutomaticSize = Enum.AutomaticSize.X
                dl.ZIndex        = 9
                btn.Size         = UDim2.new(1,0,0,46)
            end

            if opts2.Callback then
                btn.MouseButton1Click:Connect(function()
                    pcall(opts2.Callback)
                end)
            end

            return btn
        end

        -- ─── Toggle ──────────────────────────────────────
        function tabAPI:Toggle(opts2)
            opts2 = opts2 or {}
            local value = opts2.Value == true

            local row = H.frame(tabAPI._inner, UDim2.new(1,0,0,38), nil, nil, 8)
            local rlist = H.list(row, Enum.FillDirection.Horizontal, 8,
                Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
            H.pad(row, 0,0,4,4)

            if opts2.Icon and opts2.Icon ~= "" then
                local ic = H.icon(opts2.Icon, UDim2.fromOffset(15,15),
                    opts2.IconColor or theme.TextMuted)
                ic.LayoutOrder = 1; ic.ZIndex = 9; ic.Parent = row
            end

            local labelWrap = H.frame(row, UDim2.new(1,-54,1,0), nil, nil, 9)
            labelWrap.AutomaticSize = Enum.AutomaticSize.Y
            labelWrap.LayoutOrder   = 2

            H.label(labelWrap, opts2.Title or "Toggle", fonts.BodyBold, 12, theme.TextPrimary)
                :Clone().Parent = nil  -- just build it
            local tl = H.label(labelWrap, opts2.Title or "Toggle", fonts.BodyBold, 12, theme.TextPrimary)
            tl.Size   = UDim2.new(1,0,0,38)
            if opts2.Description and opts2.Description ~= "" then
                tl.Size          = UDim2.new(1,0,0,20)
                tl.TextYAlignment = Enum.TextYAlignment.Bottom
                local dl = H.label(labelWrap, opts2.Description, fonts.Body, 10, theme.TextMuted)
                dl.Size     = UDim2.new(1,0,0,18)
                dl.Position = UDim2.new(0,0,0,20)
                row.Size    = UDim2.new(1,0,0,46)
            end

            -- Switch pill
            local switchOuter = Instance.new("Frame")
            switchOuter.Size             = UDim2.fromOffset(36, 20)
            switchOuter.BackgroundColor3 = value and theme.ToggleOn or theme.ToggleOff
            switchOuter.BorderSizePixel  = 0
            switchOuter.LayoutOrder      = 3
            switchOuter.ZIndex           = 9
            switchOuter.Parent           = row
            H.corner(switchOuter, 10)
            H.stroke(switchOuter, theme.Border, 1, 0.4)

            local knob = Instance.new("Frame")
            knob.Size             = UDim2.fromOffset(14, 14)
            knob.Position         = value and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
            knob.BackgroundColor3 = theme.ToggleKnob
            knob.BorderSizePixel  = 0
            knob.ZIndex           = 10
            knob.Parent           = switchOuter
            H.corner(knob, 7)

            local clickDetect = Instance.new("TextButton")
            clickDetect.Size                = UDim2.fromScale(1,1)
            clickDetect.BackgroundTransparency = 1
            clickDetect.Text                = ""
            clickDetect.AutoButtonColor     = false
            clickDetect.ZIndex              = 11
            clickDetect.Parent              = switchOuter

            local togAPI = {}
            togAPI._value = value

            function togAPI:Set(v)
                togAPI._value = v
                H.tween(switchOuter, { BackgroundColor3 = v and theme.ToggleOn or theme.ToggleOff }):Play()
                H.tween(knob, { Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7) }):Play()
                if opts2.Callback then pcall(opts2.Callback, v) end
            end

            function togAPI:Get() return togAPI._value end

            clickDetect.MouseButton1Click:Connect(function()
                togAPI:Set(not togAPI._value)
            end)

            -- Also allow clicking the whole row
            local rowDetect = Instance.new("TextButton")
            rowDetect.Size                = UDim2.new(1,-54,1,0)
            rowDetect.BackgroundTransparency = 1
            rowDetect.Text                = ""
            rowDetect.AutoButtonColor     = false
            rowDetect.ZIndex              = 10
            rowDetect.Parent              = row
            rowDetect.MouseButton1Click:Connect(function()
                togAPI:Set(not togAPI._value)
            end)

            return togAPI
        end

        -- ─── Slider ──────────────────────────────────────
        function tabAPI:Slider(opts2)
            opts2 = opts2 or {}
            local minV   = opts2.Min     or 0
            local maxV   = opts2.Max     or 100
            local defV   = opts2.Value   or minV
            local suffix = opts2.Suffix  or ""
            local step   = opts2.Step    or 1

            local value = math.clamp(defV, minV, maxV)

            local wrap = H.frame(tabAPI._inner, UDim2.new(1,0,0,56), nil, nil, 8)
            H.pad(wrap, 4,4,4,4)

            -- Top row: label + value display
            local topRow = H.frame(wrap, UDim2.new(1,0,0,20), nil, nil, 9)
            local titleL = H.label(topRow, opts2.Title or "Slider", fonts.BodyBold, 12, theme.TextPrimary)
            titleL.Size = UDim2.new(1,-60,1,0)

            local valueL = H.label(topRow, tostring(value) .. suffix,
                fonts.BodyBold, 11, theme.AccentPrimary,
                Enum.TextXAlignment.Right)
            valueL.Size     = UDim2.fromOffset(56,20)
            valueL.Position = UDim2.new(1,-56,0,0)

            -- Track
            local trackH = 4
            local track = Instance.new("Frame")
            track.Size             = UDim2.new(1,0,0,trackH)
            track.Position         = UDim2.new(0,0,0,30)
            track.BackgroundColor3 = theme.SliderTrack
            track.BorderSizePixel  = 0
            track.ZIndex           = 9
            track.Parent           = wrap
            H.corner(track, 2)

            local function fraction()
                return (value - minV) / (maxV - minV)
            end

            local fill = Instance.new("Frame")
            fill.Size             = UDim2.new(fraction(),0,1,0)
            fill.BackgroundColor3 = theme.SliderFill
            fill.BorderSizePixel  = 0
            fill.ZIndex           = 10
            fill.Parent           = track
            H.corner(fill, 2)

            local knobBtn = Instance.new("TextButton")
            knobBtn.Size                = UDim2.fromOffset(14,14)
            knobBtn.AnchorPoint         = Vector2.new(0.5,0.5)
            knobBtn.Position            = UDim2.new(fraction(),0,0.5,0)
            knobBtn.BackgroundColor3    = theme.SliderKnob
            knobBtn.BorderSizePixel     = 0
            knobBtn.Text                = ""
            knobBtn.AutoButtonColor     = false
            knobBtn.ZIndex              = 11
            knobBtn.Parent              = track
            H.corner(knobBtn, 7)

            local draggingSlider = false
            knobBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if not draggingSlider then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
                local absPos  = track.AbsolutePosition.X
                local absSize = track.AbsoluteSize.X
                local rel = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
                local rawVal = minV + rel * (maxV - minV)
                local steppedVal = math.floor(rawVal / step + 0.5) * step
                value = math.clamp(steppedVal, minV, maxV)
                local frac = fraction()
                H.tween(fill, { Size = UDim2.new(frac,0,1,0) }, 0.05):Play()
                H.tween(knobBtn, { Position = UDim2.new(frac,0,0.5,0) }, 0.05):Play()
                valueL.Text = tostring(math.floor(value*100+0.5)/100) .. suffix
                if opts2.Callback then pcall(opts2.Callback, value) end
            end)

            -- Also allow click on track
            local trackBtn = Instance.new("TextButton")
            trackBtn.Size                = UDim2.fromScale(1,1)
            trackBtn.BackgroundTransparency = 1
            trackBtn.Text                = ""
            trackBtn.AutoButtonColor     = false
            trackBtn.ZIndex              = 9
            trackBtn.Parent              = track
            trackBtn.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local absPos  = track.AbsolutePosition.X
                local absSize = track.AbsoluteSize.X
                local rel = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
                local rawVal = minV + rel * (maxV - minV)
                local steppedVal = math.floor(rawVal / step + 0.5) * step
                value = math.clamp(steppedVal, minV, maxV)
                local frac = fraction()
                H.tween(fill, { Size = UDim2.new(frac,0,1,0) }, 0.05):Play()
                H.tween(knobBtn, { Position = UDim2.new(frac,0,0.5,0) }, 0.05):Play()
                valueL.Text = tostring(math.floor(value*100+0.5)/100) .. suffix
                if opts2.Callback then pcall(opts2.Callback, value) end
            end)

            local sliderAPI = {}
            function sliderAPI:Set(v)
                value = math.clamp(v, minV, maxV)
                local frac = fraction()
                H.tween(fill, { Size = UDim2.new(frac,0,1,0) }, 0.1):Play()
                H.tween(knobBtn, { Position = UDim2.new(frac,0,0.5,0) }, 0.1):Play()
                valueL.Text = tostring(math.floor(value*100+0.5)/100) .. suffix
            end
            function sliderAPI:Get() return value end
            return sliderAPI
        end

        if extendTabAPI then
            extendTabAPI(tabAPI, theme, fonts, _winRef)
        end

        -- Elements still to come in Part 2:
        -- Dropdown, Keybind, ToggleKeybind, Input, Progress,
        -- LiveStats, HStack, VStack, Group, Notification call
        -- (returning the API here so Part 2 can extend it)
        return tabAPI
    end

    -- ── Public Window API ─────────────────────────────────

    local winAPI = {}
    winAPI._T          = T
    winAPI._F          = F
    winAPI._ScreenGui  = ScreenGui
    winAPI._Main       = Main
    winAPI._Content    = Content
    winAPI._showToast  = showToast
    winAPI._showNotif  = showNotification
    winAPI._showConfirm= showConfirm
    winAPI._tabs       = registeredTabs
    winAPI._tabFrames  = tabFrames
    winAPI._tabButtons = tabButtons
    winAPI._SidebarTop = SidebarTop
    winAPI._flags      = {}
    winAPI._suppressCallbacks = false


    --[[
        Window:Tab(opts)
        opts:
            Title   string
            Icon    string
            Bottom  bool      (place in bottom sidebar slot)
    ]]
    function winAPI:Tab(opts2)
        opts2 = opts2 or {}
        local id = opts2.Title or ("tab_" .. #registeredTabs + 1)

        local sideParent = (opts2.Bottom == true) and SidebarBottom or SidebarTop

        -- Sidebar button
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1,-8,0,44)
        btn.BackgroundColor3 = T.SidebarBG
        btn.BorderSizePixel  = 0
        btn.Text             = ""
        btn.AutoButtonColor  = false
        btn.ZIndex           = 11
        btn.Parent           = sideParent
        H.corner(btn, 6)

        -- Active accent strip (left edge)
        local accent = H.frame(btn, UDim2.new(0,3,1,-12), UDim2.new(0,0,0,6), T.SidebarAccent, 12)
        H.corner(accent, 2)
        accent.Visible = false

        -- Tab icon
        local tabIc = H.icon(opts2.Icon or "lucide:layout-dashboard",
            UDim2.fromOffset(20,20), T.TextMuted)
        tabIc.AnchorPoint = Vector2.new(0.5,0.5)
        tabIc.Position    = UDim2.new(0.5,0,0.5,0)
        tabIc.ZIndex      = 12
        tabIc.Parent      = btn

        -- Tooltip (shown on hover since sidebar is icon-only)
        local tooltipFrame = Instance.new("Frame")
        tooltipFrame.Size             = UDim2.fromOffset(0,28)
        tooltipFrame.AutomaticSize    = Enum.AutomaticSize.X
        tooltipFrame.Position         = UDim2.new(1,6,0.5,-14)
        tooltipFrame.BackgroundColor3 = T.CardBG
        tooltipFrame.BorderSizePixel  = 0
        tooltipFrame.ZIndex           = 20
        tooltipFrame.Visible          = false
        tooltipFrame.ClipsDescendants = false
        tooltipFrame.Parent           = btn
        H.corner(tooltipFrame, 4)
        H.stroke(tooltipFrame, T.BorderLight, 1)
        H.pad(tooltipFrame, 0,0,8,8)

        local tooltipLabel = H.label(tooltipFrame, opts2.Title or "",
            DefaultFonts.BodyBold, 11, T.TextPrimary)
        tooltipLabel.AutomaticSize = Enum.AutomaticSize.X
        tooltipLabel.Size          = UDim2.fromOffset(0,28)
        tooltipLabel.ZIndex        = 21

        btn.MouseEnter:Connect(function()
            if activeTab ~= id then
                H.tween(btn, { BackgroundColor3 = T.SidebarHover }):Play()
            end
            tooltipFrame.Visible = true
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= id then
                H.tween(btn, { BackgroundColor3 = T.SidebarBG }):Play()
            end
            tooltipFrame.Visible = false
        end)

        -- Content frame for this tab
        local tabFrame = H.clipFrame(Content, UDim2.fromScale(1,1), nil, nil, 6)
        tabFrame.Name    = "Tab_" .. id
        tabFrame.Visible = false

        tabFrames[id]  = tabFrame
        tabButtons[id] = { button = btn, icon = tabIc, accent = accent }

        -- Build tab API
        local tabAPI = makeTabAPI(tabFrame, T, F, winAPI)

        -- Wire click
        btn.MouseButton1Click:Connect(function()
            if activeTab == id then return end

            -- Deactivate old
            if activeTab and tabFrames[activeTab] then
                tabFrames[activeTab].Visible = false
                local old = tabButtons[activeTab]
                H.tween(old.button, { BackgroundColor3 = T.SidebarBG }):Play()
                H.tween(old.icon,   { ImageColor3 = T.TextMuted }):Play()
                old.accent.Visible = false
            end

            -- Activate new
            activeTab         = id
            tabFrame.Visible  = true
            H.tween(btn,   { BackgroundColor3 = T.SidebarActive }):Play()
            H.tween(tabIc, { ImageColor3 = T.SidebarAccent }):Play()
            accent.Visible = true
            tooltipFrame.Visible = false
        end)

        -- First tab auto-selected
        if activeTab == nil and opts2.Bottom ~= true then
            activeTab        = id
            tabFrame.Visible = true
            btn.BackgroundColor3 = T.SidebarActive
            tabIc.ImageColor3    = T.SidebarAccent
            accent.Visible       = true
        end

        table.insert(registeredTabs, { id = id, api = tabAPI })
        return tabAPI
    end

    function winAPI:Toast(text, kind) showToast(text, kind) end
    function winAPI:Notify(opts2) showNotification(opts2) end
    function winAPI:Confirm(title, msg, onConfirm, onCancel) showConfirm(title, msg, onConfirm, onCancel) end

    function winAPI:SetToggleKey(keyCode)
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == keyCode then
                Main.Visible = not Main.Visible
                if FloatIcon then FloatIcon.Visible = not Main.Visible end
            end
        end)
    end

    function winAPI:Destroy()
        ScreenGui:Destroy()
    end

    if extendWindow then
        extendWindow(winAPI, T, F, ScreenGui, Main, Content, TopBar)
    end    

    return winAPI
end

-- ============================================================
-- ChronosUI — Roblox UI Library
-- Part 2 of 3: Dropdown, Input, Keybind, ToggleKeybind,
--              Progress, LiveStats, HStack / VStack,
--              Flag registry, Window:Dialog, Window:Tag,
--              Window:SidebarDivider
-- ============================================================
-- HOW TO MERGE:
--   1. Open ChronosUI_Part1.lua
--   2. Remove the last `return ChronosUI` line and the
--      "END OF PART 1" comment block at the bottom.
--   3. Paste the entire contents of this file directly after.
--   4. Continue with Part 3, then add `return ChronosUI`
--      at the very end of the merged file.
--
-- REQUIRED CHANGES TO PART 1 (6 small edits, listed at bottom):
--   See the MERGE GUIDE comment at the end of this file.
-- ============================================================

local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- extendTabAPI
-- Called from makeTabAPI in Part 1 (see merge guide below).
-- Adds all remaining element methods to a tabAPI table.
-- ============================================================

local function extendTabAPI(tabAPI, theme, fonts, winRef)

    -- ── internal helpers ─────────────────────────────────

    local function regFlag(flag, getFn, setFn)
        if flag and flag ~= "" and winRef and winRef._flags then
            winRef._flags[flag] = { get = getFn, set = setFn }
        end
    end

    local function suppressed()
        return winRef and winRef._suppressCallbacks == true
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:Dropdown(opts)
    --
    -- opts:
    --   Title        string
    --   Description  string          (optional, shown under title)
    --   Icon         string
    --   IconColor    Color3
    --   Values       array of strings
    --   Value        string or table (default selection)
    --   Multi        bool            (multi-select mode)
    --   Flag         string
    --   Callback     function(selected)  — string or table of strings
    --
    -- returns: { Set(v), Get(), Refresh(newValues) }
    -- ──────────────────────────────────────────────────────
    function tabAPI:Dropdown(opts2)
        opts2 = opts2 or {}
        local values   = opts2.Values or {}
        local isMulti  = opts2.Multi == true
        local selected -- string (single) | table<string,bool> (multi)

        if isMulti then
            selected = {}
            if type(opts2.Value) == "table" then
                for _, v in ipairs(opts2.Value) do selected[v] = true end
            elseif type(opts2.Value) == "string" and opts2.Value ~= "" then
                selected[opts2.Value] = true
            end
        else
            selected = (type(opts2.Value) == "string" and opts2.Value ~= "")
                and opts2.Value or (values[1] or "")
        end

        local hasDesc = opts2.Description and opts2.Description ~= ""
        local rowH    = hasDesc and 54 or 38

        local row = H.frame(tabAPI._inner, UDim2.new(1,0,0,rowH), nil, nil, 8)
        H.list(row, Enum.FillDirection.Horizontal, 8,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
        H.pad(row, 0,0,4,4)

        if opts2.Icon and opts2.Icon ~= "" then
            local ic = H.icon(opts2.Icon, UDim2.fromOffset(15,15),
                opts2.IconColor or theme.TextMuted)
            ic.LayoutOrder = 1; ic.ZIndex = 9; ic.Parent = row
        end

        local lblWrap = H.frame(row, UDim2.new(1,-118,1,0), nil, nil, 9)
        lblWrap.LayoutOrder = 2

        local titleLbl = H.label(lblWrap, opts2.Title or "Dropdown",
            fonts.BodyBold, 12, theme.TextPrimary)
        if hasDesc then
            titleLbl.Size          = UDim2.new(1,0,0,20)
            titleLbl.TextYAlignment = Enum.TextYAlignment.Bottom
            local dl = H.label(lblWrap, opts2.Description, fonts.Body, 10, theme.TextMuted)
            dl.Size     = UDim2.new(1,0,0,18); dl.Position = UDim2.new(0,0,0,20)
        else
            titleLbl.Size = UDim2.new(1,0,1,0)
        end

        -- selector button
        local selBtn = Instance.new("TextButton")
        selBtn.Size             = UDim2.fromOffset(110, 28)
        selBtn.BackgroundColor3 = theme.DropdownBG
        selBtn.BorderSizePixel  = 0
        selBtn.Text             = ""
        selBtn.AutoButtonColor  = false
        selBtn.LayoutOrder      = 3
        selBtn.ZIndex           = 9
        selBtn.Parent           = row
        H.corner(selBtn, 5)
        H.stroke(selBtn, theme.Border, 1, 0.4)
        H.pad(selBtn, 0,0,8,6)
        H.list(selBtn, Enum.FillDirection.Horizontal, 4,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

        local selLbl = H.label(selBtn, "", fonts.Body, 11, theme.TextPrimary)
        selLbl.Size         = UDim2.new(1,-16,1,0)
        selLbl.LayoutOrder  = 1
        selLbl.TextTruncate = Enum.TextTruncate.AtEnd
        selLbl.ZIndex       = 10

        local chevIc = H.icon("lucide:chevron-down",
            UDim2.fromOffset(12,12), theme.TextMuted)
        chevIc.LayoutOrder = 2; chevIc.ZIndex = 10; chevIc.Parent = selBtn

        -- display helpers
        local function displayText()
            if isMulti then
                local parts = {}
                for _, v in ipairs(values) do
                    if selected[v] then table.insert(parts, v) end
                end
                return #parts == 0 and "None" or table.concat(parts, ", ")
            end
            return selected == "" and "None" or tostring(selected)
        end

        local function refreshDisplay() selLbl.Text = displayText() end
        refreshDisplay()

        -- open / close state
        local listOpen = false
        local listFrame

        local function closeList()
            if not listFrame then return end
            H.tween(listFrame, { Size = UDim2.new(1,0,0,0) }, 0.12):Play()
            task.delay(0.13, function()
                if listFrame then listFrame:Destroy(); listFrame = nil end
            end)
            listOpen = false
            H.tween(chevIc, { Rotation = 0 }, 0.12):Play()
        end

        local function openList()
            if listOpen then closeList(); return end
            listOpen = true
            H.tween(chevIc, { Rotation = 180 }, 0.12):Play()

            local itemH   = 28
            local maxShow = math.min(#values, 6)
            local totalH  = maxShow * itemH + 8

            listFrame = Instance.new("Frame")
            listFrame.Size             = UDim2.new(1,0,0,0)
            listFrame.Position         = UDim2.new(0,0,0,rowH + 2)
            listFrame.BackgroundColor3 = theme.DropdownBG
            listFrame.BorderSizePixel  = 0
            listFrame.ZIndex           = 50
            listFrame.ClipsDescendants = true
            listFrame.Parent           = row
            H.corner(listFrame, 5)
            H.stroke(listFrame, theme.Border, 1, 0.3)

            local innerScroll = H.scrollFrame(listFrame,
                UDim2.fromScale(1,1), UDim2.new(0,0,0,0), 51)
            innerScroll.ScrollBarThickness    = 3
            innerScroll.ScrollBarImageColor3  = theme.Border
            H.list(innerScroll, Enum.FillDirection.Vertical, 0,
                Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
            H.pad(innerScroll, 4,4,0,0)

            local function buildItems()
                for _, c in ipairs(innerScroll:GetChildren()) do
                    if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
                        c:Destroy()
                    end
                end
                for _, v in ipairs(values) do
                    local isSel = isMulti and selected[v] or (selected == v)
                    local item  = Instance.new("TextButton")
                    item.Size             = UDim2.new(1,-8,0,itemH)
                    item.BackgroundColor3 = isSel
                        and theme.SidebarActive or theme.DropdownBG
                    item.BorderSizePixel  = 0
                    item.Text             = ""
                    item.AutoButtonColor  = false
                    item.ZIndex           = 52
                    item.Parent           = innerScroll
                    H.corner(item, 4)
                    H.list(item, Enum.FillDirection.Horizontal, 6,
                        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
                    H.pad(item, 0,0,8,8)

                    local chk = H.icon(isSel and "lucide:check" or "",
                        UDim2.fromOffset(12,12), theme.AccentPrimary)
                    chk.LayoutOrder = 1; chk.ZIndex = 53; chk.Parent = item

                    local vLbl = H.label(item, tostring(v), fonts.Body, 11,
                        isSel and theme.TextPrimary or theme.TextSecondary)
                    vLbl.AutomaticSize = Enum.AutomaticSize.X
                    vLbl.Size          = UDim2.fromOffset(0, itemH)
                    vLbl.LayoutOrder   = 2; vLbl.ZIndex = 53

                    item.MouseEnter:Connect(function()
                        local s = isMulti and selected[v] or (selected == v)
                        if not s then
                            H.tween(item, {
                                BackgroundColor3 = theme.DropdownItemH
                            }):Play()
                        end
                    end)
                    item.MouseLeave:Connect(function()
                        local s = isMulti and selected[v] or (selected == v)
                        H.tween(item, {
                            BackgroundColor3 = s
                                and theme.SidebarActive or theme.DropdownBG
                        }):Play()
                    end)

                    item.MouseButton1Click:Connect(function()
                        if isMulti then
                            selected[v] = not selected[v]
                            refreshDisplay()
                            buildItems()
                            if opts2.Callback and not suppressed() then
                                local out = {}
                                for _, mv in ipairs(values) do
                                    if selected[mv] then
                                        table.insert(out, mv)
                                    end
                                end
                                pcall(opts2.Callback, out)
                            end
                        else
                            selected = v
                            refreshDisplay()
                            closeList()
                            if opts2.Callback and not suppressed() then
                                pcall(opts2.Callback, selected)
                            end
                        end
                    end)
                end
            end

            buildItems()
            H.tween(listFrame, { Size = UDim2.new(1,0,0,totalH) }, 0.15,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
        end

        selBtn.MouseButton1Click:Connect(openList)

        -- close on outside click
        UserInputService.InputBegan:Connect(function(input)
            if not listOpen then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local mp  = UserInputService:GetMouseLocation()
            local ap  = row.AbsolutePosition
            local as  = row.AbsoluteSize
            local ext = listFrame and listFrame.AbsoluteSize.Y or 0
            if mp.X < ap.X or mp.X > ap.X + as.X
            or mp.Y < ap.Y or mp.Y > ap.Y + as.Y + ext + 4 then
                closeList()
            end
        end)

        -- public API
        local dropAPI = {}

        function dropAPI:Get()
            if isMulti then
                local out = {}
                for _, v in ipairs(values) do
                    if selected[v] then table.insert(out, v) end
                end
                return out
            end
            return selected
        end

        function dropAPI:Set(v)
            if isMulti then
                selected = {}
                if type(v) == "table" then
                    for _, sv in ipairs(v) do selected[sv] = true end
                end
            else
                selected = tostring(v)
            end
            refreshDisplay()
        end

        function dropAPI:Refresh(newValues)
            values = newValues or {}
            if not isMulti then
                local found = false
                for _, v in ipairs(values) do
                    if v == selected then found = true; break end
                end
                if not found then selected = values[1] or "" end
            end
            refreshDisplay()
        end

        regFlag(opts2.Flag,
            function() return dropAPI:Get() end,
            function(v) dropAPI:Set(v) end)

        return dropAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:Input(opts)
    --
    -- opts:
    --   Title        string
    --   Description  string
    --   Icon         string
    --   Placeholder  string
    --   Value        string          (initial text)
    --   Numeric      bool            (reject non-numeric input)
    --   Flag         string
    --   Callback     function(text)  fired on FocusLost
    --
    -- returns: { Set(text), Get() }
    -- ──────────────────────────────────────────────────────
    function tabAPI:Input(opts2)
        opts2 = opts2 or {}
        local curValue = tostring(opts2.Value or "")
        local hasDesc  = opts2.Description and opts2.Description ~= ""

        local wrap = H.frame(tabAPI._inner,
            UDim2.new(1,0,0, hasDesc and 70 or 54), nil, nil, 8)
        H.pad(wrap, 4,4,4,4)

        -- icon + label row
        local topRow = H.frame(wrap, UDim2.new(1,0,0,20), nil, nil, 9)
        H.list(topRow, Enum.FillDirection.Horizontal, 6,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

        if opts2.Icon and opts2.Icon ~= "" then
            local ic = H.icon(opts2.Icon, UDim2.fromOffset(14,14), theme.TextMuted)
            ic.ZIndex = 10; ic.Parent = topRow
        end

        local titleLbl = H.label(topRow, opts2.Title or "Input",
            fonts.BodyBold, 12, theme.TextPrimary)
        titleLbl.AutomaticSize = Enum.AutomaticSize.X
        titleLbl.Size          = UDim2.fromOffset(0,20)
        titleLbl.ZIndex        = 10

        if hasDesc then
            local dl = H.label(wrap, opts2.Description, fonts.Body, 10, theme.TextMuted)
            dl.Size     = UDim2.new(1,0,0,14)
            dl.Position = UDim2.new(0,0,0,22)
        end

        -- text box
        local boxY = hasDesc and 38 or 22
        local box  = Instance.new("TextBox")
        box.Size              = UDim2.new(1,0,0,26)
        box.Position          = UDim2.new(0,0,0,boxY)
        box.BackgroundColor3  = theme.InputBG
        box.BorderSizePixel   = 0
        box.ClearTextOnFocus  = false
        box.Text              = curValue
        box.PlaceholderText   = opts2.Placeholder or ""
        box.PlaceholderColor3 = theme.TextDim
        box.TextColor3        = theme.TextPrimary
        box.FontFace          = fonts.Body
        box.TextSize          = 12
        box.TextXAlignment    = Enum.TextXAlignment.Left
        box.ZIndex            = 9
        box.Parent            = wrap
        H.corner(box, 5)
        H.stroke(box, theme.Border, 1, 0.4)
        H.pad(box, 0,0,8,8)

        box.Focused:Connect(function()
            H.tween(box, { BackgroundColor3 = theme.CardBG }):Play()
        end)
        box.FocusLost:Connect(function()
            H.tween(box, { BackgroundColor3 = theme.InputBG }):Play()
            local raw = box.Text
            if opts2.Numeric then
                local n = tonumber(raw)
                if n then curValue = tostring(n)
                else box.Text = curValue; return end
            else
                curValue = raw
            end
            if opts2.Callback and not suppressed() then
                pcall(opts2.Callback, curValue)
            end
        end)

        local inputAPI = {}
        function inputAPI:Get() return curValue end
        function inputAPI:Set(v)
            curValue = tostring(v); box.Text = curValue
        end

        regFlag(opts2.Flag,
            function() return inputAPI:Get() end,
            function(v) inputAPI:Set(v) end)

        return inputAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:Keybind(opts)
    --
    -- opts:
    --   Title        string
    --   Description  string
    --   Value        string   (e.g. "G" — initial key name)
    --   CanChange    bool     (default true — allow rebinding)
    --   Flag         string
    --   Callback     function(keyName)  fired after binding changes
    --
    -- returns: { Set(keyString), Get() }
    -- ──────────────────────────────────────────────────────
    function tabAPI:Keybind(opts2)
        opts2 = opts2 or {}
        local currentKey = tostring(opts2.Value or "None")
        local canChange  = opts2.CanChange ~= false
        local listening  = false
        local hasDesc    = opts2.Description and opts2.Description ~= ""
        local rowH       = hasDesc and 46 or 38

        local row = H.frame(tabAPI._inner, UDim2.new(1,0,0,rowH), nil, nil, 8)
        H.list(row, Enum.FillDirection.Horizontal, 8,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
        H.pad(row, 0,0,4,4)

        if opts2.Icon and opts2.Icon ~= "" then
            local ic = H.icon(opts2.Icon, UDim2.fromOffset(15,15), theme.TextMuted)
            ic.LayoutOrder = 1; ic.ZIndex = 9; ic.Parent = row
        end

        local lblWrap = H.frame(row, UDim2.new(1,-82,1,0), nil, nil, 9)
        lblWrap.LayoutOrder = 2

        local titleLbl = H.label(lblWrap, opts2.Title or "Keybind",
            fonts.BodyBold, 12, theme.TextPrimary)
        if hasDesc then
            titleLbl.Size          = UDim2.new(1,0,0,20)
            titleLbl.TextYAlignment = Enum.TextYAlignment.Bottom
            local dl = H.label(lblWrap, opts2.Description, fonts.Body, 10, theme.TextMuted)
            dl.Size     = UDim2.new(1,0,0,16)
            dl.Position = UDim2.new(0,0,0,20)
        else
            titleLbl.Size = UDim2.new(1,0,1,0)
        end

        -- key pill
        local keyBtn = Instance.new("TextButton")
        keyBtn.Size             = UDim2.fromOffset(70, 26)
        keyBtn.BackgroundColor3 = theme.ButtonDark
        keyBtn.BorderSizePixel  = 0
        keyBtn.Text             = currentKey
        keyBtn.TextColor3       = theme.AccentPrimary
        keyBtn.FontFace         = fonts.BodyBold
        keyBtn.TextSize         = 11
        keyBtn.AutoButtonColor  = false
        keyBtn.LayoutOrder      = 3
        keyBtn.ZIndex           = 9
        keyBtn.Parent           = row
        H.corner(keyBtn, 4)
        H.stroke(keyBtn, theme.Border, 1, 0.4)

        local function setListening(v)
            listening = v
            if v then
                keyBtn.Text       = "..."
                keyBtn.TextColor3 = theme.TextMuted
                H.tween(keyBtn, { BackgroundColor3 = theme.ButtonDarkH }):Play()
            else
                keyBtn.Text       = currentKey
                keyBtn.TextColor3 = theme.AccentPrimary
                H.tween(keyBtn, { BackgroundColor3 = theme.ButtonDark }):Play()
            end
        end

        if canChange then
            keyBtn.MouseButton1Click:Connect(function()
                setListening(not listening)
            end)
            UserInputService.InputBegan:Connect(function(input)
                if not listening then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                local n = input.KeyCode.Name
                -- skip bare modifier keys
                if n == "LeftShift" or n == "RightShift"
                or n == "LeftControl" or n == "RightControl"
                or n == "LeftAlt" or n == "RightAlt"
                or n == "LeftMeta" or n == "RightMeta" then return end
                currentKey = n
                setListening(false)
                if opts2.Callback and not suppressed() then
                    pcall(opts2.Callback, currentKey)
                end
            end)
        end

        local kbAPI = {}
        function kbAPI:Get() return currentKey end
        function kbAPI:Set(v)
            currentKey = tostring(v); keyBtn.Text = currentKey
        end

        regFlag(opts2.Flag,
            function() return kbAPI:Get() end,
            function(v) kbAPI:Set(v) end)

        return kbAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:ToggleKeybind(opts)
    --
    -- A toggle switch and a keybind pill in one row.
    -- The toggle controls an on/off state; the keybind lets the
    -- user re-bind which key activates that state at runtime.
    --
    -- opts:
    --   Title        string
    --   Description  string
    --   Value        bool     (initial toggle state)
    --   Keybind      string   (initial key name, e.g. "H")
    --   CanChange    bool     (allow rebinding, default true)
    --   Flag         string   (serialised as "true|H")
    --   Callback     function(toggleState, keyName)
    --
    -- returns: { SetToggle(v), GetToggle(), SetKey(k), GetKey() }
    -- ──────────────────────────────────────────────────────
    function tabAPI:ToggleKeybind(opts2)
        opts2 = opts2 or {}
        local togValue   = opts2.Value == true
        local currentKey = tostring(opts2.Keybind or "None")
        local canChange  = opts2.CanChange ~= false
        local listening  = false
        local hasDesc    = opts2.Description and opts2.Description ~= ""
        local rowH       = hasDesc and 46 or 38

        local row = H.frame(tabAPI._inner, UDim2.new(1,0,0,rowH), nil, nil, 8)
        H.list(row, Enum.FillDirection.Horizontal, 8,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
        H.pad(row, 0,0,4,4)

        if opts2.Icon and opts2.Icon ~= "" then
            local ic = H.icon(opts2.Icon, UDim2.fromOffset(15,15), theme.TextMuted)
            ic.LayoutOrder = 1; ic.ZIndex = 9; ic.Parent = row
        end

        local lblWrap = H.frame(row, UDim2.new(1,-122,1,0), nil, nil, 9)
        lblWrap.LayoutOrder = 2

        local titleLbl = H.label(lblWrap, opts2.Title or "ToggleKeybind",
            fonts.BodyBold, 12, theme.TextPrimary)
        if hasDesc then
            titleLbl.Size          = UDim2.new(1,0,0,20)
            titleLbl.TextYAlignment = Enum.TextYAlignment.Bottom
            local dl = H.label(lblWrap, opts2.Description, fonts.Body, 10, theme.TextMuted)
            dl.Size     = UDim2.new(1,0,0,16)
            dl.Position = UDim2.new(0,0,0,20)
        else
            titleLbl.Size = UDim2.new(1,0,1,0)
        end

        -- toggle switch
        local switchOuter = Instance.new("Frame")
        switchOuter.Size             = UDim2.fromOffset(36, 20)
        switchOuter.BackgroundColor3 = togValue and theme.ToggleOn or theme.ToggleOff
        switchOuter.BorderSizePixel  = 0
        switchOuter.LayoutOrder      = 3
        switchOuter.ZIndex           = 9
        switchOuter.Parent           = row
        H.corner(switchOuter, 10)
        H.stroke(switchOuter, theme.Border, 1, 0.4)

        local knob = Instance.new("Frame")
        knob.Size             = UDim2.fromOffset(14,14)
        knob.Position         = togValue
            and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        knob.BackgroundColor3 = theme.ToggleKnob
        knob.BorderSizePixel  = 0
        knob.ZIndex           = 10
        knob.Parent           = switchOuter
        H.corner(knob, 7)

        local switchBtn = Instance.new("TextButton")
        switchBtn.Size                   = UDim2.fromScale(1,1)
        switchBtn.BackgroundTransparency = 1
        switchBtn.Text                   = ""
        switchBtn.AutoButtonColor        = false
        switchBtn.ZIndex                 = 11
        switchBtn.Parent                 = switchOuter

        -- keybind pill
        local keyBtn = Instance.new("TextButton")
        keyBtn.Size             = UDim2.fromOffset(66, 26)
        keyBtn.BackgroundColor3 = theme.ButtonDark
        keyBtn.BorderSizePixel  = 0
        keyBtn.Text             = currentKey
        keyBtn.TextColor3       = theme.AccentPrimary
        keyBtn.FontFace         = fonts.BodyBold
        keyBtn.TextSize         = 11
        keyBtn.AutoButtonColor  = false
        keyBtn.LayoutOrder      = 4
        keyBtn.ZIndex           = 9
        keyBtn.Parent           = row
        H.corner(keyBtn, 4)
        H.stroke(keyBtn, theme.Border, 1, 0.4)

        local tkAPI = {}

        function tkAPI:SetToggle(v)
            togValue = v
            H.tween(switchOuter, {
                BackgroundColor3 = v and theme.ToggleOn or theme.ToggleOff
            }):Play()
            H.tween(knob, {
                Position = v
                    and UDim2.new(1,-17,0.5,-7)
                    or  UDim2.new(0,3,0.5,-7)
            }):Play()
        end

        function tkAPI:GetToggle() return togValue end

        function tkAPI:SetKey(k)
            currentKey   = tostring(k)
            keyBtn.Text  = currentKey
        end

        function tkAPI:GetKey() return currentKey end

        switchBtn.MouseButton1Click:Connect(function()
            tkAPI:SetToggle(not togValue)
            if opts2.Callback and not suppressed() then
                pcall(opts2.Callback, togValue, currentKey)
            end
        end)

        local function setListening(v)
            listening = v
            if v then
                keyBtn.Text       = "..."
                keyBtn.TextColor3 = theme.TextMuted
                H.tween(keyBtn, { BackgroundColor3 = theme.ButtonDarkH }):Play()
            else
                keyBtn.Text       = currentKey
                keyBtn.TextColor3 = theme.AccentPrimary
                H.tween(keyBtn, { BackgroundColor3 = theme.ButtonDark }):Play()
            end
        end

        if canChange then
            keyBtn.MouseButton1Click:Connect(function()
                setListening(not listening)
            end)
            UserInputService.InputBegan:Connect(function(input)
                if not listening then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                local n = input.KeyCode.Name
                if n == "LeftShift" or n == "RightShift"
                or n == "LeftControl" or n == "RightControl"
                or n == "LeftAlt" or n == "RightAlt"
                or n == "LeftMeta" or n == "RightMeta" then return end
                currentKey = n
                setListening(false)
                if opts2.Callback and not suppressed() then
                    pcall(opts2.Callback, togValue, currentKey)
                end
            end)
        end

        -- flag: serialised as "bool|keyName"  e.g. "true|H"
        regFlag(opts2.Flag,
            function()
                return tostring(togValue) .. "|" .. currentKey
            end,
            function(v)
                local b, k = tostring(v):match("^([^|]+)|(.+)$")
                if b then tkAPI:SetToggle(b == "true") end
                if k then tkAPI:SetKey(k) end
            end)

        return tkAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:Progress(opts)
    --
    -- Display-only progress bar (no drag interaction).
    --
    -- opts:
    --   Title        string
    --   Description  string   (shown under bar, updatable)
    --   Value        number   (initial, in Min–Max range)
    --   Min          number   (default 0)
    --   Max          number   (default 100)
    --   Suffix       string   (default "%")
    --   Color        Color3   (bar fill colour, defaults to theme)
    --
    -- returns: { Set(v), SetDescription(text) }
    -- ──────────────────────────────────────────────────────
    function tabAPI:Progress(opts2)
        opts2 = opts2 or {}
        local minV      = opts2.Min   or 0
        local maxV      = opts2.Max   or 100
        local sufx      = opts2.Suffix or "%"
        local fillColor = opts2.Color or theme.ProgressFill
        local hasDesc   = opts2.Description and opts2.Description ~= ""
        local value     = math.clamp(opts2.Value or 0, minV, maxV)

        local wrap = H.frame(tabAPI._inner,
            UDim2.new(1,0,0, hasDesc and 72 or 56), nil, nil, 8)
        H.pad(wrap, 4,4,4,4)

        -- title + value label row
        local topRow = H.frame(wrap, UDim2.new(1,0,0,20), nil, nil, 9)

        local titleLbl = H.label(topRow, opts2.Title or "Progress",
            fonts.BodyBold, 12, theme.TextPrimary)
        titleLbl.Size = UDim2.new(1,-60,1,0)

        local valueLbl = H.label(topRow, "", fonts.BodyBold, 11,
            theme.AccentPrimary, Enum.TextXAlignment.Right)
        valueLbl.Size     = UDim2.fromOffset(56,20)
        valueLbl.Position = UDim2.new(1,-56,0,0)

        -- optional description
        local descLbl
        if hasDesc then
            descLbl = H.label(wrap, opts2.Description,
                fonts.Body, 10, theme.TextMuted)
            descLbl.Size     = UDim2.new(1,0,0,14)
            descLbl.Position = UDim2.new(0,0,0,22)
        end

        -- track
        local trackY = hasDesc and 42 or 28
        local track  = Instance.new("Frame")
        track.Size             = UDim2.new(1,0,0,6)
        track.Position         = UDim2.new(0,0,0,trackY)
        track.BackgroundColor3 = theme.ProgressTrack
        track.BorderSizePixel  = 0
        track.ZIndex           = 9
        track.Parent           = wrap
        H.corner(track, 3)

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = fillColor
        fill.BorderSizePixel  = 0
        fill.Size             = UDim2.new(0,0,1,0)
        fill.ZIndex           = 10
        fill.Parent           = track
        H.corner(fill, 3)

        local function applyValue(v)
            value = math.clamp(v, minV, maxV)
            local frac = (value - minV) / (maxV - minV)
            H.tween(fill, { Size = UDim2.new(frac,0,1,0) }, 0.2):Play()
            valueLbl.Text = tostring(math.floor(value * 100 + 0.5) / 100) .. sufx
        end

        applyValue(value)

        local progAPI = {}
        function progAPI:Set(v) applyValue(v) end
        function progAPI:SetDescription(text)
            if descLbl then descLbl.Text = tostring(text) end
        end

        return progAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:LiveStats(opts)
    --
    -- A card containing labelled stat rows with live-updatable
    -- values.  Good for session counters, status readouts, etc.
    --
    -- opts:
    --   Title  string              (optional card heading)
    --   Items  array of:
    --     { Key, Value, Icon, IconColor }
    --
    -- returns: { Update(key, newValue) }
    -- ──────────────────────────────────────────────────────
    function tabAPI:LiveStats(opts2)
        opts2 = opts2 or {}
        local items       = opts2.Items or {}
        local valueLabels = {}

        local card = Instance.new("Frame")
        card.Size             = UDim2.new(1,0,0,0)
        card.AutomaticSize    = Enum.AutomaticSize.Y
        card.BackgroundColor3 = theme.CardBG
        card.BorderSizePixel  = 0
        card.ZIndex           = 8
        card.Parent           = tabAPI._inner
        H.corner(card, 6)
        H.stroke(card, theme.Border, 1, 0.5)
        H.pad(card, 8,8,10,10)

        if opts2.Title and opts2.Title ~= "" then
            local hdr = H.label(card, opts2.Title,
                fonts.BodyBold, 11, theme.TextMuted)
            hdr.Size = UDim2.new(1,0,0,20)
        end

        local listFrame = H.frame(card, UDim2.new(1,0,0,0), nil, nil, 9)
        listFrame.AutomaticSize = Enum.AutomaticSize.Y
        H.list(listFrame, Enum.FillDirection.Vertical, 0,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)

        for i, item in ipairs(items) do
            -- divider between rows (not before first)
            if i > 1 then
                H.frame(listFrame, UDim2.new(1,0,0,1), nil,
                    theme.DividerColor, 9)
            end

            local row = H.frame(listFrame, UDim2.new(1,0,0,30), nil, nil, 9)
            H.list(row, Enum.FillDirection.Horizontal, 6,
                Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

            if item.Icon and item.Icon ~= "" then
                local ic = H.icon(item.Icon, UDim2.fromOffset(13,13),
                    item.IconColor or theme.TextMuted)
                ic.LayoutOrder = 1; ic.ZIndex = 10; ic.Parent = row
            end

            local keyLbl = H.label(row, tostring(item.Key or ""),
                fonts.Body, 11, theme.TextSecondary)
            keyLbl.AutomaticSize = Enum.AutomaticSize.X
            keyLbl.Size          = UDim2.fromOffset(0,30)
            keyLbl.LayoutOrder   = 2; keyLbl.ZIndex = 10

            -- flexible spacer pushes value to the right
            local spacer = H.frame(row, UDim2.new(1,0,1,0), nil, nil, 10)
            spacer.LayoutOrder = 3

            local valLbl = H.label(row, tostring(item.Value or "0"),
                fonts.BodyBold, 11, theme.TextPrimary,
                Enum.TextXAlignment.Right)
            valLbl.AutomaticSize = Enum.AutomaticSize.X
            valLbl.Size          = UDim2.fromOffset(0,30)
            valLbl.LayoutOrder   = 4; valLbl.ZIndex = 10

            if item.Key then
                valueLabels[tostring(item.Key)] = valLbl
            end
        end

        local statsAPI = {}
        function statsAPI:Update(key, newValue)
            local lbl = valueLabels[tostring(key)]
            if lbl then lbl.Text = tostring(newValue) end
        end

        return statsAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:HStack(opts)
    --
    -- Lays child elements out horizontally in equal-width
    -- columns.  Each element call (Button, Toggle, etc.)
    -- gets its own column and all columns resize equally.
    --
    -- opts:
    --   Padding  number   (gap between columns, default 6)
    --
    -- returns: sub-API (Button, Toggle, Slider, Dropdown, Input,
    --          Keybind, ToggleKeybind, Progress, LiveStats,
    --          Card, Divider, Spacer, Label, Section)
    -- ──────────────────────────────────────────────────────
    function tabAPI:HStack(opts2)
        opts2 = opts2 or {}
        local gap      = opts2.Padding or 6
        local slots    = {}

        local container = H.frame(tabAPI._inner, UDim2.new(1,0,0,0),
            nil, nil, 8)
        container.AutomaticSize = Enum.AutomaticSize.Y
        H.list(container, Enum.FillDirection.Horizontal, gap,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

        local function nextSlot()
            local slot = H.frame(container, UDim2.new(0,0,0,0), nil, nil, 8)
            slot.AutomaticSize = Enum.AutomaticSize.Y
            table.insert(slots, slot)
            local n = #slots
            for _, s in ipairs(slots) do
                s.Size = UDim2.new(
                    1/n, -math.ceil(gap*(n-1)/n),
                    0, 0)
            end
            H.list(slot, Enum.FillDirection.Vertical, 0,
                Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
            return slot
        end

        -- Build a fresh sub-API that writes into the next slot
        local function makeSlotAPI()
            local slot = nextSlot()
            local sAPI = makeTabAPI(slot, theme, fonts, winRef)
            sAPI._inner = slot
            return sAPI
        end

        -- Proxy the common element builders
        local hAPI = {}
        local proxied = {
            "Button","Toggle","Slider","Dropdown","Input",
            "Keybind","ToggleKeybind","Progress","LiveStats",
            "Card","Divider","Spacer","Label","Section",
        }
        for _, method in ipairs(proxied) do
            hAPI[method] = function(self, o)
                local sAPI = makeSlotAPI()
                if sAPI[method] then return sAPI[method](sAPI, o) end
            end
        end

        return hAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Tab:VStack(opts)
    --
    -- Explicit vertical sub-container.  Useful when you want a
    -- scoped sub-API (e.g. inside a section or HStack column)
    -- without the full Section styling.
    --
    -- opts:
    --   Padding  number   (gap between children, default 0)
    --
    -- returns: sub-API
    -- ──────────────────────────────────────────────────────
    function tabAPI:VStack(opts2)
        opts2 = opts2 or {}

        local container = H.frame(tabAPI._inner, UDim2.new(1,0,0,0),
            nil, nil, 8)
        container.AutomaticSize = Enum.AutomaticSize.Y
        H.list(container, Enum.FillDirection.Vertical,
            opts2.Padding or 0,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)

        local vAPI = makeTabAPI(container, theme, fonts, winRef)
        vAPI._inner = container
        return vAPI
    end

end -- /extendTabAPI


-- ============================================================
-- extendWindow
-- Called once at the end of CreateWindow (see merge guide).
-- Adds flag registry + window-level extras to winAPI.
-- ============================================================

local function extendWindow(winAPI, T, F, ScreenGui, Main, Content, TopBar)

    -- ── Flag registry ──────────────────────────────────────
    winAPI._flags             = winAPI._flags or {}
    winAPI._suppressCallbacks = false

    -- ──────────────────────────────────────────────────────
    -- Window:Tag(opts)
    --
    -- Adds a small pill badge to the right side of the topbar.
    -- Badges stack left as more are added.
    --
    -- opts:
    --   Title   string
    --   Icon    string    (optional)
    --   Color   Color3    (text/icon colour, defaults to accent)
    --
    -- returns: { SetTitle(text), SetColor(color) }
    -- ──────────────────────────────────────────────────────
    function winAPI:Tag(opts2)
        opts2 = opts2 or {}
        local tagColor = opts2.Color or T.AccentPrimary

        -- count existing tags to stack them
        local tagCount = 0
        for _, c in ipairs(TopBar:GetChildren()) do
            if c:GetAttribute("_chronosTag") then
                tagCount += 1
            end
        end
        local rightOff = 90 + tagCount * 90  -- rough width per tag

        local tag = Instance.new("Frame")
        tag.Size             = UDim2.fromOffset(0, 22)
        tag.AutomaticSize    = Enum.AutomaticSize.X
        tag.AnchorPoint      = Vector2.new(1, 0.5)
        tag.Position         = UDim2.new(1, -rightOff, 0.5, 0)
        tag.BackgroundColor3 = T.ButtonDark
        tag.BorderSizePixel  = 0
        tag.ZIndex           = 12
        tag.Parent           = TopBar
        tag:SetAttribute("_chronosTag", true)
        H.corner(tag, 4)
        H.stroke(tag, T.Border, 1, 0.4)
        H.pad(tag, 0,0,6,6)
        H.list(tag, Enum.FillDirection.Horizontal, 4,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

        if opts2.Icon and opts2.Icon ~= "" then
            local ic = H.icon(opts2.Icon, UDim2.fromOffset(11,11), tagColor)
            ic.LayoutOrder = 1; ic.ZIndex = 13; ic.Parent = tag
        end

        local tagLbl = H.label(tag, opts2.Title or "",
            F.BodyBold, 10, tagColor)
        tagLbl.AutomaticSize = Enum.AutomaticSize.X
        tagLbl.Size          = UDim2.fromOffset(0,22)
        tagLbl.LayoutOrder   = 2; tagLbl.ZIndex = 13

        local tagAPI = {}

        function tagAPI:SetTitle(text)
            tagLbl.Text = tostring(text)
        end

        function tagAPI:SetColor(color)
            tagLbl.TextColor3 = color
            for _, c in ipairs(tag:GetChildren()) do
                if c:IsA("ImageLabel") then c.ImageColor3 = color end
            end
        end

        return tagAPI
    end

    -- ──────────────────────────────────────────────────────
    -- Window:SidebarDivider()
    --
    -- Adds a thin horizontal rule between tab groups in the
    -- sidebar.  Requires winAPI._SidebarTop to be set
    -- (see merge guide step 5).
    -- ──────────────────────────────────────────────────────
    function winAPI:SidebarDivider()
        local parent = winAPI._SidebarTop
        if not parent then return end
        local div = H.frame(parent, UDim2.new(1,-16,0,1), nil, T.DividerColor, 11)
        div.AnchorPoint = Vector2.new(0.5, 0.5)
        return div
    end

    -- ──────────────────────────────────────────────────────
    -- Window:Dialog(opts)
    --
    -- Generic modal dialog with up to 4 labelled buttons.
    -- Outer frame is sharp (no UICorner); buttons inside are
    -- rounded.  Buttons have named variants:
    --   "Primary"     — gold accent colour
    --   "Secondary"   — dark/neutral  (default)
    --   "Destructive" — danger red
    --   "Success"     — teal/green
    --
    -- opts:
    --   Title    string
    --   Content  string
    --   Icon     string
    --   Buttons  array of { Title, Icon, Variant, Callback }
    --
    -- returns: { Show(), Close() }
    -- ──────────────────────────────────────────────────────
    function winAPI:Dialog(opts2)
        opts2 = opts2 or {}
        local buttons  = opts2.Buttons or {{ Title = "OK" }}
        local DTH      = 38
        local DW       = 400
        local contentH = (opts2.Content and opts2.Content ~= "") and 56 or 16
        local DH       = DTH + contentH + 56

        local overlay = Instance.new("Frame")
        overlay.Size                   = UDim2.fromScale(1,1)
        overlay.BackgroundColor3       = T.ModalOverlay
        overlay.BackgroundTransparency = 1
        overlay.BorderSizePixel        = 0
        overlay.ZIndex                 = 500
        overlay.Visible                = false
        overlay.Parent                 = Content

        local blocker = Instance.new("TextButton")
        blocker.Size                   = UDim2.fromScale(1,1)
        blocker.BackgroundTransparency = 1
        blocker.Text                   = ""
        blocker.AutoButtonColor        = false
        blocker.ZIndex                 = 500
        blocker.Parent                 = overlay

        local dlg = Instance.new("Frame")
        dlg.Size             = UDim2.fromOffset(DW, DH)
        dlg.AnchorPoint      = Vector2.new(0.5, 0.5)
        dlg.Position         = UDim2.fromScale(0.5, 0.5)
        dlg.BackgroundColor3 = T.SidebarBG
        dlg.BorderSizePixel  = 0
        dlg.ZIndex           = 501
        dlg.Parent           = overlay
        H.stroke(dlg, T.BorderLight, 1)
        -- sharp outer frame — no UICorner intentional

        local dlgTop = H.frame(dlg, UDim2.new(1,0,0,DTH), nil, T.TitleBarBG, 502)
        H.frame(dlgTop, UDim2.new(1,0,0,1), UDim2.new(0,0,1,0), T.Border, 502)

        local xOff = 14
        if opts2.Icon and opts2.Icon ~= "" then
            local ic = H.icon(opts2.Icon, UDim2.fromOffset(15,15), T.AccentPrimary)
            ic.Position = UDim2.new(0,12,0.5,-7)
            ic.ZIndex   = 503; ic.Parent = dlgTop
            xOff = 34
        end

        local htl = H.label(dlgTop, opts2.Title or "Dialog",
            F.Title, 13, T.TextPrimary)
        htl.Size     = UDim2.new(1,-(xOff+10),1,0)
        htl.Position = UDim2.new(0,xOff,0,0)
        htl.ZIndex   = 503

        if opts2.Content and opts2.Content ~= "" then
            local cLbl = H.label(dlg, opts2.Content, F.Body, 11, T.TextSecondary)
            cLbl.Size        = UDim2.new(1,-28,0,contentH)
            cLbl.Position    = UDim2.new(0,14,0,DTH+10)
            cLbl.TextWrapped = true
            cLbl.ZIndex      = 502
        end

        -- button row
        local btnRow = H.frame(dlg, UDim2.new(1,-28,0,32),
            UDim2.new(0,14,1,-44), nil, 502)
        H.list(btnRow, Enum.FillDirection.Horizontal, 8,
            Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

        local variantBG = {
            Primary     = T.AccentPrimary,
            Secondary   = T.ButtonDark,
            Destructive = T.ButtonDanger,
            Success     = T.ButtonSuccess,
        }
        local variantBGH = {
            Primary     = T.AccentPrimaryH,
            Secondary   = T.ButtonDarkH,
            Destructive = T.ButtonDangerH,
            Success     = T.ButtonSuccessH,
        }

        local dialogAPI = {}

        local function closeDialog()
            H.tween(overlay, { BackgroundTransparency = 1 }, 0.12):Play()
            task.delay(0.13, function()
                overlay.Visible = false
            end)
        end

        blocker.MouseButton1Click:Connect(closeDialog)

        for i, bDef in ipairs(buttons) do
            if i > 4 then break end
            local variant = bDef.Variant or "Secondary"
            local bg      = variantBG[variant]  or T.ButtonDark
            local bgH     = variantBGH[variant] or T.ButtonDarkH

            local b = Instance.new("TextButton")
            b.Size             = UDim2.fromOffset(92, 30)
            b.BackgroundColor3 = bg
            b.BorderSizePixel  = 0
            b.Text             = ""
            b.AutoButtonColor  = false
            b.LayoutOrder      = i
            b.ZIndex           = 503
            b.Parent           = btnRow
            H.corner(b, 4)
            H.stroke(b, T.BorderLight, 1, 0.4)
            H.hover(b, bg, bgH)

            H.list(b, Enum.FillDirection.Horizontal, 5,
                Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

            if bDef.Icon and bDef.Icon ~= "" then
                local bic = H.icon(bDef.Icon, UDim2.fromOffset(12,12), T.TextPrimary)
                bic.LayoutOrder = 1; bic.ZIndex = 504; bic.Parent = b
            end

            local bl = H.label(b, tostring(bDef.Title or "OK"),
                F.BodyBold, 11, T.TextPrimary)
            bl.AutomaticSize = Enum.AutomaticSize.X
            bl.Size          = UDim2.fromOffset(0,30)
            bl.LayoutOrder   = 2; bl.ZIndex = 504

            b.MouseButton1Click:Connect(function()
                closeDialog()
                if bDef.Callback then pcall(bDef.Callback) end
            end)
        end

        function dialogAPI:Show()
            overlay.Visible = true
            H.tween(overlay, { BackgroundTransparency = 0.5 }, 0.15):Play()
        end

        function dialogAPI:Close()
            closeDialog()
        end

        return dialogAPI
    end

end -- /extendWindow

-- ============================================================
-- ChronosUI — Roblox UI Library
-- Part 3 of 3: ConfigManager + Window:ConfigTab()
-- ============================================================
-- MERGE INSTRUCTIONS:
--   In your merged Part1+2 file, find the final `return ChronosUI`
--   at the very bottom and paste this file DIRECTLY BEFORE it.
--   No other changes needed — the CreateWindow wrapper below
--   automatically runs after extendWindow from Part 2.
-- ============================================================

-- ============================================================
-- CONFIG MANAGER
-- ============================================================
-- Handles save/load/delete of flagged element states to disk.
-- Stored as JSON in:  ChronosUI/<name>.json
-- Auto-load target:   ChronosUI/autoload.txt
--
-- Attached to winAPI as:  Window.ConfigManager
--
-- Methods:
--   :Save(name)        — serialise all _flags → JSON file
--   :Load(name)        — read file, apply flags silently
--   :Delete(name)      — remove the JSON file
--   :List()            — returns sorted array of config names
--   :SetAutoLoad(name) — write name to autoload.txt ("" to clear)
--   :GetAutoLoad()     — read autoload.txt, returns name or ""
--   :AutoLoad()        — call once after tab setup; loads autoload
--                        target after 1s delay with a toast
-- ============================================================

local function buildConfigManager(winAPI)
    local CM             = {}
    local FOLDER         = "ChronosUI"
    local AUTOLOAD_FILE  = FOLDER .. "/autoload.txt"

    local function ensureFolder()
        pcall(function()
            if isfolder and not isfolder(FOLDER) then
                makefolder(FOLDER)
            end
        end)
    end

    local function configPath(name)
        return FOLDER .. "/" .. name .. ".json"
    end

    local function getHttp()
        return game:GetService("HttpService")
    end

    local function gatherFlags()
        local data = {}
        for flag, entry in pairs(winAPI._flags or {}) do
            local ok, val = pcall(entry.get)
            if ok then data[flag] = val end
        end
        return data
    end

    function CM:Save(name)
        if not name or name == "" then return false, "No name provided." end
        ensureFolder()
        local ok, json = pcall(function()
            return getHttp():JSONEncode(gatherFlags())
        end)
        if not ok then return false, "JSON encode failed." end
        local ok2, err = pcall(writefile, configPath(name), json)
        if not ok2 then return false, tostring(err) end
        return true
    end

    function CM:Load(name)
        if not name or name == "" then return false, "No name provided." end
        local path = configPath(name)
        local exists = false
        pcall(function() exists = isfile(path) end)
        if not exists then return false, "Config not found: " .. name end

        local ok, raw = pcall(readfile, path)
        if not ok then return false, "Read failed." end

        local ok2, data = pcall(function() return getHttp():JSONDecode(raw) end)
        if not ok2 or type(data) ~= "table" then return false, "JSON decode failed." end

        local prev = winAPI._suppressCallbacks
        winAPI._suppressCallbacks = true
        for flag, value in pairs(data) do
            local entry = winAPI._flags and winAPI._flags[flag]
            if entry and entry.set then pcall(entry.set, value) end
        end
        winAPI._suppressCallbacks = prev
        return true
    end

    function CM:Delete(name)
        if not name or name == "" then return false, "No name provided." end
        local ok, err = pcall(delfile, configPath(name))
        if not ok then return false, tostring(err) end
        return true
    end

    function CM:List()
        local results = {}
        pcall(function()
            if not isfolder(FOLDER) then return end
            for _, f in ipairs(listfiles(FOLDER)) do
                local name = f:gsub("\\", "/"):match("([^/]+)%.json$")
                if name then table.insert(results, name) end
            end
        end)
        table.sort(results)
        return results
    end

    function CM:SetAutoLoad(name)
        ensureFolder()
        if name and name ~= "" then
            pcall(writefile, AUTOLOAD_FILE, name)
        else
            pcall(function()
                if isfile(AUTOLOAD_FILE) then delfile(AUTOLOAD_FILE) end
            end)
        end
    end

    function CM:GetAutoLoad()
        local name = ""
        pcall(function()
            if isfile(AUTOLOAD_FILE) then
                name = readfile(AUTOLOAD_FILE):match("^%s*(.-)%s*$")
            end
        end)
        return name
    end

    function CM:AutoLoad()
        local name = self:GetAutoLoad()
        if not name or name == "" then return end
        task.delay(1, function()
            local ok, err = self:Load(name)
            if winAPI._showToast then
                if ok then
                    winAPI._showToast("Config loaded: " .. name, "success")
                else
                    winAPI._showToast("Auto-load failed: " .. tostring(err), "error")
                end
            end
        end)
    end

    return CM
end


-- ============================================================
-- Window:ConfigTab()
-- ============================================================
-- Call after building all your other tabs.
-- Creates a bottom-sidebar "Configs" tab pre-populated with:
--
--   Section "Save Config"
--     Input  — name to save as
--     Button — Save (refreshes dropdown after saving)
--
--   Section "Manage Configs"
--     Dropdown — all saved configs (refreshed on save/delete)
--     HStack   — [Load]  [Delete]
--
--   Section "Auto-Load"
--     Toggle  — enable/disable auto-load for selected config
--     Label   — hint text
--
-- Returns the tab API so you can add extra elements below.
--
-- Usage:
--   local ConfigsTab = Window:ConfigTab()
--   Window.ConfigManager:AutoLoad()   -- call at end of script
-- ============================================================

local function addConfigTab(winAPI)
    local CM  = winAPI.ConfigManager
    local tab = winAPI:Tab({
        Title  = "Configs",
        Icon   = "lucide:save",
        Bottom = true,
    })

    -- ── Save ─────────────────────────────────────────────

    local saveSection = tab:Section({ Title = "Save Config", Icon = "lucide:save" })

    local nameInput = saveSection:Input({
        Title       = "Config Name",
        Placeholder = "e.g. MyConfig",
        Icon        = "lucide:file-text",
    })

    -- ── Manage ───────────────────────────────────────────

    local manageSection = tab:Section({ Title = "Manage Configs", Icon = "lucide:folder-open" })

    local function freshList()
        local list = CM:List()
        return #list > 0 and list or { "(none)" }
    end

    local configDrop = manageSection:Dropdown({
        Title  = "Saved Configs",
        Icon   = "lucide:list",
        Values = freshList(),
    })

    local function refreshDrop()
        local list = freshList()
        configDrop:Refresh(list)
        configDrop:Set(list[1])
    end

    -- Save button goes after dropdown so user can see list update
    saveSection:Button({
        Title    = "Save",
        Icon     = "lucide:save",
        Callback = function()
            local n = nameInput:Get():match("^%s*(.-)%s*$")
            if n == "" then
                winAPI._showToast("Enter a config name first.", "warning")
                return
            end
            local ok, err = CM:Save(n)
            if ok then
                winAPI._showToast("Saved: " .. n, "success")
                refreshDrop()
            else
                winAPI._showToast("Save failed: " .. tostring(err), "error")
            end
        end,
    })

    local actionRow = manageSection:HStack({ Padding = 8 })

    actionRow:Button({
        Title    = "Load",
        Icon     = "lucide:folder-input",
        Callback = function()
            local sel = configDrop:Get()
            if not sel or sel == "(none)" then
                winAPI._showToast("No config selected.", "warning")
                return
            end
            local ok, err = CM:Load(sel)
            if ok then
                winAPI._showToast("Loaded: " .. sel, "success")
            else
                winAPI._showToast("Load failed: " .. tostring(err), "error")
            end
        end,
    })

    actionRow:Button({
        Title    = "Delete",
        Icon     = "lucide:trash-2",
        Callback = function()
            local sel = configDrop:Get()
            if not sel or sel == "(none)" then
                winAPI._showToast("No config selected.", "warning")
                return
            end
            winAPI:Confirm(
                "Delete config?",
                'Delete "' .. sel .. '"? This cannot be undone.',
                function()
                    local ok, err = CM:Delete(sel)
                    if ok then
                        if CM:GetAutoLoad() == sel then CM:SetAutoLoad("") end
                        winAPI._showToast("Deleted: " .. sel, "info")
                        refreshDrop()
                    else
                        winAPI._showToast("Delete failed: " .. tostring(err), "error")
                    end
                end
            )
        end,
    })

    -- ── Auto-Load ─────────────────────────────────────────

    local autoSection = tab:Section({ Title = "Auto-Load", Icon = "lucide:zap" })

    autoSection:Toggle({
        Title       = "Auto-Load on Start",
        Description = "Loads the selected config automatically next session.",
        Icon        = "lucide:zap",
        Value       = CM:GetAutoLoad() ~= "",
        Callback    = function(state)
            if state then
                local sel = configDrop:Get()
                if not sel or sel == "(none)" then
                    winAPI._showToast("Select a config to auto-load first.", "warning")
                    -- re-open won't self-correct here without a ref, so just toast
                    return
                end
                CM:SetAutoLoad(sel)
                winAPI._showToast("Auto-load set to: " .. sel, "success")
            else
                CM:SetAutoLoad("")
                winAPI._showToast("Auto-load disabled.", "info")
            end
        end,
    })

    autoSection:Label({
        Text = "Select a config above, then enable this toggle to auto-load it on the next session.",
    })

    return tab
end


local _origCreateWindow = ChronosUI.CreateWindow

function ChronosUI:CreateWindow(opts)
    local winAPI = _origCreateWindow(self, opts)

    winAPI.ConfigManager = buildConfigManager(winAPI)

    function winAPI:ConfigTab()
        return addConfigTab(self)
    end

    return winAPI
end

return ChronosUI
