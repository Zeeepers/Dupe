local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local notifyEvent = remotes:WaitForChild("Notify")

-- Sell Pad: expects Workspace model SellPad with Part SellPart
do
	local sellPad = Workspace:FindFirstChild("SellPad")
	if sellPad and sellPad:FindFirstChild("SellPart") then
		sellPad.SellPart.Touched:Connect(function(hit)
			local character = hit.Parent
			if not character then return end
			local player = game.Players:GetPlayerFromCharacter(character)
			if not player then return end
			local before = PlayerData.getProfile(player).Leaderstats.Strength.Value
			if before > 0 then
				PlayerData.sellStrength(player)
				notifyEvent:FireClient(player, "Sold strength for coins!")
			end
		end)
	end
end

-- Shop: expects Workspace model Shop with ProximityPrompts
do
	local shop = Workspace:FindFirstChild("Shop")
	if shop then
		for _, desc in ipairs(shop:GetDescendants()) do
			if desc:IsA("ProximityPrompt") and desc.Name == "UpgradeClick" then
				desc.Triggered:Connect(function(player)
					local ok = PlayerData.tryUpgradeClick(player)
					if ok then
						notifyEvent:FireClient(player, "Click Power upgraded!")
					else
						notifyEvent:FireClient(player, "Not enough coins for Click Power.")
					end
				end)
			elseif desc:IsA("ProximityPrompt") and desc.Name == "UpgradeCapacity" then
				desc.Triggered:Connect(function(player)
					local ok = PlayerData.tryUpgradeCapacity(player)
					if ok then
						notifyEvent:FireClient(player, "Capacity upgraded!")
					else
						notifyEvent:FireClient(player, "Not enough coins for Capacity.")
					end
				end)
			end
		end
	end
end

-- Rebirth Altar: expects Workspace model RebirthAltar with a ProximityPrompt named RebirthPrompt
do
	local altar = Workspace:FindFirstChild("RebirthAltar")
	if altar then
		for _, desc in ipairs(altar:GetDescendants()) do
			if desc:IsA("ProximityPrompt") and desc.Name == "RebirthPrompt" then
				desc.Triggered:Connect(function(player)
					local ok = PlayerData.tryRebirth(player)
					if ok then
						notifyEvent:FireClient(player, "Rebirthed! Multiplier increased.")
					else
						notifyEvent:FireClient(player, "Not enough coins to rebirth.")
					end
				end)
			end
		end
	end
end

