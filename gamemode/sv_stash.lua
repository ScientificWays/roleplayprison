---- Roleplay: Prison

function OnStashOpen(InPlayer, InStashEntity)

	MsgN("OnStashOpen()")

	net.Start("ClientOpenStash")

	net.WriteInt(InStashEntity:EntIndex(), 32)

	net.Send(InPlayer)
end

function ServerReceiveTryInteractStash(InMessageLength, InPlayer)

	MsgN("ServerReceiveTryInteractStash()")

	local StashEntityIndex = net.ReadInt(32)

	local bPickupItem = net.ReadBool()

	local StashEntity = Entity(StashEntityIndex)

	if bPickupItem then

		TryPickItemFromStash(InPlayer, StashEntity)
	else

		local AddItemName = net.ReadString()

		--MsgN(StashEntityIndex, bPickupItem, AddItemName)

		if AddItemName == "DetailWoodNum" or AddItemName == "DetailMetalNum" or AddItemName == "PicklockNum" then

			TryAddStackableToStash(InPlayer, StashEntity, AddItemName)

		elseif AddItemName == "Weapon" then

			TryAddWeaponToStash(InPlayer, StashEntity)
		end
	end
end

function TryAddStackableToStash(InPlayer, InStashEntity, InStackableName)

	MsgN("TryAddStackableToStash()")

	if CanAddStackableToStash(InPlayer, InStashEntity, InStackableName) then

		InPlayer:SetNWInt(InStackableName, InPlayer:GetNWInt(InStackableName) - 1)

		InStashEntity:SetNWString("StashItemName", InStackableName)

		InStashEntity:SetNWInt("StashItemNum", InStashEntity:GetNWInt("StashItemNum") + 1)
	end
end

function TryAddWeaponToStash(InPlayer, InStashEntity)

	MsgN("TryAddWeaponToStash()")

	if CanAddWeaponToStash(InPlayer, InStashEntity) then

		local ActiveWeaponClassName = InPlayer:GetActiveWeapon():GetClass()

		InStashEntity:SetNWString("StashItemName", ActiveWeaponClassName)

		InStashEntity:SetNWInt("StashItemNum", 0)
	end
end

function TryPickItemFromStash(InPlayer, InStashEntity)

	MsgN("TryPickItemFromStash()")

	if CanPickItemFromStash(InPlayer, InStashEntity) then
		
		local StashItemName = InStashEntity:GetNWString("StashItemName")

		if StashItemName == "weapon_rpp_club" or StashItemName == "weapon_rpp_club" then

			InPlayer:Give(StashItemName)
		else

			InPlayer:SetNWInt(StashItemName, InPlayer:GetNWInt(StashItemName) + 1)
		end

		InStashEntity:SetNWInt("StashItemNum", InStashEntity:GetNWInt("StashItemNum") - 1)

		if InStashEntity:GetNWInt("StashItemNum") == 0 then

			InStashEntity:SetNWString("StashItemName", "")
		end
	end
end
