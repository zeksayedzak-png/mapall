-- =====================================================
-- 🗺️ Map M.R Hub - Ultimate Roblox Developer Tool
-- 🔧 Professional Explorer & Debugging Suite
-- ⚡ Version 1.0 - Core + Explorer Tab
-- =====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- =====================================================
-- المتغيرات العامة
-- =====================================================
local currentStack = {}
local currentParent = game
local selectedObject = nil
local teleportHistory = {}
local teleportIndex = 0
local xrayEnabled = false
local xrayObjects = {}

-- UI References
local mainFrame, titleBar, contentFrame, tabsFrame
local explorerTab, remoteTab, mopTab
local isMinimized = false
local originalSize, originalPos

-- =====================================================
-- 🎨 نظام الألوان
-- =====================================================
local Colors = {
    Background = Color3.fromRGB(10, 10, 15),
    Surface = Color3.fromRGB(20, 20, 30),
    SurfaceHover = Color3.fromRGB(30, 30, 45),
    Accent = Color3.fromRGB(0, 150, 255),
    AccentLight = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(240, 240, 250),
    TextDim = Color3.fromRGB(160, 160, 180),
    Success = Color3.fromRGB(0, 200, 100),
    Danger = Color3.fromRGB(255, 60, 60),
    Warning = Color3.fromRGB(255, 180, 0),
    Xray = Color3.fromRGB(255, 50, 50)
}

-- =====================================================
-- 🛠️ دوال مساعدة
-- =====================================================

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Accent
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad), props):Play()
end

-- =====================================================
-- 🖱️ نظام السحب المتقدم
-- =====================================================
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- =====================================================
-- 🏠 إنشاء الواجهة الرئيسية
-- =====================================================
local function createMainUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MapMRHub"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- الإطار الرئيسي
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.1, 0)
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    createCorner(mainFrame, 16)
    createStroke(mainFrame, Colors.Accent, 2)

    originalSize = mainFrame.Size
    originalPos = mainFrame.Position

    -- شريط العنوان
    titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Colors.Surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    createCorner(titleBar, 12)

    -- عنوان "Map M.R Hub"
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🗺️ Map M.R Hub"
    titleLabel.TextColor3 = Colors.AccentLight
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- زر التصغير (يسار)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(0, 5, 0, 5)
    minimizeBtn.BackgroundColor3 = Colors.SurfaceHover
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Colors.Text
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20
    minimizeBtn.Parent = titleBar
    createCorner(minimizeBtn, 8)

    -- زر الإغلاق (يمين)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.BackgroundColor3 = Colors.Danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    createCorner(closeBtn, 8)

    -- منطقة التبويبات
    tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "TabsFrame"
    tabsFrame.Size = UDim2.new(1, -20, 0, 40)
    tabsFrame.Position = UDim2.new(0, 10, 0, 50)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = mainFrame

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.Padding = UDim.new(0, 8)
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsLayout.Parent = tabsFrame

    -- منطقة المحتوى
    contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 95)
    contentFrame.BackgroundColor3 = Colors.Surface
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    createCorner(contentFrame, 12)

    -- =====================================================
    -- 🎯 نظام التصغير/التكبير
    -- =====================================================
    local miniButton = nil

    minimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            -- تصغير
            isMinimized = true
            tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
            task.delay(0.3, function()
                mainFrame.Visible = false
                
                -- إنشاء زر التعويم (M)
                miniButton = Instance.new("TextButton")
                miniButton.Name = "MiniMButton"
                miniButton.Size = UDim2.new(0, 50, 0, 50)
                miniButton.Position = UDim2.new(0.5, -25, 0.5, -25)
                miniButton.BackgroundColor3 = Colors.Accent
                miniButton.Text = "M"
                miniButton.TextColor3 = Colors.Text
                miniButton.Font = Enum.Font.GothamBold
                miniButton.TextSize = 24
                miniButton.Parent = screenGui
                createCorner(miniButton, 12)
                createStroke(miniButton, Colors.AccentLight, 2)
                
                -- تأثير التلألؤ
                local glow = Instance.new("ImageLabel")
                glow.Name = "Glow"
                glow.Size = UDim2.new(1.5, 0, 1.5, 0)
                glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
                glow.BackgroundTransparency = 1
                glow.Image = "rbxassetid://5028857084"
                glow.ImageColor3 = Colors.AccentLight
                glow.ImageTransparency = 0.7
                glow.Parent = miniButton
                
                -- animation loop
                spawn(function()
                    while miniButton and miniButton.Parent do
                        tween(glow, {ImageTransparency = 0.3}, 1)
                        task.wait(1)
                        tween(glow, {ImageTransparency = 0.7}, 1)
                        task.wait(1)
                    end
                end)
                
                makeDraggable(miniButton)
                
                miniButton.MouseButton1Click:Connect(function()
                    isMinimized = false
                    miniButton:Destroy()
                    mainFrame.Visible = true
                    tween(mainFrame, {Size = originalSize, Position = originalPos}, 0.3)
                end)
            end)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    makeDraggable(mainFrame, titleBar)
