local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")

local map = MemoryStoreService:GetSortedMap("BrainrotServers_V1")

local MAX_SERVERS = 100
local MIN_VALUE = 100_000_000

local function findBestServer(player)
	local success, pages = pcall(function()
		return map:GetRangeAsync(
			Enum.SortDirection.Descending,
			MAX_SERVERS
		)
	end)
	if not success then
		warn("Impossible de chercher les serveurs")
		return
	end
	for _, entry in ipairs(pages) do
		local data = entry.value
		if data
			and data.JobId
			and data.JobId ~= game.JobId
			and data.Value >= MIN_VALUE then
			print(
				"Serveur trouvé:",
				data.Value,
				"/sec",
				data.JobId
			)
			local teleportSuccess, teleportError = pcall(function()
				TeleportService:TeleportToPlaceInstance(
					game.PlaceId,
					data.JobId,
					player
				)
			end)
			if teleportSuccess then
				return
			else
				warn("Téléportation échouée:", teleportError)
			end
		end
	end
	warn("Aucun serveur avec 100M+/sec trouvé.")
end
