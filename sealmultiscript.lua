
local LOGO_ID = "rbxassetid://131261307870420"
local DISCORD_INVITE = "https://discord.gg/xhn6WaHzs5"

local UI_LIB = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"
local Slate = loadstring(game:HttpGet(UI_LIB), "@Slate")()

pcall(function() Slate.Cleanup() end)
pcall(function() Slate:PreloadIcons({ "lucide" }) end)

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local Camera            = Workspace.CurrentCamera
local LocalPlayer       = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Window = Slate:CreateWindow({
    Name = "SealDev",
    Subtitle = "universal utility",
    Icon = "zap",
    Logo = true,
    Size = UDim2.fromOffset(540, 420),
    ToggleKey = Enum.KeyCode.RightControl,
})

pcall(function() Slate.Theme.Preset("Ash") end)
pcall(function() Slate:SetFontFamily("JosefinSans") end)
pcall(function() Window:SetBackdrop("aurora") end)

pcall(function()
    local corner = Window.root:FindFirstChildOfClass("UICorner")
    if corner then corner.CornerRadius = UDim.new(0, 8) end
    local stroke = Window.root:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(0, 140, 255)
        stroke.Transparency = 0.5
    end
end)

pcall(function() setclipboard(DISCORD_INVITE) end)

task.delay(1.5, function()
    pcall(function()
        Slate:Notify({
            Title = "SealDev",
            Description = "Discord invite copied to clipboard! Paste it in your browser.",
            Icon = "users",
            Tone = "Info",
            Duration = 10,
        })
    end)
end)

task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local CoreGui   = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    task.wait(0.5)

    for _, obj in ipairs(Window.root:GetDescendants()) do
        if obj:IsA("ImageLabel") then
            local sz = obj.AbsoluteSize
            if sz.X >= 18 and sz.X <= 64 and math.abs(sz.X - sz.Y) < 10 then
                obj.Image = LOGO_ID
                obj.ImageColor3 = Color3.fromRGB(255, 255, 255)
                obj.ScaleType = Enum.ScaleType.Fit
                obj.BackgroundTransparency = 1
                break
            end
        end
    end

    local mini, attempts = nil, 0
    while not mini and attempts < 60 do
        task.wait(0.5); attempts = attempts + 1
        local function findMini(root)
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local sz = obj.AbsoluteSize
                    if sz.X >= 18 and sz.X <= 64
                        and math.abs(sz.X - sz.Y) < 10
                        and obj.Visible then
                        return obj
                    end
                end
            end
        end
        mini = findMini(PlayerGui) or findMini(CoreGui)
    end

    if mini then
        local parent, savedPos, savedAnchor, savedZ =
            mini.Parent, mini.Position, mini.AnchorPoint, mini.ZIndex
        mini.Visible = false

        local badge = Instance.new("TextButton")
        badge.Size = UDim2.new(0, 110, 0, 34)
        badge.Position = savedPos
        badge.AnchorPoint = savedAnchor
        badge.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        badge.BorderSizePixel = 0
        badge.Text = ""
        badge.AutoButtonColor = false
        badge.ZIndex = savedZ + 1
        badge.Parent = parent

        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = badge
        local stroke = Instance.new("UIStroke"); stroke.Thickness = 1.5; stroke.Color = Color3.fromRGB(0, 150, 255); stroke.Transparency = 0.15; stroke.Parent = badge

        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0, 24, 0, 24)
        img.Position = UDim2.new(0, 6, 0.5, 0)
        img.AnchorPoint = Vector2.new(0, 0.5)
        img.BackgroundTransparency = 1
        img.Image = LOGO_ID
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = badge.ZIndex + 1
        img.Parent = badge

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -36, 1, 0)
        label.Position = UDim2.new(0, 34, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "SealDev"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamBold
        label.ZIndex = badge.ZIndex + 1
        label.Parent = badge

        task.spawn(function()
            local info = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            TweenService:Create(stroke, info, { Transparency = 0.55 }):Play()
        end)

        badge.MouseButton1Click:Connect(function()
            pcall(function()
                if Window.Toggle then Window:Toggle()
                elseif Window.Open then Window:Open()
                elseif Window.Show then Window:Show() end
            end)
        end)

        task.spawn(function()
            while badge.Parent do
                task.wait(0.2)
                if mini.Parent then badge.Visible = mini.Visible end
            end
        end)
    end
end)

local Tab1 = Window:CreateTab({ Name = "Instant E", Icon = "mouse-pointer-click" })

