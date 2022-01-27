---- Roleplay: Prison

local OldInjuryValue = 0.0

local MaxBrignessValue = -0.3

local MaxColorValue = 0.0

local MaxAddAlphaValue = 0.06

function UpdatePostProcessData(InPlayer)

	local TotalValue = 0.0

	if InPlayer:Team() == TEAM_GUARD or InPlayer:Team() == TEAM_ROBBER then

		--MsgN(InPlayer:GetNWFloat("HungerValue"))

		local TotalValue = InPlayer:GetNWFloat("InjuryValue") * 0.65 + InPlayer:GetNWFloat("HungerValue") / 2

		if InPlayer:GetNWBool("bStunned") then

			TotalValue = TotalValue + 0.5
		end

		TotalValue = math.Clamp(TotalValue + (1.0 - InPlayer:GetNWFloat("EnergyValue")) / 4, 0.0, 1.0)
	end

	--MsgN(TotalValue)

	if TotalValue == OldTotalValue then

		return
	end

	InPlayer:ConCommand(Format("pp_colormod_brightness %f", Lerp(TotalValue, 0.0, MaxBrignessValue)))

	InPlayer:ConCommand(Format("pp_colormod_color %f", Lerp(TotalValue, 1.0, MaxColorValue)))

	InPlayer:ConCommand(Format("pp_motionblur_addalpha %f", Lerp(TotalValue, 1.0, MaxAddAlphaValue)))

	OldTotalValue = TotalValue
end
