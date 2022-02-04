---- Roleplay: Prison

local StashFrame = nil

local StashFrameWidth, StashFrameHeight = 300, 150

local function TryDrawStashData(InStashItemName, InStashItemNum)

	if InStashItemName ~= "" then

		local StashDataList = GetStashDataList()

		surface.SetDrawColor(255, 255, 255)

		surface.SetMaterial(StashDataList[InStashItemName].Icon)

		surface.DrawTexturedRect(30, 30, 70, 70)

		if InStashItemNum > 0 then

			draw.SimpleText(tostring(InStashItemNum), "HUDTextSmall", 65, 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end
end

function IsStashOpen()

	return IsValid(StashFrame)
end

local StashStackableDataList = {
	[1] = {Name = "DetailWoodNum", Icon = Material("vgui/rpp/icon_wood")},
	[2] = {Name = "DetailMetalNum", Icon = Material("vgui/rpp/icon_metal")},
	[3] = {Name = "PicklockNum", Icon = Material("vgui/rpp/icon_picklock")}
}

function ShowStash(InStashEntity)

	MsgN(Format("ShowStash() %s", InStashEntity))

	if IsStashOpen() then

		StashFrame:Remove()
	end

	local Client = LocalPlayer()

	StashFrame = vgui.Create("DFrame")

	StashFrame:SetSize(StashFrameWidth, StashFrameHeight)

	StashFrame:SetPos(ScrW() / 2 - 65, ScrH() / 2 - StashFrameHeight / 2)

	StashFrame:SetTitle("")

	StashFrame:MakePopup()

	StashFrame:SetAlpha(0)

	StashFrame:AlphaTo(255, 0.4, 0)

	StashFrame:SetDraggable(false)

	StashFrame:ShowCloseButton(false)

	StashFrame.Paint = function(self, w, h)
		
		
	end

	local ItemSlot = vgui.Create("DButton", StashFrame)

	ItemSlot:SetSize(130, 130)

	ItemSlot:SetPos(0, 0)

	ItemSlot:SetText("")

	ItemSlot.lerp = 0

	ItemSlot.Paint = function(self, w, h)

		DrawBlur(self, 6)

		if self:IsHovered() then

			self.lerp = Lerp(FrameTime() * 15, self.lerp, 200)
		else
			self.lerp = Lerp(FrameTime() * 15, self.lerp, 100)
		end
		
		draw.RoundedBoxEx(10, 0, 0, w, h, Color(0, 0, 0, 200), true, true, true, true)

		draw.RoundedBoxEx(10, 0, 0, 130, 130, Color(90, 90, 90, self.lerp), true, true, true, true)

		draw.RoundedBoxEx(10, 5, 5, 120, 120, Color(0, 0, 0, 200), true, true, true, true)
	
		TryDrawStashData(InStashEntity:GetNWString("StashItemName"), InStashEntity:GetNWInt("StashItemNum"))
	end

	ItemSlot.DoClick = function(self)

		if CanPickItemFromStash(Client, InStashEntity) then

			net.Start("SendTryInteractStashToServer")

			net.WriteInt(InStashEntity:EntIndex(), 32)

			net.WriteBool(true)

			net.SendToServer()
		end
	end

	for Index, StackableData in ipairs(StashStackableDataList) do

		local StackableButton = vgui.Create("DButton", StashFrame)

		StackableButton:SetSize(40, 40)

		StackableButton:SetPos(100 + 50 * Index, StashFrameHeight / 2 - 40)

		StackableButton:SetText("")

		StackableButton.lerp = 0

		StackableButton.Paint = function(self, w, h)

			draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 200))

			if self:IsHovered() then

				self.lerp = Lerp(FrameTime() * 15, self.lerp, 255)
			else
				self.lerp = Lerp(FrameTime() * 15, self.lerp, 200)
			end
			
			surface.SetDrawColor(ColorAlpha(COLOR_YELLOW, self.lerp))

			surface.SetMaterial(StackableData.Icon)

			surface.DrawTexturedRect(0, 0, w, h)
		end

		StackableButton.DoClick = function()

			if CanAddStackableToStash(Client, InStashEntity, StackableData.Name) then

				net.Start("SendTryInteractStashToServer")

				net.WriteInt(InStashEntity:EntIndex(), 32)

				net.WriteBool(false)

				net.WriteString(StackableData.Name)

				--MsgN("DoClick", InStashEntity:EntIndex(), StackableData.Name)

				net.SendToServer()

				--SendDoAnimationToServer(ACT_GMOD_GESTURE_ITEM_PLACE)
			end

			print("Клик")
		end
	end

	local ButtonWeaponItem = vgui.Create("DButton", StashFrame)

	ButtonWeaponItem:SetSize(140, 40)

	ButtonWeaponItem:SetPos(150, StashFrameHeight / 2)

	ButtonWeaponItem:SetText("")

	ButtonWeaponItem.lerp = 0

	ButtonWeaponItem.Paint = function(self, w, h)

		draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 200))

		if self:IsHovered() then

			self.lerp = Lerp(FrameTime() * 15, self.lerp, 255)
		else
			self.lerp = Lerp(FrameTime() * 15, self.lerp, 200)
		end
		
		draw.SimpleText(UtilLocalizable("RPP_UI.StashWeapon"), "HUDTextSmall",
			w / 2, h / 2, ColorAlpha(COLOR_YELLOW, self.lerp), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	ButtonWeaponItem.DoClick = function()

		if CanAddWeaponToStash(Client, InStashEntity) then

			net.Start("SendTryInteractStashToServer")

			MsgN(InStashEntity:EntIndex())

			net.WriteInt(InStashEntity:EntIndex(), 32)

			net.WriteBool(false)

			net.WriteString("Weapon")

			net.SendToServer()

			--SendDoAnimationToServer(ACT_GMOD_GESTURE_ITEM_PLACE)
		end

		print("Клик")
	end

	local CloseButton = vgui.Create("DButton", StashFrame)

	CloseButton:SetSize(130, 20)

	CloseButton:SetPos(0, 130)

	CloseButton:SetText("")

	CloseButton:SetAlpha(155)

	CloseButton.lerp = 0

	CloseButton.Paint = function(self, w, h)

		if self:IsHovered() then

			self.lerp = Lerp(FrameTime() * 6, self.lerp, 200)

			draw.RoundedBoxEx(10, 0, 0, w, h, Color(220, 20, 60, self.lerp), true, true, true, true)
		else
			self.lerp = Lerp(FrameTime() * 6, self.lerp, 100)

			draw.RoundedBoxEx(10, 0, 0, w, h, Color(220, 20, 60, self.lerp), true, true, true, true)
		end

		draw.SimpleText("Закрыть", "HUDTextSmall", 65, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	CloseButton.DoClick = function()

		HideStash()
	end
end

function HideStash()

	if IsStashOpen() then

		StashFrame:AlphaTo(0, 0.4, 0)

		timer.Simple(0.4, function()

			StashFrame:Remove()
		end)
	end
end
