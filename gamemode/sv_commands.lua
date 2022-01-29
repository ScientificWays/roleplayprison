---- Roleplay: Prison

function GM:PlayerSay(InSender, InText, bTeamChat)

	if InText[1] ~= "/" then

		MsgN(Format("Chat text: %s ", InText))

		return InText
	end

	SeparatedStrings = string.Explode(" ", InText, false)

	if SeparatedStrings[1] == "/vote" and SeparatedStrings[2] ~= nil then

		AddOfficerVote(InSender, SeparatedStrings[2])

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/votefinish" then

		FinishOfficerVote()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/start" then

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)

		StartNewCycle()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/auto" then

		FinishOfficerVote()

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)
		
		StartNewCycle()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/pause" then

		ToggleCycle(true)

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/unpause" then

		ToggleCycle(false)

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/skip" then

		if SeparatedStrings[2] == "cycle" then

			StartNewCycle()

		elseif SeparatedStrings[2] == "delay" and SeparatedStrings[3] == "" then

			TrySkipTaskDelayFor(table.concat(SeparatedStrings, " ", 3))
		end

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/Лёха" then

		local DebugDude = player.CreateNextBot("Лёха")

		DebugDude:SetTeam(TEAM_GUARD)

		DebugDude:SetNWString("RPName", "Лёха")

		DebugDude:Spawn()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/Саня" then

		local DebugDude = player.CreateNextBot("Саня")

		DebugDude:SetTeam(TEAM_ROBBER)

		DebugDude:SetNWString("RPName", "Саня")

		DebugDude:Spawn()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/give" and SeparatedStrings[2] ~= nil then

		local GivePlayer = UtilGetPlayerByRPName(SeparatedStrings[2])

		if IsValid(GivePlayer) then

			if not TryGiveWeaponItem(GivePlayer, SeparatedStrings[3]) then

				TryGiveStackableItem(GivePlayer, SeparatedStrings[3], SeparatedStrings[4] or "1")
			end
		end

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/foodadd" or SeparatedStrings[1] == "/wateradd" then

		if SeparatedStrings[2] ~= nil and SeparatedStrings[3] ~= nil then

			local TargetPlayer = UtilGetPlayerByRPName(SeparatedStrings[2])

			AddNutrition(TargetPlayer, math.Round(tonumber(SeparatedStrings[3]) or 0), SeparatedStrings[1] == "/foodadd")
		end
	end

	return ""
end
