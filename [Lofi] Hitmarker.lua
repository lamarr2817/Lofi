local Lofi = {
    Time = 0.4,
    LastHit = globals.CurTime()
}

function Lofi.OnDraw()
    if globals.CurTime() < Lofi.LastHit then
        local CenterX, CenterY = draw.GetScreenSize()
        CenterX = CenterX / 2
        CenterY = CenterY / 2
        
        draw.Color( 255, 255, 255, 255 - (255 / Lofi.Time) * (globals.CurTime() - Lofi.LastHit) )

        --// Top
        draw.Line( CenterX - 5, CenterY - 5, CenterX - 10, CenterY - 10 )
        draw.Line( CenterX + 5, CenterY - 5, CenterX + 10, CenterY - 10 )

        --// Bottom
        draw.Line( CenterX - 5, CenterY + 5, CenterX - 10, CenterY + 10 )
        draw.Line( CenterX + 5, CenterY + 5, CenterX + 10, CenterY + 10 )
    end
end

function Lofi.OnEvent(e)
    if e:GetName() == "player_hurt" then
        local Attacker = client.GetPlayerIndexByUserID( e:GetString('attacker') )
        local Me = client.GetLocalPlayerIndex()
        if Attacker == Me then
            Lofi.LastHit = globals.CurTime() + Lofi.Time
        end
    end
end

client.AllowListener( "player_hurt" )
callbacks.Register( "Draw", Lofi.OnDraw )
callbacks.Register( "FireGameEvent", Lofi.OnEvent )