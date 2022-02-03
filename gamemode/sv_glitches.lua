---- Roleplay: Prison

timer.Create("GlitchesTimer", 48.0, 0, function()

	MsgN("Glitches!")

	local PotentialGlitchEntityList = ents.FindByClass("prop_dynamic")

	table.Add(PotentialGlitchEntityList, ents.FindByClass("prop_physics"))

	for Index, PotentialGlitchEntity in ipairs(PotentialGlitchEntityList) do

		if math.random() < 0.1 and PotentialGlitchEntity:GetRenderFX() == kRenderFxNone then

			PotentialGlitchEntity:SetRenderFX(kRenderFxHologram)

			timer.Simple(5.0, function()

				--In case entity was removed during gameplay
				if IsValid(PotentialGlitchEntity) then

					PotentialGlitchEntity:SetRenderFX(kRenderFxNone)
				end
			end)
		end
	end
end)