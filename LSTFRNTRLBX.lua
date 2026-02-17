local SCRIPT_NAME = "RHub - Lost Front"
local SCRIPT_VERSION = "LF Edition v1"

local DESCRIPTION_TEXT = [[
Lost Front Special Edition.
Tabs:
- Lost Front: Aimbot & Target Selector
- ESP: Team based ESPs and Health

Features:
- All Team ESP: Highlights everyone Red
- Red Team ESP: Highlights enemies in Red folder
- Blue Team ESP: Highlights enemies in Blue folder
- Health ESP: Bars above heads

Made by: @zawarka_lol
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connections = {}

local Whitelist = {
    ["dimakrutii93"] = true,
    ["QwERsSa00"] = true,
    ["Dani_l17"] = true,
    ["AndreyVin2010"] = true,
    ["F608_71"] = true,
    ["reriti123_1"] = true
}

local aimbotEnabled = false
local allEspEnabled = false
local redEspEnabled = false
local blueEspEnabled = false
local healthEspEnabled = false
local isRightMouseDown = false
local menuOpen = true 
local currentTarget = nil
local forcedTargetPlayer = nil

local isAnimating = false
local lastToggleTime = 0
local ToggleCooldown = 1
local SavedPosition = UDim2.new(0.5, -120, 0.5, -230) 

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LF_Hub_Standalone"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 350)
MainFrame.Position = UDim2.new(-0.5, 0, 0.5, -175) 
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local DescButton = Instance.new("TextButton")
DescButton.Name = "DescButton"
DescButton.Size = UDim2.new(1, -35, 0, 20)
DescButton.Position = UDim2.new(0, 0, 0, 5)
DescButton.Text = "Open Description"
DescButton.Font = Enum.Font.GothamBold
DescButton.TextSize = 11
DescButton.TextColor3 = Color3.fromRGB(0, 200, 255)
DescButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DescButton.BorderSizePixel = 0
DescButton.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "  " .. SCRIPT_NAME
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Size = UDim2.new(1, -35, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 0
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner") TitleCorner.CornerRadius = UDim.new(0, 6) TitleCorner.Parent = Title

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Text = SCRIPT_VERSION
VersionLabel.Font = Enum.Font.GothamBold
VersionLabel.TextSize = 14
VersionLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Size = UDim2.new(1, 0, 0, 20)
VersionLabel.Position = UDim2.new(0, 0, 1, -25) 
VersionLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 2
CloseButton.Parent = MainFrame
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 6) CloseCorner.Parent = CloseButton

local textWidth = 220
local textSize = 12
local font = Enum.Font.Gotham
local finalDescHeight = 150 

local pcallSuccess, bounds = pcall(function()
    return TextService:GetTextSize(DESCRIPTION_TEXT, textSize, font, Vector2.new(textWidth, 10000))
end)

if pcallSuccess and bounds then
    finalDescHeight = math.max(bounds.Y + 50, 100)
end

local DescFrame = Instance.new("Frame")
DescFrame.Name = "DescFrame"
DescFrame.Size = UDim2.new(0, 240, 0, finalDescHeight)
DescFrame.Position = UDim2.new(0.5, -120, 0.5, -150)
DescFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DescFrame.BorderSizePixel = 0
DescFrame.Visible = false
DescFrame.Active = true
DescFrame.Parent = ScreenGui

local DescCorner = Instance.new("UICorner") DescCorner.CornerRadius = UDim.new(0, 6) DescCorner.Parent = DescFrame

local DescTitle = Instance.new("TextLabel")
DescTitle.Text = "  Description"
DescTitle.Size = UDim2.new(1, -35, 0, 30)
DescTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DescTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
DescTitle.Font = Enum.Font.GothamBold
DescTitle.TextSize = 14
DescTitle.TextXAlignment = Enum.TextXAlignment.Left
DescTitle.Parent = DescFrame
local DTC = Instance.new("UICorner") DTC.CornerRadius = UDim.new(0, 6) DTC.Parent = DescTitle

local DescCloseBtn = Instance.new("TextButton")
DescCloseBtn.Size = UDim2.new(0, 30, 0, 30)
DescCloseBtn.Position = UDim2.new(1, -30, 0, 0)
DescCloseBtn.Text = "X"
DescCloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
DescCloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DescCloseBtn.Font = Enum.Font.GothamBold
DescCloseBtn.TextSize = 16
DescCloseBtn.BorderSizePixel = 0
DescCloseBtn.Parent = DescFrame
local DCC = Instance.new("UICorner") DCC.CornerRadius = UDim.new(0, 6) DCC.Parent = DescCloseBtn

local DescTextLabel = Instance.new("TextLabel")
DescTextLabel.Size = UDim2.new(0, textWidth, 0, finalDescHeight - 40)
DescTextLabel.Position = UDim2.new(0, 10, 0, 35)
DescTextLabel.BackgroundTransparency = 1
DescTextLabel.Text = DESCRIPTION_TEXT
DescTextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DescTextLabel.Font = font
DescTextLabel.TextSize = textSize
DescTextLabel.TextXAlignment = Enum.TextXAlignment.Left
DescTextLabel.TextYAlignment = Enum.TextYAlignment.Top
DescTextLabel.TextWrapped = true
DescTextLabel.Parent = DescFrame

local function GetClampedPosition(frame, proposedPos)
    local viewportSize = Camera.ViewportSize
    local frameSize = frame.AbsoluteSize
    
    local absX = (proposedPos.X.Scale * viewportSize.X) + proposedPos.X.Offset
    local absY = (proposedPos.Y.Scale * viewportSize.Y) + proposedPos.Y.Offset
    
    local clampedX = math.clamp(absX, 0, viewportSize.X - frameSize.X)
    local clampedY = math.clamp(absY, 0, viewportSize.Y - frameSize.Y)
    
    return UDim2.new(0, clampedX, 0, clampedY)
end

local function EnableDragging(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        if isAnimating then return end
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        local clampedPos = GetClampedPosition(frame, newPos)
        frame.Position = clampedPos
        
        if menuOpen then
            SavedPosition = clampedPos 
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if menuOpen then
                        SavedPosition = GetClampedPosition(frame, frame.Position)
                    end
                end
            end)
        end
    end);

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end);

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end);
end

