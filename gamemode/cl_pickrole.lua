---- Roleplay: Prison

local MainRoleFrame = nil
local SubRoleFrame = nil

local MainFrameWidth, MainFrameHeight = 250, 300
local SubFrameWidth, SubFrameHeight = 200, 200

local TEAM_GUARD, TEAM_ROBBER = 1, 2

local MainRoleList = {[TEAM_GUARD] = true, [TEAM_ROBBER] = true}

local SubRoleList = {[TEAM_GUARD] = {"Мужчина", "Женщина"}, [TEAM_ROBBER] = {"Мужчина"--[[, "Женщина"--]]}}

function TeamCanBePicked(TeamID)

	if TeamID == TEAM_GUARD then

		return team.NumPlayers(TEAM_GUARD) < GetConVar("sk_maxguards"):GetInt()

	elseif TeamID == TEAM_ROBBER then

		return team.NumPlayers(TEAM_ROBBER) < GetConVar("sk_maxrobbers"):GetInt()

	elseif TeamID == TEAM_STAFF then

		return false
	end
end

function IsPickroleOpen()

	return IsValid(MainRoleFrame) or IsValid(SubRoleFrame)
end

function GM:ShowTeam()

	if IsPickroleOpen() then

		return
	end

	MainRoleFrame = vgui.Create("DFrame")

	MainRoleFrame:SizeTo(MainFrameWidth, MainFrameHeight, 1.5, 0, 0.1)

	MainRoleFrame:SetPos(10, ScrH() / 2 - MainFrameHeight / 2)

	MainRoleFrame:SetTitle("")

	MainRoleFrame:SetDraggable(false)

	MainRoleFrame:ShowCloseButton(false)

	MainRoleFrame:MakePopup()

	MainRoleFrame.Paint = function(self, w, h)

		DrawBlur(self, 3)

		draw.RoundedBoxEx(10, 0, 0, w, h, Color(0, 0, 0, 200), true, false, true, false)

		draw.SimpleText("Выбрать роль", "HUDTextSmall",
			MainFrameWidth / 2, 12, Color(255, 255, 255, 255),
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.RoundedBoxEx(0, 0, 20, w, 5, Color(255, 255, 255), true, true, true, true)
	end

	local PickRoleScrollPanel = vgui.Create("DScrollPanel", MainRoleFrame)

	PickRoleScrollPanel:Dock(FILL)

	local PickRoleScrollBar = PickRoleScrollPanel:GetVBar()

	PickRoleScrollBar.Paint = function() end

	function PickRoleScrollBar.btnUp:Paint(h, i)

		draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
	end
		
	function PickRoleScrollBar.btnDown:Paint(h, i)

		draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
	end

	function PickRoleScrollBar.btnGrip:Paint(h, i)

		draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
	end

	local AllTeams = team.GetAllTeams()

	for ID, TeamInfo in pairs(AllTeams) do

		if MainRoleList[ID] ~= nil then 

			local MainRoleButton = PickRoleScrollPanel:Add("DButton")

			MainRoleButton:SetSize(10, 50)

			MainRoleButton:Dock(TOP)

			MainRoleButton:DockMargin(0, 5, 0, 5)

			MainRoleButton:SetText("")

			MainRoleButton.lerp = 0

			MainRoleButton.Paint = function(self, w, h)

				draw.RoundedBoxEx(10, 0, 0, w, h, Color(30, 30, 30, 200), true, true, true, true)

				if self:IsHovered() then

					self.lerp = Lerp(FrameTime() * 6, self.lerp, 10)

					draw.RoundedBoxEx(10, 0, 0, self.lerp, h, Color(116, 0, 255, 255), true, false, true, false)
				else
					self.lerp = Lerp(FrameTime() * 6, self.lerp, 0)

					draw.RoundedBoxEx(10, 0, 0, self.lerp, h, Color(116, 0, 255, 255), true, false, true, false)
				end

				draw.SimpleText(team.GetName(ID), "HUDTextSmall", MainFrameWidth/2, 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			MainRoleButton.DoClick = function()

				if SubRoleList[ID] ~= nil then
					
					if SubRoleFrame ~= nil then

						SubRoleFrame:Remove()
					end

					SubRoleFrame = vgui.Create("DFrame")

					SubRoleFrame:SetPos(10 + MainFrameWidth, ScrH() / 2 - MainFrameHeight / 2)

					SubRoleFrame:SetSize(0, 0)

					SubRoleFrame:SizeTo(SubFrameWidth, SubFrameHeight, 1.5, 0, 0.1)

					SubRoleFrame:SetTitle("")

					SubRoleFrame:SetDraggable(false)

					SubRoleFrame:ShowCloseButton(false)

					SubRoleFrame.Paint = function(self, w, h)

						DrawBlur(self, 3)

						draw.RoundedBoxEx(10, 0, 0, w, h, Color(0, 0, 0, 200), false, true, false, true)

						--draw.SimpleText('Выбрать роль', 'title', ws2/2, 12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

						draw.RoundedBoxEx(0, 0, 20, w, 5, Color(255, 255, 255), true, true, true, true)
					end

					local SubRoleScrollPanel = vgui.Create("DScrollPanel", SubRoleFrame)

					SubRoleScrollPanel:Dock(FILL)

					local ScrollBar = SubRoleScrollPanel:GetVBar()

					ScrollBar.Paint = function() end

					function ScrollBar.btnUp:Paint(h, i)

						draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
					end
						
					function ScrollBar.btnDown:Paint(h, i)

						draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
					end

					function ScrollBar.btnGrip:Paint(h, i)

						draw.RoundedBox(0, 0, 0, h, i, Color(0, 0, 0, 200))
					end

					for Index, SampleSubRole in ipairs(SubRoleList[ID]) do

						local SubRoleButton = SubRoleScrollPanel:Add("DButton")

						SubRoleButton:SetSize(SubFrameWidth, 50)

						SubRoleButton:Dock(TOP)

						SubRoleButton:DockMargin(0, 5, 0, 5)

						SubRoleButton:SetText("")

						SubRoleButton.LerpValue = 0

						SubRoleButton.Paint = function(self, w, h)

							draw.RoundedBoxEx(10, 0, 0, w, h, Color(30, 30, 30, 200), true, true, true, true)

							if self:IsHovered() then

								self.LerpValue = Lerp(FrameTime() * 6, self.LerpValue, 10)

								draw.RoundedBoxEx(10, 0, 0, self.LerpValue, h, Color(116, 0, 255, 255), true, false, true, false)
							else
								self.LerpValue = Lerp(FrameTime() * 6, self.LerpValue, 0)

								draw.RoundedBoxEx(10, 0, 0, self.LerpValue, h, Color(116, 0, 255, 255), true, false, true, false)
							end

							draw.SimpleText(SampleSubRole, "HUDTextSmall", SubFrameWidth / 2, 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end

						SubRoleButton.DoClick = function()

							if TeamCanBePicked(ID) then

								self:HideTeam()

								ClientSendRequestJoinTeam(ID, Index == 1)
							end
						end
					end
				else

					MsgN(Format("SubRole is empty for %s!", team.GetName(ID)))
				end
			end
		end
	end
end

function GM:HideTeam()

	if not IsPickroleOpen() then

		return
	end

	--MsgN("HideTeam()")

	if IsValid(SubRoleFrame) then

		--MsgN("Valid SubRoleFrame")

		SubRoleFrame:SizeTo(0, 0, 0.9, 0, 0.1)

		timer.Simple(0.4, function()

			SubRoleFrame:Remove()

			SubRoleFrame = nil
		end)
	end

	if IsValid(MainRoleFrame) then

		--MsgN("Valid MainRoleFrame")

		MainRoleFrame:SizeTo(0, 0, 0.9, 0.2, 0.1)

		timer.Simple(0.7, function()

			MainRoleFrame:Remove()

			MainRoleFrame = nil
		end)
	end
end
