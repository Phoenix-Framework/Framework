--[[
Made by BuilderBob25620

This script sets up the framework for the game. All the children modules are the setup for
various game systems (ex. lightsaber mechanics, communication systems, workstations).


]]--
local PhoenixFramework = {Initialized = false}

function PhoenixFramework:Initialize(addon : Instance?) : () -- Setup function
	-- Check:
	if PhoenixFramework.Initialized then
		return
	end

	local sharedFramework = require(game:GetService("ReplicatedStorage"):WaitForChild("PhoenixFramework").Shared.Modules.Framework)
	if not sharedFramework.Initialized then
		sharedFramework:Initialize(addon)
	end

	-- Setup Framework:
	local Setup : (setup : Instance, storageContainer : {[string] : any}, originalSetup : Instance?)  -> ()
	Setup = function(setup : Instance, storageContainer : {[string] : any}, originalSetup : Instance?) : ()
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

	-- Set Metatable:
	setmetatable(PhoenixFramework, getmetatable(sharedFramework))

	-- Server: --
	-- Folder Groups:
	PhoenixFramework.Shared = PhoenixFramework.ReplicatedStorage:WaitForChild("PhoenixFramework").Shared :: Folder
	PhoenixFramework.Server = PhoenixFramework.ServerStorage:WaitForChild("PhoenixFramework").Server :: Folder

	-- Workspace Folder:
	PhoenixFramework.WorkspaceFolder = workspace:FindFirstChild("Phoenix Workspace Folder") or Instance.new("Folder")
	PhoenixFramework.WorkspaceFolder.Name = "Phoenix Workspace Folder"
	PhoenixFramework.WorkspaceFolder.Parent = workspace
	
	-- Default Server Core Varibles:
	PhoenixFramework.Assets = {} :: {[string] : any} -- Assets
	PhoenixFramework.Events = {} :: {[string] : any} -- Client-Server and cross-script remotes
	PhoenixFramework.Modules = {} :: {[string] : any} -- Modules
	PhoenixFramework.Services = {} :: {[string] : any} -- User-defined services
	PhoenixFramework.Game = {} :: {[string] : any} -- Game Setup & Execution

	-- Setup Server Assets:
	for _,file in pairs(PhoenixFramework.Server:GetChildren()) do
		PhoenixFramework[file.Name] = (PhoenixFramework[file.Name] or {}) :: {[string] : any} -- Create or retrieve table
		Setup(file, PhoenixFramework[file.Name])
	end
	
	-- Merge Shared Assets:
	for key,member in pairs(sharedFramework) do
		if typeof(member) == "table" then
			for name,value in pairs(member) do
				if typeof(value) == "table" and PhoenixFramework[key][name] then
					for k,v in pairs(value) do
						PhoenixFramework[key][name][k] = v
					end
				else
					PhoenixFramework[key] = member
				end
			end
		elseif typeof(member) == "Instance" then
			PhoenixFramework[key] = member
		end
	end

	-- Setup Variables
	require(script:WaitForChild("FrameworkVariables")):Initialize(addon)

	-- Initialized
	PhoenixFramework.Initialized = true

	--print(sharedFramework)
end



------------------------------------------
-- Return PhoenixFramework: --------------
return PhoenixFramework
