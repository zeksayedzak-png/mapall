-- =====================================================
-- ADDED: WEAPON DISPLAY VIEWER (GunDisplay + KnifeDisplay)
-- =====================================================

local weaponDisplayGui = Instance.new("ScreenGui", player.PlayerGui)
weaponDisplayGui.Name = "WeaponDisplayUI"
weaponDisplayGui.ResetOnSpawn = false

-- النافذة الرئيسية
local mainFrame = Instance.new("Frame", weaponDisplayGui)
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.6
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 1
mainStroke.Color = Color3.fromRGB(100, 100, 100)

-- عنوان
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🗡️ WEAPON DISPLAY"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1

-- منطقة التمرير
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 10)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 5)

-- دالة تحديث القائمة
local function UpdateWeaponList()
    -- حذف العناصر القديمة
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local weaponDisplay = workspace:FindFirstChild("WeaponDisplays")
    if not weaponDisplay then return end

    local gunDisplay = weaponDisplay:FindFirstChild("GunDisplay")
    local knifeDisplay = weaponDisplay:FindFirstChild("KnifeDisplay")

    local allWeapons = {}

    -- جمع الأسلحة من GunDisplay
    if gunDisplay then
        for _, item in pairs(gunDisplay:GetChildren()) do
            if item:IsA("Tool") or item:IsA("BasePart") then
                table.insert(allWeapons, {Name = item.Name, Ref = item, Type = "Gun"})
            end
        end
    end

    -- جمع الأسلحة من KnifeDisplay
    if knifeDisplay then
        for _, item in pairs(knifeDisplay:GetChildren()) do
            if item:IsA("Tool") or item:IsA("BasePart") then
                table.insert(allWeapons, {Name = item.Name, Ref = item, Type = "Knife"})
            end
        end
    end

    -- إنشاء صف لكل سلاح
    for _, weapon in pairs(allWeapons) do
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1, -10, 0, 35)
        row.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        -- اسم السلاح
        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = weapon.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- زر "إضافة/تجربة"
        local tryBtn = Instance.new("TextButton", row)
        tryBtn.Size = UDim2.new(0, 50, 0, 25)
        tryBtn.Position = UDim2.new(1, -55, 0, 5)
        tryBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        tryBtn.Text = "➕"
        tryBtn.TextColor3 = Color3.new(1, 1, 1)
        tryBtn.Font = Enum.Font.GothamBold
        tryBtn.TextSize = 16
        Instance.new("UICorner", tryBtn).CornerRadius = UDim.new(0, 5)

        -- وظيفة زر الإضافة
        tryBtn.MouseButton1Click:Connect(function()
            -- محاولة إضافة السلاح إلى المخزون
            local weaponRef = weapon.Ref
            if weaponRef then
                -- إذا كان السلاح في Workspace، نستنسخه
                local newWeapon = weaponRef:Clone()
                newWeapon.Parent = player.Backpack
                
                -- محاولة تجهيزه فوراً
                task.wait(0.1)
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    local humanoid = player.Character.Humanoid
                    humanoid:EquipTool(newWeapon)
                end

                Rayfield:Notify({
                    Title = "🔫 WEAPON ADDED",
                    Content = weapon.Name .. " has been added to your inventory!",
                    Duration = 2
                })
            else
                Rayfield:Notify({
                    Title = "⚠️ ERROR",
                    Content = "Could not find weapon: " .. weapon.Name,
                    Duration = 2
                })
            end
        end)
    end

    -- تحديث حجم التمرير
    scroll.CanvasSize = UDim2.new(0, 0, 0, #allWeapons * 40 + 10)
end

-- تحديث القائمة أول مرة
UpdateWeaponList()

-- تحديث تلقائي عند إضافة/حذف سلاح في المسارين
local function onWeaponDisplayChanged()
    UpdateWeaponList()
end

local weaponDisplay = workspace:FindFirstChild("WeaponDisplays")
if weaponDisplay then
    weaponDisplay.ChildAdded:Connect(onWeaponDisplayChanged)
    weaponDisplay.ChildRemoved:Connect(onWeaponDisplayChanged)
    
    -- مراقبة التغييرات داخل GunDisplay و KnifeDisplay
    local gunDisplay = weaponDisplay:FindFirstChild("GunDisplay")
    local knifeDisplay = weaponDisplay:FindFirstChild("KnifeDisplay")
    
    if gunDisplay then
        gunDisplay.ChildAdded:Connect(onWeaponDisplayChanged)
        gunDisplay.ChildRemoved:Connect(onWeaponDisplayChanged)
    end
    
    if knifeDisplay then
        knifeDisplay.ChildAdded:Connect(onWeaponDisplayChanged)
        knifeDisplay.ChildRemoved:Connect(onWeaponDisplayChanged)
    end
end

-- ==================== سحب النافذة (باللمس) ====================
local draggingWeaponUI = false
local dragWeaponUIStart = nil
local dragWeaponUIStartPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWeaponUI = true
        dragWeaponUIStart = input.Position
        dragWeaponUIStartPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if draggingWeaponUI and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragWeaponUIStart
        mainFrame.Position = UDim2.new(dragWeaponUIStartPos.X.Scale, dragWeaponUIStartPos.X.Offset + delta.X, dragWeaponUIStartPos.Y.Scale, dragWeaponUIStartPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWeaponUI = false
    end
end)

print("🗡️ Weapon Display Viewer Loaded (GunDisplay + KnifeDisplay)")
