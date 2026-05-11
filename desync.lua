-- =============================================
-- BLOCK SPIN - DESYNC LIMPIO (Sin partículas)
-- Toggle: F para activar/desactivar
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local DesyncEnabled = false
local OriginalCFrame = nil
local Connection = nil

local function EnableDesync()
    if DesyncEnabled then return end
    DesyncEnabled = true
    
    OriginalCFrame = root.CFrame
    
    -- Guardamos la posición real en el servidor
    local fakeRoot = root:Clone()
    fakeRoot.Name = "FakeRoot"
    fakeRoot.Transparency = 1
    fakeRoot.CanCollide = false
    fakeRoot.Anchored = true
    fakeRoot.Parent = character
    
    Connection = RunService.Heartbeat:Connect(function()
        if not DesyncEnabled then return end
        
        -- Movimiento solo en cliente
        if root then
            root.Velocity = Vector3.new(0, 0, 0)           -- Evita que el servidor actualice posición
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end)
    
    print("🟢 DESYNC ACTIVADO - Nadie te ve")
end

local function DisableDesync()
    if not DesyncEnabled then return end
    DesyncEnabled = false
    
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    
    -- Restaurar posición real
    if root and OriginalCFrame then
        root.CFrame = OriginalCFrame
    end
    
    -- Limpiar clones
    local fake = character:FindFirstChild("FakeRoot")
    if fake then fake:Destroy() end
    
    print("🔴 DESYNC DESACTIVADO")
end

-- Toggle con tecla F
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        if DesyncEnabled then
            DisableDesync()
        else
            EnableDesync()
        end
    end
end)

-- Auto restaurar al morir o respawnear
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = newChar:WaitForChild("HumanoidRootPart")
    if DesyncEnabled then
        task.wait(0.5)
        EnableDesync()
    end
end)

print("🎮 DESYNC SCRIPT CARGADO - Presiona F para activar/desactivar")