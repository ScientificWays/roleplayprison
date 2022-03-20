---- Roleplay: Prison

hook.Add("PlayerButtonDown", "DropWeaponBind", function(InPlayer, InButton)

	if InButton == KEY_Q then

		local ActiveWeapon = InPlayer:GetActiveWeapon()

		if IsValid(ActiveWeapon) and ActiveWeapon.AllowDrop then

			InPlayer:DropWeapon(ActiveWeapon)
		end
	end
end)

function ResetArmory()

	local ResetEntity = ents.FindByName("Armory_Reset")[1]

	if IsValid(ResetEntity) then

		ResetEntity:Fire("Trigger")

		MsgN("ResetArmory")
	end
end

function GM:PlayerCanPickupWeapon(InPlayer, InWeapon)

	MsgN("PlayerCanPickupWeapon()")

	if CurTime() - InWeapon:GetCreationTime() < 0.5 then

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

function GM:PlayerAmmoChanged(InPlayer, InAmmoID, InOldCount, InNewCount)

	local DefaultAmmoClipSize = 9999

	-- 357
	if InAmmoID == 5 then

		DefaultAmmoClipSize = 6
	end

	local MaxReserveAmmo = UtilGetMaxReserveClips() * DefaultAmmoClipSize

	if InNewCount > MaxReserveAmmo then

		InPlayer:SetAmmo(MaxReserveAmmo, InAmmoID)
	end
end
