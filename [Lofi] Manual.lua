local Lofi = {
    Left = gui.Keybox( gui.Reference( "Ragebot", "Anti-Aim", "Extra" ), "leftkey", "Left", 6 );
    Right = gui.Keybox( gui.Reference( "Ragebot", "Anti-Aim", "Extra" ), "rightkey", "Right", 5 );
    Color = gui.ColorPicker( gui.Reference( "Ragebot", "Anti-Aim", "Extra" ), "indicator", "Indicator Color", 131, 200, 60, 255 );
    Side = 0;
}

Lofi.Left:SetDescription("The button to change the anti-aim direction the the left")
Lofi.Right:SetDescription("The button to change the anti-aim direction the the right")

local PressedLeft = false
local PressedRight = false

function Draw()
    if Lofi.Left:GetValue() ~= 0 and input.IsButtonDown( Lofi.Left:GetValue() ) then
        if not PressedLeft then
            PressedLeft = true
            if Lofi.Side == 1 then
                Lofi.Side = 0;
            else
                Lofi.Side = 1;
            end
        end
    end
    if PressedLeft and not input.IsButtonDown( Lofi.Left:GetValue() ) then
        PressedLeft = false
    end

    if Lofi.Right:GetValue() ~= 0 and input.IsButtonDown( Lofi.Right:GetValue() ) then
        if not PressedRight then
            PressedRight = true
            if Lofi.Side == 2 then
                Lofi.Side = 0;
            else
                Lofi.Side = 2;
            end
        end
    end
    if PressedRight and not input.IsButtonDown( Lofi.Right:GetValue() ) then
        PressedRight = false
    end
    gui.SetValue( "rbot.antiaim.yaw", Lofi.Side == 0 and 180 or Lofi.Side == 2 and -180 + 90 or 180 - 90 )
    
    local ScrW, ScrH = draw.GetScreenSize()
    local CenterX, CenterY = ScrW / 2, ScrH / 2

    local R, G, B = Lofi.Color:GetValue()

    draw.Color( R, G, B, Lofi.Side == 2 and 255 or 50 )
    draw.Triangle( CenterX + 50 + 10, CenterY, CenterX + 50, CenterY + 5, CenterX + 50, CenterY - 5 ) --// Right

    draw.Color( R, G, B, Lofi.Side == 1 and 255 or 50 )
    draw.Triangle( CenterX - 50 - 15, CenterY, CenterX - 50, CenterY - 7, CenterX - 50, CenterY + 7 ) --// Left
end
callbacks.Register( "Draw", Draw )