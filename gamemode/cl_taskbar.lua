---- Roleplay: Prison

local TaskBarWidth, TaskBarHeight = 300, 20

local TaskBarPanel = nil

function ShowTaskBar(InClient, InTime)

	local plus = ws / InTime * 0.1
	local sum = 0

	TaskBarPanel = vgui.Create("DPanel")

	TaskBarPanel:SetPos(ScrW() / 2 - TaskBarWidth / 2, ScrH() / 2 - TaskBarHeight / 2 + 20)

	TaskBarPanel:SetSize(TaskBarWidth, TaskBarHeight)

	TaskBarPanel.lerp = 0

	TaskBarPanel.Paint = function(self, InWidth, InHeight)

		draw.RoundedBox(10, 0, 0, InWidth, InHeight, Color(0, 0, 0, 100))

		self.lerp = Lerp(FrameTime() * 6, self.lerp, sum)

		draw.RoundedBox(10, 0, 0, self.lerp, InHeight, Color(255, 255, 255, 100))
	end

	timer.Create("HighLerp", .1, 0, function()

		if sum + plus < 300 then 

			sum = sum + plus

		else

			sum = 300

			timer.Simple( 0.2, function() HideTaskBar() end)

			timer.Remove("HighLerp")
		end
	end)
end

function HideTaskBar()

	if IsValid(TaskBarPanel) then

		TaskBarPanel:AlphaTo(0, 0.7, 0)

		timer.Simple(0.7, function() TaskBarPanel:Remove() TaskBarPanel = nil end)
	end
end

concommand.Add( 'debug_prbar', function() ShowProgressBar( 2 ) end ) -- Вместо 5 любое время в секундах