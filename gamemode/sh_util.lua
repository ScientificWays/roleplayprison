GM.Name = "Roleplay: Prison"
GM.Author = "Albert Bagautdinov"
GM.Email = "albert.bagautdinov03@mail.ru"
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

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWBool("bOfficerPunished")
end

function UtilIsScheduleSet()

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWBool("bScheduleSet")
end

function UtilIsInterCycle()

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWBool("bInterCycle")
end

function UtilIsGlobalSpeakerEnabled()

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWBool("bGlobalSpeakerEnabled") and not UtilIsServerSabotaged()
end

function UtilIsServerSabotaged()

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWBool("bServerSabotaged")
end

function UtilIsWorkWoodBuffed()

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWBool("bWorkWoodBuffed")
end

function UtilIsWorkMetalBuffed()

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWBool("bWorkMetalBuffed")
end

function UtilGetCurrentCycleTimeSeconds()

	local WorldEntity = game.GetWorld()

	return WorldEntity:GetNWInt("CurrentCycleTimeSeconds")
end

function UtilGetLeftCycleTimeSeconds()

	local WorldEntity = game.GetWorld()

	return UtilGetCycleDurationMinutes(UtilIsInterCycle()) * 60 - WorldEntity:GetNWInt("CurrentCycleTimeSeconds")
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

function UtilPlayerCanDoAnimation(InPlayer)

	return not InPlayer:GetNWBool("bHandcuffed") and InPlayer:GetNWFloat("TaskTimeLeft") <= 0.0
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

	TEAM_STAFF = 3
	team.SetUp(TEAM_STAFF, "RPP_Role.Staff", Color(0, 255, 255))
	team.SetSpawnPoint(TEAM_STAFF, {"info_staff_start"})
	team.SetClass(TEAM_STAFF, {"player_default"})

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
