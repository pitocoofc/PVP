local Players = game.Players
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

---------------------------------------------------------
-- BOTÃO SEGUIR ALVO
---------------------------------------------------------
local followBtn = Instance.new("TextButton", gui)
followBtn.Size = UDim2.new(0,150,0,45)
followBtn.Position = UDim2.new(0,10,0,10)
followBtn.Text = "Seguir Alvo"
followBtn.BackgroundColor3 = Color3.fromRGB(60,120,60)
followBtn.TextScaled = true

---------------------------------------------------------
-- INPUT PARA NOME DO ALVO
---------------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,250,0,140)
frame.Position = UDim2.new(0.5,-125,0.5,-70)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Visible = false

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0,220,0,40)
box.Position = UDim2.new(0,15,0,10)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true

local confirm = Instance.new("TextButton", frame)
confirm.Size = UDim2.new(0,220,0,40)
confirm.Position = UDim2.new(0,15,0,75)
confirm.Text = "Seguir"
confirm.TextScaled = true
confirm.BackgroundColor3 = Color3.fromRGB(40,80,200)

---------------------------------------------------------
-- VARIÁVEIS DO SISTEMA
---------------------------------------------------------
local seguindo = false
local nomeAlvo = ""
local alvoModel = nil

followBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

---------------------------------------------------------
-- FUNÇÃO: ACHAR PLAYER OU NPC
---------------------------------------------------------
local function encontrarAlvo(nome)
	-- 1: procurar player
	local plr = Players:FindFirstChild(nome)
	if plr and plr.Character then return plr.Character end

	-- 2: procurar NPC (model com humanoid)
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name == nome and obj:FindFirstChild("Humanoid") then
			return obj
		end
	end

	return nil
end

---------------------------------------------------------
-- CONFIRMAR O ALVO
---------------------------------------------------------
confirm.MouseButton1Click:Connect(function()
	nomeAlvo = box.Text
	frame.Visible = false
	box.Text = ""

	if nomeAlvo == "" then return end

	alvoModel = encontrarAlvo(nomeAlvo)
	seguindo = true
end)

---------------------------------------------------------
-- LOOP DO SEGUIR
---------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(0.1)

		if seguindo then
			if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
				continue
			end

			-- tentar reencontrar se sumiu
			if not alvoModel or not alvoModel:FindFirstChild("HumanoidRootPart") then
				alvoModel = encontrarAlvo(nomeAlvo)
			end

			if alvoModel then
				local hrp = player.Character.HumanoidRootPart
				local target = alvoModel:FindFirstChild("HumanoidRootPart")

				if target then
					hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(target.Position), 0.18)
				end
			end
		end
	end
end)

---------------------------------------------------------
-- AUTO HIT / AUTO CLICK
---------------------------------------------------------
local autoHit = true       -- ligado sempre
local hitRange = 8
local hitDelay = 0.15

task.spawn(function()
	while true do
		task.wait(hitDelay)

		if autoHit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart

			-- AUTO HIT NO ALVO SEGUINDO
			if seguindo and alvoModel and alvoModel:FindFirstChild("Humanoid") then
				local hum = alvoModel.Humanoid
				local targetHRP = alvoModel:FindFirstChild("HumanoidRootPart")

				if targetHRP then
					local dist = (hrp.Position - targetHRP.Position).Magnitude
					if dist <= hitRange then
						hum:TakeDamage(10)
					end
				end

			-- AUTO CLICK (golpes no ar)
			else
				local hum = player.Character:FindFirstChild("Humanoid")
				if hum then
					hum:LoadAnimation(Instance.new("Animation")):Play()
				end
			end
		end
	end
end)
