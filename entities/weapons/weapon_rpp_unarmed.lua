---- Roleplay: Prison

AddCSLuaFile()

if CLIENT then

	SWEP.PrintName			= UtilLocalizable("RPP_Weapon.Unarmed")
	
	SWEP.Purpose			= UtilLocalizable("RPP_Weapon.Unarmed.Purpose")

	SWEP.Author				= "zana"
end

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.Base                   = "weapon_base"

SWEP.Spawnable				= false

SWEP.ViewModel				= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel				= "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV			= 10
SWEP.UseHands				= false

SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AllowDelete			= false
SWEP.AllowDrop				= false

local function CanTryInteract(InPlayer, InInteractEntity)

	return UtilPlayerCanInteract(InPlayer)
	and IsValid(InInteractEntity)
	and InInteractEntity:GetNWString("NowImplemetingBy") == ""
end

local function CanUsePicklock(InPlayer, InInteractEntity)

	if InPlayer:GetNWInt("PicklockNum") > 0
	and ((InInteractEntity:GetNWBool("bWasLocked")
	and (InInteractEntity:GetNWBool("bGuardLockable") or InInteractEntity:GetNWBool("bOfficerLockable")))
	or InInteractEntity:GetNWBool("bCellDoor")) then

		return true, InInteractEntity
	else

		local InteractEntityParent = InInteractEntity:GetParent()

		if IsValid(InteractEntityParent) then

			return CanUsePicklock(InPlayer, InteractEntityParent)
		end
	end

	return false, nil
end

local function TryUsePicklock(InPlayer, InInteractEntity)

	local bUsePicklock, FinalInteractEntity = CanUsePicklock(InPlayer, InInteractEntity)

	if not bUsePicklock then

		return
	end

	if math.random() < UtilGetPicklockOpenChance() then

		MsgN(FinalInteractEntity:GetNWBool("bCellDoor"))

		if FinalInteractEntity:GetNWBool("bCellDoor") then

			FinalInteractEntity:Input("FireUser1")
		else

			ChangeLockableState(InPlayer, FinalInteractEntity, false)
		end
	else

		InPlayer:EmitSound("Metal_Box.BulletImpact",
		60, math.random(95, 105), math.random(0.95, 1.05), CHAN_AUTO, 0, 1)
	end

	if math.random() < UtilGetPicklockBreakChance() then

		local PicklockNum = InPlayer:GetNWInt("PicklockNum")

		InPlayer:SetNWInt("PicklockNum", PicklockNum - 1)
	end
end

local function CanToggleLock(InPlayer, InInteractEntity)

	if InInteractEntity:GetNWBool("bGuardLockable") then

		return true, InInteractEntity

	elseif InInteractEntity:GetNWBool("bOfficerLockable") then

		if InPlayer:GetNWBool("bOfficer") then

			return true, InInteractEntity
		end
	else

		local InteractEntityParent = InInteractEntity:GetParent()

		if IsValid(InteractEntityParent) then

			return CanToggleLock(InPlayer, InteractEntityParent)
		end
	end

	return false, nil
end

local function TryToggleLock(InPlayer, InInteractEntity)

	local bToggleLock, FinalInteractEntity = CanToggleLock(InPlayer, InInteractEntity)

	if not bToggleLock then

		return
	end

	local bNewLockState = true

	if FinalInteractEntity:GetNWBool("bWasLocked") then

		bNewLockState = false
	end

	ChangeLockableState(InPlayer, FinalInteractEntity, bNewLockState)
end

local function TryToggleUser1(InPlayer, InInteractEntity)

	if InInteractEntity:GetNWBool("bGuardUser1") then

		InInteractEntity:Fire("FireUser1", nil, 0, InPlayer, InInteractEntity)

		return true
	end

	return false
end

local function TryKnockDoor(InPlayer, InInteractEntity)

	MsgN("TryKnockDoor()")

	if InInteractEntity:GetClass() == "prop_door_rotating" then

		InInteractEntity:EmitSound("d1_trainstation_03.breakin_doorknock",
		60, math.random(90, 110), math.random(0.9, 1.1), CHAN_AUTO, 0, 1)

		return true
	end

	if InInteractEntity:GetNWBool("bCellDoor") then

		InInteractEntity:EmitSound("MetalGrate.ImpactSoft",
		60, math.random(90, 110), math.random(0.9, 1.1), CHAN_AUTO, 0, 1)

		return true
	end

	InteractEntityParent = InInteractEntity:GetParent()

	if IsValid(InteractEntityParent) then

		return TryKnockDoor(InPlayer, InteractEntityParent)
	end

	return false
end

local function TryHitThrowable(InPlayer, InInteractEntity)

	MsgN("TryHitThrowable()")

	if string.EndsWith(InInteractEntity:GetName(), "_Throwable") then

		InInteractEntity:GetPhysicsObject():ApplyForceCenter(InPlayer:EyeAngles():Forward() * 10000.0)

		return true
	end

	return false
end

local function CanHandcuffsOn(InPlayer, InInteractEntity)

	return InInteractEntity:IsPlayer() 
	and InInteractEntity:Team() == TEAM_ROBBER
	and not InInteractEntity:GetNWBool("bHandcuffed")
