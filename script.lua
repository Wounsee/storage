-- [[ NEXUS M — ULTRA RESPONSIVE GLASSMORPHISM HUB ]] --
-- Developer: Colin | Full Mobile/PC Adaptive UI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- [ ЗАЩИТА: Прячем GUI от проверок игры ]
local TargetGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if TargetGui:FindFirstChild("NexusHub_V2") then 
    TargetGui.NexusHub_V2:Destroy() 
end

----------------------------------------------------------------
-- [КОНФИГ]
----------------------------------------------------------------
local CFG = {
    Accent = Color3.fromRGB(0, 195, 255),
    AccentDark = Color3.fromRGB(0, 120, 180),
    AccentGlow = Color3.fromRGB(0, 210, 255),
    BgDeep = Color3.fromRGB(6, 7, 12),
    BgCard = Color3.fromRGB(11, 13, 22),
    BgGlass = Color3.fromRGB(18, 20, 32),
    BgGlass2 = Color3.fromRGB(22, 25, 40),
    TextPrimary = Color3.fromRGB(240, 242, 255),
    TextSecond = Color3.fromRGB(130, 135, 165),
    TextMuted = Color3.fromRGB(70, 75, 100),
    Red = Color3.fromRGB(255, 70, 100),
    Green = Color3.fromRGB(50, 220, 130),
    Yellow = Color3.fromRGB(255, 200, 50),
    Purple = Color3.fromRGB(155, 90, 255),
}

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

----------------------------------------------------------------
-- [ГЛАВНЫЙ SCREENGUI]
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusHub_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = TargetGui

----------------------------------------------------------------
-- [УТИЛИТЫ]
----------------------------------------------------------------
local function tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t or 0.25, style, dir), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or CFG.Accent
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, c0, c1, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function padding(parent, all, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or all or 0)
    p.PaddingBottom = UDim.new(0, bottom or all or 0)
    p.PaddingLeft = UDim.new(0, left or all or 0)
    p.PaddingRight = UDim.new(0, right or all or 0)
    p.Parent = parent
    return p
end

local function label(parent, text, size, font, color, xa, ya)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 14
    l.Font = font or Enum.Font.GothamMedium
    l.TextColor3 = color or CFG.TextPrimary
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextYAlignment = ya or Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

----------------------------------------------------------------
-- [DRAGGABLE]
----------------------------------------------------------------
local function makeDraggable(handle, target)
    local dragging, dStart, tStart = false, nil, nil

    local function onInputBegan(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = true
            dStart = inp.Position
            tStart = target.Position

            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    local function onInputChanged(inp)
        local t = inp.UserInputType
        if dragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
            local d = inp.Position - dStart
            target.Position = UDim2.new(
                tStart.X.Scale, tStart.X.Offset + d.X,
                tStart.Y.Scale, tStart.Y.Offset + d.Y
            )
        end
    end

    handle.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
end

----------------------------------------------------------------
-- [AMBIENT PARTICLES — красивый фоновый эффект]
----------------------------------------------------------------
local ParticleCanvas = Instance.new("Frame")
ParticleCanvas.Name = "ParticleCanvas"
ParticleCanvas.Size = UDim2.new(1,0,1,0)
ParticleCanvas.BackgroundTransparency = 1
ParticleCanvas.ZIndex = 0
ParticleCanvas.Parent = ScreenGui

local particles = {}
local function spawnParticle()
    local vp = workspace.CurrentCamera.ViewportSize
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2,5), 0, math.random(2,5))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = math.random() > 0.5 and CFG.Accent or CFG.Purple
    p.BackgroundTransparency = math.random(60,90)/100
    p.BorderSizePixel = 0
    p.ZIndex = 1
    corner(p, 99)
    p.Parent = ParticleCanvas

    local life = math.random(4,10)
    local startT = tick()
    local startX = p.Position.X.Scale
    local startY = p.Position.Y.Scale
    local driftX = (math.random()-0.5)*0.08
    local driftY = -math.random(2,5)*0.01

    table.insert(particles, {frame=p, startT=startT, life=life, sx=startX, sy=startY, dx=driftX, dy=driftY})
end

for i=1,18 do spawnParticle() end

RunService.RenderStepped:Connect(function()
    local now = tick()
    for i = #particles, 1, -1 do
        local pt = particles[i]
        local elapsed = now - pt.startT
        if elapsed >= pt.life then
            pt.frame:Destroy()
            table.remove(particles, i)
            spawnParticle()
        else
            local prog = elapsed / pt.life
            pt.frame.Position = UDim2.new(
                pt.sx + pt.dx * prog, 0,
                pt.sy + pt.dy * prog, 0
            )
            pt.frame.BackgroundTransparency = 0.4 + 0.6*(math.abs(math.sin(prog*math.pi)))
        end
    end
end)

