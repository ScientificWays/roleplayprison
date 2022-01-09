---- Roleplay: Prison

local bInterCycle = false

local ServerScheduleList = {}

local GuardRoutineTimeLeftTable = {}

function GetServerScheduleList()

	return ServerScheduleList
end

function ServerReceiveScheduleList(InMessageLength, InPlayer)

	MsgN("ServerReceiveScheduleList()")

	if InPlayer:GetNWBool("bOfficer") == false then

		MsgN("Error! Non officer player sent schedule!")
	end

	ServerScheduleList = net.ReadTable()

	MsgN(table.ToString(ServerScheduleList))

	net.Start("SendScheduleListToClients")

	net.WriteTable(ServerScheduleList)

	net.Broadcast()
end

function ServerResetScheduleList()

	table.Empty(ServerScheduleList)

	net.Start("SendScheduleListToClients")

	net.WriteTable(ServerScheduleList)

	net.Broadcast()
end

function TrySkipTaskDelayFor(InPlayerName)

	local RoutineData = GuardRoutineTimeLeftTable[InPlayerName]

	if RoutineData then

		--Will go to 0 next cycle update
		RoutineData.DelayLeft = 1
	end
end

function UpdateGuardRoutine(InPlayerName)

	--MsgN(string.format("UpdateGuardRoutine() %s", InPlayerName))

	GuardRoutineTimeLeftTable[InPlayerName] = {DelayLeft = UtilGetRoutineDelay(), TimeLeft = UtilGetRoutineTimeout()}

	--MsgN(table.ToString(GuardRoutineTimeLeftTable))
end

local function SetupCycleStartGuardRoutine()

	local AllGuards = team.GetPlayers(TEAM_GUARD)

	local GuardsNum = team.NumPlayers(TEAM_GUARD)

	for Index = 1, GuardsNum do

		local BaseRoutineDelay = UtilGetRoutineDelay()

		local AdjustedRoutineDelay = BaseRoutineDelay / GuardsNum * Index

		local SampleGuard = table.Random(AllGuards)

		local SampleGuardName = SampleGuard:GetName()

		GuardRoutineTimeLeftTable[SampleGuardName] = {DelayLeft = AdjustedRoutineDelay, TimeLeft = UtilGetRoutineTimeout()}

		MsgN(string.format("Set first routine delay for %s: adjusted from %i to %i",
			SampleGuardName, BaseRoutineDelay, AdjustedRoutineDelay))

		table.RemoveByValue(AllGuards, SampleGuard)
	end
end

local function HandleGuardRoutine(InGuardPlayer)

	local GuardName = InGuardPlayer:GetName()

	--MsgN(string.format("HandleGuardRoutine() for %s", GuardName))

	local RoutineData = GuardRoutineTimeLeftTable[GuardName]

	if RoutineData then

		--MsgN(table.ToString(RoutineData))

		if RoutineData.DelayLeft > 0 then

			RoutineData.DelayLeft = RoutineData.DelayLeft - 1

			if RoutineData.DelayLeft <= 0 then

				if InGuardPlayer:GetNWBool("bOfficer") then

					TryEnableOfficerPhone()
				else

					EnableGuardAccountingTask(InGuardPlayer)
				end
			end

		elseif RoutineData.TimeLeft <= 0 then

			OnTaskTimeout("GuardRoutine")

			DisableGuardAccountingTask(InGuardPlayer)

			UpdateGuardRoutine(GuardName)

		elseif InGuardPlayer:GetNWFloat("TaskTimeLeft") <= 0.0 then

			RoutineData.TimeLeft = RoutineData.TimeLeft - 1
		end
	else

		UpdateGuardRoutine(GuardName)
	end
end

local function HandleOfficerPunished(InOfficerPlayer)

	DecreaseOfficerPunishmentTimeLeft()

	if GetOfficerPunishmentTimeLeft() <= 0 then

		--Will reset OfficerPunishmentTimeLeft
		ReleaseOfficerPlayer()
	end
end

function ToggleCycle(bPause)

	if bPause then

		timer.Pause("CycleUpdateTimer")

		PrintMessage(HUD_PRINTTALK, "Цикл приоставновлен...")
	else

		timer.UnPause("CycleUpdateTimer")

		PrintMessage(HUD_PRINTTALK, "Цикл продолжается...")
	end
end

function StartNewCycle()

	local WorldEntity = game.GetWorld()

	WorldEntity:SetNWInt("CurrentCycleTimeSeconds", 0)

	timer.Create("CycleUpdateTimer", 1, 0, CycleUpdate)

	if UtilIsInterCycle() then

		WorldEntity:SetNWBool("bInterCycle", false)

		WorldEntity:SetNWBool("bScheduleSet", false)

		--PrintMessage(HUD_PRINTTALK, "Начался новый цикл!")

		MsgN(table.ToString(ServerScheduleList))

		if table.IsEmpty(ServerScheduleList) then

			OnTaskTimeout("EmptySchedule")
		end 

		SetupCycleStartGuardRoutine()

		ClearDetailPickups()

		TrySetMapDayState(1.0)
	else

		WorldEntity:SetNWBool("bInterCycle", true)

		--PrintMessage(HUD_PRINTTALK, "Начался перерыв!")

		UpdateMapLockablesState()

		TrySetMapNightState(1.0)
	end
end

function OnCycleEnd()

	timer.Remove("CycleUpdateTimer")

	if UtilIsInterCycle() then

	else
		ServerResetScheduleList()

		table.Empty(GuardRoutineTimeLeftTable)
	end
end

function CycleUpdate()

	local WorldEntity = game.GetWorld()

	WorldEntity:SetNWInt("CurrentCycleTimeSeconds", WorldEntity:GetNWInt("CurrentCycleTimeSeconds") + 1)

	local CurrentCycleTimeSeconds = WorldEntity:GetNWInt("CurrentCycleTimeSeconds")

	--MsgN(WorldEntity:GetNWInt("CurrentCycleTimeSeconds"))

	if CurrentCycleTimeSeconds >= UtilGetCycleDurationMinutes(UtilIsInterCycle()) * 60 then

		OnCycleEnd()

		StartNewCycle()

		return
	end

	local LeftCycleTimeSeconds = UtilGetLeftCycleTimeSeconds()

	if LeftCycleTimeSeconds <= 150 then

		if UtilIsInterCycle() then

			TrySetMapDayState(1.0 - LeftCycleTimeSeconds / 150)
		else

			TrySetMapNightState(1.0 - LeftCycleTimeSeconds / 150)
		end
	end

	local AllGuards = team.GetPlayers(TEAM_GUARD)

	if table.IsEmpty(AllGuards) then

		PrintMessage(HUD_PRINTTALK, "Охранники не найдены!")

		ToggleCycle(true)

		return
	end

	local OfficerPlayer = UtilGetOfficerPlayer()

	if not IsValid(OfficerPlayer) then

		PrintMessage(HUD_PRINTTALK, "Офицер не найден!")

		ToggleCycle(true)

		return
	end

	local AllRobbers = team.GetPlayers(TEAM_ROBBER)

	--[[if table.IsEmpty(AllRobbers) then

		PrintMessage(HUD_PRINTTALK, "Заключенные не найдены!")

		ToggleCycle(true)

		return
	end]]

	if not UtilIsInterCycle() then

		for Index, SampleGuard in ipairs(AllGuards) do

			if SampleGuard:GetNWBool("bOfficer") and UtilIsOfficerPunished() then

			else
				HandleGuardRoutine(SampleGuard)
			end
		end
	end

	if UtilIsOfficerPunished() then

		HandleOfficerPunished()
	else

		
	end
end
