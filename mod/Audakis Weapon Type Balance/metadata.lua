return PlaceObj('ModDef', {
	'title', "Audaki’s Weapon Type Balance",
	'description', "[h1]Compatibility[/h1]\n[h2]JA3 1.1.x ✓Compatible[/h2]\n\n[h1]Audaki’s Burst Fire Balance[/h1]\nChange Burst Fire Balance by changing the damage penalty from -50% to -40%\nThis increases the damage of burst by 20%\n\n[b]=> This makes the game more challenging! (Enemies also use bursts)[/b]\n\nExample:\nAK-47 before\n3x10 = 30 damage per Burst or\n4x10 = 40 damage with Recoil Booster per Burst\nnow\n3x12 = 36 damage per Burst or\n4x12 = 48 damage with Recoil Booster per Burst\n\nThis finally makes the AK-47 in the early game competitive to the G98.\n\n\n2nd Example: FN-FAL now does\n3x18 = 54 damage\n4x18 = 72 damage with recoil booster\n\n(before it was 3x15)\n\nThe total damage curve is now:\n1 bullet: 60% damage\n2 bullets: 120% damage\n3 bullets: 180% damage\n4 bullets: 240% damage\n\nSo if only 2 bullets hit you already make more damage than single shot.\n\n\nThe Change is done in a safe new way, only surgically changing the preset parameter.\nAll Tool-tips should work properly. This includes hovering over the weapon.\n\nThe BurstFire change also applies to enemies, so they hit a little harder as well now.\n\nPS: Auto Fire and Long Bursts (MG, 8 Bullets) are unchanged by this mod.<newline><newline>[h1]Compatibility[/h1]\n[h2]JA3 1.1.x ✓Compatible[/h2]\n\n[h1]Audaki’s Sniper Balance[/h1]\nSimple Balancing for Sniper Rifles in the way of KISS (= Keep It Simple, Stupid)\n\nThis mod fixes the balancing to Assault Rifles by making Sniper Rifles just as deadly as they are now, but only in the hands of good mercs!\n\n[b]=> This makes the game harder![/b]\n\nEnemy NPCs will use the old CtH algorithm, so their difficulty is unchanged.\n\nAnd the worse your merc is in Marksmanship (MRK) and Dexterity (DEX), the better an Assault Rifle will be in comparison to the Sniper Rifle.\n\nThis is done by adding a penalty to Sniper Rifles that can be overcome by Marksmanship, Dexterity (half scale) and Aiming Levels.\n\nReal-Life Examples:\n\nA Merc with 100 MRK and 94 DEX can shoot even unaimed Sniper Rifles perfectly\n\nScope will be able to shoot just as well as Vanilla if she adds two Aim Levels, otherwise she will have a miniscule penalty.\n\nBuns will be able to shoot just as well as Vanilla if she adds three Aim Levels, otherwise she will have a small penalty.\n\nKalyna with her starting stats will need to aim three times and still have a small penalty. If Kalyna tries to shoot unaimed she will have a big penalty.",
	'last_changes', "Metadata",
	'id', "audaWeaponTypeBalance",
	'author', "Audaki_ra",
	'version_major', 2,
	'version_minor', 1,
	'version', 115,
	'lua_revision', 233360,
	'saved_with_revision', 340446,
	'code', {
		"Code/Script.lua",
	},
	'saved', 1692957997,
	'code_hash', -2550087624975448869,
	'steam_id', "3017322956",
	'TagBalancing', true,
	'TagWeapons&Items', true,
})