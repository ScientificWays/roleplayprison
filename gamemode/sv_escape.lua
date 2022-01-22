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

	MsgN(string.format("OnRobberEscape() %s", InRobberPlayer))

	local EscapeUnusedViewList = GetEscapeUnusedViewList()

	local SampleEscapeView = table.Random(EscapeUnusedViewList)

	MsgN(string.format("SampleEscapeView %s", SampleEscapeView))

	InRobberPlayer:SetNWBool("bEscaped", true)

	SampleEscapeView:Fire("FireUser1", nil, 3.0, InRobberPlayer, InRobberPlayer)

	timer.Simple(3.0, function()

		InRobberPlayer:SetViewEntity(SampleEscapeView)

		PrintMessage(HUD_PRINTTALK, Format("%s сбежал!", InRobberPlayer:Nick()))
	end)

	timer.Simple(12.0, function()

		InRobberPlayer:SetViewEntity(nil)

		GAMEMODE:PlayerJoinTeam(InRobberPlayer, TEAM_SPECTATOR)
	end)

	SampleEscapeView:SetNWBool("bWasUsed", true)
end
