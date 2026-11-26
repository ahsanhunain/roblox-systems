local RagdollConfig = {}

RagdollConfig.Seconds = 2.5 -- time on the ground
RagdollConfig.RemoteName = "Ragdoll"
RagdollConfig.Attribute = "Ragdolled"
RagdollConfig.CollisionGroup = "Ragdoll"
RagdollConfig.HipsPart = "LowerTorso"

-- Only used on old Motor6D rigs
RagdollConfig.SocketAngle = 70
RagdollConfig.SocketTwist = 45

RagdollConfig.BlockedStates = {
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
}

return RagdollConfig
