---- Roleplay: Prison

OfficerMonitorArea = {}
ControlMonitorArea = {}
LibraryMonitorArea = {}

function SetupMapLockables()

	MsgN("Setup map lockables...")

	local PotentialLockables = ents.FindByClass("prop_door_rotating")

	table.Add(PotentialLockables, ents.FindByClass("func_door_rotating"))

	for Index, SampleLockable in ipairs(PotentialLockables) do

		local SampleLockableName = SampleLockable:GetName()

		local bLockable = false

		if string.EndsWith(SampleLockableName, "_GuardLockable") then

			bLockable = true

			SampleLockable:SetNWBool("bGuardLockable", true)

		elseif string.EndsWith(SampleLockableName, "_OfficerLockable") then

			bLockable = true
			
			SampleLockable:SetNWBool("bOfficerLockable", true)
		end

		if bLockable then

			MsgN(SampleLockableName.." is registered!")

			local InputType = "Lock"

			local bNewLockState = true

			if math.random() < 0.5 then

				InputType = "Unlock"

				bNewLockState = false
			end

			SampleLockable:Input(InputType)

			SampleLockable:SetNWBool("bWasLocked", bNewLockState)

			local SlaveDoorName = SampleLockable:GetInternalVariable("slavename") or ""

			if SlaveDoorName ~= "" then

				local SlaveDoorEntity = ents.FindByName(SlaveDoorName)[1]

				if IsValid(SlaveDoorEntity) then

					SlaveDoorEntity:Input(InputType)

					SlaveDoorEntity:SetNWBool("bWasLocked", bNewLockState)
				end
			end
		end
	end
end

function SetupMapUsables()

	MsgN("Setup map usables...")

	local PotentialUsables = ents.FindByName("*User1")

	for Index, SampleUsable in ipairs(PotentialUsables) do

		local SampleUsableName = SampleUsable:GetName()

		if string.EndsWith(SampleUsableName, "_AllUser1") then

			SampleUsable:SetNWBool("bAllUser1", true)

		elseif string.EndsWith(SampleUsableName, "_GuardUser1") then

			SampleUsable:SetNWBool("bGuardUser1", true)

		elseif string.EndsWith(SampleUsableName, "_RobberUser1") then

			SampleUsable:SetNWBool("bRobberUser1", true)
		end
	end
end

function SetupMapRoutines()

	MsgN("Setup map routines...")

	local PotentialTasks = ents.FindByName("*_*Task")

	for Index, SampleTask in ipairs(PotentialTasks) do

		local SampleTaskName = SampleTask:GetName()

		if string.EndsWith(SampleTaskName, "_GuardTask") then

			MsgN(SampleTaskName.." is registered!")

			SampleTask:SetNWBool("bGuardTask", true)

		elseif string.EndsWith(SampleTaskName, "_OfficerPhone") then

			MsgN(SampleTaskName.." is registered!")

			SampleTask:SetNWBool("bOfficerPhone", true)
		end
	end
end

function SetupMapMonitorAreas()

	MsgN("Setup map monitor areas...")

	local PotentialMonitorAreas = ents.FindByClass("trigger_multiple")

	for Index, SampleMonitorArea in ipairs(PotentialMonitorAreas) do

		local SampleMonitorAreaName = SampleMonitorArea:GetName()

		if string.EndsWith(SampleMonitorAreaName, "_Officer_MonitorArea") then

			MsgN(SampleMonitorAreaName.." is registered!")

			OfficerMonitorArea = SampleMonitorArea

		elseif string.EndsWith(SampleMonitorAreaName, "_Control_MonitorArea") then

			MsgN(SampleMonitorAreaName.." is registered!")

			ControlMonitorArea = SampleMonitorArea

		elseif string.EndsWith(SampleMonitorAreaName, "_Library_MonitorArea") then

			MsgN(SampleMonitorAreaName.." is registered!")

			LibraryMonitorArea = SampleMonitorArea
		end
	end
end
