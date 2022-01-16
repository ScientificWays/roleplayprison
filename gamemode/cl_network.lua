---- Roleplay: Prison

local ClientScheduleList = {}

function GetReplicatedScheduleList()

	return ClientScheduleList
end

function ClientReceiveScheduleList(InMessageLength, InPlayer)

	ClientScheduleList = net.ReadTable()
end

function ClientSendScheduleList(InElementList)

	net.Start("SendScheduleListToServer")

	net.WriteTable(InElementList)

	net.SendToServer()
end

function ClientReceiveInspectData(InMessageLength, InPlayer)

	local InspectDataTable = net.ReadTable()

	ShowInspection(InspectDataTable)
end

function UpdateClientLightmaps(InMessageLength, InPlayer)

	render.RedownloadAllLightmaps()
end
