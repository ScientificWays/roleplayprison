---- Roleplay: Prison

function TrySabotageServer(InPlayer, InServerEntity)

	if not IsValid(InServerEntity) then

		return
	end

	if not InServerEntity:GetNWBool("bSabotaged") then

		InServerEntity:Fire("FireUser1", nil, 0, InPlayer, InServerEntity)

		InServerEntity:SetNWBool("bSabotaged", true)

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bServerSabotaged", true)
	end
end

function TryRepairServer(InPlayer, InServerEntity)

	if not IsValid(InServerEntity) then

		return
	end

	if InServerEntity:GetNWBool("bSabotaged") then

		InServerEntity:Fire("FireUser2", nil, 0, InPlayer, InServerEntity)

		InServerEntity:SetNWBool("bSabotaged", false)

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bServerSabotaged", false)
	end
end
