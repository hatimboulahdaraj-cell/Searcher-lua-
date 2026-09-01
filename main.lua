local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Protection GUI pour Delta
local parentGui
if gethui then
    parentGui = gethui()
elseif syn and syn.protect_gui then
    local sg = Instance.new("ScreenGui")
    syn.protect_gui(sg)
    sg.Parent = game:GetService("CoreGui")
    parentGui = sg
else
    parentGui = game:GetService("CoreGui")
end

local oldGui = parentGui:FindFirstChild("AutoBrainrotHunter")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoBrainrotHunter"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 300)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 170, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
title.Text = "Auto Brainrot Hunter"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 40)
statusLabel.Position = UDim2.new(0, 10, 0, 45)
statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statusLabel.Text = "Status : En attente..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

local bestLabel = Instance.new("TextLabel")
bestLabel.Size = UDim2.new(1, -20, 0, 50)
bestLabel.Position = UDim2.new(0, 10, 0, 95)
bestLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
bestLabel.Text = "Meilleur Brainrot trouve : Aucun"
bestLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
bestLabel.TextSize = 12
bestLabel.Font = Enum.Font.Gotham
bestLabel.TextWrapped = true
bestLabel.Parent = mainFrame

local minValInput = Instance.new("TextBox")
minValInput.Size = UDim2.new(1, -20, 0, 35)
minValInput.Position = UDim2.new(0, 10, 0, 155)
minValInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
minValInput.Text = "1000000" -- Valeur minimum par defaut
minValInput.PlaceholderText = "Valeur minimum recherchee"
minValInput.TextColor3 = Color3.fromRGB(255, 255, 255)
minValInput.TextSize = 13
minValInput.Font = Enum.Font.Gotham
minValInput.Parent = mainFrame

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -20, 0, 40)
autoBtn.Position = UDim2.new(0, 10, 0, 200)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
autoBtn.Text = "Lancer l'Auto-Hop"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 14
autoBtn.Font = Enum.Font.GothamBold
autoBtn.Parent = mainFrame

local isHunting = false

-- Fonction pour se téléporter sur un serveur au hasard
local function hopToNextServer()
    statusLabel.Text = "Status : Recherche d'un autre serveur..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
    
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success then
        local data = HttpService:JSONDecode(result)
        if data and data.data then
            local validServers = {}
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(validServers, s.id)
                end
            end
            
            if #validServers > 0 then
                local randomServer = validServers[math.random(1, #validServers)]
                TeleportService:TeleportToPlaceInstance(placeId, randomServer, player)
            end
        end
    end
end

-- Fonction d'analyse locale
local function scanCurrentServer()
    local targetVal = tonumber(minValInput.Text) or 1000000
    local maxFound = 0
    local bestName = "Aucun"
    
    for _, item in ipairs(Workspace:GetDescendants()) do
        local valObj = item:FindFirstChild("Price") or item:FindFirstChild("Value") or item:FindFirstChild("Generation") or item:FindFirstChild("Income")
        if valObj and (valObj:IsA("NumberValue") or valObj:IsA("IntValue")) then
            if valObj.Value > maxFound then
                maxFound = valObj.Value
                bestName = item.Name
            end
        end
    end
    
    bestLabel.Text = "Meilleur : " .. bestName .. " ($" .. tostring(maxFound) .. ")"
    
    if maxFound >= targetVal then
        statusLabel.Text = "Status : BRAINROT CIBLE TROUVE !"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        isHunting = false
        autoBtn.Text = "Relancer l'Auto-Hop"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    else
        statusLabel.Text = "Status : Trop faible ($" .. maxFound .. "). Hop en cours..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.5)
        hopToNextServer()
    end
end

autoBtn.MouseButton1Click:Connect(function()
    isHunting = not isHunting
    if isHunting then
        autoBtn.Text = "STOP Auto-Hop"
        autoBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        scanCurrentServer()
    else
        autoBtn.Text = "Lancer l'Auto-Hop"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        statusLabel.Text = "Status : Arrete."
    end
end)

-- Scan automatique à l'arrivée si la recherche était active
task.wait(2)
scanCurrentServer()
