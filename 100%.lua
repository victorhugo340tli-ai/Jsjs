-- Blox Fruits Auto Farm Script
-- Sistema completo de automação

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configurações
local Config = {
    AutoFarm = true,
    AutoLevel = true,
    AutoQuest = true,
    FastAttack = true,
    BringMobs = true,
    SafeMode = true,
    FarmDistance = 15,
    AttackDelay = 0.1
}

-- Anti-AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Função para teleportar
local function Teleport(position)
    if not Config.SafeMode then
        humanoidRootPart.CFrame = CFrame.new(position)
    else
        local distance = (humanoidRootPart.Position - position).Magnitude
        local speed = 300
        local time = distance / speed
        
        local tween = game:GetService("TweenService"):Create(
            humanoidRootPart,
            TweenInfo.new(time, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(position)}
        )
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Função para pegar quest
local function GetQuest()
    local level = player.Data.Level.Value
    local questData = nil
    
    -- Determina a quest baseada no level
    if level >= 1 and level <= 9 then
        questData = {Name = "BanditQuest1", NPC = "Bandit", Area = "Jungle"}
    elseif level >= 10 and level <= 14 then
        questData = {Name = "JungleQuest", NPC = "Monkey", Area = "Jungle"}
    elseif level >= 15 and level <= 29 then
        questData = {Name = "BuggyQuest1", NPC = "Pirate", Area = "Pirate"}
    elseif level >= 30 and level <= 39 then
        questData = {Name = "DesertQuest", NPC = "Desert Bandit", Area = "Desert"}
    elseif level >= 40 and level <= 59 then
        questData = {Name = "SnowQuest", NPC = "Snow Bandit", Area = "Snow"}
    elseif level >= 60 and level <= 74 then
        questData = {Name = "MarineQuest2", NPC = "Chief Petty Officer", Area = "Marine"}
    elseif level >= 75 and level <= 99 then
        questData = {Name = "AreaQuest", NPC = "Sky Bandit", Area = "Sky"}
    elseif level >= 100 and level <= 119 then
        questData = {Name = "PrisonerQuest", NPC = "Prisoner", Area = "Prison"}
    elseif level >= 120 and level <= 149 then
        questData = {Name = "ColosseumQuest", NPC = "Gladiator", Area = "Colosseum"}
    elseif level >= 150 and level <= 174 then
        questData = {Name = "MagmaQuest", NPC = "Military Soldier", Area = "Magma"}
    elseif level >= 175 and level <= 189 then
        questData = {Name = "FountainQuest", NPC = "Military Spy", Area = "Fountain"}
    elseif level >= 190 and level <= 209 then
        questData = {Name = "SkyExp1Quest", NPC = "God's Guard", Area = "SkyIsland"}
    elseif level >= 210 and level <= 249 then
        questData = {Name = "SkyExp2Quest", NPC = "Shanda", Area = "SkyIsland"}
    elseif level >= 250 and level <= 274 then
        questData = {Name = "FishmanQuest", NPC = "Fishman Warrior", Area = "Underwater"}
    elseif level >= 275 and level <= 299 then
        questData = {Name = "FishmanQuest2", NPC = "Fishman Commando", Area = "Underwater"}
    elseif level >= 300 and level <= 324 then
        questData = {Name = "MarineQuest3", NPC = "Marine Captain", Area = "Marine"}
    elseif level >= 325 and level <= 374 then
        questData = {Name = "PirateMillionaireQuest", NPC = "Pirate", Area = "PirateIsland"}
    elseif level >= 375 and level <= 399 then
        questData = {Name = "ZombieQuest", NPC = "Zombie", Area = "Graveyard"}
    elseif level >= 400 and level <= 449 then
        questData = {Name = "VampireQuest", NPC = "Vampire", Area = "Graveyard"}
    elseif level >= 450 and level <= 474 then
        questData = {Name = "SnowMountainQuest", NPC = "Snow Trooper", Area = "SnowMountain"}
    elseif level >= 475 and level <= 524 then
        questData = {Name = "IslandQuest", NPC = "Winter Warrior", Area = "FrozenVillage"}
    else
        questData = {Name = "MarineQuest4", NPC = "Marine Commodore", Area = "Marine"}
    end
    
    return questData
