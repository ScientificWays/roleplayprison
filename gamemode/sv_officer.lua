---- Roleplay: Prison

local OfficerVoterAndVotedList = {}

function SetOfficerPunishmentTimeLeft(InValue)

	SetGlobalInt("OfficerPunishmentTimeLeft", InValue)
end

function HandleOfficerOnIntercycleStart()

	if UtilIsOfficerPunished() then

		SetGlobalInt("OfficerPunishmentTimeLeft", math.Clamp(GetGlobalInt("OfficerPunishmentTimeLeft"), 0, UtilGetCycleDurationMinutes(true) * 20))
	end
end

function DecreaseOfficerPunishmentTimeLeft()

	SetGlobalInt("OfficerPunishmentTimeLeft", GetGlobalInt("OfficerPunishmentTimeLeft") - 1)
end

function GetOfficerPunishMinDurationSeconds()

	return GetConVar("sk_officerpunish_min_duration"):GetInt()
end

function GetOfficerPunishMaxDurationSeconds()

	return GetConVar("sk_officerpunish_max_duration"):GetInt()
end

function PunishOfficerPlayer(InSeconds)

	MsgN(Format("PunishOfficerPlayer() for %s seconds", InSeconds))

	local OfficerPlayer = UtilGetOfficerPlayer()

	local TeleportTarget = table.Random(ents.FindByName("OfficerPunishment_Teleport"))

	OfficerPlayer:ScreenFade(SCREENFADE.OUT, COLOR_WHITE, 2.0, 2.0)

	OfficerPlayer:SetRenderFX(kRenderFxDistort)

	OfficerPlayer:SetRenderMode(RENDERMODE_TRANSCOLOR)

	if IsValid(TeleportTarget) then

		timer.Simple(2.0, function()
		
			OfficerPlayer:ScreenFade(SCREENFADE.IN, COLOR_WHITE, 2.0, 0.0)

			OfficerPlayer:SetPos(TeleportTarget:GetPos())

			OfficerPlayer:SetRenderMode(RENDERMODE_NORMAL)

			OfficerPlayer:SetRenderFX(kRenderFxNone)
		end)

		SetGlobalInt("OfficerPunishmentTimeLeft", InSeconds)
	end
end

function ReleaseOfficerPlayer()

	MsgN("ReleaseOfficerPlayer()")

	local OfficerPlayer = UtilGetOfficerPlayer()

	local TeleportTarget = table.Random(ents.FindByName("Floor2_Officer_Teleport"))

	if IsValid(TeleportTarget) then

		MsgN("ReleaseOfficerPlayer() success")

		local WeaponUnarmed = OfficerPlayer:GetWeapon("weapon_rpp_unarmed")

		if IsValid(WeaponUnarmed) then

			OfficerPlayer:SetActiveWeapon(WeaponUnarmed)
		end

		OfficerPlayer:ScreenFade(SCREENFADE.OUT, COLOR_WHITE, 2.0, 2.0)

		timer.Simple(2.0, function()
		
			OfficerPlayer:ScreenFade(SCREENFADE.IN, COLOR_WHITE, 2.0, 0.0)

			OfficerPlayer:SetPos(TeleportTarget:GetPos())
		end)

		SetGlobalInt("OfficerPunishmentTimeLeft", 0)
	else

		MsgN("ReleaseOfficerPlayer() TeleportTarget is invalid!")
	end
end

function AddOfficerVote(InVoter, InVotedName)

	if InVoter:Team() ~= TEAM_GUARD then

		UtilSendEventMessageToPlayers({"RPP_RPEvent.VoteOnlyGuards"})

		return
	end

	local VotedPlayer = UtilGetPlayerByRPName(InVotedName)

	local VoterName = InVoter:GetNWString("RPName")

	if IsValid(VotedPlayer) and VotedPlayer:Team() == TEAM_GUARD then

		OfficerVoterAndVotedList[InVoter] = VotedPlayer

		UtilSendEventMessageToPlayers({"RPP_RPEvent.VoteInfo", VoterName, InVotedName})

		return
	end

	UtilSendEventMessageToPlayers({"RPP_RPEvent.VoteDeny", InVotedName})

	return
end

function FinishOfficerVote(InSender)

	if IsValid(InSender) and InSender:Team() ~= TEAM_GUARD then

		UtilSendEventMessageToPlayers({"RPP_RPEvent.VoteOnlyGuards"})

		return
	end

	local OfficerPlayerVoteCount = {}

	local MostVotedPlayer = nil

	local MostVotedVoteCount = 0

	for VoterPlayer, VotedPlayer in pairs(OfficerVoterAndVotedList) do

		local VoteCount = OfficerPlayerVoteCount[VotedPlayer]

		OfficerPlayerVoteCount[VotedPlayer] = (OfficerPlayerVoteCount[VotedPlayer] or 0) + 1

		--MsgN(VoterPlayer:GetNWString("RPName").." for "..VotedPlayer:GetNWString("RPName"))

		if OfficerPlayerVoteCount[VotedPlayer] > MostVotedVoteCount then

			MostVotedPlayer = VotedPlayer

			MostVotedVoteCount = OfficerPlayerVoteCount[VotedPlayer]
		end
	end

	if MostVotedPlayer then

		SetOfficerPlayer(MostVotedPlayer)

	else

		UtilSendEventMessageToPlayers({"RPP_RPEvent.NoVotes"})

		SetOfficerPlayer(table.Random(team.GetPlayers(TEAM_GUARD)))
	end

	table.Empty(OfficerVoterAndVotedList)
end

function SetOfficerPlayer(InPlayer)

	if InPlayer:Team() ~= TEAM_GUARD then

		UtilSendEventMessageToPlayers({"RPP_RPEvent.VoteError"})

		return
	end

	for Index, SamplePlayer in ipairs(player.GetAll()) do

		SamplePlayer:SetNWBool("bOfficer", false)
	end

	InPlayer:SetNWBool("bOfficer", true)

	UtilSendEventMessageToPlayers({"RPP_RPEvent.VoteSuccess", UtilGetRPNameSurname(InPlayer)})
end
