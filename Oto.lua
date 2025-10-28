local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
local Window = redzlib:MakeWindow({
    Title = "RZ COMMUNITY: Blox Fruits",
    SubTitle = "by oto",
    SaveFolder = "Ensinando um mlk"
})

local FarmTab = Window:MakeTab({"Farm", "Swords"})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://121088399495969", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(0, 6) },
})

--// AUTO CHEST FARM
local AutoChest = { Enabled = false, MaxSpeed = 300 }

local function getCharacter()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    player.Character:WaitForChild("HumanoidRootPart")
    return player.Character
end

local function DistanceFromPlrSort(ObjectList)
    local RootPart = getCharacter().HumanoidRootPart
    table.sort(ObjectList, function(ChestA, ChestB)
        return (RootPart.Position - ChestA.Position).Magnitude < (RootPart.Position - ChestB.Position).Magnitude
    end)
end

local UncheckedChests, FirstRun = {}, true
local function getChestsSorted()
    if FirstRun then
        FirstRun = false
        for _, Object in pairs(game:GetDescendants()) do
            if Object.Name:find("Chest") and Object.ClassName == "Part" then
                table.insert(UncheckedChests, Object)
            end
        end
    end
    local Chests = {}
    for _, Chest in pairs(UncheckedChests) do
        if Chest:FindFirstChild("TouchInterest") then
            table.insert(Chests, Chest)
        end
    end
    DistanceFromPlrSort(Chests)
    return Chests
end

local function toggleNoclip(Toggle)
    for _, v in pairs(getCharacter():GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = not Toggle
        end
    end
end

local function Teleport(Goal)
    toggleNoclip(true)
    local RootPart = getCharacter().HumanoidRootPart
    local Magnitude = (RootPart.Position - Goal.Position).Magnitude
    local targetY = Goal.Position.Y + 3

    while AutoChest.Enabled and Magnitude > 5 do
        local Speed = AutoChest.MaxSpeed
        local currentPos = RootPart.Position
        local direction = (Vector3.new(Goal.Position.X, targetY, Goal.Position.Z) - currentPos).Unit
        local moveStep = direction * (Speed * task.wait())
        RootPart.Velocity = Vector3.zero
        RootPart.CFrame = CFrame.new(currentPos + moveStep, Goal.Position)
        Magnitude = (RootPart.Position - Goal.Position).Magnitude
    end

    toggleNoclip(false)
    RootPart.CFrame = Goal
end

local function main()
    while AutoChest.Enabled do
        local Chests = getChestsSorted()
        if #Chests > 0 then
            Teleport(Chests[1].CFrame)
        else
            task.wait(2)
        end
        task.wait(0.5)
    end
end

FarmTab:AddToggle({
    Name = "AutoChest",
    Default = false,
    Callback = function(Value)
        AutoChest.Enabled = Value
        if Value then
            task.spawn(main)
        end
    end
})
