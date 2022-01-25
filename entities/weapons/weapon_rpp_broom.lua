---- Roleplay: Prison

AddCSLuaFile()

SWEP.PrintName = "Broom"
--SWEP.Author = "zana"
SWEP.Purpose = "Roleplay broom."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_rpp_broom.mdl")
SWEP.WorldModel = Model("")
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HitDistance = 96

local SwingSound = Sound("WeaponFrag.Throw")
local HitSound = Sound("Wood_Plank.ImpactHard")

local phys_pushscale = GetConVar("phys_pushscale")

function SWEP:Initialize()

	self:SetHoldType("melee2")

	self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:PrimaryAttack(bSecondary)

	if self.Owner:IsPlayer() then

		self.Owner:LagCompensation(false)
	end

	self.Owner:SetAnimation(PLAYER_ATTACK1)

	--[[local anim = "fists_left"
	if (right) then anim = "fists_right" end
	if (self:GetCombo() >= 2) then
		anim = "fists_uppercut"
	end--]]

	if bSecondary then

		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

	else
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end

	self:EmitSound(SwingSound)

	self:SetNextPrimaryFire(CurTime() + 1.0)

	self:SetNextSecondaryFire(CurTime() + 1.0)

	MsgN(self:SequenceDuration())

	timer.Create(string.format("weapon_damage_%s", self:EntIndex()), self:SequenceDuration() * 0.1, 1, function()

		if IsValid(self) then

			self:DealDamage()
		end
	end)
	
	timer.Create(string.format("weapon_idle_%s", self:EntIndex()), self:SequenceDuration(), 1, function()

		if IsValid(self) then

			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function SWEP:SecondaryAttack()

	self:PrimaryAttack(true)
end

function SWEP:DealDamage()

	local AttackTrace = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64,
		filter = self.Owner
	})

	local AttackTraceEntity = AttackTrace.Entity

	if CLIENT then

		if AttackTrace.Hit and not game.SinglePlayer() then

			self:EmitSound(HitSound)
		end
	end

	local AttackHit = false

	local PushScale = phys_pushscale:GetFloat()

	if SERVER and IsValid(AttackTraceEntity) and (AttackTraceEntity:IsNPC() or AttackTraceEntity:IsPlayer() or AttackTraceEntity:Health() > 0) then

		local ApplyDamageInfo = DamageInfo()

		local Attacker = self.Owner

		if not IsValid(Attacker) then

			Attacker = self
		end

		ApplyDamageInfo:SetAttacker(Attacker)

		ApplyDamageInfo:SetInflictor(self)

		if bSecondary then

			ApplyDamageInfo:SetDamage(math.random(16, 32))

		else
			ApplyDamageInfo:SetDamage(math.random(8, 12))
		end

		ApplyDamageInfo:SetDamageForce(self.Owner:GetRight() * 4912 * PushScale + self.Owner:GetForward() * 9998 * PushScale)

		--[[if (anim == "fists_left") then

			ApplyDamageInfo:SetDamageForce(self.Owner:GetRight() * 4912 * PushScale + self.Owner:GetForward() * 9998 * PushScale) --Yes we need those specific numbers

		elseif (anim == "fists_right") then

			ApplyDamageInfo:SetDamageForce(self.Owner:GetRight() * -4912 * PushScale + self.Owner:GetForward() * 9989 * PushScale)

		elseif (anim == "fists_uppercut") then

			ApplyDamageInfo:SetDamageForce(self.Owner:GetUp() * 5158 * PushScale + self.Owner:GetForward() * 10012 * PushScale)

			ApplyDamageInfo:SetDamage(math.random(12, 24))
		end--]]

		SuppressHostEvents(NULL) --Let the breakable gibs spawn in multiplayer on client

		AttackTraceEntity:TakeDamageInfo(ApplyDamageInfo)

		SuppressHostEvents(self.Owner)

		AttackHit = true
	end

	if IsValid(AttackTraceEntity) then

		local phys = AttackTraceEntity:GetPhysicsObject()

		if (IsValid(phys)) then

			phys:ApplyForceOffset(self.Owner:GetAimVector() * 80 * phys:GetMass() * PushScale, AttackTrace.HitPos)
		end
	end
end

function SWEP:OnRemove()

	timer.Stop(string.format("weapon_idle_%s", self:EntIndex()))
end

function SWEP:Holster()

	timer.Stop(string.format("weapon_idle_%s", self:EntIndex()))

	return true
end