EnableDragging(MainFrame)
EnableDragging(DescFrame)

local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(1, 0, 0, 30)
TabFrame.Position = UDim2.new(0, 0, 0, 60)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
MainTabBtn.Position = UDim2.new(0, 0, 0, 0)
MainTabBtn.Text = "Lost Front"
MainTabBtn.Font = Enum.Font.GothamBold
MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainTabBtn.BorderSizePixel = 0
MainTabBtn.Parent = TabFrame

local EspTabBtn = Instance.new("TextButton")
EspTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
EspTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
EspTabBtn.Text = "ESP"
EspTabBtn.Font = Enum.Font.GothamBold
EspTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
EspTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspTabBtn.BorderSizePixel = 0
EspTabBtn.Parent = TabFrame

local Page1 = Instance.new("Frame")
Page1.Size = UDim2.new(1, 0, 1, -95)
Page1.Position = UDim2.new(0, 0, 0, 95)
Page1.BackgroundTransparency = 1
Page1.Parent = MainFrame

local Page2 = Instance.new("Frame")
Page2.Size = UDim2.new(1, 0, 1, -95)
Page2.Position = UDim2.new(0, 0, 0, 95)
Page2.BackgroundTransparency = 1
Page2.Visible = false
Page2.Parent = MainFrame

local TweenSizeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

MainTabBtn.MouseButton1Click:Connect(function()
    Page1.Visible = true;
    Page2.Visible = false;
    
    MainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
    MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255);
    
    EspTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
    EspTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150);
    
    TweenService:Create(MainFrame, TweenSizeInfo, {Size = UDim2.new(0, 240, 0, 350)}):Play();
