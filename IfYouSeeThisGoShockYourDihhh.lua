-- One-time badge flag (global so it persists across re-executions)
_G.ShockerBadgeGiven = _G.ShockerBadgeGiven or false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function spawnShocker()
    local shockerModel = game:GetObjects("rbxassetid://11547803978")[1]
    shockerModel.PrimaryPart = shockerModel:FindFirstChild("HumanoidRootPart") or shockerModel:FindFirstChildWhichIsA("Part")
    
    local camera = Workspace.CurrentCamera
    shockerModel:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, 0, -7))
    shockerModel.Parent = Workspace

    local oogaBoogaaPart = shockerModel:WaitForChild("OOGA BOOGAAAA")
    local horrorScream = oogaBoogaaPart:WaitForChild("HORROR SCREAM 15")

    local lookDuration = 4
    local startTime = tick()
    local playerLookingAtShocker = true

    while playerLookingAtShocker do
        task.wait(0.1)

        if not character or not character.PrimaryPart then break end

        local angle = (oogaBoogaaPart.Position - character.PrimaryPart.Position).Unit
        local direction = camera.CFrame.LookVector

        if (angle:Dot(direction) > 0.9) then
            if tick() - startTime >= lookDuration then
                horrorScream:Play()
                humanoid:TakeDamage(30)
                playerLookingAtShocker = false

                local speed = 10
                local targetPosition = character.PrimaryPart.Position

                while oogaBoogaaPart.Position.Y > targetPosition.Y do
                    local directionToPlayer = (targetPosition - oogaBoogaaPart.Position).Unit
                    oogaBoogaaPart.Position = oogaBoogaaPart.Position + directionToPlayer * speed * 0.1
                    task.wait(0.1)
                end

                break
            end
        else
            break
        end
    end

    -- cleanup movement
    oogaBoogaaPart.CanCollide = false
    oogaBoogaaPart.Anchored = false

    task.wait(3)
    shockerModel:Destroy()

    -- death UI (only if player died from it)
    if humanoid.Health <= 0 then
        game:GetService("ReplicatedStorage").GameStats["Player_".. player.Name].Total.DeathCause.Value = "Shocker"
        firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent,
            {"You died to who you call Shocker...","Dont look at it or it stuns you!"},
            "Blue"
        )
    end

    ---====== Badge Logic (AFTER DESPAWN) ======---
    if not _G.ShockerBadgeGiven then
        _G.ShockerBadgeGiven = true

        local achievementGiver = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Achievements/Source.lua"))()

        achievementGiver({
            Title = "Shocking Experience",
            Desc = "Look at me.",
            Reason = "Encounter Shocker.",
            Image = "rbxassetid://17857830685"
        })
    end
end

spawnShocker()
