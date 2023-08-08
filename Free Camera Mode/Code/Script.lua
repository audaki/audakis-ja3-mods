


function audaFindXtByActionId(obj, actionId)
  if (obj.ActionId or '') == actionId then
    return obj
  end
  for _, sub in ipairs(obj) do
    local match = audaFindXtByActionId(sub, actionId)
    if match then
      return match
    end
  end
end

if FirstLoad then
  local xt = XTemplates['GameShortcuts']
  local sc = audaFindXtByActionId(xt, 'G_CameraChange')
  sc.__condition = nil

  table.insert(xt, audaFindXtByActionId(xt, 'G_HideCombatUI'))
  table.insert(xt, audaFindXtByActionId(xt, 'G_HideWorldCombatUI'))
  table.insert(xt, audaFindXtByActionId(xt, 'ToggleCMT'))
end