end);

EspTabBtn.MouseButton1Click:Connect(function()
    Page1.Visible = false;
    Page2.Visible = true;
    
    MainTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
    MainTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150);
    
    EspTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
    EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255);
    
    TweenService:Create(MainFrame, TweenSizeInfo, {Size = UDim2.new(0, 240, 0, 350)}):Play();
end);

local lastDescToggle = 0
DescButton.MouseButton1Click:Connect(function()
    if tick() - lastDescToggle < 1 then return end
    lastDescToggle = tick()
    MainFrame.Visible = false
    DescFrame.Position = SavedPosition 
    DescFrame.Visible = true
end);

DescCloseBtn.MouseButton1Click:Connect(function()
    if tick() - lastDescToggle < 1 then return end
    lastDescToggle = tick()
    DescFrame.Visible = false
    MainFrame.Position = SavedPosition 
    MainFrame.Visible = true
end);

local function CreateBtn(parent, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Parent = parent
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn
    return btn
end

local AimButton = CreateBtn(Page1, "AIMBOT [OFF]", 0.03)
local TargetButton = CreateBtn(Page1, "SELECT TARGET >", 0.16)
TargetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local TargetStatus = Instance.new("TextLabel")
TargetStatus.Size = UDim2.new(0.9, 0, 0, 20)
TargetStatus.Position = UDim2.new(0.05, 0, 0.35, 0)
TargetStatus.Text = "Current: Closest (Auto)"
TargetStatus.Font = Enum.Font.Gotham
TargetStatus.TextSize = 11
TargetStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
TargetStatus.BackgroundTransparency = 1
TargetStatus.Parent = Page1

local AllEspButton = CreateBtn(Page2, "All Team Esp [OFF]", 0.03)
local RedEspButton = CreateBtn(Page2, "Red Team Esp [OFF]", 0.16)
local BlueEspButton = CreateBtn(Page2, "Blue Team Esp [OFF]", 0.29)
local HealthEspButton = CreateBtn(Page2, "Health Esp [OFF]", 0.42)

local TargetListFrame = Instance.new("ScrollingFrame")
TargetListFrame.Name = "TargetList"
TargetListFrame.Size = UDim2.new(1.1, 0, 0, 200)
TargetListFrame.Position = UDim2.new(1.05, 0, 0, 0)
TargetListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TargetListFrame.BorderSizePixel = 0
TargetListFrame.Visible = false
TargetListFrame.Parent = MainFrame
local UIList = Instance.new("UIListLayout") UIList.Padding = UDim.new(0, 2) UIList.Parent = TargetListFrame
local TLC = Instance.new("UICorner") TLC.CornerRadius = UDim.new(0, 6) TLC.Parent = TargetListFrame

local function Cleanup()
    for _, conn in pairs(Connections) do if conn then conn:Disconnect() end end
    ScreenGui:Destroy()
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChild("AdminHighlight") then v.AdminHighlight:Destroy() end
        if v:FindFirstChild("HealthBarBillboard") then v.HealthBarBillboard:Destroy() end
    end
end
CloseButton.MouseButton1Click:Connect(Cleanup);

local function ToggleMenu()
    if isAnimating then return end
    if tick() - lastToggleTime < ToggleCooldown then return end
    lastToggleTime = tick()
    isAnimating = true
    
    if menuOpen then
        TargetListFrame.Visible = false
        local closePos = UDim2.new(1.5, 0, SavedPosition.Y.Scale, SavedPosition.Y.Offset)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = closePos})
        tween:Play()
        tween.Completed:Wait()
        menuOpen = false
    else
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(-0.5, 0, SavedPosition.Y.Scale, SavedPosition.Y.Offset)
        SavedPosition = GetClampedPosition(MainFrame, SavedPosition)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = SavedPosition})
        tween:Play()
        tween.Completed:Wait()
        menuOpen = true
    end
    isAnimating = false
