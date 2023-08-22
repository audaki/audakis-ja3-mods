
function audaFindXtById(obj, id)
  if (obj.Id or '') == id then
    return obj
  end
  for _, sub in ipairs(obj) do
    local match = audaFindXtById(sub, id)
    if match then
      return match
    end
  end
end


function audaFindXtByTextId(obj, id)
  if obj.Text and TGetID(obj.Text) == id then
    return obj
  end
  for _, sub in ipairs(obj) do
    local match = audaFindXtByTextId(sub, id)
    if match then
      return match
    end
  end
end

function audaFindParentXtByTextId(obj, id)
  if obj.Text and TGetID(obj.Text) == id then
    return obj, true
  end
  for _, sub in ipairs(obj) do
    local match, isDirect = audaFindParentXtByTextId(sub, id)
    if isDirect and match then
      return obj, false
    end
    if match then
      return match, false
    end
  end
end


function OnMsg.ReachSectorCenter(squad_id, sector_id, prev_sector_id)
  if type(const.Satellite.UnitTirednessTravelTimeHP) ~= 'table' then
    return
  end

  local squad = gv_Squads[squad_id]
  local player_squad = IsPlayer1Squad(squad)
  if not player_squad then
    return
  end

  local travelling = IsSquadTravelling(squad) and not IsSquadInDestinationSector(squad)
  local waterTravel = IsSquadWaterTravelling(squad)
  for idx, id in ipairs(squad.units) do
    local unit_data = gv_UnitData[id]
    if unit_data.TravelTimerStart > 0 then
      local hp = unit_data.HitPoints
      local additional = 0
      local const_hp = 75
      if hp > const_hp then
        local persent = hp - const_hp
        additional = MulDivRound(const.Satellite.UnitTirednessTravelTime, persent, 100)
      elseif hp < const_hp then
        local persent = Min(const_hp - hp, 50)
        additional = -MulDivRound(const.Satellite.UnitTirednessTravelTime, persent, 100)
      end
      NetUpdateHash("Tiredness", id, unit_data.TravelTimerStart, hp, additional, unit_data.Tiredness, waterTravel)
      if not waterTravel and unit_data.TravelTime >= const.Satellite.UnitTirednessTravelTime + additional then
        if unit_data.Tiredness < 2 then
          unit_data:ChangeTired(1)
        end
        DbgTravelTimerPrint("change tired: ", unit_data.session_id, unit_data.Tiredness)
        unit_data.TravelTime = 0
        unit_data.TravelTimerStart = Game.CampaignTime
      end
    end
    if not travelling then
      DbgTravelTimerPrint("stop travel: ", unit_data.session_id, unit_data.Operation, unit_data.TravelTime / const.Scale.h)
      unit_data.TravelTimerStart = 0
      if unit_data.Operation == "Idle" or unit_data.Operation == "Traveling" or unit_data.Operation == "Arriving" then
        unit_data:SetCurrentOperation("Idle")
        if unit_data.RestTimer == 0 then
          DbgTravelTimerPrint("start rest: ", unit_data.session_id, unit_data.Operation)
          unit_data.RestTimer = Game.CampaignTime
        end
      end
    end
  end
end


local mercRolloverXt = audaFindParentXtByTextId(XTemplates.PDAMercRollover, 997240698559)
local mercRolloverEnergyXt = audaFindXtByTextId(mercRolloverXt, 997240698559)

local removeTiredXtFn = function()
  for i, p in ipairs(mercRolloverXt) do
    if p.Id == 'audaTiredRest' then
      table.remove(mercRolloverXt, i)
      break
    end
  end
end

