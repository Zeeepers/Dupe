local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerData = {}
PlayerData.__index = PlayerData

local DATASTORE_NAME = "ClickerSimV1"
local store = DataStoreService:GetDataStore(DATASTORE_NAME)

local playersToProfiles = {}

local function createLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	local strength = Instance.new("IntValue")
	strength.Name = "Strength"
	strength.Value = 0
	strength.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	return leaderstats
end

local function createStatsFolder(player)
	local stats = Instance.new("Folder")
	stats.Name = "Stats"
	stats.Parent = player

	local clickPower = Instance.new("IntValue")
	clickPower.Name = "ClickPower"
	clickPower.Value = Config.Defaults.ClickPower
	clickPower.Parent = stats

	local capacity = Instance.new("IntValue")
	capacity.Name = "Capacity"
	capacity.Value = Config.Defaults.Capacity
	capacity.Parent = stats

	local strengthMultiplier = Instance.new("NumberValue")
	strengthMultiplier.Name = "StrengthMultiplier"
	strengthMultiplier.Value = 1
	strengthMultiplier.Parent = stats

	local clickLevel = Instance.new("IntValue")
	clickLevel.Name = "ClickLevel"
	clickLevel.Value = 0
	clickLevel.Parent = stats

	local capacityLevel = Instance.new("IntValue")
	capacityLevel.Name = "CapacityLevel"
	capacityLevel.Value = 0
	capacityLevel.Parent = stats

	return stats
end

local function computeStrengthMultiplier(rebirths)
	return 1 + (rebirths * Config.RebirthMultiplierPer)
end

local function safePcall(callback)
	local ok, result = pcall(callback)
	if ok then
		return true, result
	end
	return false, result
end

function PlayerData.loadForPlayer(player)
	local key = "player_" .. player.UserId
	local saved = nil
	for _ = 1, 3 do
		local ok, result = safePcall(function()
			return store:GetAsync(key)
		end)
		if ok then
			saved = result
			break
		end
		wait(0.2)
	end

	local leaderstats = createLeaderstats(player)
	local stats = createStatsFolder(player)

	local profile = {
		Player = player,
		Leaderstats = leaderstats,
		Stats = stats,
		LastSave = 0,
	}

	if typeof(saved) == "table" then
		leaderstats.Coins.Value = saved.Coins or Config.Defaults.Coins
		leaderstats.Strength.Value = saved.Strength or Config.Defaults.Strength
		leaderstats.Rebirths.Value = saved.Rebirths or Config.Defaults.Rebirths

		stats.ClickPower.Value = saved.ClickPower or Config.Defaults.ClickPower
		stats.Capacity.Value = saved.Capacity or Config.Defaults.Capacity
		stats.StrengthMultiplier.Value = computeStrengthMultiplier(leaderstats.Rebirths.Value)
		stats.ClickLevel.Value = saved.ClickLevel or 0
		stats.CapacityLevel.Value = saved.CapacityLevel or 0
	else
		leaderstats.Coins.Value = Config.Defaults.Coins
		leaderstats.Strength.Value = Config.Defaults.Strength
		leaderstats.Rebirths.Value = Config.Defaults.Rebirths
		stats.ClickPower.Value = Config.Defaults.ClickPower
		stats.Capacity.Value = Config.Defaults.Capacity
		stats.StrengthMultiplier.Value = 1
		stats.ClickLevel.Value = 0
		stats.CapacityLevel.Value = 0
	end

	playersToProfiles[player] = profile
	return profile
end

function PlayerData.getProfile(player)
	return playersToProfiles[player]
end

function PlayerData.addStrength(player, amount)
	local profile = playersToProfiles[player]
	if not profile then return end
	local strength = profile.Leaderstats.Strength
	local capacity = profile.Stats.Capacity
	local newValue = math.min(strength.Value + amount, capacity.Value)
	strength.Value = newValue
end

function PlayerData.sellStrength(player)
	local profile = playersToProfiles[player]
	if not profile then return end
	local strength = profile.Leaderstats.Strength
	local coins = profile.Leaderstats.Coins
	local gained = strength.Value * Config.SellRatio
	if gained > 0 then
		coins.Value = coins.Value + gained
		strength.Value = 0
	end
end

function PlayerData.tryUpgradeClick(player)
	local profile = playersToProfiles[player]
	if not profile then return false end
	local coins = profile.Leaderstats.Coins
	local stats = profile.Stats
	local level = stats.ClickLevel.Value
	local cost = Config.getClickUpgradeCost(level)
	if coins.Value < cost then return false end
	coins.Value = coins.Value - cost
	stats.ClickLevel.Value = level + 1
	stats.ClickPower.Value = stats.ClickPower.Value + 1
	return true
end

function PlayerData.tryUpgradeCapacity(player)
	local profile = playersToProfiles[player]
	if not profile then return false end
	local coins = profile.Leaderstats.Coins
	local stats = profile.Stats
	local level = stats.CapacityLevel.Value
	local cost = Config.getCapacityUpgradeCost(level)
	if coins.Value < cost then return false end
	coins.Value = coins.Value - cost
	stats.CapacityLevel.Value = level + 1
	stats.Capacity.Value = stats.Capacity.Value + Config.CapacityUpgrade.Increment
	return true
end

function PlayerData.tryRebirth(player)
	local profile = playersToProfiles[player]
	if not profile then return false end
	local leaderstats = profile.Leaderstats
	local stats = profile.Stats
	local cost = Config.getRebirthCost(leaderstats.Rebirths.Value)
	if leaderstats.Coins.Value < cost then return false end
	-- Spend all coins and reset some stats
	leaderstats.Coins.Value = 0
	leaderstats.Strength.Value = 0
	stats.ClickPower.Value = Config.Defaults.ClickPower
	stats.Capacity.Value = Config.Defaults.Capacity
	stats.ClickLevel.Value = 0
	stats.CapacityLevel.Value = 0
	-- Increment rebirths and increase multiplier
	leaderstats.Rebirths.Value = leaderstats.Rebirths.Value + 1
	stats.StrengthMultiplier.Value = computeStrengthMultiplier(leaderstats.Rebirths.Value)
	return true
end

local function serialize(profile)
	return {
		Coins = profile.Leaderstats.Coins.Value,
		Strength = profile.Leaderstats.Strength.Value,
		Rebirths = profile.Leaderstats.Rebirths.Value,
		ClickPower = profile.Stats.ClickPower.Value,
		Capacity = profile.Stats.Capacity.Value,
		ClickLevel = profile.Stats.ClickLevel.Value,
		CapacityLevel = profile.Stats.CapacityLevel.Value,
	}
end

function PlayerData.saveForPlayer(player)
	local profile = playersToProfiles[player]
	if not profile then return end
	local payload = serialize(profile)
	local key = "player_" .. player.UserId
	for _ = 1, 3 do
		local ok = safePcall(function()
			store:SetAsync(key, payload)
		end)
		if ok then break end
		wait(0.25)
	end
	profile.LastSave = os.clock()
end

function PlayerData.remove(player)
	playersToProfiles[player] = nil
end

return PlayerData

