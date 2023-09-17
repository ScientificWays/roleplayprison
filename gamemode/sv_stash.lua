---- Roleplay: Prison

function UpdateStashes()

	MsgN("UpdateStashes()")

	local AllEntities = ents.GetAll()

	for Index, SampleEntity in ipairs(AllEntities) do

		if SampleEntity:GetNWBool("bStashMetal") then

			TryAddStackableToStash(nil, SampleEntity, "DetailMetalNum", math.random(0, 2))
		end
	end
end

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

			TryAddStackableToStash(InPlayer, StashEntity, AddItemName, 1)

		elseif AddItemName == "Weapon" then

			TryAddWeaponToStash(InPlayer, StashEntity)
		end
	end
end

function TryAddStackableToStash(InPlayer, InStashEntity, InStackableName, InNum)

	MsgN("TryAddStackableToStash()")

	if CanAddStackableToStash(InPlayer, InStashEntity, InStackableName, InNum) then

		if IsValid(InPlayer) then

			InPlayer:SetNWInt(InStackableName, InPlayer:GetNWInt(InStackableName) - InNum)
		end

		InStashEntity:SetNWString("StashItemName", InStackableName)

		InStashEntity:SetNWInt("StashItemNum", InStashEntity:GetNWInt("StashItemNum") + InNum)
	end
end

function TryAddWeaponToStash(InPlayer, InStashEntity)

	MsgN("TryAddWeaponToStash()")

	if CanAddWeaponToStash(InPlayer, InStashEntity) then

		local ActiveWeaponClassName = InPlayer:GetActiveWeapon():GetClass()

		InStashEntity:SetNWString("StashItemName", ActiveWeaponClassName)

		InStashEntity:SetNWInt("StashItemNum", 0)

		InPlayer:StripWeapon(ActiveWeaponClassName)
	end
end

function TryPickItemFromStash(InPlayer, InStashEntity)

	MsgN("TryPickItemFromStash()")

	if CanPickItemFromStash(InPlayer, InStashEntity) then
		
		local StashItemName = InStashEntity:GetNWString("StashItemName")

		if string.StartsWith(StashItemName, "weapon_") then

			InPlayer:Give(StashItemName)
		else

			InPlayer:SetNWInt(StashItemName, InPlayer:GetNWInt(StashItemName) + 1)
		end

		InStashEntity:SetNWInt("StashItemNum", InStashEntity:GetNWInt("StashItemNum") - 1)

		--MsgN(InStashEntity:GetNWInt("StashItemNum"))

		if InStashEntity:GetNWInt("StashItemNum") <= 0 then

			InStashEntity:SetNWString("StashItemName", "")

			InStashEntity:SetNWInt("StashItemNum", 0)
		end
	end
end
