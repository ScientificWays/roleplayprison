---- Roleplay: Prison

AddCSLuaFile()

SWEP.PrintName				= "Дубинка"
--SWEP.Author				= "zana"
SWEP.Purpose				= "Roleplay club."

SWEP.Slot					= 2
SWEP.SlotPos				= 3

SWEP.Base                   = "weapon_base"

SWEP.Spawnable				= true

SWEP.ViewModel				= Model("models/weapons/c_rpp_bat.mdl")
SWEP.WorldModel				= Model("models/weapons/w_rpp_bat.mdl")
SWEP.ViewModelFOV			= 54
SWEP.UseHands				= true

SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= true

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

SWEP.HitDistance = 96.0

local SwingSound = Sound("WeaponFrag.Throw")
local HitSound = Sound("Wood_Plank.ImpactHard")

local phys_pushscale = GetConVar("phys_pushscale")

function SWEP:Initialize()

	self:SetHoldType("melee2")

	self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:PrimaryAttack()

	local PlayerOwner = self.Owner

	if PlayerOwner:IsPlayer() then

		PlayerOwner:LagCompensation(false)
	end

	PlayerOwner:SetAnimation(PLAYER_ATTACK1)

	--[[local anim = "fists_left"
	if (right) then anim = "fists_right" end
	if (self:GetCombo() >= 2) then
		anim = "fists_uppercut"
	end--]]

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	--MsgN("EmitSound()")

	PlayerOwner:EmitSound(SwingSound)

	self:SetNextPrimaryFire(CurTime() + 1.0)

	self:SetNextSecondaryFire(CurTime() + 1.0)

	--MsgN(self:SequenceDuration())

	timer.Create(Format("weapon_damage_%s", self:EntIndex()), self:SequenceDuration() * 0.1, 1, function()

		if IsValid(self) then

			self:DealDamage()
		end
	end)
	
	timer.Create(Format("weapon_idle_%s", self:EntIndex()), self:SequenceDuration(), 1, function()

		if IsValid(self) then

			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function SWEP:SecondaryAttack()

	
end

function SWEP:DealDamage()

	local PlayerOwner = self.Owner

	local AttackTrace = util.TraceLine({
		start = PlayerOwner:GetShootPos(),
		endpos = PlayerOwner:GetShootPos() + PlayerOwner:GetAimVector() * self.HitDistance,
		filter = PlayerOwner
	})

	local AttackTraceEntity = AttackTrace.Entity

	if SERVER then

		if AttackTrace.Hit then

			PlayerOwner:EmitSound(HitSound)

			--Delay calculated from half of attack animation duration minus delay for DealDamage()
			timer.Create(Format("weapon_remove_%s", self:EntIndex()), self:SequenceDuration() / 2 - self:SequenceDuration() * 0.1, 1, function()

				if IsValid(self) then

					PlayerOwner:StripWeapon(self:GetClass())
				end
			end)
		end
	end

	local PushScale = phys_pushscale:GetFloat()

	if SERVER and IsValid(AttackTraceEntity) and (AttackTraceEntity:IsNPC() or AttackTraceEntity:IsPlayer() or AttackTraceEntity:Health() > 0) then

		local ApplyDamageInfo = DamageInfo()

		local Attacker = PlayerOwner

		if not IsValid(Attacker) then

			Attacker = self
		end

		ApplyDamageInfo:SetAttacker(Attacker)

		ApplyDamageInfo:SetInflictor(self)

		ApplyDamageInfo:SetDamage(math.random(20, 28))

		if AttackTraceEntity:IsNPC() or AttackTraceEntity:IsPlayer() then

			UtilChangePlayerStun(AttackTraceEntity, true)

			local TimerName = Format("weapon_debuff_%s", self:EntIndex())

			if timer.Exists(TimerName) then

				UtilChangePlayerStun(AttackTraceEntity, false)
			else

				timer.Create(TimerName, 5.0, 1, function()

					UtilChangePlayerStun(AttackTraceEntity, false)
				end)
			end
		end

		ApplyDamageInfo:SetDamageForce(PlayerOwner:GetRight() * 6912 * PushScale + PlayerOwner:GetForward() * 12998 * PushScale)

		--[[if (anim == "fists_left") then

			ApplyDamageInfo:SetDamageForce(PlayerOwner:GetRight() * 4912 * PushScale + PlayerOwner:GetForward() * 9998 * PushScale) --Yes we need those specific numbers

		elseif (anim == "fists_right") then

			ApplyDamageInfo:SetDamageForce(PlayerOwner:GetRight() * -4912 * PushScale + PlayerOwner:GetForward() * 9989 * PushScale)

		elseif (anim == "fists_uppercut") then

			ApplyDamageInfo:SetDamageForce(PlayerOwner:GetUp() * 5158 * PushScale + PlayerOwner:GetForward() * 10012 * PushScale)

			ApplyDamageInfo:SetDamage(math.random(12, 24))
		end--]]

		SuppressHostEvents(NULL) --Let the breakable gibs spawn in multiplayer on client

		AttackTraceEntity:TakeDamageInfo(ApplyDamageInfo)

		SuppressHostEvents(PlayerOwner)
	end

	if IsValid(AttackTraceEntity) then

		local phys = AttackTraceEntity:GetPhysicsObject()

		if (IsValid(phys)) then

			phys:ApplyForceOffset(PlayerOwner:GetAimVector() * 80 * phys:GetMass() * PushScale, AttackTrace.HitPos)
		end
	end
end

function SWEP:Deploy()

	local PlayerOwner = self:GetOwner()

	if SERVER and IsValid(PlayerOwner) then

		timer.Create(Format("weapon_idle_%s", self:EntIndex()), self:SequenceDuration(), 1, function()

			if IsValid(self) then

				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end)
	end

	self:DrawShadow(false)

	return true
end

function SWEP:OnRemove()

	timer.Stop(Format("weapon_idle_%s", self:EntIndex()))
end

function SWEP:Holster()

	timer.Stop(Format("weapon_idle_%s", self:EntIndex()))

	return true
end
