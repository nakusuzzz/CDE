--[[
	WARNING: KrisVan Script (Special Ed.) - Custom Image Asset Floating Button v1.1.2
	[Modified: Removed Keitaz branding, updated version to v1.1.2 & updated changelog for logic replacement]
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isAntiAfkEnabled = false
local isWalkSpeedEnabled = false
local isJumpPowerEnabled = false
local isInfiniteJumpEnabled = false
local activeConnections = {}

-- 全域交通穿透變數
_G.V29_TrafficNoclip = false

-- AutoFarm 變數與設定
local IS_SALTFLATS = (game.PlaceId == 139048751758942)
local SAVE_FILE = "AutoFarmData.json"

local autoFarmActive = false
local carStabilizationConnection = nil
local uiElements = nil
local farmStartCash = 0
local farmStartTime = 0

local allTimeMoney = 0
local longestAFKSeconds = 0

local WAYPOINTS = IS_SALTFLATS and {
    Vector3.new(3338, -9, 6035),
    Vector3.new(3397, -6, 6105),
    Vector3.new(2781, -6, 5214),
    Vector3.new(599, 5, 1451),
    Vector3.new(-1313, 5, -1092),
    Vector3.new(-1893, 5, -1692),
    Vector3.new(-15069, 5, -14868),
    Vector3.new(-38681, 5, -38500),
} or {
    Vector3.new(-67850, -14, 10051),
    Vector3.new(-12121, -16, -2788),
}

local function loadData()
    local ok, result = pcall(readfile, SAVE_FILE)
    if not ok or not result then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, result)
    if not ok2 or not data then return end
    if data.allTime then allTimeMoney = data.allTime end
    if data.longestAFK then longestAFKSeconds = data.longestAFK end
end

local function saveData()
    pcall(writefile, SAVE_FILE, HttpService:JSONEncode({
        allTime = allTimeMoney,
        longestAFK = longestAFKSeconds,
    }))
end

loadData()

local function disableCollision(model)
    for _, desc in pairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then desc.CanCollide = false end
    end
end

local function setupExistingVehicles()
    local npc = workspace:FindFirstChild("NPCVehicles")
    if not npc then return end
    local vehicles = npc:FindFirstChild("Vehicles")
    if not vehicles then return end
    for _, v in pairs(vehicles:GetChildren()) do
        if v:IsA("Model") or v:IsA("Folder") then disableCollision(v) end
    end
end

setupExistingVehicles()
task.spawn(function() while true do task.wait(1) setupExistingVehicles() end end)

if not IS_SALTFLATS then
    task.spawn(function()
        task.wait(0.5)
        local SLAB, BASE_X, BASE_Z, BASE_Y = 2048, -36149, 5376, -16.5
        local roadModel = Instance.new("Model")
        roadModel.Name = "FarmRoad"
        for row = -15, 15 do
            for col = -15, 15 do
                local slab = Instance.new("Part")
                slab.Size = Vector3.new(SLAB, 0.2, SLAB)
                slab.CFrame = CFrame.new(BASE_X + col * SLAB, BASE_Y - 0.5, BASE_Z + row * SLAB)
                slab.Anchored = true; slab.CanCollide = true
                slab.Material = Enum.Material.Asphalt
                slab.Color = Color3.fromRGB(50, 50, 50)
                slab.Parent = roadModel
            end
        end
        roadModel.Parent = workspace
    end)
end

local function formatNumber(num)
    local f = tostring(math.floor(num))
    local k
    while true do
        f, k = string.gsub(f, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return f
end

local function formatAbbreviated(num)
    if num >= 1000000000 then return string.format("%.1fB", num / 1000000000)
    elseif num >= 1000000 then return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then return string.format("%.1fK", num / 1000)
    end
    return tostring(math.floor(num))
end

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local allTimeLabel = nil
local longestAFKLabel = nil

local function updateAllTimeUI()
    if allTimeLabel then allTimeLabel.Text = "All-Time Money: $" .. formatAbbreviated(allTimeMoney) end
end

local function updateLongestAFKUI()
    if longestAFKLabel then longestAFKLabel.Text = "Longest AFK: " .. formatTime(longestAFKSeconds) end
end

local function setupUITracking()
    local mainUI = player.PlayerGui:WaitForChild("Main_User_Interface", 5)
    if not mainUI then return nil end
    local afkRewards = mainUI:WaitForChild("AFKRewards")
    local cashEarnedLabel = afkRewards:WaitForChild("CashEarned"):WaitForChild("Label")
    local timeLabel = afkRewards:WaitForChild("Time"):WaitForChild("Label")
    afkRewards.Visible = false

    return {
        cashEarnedLabel = cashEarnedLabel,
        timeLabel = timeLabel,
        afkRewards = afkRewards,
    }
end

task.spawn(function() task.wait(1); uiElements = setupUITracking() end)

-- 內建防掛機 (Idled 事件)
Players.LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- 交通穿透邏輯
RunService.Stepped:Connect(function()
    if _G.V29_TrafficNoclip then
        local npcSystem = workspace:FindFirstChild("NPCVehicles")
        local vehiclesFolder = npcSystem and npcSystem:FindFirstChild("Vehicles")
        
        if vehiclesFolder and workspace.CurrentCamera then
            local myPos = workspace.CurrentCamera.CFrame.Position
            for _, npcCar in pairs(vehiclesFolder:GetChildren()) do
                local carPart = npcCar:FindFirstChildWhichIsA("BasePart", true)
                if carPart and (carPart.Position - myPos).Magnitude < 400 then 
                    for _, part in pairs(npcCar:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end
        end
    end
end)

local function stopAllRoutines()
    isAntiAfkEnabled = false
    isWalkSpeedEnabled = false
    isJumpPowerEnabled = false
    isInfiniteJumpEnabled = false
    _G.V29_TrafficNoclip = false
    if autoFarmActive then
        autoFarmActive = false
        saveData()
        if uiElements then uiElements.afkRewards.Visible = false end
        if carStabilizationConnection then
            carStabilizationConnection:Disconnect()
            carStabilizationConnection = nil
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
    titleLabelLoad.Text = "KrisVan Script v1.1.2"
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
            Title = "⚔️ KrisVan 遊戲輔助 v1.1.2",
            Tab0 = "👤 作者資訊",
            TabLog = "📋 更新日誌",
            TabFarm = "🚗 自動掛機",
            TabGhost = "👻 交通穿透",
            Tab1 = "⚙️ 其他設定",
            SwitchOff = "關閉",
            SwitchOn = "開啟",
            AuthorContent = "【 作者資訊 】\n• 作者 / 開發者：KrisVan\n• 功能：專為 Roblox 打造的強大輔助介面。\n• 感謝您的使用與支持！",
            LogHeader = "[📋 更新日誌 📋]",
            LogClickHint = " (點擊展開/收合)",
            Logs = {
                {version = "v1.1.2", details = "• 重構底層架構並替換自動掛機邏輯\n• 移除舊有品牌名稱與自訂識別標籤\n• 優化程式碼執行效能與資料儲存穩定性"},
                {version = "v1.1.1", details = "• 整合全新 Auto-Farm 自動掛機系統\n• 重新排版側邊欄選單分頁順序\n• 優化整體介面視覺體驗"},
                {version = "v1.0.0", details = "• 初始版本發布\n• 包含基礎移動速度、跳躍高度、無限跳與防掛機功能"}
            },
            SpeedTip = "移動速度 (16~200)",
            JumpTip = "跳躍高度 (50~100)",
            InfJump = "跳躍無冷卻 (無限跳)",
            AntiAfk = "防掛機保護",
            FarmDesc = "【 Auto-Farm 自動駕駛掛機 】\n請先坐上車輛後點擊下方按鈕啟動掛機系統。",
            GhostDesc = "【 Traffic Ghost 交通穿透 】\n點擊下方按鈕可快速切換 NPC 車輛碰撞穿透開關，避免撞車卡住。",
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
            Title = "⚔️ KrisVan 游戏辅助 v1.1.2",
            Tab0 = "👤 作者信息",
            TabLog = "📋 更新日志",
            TabFarm = "🚗 自动挂机",
            TabGhost = "👻 交通穿透",
            Tab1 = "⚙️ 其他设定",
            SwitchOff = "关闭",
            SwitchOn = "开启",
            AuthorContent = "【 作者信息 】\n• 作者 / 开发者：KrisVan\n• 功能：专为 Roblox 打造的强大辅助界面。\n• 感谢您的使用与支持！",
            LogHeader = "[📋 更新日志 📋]",
            LogClickHint = " (点击展开/收合)",
            Logs = {
                {version = "v1.1.2", details = "• 重构底层架构并替换自动挂机逻辑\n• 移除旧有品牌名称与自定义识别标签\n• 优化代码执行性能与数据存储稳定性"},
                {version = "v1.1.1", details = "• 整合全新 Auto-Farm 自动挂机系统\n• 重新排版侧边栏菜单分页顺序\n• 优化整体界面视觉体验"},
                {version = "v1.0.0", details = "• 初始版本发布\n• 包含基础移动速度、跳跃高度、无限跳与防挂机功能"}
            },
            SpeedTip = "移动速度 (16~200)",
            JumpTip = "跳跃高度 (50~100)",
            InfJump = "跳跃无冷却 (无限跳)",
            AntiAfk = "防挂机保护",
            FarmDesc = "【 Auto-Farm 自动驾驶挂机 】\n请先坐上车辆后点击下方按钮启动挂机系统。",
            GhostDesc = "【 Traffic Ghost 交通穿透 】\n点击下方按钮可快速切换 NPC 车辆碰撞穿透开关，避免撞车卡住。",
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
            Title = "⚔️ KrisVan Script v1.1.2",
            Tab0 = "👤 Author",
            TabLog = "📋 Changelog",
            TabFarm = "🚗 Auto-Farm",
            TabGhost = "👻 Ghost",
            Tab1 = "⚙️ Settings",
            SwitchOff = "OFF",
            SwitchOn = "ON",
            AuthorContent = "[ Author Information ]\n• Author: KrisVan\n• Description: Advanced utility script for Roblox.\n• Thank you for using!",
            LogHeader = "[📋 Changelog 📋]",
            LogClickHint = " (Click to toggle)",
            Logs = {
                {version = "v1.1.2", details = "• Refactored core architecture and replaced auto-farm logic\n• Removed legacy branding and custom markers\n• Optimized execution performance and data persistence"},
                {version = "v1.1.1", details = "• Integrated Auto-Farm system\n• Reordered sidebar menu tab layout\n• Improved overall UI design"},
                {version = "v1.0.0", details = "• Initial release\n• Includes walkspeed, jumppower, infinite jump & anti-afk features"}
            },
            SpeedTip = "Walk Speed (16~200)",
            JumpTip = "Jump Power (50~100)",
            InfJump = "Infinite Jump",
            AntiAfk = "Anti-AFK Protection",
            FarmDesc = "[ Auto-Farm Feature ]\nSit in a vehicle and click below to start auto-farm.",
            GhostDesc = "[ Traffic Ghost Feature ]\nToggle NPC vehicle collision noclip to prevent crashes.",
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
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 230)
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
    local panelFarm = Instance.new("ScrollingFrame", contentArea)
    local panelGhost = Instance.new("ScrollingFrame", contentArea)
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
    setupPanel(panelFarm, 250)
    setupPanel(panelGhost, 250)
    setupPanel(panel1, 350)

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
    local tabBtnFarm = createTabButton(L.TabFarm, 88)
    local tabBtnGhost = createTabButton(L.TabGhost, 128)
    local tabBtn1 = createTabButton(L.Tab1, 168)
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 214)

    local allPanels = {panel0, panelLog, panelFarm, panelGhost, panel1}
    local allTabBtns = {tabBtn0, tabBtnLog, tabBtnFarm, tabBtnGhost, tabBtn1}

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
    tabBtnFarm.Activated:Connect(function() switchTab(panelFarm, tabBtnFarm) end)
    tabBtnGhost.Activated:Connect(function() switchTab(panelGhost, tabBtnGhost) end)
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

    -- Panel Farm (自動掛機)
    local farmDescLabel = Instance.new("TextLabel", panelFarm)
    farmDescLabel.Size = UDim2.new(1, -24, 0, 40)
    farmDescLabel.Position = UDim2.new(0, 12, 0, 8)
    farmDescLabel.BackgroundTransparency = 1
    farmDescLabel.Text = L.FarmDesc
    farmDescLabel.Font = Enum.Font.Gotham
    farmDescLabel.TextSize = 11
    farmDescLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    farmDescLabel.TextXAlignment = Enum.TextXAlignment.Left
    farmDescLabel.TextYAlignment = Enum.TextYAlignment.Top
    farmDescLabel.TextWrapped = true

    local statusText = Instance.new("TextLabel", panelFarm)
    statusText.Size = UDim2.new(1, -24, 0, 18)
    statusText.Position = UDim2.new(0, 12, 0, 52)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: Ready"
    statusText.TextColor3 = Color3.fromRGB(175, 175, 175)
    statusText.TextSize = 12
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextXAlignment = Enum.TextXAlignment.Left

    allTimeLabel = Instance.new("TextLabel", panelFarm)
    allTimeLabel.Size = UDim2.new(1, -24, 0, 18)
    allTimeLabel.Position = UDim2.new(0, 12, 0, 72)
    allTimeLabel.BackgroundTransparency = 1
    allTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    allTimeLabel.TextSize = 12
    allTimeLabel.Font = Enum.Font.GothamBold
    allTimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    longestAFKLabel = Instance.new("TextLabel", panelFarm)
    longestAFKLabel.Size = UDim2.new(1, -24, 0, 18)
    longestAFKLabel.Position = UDim2.new(0, 12, 0, 92)
    longestAFKLabel.BackgroundTransparency = 1
    longestAFKLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    longestAFKLabel.TextSize = 12
    longestAFKLabel.Font = Enum.Font.GothamMedium
    longestAFKLabel.TextXAlignment = Enum.TextXAlignment.Left

    updateAllTimeUI()
    updateLongestAFKUI()

    local autoFarmToggle = Instance.new("TextButton", panelFarm)
    autoFarmToggle.Size = UDim2.new(1, -24, 0, 42)
    autoFarmToggle.Position = UDim2.new(0, 12, 0, 118)
    autoFarmToggle.Text = "Start AutoFarm"
    autoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoFarmToggle.TextSize = 13
    autoFarmToggle.Font = Enum.Font.GothamBold
    autoFarmToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
    autoFarmToggle.BorderSizePixel = 0
    Instance.new("UICorner", autoFarmToggle).CornerRadius = UDim.new(0, 10)

    -- 監控 Loop
    task.spawn(function()
        local lastKnownCash = 0
        local lastTimerSec = -1
        while true do
            task.wait(0.1)
            local now = tick()
            if autoFarmActive and uiElements then
                local elapsed = now - farmStartTime
                local elapsedSec = math.floor(elapsed)
                if elapsedSec ~= lastTimerSec then
                    lastTimerSec = elapsedSec
                    uiElements.timeLabel.Text = formatTime(elapsedSec)
                    if elapsedSec > longestAFKSeconds then
                        longestAFKSeconds = elapsedSec
                        updateLongestAFKUI()
                    end
                end
            end
            
            local ok, cashVal = pcall(function() return player.leaderstats.Cash.Value end)
            if ok then
                local gained = math.max(0, cashVal - lastKnownCash)
                if gained > 0 and lastKnownCash > 0 then
                    allTimeMoney = allTimeMoney + gained
                    updateAllTimeUI()
                    local sessionEarned = math.max(0, cashVal - farmStartCash)
                    if uiElements and uiElements.cashEarnedLabel then
                        uiElements.cashEarnedLabel.Text = "$" .. formatNumber(sessionEarned)
                    end
                end
                lastKnownCash = cashVal
            end
            if lastTimerSec and lastTimerSec > 0 and lastTimerSec % 30 == 0 then saveData() end
        end
    end)

    local function isPlayerSeated()
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.SeatPart then return true end
        end
        return false
    end

    local function stabilizeCar(car)
        if carStabilizationConnection then carStabilizationConnection:Disconnect() end
        carStabilizationConnection = RunService.Heartbeat:Connect(function()
            if not autoFarmActive or not car.Parent or not car.PrimaryPart then
                if carStabilizationConnection then
                    carStabilizationConnection:Disconnect()
                    carStabilizationConnection = nil
                end
                return
            end
            local cf = car.PrimaryPart.CFrame
            local pos, look = cf.Position, cf.LookVector
            car.PrimaryPart.CFrame = car.PrimaryPart.CFrame:Lerp(CFrame.new(pos, pos + Vector3.new(look.X, 0, look.Z)), 0.15)
            car.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, car.PrimaryPart.AssemblyAngularVelocity.Y * 0.5, 0)
        end)
    end

    local function smoothNavigateToCar(car, targetPos, maxSpeed)
        local curSpeed = maxSpeed * 0.4
        while autoFarmActive and isPlayerSeated() do
            if not car.Parent or not car.PrimaryPart then break end
            local currentPos = car.PrimaryPart.Position
            local distance = (targetPos - currentPos).Magnitude
            if distance < 50 then break end
            curSpeed = math.min(curSpeed + (maxSpeed * 0.02), maxSpeed)
            local direction = (targetPos - currentPos).Unit
            car.PrimaryPart.AssemblyLinearVelocity = car.PrimaryPart.AssemblyLinearVelocity:Lerp(direction * curSpeed, 0.1)
            local smoothedLook = car.PrimaryPart.CFrame.LookVector:Lerp(Vector3.new(direction.X, 0, direction.Z).Unit, 0.12)
            car.PrimaryPart.CFrame = car.PrimaryPart.CFrame:Lerp(CFrame.new(currentPos, currentPos + smoothedLook), 0.25)
            local floorY = IS_SALTFLATS and -13 or -30
            local resetY = IS_SALTFLATS and -7 or -17
            if currentPos.Y < floorY then
                car.PrimaryPart.CFrame = CFrame.new(currentPos.X, resetY, currentPos.Z)
            end
            task.wait()
        end
    end

    autoFarmToggle.Activated:Connect(function()
        if not autoFarmActive and not isPlayerSeated() then
            statusText.Text = "Status: Sit in a vehicle first"
            statusText.TextColor3 = Color3.fromRGB(255, 130, 130)
            return
        end
        autoFarmActive = not autoFarmActive
        if autoFarmActive then
            autoFarmToggle.Text = "Stop AutoFarm"
            statusText.Text = "Status: Running"
            statusText.TextColor3 = Color3.fromRGB(100, 255, 150)
            farmStartCash = player.leaderstats.Cash.Value
            farmStartTime = tick()
            if uiElements then
                uiElements.afkRewards.Visible = true
                uiElements.cashEarnedLabel.Text = "$0"
                uiElements.timeLabel.Text = "00:00:00"
            end
            task.spawn(function()
                while autoFarmActive do
                    if not isPlayerSeated() then break end
                    local hum = player.Character.Humanoid
                    local car = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
                    if not car then break end
                    local primary = (car:FindFirstChild("Body") and car.Body:FindFirstChild("#Weight")) or car.PrimaryPart
                    if not primary then break end
                    car.PrimaryPart = primary
                    car.PrimaryPart.Anchored = true
                    car:PivotTo(CFrame.new(WAYPOINTS[1]))
                    task.wait(0.15)
                    car.PrimaryPart.Anchored = false
                    stabilizeCar(car)
                    task.wait(0.3)
                    for waypointIndex = 2, #WAYPOINTS do
                        if not autoFarmActive or not isPlayerSeated() then break end
                        smoothNavigateToCar(car, WAYPOINTS[waypointIndex], 736)
                    end
                    if not autoFarmActive then break end
                end
                if carStabilizationConnection then
                    carStabilizationConnection:Disconnect()
                    carStabilizationConnection = nil
                end
            end)
        else
            autoFarmToggle.Text = "Start AutoFarm"
            statusText.Text = "Status: Stopped"
            statusText.TextColor3 = Color3.fromRGB(175, 175, 175)
            saveData()
            if uiElements then
                uiElements.afkRewards.Visible = false
            end
            if carStabilizationConnection then
                carStabilizationConnection:Disconnect()
                carStabilizationConnection = nil
            end
        end
    end)

    -- Panel Ghost (交通穿透)
    local ghostDescLabel = Instance.new("TextLabel", panelGhost)
    ghostDescLabel.Size = UDim2.new(1, -24, 0, 60)
    ghostDescLabel.Position = UDim2.new(0, 12, 0, 12)
    ghostDescLabel.BackgroundTransparency = 1
    ghostDescLabel.Text = L.GhostDesc
    ghostDescLabel.Font = Enum.Font.Gotham
    ghostDescLabel.TextSize = 12
    ghostDescLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    ghostDescLabel.TextXAlignment = Enum.TextXAlignment.Left
    ghostDescLabel.TextYAlignment = Enum.TextYAlignment.Top
    ghostDescLabel.TextWrapped = true

    local ghostToggleBtn = Instance.new("TextButton", panelGhost)
    ghostToggleBtn.Size = UDim2.new(1, -24, 0, 45)
    ghostToggleBtn.Position = UDim2.new(0, 12, 0, 80)
    ghostToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    ghostToggleBtn.BackgroundTransparency = 0.25
    ghostToggleBtn.Text = "TRAFFIC GHOST: " .. L.SwitchOff
    ghostToggleBtn.Font = Enum.Font.GothamBold
    ghostToggleBtn.TextSize = 13
    ghostToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", ghostToggleBtn).CornerRadius = UDim.new(0, 10)

    ghostToggleBtn.Activated:Connect(function()
        _G.V29_TrafficNoclip = not _G.V29_TrafficNoclip
        ghostToggleBtn.Text = "TRAFFIC GHOST: " .. (_G.V29_TrafficNoclip and L.SwitchOn or L.SwitchOff)
        ghostToggleBtn.BackgroundColor3 = _G.V29_TrafficNoclip and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 0, 0)
    end)

    -- Panel 1 (其他設定)
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
    local returnMenuBtn = createGenericButton(L.MenuBtn, 280, Color3.fromRGB(160, 80, 35))

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

