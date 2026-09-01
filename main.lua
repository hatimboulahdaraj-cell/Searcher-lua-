local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Bypassing UI restrictions for Delta
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

local oldGui = parentGui:FindFirstChild("BrainrotSearcherGUI")
if oldGui then oldGui:Destroy() end

-- ScreenGui Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotSearcherGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- Fenêtre Principale
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 450)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Titre
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
title.Text = "Steal a Brainrot - Server Searcher"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- En-tête : Scanner le serveur actuel
local scanHeader = Instance.new("TextLabel")
scanHeader.Size = UDim2.new(1, -20, 0, 20)
scanHeader.Position = UDim2.new(0, 10, 0, 42)
scanHeader.BackgroundTransparency = 1
scanHeader.Text = "MEILLEUR BRAINROT DU SERVEUR ACTUEL :"
scanHeader.TextColor3 = Color3.fromRGB(255, 215, 0)
scanHeader.TextSize = 11
scanHeader.Font = Enum.Font.GothamBold
scanHeader.Parent = mainFrame

-- Box d'info du serveur actuel
local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(1, -20, 0, 50)
infoBox.Position = UDim2.new(0, 10, 0, 65)
infoBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
infoBox.Text = "Analyse de la map en cours..."
infoBox.TextColor3 = Color3.fromRGB(200, 200, 200)
infoBox.TextSize = 12
infoBox.Font = Enum.Font.Gotham
infoBox.TextWrapped = true
infoBox.Parent = mainFrame

-- Bouton d'Analyse locale
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -20, 0, 25)
scanBtn.Position = UDim2.new(0, 10, 0, 120)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 180)
scanBtn.Text = "Scanner la map"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 12
scanBtn.Font = Enum.Font.GothamBold
scanBtn.Parent = mainFrame

-- Liste des serveurs
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 0, 210)
scrollingFrame.Position = UDim2.new(0, 10, 0, 155)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollingFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Bouton Chercher d'autres serveurs
local searchBtn = Instance.new("TextButton")
searchBtn.Size = UDim2.new(1, -20, 0, 35)
searchBtn.Position = UDim2.new(0, 10, 1, -45)
searchBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
searchBtn.Text = "Trouver des serveurs remplis"
searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBtn.TextSize = 13
searchBtn.Font = Enum.Font.GothamBold
searchBtn.Parent = mainFrame

-- 1. FONCTION : Scanner les Brainrots sur le serveur actuel
local function scanMapForBestBrainrot()
    infoBox.Text = "Recherche dans les bases..."
    local maxValue = 0
    local bestName = "Aucun"
    local ownerName = "Personne"

    -- Cherche dans Workspace (les bases/plots)
    for _, item in ipairs(Workspace:GetDescendants()) do
        local valObj = item:FindFirstChild("Price") or item:FindFirstChild("Value") or item:FindFirstChild("Generation") or item:FindFirstChild("Income")
        if valObj and (valObj:IsA("NumberValue") or valObj:IsA("IntValue")) then
            if valObj.Value > maxValue then
                maxValue = valObj.Value
                bestName = item.Name
                
                local parentPlot = item:FindFirstAncestorOfClass("Model")
                if parentPlot and parentPlot:FindFirstChild("Owner") then
                    ownerName = tostring(parentPlot.Owner.Value)
                end
            end
        end
    end

    if maxValue > 0 then
        infoBox.Text = "Nom : " .. bestName .. "\nValeur : $" .. tostring(maxValue) .. "\nJoueur : " .. ownerName
        infoBox.TextColor3 = Color3.fromRGB(0, 255, 127)
    else
        infoBox.Text = "Aucun Brainrot detecte dans les bases."
        infoBox.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- 2. FONCTION : Liste des serveurs publics + bouton Rejoindre
local function fetchServers()
    for _, v in ipairs(scrollingFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    searchBtn.Text = "Chargement..."
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
    
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        searchBtn.Text = "Erreur HTTP (Reessaie)"
        return
    end
    
    local data = HttpService:JSONDecode(result)
    if data and data.data then
        for _, server in ipairs(data.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -10, 0, 40)
                card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                card.Parent = scrollingFrame

                local serverText = Instance.new("TextLabel")
                serverText.Size = UDim2.new(0.65, 0, 1, 0)
                serverText.Position = UDim2.new(0, 10, 0, 0)
                serverText.BackgroundTransparency = 1
                serverText.Text = "Joueurs: " .. server.playing .. "/" .. server.maxPlayers
                serverText.TextColor3 = Color3.fromRGB(255, 255, 255)
                serverText.Font = Enum.Font.Gotham
                serverText.TextXAlignment = Enum.TextXAlignment.Left
                serverText.TextSize = 12
                serverText.Parent = card

                local joinBtn = Instance.new("TextButton")
                joinBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
                joinBtn.Position = UDim2.new(0.68, 0, 0.15, 0)
                joinBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                joinBtn.Text = "Rejoindre"
                joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                joinBtn.Font = Enum.Font.GothamBold
                joinBtn.TextSize = 11
                joinBtn.Parent = card

                joinBtn.MouseButton1Click:Connect(function()
                    joinBtn.Text = "..."
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                end)
            end
        end
        searchBtn.Text = "Rafraichir les serveurs"
    else
        searchBtn.Text = "Aucun serveur trouve"
    end
end

-- Connexions
scanBtn.MouseButton1Click:Connect(scanMapForBestBrainrot)
searchBtn.MouseButton1Click:Connect(fetchServers)

-- Scan automatique dès l'injection
scanMapForBestBrainrot()
