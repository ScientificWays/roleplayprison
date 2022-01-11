---- Roleplay: Prison

local OfficerVoterAndVotedList = {}

local OfficerPunishmentTimeLeft = 0

function GetOfficerPunishmentTimeLeft()

	return OfficerPunishmentTimeLeft
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

	MsgN(string.format("PunishOfficerPlayer() for %s seconds", InSeconds))

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

function AddOfficerVote(Voter, VotedName)

	if Voter:Team() ~= TEAM_GUARD then

		PrintMessage(HUD_PRINTTALK, "Только охранники могут голосовать!")

		return
	end

	local GuardPlayers = team.GetPlayers(TEAM_GUARD)

	local VoterName = Voter:GetName()

	local AdaptedVotedName = string.lower(VotedName)

	if VotedName == "лёха" then

		AdaptedVotedName = "Лёха"
	end

	for i, ply in ipairs(GuardPlayers) do

		if string.lower(ply:GetName()) == AdaptedVotedName then

			OfficerVoterAndVotedList[Voter] = ply

			local PrintVotedName = ply:GetName()

			if AdaptedVotedName == "Лёха" then

				PrintVotedName = "Лёху"
			end

			PrintMessage(HUD_PRINTTALK, string.format("%s проголосовал за %s", VoterName, PrintVotedName))

			return
		end
	end

	PrintMessage(HUD_PRINTTALK, string.format("%s не является охранником!", VotedName))

	return
end

function FinishOfficerVote()

	local OfficerPlayerVoteCount = {}

	local MostVotedPlayer = nil

	local MostVotedVoteCount = 0

	for VoterPlayer, VotedPlayer in pairs(OfficerVoterAndVotedList) do

		local VoteCount = OfficerPlayerVoteCount[VotedPlayer]

		OfficerPlayerVoteCount[VotedPlayer] = (OfficerPlayerVoteCount[VotedPlayer] or 0) + 1

		--MsgN(VoterPlayer:GetName().." for "..VotedPlayer:GetName())

		if OfficerPlayerVoteCount[VotedPlayer] > MostVotedVoteCount then

			MostVotedPlayer = VotedPlayer

			MostVotedVoteCount = OfficerPlayerVoteCount[VotedPlayer]
		end
	end

	if MostVotedPlayer then

		SetOfficerPlayer(MostVotedPlayer)

	else

		PrintMessage(HUD_PRINTTALK, "Никто не проголосовал! Выбор случайного игрока...")

		SetOfficerPlayer(table.Random(player.GetAll()))
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

	PrintMessage(HUD_PRINTTALK, string.format("Теперь %s офицер!", InPlayer:GetName()))
end