----------------------------------------------------------------
-- [FLOATING BUTTON — мобильная кнопка открытия]
----------------------------------------------------------------
local FB = Instance.new("TextButton")
FB.Name = "FloatBtn"
FB.Size = UDim2.new(0, 52, 0, 52)
FB.Position = UDim2.new(0, 16, 0.45, 0)
FB.BackgroundColor3 = CFG.BgDeep
FB.Text = ""
FB.AutoButtonColor = false
FB.ZIndex = 10
FB.Parent = ScreenGui
corner(FB, 16)
stroke(FB, CFG.Accent, 1.5)

local FBIcon = Instance.new("TextLabel")
FBIcon.Size = UDim2.new(1,0,1,0)
FBIcon.BackgroundTransparency = 1
FBIcon.Text = "⚡"
FBIcon.TextSize = 22
FBIcon.Font = Enum.Font.GothamBold
FBIcon.TextColor3 = CFG.Accent
FBIcon.TextXAlignment = Enum.TextXAlignment.Center
FBIcon.TextYAlignment = Enum.TextYAlignment.Center
FBIcon.ZIndex = 11
FBIcon.Parent = FB

local FBGlow = Instance.new("Frame")
FBGlow.Size = UDim2.new(1, 20, 1, 20)
FBGlow.Position = UDim2.new(0, -10, 0, -10)
FBGlow.BackgroundColor3 = CFG.Accent
FBGlow.BackgroundTransparency = 0.85
FBGlow.ZIndex = 9
FBGlow.Parent = FB
corner(FBGlow, 20)

makeDraggable(FB, FB)

task.spawn(function()
    while true do
        tween(FBGlow, {BackgroundTransparency=0.7, Size=UDim2.new(1,26,1,26), Position=UDim2.new(0,-13,0,-13)}, 0.9, Enum.EasingStyle.Sine)
        task.wait(0.9)
        tween(FBGlow, {BackgroundTransparency=0.92, Size=UDim2.new(1,14,1,14), Position=UDim2.new(0,-7, 0,-7)}, 0.9, Enum.EasingStyle.Sine)
        task.wait(0.9)
    end
end)

----------------------------------------------------------------
-- [ГЛАВНОЕ ОКНО]
----------------------------------------------------------------
local W = isMobile and 360 or 560
local H = isMobile and 440 or 340

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, W, 0, H)
MainFrame.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
MainFrame.BackgroundColor3 = CFG.BgDeep
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.ZIndex = 20
MainFrame.Parent = ScreenGui
corner(MainFrame, 18)
stroke(MainFrame, Color3.fromRGB(35, 38, 60), 1)

gradient(MainFrame, Color3.fromRGB(10, 11, 20), Color3.fromRGB(14, 16, 28), 135)

local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(1, 0, 0, 2)
AccentBar.Position = UDim2.new(0, 0, 0, 0)
AccentBar.BackgroundColor3 = CFG.Accent
AccentBar.BorderSizePixel = 0
AccentBar.ZIndex = 22
AccentBar.Parent = MainFrame
gradient(AccentBar, CFG.Accent, CFG.Purple, 0)

local GlassHighlight = Instance.new("Frame")
GlassHighlight.Size = UDim2.new(0.7, 0, 0.4, 0)
GlassHighlight.Position = UDim2.new(-0.1, 0, -0.2, 0)
GlassHighlight.BackgroundColor3 = CFG.Accent
GlassHighlight.BackgroundTransparency = 0.93
GlassHighlight.BorderSizePixel = 0
GlassHighlight.ZIndex = 21
GlassHighlight.Rotation = -20
GlassHighlight.Parent = MainFrame
corner(GlassHighlight, 80)

----------------------------------------------------------------
-- [ШАПКА ОКНА (HEADER)]
----------------------------------------------------------------
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = CFG.BgGlass
Header.BorderSizePixel = 0
Header.ZIndex = 23
Header.Parent = MainFrame
corner(Header, 18)

local HeaderBotCover = Instance.new("Frame")
HeaderBotCover.Size = UDim2.new(1,0,0,18)
HeaderBotCover.Position = UDim2.new(0,0,1,-18)
HeaderBotCover.BackgroundColor3 = CFG.BgGlass
HeaderBotCover.BorderSizePixel = 0
HeaderBotCover.ZIndex = 23
HeaderBotCover.Parent = Header

local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Color = Color3.fromRGB(40, 44, 70)
HeaderStroke.Thickness = 1
HeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
HeaderStroke.Parent = Header

local LogoCircle = Instance.new("Frame")
LogoCircle.Size = UDim2.new(0, 32, 0, 32)
LogoCircle.Position = UDim2.new(0, 12, 0.5, -16)
LogoCircle.BackgroundColor3 = CFG.BgDeep
LogoCircle.BorderSizePixel = 0
LogoCircle.ZIndex = 24
LogoCircle.Parent = Header
corner(LogoCircle, 10)
stroke(LogoCircle, CFG.Accent, 1.5)

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size = UDim2.new(1,0,1,0)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text = "⚡"
LogoIcon.TextSize = 16
LogoIcon.Font = Enum.Font.GothamBold
LogoIcon.TextColor3 = CFG.Accent
LogoIcon.TextXAlignment = Enum.TextXAlignment.Center
LogoIcon.TextYAlignment = Enum.TextYAlignment.Center
LogoIcon.ZIndex = 25
LogoIcon.Parent = LogoCircle

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 120, 0, 22)
TitleLabel.Position = UDim2.new(0, 52, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NEXUS"
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextColor3 = CFG.TextPrimary
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 24
TitleLabel.Parent = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 120, 0, 14)
SubLabel.Position = UDim2.new(0, 52, 0, 30)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Universal Hub v2.0"
SubLabel.TextSize = 10
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextColor3 = CFG.TextMuted
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.ZIndex = 24
SubLabel.Parent = Header

