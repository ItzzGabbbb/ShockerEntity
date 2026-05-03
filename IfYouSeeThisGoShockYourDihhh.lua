getgenv().ShockerEncountered = getgenv().ShockerEncountered or false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function spawnShocker()
    local shockerModel = game:GetObjects("rbxassetid://11547803978")[1]
    shockerModel.PrimaryPart = shockerModel:FindFirstChild("HumanoidRootPart") or shockerModel:FindFirstChildWhichIsA("BasePart")
    
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

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then break end

        local directionToShocker = (oogaBoogaaPart.Position - root.Position).Unit
        local lookDirection = camera.CFrame.LookVector

        if (directionToShocker:Dot(lookDirection) > 0.9) then
            if tick() - startTime >= lookDuration then
                horrorScream:Play()
                humanoid:TakeDamage(30)
                playerLookingAtShocker = false

                ---====== SMOOTH CHARGE ======---
                local targetPosition = root.Position

                oogaBoogaaPart.Anchored = true
                oogaBoogaaPart.CanCollide = false

                oogaBoogaaPart.CFrame = CFrame.lookAt(oogaBoogaaPart.Position, targetPosition)

                local distance = (oogaBoogaaPart.Position - targetPosition).Magnitude
                local speed = 60
                local time = distance / speed

                local chargeTween = TweenService:Create(
                    oogaBoogaaPart,
                    TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { Position = targetPosition }
                )

                chargeTween:Play()
                chargeTween.Completed:Wait()

                ---====== SMOOTH SINK DOWN ======---
                local downPosition = targetPosition - Vector3.new(0, 10, 0)

                local sinkTween = TweenService:Create(
                    oogaBoogaaPart,
                    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { Position = downPosition }
                )

                sinkTween:Play()
                sinkTween.Completed:Wait()

                task.wait(0.2)
                shockerModel:Destroy()

                -- death UI
                game:GetService("ReplicatedStorage").GameStats["Player_".. player.Name].Total.DeathCause.Value = "Shocker"
                firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent,
                    {"You died to who you call Shocker...","Dont look at it or it stuns you!"},
                    "Blue"
                )

                break
            end
        else
            break
        end
    end

    task.wait(2)
    if shockerModel then
        shockerModel:Destroy()
    end

    ---====== ONE-TIME ACHIEVEMENT ======---
    if not getgenv().ShockerEncountered then
        getgenv().ShockerEncountered = true

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