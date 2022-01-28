---- Roleplay: Prison

local OldInjuryValue = 0.0

local MaxBrignessValue = -0.3

local MaxColorValue = 0.0

local MaxAddAlphaValue = 0.06

function UpdatePostProcessData(InPlayer)

	local TotalValue = 0.0

	if InPlayer:Team() == TEAM_GUARD or InPlayer:Team() == TEAM_ROBBER then

		--MsgN(Format(InPlayer:GetNWFloat("HungerValue"), InPlayer:GetNWFloat("InjuryValue"), InPlayer:GetNWFloat("EnergyValue")))

		TotalValue = InPlayer:GetNWFloat("InjuryValue") * 0.75 + InPlayer:GetNWFloat("HungerValue") / 3

		if InPlayer:GetNWBool("bStunned") then

			TotalValue = TotalValue + 0.5
		end

		TotalValue = math.Clamp(TotalValue + (1.0 - InPlayer:GetNWFloat("EnergyValue")) / 5, 0.0, 1.0)
	end

	if TotalValue == OldTotalValue then

		return
	end

	MsgN(Format("Post process new total value: %s", TotalValue))

	InPlayer:ConCommand(Format("pp_colormod_brightness %f", Lerp(TotalValue, 0.0, MaxBrignessValue)))

	InPlayer:ConCommand(Format("pp_colormod_color %f", Lerp(TotalValue, 1.0, MaxColorValue)))

	InPlayer:ConCommand(Format("pp_motionblur_addalpha %f", Lerp(TotalValue, 1.0, MaxAddAlphaValue)))

	OldTotalValue = TotalValue
end
