-- RagdollServer
-- Ahsan Hunain

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

	-- Every change gets saved here so standing back up is just undoing them in reverse
	local undo, made = {}, {}

	local function set(obj, prop, value)
		table.insert(undo, { obj = obj, prop = prop, value = obj[prop] })
		obj[prop] = value
	end

	local function create(className, parent, props)
		local obj = Instance.new(className)
		for k, v in pairs(props) do
			obj[k] = v
		end
		obj.Parent = parent
		table.insert(made, obj)
		return obj
	end

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			-- Body hitting itself is what makes it shake on the floor
			set(part, "CollisionGroup", RagdollConfig.CollisionGroup)
			if part.Parent == character then
				set(part, "CanCollide", part ~= root)
			end

		elseif part:IsA("AnimationConstraint") then
			-- New avatar joints. They already have ball sockets so just turn these off
			set(part, "Enabled", false)

		elseif part:IsA("Motor6D") and part.Part0 and part.Part1 and part.Part1 ~= hips then
			local a0 = create("Attachment", part.Part0, { CFrame = part.C0 })
			local a1 = create("Attachment", part.Part1, { CFrame = part.C1 })
			create("BallSocketConstraint", part.Part1, {
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
		create("WeldConstraint", root, { Part0 = root, Part1 = hips })
	end

	-- Client has to do the Physics state, server can't for players
	remote:FireClient(player, true, push)

	task.delay(seconds or RagdollConfig.Seconds, function()
		for _, obj in ipairs(made) do
			obj:Destroy()
		end
		for i = #undo, 1, -1 do
			local change = undo[i]
			change.obj[change.prop] = change.value
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
