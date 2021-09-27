local Core = {}

script:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Framework") -- yield until instances load


function Core:Initialize(addon : Instance?)
	local Client = script:WaitForChild("Client")
	local Server = script:WaitForChild("Server")
	local Shared = script:WaitForChild("Shared")
	local starterPlayer = Client:WaitForChild("StarterPlayer")
	local Directory = require(Shared.Modules.Directory)

	-- This splits up the core into its key areas
	Directory.createDirectory("ServerStorage.PhoenixFramework", {Server})
	Directory.createDirectory("ReplicatedStorage.PhoenixFramework", {Shared, Client})
	Directory.createDirectory("StarterCharacterScripts", starterPlayer.StarterCharacterScripts:GetChildren())

	-- This sets-up the Server datamodel reference (i.e. game.Nanoblox)
	local pathwayModule = Shared.Assets.PhoenixFramework:Clone()
	pathwayModule.Parent = game
	
	pathwayModule = require(pathwayModule)
	pathwayModule:Initialize(addon)

	-- It's important to call this *after* the Server has initiated
	Directory.createDirectory("StarterPlayerScripts", starterPlayer.StarterPlayerScripts:GetChildren())
end

return Core
