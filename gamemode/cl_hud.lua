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
local IconCross					= Material("vgui/rpp/icon_cross")

local IconScheduleSetup			= Material("icon16/text_list_numbers.png")
local IconCellsButton			= Material("icon16/lock_open.png")
local IconAlarmButton			= Material("icon16/exclamation.png")
local IconGlobalSpeakerButton	= Material("icon16/sound.png")
local IconServerSabotage		= Material("icon16/server.png")

local IconGuardTask				= Material("icon16/folder_error.png")
local IconRobberTask			= Material("icon16/cog.png")
local IconDetailSpawn			= Material("icon16/brick.png")
local IconFood					= Material("icon16/basket.png")
local IconFoodSpawn				= Material("icon16/basket_add.png")
local IconWater					= Material("icon16/cup.png")
local IconWaterSpawn			= Material("icon16/cup_add.png")
local IconCraft					= Material("icon16/plugin.png")

local BlurMaterial = Material("pp/blurscreen")

local HUDHintData = {}

timer.Create("HUDHintDataTick", 0.2, 0, function()

	ResetHUDHintData()

	local ClientPlayer = LocalPlayer()

	if not IsValid(ClientPlayer) or ClientPlayer:GetNWFloat("TaskTimeLeft") > 0.0 then

		return
	end

	UpdatePostProcessData(ClientPlayer)

	local ClientWeapon = ClientPlayer:GetActiveWeapon()

	if not IsValid(ClientWeapon) or ClientWeapon:GetClass() ~= "weapon_rpp_unarmed" or not UtilPlayerCanInteract(ClientPlayer) then

		return
	end

	local EyeTrace = ClientPlayer:GetEyeTrace()

	if EyeTrace.Fraction * 32768 > 128 or not IsValid(EyeTrace.Entity) then

		return
	end

	--MsgN(EyeTrace.Entity:GetCollisionGroup())

	UpdateHUDHintData(ClientPlayer, EyeTrace.Entity)
end)

