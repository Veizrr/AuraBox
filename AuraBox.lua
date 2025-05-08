-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then return end

-- Global Variables
getgenv().HBE = false
getgenv().HitboxSizeValue = 5
getgenv().SelectedHitboxColor = Color3.fromRGB(128, 0, 128)
getgenv().HitboxTransparency = 0.2
local Connections = {}

-- UI Window
local Window = Rayfield:CreateWindow({
    Name = "AuraBox",
    LoadingTitle = "AuraBox",
    LoadingSubtitle = "by Z",
    ConfigurationSaving = { Enabled = false }
})

-- Main Tab
local Tab = Window:CreateTab("Main", 4483362458)

-- Toggle: Enable/Disable Hitboxes
Tab:CreateToggle({
    Name = "Enable Hitboxes",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().HBE = Value
        if Value then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                AssignHitboxes(player)
            end
        else
            for _, conn in pairs(Connections) do
                if conn then conn:Disconnect() end
            end
            Connections = {}
            ResetAllHitboxes()
        end
    end
})

-- Keybind: Toggle Hitboxes
Tab:CreateKeybind({
    Name = "Toggle Hitboxes Keybind",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Callback = function()
        getgenv().HBE = not getgenv().HBE
        Rayfield:Notify({
            Title = "AuraBox",
            Content = "Hitboxes " .. (getgenv().HBE and "Enabled" or "Disabled"),
            Duration = 3
        })
        if getgenv().HBE then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                AssignHitboxes(player)
            end
        else
            for _, conn in pairs(Connections) do
                if conn then conn:Disconnect() end
            end
            Connections = {}
            ResetAllHitboxes()
        end
    end
})

-- Slider: Hitbox Size
Tab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 8},
    Increment = 1,
    Suffix = "Size",
    CurrentValue = 5,
    Callback = function(Value)
        getgenv().HitboxSizeValue = Value
    end
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- Slider: Hitbox Transparency
VisualsTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = getgenv().HitboxTransparency,
    Callback = function(Value)
        getgenv().HitboxTransparency = Value
    end
})

-- Color Picker: Hitbox Color
VisualsTab:CreateColorPicker({
    Name = "Hitbox Color",
    Color = getgenv().SelectedHitboxColor,
    Callback = function(Color)
        getgenv().SelectedHitboxColor = Color
    end
})

-- Main Script Logic
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetCharParent()
    local charParent
    repeat wait() until LocalPlayer.Character
    for _, char in pairs(workspace:GetDescendants()) do
        if string.find(char.Name, LocalPlayer.Name) and char:FindFirstChild("Humanoid") then
            charParent = char.Parent
            break
        end
    end
    return charParent
end

local CHAR_PARENT = GetCharParent()

function AssignHitboxes(player)
    if player == LocalPlayer then return end
    if Connections[player] then Connections[player]:Disconnect() end

    Connections[player] = game:GetService("RunService").RenderStepped:Connect(function()
        if not getgenv().HBE then return end

        local char = CHAR_PARENT:FindFirstChild(player.Name)
        local size = Vector3.new(getgenv().HitboxSizeValue, getgenv().HitboxSizeValue, getgenv().HitboxSizeValue)
        local color = getgenv().SelectedHitboxColor
        local transparency = getgenv().HitboxTransparency

        if char and char:FindFirstChild("HumanoidRootPart") then
            local part = char.HumanoidRootPart
            part.Size = size
            part.Color = color
            part.CanCollide = false
            part.Transparency = transparency
        end
    end)
end

function ResetAllHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = CHAR_PARENT:FindFirstChild(player.Name)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local part = char.HumanoidRootPart
            part.Size = Vector3.new(2, 2, 1)
            part.Transparency = 1
        end
    end
end

-- Initialize hitboxes (if toggle is on)
for _, player in ipairs(Players:GetPlayers()) do
    if getgenv().HBE then
        AssignHitboxes(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if getgenv().HBE then
        AssignHitboxes(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Connections[player] then
        Connections[player]:Disconnect()
        Connections[player] = nil
    end
end)