end

task.spawn(function()
    isAnimating = true
    SavedPosition = GetClampedPosition(MainFrame, SavedPosition)
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = SavedPosition})
    tween:Play()
    tween.Completed:Wait()
    isAnimating = false
end)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end
end));
table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false currentTarget = nil end
end));

local function GetClosestPlayer()
    if forcedTargetPlayer then
        if forcedTargetPlayer.Parent and forcedTargetPlayer.Character and forcedTargetPlayer.Character:FindFirstChild("Head") and forcedTargetPlayer.Character.Humanoid.Health > 0 then return forcedTargetPlayer else return nil end
    end
    local closest, shortest = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not Whitelist[v.Name] and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < shortest then closest = v shortest = dist end
            end
        end
    end
    return closest
end

local function CreateHighlight(model, color)
    if not model then return end
    if not model:FindFirstChild("AdminHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "AdminHighlight"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Adornee = model
        hl.Parent = model
    end
end

local function ClearHighlights()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "AdminHighlight" then
            v:Destroy()
        end
    end
end

local function UpdateAllEsp()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and not Whitelist[v.Name] then
            CreateHighlight(v.Character, Color3.fromRGB(255, 0, 0))
        end
    end
end

local function UpdateRedEsp()
    local folder = workspace:FindFirstChild("IIIIllllIIIllIIlIlI_IIllIlIIIllII_o")
    if folder then
        local redTeam = folder:FindFirstChild("lIIooolll")
        if redTeam then
            for _, v in pairs(redTeam:GetChildren()) do
                if v:IsA("Model") then
                    CreateHighlight(v, Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end
end

local function UpdateBlueEsp()
    local folder = workspace:FindFirstChild("IIIIllllIIIllIIlIlI_IIllIlIIIllII_o")
    if folder then
        local blueTeam = folder:FindFirstChild("IIoooIIl")
        if blueTeam then
            for _, v in pairs(blueTeam:GetChildren()) do
                if v:IsA("Model") then
                    CreateHighlight(v, Color3.fromRGB(0, 0, 255))
                end
            end
        end
    end
end

local function UpdateHealthESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and not Whitelist[v.Name] then
            local hum = v.Character.Humanoid
            if not v.Character:FindFirstChild("HealthBarBillboard") then
                local bb = Instance.new("BillboardGui") bb.Name = "HealthBarBillboard" bb.Size = UDim2.new(0, 100, 0, 14) bb.StudsOffset = Vector3.new(0, 3.5, 0) bb.AlwaysOnTop = true bb.Adornee = v.Character:FindFirstChild("Head") or v.Character:WaitForChild("HumanoidRootPart") bb.Parent = v.Character
                local bg = Instance.new("Frame") bg.Name = "Background" bg.Size = UDim2.new(1, 0, 1, 0) bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50) bg.BorderSizePixel = 1 bg.Parent = bb
                local bar = Instance.new("Frame") bar.Name = "HealthBar" bar.Size = UDim2.new(hum.Health/hum.MaxHealth, 0, 1, 0) bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) bar.BorderSizePixel = 0 bar.ZIndex = 2 bar.Parent = bg
                local txt = Instance.new("TextLabel") txt.Name = "HealthText" txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.Text = math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) txt.TextColor3 = Color3.fromRGB(255, 255, 255) txt.TextStrokeTransparency = 0.5 txt.TextSize = 11 txt.Font = Enum.Font.GothamBold txt.ZIndex = 3 txt.Parent = bg
            else
                local bb = v.Character.HealthBarBillboard
                if bb:FindFirstChild("Background") then
                    local bg = bb.Background
                    if bg:FindFirstChild("HealthBar") then bg.HealthBar.Size = UDim2.new(hum.Health/hum.MaxHealth, 0, 1, 0) end
                    if bg:FindFirstChild("HealthText") then bg.HealthText.Text = math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end
                end
            end
        end
    end
