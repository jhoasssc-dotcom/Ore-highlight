--[[ Ore Highlight v4.0 - APENAS MINÉRIOS COM "ORE" NO FINAL --]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Aguarda o personagem carregar
local function aguardarPersonagem()
    local char = player.Character
    if not char or not char.Parent then
        char = player.CharacterAdded:Wait()
    end
    return char
end

local char = aguardarPersonagem()
local rootPart = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- ========== CONFIGURAÇÕES ==========
local COR_HIGHLIGHT = Color3.fromRGB(255, 200, 50) -- Dourado
local TRANSPARENCIA_HIGHLIGHT = 0.3
local DISTANCIA_MAXIMA = 500

-- ========== LISTA DE MINÉRIOS ESPECÍFICOS ==========
local minériosPermitidos = {
    "Gold Ore",
    "Ruby Ore",
    "Diamond Ore",
    "Emerald Ore",
    "God Ore",
    "Amethyst Ore",
    "Obstian", -- Pode ser "Obsidian" ou similar
    "Grimson",
    "Coal Ore",
    "Iron Ore",
    "Copper Ore",
    "Silver Ore",
    "Platinum Ore",
    "Mithril Ore",
    "Adamantite Ore",
    "Crystal Ore",
    "Quartz Ore",
    "Sapphire Ore",
    "Topaz Ore",
    "Onyx Ore",
    "Jade Ore",
    "Titanium Ore",
    "Uranium Ore"
}

-- ========== FUNÇÃO PARA VERIFICAR SE É MINÉRIO PERMITIDO ==========
local function isOrePermitido(obj)
    if not obj or not obj.Name then return false end
    
    local nome = obj.Name
    
    -- Verifica se o nome está na lista de minérios permitidos
    for _, oreName in ipairs(minériosPermitidos) do
        if nome == oreName then
            return true
        end
    end
    
    -- Também verifica se termina com "Ore" (caso tenha algum não listado)
    if string.find(nome, "Ore$") then
        return true
    end
    
    return false
end

-- ========== FUNÇÕES DE HIGHLIGHT ==========
local function criarHighlight(obj)
    if not obj then return end
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
    if obj:FindFirstChild("OreHighlight") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "OreHighlight"
    highlight.FillColor = COR_HIGHLIGHT
    highlight.FillTransparency = TRANSPARENCIA_HIGHLIGHT
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.Adornee = obj
    highlight.Parent = obj
    
    return highlight
end

local function removerHighlight(obj)
    if obj and obj:FindFirstChild("OreHighlight") then
        obj.OreHighlight:Destroy()
    end
end

-- ========== ESCANEAR MINÉRIOS ==========
local function escanearMinérios()
    if not rootPart or not rootPart.Parent then return end
    
    local playerPos = rootPart.Position
    local count = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if isOrePermitido(obj) then
                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                if pos and (playerPos - pos).Magnitude < DISTANCIA_MAXIMA then
                    criarHighlight(obj)
                    count = count + 1
                else
                    removerHighlight(obj)
                end
            else
                removerHighlight(obj)
            end
        end
    end
    
    return count
end

-- ========== LIMPAR TODOS OS HIGHLIGHTS ==========
local function limparTodosHighlights()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:FindFirstChild("OreHighlight") then
            obj.OreHighlight:Destroy()
        end
    end
end

-- ========== CRIAR GUI ==========
local function criarGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "OreHighlightGui"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false
    
    -- Botão principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 160)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 200, 50)
    frame.Parent = gui
    
    local frameC = Instance.new("UICorner")
    frameC.CornerRadius = UDim.new(0, 8)
    frameC.Parent = frame
    
    -- Botão toggle
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0, 0, 0, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = "⛏️ Marcar Ores: ON"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    
    -- Contador de minérios
    local contador = Instance.new("TextLabel")
    contador.Size = UDim2.new(0, 80, 0, 20)
    contador.Position = UDim2.new(1, -85, 0, 5)
    contador.BackgroundTransparency = 1
    contador.Text = "🔍 0"
    contador.TextColor3 = Color3.fromRGB(200, 200, 200)
    contador.TextSize = 11
    contador.Font = Enum.Font.Gotham
    contador.TextXAlignment = Enum.TextXAlignment.Right
    contador.Parent = frame
    
    return toggleBtn, contador
end

-- ========== INICIALIZAR ==========
local toggleBtn, contador = criarGUI()

-- Variável de controle
local ativo = true

-- Função toggle
local function alternarHighlight()
    ativo = not ativo
    if ativo then
        toggleBtn.Text = "⛏️ Marcar Ores: ON"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
        toggleBtn.Parent.BorderColor3 = Color3.fromRGB(255, 200, 50)
        escanearMinérios()
    else
        toggleBtn.Text = "⛏️ Marcar Ores: OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        toggleBtn.Parent.BorderColor3 = Color3.fromRGB(150, 150, 150)
        limparTodosHighlights()
        contador.Text = "🔍 0"
    end
end

toggleBtn.MouseButton1Click:Connect(alternarHighlight)

-- ========== LOOP PRINCIPAL ==========
task.spawn(function()
    print("⛏️ Ore Highlight (APENAS ORES) iniciado!")
    print("📋 Minérios marcados: Gold Ore, Ruby Ore, Diamond Ore, Emerald Ore, etc.")
    
    while true do
        if ativo and rootPart and rootPart.Parent then
            local count = escanearMinérios()
            if contador then
                contador.Text = "🔍 " .. count
            end
        end
        task.wait(1)
    end
end)

-- ========== MONITORAR NOVOS OBJETOS ==========
Workspace.DescendantAdded:Connect(function(obj)
    if not ativo then return end
    if not rootPart or not rootPart.Parent then return end
    
    task.wait(0.5)
    
    if isOrePermitido(obj) then
        local playerPos = rootPart.Position
        local pos = obj:IsA("Model") and obj:GetPivot().Position or (obj:IsA("BasePart") and obj.Position)
        if pos and (playerPos - pos).Magnitude < DISTANCIA_MAXIMA then
            criarHighlight(obj)
        end
    end
end)

-- ========== MONITORAR MUDANÇAS NO PERSONAGEM ==========
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    rootPart = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
    print("🔄 Personagem respawnou!")
end)

-- ========== ATALHO DO TECLADO (F9 para ligar/desligar) ==========
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        alternarHighlight()
        print("⛏️ Toggle via F9:", ativo)
    end
end)

-- ========== ESCONDER/MOSTRAR GUI ==========
local guiEscondida = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        guiEscondida = not guiEscondida
        if toggleBtn and toggleBtn.Parent and toggleBtn.Parent.Parent then
            toggleBtn.Parent.Parent.Visible = not guiEscondida
        end
    end
end)

print("✅ Ore Highlight ativado! Apenas minérios com 'Ore' serão marcados.")
print("🔹 F9 - Liga/Desliga")
print("🔹 ESC - Esconde/Mostra o botão")
print("🔹 Clique no botão para alternar")
