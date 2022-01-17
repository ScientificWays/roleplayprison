---- Roleplay: Prison

local WorkbenchFrame = nil

local WorkbenchFrameWidth, WorkbenchFrameHeight = 600, 600

function IsWorkbenchOpen()

	return IsValid(WorkbenchFrame)
end

function ShowWorkbenchFrame()

	if IsWorkbenchOpen() then

		return
	end

	WorkbenchFrame = vgui.Create("DFrame")

	WorkbenchFrame:SetSize(WorkbenchFrameWidth, WorkbenchFrameHeight)

	WorkbenchFrame:SetPos(ScrW() / 2 - WorkbenchFrameWidth / 2, ScrH() / 2 - WorkbenchFrameHeight / 2)

	WorkbenchFrame:SetTitle("")

	WorkbenchFrame:MakePopup()

	WorkbenchFrame:SetAlpha(0)

	WorkbenchFrame:AlphaTo(255, 0.4, 0)

	WorkbenchFrame:SetDraggable(false)

	WorkbenchFrame:ShowCloseButton(false)

	WorkbenchFrame.Paint = function(self, w, h) end

	local LastSelectedItem = nil

	local CraftDataList = GetCraftDataList()

	for Index, ItemData in ipairs(CraftDataList) do

		local CraftItem = vgui.Create("DButton", WorkbenchFrame)

		CraftItem:SetSize(130, 130)

		CraftItem:SetPos(20, (Index - 1) * 180)

		CraftItem:SetText("")

		CraftItem.Paint = function(self, w, h)

			DrawBlur(self, 6)

			draw.RoundedBoxEx(10, 0, 0, w, h, Color(0, 0, 0, 200), true, true, true, true)

			draw.RoundedBoxEx(10, 0, 0, 130, 130, Color(90, 90, 90, 200), true, true, true, true)

			draw.RoundedBoxEx(10, 5, 5, 120, 120, Color(0, 0, 0, 200), true, true, true, true)

			draw.SimpleText(ItemData.PrintName, "msg", 65, 110, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(255, 255, 255)

			surface.SetMaterial(ItemData.Icon)

			surface.DrawTexturedRect(30, 30, 70, 70)
		end

		CraftItem.DoClick = function(self)

			if IsValid(LastSelectedItem) then

				LastSelectedItem:SizeTo(130, 130, 0.3, 0, 0.2)

				if LastSelectedItem == self then

					LastSelectedItem = nil

					return
				end
			end

			LastSelectedItem = self

			self:SizeTo(400, 130, 0.3, 0, -1)

			local RecipePanel = vgui.Create("DButton", CraftItem)

			RecipePanel:SetSize(270, 130)

			RecipePanel:SetPos(130, 0)

			RecipePanel:SetText("")

			RecipePanel.lerp = 0

			RecipePanel.Paint = function(self, w, h)

				if self:IsHovered() then

					self.lerp = Lerp(FrameTime() * 15, self.lerp, 255)
				else
					self.lerp = Lerp(FrameTime() * 15, self.lerp, 100)
				end
				
				local Client = LocalPlayer()

				draw.SimpleText(string.format("Деревянные детали: %i/%i", Client:GetNWInt("DetailWoodNum"), ItemData.Wood),
					"HUDTextSmall", 20, h / 2 - 20, ColorAlpha(COLOR_WHITE, self.lerp), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				draw.SimpleText(string.format("Металлически детали: %i/%i", Client:GetNWInt("DetailMetalNum"), ItemData.Metal),
					"HUDTextSmall", 20, h / 2 + 20, ColorAlpha(COLOR_WHITE, self.lerp), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			RecipePanel.DoClick = function()

				--Kind of prediction logic
				if CanCraftRoleplayItem(LocalPlayer(), ItemData) then

					ClientSendTryCraftItem(ItemData.Name)

					RecipePanel:Remove()

					LastSelectedItem:SizeTo(130, 130, 0.3, 0, 0.2)

					surface.PlaySound("items/ammo_pickup.wav")
				end

				MsgN("Клик")
			end
		end
	end

	local CloseButton = vgui.Create("DButton", WorkbenchFrame)

	CloseButton:SetSize(130, 50)

	CloseButton:SetPos(20, #CraftDataList * 180)

	CloseButton:SetText("")

	CloseButton:SetAlpha(155)

	CloseButton.lerp = 0

	CloseButton.Paint = function(self, w, h)

		draw.RoundedBoxEx(10, 0, 0, w, h, Color(220, 20, 60), true, true, true, true)

		draw.SimpleText("Закрыть", "HUDTextSmall", 65, 25, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	CloseButton.DoClick = function()

		HideWorkbenchFrame()
	end 
end

function HideWorkbenchFrame()

	if not IsWorkbenchOpen() then

		return
	end

	WorkbenchFrame:AlphaTo(0, 0.4, 0)

	timer.Simple(0.4, function()

		WorkbenchFrame:Remove()

		WorkbenchFrame = nil
	end)
end
