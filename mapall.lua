-- =====================================================
-- 🔍 UNIVERSAL EXPLORER - مستكشف شامل لكل شيء
-- ⚡ يكشف كل شيء في اللعبة مع زر نسخ وتعمق
-- 📱 واجهة سوداء قابلة للسحب
-- =====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- المتغيرات العامة
-- =====================================================
local currentStack = {}  -- لتتبع مستويات التعمق
local currentParent = game  -- البداية من game (الجذر)
local mainFrame = nil
local scrollFrame = nil
local itemCache = {}  -- لتجميع العناصر المتشابهة

-- =====================================================
-- إنشاء الواجهة الرئيسية
-- =====================================================
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalExplorer"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -210, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔍 Universal Explorer"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- زر العودة (Back)
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 50, 0, 28)
    backBtn.Position = UDim2.new(1, -120, 0, 6)
    backBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    backBtn.Text = "🔙 Back"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.Font = Enum.Font.GothamBold
    backBtn.TextSize = 11
    backBtn.Parent = titleBar
    Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)

    -- زر الإغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0, 4)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar

    -- منطقة التمرير
    scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -60)
    scrollFrame.Position = UDim2.new(0, 5, 0, 50)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.Parent = mainFrame
    Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame

    -- =====================================================
    -- وظائف السحب
    -- =====================================================
    local dragData = {dragging = false, startPos = nil, startMouse = nil}

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.dragging = true
            dragData.startPos = mainFrame.Position
            dragData.startMouse = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragData.dragging then
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = Vector2.new(input.Position.X, input.Position.Y) - dragData.startMouse
                local newX = dragData.startPos.X.Offset + delta.X
                local newY = dragData.startPos.Y.Offset + delta.Y
                mainFrame.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.dragging = false
        end
    end)

    -- =====================================================
    -- عرض العناصر في القائمة
    -- =====================================================
    local function renderItems(parentObj)
        -- مسح العناصر السابقة
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        -- جمع العناصر وتجميعها
        local itemGroups = {}
        for _, obj in pairs(parentObj:GetChildren()) do
            local className = obj.ClassName
            local name = obj.Name
            
            -- تجميع العناصر المتشابهة (نفس الاسم والنوع)
            local key = className .. "|" .. name
            if not itemGroups[key] then
                itemGroups[key] = {count = 0, example = obj}
            end
            itemGroups[key].count = itemGroups[key].count + 1
        end

        -- عرض المجموعات
        for key, data in pairs(itemGroups) do
            local obj = data.example
            local count = data.count
            local displayName = obj.Name .. (count > 1 and " (" .. count .. ")" or "")

            -- بطاقة العنصر
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -10, 0, 70)
            card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
            card.Parent = scrollFrame
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

            -- أيقونة النوع
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 28, 0, 28)
            icon.Position = UDim2.new(0, 6, 0, 6)
            icon.BackgroundTransparency = 1
            local iconText = obj:IsA("RemoteEvent") and "📡" or 
                            obj:IsA("RemoteFunction") and "⚙️" or
                            obj:IsA("Script") and "📜" or
                            obj:IsA("LocalScript") and "📄" or
                            obj:IsA("Part") and "🧱" or
                            obj:IsA("Folder") and "📁" or
                            obj:IsA("Model") and "🗿" or
                            obj:IsA("Tool") and "🔧" or
                            obj:IsA("ValueBase") and "💎" or
                            "📦"
            icon.Text = iconText
            icon.TextColor3 = Color3.fromRGB(255, 200, 100)
            icon.Font = Enum.Font.Gotham
            icon.TextSize = 16
            icon.Parent = card

            -- الاسم
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -170, 0, 20)
            nameLabel.Position = UDim2.new(0, 40, 0, 4)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = displayName
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 11
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = card

            -- النوع
            local typeLabel = Instance.new("TextLabel")
            typeLabel.Size = UDim2.new(1, -170, 0, 18)
            typeLabel.Position = UDim2.new(0, 40, 0, 24)
            typeLabel.BackgroundTransparency = 1
            typeLabel.Text = obj.ClassName
            typeLabel.TextColor3 = Color3.fromRGB(160, 160, 200)
            typeLabel.Font = Enum.Font.Gotham
            typeLabel.TextSize = 9
            typeLabel.TextXAlignment = Enum.TextXAlignment.Left
            typeLabel.Parent = card

            -- المسار
            local pathLabel = Instance.new("TextLabel")
            pathLabel.Size = UDim2.new(1, -170, 0, 18)
            pathLabel.Position = UDim2.new(0, 40, 0, 42)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text = obj:GetFullName()
            pathLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
            pathLabel.Font = Enum.Font.Gotham
            pathLabel.TextSize = 8
            pathLabel.TextWrapped = true
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.Parent = card

            -- زر النسخ
            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.new(0, 45, 0, 28)
            copyBtn.Position = UDim2.new(1, -110, 0, 4)
            copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            copyBtn.Text = "📋"
            copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 14
            copyBtn.Parent = card
            Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

            copyBtn.MouseButton1Click:Connect(function()
                local fullPath = obj:GetFullName()
                setclipboard(fullPath)
                copyBtn.Text = "✅"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                task.delay(1, function()
                    if copyBtn and copyBtn.Parent then
                        copyBtn.Text = "📋"
                        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    end
                end)
            end)

            -- زر التعمق (إذا كان للكائن أبناء)
            local hasChildren = #obj:GetChildren() > 0
            local drillBtn = Instance.new("TextButton")
            drillBtn.Size = UDim2.new(0, 55, 0, 28)
            drillBtn.Position = UDim2.new(1, -52, 0, 4)
            drillBtn.BackgroundColor3 = hasChildren and Color3.fromRGB(0, 100, 180) or Color3.fromRGB(40, 40, 40)
            drillBtn.Text = hasChildren and "🔽" or "🚫"
            drillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            drillBtn.Font = Enum.Font.GothamBold
            drillBtn.TextSize = 14
            drillBtn.Parent = card
            Instance.new("UICorner", drillBtn).CornerRadius = UDim.new(0, 6)

            if hasChildren then
                drillBtn.MouseButton1Click:Connect(function()
                    -- حفظ المستوى الحالي في الـ Stack
                    table.insert(currentStack, currentParent)
                    currentParent = obj
                    renderItems(currentParent)
                    
                    -- تحديث العنوان
                    title.Text = "🔍 " .. obj:GetFullName()
                end)
            end
        end

        -- تحديث التمرير
        task.defer(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
    end

    -- =====================================================
    -- زر العودة (Back)
    -- =====================================================
    backBtn.MouseButton1Click:Connect(function()
        if #currentStack > 0 then
            currentParent = table.remove(currentStack)
            renderItems(currentParent)
            title.Text = "🔍 " .. currentParent:GetFullName()
        else
            print("⚠️ Already at the top level.")
        end
    end)

    -- =====================================================
    -- إغلاق الواجهة
    -- =====================================================
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    -- =====================================================
    -- التشغيل الأولي
    -- =====================================================
    renderItems(game)  -- نبدأ من الجذر (game)
    title.Text = "🔍 game (root)"
    print("✅ Universal Explorer loaded!")
end

-- =====================================================
-- تشغيل السكريبت
-- =====================================================
createUI()
