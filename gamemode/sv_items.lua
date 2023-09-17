---- Roleplay: Prison

function OnWorkbenchOpen(InPlayer, InStashEntity)

	net.Start("ClientOpenWorkbench")

	net.Send(InPlayer)
end

function ServerReceiveTryCraftItem(InMessageLength, InPlayer)

	local ItemName = net.ReadString()

	TryCraftItem(InPlayer, ItemName)
end

function TryGiveWeaponItem(InPlayer, InItemNameStr)

	--MsgN(InItemNameStr)

	if InItemNameStr == "club" then

		InPlayer:Give("weapon_rpp_club")

		return true

	elseif InItemNameStr == "talkie" then

		InPlayer:Give("weapon_rpp_talkie")

		return true

	elseif InItemNameStr == "crowbar" then

		InPlayer:Give("weapon_crowbar")

		return true
	end

	return false
end

function TryGiveStackableItem(InPlayer, InItemNameStr, InItemNum)

	MsgN(Format("TryGiveStackableItem() %s", InItemNum))

	local ItemName = string.lower(InItemNameStr)

	local VariableName = ""

	if ItemName == "wood" then

		VariableName = "DetailWoodNum"

	elseif ItemName == "metal" then

		VariableName = "DetailMetalNum"

	elseif ItemName == "picklock" then

		VariableName = "PicklockNum"
	end

	if VariableName ~= "" then

		local FinalItemNum = InPlayer:GetNWInt(VariableName) + InItemNum

		InPlayer:SetNWInt(VariableName, math.Clamp(FinalItemNum, 0, 99))

		return true
	end

	return false
end

function TryCraftItem(InPlayer, InItemName)

	MsgN(Format("TryCraftItem(), %s", InItemName))

	local ItemData = {}

	local CraftDataList = GetCraftDataList()

	for Index, SampleItemData in ipairs(CraftDataList) do

		--MsgN(Format("%s == %s", SampleItemData.Name, InItemName))

		if SampleItemData.Name == InItemName then

			ItemData = SampleItemData

			break
		end
	end

	if table.IsEmpty(ItemData) then

		MsgN("TryCraftItem() ItemData is empty!")

		return
	end

	if not CanCraftRoleplayItem(InPlayer, ItemData) then

		MsgN("TryCraftItem() CanCraftRoleplayItem() false")

		return
	end

	InPlayer:SetNWInt("DetailWoodNum", InPlayer:GetNWInt("DetailWoodNum") - ItemData.Wood)
	InPlayer:SetNWInt("DetailMetalNum", InPlayer:GetNWInt("DetailMetalNum") - ItemData.Metal)

	if ItemData.Name == "Picklock" then

		InPlayer:SetNWInt("PicklockNum", InPlayer:GetNWInt("PicklockNum") + 1)

	elseif ItemData.Name == "Club" then

		if InPlayer:HasWeapon("weapon_rpp_club") then

			InPlayer:DropWeapon(InPlayer:GetWeapon("weapon_rpp_club"))
		end
		InPlayer:Give("weapon_rpp_club")

	elseif ItemData.Name == "Talkie" then

		if InPlayer:HasWeapon("weapon_rpp_talkie") then

			InPlayer:DropWeapon(InPlayer:GetWeapon("weapon_rpp_talkie"))
		end
		InPlayer:Give("weapon_rpp_talkie")

	elseif ItemData.Name == "Crowbar" then

		if InPlayer:HasWeapon("weapon_crowbar") then

			InPlayer:DropWeapon(InPlayer:GetWeapon("weapon_crowbar"))
		end
		InPlayer:Give("weapon_crowbar")
	end
end
