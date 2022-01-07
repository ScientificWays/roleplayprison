---- Roleplay: Prison

local DetailStackBias = 1.0

local DetailPickupList = {}

function GetDetailNumInStack(InPickupEntity)

	if IsValid(InPickupEntity) then

		local TemplateEntity = InPickupEntity:GetParent()

		MsgN(TemplateEntity:GetName())

		if IsValid(TemplateEntity) and DetailPickupList[TemplateEntity] ~= nil then

			MsgN(string.format("GetDetailNumInStack() return %i", DetailPickupList[TemplateEntity]:Num()))

			return DetailPickupList[TemplateEntity]:Num()
		end
	end

	return 0
end

function TryAddDetailForWork(InWorkEntity)

	if IsValid(InWorkEntity) and string.EndsWith(InWorkEntity:GetName(), "_RobberTask") then

		local TemplateEntity = InWorkEntity:GetParent()

		if IsValid(TemplateEntity) and string.EndsWith(TemplateEntity:GetName(), "_DetailSpawn") then

			if DetailPickupList[TemplateEntity] == nil then

				DetailPickupList[TemplateEntity] = {DetailType = "",
					Num = function(self) return #self.DetailEntityList end,
					DetailEntityList = {}}

				if string.EndsWith(TemplateEntity:GetName(), "_Wood_DetailSpawn") then

					DetailPickupList[TemplateEntity].DetailType = "Wood"

				elseif string.EndsWith(TemplateEntity:GetName(), "_Metal_DetailSpawn") then

					DetailPickupList[TemplateEntity].DetailType = "Metal"
				end
			end

			local PickupData = DetailPickupList[TemplateEntity]

			local NewDetailEntity = ents.Create("prop_dynamic")

			local NewDetailPos = TemplateEntity:GetPos()

			NewDetailPos:Add(Vector(math.Rand(-1.0, 1.0), math.Rand(-1.0, 1.0), DetailStackBias * PickupData:Num()))

			NewDetailEntity:SetPos(NewDetailPos)

			local NewDetailAngles = TemplateEntity:GetAngles()

			NewDetailAngles:Add(Angle(0.0, math.Rand(-2.0, 2.0), 0.0))

			NewDetailEntity:SetAngles(NewDetailAngles)

			NewDetailEntity:SetModel(TemplateEntity:GetModel())

			table.insert(PickupData.DetailEntityList, NewDetailEntity)

			--NewDetailEntity:Spawn()

			--[[MsgN(string.format("Detail num now %i (%i)", PickupData:Num(), #PickupData.DetailEntityList))

			MsgN(table.ToString(PickupData))

			MsgN(string.format("Template detail pos: %s, angles: %s, model: %s",
				TemplateEntity:GetPos(), TemplateEntity:GetAngles(), TemplateEntity:GetModel()))

			MsgN(string.format("New detail pos: %s, angles: %s, model: %s",
				NewDetailEntity:GetPos(), NewDetailEntity:GetAngles(), NewDetailEntity:GetModel()))]]
		end
	end
end

function TryPickDetailFromWork(InPickingPlayer, InWorkEntity)

	MsgN("TryPickDetailFromWork()")

	--In fact double check
	if IsValid(InWorkEntity) and string.EndsWith(InWorkEntity:GetName(), "_DetailPickup") then

		local TemplateEntity = InWorkEntity:GetParent()

		MsgN(TemplateEntity)

		if IsValid(TemplateEntity) and string.EndsWith(TemplateEntity:GetName(), "_DetailSpawn") then

			local PickupData = DetailPickupList[TemplateEntity]

			MsgN(table.ToString(PickupData))

			if PickupData and PickupData:Num() > 0 then

				if PickupData.DetailType == "Wood" then

					InPickingPlayer:SetNWInt("DetailWoodNum", InPickingPlayer:GetNWInt("DetailWoodNum") + 1)

				elseif PickupData.DetailType == "Metal" then

					InPickingPlayer:SetNWInt("DetailMetalNum", InPickingPlayer:GetNWInt("DetailMetalNum") + 1)
				end

				local LastAddedDetail = table.remove(PickupData.DetailEntityList)

				MsgN(string.format("Add detail %s for %s", PickupData.DetailType, InPickingPlayer:GetName()))

				MsgN(string.format("Remove entity %s", LastAddedDetail))

				LastAddedDetail:Remove()	
			end
		end
	end
end
