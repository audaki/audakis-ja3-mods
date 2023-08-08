
function FirearmBase:GetNumModifiableComponents()
  local n = 0
  for i, slot in ipairs(self.ComponentSlots) do
    -- Non-modifiable slots broke the perk
    -- Slots with only 1 available component broke the perk
    if slot.Modifiable and (#slot.AvailableComponents >= 2 or slot.CanBeEmpty) then
      n = n + 1
    end
  end
  return n
end

function FirearmBase:IsFullyModified()
  return self:GetNumAttachedComponents() >= self:GetNumModifiableComponents()
end