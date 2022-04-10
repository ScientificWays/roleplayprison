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
