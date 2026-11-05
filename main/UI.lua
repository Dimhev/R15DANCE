local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

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

pcall(function()
	runService:UnbindFromRenderStep("EmoteWheelBypass")
end)

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
centerButton.Modal = true
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
local isDancing = false

local function getMyRig()
	local rigsFolder = workspace:FindFirstChild("Rigs")
	if rigsFolder then
		return rigsFolder:FindFirstChild(localPlayer.Name)
	end
	return nil
end

local function setRigVisibility(visible)
	local myRig = getMyRig()
	if myRig then
		for _, part in ipairs(myRig:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.LocalTransparencyModifier = visible and 0 or 1
			end
		end
	end
end

local function restoreMouseLock()
	userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	userInputService.MouseIconEnabled = false
end

local function stopActiveEmote()
	isDancing = false
	for _, track in ipairs(activeTracks) do
		if track then
			track:Stop(0.15)
		end
	end
	table.clear(activeTracks)
	setRigVisibility(false)
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
	runOnModel(getMyRig())

	if #activeTracks > 0 then
		isDancing = true
	end
end

runService:BindToRenderStep("EmoteWheelBypass", Enum.RenderPriority.Last.Value, function()
	if wheelFrame.Visible then
		userInputService.MouseBehavior = Enum.MouseBehavior.Default
		userInputService.MouseIconEnabled = true
	end

	if isDancing then
		local stillPlaying = false
		for _, track in ipairs(activeTracks) do
			if track.IsPlaying then
				stillPlaying = true
				break
			end
		end

		if not stillPlaying then
			stopActiveEmote()
			return
		end

		setRigVisibility(true)

		local cam = workspace.CurrentCamera
		if cam then
			local startPos = cam.CFrame.Position
			local targetOffset = cam.CFrame.LookVector * -7.5
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude

			local ignoreList = {localPlayer.Character, getMyRig()}
			rayParams.FilterDescendantsInstances = ignoreList

			local result = workspace:Raycast(startPos, targetOffset, rayParams)
			if result then
				local safeDist = (result.Position - startPos).Magnitude - 0.5
				cam.CFrame = cam.CFrame + (cam.CFrame.LookVector * -math.max(0, safeDist))
			else
				cam.CFrame = cam.CFrame + targetOffset
			end
		end
	end
end)

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
			wheelFrame.Visible = false
			restoreMouseLock()
			if data.animId then
				playEmoteAnim(data.animId)
			end
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
	else
		restoreMouseLock()
	end
end

centerButton.MouseButton1Click:Connect(function()
	stopActiveEmote()
	wheelFrame.Visible = false
	restoreMouseLock()
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.N then
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
	stopActiveEmote()
	restoreMouseLock()
	pcall(function()
		runService:UnbindFromRenderStep("EmoteWheelBypass")
	end)
	screenGui:Destroy()
end

return emoteWheel
