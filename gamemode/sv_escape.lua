---- Roleplay: Prison

local function GetEscapeUnusedViewList()

	local EscapeViewList = ents.FindByName("*_OutroView")

	MsgN(table.ToString(EscapeViewList))

	local OutViewList = {}

	for Index, SampleView in ipairs(EscapeViewList) do

		if not SampleView:GetNWBool("bWasUsed") then

			table.insert(OutViewList, SampleView)
		end
	end

	if table.IsEmpty(OutViewList) then

		--Reset bWasUsed state
		for Index, SampleView in ipairs(EscapeViewList) do

			SampleView:SetNWBool("bWasUsed", false)
		end

		return EscapeViewList
	end

	return OutViewList
end

function OnRobberEscape(InRobberPlayer)

	MsgN(Format("OnRobberEscape() %s", InRobberPlayer))

	local EscapeUnusedViewList = GetEscapeUnusedViewList()

	local SampleEscapeView = table.Random(EscapeUnusedViewList)

	MsgN(Format("SampleEscapeView %s", SampleEscapeView))

	InRobberPlayer:SetNWBool("bEscaped", true)

	SampleEscapeView:Fire("FireUser1", nil, 3.0, InRobberPlayer, InRobberPlayer)

	InRobberPlayer:ScreenFade(SCREENFADE.OUT, COLOR_WHITE, 2.0, 2.0)

	timer.Simple(3.0, function()

		InRobberPlayer:SetViewEntity(SampleEscapeView)

		InRobberPlayer:ScreenFade(SCREENFADE.IN, COLOR_WHITE, 2.0, 0.0)

		UtilSendEventMessageToPlayers({"RPP_Event.Escaped", UtilGetRPNameSurname(InRobberPlayer)})
	end)

	timer.Simple(9.0, function()

		InRobberPlayer:ScreenFade(SCREENFADE.OUT, COLOR_WHITE, 2.0, 2.0)
	end)

	timer.Simple(12.0, function()

		InRobberPlayer:ScreenFade(SCREENFADE.IN, COLOR_WHITE, 2.0, 0.0)

		InRobberPlayer:SetViewEntity(nil)

		GAMEMODE:PlayerJoinTeam(InRobberPlayer, TEAM_SPECTATOR)
	end)

	SampleEscapeView:SetNWBool("bWasUsed", true)
end
