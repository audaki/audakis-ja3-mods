return PlaceObj('ModDef', {
	'title', "Audaki's Sniper Balance (KISS)",
	'description', "Simple Balancing for Sniper Rifles in the way of KISS (= Keep It Simple, Stupid)\n\nThis mod fixes the balancing to Assault Rifles by making Sniper Rifles just as deadly as they are now, but only in the hands of good mercs!\n\nAnd the worse your merc is in Marksmanship (MRK) and Dexterity (DEX), the better an Assault Rifle will be in comparison to the Sniper Rifle.\n\nThis is done by adding a penalty to Sniper Rifles that can be overcome by Marksmanship, Dexterity (half scale) and Aiming Levels.\n\nReal-Life Examples:\n\nA Merc with 100 MRK and 94 DEX can shoot even unaimed Sniper Rifles perfectly\n\nScope will be able to shoot just as well as Vanilla if she adds two Aim Levels, otherwise she will have a miniscule penalty.\n\nBuns will be able to shoot just as well as Vanilla if she adds three Aim Levels, otherwise she will have a small penalty.\n\nKalyna with her starting stats will need to aim three times and still have a small penalty. If Kalyna tries to shoot unaimed she will have a big penalty.",
	'image', "Mod/rRfFoWJ/Images/KISS-sniper-rifle-balance.png",
	'last_changes', "- Improve algorithm (Using MRK, DEX and Aim Levels now)\n\n- Test for many A.I.M. mercs and balance for their starting values\n\n- Add Uninstall Routine",
	'id', "rRfFoWJ",
	'content_path', "Mod/rRfFoWJ/",
	'author', "Audaki_ra",
	'version_major', 2,
	'version', 101,
	'lua_revision', 233360,
	'saved_with_revision', 339125,
	'code', {
		"Code/Script.lua",
	},
	'saved', 1691721725,
	'code_hash', 6856088716052157189,
	'steam_id', "3017322956",
})