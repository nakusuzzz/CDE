--[[
	WARNING: KrisVan Script (Special Ed.) - Custom Image Asset Floating Button v3.3.4
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isAutoDriving = false
local isDeliveryRunning = false
local isAntiAfkEnabled = false
local isWalkSpeedEnabled = false
local isJumpPowerEnabled = false
local isInfiniteJumpEnabled = false
local activeConnections = {}

local isFarmEnabled = false
local maxItems = 4
local jobState = nil
local isTraveling = false
local noclipConnection = nil
local loopConnection = nil
local jumpConnection = nil
local charAddedConnection = nil
local startAllFarm = nil

_G.AutoFarm = false
local StartPosition = CFrame.new(Vector3.new(-34567.375, 34.895652770996094, -32846.046875), Vector3.new())
local EndPosition = CFrame.new(Vector3.new(-31448.3515625, 34.925010681152344, -26616.25), Vector3.new())

local function stopAllRoutines()
    isAutoDriving = false
    _G.AutoFarm = false
    isDeliveryRunning = false
    isAntiAfkEnabled = false
    isWalkSpeedEnabled = false
    isJumpPowerEnabled = false
    isInfiniteJumpEnabled = false
    isFarmEnabled = false
    
    if charAddedConnection then charAddedConnection:Disconnect() charAddedConnection = nil end
    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end

    for _, conn in ipairs(activeConnections) do
        if conn then
            pcall(function()
                if typeof(conn) == "RBXScriptConnection" then conn:Disconnect()
                elseif typeof(conn) == "thread" then task.cancel(conn) end
            end)
        end
    end
    activeConnections = {}
end

local runMainScript

local function showConfirmDialog(titleText, msgText, yesText, noText, onYes, onNo)
    if CoreGui:FindFirstChild("KrisVanConfirmDialog") then
        CoreGui.KrisVanConfirmDialog:Destroy()
    end

    local confirmGui = Instance.new("ScreenGui")
    confirmGui.Name = "KrisVanConfirmDialog"
    confirmGui.ResetOnSpawn = false
    confirmGui.IgnoreGuiInset = true
    confirmGui.Parent = CoreGui

    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0, 300, 0, 150)
    confirmFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    confirmFrame.BackgroundTransparency = 0.2
    confirmFrame.BorderSizePixel = 0
    confirmFrame.Parent = confirmGui

    Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", confirmFrame)
    stroke.Color = Color3.fromRGB(140, 60, 220)
    stroke.Thickness = 1.5

    local confirmTitle = Instance.new("TextLabel", confirmFrame)
    confirmTitle.Size = UDim2.new(1, -30, 0, 40)
    confirmTitle.Position = UDim2.new(0, 15, 0, 12)
    confirmTitle.BackgroundTransparency = 1
    confirmTitle.Text = titleText
    confirmTitle.Font = Enum.Font.GothamBold
    confirmTitle.TextSize = 15
    confirmTitle.TextColor3 = Color3.fromRGB(220, 130, 255)
    confirmTitle.TextXAlignment = Enum.TextXAlignment.Left

    local confirmMsg = Instance.new("TextLabel", confirmFrame)
    confirmMsg.Size = UDim2.new(1, -30, 0, 40)
    confirmMsg.Position = UDim2.new(0, 15, 0, 52)
    confirmMsg.BackgroundTransparency = 1
    confirmMsg.Text = msgText
    confirmMsg.Font = Enum.Font.Gotham
    confirmMsg.TextSize = 13
    confirmMsg.TextColor3 = Color3.fromRGB(180, 180, 200)
    confirmMsg.TextXAlignment = Enum.TextXAlignment.Left

    local btnNo = Instance.new("TextButton", confirmFrame)
    btnNo.Size = UDim2.new(0.44, 0, 0, 38)
    btnNo.Position = UDim2.new(0.04, 0, 0, 100)
    btnNo.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    btnNo.BackgroundTransparency = 0.3
    btnNo.Text = noText
    btnNo.Font = Enum.Font.GothamBold
    btnNo.TextSize = 12
    btnNo.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", btnNo).CornerRadius = UDim.new(0, 10)

    local btnYes = Instance.new("TextButton", confirmFrame)
    btnYes.Size = UDim2.new(0.44, 0, 0, 38)
    btnYes.Position = UDim2.new(0.52, 0, 0, 100)
    btnYes.BackgroundColor3 = Color3.fromRGB(130, 40, 190)
    btnYes.BackgroundTransparency = 0.15
    btnYes.Text = yesText
    btnYes.Font = Enum.Font.GothamBold
    btnYes.TextSize = 12
    btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btnYes).CornerRadius = UDim.new(0, 10)

    btnNo.Activated:Connect(function() confirmGui:Destroy() if onNo then onNo() end end)
    btnYes.Activated:Connect(function() confirmGui:Destroy() if onYes then onYes() end end)
end

