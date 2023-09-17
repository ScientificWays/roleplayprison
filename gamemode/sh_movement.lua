---- Roleplay: Prison

hook.Add("SetupMove", "EnergyMove", function(InPlayer, InMoveData, InCommandData)

	if not InPlayer:GetNWBool("bIncapped") then

		local FinalMaxSpeed = Lerp(InPlayer:GetNWFloat("EnergyValue"), 100, InMoveData:GetMaxClientSpeed())

		InMoveData:SetMaxClientSpeed(FinalMaxSpeed)
	end
end)

hook.Add("SetupMove", "HandcuffsMove", function(InPlayer, InMoveData, InCommandData)

	if not InPlayer:GetNWBool("bHandcuffed") then

		return
	end
	
	InMoveData:SetMaxClientSpeed(InMoveData:GetMaxClientSpeed() * 0.6)

	local MoveVelocty = GetHandcuffKidnappedVelocity(InPlayer, InMoveData)

	if MoveVelocty ~= nil then

		InMoveData:SetVelocity(MoveVelocty)
	end
end)

hook.Add("SetupMove", "HungerMove", function(InPlayer, InMoveData, InCommandData)

	local VelocityMul = Lerp(InPlayer:GetNWFloat("HungerValue"), 1.0, 0.5)

	InMoveData:SetMaxClientSpeed(InMoveData:GetMaxClientSpeed() * VelocityMul)
end)

hook.Add("SetupMove", "IncappedMove", function(InPlayer, InMoveData, InCommandData)

	if InPlayer:GetNWBool("bIncapped") then

		local MaxSpeed = 50.0

		InMoveData:SetMaxClientSpeed(math.min(InMoveData:GetMaxClientSpeed() * 0.25, MaxSpeed))
	end
end)

hook.Add("SetupMove", "StunMove", function(InPlayer, InMoveData, InCommandData)

	if InPlayer.StunNum ~= nil and InPlayer.StunNum > 0 then

		InMoveData:SetMaxClientSpeed(InMoveData:GetMaxClientSpeed() * 0.2)
	end
end)

hook.Add("SetupMove", "DamageMove", function(InPlayer, InMoveData, InCommandData)

	if InPlayer:GetNWFloat("DamageSlowTime") > 0.0 then

		InMoveData:SetMaxClientSpeed(InMoveData:GetMaxClientSpeed() * 0.2)
	end
end)

function GetHandcuffKidnappedVelocity(InPlayer, InMoveData)

	local Kidnapper = Entity(InPlayer:GetNWInt("KidnapperIndex"))

	if not IsValid(Kidnapper) or Kidnapper:EntIndex() == InPlayer:EntIndex() then

		return nil
	end
	
	local MoveToPos = Kidnapper:GetPos()

	local MoveDirection = (MoveToPos - InPlayer:GetPos()):GetNormal()

	local MoveFromPos = InPlayer:GetPos()
	
	local Distance = 48.0

	if MoveToPos:DistToSqr(MoveFromPos) <= 2304.0 then

		return nil
	end

	local FinalMoveToPos = MoveToPos - (MoveDirection * Distance)
	
	local xDif = math.abs(MoveFromPos.x - FinalMoveToPos.x)

	local yDif = math.abs(MoveFromPos.y - FinalMoveToPos.y)

	local zDif = math.abs(MoveFromPos.z - FinalMoveToPos.z)
	
	local speedMult = 3 + ((xDif + yDif) * 0.5)^1.01

	local vertMult = math.max((math.Max(300 - (xDif + yDif), - 10) * 0.08)^1.01 + (zDif / 2), 0)
	
	if Kidnapper:GetGroundEntity() == InPlayer then

		vertMult = -vertMult
	end
	
	local TargetVel = (FinalMoveToPos - MoveFromPos):GetNormal() * 10

	TargetVel.x = TargetVel.x * speedMult

	TargetVel.y = TargetVel.y * speedMult

	TargetVel.z = TargetVel.z * vertMult

	local MoveVelocity = InMoveData:GetVelocity()
	
	local clamp = 50

	local vclamp = 20

	local accel = 200

	local vaccel = 30 * (vertMult / 50)
	
	MoveVelocity.x = (MoveVelocity.x > TargetVel.x - clamp or MoveVelocity.x < TargetVel.x + clamp) and math.Approach(MoveVelocity.x, TargetVel.x, accel) or MoveVelocity.x

	MoveVelocity.y = (MoveVelocity.y > TargetVel.y - clamp or MoveVelocity.y < TargetVel.y + clamp) and math.Approach(MoveVelocity.y, TargetVel.y, accel) or MoveVelocity.y
	
	if MoveFromPos.z < FinalMoveToPos.z then

		MoveVelocity.z = (MoveVelocity.z > TargetVel.z - vclamp or MoveVelocity.z < TargetVel.z + vclamp) and math.Approach(MoveVelocity.z, TargetVel.z, vaccel) or MoveVelocity.z
		
		if vertMult > 0 then

			InPlayer.Cuff_ForceJump = InPlayer
		end
	end

	--MsgN(MoveVelocity)	
	return MoveVelocity
end
	