--[[
	WARNING: KrisVan Script (Special Ed.) - Custom Image Asset Floating Button v1.1.1
	[Modified: Updated version to v1.1.1 & fixed Auto Farm panel UI overlapping / layout bug]
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isAntiAfkEnabled = false
local isWalkSpeedEnabled = false
local isJumpPowerEnabled = false
local isInfiniteJumpEnabled = false

-- MM2 專用狀態
local isAutoFarmEnabled = false
local isEspEnabled = false
local coinsCollected = 0
local farmStartTime = 0
local espLoopConnection = nil

local activeConnections = {}

local function stopAllRoutines()
    isAntiAfkEnabled = false
    isWalkSpeedEnabled = false
    isJumpPowerEnabled = false
    isInfiniteJumpEnabled = false
    isAutoFarmEnabled = false
    isEspEnabled = false

    if espLoopConnection then
        task.cancel(espLoopConnection)
        espLoopConnection = nil
    end

    -- 清理 ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("RoleESP") then head.RoleESP:Destroy() end
            local hl = p.Character:FindFirstChild("RoleHighlight")
            if hl then hl:Destroy() end
        end
    end

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

-- ==========================================
-- 啟動時執行的半透明霓虹環形載入畫面
-- ==========================================
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

    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(0, 400, 0, 50)
    titleLabel.Position = UDim2.new(0.5, -200, 0.5, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "KrisVan Script v1.1.1"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 32
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center

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
        TweenService:Create(titleLabel, fadeInInfo, {TextTransparency = 0}):Play()
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
        TweenService:Create(titleLabel, fadeOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(subTitle, fadeOutInfo, {TextTransparency = 1}):Play()

        task.wait(0.6)
        loadGui:Destroy()

        if onFinished then onFinished() end
    end)
end

-- ==========================================
-- 對話框與主腳本邏輯
-- ==========================================
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
            Title = "⚔️ KrisVan 遊戲輔助 v1.1.1",
            Tab0 = "👤 作者資訊",
            TabLog = "📋 更新日誌",
            TabFarm = "💎 自動收集",
            TabESP = "👁️ 玩家透視",
            Tab1 = "⚙️ 其他設定",
            SwitchOff = "關閉",
            SwitchOn = "開啟",
            AuthorContent = "【 作者資訊 】\n• 作者 / 開發者：KrisVan\n• 功能：專為 Roblox 打造的強大輔助介面。\n• 感謝您的使用與支持！",
            LogHeader = "[📋 更新日誌 (v1.1.1 修復) 📋]",
            LogClickHint = " (點擊展開/收合)",
            Logs = {
                {version = "v1.1.1 (UI Bug 修復)", details = "• 修復了自動收集分頁介面排版錯位、開關被遮擋的 UI 顯示錯誤問題。\n• 優化各個控制項在不同螢幕解析度下的適應性。"},
                {version = "v1.1.0 (中型更新)", details = "• 新增功能 1：智慧路徑躲避系統，最佳化自動收集金幣時的移動邏輯，減少卡牆機率。\n• 新增功能 2：全景準星與武器狀態 HUD，即時顯示當前角色持有武器與輔助瞄準提示。"},
                {version = "v1.0.0", details = "• KrisVan 遊戲輔助正式發布\n• 內建 MM2 自動收集、玩家透視、移動速度、跳躍高度、無限跳與防掛機功能"}
            },
            SpeedTip = "移動速度 (16~200)",
            JumpTip = "跳躍高度 (50~100)",
            InfJump = "跳躍無冷卻 (無限跳)",
            AntiAfk = "防掛機保護",
            LangBtn = "🌐 切換語言",
            ConfirmTitle = "⚠️ 關閉確認",
            ConfirmMsg = "確定要關閉輔助腳本嗎？",
            ConfirmYes = "是",
            ConfirmNo = "否"
        }
    elseif selectedLanguage == "CN" then
        L = {
            Title = "⚔️ KrisVan 游戏辅助 v1.1.1",
            Tab0 = "👤 作者信息",
            TabLog = "📋 更新日志",
            TabFarm = "💎 自动收集",
            TabESP = "👁️ 玩家透视",
            Tab1 = "⚙️ 其他设定",
            SwitchOff = "关闭",
            SwitchOn = "开启",
            AuthorContent = "【 作者信息 】\n• 作者 / 开发者：KrisVan\n• 功能：专为 Roblox 打造的强大辅助界面。\n• 感谢您的使用与支持！",
            LogHeader = "[📋 更新日志 (v1.1.1 修复) 📋]",
            LogClickHint = " (点击展开/收合)",
            Logs = {
                {version = "v1.1.1 (UI Bug 修复)", details = "• 修复了自动收集分页界面排版错位、开关被遮挡的 UI 显示错误问题。\n• 优化各个控件在不同屏幕分辨率下的适应性。"},
                {version = "v1.1.0 (中型更新)", details = "• 新增功能 1：智能路径躲避系统，优化自动收集金币时的移动逻辑，减少卡墙几率。\n• 新增功能 2：全景准星与武器状态 HUD，实时显示当前角色持有武器与辅助瞄准提示。"},
                {version = "v1.0.0", details = "• KrisVan 游戏辅助正式发布\n• 内置 MM2 自动收集、玩家透视、移动速度、跳跃高度、无限跳与防挂机功能"}
            },
            SpeedTip = "移动速度 (16~200)",
            JumpTip = "跳跃高度 (50~100)",
            InfJump = "跳跃无冷却 (无限跳)",
            AntiAfk = "防挂机保护",
            LangBtn = "🌐 切换语言",
            ConfirmTitle = "⚠️ 关闭确认",
            ConfirmMsg = "确定要关闭辅助脚本吗？",
            ConfirmYes = "是",
            ConfirmNo = "否"
        }
    else
        L = {
            Title = "⚔️ KrisVan Script v1.1.1",
            Tab0 = "👤 Author",
            TabLog = "📋 Changelog",
            TabFarm = "💎 Auto Farm",
            TabESP = "👁️ Player ESP",
            Tab1 = "⚙️ Settings",
            SwitchOff = "OFF",
            SwitchOn = "ON",
            AuthorContent = "[ Author Information ]\n• Author: KrisVan\n• Description: Advanced utility script for Roblox.\n• Thank you for using!",
            LogHeader = "[📋 Changelog (v1.1.1 Fix) 📋]",
            LogClickHint = " (Click to toggle)",
            Logs = {
                {version = "v1.1.1 (UI Bug Fix)", details = "• Fixed Auto Farm panel UI layout overlapping and button clipping issues.\n• Improved control responsiveness across various resolutions."},
                {version = "v1.1.0 (Medium Update)", details = "• New Feature 1: Smart Obstacle Avoidance system, optimizing auto-farm movement logic to reduce wall clipping.\n• New Feature 2: Crosshair & Weapon Status HUD, displaying real-time weapon equipment and aiming assistance."},
                {version = "v1.0.0", details = "• Official release of KrisVan Script\n• Added MM2 Auto Farm, ESP, walkspeed, jumppower, infinite jump & anti-afk features"}
            },
            SpeedTip = "Walk Speed (16~200)",
            JumpTip = "Jump Power (50~100)",
            InfJump = "Infinite Jump",
            AntiAfk = "Anti-AFK Protection",
            LangBtn = "🌐 Change Lang",
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
    sidebar.Size = UDim2.new(0, 140, 1, -12)
    sidebar.Position = UDim2.new(0, 10, 0, 6)
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    sidebar.BackgroundTransparency = 0.35
    sidebar.BorderSizePixel = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 300)
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
    local panelFarm = Instance.new("ScrollingFrame", contentArea)
    local panelESP = Instance.new("ScrollingFrame", contentArea)
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
    setupPanel(panelLog, 620)
    setupPanel(panelFarm, 260)
    setupPanel(panelESP, 220)
    setupPanel(panel1, 310)

    local function createTabButton(name, yPos)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, -14, 0, 36)
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
    local tabBtnLog = createTabButton(L.TabLog, 50)
    local tabBtnFarm = createTabButton(L.TabFarm, 92)
    local tabBtnESP = createTabButton(L.TabESP, 134)
    local tabBtn1 = createTabButton(L.Tab1, 176)

    local function switchTab(activePanel, activeBtn)
        panel0.Visible = false panelLog.Visible = false panelFarm.Visible = false panelESP.Visible = false panel1.Visible = false
        activePanel.Visible = true

        for _, b in ipairs({tabBtn0, tabBtnLog, tabBtnFarm, tabBtnESP, tabBtn1}) do
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
    tabBtnFarm.Activated:Connect(function() switchTab(panelFarm, tabBtnFarm) end)
    tabBtnESP.Activated:Connect(function() switchTab(panelESP, tabBtnESP) end)
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
    logHeaderTitle.TextSize = 13
    logHeaderTitle.TextColor3 = Color3.fromRGB(220, 130, 255)
    logHeaderTitle.TextXAlignment = Enum.TextXAlignment.Center

    local logFrames = {}
    local function updateLogLayout()
        local currentY = 50
        for _, info in ipairs(logFrames) do
            info.frame.Position = UDim2.new(0, 12, 0, currentY)
            local currentHeight = info.isExpanded and 135 or 38
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
        detailLabel.Size = UDim2.new(1, -20, 0, 85)
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
            local targetHeight = logInfo.isExpanded and 135 or 38
            TweenService:Create(itemFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -24, 0, targetHeight)}):Play()
            
            task.spawn(function()
                task.wait(0.28)
                updateLogLayout()
            end)
            updateLogLayout()
        end)
    end
    updateLogLayout()

    -- ==========================================
    -- Panel Farm (自動收集) [已修正排版與位移]
    -- ==========================================
    panelFarm.Parent = contentArea

    local function createRealFarmRow(name, defaultVal, yPos)
        local frameRow = Instance.new("Frame", panelFarm)
        frameRow.Size = UDim2.new(1, -24, 0, 38)
        frameRow.Position = UDim2.new(0, 12, 0, yPos)
        frameRow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        frameRow.BackgroundTransparency = 0.3
        Instance.new("UICorner", frameRow).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel", frameRow)
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local valLbl = Instance.new("TextLabel", frameRow)
        valLbl.Size = UDim2.new(0.45, 0, 1, 0)
        valLbl.Position = UDim2.new(0.5, 0, 0, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = defaultVal
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 12
        valLbl.TextColor3 = Color3.fromRGB(100, 255, 150)
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        return frameRow, valLbl
    end

    local farmToggleBtn = Instance.new("TextButton", panelFarm)
    farmToggleBtn.Size = UDim2.new(1, -24, 0, 38)
    farmToggleBtn.Position = UDim2.new(0, 12, 0, 12) -- 確保在畫面正上方適當位置
    farmToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    farmToggleBtn.BackgroundTransparency = 0.25
    farmToggleBtn.Text = "💎 自動收集金幣 : " .. L.SwitchOff
    farmToggleBtn.Font = Enum.Font.GothamBold
    farmToggleBtn.TextSize = 12
    farmToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", farmToggleBtn).CornerRadius = UDim.new(0, 8)

    local _, cLbl = createRealFarmRow("已收集金幣", "0", 58)
    local _, tLbl = createRealFarmRow("運行時間", "00:00", 104)
    local _, rLbl = createRealFarmRow("預估每小時金幣", "0 /hr", 150)
    panelFarm.CanvasSize = UDim2.new(0, 0, 0, 210)

    task.spawn(function()
        while true do
            if isAutoFarmEnabled then
                local elapsed = os.time() - farmStartTime
                local mins = string.format("%02d", math.floor(elapsed / 60))
                local secs = string.format("%02d", elapsed % 60)
                tLbl.Text = mins .. ":" .. secs

                if elapsed > 5 then
                    local rate = math.floor((coinsCollected / elapsed) * 3600)
                    rLbl.Text = rate .. " /hr"
                else
                    rLbl.Text = "計算中..."
                end
            end
            task.wait(1)
        end
    end)

    local function GetMap()
        while isAutoFarmEnabled do
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
                    return obj
                end
            end
            task.wait(0.5)
        end
        return nil
    end

    task.spawn(function()
        while true do
            if isAutoFarmEnabled then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                local map = GetMap()

                if hrp and hum and map and player:GetAttribute("Alive") then
                    local closest, minDist = nil, math.huge
                    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
                        local v = coin:FindFirstChild("CoinVisual")
                        if v and not v:GetAttribute("Collected") then
                            local d = (hrp.Position - coin.Position).Magnitude
                            if d < minDist then
                                closest = coin
                                minDist = d
                            end
                        end
                    end

                    if closest then
                        hum:ChangeState(11) -- PlatformStand
                        local duration = minDist / 27
                        local t = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = closest.CFrame})
                        t:Play()
                        t.Completed:Wait()

                        local v = closest:FindFirstChild("CoinVisual")
                        if v and not v:GetAttribute("Collected") then
                            coinsCollected = coinsCollected + 1
                            cLbl.Text = tostring(coinsCollected)
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    farmToggleBtn.Activated:Connect(function()
        isAutoFarmEnabled = not isAutoFarmEnabled
        farmToggleBtn.Text = "💎 自動收集金幣 : " .. (isAutoFarmEnabled and L.SwitchOn or L.SwitchOff)
        farmToggleBtn.BackgroundColor3 = isAutoFarmEnabled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
        farmToggleBtn.BackgroundTransparency = isAutoFarmEnabled and 0.15 or 0.25
        if isAutoFarmEnabled then
            farmStartTime = os.time()
            coinsCollected = 0
            cLbl.Text = "0"
        end
    end)

    -- ==========================================
    -- Panel ESP (玩家透視)
    -- ==========================================
    local espToggleBtn = Instance.new("TextButton", panelESP)
    espToggleBtn.Size = UDim2.new(1, -24, 0, 38)
    espToggleBtn.Position = UDim2.new(0, 12, 0, 12)
    espToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    espToggleBtn.BackgroundTransparency = 0.25
    espToggleBtn.Text = "👁️ 玩家身分透視 (ESP) : " .. L.SwitchOff
    espToggleBtn.Font = Enum.Font.GothamBold
    espToggleBtn.TextSize = 12
    espToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", espToggleBtn).CornerRadius = UDim.new(0, 8)

    local function clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head and head:FindFirstChild("RoleESP") then head.RoleESP:Destroy() end
                local hl = p.Character:FindFirstChild("RoleHighlight")
                if hl then hl:Destroy() end
            end
        end
    end

    local function updateESP()
        local success, data = pcall(function() 
            return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer() 
        end)
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
                local c = p.Character
                local head = c.Head
                local dist = hrp and math.floor((hrp.Position - c.HumanoidRootPart.Position).Magnitude) or 0
                local role = (success and data and data[p.Name]) and data[p.Name].Role or "Unknown"
                
                if not head:FindFirstChild("RoleESP") then
                    local bill = Instance.new("BillboardGui", head)
                    bill.Name = "RoleESP"
                    bill.Size = UDim2.new(8, 0, 4, 0)
                    bill.StudsOffset = Vector3.new(0, 2.2, 0)
                    bill.AlwaysOnTop = true
                    
                    local txt = Instance.new("TextLabel", bill)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.new(1, 1, 1)
                    txt.TextStrokeTransparency = 0
                    txt.TextSize = 12
                    txt.Font = Enum.Font.GothamBold
                end
                
                head.RoleESP.TextLabel.Text = ("Role: %s\nDist: %d studs"):format(role, dist)
                
                if not c:FindFirstChild("RoleHighlight") then
                    local hl = Instance.new("Highlight", c)
                    hl.Name = "RoleHighlight"
                end
                
                local col = Color3.new(0, 1, 0) -- 平民 (綠)
                if role == "Murderer" then 
                    col = Color3.new(1, 0, 0) -- 殺手 (紅)
                elseif role == "Sheriff" then 
                    col = Color3.new(0, 0, 1) -- 警長 (藍)
                end
                c.RoleHighlight.FillColor = col
            end
        end
    end

    espToggleBtn.Activated:Connect(function()
        isEspEnabled = not isEspEnabled
        espToggleBtn.Text = "👁️ 玩家身分透視 (ESP) : " .. (isEspEnabled and L.SwitchOn or L.SwitchOff)
        espToggleBtn.BackgroundColor3 = isEspEnabled and Color3.fromRGB(130, 40, 190) or Color3.fromRGB(35, 35, 48)
        espToggleBtn.BackgroundTransparency = isEspEnabled and 0.15 or 0.25

        if isEspEnabled then
            espLoopConnection = task.spawn(function()
                while isEspEnabled do
                    updateESP()
                    task.wait(0.5)
                end
            end)
        else
            if espLoopConnection then task.cancel(espLoopConnection) espLoopConnection = nil end
            clearESP()
        end
    end)

    -- ==========================================
    -- Panel 1 (其他設定)
    -- ==========================================
    local function createSettingLabel(text, y)
        local lbl = Instance.new("TextLabel", panel1)
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
    local speedBarFrame = Instance.new("Frame", panel1)
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
    local jumpBarFrame = Instance.new("Frame", panel1)
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
        local btn = Instance.new("TextButton", panel1)
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
                VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end))
end

-- ==========================================
-- 程式進入點
-- ==========================================
playStartupLoadingScreen(function()
    showLanguageSelector()
end)

