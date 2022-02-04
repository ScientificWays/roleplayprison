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

	--MsgN(Format("ClientSendTryCraftItem() %s", InItemName))

	net.Start("SendTryCraftItemToServer")

	net.WriteString(InItemName)

	net.SendToServer()
end

function ClientSendRequestJoinTeam(InTeamID, bMale)

	MsgN(Format("ClientSendRequestJoinTeam() %i, %s", InTeamID, bMale))

	net.Start("SendRequestJoinTeamToServer")

	net.WriteInt(InTeamID, 32)

	net.WriteBool(bMale)

	net.SendToServer()
end

function ClientReceiveScheduleList(InMessageLength, InPlayer)

	ClientScheduleList = net.ReadTable()
end

function ClientReceiveInspectData(InMessageLength, InPlayer)

	local InspectDataTable = net.ReadTable()

	ShowInspection(InspectDataTable)
end

function ClientReceiveEventMessage(InMessageLength, InPlayer)

	local PrintArgumets = {}

	for Index = 1, 10 do

		local SampleString = net.ReadString()

		if SampleString == "" then

			break
		else

			table.insert(PrintArgumets, UtilLocalizable(SampleString))
		end
	end

	MsgN(PrintTable(PrintArgumets))

	MsgN(unpack(PrintArgumets))

	chat.AddText(COLOR_CYAN, Format(unpack(PrintArgumets)))
end

function ClientOpenScheduleSetup(InMessageLength, InPlayer)

	ShowScheduleSetup()
end

function ClientOpenScheduleSetup(InMessageLength, InPlayer)

	ShowScheduleSetup()
end

function ClientOpenScheduleSetup(InMessageLength, InPlayer)

	ShowScheduleSetup()
end

function ClientOpenWorkbench(InMessageLength, InPlayer)

	ShowWorkbenchFrame()
end

function ClientOpenStash(InMessageLength, InPlayer)

	local StashEntityIndex = net.ReadInt(32)

	--MsgN(StashEntityIndex)

	--MsgN(Entity(StashEntityIndex))

	ShowStash(Entity(StashEntityIndex))
end

function UpdateClientLightmaps(InMessageLength, InPlayer)

	render.RedownloadAllLightmaps()
end
