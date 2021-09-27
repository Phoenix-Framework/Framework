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
	
	-- Combine Assets:
	local Setup : (setup : Instance, storageContainer : any, originalSetup : Instance?)  -> ()
	Setup = function(setup : Instance, storageContainer : any, originalSetup : Instance?) : ()
		for _,child : Instance in pairs(setup:GetChildren()) do
			if not child:GetAttribute("Private") then -- If private then ignore and move on
				if child:IsA("ModuleScript") and (child:FindFirstAncestor("Modules") and child:FindFirstAncestor("Modules"):IsA("Folder")) then
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
				elseif child:IsA("ModuleScript") and (child:FindFirstAncestor("Services") and child:FindFirstAncestor("Services"):IsA("Folder")) then
					
				elseif child.Parent and (child.Parent.Name == "Assets" or child.Parent.Name == "Events") and child.Parent:IsA("Folder") then
					child:Clone().Parent = storageContainer
				end
			end
		end
	end
	
	-- Set Metatable:
	setmetatable(PhoenixFramework, getmetatable(loader))
	
	-- Combine:

	-- Server:
	if PhoenixFramework.RunService:IsServer() then
		-- Folder Groups:
		PhoenixFramework.Shared = PhoenixFramework.ReplicatedStorage:WaitForChild("PhoenixFramework").Shared
		PhoenixFramework.Server = PhoenixFramework.ServerStorage:WaitForChild("PhoenixFramework").Server
		PhoenixFramework.Client = PhoenixFramework.ReplicatedStorage:WaitForChild("PhoenixFramework").Client

		-- Workspace Folder:
		PhoenixFramework.WorkspaceFolder = workspace:FindFirstChild("Phoenix Workspace Folder") or Instance.new("Folder")
		PhoenixFramework.WorkspaceFolder.Name = "Phoenix Workspace Folder"
		PhoenixFramework.WorkspaceFolder.Parent = workspace

		-- Server Core Varibles:
		PhoenixFramework.Events = PhoenixFramework.Server.Events
		PhoenixFramework.Assets = PhoenixFramework.Server.Assets
		
		-- Setup Server:
		Setup(PhoenixFramework.Shared.Events, PhoenixFramework.Events)
		Setup(PhoenixFramework.Shared.Assets, PhoenixFramework.Assets)
		Setup(PhoenixFramework.Server.Modules, PhoenixFramework.Modules)
		Setup(PhoenixFramework.Shared.Modules, PhoenixFramework.Modules)
		
		PhoenixFramework.Client.Parent = PhoenixFramework.ReplicatedStorage
		PhoenixFramework.Shared.Parent = PhoenixFramework.ReplicatedStorage
		PhoenixFramework.mainModule.Parent = PhoenixFramework.ServerScriptService
	elseif PhoenixFramework.RunService:IsClient() then -- Client: 
		-- Client Folder:
		PhoenixFramework.Client = PhoenixFramework.ReplicatedStorage:WaitForChild("PhoenixFrameworkClient") :: Folder

		-- Workspace Folder:
		PhoenixFramework.WorkspaceFolder = workspace:WaitForChild("Phoenix Workspace Folder", 5) or Instance.new("Folder")
		PhoenixFramework.WorkspaceFolder.Name = "Phoenix Workspace Folder"
		PhoenixFramework.WorkspaceFolder.Parent = workspace

		-- Client Core Variables
		PhoenixFramework.Player = PhoenixFramework.Players.LocalPlayer :: Player
		PhoenixFramework.PlayerGui = PhoenixFramework.Player:WaitForChild("PlayerGui") :: PlayerGui
		PhoenixFramework.Camera = workspace.CurrentCamera :: Camera
		PhoenixFramework.PhoenixGui = PhoenixFramework.PlayerGui:WaitForChild("PhoenixGui") :: ScreenGui
		PhoenixFramework.Assets = PhoenixFramework.Client.Assets :: Folder
		PhoenixFramework.MainFrame = PhoenixFramework.PhoenixGui.MainFrame :: Frame
		PhoenixFramework.Events = PhoenixFramework.Client.Events :: Folder
		
		-- Setup Client
		Setup(PhoenixFramework.Shared.Events, PhoenixFramework.Events)
		Setup(PhoenixFramework.Shared.Assets, PhoenixFramework.Assets)
		Setup(PhoenixFramework.Client.Modules, PhoenixFramework.Modules)
		Setup(PhoenixFramework.Shared.Modules, PhoenixFramework.Modules)
	end
	
	-- Setup Variables
	require(script:WaitForChild("FrameworkVariables")):Initialize(addon)
	
	-- Initialized
	PhoenixFramework.Initialized = true
end



------------------------------------------
-- Return PhoenixFramework: --------------
return PhoenixFramework
