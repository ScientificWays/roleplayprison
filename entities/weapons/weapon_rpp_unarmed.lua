---- Roleplay: Prison

AddCSLuaFile()

SWEP.HoldType               = "normal"

if CLIENT then
	SWEP.PrintName           = "Unarmed"
	SWEP.Slot                = 0

	SWEP.ViewModelFOV        = 10
end

SWEP.Base                   = "weapon_base"
SWEP.m_WeaponDeploySpeed    = "0.5"

SWEP.ViewModel              = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             = "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.AllowDelete            = false
SWEP.AllowDrop              = false
SWEP.NoSights               = true

local function CanTryInteract(InPlayer, InInteractEntity)

	return IsValid(InInteractEntity)
	and InInteractEntity:GetNWFloat("TaskTimeLeft") <= 0
	and not InPlayer:GetNWBool("bHandcuffed")
end

local function ChangeLockableState(InPlayer, InLockableEntity, bNewLockState)

	local InputType = "Unlock"

	if bNewLockState then

		InputType = "Lock"
	end

	InLockableEntity:Fire(InputType, nil, 0, InPlayer, InLockableEntity)

	InLockableEntity:SetNWBool("bWasLocked", bNewLockState)

	InLockableEntity:EmitSound("Town.d1_town_02_default_locked",
		60, math.random(95, 105), math.random(0.95, 1.05), CHAN_AUTO, 0, 1)

	local SlaveDoorName = InLockableEntity:GetInternalVariable("slavename") or ""

	if SlaveDoorName ~= "" then

		local SlaveDoorEntity = ents.FindByName(SlaveDoorName)[1]

		--MsgN(SlaveDoorEntity:GetName())

		if IsValid(SlaveDoorEntity) then

			SlaveDoorEntity:Fire(InputType)

			SlaveDoorEntity:SetNWBool("bWasLocked", bNewLockState)
		end
	end
end

local function CanUsePicklock(InPlayer, InInteractEntity)

	if InPlayer:GetNWInt("PicklockNum") > 0
	and InInteractEntity:GetNWBool("bWasLocked")
	and (InInteractEntity:GetNWBool("bGuardLockable")
	or InInteractEntity:GetNWBool("bOfficerLockable")
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

		ChangeLockableState(InPlayer, FinalInteractEntity, false)
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

	UtilChangePlayerFreeze(InInteractEntity, false)
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

	local CurrentKidnapper = InInteractEntity:GetNWEntity("Kidnapper", nil)

	if IsValid(CurrentKidnapper) then

		InInteractEntity:SetNWEntity("Kidnapper", nil)

		timer.Remove(string.format("%s_kidnap", InInteractEntity:GetName()))

		MsgN(string.format("Release %s from %s", InInteractEntity:GetName(), InPlayer:GetName()))
	else

		InInteractEntity:SetNWEntity("Kidnapper", InPlayer)

		timer.Create(string.format("%s_kidnap", InInteractEntity:GetName()), 0.5, 0, function()

			if InInteractEntity:GetPos():DistToSqr(InPlayer:GetPos()) > 9216.0 then

				TryToggleKidnap(InPlayer, InInteractEntity)
			end
		end)

		MsgN(string.format("%s kidnapped %s", InPlayer:GetName(), InInteractEntity:GetName()))
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

	MsgN(string.format("TryTradeStackableItem() %s", InItemNameStr))

	if not CanTradeStackableItem(InPlayer, InInteractEntity, InItemNameStr) then

		return
	end

	InPlayer:SetNWInt(InItemNameStr, InPlayer:GetNWInt(InItemNameStr) - 1)

	InInteractEntity:SetNWInt(InItemNameStr, InInteractEntity:GetNWInt(InItemNameStr) + 1)

	InInteractEntity:EmitSound("HL2Player.PickupWeapon")
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

	if PlayerOwner:GetNWFloat("TaskTimeLeft") > 0.0 then

		return
	end

	local EyeTrace = PlayerOwner:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 then

		--MsgN("Eye trace was too far!")

		return
	end

	local InteractEntity = EyeTrace.Entity

	if CanTryInteract(PlayerOwner, InteractEntity) then

		if InteractEntity:GetClass() == "prop_door_rotating" then

			InteractEntity:EmitSound("d1_trainstation_03.breakin_doorknock",
			60, math.random(95, 105), math.random(0.95, 1.05), CHAN_AUTO, 0, 1)
		end

		if PlayerOwner:Team() == TEAM_GUARD then

			if TryToggleKidnap(PlayerOwner, InteractEntity) then

				return
			end

		elseif PlayerOwner:Team() == TEAM_ROBBER then

			if CanTradeStackableItem(PlayerOwner, InteractEntity, "DetailWoodNum") then

				UtilChangePlayerFreeze(InteractEntity, true)

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

	if PlayerOwner:GetNWFloat("TaskTimeLeft") > 0.0 then

		return
	end

	local EyeTrace = PlayerOwner:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 then

		--MsgN("Eye trace was too far!")

		return
	end

	local InteractEntity = EyeTrace.Entity

	if CanTryInteract(PlayerOwner, InteractEntity) then

		if PlayerOwner:Team() == TEAM_GUARD then

			if TryToggleUser1(PlayerOwner, InteractEntity) then

				return
			end

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

			if CanHandcuffsOff(PlayerOwner, InteractEntity) then

				UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(
					PlayerOwner,
					InteractEntity,
					UtilGetHandcuffsOffDuration(),
					function() UtilChangePlayerFreeze(InteractEntity, false) end,
					TryHandcuffsOff
				)
				return
			end

		elseif PlayerOwner:Team() == TEAM_ROBBER then

			if CanTradeStackableItem(PlayerOwner, InteractEntity, "DetailMetalNum") then

				UtilChangePlayerFreeze(InteractEntity, true)

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
		end
	end
end

function SWEP:Reload()
	
	if CLIENT then

		return
	end

	--MsgN("Unarmed secondary attack")

	local PlayerOwner = self:GetOwner()

	if PlayerOwner:GetNWFloat("TaskTimeLeft") > 0.0 then

		return
	end

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
				function() UtilChangePlayerFreeze(InteractEntity, false) end,
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

				UtilChangePlayerFreeze(InteractEntity, true)

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

	if SERVER and IsValid(self:GetOwner()) then

		self:GetOwner():DrawViewModel(false)
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
