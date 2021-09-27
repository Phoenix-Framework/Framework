--[[
Made by BuilderBob25620

This script sets up the framework for the game. All the children modules are the setup for
various game systems (ex. lightsaber mechanics, communication systems, workstations).


]]--
-- Index Metatables:
local PhoenixFramework = setmetatable({}, { -- Services
	__index = function(self, service)
		local success, response = pcall(game.GetService, game, service)
		if success then
			self[service] = response
			return response
		end
	end
})

function PhoenixFramework:Initialize(addon : Instance?) : () -- Setup function
	-- Setup Shared:
	local Setup : (setup : Instance, storageContainer : any, originalSetup : Instance?)  -> ()
	Setup = function(setup : Instance, storageContainer : any, originalSetup : Instance?) : ()
		for _,child : Instance in pairs(setup:GetChildren()) do
			if not child:GetAttribute("Private") then -- If private then ignore and move on
				if child:IsA("ModuleScript") and (originalSetup or setup):GetAttribute("LoadModules") then
					local success : boolean, module = pcall(require, child)

					if success then
						local parent : {[string] : any} = storageContainer -- the storage container for the module script
						if child.Parent and child.Parent ~= (originalSetup or setup) and child.Parent:IsA("Folder") then -- Create nested table for modules grouped together inside of a folder that isn't the default Modules folder
							storageContainer[child.Parent.Name] = storageContainer[child.Parent.Name] or {}
							parent = storageContainer[child.Parent.Name]
						end

						if parent[child.Name] then
							for key : string,value in pairs(module) do
								parent[child.Name][key] = value
							end
						else
							parent[child.Name] = module
						end
					else
						warn(module)
					end

					Setup(child, storageContainer, originalSetup or setup)
				else
					storageContainer[child.Name] = child
				end
			end
		end
	end
	
	-- Shared Folder
	local Shared = script:FindFirstAncestor("Shared")
	
	-- Default Shared Core Varibles:
	PhoenixFramework.Assets = {} :: {[string] : any} -- Assets
	PhoenixFramework.Events = {} :: {[string] : any} -- Client-Server and cross-script remotes
	PhoenixFramework.Modules = {} :: {[string] : any} -- Modules
	PhoenixFramework.Services = {} :: {[string] : any} -- User-defined services
	PhoenixFramework.Game = {} :: {[string] : any} -- Game Setup & Execution
	
	-- Setup Shared Assets:
	for _,file in pairs(Shared:GetChildren()) do
		PhoenixFramework[file.Name] = {} :: {[string] : any}
		Setup(file, PhoenixFramework[file.Name])
	end
	
	-- Setup Variables
	require(script:WaitForChild("FrameworkVariables")):Initialize(addon)
	
	-- Initialized
	PhoenixFramework.Initialized = true
	print(PhoenixFramework)
end



------------------------------------------
-- Return PhoenixFramework: --------------
return PhoenixFramework
