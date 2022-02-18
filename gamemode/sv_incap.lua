---- Roleplay: Prison

timer.Create("IncappedBleed", 2.5, 0, function()

	local AllPlayers = player.GetAll()

	for Index, SamplePlayer in ipairs(AllPlayers) do

		if SamplePlayer:GetNWBool("bIncapped") then

			SamplePlayer:SetHealth(math.max(1, SamplePlayer:Health() - 5))

			MsgN(0.01 * SamplePlayer:GetVelocity():Length())

			if math.random() < 0.01 * SamplePlayer:GetVelocity():Length() then

				util.Decal("Blood", SamplePlayer:GetPos() + Vector(0, 0, 10), SamplePlayer:GetPos() - Vector(0, 0, 10), SamplePlayer)
			end
		end
	end
end)

hook.Add("SetupMove", "IncappedMove", function(InPlayer, InMoveData, InCommandData)

	if InPlayer:GetNWBool("bIncapped") then

		local MaxSpeed = 100.0

		if InPlayer:Crouching() then

			MaxSpeed = 50.0
		end

		InMoveData:SetMaxClientSpeed(math.min(InMoveData:GetMaxClientSpeed() * 0.25, MaxSpeed))
	end
end)

function GM:EntityTakeDamage(InEntity, InDamageInfo)

	--MsgN("EntityTakeDamage()")

	if InEntity:IsPlayer() then

		if InEntity:GetNWBool("bIncapped") then

			InDamageInfo:SetDamage(0.0)
		else
			if InEntity:Health() <= InDamageInfo:GetDamage() then

				InDamageInfo:SetDamage(0.0)

				OnPlayerIncapped(InEntity)
			end
		end
	end
end

function OnPlayerIncapped(InPlayer)

	MsgN(InPlayer, "OnPlayerIncapped()")

	InPlayer:SetNWBool("bIncapped", true)

	InPlayer:ScreenFade(SCREENFADE.IN, COLOR_RED, 5.0, 0.0)

	InPlayer:SetHealth(1)

	local PlayerWeapons = InPlayer:GetWeapons()

	for Index, Weapon in pairs(PlayerWeapons) do

		if Weapon:GetClass() ~= "weapon_rpp_fists" and Weapon:GetClass() ~= "weapon_rpp_unarmed" then

			InPlayer:DropWeapon(Weapon, InPlayer:GetVelocity())
		end
	end

	InPlayer:SelectWeapon("weapon_rpp_unarmed")

	ServerSendMulticastDoAnimation(InPlayer, ACT_HL2MP_WALK_ZOMBIE_04, false)
end

function OnPlayerRevived(InPlayer)

	MsgN(InPlayer, "OnPlayerRevived()")

	InPlayer:SetNWBool("bIncapped", false)

	InPlayer:ScreenFade(SCREENFADE.IN, COLOR_WHITE, 5.0, 0.0)

	InPlayer:SetHealth(40)

	ServerSendMulticastDoAnimation(InPlayer, ACT_GMOD_TAUNT_CHEER, true)
end
