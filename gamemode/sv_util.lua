---- Roleplay: Prison

--local AccountingTaskList = {"Computer", "Files"}

--[[function UtilGetRandomAccountingTask()

	return table.Random(AccountingTaskList)
end]]

function UtilGetRoutineDelay()

	return math.random(GetConVar("sk_routine_delay_min"):GetInt(), GetConVar("sk_routine_delay_max"):GetInt())
end

function UtilGetRoutineTimeout()

	return GetConVar("sk_routine_timeout"):GetInt()
end

function UtilGetGuardRoutineDuration()

	return GetConVar("sk_guard_routine_duration"):GetInt()
end

function UtilGetOfficerRoutineDuration()

	return GetConVar("sk_officer_routine_duration"):GetInt()
end

function UtilGetOfficerPunishmentDuration()

	return GetConVar("sk_officer_punishment_duration"):GetInt()
end

function UtilGetRobberWorkDuration()

	return GetConVar("sk_robber_work_duration"):GetInt()
end

function UtilGetRobberWorkBuffMultiplier()

	return GetConVar("sk_robber_work_buff_multiplier"):GetFloat()
end

function UtilGetDetailPickupDuration()

	return GetConVar("sk_detail_pickup_duration"):GetInt()
end

function UtilGetServerSabotageDuration()

	return GetConVar("sk_server_sabotage_duration"):GetInt()
end

function UtilGetServerRepairDuration()

	return GetConVar("sk_server_repair_duration"):GetInt()
end

function UtilGetToggleLockDuration()

	return GetConVar("sk_toggle_lock_duration"):GetInt()
end

function UtilGetPicklockUseDuration()

	return GetConVar("sk_picklock_use_duration"):GetInt()
end

function UtilGetPicklockOpenChance()

	return GetConVar("sk_picklock_open_chance"):GetFloat()
end

function UtilGetPicklockBreakChance()

	return GetConVar("sk_picklock_break_chance"):GetFloat()
end

function UtilGetHandcuffsOnDuration()

	return GetConVar("sk_handcuffs_on_duration"):GetInt()
end

function UtilGetHandcuffsOffDuration()

	return GetConVar("sk_handcuffs_off_duration"):GetInt()
end

function UtilGetInspectionDuration()

	return GetConVar("sk_inspection_duration"):GetInt()
end

function UtilCheckPlayerInArea(InPlayer, InArea)

	if IsValid(InArea) then

		local PlayerPos = InPlayer:GetPos()

		local AreaPos = InArea:GetPos()

		local AreaBoundMin, AreaBoundMax = InArea:GetCollisionBounds()

		--MsgN(InArea:GetName(), AreaBoundMin, AreaBoundMax)

		--MsgN(PlayerPos:WithinAABox(AreaPos + AreaBoundMin, AreaPos + AreaBoundMax))

		if PlayerPos:WithinAABox(AreaPos + AreaBoundMin, AreaPos + AreaBoundMax) then

			return true
		end
	end

	return false
end

function UtilChangePlayerFreeze(InPlayer, bAddFreeze)

	InPlayer.FreezeNum = InPlayer.FreezeNum or 0

	if bAddFreeze then

		InPlayer.FreezeNum = InPlayer.FreezeNum + 1
	else

		InPlayer.FreezeNum = InPlayer.FreezeNum - 1
	end

	if InPlayer.FreezeNum <= 0 then

		InPlayer.FreezeNum = 0

		InPlayer:Freeze(false)
	else

		InPlayer:Freeze(true)
	end
end
