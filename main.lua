local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Nettoyage de l'ancienne interface
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local oldGui = parentGui:FindFirstChild("FMLYAdminExact")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FMLYAdminExact"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- Structure FMLY Admin
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 410)
mainFrame.Position = UDim2.new(0.03, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FMLY ADMIN"
title.TextColor3 = Color3.fromRGB(255, 120, 50)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Scroll List
local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(1, -16, 0, 350)
scrollList.Position = UDim2.new(0, 8, 0, 45)
scrollList.BackgroundTransparency = 1
scrollList.BorderSizePixel = 0
scrollList.ScrollBarThickness = 3
scrollList.ScrollBarImageColor3 = Color3.fromRGB(255, 120, 50)
scrollList.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollList
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

-- Fonction de Téléportation Sécurisée (avec objet en main)
local function safeTeleport(targetPlayer)
    local myChar = player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if myHrp and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHrp = targetPlayer.Character.HumanoidRootPart
        
        -- Désactive les collisions du personnage et des objets portés
        for _, obj in ipairs(myChar:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
        
        -- TP 6 studs au-dessus du joueur
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 6, 2)
        
        -- Réactive la collision après 1 seconde pour éviter le glitch sous la map
        task.delay(1, function()
            if myChar then
                for _, obj in ipairs(myChar:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.CanCollide = true
                    end
                end
            end
        end)
    end
end

-- Refresh de la liste des joueurs
local function refreshPlayerList()
    for _, child in ipairs(scrollList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -4, 0, 48)
            card.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
            card.BorderSizePixel = 0
            card.Parent = scrollList

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = card

            -- Avatar
            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Size = UDim2.new(0, 34, 0, 34)
            avatarImg.Position = UDim2.new(0, 6, 0.5, -17)
            avatarImg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            avatarImg.Image = Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            avatarImg.Parent = card

            local imgCorner = Instance.new("UICorner")
            imgCorner.CornerRadius = UDim.new(1, 0)
            imgCorner.Parent = avatarImg

            -- Pseudo
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.35, 0, 0.45, 0)
            nameLabel.Position = UDim2.new(0, 45, 0.1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = targetPlayer.DisplayName
            nameLabel.TextColor3 = Color3.fromRGB(255, 160, 40)
            nameLabel.TextSize = 10
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = card

            -- BOUTON TP MAIN (Spécial Objet en Main)
            local tpItemBtn = Instance.new("TextButton")
            tpItemBtn.Size = UDim2.new(0, 65, 0, 28)
            tpItemBtn.Position = UDim2.new(0.48, 0, 0.2, 0)
            tpItemBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 180)
            tpItemBtn.Text = "TP (Hand)"
            tpItemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpItemBtn.TextSize = 9
            tpItemBtn.Font = Enum.Font.GothamBold
            tpItemBtn.Parent = card

            local bCorner1 = Instance.new("UICorner")
            bCorner1.CornerRadius = UDim.new(0, 6)
            bCorner1.Parent = tpItemBtn

            tpItemBtn.MouseButton1Click:Connect(function()
                safeTeleport(targetPlayer)
            end)

            -- BOUTON ALL (Rose FMLY)
            local allBtn = Instance.new("TextButton")
            allBtn.Size = UDim2.new(0, 40, 0, 28)
            allBtn.Position = UDim2.new(0.82, 0, 0.2, 0)
            allBtn.BackgroundColor3 = Color3.fromRGB(210, 60, 120)
            allBtn.Text = "ALL"
            allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            allBtn.TextSize = 10
            allBtn.Font = Enum.Font.GothamBold
            allBtn.Parent = card

            local bCorner2 = Instance.new("UICorner")
            bCorner2.CornerRadius = UDim.new(0, 6)
            bCorner2.Parent = allBtn

            allBtn.MouseButton1Click:Connect(function()
                safeTeleport(targetPlayer)
            end)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()
