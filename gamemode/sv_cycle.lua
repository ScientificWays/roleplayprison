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

	SetGlobalBool("bScheduleSet", false)

	table.Empty(ServerScheduleList)

	net.Start("SendScheduleListToClients")

	net.WriteTable(ServerScheduleList)

	net.Broadcast()
end

function OnScheduleSetupOpen(InPlayer, InScheduleSetupEntity)

	net.Start("ClientOpenScheduleSetup")

	net.Send(InPlayer)
end

function TrySkipTaskDelayFor(InPlayerName)

	local RoutineData = GuardRoutineTimeLeftTable[InPlayerName]

	if RoutineData then

		--Will go to 0 next cycle update
		RoutineData.DelayLeft = 1
	end
end

function UpdateGuardRoutine(InPlayerName)

	--MsgN(Format("UpdateGuardRoutine() %s", InPlayerName))

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

		local SampleGuardName = SampleGuard:GetNWString("RPName")

		GuardRoutineTimeLeftTable[SampleGuardName] = {DelayLeft = AdjustedRoutineDelay, TimeLeft = UtilGetRoutineTimeout()}

		MsgN(Format("Set first routine delay for %s: adjusted from %i to %i",
			SampleGuardName, BaseRoutineDelay, AdjustedRoutineDelay))

		table.RemoveByValue(AllGuards, SampleGuard)
	end
end

local function GuardRoutineTick(InGuardPlayer)

	local GuardName = InGuardPlayer:GetNWString("RPName")

	--MsgN(Format("GuardRoutineTick() for %s", GuardName))

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

	MsgN(Format("HandleOfficerPunished() %s", UtilGetOfficerPunishmentTimeLeft()))

	DecreaseOfficerPunishmentTimeLeft()

	if UtilGetOfficerPunishmentTimeLeft() <= 0 then

		--Will reset OfficerPunishmentTimeLeft
		ReleaseOfficerPlayer()
	end
end

function ToggleCycle(bPause)

	if bPause then

		timer.Pause("CycleUpdateTimer")

		UtilSendEventMessageToPlayers({"RPP_Cycle.Paused"})
	else

		timer.UnPause("CycleUpdateTimer")

		UtilSendEventMessageToPlayers({"RPP_Cycle.Continue"})
	end
end

function StartNewCycle()

	SetGlobalInt("CurrentCycleTimeSeconds", 0)

	timer.Create("CycleUpdateTimer", 1, 0, CycleUpdate)

	if UtilIsInterCycle() then

		SetGlobalBool("bInterCycle", false)

		--PrintMessage(HUD_PRINTTALK, "?????????????? ?????????? ????????!")

		MsgN(table.ToString(ServerScheduleList))

		if table.IsEmpty(ServerScheduleList) then

			OnTaskTimeout("EmptySchedule")
		end 

		SetupCycleStartGuardRoutine()

		ClearDetailPickups()

		TrySetMapDayState(0.0)
	else

		SetGlobalBool("bInterCycle", true)

		--PrintMessage(HUD_PRINTTALK, "?????????????? ??????????????!")

		UpdateMapLockablesState()

		TrySetMapNightState(0.0)

		ResetArmory()
	end
end

function OnCycleEnd()

	timer.Remove("CycleUpdateTimer")

	if UtilIsInterCycle() then

	else
		ServerResetScheduleList()

		table.Empty(GuardRoutineTimeLeftTable)

		local AllGuards = team.GetPlayers(TEAM_GUARD)

		for Index, SampleGuard in ipairs(AllGuards) do

			if not SampleGuard:GetNWBool("bOfficer") then

				DisableGuardAccountingTask(SampleGuard)
			end
		end

		TryDisableOfficerPhone()

		HandleOfficerOnIntercycleStart()
	end
end

function CycleUpdate()

	SetGlobalInt("CurrentCycleTimeSeconds", GetGlobalInt("CurrentCycleTimeSeconds") + 1)

	local CurrentCycleTimeSeconds = GetGlobalInt("CurrentCycleTimeSeconds")

	--MsgN(GetGlobalInt("CurrentCycleTimeSeconds"))

	local CurrentCycleDurationSeconds = UtilGetCycleDurationMinutes(UtilIsInterCycle()) * 60

	if CurrentCycleTimeSeconds >= CurrentCycleDurationSeconds then

		OnCycleEnd()

		StartNewCycle()

		return
	end

--[[	local LeftCycleTimeSeconds = UtilGetLeftCycleTimeSeconds()

	if LeftCycleTimeSeconds <= 150 then

		if UtilIsInterCycle() then

			TrySetMapDayState(LeftCycleTimeSeconds / 150)
		else

			TrySetMapNightState(LeftCycleTimeSeconds / 150)
		end
	end--]]

	TryUpdateSkyPaintAndLightmapsState(CurrentCycleTimeSeconds / CurrentCycleDurationSeconds)

	local AllGuards = team.GetPlayers(TEAM_GUARD)

	if table.IsEmpty(AllGuards) then

		UtilSendEventMessageToPlayers({"RPP_Cycle.NoGuards"})

		ToggleCycle(true)

		return
	end

	local OfficerPlayer = UtilGetOfficerPlayer()

	if not IsValid(OfficerPlayer) then

		UtilSendEventMessageToPlayers({"RPP_Cycle.NoOfficer"})

		ToggleCycle(true)

		return
	end

	local AllRobbers = team.GetPlayers(TEAM_ROBBER)

	--[[if table.IsEmpty(AllRobbers) then

		PrintMessage(HUD_PRINTTALK, "?????????????????????? ???? ??????????????!")

		ToggleCycle(true)

		return
	end]]

	if not UtilIsInterCycle() then

		for Index, SampleGuard in ipairs(AllGuards) do

			if SampleGuard:GetNWBool("bOfficer") and UtilIsOfficerPunished() then

			else
				GuardRoutineTick(SampleGuard)
			end
		end
	end

	if UtilIsOfficerPunished() then

		HandleOfficerPunished()
	else

		
	end
end
