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

surface.CreateFont( 'txt', {
	font = 'Tahoma',
	extended = true,
	weight = 500,
	size = 17,
} )

local subteams = {

	[ 0 ] = {
		'Гл. Охранник',
		'Охранник'
	}

}

local blockedteams = {
	[ 'Joining/Connecting' ] = true,
	[ 'Unassigned' ] = true
}


local sw = ScrW()
local sh = ScrH()

local chosen_team = 'nil'
local chosen_steam = 'nil'

local ws, hs = 250, 300
local ws2, hs2 = 200, 200

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

local function ShowCTeam()

	local function closefr( panel )
		panel:SizeTo( 0, 0, 1.8, 0, 0.1 )
		timer.Simple( 0.7, function() panel:Remove() end )
	end

	local isanim = true

	local cteam = vgui.Create( 'DFrame' )
	cteam:SizeTo( ws, hs, 1.5, 0, 0.1 )
	cteam:SetPos( 10, sh/2-hs/2 )
	cteam:SetTitle( '' )
	cteam:SetDraggable( false )
	cteam:ShowCloseButton( false )
	cteam:MakePopup()
	cteam.Paint = function( self, w, h )
		DrawBlur( self, 3 )
		draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 0, 0, 0, 200 ), true, false, true, false )
		draw.SimpleText( 'Выбрать роль', 'title', ws/2, 12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.RoundedBoxEx( 0, 0, 20, w, 5, Color( 255, 255, 255 ), true, true, true, true )
	end

	local spanel = vgui.Create( 'DScrollPanel', cteam )
	spanel:Dock( FILL )

	local ScrollBar = spanel:GetVBar()
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

	for i,v in ipairs( table.GetKeys( team.GetAllTeams() ) ) do 

		if not blockedteams[ team.GetName( v ) ] then 

			local teambtn = spanel:Add( 'DButton' )
			teambtn:SetSize( 10, 50 )
			teambtn:Dock( TOP )
			teambtn:DockMargin( 0, 5, 0, 5 )
			teambtn:SetText( '' )
			teambtn.lerp = 0
			teambtn.Paint = function( self, w, h )

				draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 30, 30, 30, 200 ), true, true, true, true )

				if self:IsHovered() then
					self.lerp = Lerp( FrameTime() * 6, self.lerp, 10 )
					draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 116, 0, 255, 255 ), true, false, true, false )
				else
					self.lerp = Lerp( FrameTime() * 6, self.lerp, 0 )
					draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 116, 0, 255, 255 ), true, false, true, false )
				end

				draw.SimpleText( team.GetName( v ), 'txt', ws/2, 25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			end

			teambtn.DoClick = function()
				chosen_team = v

				if subteams[v] then
					
					csteam = vgui.Create( 'DFrame' )
					csteam:SetPos( 10 + ws, sh/2-hs/2 )
					csteam:SetSize( 0, 0 )
					csteam:SizeTo( ws2, hs2, 1.5, 0, 0.1 )
					csteam:SetTitle( '' )
					csteam:SetDraggable( false )
					csteam:ShowCloseButton( true )
					csteam.Paint = function( self, w, h )
						DrawBlur( self, 3 )
						draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 0, 0, 0, 200 ), false, true, false, true )
						--draw.SimpleText( 'Выбрать роль', 'title', ws2/2, 12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						draw.RoundedBoxEx( 0, 0, 20, w, 5, Color( 255, 255, 255 ), true, true, true, true )
					end

					local sspanel = vgui.Create( 'DScrollPanel', csteam )
					sspanel:Dock( FILL )

					local ScrollBar = sspanel:GetVBar()
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

					for i,v in pairs( subteams[v] ) do

						local teambtn = sspanel:Add( 'DButton' )
						teambtn:SetSize( ws2, 50 )
						teambtn:Dock( TOP )
						teambtn:DockMargin( 0, 5, 0, 5 )
						teambtn:SetText( '' )
						teambtn.lerp = 0
						teambtn.Paint = function( self, w, h )

							draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 30, 30, 30, 200 ), true, true, true, true )

							if self:IsHovered() then
								self.lerp = Lerp( FrameTime() * 6, self.lerp, 10 )
								draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 116, 0, 255, 255 ), true, false, true, false )
							else
								self.lerp = Lerp( FrameTime() * 6, self.lerp, 0 )
								draw.RoundedBoxEx( 10, 0, 0, self.lerp, h, Color( 116, 0, 255, 255 ), true, false, true, false )
							end

							draw.SimpleText( v, 'txt', ws2/2, 25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						
						end

						teambtn.DoClick = function()

							chosen_steam = v
							closefr( cteam )
							closefr( csteam )

						end

					end

				else 

					closefr( cteam )
					if csteam:IsValid() then
						closefr( csteam )
					end

				end
			end

		end

	end

end

concommand.Add( 'debug_cteam', function() ShowCTeam() end )