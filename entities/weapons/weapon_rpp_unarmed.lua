--Roleplay: Prison

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

local function TryToggleLock(InPlayer, InInteractEntity)

	if InInteractEntity:GetNWBool("bGuardLockable")
		or (InInteractEntity:GetNWBool("bOfficerLockable") and InPlayer:GetNWBool("bOfficer")) then

		local InputType = "Lock"

		local bNewLockState = true

		--print(InInteractEntity:GetNWBool("bWasLocked"))

		if InInteractEntity:GetNWBool("bWasLocked") then

			InputType = "Unlock"

			bNewLockState = false
		end

		InInteractEntity:Fire(InputType, nil, 0, InPlayer, InInteractEntity)

		InInteractEntity:SetNWBool("bWasLocked", bNewLockState)

		InInteractEntity:EmitSound("Town.d1_town_02_default_locked")

		local SlaveDoorName = InInteractEntity:GetInternalVariable("slavename") or ""

		if SlaveDoorName ~= "" then

			local SlaveDoorEntity = ents.FindByName(SlaveDoorName)[1]

			--MsgN(SlaveDoorEntity:GetName())

			if IsValid(SlaveDoorEntity) then

				SlaveDoorEntity:Fire(InputType)

				SlaveDoorEntity:SetNWBool("bWasLocked", bNewLockState)
			end
		end

		return true

	elseif InInteractEntity:GetNWBool("bGuardUser1") then

		InInteractEntity:Fire("FireUser1", nil, 0, InPlayer, InInteractEntity)

		return true
	end

	return false
end

local function TryImplementTask(InPlayer, InInteractEntity)

	local PlayerName = InPlayer:GetName()

	if InInteractEntity:SetNWString("TaskImplementer") == PlayerName then

		MsgN("Begin task...")

		return true
	end

	return false
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
	
	--MsgN("Unarmed secondary attack")

	local PlayerOwner = self:GetOwner()

	local EyeTrace = PlayerOwner:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 then

		MsgN("Eye trace was too far!")

		return
	end

	local InteractEntity = EyeTrace.Entity

	if SERVER then

		if PlayerOwner:Team() == TEAM_GUARD then

			if not TryToggleLock(PlayerOwner, InteractEntity) then

				local InteractEntityParent = InteractEntity:GetParent()

				if IsValid(InteractEntityParent) then

					TryToggleLock(PlayerOwner, InteractEntityParent)
				else

					TryImplementTask(PlayerOwner, InteractEntity)
				end
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
