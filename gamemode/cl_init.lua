---- Roleplay: Prison

include("sh_util.lua")
include("cl_util.lua")
include("cl_monitors.lua")
include("cl_hud.lua")
include("cl_pickrole.lua")
include("cl_schedule.lua")
include("cl_network.lua")

surface.CreateFont("MonitorText", {font = "Tahoma",
									size = 120,
									weight = 1000})
surface.CreateFont("MonitorTextSmall", {font = "Tahoma",
									size = 70,
									weight = 900})
surface.CreateFont("HUDText", {font = "Tahoma",
									size = 32,
									weight = 800})
surface.CreateFont("HUDTextSmall", {font = "Tahoma",
									size = 18,
									weight = 700})

surface.CreateFont( 'closebtn', {
	font = 'Tahoma',
	extended = true,
	weight = 500,
	size = 20,
} )

surface.CreateFont( 'title', {
	font = 'Tahoma',
	extended = true,
	weight = 600,
	size = 15,
} )

surface.CreateFont( 'msg', {
	font = 'Tahoma',
	extended = true,
	weight = 500,
	size = 17,
} )

function GM:Initialize()

	MsgN("RPP Client initializing...")

	--GAMEMODE.round_state = ROUND_WAIT

	--concommand.Add("schedulesetup", ToggleScheduleSetup)

	net.Receive("SendScheduleListToClients", ClientReceiveScheduleList)

	net.Receive("UpdateClientLightmaps", UpdateClientLightmaps)
	
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()

	local WorldEntity = game.GetWorld()

	WorldEntity:SetNWVarProxy("ScheduleList", OnRep_CycleScheduleList)

	render.RedownloadAllLightmaps();

	self.BaseClass:InitPostEntity()
end

function GM:Tick()

	if engine.TickCount() % 10 ~= 0 then

		return
	end

	ResetHUDHintData()

	local ClientPlayer = LocalPlayer()

	if not IsValid(ClientPlayer)
		or not IsValid(ClientPlayer:GetActiveWeapon())
		or ClientPlayer:GetActiveWeapon():GetClass() ~= "weapon_rpp_unarmed" then

		return
	end

	local EyeTrace = ClientPlayer:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 or not IsValid(EyeTrace.Entity) then

		return
	end

	UpdateHUDHintData(ClientPlayer, EyeTrace.Entity)
end

function GM:AddDeathNotice() end
function GM:DrawDeathNotice() end
