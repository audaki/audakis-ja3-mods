return PlaceObj('ModDef', {
	'title', "Burst Fire Balance (Mild)",
	'description', "Change Burst Fire Balance by changing the damage penalty from -50% to -40%\nThis increases the damage of burst by 20%\n\nExample:\nAK-47 before\n3x10 = 30 damage per Burst or\n4x10 = 40 damage with Recoil Booster per Burst\nnow\n3x12 = 36 damage per Burst or\n4x12 = 48 damage with Recoil Booster per Burst\n\nThis finally makes the AK-47 in the early game competitive to the G98.\n\n\n2nd Example: FN-FAL now does\n3x18 = 54 damage\n4x18 = 72 damage with recoil booster\n\n(before it was 3x15)\n\nThe total damage curve is now:\n1 bullet: 60% damage\n2 bullets: 120% damage\n3 bullets: 180% damage\n4 bullets: 240% damage\n\nSo if only 2 bullets hit you already make more damage than single shot.\n\n\nThe Change is done in a safe new way, only surgically changing the preset parameter.\nAll Tool-tips should work properly. This includes hovering over the weapon.\n\nThe BurstFire change also applies to enemies, so they hit a little harder as well now.\n\nPS: Auto Fire and Long Bursts (MG, 8 Bullets) are unchanged by this mod.",
	'image', "Mod/matT6WN/Images/burst-fire-balance.png",
	'last_changes', "Fix metadata",
	'id', "matT6WN",
	'content_path', "Mod/matT6WN/",
	'author', "Audaki_ra",
	'version_major', 1,
	'version', 85,
	'lua_revision', 233360,
	'saved_with_revision', 338408,
	'code', {
		"Code/Script.lua",
	},
	'saved', 1690707319,
	'code_hash', 806217222028708880,
	'screenshot1', "Mod/matT6WN/Images/burst-fire-ss1.png",
	'screenshot2', "Mod/matT6WN/Images/burst-fire-ss2.png",
	'screenshot3', "Mod/matT6WN/Images/burst-fire-ss3.png",
	'screenshot4', "Mod/matT6WN/Images/burst-fire-ss4.png",
	'screenshot5', "Mod/matT6WN/Images/burst-fire-ss5.png",
	'steam_id', "3008954872",
})