
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
      local additional = GetHPAdditionalTiredTime(hp)

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

-- Uninstall Routine
function OnMsg.ReloadLua()
  local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
  if not isBeingDisabled then
    return
  end

  -- Remove UI change
  removeTiredXtFn()
end