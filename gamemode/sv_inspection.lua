---- Roleplay: Prison

local function GetIllegalWeaponList(InTargetPlayer)

	local OutWeaponList = {}

	local PlayerWeapons = InTargetPlayer:GetWeapons()

	for Index, Weapon in ipairs(PlayerWeapons) do

		local ClassName = Weapon:GetClass()

		--MsgN(ClassName)

		if ClassName ~= "weapon_rpp_unarmed" and ClassName ~= "weapon_rpp_fists" then

			table.insert(OutWeaponList, Weapon)
		end
	end

	return OutWeaponList
end

function OnInspect(InPlayer, InTargetPlayer)

	local StripDetailWoodNum = InTargetPlayer:GetNWInt("DetailWoodNum")

	local StripDetailMetalNum = InTargetPlayer:GetNWInt("DetailMetalNum")

	if math.random() < 0.8 then

		StripDetailWoodNum = math.Clamp(StripDetailWoodNum - math.random(1, 3), 0, 99)
	end

	if math.random() < 0.8 then

		StripDetailMetalNum = math.Clamp(StripDetailMetalNum - math.random(1, 3), 0, 99)
	end

	local InspectDataTable = {DetailWoodNum = StripDetailWoodNum,
							DetailMetalNum = StripDetailMetalNum,
							PicklockNum = InTargetPlayer:GetNWInt("PicklockNum"),
							IllegalWeaponNameList = {}}

	InTargetPlayer:SetNWInt("DetailWoodNum", InTargetPlayer:GetNWInt("DetailWoodNum") - StripDetailWoodNum)

	InTargetPlayer:SetNWInt("DetailMetalNum", InTargetPlayer:GetNWInt("DetailMetalNum") - StripDetailMetalNum)

	local IllegalWeaponList = GetIllegalWeaponList(InTargetPlayer)

	for Index, Weapon in pairs(IllegalWeaponList) do

		InTargetPlayer:StripWeapon(Weapon:GetClass())

		table.insert(InspectDataTable.IllegalWeaponNameList, Weapon:GetPrintName())
	end

	net.Start("SendAndShowInspectDataToClient")

	net.WriteTable(InspectDataTable)

	net.Send(InPlayer)
end
