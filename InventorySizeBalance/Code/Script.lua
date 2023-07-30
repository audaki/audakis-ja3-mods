if UnitProperties then
	UnitProperties.GetInventoryMaxSlots = function(self)
		return IsMerc(self) and Max(4, (self.Strength - 23) // 3.5) or self.max_dead_slot_tiles or 20
	end
end