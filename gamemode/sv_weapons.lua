---- Roleplay: Prison

hook.Add("PlayerButtonDown", "DropWeaponBind", function(InPlayer, InButton)

	if InButton == KEY_Q then

		local ActiveWeapon = InPlayer:GetActiveWeapon()

		if IsValid(ActiveWeapon) and ActiveWeapon.AllowDrop then

			InPlayer:DropWeapon(ActiveWeapon)
		end
	end
end)

function GM:PlayerCanPickupWeapon(InPlayer, InWeapon)

	MsgN("PlayerCanPickupWeapon()")

	if not IsValid(InPlayer) or not IsValid(InWeapon) or InPlayer:Team() == TEAM_SPECTATOR then

		return false
	end

	local WeaponClass = InWeapon:GetClass()

	if InPlayer:Team() == TEAM_GUARD then

		return not InPlayer:HasWeapon(WeaponClass) or WeaponClass == "weapon_rpp_talkie" or WeaponClass == "weapon_rpp_club"

	elseif InPlayer:Team() == TEAM_ROBBER then

		return not InPlayer:HasWeapon(WeaponClass)
	end

	return false
end
