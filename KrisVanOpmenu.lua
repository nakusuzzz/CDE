-- 確保不會重複生成
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("DeltaCustomUI") then
    CoreGui.DeltaCustomUI:Destroy()
end

-- 當前選擇的語言 ("zh-TW" 繁體中文, "zh-CN" 简体中文, "en" English)
local currentLang = "zh-TW"

-- 多語言文字字典
local translations = {
    ["zh-TW"] = {
        title = "KrisVan 遊戲輔助選單 v1.0.3",
        selectLangTitle = "請選擇您的語言 / Please Select Language",
        drivingEmpire = "駕駛帝國",
        carDealership = "汽車經銷商大亨",
        mm2 = "誰是殺手2",
        scriptConfirmDesc = "是否確定要執行此腳本？",
        backText = "返回語言選擇",
        closeTitle = "提示",
        closeDesc = "是否要關閉腳本選單？",
        btnConfirm = "確定",
        btnCancel = "取消",
    },
    ["zh-CN"] = {
        title = "KrisVan 游戏辅助选单 v1.0.3",
        selectLangTitle = "请选择您的语言 / Please Select Language",
        drivingEmpire = "驾驶帝国",
        carDealership = "汽车经销商大亨",
        mm2 = "谁是杀手2",
        scriptConfirmDesc = "是否确定要执行此脚本？",
        backText = "返回语言选择",
        closeTitle = "提示",
        closeDesc = "是否要关闭脚本菜单？",
        btnConfirm = "确定",
        btnCancel = "取消",
    },
    ["en"] = {
        title = "KrisVan Game Hub Menu v1.0.3",
        selectLangTitle = "Please Select Language",
        drivingEmpire = "Driving Empire",
        carDealership = "Car Dealership Tycoon",
        mm2 = "Murder Mystery 2",
        scriptConfirmDesc = "Are you sure you want to run this script?",
        backText = "Back to Language",
        closeTitle = "Notice",
        closeDesc = "Do you want to close the script menu?",
        btnConfirm = "Confirm",
        btnCancel = "Cancel",
    }
}

-- 建立 ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCustomUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 主視窗框架 (半透明背景)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -165)
MainFrame.Size = UDim2.new(0, 400, 0, 330)
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
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.Text = "KrisVan 遊戲輔助"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- 關閉按鈕
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -11)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(235, 60, 60)
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- 內容容器
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 15, 0, 45)
Container.Size = UDim2.new(1, -30, 1, -55)

-- 畫面 1：語言選單頁面
local LangPage = Instance.new("Frame")
LangPage.Name = "LangPage"
LangPage.Parent = Container
LangPage.BackgroundTransparency = 1
LangPage.Size = UDim2.new(1, 0, 1, 0)

local LangPrompt = Instance.new("TextLabel")
LangPrompt.Parent = LangPage
LangPrompt.BackgroundTransparency = 1
LangPrompt.Size = UDim2.new(1, 0, 0, 40)
LangPrompt.Font = Enum.Font.SourceSansBold
LangPrompt.Text = "請選擇您的語言 / Please Select Language"
LangPrompt.TextColor3 = Color3.fromRGB(240, 240, 240)
LangPrompt.TextSize = 16

-- 畫面 2：腳本選單頁面 (預設隱藏)
local ScriptsPage = Instance.new("Frame")
ScriptsPage.Name = "ScriptsPage"
ScriptsPage.Parent = Container
ScriptsPage.BackgroundTransparency = 1
ScriptsPage.Size = UDim2.new(1, 0, 1, 0)
ScriptsPage.Visible = false

-- 宣告 UI 參考變數
local btn1, btn2, btn3, BackBtn

-- 宣告共用的確認彈窗變數
local ConfirmOverlay, DialogBox, DialogText, YesBtn, NoBtn
local pendingUrl = nil -- 用來暫存準備執行的網址

-- 建立腳本按鈕的函數 (改為點擊時開啟彈窗)
local function createScriptBtn(nameKey, posY, url)
    local btn = Instance.new("TextButton")
    btn.Name = nameKey
    btn.Parent = ScriptsPage
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 0.2
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Size = UDim2.new(1, 0, 0, 45)
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
btn2 = createScriptBtn("carDealership", 55, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVancdt.lua")
btn3 = createScriptBtn("mm2", 110, "https://raw.githubusercontent.com/nakusuzzz/CDE/refs/heads/main/KrisVanmm2.lua")

-- 新增：返回語言選擇按鈕
BackBtn = Instance.new("TextButton")
BackBtn.Name = "BackBtn"
BackBtn.Parent = ScriptsPage
BackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
BackBtn.BackgroundTransparency = 0.2
BackBtn.Position = UDim2.new(0, 0, 0, 165)
BackBtn.Size = UDim2.new(1, 0, 0, 45)
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
    btn1.Text = translations[currentLang].drivingEmpire
    btn2.Text = translations[currentLang].carDealership
    btn3.Text = translations[currentLang].mm2
    BackBtn.Text = translations[currentLang].backText
end

-- 建立語言選擇按鈕
local function createLangSelectBtn(langCode, langName, posY)
    local btn = Instance.new("TextButton")
    btn.Parent = LangPage
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 0.2
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Text = langName
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 16
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentLang = langCode
        updateTexts()
        LangPage.Visible = false
        ScriptsPage.Visible = true
    end)
end

createLangSelectBtn("zh-TW", "繁體中文", 50)
createLangSelectBtn("zh-CN", "简体中文", 110)
createLangSelectBtn("en", "English", 170)

-- 二次確認彈窗 (共用)
ConfirmOverlay = Instance.new("Frame")
ConfirmOverlay.Name = "ConfirmOverlay"
ConfirmOverlay.Parent = MainFrame
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

-- 點擊關閉按鈕時彈出關閉確認窗
CloseBtn.MouseButton1Click:Connect(function()
    pendingUrl = nil -- 清空待執行網址，代表這是要關閉介面
    DialogText.Text = translations[currentLang].closeDesc
    YesBtn.Text = translations[currentLang].btnConfirm
    NoBtn.Text = translations[currentLang].btnCancel
    ConfirmOverlay.Visible = true
end)

-- 確定按鈕 (根據 pendingUrl 來判斷是要執行腳本還是關閉介面)
YesBtn.MouseButton1Click:Connect(function()
    if pendingUrl then
        local urlToRun = pendingUrl
        ScreenGui:Destroy()
        pcall(function() loadstring(game:HttpGet(urlToRun))() end)
    else
        ScreenGui:Destroy()
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