local Badge = Instance.new("Frame")
Badge.Size = UDim2.new(0, 64, 0, 20)
Badge.Position = UDim2.new(0, 178, 0.5, -10)
Badge.BackgroundColor3 = Color3.fromRGB(20, 60, 35)
Badge.BorderSizePixel = 0
Badge.ZIndex = 24
Badge.Parent = Header
corner(Badge, 6)

local BadgeDot = Instance.new("Frame")
BadgeDot.Size = UDim2.new(0, 6, 0, 6)
BadgeDot.Position = UDim2.new(0, 6, 0.5, -3)
BadgeDot.BackgroundColor3 = CFG.Green
BadgeDot.BorderSizePixel = 0
BadgeDot.ZIndex = 25
BadgeDot.Parent = Badge
corner(BadgeDot, 99)

local BadgeText = Instance.new("TextLabel")
BadgeText.Size = UDim2.new(1,-16,1,0)
BadgeText.Position = UDim2.new(0,16,0,0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text = "ACTIVE"
BadgeText.TextSize = 9
BadgeText.Font = Enum.Font.GothamBold
BadgeText.TextColor3 = CFG.Green
BadgeText.TextXAlignment = Enum.TextXAlignment.Left
BadgeText.ZIndex = 25
BadgeText.Parent = Badge

local function makeWinBtn(icon, posX, bgColor, iconColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.Position = UDim2.new(1, posX, 0.5, -13)
    btn.BackgroundColor3 = bgColor
    btn.Text = icon
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = iconColor
    btn.AutoButtonColor = false
    btn.ZIndex = 26
    btn.Parent = Header
    corner(btn, 8)
    btn.MouseEnter:Connect(function() tween(btn,{BackgroundTransparency=0.3},0.15) end)
    btn.MouseLeave:Connect(function() tween(btn,{BackgroundTransparency=0},0.15) end)
    return btn
end

local CloseBtn = makeWinBtn("✕", -12, Color3.fromRGB(60,20,25), CFG.Red)
local MinimizeBtn = makeWinBtn("−", -44, Color3.fromRGB(50,45,15), CFG.Yellow)

makeDraggable(Header, MainFrame)

----------------------------------------------------------------
-- [БОКОВАЯ ПАНЕЛЬ]
----------------------------------------------------------------
local SidebarW = isMobile and 54 or 150
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SidebarW, 1, -52)
Sidebar.Position = UDim2.new(0, 0, 0, 52)
Sidebar.BackgroundColor3 = CFG.BgGlass
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 22
Sidebar.Parent = MainFrame

local SideStroke = Instance.new("UIStroke")
SideStroke.Color = Color3.fromRGB(35,38,62)
SideStroke.Thickness = 1
SideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SideStroke.Parent = Sidebar

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 1, -52)
Divider.Position = UDim2.new(0, SidebarW, 0, 52)
Divider.BackgroundColor3 = Color3.fromRGB(35,38,62)
Divider.BorderSizePixel = 0
Divider.ZIndex = 23
Divider.Parent = MainFrame

local SideList = Instance.new("UIListLayout")
SideList.Parent = Sidebar
SideList.Padding = UDim.new(0, 4)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
padding(Sidebar, 8)

----------------------------------------------------------------
-- [КОНТЕНТНАЯ ОБЛАСТЬ]
----------------------------------------------------------------
local ContentW = W - SidebarW - 1
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(0, ContentW, 1, -52)
ContentArea.Position = UDim2.new(0, SidebarW+1, 0, 52)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 22
ContentArea.Parent = MainFrame

----------------------------------------------------------------
-- [СТРАНИЦЫ]
----------------------------------------------------------------
local Pages = {}

local function makePage(id)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = id.."_page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = CFG.Accent
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.Visible = false
    Page.ZIndex = 23
    Page.Parent = ContentArea

    local List = Instance.new("UIListLayout")
    List.Parent = Page
    List.Padding = UDim.new(0, 6)
    List.SortOrder = Enum.SortOrder.LayoutOrder

    padding(Page, 10, 10, 10, 8, 8)
    Pages[id] = Page
    return Page
end

local PgMain = makePage("main")
local PgCombat = makePage("combat")
local PgVisuals = makePage("visuals")
local PgPlayer = makePage("player")
local PgMisc = makePage("misc")

local activePage = nil
local activeTab = nil