local function showLanguageSelector()
    stopAllRoutines()
    if playerGui:FindFirstChild("MultiDriveGui") then playerGui.MultiDriveGui:Destroy() end
    if CoreGui:FindFirstChild("KrisVanLangSelector") then CoreGui.KrisVanLangSelector:Destroy() end

    local langGui = Instance.new("ScreenGui")
    langGui.Name = "KrisVanLangSelector"
    langGui.ResetOnSpawn = false
    langGui.IgnoreGuiInset = true
    langGui.Parent = CoreGui

    local langFrame = Instance.new("Frame", langGui)
    langFrame.Size = UDim2.new(0, 320, 0, 230)
    langFrame.Position = UDim2.new(0.5, -160, 0.5, -115)
    langFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    langFrame.BackgroundTransparency = 0.2
    langFrame.BorderSizePixel = 0

    Instance.new("UICorner", langFrame).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", langFrame)
    stroke.Color = Color3.fromRGB(140, 60, 220)
    stroke.Thickness = 1.5

    local langTitle = Instance.new("TextLabel", langFrame)
    langTitle.Size = UDim2.new(1, -50, 0, 50)
    langTitle.Position = UDim2.new(0, 18, 0, 10)
    langTitle.BackgroundTransparency = 1
    langTitle.Text = "Select Language / 選擇語言"
    langTitle.Font = Enum.Font.GothamBold
    langTitle.TextSize = 15
    langTitle.TextColor3 = Color3.fromRGB(210, 130, 255)
    langTitle.TextXAlignment = Enum.TextXAlignment.Left

    local langCloseBtn = Instance.new("TextButton", langFrame)
    langCloseBtn.Size = UDim2.new(0, 32, 0, 32)
    langCloseBtn.Position = UDim2.new(1, -42, 0, 15)
    langCloseBtn.BackgroundTransparency = 1
    langCloseBtn.Text = "X"
    langCloseBtn.Font = Enum.Font.GothamBold
    langCloseBtn.TextSize = 16
    langCloseBtn.TextColor3 = Color3.fromRGB(200, 80, 80)

    langCloseBtn.Activated:Connect(function()
        showConfirmDialog("⚠️ 關閉確認", "確定要關閉輔助腳本嗎？", "是", "否", function()
            stopAllRoutines()
            if CoreGui:FindFirstChild("KrisVanLangSelector") then CoreGui.KrisVanLangSelector:Destroy() end
        end, nil)
    end)

    local function createLangButton(name, yPos, color)
        local btn = Instance.new("TextButton", langFrame)
        btn.Size = UDim2.new(0.88, 0, 0, 42)
        btn.Position = UDim2.new(0.06, 0, 0, yPos)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.25
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        return btn
    end

    local btnZh = createLangButton("🇹🇼 繁體中文", 65, Color3.fromRGB(35, 110, 65))
    local btnCn = createLangButton("🇨🇳 简体中文", 115, Color3.fromRGB(35, 80, 120))
    local btnEn = createLangButton("🇺🇸 English", 165, Color3.fromRGB(100, 35, 150))

    local clicked = false
    btnZh.Activated:Connect(function() if clicked then return end clicked = true langGui:Destroy() runMainScript("ZH") end)
    btnCn.Activated:Connect(function() if clicked then return end clicked = true langGui:Destroy() runMainScript("CN") end)
    btnEn.Activated:Connect(function() if clicked then return end clicked = true langGui:Destroy() runMainScript("EN") end)
end