end

-- =====================================================
-- 📂 تبويب المسارات (Explorer)
-- =====================================================
local function createExplorerTab()
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "ExplorerTab"
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.BackgroundColor3 = Colors.Accent
    tabBtn.Text = "📂 مسارات"
    tabBtn.TextColor3 = Colors.Text
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.Parent = tabsFrame
    createCorner(tabBtn, 8)

    -- محتوى التبويب
    local explorerContent = Instance.new("Frame")
    explorerContent.Name = "ExplorerContent"
    explorerContent.Size = UDim2.new(1, 0, 1, 0)
    explorerContent.BackgroundTransparency = 1
    explorerContent.Parent = contentFrame

    -- شريط البحث
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -20, 0, 35)
    searchBox.Position = UDim2.new(0, 10, 0, 10)
    searchBox.BackgroundColor3 = Colors.Background
    searchBox.Text = "🔍 ابحث عن مسار..."
    searchBox.TextColor3 = Colors.TextDim
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 13
    searchBox.ClearTextOnFocus = true
    searchBox.Parent = explorerContent
    createCorner(searchBox, 8)

    -- منطقة التمرير
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ExplorerScroll"
    scrollFrame.Size = UDim2.new(1, -20, 1, -100)
    scrollFrame.Position = UDim2.new(0, 10, 0, 55)
    scrollFrame.BackgroundColor3 = Colors.Background
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Colors.Accent
    scrollFrame.Parent = explorerContent
    createCorner(scrollFrame, 10)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = scrollFrame

    -- شريط المسار الحالي
    local pathBar = Instance.new("TextLabel")
    pathBar.Name = "PathBar"
    pathBar.Size = UDim2.new(1, -20, 0, 30)
    pathBar.Position = UDim2.new(0, 10, 1, -35)
    pathBar.BackgroundColor3 = Colors.SurfaceHover
    pathBar.Text = "📍 game"
    pathBar.TextColor3 = Colors.AccentLight
    pathBar.Font = Enum.Font.GothamBold
    pathBar.TextSize = 11
    pathBar.TextXAlignment = Enum.TextXAlignment.Left
    pathBar.TextTruncate = Enum.TextTruncate.AtEnd
    pathBar.Parent = explorerContent
    createCorner(pathBar, 6)

    -- زر الرجوع
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackBtn"
    backBtn.Size = UDim2.new(0, 80, 0, 30)
    backBtn.Position = UDim2.new(1, -90, 1, -35)
    backBtn.BackgroundColor3 = Colors.SurfaceHover
    backBtn.Text = "🔙 رجوع"
    backBtn.TextColor3 = Colors.Text
    backBtn.Font = Enum.Font.GothamBold
    backBtn.TextSize = 11
    backBtn.Parent = explorerContent
    createCorner(backBtn, 6)

    -- =====================================================
    -- 🎯 عرض العناصر
    -- =====================================================
    local function getIcon(className)
        local icons = {
            RemoteEvent = "📡",
            RemoteFunction = "⚙️",
            Script = "📜",
            LocalScript = "📄",
            ModuleScript = "📦",
            Part = "🧱",
            MeshPart = "🔷",
            UnionOperation = "⛓️",
            Folder = "📁",
            Model = "🗿",
            Tool = "🔧",
            IntValue = "🔢",
            StringValue = "📝",
            BoolValue = "✅",
            NumberValue = "💎",
            ObjectValue = "🔗",
            Humanoid = "👤",
            BasePart = "📐",
            Camera = "📷",
            Sound = "🔊",
            ParticleEmitter = "✨",
            BillboardGui = "🎭",
            ScreenGui = "🖥️",
            Frame = "⬜",
            TextButton = "🔘",
            TextLabel = "🏷️",
            ImageLabel = "🖼️",
            SpawnLocation = "🚀",
            Decal = "🎨",
            Texture = "🧩"
        }
        return icons[className] or "📦"
    end

    local function getTypeColor(className)
        if className:find("Remote") then return Colors.Warning end
        if className:find("Script") then return Color3.fromRGB(100, 255, 150) end
        if className:find("Value") then return Colors.AccentLight end
        if className == "Part" or className == "MeshPart" then return Color3.fromRGB(255, 180, 100) end
        return Colors.TextDim
    end

    local function renderExplorer(parentObj, filter)
        -- مسح القديم
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local children = parentObj:GetChildren()
        
        -- تجميع المتشابه
        local groups = {}
        for _, obj in ipairs(children) do
            if filter and not obj.Name:lower():find(filter:lower()) then continue end
            
            local key = obj.ClassName .. "|" .. obj.Name
            if not groups[key] then
                groups[key] = {count = 0, example = obj, objects = {}}
            end
            groups[key].count = groups[key].count + 1
            table.insert(groups[key].objects, obj)
        end

        -- عرض المجموعات
        for key, data in pairs(groups) do
            local obj = data.example
            local count = data.count

            local card = Instance.new("Frame")
            card.Name = "ItemCard"
            card.Size = UDim2.new(1, -10, 0, 80)
            card.BackgroundColor3 = Colors.SurfaceHover
            card.Parent = scrollFrame
            createCorner(card, 10)

            -- أيقونة
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 30, 0, 30)
            icon.Position = UDim2.new(0, 8, 0, 8)
            icon.BackgroundTransparency = 1
            icon.Text = getIcon(obj.ClassName)
            icon.TextSize = 20
            icon.Parent = card

            -- الاسم
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -280, 0, 22)
            nameLabel.Position = UDim2.new(0, 45, 0, 6)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = obj.Name .. (count > 1 and " (" .. count .. ")" or "")
            nameLabel.TextColor3 = Colors.Text
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = card

            -- النوع
            local typeLabel = Instance.new("TextLabel")
            typeLabel.Size = UDim2.new(1, -280, 0, 18)
            typeLabel.Position = UDim2.new(0, 45, 0, 28)
            typeLabel.BackgroundTransparency = 1
            typeLabel.Text = obj.ClassName
            typeLabel.TextColor3 = getTypeColor(obj.ClassName)
            typeLabel.Font = Enum.Font.Gotham
            typeLabel.TextSize = 10
            typeLabel.TextXAlignment = Enum.TextXAlignment.Left
            typeLabel.Parent = card

            -- المسار المختصر
            local shortPath = Instance.new("TextLabel")
            shortPath.Size = UDim2.new(1, -280, 0, 18)
            shortPath.Position = UDim2.new(0, 45, 0, 48)
            shortPath.BackgroundTransparency = 1
            shortPath.Text = obj:GetFullName():sub(1, 50) .. (obj:GetFullName():len() > 50 and "..." or "")
            shortPath.TextColor3 = Colors.TextDim
            shortPath.Font = Enum.Font.Gotham
            shortPath.TextSize = 9
            shortPath.TextXAlignment = Enum.TextXAlignment.Left
            shortPath.TextTruncate = Enum.TextTruncate.AtEnd
            shortPath.Parent = card

            -- زر Xray (أحمر)
            local xrayBtn = Instance.new("TextButton")
            xrayBtn.Name = "XrayBtn"
            xrayBtn.Size = UDim2.new(0, 45, 0, 28)
            xrayBtn.Position = UDim2.new(1, -155, 0, 8)
            xrayBtn.BackgroundColor3 = Colors.Xray
            xrayBtn.Text = "👁️"
            xrayBtn.TextColor3 = Colors.Text
            xrayBtn.Font = Enum.Font.GothamBold
            xrayBtn.TextSize = 14
            xrayBtn.Parent = card
            createCorner(xrayBtn, 6)

            -- زر النسخ
            local copyBtn = Instance.new("TextButton")
            copyBtn.Name = "CopyBtn"
            copyBtn.Size = UDim2.new(0, 45, 0, 28)
            copyBtn.Position = UDim2.new(1, -105, 0, 8)
            copyBtn.BackgroundColor3 = Colors.Surface
            copyBtn.Text = "📋"
            copyBtn.TextColor3 = Colors.Text
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 14
            copyBtn.Parent = card
            createCorner(copyBtn, 6)

            -- زر الدخول
            local hasChildren = #obj:GetChildren() > 0
            local enterBtn = Instance.new("TextButton")
            enterBtn.Name = "EnterBtn"
            enterBtn.Size = UDim2.new(0, 55, 0, 28)
            enterBtn.Position = UDim2.new(1, -55, 0, 8)
            enterBtn.BackgroundColor3 = hasChildren and Colors.Accent or Colors.Surface
            enterBtn.Text = hasChildren and "🔽 دخول" or "🚫"
            enterBtn.TextColor3 = Colors.Text
            enterBtn.Font = Enum.Font.GothamBold
            enterBtn.TextSize = 10
            enterBtn.Parent = card
            createCorner(enterBtn, 6)

            -- =====================================================
            -- ⚡ وظائف الأزرار
            -- =====================================================
            
            -- Xray: إظهار/إخفاء
            xrayBtn.MouseButton1Click:Connect(function()
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    if xrayObjects[obj] then
                        -- إلغاء Xray
                        if obj:IsA("BasePart") then
                            obj.Transparency = xrayObjects[obj]
                        elseif obj:IsA("Model") then
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") and xrayObjects[obj] and xrayObjects[obj][part] then
                                    part.Transparency = xrayObjects[obj][part]
                                end
                            end
                        end
                        xrayObjects[obj] = nil
                        xrayBtn.BackgroundColor3 = Colors.Xray
                    else
                        -- تفعيل Xray
                        if obj:IsA("BasePart") then
                            xrayObjects[obj] = obj.Transparency
                            obj.Transparency = 0.5
                            local hl = Instance.new("Highlight")
                            hl.Name = "MRHubXray"
                            hl.FillColor = Colors.Xray
                            hl.OutlineColor = Colors.Xray
                            hl.Parent = obj
                        elseif obj:IsA("Model") then
                            xrayObjects[obj] = {}
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    xrayObjects[obj][part] = part.Transparency
                                    part.Transparency = 0.5
                                end
                            end
                            local hl = Instance.new("Highlight")
                            hl.Name = "MRHubXray"
                            hl.FillColor = Colors.Xray
                            hl.OutlineColor = Colors.Xray
                            hl.Parent = obj
                        end
                        xrayBtn.BackgroundColor3 = Colors.Success
                    end
                else
                    xrayBtn.Text = "❌"
                    task.delay(0.5, function()
                        if xrayBtn then xrayBtn.Text = "👁️" end
                    end)
                end
            end)

            -- نسخ المسار
            copyBtn.MouseButton1Click:Connect(function()
                local fullPath = obj:GetFullName()
                if setclipboard then
                    setclipboard(fullPath)
                end
                copyBtn.Text = "✅"
                copyBtn.BackgroundColor3 = Colors.Success
                task.delay(1.2, function()
                    if copyBtn and copyBtn.Parent then
                        copyBtn.Text = "📋"
                        copyBtn.BackgroundColor3 = Colors.Surface
                    end
                end)
            end)

            -- الدخول للداخل
            if hasChildren then
                enterBtn.MouseButton1Click:Connect(function()
                    table.insert(currentStack, currentParent)
                    currentParent = obj
                    renderExplorer(currentParent)
                    pathBar.Text = "📍 " .. obj:GetFullName()
                end)
            end
        end

        -- تحديث التمرير
        task.defer(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end)
    end

    -- زر الرجوع
    backBtn.MouseButton1Click:Connect(function()
        if #currentStack > 0 then
            currentParent = table.remove(currentStack)
            renderExplorer(currentParent)
            pathBar.Text = "📍 " .. currentParent:GetFullName()
        end
    end)

    -- البحث
    searchBox.FocusLost:Connect(function()
        if searchBox.Text ~= "" and searchBox.Text ~= "🔍 ابحث عن مسار..." then
            renderExplorer(currentParent, searchBox.Text)
        else
            renderExplorer(currentParent)
        end
    end)

    -- التشغيل الأولي
    renderExplorer(game)
    pathBar.Text = "📍 game"

    return explorerContent
