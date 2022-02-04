---- Roleplay: Prison

local ScheduleFrame = {}

local RecommendedScheduleElements = {["Обход камер"] = 4,
									["Перекличка"] = 5,
									["Столовая"] = 6,
									["Отдых"] = 5,
									["Работа"] = 10,
									["Душ"] = 6,
									["Мини-игры"] = 15}

local PanelScheduleElementList = {}

local NextCycleScheduleElementList = {}

local function GetScheduleElementsDurationMinutes()

	local OutDuration = 0

	for i, ScheduleElementInfo in ipairs(NextCycleScheduleElementList) do

		OutDuration = OutDuration + ScheduleElementInfo.DurationMinutes
	end

	return OutDuration
end

local function AddScheduleElementToList(InName, InDuration)

	table.insert(NextCycleScheduleElementList, {Name = InName, DurationMinutes = InDuration})
end

local function RemoveScheduleElementFromList(InIndex)

	table.remove(NextCycleScheduleElementList, InIndex)
end

--[[Move up means make it earlier]]
local function MoveScheduleElementUp(InIndex)

	local CurrentElement = NextCycleScheduleElementList[InIndex]

	NextCycleScheduleElementList[InIndex] = NextCycleScheduleElementList[InIndex - 1]

	NextCycleScheduleElementList[InIndex - 1] = CurrentElement
end

--[[Move down means make it later]]
local function MoveScheduleElementDown(InIndex)

	local CurrentElement = NextCycleScheduleElementList[InIndex]

	NextCycleScheduleElementList[InIndex] = NextCycleScheduleElementList[InIndex + 1]

	NextCycleScheduleElementList[InIndex + 1] = CurrentElement
end

local function UpdateScheduleList()

	--MsgN("UpdateScheduleList()")

	for i, PanelElement in ipairs(PanelScheduleElementList) do

		PanelElement:Remove()
	end

	table.Empty(PanelScheduleElementList)

	--MsgN(table.ToString(NextCycleScheduleElementList))

	local bCanAccept = false

	if table.IsEmpty(NextCycleScheduleElementList) then

		local InfoLabel = vgui.Create("DLabel", ScheduleFrame)

		InfoLabel:SetPos(260, 150)

		InfoLabel:SetSize(150, 25)

		InfoLabel:SetText(UtilLocalizable("RPP_UI.ScheduleHint"))

		table.insert(PanelScheduleElementList, InfoLabel)
	else
		local y = 75

		for Index, ScheduleElementInfo in ipairs(NextCycleScheduleElementList) do

			local ScheduleElement = vgui.Create("DButton", ScheduleFrame)

			ScheduleElement:SetPos(220, y)

			ScheduleElement:SetSize(150, 20)

			ScheduleElement:SetText(Format("%s (%i мин)", ScheduleElementInfo.Name, ScheduleElementInfo.DurationMinutes))

			table.insert(PanelScheduleElementList, ScheduleElement)
			
			if Index > 1 then

				local ScheduleElementUp = vgui.Create("DImageButton", ScheduleFrame)

				ScheduleElementUp:SetPos(370, y)

				ScheduleElementUp:SetSize(20, 20)

				ScheduleElementUp:SetImage("icon16/arrow_up.png")

				function ScheduleElementUp.DoClick()

					MoveScheduleElementUp(Index)

					UpdateScheduleList()
				end

				table.insert(PanelScheduleElementList, ScheduleElementUp)
			end

			if Index < #NextCycleScheduleElementList then

				local ScheduleElementDown = vgui.Create("DImageButton", ScheduleFrame)

				ScheduleElementDown:SetPos(390, y)

				ScheduleElementDown:SetSize(20, 20)

				ScheduleElementDown:SetImage("icon16/arrow_down.png")

				function ScheduleElementDown.DoClick()

					MoveScheduleElementDown(Index)

					UpdateScheduleList()
				end

				table.insert(PanelScheduleElementList, ScheduleElementDown)
			end

			local ScheduleElementRemove = vgui.Create("DImageButton", ScheduleFrame)

			ScheduleElementRemove:SetPos(410, y)

			ScheduleElementRemove:SetSize(20, 20)

			ScheduleElementRemove:SetImage("icon16/cross.png")

			function ScheduleElementRemove.DoClick()

				RemoveScheduleElementFromList(Index)

				UpdateScheduleList()
			end

			table.insert(PanelScheduleElementList, ScheduleElementRemove)

			y = y + 30
		end

		local TimeLabel = vgui.Create("DLabel", ScheduleFrame)

		TimeLabel:SetPos(220, y)

		TimeLabel:SetSize(150, 25)

		local ElementsDurationMinutes = GetScheduleElementsDurationMinutes()

		local RequiredDurationMinutes = UtilGetCycleDurationMinutes(false)

		bCanAccept = ElementsDurationMinutes == RequiredDurationMinutes

		TimeLabel:SetText(Format(UtilLocalizable("RPP_UI.ScheduleCompletion"), ElementsDurationMinutes, RequiredDurationMinutes))

		table.insert(PanelScheduleElementList, TimeLabel)
	end

	local ConfirmElementButton = vgui.Create("DButton", ScheduleFrame)

	ConfirmElementButton:SetPos(320, 30)

	ConfirmElementButton:SetSize(120, 25)

	ConfirmElementButton:SetText(UtilLocalizable("RPP_UI.ScheduleAccept"))

	function ConfirmElementButton.DoClick()

		ClientSendScheduleList(NextCycleScheduleElementList)

		table.Empty(NextCycleScheduleElementList)

		HideScheduleSetup()
	end

	ConfirmElementButton:SetEnabled(bCanAccept)