local ProximityPromptService = game:GetService("ProximityPromptService")
local promptCache = setmetatable({}, {__mode = "k"})
local connPPS, connDesc = nil, nil

local function patchPrompt(prompt)
    if promptCache[prompt] then return end
    promptCache[prompt] = prompt.HoldDuration
    prompt.HoldDuration = 0
end

local function restorePrompt(prompt)
    local orig = promptCache[prompt]
    if orig == nil then return end
    pcall(function() prompt.HoldDuration = orig end)
    promptCache[prompt] = nil
end

local function startInteract()
    if connPPS then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then patchPrompt(obj) end
    end
    connPPS  = ProximityPromptService.PromptShown:Connect(patchPrompt)
    connDesc = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then patchPrompt(obj) end
    end)
end

local function stopInteract()
    if connPPS  then connPPS:Disconnect();  connPPS  = nil end
    if connDesc then connDesc:Disconnect(); connDesc = nil end
    for prompt in pairs(promptCache) do restorePrompt(prompt) end
end

do
    local sec = Tab1:CreateSection({ Name = "Instant E" })
    sec:Toggle({
        Name = "Instant E",
        Icon = "zap",
        Default = false,
        Callback = function(state)
            if state then
                startInteract()
                Slate:Notify({Title="SealDev",Description="Instant E enabled",Icon="circle-check",Tone="Success",Duration=3})
            else
                stopInteract()
                Slate:Notify({Title="SealDev",Description="Instant E disabled",Icon="circle-alert",Tone="Danger",Duration=3})
            end
        end,
    })
end

local Tab2 = Window:CreateTab({ Name = "Movement", Icon = "move-3d" })

local flyEnabled = false
local flySpeed   = 50
local flyConn    = nil
local flyBV      = nil

local function startFly()
    if flyConn then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.AutoRotate = false
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end
    flyBV = Instance.new("BodyVelocity")
    flyBV.Parent = hrp
    flyBV.MaxForce = Vector3.new(400000, 400000, 400000)

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        if not flyBV or flyBV.Parent ~= h then
            flyBV = Instance.new("BodyVelocity")
            flyBV.Parent = h
            flyBV.MaxForce = Vector3.new(400000, 400000, 400000)
        end
        local cam = workspace.CurrentCamera
        local cf  = cam.CFrame
        local look = cf.LookVector.Unit
        h.CFrame = CFrame.new(h.Position, h.Position + look)
        h.RotVelocity = Vector3.new(0, 0, 0)
        h.Velocity    = Vector3.new(0, 0, 0)
        local move = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
        local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if move.Magnitude > 0 then move = move.Unit * flySpeed end
        flyBV.Velocity = move
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

local noclipEnabled = false
local noclipConn = nil
local savedCollide = {}

local function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if savedCollide[part] == nil then savedCollide[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    noclipEnabled = false
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
    savedCollide = {}
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyEnabled then stopFly(); task.wait(0.1); startFly() end
end)

do
    local sec = Tab2:CreateSection({ Name = "Movement" })
    sec:Toggle({
        Name = "Fly",
        Icon = "plane",
        Default = false,
        Callback = function(state)
            flyEnabled = state
            if state then
                startFly()
                Slate:Notify({Title="SealDev",Description="Fly enabled",Icon="circle-check",Tone="Success",Duration=3})
            else
                stopFly()
                Slate:Notify({Title="SealDev",Description="Fly disabled",Icon="circle-alert",Tone="Danger",Duration=3})
            end
        end,
    })
    sec:Slider({
        Name = "Fly Speed",
        Icon = "gauge",
        Min = 10, Max = 200, Default = 50,
        Callback = function(v) flySpeed = v end,
    })
    sec:Toggle({
        Name = "Noclip",
        Icon = "ghost",
        Default = false,
        Callback = function(state)
            noclipEnabled = state
            if state then
                startNoclip()
                Slate:Notify({Title="SealDev",Description="Noclip enabled",Icon="circle-check",Tone="Success",Duration=3})
            else
                stopNoclip()
                Slate:Notify({Title="SealDev",Description="Noclip disabled",Icon="circle-alert",Tone="Danger",Duration=3})
            end
        end,
    })
end

local Tab3 = Window:CreateTab({ Name = "Aimbot", Icon = "crosshair" })

local isEspActive = false
local isAimbotEnabled = false
local fovRadius = 200
local currentAimbotTarget = nil
local AIM_PART = "Head"

