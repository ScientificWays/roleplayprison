GM.Name = "Roleplay: Prison"
GM.Author = "zana"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = true
GM.SecondsBetweenTeamSwitches = 0

COLOR_WHITE  		= Color(255, 255, 255, 255)
COLOR_TRANSPARENT	= Color(255, 255, 255, 0)
COLOR_BLACK  		= Color(0, 0, 0, 255)

COLOR_RED    		= Color(255, 0, 0, 255)
COLOR_YELLOW 		= Color(200, 200, 0, 255)
COLOR_GREEN  		= Color(0, 255, 0, 255)
COLOR_CYAN   		= Color(0, 255, 255, 255)
COLOR_BLUE   		= Color(0, 0, 255, 255)

include("player_class/guard.lua")
include("player_class/robber.lua")
include("player_class/medic.lua")

function UtilLocalizable(InString)

	return language.GetPhrase(InString)
end

function UtilGetOfficerPlayer()

	for Index, SamplePlayer in ipairs(player.GetAll()) do

		if SamplePlayer:GetNWBool("bOfficer") then

			return SamplePlayer
		end
	end

	return nil
end

function UtilIsOfficerPunished()

	return GetGlobalBool("bOfficerPunished")
end

function UtilIsScheduleSet()

	return GetGlobalBool("bScheduleSet")
end

function UtilIsInterCycle()

	return GetGlobalBool("bInterCycle")
end

function UtilIsGlobalSpeakerEnabled()

	return GetGlobalBool("bGlobalSpeakerEnabled") and not UtilIsServerSabotaged()
end

function UtilIsServerSabotaged()

	return GetGlobalBool("bServerSabotaged")
end

function UtilIsWorkWoodBuffed()

	return GetGlobalBool("bWorkWoodBuffed")
end

function UtilIsWorkMetalBuffed()

	return GetGlobalBool("bWorkMetalBuffed")
end

function UtilGetCurrentCycleTimeSeconds()

	return GetGlobalInt("CurrentCycleTimeSeconds")
end

function UtilGetLeftCycleTimeSeconds()

	return UtilGetCycleDurationMinutes(UtilIsInterCycle()) * 60 - GetGlobalInt("CurrentCycleTimeSeconds")
end

function UtilGetCycleDurationMinutes(bInterCycle)

	if bInterCycle then

		return GetConVar("sk_intercycle_duration"):GetInt()
	else

		return GetConVar("sk_cycle_duration"):GetInt()
	end
end

function UtilGetRPNameSurname(InPlayer)

	return InPlayer:GetNWString("RPName"), InPlayer:GetNWString("RPSurname")
end

function UtilCanHearByTalkie(InListener, InTalker)

	return InListener:HasWeapon("weapon_rpp_talkie")
	and IsValid(InTalker:GetActiveWeapon()) and InTalker:GetActiveWeapon():GetClass() == "weapon_rpp_talkie"
	and InListener:GetNWFloat("TalkieFrequency") == InTalker:GetNWFloat("TalkieFrequency")
end

function UtilPlayerCanInteract(InPlayer)

	return not InPlayer:GetNWBool("bHandcuffed") and not InPlayer:GetNWBool("bIncapped") and InPlayer:GetNWFloat("TaskTimeLeft") <= 0.0
end

function GM:CreateTeams()

	TEAM_GUARD = 1
	team.SetUp(TEAM_GUARD, "RPP_Role.Guards", Color(0, 150, 255))
	team.SetSpawnPoint(TEAM_GUARD, {"info_guard_start"})
	team.SetClass(TEAM_GUARD, {"player_guard"})

	TEAM_ROBBER = 2
	team.SetUp(TEAM_ROBBER, "RPP_Role.Robbers", Color(255, 150, 0))
	team.SetSpawnPoint(TEAM_ROBBER, {"info_robber_start"})
	team.SetClass(TEAM_ROBBER, {"player_robber"})

	TEAM_MEDIC = 3
	team.SetUp(TEAM_MEDIC, "RPP_Role.Medic", Color(255, 150, 200))
	team.SetSpawnPoint(TEAM_MEDIC, {"info_staff_start"})
	team.SetClass(TEAM_MEDIC, {"player_medic"})

	team.SetUp(TEAM_SPECTATOR, "RPP_Role.Spectators", Color(255, 255, 255))
	team.SetSpawnPoint(TEAM_SPECTATOR, {"worldspawn"})
end

--[[function GM:PlayerButtonDown(ply, button)

	if button == KEY_SLASH then

		--chat.Open(1)

		ply:ChatPrint("/")
	end
end

function GM:PlayerSwitchWeapon(ply, oldWeapon, newWeapon)

	LocalLastWeaponSwitchTime = CurTime()

	MsgN("LocalLastWeaponSwitchTime")

	return false
end]]
