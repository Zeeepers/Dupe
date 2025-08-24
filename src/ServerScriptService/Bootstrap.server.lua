local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

-- Ensure folders
local function ensureFolder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

-- Ensure remotes
local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")

local function ensureRemoteEvent(name)
	local evt = remotesFolder:FindFirstChild(name)
	if not evt then
		evt = Instance.new("RemoteEvent")
		evt.Name = name
		evt.Parent = remotesFolder
	end
	return evt
end

ensureRemoteEvent("Click")
ensureRemoteEvent("Notify")

-- Player lifecycle
Players.PlayerAdded:Connect(function(player)
	PlayerData.loadForPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerData.saveForPlayer(player)
	PlayerData.remove(player)
end)

-- Autosave loop (server-only)
if RunService:IsServer() then
	spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				PlayerData.saveForPlayer(player)
			end
			wait(60)
		end
	end)
end

