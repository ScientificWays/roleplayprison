---- Roleplay: Prison

include("sh_util.lua")
include("sh_craft.lua")
include("sh_stash.lua")

include("cl_util.lua")

include("cl_hud.lua")
include("cl_stash.lua")
include("cl_voice.lua")
include("cl_network.lua")
include("cl_pickrole.lua")
include("cl_schedule.lua")
include("cl_monitors.lua")
include("cl_workbench.lua")
include("cl_inspection.lua")
include("cl_animations.lua")
include("cl_postprocess.lua")

--Sit anywhere
include("sitanywhere/helpers.lua")
include("sitanywhere/client/sit.lua")
include("sitanywhere/ground_sit.lua")
--Sit anywhere

surface.CreateFont("MonitorText", {font = "Tahoma",
									size = 28,
									weight = 900})
surface.CreateFont("MonitorTextSmall", {font = "Tahoma",
									size = 18,
									weight = 900})
surface.CreateFont("HUDText", {font = "Tahoma",
									size = 32,
									weight = 800})
surface.CreateFont("HUDTextSmall", {font = "Tahoma",
									size = 18,
									weight = 700})

function GM:Initialize()

	MsgN("RPP Client initializing...")

	--GAMEMODE.round_state = ROUND_WAIT

	--concommand.Add("schedulesetup", ToggleScheduleSetup)

	net.Receive("SendScheduleListToClients", ClientReceiveScheduleList)
	net.Receive("SendEventMessageToClients", ClientReceiveEventMessage)

	net.Receive("SendInspectDataToClient", ClientReceiveInspectData)

	net.Receive("ClientOpenScheduleSetup", ClientOpenScheduleSetup)
	net.Receive("ClientOpenWorkbench", ClientOpenWorkbench)
	net.Receive("ClientOpenStash", ClientOpenStash)

	net.Receive("UpdateClientLightmaps", UpdateClientLightmaps)
	
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()

	local WorldEntity = game.GetWorld()

	WorldEntity:SetNWVarProxy("ScheduleList", OnRep_CycleScheduleList)

	render.RedownloadAllLightmaps()

	self.BaseClass:InitPostEntity()

	chat.AddText(COLOR_CYAN, UtilLocalizable("RPP_Chat.OnLoad"))
end

function GM:OnPlayerChat(InPlayer, InText, bTeamChat, bIsDead)

	local RPName, RPSurname = UtilGetRPNameSurname(InPlayer)

	chat.AddText(COLOR_WHITE, (bTeamChat and UtilLocalizable("RPP_Chat.Team")) or "",
		team.GetColor(InPlayer:Team()), Format("%s %s: ", UtilLocalizable(RPName), UtilLocalizable(RPSurname)),
		COLOR_WHITE, InText)

	return true
end

function GM:AddDeathNotice() end
function GM:DrawDeathNotice() end
