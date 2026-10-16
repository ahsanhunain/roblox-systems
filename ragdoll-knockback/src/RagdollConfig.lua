local RagdollConfig = {}

RagdollConfig.Seconds = 2.5
RagdollConfig.RemoteName = "Ragdoll"
RagdollConfig.Attribute = "Ragdolled"
RagdollConfig.CollisionGroup = "Ragdoll"
RagdollConfig.HipsPart = "LowerTorso"
RagdollConfig.SocketAngle = 70
RagdollConfig.SocketTwist = 45
RagdollConfig.BlockedStates = {
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
}

return RagdollConfig
