---- Roleplay: Prison

local MonitorFrame = {}

local MonitorFrameWidth, MonitorFrameHeight = 320, 160

local MonitorDrawFunction = nil

timer.Create("MonitorTick", 1.0, 0, function()

	local Client = LocalPlayer()

	if not IsValid(Client) then

		return
	end

	local ActiveMonitorType = Client:GetNWString("ActiveMonitorType")

	if ActiveMonitorType == "None" then

		HideMonitor()
	else
		if ActiveMonitorType == "Officer" then

			MonitorDrawFunction = OfficerMonitorDraw

		elseif ActiveMonitorType == "Control" then

			MonitorDrawFunction = ControlMonitorDraw

		elseif ActiveMonitorType == "Library" then

			MonitorDrawFunction = LibraryMonitorDraw
		end

		ShowMonitor()
	end

	MsgN(ActiveMonitorType)
end)

function OfficerMonitorDraw()

	--MsgN("OfficerMonitorDraw()")

	draw.SimpleText(string.ToMinutesSeconds(UtilGetLeftCycleTimeSeconds()),
		"MonitorText", MonitorFrameWidth * 0.5, 10, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	if UtilIsInterCycle() then

		draw.SimpleText(UtilLocalizable("RPP_UI.MonitorBreak"), "MonitorText",
			MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	else
		surface.SetFont("MonitorText")

		local ScheduleList = GetReplicatedScheduleList()

		if table.IsEmpty(ScheduleList) then

			draw.SimpleText(UtilLocalizable("RPP_UI.MonitorNoSchedule"), "MonitorTextSmall",
				MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			local ActiveElementIndex, ActiveElementTimeLeft = UtilGetActiveScheduleElementIndexAndTimeLeft(ScheduleList)

			--MsgN(table.ToString(ScheduleList))

			local ElementY = 50

			for Index, ScheduleElement in ipairs(ScheduleList) do

				if math.abs(ActiveElementIndex - Index) < 3 then

					local RowText = ""

					local RowColor = COLOR_WHITE

					if (Index == ActiveElementIndex) then

						RowText = Format("%s [%s]", ScheduleElement.Name, string.ToMinutesSeconds(ActiveElementTimeLeft))

						RowColor = COLOR_BLUE
					else

						RowText = ScheduleElement.Name

						RowColor = COLOR_WHITE
					end

					draw.SimpleText(RowText, "MonitorTextSmall",
						10, ElementY, RowColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					ElementY = ElementY + 20
				end
			end
		end
	end
end

function ControlMonitorDraw()

	draw.SimpleText(string.ToMinutesSeconds(UtilGetLeftCycleTimeSeconds()), "MonitorText",
		MonitorFrameWidth * 0.5, 10, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	if UtilIsInterCycle() then

		draw.SimpleText(UtilLocalizable("RPP_UI.MonitorBreak"), "MonitorText",
			MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	else
		surface.SetFont("MonitorText")

		local ScheduleList = GetReplicatedScheduleList()

		if table.IsEmpty(ScheduleList) then

			draw.SimpleText(UtilLocalizable("RPP_UI.MonitorNoSchedule"), "MonitorTextSmall",
				MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else

			local ActiveElementIndex, ActiveElementTimeLeft = UtilGetActiveScheduleElementIndexAndTimeLeft(ScheduleList)

			draw.SimpleText(ScheduleList[ActiveElementIndex].Name, "MonitorText",
				MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5 - 10, COLOR_BLUE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.SimpleText(Format("[%s]", string.ToMinutesSeconds(ActiveElementTimeLeft)), "MonitorTextSmall",
				MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5 + 20, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

function LibraryMonitorDraw()

	if UtilIsInterCycle() then

		draw.SimpleText(UtilLocalizable("RPP_UI.MonitorBreak"), "MonitorText",
			MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else

		draw.SimpleText(string.ToMinutesSeconds(UtilGetLeftCycleTimeSeconds()), "MonitorText",
			MonitorFrameWidth * 0.5, MonitorFrameHeight * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function IsMonitorOpen()

	return IsValid(MonitorFrame)
end

function ShowMonitor()

	if IsMonitorOpen() then
		
		return
	end

	MsgN("ShowMonitor()")

	MonitorFrame = vgui.Create("DFrame")

	MonitorFrame:SetSize(MonitorFrameWidth, MonitorFrameHeight)

	MonitorFrame:SetPos(ScrW() - MonitorFrameWidth - 15, 15)

	MonitorFrame:SetTitle("")

	--MonitorFrame:MakePopup()

	MonitorFrame:SlideDown(0.3)

	MonitorFrame:SetAlpha(0)

	MonitorFrame:AlphaTo(255, 0.4, 0)

	MonitorFrame:SetDraggable(false)

	MonitorFrame:ShowCloseButton(false)

	MonitorFrame.Paint = function(self, w, h)

		DrawBlur(self, 3)

		draw.RoundedBoxEx(10, 0, 0, w, h, Color(0, 0, 0, 200), true, true, true, true)

		if MonitorDrawFunction ~= nil then

			--MsgN("MonitorDrawFunction")

			MonitorDrawFunction()
		end
	end
end

function HideMonitor()

	if not IsMonitorOpen() then
		
		return
	end

	MsgN("HideMonitor()")

	MonitorFrame:SlideUp(0.3)

	timer.Simple(0.4, function()

		MonitorFrame:Remove()

		MonitorFrame = nil

		MonitorDrawFunction = nil
	end)
end

concommand.Add('debug_timetable', function() ShowTimeTable('0:01', 'Перерыв') end)