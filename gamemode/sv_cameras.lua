---- Roleplay: Prison

CamerasList = {}
CamerasResetRelay = nil

local function UpdateCameraIndex(InPlayer, InIndexDelta)

	InPlayer.CameraIndex = InPlayer.CameraIndex + InIndexDelta

	if InPlayer.CameraIndex > #CamerasList then

		InPlayer.CameraIndex = 1

	elseif InPlayer.CameraIndex <= 0 then

		InPlayer.CameraIndex = #CamerasList
	end
end

hook.Add("KeyPress", "CameraControls", function(InPlayer, InKey)

	if InPlayer:GetNWBool("bUsingCameras") and (InPlayer.LastCameraToggle or 0) + 3.5 < CurTime() then

		CamerasResetRelay:Input("Trigger")

		if InKey == IN_ATTACK or InKey == IN_ATTACK2 then

			if InKey == IN_ATTACK then

				UpdateCameraIndex(InPlayer, 1)
			else
				UpdateCameraIndex(InPlayer, -1)
			end

			local SampleCamera = CamerasList[InPlayer.CameraIndex]

			SampleCamera:Input("FireUser1")

			InPlayer:SetViewEntity(SampleCamera)

			InPlayer.LastCameraToggle = CurTime()
		else
			StopCamerasModeForPlayer(InPlayer)
		end

		InPlayer:ScreenFade(SCREENFADE.IN, COLOR_BLACK, 1.0, 2.5)
	end
end)

function SetupCameras()

	MsgN("Setup cameras...")

	local AllEntities = ents.GetAll()

	for SampleIndex, SampleEntity in ipairs(AllEntities) do

		local SampleEntityName = SampleEntity:GetName()

		if string.EndsWith(SampleEntityName, "_Camera") then

			MsgN(SampleEntityName.." is registered!")

			table.insert(CamerasList, SampleEntity)

		elseif string.EndsWith(SampleEntityName, "_CameraReset") then

			MsgN(SampleEntityName.." is registered!")

			CamerasResetRelay = SampleEntity
		end
	end

	MsgN(table.ToString(CamerasList))
end

function StartCamerasModeForPlayer(InPlayer)

	InPlayer:SetNWBool("bUsingCameras", true)

	InPlayer.CameraIndex = InPlayer.CameraIndex or 1

	MsgN(table.ToString(CamerasList))

	local SampleCamera = CamerasList[InPlayer.CameraIndex]

	InPlayer:SetViewEntity(SampleCamera)

	InPlayer:ScreenFade(SCREENFADE.IN, COLOR_BLACK, 1.0, 2.5)
end

function StopCamerasModeForPlayer(InPlayer)

	InPlayer:SetNWBool("bUsingCameras", false)

	InPlayer:SetViewEntity(nil)
end
