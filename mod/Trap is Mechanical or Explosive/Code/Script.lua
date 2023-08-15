CombatActions.Interact_Disarm.GetActionDisplayName = function(self, units)
  local trapName = T(726087963038, "Trap")
  local isMechanical = false

  for i, u in ipairs(units) do
    if u.GetTrapDisplayName then
      trapName = u:GetTrapDisplayName()
    end
  end

  for i, u in ipairs(units) do
    if IsKindOf(u, "BoobyTrappable") and (u.boobyTrapType or 0) >= 1 then
      if u.boobyTrapType == 3 or u.boobyTrapType == 4 then
        isMechanical = true
      end
      if u.GetTrapDisplayName then
        trapName = u:GetTrapDisplayName()
      end

    end
  end

  return T({ 0, '<type_prefix> <trap_in><trap_name>',
             type_prefix = isMechanical and 'Disable Mechanical' or 'Defuse Explosive',
             trap_in = TGetID(trapName) ~= 726087963038 and 'Trap in ' or '',
             trap_name = trapName
  })
end