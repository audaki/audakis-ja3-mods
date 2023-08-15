return {
PlaceObj('ModItemCode', {
	'CodeFileName', "Code/Script.lua",
}),
PlaceObj('ModItemOptionChoice', {
	'name', "auda_TravelSpeedFix_FastMode",
	'DisplayName', "Travel Speed Mode",
	'Help', "<style PDABrowserTextLightBold>Fast</style><newline>Can be as fast as 100 Vanilla LDR<newline><newline><style PDABrowserTextLightBold>Balanced</style><newline>Well Balanced Travel Speed<newline><newline><style PDABrowserTextLightBold>Normal</style><newline>Middle Ground<newline><newline><style PDABrowserTextLightBold>Hard</style><newline>Balanced around 50-70 Vanilla LDR",
	'DefaultValue', "Normal",
	'ChoiceList', {
		"Fast",
		"Balanced",
		"Normal",
		"Hard",
	},
}),
PlaceObj('ModItemOptionChoice', {
	'name', "auda_TravelSpeedFix_ShowOrigModifier",
	'DisplayName', "Display Vanilla Squad Speed?",
	'Help', "<style PDABrowserTextLightBold>Yes</style><newline>The displayed Speed Bonus will be exactly the same as in Vanilla for the same LDR<newline><newline><style PDABrowserTextLightBold>No</style><newline>The displayed Squad Speed Bonus will be mathematically correct",
	'DefaultValue', "Yes",
	'ChoiceList', {
		"Yes",
		"No",
	},
}),
}
