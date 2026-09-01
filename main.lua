local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Parent GUI
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local oldGui = parentGui:FindFirstChild("XenhubReplica")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XenhubReplica"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- Fenêtre Principale (XENHUB PRIVATE)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 320)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(130, 50, 250)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
title.Text = "XENHUB REPLICA - Steal a Brainrot"
title.TextColor3 = Color3.fromRGB(180, 100, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Conteneur des fonctionnalités
local function createButton(text, pos, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(120, 40, 220)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
        end
        callback(enabled, btn)
    end)
    return btn
end

-- Panneau Mouvement
local movePanel = Instance.new("Frame")
movePanel.Size = UDim2.new(0.46, 0, 0.8, 0)
movePanel.Position = UDim2.new(0.03, 0, 0.15, 0)
movePanel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
movePanel.Parent = mainFrame

local moveTitle = Instance.new("TextLabel")
moveTitle.Size = UDim2.new(1, 0, 0, 25)
moveTitle.Text = "MOVEMENT"
moveTitle.TextColor3 = Color3.fromRGB(150, 150, 255)
moveTitle.BackgroundTransparency = 1
moveTitle.Font = Enum.Font.GothamBold
moveTitle.Parent = movePanel

-- Speed Toggle
local speedActive = false
createButton("WalkSpeed (25)", UDim2.new(0.05, 0, 0.15, 0), movePanel, function(state)
    speedActive = state
    humanoid.WalkSpeed = state and 25 or 16
end)

-- Float / Fly basique
local floatActive = false
createButton("Float (Hover)", UDim2.new(0.05, 0, 0.3, 0), movePanel, function(state)
    floatActive = state
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("FloatBV") or Instance.new("BodyVelocity")
        bv.Name = "FloatBV"
        if state then
            bv.MaxForce = Vector3.new(0, 9e9, 0)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
        else
            bv:Destroy()
        end
    end
end)

-- Panneau Steal & Server
local stealPanel = Instance.new("Frame")
stealPanel.Size = UDim2.new(0.46, 0, 0.8, 0)
stealPanel.Position = UDim2.new(0.51, 0, 0.15, 0)
stealPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
stealPanel.Parent = stealPanel or mainFrame

local stealTitle = Instance.new("TextLabel")
stealTitle.Size = UDim2.new(1, 0, 0, 25)
stealTitle.Text = "STEAL & SERVER"
stealTitle.TextColor3 = Color3.fromRGB(150, 150, 255)
stealTitle.BackgroundTransparency = 1
stealTitle.Font = Enum.Font.GothamBold
stealTitle.Parent = stealPanel

-- Server Hop Button
local hopBtn = Instance.new("TextButton")
hopBtn.Size = UDim2.new(0.9, 0, 0, 30)
hopBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
hopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
hopBtn.Text = "Server Hop"
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.Font = Enum.Font.GothamBold
hopBtn.Parent = stealPanel

hopBtn.MouseButton1Click:Connect(function()
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success then
        local data = HttpService:JSONDecode(result)
        if data and data.data then
            local valid = {}
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(valid, s.id)
                end
            end
            if #valid > 0 then
                TeleportService:TeleportToPlaceInstance(placeId, valid[math.random(1, #valid)], player)
            end
        end
    end
end)
