---- Roleplay: Prison

function TrySabotage(InPlayer, InTargetEntity)

	if not IsValid(InTargetEntity) then

		return
	end

	if not InTargetEntity:GetNWBool("bSabotaged") then

		InTargetEntity:Fire("FireUser1", nil, 0, InPlayer, InTargetEntity)
		InTargetEntity:SetNWBool("bSabotaged", true)
	end
end

function TryRepairSabotage(InPlayer, InTargetEntity)

	if not IsValid(InTargetEntity) then

		return
	end

	if InTargetEntity:GetNWBool("bSabotaged") then

		InTargetEntity:Fire("FireUser2", nil, 0, InPlayer, InTargetEntity)
		InTargetEntity:SetNWBool("bSabotaged", false)
	end
end
