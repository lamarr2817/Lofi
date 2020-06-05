local Lofi = {
    Radius = 20,
    PrimaryColor = {255, 148, 0, 255},
    SecondaryColor = {42, 42, 42, 255},
    LastShot = 0,
    Font = draw.CreateFont( "Arial", 17, 570 )
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

local function ToNumber(str) -- stupid
    local l = 1
    for i=1, #str do
        local t = str:sub(i, i)
        if t == nil then
            l = i
            break
        end
    end
    return tonumber(str:sub(1, l))
end

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

function Lofi:DrawIndicator(x, y, string, col, outline)

    local _x = draw.GetTextSize( string )
    _x = _x / 2

    if outline then
        draw.Color( 0, 0, 0, 255 )
        draw.Text( x - _x - 1, y + 1, string )
    end

    draw.Color( unpack( col ) )
    draw.Text( x - _x, y, string )

end

function Lofi:OnDraw()

    if not LocalPlayer():GetProp("m_angEyeAngles") then return end

    local ScrW, ScrH = draw.GetScreenSize()
    draw.SetFont( Lofi.Font )

    for i=1, 5 do

        draw.Color(0, 0, 0, 100)
        Lofi:DrawCircle2D(ScrW / 2, ScrH / 2, Lofi.Radius + i, 0, 360)
        
        if LocalPlayer() then
            local RealAngle = Lofi:Normalize(engine.GetViewAngles().y - LocalPlayer():GetProp("m_angEyeAngles").y)
            draw.Color( unpack(Lofi.PrimaryColor) )
            Lofi:DrawCircle2D(ScrW / 2, ScrH / 2, Lofi.Radius + i, RealAngle - 15, 30)
        end

    end

    if globals.CurTime() - Lofi.LastShot < 0.1 then
        Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius + 15, "ON-SHOT", Lofi.PrimaryColor, true )
    else
        Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius + 15, "ON-SHOT", Lofi.SecondaryColor, true )
    end

    if gui.GetValue( "rbot.accuracy.weapon.asniper.doublefire" ) > 1 then
        Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius + 15 + 15, "DOUBLE TAP", Lofi.PrimaryColor, true )
    else
        Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius + 15 + 15, "DOUBLE TAP", Lofi.SecondaryColor, true )
    end

    local AtTargets;
    pcall(function()
        AtTargets = gui.GetValue( "rbot.antiaim.advanced.at_targets" )
    end)

    if AtTargets then
        Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius + 15 + 30, "AT TARGETS", Lofi.PrimaryColor, true )
    elseif AtTargets == false then
        Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius + 15 + 30, "AT TARGETS", Lofi.SecondaryColor, true )
    elseif AtTargets == nil then
        local Alpha = globals.TickCount() % 50
        if Alpha > 25 then
            Alpha = math.abs(50 - Alpha)
        end
        Alpha = Alpha * 3
        Lofi:DrawIndicator( ScrW / 2, ScrH / 2 + Lofi.Radius + 15 + 30, "AT TARGETS", {0, 0, 0, Alpha}, false )
    end

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