end

function IsScheduleOpen()

	return IsValid(ScheduleFrame)
end

function ShowScheduleSetup()

	if IsScheduleOpen() then

		return
	end
	
	ScheduleFrame = vgui.Create("DFrame")

	ScheduleFrame:SetTitle(UtilLocalizable("RPP_UI.ScheduleSetup"))
	
	local ScheduleNameEntry = vgui.Create("DTextEntry", ScheduleFrame)
	
	ScheduleNameEntry:SetPos(10, 30)

	ScheduleNameEntry:SetSize(150, 25)

	local ScheduleDurationEntry = vgui.Create("DNumberWang", ScheduleFrame)
	
	ScheduleDurationEntry:SetPos(150, 30)

	ScheduleDurationEntry:SetSize(50, 25)

	local y = 75

	--MsgN(table.ToString(RecommendedScheduleElements))

	for RecommendedElementName, RecommendedElementDuration in pairs(RecommendedScheduleElements) do
	
		local RecommendedElement = vgui.Create("DButton", ScheduleFrame)

		--print(RecommendedElementName, RecommendedElementDuration)

		function RecommendedElement.DoClick()

			ScheduleNameEntry:SetValue(RecommendedElementName)

			ScheduleDurationEntry:SetValue(RecommendedElementDuration)
		end

		RecommendedElement:SetPos(10, y)

		RecommendedElement:SetSize(190, 20)

		RecommendedElement:SetText(Format(UtilLocalizable("RPP_UI.ScheduleRecommended"), RecommendedElementName, RecommendedElementDuration))
			
		y = y + 30
	end

	local AddElementButton = vgui.Create("DButton", ScheduleFrame)

	AddElementButton:SetPos(200, 30)

	AddElementButton:SetSize(120, 25)

	AddElementButton:SetText(UtilLocalizable("RPP_UI.ScheduleAdd"))

	function AddElementButton.DoClick()

		AddScheduleElementToList(ScheduleNameEntry:GetValue(), ScheduleDurationEntry:GetValue())

		UpdateScheduleList()
	end

	ScheduleFrame:SetSize(450, y)

	ScheduleFrame:Center()

	ScheduleFrame:MakePopup()

	ScheduleFrame:SetKeyboardInputEnabled(true)

	function ScheduleFrame.OnClose()

		HideScheduleSetup()
	end

	UpdateScheduleList()
end

function HideScheduleSetup()

	if not IsScheduleOpen() then
		
		return
	end
	
	ScheduleFrame:Remove()

	ScheduleFrame = nil
end

function ToggleScheduleSetup()

	if (IsValid(ScheduleFrame)) then

		HideScheduleSetup()
	else

		ShowScheduleSetup()
	end
end
