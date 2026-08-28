-- 確保不會重複生成
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("DeltaCustomUI") then
    CoreGui.DeltaCustomUI:Destroy()
end

-- 當前選擇的語言 ("zh-TW" 繁體中文, "zh-CN" 简体中文, "en" English)
local currentLang = "zh-TW"

-- 設定更新後的腳本密碼
local scriptPassword = "Ziwjri19fk2o.s92j"

-- 多語言文字字典
local translations = {
    ["zh-TW"] = {
        title = "KrisVan 遊戲輔助選單 v1.0.3",
        selectLangTitle = "請選擇您的語言 / Please Select Language",
        pwdPrompt = "請輸入執行密碼：",
        pwdPlaceholder = "輸入密碼...",
        pwdError = "❌ 密碼錯誤，請重新輸入！",
        drivingEmpire = "駕駛帝國",
        carDealership = "汽車經銷商大亨",
        mm2 = "誰是殺手2",
        midnightChasers = "午夜追逐者",
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
        drivingEmpire = "驾驶帝国",
        carDealership = "汽车经销商大亨",
        mm2 = "谁是杀手2",
        midnightChasers = "午夜追逐者",
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
        drivingEmpire = "Driving Empire",
        carDealership = "Car Dealership Tycoon",
        mm2 = "Murder Mystery 2",
        midnightChasers = "Midnight Chasers",
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

-- 主視窗框架 (高度縮小至 270)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -135)
MainFrame.Size = UDim2.new(0, 400, 0, 270)
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

-- 畫面 1：語言選單頁面 (預設顯示)
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

-- 畫面 2：密碼輸入頁面 (預設隱藏)
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

-- 畫面 3：腳本選單頁面 (預設隱藏)
local ScriptsPage = Instance.new("ScrollingFrame")
ScriptsPage.Name = "ScriptsPage"
ScriptsPage.Parent = Container
ScriptsPage.BackgroundTransparency = 1
ScriptsPage.Size = UDim2.new(1, 0, 1, 0)
ScriptsPage.CanvasSize = UDim2.new(0, 0, 0, 270)
ScriptsPage.ScrollBarThickness = 4
ScriptsPage.Visible = false

-- 宣告 UI 參考變數
local btn1, btn2, btn3, btn4, BackBtn

-- 宣告共用的確認彈窗變數
local ConfirmOverlay, DialogBox, DialogText, YesBtn, NoBtn
local pendingUrl = nil

-- 建立腳本按鈕的函數
local function createScriptBtn(nameKey, posY, url)
    local btn = Instance.new("TextButton")
    btn.Name = nameKey
    btn.Parent = ScriptsPage
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 0.2
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Size = UDim2.new(1, -6, 0, 45)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 15
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        pendingUrl = url
        DialogText.Text = translations[currentLang].scriptConfirmDesc
        YesBtn.Text = translations[currentLang].btnConfirm
        NoBtn.Text = translations[currentLang].btnCancel
        ConfirmOverlay.Visible = true
    end)
    
    return btn
end

btn1 = createScriptBtn("drivingEmpire", 0, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVanauto.lua")
btn2 = createScriptBtn("carDealership", 52, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVancdt.lua")
btn3 = createScriptBtn("mm2", 104, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVanmm2.lua")
btn4 = createScriptBtn("midnightChasers", 156, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisMidnight.lua")

-- 返回語言選擇按鈕
BackBtn = Instance.new("TextButton")
BackBtn.Name = "BackBtn"
BackBtn.Parent = ScriptsPage
BackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
BackBtn.BackgroundTransparency = 0.2
BackBtn.Position = UDim2.new(0, 0, 0, 215)
BackBtn.Size = UDim2.new(1, -6, 0, 45)
BackBtn.Font = Enum.Font.SourceSansSemibold
BackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
BackBtn.TextSize = 15
Instance.new("UICorner", BackBtn).CornerRadius = UDim.new(0, 6)

BackBtn.MouseButton1Click:Connect(function()
    ScriptsPage.Visible = false
    LangPage.Visible = true
end)

-- 更新文字內容的函數
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
    BackBtn.Text = translations[currentLang].backText
end

-- 密碼驗證邏輯
PwdSubmitBtn.MouseButton1Click:Connect(function()
    if PwdBox.Text == scriptPassword then
        PasswordPage.Visible = false
        ScriptsPage.Visible = true
    else
        PwdErrorLabel.Text = translations[currentLang].pwdError
        task.delay(2, function()
            if PwdErrorLabel then
                PwdErrorLabel.Text = ""
            end
        end)
    end
end)

-- 建立語言選擇按鈕 (選擇後進入密碼頁面)
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

-- 二次確認彈窗
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

-- 確定按鈕 (執行腳本)
YesBtn.MouseButton1Click:Connect(function()
    if pendingUrl then
        local urlToRun = pendingUrl
        ScreenGui:Destroy()
        pcall(function() loadstring(game:HttpGet(urlToRun))() end)
    end
end)

-- 取消按鈕
NoBtn.MouseButton1Click:Connect(function()
    ConfirmOverlay.Visible = false
    pendingUrl = nil
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

