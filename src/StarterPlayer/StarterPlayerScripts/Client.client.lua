local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local clickEvent = remotes:WaitForChild("Click")
local notifyEvent = remotes:WaitForChild("Notify")

-- Simple ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClickerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 220, 0, 60)
clickButton.Position = UDim2.new(0.5, -110, 1, -80)
clickButton.AnchorPoint = Vector2.new(0.5, 1)
clickButton.Text = "CLICK"
clickButton.TextScaled = true
clickButton.BackgroundColor3 = Color3.fromRGB(255, 200, 70)
clickButton.Parent = screenGui

local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "Info"
infoLabel.Size = UDim2.new(0, 400, 0, 28)
infoLabel.Position = UDim2.new(0.5, -200, 1, -120)
infoLabel.AnchorPoint = Vector2.new(0.5, 1)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = ""
infoLabel.TextScaled = true
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.Parent = screenGui

local hud = Instance.new("TextLabel")
hud.Name = "HUD"
hud.Size = UDim2.new(0, 400, 0, 28)
hud.Position = UDim2.new(0.5, -200, 0, 20)
hud.AnchorPoint = Vector2.new(0.5, 0)
hud.BackgroundTransparency = 1
hud.TextScaled = true
hud.TextColor3 = Color3.fromRGB(255, 255, 255)
hud.Parent = screenGui

clickButton.MouseButton1Click:Connect(function()
	clickEvent:FireServer()
end)

notifyEvent.OnClientEvent:Connect(function(message)
	infoLabel.Text = message
	delay(2, function()
		if infoLabel.Text == message then
			infoLabel.Text = ""
		end
	end)
end)

local function getLeader(name)
	return player:WaitForChild("leaderstats"):WaitForChild(name)
end

local function getStat(name)
	return player:WaitForChild("Stats"):WaitForChild(name)
end

local function updateHUD()
	local coins = getLeader("Coins").Value
	local strength = getLeader("Strength").Value
	local rebirths = getLeader("Rebirths").Value
	local power = getStat("ClickPower").Value
	local capacity = getStat("Capacity").Value
	hud.Text = string.format("Coins: %d | Strength: %d/%d | Power: %d | Rebirths: %d", coins, strength, capacity, power, rebirths)
end

for _, val in ipairs({
	getLeader("Coins"),
	getLeader("Strength"),
	getLeader("Rebirths"),
	getStat("ClickPower"),
	getStat("Capacity")
}) do
	val:GetPropertyChangedSignal("Value"):Connect(updateHUD)
end

updateHUD()

