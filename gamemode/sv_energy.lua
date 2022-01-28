---- Roleplay: Prison

timer.Create("EnergyTick", 1.0, 0, function()

	local AllPlayers = player.GetAll()

	for Index, Player in ipairs(AllPlayers) do

		--MsgN(team.GetName(Player:Team()))

		if Player:Team() == TEAM_ROBBER or Player:Team() == TEAM_GUARD then

			local OldEnergy = Player.Energy

			if Player:IsSprinting() then

				if Player.Energy >= 1.0 then

					Player.Energy = Player.Energy - 1.0

					Player.Food = Player.Food - 0.02

					Player.Water = Player.Water - 0.04

					--MsgN(Format("Hunger sprint tick for %s", Player:Nick()))

					UpdatePlayerHungerValue(Player)
				else

					Player.Energy = 0.0
				end
			else

				if Player.Energy < UtilGetSprintDuration() then

					Player.Energy = Player.Energy + 1.0
				else

					Player.Energy = UtilGetSprintDuration()
				end
			end

			if OldEnergy ~= Player.Energy then

				--MsgN(Format("%s energy changed from %s to %s (before clamp)", Player:Nick(), OldEnergy, Player.Energy))

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
		end
	end
end)

function UpdatePlayerEnergyValue(InPlayer)

	InPlayer.Energy = math.Clamp(InPlayer.Energy, 0.0, UtilGetSprintDuration())

	--MsgN(Format("%s Energy: %f/%f", InPlayer:GetNWString("RPName"), InPlayer.Energy, UtilGetSprintDuration()))

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
