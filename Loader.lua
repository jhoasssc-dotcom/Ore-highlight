--[[ Ore Highlight v2.0 - Marca todos os minérios no mapa (CORRIGIDO) --]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
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
local TRANSPARENCIA_HIGHLIGHT = 0.4
local DISTANCIA_MAXIMA = 500

-- Lista de palavras relacionadas a minérios
local palavrasOre = {
    "ore", "minerio", "minério", "mineral", "rock", "pedra",
    "coal", "carvao", "carvão", "iron", "ferro", "gold", "ouro",
    "diamond", "diamante", "emerald", "esmeralda", "ruby", "rubi",
    "sapphire", "safira", "copper", "cobre", "tin", "estanho",
    "silver", "prata", "platinum", "platina", "mithril", "mithral",
    "adamantite", "adamant", "runite", "rune", "void", "vazio",
    "crystal", "cristal", "gem", "gema", "quartz", "quartzo",
    "obsidian", "obsidiana", "nether", "infernal", "end", "ender",
    "bamboo", "bambu", "bamboo", "panda", "candy", "doce"
}

local palavrasIgnorar = {
    "chest", "bau", "baú", "shop", "loja", "store", "gift", "presente",
    "reward", "recompensa", "starter", "iniciante", "pack", "pacote",
    "vip", "premium", "daily", "weekly", "bonus", "free", "gratuito",
    "news", "noticias", "index", "decor", "decoracao"
}

-- ========== FUNÇÃO PARA VERIFICAR SE É MINÉRIO ==========
local function isOre(obj)
    if not obj or not obj.Name then return false end
    
    local nome = string.lower(obj.Name)
    
    -- Verifica se é para ignorar
    for _, palavra in ipairs(palavrasIgnorar) do
        if string.find(nome, palavra) then
            return false
        end
    end
    
    -- Verifica se contém palavra de minério
    for _, palavra in ipairs(palavrasOre) do
        if string.find(nome, palavra) then
            return true
        end
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
            if isOre(obj) then
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
    
    -- Sombra
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 3, 0, 3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = frame
    
    local shadowC = Instance.new("UICorner")
    shadowC.CornerRadius = UDim.new(0, 8)
    shadowC.Parent = shadow
    
    -- Botão toggle
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0, 0, 0, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = "⛏️ Marcar Minérios: ON"
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
        toggleBtn.Text = "⛏️ Marcar Minérios: ON"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
        toggleBtn.Parent.BorderColor3 = Color3.fromRGB(255, 200, 50)
        escanearMinérios()
    else
        toggleBtn.Text = "⛏️ Marcar Minérios: OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        toggleBtn.Parent.BorderColor3 = Color3.fromRGB(150, 150, 150)
        limparTodosHighlights()
        contador.Text = "🔍 0"
    end
end

toggleBtn.MouseButton1Click:Connect(alternarHighlight)

-- ========== LOOP PRINCIPAL ==========
task.spawn(function()
    print("⛏️ Ore Highlight iniciado!")
    
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
    
    if isOre(obj) then
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
UserInputService = game:GetService("UserInputService")

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

print("✅ Ore Highlight ativado!")
print("🔹 F9 - Liga/Desliga")
print("🔹 ESC - Esconde/Mostra o botão")
print("🔹 Clique no botão para alternar")
