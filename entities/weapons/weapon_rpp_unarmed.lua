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

	if not InPlayer:GetNWBool("bHandcuffed")
	and InPlayer:GetNWInt("PicklockNum") > 0
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

		InPlayer:EmitSound("Metal_Box.BulletImpact")
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

	if IsValid(InteractEntity) and not PlayerOwner:GetNWBool("bHandcuffed") then

		if PlayerOwner:Team() == TEAM_GUARD then

			if TryToggleKidnap(PlayerOwner, InteractEntity) then

				return
			end
		end

		if InteractEntity:GetClass() == "prop_door_rotating" then

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

	if IsValid(InteractEntity) and not PlayerOwner:GetNWBool("bHandcuffed") then

		if PlayerOwner:Team() == TEAM_GUARD then

			if TryToggleUser1(PlayerOwner, InteractEntity) then

				return
			end

			local bToggleLock, FinalInteractEntity = CanToggleLock(PlayerOwner, InteractEntity)

			if bToggleLock then

				OnImplementTaskStart(PlayerOwner,
						FinalInteractEntity,
						UtilGetToggleLockDuration(),
						nil,
						TryToggleLock)

				return
			end

			if CanHandcuffsOn(PlayerOwner, InteractEntity) then

				UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(PlayerOwner,
						InteractEntity,
						UtilGetHandcuffsOnDuration(),
						function() UtilChangePlayerFreeze(InteractEntity, false) end,
						TryHandcuffsOn)

				return
			end

			if CanHandcuffsOff(PlayerOwner, InteractEntity) then

				UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(PlayerOwner,
						InteractEntity,
						UtilGetHandcuffsOffDuration(),
						function() UtilChangePlayerFreeze(InteractEntity, false) end,
						TryHandcuffsOff)

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

	if IsValid(InteractEntity) and not PlayerOwner:GetNWBool("bHandcuffed") then

		if PlayerOwner:Team() == TEAM_GUARD then

			if CanInspect(PlayerOwner, InteractEntity) then

				UtilChangePlayerFreeze(InteractEntity, true)

				OnImplementTaskStart(PlayerOwner,
						InteractEntity,
						UtilGetInspectionDuration(),
						function() UtilChangePlayerFreeze(InteractEntity, false) end,
						TryInspect)

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
