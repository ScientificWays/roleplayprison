---- Roleplay: Prison

local AnimationsFrame = nil

local AnimationsFrameWidth, AnimationsFrameHeight = 300, 800

local AnimationDataList = {
	{PrintName = "Согласиться", Gesture = ACT_GMOD_GESTURE_AGREE},
	{PrintName = "Отказаться", Gesture = ACT_GMOD_GESTURE_DISAGREE},
	{PrintName = "Подозвать", Gesture = ACT_GMOD_GESTURE_BECON},
	{PrintName = "Поклониться", Gesture = ACT_GMOD_GESTURE_BOW},
	{PrintName = "Приветствие", Gesture = ACT_GMOD_TAUNT_SALUTE},
	{PrintName = "Помахать", Gesture = ACT_GMOD_GESTURE_WAVE},
	{PrintName = "Цапля", Gesture = ACT_GMOD_TAUNT_PERSISTENCE},
	{PrintName = "Красоваться", Gesture = ACT_GMOD_TAUNT_MUSCLE},
	{PrintName = "Смеяться", Gesture = ACT_GMOD_TAUNT_LAUGH},
	{PrintName = "Радоваться", Gesture = ACT_GMOD_TAUNT_CHEER},
	{PrintName = "Танцевать", Gesture = ACT_GMOD_TAUNT_DANCE},
	{PrintName = "Танец робота", Gesture = ACT_GMOD_TAUNT_ROBOT},
	{PrintName = "Крик зомби", Gesture = ACT_GMOD_GESTURE_TAUNT_ZOMBIE},
	{PrintName = "Двигаемся", Gesture = ACT_SIGNAL_FORWARD},
	{PrintName = "Группироваться", Gesture = ACT_SIGNAL_GROUP},
	{PrintName = "Остановиться", Gesture = ACT_SIGNAL_HALT}
}

net.Receive("MulticastDoAnimation", function(InMessageLength, InPlayer)

	local Gesture = net.ReadInt(32)

	local PlayerEntityIndex = net.ReadInt(32)

	local bAutoKill = net.ReadBool()

	local Player = Entity(PlayerEntityIndex)

	MsgN(Format("%s %i", Player, Gesture))

	Player:AnimRestartGesture(GESTURE_SLOT_CUSTOM, Gesture, bAutoKill)
end)

function SendDoAnimationToServer(InGesture)

	local Client = LocalPlayer()

	net.Start("SendDoAnimationToServer")

	net.WriteInt(InGesture, 32)

	net.SendToServer()
end

function IsAnimationsOpen()

	return IsValid(AnimationsFrame)
end

function ShowAnimations()

	if IsAnimationsOpen() then

		return
	end

	AnimationsFrame = vgui.Create("DFrame")

	AnimationsFrame:SetSize(AnimationsFrameWidth, AnimationsFrameHeight)

	AnimationsFrame:SetPos(10, ScrH() / 2 - AnimationsFrameHeight / 2)

	AnimationsFrame:SetTitle("")

	AnimationsFrame:SetAlpha(0)

	AnimationsFrame:AlphaTo(255, 0.4, 0)

	AnimationsFrame:SetDraggable(false)

	AnimationsFrame:ShowCloseButton(false)

	AnimationsFrame:MakePopup()

	AnimationsFrame.Paint = function(self, w, h)

		DrawBlur(self, 3)

		draw.RoundedBoxEx(10, 0, 0, w, h, Color(0, 0, 0, 200), true, true, true, true)

		draw.SimpleText("Список анимаций", "HUDTextSmall", AnimationsFrameWidth / 2, 12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.RoundedBoxEx(0, 0, 25, w, 5, Color(255, 255, 255), true, true, true, true)
	end

	local AnimationsScrollPanel = vgui.Create("DScrollPanel", AnimationsFrame)

	AnimationsScrollPanel:Dock(FILL)

	local ScrollBar = AnimationsScrollPanel:GetVBar()

		ScrollBar.Paint = function()
	end

	function ScrollBar.btnUp:Paint(h,i)

		draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
	end
		
	function ScrollBar.btnDown:Paint(h,i)

		draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
	end

	function ScrollBar.btnGrip:Paint(h,i)

		draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
	end

	for Index, AnimationData in ipairs(AnimationDataList) do

		local AnimationButton = AnimationsScrollPanel:Add("DButton")

		AnimationButton:SetSize(AnimationsFrameWidth, 50)

		AnimationButton:Dock(TOP)

		AnimationButton:DockMargin(5, 5, 0, 5)

		AnimationButton:SetText("")

		AnimationButton.lerp = 0

		AnimationButton.Paint = function(self, w, h)

			draw.RoundedBoxEx(10, 0, 0, w, h, Color(30, 30, 30, 200), true, false, true, false)

			if self:IsHovered() then

				self.lerp = Lerp(FrameTime() * 6, self.lerp, 10)

				draw.RoundedBoxEx(10, 0, 0, self.lerp, h, Color(116, 0, 255, 255), true, false, true, false)
			else
				self.lerp = Lerp(FrameTime() * 6, self.lerp, 0)

				draw.RoundedBoxEx(10, 0, 0, self.lerp, h, Color(116, 0, 255, 255), true, false, true, false)
			end

			draw.SimpleText(AnimationData.PrintName, "HUDTextSmall", AnimationsFrameWidth / 2, 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		AnimationButton.DoClick = function()

			if UtilPlayerCanInteract(LocalPlayer()) then

				SendDoAnimationToServer(AnimationData.Gesture)

				HideAnimations(AnimationsFrame)
			else

				surface.PlaySound("buttons/button10.wav")
			end
		end

	end

	local CloseButton = vgui.Create("DButton", AnimationsFrame)

	CloseButton:SetSize(25, 25)

	CloseButton:SetPos(AnimationsFrameWidth - 25, 0)

	CloseButton:SetText("")

	CloseButton.lerp = 0

	CloseButton.Paint = function(self, w, h)

		if self:IsHovered() then
			self.lerp = Lerp(FrameTime() * 6, self.lerp, w)
			draw.RoundedBoxEx(10, 0, 0, self.lerp, h, Color(220, 20, 60), false, true, false, false)
		else
			self.lerp = Lerp(FrameTime() * 6, self.lerp, 0)
			draw.RoundedBoxEx(10, 0, 0, self.lerp, h, Color(220, 20, 60), false, true, false, false)
		end

		draw.SimpleText("X", "HUDTextSmall", 12, 12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end

	CloseButton.DoClick = function()

		HideAnimations()
	end
end


function HideAnimations()

	if IsAnimationsOpen() then

		AnimationsFrame:AlphaTo(0, 0.4, 0)

		timer.Simple(0.4, function()

			AnimationsFrame:Remove()

			AnimationsFrame = nil
		end)
	end
end
