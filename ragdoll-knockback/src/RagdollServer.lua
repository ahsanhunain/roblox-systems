local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local RagdollConfig = require(script.Parent.RagdollConfig)

local RagdollServer = {}

local remote

function RagdollServer.Ragdoll(player, push, seconds)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local hips = character and character:FindFirstChild(RagdollConfig.HipsPart)
	if not humanoid or not root or humanoid.Health <= 0 or character:GetAttribute(RagdollConfig.Attribute) then
		return false
	end
	character:SetAttribute(RagdollConfig.Attribute, true)
	local undo, made = {}, {}
	local function set(item, property, value)
		table.insert(undo, { item = item, property = property, value = item[property] })
		item[property] = value
	end
	local function make(className, parent, props)
		local item = Instance.new(className)
		for key, value in pairs(props) do
			item[key] = value
		end
		item.Parent = parent
		table.insert(made, item)
		return item
	end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			set(part, "CollisionGroup", RagdollConfig.CollisionGroup)
			if part.Parent == character then
				set(part, "CanCollide", part ~= root)
			end
		elseif part:IsA("AnimationConstraint") then
			set(part, "Enabled", false)
		elseif part:IsA("Motor6D") and part.Part0 and part.Part1 and part.Part1 ~= hips then
			local a0 = make("Attachment", part.Part0, { CFrame = part.C0 })
			local a1 = make("Attachment", part.Part1, { CFrame = part.C1 })
			make("BallSocketConstraint", part.Part1, {
				Attachment0 = a0,
				Attachment1 = a1,
				LimitsEnabled = true,
				TwistLimitsEnabled = true,
				UpperAngle = RagdollConfig.SocketAngle,
				TwistLowerAngle = -RagdollConfig.SocketTwist,
				TwistUpperAngle = RagdollConfig.SocketTwist,
			})
			set(part, "Enabled", false)
		end
	end
	if hips then
		make("WeldConstraint", root, { Part0 = root, Part1 = hips })
	end
	remote:FireClient(player, true, push)
	task.delay(seconds or RagdollConfig.Seconds, function()
		for _, item in ipairs(made) do
			item:Destroy()
		end
		for index = #undo, 1, -1 do
			local entry = undo[index]
			entry.item[entry.property] = entry.value
		end
		if character.Parent then
			character:SetAttribute(RagdollConfig.Attribute, nil)
			remote:FireClient(player, false)
		end
	end)
	return true
end

function RagdollServer.Start()
	remote = ReplicatedStorage:FindFirstChild(RagdollConfig.RemoteName) or Instance.new("RemoteEvent")
	remote.Name = RagdollConfig.RemoteName
	remote.Parent = ReplicatedStorage
	PhysicsService:RegisterCollisionGroup(RagdollConfig.CollisionGroup)
	PhysicsService:CollisionGroupSetCollidable(RagdollConfig.CollisionGroup, RagdollConfig.CollisionGroup, false)
end

return RagdollServer
