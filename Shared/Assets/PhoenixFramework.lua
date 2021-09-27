local RunService = game:GetService("RunService")

local framework
if RunService:IsServer() then
	local phoenix = game:GetService("ServerStorage"):WaitForChild("PhoenixFramework")
	framework = require(phoenix.Server.Modules.Framework)
elseif RunService:IsClient() then -- redundant but better safe than sorry
	local phoenix = game:GetService("ReplicatedStorage"):WaitForChild("PhoenixFramework")
	framework = require(phoenix.Client.Modules.Framework)
end

return framework
