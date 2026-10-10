-- AutoBatServer.lua
-- Install as a Script in ServerScriptService in a Roblox Studio game you control.
-- Requires a Tool named "Bat" to be equipped by the player.
-- Server validates equipped tool, target, distance, cooldown, and line of sight.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "AutoBatRemote"
local TOOL_NAME = "Bat"
local MAX_RANGE = 10
local MIN_COOLDOWN = 0.5
local DAMAGE = 15

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

local lastHitAt = {}

local function rootOf(model)
    return model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso"))
end

local function hasEquippedBat(character)
    local tool = character and character:FindFirstChildOfClass("Tool")
    return tool ~= nil and tool.Name == TOOL_NAME
end

local function targetIsValid(attacker, targetModel)
    if typeof(targetModel) ~= "Instance" or not targetModel:IsA("Model") then
        return false
    end

    local attackerCharacter = attacker.Character
    if not attackerCharacter or targetModel == attackerCharacter then
        return false
    end

    if not targetModel:IsDescendantOf(workspace) then
        return false
    end

    local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
    local targetRoot = rootOf(targetModel)
    if not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot then
        return false
    end

    local attackerRoot = rootOf(attackerCharacter)
    local attackerHumanoid = attackerCharacter:FindFirstChildOfClass("Humanoid")
    if not attackerRoot or not attackerHumanoid or attackerHumanoid.Health <= 0 then
        return false
    end

    -- Require an equipped Bat on the server, not merely a client claim.
    if not hasEquippedBat(attackerCharacter) then
        return false
    end

    -- Server-controlled range cap: client cannot request extra range.
    local distance = (targetRoot.Position - attackerRoot.Position).Magnitude
    if distance > MAX_RANGE then
        return false
    end

    -- Optional line-of-sight check to prevent hitting through walls.
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {attackerCharacter}
    params.IgnoreWater = true
    local direction = targetRoot.Position - attackerRoot.Position
    local result = workspace:Raycast(attackerRoot.Position, direction, params)
    if result and not result.Instance:IsDescendantOf(targetModel) then
        return false
    end

    return targetHumanoid
end

remote.OnServerEvent:Connect(function(player, targetModel, _clientRange)
    local now = os.clock()
    if now - (lastHitAt[player] or 0) < MIN_COOLDOWN then
        return
    end

    local targetHumanoid = targetIsValid(player, targetModel)
    if not targetHumanoid then
        return
    end

    lastHitAt[player] = now
    targetHumanoid:TakeDamage(DAMAGE)
end)

Players.PlayerRemoving:Connect(function(player)
    lastHitAt[player] = nil
end)
