--[[
    Lofi
        Table containing all variables used
--]]
local Lofi = {
    BASE_SIZE = 20,
    FONT = draw.CreateFont( "Verdana", 24, 400 ),
    FONT_B = draw.CreateFont( "Verdana", 12, 400 ),
    OFFSET_Y = -35
}

--[[
    Lofi:Draw
        Draws the indicator at [int x] and [int y]
--]]
function Lofi:Draw(x, y, str)
    -- Circle
    draw.Color( 26, 26, 26, 255 )
    draw.FilledCircle(x, y, Lofi.BASE_SIZE)

    -- Outline
    draw.Color( 62, 62, 62, 255 )
    draw.OutlinedCircle(x, y, Lofi.BASE_SIZE)

    -- !
    draw.SetFont( draw.CreateFont( "Verdana", Lofi.BASE_SIZE, 400 ) )
    draw.Color( 255, 223, 0, 255 )
    draw.Text( x-Lofi.BASE_SIZE/8, y-Lofi.BASE_SIZE/5*3, "!" )

    -- ft
    draw.SetFont( draw.CreateFont( "Verdana", Lofi.BASE_SIZE/2, 400 ) )
    draw.Color( 255, 255, 255, 255 )
    draw.Text( x-Lofi.BASE_SIZE/2, y+Lofi.BASE_SIZE/10, string.format("%s ft", str) )
end

--[[
    Draw Callback
        Actually handling the drawing    
--]]
callbacks.Register("Draw", function()
    for _, Player in next, entities.FindByClass( "CCSPlayer" ) do
        if Player:GetTeamNumber() ~= entities.GetLocalPlayer():GetTeamNumber() then 
            if Player:GetWeaponID() == 31 then
                local X, Y = client.WorldToScreen( Player:GetHitboxPosition("Head") )
                if X and Y then
                    Lofi:Draw( X, Y + Lofi.OFFSET_Y, math.floor(( Player:GetAbsOrigin() - entities.GetLocalPlayer():GetAbsOrigin() ):Length()/10) )
                end
            end
        end
    end
end)