---- Roleplay: Prison

local bHideHUD = false

local IconWood					= Material("vgui/rpp/icon_wood")
local IconMetal					= Material("vgui/rpp/icon_metal")
local IconHandcuffs				= Material("vgui/rpp/icon_handcuffs")
--local IconDressRobber			= Material("vgui/rpp/icon_dress_robber")
local IconLocked				= Material("vgui/rpp/icon_locked")
local IconUnlocked				= Material("vgui/rpp/icon_unlocked")
local IconHand					= Material("vgui/rpp/icon_hand")
local IconPicklock				= Material("vgui/rpp/icon_picklock")
local IconKnock					= Material("vgui/rpp/icon_knock")
local IconInspect				= Material("vgui/rpp/icon_inspect")

local IconScheduleSetup			= Material("icon16/text_list_numbers.png")
local IconCellsButton			= Material("icon16/lock_open.png")
local IconAlarmButton			= Material("icon16/exclamation.png")
local IconGlobalSpeakerButton	= Material("icon16/sound.png")
local IconServerSabotage		= Material("icon16/server.png")

local IconGuardTask				= Material("icon16/folder_error.png")
local IconRobberTask			= Material("icon16/cog.png")
local IconDetailSpawn			= Material("icon16/brick.png")

local BlurMaterial = Material("pp/blurscreen")

local HUDHintData = {}

local function SetHUDHintDataScheduleSetup()

	HUDHintData.Icon = IconScheduleSetup

	HUDHintData.Text = "Редактирование расписания"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataCellsButton()

	HUDHintData.Icon = IconCellsButton

	HUDHintData.Text = "Управление камерами"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataAlarmButton()

	HUDHintData.Icon = IconAlarmButton

	HUDHintData.Text = "Кнопка тревоги"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataGlobalSpeakerButton()

	HUDHintData.Icon = IconGlobalSpeakerButton

	HUDHintData.Text = "Громкоговоритель"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
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

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataUsable()

	HUDHintData.Icon = IconHand

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = "ПКМ"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataGuardTask(InImplementerName, InNowImplemetingBy)

	HUDHintData.Icon = IconGuardTask

	if InNowImplemetingBy == "" then

		HUDHintData.Text = string.format("Задание для %s", InImplementerName)
	else

		HUDHintData.Text = string.format("Выполняет %s", InNowImplemetingBy)
	end

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
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

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataDetailSpawn(InNowImplemetingBy)

	HUDHintData.Icon = IconDetailSpawn

	if InNowImplemetingBy == "" then

		HUDHintData.Text = "Произведенные детали"
	else

		HUDHintData.Text = string.format("Подбирает %s", InNowImplemetingBy)
	end

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataServerSabotage(bRobberTeam)

	HUDHintData.Icon = IconServerSabotage

	if bRobberTeam then

		HUDHintData.Text = "Саботаж"
	else

		HUDHintData.Text = "Починить"
	end

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataHandcuffs()

	HUDHintData.Icon = IconHandcuffs

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = "ПКМ"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData2Knock()

	HUDHintData.Icon2 = IconKnock

	HUDHintData.IconColor2 = COLOR_YELLOW

	HUDHintData.Text2 = "ЛКМ"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData2Inspect()

	HUDHintData.Icon3 = IconInspect

	HUDHintData.IconColor3 = COLOR_YELLOW

	HUDHintData.Text3 = "R"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData3Kidnap()

	HUDHintData.Icon2 = IconHand

	HUDHintData.IconColor2 = COLOR_YELLOW

	HUDHintData.Text2 = "ЛКМ"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function TryDrawInventory(InClient)

	surface.SetDrawColor(COLOR_YELLOW)

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
	
	surface.SetMaterial(IconPicklock)

	surface.DrawTexturedRect(50, ScrH() - 300, 50, 50)

	surface.SetTextPos(120, ScrH() - 290)

	surface.DrawText(InClient:GetNWInt("PicklockNum"))
end

local function TryDrawHandcuffed(InClient)

	local CurrentAlpha = math.abs(math.sin(CurTime())) * 255

	surface.SetDrawColor(ColorAlpha(COLOR_YELLOW, CurrentAlpha))

	surface.SetMaterial(IconHandcuffs)

	surface.DrawTexturedRect(100, ScrH() / 2, 64, 64)
end

local function DrawHUDHintElement(InX, InIcon, InIconColor, InIconSize, InText)

	local bSuccess = false

	if InIcon then

		surface.SetMaterial(InIcon)

		surface.SetDrawColor(InIconColor)

		surface.DrawTexturedRect(InX - InIconSize.x / 2,
			ScrH() / 2 - InIconSize.y / 2,
			InIconSize.x, InIconSize.y)

		bSuccess = true
	end

	if InText then

		draw.DrawText(InText, "HUDTextSmall", InX, ScrH() / 2 + 16, COLOR_YELLOW, TEXT_ALIGN_CENTER)

		bSuccess = true
	end

	return bSuccess
end

