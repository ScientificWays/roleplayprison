---- Roleplay: Prison

AddCSLuaFile("sh_util.lua")
AddCSLuaFile("sh_craft.lua")
AddCSLuaFile("sh_stash.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_util.lua")

AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_stash.lua")
AddCSLuaFile("cl_network.lua")
AddCSLuaFile("cl_monitors.lua")
AddCSLuaFile("cl_pickrole.lua")
AddCSLuaFile("cl_schedule.lua")
AddCSLuaFile("cl_workbench.lua")
AddCSLuaFile("cl_inspection.lua")
AddCSLuaFile("cl_postprocess.lua")

include("sh_util.lua")
include("sh_craft.lua")
include("sh_stash.lua")

include("sv_util.lua")

include("sv_map.lua")
include("sv_task.lua")
include("sv_work.lua")
include("sv_voice.lua")
include("sv_cycle.lua")
include("sv_stash.lua")
include("sv_items.lua")
include("sv_player.lua")
include("sv_hunger.lua")
include("sv_energy.lua")
include("sv_officer.lua")
include("sv_skylight.lua")
include("sv_sabotage.lua")
include("sv_inspection.lua")

util.AddNetworkString("SendTryCraftItemToServer")
util.AddNetworkString("SendTryInteractStashToServer")

util.AddNetworkString("SendScheduleListToServer")
util.AddNetworkString("SendScheduleListToClients")

util.AddNetworkString("SendInspectDataToClient")

util.AddNetworkString("UpdateClientLightmaps")

util.AddNetworkString("ClientOpenScheduleSetup")
util.AddNetworkString("ClientOpenWorkbench")
util.AddNetworkString("ClientOpenStash")

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

	net.Receive("SendTryCraftItemToServer", ServerReceiveTryCraftItem)

	net.Receive("SendTryInteractStashToServer", ServerReceiveTryInteractStash)

	net.Receive("SendScheduleListToServer", ServerReceiveScheduleList)

	self.BaseClass:Initialize()
end

function GM:InitPostEntity()

	MsgN("Server post entity initializing...")

	SetupMapEntityFlags()

	SetupMapAreas()

	SetupSkyPaint()

	local WorldEntity = game.GetWorld()

	WorldEntity:SetNWBool("bInterCycle", true)

	--WorldEntity:SetNWVarProxy("ScheduleList", OnRep_CycleScheduleList)

	timer.Create("PlayerAreaUpdate", 1.0, 0, OnPlayerAreaUpdate)

	self.BaseClass:InitPostEntity()
end

--[[function GM:Tick()


end]]

--Дубинка, рация и их крафт
--Sit anywhere
--Логика для побега и перехода в режим наблюдателя

--Предмет швабра
--Система тревоги с освещением
--Задержка включения камеры