end

-- =====================================================
-- 📡 تبويب الريموتي (Remote Events)
-- =====================================================
local function createRemoteTab()
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "RemoteTab"
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.BackgroundColor3 = Colors.SurfaceHover
    tabBtn.Text = "📡 ريموتي"
    tabBtn.TextColor3 = Colors.Text
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.Parent = tabsFrame
    createCorner(tabBtn, 8)

    local remoteContent = Instance.new("Frame")
    remoteContent.Name = "RemoteContent"
    remoteContent.Size = UDim2.new(1, 0, 1, 0)
    remoteContent.BackgroundTransparency = 1
    remoteContent.Visible = false
    remoteContent.Parent = contentFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "📡 الريموتات النشطة"
    title.TextColor3 = Colors.AccentLight
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = remoteContent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 45)
    scrollFrame.BackgroundColor3 = Colors.Background
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.Parent = remoteContent
    createCorner(scrollFrame, 10)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = scrollFrame

    local function scanRemotes()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local remotes = {}
        
        local function scan(parent)
            for _, obj in pairs(parent:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotes, obj)
                end
            end
        end
        
        scan(game)

        for _, remote in ipairs(remotes) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -10, 0, 70)
            card.BackgroundColor3 = Colors.SurfaceHover
            card.Parent = scrollFrame
            createCorner(card, 10)

            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 30, 0, 30)
            icon.Position = UDim2.new(0, 8, 0, 8)
            icon.BackgroundTransparency = 1
            icon.Text = remote:IsA("RemoteEvent") and "📡" or "⚙️"
            icon.TextSize = 20
            icon.Parent = card

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -220, 0, 20)
            nameLabel.Position = UDim2.new(0, 45, 0, 6)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = remote.Name
            nameLabel.TextColor3 = Colors.Text
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = card

            local pathLabel = Instance.new("TextLabel")
            pathLabel.Size = UDim2.new(1, -220, 0, 18)
            pathLabel.Position = UDim2.new(0, 45, 0, 26)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text = remote:GetFullName()
            pathLabel.TextColor3 = Colors.TextDim
            pathLabel.Font = Enum.Font.Gotham
            pathLabel.TextSize = 9
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
            pathLabel.Parent = card

            local typeLabel = Instance.new("TextLabel")
            typeLabel.Size = UDim2.new(1, -220, 0, 16)
            typeLabel.Position = UDim2.new(0, 45, 0, 46)
            typeLabel.BackgroundTransparency = 1
            typeLabel.Text = remote:IsA("RemoteEvent") and "RemoteEvent (One-way)" or "RemoteFunction (Two-way)"
            typeLabel.TextColor3 = Colors.Warning
            typeLabel.Font = Enum.Font.Gotham
            typeLabel.TextSize = 9
            typeLabel.TextXAlignment = Enum.TextXAlignment.Left
            typeLabel.Parent = card

            -- زر الاستدعاء
            local fireBtn = Instance.new("TextButton")
            fireBtn.Size = UDim2.new(0, 55, 0, 28)
            fireBtn.Position = UDim2.new(1, -120, 0, 8)
            fireBtn.BackgroundColor3 = Colors.Accent
            fireBtn.Text = "🔥 استدعاء"
            fireBtn.TextColor3 = Colors.Text
            fireBtn.Font = Enum.Font.GothamBold
            fireBtn.TextSize = 9
            fireBtn.Parent = card
            createCorner(fireBtn, 6)

            -- زر النسخ
            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.new(0, 45, 0, 28)
            copyBtn.Position = UDim2.new(1, -60, 0, 8)
            copyBtn.BackgroundColor3 = Colors.Surface
            copyBtn.Text = "📋"
            copyBtn.TextColor3 = Colors.Text
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 14
            copyBtn.Parent = card
            createCorner(copyBtn, 6)

            -- استدعاء الريموت
            fireBtn.MouseButton1Click:Connect(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    fireBtn.Text = "✅ تم"
                elseif remote:IsA("RemoteFunction") then
                    local success = pcall(function()
                        remote:InvokeServer()
                    end)
                    fireBtn.Text = success and "✅ تم" or "❌ خطأ"
                end
                fireBtn.BackgroundColor3 = Colors.Success
                task.delay(1.5, function()
                    if fireBtn and fireBtn.Parent then
                        fireBtn.Text = "🔥 استدعاء"
                        fireBtn.BackgroundColor3 = Colors.Accent
                    end
                end)
            end)

            -- نسخ
            copyBtn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(remote:GetFullName())
                end
                copyBtn.Text = "✅"
                task.delay(1, function()
                    if copyBtn then copyBtn.Text = "📋" end
                end)
            end)
        end

        task.defer(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end)
    end

    -- زر إعادة الفحص
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 100, 0, 28)
    refreshBtn.Position = UDim2.new(1, -110, 0, 10)
    refreshBtn.BackgroundColor3 = Colors.SurfaceHover
    refreshBtn.Text = "🔄 إعادة فحص"
    refreshBtn.TextColor3 = Colors.Text
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 11
    refreshBtn.Parent = remoteContent
    createCorner(refreshBtn, 6)

    refreshBtn.MouseButton1Click:Connect(scanRemotes)
    scanRemotes()

    return remoteContent
