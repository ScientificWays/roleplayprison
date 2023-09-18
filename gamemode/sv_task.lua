---- Roleplay: Prison

--local CurrentOfficerPhoneReason = ""

local OfficerPunishmentDuration = 0
local TimeoutTaskNum = 0

local bOfficerPhoneEnabled = false

local PlayerTaskDataList = {}

function IsOfficerPhoneEnabled()

	return bOfficerPhoneEnabled
end

function OnTaskTimeout(InTaskType)

	if UtilIsOfficerPunished() then

		SetOfficerPunishmentTimeLeft(UtilGetOfficerPunishmentTimeLeft() + UtilGetOfficerPunishmentDuration() * 0.25)

		MsgN(Format("OnTaskTimeout() %s, punishment time left %i", InTaskType, UtilGetOfficerPunishmentTimeLeft()))
	else
		TimeoutTaskNum = TimeoutTaskNum + 1

		if TimeoutTaskNum > 3 then

			OnOfficerAnswerPhone()
		end

		OfficerPunishmentDuration = OfficerPunishmentDuration + UtilGetOfficerPunishmentDuration() / TimeoutTaskNum

		TryEnableOfficerPhone()

		MsgN(Format("OnTaskTimeout() %s, punishment duration now %i", InTaskType, OfficerPunishmentDuration))
	end
end

function ResetTaskTimeouts()

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
		end
	end
end

function OnOfficerAnswerPhone()

	TryDisableOfficerPhone()

	if TimeoutTaskNum > 0 then

		PunishOfficerPlayer(OfficerPunishmentDuration)

		ResetTaskTimeouts()

		return false
	end

	return true
end

function CancelOfficerAnswerPhone(InOfficerPlayer, InTaskStartEntity)

	MsgN("CancelOfficerAnswerPhone()")

	TryEnableOfficerPhone()
end

function FinishOfficerAnswerPhone(InOfficerPlayer, InTaskStartEntity)

	MsgN("FinishOfficerAnswerPhone()")

	UpdateGuardRoutine(InOfficerPlayer:GetNWString("RPName"))
end

function TryEnableGuardAccountingTask(InGuardPlayer)

	local GuardName = InGuardPlayer:GetNWString("RPName")

	local PotentialSpots = ents.FindByName("*_GuardTask")

	local FilteredPotentialSpots = {}

	for Index, SampleSpot in ipairs(PotentialSpots) do

		if SampleSpot:GetNWString("TaskImplementer") == "" then

			table.insert(FilteredPotentialSpots, SampleSpot)
		end
	end

	if not table.IsEmpty(FilteredPotentialSpots) then

		local SampleSpot = table.Random(FilteredPotentialSpots)

		SampleSpot:Fire("FireUser1")

		SampleSpot:SetNWString("TaskImplementer", InGuardPlayer:GetNWString("RPName"))

		SampleSpot:SetNWFloat("TaskTimeLeft", UtilGetGuardRoutineDuration())

		MsgN(Format("Enable guard %s accounting task with %s...", GuardName, SampleSpot:GetName()))
	else
		UpdateGuardRoutine(GuardName)

		MsgN(Format("All spots are occupied! Skip routine for %s", GuardName))
	end
end

function DisableGuardAccountingTask(InGuardPlayer)

	local GuardName = InGuardPlayer:GetNWString("RPName")

	local PotentialSpots = ents.FindByName("*_GuardTask")

	for Index, SampleSpot in ipairs(PotentialSpots) do

		if SampleSpot:GetNWString("TaskImplementer") == GuardName then

			SampleSpot:Fire("FireUser2")

			SampleSpot:SetNWString("TaskImplementer", "")

			SampleSpot:SetNWFloat("TaskTimeLeft", 0)

			MsgN(Format("Disable guard %s accounting task with %s...", GuardName, SampleSpot:GetName()))

			break
		end
	end
end

function FinishGuardAccountingTask(InGuardPlayer, InTaskStartEntity)

	MsgN("FinishGuardAccountingTask()")

	DisableGuardAccountingTask(InGuardPlayer)

	UpdateGuardRoutine(InGuardPlayer:GetNWString("RPName"))
end

