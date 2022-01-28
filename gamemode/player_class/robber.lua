---- Roleplay: Prison

AddCSLuaFile()

DEFINE_BASECLASS("player_default")
 
local PLAYER = {} 
 
PLAYER.DisplayName          = "Robber Class"

PLAYER.SlowWalkSpeed        = 100       -- How fast to move when slow-walking (+WALK)
PLAYER.WalkSpeed            = 150       -- How fast to move when not running
PLAYER.RunSpeed             = 250       -- How fast to move when running
PLAYER.CrouchedWalkSpeed    = 0.3       -- Multiply move speed by this when crouching
PLAYER.DuckSpeed            = 0.3       -- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed          = 0.3       -- How fast to go from ducking, to not ducking
PLAYER.JumpPower            = 200       -- How powerful our jump should be
PLAYER.CanUseFlashlight     = false     -- Can we use the flashlight
PLAYER.MaxHealth            = 100       -- Max health we can have
PLAYER.MaxArmor             = 0         -- Max armor we can have
PLAYER.StartHealth          = 100       -- How much health we start with
PLAYER.StartArmor           = 0         -- How much armour we start with
PLAYER.DropWeaponOnDie      = false     -- Do we drop our weapon when we die
PLAYER.TeammateNoCollide    = false      -- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers         = true      -- Automatically swerves around other players
PLAYER.UseVMHands           = true      -- Uses viewmodel hands

function PLAYER:Init()
	
	

end

function PLAYER:Spawn()

	if not UtilIsInterCycle() then

		local RespawnPositions = ents.FindByClass("info_cycle_respawn")

		self.Player:SetPos(table.Random(RespawnPositions):GetPos())
	end
end

function PLAYER:SetModel()

	SetupRPModel(self.Player)
end

function PLAYER:Loadout()
 
	self.Player:RemoveAllItems()
 
	self.Player:SetNWInt("DetailWoodNum", 0)
	self.Player:SetNWInt("DetailMetalNum", 0)
	self.Player:SetNWInt("PicklockNum", 0)

	self.Player:Give("weapon_rpp_unarmed")
	self.Player:Give("weapon_rpp_fists")

	self.Player:Give("weapon_rpp_club")
end
 
player_manager.RegisterClass("player_robber", PLAYER, "player_default")
