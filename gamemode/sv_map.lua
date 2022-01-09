---- Roleplay: Prison

OfficerMonitorArea = {}
ControlMonitorArea = {}
LibraryMonitorArea = {}

ControlSpeakerArea = {}

WorkWoodArea = {}
WorkMetalArea = {}

local bDayMapState = nil

local OldLightStyle = ""

local function TryUpdateLightStyle(InNewLightStyle)

	if InNewLightStyle ~= OldLightStyle then

		engine.LightStyle(0, InNewLightStyle)

		timer.Simple( 0.1, function()

		net.Start("UpdateClientLightmaps")

		net.Broadcast()

		end)

		MsgN(string.format("New light style: %s", InNewLightStyle))

		OldLightStyle = InNewLightStyle
	end
end

function UpdateMapLockablesState()

	MsgN("Update map lockables state...")

	local PotentialLockables = ents.FindByName("*Lockable")

	--MsgN(table.ToString(PotentialLockables))

	for Index, SampleEntity in ipairs(PotentialLockables) do

		local InputType = "Lock"

		local bNewLockState = true

		if math.random() < 0.5 then

			InputType = "Unlock"

			bNewLockState = false
		end

		SampleEntity:Input(InputType)

		SampleEntity:SetNWBool("bWasLocked", bNewLockState)

		--MsgN(InputType)

		local SlaveDoorName = SampleEntity:GetInternalVariable("slavename") or ""

		if SlaveDoorName ~= "" then

			local SlaveDoorEntity = ents.FindByName(SlaveDoorName)[1]

			if IsValid(SlaveDoorEntity) then

				SlaveDoorEntity:Input(InputType)

				SlaveDoorEntity:SetNWBool("bWasLocked", bNewLockState)
			end
		end
	end
end

function SetColorCorrectionEntities()

	ColorCorrectionNightAreaList = ents.FindByName("ColorCorrection_Night")
end

function SetupMapEntityFlags()

	MsgN("Setup map lockables...")

	local AllEntities = ents.GetAll()

	for Index, SampleEntity in ipairs(AllEntities) do

		local SampleEntityName = SampleEntity:GetName()

		if string.EndsWith(SampleEntityName, "_GuardLockable") then

			SampleEntity:SetNWBool("bGuardLockable", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_OfficerLockable") then

			SampleEntity:SetNWBool("bOfficerLockable", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_AllUser1") then

			SampleEntity:SetNWBool("bAllUser1", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_GuardUser1") then

			SampleEntity:SetNWBool("bGuardUser1", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_RobberUser1") then

			SampleEntity:SetNWBool("bRobberUser1", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_ScheduleSetup") then

			SampleEntity:SetNWBool("bScheduleSetupEntity", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_CellsButton") then

			SampleEntity:SetNWBool("bCellsButton", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_AlarmButton") then

			SampleEntity:SetNWBool("bAlarmButton", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_GlobalSpeakerButton") then

			SampleEntity:SetNWBool("bGlobalSpeakerButton", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_ServerSabotage") then

			SampleEntity:SetNWBool("bServerSabotage", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_GuardTask") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bGuardTask", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_OfficerPhone") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bOfficerPhone", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_RobberTask") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bRobberTask", true)

			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_DetailPickup") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bDetailPickup", true)

		elseif string.EndsWith(SampleEntityName, "_DetailSpawn") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bDetailSpawn", true)

			--Will be true if will have at least 1 detail made
			--SampleEntity:SetNWBool("bShowHint", true)
		end
	end
end

function SetupMapAreas()

	MsgN("Setup map areas...")

	local PotentialMonitorAreas = ents.FindByClass("trigger_multiple")

	for Index, SampleMonitorArea in ipairs(PotentialMonitorAreas) do

		local SampleMonitorAreaName = SampleMonitorArea:GetName()

		if string.EndsWith(SampleMonitorAreaName, "_Officer_MonitorArea") then

			OfficerMonitorArea = SampleMonitorArea

		elseif string.EndsWith(SampleMonitorAreaName, "_Control_MonitorArea") then

			ControlMonitorArea = SampleMonitorArea

		elseif string.EndsWith(SampleMonitorAreaName, "_Library_MonitorArea") then

			LibraryMonitorArea = SampleMonitorArea

		elseif string.EndsWith(SampleMonitorAreaName, "_Control_SpeakerArea") then

			ControlSpeakerArea = SampleMonitorArea

		elseif string.EndsWith(SampleMonitorAreaName, "_Work_WoodArea") then

			WorkWoodArea = SampleMonitorArea

		elseif string.EndsWith(SampleMonitorAreaName, "_Work_MetalArea") then

			WorkMetalArea = SampleMonitorArea
		end
	end
end

function TrySetMapDayState(InAlpha)

	if not bDayMapState then

		local ToggleEntity = ents.FindByName("ColorCorrection_Toggle")[1]

		if IsValid(ToggleEntity) then

			ToggleEntity:Fire("FireUser1")

			MsgN("SetMapDayState")
		end

		bDayMapState = true
	end

	local RemappedAlpha = math.Remap(InAlpha, 0.0, 1.0, string.byte("b"), string.byte("m"))

	TryUpdateLightStyle(string.char(math.Round(RemappedAlpha)))
end

function TrySetMapNightState(InAlpha)

	if bDayMapState or bDayMapState == nil then

		local ToggleEntity = ents.FindByName("ColorCorrection_Toggle")[1]

		if IsValid(ToggleEntity) then

			ToggleEntity:Fire("FireUser2")

			MsgN("SetMapNightState")
		end

		bDayMapState = false
	end

	local RemappedAlpha = math.Remap(InAlpha, 0.0, 1.0, string.byte("m"), string.byte("b"))

	TryUpdateLightStyle(string.char(math.Round(RemappedAlpha)))
end