local espInstances = {}

local fovCircleGui = Instance.new("ScreenGui")
fovCircleGui.Name = "SealDevFOV"
fovCircleGui.ResetOnSpawn = false
fovCircleGui.IgnoreGuiInset = true
fovCircleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local fovCircle = Instance.new("Frame", fovCircleGui)
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false

local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.new(1, 1, 1)
fovStroke.Thickness = 2
fovStroke.Transparency = 0.5

local aspectRatio = Instance.new("UIAspectRatioConstraint", fovCircle)
aspectRatio.AspectRatio = 1

local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1, 0)

local function cleanUpEsp(player)
    if espInstances[player.UserId] then
        for _, inst in ipairs(espInstances[player.UserId]) do
            if inst and inst.Parent then inst:Destroy() end
        end
        espInstances[player.UserId] = nil
    end
end

local function isEspValid(player)
    local data = espInstances[player.UserId]
    if not data then return false end
    local hl, bb = data[1], data[2]
    if not hl or not hl.Parent then return false end
    if not bb or not bb.Parent then return false end
    local char = player.Character
    if not char or hl.Parent ~= char then return false end
    return true
end

local function createEspElements(player)
    if player == LocalPlayer then return end
    if isEspValid(player) then return end
    cleanUpEsp(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 1)
    local rootPart = character:WaitForChild("HumanoidRootPart", 1)
    if not humanoid or not rootPart then return end

    local playerObjects = {}

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 1, 1)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Enabled = true
    highlight.Parent = character
    table.insert(playerObjects, highlight)

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(4, 0, 2, 0)
    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
    billboardGui.ClipsDescendants = true
    billboardGui.Parent = rootPart

    local containerFrame = Instance.new("Frame", billboardGui)
    containerFrame.Name = "Container"
    containerFrame.Size = UDim2.new(1, 0, 1, 0)
    containerFrame.BackgroundTransparency = 1

    local nameLabel = Instance.new("TextLabel", containerFrame)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.5, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0.25, 0, 0.25, 0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.BackgroundTransparency = 1

    local healthBar = Instance.new("Frame", containerFrame)
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(0.5, 0, 0.2, 0)
    healthBar.Position = UDim2.new(0.25, 0, 0.65, 0)
    healthBar.BackgroundColor3 = Color3.new(1, 0, 0)
    healthBar.BorderSizePixel = 1
    healthBar.BorderColor3 = Color3.new(1, 1, 1)

    local healthFill = Instance.new("Frame", healthBar)
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
    healthFill.BorderSizePixel = 0

    table.insert(playerObjects, billboardGui)
    espInstances[player.UserId] = playerObjects
end

local function updateEspElements(player)
    if not isEspValid(player) then
        if isEspActive then createEspElements(player) end
        return
    end
    local espData = espInstances[player.UserId]
    local highlight = espData[1]
    local billboardGui = espData[2]

    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end
    local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not myHead then return end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local raycastResult = Workspace:Raycast(myHead.Position, character.Head.Position - myHead.Position, raycastParams)
    local isVisible = not raycastResult or raycastResult.Instance:IsDescendantOf(player.Character)

    local color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    if isAimbotEnabled and currentAimbotTarget and currentAimbotTarget == player then
        color = Color3.new(1, 1, 0)
    end

    local distance = (myHead.Position - character.Head.Position).Magnitude
    local scaleFactor = math.clamp(500 / distance, 0.5, 2.0)
    billboardGui.Size = UDim2.new(4 * scaleFactor, 0, 2 * scaleFactor, 0)

    if highlight then
        highlight.FillColor = color
        highlight.OutlineColor = color
    end

    if billboardGui and billboardGui.Parent then
        local c = billboardGui:FindFirstChild("Container")
        local nameLabel = c and c:FindFirstChild("NameLabel")
        local healthBar = c and c:FindFirstChild("HealthBar")
        local healthFill = healthBar and healthBar:FindFirstChild("HealthFill")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if nameLabel then nameLabel.TextColor3 = color end
        if healthFill and humanoid then
            healthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
            healthFill.BackgroundColor3 = color
        end
    end
end

local function watchPlayerForEsp(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(character)
        if isEspActive then
            cleanUpEsp(player)
            character:WaitForChild("Humanoid", 5)
            character:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.2)
            if isEspActive then createEspElements(player) end
        end
    end)
end

