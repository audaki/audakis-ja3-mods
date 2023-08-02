return {
PlaceObj('ModItemCode', {
	'CodeFileName', "Code/Script.lua",
}),
PlaceObj('ModItemOptionChoice', {
	'name', "auda_increaseScrapParts_modifier",
	'DisplayName', "Scrap Parts Amount",
	'Help', "How many parts shall you get for scrapping?<newline><newline>100% = no change<newline>110% = 10% more<newline>200% = double amount",
	'DefaultValue', "200%",
	'ChoiceList', {
		"100%",
		"110%",
		"125%",
		"150%",
		"175%",
		"200%",
		"250%",
		"300%",
		"400%",
	},
}),
}