end

-- Função para aceitar quest
local function AcceptQuest(questData)
    if not questData then return end
    
    local questGiver = workspace.NPCs:FindFirstChild(questData.Name)
    if questGiver then
        local args = {
            [1] = "StartQuest",
            [2] = questData.Name,
            [3] = 1
        }
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
    end
end

-- Função para encontrar mobs
local function FindMob(mobName)
    local nearestMob = nil
    local nearestDistance = math.huge
    
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == mobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local distance = (humanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestMob = mob
            end
        end
    end
    
    return nearestMob
end

-- Sistema de ataque rápido
local function FastAttack()
    local combat = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
    if combat then
        pcall(function()
            combat:InvokeServer("weaponEvent", "attack")
        end)
    end
end

-- Função para trazer mobs
local function BringMobs(targetMob)
    if not Config.BringMobs then return end
    
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == targetMob.Name and mob ~= targetMob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            if (humanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude <= 350 then
                mob.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame
                mob.HumanoidRootPart.CanCollide = false
                mob.Humanoid.WalkSpeed = 0
                mob.Humanoid.JumpPower = 0
                
                if mob:FindFirstChild("Head") then
                    mob.Head.CanCollide = false
                end
            end
        end
    end
end

-- Loop principal de farm
local function AutoFarmLoop()
    while Config.AutoFarm do
        wait()
        
        pcall(function()
            local questData = GetQuest()
            
            -- Aceita a quest
            if Config.AutoQuest then
                AcceptQuest(questData)
            end
            
            -- Encontra e ataca o mob
            local targetMob = FindMob(questData.NPC)
            
            if targetMob and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 then
                -- Teleporta para o mob
                local mobPosition = targetMob.HumanoidRootPart.Position
                local farmPosition = mobPosition + Vector3.new(0, Config.FarmDistance, 0)
                
                Teleport(farmPosition)
                
                -- Posiciona o personagem
                humanoidRootPart.CFrame = CFrame.new(farmPosition, mobPosition)
                
                -- Traz outros mobs
                BringMobs(targetMob)
                
                -- Ataca
                if Config.FastAttack then
                    for i = 1, 3 do
                        FastAttack()
                        wait(Config.AttackDelay)
                    end
                end
            else
                -- Se não há mob, espera spawn
                wait(2)
            end
        end)
    end
end

-- Função para verificar se tem quest ativa
local function HasQuest()
    return player.PlayerGui:FindFirstChild("Quest") and player.PlayerGui.Quest.Enabled
end

-- Interface simples de controle
print("=== Blox Fruits Auto Farm ===")
print("Script carregado com sucesso!")
print("Configurações:")
print("- Auto Farm: " .. tostring(Config.AutoFarm))
print("- Auto Level: " .. tostring(Config.AutoLevel))
print("- Auto Quest: " .. tostring(Config.AutoQuest))
print("- Fast Attack: " .. tostring(Config.FastAttack))
print("- Bring Mobs: " .. tostring(Config.BringMobs))
print("=============================")

-- Inicia o auto farm
spawn(AutoFarmLoop)

-- Comando para parar o farm
_G.StopFarm = function()
    Config.AutoFarm = false
    print("Auto Farm desativado!")
end

-- Comando para reiniciar o farm
_G.StartFarm = function()
    Config.AutoFarm = true
    spawn(AutoFarmLoop)
    print("Auto Farm ativado!")
end

-- Atualiza character quando respawna
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    wait(1)
end)

print("Use _G.StopFarm() para parar e _G.StartFarm() para iniciar")