local function switchPage(id, tabData)
    if activeTab then
        tween(activeTab.bg, {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency=1}, 0.2)
        tween(activeTab.icon, {TextColor3 = CFG.TextMuted}, 0.2)
        if activeTab.lbl then
            tween(activeTab.lbl, {TextColor3 = CFG.TextMuted}, 0.2)
        end
    end

    if activePage then
        activePage.Visible = false
    end

    activePage = Pages[id]
    activeTab = tabData

    if activePage then
        activePage.Visible = true
    end

    tween(tabData.bg, {BackgroundColor3 = Color3.fromRGB(0,120,160), BackgroundTransparency=0.7}, 0.2)
    tween(tabData.icon, {TextColor3 = CFG.Accent}, 0.2)
    if tabData.lbl then
        tween(tabData.lbl, {TextColor3 = CFG.TextPrimary}, 0.2)
    end
end

----------------------------------------------------------------
-- [СОЗДАНИЕ ВКЛАДКИ (TAB BUTTON)]
----------------------------------------------------------------
local tabDefs = {
    {id="main", icon="🏠", label="Главная", color=CFG.Accent},
    {id="combat", icon="⚔️", label="Бой", color=CFG.Red},
    {id="visuals", icon="👁", label="Визуал", color=CFG.Purple},
    {id="player", icon="🏃", label="Игрок", color=CFG.Green},
    {id="misc", icon="⚙️", label="Прочее", color=CFG.Yellow},
}

local tabButtons = {}

for i, def in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = isMobile and UDim2.new(1, 0, 0, 44) or UDim2.new(1, 0, 0, 38)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 24
    btn.Parent = Sidebar
    btn.LayoutOrder = i
    corner(btn, 10)

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(0,120,160)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.ZIndex = 24
    bg.Parent = btn
    corner(bg, 10)

    local ico = Instance.new("TextLabel")
    ico.BackgroundTransparency = 1
    ico.TextColor3 = CFG.TextMuted
    ico.Font = Enum.Font.GothamBold
    ico.ZIndex = 25
    ico.Parent = btn
    ico.Text = def.icon

    local lbl = nil

    if not isMobile then
        ico.Size = UDim2.new(0, 28, 1, 0)
        ico.Position = UDim2.new(0, 6, 0, 0)
        ico.TextSize = 15
        ico.TextXAlignment = Enum.TextXAlignment.Center

        lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -36, 1, 0)
        lbl.Position = UDim2.new(0, 36, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = def.label
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextColor3 = CFG.TextMuted
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 25
        lbl.Parent = btn
    else
        ico.Size = UDim2.new(1, 0, 1, 0)
        ico.Position = UDim2.new(0, 0, 0, 0)
        ico.TextSize = 18
        ico.TextXAlignment = Enum.TextXAlignment.Center
    end

    -- Упаковываем элементы вкладки в таблицу
    local tabData = {
        button = btn,
        bg = bg,
        icon = ico,
        lbl = lbl,
        id = def.id
    }
    tabButtons[def.id] = tabData

    btn.MouseButton1Click:Connect(function()
        switchPage(def.id, tabData)
    end)

    btn.MouseEnter:Connect(function()
        if tabData ~= activeTab then
            tween(bg, {BackgroundTransparency=0.88}, 0.15)
        end
    end)

    btn.MouseLeave:Connect(function()
        if tabData ~= activeTab then
            tween(bg, {BackgroundTransparency=1}, 0.15)
        end
    end)
end

-- Активируем первую вкладку
switchPage("main", tabButtons["main"])

----------------------------------------------------------------
-- [КОМПОНЕНТЫ КАРТОЧЕК]
----------------------------------------------------------------
local function sectionHeader(parent, text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    f.Parent = parent
    local l = label(f, text, 10, Enum.Font.GothamBold, CFG.TextMuted)
    l.TextXAlignment = Enum.TextXAlignment.Left
    padding(f, 0, 0, 0, 4, 0)
    return f
end

local function card(parent, height, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, height)
    f.BackgroundColor3 = CFG.BgGlass2
    f.BorderSizePixel = 0
    f.LayoutOrder = order or 0
    f.Parent = parent
    corner(f, 10)
    stroke(f, Color3.fromRGB(38, 42, 68), 1, 0)

    local shine = Instance.new("Frame")
    shine.Size = UDim2.new(1, -20, 0, 1)
    shine.Position = UDim2.new(0, 10, 0, 0)
    shine.BackgroundColor3 = Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency = 0.88
    shine.BorderSizePixel = 0
    shine.ZIndex = f.ZIndex+1
    shine.Parent = f
    return f
end

local function toggleCard(parent, iconText, titleText, descText, accentColor, order)
    local c = card(parent, 62, order)
    local isOn = false

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0,36,0,36)
    ico.Position = UDim2.new(0,10,0.5,-18)
    ico.BackgroundColor3 = Color3.fromRGB(18,20,34)
    ico.Text = iconText
    ico.TextSize = 18
    ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = accentColor
    ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.TextYAlignment = Enum.TextYAlignment.Center
    ico.ZIndex = c.ZIndex+2
    ico.Parent = c
    corner(ico, 10)
    stroke(ico, accentColor, 1, 0.3)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-115,0,18)
    title.Position = UDim2.new(0,54,0,12)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = CFG.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = c.ZIndex+2
    title.Parent = c

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1,-115,0,14)
    desc.Position = UDim2.new(0,54,0,32)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextColor3 = CFG.TextMuted
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = c.ZIndex+2
    desc.Parent = c

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 22)
    track.Position = UDim2.new(1,-54,0.5,-11)
    track.BackgroundColor3 = Color3.fromRGB(30,32,50)
    track.BorderSizePixel = 0
    track.ZIndex = c.ZIndex+2
    track.Parent = c
    corner(track, 11)
    stroke(track, Color3.fromRGB(50,54,80), 1)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(140,145,180)
    knob.BorderSizePixel = 0
    knob.ZIndex = c.ZIndex+3
    knob.Parent = track
    corner(knob, 99)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = c.ZIndex+4
    btn.Parent = c

    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            tween(track, {BackgroundColor3 = accentColor}, 0.2)
            tween(knob, {Position=UDim2.new(0,23,0.5,-8), BackgroundColor3=Color3.fromRGB(255,255,255)}, 0.2)
        else
            tween(track, {BackgroundColor3 = Color3.fromRGB(30,32,50)}, 0.2)
            tween(knob, {Position=UDim2.new(0,3,0.5,-8), BackgroundColor3=Color3.fromRGB(140,145,180)}, 0.2)
        end
    end)
    return c
