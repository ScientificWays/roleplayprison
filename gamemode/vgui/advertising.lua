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


local sw = ScrW()
local sh = ScrH()

local ws, hs = 400, 150

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

local function ShowAdvert( title, msg )

	local function closefr( panel )
		panel:SizeTo( 0, 0, 1.8, 0, 0.1 )
		timer.Simple( 0.7, function() panel:Remove() end )
	end

	local advert = vgui.Create( 'DFrame' )
	advert:SizeTo( ws, hs, 1.8, 0, 0.1 )
	advert:SetPos( 10, 20 )
	advert:SetTitle( '' )
	advert:SetDraggable( false )
	advert:ShowCloseButton( false )
	advert.Paint = function( self, w, h )
		DrawBlur( self, 3 )
		draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 0, 0, 0, 200 ), true, true, true, true )
		draw.SimpleText( title, 'title', 10, 12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.RoundedBoxEx( 0, 0, 25, w, 5, Color( 255, 255, 255 ), true, true, true, true )
	end

	local richtext = vgui.Create( 'RichText', advert )
	richtext:Dock( FILL )
	richtext:SetVerticalScrollbarEnabled( false )
	richtext:AppendText( msg )

	function richtext:PerformLayout()

		self:SetFontInternal( 'msg' )
		self:SetFGColor( Color( 255, 255, 255 ) )
		self:SetSize( ws, hs )
	
	end

	--[[ local closebtn = vgui.Create( 'DButton', advert )
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

		closefr( advert )

	end--]] 

	timer.Simple( 10, function() if advert:IsValid() then closefr( advert ) end end )


end

concommand.Add( 'debug_advert', function() ShowAdvert( 'Тайтл', '1. Пункт первый\n2. Пункт Второй' ) end )