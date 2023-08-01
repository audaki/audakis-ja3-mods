
CombatActions.Interact_Disarm.GetActionDisplayName = function (self, units)
  for i, u in ipairs(units) do
    if IsKindOf(u, "BoobyTrappable") then
      if u.boobyTrapType == 3 or u.boobyTrapType == 4 then
        return 'Disable Mechanical ' .. u.GetTrapDisplayName()
      end
    end
  end

  return 'Defuse Explosive ' .. u.GetTrapDisplayName()
end