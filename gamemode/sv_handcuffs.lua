---- Roleplay: Prison

function OnPlayerHandcuffsOn(InPlayer)

	MsgN(Format("%s OnPlayerHandcuffsOn()", InPlayer:GetNWString("RPName")))

	InPlayer:SetNWBool("bHandcuffed", true)

	local WeaponUnarmed = InPlayer:GetWeapon("weapon_rpp_unarmed")

	if IsValid(WeaponUnarmed) then

		InPlayer:SetActiveWeapon(WeaponUnarmed)

		WeaponUnarmed:SetHoldType("fist")
	end
end

function OnPlayerHandcuffsOff(InPlayer)

	MsgN(Format("%s OnPlayerHandcuffsOff()", InPlayer:GetNWString("RPName")))

	InPlayer:SetNWBool("bHandcuffed", false)

	local WeaponUnarmed = InPlayer:GetWeapon("weapon_rpp_unarmed")

	if IsValid(WeaponUnarmed) then

		WeaponUnarmed:SetHoldType("normal")
	end
end