function FinishRobberWorkTask(InRobberPlayer, InTaskStartEntity)

	MsgN("FinishRobberWorkTask()")

	TryAddDetailForWork(InTaskStartEntity)
end

function OnImplementTaskStart(InPlayer, InTaskStartEntity, InDuration, InCancelCallback, InFinishCallback)

	local PlayerName = InPlayer:GetNWString("RPName")

	timer.Create(Format("%s_Task", PlayerName), 0.1, 0, function()
		OnImplementTaskProgress(InPlayer)
	end)

	--InPlayer:Freeze(true)

	InPlayer:SetNWFloat("TaskTimeLeft", InDuration)

	InTaskStartEntity:SetNWString("NowImplemetingBy", PlayerName)

	PlayerTaskDataList[PlayerName] = {TaskEntity = InTaskStartEntity,
		Position = InPlayer:EyePos(),
		Angles = InPlayer:EyeAngles(),
		CancelCallback = InCancelCallback or function(InPlayer, InTaskEntity) end,
		FinishCallback = InFinishCallback or function(InPlayer, InTaskEntity) end}
end

function OnImplementTaskProgress(InPlayer)

	local SpeedMul = 1.0

	local PlayerName = InPlayer:GetNWString("RPName")

	local TaskData = PlayerTaskDataList[PlayerName]

	if not IsValid(TaskData.TaskEntity) then

		OnImplementTaskStop(InPlayer, true)
	end

	if (string.EndsWith(TaskData.TaskEntity:GetName(), "_Wood_RobberTask") and UtilIsWorkWoodBuffed())
	or (string.EndsWith(TaskData.TaskEntity:GetName(), "_Metal_RobberTask") and UtilIsWorkMetalBuffed()) then

		SpeedMul = UtilGetRobberWorkBuffMultiplier()
	end

	InPlayer:SetNWFloat("TaskTimeLeft", InPlayer:GetNWFloat("TaskTimeLeft") - 0.1 * SpeedMul)

	local TimeLeft = InPlayer:GetNWFloat("TaskTimeLeft")

	if TimeLeft <= 0.0 or InPlayer:GetNWBool("bHandcuffed") then

		OnImplementTaskStop(InPlayer, false)
	else
		local CurrentPlayerPos = InPlayer:EyePos()

		local CurrentPlayerAngles = InPlayer:EyeAngles()

		local CurrentEntityPos = TaskData.TaskEntity:GetPos()

		local CurrentYawDifference = math.abs(math.AngleDifference(CurrentPlayerAngles.Yaw, TaskData.Angles.Yaw))

		local CurrentPitchDifference = math.abs(math.AngleDifference(CurrentPlayerAngles.Pitch, TaskData.Angles.Pitch))

		local MaxAngleDifference = math.max(CurrentYawDifference, CurrentPitchDifference)

		InPlayer:SetNWFloat("TaskCancelExtent", MaxAngleDifference / 30.0 - 0.2)

		if CurrentPlayerPos:DistToSqr(TaskData.Position) > 256.0		--16^2
			or CurrentPlayerPos:DistToSqr(CurrentEntityPos) > 16384.0	--128^2
			or MaxAngleDifference > 30.0 then

			OnImplementTaskStop(InPlayer, true)
		end
	end
end

function OnImplementTaskStop(InPlayer, bCancel)

	MsgN("OnImplementTaskStop()")

	timer.Remove(Format("%s_Task", InPlayer:GetNWString("RPName")))

	local PlayerName = InPlayer:GetNWString("RPName")

	local TaskData = PlayerTaskDataList[PlayerName]

	--InPlayer:Freeze(false)

	InPlayer:SetNWFloat("TaskTimeLeft", 0.0)

	InPlayer:SetNWFloat("TaskCancelExtent", 0.0)

	if IsValid(TaskData.TaskEntity) then

		TaskData.TaskEntity:SetNWString("NowImplemetingBy", "")
	end

	if bCancel then

		TaskData.CancelCallback(InPlayer, TaskData.TaskEntity)
	else

		TaskData.FinishCallback(InPlayer, TaskData.TaskEntity)
	end

	table.Empty(TaskData)

	--MsgN("TaskData nil test: ", table.ToString(PlayerTaskDataList[PlayerName]))
end
