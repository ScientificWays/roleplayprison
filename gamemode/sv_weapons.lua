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

	if InPlayer.bLoadout then

		return true
	end

	local WeaponClass = InWeapon:GetClass()

	if InPlayer:Team() == TEAM_SPECTATOR or not IsValid(InPlayer) or not IsValid(InWeapon) or InPlayer:HasWeapon(WeaponClass) then

		return false
	end

	return UtilPlayerCanInteract(InPlayer) and InPlayer:KeyPressed(IN_USE)
end

function GM:PlayerCanPickupItem(InPlayer, InEntity)

	return UtilPlayerCanInteract(InPlayer) and InPlayer:KeyPressed(IN_USE)
end
