---- Roleplay: Prison

local PlayerFallSounds = {
	Sound("player/damage1.wav"),
	Sound("player/damage2.wav"),
	Sound("player/damage3.wav")
}

local DebugDude = {}

function UpdatePlayerMonitorType(InPlayer)

	if UtilCheckPlayerInArea(InPlayer, OfficerMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Officer")

	elseif UtilCheckPlayerInArea(InPlayer, ControlMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Control")

	elseif UtilCheckPlayerInArea(InPlayer, LibraryMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Library")
	else
			
		InPlayer:SetNWString("ActiveMonitorType", "None")
	end
end

function UpdatePlayerSpeakerState(InPlayer)

	if UtilCheckPlayerInArea(InPlayer, ControlSpeakerArea) then

		InPlayer:SetNWBool("bGlobalSpeaker", true)
	else

		InPlayer:SetNWBool("bGlobalSpeaker", false)
	end
end

function UpdatePlayerVoiceArea(InPlayer)

	if UtilCheckPlayerInArea(InPlayer, LocalPunishmentArea) then

		InPlayer:SetNWString("VoiceLocalArea", "LocalPunishmentArea")

	elseif UtilCheckPlayerInArea(InPlayer, LocalOutside1Area) then

		InPlayer:SetNWString("VoiceLocalArea", "LocalOutside1Area")
	else

		InPlayer:SetNWString("VoiceLocalArea", "")
	end

	--MsgN(InPlayer:GetNWString("VoiceLocalArea"))
end

function TryGiveRoleplayItem(InPlayer, InItemNameStr, InItemNumStr)

	local ItemNum = util.StringToType(InItemNumStr, "int")

	if ItemNum == nil then

		return
	end

	local ItemName = string.lower(InItemNameStr)

	local VariableName = ""

	MsgN(ItemNum)

	if ItemName == "wood" then

		VariableName = "DetailWoodNum"

	elseif ItemName == "metal" then

		VariableName = "DetailMetalNum"

	elseif ItemName == "picklock" then

		VariableName = "PicklockNum"
	end

	if VariableName ~= "" then

		local FinalItemNum = InPlayer:GetNWInt(VariableName) + ItemNum

		InPlayer:SetNWInt(VariableName, math.Clamp(FinalItemNum, 0, 99))
	end
end

function OnPlayerHandcuffsOn(InPlayer)

	MsgN(string.format("%s OnPlayerHandcuffsOn()", InPlayer:GetName()))

	InPlayer:SetNWBool("bHandcuffed", true)

	InPlayer:SetActiveWeapon(InPlayer:GetWeapon("weapon_rpp_unarmed"))
end

function OnPlayerHandcuffsOff(InPlayer)

	MsgN(string.format("%s OnPlayerHandcuffsOff()", InPlayer:GetName()))

	InPlayer:SetNWBool("bHandcuffed", false)
end

hook.Add("SetupMove", "HandcuffsMove", function(InPlayer, InMoveData, InCommandData)

	if not InPlayer:GetNWBool("bHandcuffed") then

		return
	end
	
	InMoveData:SetMaxClientSpeed(InMoveData:GetMaxClientSpeed() * 0.6)

	local Kidnapper = InPlayer.Kidnapper

	if not IsValid(Kidnapper) or Kidnapper == InPlayer then

		return
	end
	
	local MoveToPos = Kidnapper:GetPos()

	local MoveDirection = (MoveToPos - InPlayer:GetPos()):GetNormal()

	local MoveFromPos = InPlayer:GetPos()
	
	local Distance = 48.0

	if MoveToPos:DistToSqr(MoveFromPos) <= 2304.0 then

		return
	end

	local FinalMoveToPos = MoveToPos - (MoveDirection * Distance)
	
	local xDif = math.abs(MoveFromPos.x - FinalMoveToPos.x)
	local yDif = math.abs(MoveFromPos.y - FinalMoveToPos.y)
	local zDif = math.abs(MoveFromPos.z - FinalMoveToPos.z)
	
	local speedMult = 3 + ((xDif + yDif) * 0.5)^1.01
	local vertMult = math.max((math.Max(300 - (xDif + yDif), - 10) * 0.08)^1.01  + (zDif / 2), 0)
	
	if Kidnapper:GetGroundEntity() == InPlayer then

		vertMult = -vertMult
	end
	
	local TargetVel = (FinalMoveToPos - MoveFromPos):GetNormal() * 10
	TargetVel.x = TargetVel.x*speedMult
	TargetVel.y = TargetVel.y*speedMult
	TargetVel.z = TargetVel.z*vertMult

	local MoveVelocity = InMoveData:GetVelocity()
	
	local clamp = 50
	local vclamp = 20
	local accel = 200
	local vaccel = 30 * (vertMult / 50)
	
	MoveVelocity.x = (MoveVelocity.x > TargetVel.x - clamp or MoveVelocity.x < TargetVel.x + clamp) and math.Approach(MoveVelocity.x, TargetVel.x, accel) or MoveVelocity.x
	MoveVelocity.y = (MoveVelocity.y > TargetVel.y - clamp or MoveVelocity.y < TargetVel.y + clamp) and math.Approach(MoveVelocity.y, TargetVel.y, accel) or MoveVelocity.y
	
	if MoveFromPos.z < FinalMoveToPos.z then
		MoveVelocity.z = (MoveVelocity.z > TargetVel.z-vclamp or MoveVelocity.z < TargetVel.z + vclamp) and math.Approach(MoveVelocity.z, TargetVel.z, vaccel) or MoveVelocity.z
		
		if vertMult > 0 then InPlayer.Cuff_ForceJump = InPlayer end
	end
	
	InMoveData:SetVelocity(MoveVelocity)
	
	if SERVER
	and InMoveData:GetVelocity():Length() >= (InMoveData:GetMaxClientSpeed() * 10)
	and InPlayer:IsOnGround()
	and CurTime() > (InPlayer.Cuff_NextDragDamage or 0) then

		InPlayer:SetHealth(InPlayer:Health() - 1)

		if InPlayer:Health() <= 0 then

			InPlayer:Kill()
		end
		
		InPlayer.Cuff_NextDragDamage = CurTime() + 0.1
	end
end)

function GM:PlayerSay(InSender, InText, bTeamChat)

	if InText[1] ~= "/" then

		return InText
	end

	SeparatedStrings = string.Explode(" ", InText, false)

	if SeparatedStrings[1] == "/vote" and SeparatedStrings[2] ~= "" then

		AddOfficerVote(InSender, table.concat(SeparatedStrings, " ", 2))

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/votefinish" then

		FinishOfficerVote()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/start" then

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)

		StartNewCycle()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/auto" then

		FinishOfficerVote()

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)
		
		StartNewCycle()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/pause" then

		ToggleCycle(true)

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/unpause" then

		ToggleCycle(false)

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/skip" then

		if SeparatedStrings[2] == "cycle" then

			StartNewCycle()

		elseif SeparatedStrings[2] == "delay" and SeparatedStrings[3] == "" then

			TrySkipTaskDelayFor(table.concat(SeparatedStrings, " ", 3))
		end

	elseif InSender:IsAdmin() and (SeparatedStrings[1] == "/Лёха" or SeparatedStrings[1] == "/лёха") then

		DebugDude = player.CreateNextBot("Лёха")

		DebugDude:SetTeam(TEAM_GUARD)

		DebugDude:Spawn()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/give" and SeparatedStrings[2] ~= nil then

			TryGiveRoleplayItem(InSender, SeparatedStrings[2], SeparatedStrings[3] or "1")
	end

	return ""
end

function GM:AcceptInput(InTargetEntity, InInput, InActivator, InCaller, InValue)

	if not InActivator:IsPlayer() then

		return false
	end

	--MsgN(InInput)

	if InInput == "Use" and InActivator:GetNWFloat("TaskTimeLeft") <= 0 then

		local TargetEntityName = InTargetEntity:GetName()

		--MsgN(table.ToString(GuardOnlyUsableNames))

		if string.EndsWith(TargetEntityName, "_GuardOnly") and InActivator:Team() ~= TEAM_GUARD then

			--MsgN(TargetEntityName.." activation blocked!")

			InTargetEntity:Input("Lock")

			InTargetEntity:Input("Use")

			InTargetEntity:Fire("Unlock", nil, 1.5, InActivator, caller)

			return true
		end

		if InTargetEntity:GetNWBool("bGlobalSpeakerButton") and not UtilIsServerSabotaged() then

			ToggleGlobalSpeaker(InTargetEntity)

			return true
		end

		if InActivator:Team() == TEAM_GUARD then

			if InTargetEntity:GetNWBool("bScheduleSetupEntity") then

				if InActivator:GetNWBool("bOfficer") and not IsOfficerPhoneEnabled() and not UtilIsScheduleSet() then

					InActivator:SendLua("ToggleScheduleSetup()")

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

					OnImplementTaskStart(InActivator,
						InTargetEntity,
						UtilGetServerRepairDuration(),
						nil,
						TryRepairServer)

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

						OnImplementTaskStart(InActivator,
							InTargetEntity,
							UtilGetOfficerRoutineDuration(),
							CancelOfficerAnswerPhone,
							FinishOfficerAnswerPhone)
					end

					return true
				else

					return false
				end
			end

			if InTargetEntity:GetNWBool("bGuardTask") then

				if InTargetEntity:GetNWString("NowImplemetingBy") == ""
					and InActivator:GetName() == InTargetEntity:GetNWString("TaskImplementer") then

					OnImplementTaskStart(InActivator,
						InTargetEntity,
						UtilGetGuardRoutineDuration(),
						nil,
						FinishGuardAccountingTask)

					return true
				else

					return false
				end
			end

		elseif InActivator:Team() == TEAM_ROBBER then

			if InTargetEntity:GetNWBool("bServerSabotage") then

				if not InTargetEntity:GetNWBool("bSabotaged") then

					OnImplementTaskStart(InActivator,
						InTargetEntity,
						UtilGetServerSabotageDuration(),
						nil,
						TrySabotageServer)

					return true
				else

					return false
				end
			end

			if InTargetEntity:GetNWBool("bRobberTask") then

				if InTargetEntity:GetNWString("NowImplemetingBy") == "" then

					OnImplementTaskStart(InActivator,
						InTargetEntity,
						UtilGetRobberWorkDuration(),
						nil,
						FinishRobberWorkTask)

					return true
				else

					return false
				end
			end

			if InTargetEntity:GetNWBool("bDetailPickup") and GetDetailNumInStack(InTargetEntity) > 0 then

				OnImplementTaskStart(InActivator,
						InTargetEntity,
						UtilGetDetailPickupDuration(),
						nil,
						TryPickDetailFromWork)

				return true
			else

				return false
			end
		end
	end
end

function GM:PlayerInitialSpawn(InPlayer, bTransition)

	InPlayer:SetTeam(TEAM_UNASSIGNED)

	InPlayer:ConCommand("gm_showteam")
end

function GM:OnPlayerChangedTeam(InPlayer, InOldTeam, InNewTeam)

	if (InNewTeam == TEAM_SPECTATOR) then

		local PlayerEyePos = InPlayer:EyePos()

		InPlayer:SetPos(PlayerEyePos)
	end

	InPlayer:Spawn()

	PrintMessage(HUD_PRINTTALK, Format("%s присоединился к '%s'", InPlayer:Nick(), team.GetName(InNewTeam)))
end

function GM:PlayerSpawnAsSpectator(InPlayer)

	InPlayer:StripWeapons()

	if (InPlayer:Team() == TEAM_UNASSIGNED) then

	  InPlayer:Spectate(OBS_MODE_FIXED)

	  return
	end

	InPlayer:SetTeam(TEAM_SPECTATOR)

	InPlayer:Spectate(OBS_MODE_ROAMING)
end

function GM:PlayerSpawn(InPlayer, InTransiton)

	if (InPlayer:Team() == TEAM_SPECTATOR || InPlayer:Team() == TEAM_UNASSIGNED) then

		self:PlayerSpawnAsSpectator(InPlayer)

		return
	else
		player_manager.SetPlayerClass(InPlayer, table.Random(team.GetClass(InPlayer:Team())))

		InPlayer:UnSpectate()

		InPlayer:SetupHands()

		player_manager.OnPlayerSpawn(InPlayer, InTransiton)

		player_manager.RunClass(InPlayer, "Spawn")

		hook.Run("PlayerLoadout", InPlayer)

		hook.Run("PlayerSetModel", InPlayer)
	end
	
	net.Start("SendScheduleListToClients")

	net.WriteTable(GetServerScheduleList())

	net.Send(InPlayer)
end

function GM:PlayerDisconnected(InPlayer)
	
end

function GM:PlayerSelectTeamSpawn(TeamID, InPlayer)

	MsgN("PlayerSelectTeamSpawn")

	local SpawnPointList = team.GetSpawnPoints(TeamID) or {}

	if table.IsEmpty(SpawnPointList) then

		return
	end

	local OutSpawnPoint = table.Random(SpawnPointList)

	return OutSpawnPoint
end

function GM:PlayerSwitchWeapon(InPlayer, InOldWeapon, InNewWeapon)

	if InPlayer:GetNWBool("bHandcuffed") then

		return true
	end

	return false
end

function GM:OnPlayerHitGround(InPlayer, in_water, on_floater, speed)

	if in_water or speed < 450 or not IsValid(InPlayer) then return end

	-- Everything over a threshold hurts you, rising exponentially with speed
	local CalculatedDamage = math.pow(0.05 * (speed - 420), 1.75)

	-- I don't know exactly when on_floater is true, but it's probably when
	-- landing on something that is in water.
	if on_floater then CalculatedDamage = CalculatedDamage / 2 end

	-- if we fell on a dude, that hurts (him)
	local ground = InPlayer:GetGroundEntity()

	if IsValid(ground) and ground:IsPlayer() then

	  if math.floor(CalculatedDamage) > 0 then

		 local att = InPlayer

		 -- if the faller was pushed, that person should get attrib
		 local push = InPlayer.was_pushed

		 if push then
			-- TODO: move push time checking stuff into fn?
			if math.max(push.t or 0, push.hurt or 0) > CurTime() - 4 then

				att = push.att

			end
		 end

		 local DamageInfo = DamageInfo()

		 if att == InPlayer then
			-- hijack physgun damage as a marker of this type of kill
			DamageInfo:SetDamageType(DMG_CRUSH + DMG_PHYSGUN)
		 else
			-- if attributing to pusher, show more generic crush msg for now
			DamageInfo:SetDamageType(DMG_CRUSH)

		 end

		 DamageInfo:SetAttacker(att)
		 DamageInfo:SetInflictor(att)
		 DamageInfo:SetDamageForce(Vector(0,0,-1))
		 DamageInfo:SetDamage(CalculatedDamage)

		 ground:TakeDamageInfo(DamageInfo)

	  end

	  -- our own falling damage is cushioned
	  CalculatedDamage = CalculatedDamage / 3
	end

	if math.floor(CalculatedDamage) > 0 then
		
		local DamageInfo = DamageInfo()
		
		DamageInfo:SetDamageType(DMG_FALL)

		DamageInfo:SetAttacker(game.GetWorld())

		DamageInfo:SetInflictor(game.GetWorld())

		DamageInfo:SetDamageForce(Vector(0,0,1))

		DamageInfo:SetDamage(CalculatedDamage)

		InPlayer:TakeDamageInfo(DamageInfo)

		-- play CS:S fall sound if we got somewhat significant damage
		if CalculatedDamage > 5 then

			sound.Play(table.Random(PlayerFallSounds), InPlayer:GetMoveFromPos(), 55 + math.Clamp(CalculatedDamage, 0, 50), 100)
		end
	end
end
