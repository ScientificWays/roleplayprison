---- Roleplay: Prison

local MonitorOfficerRT = GetRenderTarget("_rt_MonitorOfficer", 2048, 2048)
local MonitorControlRT = GetRenderTarget("_rt_MonitorControl", 2048, 2048)
local MonitorLibraryRT = GetRenderTarget("_rt_MonitorLibrary", 2048, 2048)

--local MonitorRTTexture = Material("models/rendertarget"):GetTexture("$basetexture")

function GM:PostRenderVGUI()

	local Client = LocalPlayer()

	if engine.TickCount() % 60 == 0 then

		local ActiveMonitorType = Client:GetNWString("ActiveMonitorType")

		if ActiveMonitorType ~= "None" then

			if ActiveMonitorType == "Officer" then

				OfficerMonitorDraw()

			elseif ActiveMonitorType == "Control" then

				ControlMonitorDraw()

			elseif ActiveMonitorType == "Library" then

				LibraryMonitorDraw()
			end
		end
	end
end

function OfficerMonitorDraw()

	render.PushRenderTarget(MonitorOfficerRT)

	render.Clear(0, 0, 20, 255)

	draw.DrawText(string.ToMinutesSeconds(UtilGetLeftCycleTimeSeconds()), "MonitorText", 850, 10, COLOR_WHITE, TEXT_ALIGN_CENTER)

	if UtilIsInterCycle() then

		draw.DrawText("Перерыв", "MonitorText", 850, 380, COLOR_WHITE, TEXT_ALIGN_CENTER)

	else
		surface.SetFont("MonitorText")

		local ScheduleList = GetReplicatedScheduleList()

		if table.IsEmpty(ScheduleList) then

			draw.DrawText("Расписание не обнаружено", "MonitorText", 850, 380, COLOR_RED, TEXT_ALIGN_CENTER)
		else

			local ElementY = 150

			local ActiveElementIndex, ActiveElementTimeLeft = UtilGetActiveScheduleElementIndexAndTimeLeft(ScheduleList)

			--MsgN(table.ToString(ScheduleList))

			for i, ScheduleElement in ipairs(ScheduleList) do

				local RowText = ""

				local RowColor = COLOR_WHITE

				if (i == ActiveElementIndex) then

					RowText = string.format("%s [%s]", ScheduleElement.Name, string.ToMinutesSeconds(ActiveElementTimeLeft))

					RowColor = COLOR_BLUE
				else

					RowText = ScheduleElement.Name

					RowColor = COLOR_WHITE
				end

				draw.DrawText(RowText, "MonitorTextSmall", 40, ElementY, RowColor, TEXT_ALIGN_LEFT)

				ElementY = ElementY + 70
			end
		end
	end

	render.PopRenderTarget()
end

function ControlMonitorDraw()

	render.PushRenderTarget(MonitorControlRT)

	render.Clear(0, 0, 20, 255)

	draw.DrawText(string.ToMinutesSeconds(UtilGetLeftCycleTimeSeconds()), "MonitorText", 850, 10, COLOR_WHITE, TEXT_ALIGN_CENTER)

	if UtilIsInterCycle() then

		draw.DrawText("Перерыв", "MonitorText", 850, 380, COLOR_WHITE, TEXT_ALIGN_CENTER)

	else
		surface.SetFont("MonitorText")

		local ScheduleList = GetReplicatedScheduleList()

		if table.IsEmpty(ScheduleList) then

			draw.DrawText("Расписание не обнаружено", "MonitorText", 850, 380, COLOR_RED, TEXT_ALIGN_CENTER)
		else

			local ActiveElementIndex, ActiveElementTimeLeft = UtilGetActiveScheduleElementIndexAndTimeLeft(ScheduleList)

			draw.DrawText(ScheduleList[ActiveElementIndex].Name, "MonitorText", 850, 350, COLOR_BLUE, TEXT_ALIGN_CENTER)

			draw.DrawText(string.format("[%s]",
				string.ToMinutesSeconds(ActiveElementTimeLeft)),
				"MonitorTextSmall", 850, 470, COLOR_WHITE, TEXT_ALIGN_CENTER)
		end
	end

	render.PopRenderTarget()
end

function LibraryMonitorDraw()

	render.PushRenderTarget(MonitorLibraryRT)

	render.Clear(0, 0, 20, 255)

	if UtilIsInterCycle() then

		draw.DrawText("Перерыв", "MonitorText", 850, 380, COLOR_WHITE, TEXT_ALIGN_CENTER)
	else

		draw.DrawText(string.ToMinutesSeconds(UtilGetLeftCycleTimeSeconds()),
			"MonitorText", 850, 380, COLOR_WHITE, TEXT_ALIGN_CENTER)
	end

	render.PopRenderTarget()
end