runMainScript = function(selectedLanguage)
    if playerGui:FindFirstChild("MultiDriveGui") then playerGui.MultiDriveGui:Destroy() end
    if CoreGui:FindFirstChild("KrisVanLangSelector") then CoreGui.KrisVanLangSelector:Destroy() end

    local L = {}
    if selectedLanguage == "ZH" then
        L = {
            Title = "⚔️ KrisVan 遊戲輔助 v3.3.4",
            Tab0 = "👤 作者資訊",
            TabLog = "📋 更新日誌",
            Tab1 = "🚗 自動駕駛",
            Tab2 = "💵 自動送貨",
            Tab3 = "⚙️ 其他設定",
            SwitchOff = "關閉",
            SwitchOn = "開啟",
            AuthorContent = "【 作者資訊 】\n• 作者 / 開發者：KrisVan\n• 功能：專為 Roblox 多功能遊戲打造的強大輔助介面。\n• 感謝您的使用與支持！",
            AutoDriveDesc = "高速傳送自動駕駛模式",
            DeliveryDesc = "自動接單與送貨作業",
            SpeedTip = "移動速度 (16~200)",
            JumpTip = "跳躍高度 (50~100)",
            InfJump = "跳躍無冷卻 (無限跳)",
            AntiAfk = "防掛機保護",
            LangBtn = "🌐 切換語言",
            StatusRunning = "狀態: 運行中",
            StatusStopped = "狀態: 已停止",
            ConfirmTitle = "⚠️ 關閉確認",
            ConfirmMsg = "確定要關閉輔助腳本嗎？",
            ConfirmYes = "是",
            ConfirmNo = "否"
        }
    elseif selectedLanguage == "CN" then
        L = {
            Title = "⚔️ KrisVan 游戏辅助 v3.3.4",
            Tab0 = "👤 作者信息",
            TabLog = "📋 更新日志",
            Tab1 = "🚗 自动驾驶",
            Tab2 = "💵 自动送货",
            Tab3 = "⚙️ 其他设定",
            SwitchOff = "关闭",
            SwitchOn = "开启",
            AuthorContent = "【 作者信息 】\n• 作者 / 开发者：KrisVan\n• 功能：专为 Roblox 多功能游戏打造的强大辅助界面。\n• 感谢您的使用与支持！",
            AutoDriveDesc = "高速传送自动驾驶模式",
            DeliveryDesc = "自动接单与送货作业",
            SpeedTip = "移动速度 (16~200)",
            JumpTip = "跳跃高度 (50~100)",
            InfJump = "跳跃无冷却 (无限跳)",
            AntiAfk = "防挂机保护",
            LangBtn = "🌐 切换语言",
            StatusRunning = "状态: 运行中",
            StatusStopped = "状态: 已停止",
            ConfirmTitle = "⚠️ 关闭确认",
            ConfirmMsg = "确定要关闭辅助脚本吗？",
            ConfirmYes = "是",
            ConfirmNo = "否"
        }
    else
        L = {
            Title = "⚔️ KrisVan Script v3.3.4",
            Tab0 = "👤 Author",
            TabLog = "📋 Changelog",
            Tab1 = "🚗 Auto Drive",
            Tab2 = "💵 Auto Delivery",
            Tab3 = "⚙️ Settings",
            SwitchOff = "OFF",
            SwitchOn = "ON",
            AuthorContent = "[ Author Information ]\n• Author: KrisVan\n• Description: Advanced multi-feature utility script.\n• Thank you for using!",
            AutoDriveDesc = "High-speed TP Auto Drive mode",
            DeliveryDesc = "Automated delivery and earnings",
            SpeedTip = "Walk Speed (16~200)",
            JumpTip = "Jump Power (50~100)",
            InfJump = "Infinite Jump",
            AntiAfk = "Anti-AFK Protection",
            LangBtn = "🌐 Change Lang",
            StatusRunning = "Status: Running",
            StatusStopped = "Status: Stopped",
            ConfirmTitle = "⚠️ Confirm Close",
            ConfirmMsg = "Are you sure to close script?",
            ConfirmYes = "Yes",
            ConfirmNo = "No"
        }
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MultiDriveGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 500, 0, 320)
    frame.Position = UDim2.new(0.5, -250, 0.5, -160)
    frame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(140, 50, 210)
    stroke.Thickness = 1.5

    local topBar = Instance.new("Frame", frame)
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = L.Title
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(210, 130, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local dragging, dragInput, dragStart, startPos
    local function setupDrag(targetObj)
        targetObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = targetObj.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        targetObj.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
    end

    setupDrag(frame)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if frame.Visible then
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(1, 0, 1, -42)
    container.Position = UDim2.new(0, 0, 0, 42)
    container.BackgroundTransparency = 1

    local closeScriptBtn = Instance.new("TextButton", topBar)
    closeScriptBtn.Size = UDim2.new(0, 32, 0, 32)
    closeScriptBtn.Position = UDim2.new(1, -40, 0, 5)
    closeScriptBtn.BackgroundTransparency = 1
    closeScriptBtn.Text = "X"
    closeScriptBtn.Font = Enum.Font.GothamBold
    closeScriptBtn.TextSize = 16
    closeScriptBtn.TextColor3 = Color3.fromRGB(220, 80, 80)

    closeScriptBtn.Activated:Connect(function()
        showConfirmDialog(L.ConfirmTitle, L.ConfirmMsg, L.ConfirmYes, L.ConfirmNo, function()
            stopAllRoutines()
            if playerGui:FindFirstChild("MultiDriveGui") then playerGui.MultiDriveGui:Destroy() end
        end, nil)
    end)

    local minimizeBtn = Instance.new("TextButton", topBar)
    minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    minimizeBtn.Position = UDim2.new(1, -72, 0, 7)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    minimizeBtn.BackgroundTransparency = 0.2
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 14
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

    local floatingBall = Instance.new("ImageButton", screenGui)
    floatingBall.Size = UDim2.new(0, 46, 0, 46)
    floatingBall.Position = UDim2.new(0, 20, 0.4, 0)
    floatingBall.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
    floatingBall.BackgroundTransparency = 0.15
    -- 已成功替換為你自訂的圖片 ID
    floatingBall.Image = "rbxassetid://112545408366284" 
    floatingBall.Visible = false
    
    Instance.new("UICorner", floatingBall).CornerRadius = UDim.new(0, 10)
    local ballStroke = Instance.new("UIStroke", floatingBall)
    ballStroke.Color = Color3.fromRGB(210, 80, 255)
    ballStroke.Thickness = 2

    local innerCircle = Instance.new("ImageLabel", floatingBall)
    innerCircle.Size = UDim2.new(1, 0, 1, 0)
    innerCircle.Position = UDim2.new(0, 0, 0, 0)
    innerCircle.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    innerCircle.BackgroundTransparency = 0.3
    innerCircle.Image = "rbxassetid://112545408366284"
    Instance.new("UICorner", innerCircle).CornerRadius = UDim.new(1, 0)
    
    local innerStroke = Instance.new("UIStroke", innerCircle)
    innerStroke.Color = Color3.fromRGB(210, 80, 255)
    innerStroke.Thickness = 1.8

    local ballDragging, ballDragInput, ballDragStart, ballStartPos
    floatingBall.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ballDragging = true
            ballDragStart = input.Position
            ballStartPos = floatingBall.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then ballDragging = false end
            end)
        end
    end)
    floatingBall.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            ballDragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == ballDragInput and ballDragging and floatingBall.Visible then
            local delta = input.Position - ballDragStart
            floatingBall.Position = UDim2.new(ballStartPos.X.Scale, ballStartPos.X.Offset + delta.X, ballStartPos.Y.Scale, ballStartPos.Y.Offset + delta.Y)
        end
    end)

    local isMinimized = false
    local function toggleMinimize()
        isMinimized = not isMinimized
        container.Visible = not isMinimized
        topBar.Visible = not isMinimized
        frame.Visible = not isMinimized
        floatingBall.Visible = isMinimized

        if isMinimized then
            floatingBall.Position = frame.Position
        else
            frame.Position = floatingBall.Position
            frame.Size = UDim2.new(0, 500, 0, 320)
            stroke.Color = Color3.fromRGB(140, 50, 210)
        end
    end

    minimizeBtn.Activated:Connect(toggleMinimize)
    
    local clickCheckPos
    floatingBall.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            clickCheckPos = input.Position
        end
    end)
    floatingBall.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and clickCheckPos then
            if (input.Position - clickCheckPos).Magnitude < 8 then
                toggleMinimize()
            end
        end
    end)

    local sidebar = Instance.new("ScrollingFrame", container)
    sidebar.Size = UDim2.new(0, 140, 1, -12)
    sidebar.Position = UDim2.new(0, 10, 0, 6)
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    sidebar.BackgroundTransparency = 0.35
    sidebar.BorderSizePixel = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 260)
    sidebar.ScrollBarThickness = 4
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    sidebar.Selectable = true
    sidebar.Active = true
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

    local contentArea = Instance.new("Frame", container)
    contentArea.Size = UDim2.new(1, -162, 1, -12)
    contentArea.Position = UDim2.new(0, 156, 0, 6)
    contentArea.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    contentArea.BackgroundTransparency = 0.35
    contentArea.BorderSizePixel = 0
    Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 10)

    local panel0 = Instance.new("ScrollingFrame", contentArea)
    local panelLog = Instance.new("ScrollingFrame", contentArea)
    local panel1 = Instance.new("ScrollingFrame", contentArea)
    local panel2 = Instance.new("ScrollingFrame", contentArea)
    local panel3 = Instance.new("ScrollingFrame", contentArea)

    local function setupPanel(p, canvasHeight)
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.CanvasSize = UDim2.new(0, 0, 0, canvasHeight or 320)
        p.ScrollBarThickness = 3
        p.Visible = false
    end
    setupPanel(panel0, 260)
    setupPanel(panelLog, 520)
    setupPanel(panel1, 200)
    setupPanel(panel2, 250)
    setupPanel(panel3, 310)

    local function createTabButton(name, yPos)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, -14, 0, 38)
        btn.Position = UDim2.new(0, 7, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.BackgroundTransparency = 0.3
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(160, 160, 180)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        return btn
    end

    local tabBtn0 = createTabButton(L.Tab0, 8)
    local tabBtnLog = createTabButton(L.TabLog, 52)
    local tabBtn1 = createTabButton(L.Tab1, 96)
    local tabBtn2 = createTabButton(L.Tab2, 140)
    local tabBtn3 = createTabButton(L.Tab3, 184)

    local function switchTab(activePanel, activeBtn)
        panel0.Visible = false panelLog.Visible = false panel1.Visible = false panel2.Visible = false panel3.Visible = false
        activePanel.Visible = true

        for _, b in ipairs({tabBtn0, tabBtnLog, tabBtn1, tabBtn2, tabBtn3}) do
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            b.BackgroundTransparency = 0.3
            b.TextColor3 = Color3.fromRGB(160, 160, 180)
        end
        activeBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 190)
        activeBtn.BackgroundTransparency = 0.15
        activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    tabBtn0.Activated:Connect(function() switchTab(panel0, tabBtn0) end)
    tabBtnLog.Activated:Connect(function() switchTab(panelLog, tabBtnLog) end)
    tabBtn1.Activated:Connect(function() switchTab(panel1, tabBtn1) end)
    tabBtn2.Activated:Connect(function() switchTab(panel2, tabBtn2) end)
    tabBtn3.Activated:Connect(function() switchTab(panel3, tabBtn3) end)
    switchTab(panel0, tabBtn0)

    local authorLabel = Instance.new("TextLabel", panel0)
    authorLabel.Size = UDim2.new(1, -24, 1, -20)
    authorLabel.Position = UDim2.new(0, 12, 0, 12)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Text = L.AuthorContent
    authorLabel.Font = Enum.Font.Gotham
    authorLabel.TextSize = 12
    authorLabel.TextColor3 = Color3.fromRGB(190, 190, 210)
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.TextYAlignment = Enum.TextYAlignment.Top
    authorLabel.TextWrapped = true

    local logHeader = Instance.new("TextLabel", panelLog)
    logHeader.Size = UDim2.new(1, 0, 0, 30)
    logHeader.Position = UDim2.new(0, 0, 0, 10)
    logHeader.BackgroundTransparency = 1
    logHeader.Text = "[📜更新日誌📜]"
    logHeader.Font = Enum.Font.GothamBold
    logHeader.TextSize = 16
    logHeader.TextColor3 = Color3.fromRGB(220, 130, 255)
    logHeader.TextXAlignment = Enum.TextXAlignment.Center

    local function createAccordionVersion(versionTitle, contentText, defaultOpen, yPos)
        local containerFrame = Instance.new("Frame", panelLog)
        containerFrame.Size = UDim2.new(1, -24, 0, defaultOpen and 85 or 42)
        containerFrame.Position = UDim2.new(0, 12, 0, yPos)
        containerFrame.BackgroundTransparency = 1

        local btn = Instance.new("TextButton", containerFrame)
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.Position = UDim2.new(0, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
        btn.BackgroundTransparency = 0.25
        btn.Text = "  " .. versionTitle .. "  (點擊展開/收合)"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(220, 180, 255)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local desc = Instance.new("TextLabel", containerFrame)
        desc.Size = UDim2.new(1, -12, 0, 40)
        desc.Position = UDim2.new(0, 6, 0, 42)
        desc.BackgroundTransparency = 1
        desc.Text = contentText
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 12
        desc.TextColor3 = Color3.fromRGB(200, 200, 220)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextWrapped = true
        desc.Visible = defaultOpen

        local isOpen = defaultOpen
        btn.Activated:Connect(function()
            isOpen = not isOpen
            desc.Visible = isOpen
            containerFrame.Size = UDim2.new(1, -24, 0, isOpen and 85 or 42)
        end)

        return containerFrame
    end

    createAccordionVersion("[v3.3.4]", "• 已成功套用並更新為你自己的專屬圖片 ID (112545408366284)，懸浮按鈕完美顯示！", true, 50)
    createAccordionVersion("[v3.3.3]", "• 修復自訂圖片 ID 無法正常顯示的問題。", false, 142)
    createAccordionVersion("[v3.3.2]", "• 移除車速調整條，還原穩定版自動駕駛邏輯。", false, 234)
    createAccordionVersion("[v3.3.1]", "• 修復自動駕駛開關載入順序問題。", false, 326)

    local adDesc = Instance.new("TextLabel", panel1)
    adDesc.Size = UDim2.new(1, -24, 0, 30)
    adDesc.Position = UDim2.new(0, 12, 0, 10)
    adDesc.BackgroundTransparency = 1
    adDesc.Text = L.AutoDriveDesc
    adDesc.Font = Enum.Font.Gotham
    adDesc.TextSize = 12
    adDesc.TextColor3 = Color3.fromRGB(160, 160, 180)
    adDesc.TextWrapped = true

    local adToggleBtn = Instance.new("TextButton", panel1)
    adToggleBtn.Size = UDim2.new(1, -24, 0, 44)
    adToggleBtn.Position = UDim2.new(0, 12, 0, 52)
    adToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    adToggleBtn.BackgroundTransparency = 0.25
    adToggleBtn.Text = L.Tab1 .. " : " .. L.SwitchOff
    adToggleBtn.Font = Enum.Font.GothamBold
    adToggleBtn.TextSize = 13
    adToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", adToggleBtn).CornerRadius = UDim.new(0, 10)

    local function GetCurrentVehicle()
        return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.SeatPart and player.Character.Humanoid.SeatPart.Parent
    end

    local function TP(cframe)
        local vehicle = GetCurrentVehicle()
        if vehicle and vehicle.PrimaryPart then vehicle:SetPrimaryPartCFrame(cframe) end
    end

    local function VelocityTP(cframe)
        local Car = GetCurrentVehicle()
        if not Car or not Car.PrimaryPart then return end
        
        local speed = 600
        local bg = Instance.new("BodyGyro", Car.PrimaryPart)
        bg.P = 5000 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.CFrame = Car.PrimaryPart.CFrame
        local bv = Instance.new("BodyVelocity", Car.PrimaryPart)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = CFrame.new(Car.PrimaryPart.Position, cframe.p).LookVector * speed
        task.wait((Car.PrimaryPart.Position - cframe.p).Magnitude / speed)
        bv.Velocity = Vector3.new() task.wait(0.1)
        bv:Destroy() bg:Destroy()
    end

    adToggleBtn.Activated:Connect(function()
        isAutoDriving = not isAutoDriving
        _G.AutoFarm = isAutoDriving
        if isAutoDriving then
            adToggleBtn.Text = L.Tab1 .. " : " .. L.SwitchOn
            adToggleBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 190)
            adToggleBtn.BackgroundTransparency = 0.15
        else
            adToggleBtn.Text = L.Tab1 .. " : " .. L.SwitchOff
            adToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            adToggleBtn.BackgroundTransparency = 0.25
        end
    end)

    table.insert(activeConnections, task.spawn(function()
        while true do
            task.wait()
            if _G.AutoFarm then
                pcall(function()
                    if GetCurrentVehicle() then
                        local offset = Vector3.new(0, -5, 0)
                        TP(StartPosition + offset)
                        VelocityTP(EndPosition + offset)
                        TP(EndPosition + offset)
                        VelocityTP(StartPosition + offset)
                    end
                end)
            end
        end
    end))

    local dlDesc = Instance.new("TextLabel", panel2)
    dlDesc.Size = UDim2.new(1, -24, 0, 30)
    dlDesc.Position = UDim2.new(0, 12, 0, 12)
    dlDesc.BackgroundTransparency = 1
    dlDesc.Text = L.DeliveryDesc
    dlDesc.Font = Enum.Font.Gotham
    dlDesc.TextSize = 12
    dlDesc.TextColor3 = Color3.fromRGB(160, 160, 180)
    dlDesc.TextWrapped = true

    local dlToggleBtn = Instance.new("TextButton", panel2)
    dlToggleBtn.Size = UDim2.new(1, -24, 0, 44)
    dlToggleBtn.Position = UDim2.new(0, 12, 0, 52)
    dlToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    dlToggleBtn.BackgroundTransparency = 0.25
    dlToggleBtn.Text = L.Tab2 .. " : " .. L.SwitchOff
    dlToggleBtn.Font = Enum.Font.GothamBold
    dlToggleBtn.TextSize = 13
    dlToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", dlToggleBtn).CornerRadius = UDim.new(0, 10)

    local dlStatusLabel = Instance.new("TextLabel", panel2)
    dlStatusLabel.Size = UDim2.new(1, -24, 0, 24)
    dlStatusLabel.Position = UDim2.new(0, 12, 0, 104)
    dlStatusLabel.BackgroundTransparency = 1
    dlStatusLabel.Text = L.StatusStopped
    dlStatusLabel.Font = Enum.Font.GothamBold
    dlStatusLabel.TextSize = 12
    dlStatusLabel.TextColor3 = Color3.fromRGB(210, 130, 255)

    local function disableSitting(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Sit = false hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
    end
    local function getCharFarm()
        local char = player.Character
        if char then return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid") end
        return nil, nil
    end
    local function startNoclipFarm()
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not isFarmEnabled then return end
            local char = player.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end)
    end
    local function startInfiniteJumpFarm()
        if jumpConnection then jumpConnection:Disconnect() end
        jumpConnection = RunService.Heartbeat:Connect(function()
            if not isFarmEnabled then return end
            local _, hum = getCharFarm()
            if hum and hum.Sit then hum.Jump = true end
        end)
    end
    local function travelInAirRectangle(targetPos)
        if isTraveling or not targetPos then return end
        local root = select(1, getCharFarm())
        if not root then return end
        isTraveling = true
        local currentPos = root.Position
        pcall(function()
            local upGoal = CFrame.new(currentPos.X, math.max(currentPos.Y, targetPos.Y) + 15, currentPos.Z)
            local t1 = TweenService:Create(root, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {CFrame = upGoal})
            t1:Play() t1.Completed:Wait()
            if not isFarmEnabled then isTraveling = false return end
            local horizGoal = CFrame.new(targetPos.X, math.max(currentPos.Y, targetPos.Y) + 15, targetPos.Z)
            local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            local t2 = TweenService:Create(root, TweenInfo.new(math.clamp(dist/80, 0.4, 1.8), Enum.EasingStyle.Linear), {CFrame = horizGoal})
            t2:Play() t2.Completed:Wait()
            if not isFarmEnabled then isTraveling = false return end
            local downGoal = CFrame.new(targetPos.X, targetPos.Y + 3, targetPos.Z)
            local t3 = TweenService:Create(root, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {CFrame = downGoal})
            t3:Play() t3.Completed:Wait()
        end)
        isTraveling = false
    end
    local function findRemoteFunction(name)
        local folder = ReplicatedStorage:FindFirstChild("RemoteFunctions", true)
        if folder then
            local rf = folder:FindFirstChild(name)
            if rf then return rf end
        end
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v.Name == name then return v end end
        return nil
    end
    local function invokeRemote(name)
        local rf = findRemoteFunction(name)
        if not rf then return false end
        local ok, ret = pcall(function()
            if rf:IsA("RemoteFunction") then return rf.InvokeServer and rf:InvokeServer()
            elseif rf:IsA("RemoteEvent") then rf:FireServer() return true end
        end)
        return ok and (ret ~= false)
    end
    local function startLoopFarm()
        if loopConnection then loopConnection:Disconnect() end
        local ok, jobModule = pcall(function() return require(ReplicatedStorage:WaitForChild("Modules").Client.Jobs.Tasks.DeliveryJobTask) end)
        if not ok or not jobModule then return end
        jobModule.OnStateChanged:Connect(function(state) jobState = state end)
        loopConnection = RunService.Heartbeat:Connect(function()
            if not isFarmEnabled or not jobState or isTraveling then return end
            local root = select(1, getCharFarm())
            if not root then return end
            local itemsCarried = jobState.ItemsCarried or 0
            local pickupPos = jobState.PickupPosition
            local destPos = jobState.DestinationPosition
            if itemsCarried < maxItems and pickupPos then
                if (root.Position - pickupPos).Magnitude > 8 then travelInAirRectangle(pickupPos)
                else
                    pcall(function() invokeRemote("Pickup") end)
                    task.wait(0.18)
                end
            elseif itemsCarried >= maxItems and destPos then
                if (root.Position - destPos).Magnitude > 8 then travelInAirRectangle(destPos)
                else
                    pcall(function() invokeRemote("Deliver") end)
                    task.wait(0.18)
                end
            end
        end)
    end
    startAllFarm = function()
        task.wait(1)
        pcall(function()
            local ev = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RequestStartJobSession")
            if ev then ev:FireServer("Delivery", "jobPad") end
        end)
        startNoclipFarm() startInfiniteJumpFarm() startLoopFarm()
    end

    dlToggleBtn.Activated:Connect(function()
        isFarmEnabled = not isFarmEnabled
        isDeliveryRunning = isFarmEnabled
        if isFarmEnabled then
            dlToggleBtn.Text = L.Tab2 .. " : " .. L.SwitchOn
            dlToggleBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 190)
            dlToggleBtn.BackgroundTransparency = 0.15
            dlStatusLabel.Text = L.StatusRunning
            if player.Character then disableSitting(player.Character) end
            if charAddedConnection then charAddedConnection:Disconnect() end
            charAddedConnection = player.CharacterAdded:Connect(function(char) disableSitting(char) end)
            if not _G.InitDone then
                pcall(function()
                    maxItems = MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1744052086) and 8 or 4
                end)
                if startAllFarm then startAllFarm() end
                _G.InitDone = true
            else
                startNoclipFarm() startInfiniteJumpFarm() startLoopFarm()
            end
        else
            dlToggleBtn.Text = L.Tab2 .. " : " .. L.SwitchOff
            dlToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            dlToggleBtn.BackgroundTransparency = 0.25
            dlStatusLabel.Text = L.StatusStopped
            if charAddedConnection then charAddedConnection:Disconnect() charAddedConnection = nil end
            if loopConnection then loopConnection:Disconnect() loopConnection = nil end
            if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        end
    end)

    local function createSettingLabel(text, y)
        local lbl = Instance.new("TextLabel", panel3)
        lbl.Size = UDim2.new(1, -24, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = Color3.fromRGB(160, 160, 180)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        return lbl
    end

    createSettingLabel(L.SpeedTip, 10)
    local speedBarFrame = Instance.new("Frame", panel3)
    speedBarFrame.Size = UDim2.new(1, -24, 0, 36)
    speedBarFrame.Position = UDim2.new(0, 12, 0, 30)
    speedBarFrame.BackgroundTransparency = 1

    local walkSpeedBox = Instance.new("TextBox", speedBarFrame)
    walkSpeedBox.Size = UDim2.new(0.48, 0, 1, 0)
    walkSpeedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    walkSpeedBox.BackgroundTransparency = 0.25
    walkSpeedBox.Text = "50"
    walkSpeedBox.Font = Enum.Font.GothamBold
    walkSpeedBox.TextSize = 12
    walkSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", walkSpeedBox).CornerRadius = UDim.new(0, 8)

    local walkSpeedToggleBtn = Instance.new("TextButton", speedBarFrame)
    walkSpeedToggleBtn.Size = UDim2.new(0.48, 0, 1, 0)
    walkSpeedToggleBtn.Position = UDim2.new(0.52, 0, 0, 0)
    walkSpeedToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    walkSpeedToggleBtn.BackgroundTransparency = 0.25
    walkSpeedToggleBtn.Text = L.SwitchOff
    walkSpeedToggleBtn.Font = Enum.Font.GothamBold
    walkSpeedToggleBtn.TextSize = 11
    walkSpeedToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", walkSpeedToggleBtn).CornerRadius = UDim.new(0, 8)

    createSettingLabel(L.JumpTip, 76)
    local jumpBarFrame = Instance.new("Frame", panel3)
    jumpBarFrame.Size = UDim2.new(1, -24, 0, 36)
    jumpBarFrame.Position = UDim2.new(0, 12, 0, 96)
    jumpBarFrame.BackgroundTransparency = 1

    local jumpPowerBox = Instance.new("TextBox", jumpBarFrame)
    jumpPowerBox.Size = UDim2.new(0.48, 0, 1, 0)
    jumpPowerBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    jumpPowerBox.BackgroundTransparency = 0.25
    jumpPowerBox.Text = "50"
    jumpPowerBox.Font = Enum.Font.GothamBold
    jumpPowerBox.TextSize = 12
    jumpPowerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", jumpPowerBox).CornerRadius = UDim.new(0, 8)

    local jumpPowerToggleBtn = Instance.new("TextButton", jumpBarFrame)
    jumpPowerToggleBtn.Size = UDim2.new(0.48, 0, 1, 0)
    jumpPowerToggleBtn.Position = UDim2.new(0.52, 0, 0, 0)
    jumpPowerToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    jumpPowerToggleBtn.BackgroundTransparency = 0.25
    jumpPowerToggleBtn.Text = L.SwitchOff
    jumpPowerToggleBtn.Font = Enum.Font.GothamBold
    jumpPowerToggleBtn.TextSize = 11
    jumpPowerToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", jumpPowerToggleBtn).CornerRadius = UDim.new(0, 8)

    local function createGenericButton(text, yPos, color)
        local btn = Instance.new("TextButton", panel3)
        btn.Size = UDim2.new(1, -24, 0, 38)
        btn.Position = UDim2.new(0, 12, 0, yPos)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.25
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        return btn
    end

    local infiniteJumpBtn = createGenericButton(L.InfJump .. " : " .. L.SwitchOff, 142, Color3.fromRGB(35, 35, 48))
    local afkBtn = createGenericButton(L.AntiAfk .. " : " .. L.SwitchOff, 188, Color3.fromRGB(35, 35, 48))
    local changeLangBtn = createGenericButton(L.LangBtn, 234, Color3.fromRGB(110, 35, 160))

    walkSpeedToggleBtn.Activated:Connect(function()
        isWalkSpeedEnabled = not isWalkSpeedEnabled
        walkSpeedToggleBtn.Text = isWalkSpeedEnabled and L.SwitchOn or L.SwitchOff
        walkSpeedToggleBtn.BackgroundColor3 = isWalkSpeedEnabled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
        walkSpeedToggleBtn.BackgroundTransparency = isWalkSpeedEnabled and 0.15 or 0.25
    end)

    jumpPowerToggleBtn.Activated:Connect(function()
        isJumpPowerEnabled = not isJumpPowerEnabled
        jumpPowerToggleBtn.Text = isJumpPowerEnabled and L.SwitchOn or L.SwitchOff
        jumpPowerToggleBtn.BackgroundColor3 = isJumpPowerEnabled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
        jumpPowerToggleBtn.BackgroundTransparency = isJumpPowerEnabled and 0.15 or 0.25
    end)

    infiniteJumpBtn.Activated:Connect(function()
        isInfiniteJumpEnabled = not isInfiniteJumpEnabled
        infiniteJumpBtn.Text = L.InfJump .. " : " .. (isInfiniteJumpEnabled and L.SwitchOn or L.SwitchOff)
        infiniteJumpBtn.BackgroundColor3 = isInfiniteJumpEnabled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
        infiniteJumpBtn.BackgroundTransparency = isInfiniteJumpEnabled and 0.15 or 0.25
    end)

    afkBtn.Activated:Connect(function()
        isAntiAfkEnabled = not isAntiAfkEnabled
        afkBtn.Text = L.AntiAfk .. " : " .. (isAntiAfkEnabled and L.SwitchOn or L.SwitchOff)
        afkBtn.BackgroundColor3 = isAntiAfkEnabled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
        afkBtn.BackgroundTransparency = isAntiAfkEnabled and 0.15 or 0.25
    end)

    changeLangBtn.Activated:Connect(function() showLanguageSelector() end)

    table.insert(activeConnections, UserInputService.JumpRequest:Connect(function()
        if isInfiniteJumpEnabled then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end))

    table.insert(activeConnections, RunService.RenderStepped:Connect(function()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if isWalkSpeedEnabled then hum.WalkSpeed = math.clamp(tonumber(walkSpeedBox.Text) or 50, 16, 200) end
            if isJumpPowerEnabled then hum.UseJumpPower = true hum.JumpPower = math.clamp(tonumber(jumpPowerBox.Text) or 50, 50, 100) end
        end
        if isAntiAfkEnabled and tick() % 30 < 0.1 then
            pcall(function()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end))
end

showLanguageSelector()

