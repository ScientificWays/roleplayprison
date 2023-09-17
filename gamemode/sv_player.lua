---- Roleplay: Prison

function UpdatePlayerMonitorType(InPlayer)

	if UtilCheckPlayerInArea(InPlayer, OfficerMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Officer")

		InPlayer.MonitorTimeLeft = 10

	elseif UtilCheckPlayerInArea(InPlayer, ControlMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Control")

		InPlayer.MonitorTimeLeft = 10

	elseif UtilCheckPlayerInArea(InPlayer, LibraryMonitorArea) then

		InPlayer:SetNWString("ActiveMonitorType", "Library")

		InPlayer.MonitorTimeLeft = 10

	else
		
		InPlayer.MonitorTimeLeft = InPlayer.MonitorTimeLeft - 1

		if InPlayer.MonitorTimeLeft <= 0 then

			InPlayer:SetNWString("ActiveMonitorType", "None")

			InPlayer.MonitorTimeLeft = 0
		end		
	end
end

function ServerReceiveRequestJoinTeam(InMessageLength, InPlayer)

	local TeamID = net.ReadInt(32)

	local bMale = net.ReadBool()

	MsgN(Format("ServerReceiveRequestJoinTeam() %i, %s", TeamID, bMale))

	InPlayer:SetNWBool("bMale", bMale)

	GAMEMODE:PlayerRequestTeam(InPlayer, TeamID)
end

function GM:PlayerInitialSpawn(InPlayer, bTransition)

	InPlayer:SetTeam(TEAM_UNASSIGNED)

	InPlayer:ConCommand("gm_showteam")

	InPlayer.MonitorTimeLeft = 0

	InPlayer:SetNWBool("bMale", true)
	
	net.Start("SendScheduleListToClients")

	net.WriteTable(GetServerScheduleList())

	net.Send(InPlayer)
end

function GM:OnPlayerChangedTeam(InPlayer, InOldTeam, InNewTeam)

	if InNewTeam == TEAM_SPECTATOR then

		InPlayer:Spawn()

		UtilSendEventMessageToPlayers({"RPP_Event.Spectate", InPlayer:Nick()})

		return
	end

	local NewModel, NewRPName, NewRPSurname = GetNewPlayerIdentity(InPlayer, InNewTeam, InPlayer:GetNWBool("bMale"))

	InPlayer.RPModel = NewModel

	InPlayer:SetNWString("RPName", NewRPName)
	InPlayer:SetNWString("RPSurname", NewRPSurname)

	InPlayer:Spawn()

	UtilSendEventMessageToPlayers({"RPP_Event.JoinRole", InPlayer:Nick(), team.GetName(InNewTeam), UtilGetRPNameSurname(InPlayer)})
end

function GM:PlayerRequestTeam(InPlayer, InTeamID)

	if InPlayer:GetNWBool("bEscaped") then

		return
	end

	-- This team isn't joinable
	if not team.Joinable(InTeamID) then

		InPlayer:ChatPrint("You can't join this team")

		return
	end

	-- This team isn't joinable
	if not GAMEMODE:PlayerCanJoinTeam(InPlayer, InTeamID) then

		return
	end

	GAMEMODE:PlayerJoinTeam(InPlayer, InTeamID)
end

function GM:PlayerSpawnAsSpectator(InPlayer)

	InPlayer:StripWeapons()

	if InPlayer:Team() == TEAM_UNASSIGNED then

		InPlayer:Spectate(OBS_MODE_FIXED)

		return
	end

	InPlayer:SetTeam(TEAM_SPECTATOR)

	InPlayer:Spectate(OBS_MODE_ROAMING)
end

function GM:PostPlayerDeath(InPlayer)

	OnPlayerHandcuffsOff(InPlayer)

	InPlayer:SetNWBool("bIncapped", false)
end

function GM:PlayerSpawn(InPlayer, bTransiton)

	OnPlayerHandcuffsOff(InPlayer)

	InPlayer:SetNWBool("bIncapped", false)

	if InPlayer:Team() == TEAM_SPECTATOR or InPlayer:Team() == TEAM_UNASSIGNED then

		self:PlayerSpawnAsSpectator(InPlayer)

		return
	else
		player_manager.SetPlayerClass(InPlayer, table.Random(team.GetClass(InPlayer:Team())))

		InPlayer:UnSpectate()

		InPlayer:SetupHands()

		player_manager.OnPlayerSpawn(InPlayer, bTransiton)

		player_manager.RunClass(InPlayer, "Spawn")

		InPlayer:ConCommand("pp_colormod 1")

		InPlayer:ConCommand("pp_colormod_addr 0")
		InPlayer:ConCommand("pp_colormod_addg 0")
		InPlayer:ConCommand("pp_colormod_addb 0")
		InPlayer:ConCommand("pp_colormod_contrast 1")
		InPlayer:ConCommand("pp_colormod_mulr 0")
		InPlayer:ConCommand("pp_colormod_mulg 0")
		InPlayer:ConCommand("pp_colormod_mulb 0")

		InPlayer:ConCommand("pp_motionblur 1")

		InPlayer:ConCommand("pp_motionblur_addalpha 1.0")
		InPlayer:ConCommand("pp_motionblur_drawalpha 1.0")
		InPlayer:ConCommand("pp_motionblur_delay 0.0")

		InPlayer.MonitorTimeLeft = 0

		InPlayer.Food = 100

		InPlayer.Water = 100

		InPlayer.Energy = UtilGetSprintDuration()

		InPlayer:SetNWFloat("EnergyValue", 1.0)

		hook.Run("PlayerLoadout", InPlayer)

		hook.Run("PlayerSetModel", InPlayer)

		local WeaponUnarmed = InPlayer:GetWeapon("weapon_rpp_unarmed")

		if IsValid(WeaponUnarmed) then

			InPlayer:SetActiveWeapon(WeaponUnarmed)
		end
	end
end

function GM:PlayerDisconnected(InPlayer)
	
	return
end

function GM:PlayerSelectTeamSpawn(TeamID, InPlayer)

	MsgN("PlayerSelectTeamSpawn()")

	if InPlayer:GetNWBool("bOfficer") and UtilIsOfficerPunished() then

		local TeleportTarget = table.Random(ents.FindByName("OfficerPunishment_Teleport"))

		if IsValid(TeleportTarget) then

			return TeleportTarget
		end
	end

	local SpawnPointList = team.GetSpawnPoints(TeamID) or {}

	if table.IsEmpty(SpawnPointList) then

		return
	end

	local OutSpawnPoint = table.Random(SpawnPointList)

	return OutSpawnPoint
end

function GM:PlayerSwitchWeapon(InPlayer, InOldWeapon, InNewWeapon)

	if UtilPlayerCanInteract(InPlayer) then

		return false
	end

	return true
end

local PlayerFallSounds = {
	Sound("player/damage1.wav"),
	Sound("player/damage2.wav"),
	Sound("player/damage3.wav")
}

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

function UpdateAllPlayersHealthValue()

	local AllPlayers = player.GetAll()

	for Index, SamplePlayer in ipairs(AllPlayers) do

		SamplePlayer:SetNWFloat("HealthValue", SamplePlayer:Health() / 100.0)
	end
end

function GM:PlayerHurt(InVictimPlayer, InAttackerEntity, InHealthRemaining, InDamageTaken)

	UpdateAllPlayersHealthValue()

	if InAttackerEntity:IsPlayer() then

		InVictimPlayer:SetNWFloat("DamageSlowTime", 2.0)
	end
	
	if InVictimPlayer:GetNWBool("bUsingCameras") then

		StopCamerasModeForPlayer(InVictimPlayer)
	end
end

timer.Create("DamageSlowUpdate", 0.5, 0, function()

	local AllPlayers = player.GetAll()

	for Index, SamplePlayer in ipairs(AllPlayers) do

		if SamplePlayer:GetNWFloat("DamageSlowTime") > 0.5 then

			SamplePlayer:SetNWFloat("DamageSlowTime", SamplePlayer:GetNWFloat("DamageSlowTime") - 0.5)

		else
			SamplePlayer:SetNWFloat("DamageSlowTime", 0.0)
		end
	end
end)

timer.Create("InjuryUpdate", 0.2, 0, UpdateAllPlayersHealthValue)

function GM:PlayerNoClip(InPlayer, bDesiredNoClipState)
	
	return (UtilGetAllowNoclip() and InPlayer:Alive()) or bDesiredNoClipState == false
end
