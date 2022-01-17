---- Roleplay: Prison

local ClientScheduleList = {}

function GetReplicatedScheduleList()

	return ClientScheduleList
end

function ClientSendScheduleList(InElementList)

	net.Start("SendScheduleListToServer")

	net.WriteTable(InElementList)

	net.SendToServer()
end

function ClientSendTryCraftItem(InItemName)

	--MsgN(string.format("ClientSendTryCraftItem() %s", InItemName))

	net.Start("SendTryCraftItemToServer")

	net.WriteString(InItemName)

	net.SendToServer()
end

function ClientReceiveScheduleList(InMessageLength, InPlayer)

	ClientScheduleList = net.ReadTable()
end

function ClientReceiveInspectData(InMessageLength, InPlayer)

	local InspectDataTable = net.ReadTable()

	ShowInspection(InspectDataTable)
end

function UpdateClientLightmaps(InMessageLength, InPlayer)

	render.RedownloadAllLightmaps()
end
