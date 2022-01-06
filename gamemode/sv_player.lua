---- Roleplay: Prison

local PlayerFallSounds = {
	Sound("player/damage1.wav"),
	Sound("player/damage2.wav"),
	Sound("player/damage3.wav")
};

local DebugDude = {}

function UpdatePlayerMonitorType(InPlayer)

	if CheckPlayerInArea(InPlayer, OfficerMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Officer")

	elseif CheckPlayerInArea(InPlayer, ControlMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Control")

	elseif CheckPlayerInArea(InPlayer, LibraryMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Library")
	else
			
		InPlayer:SetNWString("ActiveMonitorType", "None")
	end
end

function CheckPlayerInArea(InPlayer, InArea)

	if IsValid(InArea) then

		local PlayerPos = InPlayer:GetPos()

		local AreaPos = InArea:GetPos()

		local AreaBoundMin, AreaBoundMax = InArea:GetCollisionBounds()

		--MsgN(InArea:GetName(), AreaBoundMin, AreaBoundMax)

		--MsgN(PlayerPos:WithinAABox(AreaPos + AreaBoundMin, AreaPos + AreaBoundMax))

		if PlayerPos:WithinAABox(AreaPos + AreaBoundMin, AreaPos + AreaBoundMax) then

			return true
		end
	end

	return false
end

function GM:PlayerSay(sender, text, teamChat)

	if text[1] ~= "/" then

		return text
	end

	SeparatedStrings = string.Explode(" ", text, false)

	if SeparatedStrings[1] == "/vote" then

		AddOfficerVote(sender, SeparatedStrings[2] or "")

	elseif sender:IsAdmin() and SeparatedStrings[1] == "/votefinish" then

		FinishOfficerVote()

	elseif sender:IsAdmin() and SeparatedStrings[1] == "/start" then

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)

		StartNewCycle()

	elseif sender:IsAdmin() and SeparatedStrings[1] == "/auto" then

		FinishOfficerVote()

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)
		
		StartNewCycle()

	elseif sender:IsAdmin() and SeparatedStrings[1] == "/pause" then

		ToggleCycle(true)

	elseif sender:IsAdmin() and SeparatedStrings[1] == "/unpause" then

		ToggleCycle(false)

	elseif sender:IsAdmin() and SeparatedStrings[1] == "/skip" then

		if SeparatedStrings[2] == "cycle" then

			StartNewCycle()

		elseif SeparatedStrings[2] == "delay" then

			TrySkipTaskDelayFor(SeparatedStrings[3] or "")
		end

	elseif sender:IsAdmin() and (SeparatedStrings[1] == "/Лёха" or SeparatedStrings[1] == "/лёха") then

		DebugDude = player.CreateNextBot("Лёха")

		DebugDude:SetTeam(TEAM_GUARD)

		DebugDude:Spawn()

	end

	return ""
end

function GM:AcceptInput(ent, input, activator, caller, value)

	if not activator:IsPlayer() then

		return false
	end

	--MsgN(input)

	if input == "Use" then

		local TargetEntityName = ent:GetName()

		--MsgN(table.ToString(GuardOnlyUsableNames))

		if string.EndsWith(TargetEntityName, "_GuardOnly") and activator:Team() ~= TEAM_GUARD then

			--MsgN(TargetEntityName.." activation blocked!")

			ent:Input("Lock")

			ent:Input("Use")

			ent:Fire("Unlock", nil, 1.5, activator, caller)

			return true
		end

		if string.EndsWith(TargetEntityName, "_ScheduleSetup") then

			if activator:GetNWBool("bOfficer") and not IsOfficerPhoneEnabled() and not UtilIsScheduleSet() then

				activator:SendLua("ToggleScheduleSetup()")

				return false
			else

				ent:Input("Lock")

				ent:Input("Use")

				ent:Fire("Unlock", nil, 1.5, activator, caller)

				return true
			end
		end

		if string.EndsWith(TargetEntityName, "_OfficerPhone") then

			if activator:GetNWBool("bOfficer") and IsOfficerPhoneEnabled() then

				--Temporary disable ringing, true if no punishment
				if OnOfficerAnswerPhone() then

					OnImplementTaskStart(activator,
						UtilGetOfficerRoutineDuration(),
						CancelOfficerAnswerPhone,
						FinishOfficerAnswerPhone)
				end

				return true
			else

				return false
			end
		end

		if string.EndsWith(TargetEntityName, "_GuardTask") then

			if activator:GetName() == ent:GetNWString("TaskImplementer") then

				OnImplementTaskStart(activator,
					UtilGetGuardRoutineDuration(),
					CancelGuardAccountingTask,
					FinishGuardAccountingTask)

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

			sound.Play(table.Random(PlayerFallSounds), InPlayer:GetShootPos(), 55 + math.Clamp(CalculatedDamage, 0, 50), 100)
		end
	end
end
