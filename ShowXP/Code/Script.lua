

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

local mercRolloverEnergyXt = audaFindXtByTextId(XTemplates.PDAMercRollover, 997240698559)
if mercRolloverEnergyXt then
  mercRolloverEnergyXt.ContextUpdateOnOpen = true
  mercRolloverEnergyXt.OnContextUpdate = function(self, context, ...)
    local level = CalcLevel(context.Experience)
    local nextLevel = Min(#XPTable, level + 1)
    self:SetText('XP (Level ' .. level .. ') <right><style PDABrowserTextLightMedium>' .. context.Experience .. ' / ' .. XPTable[nextLevel] .. '</style><newline><left>' .. T(997240698559, "Energy<right><style PDABrowserTextLightMedium><EnergyStatusEffect()></style>"))
    return XContextControl.OnContextUpdate(self, context)
  end
end