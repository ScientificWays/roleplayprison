---- Roleplay: Prison

function UtilGetActiveScheduleElementIndexAndTimeLeft(InList)

	--MsgN(table.ToString(InList))

	local AccumulatedTimeSeconds = 0

	for i, ScheduleElement in ipairs(InList) do

		local CurrentTimeSeconds = UtilGetCurrentCycleTimeSeconds()

		AccumulatedTimeSeconds = AccumulatedTimeSeconds + ScheduleElement.DurationMinutes * 60

		local CurrentTime = UtilGetCurrentCycleTimeSeconds()

		if AccumulatedTimeSeconds >= CurrentTime then

			return i, AccumulatedTimeSeconds - CurrentTime
		end
	end
end

local HandcuffsDragBoneName = "ValveBiped.Bip01_R_Hand"
local HandcuffsRopeMaterial = Material("cable/cable2")

local LeftHandBoneName = "ValveBiped.Bip01_L_Hand"
local RightHandBoneName = "ValveBiped.Bip01_R_Hand"

hook.Add("PostDrawOpaqueRenderables", "HandcuffsDragRope", function()

	local Client = LocalPlayer()

	local AllPlayers = player.GetAll()

	for Index, SamplePlayer in ipairs(AllPlayers) do

		if SamplePlayer:GetNWBool("bHandcuffed") and Client:EntIndex() ~= SamplePlayer:EntIndex() then
		
			local Kidnapper = Entity(SamplePlayer:GetNWInt("KidnapperIndex", -1))

			if IsValid(Kidnapper) then

				local KidnapperPos = (Kidnapper:IsPlayer() and Kidnapper:GetPos() + Vector(0,0,37)) or Kidnapper:GetPos()
				
				local RopeStartPos = SamplePlayer:GetPos()

				local DragBone = SamplePlayer:LookupBone(HandcuffsDragBoneName)

				if DragBone then

					RopeStartPos = SamplePlayer:GetBonePosition(DragBone)

					if RopeStartPos:IsZero() then

						RopeStartPos = SamplePlayer:GetPos()
					end
				end
				
				render.SetMaterial(HandcuffsRopeMaterial)

				render.DrawBeam(KidnapperPos, RopeStartPos, 0.7, 0, 5, COLOR_WHITE)

				--render.DrawBeam(RopeStartPos, KidnapperPos, -0.7, 0, 5, COLOR_WHITE)
			end

			local LeftHandBone = SamplePlayer:LookupBone(LeftHandBoneName)

			local LeftHandBonePos = SamplePlayer:GetBonePosition(LeftHandBone)

			local RightHandBone = SamplePlayer:LookupBone(RightHandBoneName)

			local RightHandBonePos = SamplePlayer:GetBonePosition(RightHandBone)

			if not LeftHandBonePos:IsZero() and not RightHandBonePos:IsZero() then

				render.SetMaterial(HandcuffsRopeMaterial)

				render.DrawBeam(LeftHandBonePos, RightHandBonePos, 0.7, 0, 5, COLOR_WHITE)

				--render.DrawBeam(RightHandBonePos, LeftHandBonePos, -0.7, 0, 5, COLOR_WHITE)
			end
		end
	end
end)
