---- Roleplay: Prison

function TeamCanBePicked(TeamID)

	if TeamID == TEAM_GUARD then

		return team.NumPlayers(TEAM_GUARD) < GetConVar("sk_maxguards"):GetInt()

	elseif TeamID == TEAM_ROBBER then

		return team.NumPlayers(TEAM_ROBBER) < GetConVar("sk_maxrobbers"):GetInt()

	elseif TeamID == TEAM_STAFF then

		return false
	end
end

function GM:ShowTeam()

	if (IsValid(self.TeamSelectFrame)) then return end
	
	self.TeamSelectFrame = vgui.Create("DFrame")

	self.TeamSelectFrame:SetTitle("Выбор роли")
	
	local AllTeams = team.GetAllTeams()

	local y = 30

	for ID, TeamInfo in pairs (AllTeams) do
	
		if (ID ~= TEAM_CONNECTING && ID ~= TEAM_UNASSIGNED) then
	
			local Team = vgui.Create("DButton", self.TeamSelectFrame)

			function Team.DoClick()

				if TeamCanBePicked(ID) then

					self:HideTeam()

					RunConsoleCommand("changeteam", ID)
				end
			end

			Team:SetPos(10, y)

			Team:SetSize(200, 20)

			Team:SetText(TeamInfo.Name)
			
			if (IsValid(LocalPlayer()) && LocalPlayer():Team() == ID) then

				Team:SetDisabled(true)
			end
			
			y = y + 30
		end
		
	end
	
	self.TeamSelectFrame:SetSize(220, y)

	self.TeamSelectFrame:Center()

	self.TeamSelectFrame:MakePopup()

	self.TeamSelectFrame:SetKeyboardInputEnabled( false )

end

--[[---------------------------------------------------------
   Name: gamemode:HideTeam()
   Desc:
-----------------------------------------------------------]]
function GM:HideTeam()

	if IsValid(self.TeamSelectFrame) then

		self.TeamSelectFrame:Remove()

		self.TeamSelectFrame = nil
	end
end