if mercRolloverXt and mercRolloverEnergyXt then

  -- Always remove element first if it was added in a previous cycle
  removeTiredXtFn()

  -- Fix margins of sibling element due to FoldWhenHidden
  mercRolloverEnergyXt.Margins = box(0, 0, 0, 1)

  tiredXt = PlaceObj("XTemplateWindow", {
    "__class",
    "XText",
    "Id",
    "audaTiredRest",
    "VAlign",
    "center",
    "Clip",
    false,
    "UseClipBox",
    false,
    "TextStyle",
    "SatelliteContextMenuKeybind",
    "Translate",
    true,
    "ContextUpdateOnOpen",
    true,
    "OnContextUpdate",
    function(self, context, ...)

      if not g_SatelliteUI or IsInventoryOpened() then
        self:SetVisible(false)
        self:SetText('')
        return
      end

      local hp = context.HitPoints
      local additional = 0
      --local const_hp = const.Satellite.UnitTirednessTravelTimeHP
      local const_hp = 75
      if hp > const_hp then
        local percent = hp - const_hp
        additional = MulDivRound(const.Satellite.UnitTirednessTravelTime, percent, 100)
      elseif hp < const_hp then
        local percent = Min(const_hp - hp, 50)
        additional = -MulDivRound(const.Satellite.UnitTirednessTravelTime, percent, 100)
      end

      local travelTime = MulDivRound(context.TravelTime, 10,  const.Scale.h)
      local travelTimeMax = MulDivRound(const.Satellite.UnitTirednessTravelTime + additional, 10, const.Scale.h)
      local travelTimeRemain = travelTimeMax - travelTime

      local restTimer = MulDivRound(Game.CampaignTime - context.RestTimer, 10,  const.Scale.h)
      local restTimerMax = MulDivRound(const.Satellite.UnitTirednessRestTime, 10,  const.Scale.h)
      local restTimerRemain = restTimerMax - restTimer

      local text
      if travelTimeRemain >= 0 then
        text = text .. T{
          '<style SatelliteContextMenuKeybind>Tired In<scale 690> (Travel)<scale 1000></style><right><style PDABrowserTextLightMedium><travelTimeRemain>h<scale 690> (Max: <travelTimeMax>h)<scale 1000></style><newline><left>',
          travelTimeRemain = travelTimeRemain / 10.0,
          travelTime = travelTime / 10,
          travelTimeMax = travelTimeMax / 10,
        }
      else
        text = text .. T{
          '<style SatelliteContextMenuKeybind>Tired In<scale 690> (Travel)<scale 1000></style><right><style PDABrowserTextLightMedium><scale 690>+Tired Incoming<scale 1000></style><newline><left>',
        }
      end

      if context.RestTimer > 0 and restTimerRemain >= 0 then
        text = text .. T{
          '<style SatelliteContextMenuKeybind>Rested In</style><right><style PDABrowserTextLightMedium><restTimerRemain>h<scale 690> (Max: <restTimerMax>h)<scale 1000></style><newline><left>',
          restTimerRemain = restTimerRemain == 120 and 12 or (restTimerRemain / 10.0),
          restTimer = restTimer / 10,
          restTimerMax = restTimerMax / 10,
        }
      elseif context.RestTimer > 0 then
        text = text .. T{
          '<style SatelliteContextMenuKeybind>Rested In</style><right><style PDABrowserTextLightMedium><scale 690>+Rest Incoming<scale 1000></style><newline><left>',
        }
      else
        text = text .. T{
          '<style SatelliteContextMenuKeybind>Rested In</style><right><style PDABrowserTextLightMedium><scale 690>Not Resting Normally<scale 1000></style><newline><left>',
        }
      end

      self:SetVisible(true)
      self:SetText(text)
      return XContextControl.OnContextUpdate(self, context)
    end,
    "FoldWhenHidden",
    true,
    box(1, 0, 1, 0),
    T(997240698559, "Tired/Rest Placeholder")
  })

  table.insert(mercRolloverXt, tiredXt)
end

const.Satellite.UnitTirednessTravelTimeHP = {}

-- Uninstall Routine
function OnMsg.ReloadLua()
  local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
  if not isBeingDisabled then
    return
  end

  -- Remove UI change
  removeTiredXtFn()

  -- Remove bugfix
  const.Satellite.UnitTirednessTravelTimeHP = 75
end