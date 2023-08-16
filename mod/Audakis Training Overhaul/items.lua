return {
PlaceObj('ModItemCode', {
	'CodeFileName', "Code/Script.lua",
}),
PlaceObj('ModItemOptionChoice', {
	'name', "audaAtoSectorTrainStatCap",
	'DisplayName', "Sector Training Operation Stat Cap",
	'DefaultValue', "80 (Hard, Default)",
	'ChoiceList', {
		"60 (Masochist)",
		"65",
		"70 (Very Hard)",
		"75",
		"80 (Hard, Default)",
		"85 (Balanced)",
		"90 (Easy)",
		"95 (Very Easy)",
		"100 (Piece of Cake)",
	},
}),
PlaceObj('ModItemOptionChoice', {
	'name', "audaAtoSgeGainMod",
	'DisplayName', "TrainBoost GainSpeed",
	'Help', "100% is default balancing<newline><newline>Less is harder<newline>More is easier<newline><newline>This setting is about extra Train Boosts you earn for combat and quest activity, you will still get some Train Boosts statically based on total XP earned",
	'DefaultValue', "50% (Hard, Default)",
	'ChoiceList', {
		"5% (Masochist)",
		"10%",
		"25% (Very Hard)",
		"40%",
		"50% (Hard, Default)",
		"60%",
		"75%",
		"90%",
		"100% (Balanced)",
		"125%",
		"150%",
		"175%",
		"200% (Easy)",
		"300%",
		"400% (Very Easy)",
		"600%",
		"800% (Piece of Cake)",
	},
}),
}
