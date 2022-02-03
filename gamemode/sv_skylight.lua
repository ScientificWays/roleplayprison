---- Roleplay: Prison

--Borrowed from Atmos - Day / Night and Weather Modification
local SkyPaintEntity = nil

local NIGHT	= 0
local DAWN = 1
local DAY = 2
local DUSK = 3

local SkyPaintData =
{
	[DAWN] =
	{
		TopColor		= Vector(0.2, 0.5, 1),
		BottomColor		= Vector(0.46, 0.65, 0.49),
		FadeBias		= 1,
		HDRScale		= 0.26,
		StarScale 		= 1.84,
		StarFade		= 0.0,
		StarSpeed 		= 0.02,
		DuskScale		= 1,
		DuskIntensity	= 1,
		DuskColor		= Vector(1, 0.2, 0),
		SunColor		= Vector(0.2, 0.1, 0),
		SunSize			= 2,
		LightmapStyle	= "f"
	},
	[DAY] =
	{
		TopColor		= Vector(0.2, 0.49, 1),
		BottomColor		= Vector(0.8, 1, 1),
		FadeBias		= 1,
		HDRScale		= 0.26,
		StarScale 		= 1.84,
		StarFade		= 1.5,
		StarSpeed 		= 0.02,
		DuskScale		= 1,
		DuskIntensity	= 1,
		DuskColor		= Vector(1, 0.2, 0),
		SunColor		= Vector(0.83, 0.45, 0.11),
		SunSize			= 0.34,
		LightmapStyle	= "m"
	},
	[DUSK] =
	{
		TopColor		= Vector(0.24, 0.15, 0.08),
		BottomColor		= Vector(.4, 0.07, 0),
		FadeBias		= 1,
		HDRScale		= 0.36,
		StarScale		= 1.50,
		StarFade		= 5.0,
		StarSpeed 		= 0.01,
		DuskScale		= 1,
		DuskIntensity	= 1.94,
		DuskColor		= Vector(0.69, 0.22, 0.02),
		SunColor		= Vector(0.90, 0.30, 0.00),
		SunSize			= 0.44,
		LightmapStyle	= "d"
	},
	[NIGHT] =
	{
		TopColor		= Vector(0.00, 0.00, 0.00),
		BottomColor		= Vector(0.05, 0.05, 0.11),
		FadeBias		= 0.1,
		HDRScale		= 0.19,
		StarScale		= 1.50,
		StarFade		= 5.0,
		StarSpeed 		= 0.01,
		DuskScale		= 0,
		DuskIntensity	= 0,
		DuskColor		= Vector(1, 0.36, 0),
		SunColor		= Vector(0.83, 0.45, 0.11),
		SunSize			= 0.0,
		LightmapStyle	= "b"
	}
}

local function TryUpdateLightStyle(InNewLightStyle)

	if InNewLightStyle ~= OldLightStyle then

		engine.LightStyle(0, InNewLightStyle)

		timer.Simple(0.1, function()

			net.Start("UpdateClientLightmaps")

			net.Broadcast()

		end)

		MsgN(Format("New light style: %s", InNewLightStyle))

		OldLightStyle = InNewLightStyle
	end
end

