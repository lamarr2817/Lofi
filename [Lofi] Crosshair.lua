local Lofi = {
    Radius = 20,
    PrimaryColor = {255, 148, 0, 255},
    SecondaryColor = {42, 42, 42, 255},
    LastShot = 0,
    Font = draw.CreateFont( "Arial", 17, 570 ),
    Offset = 15
}

local LocalPlayer = function() 
    local Player = entities.GetLocalPlayer()
    if not Player then
        return;
    end
    if Player:IsAlive() then
        return Player
    end
    return Player:GetPropEntity("m_hObserverTarget")
end -- Don't really feel like calling the whole function everytime smh

function Lofi:Normalize(Yaw)
    while Yaw > 180 do
        Yaw = Yaw - 360
    end
    while Yaw < -180 do
        Yaw = Yaw + 360
    end
    return Yaw
end

function Lofi:DrawCircle2D(x, y, radius, start, angle)
    local OldAngle = math.rad(start + 270);
    for NewAngle = start + 270, start + angle + 270 do
        NewAngle = math.rad(NewAngle) --// Degrees to radians
        local OffsetX, OffsetY = math.cos(NewAngle) * radius, math.sin(NewAngle) * radius
        local OldOffsetX, OldOffsetY = math.cos(OldAngle) * radius, math.sin(OldAngle) * radius
        draw.Line( x + OldOffsetX, y + OldOffsetY, x + OffsetX, y + OffsetY )
        OldAngle = NewAngle --// Needed for next line
    end
end

function Lofi:DrawIndicator(x, y, string, outline, enabled)
    local _x = draw.GetTextSize( string )
    _x = _x / 2
    y = y + Lofi.Offset
    if outline then
        draw.Color( 0, 0, 0, 255 )
        draw.Text( x - _x - 1, y + 1, string )
    end
    if enabled then
        draw.Color( unpack( Lofi.PrimaryColor ) )
    else
        draw.Color( unpack( Lofi.SecondaryColor ) )
    end
    draw.Text( x - _x, y, string )
    Lofi.Offset = Lofi.Offset + 15
end

function Lofi:OnDraw()

    if not LocalPlayer() or not LocalPlayer():GetProp("m_angEyeAngles") then return end

    Lofi.Offset = 15

    local ScrW, ScrH = draw.GetScreenSize()
    local AtTargets;
    draw.SetFont( Lofi.Font )

    pcall(function()
        AtTargets = gui.GetValue( "rbot.antiaim.advanced.at_targets" )
    end)

    for i=1, 5 do

        draw.Color(0, 0, 0, 100)
        Lofi:DrawCircle2D(ScrW / 2, ScrH / 2, Lofi.Radius + i, 0, 360)
        
        if LocalPlayer() then
            local FakeAngle = Lofi:Normalize(engine.GetViewAngles().y - LocalPlayer():GetProp("m_angEyeAngles").y)
            draw.Color( unpack(Lofi.PrimaryColor) )
            Lofi:DrawCircle2D(ScrW / 2, ScrH / 2, Lofi.Radius + i, FakeAngle - 15, 30)
        end

    end

    Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius, "ON-SHOT", true, globals.CurTime() - Lofi.LastShot < 0.1 )
    Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius, "DOUBLE TAP", true, gui.GetValue( "rbot.accuracy.weapon.asniper.doublefire" ) > 0 )
    Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius, "AT TARGETS", true, AtTargets ~= nil and AtTargets == true )

end

function Lofi.OnEvent(e)
    if e:GetName() == "weapon_fire" then
        if client.GetPlayerNameByUserID( e:GetInt("userid") ) == LocalPlayer():GetName() then
            Lofi.LastShot = globals.CurTime()
        end
    end
end

client.AllowListener( "weapon_fire" )
callbacks.Register( "Draw", Lofi.OnDraw )
callbacks.Register( "FireGameEvent", Lofi.OnEvent )
