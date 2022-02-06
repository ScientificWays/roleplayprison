---- Roleplay: Prison

local RPNameConvertTable = {
	Bazar = "Базар",
	Karp = "Карп",
	Sever = "Север",
	Agafon = "Агафон",
	Anton = "Антон",
	Arkadiy = "Аркадий",
	Arseniy = "Арсений",
	Artemiy = "Артемий",
	Arhipp = "Архипп",
	Afanasiy = "Афанасий",
	Boris = "Борис",
	Valentin = "Валентин",
	Varlam = "Варлам",
	Varfolomey = "Варфоломей",
	Vasiliy = "Василий",
	Venedikt = "Венедикт",
	Vikentiy = "Викентий",
	Viktor = "Виктор",
	Vissarion = "Виссарион",
	Vsevolod = "Всеволод",
	Gavriil = "Гавриил",
	Gennadiy = "Геннадий",
	Georgiy = "Георгий",
	Gerasim = "Герасим",
	German = "Герман",
	Gleb = "Глеб",
	Grigoriy = "Григорий",
	Demyan = "Демьян",
	Efrem = "Ефрем",
	Zhdan = "Ждан",
	Ivan = "Иван",
	Innokentiy = "Иннокентий",
	Kondrat = "Кондрат",
	Lavrentiy = "Лаврентий",
	Leonid = "Леонид",
	Makar = "Макар",
	Matvey = "Матвей",
	Nikifor = "Никифор",
	Nikolay = "Николай",
	Oleg = "Олег",
	Panteleimon = "Пантелеймон",
	Pahomiy = "Пахомий",
	Pyotr = "Пётр",
	Platon = "Платон",
	Roman = "Роман",
	Saveliy = "Савелий",
	Semen = "Семён",
	Sergey = "Сергей",
	Stepan = "Степан",
	Taras = "Тарас",
	Tihon = "Тихон",
	Fedor = "Фёдор",
	Fedot = "Федот",
	Foma = "Фома",

	Avrora = "Аврора",
	Agafya = "Агафья",
	Alevtina = "Алевтина",
	Anna = "Анна",
	Vasilisa = "Василиса",
	Veronika = "Вероника",
	Glafira = "Глафира",
	Darya = "Дарья",
	Evgenia = "Евгения",
	Evdokia = "Евдокия",
	Klementina = "Клементина",
	Ksenia = "Ксения",
	Larisa = "Лариса",
	Marianna = "Марианна",
	Marina = "Марина",
	Maria = "Мария",
	Marta = "Марта",
	Nadezhda = "Надежда",
	Natalia = "Наталья",
	Nikoletta = "Николетта"
}

local function TryConvertPlayerName(InName)

	return RPNameConvertTable[InName] or InName
end

function GM:PlayerSay(InSender, InText, bTeamChat)

	if InText[1] ~= "/" then

		MsgN(Format("Chat text: %s ", InText))

		return InText
	end

	local SeparatedStrings = string.Explode(" ", InText, false)

	if SeparatedStrings[1] == "/help" then

		UtilSendEventMessageToPlayers({"RPP_Chat.Help"})

	elseif SeparatedStrings[1] == "/vote" and SeparatedStrings[2] ~= nil then

		AddOfficerVote(InSender, TryConvertPlayerName(SeparatedStrings[2]))

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/votefinish" then

		FinishOfficerVote()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/start" then

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)

		StartNewCycle()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/auto" then

		FinishOfficerVote()

		local WorldEntity = game.GetWorld()

		WorldEntity:SetNWBool("bInterCycle", false)
		
		StartNewCycle()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/pause" then

		ToggleCycle(true)

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/unpause" then

		ToggleCycle(false)

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/skip" then

		if SeparatedStrings[2] == "cycle" then

			StartNewCycle()

		elseif SeparatedStrings[2] == "delay" and SeparatedStrings[3] ~= nil then

			TrySkipTaskDelayFor(TryConvertPlayerName(SeparatedStrings[3]))
		end

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/Лёха" then

		local DebugDude = player.CreateNextBot("Лёха")

		DebugDude:SetTeam(TEAM_GUARD)

		DebugDude:SetNWString("RPName", "Лёха")

		DebugDude:Spawn()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/Саня" then

		local DebugDude = player.CreateNextBot("Саня")

		DebugDude:SetTeam(TEAM_ROBBER)

		DebugDude:SetNWString("RPName", "Саня")

		DebugDude:Spawn()

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/give" and SeparatedStrings[2] ~= nil then

		local GivePlayer = UtilGetPlayerByRPName(TryConvertPlayerName(SeparatedStrings[2]))

		if IsValid(GivePlayer) then

			if not TryGiveWeaponItem(GivePlayer, SeparatedStrings[3]) then

				TryGiveStackableItem(GivePlayer, SeparatedStrings[3], SeparatedStrings[4] or "1")
			end
		end

	elseif InSender:IsAdmin() and SeparatedStrings[1] == "/foodadd" or SeparatedStrings[1] == "/wateradd" then

		if SeparatedStrings[2] ~= nil and SeparatedStrings[3] ~= nil then

			local TargetPlayer = UtilGetPlayerByRPName(TryConvertPlayerName(SeparatedStrings[2]))

			AddNutrition(TargetPlayer, math.Round(tonumber(SeparatedStrings[3]) or 0), SeparatedStrings[1] == "/foodadd")
		end
	end

	return ""
end