end

-- =====================================================
-- 🎯 تبويب Mop & NPC & Part (Selector + Teleport)
-- =====================================================
local function createMopTab()
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "MopTab"
    tabBtn.Size = UDim2.new(0, 140, 1, 0)
    tabBtn.BackgroundColor3 = Colors.SurfaceHover
    tabBtn.Text = "🎯 Mop&NPC"
    tabBtn.TextColor3 = Colors.Text
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.Parent = tabsFrame
    createCorner(tabBtn, 8)

    local mopContent = Instance.new("Frame")
    mopContent.Name = "MopContent"
    mopContent.Size = UDim2.new(1, 0, 1, 0)
    mopContent.BackgroundTransparency = 1
    mopContent.Visible = false
    mopContent.Parent = contentFrame

    -- زر التفعيل ON/OFF
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Position = UDim2.new(0.5, -60, 0, 10)
    toggleBtn.BackgroundColor3 = Colors.Danger
    toggleBtn.Text = "⚡ OFF"
    toggleBtn.TextColor3 = Colors.Text
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = mopContent
    createCorner(toggleBtn, 10)

    -- حالة التفعيل
    local selectorActive = false

    -- النص التوضيحي
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 50)
    infoLabel.Position = UDim2.new(0, 10, 0, 55)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "🔧 اضغط ON ثم انقر على أي شيء في اللعبة\nلتحديده ونسخ مساره"
    infoLabel.TextColor3 = Colors.TextDim
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 11
    infoLabel.TextWrapped = true
    infoLabel.Parent = mopContent

    -- اسم الشيء المختار
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -20, 0, 30)
    selectedLabel.Position = UDim2.new(0, 10, 0, 110)
    selectedLabel.BackgroundColor3 = Colors.SurfaceHover
    selectedLabel.Text = "❌ لم يتم التحديد"
    selectedLabel.TextColor3 = Colors.TextDim
    selectedLabel.Font = Enum.Font.GothamBold
    selectedLabel.TextSize = 12
    selectedLabel.Parent = mopContent
    createCorner(selectedLabel, 8)

    -- أزرار التنقل
    local prevBtn = Instance.new("TextButton")
    prevBtn.Size = UDim2.new(0, 80, 0, 35)
    prevBtn.Position = UDim2.new(0, 10, 0, 150)
    prevBtn.BackgroundColor3 = Colors.Accent
    prevBtn.Text = "⬅️ سابق"
    prevBtn.TextColor3 = Colors.Text
    prevBtn.Font = Enum.Font.GothamBold
    prevBtn.TextSize = 12
    prevBtn.Parent = mopContent
    createCorner(prevBtn, 8)

    local nextBtn = Instance.new("TextButton")
    nextBtn.Size = UDim2.new(0, 80, 0, 35)
    nextBtn.Position = UDim2.new(1, -90, 0, 150)
    nextBtn.BackgroundColor3 = Colors.Accent
    nextBtn.Text = "تالي ➡️"
    nextBtn.TextColor3 = Colors.Text
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.TextSize = 12
    nextBtn.Parent = mopContent
    createCorner(nextBtn, 8)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 80, 0, 35)
    resetBtn.Position = UDim2.new(0.5, -40, 0, 150)
    resetBtn.BackgroundColor3 = Colors.Danger
    resetBtn.Text = "🔄 ريست"
    resetBtn.TextColor3 = Colors.Text
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 12
    resetBtn.Parent = mopContent
    createCorner(resetBtn, 8)

    -- قسم التنقل بالمسار
    local pathSection = Instance.new("Frame")
    pathSection.Size = UDim2.new(1, -20, 0, 120)
    pathSection.Position = UDim2.new(0, 10, 0, 200)
    pathSection.BackgroundColor3 = Colors.SurfaceHover
    pathSection.Parent = mopContent
    createCorner(pathSection, 10)

    local pathTitle = Instance.new("TextLabel")
    pathTitle.Size = UDim2.new(1, -10, 0, 25)
    pathTitle.Position = UDim2.new(0, 5, 0, 5)
    pathTitle.BackgroundTransparency = 1
    pathTitle.Text = "🚀 تنقل بالمسار المباشر"
    pathTitle.TextColor3 = Colors.AccentLight
    pathTitle.Font = Enum.Font.GothamBold
    pathTitle.TextSize = 13
    pathTitle.Parent = pathSection

    local pathBox = Instance.new("TextBox")
    pathBox.Size = UDim2.new(1, -90, 0, 35)
    pathBox.Position = UDim2.new(0, 5, 0, 35)
    pathBox.BackgroundColor3 = Colors.Background
    pathBox.Text = "workspace.Part"
    pathBox.TextColor3 = Colors.Text
    pathBox.Font = Enum.Font.Gotham
    pathBox.TextSize = 12
    pathBox.Parent = pathSection
    createCorner(pathBox, 8)

    local pathGoBtn = Instance.new("TextButton")
    pathGoBtn.Size = UDim2.new(0, 70, 0, 35)
    pathGoBtn.Position = UDim2.new(1, -75, 0, 35)
    pathGoBtn.BackgroundColor3 = Colors.Success
    pathGoBtn.Text = "🚀 OK"
    pathGoBtn.TextColor3 = Colors.Text
    pathGoBtn.Font = Enum.Font.GothamBold
    pathGoBtn.TextSize = 12
    pathGoBtn.Parent = pathSection
    createCorner(pathGoBtn, 8)

    local pathResetBtn = Instance.new("TextButton")
    pathResetBtn.Size = UDim2.new(0, 100, 0, 30)
    pathResetBtn.Position = UDim2.new(0.5, -50, 0, 80)
    pathResetBtn.BackgroundColor3 = Colors.Danger
    pathResetBtn.Text = "🔄 إعادة ضبط"
    pathResetBtn.TextColor3 = Colors.Text
    pathResetBtn.Font = Enum.Font.GothamBold
    pathResetBtn.TextSize = 11
    pathResetBtn.Parent = pathSection
    createCorner(pathResetBtn, 8)

    -- =====================================================
    -- ⚡ منطق الـ Selector
    -- =====================================================
    local selectedObjects = {}
    local currentIndex = 0

    toggleBtn.MouseButton1Click:Connect(function()
        selectorActive = not selectorActive
        if selectorActive then
            toggleBtn.Text = "⚡ ON"
            toggleBtn.BackgroundColor3 = Colors.Success
            infoLabel.Text = "✅ Selector نشط! انقر على أي شيء في اللعبة\n(مع حماية من الضغط على الأزرار)"
        else
            toggleBtn.Text = "⚡ OFF"
            toggleBtn.BackgroundColor3 = Colors.Danger
            infoLabel.Text = "🔧 اضغط ON ثم انقر على أي شيء في اللعبة\nلتحديده ونسخ مساره"
        end
    end)

    -- حماية الضغط: نستخدم InputBegan على الـ Workspace
    local clickConnection = nil

    local function startSelector()
        clickConnection = UserInputService.InputBegan:Connect(function(input)
            if not selectorActive then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            
            -- حماية: لو ضغط على UI، ما نعملش حاجة
            local mousePos = UserInputService:GetMouseLocation()
            -- نتأكد إنه مش ضاغط على UI بتاعنا
            for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if gui:IsA("GuiObject") and gui.Visible then
                    local absPos = gui.AbsolutePosition
                    local absSize = gui.AbsoluteSize
                    if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                       mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
                        return -- ضغط على UI، نتجاهل
                    end
                end
            end

            -- Raycast للعثور على الـ Part
            local ray = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            
            if result and result.Instance then
                local hit = result.Instance
                selectedObject = hit
                selectedLabel.Text = "✅ " .. hit.Name .. " (" .. hit.ClassName .. ")"
                selectedLabel.TextColor3 = Colors.Success
                
                -- نسخ المسار
                if setclipboard then
                    setclipboard(hit:GetFullName())
                end
                
                -- إضافة للتاريخ
                table.insert(selectedObjects, hit)
                currentIndex = #selectedObjects
                
                -- Highlight
                for _, hl in pairs(hit:GetDescendants()) do
                    if hl.Name == "MRHubSelect" then hl:Destroy() end
                end
                for _, hl in pairs(hit.Parent:GetDescendants()) do
                    if hl.Name == "MRHubSelect" then hl:Destroy() end
                end
                
                local highlight = Instance.new("Highlight")
                highlight.Name = "MRHubSelect"
                highlight.FillColor = Colors.Accent
                highlight.OutlineColor = Colors.AccentLight
                highlight.Parent = hit
                
                task.delay(3, function()
                    if highlight and highlight.Parent then highlight:Destroy() end
                end)
            end
        end)
    end

    startSelector()

    -- أزرار التنقل
    prevBtn.MouseButton1Click:Connect(function()
        if currentIndex > 1 then
            currentIndex = currentIndex - 1
            local obj = selectedObjects[currentIndex]
            if obj and obj.Parent then
                selectedObject = obj
                selectedLabel.Text = "⬅️ " .. obj.Name
                -- تنقل الكاميرا
                if obj:IsA("BasePart") then
                    workspace.CurrentCamera.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 10), obj.Position)
                end
            end
        end
    end)

    nextBtn.MouseButton1Click:Connect(function()
        if currentIndex < #selectedObjects then
            currentIndex = currentIndex + 1
            local obj = selectedObjects[currentIndex]
            if obj and obj.Parent then
                selectedObject = obj
                selectedLabel.Text = "➡️ " .. obj.Name
                if obj:IsA("BasePart") then
                    workspace.CurrentCamera.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 10), obj.Position)
                end
            end
        end
    end)

    resetBtn.MouseButton1Click:Connect(function()
        selectedObjects = {}
        currentIndex = 0
        selectedObject = nil
        selectedLabel.Text = "❌ لم يتم التحديد"
        selectedLabel.TextColor3 = Colors.TextDim
    end)

    -- تنقل بالمسار المباشر
    local pathMatches = {}
    local pathIndex = 0

    pathGoBtn.MouseButton1Click:Connect(function()
        local path = pathBox.Text
        if path == "" then return end
        
        -- محاولة الوصول للمسار
        local success, result = pcall(function()
            local current = game
            for segment in path:gmatch("[^%.]+") do
                -- دعم الفهارس الرقمية مثل workspace.Part[1]
                local name, index = segment:match("^([^%[]+)%[?(%d*)%]?$")
                current = current:FindFirstChild(name)
                if not current then return nil end
                if index and index ~= "" then
                    current = current[tonumber(index)]
                end
            end
            return current
        end)

        if success and result then
            -- جمع كل المطابقات
            pathMatches = {}
            local parent = result.Parent
            if parent then
                for _, sibling in pairs(parent:GetChildren()) do
                    if sibling.Name == result.Name and sibling.ClassName == result.ClassName then
                        table.insert(pathMatches, sibling)
                    end
                end
            else
                pathMatches = {result}
            end
            
            pathIndex = 1
            if #pathMatches > 0 then
                local target = pathMatches[pathIndex]
                if target:IsA("BasePart") then
                    workspace.CurrentCamera.CFrame = CFrame.new(target.Position + Vector3.new(0, 10, 20), target.Position)
                end
                selectedLabel.Text = "🚀 " .. target.Name .. " (1/" .. #pathMatches .. ")"
            end
        else
            selectedLabel.Text = "❌ المسار غير صالح"
            selectedLabel.TextColor3 = Colors.Danger
        end
    end)

    -- تنقل للتالي من نفس المسار
    pathBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            pathGoBtn.MouseButton1Click:Fire()
        end
    end)

    pathResetBtn.MouseButton1Click:Connect(function()
        pathMatches = {}
        pathIndex = 0
        pathBox.Text = "workspace.Part"
        selectedLabel.Text = "❌ تم إعادة الضبط"
    end)

    return mopContent