end

local function buttonCard(parent, iconText, titleText, descText, accentColor, order)
    local c = card(parent, 56, order)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0,32,0,32)
    ico.Position = UDim2.new(0,10,0.5,-16)
    ico.BackgroundColor3 = Color3.fromRGB(18,20,34)
    ico.Text = iconText
    ico.TextSize = 15
    ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = accentColor
    ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.TextYAlignment = Enum.TextYAlignment.Center
    ico.ZIndex = c.ZIndex+2
    ico.Parent = c
    corner(ico, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-100,0,18)
    title.Position = UDim2.new(0,50,0,10)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = CFG.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = c.ZIndex+2
    title.Parent = c

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1,-100,0,14)
    desc.Position = UDim2.new(0,50,0,29)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextColor3 = CFG.TextMuted
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = c.ZIndex+2
    desc.Parent = c

    local ab = Instance.new("TextButton")
    ab.Size = UDim2.new(0,54,0,26)
    ab.Position = UDim2.new(1,-64,0.5,-13)
    ab.BackgroundColor3 = accentColor
    ab.Text = "Запуск"
    ab.TextSize = 10
    ab.Font = Enum.Font.GothamBold
    ab.TextColor3 = Color3.fromRGB(5,5,10)
    ab.AutoButtonColor = false
    ab.ZIndex = c.ZIndex+3
    ab.Parent = c
    corner(ab, 7)

    ab.MouseEnter:Connect(function() tween(ab,{BackgroundTransparency=0.25},0.15) end)
    ab.MouseLeave:Connect(function() tween(ab,{BackgroundTransparency=0},0.15) end)
    ab.MouseButton1Click:Connect(function()
        tween(ab,{BackgroundTransparency=0.6},0.08)
        task.delay(0.12, function() tween(ab,{BackgroundTransparency=0},0.15) end)
    end)
    return c
end

