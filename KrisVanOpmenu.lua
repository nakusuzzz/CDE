-- 確保不會重複生成
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("DeltaCustomUI") then
    CoreGui.DeltaCustomUI:Destroy()
end

-- 當前選擇的語言 ("zh-TW" 繁體中文, "zh-CN" 简体中文, "en" English)
local currentLang = "zh-TW"

-- 從指定的白名單網址動態載入帳號密碼對照表
local expectedPassword = ""
local isUserRegistered = false

pcall(function()
    local jsonUrl = "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/password.json"
    local response = game:HttpGet(jsonUrl)
    local data = HttpService:JSONDecode(response)
    
    -- 取得當前登入玩家的 UserId (轉成字串以符合 JSON 的鍵值)
    local myUserId = tostring(LocalPlayer.UserId)
    
    -- 檢查對照表內有沒有這個帳號
    if data[myUserId] then
        expectedPassword = data[myUserId]
        isUserRegistered = true
    end
end)

-- 多語言文字字典 (新增管理員功能按鈕的翻譯)
local translations = {
    ["zh-TW"] = {
        title = "KrisVan 遊戲輔助選單 v1.0.3",
        selectLangTitle = "請選擇您的語言 / Please Select Language",
        pwdPrompt = "請輸入執行密碼：",
        pwdPlaceholder = "輸入密碼...",
        pwdError = "❌ 密碼錯誤，請重新輸入！",
        notAuthorized = "❌ 此帳號未獲授權！",
        drivingEmpire = "駕駛帝國",
        carDealership = "汽車經銷商大亨",
        mm2 = "誰是殺手2",
        midnightChasers = "午夜追逐者",
        stealAnEgg = "偷一個蛋",
        taxiBoss = "計程車大亨",
        rideStorm = "騎風暴",
        adminPosDisplay = "📍 即時座標顯示 (管理員專屬)",
        scriptConfirmDesc = "是否確定要執行此腳本？",
        backText = "返回語言選擇",
        btnConfirm = "確定",
        btnCancel = "取消",
    },
    ["zh-CN"] = {
        title = "KrisVan 游戏辅助选单 v1.0.3",
        selectLangTitle = "请选择您的语言 / Please Select Language",
        pwdPrompt = "请输入执行密码：",
        pwdPlaceholder = "输入密码...",
        pwdError = "❌ 密码错误，请重新输入！",
        notAuthorized = "❌ 此账号未获授权！",
        drivingEmpire = "驾驶帝国",
        carDealership = "汽车经销商大亨",
        mm2 = "谁是杀手2",
        midnightChasers = "午夜追逐者",
        stealAnEgg = "偷一个蛋",
        taxiBoss = "出租车大亨",
        rideStorm = "骑风暴",
        adminPosDisplay = "📍 实时坐标显示 (管理员专属)",
        scriptConfirmDesc = "是否确定要执行此脚本？",
        backText = "返回语言选择",
        btnConfirm = "确定",
        btnCancel = "取消",
    },
    ["en"] = {
        title = "KrisVan Game Hub Menu v1.0.3",
        selectLangTitle = "Please Select Language",
        pwdPrompt = "Please enter password:",
        pwdPlaceholder = "Enter password...",
        pwdError = "❌ Incorrect password, try again!",
        notAuthorized = "❌ This account is not authorized!",
        drivingEmpire = "Driving Empire",
        carDealership = "Car Dealership Tycoon",
        mm2 = "Murder Mystery 2",
        midnightChasers = "Midnight Chasers",
        stealAnEgg = "Steal an egg",
        taxiBoss = "Taxi Boss",
        rideStorm = "Ride Storm",
        adminPosDisplay = "📍 Live Position Display (Admin)",
        scriptConfirmDesc = "Are you sure you want to run this script?",
        backText = "Back to Language",
        btnConfirm = "Confirm",
        btnCancel = "Cancel",
    }
}

-- 建立 ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCustomUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 主視窗框架
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true

-- 紫色外框
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(150, 75, 230)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- 頂部標題列
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.BackgroundTransparency = 0.2
Header.Size = UDim2.new(1, 0, 0, 35)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0, 350, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.Text = "KrisVan 遊戲輔助"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- 內容容器
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 42)
Container.Size = UDim2.new(1, -20, 1, -50)

-- 畫面 1：語言選單頁面
local LangPage = Instance.new("ScrollingFrame")
LangPage.Name = "LangPage"
LangPage.Parent = Container
LangPage.BackgroundTransparency = 1
LangPage.Size = UDim2.new(1, 0, 1, 0)
LangPage.CanvasSize = UDim2.new(0, 0, 0, 160)
LangPage.ScrollBarThickness = 4

