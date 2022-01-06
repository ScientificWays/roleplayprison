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
