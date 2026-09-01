local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local map = MemoryStoreService:GetSortedMap("BrainrotServers_V1")

local MAX_SERVERS = 100
local MIN_VALUE = 100_000_000

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerSearcherGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(0, 120, 215)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Server Searcher"
titleLabel.Parent = mainFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -10, 0, 30)
statusLabel.Position = UDim2.new(0, 5, 0, 50)
statusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: Idle"
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- ScrollingFrame for server list
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ServerList"
scrollingFrame.Size = UDim2.new(1, -10, 1, -140)
scrollingFrame.Position = UDim2.new(0, 5, 0, 90)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollingFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.Parent = mainFrame

-- UIListLayout for scrolling frame
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollingFrame

-- Search Button
local searchButton = Instance.new("TextButton")
searchButton.Name = "SearchButton"
searchButton.Size = UDim2.new(0.48, -3, 0, 40)
searchButton.Position = UDim2.new(0, 5, 1, -45)
searchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
searchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
searchButton.TextSize = 16
searchButton.Font = Enum.Font.GothamBold
searchButton.Text = "Search Servers"
searchButton.Parent = mainFrame

-- Auto Join Button
local autoJoinButton = Instance.new("TextButton")
autoJoinButton.Name = "AutoJoinButton"
autoJoinButton.Size = UDim2.new(0.48, -3, 0, 40)
autoJoinButton.Position = UDim2.new(0.52, 3, 1, -45)
autoJoinButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
autoJoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJoinButton.TextSize = 16
autoJoinButton.Font = Enum.Font.GothamBold
autoJoinButton.Text = "Auto Join"
autoJoinButton.Parent = mainFrame

local serverData = {}

local function showConfirmationDialog(jobId, value)
	-- Create dialog background
	local dialogBg = Instance.new("Frame")
	dialogBg.Name = "ConfirmationDialog"
	dialogBg.Size = UDim2.new(1, 0, 1, 0)
	dialogBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dialogBg.BackgroundTransparency = 0.5
	dialogBg.Parent = screenGui
	
	-- Create dialog box
	local dialogBox = Instance.new("Frame")
	dialogBox.Name = "DialogBox"
	dialogBox.Size = UDim2.new(0, 300, 0, 150)
	dialogBox.Position = UDim2.new(0.5, -150, 0.5, -75)
	dialogBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	dialogBox.BorderColor3 = Color3.fromRGB(0, 120, 215)
	dialogBox.BorderSizePixel = 2
	dialogBox.Parent = dialogBg
	
	-- Dialog title
	local dialogTitle = Instance.new("TextLabel")
	dialogTitle.Name = "DialogTitle"
	dialogTitle.Size = UDim2.new(1, 0, 0, 40)
	dialogTitle.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	dialogTitle.TextSize = 16
	dialogTitle.Font = Enum.Font.GothamBold
	dialogTitle.Text = "Confirm Join"
	dialogTitle.Parent = dialogBox
	
	-- Dialog message
	local dialogMessage = Instance.new("TextLabel")
	dialogMessage.Name = "DialogMessage"
	dialogMessage.Size = UDim2.new(1, -10, 0, 50)
	dialogMessage.Position = UDim2.new(0, 5, 0, 50)
	dialogMessage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	dialogMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
	dialogMessage.TextSize = 12
	dialogMessage.Font = Enum.Font.Gotham
	dialogMessage.Text = "Join server with " .. value .. " players/sec?"
	dialogMessage.TextWrapped = true
	dialogMessage.Parent = dialogBox
	
	-- Allow button
	local allowButton = Instance.new("TextButton")
	allowButton.Name = "AllowButton"
	allowButton.Size = UDim2.new(0.45, 0, 0, 35)
	allowButton.Position = UDim2.new(0, 5, 1, -40)
	allowButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	allowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	allowButton.TextSize = 14
	allowButton.Font = Enum.Font.GothamBold
	allowButton.Text = "Allow"
	allowButton.Parent = dialogBox
	
	-- Deny button
	local denyButton = Instance.new("TextButton")
	denyButton.Name = "DenyButton"
	denyButton.Size = UDim2.new(0.45, 0, 0, 35)
	denyButton.Position = UDim2.new(0.55, 0, 1, -40)
	denyButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	denyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	denyButton.TextSize = 14
	denyButton.Font = Enum.Font.GothamBold
	denyButton.Text = "Deny"
	denyButton.Parent = dialogBox
	
	function allowButton.MouseButton1Click()
		statusLabel.Text = "Status: Joining server..."
		statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		
		local teleportSuccess, teleportError = pcall(function()
			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				jobId,
				player
			)
		end)
		
		if teleportSuccess then
			statusLabel.Text = "Status: Teleporting..."
			statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			statusLabel.Text = "Status: Teleport failed!"
			statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			warn("Téléportation échouée:", teleportError)
		end
		
		dialogBg:Destroy()
	end
	
	function denyButton.MouseButton1Click()
		statusLabel.Text = "Status: Join cancelled"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
		dialogBg:Destroy()
	end
end

local function createServerButton(jobId, value)
	local button = Instance.new("TextButton")
	button.Name = "ServerButton_" .. jobId
	button.Size = UDim2.new(1, -10, 0, 50)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BorderColor3 = Color3.fromRGB(80, 80, 80)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	button.Font = Enum.Font.Gotham
	button.Text = "Players/sec: " .. value .. "\nJobId: " .. jobId:sub(1, 12) .. "..."
	button.Parent = scrollingFrame
	
	function button.MouseButton1Click()
		-- Show confirmation dialog
		showConfirmationDialog(jobId, value)
	end
	
	return button
end

local function refreshServerList()
	-- Clear existing buttons
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	serverData = {}
	
	statusLabel.Text = "Status: Searching for servers..."
	statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	
	local success, pages = pcall(function()
		return map:GetRangeAsync(
			Enum.SortDirection.Descending,
			MAX_SERVERS
		)
	end)
	
	if not success then
		statusLabel.Text = "Status: Search failed!"
		statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		warn("Impossible de chercher les serveurs")
		return
	end
	
	local serverCount = 0
	for _, entry in ipairs(pages) do
		local data = entry.value
		if data and data.JobId and data.JobId ~= game.JobId and data.Value >= MIN_VALUE then
			serverCount = serverCount + 1
			table.insert(serverData, {JobId = data.JobId, Value = data.Value})
			createServerButton(data.JobId, data.Value)
			print("Serveur trouvé:", data.Value, "/sec", data.JobId)
		end
	end
	
	if serverCount == 0 then
		statusLabel.Text = "Status: No servers found with 100M+/sec"
		statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	else
		statusLabel.Text = "Status: Found " .. serverCount .. " server(s)"
		statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	end
	
	-- Update canvas size
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

function searchButton.MouseButton1Click()
	refreshServerList()
end

function autoJoinButton.MouseButton1Click()
	statusLabel.Text = "Status: Auto-joining first server..."
	statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	
	local success, pages = pcall(function()
		return map:GetRangeAsync(
			Enum.SortDirection.Descending,
			MAX_SERVERS
		)
	end)
	
	if not success then
		statusLabel.Text = "Status: Auto-join failed!"
		statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		warn("Impossible de chercher les serveurs")
		return
	end
	
	for _, entry in ipairs(pages) do
		local data = entry.value
		if data and data.JobId and data.JobId ~= game.JobId and data.Value >= MIN_VALUE then
			-- Show confirmation dialog for auto-join too
			showConfirmationDialog(data.JobId, data.Value)
			return
		end
	end
	
	statusLabel.Text = "Status: No servers available"
	statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
end

-- Initial search
refreshServerList()