local LangPrompt = Instance.new("TextLabel")
LangPrompt.Name = "LangPrompt"
LangPrompt.Parent = LangPage
LangPrompt.BackgroundTransparency = 1
LangPrompt.Size = UDim2.new(1, 0, 0, 35)
LangPrompt.Font = Enum.Font.SourceSansBold
LangPrompt.Text = "請選擇您的語言 / Please Select Language"
LangPrompt.TextColor3 = Color3.fromRGB(240, 240, 240)
LangPrompt.TextSize = 15

-- 畫面 2：密碼輸入頁面
local PasswordPage = Instance.new("Frame")
PasswordPage.Name = "PasswordPage"
PasswordPage.Parent = Container
PasswordPage.BackgroundTransparency = 1
PasswordPage.Size = UDim2.new(1, 0, 1, 0)
PasswordPage.Visible = false

local PwdPrompt = Instance.new("TextLabel")
PwdPrompt.Name = "PwdPrompt"
PwdPrompt.Parent = PasswordPage
PwdPrompt.BackgroundTransparency = 1
PwdPrompt.Position = UDim2.new(0, 0, 0, 20)
PwdPrompt.Size = UDim2.new(1, 0, 0, 30)
PwdPrompt.Font = Enum.Font.SourceSansBold
PwdPrompt.Text = translations[currentLang].pwdPrompt
PwdPrompt.TextColor3 = Color3.fromRGB(240, 240, 240)
PwdPrompt.TextSize = 16

local PwdBox = Instance.new("TextBox")
PwdBox.Name = "PwdBox"
PwdBox.Parent = PasswordPage
PwdBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
PwdBox.BackgroundTransparency = 0.2
PwdBox.Position = UDim2.new(0.1, 0, 0, 65)
PwdBox.Size = UDim2.new(0.8, 0, 0, 45)
PwdBox.Font = Enum.Font.SourceSans
PwdBox.PlaceholderText = translations[currentLang].pwdPlaceholder
PwdBox.Text = ""
PwdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PwdBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
PwdBox.TextSize = 16
Instance.new("UICorner", PwdBox).CornerRadius = UDim.new(0, 6)
local PwdBoxStroke = Instance.new("UIStroke")
PwdBoxStroke.Color = Color3.fromRGB(100, 100, 120)
PwdBoxStroke.Parent = PwdBox

local PwdErrorLabel = Instance.new("TextLabel")
PwdErrorLabel.Name = "PwdErrorLabel"
PwdErrorLabel.Parent = PasswordPage
PwdErrorLabel.BackgroundTransparency = 1
PwdErrorLabel.Position = UDim2.new(0, 0, 0, 115)
PwdErrorLabel.Size = UDim2.new(1, 0, 0, 25)
PwdErrorLabel.Font = Enum.Font.SourceSansSemibold
PwdErrorLabel.Text = ""
PwdErrorLabel.TextColor3 = Color3.fromRGB(235, 60, 60)
PwdErrorLabel.TextSize = 14

local PwdSubmitBtn = Instance.new("TextButton")
PwdSubmitBtn.Name = "PwdSubmitBtn"
PwdSubmitBtn.Parent = PasswordPage
PwdSubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 75, 230)
PwdSubmitBtn.Position = UDim2.new(0.25, 0, 0, 155)
PwdSubmitBtn.Size = UDim2.new(0.5, 0, 0, 45)
PwdSubmitBtn.Font = Enum.Font.SourceSansBold
PwdSubmitBtn.Text = translations[currentLang].btnConfirm
PwdSubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PwdSubmitBtn.TextSize = 16
Instance.new("UICorner", PwdSubmitBtn).CornerRadius = UDim.new(0, 6)

-- 畫面 3：腳本選單頁面
local ScriptsPage = Instance.new("ScrollingFrame")
ScriptsPage.Name = "ScriptsPage"
ScriptsPage.Parent = Container
ScriptsPage.BackgroundTransparency = 1
ScriptsPage.Size = UDim2.new(1, 0, 1, 0)
ScriptsPage.CanvasSize = UDim2.new(0, 0, 0, 430) -- 加大容量以容納管理員按鈕
ScriptsPage.ScrollBarThickness = 4
ScriptsPage.Visible = false

local btn1, btn2, btn3, btn4, btn5, btn6, btn7, adminBtn, BackBtn
local ConfirmOverlay, DialogBox, DialogText, YesBtn, NoBtn
local pendingUrl = nil
local pendingCallback = nil -- 用於支援不關閉選單的自定義動作

