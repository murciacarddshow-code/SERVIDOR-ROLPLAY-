-- Mission Row Police Station Extended
-- Asegura la carga del interior y estado de Mission Row

local MISSION_ROW_COORDS = vector3(441.47, -982.74, 30.69)

CreateThread(function()
    RequestIpl("v_police_div")
    
    local interiorId = GetInteriorAtCoords(MISSION_ROW_COORDS.x, MISSION_ROW_COORDS.y, MISSION_ROW_COORDS.z)
    if interiorId and interiorId ~= 0 then
        PinInteriorInMemory(interiorId)
        RefreshInterior(interiorId)
    end
end)
