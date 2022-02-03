---- Roleplay: Prison

function OnPlayerHandcuffsOn(InPlayer)

	MsgN(Format("%s OnPlayerHandcuffsOn()", InPlayer:GetNWString("RPName")))

	InPlayer:SetNWBool("bHandcuffed", true)

	InPlayer:SetActiveWeapon(InPlayer:GetWeapon("weapon_rpp_unarmed"))

	InPlayer:GetWeapon("weapon_rpp_unarmed"):SetHoldType("fist")
end

function OnPlayerHandcuffsOff(InPlayer)

	MsgN(Format("%s OnPlayerHandcuffsOff()", InPlayer:GetNWString("RPName")))

	InPlayer:SetNWBool("bHandcuffed", false)

	InPlayer:GetWeapon("weapon_rpp_unarmed"):SetHoldType("normal")
end

hook.Add("SetupMove", "HandcuffsMove", function(InPlayer, InMoveData, InCommandData)

	if not InPlayer:GetNWBool("bHandcuffed") then

		return
	end
	
	InMoveData:SetMaxClientSpeed(InMoveData:GetMaxClientSpeed() * 0.6)

	local Kidnapper = Entity(InPlayer:GetNWInt("KidnapperIndex"))

	if not IsValid(Kidnapper) or Kidnapper == InPlayer then

		return
	end
	
	local MoveToPos = Kidnapper:GetPos()

	local MoveDirection = (MoveToPos - InPlayer:GetPos()):GetNormal()

	local MoveFromPos = InPlayer:GetPos()
	
	local Distance = 48.0

	if MoveToPos:DistToSqr(MoveFromPos) <= 2304.0 then

		return
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

	TargetVel.x = TargetVel.x*speedMult

	TargetVel.y = TargetVel.y*speedMult

	TargetVel.z = TargetVel.z*vertMult

	local MoveVelocity = InMoveData:GetVelocity()
	
	local clamp = 50

	local vclamp = 20

	local accel = 200

	local vaccel = 30 * (vertMult / 50)
	
	MoveVelocity.x = (MoveVelocity.x > TargetVel.x - clamp or MoveVelocity.x < TargetVel.x + clamp) and math.Approach(MoveVelocity.x, TargetVel.x, accel) or MoveVelocity.x

	MoveVelocity.y = (MoveVelocity.y > TargetVel.y - clamp or MoveVelocity.y < TargetVel.y + clamp) and math.Approach(MoveVelocity.y, TargetVel.y, accel) or MoveVelocity.y
	
	if MoveFromPos.z < FinalMoveToPos.z then
		MoveVelocity.z = (MoveVelocity.z > TargetVel.z-vclamp or MoveVelocity.z < TargetVel.z + vclamp) and math.Approach(MoveVelocity.z, TargetVel.z, vaccel) or MoveVelocity.z
		
		if vertMult > 0 then InPlayer.Cuff_ForceJump = InPlayer end
	end

	--MsgN(MoveVelocity)
	
	InMoveData:SetVelocity(MoveVelocity)
	
	if SERVER
	and InMoveData:GetVelocity():Length() >= (InMoveData:GetMaxClientSpeed() * 10)
	and InPlayer:IsOnGround()
	and CurTime() > (InPlayer.Cuff_NextDragDamage or 0) then

		InPlayer:SetHealth(InPlayer:Health() - 1)

		if InPlayer:Health() <= 0 then

			InPlayer:Kill()
		end
		
		InPlayer.Cuff_NextDragDamage = CurTime() + 0.1
	end
end)