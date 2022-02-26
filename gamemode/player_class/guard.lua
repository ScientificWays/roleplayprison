---- Roleplay: Prison

AddCSLuaFile()

DEFINE_BASECLASS("player_default")
 
local PLAYER = {}

PLAYER.DisplayName          = "Guard Class"

PLAYER.SlowWalkSpeed        = 100       -- How fast to move when slow-walking (+WALK)
PLAYER.WalkSpeed            = 150       -- How fast to move when not running
PLAYER.RunSpeed             = 300       -- How fast to move when running
PLAYER.CrouchedWalkSpeed    = 0.5       -- Multiply move speed by this when crouching
PLAYER.DuckSpeed            = 0.3       -- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed          = 0.3       -- How fast to go from ducking, to not ducking
PLAYER.JumpPower            = 200       -- How powerful our jump should be
PLAYER.CanUseFlashlight     = true      -- Can we use the flashlight
PLAYER.MaxHealth            = 100       -- Max health we can have
PLAYER.MaxArmor             = 50		-- Max armor we can have
PLAYER.StartHealth          = 100       -- How much health we start with
PLAYER.StartArmor           = 50		-- How much armour we start with
PLAYER.DropWeaponOnDie      = false     -- Do we drop our weapon when we die
PLAYER.TeammateNoCollide    = true      -- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers         = true      -- Automatically swerves around other players
PLAYER.UseVMHands           = true      -- Uses viewmodel hands


function PLAYER:Init()
	


end

function PLAYER:Spawn()


end

function PLAYER:SetModel()

	SetupRPModel(self.Player)
end

function PLAYER:Loadout()
 
	self.Player:RemoveAllItems()
	
	self.Player:Give("weapon_rpp_unarmed")
	self.Player:Give("weapon_rpp_fists")
	self.Player:Give("weapon_stunstick")
	self.Player:Give("weapon_rpp_talkie")

	self.Player:GiveAmmo(60, "357", true)
	self.Player:Give("weapon_357")
	
	self.Player:Give("weapon_rpp_broom")
end

player_manager.RegisterClass("player_guard", PLAYER, "player_default")