end

-- =====================================================
-- 🔄 نظام التبويبات
-- =====================================================
local function setupTabs()
    local explorerContent = createExplorerTab()
    local remoteContent = createRemoteTab()
    local mopContent = createMopTab()

    local tabs = {
        {btn = tabsFrame:FindFirstChild("ExplorerTab"), content = explorerContent},
        {btn = tabsFrame:FindFirstChild("RemoteTab"), content = remoteContent},
        {btn = tabsFrame:FindFirstChild("MopTab"), content = mopContent}
    }

    for i, tab in ipairs(tabs) do
        tab.btn.MouseButton1Click:Connect(function()
            -- إخفاء الكل
            for _, t in ipairs(tabs) do
                t.content.Visible = false
                t.btn.BackgroundColor3 = Colors.SurfaceHover
            end
            -- إظهار المختار
            tab.content.Visible = true
            tab.btn.BackgroundColor3 = Colors.Accent
        end)
    end

    -- تفعيل الأول افتراضياً
    tabs[1].btn.BackgroundColor3 = Colors.Accent
end

-- =====================================================
-- 🚀 التشغيل
-- =====================================================
createMainUI()
setupTabs()

print("✅ Map M.R Hub loaded successfully!")
print("🗺️ Tabs: Explorer | Remotes | Mop&NPC Selector")
