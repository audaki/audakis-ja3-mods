return PlaceObj('ModDef', {
	'title', "Fix Combat never Ending",
	'description', 'Fixes the bug that your combat never ends even when you have no visibility. Especially important for the "Good Place"\n\nCombat should now end when there\'s no enemy visibility for 5 end turns (4 full Rounds).\n\nAlso I\'ve programmed a special Suspicious Mode so it\'s more immersive. After ending the combat this way the enemies will stay in suspicious mode for a while with increased Sight Range.\n\nYou can watch the video how it works: https://www.youtube.com/watch?v=qvvK_vVum0o\n\nCan be safely added and removed at any time.\n\nEnjoy! :-)',
	'image', "Mod/YSygaHA/Images/fix-combat-never-ending.png",
	'last_changes', "Add config for required turn ends to end combat",
	'id', "YSygaHA",
	'content_path', "Mod/YSygaHA/",
	'author', "Audaki_ra",
	'version_major', 1,
	'version_minor', 2,
	'version', 40,
	'lua_revision', 233360,
	'saved_with_revision', 339125,
	'code', {
		"Code/Script.lua",
	},
	'has_options', true,
	'saved', 1691095645,
	'code_hash', -7435575520668440373,
	'steam_id', "3013612894",
})