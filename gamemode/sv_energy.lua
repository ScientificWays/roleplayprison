---- Roleplay: Prison

timer.Create("EnergyTick", 1.0, 0, function(InPlayer)

	local AllPlayers = player.GetAll()

	for Index, Player in ipairs(AllPlayers) do

		if Player:Team() ~= TEAM_ROBBER and Player:Team() ~= TEAM_GUARD then

			return
		end

		local OldEnergy = Player.Energy

		if Player:IsSprinting() then

			if Player.Energy >= 1.0 then

				Player.Energy = Player.Energy - 1.0

				Player.Food = Player.Food - 0.05

				Player.Water = Player.Water - 0.1

				UpdatePlayerHungerValue(Player)
			else

				Player.Energy = 0.0
			end
		else

			if Player.Energy < UtilGetSprintDuration() then

				Player.Energy = Player.Energy + 2.0
			else

				Player.Energy = UtilGetSprintDuration()
			end
		end

		if OldEnergy == Player.Energy then

			return
		end

		if Player.Energy < UtilGetSprintDuration() * 0.25 then

			if Player.BreatheSound == nil then

				Player.BreatheSound = CreateSound(Player, "player/breathe1.wav", RecipientFilter():AddAllPlayers())

				Player.BreatheSound:Play()

				--MsgN("Play sound")
			end

			Player.BreatheSound:ChangeVolume(1.0 - Player.Energy / (UtilGetSprintDuration() * 0.25))
		else

			--MsgN(Player.BreatheSound)

			if Player.BreatheSound ~= nil then

				Player.BreatheSound:Stop()

				Player.BreatheSound = nil

				--MsgN("Stop sound")
			end
		end

		UpdatePlayerEnergyValue(Player)
	end
end)

function UpdatePlayerEnergyValue(InPlayer)

	InPlayer.Energy = math.Clamp(InPlayer.Energy, 0.0, UtilGetSprintDuration())

	--MsgN(string.format("%s Energy: %f/%f", InPlayer:GetName(), InPlayer.Energy, UtilGetSprintDuration()))

	local FinalEnergyValue = InPlayer.Energy / UtilGetSprintDuration()

	InPlayer:SetNWFloat("EnergyValue", FinalEnergyValue)

	InPlayer:SetJumpPower(200.0 * math.Clamp(FinalEnergyValue + 0.5, 0.0, 1.0))
end

hook.Add("SetupMove", "EnergyMove", function(InPlayer, InMoveData, InCommandData)

	local FinalMaxSpeed = Lerp(InPlayer:GetNWFloat("EnergyValue"), 100, InMoveData:GetMaxClientSpeed())

	InMoveData:SetMaxClientSpeed(FinalMaxSpeed)
end)

local LastJumpEnergyDrain = 0.0

hook.Add("KeyPress", "EnergyJump", function(InPlayer, InKey)

	if InKey == IN_JUMP and CurTime() - LastJumpEnergyDrain > 1.5 then

		InPlayer.Food = InPlayer.Food - 0.2

		InPlayer.Water = InPlayer.Water - 0.4

		UpdatePlayerHungerValue(InPlayer)

		InPlayer.Energy = InPlayer.Energy * 0.8

		UpdatePlayerEnergyValue(InPlayer)

		LastJumpEnergyDrain = CurTime()
	end
end)
