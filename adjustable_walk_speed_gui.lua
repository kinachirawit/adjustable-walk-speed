-- Adjustable Walk Speed GUI (Roblox Studio - your own game)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Includes: slider, editable speed value, Enable/Disable, and Reset to Normal.
-- A server-authoritative game can override client-side WalkSpeed changes.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local MIN_SPEED = 16
local MAX_SPEED = 1000
local NORMAL_SPEED = 16
local selectedSpeed = NORMAL_SPEED
local speedEnabled = false

local gui = Instance.new("ScreenGui")
gui.Name = "AdjustableWalkSpeedGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(300, 235)
panel.Position = UDim2.new(0, 20, 0.5, -117)
panel.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "WALK SPEED CONTROL"
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.Parent = panel

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, -30, 0, 25)
valueLabel.Position = UDim2.fromOffset(15, 43)
valueLabel.BackgroundTransparency = 1
valueLabel.Font = Enum.Font.Gotham
valueLabel.TextSize = 14
valueLabel.TextXAlignment = Enum.TextXAlignment.Left
valueLabel.TextColor3 = Color3.fromRGB(220, 222, 240)
valueLabel.Text = "Speed: 16"
valueLabel.Parent = panel

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, -30, 0, 8)
sliderTrack.Position = UDim2.fromOffset(15, 77)
sliderTrack.BackgroundColor3 = Color3.fromRGB(65, 68, 84)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = panel
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(143, 108, 255)
fill.BorderSizePixel = 0
fill.Parent = sliderTrack
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("TextButton")
knob.Size = UDim2.fromOffset(18, 18)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.new(0, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.Text = ""
knob.AutoButtonColor = false
knob.Parent = sliderTrack
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local valueBox = Instance.new("TextBox")
valueBox.Size = UDim2.fromOffset(100, 32)
valueBox.Position = UDim2.fromOffset(15, 101)
valueBox.BackgroundColor3 = Color3.fromRGB(43, 46, 60)
valueBox.TextColor3 = Color3.new(1, 1, 1)
valueBox.PlaceholderText = "16–1000"
valueBox.Text = "16"
valueBox.ClearTextOnFocus = false
valueBox.Font = Enum.Font.Gotham
valueBox.TextSize = 14
valueBox.Parent = panel
Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

local enableButton = Instance.new("TextButton")
enableButton.Size = UDim2.fromOffset(150, 32)
enableButton.Position = UDim2.fromOffset(135, 101)
enableButton.BackgroundColor3 = Color3.fromRGB(53, 145, 92)
enableButton.TextColor3 = Color3.new(1, 1, 1)
enableButton.Text = "Speed: OFF"
enableButton.Font = Enum.Font.GothamBold
enableButton.TextSize = 13
enableButton.Parent = panel
Instance.new("UICorner", enableButton).CornerRadius = UDim.new(0, 6)

local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.fromOffset(125, 32)
applyButton.Position = UDim2.fromOffset(15, 145)
applyButton.BackgroundColor3 = Color3.fromRGB(85, 89, 112)
applyButton.TextColor3 = Color3.new(1, 1, 1)
applyButton.Text = "Apply Value"
applyButton.Font = Enum.Font.Gotham
applyButton.TextSize = 13
applyButton.Parent = panel
Instance.new("UICorner", applyButton).CornerRadius = UDim.new(0, 6)

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.fromOffset(125, 32)
resetButton.Position = UDim2.fromOffset(150, 145)
resetButton.BackgroundColor3 = Color3.fromRGB(85, 89, 112)
resetButton.TextColor3 = Color3.new(1, 1, 1)
resetButton.Text = "Normal (16)"
resetButton.Font = Enum.Font.Gotham
resetButton.TextSize = 13
resetButton.Parent = panel
Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 25)
status.Position = UDim2.fromOffset(15, 190)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(180, 185, 205)
status.Text = "Disabled — normal speed"
status.Parent = panel

local dragging = false

local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function applyCurrentSpeed()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speedEnabled and selectedSpeed or NORMAL_SPEED
    end
end

local function updateSlider(speed)
    selectedSpeed = math.clamp(math.floor(speed + 0.5), MIN_SPEED, MAX_SPEED)
    local alpha = (selectedSpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    fill.Size = UDim2.new(alpha, 0, 1, 0)
    knob.Position = UDim2.new(alpha, 0, 0.5, 0)
    valueLabel.Text = "Speed: " .. selectedSpeed
    valueBox.Text = tostring(selectedSpeed)
    if speedEnabled then
        applyCurrentSpeed()
    end
end

local function setSpeedEnabled(enabled)
    speedEnabled = enabled
    enableButton.Text = speedEnabled and "Speed: ON" or "Speed: OFF"
    enableButton.BackgroundColor3 = speedEnabled and Color3.fromRGB(53, 145, 92) or Color3.fromRGB(120, 65, 65)
    status.Text = speedEnabled and ("Enabled — " .. selectedSpeed) or "Disabled — normal speed"
    applyCurrentSpeed()
end

local function setFromX(x)
    local width = sliderTrack.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp((x - sliderTrack.AbsolutePosition.X) / width, 0, 1)
    updateSlider(MIN_SPEED + alpha * (MAX_SPEED - MIN_SPEED))
end

knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        setFromX(input.Position.X)
    end
end)

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        setFromX(input.Position.X)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setFromX(input.Position.X)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

applyButton.Activated:Connect(function()
    local number = tonumber(valueBox.Text)
    if number then
        updateSlider(math.clamp(number, MIN_SPEED, MAX_SPEED))
        status.Text = "Selected speed: " .. selectedSpeed
    else
        status.Text = "Enter a number from 16 to 1000"
    end
end)

enableButton.Activated:Connect(function()
    setSpeedEnabled(not speedEnabled)
end)

resetButton.Activated:Connect(function()
    updateSlider(NORMAL_SPEED)
    setSpeedEnabled(false)
end)

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speedEnabled and selectedSpeed or NORMAL_SPEED
end)

updateSlider(NORMAL_SPEED)
setSpeedEnabled(false)
