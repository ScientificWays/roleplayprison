surface.CreateFont( 'closebtn', {
	font = 'Tahoma',
	extended = true,
	weight = 500,
	size = 20,
} )

surface.CreateFont( 'title', {
	font = 'Tahoma',
	extended = true,
	weight = 600,
	size = 15,
} )

surface.CreateFont( 'msg', {
	font = 'Tahoma',
	extended = true,
	weight = 500,
	size = 17,
} )

local emotes = {
	'agree',
	'becon',
	'bow',
	'cheer',
	'dance',
	'disagree',
	'forward',
	'group',
	'halt',
	'laugh',
	'muscle',
	'pers',
	'robot',
	'salute',
	'wave',
	'zombie'
}

local emotes = {
	[ 'agree' ] = 'Согласиться',
	[ 'becon' ] = 'Подозвать',
	[ 'bow' ] = 'Поклониться',
	[ 'cheer' ] = 'Радоваться',
	[ 'dance' ] = 'Танцевать',
	[ 'disagree' ] = 'Отказаться',
	[ 'forward' ] = 'Двигаемся',
	[ 'group' ] = 'Группироваться',
	[ 'halt' ] = 'Остановиться',
	[ 'laugh' ] = 'Смеяться',
	[ 'muscle' ] = 'Красоваться',
	[ 'pers' ] = 'Я не придумал название',
	[ 'robot' ] = 'Танец робота',
	[ 'salute' ] = 'Тут тоже не придумал название',
	[ 'wave' ] = 'Помахать',
	[ 'zombie' ] = 'Крик зомби'
}

local sw = ScrW()
local sh = ScrH()

local ws, hs = 300, 400

local close_menu = false

local blur = Material("pp/blurscreen")

local function DrawBlur( panel, amount )

	local x, y = panel:LocalToScreen( 0, 0 )
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat("$blur", ( i / 3 ) * ( amount or 6 ) )
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( x * -1, y * -1, sw, sh )
	end

end

local function DoEmote( emote )
	RunConsoleCommand( 'act', emote )
end

local function ShowAnimations( title, msg )

	local function closefr( panel )
		panel:AlphaTo( 0, 0.4, 0 )
		timer.Simple( 0.4, function() panel:Remove() end )
	end

	local anim = vgui.Create( 'DFrame' )
	anim:SetSize( ws, hs )
	anim:SetPos( 10, sh/2-hs/2 )
	anim:SetTitle( '' )
	anim:SetAlpha( 0 )
	anim:AlphaTo( 255, 0.4, 0 )
	anim:SetDraggable( false )
	anim:ShowCloseButton( false )
	anim.Paint = function( self, w, h )
		DrawBlur( self, 3 )
		draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 0, 0, 0, 200 ), true, true, true, true )
		draw.SimpleText( 'Список анимаций', 'title', ws/2, 12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.RoundedBoxEx( 0, 0, 25, w, 5, Color( 255, 255, 255 ), true, true, true, true )
	end

	local apanel = vgui.Create( 'DScrollPanel', anim )
	apanel:Dock( FILL )

	local ScrollBar = apanel:GetVBar()
		ScrollBar.Paint = function()
	end

	function ScrollBar.btnUp:Paint(h,i)
		draw.RoundedBox( 0, 0, 0, h, i, Color( 0, 0, 0, 200 ) )
	end
		
	function ScrollBar.btnDown:Paint(h,i)
		draw.RoundedBox( 0, 0, 0, h, i, Color( 0, 0, 0, 200 ) )
	end

	function ScrollBar.btnGrip:Paint(h,i)
		draw.RoundedBox( 0, 0, 0, h, i, Color( 0, 0, 0, 200 ) )
	end

	for i,v in ipairs( table.GetKeys( emotes ) ) do

		local animbtn = apanel:Add( 'DButton' )
		animbtn:SetSize( ws, 50 )
		animbtn:Dock( TOP )
		animbtn:DockMargin( 5, 5, 0, 5 )
		animbtn:SetText( '' )
		animbtn.lerp = 0
		animbtn.Paint = function( self, w, h )

			draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 30, 30, 30, 200 ), true, false, true, false )

			if self:IsHovered() then
				self.lerp = Lerp( FrameTime() * 6, self.lerp, 10 )
				draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 116, 0, 255, 255 ), true, false, true, false )
			else
				self.lerp = Lerp( FrameTime() * 6, self.lerp, 0 )
				draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 116, 0, 255, 255 ), true, false, true, false )
			end

			draw.SimpleText( emotes[v], 'txt', ws/2, 25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

		animbtn.DoClick = function()

			if close_menu then
				DoEmote( v )
				closefr( anim )
			else
				DoEmote( v )
			end

		end

	end

	local closebtn = vgui.Create( 'DButton', anim )
	closebtn:SetSize( 25, 25 )
	closebtn:SetPos( ws - 25, 0 )
	closebtn:SetText( '' )
	closebtn.lerp = 0
	closebtn.Paint = function( self, w, h )

		if self:IsHovered() then
			self.lerp = Lerp( FrameTime() * 6, self.lerp, w )
			draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 220, 20, 60 ), false, true, false, false )
		else
			self.lerp = Lerp( FrameTime() * 6, self.lerp, 0 )
			draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 220, 20, 60 ), false, true, false, false )
		end

		draw.SimpleText( 'X', 'closebtn', 12, 12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

	closebtn.DoClick = function()

		closefr( anim )

	end

end

net.Receive( 'OpenAnimationsMenu', function() ShowAnimations() end)

concommand.Add( 'anim_closemenu', function( ply, cmd, argStr )

	if argStr[1] == '0' then

		close_menu = false

	elseif argStr[1] == '1' then

		close_menu = true

	end

end)

concommand.Add( 'debug_anim', function() ShowAnimations() end )