---- Roleplay: Prison

local bHideHUD = false

local IconWood					= Material("vgui/rpp/icon_wood")
local IconMetal					= Material("vgui/rpp/icon_metal")
--local IconDressRobber			= Material("vgui/rpp/icon_dress_robber")
local IconLocked				= Material("vgui/rpp/icon_locked")
local IconUnlocked				= Material("vgui/rpp/icon_unlocked")
local IconHand					= Material("vgui/rpp/icon_hand")

local IconCellsButton			= Material("icon16/lock_open.png")
local IconAlarmButton			= Material("icon16/exclamation.png")
local IconGlobalSpeakerButton	= Material("icon16/sound.png")

local IconGuardTask				= Material("icon16/folder_error.png")
local IconRobberTask			= Material("icon16/cog.png")

local HUDHintData = {}

local function SetHUDHintDataCellsButton()

	HUDHintData.Icon = IconCellsButton

	HUDHintData.Text = "Управление камерами"
end

local function SetHUDHintDataAlarmButton()

	HUDHintData.Icon = IconAlarmButton

	HUDHintData.Text = "Кнопка тревоги"
end

local function SetHUDHintDataGlobalSpeakerButton()

	HUDHintData.Icon = IconGlobalSpeakerButton

	HUDHintData.Text = "Громкоговоритель"
end

local function SetHUDHintDataLockable(bWasLocked)

	if bWasLocked then

		HUDHintData.Icon = IconLocked
	else

		HUDHintData.Icon = IconUnlocked
	end

	HUDHintData.IconSize.x = 48

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = "ПКМ"
end

local function SetHUDHintDataUsable()

	HUDHintData.Icon = IconHand

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = "ПКМ"
end

local function SetHUDHintDataGuardTask(InImplementerName, InNowImplemetingBy)

	HUDHintData.Icon = IconGuardTask

	if InNowImplemetingBy == "" then

		HUDHintData.Text = string.format("Задание для %s", InImplementerName)
	else

		HUDHintData.Text = string.format("Выполняет %s", InNowImplemetingBy)
	end
end

local function SetHUDHintDataRobberTask(InNowImplemetingBy, bRobberTeam)

	HUDHintData.Icon = IconRobberTask

	if InNowImplemetingBy == "" then

		if bRobberTeam then

			HUDHintData.Text = "Начать работу"
		else

			HUDHintData.Text = "Работа для заключенного"
		end
	else

		HUDHintData.Text = string.format("Выполняет %s", InNowImplemetingBy)
	end
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

	surface.DrawText(InClient:GetNWInt("DetailWoodNum"))
	
	surface.SetMaterial(IconMetal)

	surface.DrawTexturedRect(50, ScrH() - 250, 50, 50)

	surface.SetTextPos(120, ScrH() - 240)

	surface.DrawText(InClient:GetNWInt("DetailMetalNum"))
end

local function TryDrawHUDHintData(InClient)

	if not IsValid(InClient) then

		return
	end

	local TextBiasY = 0

	if HUDHintData.Icon then

		surface.SetMaterial(HUDHintData.Icon)

		surface.SetDrawColor(HUDHintData.IconColor)

		surface.DrawTexturedRect(ScrW() / 2 - HUDHintData.IconSize.x / 2,
			ScrH() / 2 - HUDHintData.IconSize.y / 2,
			HUDHintData.IconSize.x, HUDHintData.IconSize.y)

		TextBiasY = HUDHintData.IconSize.y / 2
	end

	if HUDHintData.Text then

		draw.DrawText(HUDHintData.Text, "HUDTextSmall", ScrW() / 2, ScrH() / 2 + TextBiasY, COLOR_YELLOW, TEXT_ALIGN_CENTER)
	end
end

local function TryDrawTaskTime(InClient)

	if not IsValid(InClient) then

		return false
	end

	local TaskTimeLeft = InClient:GetNWFloat("TaskTimeLeft")

	if TaskTimeLeft > 0 then

		local TextColor = ColorAlpha(COLOR_YELLOW, 255 * (1.0 - InClient:GetNWFloat("TaskCancelExtent")))

		draw.DrawText(string.format("%.1f", TaskTimeLeft),
			"HUDTextSmall", ScrW() / 2, ScrH() / 2 + 64, TextColor, TEXT_ALIGN_CENTER)

		return true
	end

	return false
end

function ResetHUDHintData()

	HUDHintData = {Icon = nil, IconColor = COLOR_WHITE, IconSize = {x = 32, y = 32}, Text = nil}
end

function UpdateHUDHintData(InPlayer, InTargetEntity)

	MsgN(InTargetEntity)

	if not InTargetEntity:GetNWBool("bShowHint") then

		local TargetEntityParent = InTargetEntity:GetParent()

		if IsValid(TargetEntityParent) and TargetEntityParent:GetNWBool("bShowHint") then

			TryUpdateHUDHintData(InPlayer, TargetEntityParent)
		end

		return
	end

	if InTargetEntity:GetNWBool("bCellsButton") then

		SetHUDHintDataCellsButton()

		return

	elseif InTargetEntity:GetNWBool("bAlarmButton") then

		SetHUDHintDataAlarmButton()

		return

	elseif InTargetEntity:GetNWBool("bGlobalSpeakerButton") then

		SetHUDHintDataGlobalSpeakerButton()

		return
	end

	if InPlayer:Team() == TEAM_GUARD then

		if InTargetEntity:GetNWBool("bGuardLockable") or InTargetEntity:GetNWBool("bOfficerLockable") then

			SetHUDHintDataLockable(InTargetEntity:GetNWBool("bWasLocked"))
		
		elseif InTargetEntity:GetNWBool("bGuardUser1") or InTargetEntity:GetNWBool("bAllUser1") then

			SetHUDHintDataUsable()
		
		elseif InTargetEntity:GetNWBool("bGuardTask") or InTargetEntity:GetNWBool("bOfficerPhone") then

			local TaskImplementer = InTargetEntity:GetNWString("TaskImplementer")

			if TaskImplementer ~= "" then

				SetHUDHintDataGuardTask(TaskImplementer, InTargetEntity:GetNWString("NowImplemetingBy"))
			end
		
		elseif InTargetEntity:GetNWBool("bRobberTask") then

			SetHUDHintDataRobberTask(InTargetEntity:GetNWString("TaskImplementer"), false)
		end

	elseif InPlayer:Team() == TEAM_ROBBER then

		if InTargetEntity:GetNWBool("bRobberTask") then

			SetHUDHintDataRobberTask(InTargetEntity:GetNWString("TaskImplementer"), true)
		end
	end
end

function GM:HUDDrawTargetID()

	
end

function GM:HUDPaint()

	local Client = LocalPlayer()

	bHideHUD = not Client:KeyDown(IN_WALK)

	if not Client:Alive() or Client:Team() == TEAM_SPECTATOR or Client:Team() == TEAM_UNASSIGNED then

		if hook.Run("HUDShouldDraw", "RPPSpecHUD") then

			 --SpecHUDPaint(Client)
		end

		return
	end

	if hook.Run("HUDShouldDraw", "RPPInventory") and Client:Team() == TEAM_ROBBER then

		InventoryDraw(Client)
	end

	if not TryDrawTaskTime(Client) then

		TryDrawHUDHintData(Client)
	end
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
