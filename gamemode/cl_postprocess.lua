---- Roleplay: Prison

local OldInjuryValue = 0.0

local MaxBrignessValue = -0.3

local MaxColorValue = 0.0

local MaxAddAlphaValue = 0.1

function UpdatePostProcessData(InPlayer)

	local TotalValue = 0.0

	if InPlayer:Team() ~= TEAM_SPECTATOR and InPlayer:Team() ~= TEAM_UNASSIGNED then

		if InPlayer:GetNWBool("bStunned") or InPlayer:GetNWBool("bIncapped") then

			TotalValue = 1.0

		else

			--MsgN(Format(InPlayer:GetNWFloat("HungerValue"), InPlayer:GetNWFloat("InjuryValue"), InPlayer:GetNWFloat("EnergyValue")))

			TotalValue = 1.0 - math.Clamp(InPlayer:GetNWFloat("HealthValue") * 3.0, 0.0, 1.0) + InPlayer:GetNWFloat("HungerValue") * 0.3

			TotalValue = math.Clamp(TotalValue + (1.0 - InPlayer:GetNWFloat("EnergyValue")) * 0.2, 0.0, 1.0)
		end
	end

	if TotalValue == OldTotalValue then

		return
	end

	--MsgN(Format("Post process new total value: %s", TotalValue))

	InPlayer:ConCommand(Format("pp_colormod_brightness %f", Lerp(TotalValue, 0.0, MaxBrignessValue)))

	InPlayer:ConCommand(Format("pp_colormod_color %f", Lerp(TotalValue, 1.0, MaxColorValue)))

	InPlayer:ConCommand(Format("pp_motionblur_addalpha %f", Lerp(TotalValue, 1.0, MaxAddAlphaValue)))

	OldTotalValue = TotalValue
end
