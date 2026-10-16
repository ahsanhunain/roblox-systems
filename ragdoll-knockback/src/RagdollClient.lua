local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RagdollConfig = require(script.Parent.RagdollConfig)

local player = Players.LocalPlayer

local RagdollClient = {}

function RagdollClient.Start()
	ReplicatedStorage:WaitForChild(RagdollConfig.RemoteName).OnClientEvent:Connect(function(on, push)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		for _, state in ipairs(RagdollConfig.BlockedStates) do
			humanoid:SetStateEnabled(state, not on)
		end
		if on then
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			for _, part in ipairs(push and character:GetChildren() or {}) do
				if part:IsA("BasePart") then
					part.AssemblyLinearVelocity = push
				end
			end
		else
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

return RagdollClient
