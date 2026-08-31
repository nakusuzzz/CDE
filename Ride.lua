--[[
	KrisVan Script (Special Ed.) - v1.0.1
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

-- Auto Farm 相關變數（最高速已改為 500）
local farmState = 0 -- 0: 關閉, 1: 已傳送到A點/準備中, 2: 正在自動駕駛
local farming = false
local force, gyro
local currentSpeed = 0
local maxSpeed = 500       
local speedControl = 500   

local pointA = Vector3.new(-6370.5, 1986.9, 4504.2) 
local pointB = Vector3.new(-13260.9, 1980.6, 5194.4) 
local targetPoint = pointA 
local threshold = 25       

local function stopAllRoutines()
    isAntiAfkEnabled = false
    farming = false
    farmState = 0
    if force then force:Destroy() end
    if gyro then gyro:Destroy() end

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
    titleLabelLoad.Text = "KrisVan Script v1.0.1"
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

local function showAlertPopup(titleText, msgText, btnText, onConfirm)
    if CoreGui:FindFirstChild("KrisVanAlertPopup") then
        CoreGui.KrisVanAlertPopup:Destroy()
    end

    local alertGui = Instance.new("ScreenGui")
    alertGui.Name = "KrisVanAlertPopup"
    alertGui.ResetOnSpawn = false
    alertGui.IgnoreGuiInset = true
    alertGui.Parent = CoreGui

    local alertFrame = Instance.new("Frame")
    alertFrame.Size = UDim2.new(0, 300, 0, 150)
    alertFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    alertFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    alertFrame.BackgroundTransparency = 0.2
    alertFrame.BorderSizePixel = 0
    alertFrame.Parent = alertGui

    Instance.new("UICorner", alertFrame).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", alertFrame)
    stroke.Color = Color3.fromRGB(140, 60, 220)
    stroke.Thickness = 1.5

    local alertTitle = Instance.new("TextLabel", alertFrame)
    alertTitle.Size = UDim2.new(1, -30, 0, 40)
    alertTitle.Position = UDim2.new(0, 15, 0, 12)
    alertTitle.BackgroundTransparency = 1
    alertTitle.Text = titleText
    alertTitle.Font = Enum.Font.GothamBold
    alertTitle.TextSize = 15
    alertTitle.TextColor3 = Color3.fromRGB(220, 130, 255)
    alertTitle.TextXAlignment = Enum.TextXAlignment.Left

    local alertMsg = Instance.new("TextLabel", alertFrame)
    alertMsg.Size = UDim2.new(1, -30, 0, 40)
    alertMsg.Position = UDim2.new(0, 15, 0, 52)
    alertMsg.BackgroundTransparency = 1
    alertMsg.Text = msgText
    alertMsg.Font = Enum.Font.Gotham
    alertMsg.TextSize = 13
    alertMsg.TextColor3 = Color3.fromRGB(180, 180, 200)
    alertMsg.TextXAlignment = Enum.TextXAlignment.Left
    alertMsg.TextWrapped = true

    local btnConfirm = Instance.new("TextButton", alertFrame)
    btnConfirm.Size = UDim2.new(0.92, 0, 0, 38)
    btnConfirm.Position = UDim2.new(0.04, 0, 0, 100)
    btnConfirm.BackgroundColor3 = Color3.fromRGB(130, 40, 190)
    btnConfirm.BackgroundTransparency = 0.15
    btnConfirm.Text = btnText
    btnConfirm.Font = Enum.Font.GothamBold
    btnConfirm.TextSize = 12
    btnConfirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btnConfirm).CornerRadius = UDim.new(0, 10)

    btnConfirm.Activated:Connect(function()
        alertGui:Destroy()
        if onConfirm then onConfirm() end
    end)
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
            Title = "⚔️ KrisVan 遊戲輔助 v1.0.1",
            Tab0 = "👤 作者資訊",
            TabLog = "📋 更新日誌",
            TabAuto = "🚗 自動駕駛",
            Tab1 = "⚙️ 其他設定",
            SwitchOff = "關閉",
            SwitchOn = "開啟",
            AuthorContent = "【 作者資訊 】\n• 作者 / 開發者：KrisVan\n• 功能：專為 Roblox 打造的強大輔助介面。\n• 感謝您的使用與支持！",
            LogHeader = "[📋 更新日誌 📋]",
            LogClickHint = " (點擊展開/收合)",
            Logs = {
                {version = "v1.0.1", details = "• 修復自動駕駛按鈕邏輯與步驟順序錯誤\n• 將最高速提升至 500\n• 統一將介面中的「自動刷」字樣修正為「自動駕駛」"},
                {version = "v1.0.0", details = "• 初始版本發布\n• 包含防掛機與重新加入遊戲功能"}
            },
            AutoFarmTitle = "自動駕駛",
            AutoFarmDesc = "狀態說明：\n• 點擊 1 次：傳送至 A 點並尋找車輛\n• 點擊 2 次：開始 A/B 點來回自動駕駛\n• 點擊 3 次：關閉功能",
            AutoFarmBtnStates = {"狀態：已關閉", "狀態：已傳送 (等待啟動)", "狀態：自動駕駛中 (ON)"},
            AlertTitle = "⚠️ 提示",
            AlertMsg = "請生成車輛後再重新按下按鈕",
            AlertBtn = "確定",
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
            Title = "⚔️ KrisVan 游戏辅助 v1.0.1",
            Tab0 = "👤 作者信息",
            TabLog = "📋 更新日志",
            TabAuto = "🚗 自动驾驶",
            Tab1 = "⚙️ 其他设定",
            SwitchOff = "关闭",
            SwitchOn = "开启",
            AuthorContent = "【 作者信息 】\n• 作者 / 开发者：KrisVan\n• 功能：专为 Roblox 打造的强大辅助界面。\n• 感谢您的使用与支持！",
            LogHeader = "[📋 更新日志 📋]",
            LogClickHint = " (点击展开/收合)",
            Logs = {
                {version = "v1.0.1", details = "• 修复自动驾驶按钮逻辑与步骤顺序错误\n• 将最高速提升至 500\n• 统一将界面中的「自动刷」字样修正为「自动驾驶」"},
                {version = "v1.0.0", details = "• 初始版本发布\n• 包含防挂机与重新加入游戏功能"}
            },
            AutoFarmTitle = "自动驾驶",
            AutoFarmDesc = "状态说明：\n• 点击 1 次：传送至 A 点并寻找车辆\n• 点击 2 次：开始 A/B 点来回自动驾驶\n• 点击 3 次：关闭功能",
            AutoFarmBtnStates = {"状态：已关闭", "状态：已传送 (等待启动)", "状态：自动驾驶中 (ON)"},
            AlertTitle = "⚠️ 提示",
            AlertMsg = "请生成车辆后再重新按下按钮",
            AlertBtn = "确定",
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
            Title = "⚔️ KrisVan Script v1.0.1",
            Tab0 = "👤 Author",
            TabLog = "📋 Changelog",
            TabAuto = "🚗 Auto Drive",
            Tab1 = "⚙️ Settings",
            SwitchOff = "OFF",
            SwitchOn = "ON",
            AuthorContent = "[ Author Information ]\n• Author: KrisVan\n• Description: Advanced utility script for Roblox.\n• Thank you for using!",
            LogHeader = "[📋 Changelog 📋]",
            LogClickHint = " (Click to toggle)",
            Logs = {
                {version = "v1.0.1", details = "• Fixed auto drive button logic and step sequence bugs\n• Increased max speed to 500\n• Updated references from auto farm to auto drive"},
                {version = "v1.0.0", details = "• Initial release\n• Includes anti-afk and rejoin features"}
            },
            AutoFarmTitle = "Auto Drive",
            AutoFarmDesc = "Instructions:\n• Click 1: Teleport to Point A & Find Car\n• Click 2: Start A/B Auto Loop\n• Click 3: Turn Off",
            AutoFarmBtnStates = {"Status: OFF", "Status: Teleported (Ready)", "Status: Running (ON)"},
            AlertTitle = "⚠️ Notice",
            AlertMsg = "Please spawn a vehicle before clicking again",
            AlertBtn = "Confirm",
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
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 200)
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
    local panelAuto = Instance.new("ScrollingFrame", contentArea)
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
    setupPanel(panelLog, 480)
    setupPanel(panelAuto, 260)
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
    local tabBtnAuto = createTabButton(L.TabAuto, 88)
    local tabBtn1 = createTabButton(L.Tab1, 128)
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 172)

    local allPanels = {panel0, panelLog, panelAuto, panel1}
    local allTabBtns = {tabBtn0, tabBtnLog, tabBtnAuto, tabBtn1}

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
    tabBtnAuto.Activated:Connect(function() switchTab(panelAuto, tabBtnAuto) end)
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
            local currentHeight = info.isExpanded and 130 or 38
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

        local itemBtn = Instance.new("TextButton", panelLog)
        itemBtn.Size = UDim2.new(1, 0, 0, 38)
        itemBtn.BackgroundTransparency = 1
        itemBtn.Text = "  " .. logData.version .. L.LogClickHint
        itemBtn.Font = Enum.Font.GothamBold
        itemBtn.TextSize = 12
        itemBtn.TextColor3 = Color3.fromRGB(210, 180, 255)
        itemBtn.TextXAlignment = Enum.TextXAlignment.Left

        local detailLabel = Instance.new("TextLabel", itemFrame)
        detailLabel.Size = UDim2.new(1, -20, 0, 80)
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
            local targetHeight = logInfo.isExpanded and 130 or 38
            TweenService:Create(itemFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -24, 0, targetHeight)}):Play()
            task.spawn(function()
                task.wait(0.28)
                updateLogLayout()
            end)
            updateLogLayout()
        end)
    end
    updateLogLayout()

    -- Panel Auto (自動駕駛)
    local autoDesc = Instance.new("TextLabel", panelAuto)
    autoDesc.Size = UDim2.new(1, -24, 0, 95)
    autoDesc.Position = UDim2.new(0, 12, 0, 10)
    autoDesc.BackgroundTransparency = 1
    autoDesc.Text = L.AutoFarmDesc
    autoDesc.Font = Enum.Font.Gotham
    autoDesc.TextSize = 12
    autoDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
    autoDesc.TextXAlignment = Enum.TextXAlignment.Left
    autoDesc.TextYAlignment = Enum.TextYAlignment.Top
    autoDesc.TextWrapped = true

    local autoDriveBtn = Instance.new("TextButton", panelAuto)
    autoDriveBtn.Size = UDim2.new(1, -24, 0, 48)
    autoDriveBtn.Position = UDim2.new(0, 12, 0, 115)
    autoDriveBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    autoDriveBtn.BackgroundTransparency = 0.25
    autoDriveBtn.Text = L.AutoFarmBtnStates[1]
    autoDriveBtn.Font = Enum.Font.GothamBold
    autoDriveBtn.TextSize = 13
    autoDriveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", autoDriveBtn).CornerRadius = UDim.new(0, 10)

    local function getSeat()
        local char = player.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then return hum.SeatPart end
    end

    local function findAndSitVehicle()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
        local rootPart = char.HumanoidRootPart
        local closestSeat = nil
        local shortestDistance = 50

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
                local dist = (obj.Position - rootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestSeat = obj
                end
            end
        end

        if closestSeat then
            closestSeat:Sit(char:FindFirstChildOfClass("Humanoid"))
            task.wait(0.3)
            return true
        end
        return false
    end

    local function startAutoFarmLoop()
        if activeConnections["farmLoop"] then
            pcall(function() activeConnections["farmLoop"]:Disconnect() end)
            activeConnections["farmLoop"] = nil
        end

        activeConnections["farmLoop"] = RunService.RenderStepped:Connect(function()
            if not farming then return end

            local seat = getSeat()
            if not seat or not seat.Parent then return end

            local pos = seat.Position
            local flatCurrent = Vector3.new(pos.X, 0, pos.Z)
            local flatTarget = Vector3.new(targetPoint.X, 0, targetPoint.Z)
            
            if (flatCurrent - flatTarget).Magnitude < threshold then
                if targetPoint == pointA then
                    targetPoint = pointB
                else
                    targetPoint = pointA
                end
            end

            if not seat:FindFirstChild("BodyVelocity") then
                if force then force:Destroy() end
                force = Instance.new("BodyVelocity")
                force.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                force.Parent = seat
            end

            if not seat:FindFirstChild("BodyGyro") then
                if gyro then gyro:Destroy() end
                gyro = Instance.new("BodyGyro")
                gyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                gyro.P = 100000
                gyro.D = 5000
                gyro.Parent = seat
            end

            local directionToTarget = (targetPoint - pos)
            local flatForward = Vector3.new(directionToTarget.X, 0, directionTarget and directionTarget.Z or directionToTarget.Z).Unit

            currentSpeed = math.min(currentSpeed + 50, speedControl)

            seat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            seat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            local forwardVel = flatForward * currentSpeed

            force.Velocity = Vector3.new(
                forwardVel.X,
                seat.Velocity.Y,
                forwardVel.Z
            )

            seat.CFrame = CFrame.lookAt(
                pos,
                pos + flatForward,
                Vector3.new(0, 1, 0)
            )
        end)
    end

    -- 修復：修正三段式順序與重複邏輯（0 -> 1 -> 2 -> 0）
    autoDriveBtn.Activated:Connect(function()
        if farmState == 0 then
            -- 狀態 0 轉 1：第一次點擊，傳送至 A 點並檢查車輛
            farming = false
            if force then force:Destroy() end
            if gyro then gyro:Destroy() end

            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(pointA + Vector3.new(0, 5, 0))
            end
            task.wait(0.5)
            
            local foundCar = findAndSitVehicle()
            if not foundCar then
                -- 沒找到車輛，跳出提示彈窗，維持在狀態 0
                showAlertPopup(L.AlertTitle, L.AlertMsg, L.AlertBtn, function() end)
                return
            end

            farmState = 1
            autoDriveBtn.Text = L.AutoFarmBtnStates[2]
            autoDriveBtn.BackgroundColor3 = Color3.fromRGB(110, 80, 35)
            autoDriveBtn.BackgroundTransparency = 0.15

        elseif farmState == 1 then
            -- 狀態 1 轉 2：第二次點擊，開始自動駕駛迴圈
            farmState = 2
            farming = true
            currentSpeed = 0
            targetPoint = pointA
            startAutoFarmLoop()

            autoDriveBtn.Text = L.AutoFarmBtnStates[3]
            autoDriveBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 190)
            autoDriveBtn.BackgroundTransparency = 0.15

        else
            -- 狀態 2 轉 0：第三次點擊，關閉功能
            farmState = 0
            farming = false
            if force then force:Destroy() end
            if gyro then gyro:Destroy() end
            if activeConnections["farmLoop"] then
                pcall(function() activeConnections["farmLoop"]:Disconnect() end)
                activeConnections["farmLoop"] = nil
            end

            autoDriveBtn.Text = L.AutoFarmBtnStates[1]
            autoDriveBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            autoDriveBtn.BackgroundTransparency = 0.25
        end
    end)

    -- Panel 1 (其他設定)
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

