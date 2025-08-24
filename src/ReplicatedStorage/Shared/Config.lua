local Config = {}

-- Core Defaults
Config.Defaults = {
	Strength = 0,
	Coins = 0,
	Rebirths = 0,
	ClickPower = 1,
	Capacity = 50,
}

-- Gameplay Tuning
Config.SellRatio = 1 -- 1 Strength -> 1 Coin
Config.RebirthMultiplierPer = 0.5 -- Each rebirth adds +0.5x to Strength gain

-- Cost Curves
Config.ClickUpgrade = {
	BaseCost = 50,
	Growth = 1.75,
}

Config.CapacityUpgrade = {
	BaseCost = 100,
	Growth = 1.6,
	Increment = 50, -- Capacity gained per upgrade level
}

Config.Rebirth = {
	BaseCost = 1000,
	Growth = 4.0,
}

function Config.getClickUpgradeCost(level)
	return math.floor(Config.ClickUpgrade.BaseCost * (Config.ClickUpgrade.Growth ^ level))
end

function Config.getCapacityUpgradeCost(level)
	return math.floor(Config.CapacityUpgrade.BaseCost * (Config.CapacityUpgrade.Growth ^ level))
end

function Config.getRebirthCost(rebirths)
	return math.floor(Config.Rebirth.BaseCost * (Config.Rebirth.Growth ^ rebirths))
end

return Config