local function TryDrawHUDHintData(InClient)

	local TextBiasY = 0

	local DrawX = ScrW() / 2 - (HUDHintData.TotalNum - 1) * 24

	if DrawHUDHintElement(DrawX, HUDHintData.Icon2, HUDHintData.IconColor2, HUDHintData.IconSize2, HUDHintData.Text2) then

		DrawX = DrawX + 48
	end

	if DrawHUDHintElement(DrawX, HUDHintData.Icon, HUDHintData.IconColor, HUDHintData.IconSize, HUDHintData.Text) then

		DrawX = DrawX + 48
	end

	if DrawHUDHintElement(DrawX, HUDHintData.Icon3, HUDHintData.IconColor3, HUDHintData.IconSize3, HUDHintData.Text3) then

		DrawX = DrawX + 48
	end
end

local function TryDrawTaskTime(InClient)

	local TaskTimeLeft = InClient:GetNWFloat("TaskTimeLeft")

	if TaskTimeLeft > 0 then

		local TextColor = ColorAlpha(COLOR_YELLOW, 255 * (1.0 - InClient:GetNWFloat("TaskCancelExtent")))

		draw.DrawText(string.format("%.1f", TaskTimeLeft),
			"HUDTextSmall", ScrW() / 2, ScrH() / 2 + 64, TextColor, TEXT_ALIGN_CENTER)

		return true
	end

	return false
end

function DrawBlur(InPanel, InValue)

	local ScreenX, ScreenY = InPanel:LocalToScreen(0, 0)

	surface.SetDrawColor(255, 255, 255)

	surface.SetMaterial(BlurMaterial)

	for i = 1, 3 do

		BlurMaterial:SetFloat("$blur", (i / 3) * (InValue or 6))

		BlurMaterial:Recompute()

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect(ScreenX * -1, ScreenY * -1, ScrW(), ScrH())
	end
end

function ResetHUDHintData()

	--Default size and color defined here
	HUDHintData = {Icon = nil, IconColor = COLOR_WHITE, IconSize = {x = 32, y = 32}, Text = nil, TotalNum = 0,
					IconSize2 = {x = 32, y = 32},
					IconSize3 = {x = 32, y = 32}}
end

function UpdateHUDHintData(InPlayer, InTargetEntity)

	--MsgN(InTargetEntity)

	if not InTargetEntity:GetNWBool("bShowHint") and not InTargetEntity:IsPlayer() then

		local TargetEntityParent = InTargetEntity:GetParent()

		if IsValid(TargetEntityParent) and TargetEntityParent:GetNWBool("bShowHint") then

			UpdateHUDHintData(InPlayer, TargetEntityParent)
		end

		return
	end

	if InTargetEntity:GetClass() == "prop_door_rotating" then

		SetHUDHintData2Knock()
	end

	if InTargetEntity:GetNWBool("bScheduleSetupEntity") then

		SetHUDHintDataScheduleSetup()

		return

	elseif InTargetEntity:GetNWBool("bCellsButton") then

		SetHUDHintDataCellsButton()

		return

	elseif InTargetEntity:GetNWBool("bAlarmButton") then

		SetHUDHintDataAlarmButton()

		return

	elseif InTargetEntity:GetNWBool("bGlobalSpeakerButton") then

		SetHUDHintDataGlobalSpeakerButton()

		return
		
	elseif InTargetEntity:GetNWBool("bDetailSpawn") then

		SetHUDHintDataDetailSpawn(InTargetEntity:GetNWString("TaskImplementer"))

		return
		
	elseif InTargetEntity:GetNWBool("bStash") then

		SetHUDHintDataUsable()

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

		elseif InTargetEntity:GetNWBool("bServerSabotage") and InTargetEntity:GetNWBool("bSabotaged") then

			SetHUDHintDataServerSabotage(false)

		elseif InTargetEntity:IsPlayer() and InTargetEntity:Team() == TEAM_ROBBER then

			SetHUDHintDataHandcuffs()

			SetHUDHintData2Inspect()

			if InTargetEntity:GetNWBool("bHandcuffed") then

				SetHUDHintData3Kidnap()
			end
		end

	elseif InPlayer:Team() == TEAM_ROBBER then

		if InTargetEntity:GetNWBool("bRobberTask") then

			SetHUDHintDataRobberTask(InTargetEntity:GetNWString("TaskImplementer"), true)

		elseif InTargetEntity:GetNWBool("bServerSabotage") and not InTargetEntity:GetNWBool("bSabotaged") then

			SetHUDHintDataServerSabotage(true)

		elseif InTargetEntity:GetNWBool("bWasLocked")
			and (InTargetEntity:GetNWBool("bGuardLockable") or InTargetEntity:GetNWBool("bOfficerLockable"))
			and InPlayer:GetNWInt("PicklockNum") > 0 then

			SetHUDHintDataLockable(InTargetEntity:GetNWBool("bWasLocked"))
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

		TryDrawInventory(Client)
	end

	if TryDrawTaskTime(Client) then

		ResetHUDHintData()
	else

		TryDrawHUDHintData(Client)
	end

	if Client:GetNWBool("bHandcuffed") then

		TryDrawHandcuffed(Client)
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