Players.PlayerAdded:Connect(watchPlayerForEsp)
for _, player in ipairs(Players:GetPlayers()) do watchPlayerForEsp(player) end
Players.PlayerRemoving:Connect(cleanUpEsp)

task.spawn(function()
    while true do
        task.wait(1)
        if isEspActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not isEspValid(player) then
                        createEspElements(player)
                    end
                end
            end
        end
    end
end)

local function getClosestEnemyInFOV()
    local myCharacter = LocalPlayer.Character
    if not myCharacter or not myCharacter:FindFirstChild("Head") then return nil end

    local centerPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestPlayer = nil
    local minDistance = fovRadius + 1

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end

            local targetPart = player.Character:FindFirstChild(AIM_PART)
            if not targetPart then continue end

            local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - centerPoint).Magnitude

            if onScreen and distance <= fovRadius then
                local myPart = myCharacter:FindFirstChild("Head")
                if myPart then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {myCharacter, player.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    local raycastResult = Workspace:Raycast(myPart.Position, targetPart.Position - myPart.Position, raycastParams)
                    if not raycastResult or raycastResult.Instance:IsDescendantOf(player.Character) then
                        if distance < minDistance then
                            minDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function aimAtTarget(target, targetPartName)
    local partToAimAt = target.Character:FindFirstChild(targetPartName)
    if not partToAimAt then return end
    local lookAtCFrame = CFrame.new(Camera.CFrame.Position, partToAimAt.Position)
    Camera.CFrame = Camera.CFrame:Lerp(lookAtCFrame, 0.8)
end

RunService.Heartbeat:Connect(function()
    if isEspActive then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not espInstances[player.UserId] then
                    createEspElements(player)
                end
                updateEspElements(player)
            end
        end
    end

    local rmb = false
    pcall(function()
        rmb = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end)

    if isAimbotEnabled and rmb then
        if not currentAimbotTarget or not currentAimbotTarget.Character or currentAimbotTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            currentAimbotTarget = getClosestEnemyInFOV()
        end
        if currentAimbotTarget then
            aimAtTarget(currentAimbotTarget, AIM_PART)
        end
    else
        currentAimbotTarget = nil
    end
end)

do
    local sec = Tab3:CreateSection({ Name = "Aimbot" })

    sec:Toggle({
        Name = "Aimbot (RMB)",
        Icon = "crosshair",
        Default = false,
        Callback = function(state)
            isAimbotEnabled = state
            fovCircle.Visible = state
            if not state then currentAimbotTarget = nil end
            Slate:Notify({Title="SealDev",Description=state and "Aimbot enabled" or "Aimbot disabled",Icon="circle-check",Tone="Success",Duration=3})
        end,
    })

    sec:Slider({
        Name = "FOV",
        Icon = "circle",
        Min = 50, Max = 800, Default = 200,
        Callback = function(value)
            fovRadius = value
            fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
        end,
    })

    local sec2 = Tab3:CreateSection({ Name = "ESP" })
    sec2:Toggle({
        Name = "ESP",
        Icon = "eye",
        Default = false,
        Callback = function(state)
            isEspActive = state
            if state then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then createEspElements(player) end
                end
                Slate:Notify({Title="SealDev",Description="ESP ON",Icon="circle-check",Tone="Success",Duration=3})
            else
                for _, player in ipairs(Players:GetPlayers()) do cleanUpEsp(player) end
                Slate:Notify({Title="SealDev",Description="ESP OFF",Icon="circle-alert",Tone="Danger",Duration=3})
            end
        end,
    })
end

local Tab4 = Window:CreateTab({ Name = "Teleport", Icon = "navigation" })

local TELEPORT_DISTANCE = 3
local selectedPlayer = nil

local function teleportBehind(targetPlayer)
    if not targetPlayer then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetCF = targetRoot.CFrame
    local behindCF = targetCF * CFrame.new(0, 0, TELEPORT_DISTANCE)
    local newPos = Vector3.new(behindCF.Position.X, myRoot.Position.Y, behindCF.Position.Z)
    pcall(function()
        myRoot.CFrame = CFrame.new(newPos, newPos + targetCF.LookVector)
        myRoot.Velocity = Vector3.new(0, 0, 0)
    end)
end

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local playerDropdown = nil
local function refreshPlayerList()
    if playerDropdown and playerDropdown.SetOptions then
        pcall(function() playerDropdown:SetOptions(getPlayerNames()) end)
    end
end

do
    local sec = Tab4:CreateSection({ Name = "Teleport" })

    playerDropdown = sec:Dropdown({
        Name = "Select Player",
        Icon = "user",
        Options = getPlayerNames(),
        Default = "Select...",
        Callback = function(value)
            selectedPlayer = Players:FindFirstChild(value)
        end,
    })

    sec:Button({
        Name = "Teleport Behind",
        Icon = "navigation",
        Callback = function()
            if not selectedPlayer then
                Slate:Notify({Title="SealDev",Description="No player selected",Icon="circle-alert",Tone="Danger",Duration=3})
                return
            end
            teleportBehind(selectedPlayer)
            Slate:Notify({Title="SealDev",Description="Teleported behind " .. selectedPlayer.Name,Icon="circle-check",Tone="Success",Duration=3})
        end,
    })

    sec:Button({
        Name = "Refresh Player List",
        Icon = "refresh-cw",
        Callback = function()
            refreshPlayerList()
        end,
    })
end

Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshPlayerList() end)

