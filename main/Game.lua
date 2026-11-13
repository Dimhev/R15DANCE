local ws = game:GetService("Workspace")
local rs = game:GetService("RunService")
local plrs = game:GetService("Players")

local lp = plrs.LocalPlayer

local gamemod = {
	nobanana = false,
	noredball = false,
	repelprops = false
}

local function setpropstouch(targetname, cantouch)
	local props = ws:FindFirstChild("Props")
	if not props then return end

	for idx, item in ipairs(props:GetChildren()) do
		if item.Name == targetname then
			if item:IsA("BasePart") then
				item.CanTouch = cantouch
			end
			for subidx, part in ipairs(item:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanTouch = cantouch
				end
			end
		end
	end
end

local function handleprop(item)
	if item.Name == "BananaPeel" and gamemod.nobanana then
		if item:IsA("BasePart") then
			item.CanTouch = false
		end
		for idx, part in ipairs(item:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanTouch = false
			end
		end
	elseif item.Name == "RedBall" and gamemod.noredball then
		if item:IsA("BasePart") then
			item.CanTouch = false
		end
		for idx, part in ipairs(item:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanTouch = false
			end
		end
	end
end

local hookedprops = nil

local function hookpropsfolder()
	local props = ws:FindFirstChild("Props")
	if props and props ~= hookedprops then
		hookedprops = props
		props.ChildAdded:Connect(function(item)
			task.wait()
			handleprop(item)
		end)
	end
end

hookpropsfolder()

ws.ChildAdded:Connect(function(child)
	if child.Name == "Props" then
		hookpropsfolder()
	end
end)

function gamemod:togglebanana(state)
	self.nobanana = state
	hookpropsfolder()
	setpropstouch("BananaPeel", not state)
end

function gamemod:toggleredball(state)
	self.noredball = state
	hookpropsfolder()
	setpropstouch("RedBall", not state)
end

function gamemod:togglerepel(state)
	self.repelprops = state
end

rs.Heartbeat:Connect(function()
	if not gamemod.repelprops then return end
	local props = ws:FindFirstChild("Props")
	if not props then return end

	local chr = lp.Character
	local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	for idx, item in ipairs(props:GetChildren()) do
		if item.Name == "BananaPeel" or item.Name == "RedBall" then
			local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
			if part and not part.Anchored then
				local dist = (part.Position - hrp.Position).Magnitude
				if dist < 25 then
					part.AssemblyLinearVelocity = Vector3.new(0, 150, 0)
					part.CFrame = part.CFrame + Vector3.new(0, 50, 0)
				end
			end
		end
	end
end)

return gamemod
