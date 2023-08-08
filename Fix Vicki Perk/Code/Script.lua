
function FirearmBase:GetNumModifiableComponents()
  local n = 0
  for i, slot in ipairs(self.ComponentSlots) do
    local component = self.components[slot.SlotType]
    -- Non-modifiable slots broke the perk
    -- Slots with only 1 available component broke the perk
    if component and slot.Modifiable and #slot.AvailableComponents >= 2 then
      n = n + 1
    end
  end
  return n
end

function FirearmBase:IsFullyModified()
  return self:GetNumAttachedComponents() == self:GetNumModifiableComponents()
end