---- Roleplay: Prison

local VoiceNotifyPanel = {}
local PlayerVoicePanels = {}

local IconTalkie			= Material("vgui/rpp/icon_talkie")
local IconGlobalSpeaker		= Material("icon16/sound.png")

function VoiceNotifyPanel:Init()

	self.LabelName = vgui.Create("DLabel", self)

	self.LabelName:SetFont("GModNotify")

	self.LabelName:Dock(FILL)

	self.LabelName:DockMargin(40, 0, 0, 0)

	self.LabelName:SetTextColor(COLOR_WHITE)

	self.Color = COLOR_TRANSPARENT

	self:SetSize(250, 32 + 8)

	self:DockPadding(4, 4, 4, 4)

	self:DockMargin(2, 2, 2, 2)

	self:Dock(BOTTOM)
end

function VoiceNotifyPanel:Setup(InPlayer)

	self.Player = InPlayer

	local RPName, RPSurname = UtilGetRPNameSurname(self.Player)

	self.LabelName:SetText(Format("%s %s", UtilLocalizable(RPName), UtilLocalizable(RPSurname)))

	local Client = LocalPlayer()

	self.Color = team.GetColor(self.Player:Team())
	
	self:InvalidateLayout()
end

function VoiceNotifyPanel:Paint(w, h)

	if IsValid(self.Player) then

		local bShowPanel = false

		local PlayerIcon = nil

		if UtilIsGlobalSpeakerEnabled() and self.Player:GetNWBool("bGlobalSpeaker") then

			bShowPanel = true

			PlayerIcon = IconGlobalSpeaker

		elseif UtilCanHearByTalkie(LocalPlayer(), self.Player) then

			bShowPanel = true

			PlayerIcon = IconTalkie

		elseif Client:EntIndex() == InPlayer:EntIndex() then

			bShowPanel = true
		end

		if bShowPanel then

			draw.RoundedBox(4, 0, 0, w, h, Color(0, self.Player:VoiceVolume() * 255, 0, 240))

			if IsValid(PlayerIcon) then

				surface.SetDrawColor(COLOR_WHITE)

				surface.SetMaterial(IconTalkie)

				surface.DrawTexturedRect(4, 4, 32, 32)
			end
		end
	end
end

function VoiceNotifyPanel:Think()

	if IsValid(self.Player) then

		self.LabelName:SetText(UtilGetRPNameSurname(self.Player))
	end

	if self.fadeAnim then

		self.fadeAnim:Run()
	end

end

function VoiceNotifyPanel:FadeOut(anim, delta, data)
	
	if anim.Finished then
	
		if IsValid(PlayerVoicePanels[self.Player]) then

			PlayerVoicePanels[self.Player]:Remove()

			PlayerVoicePanels[self.Player] = nil

			return
		end
		
		return
	end
	
	self:SetAlpha(255 - (255 * delta))
end

derma.DefineControl("VoiceNotify", "", VoiceNotifyPanel, "DPanel")

function GM:PlayerStartVoice(InPlayer)

	--MsgN(Format("PlayerStartVoice() %s", InPlayer))

	--local Client = LocalPlayer()

	--if UtilCanHearByTalkie(Client, InPlayer) or Client:EntIndex() == InPlayer:EntIndex() then

	self.BaseClass:PlayerStartVoice(InPlayer)
	--end
end

--[[function GM:PlayerEndVoice(InPlayer)

	return
end--]]