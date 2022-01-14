---- Roleplay: Prison

AddCSLuaFile("sh_util.lua")
AddCSLuaFile("cl_init.lua")

AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_util.lua")
AddCSLuaFile("cl_network.lua")
AddCSLuaFile("cl_monitors.lua")
AddCSLuaFile("cl_pickrole.lua")
AddCSLuaFile("cl_schedule.lua")

include("sh_util.lua")
include("sv_util.lua")

include("sv_map.lua")
include("sv_task.lua")
include("sv_work.lua")
include("sv_voice.lua")
include("sv_cycle.lua")
include("sv_player.lua")
include("sv_officer.lua")
include("sv_sabotage.lua")

util.AddNetworkString("SendScheduleListToServer")
util.AddNetworkString("SendScheduleListToClients")

util.AddNetworkString("UpdateClientLightmaps")

function OnPlayerAreaUpdate()

	for Index, SamplePlayer in ipairs(player.GetAll()) do

		UpdatePlayerMonitorType(SamplePlayer)

		UpdatePlayerSpeakerState(SamplePlayer)

		UpdatePlayerVoiceArea(SamplePlayer)
	end

	UpdateWorkAreasState()
end

function GM:Initialize()

	MsgN("Roleplay: Prison gamemode initializing...")

	--GAMEMODE.round_state = ROUND_WAIT

	--concommand.Add("schedulesetup", ToggleScheduleSetup)

	net.Receive("SendScheduleListToServer", ServerReceiveScheduleList)

	self.BaseClass:Initialize()
end

function GM:InitPostEntity()

	MsgN("Server post entity initializing...")

	SetupMapEntityFlags()

	SetupMapAreas()

	SetColorCorrectionEntities()

	local WorldEntity = game.GetWorld()

	WorldEntity:SetNWBool("bInterCycle", true)

	--WorldEntity:SetNWVarProxy("ScheduleList", OnRep_CycleScheduleList)

	timer.Create("PlayerAreaUpdate", 1.0, 0, OnPlayerAreaUpdate)

	self.BaseClass:InitPostEntity()
end

--[[function GM:Tick()


end]]

--Интерфейс крафта, крафт отмычек
--Интерфейс вместо монитора
--Дубинка, рация и их крафт
--Заначки и досмотр
--Логика для побега и перехода в режим наблюдателя

--Предмет швабра
--Система выносливости и замедления от повреждений
--Система голода
--Система тревоги с освещением
--Задержка включения камеры
