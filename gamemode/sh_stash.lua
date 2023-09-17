---- Roleplay: Prison

local StashDataList = {
	DetailWoodNum = {Icon = Material("vgui/rpp/icon_wood")},
	DetailMetalNum = {Icon = Material("vgui/rpp/icon_metal")},
	PicklockNum = {Icon = Material("vgui/rpp/icon_picklock")},
	weapon_rpp_club = {Icon = Material("vgui/rpp/icon_club")},
	weapon_rpp_talkie = {Icon = Material("vgui/rpp/icon_talkie")},
	weapon_crowbar = {Icon = Material("vgui/rpp/icon_crowbar")},
}

function GetStashDataList()

	--MsgN("GetStashDataList()")

	return StashDataList
end

function CanAddStackableToStash(InPlayer, InStashEntity, InStackableName, InNum)

	if InStashEntity == nil then

		return false
	end

	if InPlayer == nil then

		return true
	end

	if InPlayer:Team() == TEAM_GUARD then

		return false
	end

	local StashItemName = InStashEntity:GetNWString("StashItemName")

	--MsgN(InStackableName)

	return (StashItemName == "" or StashItemName == InStackableName)
	and InPlayer:GetNWInt(InStackableName) >= InNum
end

function CanAddWeaponToStash(InPlayer, InStashEntity)

	if InPlayer:Team() == TEAM_GUARD then

		return false
	end

	local ActiveWeaponClassName = InPlayer:GetActiveWeapon():GetClass()

	return InStashEntity:GetNWString("StashItemName") == "" and StashDataList[ActiveWeaponClassName] ~= nil
end

function CanPickItemFromStash(InPlayer, InStashEntity)

	local StashItemName = InStashEntity:GetNWString("StashItemName")

	return StashItemName ~= "" and (not InPlayer:HasWeapon(StashItemName) or InPlayer:Team() == TEAM_GUARD)
end
