---- Roleplay: Prison

OfficerMonitorArea = {}
ControlMonitorArea = {}
LibraryMonitorArea = {}

ControlSpeakerArea = {}

WorkWoodArea = {}
WorkMetalArea = {}

PunishmentArea = {}
--Outside1Area = {}
GuardRestArea = {}

local bDayMapState = nil

local OldLightStyle = ""

function UpdateMapLockablesState()

	MsgN("Update map lockables state...")

	local AllLockables = ents.FindByName("*Lockable")

	--MsgN(table.ToString(AllLockables))

	for Index, SampleLockable in ipairs(AllLockables) do

		if SampleLockable:GetNWBool("bWasLocked") then

			local InputType = "Lock"

			local bNewLockState = true

			if math.random() < 0.5 then

				InputType = "Unlock"

				bNewLockState = false
			end

			SampleLockable:Input(InputType)

			SampleLockable:SetNWBool("bWasLocked", bNewLockState)

			--MsgN(InputType)

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

function SetupMapEntityFlags()

	MsgN("Setup map entity flags...")

	local AllEntities = ents.GetAll()

	for Index, SampleEntity in ipairs(AllEntities) do

		local SampleEntityName = SampleEntity:GetName()

		if string.EndsWith(SampleEntityName, "_GuardLockable") then

			SampleEntity:SetNWBool("bGuardLockable", true)
			SampleEntity:SetNWBool("bShowHint", true)
			SampleEntity:Input("Lock")
			SampleEntity:SetNWBool("bWasLocked", true)

		elseif string.EndsWith(SampleEntityName, "_OfficerLockable") then

			SampleEntity:SetNWBool("bOfficerLockable", true)
			SampleEntity:SetNWBool("bShowHint", true)
			SampleEntity:Input("Lock")
			SampleEntity:SetNWBool("bWasLocked", true)

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

		elseif string.EndsWith(SampleEntityName, "_CellDoor") then

			SampleEntity:SetNWBool("bCellDoor", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_AlarmButton") then

			SampleEntity:SetNWBool("bAlarmButton", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_GlobalSpeakerButton") then

			SampleEntity:SetNWBool("bGlobalSpeakerButton", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_Sabotage") then

			SampleEntity:SetNWBool("bSabotage", true)
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

			--No hint needed
			--SampleEntity:SetNWBool("bShowHint", false)

		elseif string.EndsWith(SampleEntityName, "_DetailSpawn") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bDetailSpawn", true)

			--Will be true if will have at least 1 detail made
			SampleEntity:SetNWBool("bShowHint", false)

		elseif string.EndsWith(SampleEntityName, "_FoodSpawn") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bFoodSpawn", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_WaterSpawn") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bWaterSpawn", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_Workbench") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bWorkbench", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_Stash") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bStash", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_StashMetal") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bStash", true)
			SampleEntity:SetNWBool("bStashMetal", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_CameraControl") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bCameraControl", true)
			SampleEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(SampleEntityName, "_CrowbarOnly") then

			MsgN(SampleEntityName.." is registered!")

			SampleEntity:SetNWBool("bCrowbarOnly", true)
			SampleEntity:SetNWBool("bShowHint", true)
		end
	end
end

function SetupMapAreas()

	MsgN("Setup map areas...")

	local PotentialAreas = ents.FindByClass("trigger_multiple")

	for Index, SampleArea in ipairs(PotentialAreas) do

		local SampleAreaName = SampleArea:GetName()

		if string.EndsWith(SampleAreaName, "_Officer_MonitorArea") then

			OfficerMonitorArea = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Control_MonitorArea") then

			ControlMonitorArea = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Library_MonitorArea") then

			LibraryMonitorArea = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Control_SpeakerArea") then

			ControlSpeakerArea = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Work_WoodArea") then

			WorkWoodArea = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Work_MetalArea") then

			WorkMetalArea = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Punishment_Area") then

			PunishmentArea = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Outside1_Area") then

			Outside1Area = SampleArea

		elseif string.EndsWith(SampleAreaName, "_Rest_Area") then

			GuardRestArea = SampleArea
		end
	end
end

function ChangeLockableState(InPlayer, InLockableEntity, bNewLockState)

	local InputType = "Unlock"

	if bNewLockState then

		InputType = "Lock"
	end

	InLockableEntity:Fire(InputType, nil, 0, InPlayer, InLockableEntity)
	InLockableEntity:SetNWBool("bWasLocked", bNewLockState)

	InLockableEntity:EmitSound("Town.d1_town_02_default_locked",
		60, math.random(95, 105), math.random(0.95, 1.05), CHAN_AUTO, 0, 1)

	local SlaveDoorName = InLockableEntity:GetInternalVariable("slavename") or ""

	if SlaveDoorName ~= "" then

		local SlaveDoorEntity = ents.FindByName(SlaveDoorName)[1]

		--MsgN(SlaveDoorEntity:GetName())

		if IsValid(SlaveDoorEntity) then

			SlaveDoorEntity:Fire(InputType)
			SlaveDoorEntity:SetNWBool("bWasLocked", bNewLockState)
		end
	end
end

function GM:EntityTakeDamage(InEntity, InDamageInfo)

	--MsgN("EntityTakeDamage()")

	if InEntity:IsPlayer() then

		HandlePlayerTakeDamage(InEntity, InDamageInfo)
	end

	if InEntity:GetNWBool("bCrowbarOnly") then

		local AttackerEntity = InDamageInfo:GetAttacker()

		if AttackerEntity == nil or AttackerEntity:GetActiveWeapon() == nil or AttackerEntity:GetActiveWeapon():GetClass() ~= "weapon_crowbar" then
			
			--Block damage
			return true
		end
	end
end

function GM:PostEntityTakeDamage(InEntity, InDamageInfo, bTookDamage)

	if InEntity:GetNWBool("bWasLocked") and math.random() < 0.35 then

		ChangeLockableState(InDamageInfo:GetAttacker(), InEntity, false)
	end
end
