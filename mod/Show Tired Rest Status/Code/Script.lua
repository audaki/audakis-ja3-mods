
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

if mercRolloverXt then
  removeTiredXtFn()

  mercRolloverEnergyXt.Margins = box(0, 0, 0, 2)

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
      local const_hp = const.Satellite.UnitTirednessTravelTimeHP
      if hp > const_hp then
        local percent = 100 - hp
        additional = MulDivRound(const.Satellite.UnitTirednessTravelTime, percent, 100)
      elseif hp < const_hp then
        local percent = Min(const_hp - hp, 50)
        additional = -MulDivRound(const.Satellite.UnitTirednessTravelTime, percent, 100)
      end

      local travelTime = MulDivRound(context.TravelTime, 1,  const.Scale.h)
      local travelTimeMax = MulDivRound(const.Satellite.UnitTirednessTravelTime + additional, 1, const.Scale.h)
      local travelTimeRemain = travelTimeMax - travelTime

      local restTimer = MulDivRound(Game.CampaignTime - context.RestTimer, 1,  const.Scale.h)
      local restTimerMax = MulDivRound(const.Satellite.UnitTirednessRestTime, 1,  const.Scale.h)
      local restTimerRemain = restTimerMax - restTimer

      local text = T{
        '<style SatelliteContextMenuKeybind>Tired In<scale 690> (Travel)<scale 1000></style><right><style PDABrowserTextLightMedium><travelTimeRemain>h<scale 690> (<travelTime>h<scale 500> / <scale 690><travelTimeMax>h)<scale 1000></style><newline><left>',
        travelTimeRemain = travelTimeRemain,
        travelTime = travelTime,
        travelTimeMax = travelTimeMax,
      }

      text = text .. T{
        '<style SatelliteContextMenuKeybind>Rested In</style><right><style PDABrowserTextLightMedium><restTimerRemain>h<scale 690> (<restTimer>h<scale 500> / <scale 690><restTimerMax>h)<scale 1000></style><newline><left>',
        restTimerRemain = restTimerRemain,
        restTimer = restTimer,
        restTimerMax = restTimerMax,
      }

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




-- Uninstall Routine
function OnMsg.ReloadLua()
  local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
  if isBeingDisabled then
    removeTiredXtFn()
  end
end