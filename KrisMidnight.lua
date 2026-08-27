--[[
	WARNING: KrisVan Script (Special Ed.) - Custom Image Asset Floating Button v1.1.1
	[Modified: Reordered Sidebar Tabs - Settings moved below Traffic Ghost]
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isAntiAfkEnabled = false
local isWalkSpeedEnabled = false
local isJumpPowerEnabled = false
local isInfiniteJumpEnabled = false
local activeConnections = {}

-- 全域自動駕駛與穿透變數
_G.V29_TrafficNoclip = false
_G.V29_Mode = "None"
_G.V29_Speed = 370 
_G.V29_Setup = false 
_G.V29_Waypoint = 1 

local HIGHWAY_PATH = {
    Vector3.new(3305.3, -17.7, 834.7), Vector3.new(3265.1, -17.7, 812.8), Vector3.new(3227.8, -17.7, 792.1),
    Vector3.new(3192.5, -17.7, 771.8), Vector3.new(3152.6, -17.7, 748.8), Vector3.new(3117.4, -17.6, 729.6),
    Vector3.new(3078.9, -17.7, 710.7), Vector3.new(3035.2, -17.7, 690.2), Vector3.new(2990.8, -17.7, 669.5),
    Vector3.new(2941.3, -17.7, 649.9), Vector3.new(2887.0, -17.7, 630.7), Vector3.new(2832.8, -17.7, 611.5),
    Vector3.new(2777.6, -17.7, 592.0), Vector3.new(2736.8, -17.5, 576.8), Vector3.new(2680.7, -17.1, 555.2),
    Vector3.new(2642.7, -16.6, 541.5), Vector3.new(2590.9, -15.7, 523.7), Vector3.new(2542.3, -14.6, 507.9),
    Vector3.new(2496.4, -13.4, 492.9), Vector3.new(2451.9, -11.9, 477.5), Vector3.new(2405.7, -10.3, 461.4),
    Vector3.new(2357.8, -8.3, 444.6), Vector3.new(2313.5, -6.3, 429.1), Vector3.new(2263.8, -3.8, 412.1),
    Vector3.new(2209.4, -0.8, 393.9), Vector3.new(2155.9, 2.1, 376.3), Vector3.new(2103.4, 5.0, 359.1),
    Vector3.new(2051.0, 7.5, 341.9), Vector3.new(1999.8, 9.7, 325.2), Vector3.new(1944.9, 11.8, 307.2),
    Vector3.new(1879.9, 13.9, 286.0), Vector3.new(1825.3, 15.4, 268.1), Vector3.new(1773.3, 16.5, 251.1),
    Vector3.new(1714.5, 17.4, 231.8), Vector3.new(1653.8, 18.0, 211.9), Vector3.new(1596.8, 18.2, 193.2),
    Vector3.new(1537.9, 18.2, 173.9), Vector3.new(1473.8, 18.2, 152.8), Vector3.new(1407.7, 18.2, 131.7),
    Vector3.new(1338.0, 18.2, 111.3), Vector3.new(1268.4, 18.2, 98.2), Vector3.new(1214.3, 18.2, 89.9),
    Vector3.new(1150.6, 18.1, 81.8), Vector3.new(1088.0, 18.2, 75.4), Vector3.new(1028.7, 18.2, 71.2),
    Vector3.new(974.6, 18.3, 70.5), Vector3.new(920.8, 18.2, 73.1), Vector3.new(860.0, 18.2, 77.8),
    Vector3.new(803.5, 18.2, 80.6), Vector3.new(741.8, 18.2, 81.5), Vector3.new(683.7, 18.2, 82.5),
    Vector3.new(629.1, 18.2, 83.9), Vector3.new(566.0, 18.2, 85.0), Vector3.new(504.3, 18.2, 86.2),
    Vector3.new(434.9, 18.2, 87.4), Vector3.new(376.2, 18.2, 88.1), Vector3.new(307.4, 18.2, 87.9),
    Vector3.new(242.4, 18.2, 87.6), Vector3.new(180.3, 18.2, 87.3), Vector3.new(115.1, 18.2, 87.1),
    Vector3.new(41.8, 18.2, 86.8), Vector3.new(-20.0, 18.2, 86.6), Vector3.new(-82.4, 18.2, 86.5),
    Vector3.new(-151.7, 18.2, 86.3), Vector3.new(-224.3, 18.2, 86.2), Vector3.new(-266.7, 18.2, 86.1),
    Vector3.new(-306.8, 18.2, 86.1), Vector3.new(-374.4, 18.2, 86.0), Vector3.new(-444.1, 18.2, 86.0),
    Vector3.new(-513.0, 18.2, 86.1), Vector3.new(-582.5, 18.2, 86.1), Vector3.new(-651.3, 18.2, 86.2),
    Vector3.new(-728.8, 18.2, 86.3), Vector3.new(-800.2, 18.1, 86.5), Vector3.new(-870.8, 18.2, 86.6),
    Vector3.new(-944.6, 18.2, 86.7), Vector3.new(-1016.1, 17.9, 87.2), Vector3.new(-1090.8, 17.1, 89.8),
    Vector3.new(-1164.3, 15.9, 95.9), Vector3.new(-1205.5, 14.9, 100.7), Vector3.new(-1246.8, 13.8, 105.9),
    Vector3.new(-1289.6, 12.4, 111.5), Vector3.new(-1330.7, 11.0, 117.3), Vector3.new(-1370.8, 9.5, 125.1),
    Vector3.new(-1441.6, 6.6, 138.5), Vector3.new(-1519.0, 2.5, 156.9), Vector3.new(-1568.8, -0.2, 169.8),
    Vector3.new(-1642.2, -4.1, 189.2), Vector3.new(-1681.8, -6.2, 199.9), Vector3.new(-1755.2, -9.4, 217.9),
    Vector3.new(-1825.2, -11.9, 234.1), Vector3.new(-1899.5, -14.0, 251.4), Vector3.new(-1938.5, -14.9, 261.2),
    Vector3.new(-2010.7, -16.3, 281.1), Vector3.new(-2052.3, -16.8, 292.6), Vector3.new(-2130.6, -17.4, 312.2),
    Vector3.new(-2210.6, -17.4, 330.4), Vector3.new(-2252.7, -17.4, 339.9), Vector3.new(-2323.0, -16.9, 355.0),
    Vector3.new(-2398.9, -15.8, 370.7), Vector3.new(-2467.7, -14.5, 385.0), Vector3.new(-2536.5, -12.7, 399.3),
    Vector3.new(-2612.4, -10.2, 414.6), Vector3.new(-2654.5, -8.5, 423.2), Vector3.new(-2696.6, -6.7, 431.9),
    Vector3.new(-2769.5, -3.2, 447.0), Vector3.new(-2842.3, 0.6, 462.1), Vector3.new(-2881.6, 2.7, 470.1),
    Vector3.new(-2923.6, 5.0, 478.8), Vector3.new(-2964.3, 7.2, 487.1), Vector3.new(-3006.3, 9.2, 495.8),
    Vector3.new(-3045.6, 11.0, 503.8), Vector3.new(-3086.4, 12.7, 512.2), Vector3.new(-3128.4, 14.3, 521.0),
    Vector3.new(-3167.7, 15.6, 529.3), Vector3.new(-3208.4, 16.8, 537.9), Vector3.new(-3258.9, 18.1, 548.5),
    Vector3.new(-3298.2, 19.0, 556.8), Vector3.new(-3368.4, 20.1, 571.6), Vector3.new(-3411.9, 20.6, 580.7),
    Vector3.new(-3451.3, 20.9, 589.1), Vector3.new(-3527.2, 21.0, 605.1), Vector3.new(-3604.6, 21.0, 621.4),
    Vector3.new(-3687.6, 21.0, 639.0), Vector3.new(-3732.6, 21.0, 648.6), Vector3.new(-3805.6, 21.0, 664.0),
    Vector3.new(-3887.1, 21.1, 681.4), Vector3.new(-3957.4, 21.0, 696.4), Vector3.new(-3998.2, 21.0, 705.1),
    Vector3.new(-4040.4, 21.0, 714.1), Vector3.new(-4079.8, 21.0, 722.0), Vector3.new(-4123.5, 21.1, 730.7),
    Vector3.new(-4199.6, 21.7, 746.1), Vector3.new(-4240.4, 22.2, 754.8), Vector3.new(-4312.2, 23.4, 770.2),
    Vector3.new(-4355.6, 24.2, 779.8), Vector3.new(-4428.4, 25.5, 796.4), Vector3.new(-4506.8, 26.9, 814.4),
    Vector3.new(-4581.0, 28.1, 831.1), Vector3.new(-4658.0, 28.8, 848.4), Vector3.new(-4726.8, 29.1, 863.7),
    Vector3.new(-4768.8, 29.2, 873.2), Vector3.new(-4851.6, 28.8, 891.7), Vector3.new(-4895.0, 28.4, 901.4),
    Vector3.new(-4935.7, 27.9, 910.5), Vector3.new(-5008.8, 26.7, 926.9), Vector3.new(-5083.3, 25.3, 943.5),
    Vector3.new(-5124.0, 24.6, 952.6), Vector3.new(-5167.6, 23.8, 962.3), Vector3.new(-5208.3, 23.1, 971.4),
    Vector3.new(-5251.9, 22.3, 981.1), Vector3.new(-5322.2, 21.1, 996.6), Vector3.new(-5401.0, 19.7, 1013.7),
    Vector3.new(-5443.2, 18.9, 1022.8), Vector3.new(-5517.8, 17.6, 1038.8), Vector3.new(-5561.4, 16.8, 1048.1),
    Vector3.new(-5603.7, 16.0, 1057.1), Vector3.new(-5647.3, 15.3, 1066.4), Vector3.new(-5724.7, 13.9, 1083.0),
    Vector3.new(-5764.1, 13.2, 1091.4), Vector3.new(-5809.2, 12.4, 1101.0), Vector3.new(-5882.4, 11.1, 1116.6),
    Vector3.new(-5921.8, 10.4, 1125.0), Vector3.new(-5962.6, 9.6, 1133.7), Vector3.new(-6035.8, 8.4, 1149.3),
    Vector3.new(-6075.3, 7.9, 1157.6), Vector3.new(-6114.7, 7.6, 1166.0), Vector3.new(-6154.1, 7.4, 1174.4),
    Vector3.new(-6225.9, 7.3, 1189.6), Vector3.new(-6266.7, 7.4, 1198.2), Vector3.new(-6341.1, 7.3, 1214.0),
    Vector3.new(-6415.7, 7.3, 1229.8), Vector3.new(-6456.5, 7.3, 1238.4), Vector3.new(-6531.0, 7.3, 1254.1),
    Vector3.new(-6604.2, 7.3, 1269.5), Vector3.new(-6682.9, 7.3, 1286.0), Vector3.new(-6753.3, 7.3, 1300.8),
    Vector3.new(-6826.5, 7.3, 1316.2), Vector3.new(-6896.8, 7.3, 1331.0), Vector3.new(-6974.2, 7.3, 1347.3),
    Vector3.new(-7015.0, 7.3, 1355.9), Vector3.new(-7092.4, 7.3, 1372.1), Vector3.new(-7171.2, 7.3, 1388.7),
    Vector3.new(-7244.3, 7.4, 1404.0), Vector3.new(-7286.5, 7.3, 1412.9), Vector3.new(-7358.2, 7.3, 1428.0),
    Vector3.new(-7434.2, 7.3, 1444.1), Vector3.new(-7508.6, 7.5, 1460.1), Vector3.new(-7547.7, 7.4, 1469.3),
    Vector3.new(-7621.0, 7.4, 1489.2), Vector3.new(-7696.1, 7.5, 1514.6), Vector3.new(-7762.8, 7.6, 1541.5),
    Vector3.new(-7834.0, 7.4, 1573.1), Vector3.new(-7899.0, 7.3, 1602.2), Vector3.new(-7967.0, 7.3, 1632.7),
    Vector3.new(-8015.4, 7.4, 1654.4), Vector3.new(-8062.6, 7.3, 1675.5), Vector3.new(-8106.0, 7.3, 1694.7),
    Vector3.new(-8142.8, 7.3, 1711.0), Vector3.new(-8182.3, 7.3, 1728.3), Vector3.new(-8220.4, 7.3, 1745.1),
    Vector3.new(-8259.9, 7.2, 1762.5), Vector3.new(-8303.6, 6.7, 1781.2), Vector3.new(-8340.7, 6.3, 1796.9),
    Vector3.new(-8383.1, 5.5, 1814.8), Vector3.new(-8420.2, 4.7, 1830.4), Vector3.new(-8489.1, 2.9, 1859.7),
    Vector3.new(-8562.0, 0.3, 1890.8), Vector3.new(-8634.8, -2.5, 1921.9), Vector3.new(-8674.6, -4.2, 1938.9),
    Vector3.new(-8711.7, -6.0, 1954.8), Vector3.new(-8783.2, -9.7, 1985.3), Vector3.new(-8825.6, -12.3, 2003.4),
    Vector3.new(-8862.6, -14.7, 2019.3), Vector3.new(-8902.4, -17.3, 2036.3), Vector3.new(-8972.5, -22.5, 2066.3),
    Vector3.new(-9040.0, -28.0, 2095.2), Vector3.new(-9107.5, -33.9, 2124.1), Vector3.new(-9179.0, -40.7, 2154.7),
    Vector3.new(-9217.4, -44.4, 2171.1), Vector3.new(-9286.2, -50.9, 2200.7), Vector3.new(-9357.5, -57.7, 2231.9),
    Vector3.new(-9427.5, -64.4, 2262.7), Vector3.new(-9464.5, -67.9, 2278.9), Vector3.new(-9537.1, -74.9, 2310.9),
    Vector3.new(-9574.1, -78.4, 2327.2), Vector3.new(-9613.7, -82.0, 2344.6), Vector3.new(-9685.0, -88.1, 2376.0),
    Vector3.new(-9723.3, -91.2, 2392.9), Vector3.new(-9798.4, -96.6, 2426.1), Vector3.new(-9837.9, -99.3, 2443.5),
    Vector3.new(-9874.9, -101.6, 2459.7), Vector3.new(-9912.0, -103.8, 2475.5), Vector3.new(-9951.9, -106.0, 2492.2),
    Vector3.new(-10018.3, -109.2, 2520.0), Vector3.new(-10056.8, -110.9, 2536.1), Vector3.new(-10124.6, -113.4, 2564.5),
    Vector3.new(-10163.1, -114.7, 2580.7), Vector3.new(-10200.2, -115.8, 2596.4), Vector3.new(-10237.4, -116.7, 2612.0),
    Vector3.new(-10305.2, -117.9, 2640.6), Vector3.new(-10375.5, -118.7, 2670.2), Vector3.new(-10414.0, -119.0, 2686.4),
    Vector3.new(-10485.6, -119.0, 2716.6), Vector3.new(-10555.9, -118.5, 2746.2), Vector3.new(-10592.9, -118.0, 2761.8),
    Vector3.new(-10631.3, -117.3, 2778.0), Vector3.new(-10669.7, -116.5, 2794.2), Vector3.new(-10710.7, -115.5, 2811.4),
    Vector3.new(-10749.1, -114.3, 2827.6), Vector3.new(-10820.5, -111.8, 2857.6), Vector3.new(-10858.8, -110.3, 2873.7),
    Vector3.new(-10899.7, -108.4, 2891.0), Vector3.new(-10964.0, -105.1, 2919.0), Vector3.new(-11003.2, -102.9, 2936.6),
    Vector3.new(-11071.0, -98.7, 2967.1), Vector3.new(-11110.2, -96.0, 2984.7), Vector3.new(-11149.4, -93.1, 3002.1),
    Vector3.new(-11189.9, -90.0, 3019.9), Vector3.new(-11227.8, -87.0, 3036.6), Vector3.new(-11301.1, -80.6, 3068.6),
    Vector3.new(-11370.6, -74.0, 3098.3), Vector3.new(-11441.4, -67.3, 3128.5), Vector3.new(-11511.0, -60.7, 3158.2),
    Vector3.new(-11547.7, -57.2, 3173.9), Vector3.new(-11587.1, -53.6, 3190.8), Vector3.new(-11663.2, -47.2, 3223.3),
    Vector3.new(-11736.9, -41.5, 3254.8), Vector3.new(-11777.7, -38.7, 3272.2), Vector3.new(-11843.4, -34.4, 3300.3),
    Vector3.new(-11907.9, -30.7, 3327.8), Vector3.new(-11947.5, -28.6, 3344.7), Vector3.new(-11989.7, -26.6, 3362.6),
    Vector3.new(-12026.7, -25.0, 3378.1), Vector3.new(-12067.9, -23.4, 3395.0), Vector3.new(-12136.8, -20.8, 3423.6),
    Vector3.new(-12211.0, -18.0, 3454.4), Vector3.new(-12279.8, -15.4, 3483.0), Vector3.new(-12316.8, -14.0, 3498.4),
    Vector3.new(-12357.5, -12.6, 3516.1), Vector3.new(-12395.4, -11.5, 3533.3), Vector3.new(-12433.1, -10.6, 3550.9),
    Vector3.new(-12497.9, -9.3, 3581.8), Vector3.new(-12563.5, -8.0, 3614.6), Vector3.new(-12630.3, -6.6, 3651.2),
    Vector3.new(-12666.4, -5.9, 3672.2), Vector3.new(-12732.8, -4.5, 3712.5), Vector3.new(-12796.6, -3.6, 3754.0),
    Vector3.new(-12858.5, -3.2, 3797.9), Vector3.new(-12915.7, -3.2, 3843.3), Vector3.new(-12971.3, -3.2, 3892.6),
    Vector3.new(-13001.6, -3.3, 3920.8), Vector3.new(-13056.5, -3.3, 3971.2), Vector3.new(-13112.5, -3.3, 4024.7),
    Vector3.new(-13165.4, -3.3, 4079.4), Vector3.new(-13214.7, -3.3, 4135.3), Vector3.new(-13262.9, -3.3, 4192.5),
    Vector3.new(-13311.9, -3.3, 4250.9), Vector3.new(-13360.9, -3.3, 4309.2), Vector3.new(-13405.3, -3.3, 4365.6),
    Vector3.new(-13447.9, -3.3, 4425.0), Vector3.new(-13489.0, -3.3, 4485.5), Vector3.new(-13530.9, -3.3, 4549.1),
    Vector3.new(-13570.8, -3.5, 4610.5), Vector3.new(-13593.3, -3.7, 4645.6), Vector3.new(-13632.0, -4.5, 4706.3),
    Vector3.new(-13653.7, -5.1, 4740.2), Vector3.new(-13675.5, -5.8, 4774.2), Vector3.new(-13697.5, -6.5, 4808.0),
    Vector3.new(-13720.1, -7.2, 4841.4), Vector3.new(-13762.1, -8.5, 4901.6), Vector3.new(-13785.3, -9.2, 4934.7),
    Vector3.new(-13827.8, -10.5, 4994.6), Vector3.new(-13869.8, -11.7, 5053.1), Vector3.new(-13910.6, -12.9, 5110.6),
    Vector3.new(-13955.2, -14.3, 5174.3), Vector3.new(-13980.0, -14.9, 5209.7), Vector3.new(-14003.9, -15.4, 5243.9),
    Vector3.new(-14026.9, -15.8, 5277.0), Vector3.new(-14070.1, -16.1, 5339.8), Vector3.new(-14112.6, -16.1, 5401.4),
    Vector3.new(-14153.2, -15.6, 5460.6), Vector3.new(-14176.7, -15.2, 5495.0), Vector3.new(-14218.1, -14.2, 5555.4),
    Vector3.new(-14258.5, -12.8, 5614.7), Vector3.new(-14281.7, -11.8, 5649.3), Vector3.new(-14322.3, -9.8, 5710.1),
    Vector3.new(-14364.6, -7.3, 5773.2), Vector3.new(-14406.8, -4.7, 5836.3), Vector3.new(-14429.1, -3.3, 5869.6),
    Vector3.new(-14472.9, -0.9, 5935.1), Vector3.new(-14495.2, 0.2, 5968.5), Vector3.new(-14538.3, 1.9, 6032.9),
    Vector3.new(-14585.5, 3.2, 6103.4), Vector3.new(-16565.8, 16.6, 12373.3)
}

local tracker = Instance.new("Part")
tracker.Size = Vector3.new(4, 50, 4)
tracker.Anchored = true; tracker.CanCollide = false
tracker.Material = Enum.Material.Neon; tracker.Color = Color3.fromRGB(255, 0, 0)
tracker.Transparency = 0.3; tracker.Parent = workspace
tracker.CFrame = CFrame.new(0, -1000, 0)

local function getCar()
    local cam = workspace.CurrentCamera
    if cam and cam.CameraSubject and cam.CameraSubject:IsA("BasePart") then
        local carModel = cam.CameraSubject:FindFirstAncestorOfClass("Model")
        if carModel and carModel ~= player.Character then return carModel end
    end
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then return hum.SeatPart:FindFirstAncestorOfClass("Model") end
    end
    return nil
end

local function getCarRoot(car)
    return car.PrimaryPart or car:FindFirstChild("DriveSeat") or car:FindFirstChild("VehicleSeat") or car:FindFirstChildWhichIsA("BasePart")
end

local function getNextWaypointStrict(currentPos, activePath)
    if #activePath == 0 then return 1 end
    local maxCheck = math.min(_G.V29_Waypoint + 15, #activePath)
    local closestDist = math.huge
    local bestIndex = _G.V29_Waypoint
    
    for i = _G.V29_Waypoint, maxCheck do
        local dist = (activePath[i] - currentPos).Magnitude
        if dist < closestDist then 
            closestDist = dist
            bestIndex = i 
        end
    end
    return bestIndex
end

RunService.Stepped:Connect(function()
    if _G.V29_TrafficNoclip or _G.V29_Mode ~= "None" then
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

local bodyVelocity = nil
local bodyGyro = nil

local function cleanupMovers()
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    tracker.CFrame = CFrame.new(0, -1000, 0)
end

task.spawn(function()
    while true do
        if _G.V29_Mode == "Farm" and not _G.V29_Setup then
            local activePath = HIGHWAY_PATH
            local car = getCar()
            local root = car and getCarRoot(car)

            if car and root then
                for _, part in pairs(car:GetDescendants()) do
                    if part:IsA("BasePart") and part.Anchored then
                        part.Anchored = false
                    end
                end
                
                if not bodyVelocity or bodyVelocity.Parent ~= root then
                    if bodyVelocity then bodyVelocity:Destroy() end
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge) 
                    bodyVelocity.Parent = root
                end
                
                if not bodyGyro or bodyGyro.Parent ~= root then
                    if bodyGyro then bodyGyro:Destroy() end
                    bodyGyro = Instance.new("BodyGyro")
                    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
                    bodyGyro.D = 500
                    bodyGyro.P = 50000 
                    bodyGyro.Parent = root
                end

                _G.V29_Waypoint = getNextWaypointStrict(root.Position, activePath)
                
                if _G.V29_Waypoint >= #activePath - 2 then
                    bodyVelocity.Velocity = Vector3.zero
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    
                    _G.V29_Waypoint = 1
                    car:PivotTo(CFrame.new(activePath[1] + Vector3.new(0, 5, 0)))
                    task.wait(1)
                    continue
                end
                
                local targetIndex = _G.V29_Waypoint + 1
                if targetIndex > #activePath then targetIndex = #activePath end
                local targetPos = activePath[targetIndex]
                tracker.CFrame = CFrame.new(targetPos)
                
                local direction = (targetPos - root.Position).Unit
                bodyVelocity.Velocity = direction * _G.V29_Speed
                bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + direction)
            end
        else
            cleanupMovers()
        end
        task.wait(0.03) 
    end
end)

local function stopAllRoutines()
    isAntiAfkEnabled = false
    isWalkSpeedEnabled = false
    isJumpPowerEnabled = false
    isInfiniteJumpEnabled = false
    _G.V29_Mode = "None"
    _G.V29_TrafficNoclip = false

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
            TabFarm = "🚗 自動掛機",
            TabGhost = "👻 交通穿透",
            Tab1 = "⚙️ 其他設定",
            SwitchOff = "關閉",
            SwitchOn = "開啟",
            AuthorContent = "【 作者資訊 】\n• 作者 / 開發者：KrisVan\n• 功能：專為 Roblox 打造的強大輔助介面。\n• 感謝您的使用與支持！",
            LogHeader = "[📋 更新日誌 📋]",
            LogClickHint = " (點擊展開/收合)",
            Logs = {
                {version = "v1.1.1", details = "• 重新排版側邊欄選單分頁順序\n• 將「其他設定」分頁移動至「交通穿透」下方\n• 優化整體介面視覺體驗"},
                {version = "v1.1.0", details = "• 新增獨立分頁：Auto-Farm 與 Traffic Ghost 開關\n• 優化介面配置與導航功能"},
                {version = "v1.0.0", details = "• 初始版本發布\n• 包含基礎移動速度、跳躍高度、無限跳與防掛機功能"}
            },
            SpeedTip = "移動速度 (16~200)",
            JumpTip = "跳躍高度 (50~100)",
            InfJump = "跳躍無冷卻 (無限跳)",
            AntiAfk = "防掛機保護",
            FarmDesc = "【 Auto-Farm 自動駕駛 】\n點擊下方按鈕可快速切換高速公路自動農金開關。",
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
            Title = "⚔️ KrisVan 游戏辅助 v1.1.1",
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
                {version = "v1.1.1", details = "• 重新排版侧边栏菜单分页顺序\n• 将“其他设定”分页移动至“交通穿透”下方\n• 优化整体界面视觉体验"},
                {version = "v1.1.0", details = "• 新增独立分页：Auto-Farm 与 Traffic Ghost 开关\n• 优化界面配置与导航功能"},
                {version = "v1.0.0", details = "• 初始版本发布\n• 包含基础移动速度、跳跃高度、无限跳与防挂机功能"}
            },
            SpeedTip = "移动速度 (16~200)",
            JumpTip = "跳跃高度 (50~100)",
            InfJump = "跳跃无冷却 (无限跳)",
            AntiAfk = "防挂机保护",
            FarmDesc = "【 Auto-Farm 自动驾驶 】\n点击下方按钮可快速切换高速公路自动农金开关。",
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
            Title = "⚔️ KrisVan Script v1.1.1",
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
                {version = "v1.1.1", details = "• Reordered sidebar menu tab layout\n• Moved Settings tab below Traffic Ghost tab\n• Improved overall UI design"},
                {version = "v1.1.0", details = "• Added dedicated tabs for Auto-Farm and Traffic Ghost\n• Improved UI layout"},
                {version = "v1.0.0", details = "• Initial release\n• Includes walkspeed, jumppower, infinite jump & anti-afk features"}
            },
            SpeedTip = "Walk Speed (16~200)",
            JumpTip = "Jump Power (50~100)",
            InfJump = "Infinite Jump",
            AntiAfk = "Anti-AFK Protection",
            FarmDesc = "[ Auto-Farm Feature ]\nToggle highway auto-farm driving mode.",
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
    farmDescLabel.Size = UDim2.new(1, -24, 0, 60)
    farmDescLabel.Position = UDim2.new(0, 12, 0, 12)
    farmDescLabel.BackgroundTransparency = 1
    farmDescLabel.Text = L.FarmDesc
    farmDescLabel.Font = Enum.Font.Gotham
    farmDescLabel.TextSize = 12
    farmDescLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    farmDescLabel.TextXAlignment = Enum.TextXAlignment.Left
    farmDescLabel.TextYAlignment = Enum.TextYAlignment.Top
    farmDescLabel.TextWrapped = true

    local farmToggleBtn = Instance.new("TextButton", panelFarm)
    farmToggleBtn.Size = UDim2.new(1, -24, 0, 45)
    farmToggleBtn.Position = UDim2.new(0, 12, 0, 80)
    farmToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    farmToggleBtn.BackgroundTransparency = 0.25
    farmToggleBtn.Text = "AUTO-FARM: " .. L.SwitchOff
    farmToggleBtn.Font = Enum.Font.GothamBold
    farmToggleBtn.TextSize = 13
    farmToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", farmToggleBtn).CornerRadius = UDim.new(0, 10)

    farmToggleBtn.Activated:Connect(function()
        if _G.V29_Mode == "Farm" then
            _G.V29_Mode = "None"
        else
            _G.V29_Mode = "Farm"
            _G.V29_Waypoint = 1
            _G.V29_TrafficNoclip = true
        end
        local isOn = (_G.V29_Mode == "Farm")
        farmToggleBtn.Text = "AUTO-FARM: " .. (isOn and L.SwitchOn or L.SwitchOff)
        farmToggleBtn.BackgroundColor3 = isOn and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 0, 0)
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

