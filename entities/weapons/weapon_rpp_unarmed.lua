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

local function ChangeLockableState(InPlayer, InLockableEntity, bNewLockState)

	local InputType = "Unlock"

	if bNewLockState then

		InputType = "Lock"
	end

	InLockableEntity:Fire(InputType, nil, 0, InPlayer, InLockableEntity)

	InLockableEntity:SetNWBool("bWasLocked", bNewLockState)

	InLockableEntity:EmitSound("Town.d1_town_02_default_locked")

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

		local InteractEntityParent = InteractEntity:GetParent()

		if IsValid(InteractEntityParent) then

			return CanUsePicklock(InPlayer, InteractEntityParent)
		end
	end

	return false, nil
end

local function TryUsePicklock(InPlayer, InInteractEntity)

	local bUsePicklock, FinalInteractEntity = CanUsePicklock(InPlayer, InInteractEntity)

	if not bUsePicklock then

		return false
	end

	if math.random() < UtilGetPicklockOpenChance() then

		ChangeLockableState(InPlayer, FinalInteractEntity, false)
	else

		InPlayer:EmitSound("Door.Locked2")
	end

	if math.random() < UtilGetPicklockBreakChance() then

		local PicklockNum = InPlayer:GetNWInt("PicklockNum")

		InPlayer:SetNWInt("PicklockNum", PicklockNum - 1)
	end

	return true
end

local function CanToggleLock(InPlayer, InInteractEntity)

	if InInteractEntity:GetNWBool("bGuardLockable")
	or (InInteractEntity:GetNWBool("bOfficerLockable") and InPlayer:GetNWBool("bOfficer")) then

		return true, InInteractEntity
	else

		local InteractEntityParent = InteractEntity:GetParent()

		if IsValid(InteractEntityParent) then

			return CanToggleLock(InPlayer, InteractEntityParent)
		end
	end

	return false, nil
end

local function TryToggleLock(InPlayer, InInteractEntity)

	local bToggleLock, FinalInteractEntity = CanToggleLock(InPlayer, InInteractEntity)

	if not bToggleLock then

		return false
	end

	local bNewLockState = true

	if FinalInteractEntity:GetNWBool("bWasLocked") then

		bNewLockState = false
	end

	ChangeLockableState(InPlayer, FinalInteractEntity, bNewLockState)

	return true
end

local function TryToggleUser1(InPlayer, InInteractEntity)

	if InInteractEntity:GetNWBool("bGuardUser1") then

		InInteractEntity:Fire("FireUser1", nil, 0, InPlayer, InInteractEntity)

		return true
	end

	return false
end

--[[local function TryImplementTask(InPlayer, InInteractEntity)

	local PlayerName = InPlayer:GetName()

	if InInteractEntity:SetNWString("TaskImplementer") == PlayerName then

		MsgN("Begin task...")

		return true
	end

	return false
end]]

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

	local PlayerOwner = self:GetOwner()

	local EyeTrace = PlayerOwner:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 then

		MsgN("Eye trace was too far!")

		return
	end

	local InteractEntity = EyeTrace.Entity

	if SERVER then

		local InteractEntityClass = InteractEntity:GetClass()

		if InteractEntityClass == "prop_door_rotating" then

			InteractEntity:EmitSound("d1_trainstation_03.breakin_doorknock")
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

	if IsValid(InteractEntity) then

		if PlayerOwner:Team() == TEAM_GUARD then

			if CanToggleLock(PlayerOwner, InteractEntity) then

				OnImplementTaskStart(PlayerOwner,
						InteractEntity,
						UtilGetToggleLockDuration(),
						nil,
						TryToggleLock)

				return
			end

			if TryToggleUser1(PlayerOwner, InteractEntity) then

				return
			end

		elseif PlayerOwner:Team() == TEAM_ROBBER then

			if CanUsePicklock(PlayerOwner, InteractEntity) then

				OnImplementTaskStart(PlayerOwner,
						InteractEntity,
						UtilGetPicklockUseDuration(),
						nil,
						TryUsePicklock)

				return
			end
		end
	end
end

function SWEP:Reload()
	
	
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
