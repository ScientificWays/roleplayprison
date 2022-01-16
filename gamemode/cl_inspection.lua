---- Roleplay: Prison

local InspectionFrame = nil

local InspectionFrameWidth = 500

function ShowInspection(InInspectDataTable)

	if IsValid(InspectionFrame) then

		InspectionFrame:Remove()
	end

	InspectionFrame = vgui.Create("DFrame")

	local InspectionFrameHeight = 150 + #InInspectDataTable.IllegalWeaponNameList * 20

	InspectionFrame:SizeTo(InspectionFrameWidth, InspectionFrameHeight, 1.5, 0, 0.1)

	InspectionFrame:SetPos(ScrW() / 2 - InspectionFrameWidth / 2, ScrH() / 2 - InspectionFrameHeight / 2)

	InspectionFrame:SetTitle("")

	InspectionFrame:SetDraggable(false)

	InspectionFrame:ShowCloseButton(true)

	InspectionFrame:MakePopup()

	InspectionFrame.Paint = function(self, w, h)

		DrawBlur(self, 3)

		draw.RoundedBoxEx(10, 0, 0, w, h, Color(0, 0, 0, 200), true, true, true, true)

		draw.SimpleText('Досмотр', 'title',
			InspectionFrameWidth / 2, 12, Color(255, 255, 255, 255),
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.RoundedBoxEx(0, 0, 20, w, 5, Color(255, 255, 255), true, true, true, true)
	end

	DetailWoodInfo = vgui.Create("DLabel", InspectionFrame)

	DetailWoodInfo:SetPos(50, 50)

	DetailWoodInfo:SetSize(InspectionFrameWidth - 50, 20)

	DetailWoodInfo:SetFont("txt")

	DetailWoodInfo:SetText(string.format("Деревянные детали: %i", InInspectDataTable.DetailWoodNum))

	DetailMetalInfo = vgui.Create("DLabel", InspectionFrame)

	DetailMetalInfo:SetPos(50, 70)

	DetailMetalInfo:SetSize(InspectionFrameWidth - 50, 20)

	DetailMetalInfo:SetFont("txt")

	DetailMetalInfo:SetText(string.format("Металлические детали: %i", InInspectDataTable.DetailMetalNum))

	for Index, PrintName in ipairs(InInspectDataTable.IllegalWeaponNameList) do

		local IllegalWeaponInfo = vgui.Create("DLabel", InspectionFrame)

		IllegalWeaponInfo:SetPos(50, 80 + Index * 20)

		IllegalWeaponInfo:SetSize(InspectionFrameWidth - 50, 20)

		IllegalWeaponInfo:SetFont("txt")

		IllegalWeaponInfo:SetText(string.format("Нелегальное оружие: %s", language.GetPhrase(PrintName)))
	end
end

function HideInspection()

	if IsValid(InspectionFrame) then

		MsgN("Valid InspectionFrame")

		InspectionFrame:SizeTo(0, 0, 0.9, 0.2, 0.1)

		timer.Simple(0.7, function()

			InspectionFrame:Remove()

			InspectionFrame = nil
		end)
	end
end
