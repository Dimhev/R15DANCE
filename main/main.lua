local uiUrl = "https://raw.githubusercontent.com/Dimhev/R15DANCE/refs/heads/main/main/UI.lua"
local wheel = loadstring(game:HttpGet(uiUrl))()

local danceList = {
	{
		name = "California Girls",
		animId = 111281033685433
	},
	{
		name = "Gangnam Style",
		animId = 118644064755644
	},
	{
		name = "Thanos Shuffle",
		animId = 123176416564243
	},
	{
		name = "Tenna Dance",
		animId = 115605836623904
	},
		{
		name = "how did he hit every beat",
		animId = 136095999219650
	}
}

wheel.setEmotes(danceList)
