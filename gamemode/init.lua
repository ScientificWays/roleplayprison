---- Roleplay: Prison

AddCSLuaFile("sh_util.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_util.lua")
AddCSLuaFile("cl_monitors.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_pickrole.lua")
AddCSLuaFile("cl_schedule.lua")
AddCSLuaFile("cl_network.lua")

include("sh_util.lua")
include("sv_util.lua")
include("sv_map.lua")
include("sv_cycle.lua")
include("sv_player.lua")
include("sv_officer.lua")
include("sv_task.lua")

util.AddNetworkString("SendScheduleListToServer")
util.AddNetworkString("SendScheduleListToClients")

--CreateClientConVar("schedulesetup", "0")

function GM:Initialize()

	MsgN("Roleplay: Prison gamemode initializing...")

	--GAMEMODE.round_state = ROUND_WAIT

	--concommand.Add("schedulesetup", ToggleScheduleSetup)

	net.Receive("SendScheduleListToServer", ServerReceiveScheduleList)

	self.BaseClass:Initialize()
end

function GM:InitPostEntity()

	MsgN("Server post entity initializing...")

	SetupMapLockables()

	SetupMapUsables()

	SetupMapRoutines()

	SetupMapMonitorAreas()

	local WorldEntity = game.GetWorld()

	WorldEntity:SetNWBool("bInterCycle", true)

	--WorldEntity:SetNWVarProxy("ScheduleList", OnRep_CycleScheduleList)

	self.BaseClass:InitPostEntity()
end

function GM:Tick()

	if engine.TickCount() % 60 ~= 0 then

		return
	end

	for Index, SamplePlayer in ipairs(player.GetAll()) do

		UpdatePlayerMonitorType(SamplePlayer)
	end
end

--Дальность слышимости
--Система тревоги с освещением
--Ловушки и освещение в вентиляции
--Бафф на скорость работы если охранник в комнате
--Громкоговоритель на всю тюрьму и локальный на улице
--Отмычки ломаются с шансом 90%, дверь открывается с шансом 90%
