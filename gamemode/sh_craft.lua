---- Roleplay: Prison

local CraftDataList = {
	[1] = {Name = "Picklock", PrintName = "RPP_Item.Picklock", Icon = Material("vgui/rpp/icon_picklock"), Metal = 2, Wood = 0},
	[2] = {Name = "Club", PrintName = "RPP_Weapon.Club", Icon = Material("vgui/rpp/icon_club"), Metal = 0, Wood = 6},
	[3] = {Name = "Talkie", PrintName = "RPP_Weapon.Talkie", Icon = Material("vgui/rpp/icon_talkie"), Metal = 3, Wood = 1},
	[4] = {Name = "Crowbar", PrintName = "RPP_Weapon.Crowbar", Icon = Material("vgui/rpp/icon_crowbar"), Metal = 4, Wood = 0}
}

function GetCraftDataList()

	--MsgN("GetCraftDataList()")

	return CraftDataList
end

function CanCraftRoleplayItem(InPlayer, InItemData)

	local DetailWoodNum = InPlayer:GetNWInt("DetailWoodNum")
	local DetailMetalNum = InPlayer:GetNWInt("DetailMetalNum")

	if DetailWoodNum < InItemData.Wood or DetailMetalNum < InItemData.Metal then

		return false
	end

	return true
end
