local Lofi = {
    DotColors = {
        -- ... = {Red, Green, Blue, Alpha (transparency)}
        Open = {0, 0, 0, 50},
        Overlapping = {255, 0, 127, 255}
    }
}

local LocalPlayer = function() 
    local Player = entities.GetLocalPlayer()
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

function Lofi:GetOrigin()
    if not LocalPlayer() then return end
    local Origin = LocalPlayer():GetAbsOrigin()
    local Offset = LocalPlayer():GetPropVector( "localdata", "m_vecViewOffset[0]" ); Offset.x, Offset.y = 0, 0 -- uh only z needed pls
    return Origin + Offset
end

function Lofi:IsOverlapping(Destination)
    local Origin = Lofi:GetOrigin()
    local Trace = engine.TraceLine( Origin, Destination )
    local Distance = ( Origin - Destination ):Length() * Trace.fraction
    if Distance ~= ( Origin - Destination ):Length() then
        return true
    end
    return false
end

function Lofi:GetPoints(Size, Length, Offset)
    local Points = {}
    for Angle=1, 90, (90)/Size do
        local RelativeAngle = engine.GetViewAngles().y + Angle + Offset
        local AngleRadians = math.rad(RelativeAngle)
        local VectorX = math.cos(AngleRadians) * Length
        local VectorY = math.sin(AngleRadians) * Length
        table.insert( Points, Lofi:GetOrigin() + Vector3( VectorX, VectorY, 0 ) )
    end
    return Points
end

function Lofi:CalcAngle(Vector)
    local Origin = LocalPlayer():GetAbsOrigin()
    local DeltaX, DeltaY = Origin.x - Vector.x, Origin.y - Vector.y

    RelativeYaw = math.atan( DeltaY / DeltaX )
    RelativeYaw = Lofi:Normalize( RelativeYaw * 180 / math.pi )
    if DeltaX >= 0 then
        RelativeYaw = Lofi:Normalize( RelativeYaw + 180 )
    end
    return RelativeYaw
end

function Lofi:GetBaseFromVector(Vector)
    local AtPoint = Lofi:CalcAngle( Vector )
    local Yaw = Lofi:Normalize( AtPoint - engine.GetViewAngles().y )
    return Yaw
end

function Lofi:GetOptimalPoint(Points)
    local Forward = engine.GetViewAngles():Forward()
    local Distance = 0
    local Furthest;
    for _, Point in next, Points do
        local Dist = (Lofi:GetOrigin() + Vector3(Forward.x*150, Forward.y*150, 0) - Point):Length()
        if Dist > Distance then
            Furthest = Point
            Distance = Dist
        end
    end
    return Furthest
end

callbacks.Register("Draw", function()

    --[[----------------------
        Point Handling
    ------------------------]]
    local LeftPoints = Lofi:GetPoints( 60, 35, 5 )
    local LeftOverlapping = {}
    for _, Point in next, LeftPoints do
        if Lofi:IsOverlapping( Point ) then
            local x, y = client.WorldToScreen( Point )
            draw.Color( unpack( Lofi.DotColors.Overlapping ) )
            draw.FilledCircle(x, y, 5)
            table.insert( LeftOverlapping, Point )
        else
            local x, y = client.WorldToScreen( Point )
            draw.Color( unpack( Lofi.DotColors.Open ) )
            draw.FilledCircle(x, y, 5)
        end
    end
    
    local RightPoints = Lofi:GetPoints( 60, 35, -95 )
    local RightOverlapping = {}
    for _, Point in next, RightPoints do
        if Lofi:IsOverlapping( Point ) then
            local x, y = client.WorldToScreen( Point )
            draw.Color( unpack( Lofi.DotColors.Overlapping ) )
            draw.FilledCircle(x, y, 5)
            table.insert( RightOverlapping, Point )
        else
            local x, y = client.WorldToScreen( Point )
            draw.Color( unpack( Lofi.DotColors.Open ) )
            draw.FilledCircle(x, y, 5)
        end
    end

    --[[----------------------
        Anti-Aim Handling
    ------------------------]]
    local Overlapping;
    if #RightOverlapping < #LeftOverlapping then
        Overlapping = LeftOverlapping
        gui.SetValue( "rbot.antiaim.base.rotation", -58 )
        gui.SetValue( "rbot.antiaim.base.lby", 58 )
    else
        Overlapping = RightOverlapping
        gui.SetValue( "rbot.antiaim.base.rotation", 58 )
        gui.SetValue( "rbot.antiaim.base.lby", -58 )
    end
    local Optimal = Lofi:GetOptimalPoint(Overlapping)
    if Optimal and #Overlapping > 0 then
        gui.SetValue( "rbot.antiaim.base", Lofi:GetBaseFromVector(Optimal), Lofi:GetBaseFromVector(Optimal) )
    else
        gui.SetValue( "rbot.antiaim.base", 180, 180 )
    end

end)