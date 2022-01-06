---- Roleplay: Prison

function UtilGetActiveScheduleElementIndexAndTimeLeft(InList)

	--MsgN(table.ToString(InList))

	local AccumulatedTimeSeconds = 0

	for i, ScheduleElement in ipairs(InList) do

		local CurrentTimeSeconds = UtilGetCurrentCycleTimeSeconds()

		AccumulatedTimeSeconds = AccumulatedTimeSeconds + ScheduleElement.DurationMinutes * 60

		local CurrentTime = UtilGetCurrentCycleTimeSeconds()

		if AccumulatedTimeSeconds >= CurrentTime then

			return i, AccumulatedTimeSeconds - CurrentTime
		end
	end
end