local function UpdateSkyPaintAndLightmaps(InCurrentState, InNextState, InAlpha)

	if not IsValid(SkyPaintEntity) then

		return
	end

	SkyPaintEntity:SetTopColor(LerpVector(InAlpha, SkyPaintData[InCurrentState].TopColor, SkyPaintData[InNextState].TopColor))
	SkyPaintEntity:SetBottomColor(LerpVector(InAlpha, SkyPaintData[InCurrentState].BottomColor, SkyPaintData[InNextState].BottomColor))
	SkyPaintEntity:SetSunColor(LerpVector(InAlpha, SkyPaintData[InCurrentState].SunColor, SkyPaintData[InNextState].SunColor))
	SkyPaintEntity:SetDuskColor(LerpVector(InAlpha, SkyPaintData[InCurrentState].DuskColor, SkyPaintData[InNextState].DuskColor))
	SkyPaintEntity:SetFadeBias(Lerp(InAlpha, SkyPaintData[InCurrentState].FadeBias, SkyPaintData[InNextState].FadeBias))
	SkyPaintEntity:SetHDRScale(Lerp(InAlpha, SkyPaintData[InCurrentState].HDRScale, SkyPaintData[InNextState].HDRScale))
	SkyPaintEntity:SetDuskScale(Lerp(InAlpha, SkyPaintData[InCurrentState].DuskScale, SkyPaintData[InNextState].DuskScale))
	SkyPaintEntity:SetDuskIntensity(Lerp(InAlpha, SkyPaintData[InCurrentState].DuskIntensity, SkyPaintData[InNextState].DuskIntensity))
	SkyPaintEntity:SetSunSize(Lerp(InAlpha, SkyPaintData[InCurrentState].SunSize, SkyPaintData[InNextState].SunSize))

	SkyPaintEntity:SetStarFade(SkyPaintData[InNextState].StarFade)
	SkyPaintEntity:SetStarScale(SkyPaintData[InNextState].StarScale)
	SkyPaintEntity:SetStarSpeed(SkyPaintData[InNextState].StarSpeed)

	local LightmapAlpha = math.Remap(InAlpha, 0.0, 1.0, string.byte(SkyPaintData[InCurrentState].LightmapStyle), string.byte(SkyPaintData[InNextState].LightmapStyle))

	TryUpdateLightStyle(string.char(math.Round(LightmapAlpha)))
end

function SetupSkyPaint()

	SkyPaintEntity = ents.FindByClass("env_skypaint")[1]

	if IsValid(SkyPaintEntity) then

		MsgN("SkyPaintEntity registered!")
	else

		MsgN("Error! Can't find env_skypaint entity!")
	end
end

function TrySetMapDayState(InAlpha)

	if not bDayMapState then

		local ToggleEntity = ents.FindByName("ColorCorrection_Toggle")[1]

		if IsValid(ToggleEntity) then

			ToggleEntity:Fire("FireUser1")

			MsgN("SetMapDayState")
		end

		if IsValid(SkyPaintEntity) then

			if math.random() < 0.5 then

				SkyPaintEntity:SetStarTexture("skybox/clouds")

				SkyPaintData[DAY].StarFade = 1.5

			else
				SkyPaintEntity:SetStarTexture("skybox/starfield")

				SkyPaintData[DAY].StarFade = 0
			end
		end

		bDayMapState = true
	end
end

function TrySetMapNightState(InAlpha)

	if bDayMapState or bDayMapState == nil then

		local ToggleEntity = ents.FindByName("ColorCorrection_Toggle")[1]

		if IsValid(ToggleEntity) then

			ToggleEntity:Fire("FireUser2")

			MsgN("SetMapNightState")
		end

		bDayMapState = false
	end
end

function TryUpdateSkyPaintAndLightmapsState(InAlpha)

	if UtilIsInterCycle() then

		if InAlpha < 0.25 then

			InAlpha = math.Remap(InAlpha, 0.0, 0.25, 0.0, 1.0)

			UpdateSkyPaintAndLightmaps(DUSK, NIGHT, InAlpha)

			--MsgN(Format("DUSK-NIGHT %f", InAlpha))
		else

			UpdateSkyPaintAndLightmaps(NIGHT, NIGHT, 0.0)

			--MsgN(Format("NIGHT-NIGHT %f", InAlpha))
		end
	else

		if InAlpha < 0.2 then

			UpdateSkyPaintAndLightmaps(NIGHT, DAWN, math.Remap(InAlpha, 0.0, 0.2, 0.0, 1.0))

			--MsgN(Format("NIGHT-DAWN %f", InAlpha))

		elseif InAlpha < 0.4 then

			UpdateSkyPaintAndLightmaps(DAWN, DAY, math.Remap(InAlpha, 0.2, 0.4, 0.0, 1.0))

			--MsgN(Format("DAWN-DAY %f", InAlpha))

		elseif InAlpha > 0.8 then

			UpdateSkyPaintAndLightmaps(DAY, DUSK, math.Remap(InAlpha, 0.8, 1.0, 0.0, 1.0))

			--MsgN(Format("DAY-DUSK %f", InAlpha))
		else

			UpdateSkyPaintAndLightmaps(DAY, DAY, 0.0)

			--MsgN(Format("DAY-DAY %f", InAlpha))
		end
	end
end