end

local function TryHandcuffsOn(InPlayer, InInteractEntity)

	if not CanHandcuffsOn(InPlayer, InInteractEntity) then

		return
	end

	OnPlayerHandcuffsOn(InInteractEntity)

	UtilChangePlayerFreeze(InInteractEntity, false)
end

local function CanHandcuffsOff(InPlayer, InInteractEntity)

	return InInteractEntity:IsPlayer() 
	and InInteractEntity:Team() == TEAM_ROBBER
	and InInteractEntity:GetNWBool("bHandcuffed")
end

local function TryHandcuffsOff(InPlayer, InInteractEntity)

	if not CanHandcuffsOff(InPlayer, InInteractEntity) then

		return
	end

	OnPlayerHandcuffsOff(InInteractEntity)

	--UtilChangePlayerFreeze(InInteractEntity, false)
end

local function CanInspect(InPlayer, InInteractEntity)

	return InInteractEntity:IsPlayer() 
	and InInteractEntity:Team() == TEAM_ROBBER
end

local function TryInspect(InPlayer, InInteractEntity)

	if not CanInspect(InPlayer, InInteractEntity) then

		return
	end

	OnInspect(InPlayer, InInteractEntity)

	UtilChangePlayerFreeze(InInteractEntity, false)
end

local function TryToggleKidnap(InPlayer, InInteractEntity)

	if not InInteractEntity:GetNWBool("bHandcuffed") then

		return false
	end

	local CurrentKidnapper = Entity(InInteractEntity:GetNWInt("KidnapperIndex", -1))

	if IsValid(CurrentKidnapper) then

		InInteractEntity:SetNWInt("KidnapperIndex", -1)

		timer.Remove(Format("%s_kidnap", InInteractEntity:GetName()))

		MsgN(Format("Release %s from %s", InInteractEntity:GetName(), InPlayer:GetName()))
	else

		InInteractEntity:SetNWInt("KidnapperIndex", InPlayer:EntIndex())

		timer.Create(Format("%s_kidnap", InInteractEntity:GetName()), 0.5, 0, function()

			if InInteractEntity:GetPos():DistToSqr(InPlayer:GetPos()) > 9216.0 then

				TryToggleKidnap(InPlayer, InInteractEntity)
			end
		end)

		MsgN(Format("%s kidnapped %s", InPlayer:GetName(), InInteractEntity:GetName()))
	end

	return true
end

local function CanConsumeNutrition(InPlayer, InInteractEntity)

	return IsValid(InInteractEntity)
	and (InInteractEntity:GetNWBool("bWaterInstance") or InInteractEntity:GetNWBool("bFoodInstance"))
end

local function TryConsumeNutrition(InPlayer, InInteractEntity)

	if not CanConsumeNutrition(InPlayer, InInteractEntity) then

		return
	end

	OnNutritionConsume(InPlayer, InInteractEntity)
end

--[[local function TryImplementTask(InPlayer, InInteractEntity)

	local PlayerName = InPlayer:GetName()

	if InInteractEntity:SetNWString("TaskImplementer") == PlayerName then

		MsgN("Begin task...")

		return true
	end

	return false
end]]

local function CanTradeStackableItem(InPlayer, InInteractEntity, InItemNameStr)

	return InInteractEntity:IsPlayer() and InInteractEntity:Team() == TEAM_ROBBER and InPlayer:GetNWInt(InItemNameStr) > 0
end

local function TryTradeStackableItem(InPlayer, InInteractEntity, InItemNameStr)

	MsgN(Format("TryTradeStackableItem() %s", InItemNameStr))

	if not CanTradeStackableItem(InPlayer, InInteractEntity, InItemNameStr) then

		return
	end

	InPlayer:SetNWInt(InItemNameStr, InPlayer:GetNWInt(InItemNameStr) - 1)

	InInteractEntity:SetNWInt(InItemNameStr, InInteractEntity:GetNWInt(InItemNameStr) + 1)

	InInteractEntity:EmitSound("HL2Player.PickupWeapon")
end

local function CanRevive(InPlayer, InInteractEntity)

	return InInteractEntity:GetNWBool("bIncapped")
end

local function TryRevive(InPlayer, InInteractEntity)

	MsgN("TryRevive()")

	if not CanRevive(InPlayer, InInteractEntity) then

		return
	end

	OnPlayerRevived(InInteractEntity)
end

function SWEP:Initialize()

	self:SetHoldType("normal")
end

function SWEP:GetClass()

	return "weapon_rpp_unarmed"
end

function SWEP:OnDrop()

	self:Remove()
end

function SWEP:ShouldDropOnDie()

	return false
end