local function SetHUDHintDataFood()

	--MsgN("SetHUDHintDataFood()")

	HUDHintData.Icon = IconFood

	HUDHintData.IconColor = COLOR_WHITE

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Reload")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataFoodSpawn()

	--MsgN("SetHUDHintDataFoodSpawn()")

	HUDHintData.Icon = IconFoodSpawn

	HUDHintData.IconColor = COLOR_WHITE

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Nutrition")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataWater()

	--MsgN("SetHUDHintDataWater()")

	HUDHintData.Icon = IconWater

	HUDHintData.IconColor = COLOR_WHITE

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Reload")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataWaterSpawn()

	--MsgN("SetHUDHintDataWaterSpawn()")

	HUDHintData.Icon = IconWaterSpawn

	HUDHintData.IconColor = COLOR_WHITE

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Nutrition")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataCraft()

	--MsgN("SetHUDHintDataCraft()")

	HUDHintData.Icon = IconCraft

	HUDHintData.IconColor = COLOR_WHITE

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Workbench")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataScheduleSetup()

	HUDHintData.Icon = IconScheduleSetup

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Schedule")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataCellsButton()

	HUDHintData.Icon = IconCellsButton

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Cells")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataAlarmButton()

	HUDHintData.Icon = IconAlarmButton

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Alarm")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataGlobalSpeakerButton()

	HUDHintData.Icon = IconGlobalSpeakerButton

	HUDHintData.Text = UtilLocalizable("RPP_HUD.Speaker")

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

	HUDHintData.Text = UtilLocalizable("RPP_HUD.RMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataPicklock()

	HUDHintData.Icon = IconPicklock

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = UtilLocalizable("RPP_HUD.RMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataUsable()

	HUDHintData.Icon = IconHand

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = UtilLocalizable("RPP_HUD.RMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataGuardTask(InImplementerName, InNowImplemetingBy)

	HUDHintData.Icon = IconGuardTask

	if InNowImplemetingBy == "" then

		HUDHintData.Text = Format(UtilLocalizable("RPP_HUD.TaskFor"), InImplementerName)
	else

		HUDHintData.Text = Format(UtilLocalizable("RPP_HUD.ImplementingBy"), InNowImplemetingBy)
	end

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataRobberTask(InNowImplemetingBy, bRobberTeam)

	HUDHintData.Icon = IconRobberTask

	if InNowImplemetingBy == "" then

		if bRobberTeam then

			HUDHintData.Text = UtilLocalizable("RPP_HUD.StartWork")
		else

			HUDHintData.Text = UtilLocalizable("RPP_HUD.RobberWork")
		end
	else

		HUDHintData.Text = Format(UtilLocalizable("RPP_HUD.ImplementingBy"), InNowImplemetingBy)
	end

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataDetailSpawn(InNowImplemetingBy)

	HUDHintData.Icon = IconDetailSpawn

	if InNowImplemetingBy == "" then

		HUDHintData.Text = UtilLocalizable("RPP_HUD.Details")
	else

		HUDHintData.Text = Format(UtilLocalizable("RPP_HUD.BeingTakenBy"), InNowImplemetingBy)
	end

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataServerSabotage(bRobberTeam)

	HUDHintData.Icon = IconServerSabotage

	if bRobberTeam then

		HUDHintData.Text = UtilLocalizable("RPP_HUD.Sabotage")
	else

		HUDHintData.Text = UtilLocalizable("RPP_HUD.Repair")
	end

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData2Knock()

	HUDHintData.Icon2 = IconKnock

	HUDHintData.IconColor2 = COLOR_YELLOW

	HUDHintData.Text2 = UtilLocalizable("RPP_HUD.LMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataHandcuffs()

	HUDHintData.Icon = IconHandcuffs

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = UtilLocalizable("RPP_HUD.RMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData2Inspect()

	HUDHintData.Icon2 = IconInspect

	HUDHintData.IconColor2 = COLOR_YELLOW

	HUDHintData.Text2 = UtilLocalizable("RPP_HUD.Reload")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData3Kidnap()

	HUDHintData.Icon3 = IconHand

	HUDHintData.IconColor3 = COLOR_YELLOW

	HUDHintData.Text3 = UtilLocalizable("RPP_HUD.LMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataTradeWood()

	--MsgN("SetHUDHintDataTradeWood()")

	HUDHintData.Icon = IconWood

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = UtilLocalizable("RPP_HUD.LMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData2TradeMetal()

	--MsgN("SetHUDHintData2TradeMetal()")

	HUDHintData.Icon2 = IconMetal

	HUDHintData.IconColor2 = COLOR_YELLOW

	HUDHintData.Text2 = UtilLocalizable("RPP_HUD.RMB")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintData3TradePicklock()

	--MsgN("SetHUDHintData3TradePicklock()")

	HUDHintData.Icon3 = IconPicklock

	HUDHintData.IconColor3 = COLOR_YELLOW

	HUDHintData.Text3 = UtilLocalizable("RPP_HUD.Reload")

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataStash()

	HUDHintData.Icon = IconHand

	HUDHintData.IconColor = COLOR_YELLOW

	--HUDHintData.Text = "Заначка"

	HUDHintData.TotalNum = HUDHintData.TotalNum + 1
end

local function SetHUDHintDataRevive()

	--MsgN("SetHUDHintDataRevive()")

	HUDHintData.Icon = IconCross

	HUDHintData.IconColor = COLOR_YELLOW

	HUDHintData.Text = UtilLocalizable("RPP_HUD.RMB")

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

local function TryDrawPlayerInfo(InClient)

	local RPName, RPSurname = UtilGetRPNameSurname(InClient)

	draw.SimpleText(Format("%s %s", UtilLocalizable(RPName), UtilLocalizable(RPSurname)),
		"HUDText", ScrW() - 50, ScrH() - 150, COLOR_YELLOW, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

local function TryDrawTalkieInfo(InClient)

	draw.SimpleText(Format("%.1f", InClient:GetNWFloat("TalkieFrequency")),
		"HUDText", ScrW() - 50, ScrH() - 300, COLOR_YELLOW, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
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

	local DrawX = ScrW() / 2 - ((HUDHintData.TotalNum or 0) - 1) * 24

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

		draw.SimpleText(Format("%.1f", TaskTimeLeft),
			"HUDTextSmall", ScrW() / 2, ScrH() / 2 + 64, TextColor, TEXT_ALIGN_CENTER)

		return true
	end

	return false
end

local function TryDrawOfficerPunishmentTimeLeft(InClient)

	local PunishmentTimeLeft = UtilGetOfficerPunishmentTimeLeft()

	if PunishmentTimeLeft > 0 then

		draw.SimpleText(Format(UtilLocalizable("RPP_HUD.PunishmentTimeLeft"), PunishmentTimeLeft),
			"HUDText", ScrW() / 2, ScrH() / 2 + 150, COLOR_YELLOW, TEXT_ALIGN_CENTER)

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

	--MsgN("ResetHUDHintData()")

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

	if InTargetEntity:GetClass() == "prop_door_rotating" or InTargetEntity:GetNWBool("bCellDoor") then

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
		
	elseif InTargetEntity:GetNWBool("bFoodInstance") then

		SetHUDHintDataFood()

		return
		
	elseif InTargetEntity:GetNWBool("bFoodSpawn") then

		SetHUDHintDataFoodSpawn()

		return
		
	elseif InTargetEntity:GetNWBool("bWaterInstance") then

		SetHUDHintDataWater()

		return
		
	elseif InTargetEntity:GetNWBool("bWaterSpawn") then

		SetHUDHintDataWaterSpawn()

		return

	elseif InTargetEntity:GetNWBool("bWorkbench") then

		SetHUDHintDataCraft()

		return
		
	elseif InTargetEntity:GetNWBool("bStash") then

		SetHUDHintDataStash()

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

			SetHUDHintDataPicklock()

		elseif InTargetEntity:GetNWBool("bCellDoor") and InPlayer:GetNWInt("PicklockNum") > 0 then

			SetHUDHintDataPicklock()

		elseif InTargetEntity:IsPlayer() and InTargetEntity:Team() == TEAM_ROBBER then

			if InTargetEntity:GetNWBool("bHandcuffed") then

				SetHUDHintDataHandcuffs()
			else
				if InPlayer:GetNWInt("DetailWoodNum") > 0 then

					SetHUDHintDataTradeWood()
				end

				if InPlayer:GetNWInt("DetailMetalNum") > 0 then

					SetHUDHintData2TradeMetal()
				end

				if InPlayer:GetNWInt("PicklockNum") > 0 then

					SetHUDHintData3TradePicklock()
				end
			end
		end

	elseif InPlayer:Team() == TEAM_MEDIC then

		if InTargetEntity:GetNWBool("bGuardLockable") or InTargetEntity:GetNWBool("bOfficerLockable") then

			SetHUDHintDataLockable(InTargetEntity:GetNWBool("bWasLocked"))
		
		elseif InTargetEntity:GetNWBool("bGuardUser1") or InTargetEntity:GetNWBool("bAllUser1") then

			SetHUDHintDataUsable()

		elseif InTargetEntity:GetNWBool("bIncapped") then

			SetHUDHintDataRevive()
		end
	end
end

function GM:HUDDrawTargetID()

	local Client = LocalPlayer()

	local EyeTrace = Client:GetEyeTrace()

	--MsgN(EyeTrace.Entity)

	if not EyeTrace.Hit or not EyeTrace.HitNonWorld then

		return
	end

	if EyeTrace.Entity:IsPlayer() then

		local RPName, RPSurname = UtilGetRPNameSurname(EyeTrace.Entity)

		draw.SimpleText(Format("%s %s", UtilLocalizable(RPName), UtilLocalizable(RPSurname)),
			"HUDText", ScrW() / 2, ScrH() / 2 + 50, self:GetTeamColor(EyeTrace.Entity), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function GM:HUDPaint()

	local Client = LocalPlayer()

	local bInteractInterfaceOpen = IsScheduleOpen() or IsWorkbenchOpen() or IsStashOpen()

	bHideHUD = not Client:KeyDown(IN_WALK) and not bInteractInterfaceOpen

	if not Client:Alive() or Client:Team() == TEAM_SPECTATOR or Client:Team() == TEAM_UNASSIGNED then

		--SpecHUDPaint(Client)

		return
	end

	if not bHideHUD then

		TryDrawPlayerInfo(Client)

		if Client:Team() == TEAM_ROBBER then

			TryDrawInventory(Client)
		end

		hook.Run("HUDDrawTargetID")
	end

	if Client:GetNWBool("bOfficer") then

		TryDrawOfficerPunishmentTimeLeft()
	end

	if IsValid(Client:GetActiveWeapon()) and Client:GetActiveWeapon():GetClass() == "weapon_rpp_talkie" then

		TryDrawTalkieInfo(Client)
	end

	if not TryDrawTaskTime(Client) and not bInteractInterfaceOpen then

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
						["RPPPlayerInfo"] = true,
						["RPPSpecHUD"] = true}

function GM:HUDShouldDraw(ElementName)

	if bHideHUD and ElementsToHide[ElementName] then

		return false
	end

	return self.BaseClass.HUDShouldDraw(self, ElementName)
end
