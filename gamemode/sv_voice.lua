---- Roleplay: Prison

function ToggleGlobalSpeaker(InSpeakerEntity)

	local WorldEntity = game.GetWorld()

	if WorldEntity:GetNWBool("bGlobalSpeakerEnabled") then

		WorldEntity:SetNWBool("bGlobalSpeakerEnabled", false)

		InSpeakerEntity:Input("FireUser2")
	else

		WorldEntity:SetNWBool("bGlobalSpeakerEnabled", true)

		InSpeakerEntity:Input("FireUser1")
	end
end

function GM:PlayerCanHearPlayersVoice(InListener, InTalker)

	if UtilIsGlobalSpeakerEnabled() and InTalker:GetNWBool("bGlobalSpeaker") then

		return true, false

	elseif InListener:GetNWBool("bHasTalkie") and InTalker:GetNWBool("bUsingTalkie") then

		return true, false
	else
		local bWithinDistance = InListener:GetPos():DistToSqr(InTalker:GetPos()) < 1000000

		return bWithinDistance, true
	end
end