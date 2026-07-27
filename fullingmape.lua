-- =====================================================
-- ADDED: WEAPON DISPLAY (MOBILE SIMPLE)
-- =====================================================

local weaponGui = Instance.new("ScreenGui", player.PlayerGui)
weaponGui.Name = "WeaponDisplayUI"
weaponGui.ResetOnSpawn = false

-- النافذة الرئيسية (مربع أسود شفاف)
local mainFrame = Instance.new("Frame", weaponGui)
mainFrame.Size = UDim2.new(0, 250, 0, 350)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.6
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- سحب النافذة باللمس (بدون تعقيد)
local dragging = false
local dragStart = nil
local dragStartPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        dragStartPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- قائمة الأسلحة (بدون سكرول، كل السلاح في صف)
local function UpdateWeaponList()
    for _, child in pairs(mainFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local weaponDisplay = workspace:FindFirstChild("WeaponDisplays")
    if not weaponDisplay then return end

    local gunDisplay = weaponDisplay:FindFirstChild("GunDisplay")
    local knifeDisplay = weaponDisplay:FindFirstChild("KnifeDisplay")

    local weapons = {}
    if gunDisplay then
        for _, item in pairs(gunDisplay:GetChildren()) do
            table.insert(weapons, {Name = item.Name, Ref = item})
        end
    end
    if knifeDisplay then
        for _, item in pairs(knifeDisplay:GetChildren()) do
            table.insert(weapons, {Name = item.Name, Ref = item})
        end
    end

    local yOffset = 10
    for _, weapon in pairs(weapons) do
        -- صف السلاح
        local row = Instance.new("Frame", mainFrame)
        row.Size = UDim2.new(1, -10, 0, 30)
        row.Position = UDim2.new(0, 5, 0, yOffset)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

        -- اسم السلاح
        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(0.65, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = weapon.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- زر الإضافة
        local addBtn = Instance.new("TextButton", row)
        addBtn.Size = UDim2.new(0, 40, 0, 22)
        addBtn.Position = UDim2.new(1, -45, 0, 4)
        addBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        addBtn.Text = "+"
        addBtn.TextColor3 = Color3.new(1, 1, 1)
        addBtn.Font = Enum.Font.GothamBold
        addBtn.TextSize = 16
        Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 5)

        addBtn.MouseButton1Click:Connect(function()
            local newWeapon = weapon.Ref:Clone()
            newWeapon.Parent = player.Backpack
            task.wait(0.1)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:EquipTool(newWeapon)
            end
            Rayfield:Notify({
                Title = "✅ ADDED",
                Content = weapon.Name .. " added!",
                Duration = 2
            })
        end)

        yOffset = yOffset + 35
    end
end

UpdateWeaponList()

-- تحديث عند تغيير الأسلحة
local weaponDisplay = workspace:FindFirstChild("WeaponDisplays")
if weaponDisplay then
    weaponDisplay.ChildAdded:Connect(UpdateWeaponList)
    weaponDisplay.ChildRemoved:Connect(UpdateWeaponList)
    local gunDisplay = weaponDisplay:FindFirstChild("GunDisplay")
    local knifeDisplay = weaponDisplay:FindFirstChild("KnifeDisplay")
    if gunDisplay then
        gunDisplay.ChildAdded:Connect(UpdateWeaponList)
        gunDisplay.ChildRemoved:Connect(UpdateWeaponList)
    end
    if knifeDisplay then
        knifeDisplay.ChildAdded:Connect(UpdateWeaponList)
        knifeDisplay.ChildRemoved:Connect(UpdateWeaponList)
    end
end

print("🗡️ Weapon Display (Mobile Simple) Loaded")
