local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local targetParent = playerGui

pcall(function()
	if coreGui then
		targetParent = coreGui
	end
end)

local existingGui = targetParent:FindFirstChild("EmoteWheelGui")
if existingGui then
	existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteWheelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetParent

local wheelFrame = Instance.new("Frame")
wheelFrame.Name = "WheelFrame"
wheelFrame.Size = UDim2.new(0, 360, 0, 360)
wheelFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
wheelFrame.AnchorPoint = Vector2.new(0.5, 0.5)
wheelFrame.BackgroundTransparency = 1
wheelFrame.Visible = false
wheelFrame.Parent = screenGui

local centerButton = Instance.new("TextButton")
centerButton.Name = "CenterButton"
centerButton.Size = UDim2.new(0, 80, 0, 80)
centerButton.Position = UDim2.new(0.5, 0, 0.5, 0)
centerButton.AnchorPoint = Vector2.new(0.5, 0.5)
centerButton.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
centerButton.TextColor3 = Color3.fromRGB(230, 230, 230)
centerButton.TextSize = 13
centerButton.Font = Enum.Font.GothamBold
centerButton.Text = "Stop"
centerButton.AutoButtonColor = false
centerButton.Parent = wheelFrame

local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = centerButton

local centerStroke = Instance.new("UIStroke")
centerStroke.Color = Color3.fromRGB(55, 55, 70)
centerStroke.Thickness = 2
centerStroke.Parent = centerButton

local emoteWheel = {}
local activeTracks = {} 

local function stopActiveEmote()
	for _, track in ipairs(activeTracks) do
		if track then
			track:Stop(0.15)
		end
	end
	table.clear(activeTracks)
end

local function playEmoteAnim(animId)
	stopActiveEmote()
	
	local fullId = string.find(tostring(animId), "rbxassetid://") and tostring(animId) or ("rbxassetid://" .. tostring(animId))
	local anim = Instance.new("Animation")
	anim.AnimationId = fullId

	local function runOnModel(model)
		if not model then return end
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		
		if animator then
			local success, track = pcall(function()
				return animator:LoadAnimation(anim)
			end)
			
			if success and track then
				track.Priority = Enum.AnimationPriority.Action4
				track:Play(0.1)
				table.insert(activeTracks, track)
			end
		end
	end

	runOnModel(localPlayer.Character)

	local rigsFolder = workspace:FindFirstChild("Rigs")
	if rigsFolder then
		local myRig = rigsFolder:FindFirstChild(localPlayer.Name)
		if myRig then
			runOnModel(myRig)
		end
	end
end

local function clearWheel()
	for index, child in ipairs(wheelFrame:GetChildren()) do
		if child.Name == "EmoteSlot" then
			child:Destroy()
		end
	end
end

local function renderSlots(emotesList)
	clearWheel()
	local totalSlots = #emotesList
	if totalSlots == 0 then return end

	local radius = 135
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for index, data in ipairs(emotesList) do
		local angle = ((index - 1) / totalSlots) * math.pi * 2 - (math.pi / 2)
		local posX = math.cos(angle) * radius
		local posY = math.sin(angle) * radius

		local slot = Instance.new("TextButton")
		slot.Name = "EmoteSlot"
		slot.Size = UDim2.new(0, 110, 0, 42)
		slot.Position = UDim2.new(0.5, posX, 0.5, posY)
		slot.AnchorPoint = Vector2.new(0.5, 0.5)
		slot.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		slot.TextColor3 = Color3.fromRGB(240, 240, 245)
		slot.Text = data.name or ("Slot " .. tostring(index))
		slot.Font = Enum.Font.GothamMedium
		slot.TextSize = 12
		slot.AutoButtonColor = false
		slot.Parent = wheelFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = slot

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(55, 55, 70)
		stroke.Thickness = 1.5
		stroke.Parent = slot

		slot.MouseEnter:Connect(function()
			tweenService:Create(slot, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(65, 70, 95),
				Size = UDim2.new(0, 116, 0, 46)
			}):Play()
			tweenService:Create(stroke, tweenInfo, {
				Color = Color3.fromRGB(130, 140, 190)
			}):Play()
		end)

		slot.MouseLeave:Connect(function()
			tweenService:Create(slot, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(30, 30, 38),
				Size = UDim2.new(0, 110, 0, 42)
			}):Play()
			tweenService:Create(stroke, tweenInfo, {
				Color = Color3.fromRGB(55, 55, 70)
			}):Play()
		end)

		slot.MouseButton1Click:Connect(function()
			if data.animId then
				playEmoteAnim(data.animId)
			end
			wheelFrame.Visible = false
		end)
	end
end

local function toggleWheel()
	wheelFrame.Visible = not wheelFrame.Visible
	if wheelFrame.Visible then
		wheelFrame.Size = UDim2.new(0, 280, 0, 280)
		tweenService:Create(wheelFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 360, 0, 360)
		}):Play()
	end
end

centerButton.MouseButton1Click:Connect(function()
	stopActiveEmote()
	wheelFrame.Visible = false
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Space then
		stopActiveEmote()
	end
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.G then
		toggleWheel()
	end
end)

function emoteWheel.setEmotes(newList)
	renderSlots(newList)
end

function emoteWheel.toggle()
	toggleWheel()
end

function emoteWheel.stop()
	stopActiveEmote()
end

function emoteWheel.destroy()
	screenGui:Destroy()
end

return emoteWheel
