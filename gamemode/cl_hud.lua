---- Roleplay: Prison

local bHideHUD = false

local IconWood			= Material("vgui/rpp/icon_wood")
local IconMetal			= Material("vgui/rpp/icon_metal")
--local IconDressRobber	= Material("vgui/rpp/icon_dress_robber")
local IconLocked		= Material("vgui/rpp/icon_locked")
local IconUnlocked		= Material("vgui/rpp/icon_unlocked")
local IconHand			= Material("vgui/rpp/icon_hand")

local IconComputerTask	= Material("icon16/folder_error.png")

local ClientTargetLockable = nil
local ClientTargetUsable = nil
local ClientTargetTask = nil

function HUDResetTarget()

	ClientTargetLockable = nil
	ClientTargetUsable = nil
	ClientTargetTask = nil
end

function TrySetTargetLockable(InTargetEntity)

	local bLockable = InTargetEntity:GetNWBool("bGuardLockable") or InTargetEntity:GetNWBool("bOfficerLockable")

	if bLockable then

		ClientTargetLockable = InTargetEntity

		return true
	end

	return false
end

function TrySetTargetUsable(InTargetEntity)

	local bUsable = InTargetEntity:GetNWBool("bGuardUser1")
					or InTargetEntity:GetNWBool("bRobberUser1")
					or InTargetEntity:GetNWBool("bAllUser1")

	if bUsable then

		ClientTargetUsable = InTargetEntity

		return true
	end

	return false
end

function TrySetTargetTask(InTargetEntity)

	local bTask = InTargetEntity:GetNWBool("bGuardTask") or InTargetEntity:GetNWBool("bOfficerPhone")

	--MsgN(string.format("TrySetTargetTask() return %s", bTask))
	
	if bTask then

		ClientTargetTask = InTargetEntity

		return true
	end

	return false
end

local function SpecHUDPaint(InClient)
	
	if not IsValid(InClient) then

		return
	end

	return
end

local function InventoryDraw(InClient)

	if not IsValid(InClient) then

		return
	end

	surface.SetDrawColor(255, 255, 0)

	surface.SetFont("DermaLarge")

	surface.SetTextColor(COLOR_YELLOW)

	surface.SetMaterial(IconWood)

	surface.DrawTexturedRect(50, ScrH() - 200, 50, 50)

	surface.SetTextPos(120, ScrH() - 190)

	surface.DrawText(InClient.DetailWoodAmount)
	
	surface.SetMaterial(IconMetal)

	surface.DrawTexturedRect(50, ScrH() - 250, 50, 50)

	surface.SetTextPos(120, ScrH() - 240)

	surface.DrawText(InClient.DetailMetalAmount)
end

local function DoorLockDraw(InClient)

	if not IsValid(InClient) then

		return
	end

	if ClientTargetLockable:GetNWBool("bWasLocked") then

		surface.SetMaterial(IconLocked)
	else

		surface.SetMaterial(IconUnlocked)
	end

	surface.SetDrawColor(COLOR_YELLOW)

	surface.DrawTexturedRect(ScrW() / 2 - 24, ScrH() / 2 - 16, 48, 32)

	draw.DrawText("ПКМ", "HUDTextSmall", ScrW() / 2, ScrH() / 2 + 16, COLOR_YELLOW, TEXT_ALIGN_CENTER)
end

local function UsableDraw(InClient)

	if not IsValid(InClient) then

		return
	end

	surface.SetMaterial(IconHand)

	surface.SetDrawColor(COLOR_YELLOW)

	surface.DrawTexturedRect(ScrW() / 2 - 16, ScrH() / 2 - 16, 32, 32)
end

local function TaskDraw(InClient)

	if not IsValid(InClient) then

		return
	end

	local TaskImplementer = ClientTargetTask:GetNWString("TaskImplementer")

	if TaskImplementer ~= "" then

		surface.SetMaterial(IconComputerTask)

		surface.SetDrawColor(COLOR_WHITE)

		surface.DrawTexturedRect(ScrW() / 2 - 16, ScrH() / 2 - 16, 32, 32)

		draw.DrawText(string.format("Задание для %s", TaskImplementer),
			"HUDTextSmall", ScrW() / 2, ScrH() / 2 + 16, COLOR_YELLOW, TEXT_ALIGN_CENTER)
	end
end

local function TaskTimeDraw(InClient)

	if not IsValid(InClient) then

		return
	end

	local TaskTimeLeft = InClient:GetNWFloat("TaskTimeLeft")

	if TaskTimeLeft > 0 then

		draw.DrawText(string.format("%.1f", TaskTimeLeft), "HUDTextSmall", ScrW() / 2, ScrH() / 2 + 48, COLOR_YELLOW, TEXT_ALIGN_CENTER)
	end
end

function GM:HUDDrawTargetID()

	
end

function GM:HUDPaint()

	local Client = LocalPlayer()

	bHideHUD = not Client:KeyDown(IN_WALK)

	if (not Client:Alive()) or Client:Team() == TEAM_SPECTATOR then

		if hook.Run("HUDShouldDraw", "RPPSpecHUD") then

			 --SpecHUDPaint(Client)
		end

		return
	end

	if hook.Run("HUDShouldDraw", "RPPInventory") and Client:Team() == TEAM_ROBBER then

		InventoryDraw(Client)
	end

	if IsValid(ClientTargetLockable) then

		--MsgN("DoorLockDraw()")

		DoorLockDraw(Client)

	elseif IsValid(ClientTargetUsable) then

		--MsgN("UsableDraw()")

		UsableDraw(Client)

	elseif IsValid(ClientTargetTask) then

		--MsgN("TaskDraw()")

		TaskDraw(Client)
	end

	TaskTimeDraw(Client)
end

-- Hide HUD elements
local ElementsToHide = {["CHudHealth"] = true,
						["CHudBattery"] = true,
						["CHudAmmo"] = true,
						["CHudSecondaryAmmo"] = true,
						["CHudCrosshair"] = true,
						["RPPInventory"] = true,
						["RPPSpecHUD"] = true}

function GM:HUDShouldDraw(ElementName)

	if bHideHUD and ElementsToHide[ElementName] then

		return false
	end

	return self.BaseClass.HUDShouldDraw(self, ElementName)
end
