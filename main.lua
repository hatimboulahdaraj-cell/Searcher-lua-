local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Nettoyage ancienne UI
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local oldGui = parentGui:FindFirstChild("AutoBrainrotHunter")
if oldGui then oldGui:Destroy() end

-- Interface Graphique
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoBrainrotHunter"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 330, 0, 320)
mainFrame.Position = UDim2.new(0.5, -165, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 140, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
title.Text = "Steal a Brainrot - Ultra Hunter"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 35)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusLabel.Text = "Status : Pret."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

local bestLabel = Instance.new("TextLabel")
bestLabel.Size = UDim2.new(1, -20, 0, 60)
bestLabel.Position = UDim2.new(0, 10, 0, 95)
bestLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bestLabel.Text = "Meilleur Brainrot : Aucun"
bestLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
bestLabel.TextSize = 11
bestLabel.Font = Enum.Font.Gotham
bestLabel.TextWrapped = true
bestLabel.Parent = mainFrame

local minValInput = Instance.new("TextBox")
minValInput.Size = UDim2.new(1, -20, 0, 35)
minValInput.Position = UDim2.new(0, 10, 0, 165)
minValInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minValInput.Text = "1000000"
minValInput.PlaceholderText = "Valeur minimum recherchee"
minValInput.TextColor3 = Color3.fromRGB(255, 255, 255)
minValInput.TextSize = 12
minValInput.Font = Enum.Font.Gotham
minValInput.Parent = mainFrame

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.48, 0, 0, 40)
autoBtn.Position = UDim2.new(0, 10, 0, 210)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
autoBtn.Text = "Lancer Auto-Hop"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 12
autoBtn.Font = Enum.Font.GothamBold
autoBtn.Parent = mainFrame

local manualScanBtn = Instance.new("TextButton")
manualScanBtn.Size = UDim2.new(0.48, 0, 0, 40)
manualScanBtn.Position = UDim2.new(0.52, 0, 0, 210)
manualScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
manualScanBtn.Text = "Scanner Map"
manualScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
manualScanBtn.TextSize = 12
manualScanBtn.Font = Enum.Font.GothamBold
manualScanBtn.Parent = mainFrame

local isHunting = false

-- Convertisseur de texte (ex: "$1.5M/s" -> 1500000)
local function parseValue(val)
    if type(val) == "number" then return val end
    if type(val) == "string" then
        local cleanStr = val:gsub(",", ""):gsub("%$", "")
        local num = tonumber(cleanStr:match("[%d%.]+"))
        if not num then return 0 end
        if cleanStr:lower():find("k") then return num * 1000 end
        if cleanStr:lower():find("m") then return num * 1000000 end
        if cleanStr:lower():find("b") then return num * 1000000000 end
        return num
    end
    return 0
end

local function hopToNextServer()
    statusLabel.Text = "Status : Teleportation..."
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
                TeleportService:TeleportToPlaceInstance(placeId, validServers[math.random(1, #validServers)], player)
            end
        end
    end
end

-- Scan approfondi (Valeurs + Textes d'affichage + Leaderstats)
local function scanCurrentServer()
    statusLabel.Text = "Status : Scan en cours..."
    local targetVal = tonumber(minValInput.Text) or 1000000
    local maxFound = 0
    local bestName = "Aucun"

    -- 1. Scan des TextLabels (3D UI au-dessus des Brainrots)
    for _, gui in ipairs(Workspace:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
            local text = (gui:IsA("TextLabel") and gui.Text) or ""
            if text ~= "" and (text:find("%$") or text:lower():find("/s") or text:lower():find("m") or text:lower():find("k")) then
                local num = parseValue(text)
                if num > maxFound then
                    maxFound = num
                    bestName = gui.Parent.Name
                end
            end
        end
    end

    -- 2. Scan des objets/ValueBase classiques
    for _, item in ipairs(Workspace:GetDescendants()) do
        local valObj = item:FindFirstChild("Price") or item:FindFirstChild("Value") or item:FindFirstChild("Generation") or item:FindFirstChild("Income") or item:FindFirstChild("Cost")
        local rawVal = valObj and valObj:IsA("ValueBase") and valObj.Value or item:GetAttribute("Price") or item:GetAttribute("Value")
        if rawVal then
            local numVal = parseValue(rawVal)
            if numVal > maxFound then
                maxFound = numVal
                bestName = item.Name
            end
        end
    end

    if maxFound > 0 then
        bestLabel.Text = "Objet/Base : " .. bestName .. "\nValeur estimee : $" .. tostring(maxFound)
    else
        bestLabel.Text = "Aucune valeur detectee. Verifie F9 !"
        print("--- DEBUG DEBUT ---")
        for _, child in ipairs(Workspace:GetChildren()) do
            print("Objet Workspace : " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        print("--- DEBUG FIN ---")
    end

    if maxFound >= targetVal and maxFound > 0 then
        statusLabel.Text = "Status : SERVEUR VALIDE !"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        isHunting = false
        autoBtn.Text = "Lancer Auto-Hop"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    else
        if isHunting then
            statusLabel.Text = "Status : Valeur trop basse ($" .. maxFound .. "). Hop..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(1.5)
            hopToNextServer()
        else
            statusLabel.Text = "Status : Scan termine."
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

autoBtn.MouseButton1Click:Connect(function()
    isHunting = not isHunting
    if isHunting then
        autoBtn.Text = "STOP Auto-Hop"
        autoBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        scanCurrentServer()
    else
        autoBtn.Text = "Lancer Auto-Hop"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        statusLabel.Text = "Status : Arrete."
    end
end)

manualScanBtn.MouseButton1Click:Connect(scanCurrentServer)

task.wait(2)
scanCurrentServer()
