---- Roleplay: Prison

AddCSLuaFile()

SWEP.PrintName				= "Talkie"
--SWEP.Author				= "zana"
SWEP.Purpose				= "Roleplay talkie."

SWEP.Slot					= 2
SWEP.SlotPos				= 2

SWEP.Base                   = "weapon_base"

SWEP.Spawnable				= true

SWEP.ViewModel				= Model("models/weapons/c_rpp_talkie.mdl")
SWEP.WorldModel				= Model("")
SWEP.ViewModelFOV			= 54
SWEP.UseHands				= true

SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.AllowDelete			= true
SWEP.AllowDrop				= true

local FrequencySwitchSoundList = {
	"novaprospekt.radiostatic_1",
	"novaprospekt.radiostatic_2",
	"novaprospekt.radiostatic_6",
	"novaprospekt.radiostatic_9",
	"novaprospekt.radiostatic_13",
	"novaprospekt.radiostatic_15",
}

local function UpdatePlayerFrequency(InPlayer, bAdd)

	local NewFrequency = InPlayer:GetNWFloat("TalkieFrequency")

	if bAdd == true then

		NewFrequency = NewFrequency + 0.5

	elseif bAdd == false then

		NewFrequency = NewFrequency - 0.5
	end

	InPlayer:SetNWFloat("TalkieFrequency", math.Clamp(NewFrequency, 100.0, 107.0))

	InPlayer:EmitSound(table.Random(FrequencySwitchSoundList))
end

function SWEP:Initialize()

	self:SetHoldType("normal")
end

function SWEP:GetClass()

	return "weapon_rpp_talkie"
end

function SWEP:OnDrop()

end

function SWEP:ShouldDropOnDie()

	return true
end

function SWEP:PrimaryAttack()

	if CLIENT then

		return
	end

	self:SetNextPrimaryFire(CurTime() + 2.0)

	self:SetNextSecondaryFire(CurTime() + 2.0)

	local PlayerOwner = self:GetOwner()

	UpdatePlayerFrequency(PlayerOwner, true)
end

function SWEP:SecondaryAttack()
	
	if CLIENT then

		return
	end

	--MsgN("Unarmed secondary attack")

	self:SetNextPrimaryFire(CurTime() + 2.0)

	self:SetNextSecondaryFire(CurTime() + 2.0)

	local PlayerOwner = self:GetOwner()

	UpdatePlayerFrequency(PlayerOwner, false)
end

function SWEP:Deploy()

	local PlayerOwner = self:GetOwner()

	if SERVER and IsValid(PlayerOwner) then

		--PlayerOwner:SetNWBool("bUsingTalkie", true)

		UpdatePlayerFrequency(PlayerOwner, nil)
	end

	self:DrawShadow(false)

	return true
end

function SWEP:Holster()

	local PlayerOwner = self:GetOwner()

	if SERVER and IsValid(PlayerOwner) then

		--PlayerOwner:SetNWBool("bUsingTalkie", false)
	end

	return true
end

function SWEP:DrawWorldModel()


end

function SWEP:DrawWorldModelTranslucent()


end
