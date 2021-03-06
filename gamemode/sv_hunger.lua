---- Roleplay: Prison

timer.Create("HungerTick", 24.0, 0, function()

	local AllPlayers = player.GetAll()

	for Index, Player in ipairs(AllPlayers) do

		if Player:Team() == TEAM_ROBBER or Player:Team() == TEAM_GUARD then

			local HungerMultiplier = 0.5

			if Player:Team() == TEAM_GUARD and UtilCheckPlayerInArea(Player, GuardRestArea) then

				MsgN(Format("Hunger tick for %s in rest area", Player))

				Player:SetArmor(math.Clamp(Player:Armor() + 15, 0, Player:GetMaxArmor()))

				HungerMultiplier = 0.0

			elseif UtilCheckPlayerInArea(Player, PunishmentArea) then

				HungerMultiplier = 3.0
			end

			if Player.Food >= 1 * HungerMultiplier then

				Player.Food = Player.Food - 1 * HungerMultiplier
			else

				Player.Food = 0
			end

			if Player.Water >= 2 * HungerMultiplier then

				Player.Water = Player.Water - 2 * HungerMultiplier
			else

				Player.Water = 0
			end

			if Player.Food < 20 or Player.Water < 20 then

				if Player:Health() > 15 then

					Player:SetHealth(Player:Health() - 1)
				end

			elseif Player.Food > 50 and Player.Water > 50 then

				if Player:Health() < 100 then

					Player:SetHealth(math.Clamp(Player:Health() + 5, 0, Player:GetMaxHealth()))
				end
			end

			UpdatePlayerHungerValue(Player)
		end
	end
end)

hook.Add("OnEntityCreated", "NutritionSpawn", function(InEntity)

	timer.Simple(0.1, function()

		if not IsValid(InEntity) then

			return
		end

		--MsgN(InEntity:GetName())

		if string.EndsWith(InEntity:GetName(), "_FoodInstance") then

			InEntity:SetNWBool("bFoodInstance", true)

			InEntity:SetNWBool("bShowHint", true)

		elseif string.EndsWith(InEntity:GetName(), "_WaterInstance") then

			InEntity:SetNWBool("bWaterInstance", true)

			InEntity:SetNWBool("bShowHint", true)
		end
	end)
end)

hook.Add("OnPlayerPhysicsPickup", "NutritionPickup", function(InPlayer, InEntity)

	if InEntity:GetNWBool("bFoodInstance") or InEntity:GetNWBool("bWaterInstance") then

		InEntity:SetNWBool("bShowHint", false)
	end
end)

hook.Add("OnPlayerPhysicsDrop", "NutritionDrop", function(InPlayer, InEntity, bThrown)

	if InEntity:GetNWBool("bFoodInstance") or InEntity:GetNWBool("bWaterInstance") then

		InEntity:SetNWBool("bShowHint", true)
	end
end)

function UpdatePlayerHungerValue(InPlayer)

	InPlayer.Food = math.Clamp(InPlayer.Food, 0.0, 100.0)

	InPlayer.Water = math.Clamp(InPlayer.Water, 0.0, 100.0)

	--MsgN(Format("%s Food: %i, Water: %s", InPlayer:GetNWString("RPName"), InPlayer.Food, InPlayer.Water))

	InPlayer:SetNWFloat("HungerValue", 1.0 - math.Clamp((InPlayer.Food + InPlayer.Water) * 2, 0, 200) / 200)
end

function AddNutrition(InPlayer, InValue, bFood)

	if bFood then

		InPlayer.Food = InPlayer.Food + InValue
	else

		InPlayer.Water = InPlayer.Water + InValue
	end

	UpdatePlayerHungerValue(InPlayer)
end

function OnNutritionSpawn(InPlayer, InTemplateEntity)

	local NutritionInstance = ents.Create("prop_physics")

	if InTemplateEntity:GetNWBool("bFoodSpawn") then

		NutritionInstance:SetName("Spawned_FoodInstance")

	else
		NutritionInstance:SetName("Spawned_WaterInstance")
	end

	NutritionInstance:SetPos(InTemplateEntity:GetPos() + Vector(0.0, 0.0, 16.0))

	NutritionInstance:SetAngles(InTemplateEntity:GetAngles())

	NutritionInstance:SetModel(InTemplateEntity:GetModel())

	NutritionInstance:Spawn()
--[[
	if InTemplateEntity:GetNWBool("bFoodSpawn") then

		NutritionInstance:SetNWBool("bFoodInstance", true)

	else
		NutritionInstance:SetNWBool("bWaterInstance", true)
	end

	NutritionInstance:SetNWBool("bShowHint", true)
--]]
	InPlayer:PickupObject(NutritionInstance)
end

function OnNutritionConsume(InPlayer, InNutritionInstance)

	if InNutritionInstance:GetNWBool("bFoodInstance") then

		AddNutrition(InPlayer, 60, true)

		InPlayer:EmitSound("Watermelon.BulletImpact")

	elseif InNutritionInstance:GetNWBool("bWaterInstance") then

		AddNutrition(InPlayer, 60, false)

		InPlayer:EmitSound("Water.BulletImpact")
	end

	InNutritionInstance:Remove()
end
