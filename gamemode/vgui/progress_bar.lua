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

local ws, hs = 300, 20

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

local function ShowProgressBar( time )

	local plus = ws / time * 0.1
	local sum = 0

	local function closefr( panel )
		action:AlphaTo( 0, 0.7, 0 )
		timer.Simple( 0.7, function() panel:Remove() end )
	end

	action = vgui.Create( 'DPanel' )
	action:SetPos( sw/2-ws/2, sh/2-hs/2+20 )
	action:SetSize( ws, hs )
	action.lerp = 0
	action.Paint = function( self, w, h )
		draw.RoundedBox( 10, 0, 0, w, h, Color( 0, 0, 0, 100 ) )

		self.lerp = Lerp( FrameTime() * 6, self.lerp, sum )
		draw.RoundedBox( 10, 0, 0, self.lerp, h, Color( 255, 255, 255, 100 ) )
	end

	timer.Create( 'HighLerp', .1, 0, function()

		if sum + plus < 300 then 

			sum = sum + plus

		else

			sum = 300
			timer.Simple( 0.2, function() closefr( action ) end )
			timer.Remove( 'HighLerp' )

		end

	end)

end

concommand.Add( 'debug_prbar', function() ShowProgressBar( 2 ) end ) -- Вместо 5 любое время в секундах