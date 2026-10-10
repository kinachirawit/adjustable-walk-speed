-- Adjustable Walk Speed GUI
-- For a Roblox Studio game you own. Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- A live game's server may override or reject client-side WalkSpeed changes.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local MIN_SPEED = 16
local MAX_SPEED = 1000
local currentSpeed = 16

local gui = Instance.new("ScreenGui")
gui.Name = "WalkSpeedControl"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.fromOffset(260, 170)
frame.Position = UDim2.new(0, 20, 0.5, -85)
frame.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "WALK SPEED"
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Parent = frame

local valueBox = Instance.new("TextBox")
valueBox.Size = UDim2.fromOffset(110, 34)
valueBox.Position = UDim2.fromOffset(15, 48)
valueBox.BackgroundColor3 = Color3.fromRGB(43, 46, 60)
valueBox.TextColor3 = Color3.new(1, 1, 1)
valueBox.PlaceholderText = "16–1000"
valueBox.Text = tostring(currentSpeed)
valueBox.ClearTextOnFocus = false
valueBox.Font = Enum.Font.Gotham
valueBox.TextSize = 15
valueBox.Parent = frame
Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

local apply = Instance.new("TextButton")
apply.Size = UDim2.fromOffset(105, 34)
apply.Position = UDim2.fromOffset(140, 48)
apply.BackgroundColor3 = Color3.fromRGB(111, 83, 220)
apply.TextColor3 = Color3.new(1, 1, 1)
apply.Text = "Apply"
apply.Font = Enum.Font.GothamBold
apply.TextSize = 14
apply.Parent = frame
Instance.new("UICorner", apply).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 24)
status.Position = UDim2.fromOffset(12, 90)
status.BackgroundTransparency = 1
status.Text = "Current speed: 16"
status.TextColor3 = Color3.fromRGB(190, 195, 215)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

local reset = Instance.new("TextButton")
reset.Size = UDim2.new(1, -30, 0, 30)
reset.Position = UDim2.fromOffset(15, 125)
reset.BackgroundColor3 = Color3.fromRGB(57, 61, 76)
reset.TextColor3 = Color3.new(1, 1, 1)
reset.Text = "Reset to 16"
reset.Font = Enum.Font.Gotham
reset.TextSize = 13
reset.Parent = frame
Instance.new("UICorner", reset).CornerRadius = UDim.new(0, 6)

local function applySpeed(speed)
    currentSpeed = math.clamp(math.floor(speed), MIN_SPEED, MAX_SPEED)
    valueBox.Text = tostring(currentSpeed)
    status.Text = "Current speed: " .. currentSpeed

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = currentSpeed
    end
end

apply.Activated:Connect(function()
    local requested = tonumber(valueBox.Text)
    if requested then
        applySpeed(requested)
    else
        status.Text = "Enter a number from 16 to 1000"
    end
end)

reset.Activated:Connect(function()
    applySpeed(16)
end)

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentSpeed
end)

if player.Character then
    applySpeed(currentSpeed)
end
