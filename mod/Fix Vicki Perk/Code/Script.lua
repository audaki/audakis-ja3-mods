
function FirearmBase:GetNumModifiableComponents()
  local n = 0

  local blocked = {}

  for i, slot in ipairs(self.ComponentSlots) do
    local componentId = self.components[slot.SlotType]
    if componentId and WeaponComponents[componentId] then
      component = WeaponComponents[componentId]
      if component and component.BlockSlots and type(component.BlockSlots) == 'table' then
        for i2, blockSlot in ipairs(component.BlockSlots) do
          blocked[blockSlot] = true
        end
      end
    end
  end

  for i, slot in ipairs(self.ComponentSlots) do
    -- Non-modifiable slots broke the perk
    -- Slots with only 1 available component broke the perk
    if slot.Modifiable and (#slot.AvailableComponents >= 2 or slot.CanBeEmpty) and not blocked[slot.SlotType] then
      n = n + 1
    end
  end
  return n
end


function FirearmBase:GetNumAttachedComponents()
  local n = 0

  local blocked = {}

  for i, slot in ipairs(self.ComponentSlots) do
    local componentId = self.components[slot.SlotType]
    if componentId and WeaponComponents[componentId] then
      component = WeaponComponents[componentId]
      if component and component.BlockSlots and type(component.BlockSlots) == 'table' then
        for i2, blockSlot in ipairs(component.BlockSlots) do
          blocked[blockSlot] = true
        end
      end
    end
  end

  for i, slot in ipairs(self.ComponentSlots) do
    local component = self.components[slot.SlotType]
    if component and slot.Modifiable and component ~= slot.DefaultComponent and not blocked[slot.SlotType] then
      n = n + 1
    end
  end
  return n
end

function FirearmBase:IsFullyModified()
  return self:GetNumAttachedComponents() >= self:GetNumModifiableComponents()
end