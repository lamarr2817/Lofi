local QuickPeek = {
    Colors = {
        cEnabled = {
            124,
            176,
            34
        },
        cInUse = {
            253,
            165,
            15
        },
        cDisabled = {
            237,
            41,
            57
        }
    },
    gKeybind = gui.Keybox( gui.Reference( "Ragebot", "Accuracy", "Movement" ), "quickpeek.keybind", "Quick Peek", 18 ),
    gKeyHeld = false,
    bShouldFallback = false,
    vOrigin = Vector3(0, 0, 0),
    bIsQuickStopping = false
}

function draw.BubbleThing(Origin)
    local LastAngle;
    for Angle=0, 360 do
        Angle = math.rad(Angle)
        local X = math.cos(Angle) * 3
        local Y = math.sin(Angle) * 3
        local Offset = Vector3(X, Y, 0)
        if LastAngle then
            local x1, y1 = client.WorldToScreen( Offset + Origin )
            local x2, y2 = client.WorldToScreen( LastAngle )
            local x3, y3 = client.WorldToScreen( entities.GetLocalPlayer():GetAbsOrigin() )
            if x1 and x2 and x1 and y1 and y2 and y3 then
                draw.Triangle( x1, y1, x2, y2, x3, y3 )
            end
        end
        LastAngle = Offset + Origin
    end
end

function math.clamp(x, a, b)
    return x<a and a or x>b and b or x
end

function QuickPeek.Indicator()
    if not entities.GetLocalPlayer():IsAlive() then return end
    local x, y = draw.GetScreenSize()
    local bKeyDown = input.IsButtonDown( QuickPeek.gKeybind:GetValue() )
    local color
    if QuickPeek.bShouldFallback and not bKeyDown then
        QuickPeek.bShouldFallback = false
        QuickPeek.gKeyHeld = false
        QuickPeek.bIsQuickStopping = false
        return
    end
    if bKeyDown and not QuickPeek.bShouldFallback then
        color = QuickPeek.Colors.cEnabled
    elseif QuickPeek.bShouldFallback then
        color = QuickPeek.Colors.cInUse
    else
        color = QuickPeek.Colors.cDisabled
    end
    draw.Color( 42, 42, 42, 150 )
    draw.Color( color[1], color[2], color[3], 255 )
    draw.BubbleThing(QuickPeek.vOrigin)
end

function QuickPeek.QuickStop(cmd)
    cmd.forwardmove = 0
    cmd.sidemove = 0

    local VelocityProp = entities.GetLocalPlayer():GetPropVector("localdata", "m_vecVelocity[0]")
    local Velocity = VelocityProp:Length2D()
    
    local Direction = VelocityProp:Angles()
    Direction.y = engine.GetViewAngles().y - Direction.y

    local Forward = Direction:Forward()
    local Negated = -Direction
    local Factor = math.max(Negated.x, Negated.y) / 450
    Negated = Negated * Factor

    cmd.forwardmove = Negated.x
    cmd.sidemove = Negated.y
end

function QuickPeek.Movement(cmd)
    local bKeyDown = input.IsButtonDown( QuickPeek.gKeybind:GetValue() )
    if QuickPeek.bShouldFallback then
        if QuickPeek.bIsQuickStopping then
            local VelocityProp = entities.GetLocalPlayer():GetPropVector("localdata", "m_vecVelocity[0]")
            local Velocity = math.sqrt( VelocityProp.x^2, VelocityProp.y^2 )
            if Velocity < 1 then
                QuickPeek.bIsQuickStopping = false
            end
            QuickPeek.QuickStop(cmd)
            if Velocity < 20 then
                QuickPeek.bIsQuickStopping = false
            end
        else
            local Angle = (QuickPeek.vOrigin - entities.GetLocalPlayer():GetAbsOrigin()):Angles()
            cmd.forwardmove = math.cos(math.rad((engine:GetViewAngles() - Angle).y)) * 250
            cmd.sidemove = math.sin(math.rad((engine:GetViewAngles() - Angle).y)) * 250
            if (QuickPeek.vOrigin - entities.GetLocalPlayer():GetAbsOrigin()):Length() < 5 then
                QuickPeek.bShouldFallback = false
            end
        end
    end
    if ( not QuickPeek.gKeyHeld and input.IsButtonDown( QuickPeek.gKeybind:GetValue() ) ) or not input.IsButtonDown( QuickPeek.gKeybind:GetValue() ) then
        QuickPeek.vOrigin = entities.GetLocalPlayer():GetAbsOrigin()
        QuickPeek.gKeyHeld = true
        return
    end
end

function QuickPeek.Events(event)
    if event:GetName() == "bullet_impact" then
        if entities.GetLocalPlayer():GetIndex() == entities.GetByUserID( event:GetInt("userid") ):GetIndex() then
            if QuickPeek.bShouldFallback then
                QuickPeek.bShouldFallback = true
            else
                QuickPeek.bShouldFallback = true
                QuickPeek.bIsQuickStopping = true
            end
        end
    end
end

callbacks.Register("Draw", QuickPeek.Indicator)
callbacks.Register("CreateMove", QuickPeek.Movement)
callbacks.Register("FireGameEvent", QuickPeek.Events)
