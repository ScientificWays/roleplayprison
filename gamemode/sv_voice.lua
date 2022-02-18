---- Roleplay: Prison

function ToggleGlobalSpeaker(InSpeakerEntity)

	if GetGlobalBool("bGlobalSpeakerEnabled") then

		SetGlobalBool("bGlobalSpeakerEnabled", false)

		InSpeakerEntity:Input("FireUser2")
	else

		SetGlobalBool("bGlobalSpeakerEnabled", true)

		InSpeakerEntity:Input("FireUser1")
	end
end

function UpdatePlayerSpeakerState(InPlayer)

	if UtilCheckPlayerInArea(InPlayer, ControlSpeakerArea) then

		InPlayer:SetNWBool("bGlobalSpeaker", true)
	else

		InPlayer:SetNWBool("bGlobalSpeaker", false)
	end
end

function UpdatePlayerVoiceArea(InPlayer)

	if UtilCheckPlayerInArea(InPlayer, PunishmentArea) then

		InPlayer:SetNWString("VoiceLocalArea", "LocalPunishmentArea")

	elseif UtilCheckPlayerInArea(InPlayer, Outside1Area) then

		InPlayer:SetNWString("VoiceLocalArea", "LocalOutside1Area")
	else

		InPlayer:SetNWString("VoiceLocalArea", "")
	end

	--MsgN(InPlayer:GetNWString("VoiceLocalArea"))
end

timer.Create("PlayerVoiceFilterUpdate", 0.5, 0, function()

	local AllPlayers = player.GetAll()

	for Index, SamplePlayer in ipairs(AllPlayers) do

		SamplePlayer.VoiceFilteredPlayers = {}

		local VoiceFilter = RecipientFilter()
		
		VoiceFilter:AddPVS(SamplePlayer:EyePos())

		for Index, VisiblePlayer in ipairs(VoiceFilter:GetPlayers()) do

			SamplePlayer.VoiceFilteredPlayers[VisiblePlayer:UserID()] = true
		end

		--MsgN(SamplePlayer, table.ToString(SamplePlayer.VoiceFilteredPlayers))
	end
end)

function GM:PlayerCanHearPlayersVoice(InListener, InTalker)

	if UtilIsGlobalSpeakerEnabled() and InTalker:GetNWBool("bGlobalSpeaker") then

		return true, false

	elseif UtilCanHearByTalkie(InListener, InTalker) then

		return true, false

	elseif InListener:GetNWString("VoiceLocalArea") ~= "" or InTalker:GetNWString("VoiceLocalArea") ~= "" then

		if InListener:GetNWString("VoiceLocalArea") == InTalker:GetNWString("VoiceLocalArea") then

			return true, true
		else

			local bWithinDistance = InListener:GetPos():DistToSqr(InTalker:GetPos()) < 3600

			return bWithinDistance, true
		end
	else
		--MsgN(InListener, table.ToString(InListener.VoiceFilteredPlayers))

		if InListener.VoiceFilteredPlayers and InListener.VoiceFilteredPlayers[InTalker:UserID()] then

			--MsgN("Test")

			local TraceResult = util.TraceLine({
				start = InListener:EyePos(),
				endpos = InTalker:EyePos(),
				mask = CONTENTS_SOLID
			})

			local CurrentDistance, MaxDistance = InListener:GetPos():DistToSqr(InTalker:GetPos()), 4200000

			if TraceResult.Hit then

				MaxDistance = 22500
			end

			local bWithinDistance = CurrentDistance < MaxDistance

			return bWithinDistance, true
		else

			return false, false
		end
	end
end
