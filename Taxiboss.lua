--[[
	KrisVan Script (Special Ed.) - v1.0.0
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isAntiAfkEnabled = false
local activeConnections = {}

local function stopAllRoutines()
    isAntiAfkEnabled = false
    getfenv().Trophies = false
    getfenv().medals = false
    getfenv().customersfarm = false
    getfenv().partcollector = false

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
local showLanguageSelector

local function playStartupLoadingScreen(onFinished)
    local loadGui = Instance.new("ScreenGui")
    loadGui.Name = "KrisVanLoadingScreen"
    loadGui.ResetOnSpawn = false
    loadGui.IgnoreGuiInset = true
    loadGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame", loadGui)
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0

    local pulseGlow = Instance.new("Frame", mainFrame)
    pulseGlow.Size = UDim2.new(0, 260, 0, 260)
    pulseGlow.Position = UDim2.new(0.5, -130, 0.5, -150)
    pulseGlow.BackgroundColor3 = Color3.fromRGB(160, 30, 255)
    pulseGlow.BackgroundTransparency = 1
    Instance.new("UICorner", pulseGlow).CornerRadius = UDim.new(1, 0)

    local ringOuter = Instance.new("Frame", mainFrame)
    ringOuter.Size = UDim2.new(0, 110, 0, 110)
    ringOuter.Position = UDim2.new(0.5, -55, 0.5, -75)
    ringOuter.BackgroundTransparency = 1
    Instance.new("UICorner", ringOuter).CornerRadius = UDim.new(1, 0)

    local ringStroke = Instance.new("UIStroke", ringOuter)
    ringStroke.Color = Color3.fromRGB(200, 80, 255)
    ringStroke.Thickness = 3
    ringStroke.Transparency = 1

    local ringInner = Instance.new("Frame", ringOuter)
    ringInner.Size = UDim2.new(0, 70, 0, 70)
    ringInner.Position = UDim2.new(0.5, -35, 0.5, -35)
    ringInner.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    ringInner.BackgroundTransparency = 1
    Instance.new("UICorner", ringInner).CornerRadius = UDim.new(1, 0)

    local innerStroke = Instance.new("UIStroke", ringInner)
    innerStroke.Color = Color3.fromRGB(100, 200, 255)
    innerStroke.Thickness = 1.5
    innerStroke.Transparency = 1

    local titleLabelLoad = Instance.new("TextLabel", mainFrame)
    titleLabelLoad.Size = UDim2.new(0, 400, 0, 50)
    titleLabelLoad.Position = UDim2.new(0.5, -200, 0.5, 25)
    titleLabelLoad.BackgroundTransparency = 1
    titleLabelLoad.Text = "KrisVan Script v1.0.0"
    titleLabelLoad.Font = Enum.Font.GothamBold
    titleLabelLoad.TextSize = 32
    titleLabelLoad.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabelLoad.TextTransparency = 1
    titleLabelLoad.TextXAlignment = Enum.TextXAlignment.Center

    local subTitle = Instance.new("TextLabel", mainFrame)
    subTitle.Size = UDim2.new(0, 400, 0, 20)
    subTitle.Position = UDim2.new(0.5, -200, 0.5, 68)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = "INITIALIZING CORE..."
    subTitle.Font = Enum.Font.Code
    subTitle.TextSize = 11
    subTitle.TextColor3 = Color3.fromRGB(150, 120, 200)
    subTitle.TextTransparency = 1
    subTitle.TextXAlignment = Enum.TextXAlignment.Center

    task.spawn(function()
        task.wait(1.0)
        local fadeInInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(mainFrame, fadeInInfo, {BackgroundTransparency = 0.35}):Play()
        TweenService:Create(pulseGlow, fadeInInfo, {BackgroundTransparency = 0.85}):Play()
        TweenService:Create(ringStroke, fadeInInfo, {Transparency = 0.2}):Play()
        TweenService:Create(innerStroke, fadeInInfo, {Transparency = 0}):Play()
        TweenService:Create(ringInner, fadeInInfo, {BackgroundTransparency = 0.3}):Play()
        TweenService:Create(titleLabelLoad, fadeInInfo, {TextTransparency = 0}):Play()
        TweenService:Create(subTitle, fadeInInfo, {TextTransparency = 0}):Play()

        local active = true
        task.spawn(function()
            local t = 0
            while active do
                t = t + RunService.RenderStepped:Wait()
                ringOuter.Rotation = ringOuter.Rotation + 3
                pulseGlow.Size = UDim2.new(0, 260 + math.sin(t * 4) * 30, 0, 260 + math.sin(t * 4) * 30)
                pulseGlow.Position = UDim2.new(0.5, -pulseGlow.AbsoluteSize.X/2, 0.5, -pulseGlow.AbsoluteSize.Y/2 - 20)
            end
        end)

        task.wait(1.5)
        subTitle.Text = "READY"
        task.wait(2.0)
        active = false
        
        local fadeOutInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(mainFrame, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(pulseGlow, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(ringStroke, fadeOutInfo, {Transparency = 1}):Play()
        TweenService:Create(innerStroke, fadeOutInfo, {Transparency = 1}):Play()
        TweenService:Create(ringInner, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLabelLoad, fadeOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(subTitle, fadeOutInfo, {TextTransparency = 1}):Play()

        task.wait(0.6)
        loadGui:Destroy()
        if onFinished then onFinished() end
    end)
end

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

showLanguageSelector = function()
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
            Title = "⚔️ KrisVan 遊戲輔助 v1.0.0",
            Tab0 = "👤 作者資訊",
            TabLog = "📋 更新日誌",
            TabAutoTrophies = "🏆 自動獎盃",
            TabAutoMedals = "🏅 計時賽獎牌",
            TabAutoCustomers = "🚗 自動載客",
            TabAutoParts = "📦 收集零件",
            Tab1 = "⚙️ 其他設定",
            SwitchOff = "關閉",
            SwitchOn = "開啟",
            AuthorContent = "【 作者資訊 】\n• 作者 / 開發者：KrisVan\n• 功能：專為 Roblox 打造的強大輔助介面。\n• 感謝您的使用與支持！",
            LogHeader = "[📋 更新日誌 📋]",
            LogClickHint = " (點擊展開/收合)",
            Logs = {
                {version = "v1.0.0", details = "• 初始版本發布\n• 整合自動獎盃、計時賽獎牌、載客與零件收集功能"}
            },
            AntiAfk = "防掛機保護",
            RejoinBtn = "🔄 重新加入遊戲",
            LangBtn = "🌐 切換語言",
            MenuBtn = "🏠 返回遊戲選單",
            MenuConfirmTitle = "⚠️ 返回確認",
            MenuConfirmMsg = "是否返回遊戲選單？",
            ConfirmYes = "確認",
            ConfirmNo = "取消",
            ScriptConfirmTitle = "⚠️ 關閉確認",
            ScriptConfirmMsg = "確定要關閉輔助腳本嗎？"
        }
    elseif selectedLanguage == "CN" then
        L = {
            Title = "⚔️ KrisVan 游戏辅助 v1.0.0",
            Tab0 = "👤 作者信息",
            TabLog = "📋 更新日志",
            TabAutoTrophies = "🏆 自动奖杯",
            TabAutoMedals = "🏅 计时赛奖牌",
            TabAutoCustomers = "🚗 自动载客",
            TabAutoParts = "📦 收集零件",
            Tab1 = "⚙️ 其他设定",
            SwitchOff = "关闭",
            SwitchOn = "开启",
            AuthorContent = "【 作者信息 】\n• 作者 / 开发者：KrisVan\n• 功能：专为 Roblox 打造的强大辅助界面。\n• 感谢您的使用与支持！",
            LogHeader = "[📋 更新日志 📋]",
            LogClickHint = " (点击展开/收合)",
            Logs = {
                {version = "v1.0.0", details = "• 初始版本发布\n• 整合自动奖杯、计时赛奖牌、载客与零件收集功能"}
            },
            AntiAfk = "防挂机保护",
            RejoinBtn = "🔄 重新加入游戏",
            LangBtn = "🌐 切换语言",
            MenuBtn = "🏠 返回游戏菜单",
            MenuConfirmTitle = "⚠️ 返回确认",
            MenuConfirmMsg = "是否返回游戏菜单？",
            ConfirmYes = "确认",
            ConfirmNo = "取消",
            ScriptConfirmTitle = "⚠️ 关闭确认",
            ScriptConfirmMsg = "确定要关闭辅助脚本吗？"
        }
    else
        L = {
            Title = "⚔️ KrisVan Script v1.0.0",
            Tab0 = "👤 Author",
            TabLog = "📋 Changelog",
            TabAutoTrophies = "🏆 Auto Trophies",
            TabAutoMedals = "🏅 TT Medals",
            TabAutoCustomers = "🚗 Auto Customers",
            TabAutoParts = "📦 Collect Parts",
            Tab1 = "⚙️ Settings",
            SwitchOff = "OFF",
            SwitchOn = "ON",
            AuthorContent = "[ Author Information ]\n• Author: KrisVan\n• Description: Advanced utility script for Roblox.\n• Thank you for using!",
            LogHeader = "[📋 Changelog 📋]",
            LogClickHint = " (Click to toggle)",
            Logs = {
                {version = "v1.0.0", details = "• Initial release\n• Integrated auto trophies, medals, customers & parts features"}
            },
            AntiAfk = "Anti-AFK Protection",
            RejoinBtn = "🔄 Rejoin Game",
            LangBtn = "🌐 Change Lang",
            MenuBtn = "🏠 Return to Menu",
            MenuConfirmTitle = "⚠️ Return Confirm",
            MenuConfirmMsg = "Return to game menu?",
            ConfirmYes = "Confirm",
            ConfirmNo = "Cancel",
            ScriptConfirmTitle = "⚠️ Confirm Close",
            ScriptConfirmMsg = "Are you sure to close script?"
        }
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MultiDriveGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 520, 0, 340)
    frame.Position = UDim2.new(0.5, -260, 0.5, -170)
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
        showConfirmDialog(L.ScriptConfirmTitle, L.ScriptConfirmMsg, "是", "否", function()
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
            frame.Size = UDim2.new(0, 520, 0, 340)
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
    sidebar.Size = UDim2.new(0, 135, 1, -12)
    sidebar.Position = UDim2.new(0, 10, 0, 6)
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    sidebar.BackgroundTransparency = 0.35
    sidebar.BorderSizePixel = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 260)
    sidebar.ScrollBarThickness = 3
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    sidebar.Selectable = true
    sidebar.Active = true
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

    local contentArea = Instance.new("Frame", container)
    contentArea.Size = UDim2.new(1, -157, 1, -12)
    contentArea.Position = UDim2.new(0, 153, 0, 6)
    contentArea.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    contentArea.BackgroundTransparency = 0.35
    contentArea.BorderSizePixel = 0
    Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 10)

    local panel0 = Instance.new("ScrollingFrame", contentArea)
    local panelLog = Instance.new("ScrollingFrame", contentArea)
    local panelAutoTrophies = Instance.new("ScrollingFrame", contentArea)
    local panelAutoMedals = Instance.new("ScrollingFrame", contentArea)
    local panelAutoCustomers = Instance.new("ScrollingFrame", contentArea)
    local panelAutoParts = Instance.new("ScrollingFrame", contentArea)
    local panel1 = Instance.new("ScrollingFrame", contentArea)

    local function setupPanel(p, canvasHeight)
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.CanvasSize = UDim2.new(0, 0, 0, canvasHeight or 320)
        p.ScrollBarThickness = 3
        p.Visible = false
    end
    setupPanel(panel0, 260)
    setupPanel(panelLog, 450)
    setupPanel(panelAutoTrophies, 260)
    setupPanel(panelAutoMedals, 260)
    setupPanel(panelAutoCustomers, 260)
    setupPanel(panelAutoParts, 260)
    setupPanel(panel1, 260)

    local function createTabButton(name, yPos)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, -12, 0, 36)
        btn.Position = UDim2.new(0, 6, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.BackgroundTransparency = 0.3
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(160, 160, 180)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        return btn
    end

    local tabBtn0 = createTabButton(L.Tab0, 8)
    local tabBtnLog = createTabButton(L.TabLog, 48)
    local tabBtnAutoTrophies = createTabButton(L.TabAutoTrophies, 88)
    local tabBtnAutoMedals = createTabButton(L.TabAutoMedals, 128)
    local tabBtnAutoCustomers = createTabButton(L.TabAutoCustomers, 168)
    local tabBtnAutoParts = createTabButton(L.TabAutoParts, 208)
    local tabBtn1 = createTabButton(L.Tab1, 248)
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 294)

    local allPanels = {panel0, panelLog, panelAutoTrophies, panelAutoMedals, panelAutoCustomers, panelAutoParts, panel1}
    local allTabBtns = {tabBtn0, tabBtnLog, tabBtnAutoTrophies, tabBtnAutoMedals, tabBtnAutoCustomers, tabBtnAutoParts, tabBtn1}

    local function switchTab(activePanel, activeBtn)
        for _, p in ipairs(allPanels) do p.Visible = false end
        activePanel.Visible = true

        for _, b in ipairs(allTabBtns) do
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
    tabBtnAutoTrophies.Activated:Connect(function() switchTab(panelAutoTrophies, tabBtnAutoTrophies) end)
    tabBtnAutoMedals.Activated:Connect(function() switchTab(panelAutoMedals, tabBtnAutoMedals) end)
    tabBtnAutoCustomers.Activated:Connect(function() switchTab(panelAutoCustomers, tabBtnAutoCustomers) end)
    tabBtnAutoParts.Activated:Connect(function() switchTab(panelAutoParts, tabBtnAutoParts) end)
    tabBtn1.Activated:Connect(function() switchTab(panel1, tabBtn1) end)
    switchTab(panel0, tabBtn0)

    -- Panel 0 (作者資訊)
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

    -- Panel Log (更新日誌)
    local logHeaderTitle = Instance.new("TextLabel", panelLog)
    logHeaderTitle.Size = UDim2.new(1, -24, 0, 30)
    logHeaderTitle.Position = UDim2.new(0, 12, 0, 10)
    logHeaderTitle.BackgroundTransparency = 1
    logHeaderTitle.Text = L.LogHeader
    logHeaderTitle.Font = Enum.Font.GothamBold
    logHeaderTitle.TextSize = 14
    logHeaderTitle.TextColor3 = Color3.fromRGB(220, 130, 255)
    logHeaderTitle.TextXAlignment = Enum.TextXAlignment.Center

    local logFrames = {}
    local function updateLogLayout()
        local currentY = 50
        for _, info in ipairs(logFrames) do
            info.frame.Position = UDim2.new(0, 12, 0, currentY)
            local currentHeight = info.isExpanded and 115 or 38
            info.frame.Size = UDim2.new(1, -24, 0, currentHeight)
            currentY = currentY + currentHeight + 8
        end
        panelLog.CanvasSize = UDim2.new(0, 0, 0, currentY + 20)
    end

    for _, logData in ipairs(L.Logs) do
        local itemFrame = Instance.new("Frame", panelLog)
        itemFrame.Size = UDim2.new(1, -24, 0, 38)
        itemFrame.BackgroundColor3 = Color3.fromRGB(24, 20, 35)
        itemFrame.BackgroundTransparency = 0.3
        itemFrame.ClipsDescendants = true
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 8)

        local itemBtn = Instance.new("TextButton", itemFrame)
        itemBtn.Size = UDim2.new(1, 0, 0, 38)
        itemBtn.BackgroundTransparency = 1
        itemBtn.Text = "  " .. logData.version .. L.LogClickHint
        itemBtn.Font = Enum.Font.GothamBold
        itemBtn.TextSize = 12
        itemBtn.TextColor3 = Color3.fromRGB(210, 180, 255)
        itemBtn.TextXAlignment = Enum.TextXAlignment.Left

        local detailLabel = Instance.new("TextLabel", itemFrame)
        detailLabel.Size = UDim2.new(1, -20, 0, 65)
        detailLabel.Position = UDim2.new(0, 10, 0, 42)
        detailLabel.BackgroundTransparency = 1
        detailLabel.Text = logData.details
        detailLabel.Font = Enum.Font.Gotham
        detailLabel.TextSize = 11
        detailLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        detailLabel.TextXAlignment = Enum.TextXAlignment.Left
        detailLabel.TextYAlignment = Enum.TextYAlignment.Top
        detailLabel.TextWrapped = true

        local logInfo = {frame = itemFrame, isExpanded = false}
        table.insert(logFrames, logInfo)

        itemBtn.Activated:Connect(function()
            logInfo.isExpanded = not logInfo.isExpanded
            local targetHeight = logInfo.isExpanded and 115 or 38
            TweenService:Create(itemFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -24, 0, targetHeight)}):Play()
            task.spawn(function()
                task.wait(0.28)
                updateLogLayout()
            end)
            updateLogLayout()
        end)
    end
    updateLogLayout()

    -- 輔助建立開關按鈕函數
    local function createToggleButton(parentPanel, text, yPos, callback)
        local btn = Instance.new("TextButton", parentPanel)
        btn.Size = UDim2.new(1, -24, 0, 42)
        btn.Position = UDim2.new(0, 12, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        btn.BackgroundTransparency = 0.25
        btn.Text = text .. " : " .. L.SwitchOff
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local toggled = false
        btn.Activated:Connect(function()
            toggled = not toggled
            btn.Text = text .. " : " .. (toggled and L.SwitchOn or L.SwitchOff)
            btn.BackgroundColor3 = toggled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
            btn.BackgroundTransparency = toggled and 0.15 or 0.25
            pcall(function()
                callback(toggled)
            end)
        end)
        return btn
    end

    -- 1. Auto Trophies 功能整合
    createToggleButton(panelAutoTrophies, "Auto Trophies", 15, function(state)
        getfenv().Trophies = (state and true or false)
        game:GetService("ReplicatedStorage").Race.LeaveRace:InvokeServer()
        getfenv().showui = getfenv().Trophies
        task.spawn(function()
             if getfenv().showui == false and game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Money:FindFirstChild("Rep") then
                  game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Money.Rep:Destroy()
             else
                  while getfenv().showui do
                      task.wait()
                      if not game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Money:FindFirstChild("Rep") then
                          local oh = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Money.CashLabel:Clone()
                          oh.Name = "Rep"
                          oh.Parent = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Money
                          task.wait()
                          game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Money.Rep.Position = UDim2.new(3,0,0,0)
                      else
                          game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Money.Rep.Text = "Rep:"..tostring(game:GetService("Players").LocalPlayer.variables.rep.Value)
                      end
                  end
             end
        end) 
        task.spawn(function()
            while getfenv().Trophies do
                 task.wait()
                 pcall(function()
                     if game.Players.LocalPlayer.Character.Humanoid.Sit == true then
                         if game:GetService("Players").LocalPlayer.variables.race.Value == "none" then
                             task.wait()
                             game:GetService("ReplicatedStorage").Race.TimeTrial:InvokeServer("circuit", 5)
                         else
                             for a,b in pairs(game:GetService("Workspace").Vehicles:GetDescendants()) do
                                 if b.Name == "Player" and b.Value == game.Players.LocalPlayer then
                                     for i,v in pairs(game:GetService("Workspace").Races["circuit"].detects:GetChildren()) do
                                         if v.ClassName == "Part" and v:FindFirstChild("TouchInterest") then
                                             v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                             firetouchinterest(b.Parent.Parent.PrimaryPart,v,0)
                                             firetouchinterest(b.Parent.Parent.PrimaryPart,v,1)
                                         end
                                     end
                                     game:GetService("Workspace").Races["circuit"].timeTrial:FindFirstChildOfClass("IntValue").finish.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                     firetouchinterest(b.Parent.Parent.PrimaryPart,game:GetService("Workspace").Races["circuit"].timeTrial:FindFirstChildOfClass("IntValue").finish,0)
                                     firetouchinterest(b.Parent.Parent.PrimaryPart,game:GetService("Workspace").Races["circuit"].timeTrial:FindFirstChildOfClass("IntValue").finish,1)
                                 end
                             end   
                         end
                     elseif game.Players.LocalPlayer.Character.Humanoid.Sit == false then
                         game:GetService("ReplicatedStorage").Vehicles.GetNearestSpot:InvokeServer(game:GetService("Players").LocalPlayer.variables.carId.Value)
                         task.wait(0.5)
                         game:GetService("ReplicatedStorage").Vehicles.EnterVehicleEvent:InvokeServer()
                     end
                 end)
            end
        end)
    end)

    -- 2. Auto TimeTrial Medals 功能整合
    createToggleButton(panelAutoMedals, "Auto TimeTrial Medals", 15, function(state)
        getfenv().medals = (state and true or false)
        game:GetService("ReplicatedStorage").Race.LeaveRace:InvokeServer()
        task.spawn(function()
            while getfenv().medals do
                 task.wait()
                 if game.Players.LocalPlayer.Character.Humanoid.Sit == true then
                     for round=1,3 do
                         for what,races in pairs(game:GetService("Workspace").Races:GetChildren()) do
                             if races.ClassName == "Folder" and getfenv().medals then
                                 game:GetService("ReplicatedStorage").Race.TimeTrial:InvokeServer(races.Name, round)
                                 task.wait()
                                 if game:GetService("Players").LocalPlayer.variables.race.Value == "none" then
                                     task.wait()
                                     game:GetService("ReplicatedStorage").Race.TimeTrial:InvokeServer(races.Name, round)
                                 else
                                     for a,b in pairs(game:GetService("Workspace").Vehicles:GetDescendants()) do
                                         if b.Name == "Player" and b.Value == game.Players.LocalPlayer then
                                             repeat task.wait()
                                                 for i,v in pairs(game:GetService("Workspace").Races[races.Name].detects:GetChildren()) do
                                                     if v.ClassName == "Part" and v:FindFirstChild("TouchInterest") then
                                                         v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                                         firetouchinterest(b.Parent.Parent.PrimaryPart,v,0)
                                                         firetouchinterest(b.Parent.Parent.PrimaryPart,v,1)
                                                     end
                                                 end
                                             until game:GetService("Workspace").Races[races.Name].timeTrial:FindFirstChildOfClass("IntValue") or getfenv().medals == false
                                             
                                             repeat task.wait()
                                                 for i,v in pairs(game:GetService("Workspace").Races[races.Name].detects:GetChildren()) do
                                                     if v.ClassName == "Part" and v:FindFirstChild("TouchInterest") then
                                                         v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                                         firetouchinterest(b.Parent.Parent.PrimaryPart,v,0)
                                                         firetouchinterest(b.Parent.Parent.PrimaryPart,v,1)
                                                     end
                                                 end
                                                 pcall(function()
                                                     game:GetService("Workspace").Races[races.Name].timeTrial:FindFirstChildOfClass("IntValue").finish.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                                     firetouchinterest(b.Parent.Parent.PrimaryPart,game:GetService("Workspace").Races[races.Name].timeTrial:FindFirstChildOfClass("IntValue").finish,0)
                                                     firetouchinterest(b.Parent.Parent.PrimaryPart,game:GetService("Workspace").Races[races.Name].timeTrial:FindFirstChildOfClass("IntValue").finish,1)
                                                 end)
                                             until game:GetService("Players").LocalPlayer.variables.race.Value == "none" or getfenv().medals == false
                                         end
                                     end 
                                 end
                             end
                         end
                     end
                 elseif game.Players.LocalPlayer.Character.Humanoid.Sit == false then
                     game:GetService("ReplicatedStorage").Vehicles.GetNearestSpot:InvokeServer(game:GetService("Players").LocalPlayer.variables.carId.Value)
                     task.wait(0.5)
                     game:GetService("ReplicatedStorage").Vehicles.EnterVehicleEvent:InvokeServer()
                 end
            end
        end)
    end)

    -- 3. Auto Customers 功能整合
    createToggleButton(panelAutoCustomers, "Auto Customers[Beta]", 15, function(state)
        getfenv().customersfarm = (state and true or false)
        pcall(function()
           game:GetService("Workspace").GaragePlate:Destroy()
        end)
        for i,v in pairs(game:GetService("Workspace").World.Industrial.Port:GetChildren()) do
            if string.find(v.Name,"Container") then
               v:Destroy()
            end
        end
        getfenv().numbers = 0
        getfenv().stuck = 0
        local testvalue = 1
        local ohsoso = false
        local antiban = 0
        task.spawn(function()
            while getfenv().customersfarm do
                task.wait()
                pcall(function()
                    if game.Players.LocalPlayer.Character.Humanoid.SeatPart ~= nil then
                        local chr = game.Players.LocalPlayer.Character
                        local car = chr.Humanoid.SeatPart.Parent.Parent
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {chr,car,workspace.Camera}
                        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                        raycastParams.IgnoreWater = false
                        ohsoso = false
                        if game:GetService("Players").LocalPlayer.variables.inMission.Value == true and not game:GetService("Workspace").ParkingMarkers:FindFirstChild("destinationPart") then
                            antiban=antiban+1
                            task.wait(1)
                        elseif antiban > 10 then
                            game.Players.LocalPlayer:Kick("Kicked Due to game being glitched")
                        end
                        if game:GetService("Players").LocalPlayer.variables.inMission.Value == true and game:GetService("Workspace").ParkingMarkers:FindFirstChild("destinationPart") and game.Players.LocalPlayer:DistanceFromCharacter(game:GetService("Workspace").ParkingMarkers:WaitForChild("destinationPart").Position) < 50 then
                            testvalue = 1
                            car:SetPrimaryPartCFrame(game:GetService("Workspace").ParkingMarkers.destinationPart.CFrame+Vector3.new(0,3,0))
                            car.PrimaryPart.Velocity = Vector3.new(0,0,0)
                            game:GetService("VirtualInputManager"):SendKeyEvent(true,304,false,game)
                            task.wait(1)
                            car:SetPrimaryPartCFrame(game:GetService("Workspace").ParkingMarkers.destinationPart.CFrame+Vector3.new(0,3,0))
                            car.PrimaryPart.Velocity = Vector3.new(0,0,0)
                            game:GetService("VirtualInputManager"):SendKeyEvent(true,304,false,game)
                            task.wait()
                            local dcframe = game:GetService("Workspace").ParkingMarkers.destinationPart.CFrame
                            repeat task.wait()
                                if (car.PrimaryPart.Position-Vector3.new(dcframe.X,dcframe.Y,dcframe.Z)).magnitude > 3 then
                                    car.PrimaryPart.Velocity = Vector3.new(0,0,0)
                                    car:PivotTo(dcframe)
                                    task.wait(0.1)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,304,false,game)
                                    car.PrimaryPart.Velocity = Vector3.new(0,0,0)
                                end
                            until not game:GetService("Workspace").ParkingMarkers:FindFirstChild("destinationPart") or getfenv().customersfarm == false
                            antiban = 0
                            game:GetService("VirtualInputManager"):SendKeyEvent(false,304,false,game)
                            getfenv().numbers=getfenv().numbers+1
                            testvalue = 1
                            task.wait()
                        elseif workspace:Raycast(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(0, -100, 0),raycastParams).Instance.Name == "Terrain" and ohsoso == false then
                            getfenv().rat = nil
                            local distance = math.huge
                            for i,v in pairs(game:GetService("Workspace").World:GetDescendants()) do
                                if (string.find(v.Name,"road") or string.find(v.Name,"Road")) and v.ClassName == "Part" then
                                    local Dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position-v.Position).magnitude
                                    if Dist < distance then
                                        distance = Dist
                                        getfenv().rat = v
                                    end
                                end
                            end
                            car:PivotTo(getfenv().rat.CFrame)
                            ohsoso = true
                        elseif game:GetService("Players").LocalPlayer.variables.inMission.Value == true then
                            testvalue = testvalue-.02 
                            if testvalue < 0 then
                                getfenv().rat = nil
                                local distance = math.huge
                                for i,v in pairs(game:GetService("Workspace").World:GetDescendants()) do
                                    if (string.find(v.Name,"road") or string.find(v.Name,"Road")) and v.ClassName == "Part" then
                                        local Dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position-v.Position).magnitude
                                        if Dist < distance then
                                            distance = Dist
                                            getfenv().rat = v
                                        end
                                    end
                                end
                                car:PivotTo(getfenv().rat.CFrame)
                                getfenv().stuck = getfenv().stuck+1
                                testvalue = 1 
                            end
                            pcall(function()
                                local PathfindingService = game:GetService("PathfindingService")
                                local part1 = game.Players.LocalPlayer.Character.HumanoidRootPart
                                local part2 = game:GetService("Workspace").ParkingMarkers.destinationPart
                                local whatever = part1.CFrame:lerp(part2.CFrame, testvalue)
                                local iguess = Vector3.new(whatever.X,part2.Position.Y,whatever.Z)
                                local path = PathfindingService:CreatePath({ AgentRadius = 20 })
                                path:ComputeAsync(car.PrimaryPart.Position, iguess)
                                local waypoints = path:GetWaypoints()
                                for yay, waypoint in pairs(waypoints) do
                                    local part = Instance.new("Part")
                                    part.Shape = "Ball"
                                    part.Size = Vector3.new(0.6, 0.6, 0.6)
                                    part.Position = waypoint.Position
                                    part.Anchored = true
                                    part.CanCollide = false
                                    part.Parent = game.Workspace
                                    if workspace:Raycast(waypoint.Position, Vector3.new(0, 1000, 0), raycastParams) == nil then
                                        car:PivotTo(part.CFrame+Vector3.new(0,5,0))
                                        part:Destroy()
                                        testvalue = 1
                                        task.wait(0.009)
                                    else
                                        part:Destroy()
                                        testvalue = 1
                                    end
                                end
                            end)
                        elseif game:GetService("Players").LocalPlayer.variables.inMission.Value == false then
                            getfenv().rat = nil
                            local distance = math.huge
                            for i,v in pairs(game:GetService("Workspace").NewCustomers:GetDescendants()) do
                                if v.Name == "Part" and v:GetAttribute("GroupSize") ~= nil and v:FindFirstChildOfClass("CFrameValue") and game.Players.LocalPlayer.variables.seatAmount.Value > v:GetAttribute("GroupSize") and v:GetAttribute("Rating") < game:GetService("Players").LocalPlayer.variables.vehicleRating.Value then
                                    local Dist = (v.Position-Vector3.new(v:FindFirstChildOfClass("CFrameValue").Value.X,v:FindFirstChildOfClass("CFrameValue").Value.Y,v:FindFirstChildOfClass("CFrameValue").Value.Z)).magnitude
                                    if Dist < distance then
                                        distance = Dist
                                        getfenv().rat = v
                                    end
                                end
                            end
                            for ok,ya in pairs(game:GetService("Workspace").Vehicles:GetDescendants()) do
                                if ya.Name == "Player" and ya.Value == game.Players.LocalPlayer then
                                    ya.Parent.Parent:SetPrimaryPartCFrame(getfenv().rat.CFrame*CFrame.new(0,3,0))
                                    task.wait(1)
                                    fireproximityprompt(getfenv().rat.Client.PromptPart.CustomerPrompt)
                                    task.wait(3)
                                end
                            end
                        end
                    elseif game.Players.LocalPlayer.Character.Humanoid.SeatPart == nil then
                        game:GetService("ReplicatedStorage").Vehicles.GetNearestSpot:InvokeServer(game:GetService("Players").LocalPlayer.variables.carId.Value)
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Vehicles.EnterVehicleEvent:InvokeServer()
                    end
                end)
            end
        end)
    end)

    -- 4. Auto Collect Parts 功能整合
    createToggleButton(panelAutoParts, "Auto Collect Parts", 15, function(state)
        getfenv().partcollector = (state and true or false)
        task.spawn(function()
            while getfenv().partcollector do
                task.wait()
                for a,b in pairs(workspace.ItemSpawnLocations:GetChildren()) do
                    if getfenv().partcollector then
                        local timer = tick()
                        repeat task.wait()
                            game.Players.LocalPlayer.Character:PivotTo(b.CFrame+Vector3.new(0,251,0))
                        until tick()-timer >= 2
                        for i,v in pairs(workspace.ItemSpawnLocations:GetDescendants()) do
                            if v.Name == "TouchInterest" then
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,v.Parent,0)
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,v.Parent,1)
                            end
                        end
                    end
                end
            end
        end)
    end)

    -- Panel 1 (其他設定 - 保留防掛機、重新加入、切換語言、返回遊戲選單)
    local function createGenericButton(text, yPos, color)
        local btn = Instance.new("TextButton", panel1)
        btn.Size = UDim2.new(1, -24, 0, 42)
        btn.Position = UDim2.new(0, 12, 0, yPos)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.25
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        return btn
    end

    local afkBtn = createGenericButton(L.AntiAfk .. " : " .. L.SwitchOff, 15, Color3.fromRGB(35, 35, 48))
    local rejoinBtn = createGenericButton(L.RejoinBtn, 72, Color3.fromRGB(45, 90, 120))
    local changeLangBtn = createGenericButton(L.LangBtn, 129, Color3.fromRGB(110, 35, 160))
    local returnMenuBtn = createGenericButton(L.MenuBtn, 186, Color3.fromRGB(160, 80, 35))

    afkBtn.Activated:Connect(function()
        isAntiAfkEnabled = not isAntiAfkEnabled
        afkBtn.Text = L.AntiAfk .. " : " .. (isAntiAfkEnabled and L.SwitchOn or L.SwitchOff)
        afkBtn.BackgroundColor3 = isAntiAfkEnabled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
        afkBtn.BackgroundTransparency = isAntiAfkEnabled and 0.15 or 0.25
    end)

    rejoinBtn.Activated:Connect(function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)

    changeLangBtn.Activated:Connect(function() showLanguageSelector() end)

    returnMenuBtn.Activated:Connect(function()
        showConfirmDialog(
            L.MenuConfirmTitle, 
            L.MenuConfirmMsg, 
            L.ConfirmYes, 
            L.ConfirmNo, 
            function()
                stopAllRoutines()
                if playerGui:FindFirstChild("MultiDriveGui") then playerGui.MultiDriveGui:Destroy() end
                if CoreGui:FindFirstChild("KrisVanLangSelector") then CoreGui.KrisVanLangSelector:Destroy() end
                loadstring(game:HttpGet("https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVanOpmenu.lua"))()
            end, 
            function()
            end
        )
    end)

    table.insert(activeConnections, RunService.RenderStepped:Connect(function()
        if isAntiAfkEnabled and tick() % 30 < 0.1 then
            pcall(function()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end))
end

playStartupLoadingScreen(function()
    showLanguageSelector()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        if playerGui:FindFirstChild("MultiDriveGui") then
            local m = playerGui.MultiDriveGui:FindFirstChildOfClass("Frame")
            if m then m.Visible = not m.Visible end
        end
    end
end)

