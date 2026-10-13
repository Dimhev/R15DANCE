local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local wheelUrl = "https://raw.githubusercontent.com/username/repo/main/wheel.lua"
local wheelModule = loadstring(game:HttpGet(wheelUrl))()

local function playCustomAudio(fileName, rawUrl)
	local audioData = nil
	if not isfile(fileName) then
		local response = request({
			Url = rawUrl,
			Method = "GET"
		})
		if response and response.Body then
			writefile(fileName, response.Body)
			audioData = response.Body
		end
	end

	local soundAsset = getcustomasset(fileName)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	local sound = Instance.new("Sound")
	sound.Name = "EmoteMusic"
	sound.SoundId = soundAsset
	sound.Volume = 1
	sound.Parent = root
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	return sound
end

local myEmotes = {
	{
		name = "California Girls",
		animId = 111281033685433,
		callback = function()
			playCustomAudio("california.mp3", "https://raw.githubusercontent.com/username/repo/main/california.mp3")
		end
	},
	{
		name = "Gangnam Style",
		animId = 118644064755644,
		callback = function()
			playCustomAudio("gangnam.mp3", "https://raw.githubusercontent.com/username/repo/main/gangnam.mp3")
		end
	}
}

wheelModule.setEmotes(myEmotes)
