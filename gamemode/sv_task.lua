---- Roleplay: Prison

local CurrentOfficerPhoneReason = ""

local OfficerPunishmentDuration = 0
local TimeoutTaskNum = 0

local bOfficerPhoneEnabled = false

local PlayerTaskDataList = {}

function IsOfficerPhoneEnabled()

	return bOfficerPhoneEnabled
end

function OnTaskTimeout(InTaskType)

	TimeoutTaskNum = TimeoutTaskNum + 1

	OfficerPunishmentDuration = OfficerPunishmentDuration + UtilGetOfficerPunishmentDuration() / TimeoutTaskNum

	MsgN(string.format("OnTaskTimeout() %s, punishment duration now %i", InTaskType, OfficerPunishmentDuration))

	TryEnableOfficerPhone()

	if TimeoutTaskNum > 3 then

		PunishOfficerPlayer(OfficerPunishmentDuration)

		ResetTaskTimeout()
	end
end

function ResetTaskTimeout()

	OfficerPunishmentDuration = 0
	TimeoutTaskNum = 0
end

function TryEnableOfficerPhone()

	if not bOfficerPhoneEnabled then

		MsgN("Enable officer phone...")

		bOfficerPhoneEnabled = true

		local OfficerPhone = ents.FindByName("*_OfficerPhone")[1]

		if IsValid(OfficerPhone) then

			OfficerPhone:Fire("FireUser1")

			OfficerPhone:SetNWFloat("TaskTimeLeft", UtilGetOfficerRoutineDuration())
		end
	end
end

function TryDisableOfficerPhone()

	if bOfficerPhoneEnabled then

		MsgN("Disable officer phone...")

		bOfficerPhoneEnabled = false

		local OfficerPhone = ents.FindByName("*_OfficerPhone")[1]

		if IsValid(OfficerPhone) then

			OfficerPhone:Fire("FireUser2")

			OfficerPhone:SetNWFloat("TaskTimeLeft", 0)
		end
	end
end

function OnOfficerAnswerPhone()

	TryDisableOfficerPhone()

	if TimeoutTaskNum > 0 then

		PunishOfficerPlayer(OfficerPunishmentDuration)

		ResetTaskTimeout()

		return false
	end

	return true
end

function CancelOfficerAnswerPhone(InOfficerPlayer)

	MsgN("CancelOfficerAnswerPhone()")

	TryEnableOfficerPhone()
end

function FinishOfficerAnswerPhone(InOfficerPlayer)

	MsgN("FinishOfficerAnswerPhone()")

	UpdateGuardRoutine(InOfficerPlayer:GetName())
end

function EnableGuardAccountingTask(InGuardPlayer)

	local GuardName = InGuardPlayer:GetName()

	local PotentialComputers = ents.FindByName("*_GuardTask")

	if not table.IsEmpty(PotentialComputers) then

		local SampleComputer = table.Random(PotentialComputers)

		SampleComputer:Fire("FireUser1")

		SampleComputer:SetNWString("TaskImplementer", GuardName)

		SampleComputer:SetNWFloat("TaskTimeLeft", UtilGetGuardRoutineDuration())

		MsgN(string.format("Enable guard %s accounting task with %s...", GuardName, SampleComputer:GetName()))
	end
end

function DisableGuardAccountingTask(InGuardPlayer)

	local GuardName = InGuardPlayer:GetName()

	local PotentialComputers = ents.FindByName("*_GuardTask")

	for Index, SampleComputer in ipairs(PotentialComputers) do

		if SampleComputer:GetNWString("TaskImplementer") == GuardName then

			SampleComputer:Fire("FireUser2")

			SampleComputer:SetNWString("TaskImplementer", "")

			SampleComputer:SetNWFloat("TaskTimeLeft", 0)

			MsgN(string.format("Disable guard %s accounting task with %s...", GuardName, SampleComputer:GetName()))

			break
		end
	end
end

function CancelGuardAccountingTask(InGuardPlayer)

	MsgN("CancelGuardAccountingTask()")



end

function FinishGuardAccountingTask(InGuardPlayer)

	MsgN("FinishGuardAccountingTask()")

	DisableGuardAccountingTask(InGuardPlayer)

	UpdateGuardRoutine(InGuardPlayer:GetName())
end

function OnImplementTaskStart(InPlayer, InDuration, InCancelCallback, InFinishCallback)

	local PlayerName = InPlayer:GetName()

	timer.Create(string.format("%s_Task", PlayerName), 0.1, 0, function()
		OnImplementTaskProgress(InPlayer)
	end)

	--InPlayer:Freeze(true)

	InPlayer:SetNWFloat("TaskTimeLeft", InDuration)

	PlayerTaskDataList[PlayerName] = {Position = InPlayer:GetPos(),
		Yaw = InPlayer:GetAngles().Yaw,
		CancelCallback = InCancelCallback,
		FinishCallback = InFinishCallback}
end

function OnImplementTaskProgress(InPlayer)

	InPlayer:SetNWFloat("TaskTimeLeft", InPlayer:GetNWFloat("TaskTimeLeft") - 0.1)

	local TimeLeft = InPlayer:GetNWFloat("TaskTimeLeft")

	if TimeLeft <= 0.0 then

		OnImplementTaskStop(InPlayer, false)

	else

		local PlayerName = InPlayer:GetName()

		local TaskData = PlayerTaskDataList[PlayerName]

		local CurrentPlayerPos = InPlayer:GetPos()

		local CurrentPlayerAngles = InPlayer:GetAngles()

		if CurrentPlayerPos:DistToSqr(TaskData.Position) > 128.0
			or math.abs(math.AngleDifference(CurrentPlayerAngles.Yaw, TaskData.Yaw)) > 25.0 then

			OnImplementTaskStop(InPlayer, true)
		end
	end
end

function OnImplementTaskStop(InPlayer, bCancel)

	MsgN("OnImplementTaskStop()")

	timer.Remove(string.format("%s_Task", InPlayer:GetName()))

	local PlayerName = InPlayer:GetName()

	--InPlayer:Freeze(false)

	InPlayer:SetNWFloat("TaskTimeLeft", 0.0)

	if bCancel then

		PlayerTaskDataList[PlayerName].CancelCallback(InPlayer)
	else

		PlayerTaskDataList[PlayerName].FinishCallback(InPlayer)
	end
end
