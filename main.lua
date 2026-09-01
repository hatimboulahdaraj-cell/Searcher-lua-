local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

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

local oldGui = parentGui:FindFirstChild("DeltaServerSearcher")
if oldGui then oldGui:Destroy() end

local filterMode = "ALL" 

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaServerSearcher"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 120, 215)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
title.Text = "Server Searcher (Delta)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
statusLabel.Text = "Status: Pret"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local filterBtn = Instance.new("TextButton")
filterBtn.Size = UDim2.new(1, -20, 0, 30)
filterBtn.Position = UDim2.new(0, 10, 0, 70)
filterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
filterBtn.Text = "Filtre : Tous les serveurs"
filterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
filterBtn.TextSize = 12
filterBtn.Font = Enum.Font.GothamBold
filterBtn.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -150)
scrollingFrame.Position = UDim2.new(0, 10, 0, 105)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollingFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

local searchBtn = Instance.new("TextButton")
searchBtn.Size = UDim2.new(1, -20, 0, 35)
searchBtn.Position = UDim2.new(0, 10, 1, -40)
searchBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
searchBtn.Text = "Lancer la recherche"
searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBtn.TextSize = 14
searchBtn.Font = Enum.Font.GothamBold
searchBtn.Parent = mainFrame

filterBtn.MouseButton1Click:Connect(function()
	if filterMode == "ALL" then
		filterMode = "LOW"
		filterBtn.Text = "Filtre : Peu peuples (-40%)"
		filterBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
	elseif filterMode == "LOW" then
		filterMode = "HIGH"
		filterBtn.Text = "Filtre : Presque pleins (+70%)"
		filterBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 0)
	else
		filterMode = "ALL"
		filterBtn.Text = "Filtre : Tous les serveurs"
		filterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

local function fetchServers()
	for _, v in ipairs(scrollingFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
	
	statusLabel.Text = "Status: Recherche..."
	statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	
	local placeId = game.PlaceId
	local sortOrder = "Asc"
	if filterMode == "HIGH" then sortOrder = "Desc" end
	
	local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"
	
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	
	if not success then
		statusLabel.Text = "Status: Erreur HTTP"
		statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		return
	end
	
	local data = HttpService:JSONDecode(result)
	if data and data.data then
		local count = 0
		for _, server in ipairs(data.data) do
			if server.id ~= game.JobId and server.playing < server.maxPlayers then
				local addServer = false
				
				if filterMode == "ALL" then
					addServer = true
				elseif filterMode == "LOW" and server.playing <= math.ceil(server.maxPlayers * 0.4) then
					addServer = true
				elseif filterMode == "HIGH" and server.playing >= math.floor(server.maxPlayers * 0.7) then
					addServer = true
				end
				
				if addServer then
					count = count + 1
					
					local btn = Instance.new("TextButton")
					btn.Size = UDim2.new(1, -10, 0, 35)
					btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					btn.Text = "Joueurs: " .. server.playing .. "/" .. server.maxPlayers
					btn.TextColor3 = Color3.fromRGB(255, 255, 255)
					btn.Font = Enum.Font.Gotham
					btn.TextSize = 12
					btn.Parent = scrollingFrame
					
					btn.MouseButton1Click:Connect(function()
						statusLabel.Text = "Status: Teleportation..."
						TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
					end)
				end
			end
		end
		statusLabel.Text = "Status: " .. count .. " serveur(s) trouve(s)"
		statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		statusLabel.Text = "Status: Aucun serveur"
		statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end

searchBtn.MouseButton1Click:Connect(fetchServers)