end

AllEspButton.MouseButton1Click:Connect(function()
    allEspEnabled = not allEspEnabled
    AllEspButton.Text = allEspEnabled and "All Team Esp [ON]" or "All Team Esp [OFF]"
    AllEspButton.BackgroundColor3 = allEspEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    if not allEspEnabled then ClearHighlights() end
end);

RedEspButton.MouseButton1Click:Connect(function()
    redEspEnabled = not redEspEnabled
    RedEspButton.Text = redEspEnabled and "Red Team Esp [ON]" or "Red Team Esp [OFF]"
    RedEspButton.BackgroundColor3 = redEspEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    if not redEspEnabled then ClearHighlights() end
end);

BlueEspButton.MouseButton1Click:Connect(function()
    blueEspEnabled = not blueEspEnabled
    BlueEspButton.Text = blueEspEnabled and "Blue Team Esp [ON]" or "Blue Team Esp [OFF]"
    BlueEspButton.BackgroundColor3 = blueEspEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    if not blueEspEnabled then ClearHighlights() end
end);

HealthEspButton.MouseButton1Click:Connect(function()
    healthEspEnabled = not healthEspEnabled
    HealthEspButton.Text = healthEspEnabled and "Health Esp [ON]" or "Health Esp [OFF]"
    HealthEspButton.BackgroundColor3 = healthEspEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    if healthEspEnabled then UpdateHealthESP() else for _, v in pairs(Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("HealthBarBillboard") then v.Character.HealthBarBillboard:Destroy() end end end
end);

AimButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimButton.Text = aimbotEnabled and "AIMBOT [ON]" or "AIMBOT [OFF]"
    AimButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    currentTarget = nil
end);

local function RefreshTargetList()
    for _, c in pairs(TargetListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local count = 0
    local rBtn = Instance.new("TextButton")
    rBtn.Size = UDim2.new(1, -4, 0, 25) rBtn.Text = "Reset (Auto)" rBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40) rBtn.TextColor3 = Color3.fromRGB(255,255,255) rBtn.Parent = TargetListFrame
    rBtn.MouseButton1Click:Connect(function() forcedTargetPlayer = nil TargetStatus.Text = "Current: Closest (Auto)" TargetStatus.TextColor3 = Color3.fromRGB(150,150,150) TargetListFrame.Visible = false end)
    count = count + 1
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and not Whitelist[pl.Name] then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 25) btn.Text = pl.Name btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) btn.TextColor3 = Color3.fromRGB(255,255,255) btn.Parent = TargetListFrame
            btn.MouseButton1Click:Connect(function() forcedTargetPlayer = pl TargetStatus.Text = "Target: "..pl.Name TargetStatus.TextColor3 = Color3.fromRGB(0,255,0) TargetListFrame.Visible = false end)
            count = count + 1
        end
    end
    TargetListFrame.CanvasSize = UDim2.new(0, 0, 0, count * 27)
end

TargetButton.MouseButton1Click:Connect(function()
    TargetListFrame.Visible = not TargetListFrame.Visible
    if TargetListFrame.Visible then
        RefreshTargetList()
    end
end);

task.spawn(function()
    local loop
    loop = RunService.RenderStepped:Connect(function()
        if not ScreenGui.Parent then loop:Disconnect() return end
        if aimbotEnabled and isRightMouseDown then
            if not currentTarget or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then currentTarget = GetClosestPlayer() end
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character.Head.Position)
            end
        end
    end)
    table.insert(Connections, loop)
end)

task.spawn(function()
    while ScreenGui.Parent do
        if allEspEnabled then UpdateAllEsp() end
        if redEspEnabled then UpdateRedEsp() end
        if blueEspEnabled then UpdateBlueEsp() end
        if healthEspEnabled then UpdateHealthESP() end
        task.wait(1)
    end
end)
