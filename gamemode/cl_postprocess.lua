---- Roleplay: Prison

local OldInjuryValue = 0.0

local MaxBrignessValue = -0.3

local MaxColorValue = 0.0

local MaxAddAlphaValue = 0.06

function UpdatePostProcessData(InPlayer)

	--MsgN(InPlayer:GetNWFloat("HungerValue"))

	local TotalValue = (InPlayer:GetNWFloat("InjuryValue") + InPlayer:GetNWFloat("HungerValue")) / 2

	TotalValue = math.Clamp(TotalValue + (1.0 - InPlayer:GetNWFloat("EnergyValue")) / 3, 0.0, 1.0)

	--MsgN(TotalValue)

	if TotalValue == OldTotalValue then

		return
	end

	InPlayer:ConCommand(string.format("pp_colormod_brightness %f", Lerp(TotalValue, 0.0, MaxBrignessValue)))

	InPlayer:ConCommand(string.format("pp_colormod_color %f", Lerp(TotalValue, 1.0, MaxColorValue)))

	InPlayer:ConCommand(string.format("pp_motionblur_addalpha %f", Lerp(TotalValue, 1.0, MaxAddAlphaValue)))

	OldTotalValue = TotalValue
end