local TabMM2 = Window:CreateTab({ Name = "MM2", Icon = "sword" })

local roleEspActive = false
local roleLoopRunning = false
local roles = {}
local MurderName = ""
local SheriffName = ""
local HeroName = ""

local function isAlive(playerName)
    for name, data in pairs(roles) do
        if name == playerName then
            return not data.Killed and not data.Dead
        end
    end
    return false
end

local function clearAllHighlights()
    for _, v in ipairs(Players:GetPlayers()) do
        if v.Character then
            local h = v.Character:FindFirstChild("SealDevRoleESP")
            if h then h:Destroy() end
        end
    end
end

local function createHighlightFor(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    if player.Character:FindFirstChild("SealDevRoleESP") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "SealDevRoleESP"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 1
    hl.Parent = player.Character
end

local function updateHighlight(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    local hl = player.Character:FindFirstChild("SealDevRoleESP")
    if not hl then return end

    local alive = isAlive(player.Name)
    if player.Name == SheriffName and alive then
        hl.FillColor = Color3.fromRGB(0, 0, 225)
    elseif player.Name == MurderName and alive then
        hl.FillColor = Color3.fromRGB(225, 0, 0)
    elseif player.Name == HeroName and alive and not isAlive(SheriffName) then
        hl.FillColor = Color3.fromRGB(255, 250, 0)
    elseif alive then
        hl.FillColor = Color3.fromRGB(0, 225, 0)
    else
        hl.FillColor = Color3.fromRGB(100, 100, 100)
    end
    hl.FillTransparency = alive and 0.5 or 0.7
end

local function refreshRoleEsp()
    local ok, data = pcall(function()
        local getData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if not getData then return nil end
        return getData:InvokeServer()
    end)

    if ok and type(data) == "table" then
        roles = data
        MurderName = ""
        SheriffName = ""
        HeroName = ""
        for name, v in pairs(roles) do
            if type(v) == "table" then
                if v.Role == "Murderer" then
                    MurderName = name
                elseif v.Role == "Sheriff" then
                    SheriffName = name
                elseif v.Role == "Hero" then
                    HeroName = name
                end
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            createHighlightFor(plr)
            updateHighlight(plr)
        end
    end
end

local function startRoleEspLoop()
    if roleLoopRunning then return end
    roleLoopRunning = true
    task.spawn(function()
        while roleEspActive do
            pcall(refreshRoleEsp)
            RunService.RenderStepped:Wait()
        end
        roleLoopRunning = false
        clearAllHighlights()
    end)
end

local FlingTargets = {}
local FlingActive = false
local FlingOldPos = nil
local FlingFPDH = workspace.FallenPartsDestroyHeight

local function FlingOne(TargetPlayer)
    local Char = LocalPlayer.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local RP = Hum and Hum.RootPart
    local TC = TargetPlayer.Character
    if not (Char and Hum and RP and TC) then return end
    local TH = TC:FindFirstChildOfClass("Humanoid")
    local TR = TH and TH.RootPart
    local THead = TC:FindFirstChild("Head")
    if RP.Velocity.Magnitude < 50 then FlingOldPos = RP.CFrame end
    if TH and TH.Sit then return end
    workspace.FallenPartsDestroyHeight = 0/0
    local BV = Instance.new("BodyVelocity")
    BV.Parent = RP
    BV.Velocity = Vector3.new(0,0,0)
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local Target = TR or THead
    if Target then
        local T0, Angle = tick(), 0
        repeat
            if RP and TH then
                Angle = Angle + 100
                for _, off in ipairs({1.5, -1.5}) do
                    RP.CFrame = CFrame.new(Target.Position) * CFrame.new(0, off, 0) * CFrame.Angles(math.rad(Angle),0,0)
                    Char:SetPrimaryPartCFrame(RP.CFrame)
                    RP.Velocity = Vector3.new(9e7, 9e8, 9e7)
                    RP.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                    task.wait()
                end
            end
        until tick() - T0 > 2 or not FlingActive
    end
    BV:Destroy()
    Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    if FlingOldPos then
        repeat
            RP.CFrame = FlingOldPos * CFrame.new(0, .5, 0)
            Char:SetPrimaryPartCFrame(RP.CFrame)
            Hum:ChangeState("GettingUp")
            for _, p in pairs(Char:GetChildren()) do
                if p:IsA("BasePart") then p.Velocity, p.RotVelocity = Vector3.new(), Vector3.new() end
            end
            task.wait()
        until (RP.Position - FlingOldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = FlingFPDH
    end
end

do
    local sec1 = TabMM2:CreateSection({ Name = "Role ESP" })
    sec1:Toggle({
        Name = "Role ESP",
        Icon = "eye",
        Default = false,
        Callback = function(state)
            roleEspActive = state
            if state then
                startRoleEspLoop()
                Slate:Notify({Title="MM2",Description="Role ESP ON",Icon="circle-check",Tone="Success",Duration=3})
            else
                clearAllHighlights()
                Slate:Notify({Title="MM2",Description="Role ESP OFF",Icon="circle-alert",Tone="Danger",Duration=3})
            end
        end,
    })

    local sec3 = TabMM2:CreateSection({ Name = "Fling" })
    local pendingName = nil

    sec3:Dropdown({
        Name = "Add Target",
        Icon = "user-plus",
        Options = (function()
            local t = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then table.insert(t, p.Name) end
            end
            return t
        end)(),
        Default = "Select...",
        Callback = function(v) pendingName = v end,
    })

    sec3:Button({
        Name = "Add Selected",
        Icon = "plus",
        Callback = function()
            if pendingName then
                local p = Players:FindFirstChild(pendingName)
                if p and p ~= LocalPlayer then
                    FlingTargets[p.Name] = p
                    Slate:Notify({Title="Fling",Description="Added: "..p.Name,Icon="circle-check",Tone="Success",Duration=2})
                end
            end
        end,
    })

    sec3:Button({
        Name = "Clear Targets",
        Icon = "trash-2",
        Callback = function() FlingTargets = {} end,
    })

    sec3:Toggle({
        Name = "Fling Active",
        Icon = "flame",
        Default = false,
        Callback = function(state)
            FlingActive = state
            if state then
                local n = 0
                for _ in pairs(FlingTargets) do n = n + 1 end
                if n == 0 then FlingActive = false; return end
                task.spawn(function()
                    while FlingActive do
                        for name, p in pairs(FlingTargets) do
                            if not FlingActive then break end
                            if p and p.Parent and p.Character then
                                pcall(FlingOne, p)
                                task.wait(0.1)
                            else
                                FlingTargets[name] = nil
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end,
    })
end

local TabInfo = Window:CreateTab({ Name = "Info", Icon = "info" })
do
    local sec = TabInfo:CreateSection({ Name = "Community" })

    sec:Button({
        Name = "Join Discord",
        Icon = "users",
        Callback = function()
            pcall(function() setclipboard(DISCORD_INVITE) end)
            Slate:Notify({
                Title = "SealDev",
                Description = "Discord link copied! Paste in browser.",
                Icon = "circle-check",
                Tone = "Success",
                Duration = 6,
            })
        end,
    })

    sec:Button({
        Name = "Copy Discord Link",
        Icon = "copy",
        Callback = function()
            pcall(function() setclipboard(DISCORD_INVITE) end)
            Slate:Notify({
                Title = "SealDev",
                Description = "Copied: " .. DISCORD_INVITE,
                Icon = "circle-check",
                Tone = "Success",
                Duration = 6,
            })
        end,
    })
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if roleEspActive and p ~= LocalPlayer and p.Character then
            createHighlightFor(p)
            updateHighlight(p)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if p.Character then
        local h = p.Character:FindFirstChild("SealDevRoleESP")
        if h then h:Destroy() end
    end
end)

warn("[SealDev] Loaded")
