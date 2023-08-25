

local auda_increaseScrapParts_modifier = 100

local applyLocalOptions = function()
	auda_increaseScrapParts_modifier = tonumber(string.sub(CurrentModOptions['auda_increaseScrapParts_modifier'] or '100%', 1, -2))
end

OnMsg.ApplyModOptions = applyLocalOptions
OnMsg.ModsReloaded = applyLocalOptions

InventoryStack.GetScrapParts = function(self)
	if self.class and InventoryItemDefs[self.class] then
		return MulDivRound(self.Amount * (InventoryItemDefs[self.class]:GetProperty("ScrapParts") or 0), auda_increaseScrapParts_modifier or 100, 100)
	end

	-- else fallback to default function
	return self.Amount * InventoryItem.GetScrapParts(self)
end

InventoryItem.GetScrapParts = function(self)
	if self.class and InventoryItemDefs[self.class] then
		return MulDivRound((InventoryItemDefs[self.class]:GetProperty("ScrapParts") or 0), auda_increaseScrapParts_modifier or 100, 100)
	end

	-- else fallback to default function
	return MulDivRound(self.ScrapParts, auda_increaseScrapParts_modifier or 100, 100)
end

function audaSetScrap(className, partsNum)
	if _G[className] then
		_G[className].ScrapParts = partsNum
	end
	if InventoryItemDefs[className] then
		InventoryItemDefs[className].ScrapParts = partsNum
	end
end

local partsConfig = {
	C4 = 3,
	ChippedSapphire = 2,
	Combination_BalancingWeight = 3,
	Combination_CeramicPlates = 5,
	Combination_Detonator_Proximity = 5,
	Combination_Detonator_Remote = 5,
	Combination_Detonator_Time = 5,
	Combination_Sharpener = 3,
	Combination_WeavePadding = 5,
	ConcussiveGrenade = 5,
	Cookie = 1,
	FineSteelPipe = 5,
	FlareStick = 2,
	FragGrenade = 3,
	GlowStick = 2,
	HE_Grenade = 5,
	HerbalMedicine = 1,
	Knife = 2,
	Knife_Balanced = 2,
	Knife_Sharpened = 2,
	Microchip = 25,
	Molotov = 3,
	MoneyBag = 2,
	OpticalLens = 5,
	PETN = 3,
	PipeBomb = 5,
	ProximityC4 = 8,
	ProximityPETN = 8,
	ProximityTNT = 8,
	RemoteC4 = 8,
	RemotePETN = 8,
	RemoteTNT = 8,
	ShapedCharge = 5,
	SmokeGrenade = 5,
	TearGasGrenade = 5,
	TimedC4 = 8,
	TimedPETN = 8,
	TimedTNT = 8,
	TNT = 3,
	ToxicGasGrenade = 5,
	TreasureFigurine = 3,
	TreasureGoldenDog = 3,
	TreasureIdol = 3,
	TreasureMask = 3,
	TreasureTablet = 3,
}

for className, parts in pairs(partsConfig) do
	if InventoryItemDefs[className] then
		InventoryItemDefs[className].ScrapParts = parts
		InventoryItemDefs[className]:PostLoad()
	end
	if _G[className] then
		_G[className].ScrapParts = parts
	end
end

-- Uninstall Routine
function OnMsg.ReloadLua()
	local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
	if not isBeingDisabled then
		return
	end

	for className, parts in pairs(partsConfig) do
		if InventoryItemDefs[className] then
			InventoryItemDefs[className].ScrapParts = nil
			InventoryItemDefs[className]:PostLoad()
		end
		if _G[className] then
			_G[className].ScrapParts = nil
		end
	end

	auda_increaseScrapParts_modifier = 100

	CreateRealTimeThread(function()
		Sleep(5000)

		InventoryStack.GetScrapParts = function(self)
			if self.class and InventoryItemDefs[self.class] then
				local parts = InventoryItemDefs[self.class]:GetProperty("ScrapParts")
				return parts and self.Amount * parts or nil
			end

			-- else fallback to default function
			return self.Amount * InventoryItem.GetScrapParts(self)
		end

		InventoryItem.GetScrapParts = function(self)
			if self.class and InventoryItemDefs[self.class] then
				return InventoryItemDefs[self.class]:GetProperty("ScrapParts") or nil
			end

			-- else fallback to default function
			return self.ScrapParts
		end
	end)

end