---- Roleplay: Prison

function GM:AcceptInput(InTargetEntity, InInput, InActivator, InCaller, InValue)

	if not InActivator:IsPlayer() then

		return false
	end

	--MsgN(InInput)

	if InInput == "Use" and InActivator:GetNWFloat("TaskTimeLeft") <= 0 then

		if not UtilPlayerCanInteract(InActivator) or InActivator:Team() == TEAM_SPECTATOR then

			return true
		end

		local TargetEntityName = InTargetEntity:GetName()

		--MsgN(table.ToString(GuardOnlyUsableNames))

		if string.EndsWith(TargetEntityName, "_GuardOnly") then

			if InActivator:Team() == TEAM_GUARD then

				return false
			else

				--MsgN(TargetEntityName.." activation blocked!")

				InTargetEntity:Input("Lock")

				InTargetEntity:Input("Use")

				InTargetEntity:Fire("Unlock", nil, 1.5, InActivator, caller)

				return true
			end
		end

		if InTargetEntity:GetNWBool("bGlobalSpeakerButton") then

			if not UtilIsServerSabotaged() then

				ToggleGlobalSpeaker(InTargetEntity)
			end

			return false
		end

		if InTargetEntity:GetNWBool("bFoodSpawn") or InTargetEntity:GetNWBool("bWaterSpawn") then

			OnImplementTaskStart(
				InActivator,
				InTargetEntity,
				1.0,
				nil,
				OnNutritionSpawn
			)

			return false
		end

		if InTargetEntity:GetNWBool("bStash") then

			OnImplementTaskStart(
				InActivator,
				InTargetEntity,
				1.0,
				nil,
				OnStashOpen
			)

			return false
		end

		if InActivator:Team() == TEAM_GUARD then

			if InTargetEntity:GetNWBool("bScheduleSetupEntity") then

				if InActivator:GetNWBool("bOfficer") and not IsOfficerPhoneEnabled() and not UtilIsScheduleSet() then

					OnScheduleSetupOpen(InActivator, InTargetEntity)

					return false
				else

					InTargetEntity:Input("Lock")

					InTargetEntity:Input("Use")

					InTargetEntity:Fire("Unlock", nil, 1.5, InActivator, caller)

					return true
				end
			end

			if InTargetEntity:GetNWBool("bServerSabotage") then

				if InTargetEntity:GetNWBool("bSabotaged") then

					OnImplementTaskStart(
						InActivator,
						InTargetEntity,
						UtilGetServerRepairDuration(),
						nil,
						TryRepairServer
					)

					return true
				else

					return false
				end
			end

			if InTargetEntity:GetNWBool("bOfficerPhone") then

				if InActivator:GetNWBool("bOfficer")
					and IsOfficerPhoneEnabled() then

					--Temporary disable ringing, true if no punishment
					if OnOfficerAnswerPhone() then

						OnImplementTaskStart(
							InActivator,
							InTargetEntity,
							UtilGetOfficerRoutineDuration(),
							CancelOfficerAnswerPhone,
							FinishOfficerAnswerPhone
						)
					end

					return true
				else

					return false
				end
			end

			if InTargetEntity:GetNWBool("bGuardTask") then

				if InTargetEntity:GetNWString("NowImplemetingBy") == ""
					and InActivator:GetNWString("RPName") == InTargetEntity:GetNWString("TaskImplementer") then

					OnImplementTaskStart(
						InActivator,
						InTargetEntity,
						UtilGetGuardRoutineDuration(),
						nil,
						FinishGuardAccountingTask
					)

					return true
				else

					return false
				end
			end

		elseif InActivator:Team() == TEAM_ROBBER then

			if InTargetEntity:GetNWBool("bServerSabotage") then

				if not InTargetEntity:GetNWBool("bSabotaged") then

					OnImplementTaskStart(
						InActivator,
						InTargetEntity,
						UtilGetServerSabotageDuration(),
						nil,
						TrySabotageServer
					)

					return true
				else

					return false
				end
			end

			if InTargetEntity:GetNWBool("bRobberTask") then

				if InTargetEntity:GetNWString("NowImplemetingBy") == "" then

					OnImplementTaskStart(
						InActivator,
						InTargetEntity,
						UtilGetRobberWorkDuration(),
						nil,
						FinishRobberWorkTask
					)

					return true
				else

					return false
				end
			end

			if InTargetEntity:GetNWBool("bDetailPickup") and GetDetailNumInStack(InTargetEntity) > 0 then

				OnImplementTaskStart(
					InActivator,
					InTargetEntity,
					UtilGetDetailPickupDuration(),
					nil,
					TryPickDetailFromWork
				)

				return true
			end

			if InTargetEntity:GetNWBool("bWorkbench") then

				OnImplementTaskStart(
					InActivator,
					InTargetEntity,
					1.0,
					nil,
					OnWorkbenchOpen
				)

				return true
			end
		end

	elseif InInput == "Trigger" and InActivator:Team() == TEAM_ROBBER and not InActivator:GetNWBool("bEscaped") then

		if InTargetEntity:GetName() == "Escape_OnTrigger" then

			OnRobberEscape(InActivator)

			return false
		end
	end

	return false
end

function GM:OnPlayerPhysicsDrop(InPlayer, InEntity, bThrown)

	if bThrown and string.EndsWith(InEntity:GetName(), "_Throwable") then

		local ThrowDirection = (InEntity:GetPos() - InPlayer:EyePos())

		ThrowDirection:Normalize()

		--MsgN(ThrowDirection)

		InEntity:GetPhysicsObject():ApplyForceCenter(ThrowDirection * 10000.0)
	end
end
