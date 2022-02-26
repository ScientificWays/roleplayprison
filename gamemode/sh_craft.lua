---- Roleplay: Prison

local CraftDataList = {
	[1] = {Name = "Picklock", PrintName = "Отмычка", Icon = Material("vgui/rpp/icon_picklock"), Metal = 2, Wood = 0},
	[2] = {Name = "Club", PrintName = "Дубинка", Icon = Material("vgui/rpp/icon_club"), Metal = 0, Wood = 6},
	[3] = {Name = "Talkie", PrintName = "Рация", Icon = Material("vgui/rpp/icon_talkie"), Metal = 3, Wood = 1}
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
