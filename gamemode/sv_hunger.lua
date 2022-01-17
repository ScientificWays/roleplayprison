---- Roleplay: Prison

timer.Create("HungerTick", 24.0, 0, function()

	local AllPlayers = player.GetAll()

	for Index, Player in ipairs(AllPlayers) do

		if Player:Team() ~= TEAM_ROBBER and Player:Team() ~= TEAM_GUARD then

			return
		end

		if Player.Food >= 1 then

			Player.Food = Player.Food - 1
		else

			Player.Food = 0
		end

		if Player.Water >= 1 then

			Player.Water = Player.Water - 2
		else

			Player.Water = 0
		end

		--print(Player.Food, Player.Water)

		Player:SetNWFloat("HungerValue", 1.0 - (Player.Food + Player.Water) / 200)

		if Player.Food < 20 or Player.Water < 20 then

			if Player:Health() > 15 then

				Player:SetHealth(Player:Health() - 1)
			end
		end
	end
end)

hook.Add("SetupMove", "HungerMove", function(InPlayer, InMoveData, InCommandData)

	local VelocityMul = Lerp(InPlayer:GetNWFloat("HungerValue"), 1.0, 0.5)

	InMoveData:SetMaxClientSpeed(InMoveData:GetMaxClientSpeed() * VelocityMul)
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

function AddNutrition(InPlayer, InValue, bFood)

	if bFood then

		InPlayer.Food = math.Clamp(InPlayer.Food + InValue, 0, 100)
	else

		InPlayer.Water = math.Clamp(InPlayer.Water + InValue, 0, 100)
	end

	InPlayer:SetNWFloat("HungerValue", 1.0 - (InPlayer.Food + InPlayer.Water) / 200)
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

		AddNutrition(InPlayer, 40, true)

		InPlayer:EmitSound("Watermelon.BulletImpact")

	elseif InNutritionInstance:GetNWBool("bWaterInstance") then

		AddNutrition(InPlayer, 40, false)

		InPlayer:EmitSound("Water.BulletImpact")
	end

	InNutritionInstance:Remove()
end