local function createScriptBtn(nameKey, posY, url)
    local btn = Instance.new("TextButton")
    btn.Name = nameKey
    btn.Parent = ScriptsPage
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 0.2
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Size = UDim2.new(1, -6, 0, 38)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        pendingUrl = url
        pendingCallback = nil
        DialogText.Text = translations[currentLang].scriptConfirmDesc
        YesBtn.Text = translations[currentLang].btnConfirm
        NoBtn.Text = translations[currentLang].btnCancel
        ConfirmOverlay.Visible = true
    end)
    
    return btn
end

btn1 = createScriptBtn("drivingEmpire", 0, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVanauto.lua")
btn2 = createScriptBtn("carDealership", 44, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVancdt.lua")
btn3 = createScriptBtn("mm2", 88, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVanmm2.lua")
btn4 = createScriptBtn("midnightChasers", 132, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisMidnight.lua")
btn5 = createScriptBtn("stealAnEgg", 176, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/Egg.lua")
btn6 = createScriptBtn("taxiBoss", 220, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/Taxiboss.lua")
btn7 = createScriptBtn("rideStorm", 264, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/Ride.lua")

-- 建立返回按鈕 (預設位置在一般按鈕下方)
BackBtn = Instance.new("TextButton")
BackBtn.Name = "BackBtn"
BackBtn.Parent = ScriptsPage
BackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
BackBtn.BackgroundTransparency = 0.2
BackBtn.Position = UDim2.new(0, 0, 0, 312)
BackBtn.Size = UDim2.new(1, -6, 0, 38)
BackBtn.Font = Enum.Font.SourceSansSemibold
BackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
BackBtn.TextSize = 14
Instance.new("UICorner", BackBtn).CornerRadius = UDim.new(0, 6)

BackBtn.MouseButton1Click:Connect(function()
    ScriptsPage.Visible = false
    LangPage.Visible = true
end)

local function updateTexts()
    TitleLabel.Text = translations[currentLang].title
    LangPrompt.Text = translations[currentLang].selectLangTitle
    PwdPrompt.Text = translations[currentLang].pwdPrompt
    PwdBox.PlaceholderText = translations[currentLang].pwdPlaceholder
    PwdSubmitBtn.Text = translations[currentLang].btnConfirm
    btn1.Text = translations[currentLang].drivingEmpire
    btn2.Text = translations[currentLang].carDealership
    btn3.Text = translations[currentLang].mm2
    btn4.Text = translations[currentLang].midnightChasers
    btn5.Text = translations[currentLang].stealAnEgg
    btn6.Text = translations[currentLang].taxiBoss
    btn7.Text = translations[currentLang].rideStorm
    if adminBtn then
        adminBtn.Text = translations[currentLang].adminPosDisplay
    end
    BackBtn.Text = translations[currentLang].backText
end

-- 密碼驗證邏輯 (含白名單檢查與管理員動態生成)
PwdSubmitBtn.MouseButton1Click:Connect(function()
    if not isUserRegistered then
        PwdErrorLabel.Text = translations[currentLang].notAuthorized
        task.delay(2, function()
            if PwdErrorLabel then PwdErrorLabel.Text = "" end
        end)
        return
    end

    if PwdBox.Text == expectedPassword then
        -- 檢查是否為管理員密碼 ("KrisVan_admin")
        if PwdBox.Text == "KrisVan_admin" then
            ScriptsPage.CanvasSize = UDim2.new(0, 0, 0, 410)
            
            -- 動態生成管理員專屬按鈕（點擊後不關閉選單）
            adminBtn = Instance.new("TextButton")
            adminBtn.Name = "AdminPosBtn"
            adminBtn.Parent = ScriptsPage
            adminBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 180) -- 特殊紫色標示
            adminBtn.BackgroundTransparency = 0.2
            adminBtn.Position = UDim2.new(0, 0, 0, 312)
            adminBtn.Size = UDim2.new(1, -6, 0, 38)
            adminBtn.Font = Enum.Font.SourceSansBold
            adminBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            adminBtn.TextSize = 14
            adminBtn.Text = translations[currentLang].adminPosDisplay
            Instance.new("UICorner", adminBtn).CornerRadius = UDim.new(0, 6)
            
            -- 將原本的返回按鈕往下挪
            BackBtn.Position = UDim2.new(0, 0, 0, 356)
            
            -- 綁定管理員按鈕點擊事件：執行座標顯示，且「不」銷毀選單
            adminBtn.MouseButton1Click:Connect(function()
                pendingUrl = nil
                pendingCallback = function()
                    -- 內嵌你的座標顯示器邏輯
                    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                    if playerGui:FindFirstChild("PositionDisplayGui") then
                        playerGui.PositionDisplayGui:Destroy()
                    end

                    local screenGui = Instance.new("ScreenGui")
                    screenGui.Name = "PositionDisplayGui"
                    screenGui.ResetOnSpawn = false
                    screenGui.Parent = playerGui

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Name = "PosLabel"
                    textLabel.Size = UDim2.new(0, 220, 0, 50)
                    textLabel.Position = UDim2.new(1, -230, 0, 10)
                    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.BackgroundTransparency = 0.5
                    textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    textLabel.TextSize = 16
                    textLabel.Font = Enum.Font.Code
                    textLabel.Text = "正在載入座標..."
                    textLabel.Parent = screenGui

                    local uiCorner = Instance.new("UICorner")
                    uiCorner.CornerRadius = UDim.new(0, 8)
                    uiCorner.Parent = textLabel

                    task.spawn(function()
                        while screenGui.Parent do
                            local character = LocalPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local pos = character.HumanoidRootPart.Position
                                textLabel.Text = string.format("X: %.1f\nY: %.1f\nZ: %.1f", pos.X, pos.Y, pos.Z)
                            else
                                textLabel.Text = "尋找中人物位置..."
                            end
                            task.wait(0.2)
                        end
                    end)
                end
                
                DialogText.Text = translations[currentLang].scriptConfirmDesc
                YesBtn.Text = translations[currentLang].btnConfirm
                NoBtn.Text = translations[currentLang].btnCancel
                ConfirmOverlay.Visible = true
            end)
        end

        PasswordPage.Visible = false
        ScriptsPage.Visible = true
    else
        PwdErrorLabel.Text = translations[currentLang].pwdError
        task.delay(2, function()
            if PwdErrorLabel then PwdErrorLabel.Text = "" end
        end)
    end
end)

local function createLangSelectBtn(langCode, langName, posY)
    local btn = Instance.new("TextButton")
    btn.Parent = LangPage
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 0.2
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Size = UDim2.new(1, -6, 0, 45)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Text = langName
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 15
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentLang = langCode
        updateTexts()
        LangPage.Visible = false
        PasswordPage.Visible = true
    end)
end

createLangSelectBtn("zh-TW", "繁體中文", 40)
createLangSelectBtn("zh-CN", "简体中文", 92)
createLangSelectBtn("en", "English", 144)

ConfirmOverlay = Instance.new("Frame")
ConfirmOverlay.Name = "ConfirmOverlay"
ConfirmOverlay.Parent = ScreenGui
ConfirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ConfirmOverlay.BackgroundTransparency = 0.6
ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
ConfirmOverlay.Visible = false
ConfirmOverlay.ZIndex = 10

DialogBox = Instance.new("Frame")
DialogBox.Parent = ConfirmOverlay
DialogBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DialogBox.Position = UDim2.new(0.5, -130, 0.5, -60)
DialogBox.Size = UDim2.new(0, 260, 0, 120)
DialogBox.ZIndex = 11
Instance.new("UICorner", DialogBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", DialogBox).Color = Color3.fromRGB(150, 75, 230)

DialogText = Instance.new("TextLabel")
DialogText.Parent = DialogBox
DialogText.BackgroundTransparency = 1
DialogText.Position = UDim2.new(0, 10, 0, 15)
DialogText.Size = UDim2.new(1, -20, 0, 40)
DialogText.Font = Enum.Font.SourceSansSemibold
DialogText.TextColor3 = Color3.fromRGB(240, 240, 240)
DialogText.TextSize = 15
DialogText.ZIndex = 12
DialogText.TextWrapped = true

YesBtn = Instance.new("TextButton")
YesBtn.Parent = DialogBox
YesBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
YesBtn.Position = UDim2.new(0, 15, 0, 70)
YesBtn.Size = UDim2.new(0, 105, 0, 35)
YesBtn.Font = Enum.Font.SourceSansBold
YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
YesBtn.TextSize = 14
YesBtn.ZIndex = 12
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

NoBtn = Instance.new("TextButton")
NoBtn.Parent = DialogBox
NoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
NoBtn.Position = UDim2.new(1, -120, 0, 70)
NoBtn.Size = UDim2.new(0, 105, 0, 35)
NoBtn.Font = Enum.Font.SourceSansBold
NoBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
NoBtn.TextSize = 14
NoBtn.ZIndex = 12
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

-- 確認按鈕行為：如果是管理員按鈕，執行完後不銷毀介面；一般腳本則會執行並銷毀介面
YesBtn.MouseButton1Click:Connect(function()
    ConfirmOverlay.Visible = false
    if pendingCallback then
        pendingCallback()
        pendingCallback = nil
    elseif pendingUrl then
        local urlToRun = pendingUrl
        ScreenGui:Destroy()
        pcall(function() loadstring(game:HttpGet(urlToRun))() end)
    end
end)

NoBtn.MouseButton1Click:Connect(function()
    ConfirmOverlay.Visible = false
    pendingUrl = nil
    pendingCallback = nil
end)

-- 拖動功能
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

