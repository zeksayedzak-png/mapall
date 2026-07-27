-- [[ Mozer Hub v2 - Weapon Spawner ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LeftSidebar = Instance.new("Frame")
local RightContent = Instance.new("Frame")
local MinimizedFrame = Instance.new("TextButton")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local UserProfile = Instance.new("Frame")
local UserName = Instance.new("TextLabel")
local UserID = Instance.new("TextLabel")
local UserIcon = Instance.new("ImageLabel")
local TabContainer = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

-- Setup ScreenGui
ScreenGui.Name = "MozerHub_v2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- 1. Welcome Animation
local function ShowWelcome()
    local WelcomeGui = Instance.new("ScreenGui", game.CoreGui)
    local MozerLabel = Instance.new("TextLabel", WelcomeGui)
    MozerLabel.Size = UDim2.new(1, 0, 0.1, 0)
    MozerLabel.Position = UDim2.new(0, 0, 0.38, 0)
    MozerLabel.BackgroundTransparency = 1
    MozerLabel.Text = "Mozer"
    MozerLabel.TextSize = 80
    MozerLabel.Font = Enum.Font.FredokaOne

    local WelcomeLabel = Instance.new("TextLabel", WelcomeGui)
    WelcomeLabel.Size = UDim2.new(1, 0, 0.1, 0)
    WelcomeLabel.Position = UDim2.new(0, 0, 0.56, 0)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Text = "Welcome"
    WelcomeLabel.TextSize = 50
    WelcomeLabel.Font = Enum.Font.FredokaOne

    task.spawn(function()
        while WelcomeGui.Parent do
            local hue = tick() % 5 / 5
            MozerLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            WelcomeLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait()
        end
    end)
    task.wait(2.5)
    WelcomeGui:Destroy()
end

-- 2. Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

LeftSidebar.Name = "Sidebar"
LeftSidebar.Parent = MainFrame
LeftSidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LeftSidebar.Size = UDim2.new(0, 155, 1, 0)
LeftSidebar.BorderSizePixel = 0
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 12)

Title.Parent = LeftSidebar
Title.Text = "Be Mozer"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22

TabContainer.Parent = LeftSidebar
TabContainer.Position = UDim2.new(0, 10, 0, 65)
TabContainer.Size = UDim2.new(1, -20, 0.55, 0)
TabContainer.BackgroundTransparency = 1

UIListLayout.Parent = TabContainer
UIListLayout.Padding = UDim.new(0, 6)

-- Content Area (Scrolling)
local ScrollContent = Instance.new("ScrollingFrame")
ScrollContent.Parent = MainFrame
ScrollContent.Size = UDim2.new(0, 345, 0, 270)
ScrollContent.Position = UDim2.new(0, 165, 0, 55)
ScrollContent.BackgroundTransparency = 1
ScrollContent.BorderSizePixel = 0
ScrollContent.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContent.ScrollBarThickness = 2

local ContentLayout = Instance.new("UIListLayout", ScrollContent)
ContentLayout.Padding = UDim.new(0, 5)

-- Tabs Creation
local function CreateTab(name)
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Btn.Text = "   " .. name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    return Btn
end

local weaponsTab = CreateTab("Weapons")
CreateTab("Information")
CreateTab("Gamepass")

-- User Profile
UserProfile.Parent = LeftSidebar
UserProfile.Size = UDim2.new(1, -12, 0, 50)
UserProfile.Position = UDim2.new(0, 6, 1, -60)
UserProfile.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", UserProfile).CornerRadius = UDim.new(0, 10)

UserIcon.Parent = UserProfile
UserIcon.Size = UDim2.new(0, 34, 0, 34)
UserIcon.Position = UDim2.new(0, 8, 0.5, -17)
UserIcon.Image = game:GetService("Players"):GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
Instance.new("UICorner", UserIcon).CornerRadius = UDim.new(1, 0)

UserName.Parent = UserProfile
UserName.Text = game.Players.LocalPlayer.DisplayName
UserName.Size = UDim2.new(1, -50, 0, 15)
UserName.Position = UDim2.new(0, 48, 0.3, -2)
UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 11
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.BackgroundTransparency = 1

UserID.Parent = UserProfile
UserID.Text = "@" .. game.Players.LocalPlayer.Name
UserID.Size = UDim2.new(1, -50, 0, 15)
UserID.Position = UDim2.new(0, 48, 0.6, -2)
UserID.TextColor3 = Color3.fromRGB(130, 130, 130)
UserID.Font = Enum.Font.Gotham
UserID.TextSize = 9
UserID.TextXAlignment = Enum.TextXAlignment.Left
UserID.BackgroundTransparency = 1

-- Minimized Button (M)
MinimizedFrame.Name = "MinimizedFrame"
MinimizedFrame.Parent = ScreenGui
MinimizedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MinimizedFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MinimizedFrame.Size = UDim2.new(0, 55, 0, 55)
MinimizedFrame.Visible = false
MinimizedFrame.Text = "M"
MinimizedFrame.Font = Enum.Font.FredokaOne
MinimizedFrame.TextSize = 32
MinimizedFrame.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinimizedFrame).CornerRadius = UDim.new(0, 12)

-- Function to Add Weapon Button to UI
local function AddWeaponUI(weaponObject, categoryName)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.Parent = ScrollContent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "[" .. categoryName .. "] " .. weaponObject.Name
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham

    local AddBtn = Instance.new("TextButton", Frame)
    AddBtn.Text = "ADD"
    AddBtn.Size = UDim2.new(0.2, 0, 0.7, 0)
    AddBtn.Position = UDim2.new(0.75, 0, 0.15, 0)
    AddBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
    AddBtn.TextColor3 = Color3.new(1, 1, 1)
    AddBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", AddBtn).CornerRadius = UDim.new(0, 4)

    AddBtn.MouseButton1Click:Connect(function()
        -- Attempt to pick up weapon
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")

        -- Logic: If it has a ProximityPrompt, trigger it
        local prompt = weaponObject:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            fireproximityprompt(prompt)
        else
            -- Logic: Teleport slightly to it or touch it
            local handle = weaponObject:FindFirstChild("Handle") or weaponObject:FindFirstChildWhichIsA("BasePart", true)
            if handle then
                firetouchinterest(root, handle, 0)
                task.wait(0.1)
                firetouchinterest(root, handle, 1)
            end
        end
    end)
    
    ScrollContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
end

-- Load Weapons
local function RefreshWeapons()
    for _, child in pairs(ScrollContent:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local guns = workspace:FindFirstChild("WeaponDisplays") and workspace.WeaponDisplays:FindFirstChild("GunDisplay")
    local knives = workspace:FindFirstChild("WeaponDisplays") and workspace.WeaponDisplays:FindFirstChild("KnifeDisplay")

    if guns then
        for _, v in pairs(guns:GetChildren()) do
            AddWeaponUI(v, "GUN")
        end
    end
    if knives then
        for _, v in pairs(knives:GetChildren()) do
            AddWeaponUI(v, "KNIFE")
        end
    end
end

-- Make Draggable for Mobile
local function MakeDraggable(frame)
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(MainFrame)
MakeDraggable(MinimizedFrame)

-- Buttons Events
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizedFrame.Visible = true
end)

MinimizedFrame.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizedFrame.Visible = false
end)

-- Rainbow Effect for M Button
task.spawn(function()
    while true do
        MinimizedFrame.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        task.wait()
    end
end)

-- Start Hub
task.spawn(function()
    ShowWelcome()
    MainFrame.Visible = true
    RefreshWeapons()
end)
