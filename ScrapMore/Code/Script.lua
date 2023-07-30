
if InventoryStack then
	InventoryStack.GetScrapParts = function(self)
		if self.class and InventoryItemDefs[self.class] then
			return self.Amount * (InventoryItemDefs[self.class]:GetProperty("ScrapParts") or 0)
		end

		-- else fallback to default function
		local parts = InventoryItem.GetScrapParts(self)
		return parts * self.Amount
	end
end

function audaSetScrap(className, partsNum)
	if _G[className] then
		_G[className].ScrapParts = partsNum
	end
	if InventoryItemDefs[className] then
		InventoryItemDefs[className].ScrapParts = partsNum
	end
end

audaSetScrap('C4', 3)
audaSetScrap('ChippedSapphire', 2)
audaSetScrap('Combination_BalancingWeight', 3)
audaSetScrap('Combination_CeramicPlates', 5)
audaSetScrap('Combination_Detonator_Proximity', 5)
audaSetScrap('Combination_Detonator_Remote', 5)
audaSetScrap('Combination_Detonator_Time', 5)
audaSetScrap('Combination_Sharpener', 3)
audaSetScrap('Combination_WeavePadding', 5)
audaSetScrap('ConcussiveGrenade', 5)
audaSetScrap('FineSteelPipe', 5)
audaSetScrap('FlareStick', 2)
audaSetScrap('FragGrenade', 3)
audaSetScrap('GlowStick', 2)
audaSetScrap('HE_Grenade', 5)
audaSetScrap('Knife', 2)
audaSetScrap('Knife_Balanced', 2)
audaSetScrap('Knife_Sharpened', 2)
audaSetScrap('Microchip', 25)
audaSetScrap('Molotov', 3)
audaSetScrap('MoneyBag', 2)
audaSetScrap('OpticalLens', 5)
audaSetScrap('PETN', 3)
audaSetScrap('PipeBomb', 5)
audaSetScrap('ProximityC4', 8)
audaSetScrap('ProximityPETN', 8)
audaSetScrap('ProximityTNT', 8)
audaSetScrap('RemoteC4', 8)
audaSetScrap('RemotePETN', 8)
audaSetScrap('RemoteTNT', 8)
audaSetScrap('ShapedCharge', 5)
audaSetScrap('SmokeGrenade', 5)
audaSetScrap('TearGasGrenade', 5)
audaSetScrap('TimedC4', 8)
audaSetScrap('TimedPETN', 8)
audaSetScrap('TimedTNT', 8)
audaSetScrap('TNT', 3)
audaSetScrap('ToxicGasGrenade', 5)
audaSetScrap('TreasureFigurine', 3)
audaSetScrap('TreasureGoldenDog', 3)
audaSetScrap('TreasureIdol', 3)
audaSetScrap('TreasureMask', 3)
audaSetScrap('TreasureTablet', 3)