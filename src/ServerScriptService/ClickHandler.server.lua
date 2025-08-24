local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local clickEvent = remotes:WaitForChild("Click")

clickEvent.OnServerEvent:Connect(function(player)
	local profile = PlayerData.getProfile(player)
	if not profile then return end
	local power = profile.Stats.ClickPower.Value
	local mult = profile.Stats.StrengthMultiplier.Value
	local amount = math.floor(power * mult)
	if amount < 1 then amount = 1 end
	PlayerData.addStrength(player, amount)
end)