function SWEP:PrimaryAttack()

	if CLIENT then

		return
	end

	local PlayerOwner = self:GetOwner()

	local EyeTrace = PlayerOwner:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 then

		--MsgN("Eye trace was too far!")

		return
	end

	local InteractEntity = EyeTrace.Entity

	if CanTryInteract(PlayerOwner, InteractEntity) then

		if TryKnockDoor(PlayerOwner, InteractEntity) then

			return
		end

		if TryHitThrowable(PlayerOwner, InteractEntity) then

			return
		end

		if PlayerOwner:Team() == TEAM_GUARD then

			if TryToggleKidnap(PlayerOwner, InteractEntity) then

				return
			end

		elseif PlayerOwner:Team() == TEAM_ROBBER then

			if CanTradeStackableItem(PlayerOwner, InteractEntity, "DetailWoodNum") then

				--UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetTradeDuration(),
					nil,
					function(InPlayer, InInteractEntity) TryTradeStackableItem(InPlayer, InInteractEntity, "DetailWoodNum") end
				)
				return
			end
		end
	end
end

function SWEP:SecondaryAttack()
	
	if CLIENT then

		return
	end

	--MsgN("Unarmed secondary attack")

	local PlayerOwner = self:GetOwner()

	local EyeTrace = PlayerOwner:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 then

		--MsgN("Eye trace was too far!")

		return
	end

	local InteractEntity = EyeTrace.Entity

	if CanTryInteract(PlayerOwner, InteractEntity) then

		if PlayerOwner:Team() == TEAM_GUARD or PlayerOwner:Team() == TEAM_MEDIC then

			local bToggleLock, FinalInteractEntity = CanToggleLock(PlayerOwner, InteractEntity)

			if bToggleLock then

				OnImplementTaskStart(
					PlayerOwner,
					FinalInteractEntity,
					UtilGetToggleLockDuration(),
					nil,
					TryToggleLock
				)
				return
			end
		end

		if PlayerOwner:Team() == TEAM_GUARD then

			if TryToggleUser1(PlayerOwner, InteractEntity) then

				return
			end

			if CanHandcuffsOn(PlayerOwner, InteractEntity) then

				UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetHandcuffsOnDuration(),
					function() UtilChangePlayerFreeze(InteractEntity, false) end,
					TryHandcuffsOn
				)
				return
			end

		elseif PlayerOwner:Team() == TEAM_ROBBER then

			if CanTradeStackableItem(PlayerOwner, InteractEntity, "DetailMetalNum") then

				--UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetTradeDuration(),
					nil,
					function(InPlayer, InInteractEntity) TryTradeStackableItem(InPlayer, InInteractEntity, "DetailMetalNum") end
				)
				return
			end

			if CanUsePicklock(PlayerOwner, InteractEntity) then

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetPicklockUseDuration(),
					nil,
					TryUsePicklock
				)
				return
			end

		elseif PlayerOwner:Team() == TEAM_MEDIC then

			MsgN(InteractEntity)

			if CanRevive(PlayerOwner, InteractEntity) then

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetReviveDuration(),
					nil,
					TryRevive
				)
				return
			end			
		end

		if CanHandcuffsOff(PlayerOwner, InteractEntity) then

			--UtilChangePlayerFreeze(InteractEntity, true)

			local HandcuffsOffDuration = UtilGetHandcuffsOffDuration()

			if PlayerOwner:Team() ~= TEAM_GUARD then

				HandcuffsOffDuration = HandcuffsOffDuration * 2.0
			end

			OnImplementTaskStart(
				PlayerOwner,
				InteractEntity,
				HandcuffsOffDuration,
				--[[function() UtilChangePlayerFreeze(InteractEntity, false) end--]]nil,
				TryHandcuffsOff
			)
			return
		end
	end
end

function SWEP:Reload()
	
	if CLIENT then

		return
	end

	--MsgN("Unarmed secondary attack")

	local PlayerOwner = self:GetOwner()

	local EyeTrace = PlayerOwner:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 then

		--MsgN("Eye trace was too far!")

		return
	end

	local InteractEntity = EyeTrace.Entity

	if CanTryInteract(PlayerOwner, InteractEntity) then

		if CanConsumeNutrition(PlayerOwner, InteractEntity) then

			OnImplementTaskStart(
				PlayerOwner,
				InteractEntity,
				1.0,
				nil,
				TryConsumeNutrition
			)

			return
		end

		if PlayerOwner:Team() == TEAM_GUARD then

			if CanInspect(PlayerOwner, InteractEntity) then

				UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetInspectionDuration(),
					function() UtilChangePlayerFreeze(InteractEntity, false) end,
					TryInspect
				)

				return
			end

		elseif PlayerOwner:Team() == TEAM_ROBBER then

			if CanTradeStackableItem(PlayerOwner, InteractEntity, "PicklockNum") then

				--UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetTradeDuration(),
					nil,
					function(InPlayer, InInteractEntity) TryTradeStackableItem(InPlayer, InInteractEntity, "PicklockNum") end
				)
				return
			end
		end
	end
end

function SWEP:Deploy()

	local PlayerOwner = self:GetOwner()

	if SERVER and IsValid(PlayerOwner) then

		PlayerOwner:DrawViewModel(false)

		--MsgN("DrawViewModel(false)")
	end

	self:DrawShadow(false)

	return true
end

function SWEP:Holster()

	return true
end

function SWEP:DrawWorldModel()


end

function SWEP:DrawWorldModelTranslucent()


end
