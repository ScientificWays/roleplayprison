---- Roleplay: Prison

local OfficerVoterAndVotedList = {}

local OfficerPunishmentTimeLeft = 0

function GetOfficerPunishmentTimeLeft()

	return OfficerPunishmentTimeLeft
end

function HandleOfficerOnIntercycleStart()

	if UtilIsOfficerPunished() then

		OfficerPunishmentTimeLeft = math.Clamp(OfficerPunishmentTimeLeft, 0, UtilGetCycleDurationMinutes(true) * 30)
	end
end

function DecreaseOfficerPunishmentTimeLeft()

	OfficerPunishmentTimeLeft = OfficerPunishmentTimeLeft - 1
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

	if IsValid(TeleportTarget) then

		OfficerPlayer:SetPos(TeleportTarget:GetPos())

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bOfficerPunished", true)

		OfficerPunishmentTimeLeft = InSeconds
	end
end

function ReleaseOfficerPlayer()

	local OfficerPlayer = UtilGetOfficerPlayer()

	local TeleportTarget = table.Random(ents.FindByName("Floor2_Officer_Teleport"))

	if IsValid(TeleportTarget) then

		OfficerPlayer:SetPos(TeleportTarget:GetPos())

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bOfficerPunished", false)

		OfficerPunishmentTimeLeft = 0
	end
end

function AddOfficerVote(InVoter, InVotedName)

	if InVoter:Team() ~= TEAM_GUARD then

		PrintMessage(HUD_PRINTTALK, "Только охранники могут голосовать!")

		return
	end

	local VotedPlayer = UtilGetPlayerByRPName(InVotedName)

	local VoterName = InVoter:GetNWString("RPName")

	if IsValid(VotedPlayer) and VotedPlayer:Team() == TEAM_GUARD then

		OfficerVoterAndVotedList[InVoter] = VotedPlayer

		PrintMessage(HUD_PRINTTALK, Format("%s хочет, чтобы %s был офицером.", VoterName, InVotedName))

		return
	end

	PrintMessage(HUD_PRINTTALK, Format("%s не является охранником!", InVotedName))

	return
end

function FinishOfficerVote()

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

		PrintMessage(HUD_PRINTTALK, "Никто не проголосовал! Выбор случайного игрока...")

		SetOfficerPlayer(table.Random(team.GetPlayers(TEAM_GUARD)))
	end

	table.Empty(OfficerVoterAndVotedList)
end

function SetOfficerPlayer(InPlayer)

	if InPlayer:Team() ~= TEAM_GUARD then

		PrintMessage(HUD_PRINTTALK, "Попытка сделать офицером не охранника! Отмена...")

		return
	end

	for Index, SamplePlayer in ipairs(player.GetAll()) do

		SamplePlayer:SetNWBool("bOfficer", false)
	end

	InPlayer:SetNWBool("bOfficer", true)

	PrintMessage(HUD_PRINTTALK, Format("Теперь %s %s офицер!", InPlayer:GetNWString("RPName"), InPlayer:GetNWString("RPSurname")))
end
