-- Adjustable Walk Speed (Roblox Studio - your own game)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- This maintains the selected speed locally while this character exists.
-- A server-authoritative game can still override client-side changes.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local MIN_SPEED = 16
local MAX_SPEED = 1000
local desiredSpeed = 1000

local function applySpeed(humanoid)
    if humanoid and humanoid.Parent and humanoid.WalkSpeed ~= desiredSpeed then
        humanoid.WalkSpeed = desiredSpeed
    end
end

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")

    -- Apply after spawn and reapply if another local script changes WalkSpeed.
    applySpeed(humanoid)

    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.Parent and humanoid.WalkSpeed ~= desiredSpeed then
            applySpeed(humanoid)
        end
    end)
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
    task.spawn(setupCharacter, player.Character)
end

-- Optional helper for a GUI or other LocalScript in your own game:
-- Set desiredSpeed to a value between 16 and 1000 before calling applySpeed.
-- For a secure multiplayer game, validate movement on the server.
