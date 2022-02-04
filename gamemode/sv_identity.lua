---- Roleplay: Prison

local MaleGuardModels = {
	{Name = "male_01_security", HandsBodygroup = 1},
	{Name = "male_02_security", HandsBodygroup = 0},
	{Name = "male_03_security", HandsBodygroup = 1},
	{Name = "male_04_security", HandsBodygroup = 0},
	{Name = "male_05_security", HandsBodygroup = 0},
	{Name = "male_06_security", HandsBodygroup = 0},
	{Name = "male_07_security", HandsBodygroup = 0},
	{Name = "male_08_security", HandsBodygroup = 0},
	{Name = "male_09_security", HandsBodygroup = 0}
} local MaleGuardModelsCopy = table.Copy(MaleGuardModels)

for Index, SampleModelData in ipairs(MaleGuardModels) do

	player_manager.AddValidModel(SampleModelData.Name, Format("models/player/portal/%s.mdl", SampleModelData.Name))
	player_manager.AddValidHands(SampleModelData.Name, "models/weapons/c_arms_citizen.mdl", SampleModelData.HandsBodygroup, "0000000")
end

local MaleRobberModels = {
	{Name = "class_d_1", HandsBodygroup = 0},
	{Name = "class_d_2", HandsBodygroup = 0},
	{Name = "class_d_3", HandsBodygroup = 0},
	{Name = "class_d_4", HandsBodygroup = 0},
	{Name = "class_d_5", HandsBodygroup = 0},
	{Name = "class_d_6", HandsBodygroup = 0},
	{Name = "class_d_7", HandsBodygroup = 0}
} local MaleRobberModelsCopy = table.Copy(MaleRobberModels)

for Index, SampleModelData in ipairs(MaleRobberModels) do

	player_manager.AddValidModel(SampleModelData.Name, Format("models/player/kerry/%s.mdl", SampleModelData.Name))
	player_manager.AddValidHands(SampleModelData.Name, "models/weapons/c_arms_refugee.mdl", SampleModelData.HandsBodygroup, "0000000")
end

local MaleNames = {
	"Базар",
	"Карп",
	"Север",
	"Агафон",
	"Антон",
	"Аркадий",
	"Арсений",
	"Артемий",
	"Архипп",
	"Афанасий",
	"Борис",
	"Валентин",
	"Варлам",
	"Варфоломей",
	"Василий",
	"Венедикт",
	"Викентий",
	"Виктор",
	"Виссарион",
	"Всеволод",
	"Гавриил",
	"Геннадий",
	"Георгий",
	"Герасим",
	"Герман",
	"Глеб",
	"Григорий",
	"Демьян",
	"Ефрем",
	"Ждан",
	"Иван",
	"Иннокентий",
	"Кондрат",
	"Лаврентий",
	"Леонид",
	"Макар",
	"Матвей",
	"Никифор",
	"Николай",
	"Олег",
	"Пантелеймон",
	"Пахомий",
	"Пётр",
	"Платон",
	"Роман",
	"Савелий",
	"Семён",
	"Сергей",
	"Степан",
	"Тарас",
	"Тихон",
	"Фёдор",
	"Федот",
	"Фома"
} local MaleNamesCopy = table.Copy(MaleNames)

