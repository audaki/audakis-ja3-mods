
function FirearmBase:GetNumModifiableComponents()
  local n = 0
  for i, slot in ipairs(self.ComponentSlots) do
    local component = self.components[slot.SlotType]
    if component and slot.Modifiable then
      n = n + 1
    end
  end
  return n
end

function FirearmBase:IsFullyModified()
  return self:GetNumAttachedComponents() == self:GetNumModifiableComponents()
end