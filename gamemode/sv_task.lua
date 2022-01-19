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

	TimeoutTaskNum = TimeoutTaskNum + 1

	if TimeoutTaskNum > 3 then

		OnOfficerAnswerPhone()
	end

	OfficerPunishmentDuration = OfficerPunishmentDuration + UtilGetOfficerPunishmentDuration() / TimeoutTaskNum

	MsgN(string.format("OnTaskTimeout() %s, punishment duration now %i", InTaskType, OfficerPunishmentDuration))

	TryEnableOfficerPhone()
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

	UpdateGuardRoutine(InOfficerPlayer:GetName())
end

function EnableGuardAccountingTask(InGuardPlayer)

	local GuardName = InGuardPlayer:GetName()

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

		SampleSpot:SetNWString("TaskImplementer", GuardName)

		SampleSpot:SetNWFloat("TaskTimeLeft", UtilGetGuardRoutineDuration())

		MsgN(string.format("Enable guard %s accounting task with %s...", GuardName, SampleSpot:GetName()))
	else
		UpdateGuardRoutine(GuardName)

		MsgN(string.format("All spots are occupied! Skip routine for %s", GuardName))
	end
end

function DisableGuardAccountingTask(InGuardPlayer)

	local GuardName = InGuardPlayer:GetName()

	local PotentialSpots = ents.FindByName("*_GuardTask")

	for Index, SampleSpot in ipairs(PotentialSpots) do

		if SampleSpot:GetNWString("TaskImplementer") == GuardName then

			SampleSpot:Fire("FireUser2")

			SampleSpot:SetNWString("TaskImplementer", "")

			SampleSpot:SetNWFloat("TaskTimeLeft", 0)

			MsgN(string.format("Disable guard %s accounting task with %s...", GuardName, SampleSpot:GetName()))

			break
		end
	end
end

function FinishGuardAccountingTask(InGuardPlayer, InTaskStartEntity)

	MsgN("FinishGuardAccountingTask()")

	DisableGuardAccountingTask(InGuardPlayer)

	UpdateGuardRoutine(InGuardPlayer:GetName())
end

function FinishRobberWorkTask(InRobberPlayer, InTaskStartEntity)

	MsgN("FinishRobberWorkTask()")

	TryAddDetailForWork(InTaskStartEntity)
end

function OnImplementTaskStart(InPlayer, InTaskStartEntity, InDuration, InCancelCallback, InFinishCallback)

	local PlayerName = InPlayer:GetName()

	timer.Create(string.format("%s_Task", PlayerName), 0.1, 0, function()
		OnImplementTaskProgress(InPlayer)
	end)

	--InPlayer:Freeze(true)

	InPlayer:SetNWFloat("TaskTimeLeft", InDuration)

	InTaskStartEntity:SetNWString("NowImplemetingBy", PlayerName)

	PlayerTaskDataList[PlayerName] = {TaskEntity = InTaskStartEntity,
		Position = InPlayer:GetPos(),
		Angles = InPlayer:EyeAngles(),
		CancelCallback = InCancelCallback or function(InPlayer, InTaskEntity) end,
		FinishCallback = InFinishCallback or function(InPlayer, InTaskEntity) end}
end

function OnImplementTaskProgress(InPlayer)

	local SpeedMul = 1.0

	local PlayerName = InPlayer:GetName()

	local TaskData = PlayerTaskDataList[PlayerName]

	if (string.EndsWith(TaskData.TaskEntity:GetName(), "_Wood_RobberTask") and UtilIsWorkWoodBuffed())
	or (string.EndsWith(TaskData.TaskEntity:GetName(), "_Metal_RobberTask") and UtilIsWorkMetalBuffed()) then

		SpeedMul = UtilGetRobberWorkBuffMultiplier()
	end

	InPlayer:SetNWFloat("TaskTimeLeft", InPlayer:GetNWFloat("TaskTimeLeft") - 0.1 * SpeedMul)

	local TimeLeft = InPlayer:GetNWFloat("TaskTimeLeft")

	if TimeLeft <= 0.0 or InPlayer:GetNWBool("bHandcuffed") then

		OnImplementTaskStop(InPlayer, false)
	else
		local CurrentPlayerPos = InPlayer:GetPos()

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

	timer.Remove(string.format("%s_Task", InPlayer:GetName()))

	local PlayerName = InPlayer:GetName()

	local TaskData = PlayerTaskDataList[PlayerName]

	--InPlayer:Freeze(false)

	InPlayer:SetNWFloat("TaskTimeLeft", 0.0)

	InPlayer:SetNWFloat("TaskCancelExtent", 0.0)

	TaskData.TaskEntity:SetNWString("NowImplemetingBy", "")

	if bCancel then

		TaskData.CancelCallback(InPlayer, TaskData.TaskEntity)
	else

		TaskData.FinishCallback(InPlayer, TaskData.TaskEntity)
	end

	table.Empty(TaskData)

	--MsgN("TaskData nil test: ", table.ToString(PlayerTaskDataList[PlayerName]))
end
