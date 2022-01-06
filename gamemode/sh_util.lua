GM.Name = "Roleplay: Prison"
GM.Author = "Albert Bagautdinov"
GM.Email = "albert.bagautdinov03@mail.ru"
GM.Website = "N/A"
GM.TeamBased = true

COLOR_WHITE  = Color(255, 255, 255, 255)
COLOR_BLACK  = Color(0, 0, 0, 255)

COLOR_RED    = Color(255, 0, 0, 255)
COLOR_YELLOW = Color(200, 200, 0, 255)
COLOR_GREEN  = Color(0, 255, 0, 255)
COLOR_CYAN   = Color(0, 255, 255, 255)
COLOR_BLUE   = Color(0, 0, 255, 255)

include("player_class/guard.lua")
include("player_class/robber.lua")

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

function GM:CreateTeams()

	TEAM_GUARD = 1
	team.SetUp(TEAM_GUARD, "Охранники", Color(0, 0, 255))
	team.SetSpawnPoint(TEAM_GUARD, {"info_guard_start"})
	team.SetClass(TEAM_GUARD, {"player_guard"})

	TEAM_ROBBER = 2
	team.SetUp(TEAM_ROBBER, "Заключенные", Color(255, 255, 0))
	team.SetSpawnPoint(TEAM_ROBBER, {"info_robber_start"})
	team.SetClass(TEAM_ROBBER, {"player_robber"})

	TEAM_STAFF = 3
	team.SetUp(TEAM_STAFF, "Обслуживающий персонал", Color(0, 255, 255))
	team.SetSpawnPoint(TEAM_STAFF, {"info_staff_start"})
	team.SetClass(TEAM_STAFF, {"player_default"})

	team.SetUp(TEAM_SPECTATOR, "Наблюдение", Color(255, 255, 255))
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