local MaleSurnames = {
	"Барсов",
	"Бабочкин",
	"Окуневский",
	"Тополь",
	"Дубов",
	"Цветков",
	"Токарев",
	"Гончаров",
	"Москвин",
	"Костромской",
	"Ржевский",
	"Загорский",
	"Смоленский",
	"Снежин",
	"Козырь",
	"Агатов",
	"Аграновский",
	"Алмазов",
	"Амурский",
	"Андреев",
	"Антонов",
	"Арсеньев",
	"Архипов",
	"Афанасьев",
	"Белов",
	"Бахметев",
	"Барский",
	"Березин",
	"Булатов",
	"Васильев",
	"Вертинский",
	"Ветринский",
	"Ветров",
	"Волынский",
	"Воронов",
	"Вьюгин",
	"Глинский",
	"Городецкий",
	"Градов",
	"Граф",
	"Григорьев",
	"Даль",
	"Дёмин",
	"Донской",
	"Ежов",
	"Жаров",
	"Звездинский",
	"Зефиров",
	"Златовратский",
	"Златоумов",
	"Ижорский",
	"Кедров",
	"Книжник",
	"Князев",
	"Колосов",
	"Кондратьев",
	"Король",
	"Красавин",
	"Крапивин",
	"Красногорский",
	"Лапин",
	"Лебедев",
	"Лисичкин",
	"Магницкий",
	"Майоров",
	"Малинин",
	"Мамин",
	"Мельников",
	"Нагорный",
	"Оленин",
	"Орлов",
	"Остроумов",
	"Парижский",
	"Пешков",
	"Погодин",
	"Полянский",
	"Решетов",
	"Румянцев",
	"Сахаров",
	"Северянин",
	"Серебров",
	"Сербский",
	"Солнцев",
	"Сталь",
	"Симонов",
	"Субботин",
	"Троянский",
	"Федоров",
	"Францев",
	"Хомский",
	"Цезарев",
	"Черкасов",
	"Чернышевский",
	"Шведов",
	"Шестов",
	"Шумов",
	"Эльбрусский",
	"Юпитеров",
	"Юрский",
	"Яблоков"
} local MaleSurnamesCopy = table.Copy(MaleSurnames)

local FemaleGuardModels = {
	{Name = "f_sheriff_03", HandsBodygroup = 0},
	{Name = "f_sheriff_04", HandsBodygroup = 0},
	{Name = "thalia_sheriff_02", HandsBodygroup = 0}
} local FemaleGuardModelsCopy = table.Copy(FemaleGuardModels)

for Index, SampleModelData in ipairs(FemaleGuardModels) do

	player_manager.AddValidModel(SampleModelData.Name, Format("models/player/kerry/%s.mdl", SampleModelData.Name))
	player_manager.AddValidHands(SampleModelData.Name, "models/weapons/c_arms_citizen.mdl", SampleModelData.HandsBodygroup, "0000000")
end

--[[local FemaleRobberModels = {
	{Name = "female07", HandsBodygroup = 0},
	{Name = "female08", HandsBodygroup = 0},
	{Name = "female09", HandsBodygroup = 1},
	{Name = "female10", HandsBodygroup = 0},
	{Name = "female11", HandsBodygroup = 1},
	{Name = "female12", HandsBodygroup = 0}
} local FemaleRobberModelsCopy = table.Copy(FemaleRobberModels)--]]

--[[for Index, SampleModelData in ipairs(FemaleRobberModels) do

	player_manager.AddValidModel(SampleModelData.Name, Format("models/humans/group04/%s.mdl", string.Left(SampleModelData.Name, 9)))
	player_manager.AddValidHands(SampleModelData.Name, "models/weapons/c_arms_refugee.mdl", SampleModelData.HandsBodygroup, "0000000")
end--]]

local FemaleNames = {
	"Аврора",
	"Агафья",
	"Алевтина",
	"Анна",
	"Василиса",
	"Вероника",
	"Глафира",
	"Дарья",
	"Евгения",
	"Евдокия",
	"Клементина",
	"Ксения",
	"Лариса",
	"Марианна",
	"Марина",
	"Мария",
	"Марта",
	"Надежда",
	"Наталья",
	"Николетта"
} local FemaleNamesCopy = table.Copy(FemaleNames)

local FemaleSurnames = {
	"Алёхина",
	"Алёшина",
	"Андреева",
	"Антипова",
	"Антонова",
	"Астафьева",
	"Афанасьева",
	"Барсукова",
	"Басова",
	"Белова",
	"Березина",
	"Бессонова",
	"Блинова",
	"Боброва",
	"Борисова",
	"Быкова",
	"Васильева",
	"Виноградова",
	"Воробьёва",
	"Глебова",
	"Гончарова",
	"Горохова",
	"Грачёва",
	"Гришина",
	"Дашкова",
	"Дорофеева",
	"Евдокимова",
	"Ежова",
	"Емельянова",
	"Ерофеева",
	"Исаева"
} local FemaleSurnamesCopy = table.Copy(FemaleSurnames)