local function sliderCard(parent, iconText, titleText, minV, maxV, defaultV, accentColor, order)
    local c = card(parent, 70, order)
    local value = defaultV

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0,28,0,28)
    ico.Position = UDim2.new(0,10,0,10)
    ico.BackgroundColor3 = Color3.fromRGB(18,20,34)
    ico.Text = iconText
    ico.TextSize = 13
    ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = accentColor
    ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.TextYAlignment = Enum.TextYAlignment.Center
    ico.ZIndex = c.ZIndex+2
    ico.Parent = c
    corner(ico, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-90,0,16)
    title.Position = UDim2.new(0,46,0,10)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = CFG.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = c.ZIndex+2
    title.Parent = c

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0,40,0,16)
    valLbl.Position = UDim2.new(1,-46,0,10)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultV)
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextColor3 = accentColor
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = c.ZIndex+2
    valLbl.Parent = c

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1,-20,0,5)
    trackBg.Position = UDim2.new(0,10,0,46)
    trackBg.BackgroundColor3 = Color3.fromRGB(30,32,52)
    trackBg.BorderSizePixel = 0
    trackBg.ZIndex = c.ZIndex+2
    trackBg.Parent = c
    corner(trackBg, 99)

    local trackFill = Instance.new("Frame")
    local fillPct = (defaultV - minV)/(maxV - minV)
    trackFill.Size = UDim2.new(fillPct, 0, 1, 0)
    trackFill.BackgroundColor3 = accentColor
    trackFill.BorderSizePixel = 0
    trackFill.ZIndex = c.ZIndex+3
    trackFill.Parent = trackBg
    corner(trackFill, 99)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0,14,0,14)
    thumb.Position = UDim2.new(fillPct, -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = c.ZIndex+4
    thumb.Parent = trackBg
    corner(thumb, 99)
    stroke(thumb, accentColor, 2)

    local draggingSlider = false
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1,0,0,24)
    sliderBtn.Position = UDim2.new(0,0,0,-10)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = c.ZIndex+5
    sliderBtn.Parent = trackBg

    local function updateSlider(absX)
        local tbPos = trackBg.AbsolutePosition.X
        local tbSz = trackBg.AbsoluteSize.X
        local pct = math.clamp((absX - tbPos)/tbSz, 0, 1)
        value = math.floor(minV + (maxV-minV)*pct)
        valLbl.Text = tostring(value)
        trackFill.Size = UDim2.new(pct,0,1,0)
        thumb.Position = UDim2.new(pct,-7,0.5,-7)
    end

    sliderBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(inp.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if draggingSlider and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(inp.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    return c
end

local function dropdownCard(parent, iconText, titleText, options, accentColor, order)
    local c = card(parent, 58, order)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0,30,0,30)
    ico.Position = UDim2.new(0,10,0.5,-15)
    ico.BackgroundColor3 = Color3.fromRGB(18,20,34)
    ico.Text = iconText
    ico.TextSize = 14
    ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = accentColor
    ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.TextYAlignment = Enum.TextYAlignment.Center
    ico.ZIndex = c.ZIndex+2
    ico.Parent = c
    corner(ico, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.45,0,1,0)
    title.Position = UDim2.new(0,48,0,0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = CFG.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = c.ZIndex+2
    title.Parent = c

    local dropBox = Instance.new("Frame")
    dropBox.Size = UDim2.new(0, 110, 0, 28)
    dropBox.Position = UDim2.new(1,-120,0.5,-14)
    dropBox.BackgroundColor3 = Color3.fromRGB(18,20,34)
    dropBox.BorderSizePixel = 0
    dropBox.ZIndex = c.ZIndex+2
    dropBox.Parent = c
    corner(dropBox, 7)
    stroke(dropBox, Color3.fromRGB(50,54,80), 1)

    local selectedIdx = 1
    local selLabel = Instance.new("TextLabel")
    selLabel.Size = UDim2.new(1,-24,1,0)
    selLabel.Position = UDim2.new(0,8,0,0)
    selLabel.BackgroundTransparency = 1
    selLabel.Text = options[1] or "—"
    selLabel.TextSize = 11
    selLabel.Font = Enum.Font.GothamSemibold
    selLabel.TextColor3 = CFG.TextPrimary
    selLabel.TextXAlignment = Enum.TextXAlignment.Left
    selLabel.ZIndex = c.ZIndex+3
    selLabel.Parent = dropBox

    local arr = Instance.new("TextLabel")
    arr.Size = UDim2.new(0,20,1,0)
    arr.Position = UDim2.new(1,-22,0,0)
    arr.BackgroundTransparency = 1
    arr.Text = "▾"
    arr.TextSize = 11
    arr.Font = Enum.Font.GothamBold
    arr.TextColor3 = accentColor
    arr.ZIndex = c.ZIndex+3
    arr.Parent = dropBox

    local db = Instance.new("TextButton")
    db.Size = UDim2.new(1,0,1,0)
    db.BackgroundTransparency = 1
    db.Text = ""
    db.ZIndex = c.ZIndex+4
    db.Parent = dropBox

    db.MouseButton1Click:Connect(function()
        selectedIdx = selectedIdx % #options + 1
        selLabel.Text = options[selectedIdx]
        tween(arr, {Rotation = arr.Rotation == 0 and 180 or 0}, 0.2)
    end)

    return c
end

----------------------------------------------------------------
-- [НАПОЛНЕНИЕ СТРАНИЦ]
----------------------------------------------------------------
sectionHeader(PgMain, "◈ БЫСТРЫЙ ОБЗОР", 1)
local statRow = Instance.new("Frame")
statRow.Size = UDim2.new(1,0,0,66)
statRow.BackgroundTransparency = 1
statRow.LayoutOrder = 2
statRow.Parent = PgMain

local statList = Instance.new("UIListLayout")
statList.Parent = statRow
statList.FillDirection = Enum.FillDirection.Horizontal
statList.Padding = UDim.new(0,6)
statList.SortOrder = Enum.SortOrder.LayoutOrder

local statDefs = {
    {icon="⚡",label="Модулей", val="5", color=CFG.Accent},
    {icon="🎯",label="Активных", val="0", color=CFG.Green},
    {icon="🔒",label="Статус", val="OK", color=CFG.Yellow},
}

for i, sd in ipairs(statDefs) do
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(0.328,0,1,0)
    sf.BackgroundColor3 = CFG.BgGlass2
    sf.BorderSizePixel = 0
    sf.LayoutOrder = i
    sf.Parent = statRow
    corner(sf, 10)
    stroke(sf, Color3.fromRGB(38,42,68), 1)

    local sico = Instance.new("TextLabel")
    sico.Size = UDim2.new(1,0,0,26)
    sico.Position = UDim2.new(0,0,0,6)
    sico.BackgroundTransparency = 1
    sico.Text = sd.icon
    sico.TextSize = 18
    sico.Font = Enum.Font.GothamBold
    sico.TextXAlignment = Enum.TextXAlignment.Center
    sico.ZIndex = sf.ZIndex+1
    sico.Parent = sf

    local sval = Instance.new("TextLabel")
    sval.Size = UDim2.new(1,0,0,16)
    sval.Position = UDim2.new(0,0,0,32)
    sval.BackgroundTransparency = 1
    sval.Text = sd.val
    sval.TextSize = 14
    sval.Font = Enum.Font.GothamBlack
    sval.TextColor3 = sd.color
    sval.TextXAlignment = Enum.TextXAlignment.Center
    sval.ZIndex = sf.ZIndex+1
    sval.Parent = sf

    local slbl = Instance.new("TextLabel")
    slbl.Size = UDim2.new(1,0,0,12)
    slbl.Position = UDim2.new(0,0,0,49)
    slbl.BackgroundTransparency = 1
    slbl.Text = sd.label
    slbl.TextSize = 9
    slbl.Font = Enum.Font.Gotham
    slbl.TextColor3 = CFG.TextMuted
    slbl.TextXAlignment = Enum.TextXAlignment.Center
    slbl.ZIndex = sf.ZIndex+1
    slbl.Parent = sf
end

sectionHeader(PgMain, "◈ БЫСТРЫЕ ДЕЙСТВИЯ", 3)
toggleCard(PgMain, "🔔", "Уведомления", "Показывать системные сообщения", CFG.Accent, 4)
buttonCard(PgMain, "🔄", "Обновить хаб", "Перезагрузить все модули", CFG.Yellow, 5)
buttonCard(PgMain, "📋", "Копировать лог", "Экспорт журнала событий", CFG.Purple, 6)

sectionHeader(PgCombat, "◈ ЦЕЛЬ И АИМ", 1)
toggleCard(PgCombat, "🎯", "Aimbot", "Автоматическое наведение на цель", CFG.Red, 2)
toggleCard(PgCombat, "🔫", "Silent Aim", "Скрытый aimbot без видимой цели", CFG.Red, 3)
sliderCard(PgCombat, "📐", "FOV прицела", 1, 360, 90, CFG.Red, 4)
sliderCard(PgCombat, "🚀", "Smoothness", 1, 100, 50, CFG.Orange or CFG.Yellow, 5)

sectionHeader(PgCombat, "◈ АТАКА", 6)
toggleCard(PgCombat, "💥", "Infinite Ammo", "Бесконечные патроны", CFG.Yellow, 7)
toggleCard(PgCombat, "⚡", "Rapid Fire", "Максимальная скорострельность", CFG.Yellow, 8)
dropdownCard(PgCombat, "🎯","Часть тела", {"Голова","Грудь","Шея","Торс"}, CFG.Red, 9)

sectionHeader(PgVisuals, "◈ ESP", 1)
toggleCard(PgVisuals, "📦", "ESP Boxes", "Рамки вокруг игроков", CFG.Purple, 2)
toggleCard(PgVisuals, "↗️", "ESP Tracers", "Линии трассировки до игроков", CFG.Purple, 3)
toggleCard(PgVisuals, "🏷️", "ESP Имена", "Имена игроков в пространстве", CFG.Purple, 4)
toggleCard(PgVisuals, "❤️", "ESP Здоровье", "Полоска здоровья над головой", CFG.Red, 5)

sectionHeader(PgVisuals, "◈ МИРОВЫЕ ЭФФЕКТЫ", 6)
toggleCard(PgVisuals, "🌟", "Full Bright", "Максимальная яркость карты", CFG.Yellow, 7)
toggleCard(PgVisuals, "🌈", "Rainbow Noclip", "Визуальный эффект прозрачности", CFG.Accent, 8)
dropdownCard(PgVisuals,"🎨","Цвет ESP", {"Голубой","Красный","Зелёный","Белый"}, CFG.Purple, 9)

sectionHeader(PgPlayer, "◈ ДВИЖЕНИЕ", 1)
toggleCard(PgPlayer, "🏃", "Speed Hack", "Увеличенная скорость бега", CFG.Green, 2)
sliderCard(PgPlayer, "⚡", "WalkSpeed", 1, 500, 16, CFG.Green, 3)
toggleCard(PgPlayer, "🦘", "High Jump", "Увеличенная высота прыжка", CFG.Accent, 4)
sliderCard(PgPlayer, "↑", "JumpPower", 1, 500, 50, CFG.Accent, 5)

sectionHeader(PgPlayer, "◈ ФИЗИКА", 6)
toggleCard(PgPlayer, "👻", "Noclip", "Полёт сквозь стены", CFG.Yellow, 7)
toggleCard(PgPlayer, "🕊️", "Anti-Gravity", "Уменьшение гравитации", CFG.Purple, 8)
sliderCard(PgPlayer, "🌍", "Gravity", 0, 200, 100, CFG.Purple, 9)

sectionHeader(PgMisc, "◈ СИСТЕМА", 1)
buttonCard(PgMisc, "🔑", "Получить ключ", "Запрос лицензионного ключа", CFG.Yellow, 2)
buttonCard(PgMisc, "📡", "Проверить VPN", "Тест соединения и анонимности", CFG.Green, 3)
buttonCard(PgMisc, "🗑️", "Сброс настроек", "Вернуть все значения по умолчанию", CFG.Red, 4)

sectionHeader(PgMisc, "◈ ИНТЕРФЕЙС", 5)
dropdownCard(PgMisc, "🎨","Тема оформления", {"Cyan","Purple","Red","Green"}, CFG.Accent, 6)
toggleCard(PgMisc, "✨", "Партиклы", "Фоновые анимированные частицы", CFG.Purple, 7)
toggleCard(PgMisc, "📌", "Плавающая кнопка","Кнопка открытия хаба", CFG.Accent, 8)

----------------------------------------------------------------
-- [НИЖНЯЯ ПАНЕЛЬ СТАТУСА]
----------------------------------------------------------------
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, -SidebarW-1, 0, 28)
Footer.Position = UDim2.new(0, SidebarW+1, 1, -28)
Footer.BackgroundColor3 = CFG.BgGlass
Footer.BorderSizePixel = 0
Footer.ZIndex = 22
Footer.Parent = MainFrame

local FooterStroke = Instance.new("UIStroke")
FooterStroke.Color = Color3.fromRGB(35,38,62)
FooterStroke.Thickness = 1
FooterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FooterStroke.Parent = Footer

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(0.6,0,1,0)
FooterText.Position = UDim2.new(0,10,0,0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Nexus Hub • Build 2024.12"
FooterText.TextSize = 9
FooterText.Font = Enum.Font.Gotham
FooterText.TextColor3 = CFG.TextMuted
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.ZIndex = 23
FooterText.Parent = Footer

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0.4,0,1,0)
PingLabel.Position = UDim2.new(0.6,0,0,0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "ping: — ms"
PingLabel.TextSize = 9
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextColor3 = CFG.Green
PingLabel.TextXAlignment = Enum.TextXAlignment.Right
PingLabel.ZIndex = 23
PingLabel.Parent = Footer
padding(Footer, 0,0,0,0,10)

task.spawn(function()
    while task.wait(2) do
        local ok, p = pcall(function()
            return Players.LocalPlayer:GetNetworkPing and math.floor(Players.LocalPlayer:GetNetworkPing()*1000) or 0
        end)
        local ms = ok and p or 0
        PingLabel.Text = "ping: "..ms.." ms"
        PingLabel.TextColor3 = ms < 80 and CFG.Green or ms < 150 and CFG.Yellow or CFG.Red
    end
end)

----------------------------------------------------------------
-- [ЛОГИКА КНОПОК УПРАВЛЕНИЯ ОКНОМ]
----------------------------------------------------------------
local isOpen = false
local isMinimized = false

local function openHub()
    isOpen = true
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5,0,0.5,0)

    tween(MainFrame, {
        Size = UDim2.new(0,W,0,H),
        Position = UDim2.new(0.5,-W/2,0.5,-H/2)
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    tween(FB, {BackgroundTransparency=1}, 0.2)
    task.delay(0.25, function() FB.Visible = false end)
end

local function closeHub()
    isOpen = false
    tween(MainFrame, {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0)
    }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

    task.delay(0.3, function()
        MainFrame.Visible = false
        FB.Visible = true
        tween(FB, {BackgroundTransparency=0}, 0.2)
    end)
end

FB.MouseButton1Click:Connect(openHub)
CloseBtn.MouseButton1Click:Connect(closeHub)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        tween(MainFrame, {Size=UDim2.new(0,W,0,52)}, 0.3, Enum.EasingStyle.Quart)
    else
        tween(MainFrame, {Size=UDim2.new(0,W,0,H)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

task.delay(0.5, openHub)

----------------------------------------------------------------
-- [АНИМАЦИЯ ЧАСТИЦ ФОНА ПО ОТКРЫТИЮ]
----------------------------------------------------------------
local function burstParticles()
    for i = 1, 8 do
        task.delay(i*0.04, function()
            local vp = workspace.CurrentCamera.ViewportSize
            local p = Instance.new("Frame")
            p.Size = UDim2.new(0,4,0,4)
            p.Position = UDim2.new(0.5, math.random(-20,20), 0.5, math.random(-20,20))
            p.BackgroundColor3 = i%2==0 and CFG.Accent or CFG.Purple
            p.BackgroundTransparency = 0.3
            p.BorderSizePixel = 0
            p.ZIndex = 5
            corner(p, 99)
            p.Parent = ScreenGui

            tween(p, {
                Position = UDim2.new(
                    0.5 + (math.random()-0.5)*0.4, 0,
                    0.5 + (math.random()-0.5)*0.4, 0
                ),
                BackgroundTransparency = 1,
                Size = UDim2.new(0,1,0,1)
            }, 0.6, Enum.EasingStyle.Quad)

            task.delay(0.65, function() p:Destroy() end)
        end)
    end
end

FB.MouseButton1Click:Connect(burstParticles)
