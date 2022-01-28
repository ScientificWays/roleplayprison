---- Roleplay: Prison

local VoiceNotifyPanel = {}
local PlayerVoicePanels = {}

local TalkieIcon = Material("vgui/rpp/icon_talkie")

function VoiceNotifyPanel:Init()

	self.LabelName = vgui.Create("DLabel", self)

	self.LabelName:SetFont("GModNotify")

	self.LabelName:Dock(FILL)

	self.LabelName:DockMargin(8, 0, 0, 0)

	self.LabelName:SetTextColor(COLOR_WHITE)

	self.Icon = vgui.Create("DImage", self)

	self.Icon:Dock(LEFT)

	self.Icon:SetSize(32, 32)

	self.Color = COLOR_TRANSPARENT

	self:SetSize(250, 32 + 8)

	self:DockPadding(4, 4, 4, 4)

	self:DockMargin(2, 2, 2, 2)

	self:Dock(BOTTOM)
end

function VoiceNotifyPanel:Setup(InPlayer)

	self.Player = InPlayer

	self.LabelName:SetText(UtilGetPlayerFullRPName(self.Player))

	self.Icon:SetMaterial(TalkieIcon)
	
	self.Color = team.GetColor(self.Player:Team())
	
	self:InvalidateLayout()
end

function VoiceNotifyPanel:Paint(w, h)

	if IsValid(self.Player) then

		draw.RoundedBox(4, 0, 0, w, h, Color(0, self.Player:VoiceVolume() * 255, 0, 240))
	end
end

function VoiceNotifyPanel:Think()

	if IsValid(self.Player) then

		self.LabelName:SetText(UtilGetPlayerFullRPName(self.Player))
	end

	if self.fadeAnim then

		self.fadeAnim:Run()
	end

end

function VoiceNotifyPanel:FadeOut(anim, delta, data)
	
	if (anim.Finished) then
	
		if (IsValid(PlayerVoicePanels[ self.Player ])) then
			PlayerVoicePanels[ self.Player ]:Remove()
			PlayerVoicePanels[ self.Player ] = nil
			return
		end
		
	return end
	
	self:SetAlpha(255 - (255 * delta))

end

derma.DefineControl("VoiceNotify", "", VoiceNotifyPanel, "DPanel")

function GM:PlayerStartVoice(InPlayer)

	local Client = LocalPlayer()

	if UtilCanHearByTalkie(Client, InPlayer) then

		self.BaseClass:PlayerStartVoice(InPlayer)
	end
end

--[[function GM:PlayerEndVoice(InPlayer)

	return
end--]]