local function GetRandomAndDeleteFromLists(InModelList, InNameList, InSurnameList)

	local ModelIndex, NameIndex, SurnameIndex = math.random(#InModelList), math.random(#InNameList), math.random(#InSurnameList)

	local OutModel, OutName, OutSurname = InModelList[ModelIndex].Name, InNameList[NameIndex], InSurnameList[SurnameIndex]

	table.remove(InModelList, ModelIndex)

	table.remove(InNameList, NameIndex)

	table.remove(InSurnameList, SurnameIndex)

	return OutModel, OutName, OutSurname
end

local function RefreshEmptyLists()

	if table.IsEmpty(MaleGuardModels) then

		MaleGuardModels = table.Copy(MaleGuardModelsCopy)
	end

	if table.IsEmpty(MaleRobberModels) then

		MaleRobberModels = table.Copy(MaleRobberModelsCopy)
	end

	if table.IsEmpty(MaleNames) then

		MaleNames = table.Copy(MaleNamesCopy)
	end

	if table.IsEmpty(MaleSurnames) then

		MaleSurnames = table.Copy(MaleSurnamesCopy)
	end

	if table.IsEmpty(FemaleGuardModels) then

		FemaleGuardModels = table.Copy(FemaleGuardModelsCopy)
	end

	--[[if table.IsEmpty(FemaleRobberModels) then

		FemaleRobberModels = table.Copy(FemaleRobberModelsCopy)
	end--]]

	if table.IsEmpty(FemaleNames) then

		FemaleNames = table.Copy(FemaleNamesCopy)
	end

	if table.IsEmpty(FemaleSurnames) then

		FemaleSurnames = table.Copy(FemaleSurnamesCopy)
	end
end

local RejoinIdentityList = {}

function GetNewPlayerIdentity(InPlayer, bGuard, bMale)

	local ID = InPlayer:AccountID()

	local OutModel, OutName, OutSurname = "", "", ""

	if RejoinIdentityList[ID] ~= nil and RejoinIdentityList[ID].bGuard == bGuard and RejoinIdentityList[ID].bMale == bMale then

		OutModel, OutName, OutSurname = RejoinIdentityList[ID].Model, RejoinIdentityList[ID].Name, RejoinIdentityList[ID].Surname

		UtilSendEventMessageToPlayers({"RPP_RPEvent.Reconnect", InPlayer:Nick()})
	else
		RefreshEmptyLists()

		if bMale then

			if bGuard then

				OutModel, OutName, OutSurname = GetRandomAndDeleteFromLists(MaleGuardModels, MaleNames, MaleSurnames)
			else

				OutModel, OutName, OutSurname = GetRandomAndDeleteFromLists(MaleRobberModels, MaleNames, MaleSurnames)
			end
		else

			if bGuard then

				OutModel, OutName, OutSurname = GetRandomAndDeleteFromLists(FemaleGuardModels, FemaleNames, FemaleSurnames)
			else

				--OutModel, OutName, OutSurname = GetRandomAndDeleteFromLists(FemaleRobberModels, FemaleNames, FemaleSurnames)
			end
		end

		RejoinIdentityList[ID] = {Model = OutModel, Name = OutName, Surname = OutSurname, bGuard = bGuard, bMale = bMale}
	end

	return OutModel, OutName, OutSurname
end

function SetupRPModel(InPlayer)

	local RPPlayerModel = InPlayer.RPModel or InPlayer:GetInfo("cl_playermodel")

	local ModelName = player_manager.TranslatePlayerModel(RPPlayerModel)

	MsgN(ModelName)

	util.PrecacheModel(ModelName)

	InPlayer:SetModel(ModelName)

	local ModelSkin = math.random(InPlayer:SkinCount() - 1)

	InPlayer:SetSkin(ModelSkin)

	--[[for BodygroupIndex = 0, InPlayer:GetNumBodyGroups() - 1 do

		InPlayer:SetBodygroup(BodygroupIndex, math.random(InPlayer:GetBodygroupCount(BodygroupIndex) - 1))
	end--]]
end
