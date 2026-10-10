-- AutoBatClient.lua
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- GUI defaults: hit range 10 studs, attack interval 0.5 seconds.
-- Designed for a Roblox Studio game you control. Server validates every hit.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("AutoBatRemote")

local DEFAULT_RANGE = 10
local DEFAULT_INTERVAL = 0.5
local MIN_RANGE, MAX_RANGE = 5, 50
local MIN_INTERVAL, MAX_INTERVAL = 0.2, 2

local enabled = false
local hitRange = DEFAULT_RANGE
local interval = DEFAULT_INTERVAL
local lastRequest = 0

local gui = Instance.new("ScreenGui")
gui.Name = "AutoBatGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(290, 250)
panel.Position = UDim2.new(0, 20, 0.5, -125)
panel.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local function label(text, position, size, textSize)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1
    item.Position = position
    item.Size = size
    item.Font = Enum.Font.Gotham
    item.Text = text
    item.TextSize = textSize or 14
    item.TextColor3 = Color3.fromRGB(240, 240, 250)
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Parent = panel
    return item
end

label("AUTO BAT", UDim2.fromOffset(14, 8), UDim2.new(1, -28, 0, 28), 17).Font = Enum.Font.GothamBold
local status = label("Status: OFF", UDim2.fromOffset(14, 37), UDim2.new(1, -28, 0, 22), 12)
status.TextColor3 = Color3.fromRGB(190, 195, 210)

local rangeText = label("Hit range: 10 studs", UDim2.fromOffset(14, 67), UDim2.new(1, -28, 0, 22), 13)
local rangeBox = Instance.new("TextBox")
rangeBox.Position = UDim2.fromOffset(14, 91)
rangeBox.Size = UDim2.fromOffset(90, 30)
rangeBox.BackgroundColor3 = Color3.fromRGB(43, 46, 60)
rangeBox.TextColor3 = Color3.new(1, 1, 1)
rangeBox.Text = tostring(DEFAULT_RANGE)
rangeBox.PlaceholderText = "5–50"
rangeBox.ClearTextOnFocus = false
rangeBox.Font = Enum.Font.Gotham
rangeBox.TextSize = 14
rangeBox.Parent = panel
Instance.new("UICorner", rangeBox).CornerRadius = UDim.new(0, 6)

local rangeSlider = Instance.new("TextButton")
rangeSlider.Position = UDim2.fromOffset(116, 91)
rangeSlider.Size = UDim2.fromOffset(160, 30)
rangeSlider.BackgroundColor3 = Color3.fromRGB(69, 65, 105)
rangeSlider.TextColor3 = Color3.new(1, 1, 1)
rangeSlider.Text = "Range − / +"
rangeSlider.Font = Enum.Font.Gotham
rangeSlider.TextSize = 12
rangeSlider.Parent = panel
Instance.new("UICorner", rangeSlider).CornerRadius = UDim.new(0, 6)

local intervalText = label("Attack interval: 0.5 sec", UDim2.fromOffset(14, 130), UDim2.new(1, -28, 0, 22), 13)
local intervalBox = Instance.new("TextBox")
intervalBox.Position = UDim2.fromOffset(14, 154)
intervalBox.Size = UDim2.fromOffset(90, 30)
intervalBox.BackgroundColor3 = Color3.fromRGB(43, 46, 60)
intervalBox.TextColor3 = Color3.new(1, 1, 1)
intervalBox.Text = tostring(DEFAULT_INTERVAL)
intervalBox.PlaceholderText = "0.2–2"
intervalBox.ClearTextOnFocus = false
intervalBox.Font = Enum.Font.Gotham
intervalBox.TextSize = 14
intervalBox.Parent = panel
Instance.new("UICorner", intervalBox).CornerRadius = UDim.new(0, 6)

local intervalButton = Instance.new("TextButton")
intervalButton.Position = UDim2.fromOffset(116, 154)
intervalButton.Size = UDim2.fromOffset(160, 30)
intervalButton.BackgroundColor3 = Color3.fromRGB(69, 65, 105)
intervalButton.TextColor3 = Color3.new(1, 1, 1)
intervalButton.Text = "Interval − / +"
intervalButton.Font = Enum.Font.Gotham
intervalButton.TextSize = 12
intervalButton.Parent = panel
Instance.new("UICorner", intervalButton).CornerRadius = UDim.new(0, 6)

local toggle = Instance.new("TextButton")
toggle.Position = UDim2.fromOffset(14, 198)
toggle.Size = UDim2.fromOffset(262, 36)
toggle.BackgroundColor3 = Color3.fromRGB(120, 65, 65)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "START AUTO HIT"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.Parent = panel
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)

local function setRange(value)
    hitRange = math.clamp(math.floor(value + 0.5), MIN_RANGE, MAX_RANGE)
    rangeBox.Text = tostring(hitRange)
    rangeText.Text = "Hit range: " .. hitRange .. " studs"
end

local function setInterval(value)
    interval = math.clamp(value, MIN_INTERVAL, MAX_INTERVAL)
    interval = math.floor(interval * 10 + 0.5) / 10
    intervalBox.Text = string.format("%.1f", interval)
    intervalText.Text = string.format("Attack interval: %.1f sec", interval)
end

rangeSlider.Activated:Connect(function()
    setRange(hitRange >= MAX_RANGE and MIN_RANGE or hitRange + 5)
end)

intervalButton.Activated:Connect(function()
    setInterval(interval >= MAX_INTERVAL and MIN_INTERVAL or interval + 0.1)
end)

rangeBox.FocusLost:Connect(function()
    local value = tonumber(rangeBox.Text)
    if value then setRange(value) else setRange(hitRange) end
end)

intervalBox.FocusLost:Connect(function()
    local value = tonumber(intervalBox.Text)
    if value then setInterval(value) else setInterval(interval) end
end)

local function getRoot(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

local function findNearestTarget()
    local myCharacter = player.Character
    local myRoot = getRoot(myCharacter)
    if not myRoot then return nil end

    local bestModel, bestDistance = nil, hitRange
    -- Other players
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local model = otherPlayer.Character
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local root = getRoot(model)
            if humanoid and humanoid.Health > 0 and root then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance <= bestDistance then
                    bestModel, bestDistance = model, distance
                end
            end
        end
    end
    -- NPCs in Workspace (models with Humanoid and root), excluding own character.
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item ~= myCharacter and not Players:GetPlayerFromCharacter(item) then
            local humanoid = item:FindFirstChildOfClass("Humanoid")
            local root = getRoot(item)
            if humanoid and humanoid.Health > 0 and root then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance <= bestDistance then
                    bestModel, bestDistance = item, distance
                end
            end
        end
    end
    return bestModel
end

toggle.Activated:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "STOP AUTO HIT" or "START AUTO HIT"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(53, 145, 92) or Color3.fromRGB(120, 65, 65)
    status.Text = enabled and "Status: ON — server checks each hit" or "Status: OFF"
end)

task.spawn(function()
    while gui.Parent do
        if enabled and (os.clock() - lastRequest) >= interval then
            lastRequest = os.clock()
            local target = findNearestTarget()
            if target then
                remote:FireServer(target, hitRange)
            end
        end
        task.wait(0.05)
    end
end)

setRange(DEFAULT_RANGE)
setInterval(DEFAULT_INTERVAL)
