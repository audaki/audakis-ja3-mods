if CurrentModOptions['auda_TravelSpeedFix_FastMode'] == 'Yes' or CurrentModOptions['auda_TravelSpeedFix_FastMode'] == '' then
    CurrentModOptions['auda_TravelSpeedFix_FastMode'] = 'Normal'
elseif CurrentModOptions['auda_TravelSpeedFix_FastMode'] == 'No' then
    CurrentModOptions['auda_TravelSpeedFix_FastMode'] = 'Hard'
end

function GetSectorTravelTime(from_sector_id, to_sector_id, route, units, pass_mode, squad_curr_sector, side, dir)
    local shortcut
    if to_sector_id and not AreAdjacentSectors(from_sector_id, to_sector_id) then
        shortcut = GetShortcutByStartEnd(from_sector_id, to_sector_id)
    end
    if not shortcut and to_sector_id and SectorTravelBlocked(from_sector_id, to_sector_id, route, pass_mode, squad_curr_sector, dir) then
        return false
    end
    if route and route.diamond_briefcase then
        local time = const.Satellite.SectorTravelTimeDiamonds
        time = DivCeil(time, const.Scale.min) * const.Scale.min
        return time * 2, time, time, {}
    end
    local from_sector = gv_Sectors[from_sector_id]
    local to_sector = to_sector_id and gv_Sectors[to_sector_id]
    if to_sector then
        local same_city = from_sector.City == to_sector.City and from_sector.City ~= "none"
        if same_city or from_sector.GroundSector == to_sector_id or to_sector.GroundSector == from_sector_id then
            return 0
        end
        if (side == "enemy1" or side == "diamonds") and to_sector.ImpassableForEnemies then
            return false
        end
        if side == "diamonds" and to_sector.ImpassableForDiamonds then
            return false
        end
    end
    local breakdown = {}
    local terrain_type1 = gv_Sectors[from_sector_id].TerrainType
    local terrain_type2 = to_sector_id and gv_Sectors[to_sector_id].TerrainType
    if gv_Sectors[from_sector_id] and gv_Sectors[from_sector_id].Passability == "Water" then
        terrain_type1 = "Water"
    end
    if gv_Sectors[to_sector_id] and gv_Sectors[to_sector_id].Passability == "Water" then
        terrain_type2 = "Water"
    end
    local travel_time_modifier1 = SectorTerrainTypes[terrain_type1] and SectorTerrainTypes[terrain_type1].TravelMod or 100
    local travel_time_modifier2 = to_sector_id and SectorTerrainTypes[terrain_type2] and SectorTerrainTypes[terrain_type2].TravelMod or travel_time_modifier1
    local hasRoad = false
    if to_sector_id and HasRoad(from_sector_id, to_sector_id) then
        travel_time_modifier1 = const.Satellite.RoadTravelTimeMod
        travel_time_modifier2 = const.Satellite.RoadTravelTimeMod
        hasRoad = true
    end
    local mod = travel_time_modifier2
    if mod ~= 0 and terrain_type1 ~= "Water" and terrain_type2 ~= "Water" and not shortcut then
        if hasRoad then
            breakdown[#breakdown + 1] = {
                Text = T(414143808849, "<em>(Road)</em>"),
                Value = 100 - mod,
                Category = "sector-special"
            }
        end
        local difficultyText = false
        if mod == 100 then
            difficultyText = T(714191851131, "Normal")
        elseif mod <= 25 then
            difficultyText = T(367857875968, "Very Easy")
        elseif mod <= 75 then
            difficultyText = T(825299951074, "Easy")
        elseif 150 <= mod then
            difficultyText = T(625725601692, "Very Hard")
        elseif 120 <= mod then
            difficultyText = T(835764015096, "Hard")
        end
        breakdown[#breakdown + 1] = {
            Text = T(379323289276, "Terrain"),
            Value = difficultyText,
            ValueType = "text",
            Category = "sector"
        }
    end
    local speed_change = 0
    local is_player = side and (side == "player1" or side == "player2")
    local max_leadership, max_leadership_merc = 0, false
    for i, u in ipairs(units or empty_table) do
        local unit_data = gv_UnitData[u]
        if is_player and max_leadership < unit_data.Leadership then
            max_leadership = unit_data.Leadership
            max_leadership_merc = unit_data.session_id
        end
    end
    local squadModifier = is_player and 100 - (const.Satellite.SectorTravelTimeBase - max_leadership) or 0

    local orig_squadModifier = squadModifier

    local tsf_mode = CurrentModOptions['auda_TravelSpeedFix_FastMode']
    if tsf_mode == 'Fast' then
        squadModifier = squadModifier + 50
        squadModifier = MulDivRound(squadModifier, 240, 100)
    elseif tsf_mode == 'Normal' then
        squadModifier = squadModifier + 50
    end

    local show_original_mod = CurrentModOptions['auda_TravelSpeedFix_ShowOrigModifier'] == 'Yes'

    breakdown[#breakdown + 1] = {
        Text = T(703764048855, "Squad Speed"),
        Value = show_original_mod and orig_squadModifier or squadModifier,
        Category = "squad",
        rollover = T({
            898857286023,
            "The squad speed is defined by the merc with the highest Leadership in the squad.<newline><mercName><right><stat>",
            mercName = max_leadership_merc and UnitDataDefs[max_leadership_merc] and UnitDataDefs[max_leadership_merc].Nick or Untranslated("???"),
            stat = max_leadership
        })
    }
    local sector_travel_time = side and side ~= "player1" and side ~= "player2" and const.Satellite.SectorTravelTimeEnemy or const.Satellite.SectorTravelTime

    if squadModifier ~= 0 then
        sector_travel_time = MulDivRound(sector_travel_time, 100, 100 + squadModifier)
    end

    local travel_time_1 = sector_travel_time * travel_time_modifier1 / 100
    local travel_time_2 = sector_travel_time * travel_time_modifier2 / 100
    if to_sector_id == from_sector_id and 0 < #(units or "") then
        local ud = gv_UnitData[units[1]]
        local squad = ud and ud.Squad
        squad = squad and gv_Squads[squad]
        if squad then
            local squadPos = GetSquadVisualPos(squad)
            local retreatSector = from_sector.XMapPosition
            local from = GetSquadPrevSector(squadPos, from_sector_id, retreatSector)
            from = from and gv_Sectors[from].XMapPosition
            local diff = retreatSector - from
            local passed = squadPos - from
            local passedDDiff = Dot(passed, diff)
            local percentPassed = passedDDiff ~= 0 and MulDivRound(passedDDiff, 1000, Dot(diff, diff)) or 0
            travel_time_1 = MulDivRound(travel_time_1, percentPassed, 1000)
            travel_time_2 = 0
        end
    elseif shortcut then
        travel_time_1 = shortcut:GetTravelTime()
        travel_time_2 = 0
    elseif IsRiverSector(from_sector_id) and IsRiverSector(to_sector_id, "two_way") then
        travel_time_1 = const.Satellite.RiverTravelTime + 1
        travel_time_2 = 0
    end
    local waterTravel = const.Satellite.SectorTravelTimeWater
    if terrain_type1 == "Water" or terrain_type2 == "Water" then
        travel_time_1 = waterTravel / 2
        travel_time_2 = waterTravel / 2
    end
    travel_time_1 = DivCeil(travel_time_1, const.Scale.min) * const.Scale.min
    travel_time_2 = DivCeil(travel_time_2, const.Scale.min) * const.Scale.min
    return travel_time_1 + travel_time_2, travel_time_1, travel_time_2, breakdown
end