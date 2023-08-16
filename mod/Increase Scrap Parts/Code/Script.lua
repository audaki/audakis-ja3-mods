

local auda_increaseScrapParts_modifier = tonumber(string.sub(CurrentModOptions['auda_increaseScrapParts_modifier'], 1, -2))

function OnMsg.ApplyModOptions()
  auda_increaseScrapParts_modifier = tonumber(string.sub(CurrentModOptions['auda_increaseScrapParts_modifier'], 1, -2))
end

if InventoryStack then
  InventoryStack.hasIncreasedScrapParts = true
  InventoryStack.GetScrapParts = function(self)
    if self.class and InventoryItemDefs[self.class] then
      return MulDivRound(self.Amount * (InventoryItemDefs[self.class]:GetProperty("ScrapParts") or 0), auda_increaseScrapParts_modifier, 100)
    end

    -- else fallback to default function
    return self.Amount * InventoryItem.GetScrapParts(self)
  end
end

if InventoryItem then
  InventoryItem.hasIncreasedScrapParts = true
  InventoryItem.GetScrapParts = function(self)
    if self.class and InventoryItemDefs[self.class] then
      return MulDivRound((InventoryItemDefs[self.class]:GetProperty("ScrapParts") or 0), auda_increaseScrapParts_modifier, 100)
    end

    -- else fallback to default function
    return MulDivRound(self.ScrapParts, auda_increaseScrapParts_modifier, 100)
  end
end