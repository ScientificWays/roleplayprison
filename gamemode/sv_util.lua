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
